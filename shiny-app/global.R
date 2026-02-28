# ============================================================================
# Shiny AutoML Wizard — global.R
# Load all packages, source helpers, initialise config and logging.
# ============================================================================

# ---- Load config & logging FIRST (before any other sourcing) ----
source("R/config.R",           local = FALSE)
source("R/utils_logging.R",    local = FALSE)
source("R/utils_validation.R", local = FALSE)

# Initialise application config from environment variables
APP_CONFIG <- load_app_config()
options(sensehub.config = APP_CONFIG)

# ---- rlang version advisory ----
if (requireNamespace("rlang", quietly = TRUE) &&
    utils::packageVersion("rlang") > "1.1.6") {
  message(sprintf(
    "[WARN] rlang %s detected. This app was tested with rlang <= 1.1.6. If you encounter issues, run: remotes::install_version('rlang', version = '1.1.6')",
    as.character(utils::packageVersion("rlang"))
  ))
}

# ---- Suppress startup messages to speed up launch ----
suppressPackageStartupMessages({

# ---- Core Shiny & UI ----
library(shiny)
library(bslib)
library(DT)
library(shinyWidgets)
library(shinyjs)

# ---- Tidymodels ecosystem ----
library(tidymodels)
library(recipes)
library(parsnip)
library(workflows)
library(workflowsets)
library(tune)
library(rsample)
library(yardstick)
library(dials)
library(stacks)
library(probably)

# ---- Model engines ----
library(glmnet)
library(ranger)
library(xgboost)
library(kknn)
library(kernlab)
library(discrim)
library(naivebayes)
library(rpart)

# ---- Async execution ----
library(promises)
library(future)

tryCatch({
  n_cores <- if (requireNamespace("parallelly", quietly = TRUE)) {
    parallelly::availableCores()
  } else {
    1L
  }
  plan(multisession, workers = min(APP_CONFIG$max_workers, n_cores))
}, error = function(e) {
  app_log("warn", "future::plan(multisession) failed — falling back to sequential",
          list(error = e$message))
  plan(sequential)
})

# ---- Utilities ----
library(dplyr)
library(tidyr)
library(purrr)
library(readr)
library(forcats)
library(readxl)
library(lubridate)
library(ggplot2)
library(jsonlite)

})

# ---- Source modules & helpers ----
source("R/fn_modeling.R",    local = FALSE)
source("R/fn_export.R",     local = FALSE)
source("R/mod_upload.R",    local = FALSE)
source("R/mod_configure.R", local = FALSE)
source("R/mod_advanced.R",  local = FALSE)
source("R/mod_results.R",   local = FALSE)

# ---- Global seed for reproducibility ----
GLOBAL_SEED <- APP_CONFIG$global_seed
set.seed(GLOBAL_SEED)

# ---- MARS availability flag ----
HAS_EARTH <- requireNamespace("earth", quietly = TRUE)

# ---- Set upload size limit from config ----
options(shiny.maxRequestSize = APP_CONFIG$max_upload_mb * 1024^2)

# ---- Initialise logging ----
init_logging()
app_log("info", "Global environment loaded", list(
  seed = GLOBAL_SEED,
  max_upload_mb = APP_CONFIG$max_upload_mb,
  allow_rds = APP_CONFIG$allow_rds_upload,
  workers = APP_CONFIG$max_workers,
  has_earth = HAS_EARTH
))
