# ============================================================================
# tests/test_pipeline.R — Automated checks for failure modes
# Run with: testthat::test_file("tests/test_pipeline.R")
# ============================================================================

library(testthat)
source("R/fn_modeling.R")
source("R/fn_export.R")

# ---- Helper: create test data ----
make_clf_data <- function(n = 200) {
  tibble::tibble(
    id    = seq_len(n),
    x1    = rnorm(n),
    x2    = sample(c("A", "B", "C"), n, replace = TRUE),
    x3    = rnorm(n),
    target = sample(c("yes", "no"), n, replace = TRUE, prob = c(0.3, 0.7))
  )
}

make_reg_data <- function(n = 200) {
  tibble::tibble(
    id     = seq_len(n),
    x1     = rnorm(n),
    x2     = sample(c("A", "B", "C"), n, replace = TRUE),
    target = 3 * rnorm(n) + 10
  )
}

# ---- Tests ----

test_that("parse_dataset rejects < 2 columns", {
  tmp <- tempfile(fileext = ".csv")
  readr::write_csv(tibble::tibble(x = 1:20), tmp)
  expect_error(parse_dataset(tmp, "test.csv"), "at least 2 columns")
})

test_that("validate_config catches all-missing target", {
  data <- make_clf_data()
  data$target <- NA
  config <- list(target = "target", predictors = c("x1", "x2"),
                 problem_type = "classification",
                 advanced = list(imbalance = "none"))
  result <- validate_config(data, config)
  expect_false(result$ok)
  expect_match(result$message, "entirely missing")
})

test_that("validate_config catches single unique target", {
  data <- make_clf_data()
  data$target <- "yes"
  config <- list(target = "target", predictors = c("x1", "x2"),
                 problem_type = "classification",
                 advanced = list(imbalance = "none"))
  result <- validate_config(data, config)
  expect_false(result$ok)
  expect_match(result$message, "fewer than 2")
})

test_that("validate_config warns on class imbalance", {
  data <- make_clf_data(500)
  data$target <- sample(c("rare", rep("common", 49)),
                        500, replace = TRUE)
  config <- list(target = "target", predictors = c("x1", "x2"),
                 problem_type = "classification",
                 advanced = list(imbalance = "none"))
  result <- validate_config(data, config)
  expect_true(result$ok)
  expect_true(any(grepl("imbalance", result$warnings, ignore.case = TRUE)))
})

test_that("validate_config rejects non-numeric regression target", {
  data <- make_clf_data()
  config <- list(target = "target", predictors = c("x1", "x2"),
                 problem_type = "regression",
                 advanced = list(imbalance = "none"))
  result <- validate_config(data, config)
  expect_false(result$ok)
  expect_match(result$message, "numeric")
})

test_that("infer_problem_type works for classification and regression", {
  clf_data <- make_clf_data()
  reg_data <- make_reg_data()
  expect_equal(infer_problem_type(clf_data, "target"), "classification")
  expect_equal(infer_problem_type(reg_data, "target"), "regression")
})

test_that("build_preprocessing_recipe returns a recipe", {
  data <- make_clf_data()
  config <- list(
    target = "target", predictors = c("x1", "x2", "x3"),
    problem_type = "classification",
    advanced = list(imbalance = "none")
  )
  rec <- build_preprocessing_recipe(data, config, variant = "base")
  expect_s3_class(rec, "recipe")

  rec_norm <- build_preprocessing_recipe(data, config, variant = "normalized")
  expect_s3_class(rec_norm, "recipe")
})

test_that("build_resamples returns split and folds", {
  data <- make_clf_data(200)
  config <- list(
    target = "target", predictors = c("x1", "x2", "x3"),
    problem_type = "classification",
    time_col = NULL,
    advanced = list(cv_folds = 3, cv_repeats = 1)
  )
  res <- build_resamples(data, config)
  expect_true("split" %in% names(res))
  expect_true("folds" %in% names(res))
})

test_that("health check detects suspected ID columns", {
  data <- make_clf_data(100)
  schema <- build_schema(data)
  health <- build_health_check(data, schema)
  expect_true("id" %in% health$suspected_ids)
})

test_that("select_default_metric handles imbalanced classification", {
  data <- tibble::tibble(target = c(rep("rare", 5), rep("common", 95)))
  metric <- select_default_metric("classification", data, "target")
  expect_equal(metric, "pr_auc")  # rare class → PR AUC
})

test_that("select_default_metric defaults to roc_auc for balanced", {
  data <- tibble::tibble(target = rep(c("A", "B"), 50))
  metric <- select_default_metric("classification", data, "target")
  expect_equal(metric, "roc_auc")
})

cat("\n✓ All pipeline tests passed.\n")
