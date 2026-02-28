# ============================================================================
# utils_logging.R — Structured logging for Sensehub
# ============================================================================
# Lightweight structured logging using message() for compatibility with
# all deployment targets. When possible, also appends to a date-named log file
# in the user's Sensehub log directory (see get_log_file_path()).

#' Return the Sensehub log directory (platform-specific)
#' Creates the directory if it doesn't exist; returns NULL if creation fails.
get_sensehub_log_dir <- function() {
  if (.Platform$OS.type == "windows") {
    base <- Sys.getenv("LOCALAPPDATA", NA_character_)
    if (is.na(base) || !nzchar(base)) base <- Sys.getenv("USERPROFILE", "~")
    log_dir <- file.path(base, "Sensehub", "logs")
  } else {
    base <- Sys.getenv("XDG_DATA_HOME", NA_character_)
    if (is.na(base) || !nzchar(base)) {
      base <- path.expand("~/.local/share")
    }
    log_dir <- file.path(base, "Sensehub", "logs")
    if (Sys.info()["sysname"] == "Darwin") {
      log_dir <- path.expand("~/Library/Application Support/Sensehub/logs")
    }
  }
  if (!dir.exists(log_dir)) {
    ok <- tryCatch(dir.create(log_dir, recursive = TRUE, showWarnings = FALSE),
                  error = function(e) FALSE)
    if (!ok) return(NULL)
  }
  log_dir
}

#' Path to today's log file (for UI messages: "See log at ...")
#' Returns NULL if file logging is not available.
get_log_file_path <- function() {
  log_dir <- get_sensehub_log_dir()
  if (is.null(log_dir)) return(NULL)
  fname <- paste0("sensehub_", format(Sys.time(), "%Y-%m-%d"), ".log")
  file.path(log_dir, fname)
}

#' Initialise the application logger
#' Call once at startup in global.R
init_logging <- function() {
  app_log("info", "Sensehub AutoM/L starting",
          list(r_version = R.version.string,
               pid = Sys.getpid(),
               time = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")))
}


#' Structured log message
#' @param level One of "info", "warn", "error", "debug"
#' @param msg The log message
#' @param data Optional named list of key-value pairs for context
app_log <- function(level = "info", msg, data = NULL) {
  level <- match.arg(level, c("info", "warn", "error", "debug"))

  log_entry <- list(
    ts    = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
    level = toupper(level),
    msg   = msg
  )

  if (!is.null(data) && is.list(data)) {
    # Scrub any sensitive fields
    sensitive_keys <- c("password", "token", "secret", "key", "credential", "api_key")
    for (k in names(data)) {
      if (tolower(k) %in% sensitive_keys) {
        data[[k]] <- "[REDACTED]"
      }
    }
    log_entry$data <- data
  }

  json_line <- tryCatch(
    jsonlite::toJSON(log_entry, auto_unbox = TRUE, null = "null"),
    error = function(e) paste0('{"level":"ERROR","msg":"Log serialisation failed: ', e$message, '"}')
  )

  # Use message() for Shiny-compatible logging (goes to stderr → captured by deployment platforms)
  message(json_line)

  # Append to date-named log file when possible (for support / troubleshooting)
  log_dir <- get_sensehub_log_dir()
  if (!is.null(log_dir)) {
    fpath <- file.path(log_dir, paste0("sensehub_", format(Sys.time(), "%Y-%m-%d"), ".log"))
    tryCatch(
      cat(json_line, "\n", file = fpath, append = TRUE),
      error = function(e) NULL
    )
  }
}


#' Log a user action (expensive operations)
log_user_action <- function(action, session_id = NULL, details = NULL) {
  data <- list(action = action)
  if (!is.null(session_id)) data$session <- substr(session_id, 1, 8)  # truncate for privacy
  if (!is.null(details)) data <- c(data, details)
  app_log("info", paste("User action:", action), data)
}


#' Log an error with optional stack trace
log_error <- function(msg, error = NULL, context = NULL) {
  data <- list()
  if (!is.null(context)) data$context <- context
  if (!is.null(error)) {
    data$error_class <- class(error)[1]
    data$error_msg <- conditionMessage(error)
    # Don't include full stack trace in production to avoid leaking internals
    # but do include the call
    if (!is.null(error$call)) {
      data$call <- deparse(error$call, width.cutoff = 100)[1]
    }
  }
  app_log("error", msg, data)
}


#' Timed operation wrapper — logs elapsed time
timed_operation <- function(label, expr) {
  start <- Sys.time()
  result <- tryCatch(
    force(expr),
    error = function(e) {
      elapsed <- as.numeric(difftime(Sys.time(), start, units = "secs"))
      log_error(paste(label, "failed after", round(elapsed, 2), "s"), error = e)
      stop(e)
    }
  )
  elapsed <- as.numeric(difftime(Sys.time(), start, units = "secs"))
  app_log("info", paste(label, "completed"),
          list(elapsed_secs = round(elapsed, 2)))
  result
}
