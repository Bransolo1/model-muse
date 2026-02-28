# =============================================================================
# Run the Sensehub AutoM/L app from RStudio
# =============================================================================
# 1. Open this project in RStudio (File → Open Project → choose this folder).
# 2. In the R CONSOLE (bottom), run: source("run_app.R")
#    Or: source("run_app.R", echo = TRUE)  to see each line as it runs.
# 3. The Shiny app will open in your browser or the Viewer pane.
#
# First time: install required packages (see RUN_FROM_RSTUDIO.md or run
# install.packages(c("shiny", "bslib", "DT", "shinyWidgets", "shinyjs", ...))
# =============================================================================

cat("Run app: starting...\n")
flush.console()

# If "shiny-app" not found, try switching to the project folder (e.g. when not opened as RStudio project)
if (!dir.exists("shiny-app")) {
  project_dir <- Sys.getenv("SENSEHUB_PROJECT_DIR", "")
  if (nzchar(project_dir) && dir.exists(project_dir) && dir.exists(file.path(project_dir, "shiny-app"))) {
    setwd(project_dir)
    cat("Changed working directory to project folder.\n")
  }
}

shiny_app_dir <- "shiny-app"
if (!dir.exists(shiny_app_dir)) {
  stop(
    "Folder 'shiny-app' not found. Current directory: ", getwd(), ". ",
    "Open the project in RStudio (File → Open Project) or setwd() to the project folder."
  )
}
server_file <- file.path(shiny_app_dir, "server.R")
if (!file.exists(server_file)) {
  stop(
    "Shiny app not found in 'shiny-app/' (missing server.R). ",
    "Clone the full repository from GitHub: https://github.com/Bransolo1/model-muse"
  )
}

# Use absolute path to app dir so Shiny finds server.R/ui.R regardless of working directory
app_dir <- normalizePath(shiny_app_dir, winslash = "/", mustWork = TRUE)
# Run with app dir as working directory so global.R and relative paths work
owd <- setwd(app_dir)
on.exit(setwd(owd), add = TRUE)

if (!requireNamespace("shiny", quietly = TRUE)) {
  stop(
    "Package 'shiny' is not installed. ",
    "Install required packages first — see RUN_FROM_RSTUDIO.md for the full list, then run: install.packages(c(\"shiny\", \"bslib\", ...))"
  )
}

cat("Launching Sensehub AutoM/L (Shiny app)...\n")
flush.console()
# 127.0.0.1 = localhost only (no network exposure; best for corporate / no-IT delivery)
# Use port 3840 (3838 often still in use from a previous run)
shiny::runApp(appDir = app_dir, host = "127.0.0.1", port = 3840L, launch.browser = TRUE)
