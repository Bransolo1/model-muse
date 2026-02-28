# =============================================================================
# sensehub::run_app() — Launch the Sensehub AutoM/L Shiny app
# =============================================================================
# Use from the project root (folder containing launch_sensehub.R):
#   devtools::load_all(".")
#   sensehub::run_app()
# Or after installing: install.packages("remotes"); remotes::install_github("Bransolo1/model-muse")
#   sensehub::run_app()   # still requires wd = project root for repo layout
# =============================================================================

#' Launch Sensehub AutoM/L
#'
#' Validates the setup (structure, packages, config) then starts the Shiny app.
#' Working directory must be the project root (the folder that contains
#' \code{launch_sensehub.R} and \code{shiny-app/}).
#'
#' @export
run_app <- function() {
  if (!file.exists("launch_sensehub.R")) {
    stop(
      "Working directory must be the Sensehub project root (folder containing launch_sensehub.R). ",
      "Open the project in RStudio (File -> Open Project) or setwd() to that folder, then run sensehub::run_app()."
    )
  }
  source("launch_sensehub.R", local = FALSE)
}
