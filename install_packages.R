# Install all packages required by Sensehub AutoM/L
# Run from RStudio: in the Console, source("install_packages.R")
options(repos = c(CRAN = "https://cloud.r-project.org"))
cat("Installing R packages for Sensehub AutoM/L...\n")
pkgs <- c(
  "shiny", "bslib", "DT", "shinyWidgets", "shinyjs",
  "tidymodels", "recipes", "parsnip", "workflows", "workflowsets",
  "tune", "rsample", "yardstick", "dials", "stacks", "probably",
  "glmnet", "ranger", "xgboost", "kknn", "kernlab", "discrim", "naivebayes", "rpart",
  "promises", "future",
  "dplyr", "tidyr", "purrr", "readr", "forcats", "readxl", "lubridate",
  "ggplot2", "jsonlite", "vip", "themis"
)
install.packages(pkgs, dependencies = TRUE, quiet = FALSE)
cat("Done.\n")
