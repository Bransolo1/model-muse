# Configuration Management Functions
# Load app settings from environment variables with sensible defaults
load_config <- function() {
  list(
    db_host = Sys.getenv("DB_HOST", "localhost"),
    db_user = Sys.getenv("DB_USER", "user"),
    db_password = Sys.getenv("DB_PASSWORD", "password"),
    app_port = as.numeric(Sys.getenv("APP_PORT", "8080")),
    log_level = Sys.getenv("LOG_LEVEL", "info")
  )
}
