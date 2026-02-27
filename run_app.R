# =============================================================================
# Run the Sensehub AutoM/L app from RStudio
# =============================================================================
# 1. Open this project in RStudio (File → Open Project → choose this folder).
# 2. Run this script: source("run_app.R") or click "Source" / Run in the editor.
# 3. The Shiny app will open in your browser or the Viewer pane.
#
# First time: install required packages (see RUN_FROM_RSTUDIO.md or run
# install.packages(c("shiny", "bslib", "DT", "shinyWidgets", "shinyjs", ...))
# =============================================================================

shiny_app_dir <- "shiny-app"
if (!dir.exists(shiny_app_dir)) {
  stop(
    "Folder 'shiny-app' not found. ",
    "Make sure you have the full codebase (e.g. clone from GitHub)."
  )
}
server_file <- file.path(shiny_app_dir, "server.R")
if (!file.exists(server_file)) {
  stop(
    "Shiny app not found in 'shiny-app/' (missing server.R). ",
    "Clone the full repository from GitHub: https://github.com/Bransolo1/model-muse"
  )
}

# Run from project root so global.R can use setwd("shiny-app")-relative paths
# Shiny expects to be run with working directory = app directory
owd <- setwd(shiny_app_dir)
on.exit(setwd(owd), add = TRUE)

if (!requireNamespace("shiny", quietly = TRUE)) {
  stop(
    "Package 'shiny' is not installed. ",
    "Install required packages first — see RUN_FROM_RSTUDIO.md for the full list, then run: install.packages(c(\"shiny\", \"bslib\", ...))"
  )
}

message("Launching Sensehub AutoM/L (Shiny app)...")
# 127.0.0.1 = localhost only (no network exposure; best for corporate / no-IT delivery)
shiny::runApp(host = "127.0.0.1", launch.browser = TRUE)
