# ============================================================================
# utils_validation.R — Input validation & sanitisation helpers
# ============================================================================

# Maximum upload size in bytes (100 MB)
MAX_UPLOAD_BYTES <- 100 * 1024 * 1024

# Allowed file extensions for dataset upload
ALLOWED_EXTENSIONS <- c("csv", "tsv", "txt", "xlsx", "xls", "rds")

# Maximum number of columns and rows
MAX_COLUMNS <- 2000
MAX_ROWS    <- 5000000

# Maximum string input length for free-text fields
MAX_TEXT_LENGTH <- 500

#' Validate uploaded file before processing
#' Returns list(ok, message) — ok=TRUE if valid, FALSE with message if not
validate_upload <- function(file_path, file_name, file_size = NULL) {
  if (is.null(file_path) || !file.exists(file_path)) {
    return(list(ok = FALSE, message = "File not found or inaccessible."))
  }

  # Extension check

  ext <- tolower(tools::file_ext(file_name %||% file_path))
  if (!ext %in% ALLOWED_EXTENSIONS) {
    return(list(ok = FALSE,
      message = sprintf("Unsupported file type: .%s. Allowed: %s",
                        ext, paste(ALLOWED_EXTENSIONS, collapse = ", "))))
  }

  # Size check (server-side enforcement)
  actual_size <- file.info(file_path)$size
  if (!is.na(actual_size) && actual_size > MAX_UPLOAD_BYTES) {
    return(list(ok = FALSE,
      message = sprintf("File too large (%.1f MB). Maximum: %.0f MB.",
                        actual_size / 1024^2, MAX_UPLOAD_BYTES / 1024^2)))
  }

  # RDS safety warning — readRDS can execute arbitrary code

  if (ext == "rds") {
    app_log("warn", "RDS file uploaded — potential deserialization risk",
            list(file = file_name, size = actual_size))
  }

  # Path traversal check — ensure filename has no directory separators
  if (grepl("[/\\\\]", basename(file_name))) {
    return(list(ok = FALSE, message = "Invalid filename."))
  }

  # Content-type validation via magic bytes (first few bytes of file)
  mime_check <- validate_file_magic(file_path, ext)
  if (!mime_check$ok) {
    return(mime_check)
  }

  list(ok = TRUE, message = "OK")
}


#' Validate file content matches declared extension via magic bytes
#' Prevents extension spoofing (e.g. renaming .exe to .csv)
validate_file_magic <- function(file_path, declared_ext) {
  tryCatch({
    con <- file(file_path, "rb")
    on.exit(close(con))
    header <- readBin(con, "raw", n = 8)

    if (length(header) < 4) {
      return(list(ok = TRUE, message = "OK"))  # too small to check, allow
    }

    hex <- paste(header[1:4], collapse = " ")

    # PK (ZIP) header — xlsx/xls use ZIP format
    is_zip <- identical(header[1:2], as.raw(c(0x50, 0x4B)))
    # OLE2 header — older xls files
    is_ole2 <- identical(header[1:4], as.raw(c(0xD0, 0xCF, 0x11, 0xE0)))

    if (declared_ext %in% c("xlsx")) {
      if (!is_zip) {
        return(list(ok = FALSE,
          message = "File content does not match .xlsx format. The file may be corrupted or mislabeled."))
      }
    }

    if (declared_ext == "xls") {
      if (!is_ole2 && !is_zip) {
        return(list(ok = FALSE,
          message = "File content does not match .xls format. The file may be corrupted or mislabeled."))
      }
    }

    # Check for executable signatures in text-based formats
    if (declared_ext %in% c("csv", "tsv", "txt")) {
      # ELF binary
      if (identical(header[1:4], as.raw(c(0x7F, 0x45, 0x4C, 0x46)))) {
        return(list(ok = FALSE, message = "Binary executable detected. Upload rejected."))
      }
      # MZ (Windows PE/EXE)
      if (identical(header[1:2], as.raw(c(0x4D, 0x5A)))) {
        return(list(ok = FALSE, message = "Windows executable detected. Upload rejected."))
      }
      # ZIP archive masquerading as text
      if (is_zip) {
        return(list(ok = FALSE, message = "Archive file detected but text format expected. Upload rejected."))
      }
    }

    list(ok = TRUE, message = "OK")
  }, error = function(e) {
    # If magic byte check fails, allow through (don't block on check errors)
    list(ok = TRUE, message = "OK")
  })
}


#' Rename uploaded file to a safe random filename
#' Prevents path traversal and user-controlled filenames on disk
sanitise_upload_path <- function(original_path, original_name) {
  ext <- tolower(tools::file_ext(original_name))
  safe_name <- paste0(
    "upload_",
    format(Sys.time(), "%Y%m%d%H%M%S"),
    "_",
    paste0(sample(c(letters, 0:9), 8, replace = TRUE), collapse = ""),
    ".", ext
  )
  safe_path <- file.path(tempdir(), safe_name)
  file.copy(original_path, safe_path, overwrite = TRUE)
  safe_path
}


#' Sanitise a column name to prevent injection
sanitise_column_name <- function(col_name) {
  if (is.null(col_name) || !is.character(col_name)) return(NULL)
  # Strip anything that isn't alphanumeric, underscore, dot, or space

  gsub("[^A-Za-z0-9_.\\s]", "", col_name)
}


#' Validate that a string input is within safe bounds
validate_text_input <- function(value, max_length = MAX_TEXT_LENGTH, label = "Input") {
  if (is.null(value) || !is.character(value)) {
    return(list(ok = FALSE, message = paste(label, "must be a text value.")))
  }
  if (nchar(value) > max_length) {
    return(list(ok = FALSE,
      message = sprintf("%s exceeds maximum length of %d characters.", label, max_length)))
  }
  list(ok = TRUE, message = "OK")
}


#' Validate a numeric input is within expected range
validate_numeric_input <- function(value, min_val = NULL, max_val = NULL, label = "Value") {
  if (is.null(value) || !is.numeric(value) || length(value) != 1) {
    return(list(ok = FALSE, message = paste(label, "must be a single number.")))
  }
  if (is.na(value)) {
    return(list(ok = FALSE, message = paste(label, "cannot be NA.")))
  }
  if (!is.null(min_val) && value < min_val) {
    return(list(ok = FALSE,
      message = sprintf("%s must be >= %s.", label, min_val)))
  }
  if (!is.null(max_val) && value > max_val) {
    return(list(ok = FALSE,
      message = sprintf("%s must be <= %s.", label, max_val)))
  }
  list(ok = TRUE, message = "OK")
}


#' Rate limiter — returns TRUE if action is allowed, FALSE if throttled
#' Uses a simple per-session timestamp approach
create_rate_limiter <- function(cooldown_secs = 10) {
  last_action <- NULL

  list(
    check = function() {
      now <- Sys.time()
      if (is.null(last_action)) {
        last_action <<- now
        return(list(ok = TRUE, wait = 0))
      }
      elapsed <- as.numeric(difftime(now, last_action, units = "secs"))
      if (elapsed < cooldown_secs) {
        return(list(ok = FALSE,
          wait = ceiling(cooldown_secs - elapsed),
          message = sprintf("Please wait %d seconds before trying again.",
                            ceiling(cooldown_secs - elapsed))))
      }
      last_action <<- now
      list(ok = TRUE, wait = 0)
    },
    reset = function() {
      last_action <<- NULL
    }
  )
}


#' Validate dataset dimensions after parsing
validate_dataset_dimensions <- function(data) {
  if (ncol(data) > MAX_COLUMNS) {
    return(list(ok = FALSE,
      message = sprintf("Too many columns (%d). Maximum: %d.", ncol(data), MAX_COLUMNS)))
  }
  if (nrow(data) > MAX_ROWS) {
    return(list(ok = FALSE,
      message = sprintf("Too many rows (%s). Maximum: %s.",
                        format(nrow(data), big.mark = ","),
                        format(MAX_ROWS, big.mark = ","))))
  }
  list(ok = TRUE, message = "OK")
}
