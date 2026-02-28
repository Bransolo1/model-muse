# Configuration for Sensehub AutoM/L Shiny Application
# Optional: load .env via dotenv if installed; otherwise use Sys.getenv() only.

if (requireNamespace("dotenv", quietly = TRUE)) {
  tryCatch(dotenv::load_dotenv(), error = function(e) NULL)
}

load_app_config <- function() {
  list(
    global_seed       = as.integer(Sys.getenv("GLOBAL_SEED", "42")),
    max_upload_mb     = as.numeric(Sys.getenv("MAX_UPLOAD_MB", "50")),
    allow_rds_upload  = as.logical(Sys.getenv("ALLOW_RDS_UPLOAD", "FALSE")),
    max_workers       = as.integer(Sys.getenv("MAX_WORKERS", "2")),
    rate_limit_secs   = as.numeric(Sys.getenv("RATE_LIMIT_SECS", "15"))
  )
}

APP_CONFIG <- load_app_config()

#' Read a value from app config (set in global.R via options(sensehub.config = APP_CONFIG))
app_config <- function(key) {
  cfg <- getOption("sensehub.config")
  if (is.null(cfg)) return(NULL)
  cfg[[key]]
}
