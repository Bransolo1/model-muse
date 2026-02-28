# Configuration for Shiny Application

# Load environment variables from .env file (use dotenv package)
library(dotenv)
load_dotenv()

# Default configuration values
config <- list(
  port = as.integer(Sys.getenv("PORT", "1234")),
  host = Sys.getenv("HOST", "0.0.0.0"),
  debug = as.logical(Sys.getenv("DEBUG", "FALSE")),
  db_host = Sys.getenv("DB_HOST", "localhost"),
  db_port = as.integer(Sys.getenv("DB_PORT", "3306")),
  db_name = Sys.getenv("DB_NAME", "my_database"),
  db_user = Sys.getenv("DB_USER", "user"),
  db_password = Sys.getenv("DB_PASSWORD", "password") 
)

# Validate configuration values
validate_config <- function(config) {
  if (is.null(config$host) || config$host == "") {
    stop("ERROR: HOST must be set.")
  }
  if (is.null(config$db_name) || config$db_name == "") {
    stop("ERROR: DB_NAME must be set.")
  }
  if (is.null(config$db_user) || config$db_user == "") {
    stop("ERROR: DB_USER must be set.")
  }
  # Add more validations as necessary
}

# Run validation
validate_config(config)

# Export configuration
return(config)