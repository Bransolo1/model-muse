# =============================================================================
# Launch Sensehub AutoM/L — validate first, then run the app
# =============================================================================
# One script to rule them all: run this instead of validate_r_app.R + run_app.R
#
# In RStudio Console:  source("launch_sensehub.R")
#
# What it does:
#   1. Runs the same checks as validate_r_app.R (structure, packages, load test).
#   2. If any check fails, it stops and tells you what to fix (see TROUBLESHOOTING.md).
#   3. If all pass, it starts the Shiny app (same as run_app.R).
#
# First time: run source("install_packages.R") once, then source("launch_sensehub.R").
# =============================================================================

cat("Sensehub launcher: validating...\n")
flush.console()

# Ensure we're in project root (same logic as run_app.R)
if (!dir.exists("shiny-app")) {
  project_dir <- Sys.getenv("SENSEHUB_PROJECT_DIR", "")
  if (nzchar(project_dir) && dir.exists(project_dir) && dir.exists(file.path(project_dir, "shiny-app"))) {
    setwd(project_dir)
    cat("Changed working directory to project folder.\n")
  }
}

# Signal we're sourcing validation (so validate_r_app.R won't quit when non-interactive, e.g. .bat)
options(sensehub.validate.sourced = TRUE)
on.exit(options(sensehub.validate.sourced = NULL), add = TRUE)
source("validate_r_app.R")

if (exists("ok") && !ok) {
  stop(
    "Validation failed. Fix the issues above, then run source(\"launch_sensehub.R\") again. ",
    "See TROUBLESHOOTING.md for help."
  )
}

cat("\nValidation passed. Starting app...\n")
flush.console()
source("run_app.R")
