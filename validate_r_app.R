# =============================================================================
# Validate Sensehub AutoM/L R/Shiny setup
# Run from RStudio: source("validate_r_app.R") (with project root as working dir)
# =============================================================================

cat("Validating Sensehub AutoM/L R setup...\n\n")

ok <- TRUE

# 1. Project structure
cat("1. Project structure\n")
if (!dir.exists("shiny-app")) {
  cat("   FAIL: Folder 'shiny-app' not found.\n")
  ok <- FALSE
} else {
  cat("   OK: shiny-app/\n")
}

required_files <- c(
  "run_app.R",
  "shiny-app/server.R",
  "shiny-app/ui.R",
  "shiny-app/global.R",
  "shiny-app/R/config.R",
  "shiny-app/R/utils_logging.R",
  "shiny-app/R/utils_validation.R",
  "shiny-app/R/modeling.R",
  "shiny-app/R/export.R",
  "shiny-app/R/mod_upload.R",
  "shiny-app/R/mod_configure.R",
  "shiny-app/R/mod_advanced.R",
  "shiny-app/R/mod_results.R"
)
for (f in required_files) {
  if (!file.exists(f)) {
    cat("   FAIL: ", f, " not found.\n", sep = "")
    ok <- FALSE
  }
}
if (ok) cat("   OK: All required files present.\n")

# 2. R packages (must match install_packages.R)
cat("\n2. R packages\n")
pkgs_required <- c(
  "shiny", "bslib", "DT", "shinyWidgets", "shinyjs",
  "tidymodels", "recipes", "parsnip", "workflows", "workflowsets",
  "tune", "rsample", "yardstick", "dials", "stacks", "probably",
  "glmnet", "ranger", "xgboost", "kknn", "kernlab", "discrim", "naivebayes", "rpart",
  "promises", "future", "parallelly",
  "dplyr", "tidyr", "purrr", "readr", "forcats", "readxl", "lubridate",
  "ggplot2", "jsonlite", "vip", "themis"
)
missing <- character(0)
for (p in pkgs_required) {
  if (!requireNamespace(p, quietly = TRUE)) {
    missing <- c(missing, p)
  }
}
if (length(missing) > 0) {
  cat("   FAIL: Missing packages:", paste(missing, collapse = ", "), "\n")
  cat("   Run: source('install_packages.R')\n")
  ok <- FALSE
} else {
  cat("   OK: All ", length(pkgs_required), " required packages installed.\n", sep = "")
}

# 3. Optional packages
pkgs_optional <- c("earth", "dotenv")
for (p in pkgs_optional) {
  if (requireNamespace(p, quietly = TRUE)) {
    cat("   OK: Optional '", p, "' installed.\n", sep = "")
  }
}

# 4. Quick load test (sources global.R which loads everything)
cat("\n3. Load test\n")
owd <- setwd("shiny-app")
on.exit(setwd(owd), add = TRUE)
load_ok <- tryCatch({
  source("R/config.R", local = TRUE)
  source("R/utils_logging.R", local = TRUE)
  source("R/utils_validation.R", local = TRUE)
  TRUE
}, error = function(e) {
  cat("   FAIL: Config/utils failed to load:", conditionMessage(e), "\n")
  FALSE
})
if (load_ok) {
  cat("   OK: Config and utils load successfully.\n")
} else {
  ok <- FALSE
}

# 5. R version
cat("\n4. R version\n")
rver <- getRversion()
if (rver >= "4.2.0") {
  cat("   OK: R ", as.character(rver), " (>= 4.2 required)\n", sep = "")
} else {
  cat("   WARN: R ", as.character(rver), " — 4.2+ recommended.\n", sep = "")
}

# Summary
cat("\n")
if (ok) {
  cat("All checks passed. Run the app with: source('run_app.R')\n")
} else {
  cat("Some checks failed. Fix the issues above before running the app.\n")
}
if (!interactive()) quit(status = if (ok) 0 else 1)
