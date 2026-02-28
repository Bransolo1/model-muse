# ============================================================================
# fn_export.R — Export functions
# ============================================================================

#' Export a reproducibility bundle as a zip file
#' Includes config, seed, recipe, split IDs, tune results, leaderboard,
#' and the final fitted model for deployment.
export_bundle <- function(results, config, run_id, zip_path) {
  tmpdir <- file.path(tempdir(), run_id)
  dir.create(tmpdir, recursive = TRUE, showWarnings = FALSE)

  # Config
  jsonlite::write_json(config, file.path(tmpdir, "config.json"),
                       pretty = TRUE, auto_unbox = TRUE)

  # Leaderboard
  if (!is.null(results$leaderboard)) {
    readr::write_csv(results$leaderboard,
                     file.path(tmpdir, "leaderboard.csv"))
    jsonlite::write_json(results$leaderboard,
                         file.path(tmpdir, "leaderboard.json"),
                         pretty = TRUE)
  }

  # Predictions
  if (!is.null(results$predictions)) {
    readr::write_csv(results$predictions,
                     file.path(tmpdir, "predictions.csv"))
  }

  # Feature importance
  if (!is.null(results$importance)) {
    readr::write_csv(results$importance,
                     file.path(tmpdir, "feature_importance.csv"))
  }

  # Tune results (serialised R objects)
  tryCatch({
    saveRDS(results$tune_results, file.path(tmpdir, "tune_results.rds"))
  }, error = function(e) NULL)

  # Final fitted model for deployment
  tryCatch({
    if (!is.null(results$confidence$final_fit)) {
      saveRDS(results$confidence$final_fit,
              file.path(tmpdir, "fitted_model.rds"))
    }
  }, error = function(e) NULL)

  # Split info
  tryCatch({
    if (!is.null(results$split)) {
      split_info <- list(
        training_rows = as.integer(nrow(rsample::training(results$split))),
        testing_rows  = as.integer(nrow(rsample::testing(results$split)))
      )
      jsonlite::write_json(split_info, file.path(tmpdir, "split_info.json"),
                           pretty = TRUE, auto_unbox = TRUE)
    }
  }, error = function(e) NULL)

  # Seed
  writeLines(as.character(config$seed),
             file.path(tmpdir, "random_seed.txt"))

  # README
  readme <- c(
    paste0("# ", run_id, " — Reproducibility Bundle"),
    "",
    "## Contents",
    "- config.json: Full run configuration",
    "- leaderboard.csv/json: Model rankings",
    "- predictions.csv: Test set predictions",
    "- feature_importance.csv: Permutation importance",
    "- fitted_model.rds: Final fitted workflow (use with predict())",
    "- tune_results.rds: Full tuning results",
    "- split_info.json: Train/test split details",
    "- random_seed.txt: Seed for reproducibility",
    "",
    "## Using the fitted model",
    "```r",
    "model <- readRDS('fitted_model.rds')",
    "new_predictions <- predict(model, new_data)",
    "```"
  )
  writeLines(readme, file.path(tmpdir, "README.md"))

  # Zip it up
  old_wd <- setwd(tmpdir)
  on.exit(setwd(old_wd))
  utils::zip(zip_path, files = list.files(".", recursive = TRUE))

  invisible(zip_path)
}
