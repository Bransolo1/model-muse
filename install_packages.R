# =============================================================================
# Install all packages required by Sensehub AutoM/L
# Run from RStudio: in the Console, source("install_packages.R")
# =============================================================================
options(repos = c(CRAN = "https://cloud.r-project.org"))
cat("Installing R packages for Sensehub AutoM/L...\n")

# Core Shiny & UI
pkgs_shiny <- c("shiny", "bslib", "DT", "shinyWidgets", "shinyjs")

# Tidymodels ecosystem (install tidymodels meta-package first for correct deps)
pkgs_tidymodels <- c(
  "tidymodels", "recipes", "parsnip", "workflows", "workflowsets",
  "tune", "rsample", "yardstick", "dials", "stacks", "probably"
)

# Model engines
pkgs_models <- c(
  "glmnet", "ranger", "xgboost", "kknn", "kernlab", "discrim", "naivebayes", "rpart"
)

# Async & parallel
pkgs_async <- c("promises", "future", "parallelly")

# Data & viz
pkgs_data <- c(
  "dplyr", "tidyr", "purrr", "readr", "forcats", "readxl", "lubridate",
  "ggplot2", "jsonlite", "vip", "themis"
)

# Optional: dotenv for .env file support (config.R uses it if present)
pkgs_optional <- c("dotenv")

pkgs <- c(pkgs_shiny, pkgs_tidymodels, pkgs_models, pkgs_async, pkgs_data, pkgs_optional)
install.packages(pkgs, dependencies = TRUE, quiet = FALSE)

cat("Done. Optional: install.packages('earth') for MARS models.\n")
