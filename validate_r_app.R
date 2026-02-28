# =============================================================================
# Validate Sensehub AutoM/L R/Shiny setup
# Run from RStudio: in the Console, source("validate_r_app.R") (with project root as working dir)
# =============================================================================

cat("Validating Sensehub AutoM/L R setup...\n")

ok <- TRUE

# 1. Check shiny-app folder
shiny_app_dir <- "shiny-app"
if (!dir.exists(shiny_app_dir)) {
  cat("  FAIL: Folder 'shiny-app' not found.\n")
  ok <- FALSE
} else {
  cat("  OK: Folder 'shiny-app' exists.\n")
}

# 2. Check server.R
server_file <- file.path(shiny_app_dir, "server.R")
if (!file.exists(server_file)) {
  cat("  FAIL: 'shiny-app/server.R' not found (need full repo from GitHub).\n")
  ok <- FALSE
} else {
  cat("  OK: server.R found.\n")
}

# 3. Check shiny package
if (!requireNamespace("shiny", quietly = TRUE)) {
  cat("  FAIL: Package 'shiny' not installed. See RUN_FROM_RSTUDIO.md.\n")
  ok <- FALSE
} else {
  cat("  OK: Package 'shiny' is installed.\n")
}

# 4. Optional: check run_app.R exists
if (!file.exists("run_app.R")) {
  cat("  FAIL: run_app.R not found in project root.\n")
  ok <- FALSE
} else {
  cat("  OK: run_app.R found.\n")
}

if (ok) {
  cat("\nAll checks passed. Run the app with: source('run_app.R') in the RStudio Console.\n")
} else {
  cat("\nSome checks failed. Fix the issues above before running the app.\n")
}
if (!interactive()) quit(status = if (ok) 0 else 1)
