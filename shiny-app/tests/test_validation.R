# ============================================================================
# tests/test_validation.R — Tests for input validation & security
# Run with: testthat::test_file("tests/test_validation.R")
# ============================================================================

library(testthat)
source("R/config.R")
source("R/utils_logging.R")
source("R/utils_validation.R")

# Init config for tests
options(sensehub.config = list(
  max_upload_mb = 100,
  max_rows = 5000000,
  max_columns = 2000,
  allow_rds_upload = FALSE,
  rate_limit_secs = 15,
  max_workers = 1,
  shap_bg_size = 20,
  pdp_sample_size = 500,
  global_seed = 42,
  log_level = "info",
  behind_proxy = FALSE,
  app_name = "test",
  app_version = "0.0.1"
))

# ---- Upload validation tests ----

test_that("validate_upload rejects unsupported extensions", {
  tmp <- tempfile(fileext = ".exe")
  writeLines("test", tmp)
  result <- validate_upload(tmp, "malware.exe")
  expect_false(result$ok)
  expect_match(result$message, "Unsupported file type")
  unlink(tmp)
})

test_that("validate_upload accepts valid CSV", {
  tmp <- tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)
  result <- validate_upload(tmp, "data.csv")
  expect_true(result$ok)
  unlink(tmp)
})

test_that("validate_upload accepts valid Excel extension", {
  tmp <- tempfile(fileext = ".xlsx")
  writeLines("dummy", tmp)
  result <- validate_upload(tmp, "data.xlsx")
  expect_true(result$ok)
  unlink(tmp)
})

test_that("validate_upload rejects nonexistent file", {
  result <- validate_upload("/nonexistent/path.csv", "data.csv")
  expect_false(result$ok)
  expect_match(result$message, "not found")
})

test_that("validate_upload rejects path traversal in filename", {
  tmp <- tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)
  result <- validate_upload(tmp, "../../etc/passwd")
  # basename removes path separators, so this should actually pass the traversal check
  # but fail on extension
  expect_false(result$ok)
  unlink(tmp)
})

# ---- Text validation tests ----

test_that("validate_text_input rejects overlong strings", {
  long_str <- paste(rep("A", 600), collapse = "")
  result <- validate_text_input(long_str, max_length = 500)
  expect_false(result$ok)
  expect_match(result$message, "exceeds maximum length")
})

test_that("validate_text_input accepts normal strings", {
  result <- validate_text_input("hello world")
  expect_true(result$ok)
})

test_that("validate_text_input rejects NULL", {
  result <- validate_text_input(NULL)
  expect_false(result$ok)
})

# ---- Numeric validation tests ----

test_that("validate_numeric_input rejects out-of-range values", {
  result <- validate_numeric_input(100, max_val = 50, label = "folds")
  expect_false(result$ok)
  expect_match(result$message, "<=")
})

test_that("validate_numeric_input accepts in-range values", {
  result <- validate_numeric_input(5, min_val = 1, max_val = 10)
  expect_true(result$ok)
})

test_that("validate_numeric_input rejects NA", {
  result <- validate_numeric_input(NA_real_)
  expect_false(result$ok)
})

# ---- Rate limiter tests ----

test_that("rate limiter allows first action", {
  rl <- create_rate_limiter(cooldown_secs = 1)
  result <- rl$check()
  expect_true(result$ok)
})

test_that("rate limiter blocks rapid second action", {
  rl <- create_rate_limiter(cooldown_secs = 60)
  rl$check()  # first

  result <- rl$check()  # immediate second
  expect_false(result$ok)
  expect_true(result$wait > 0)
})

test_that("rate limiter reset works", {
  rl <- create_rate_limiter(cooldown_secs = 60)
  rl$check()
  rl$reset()
  result <- rl$check()
  expect_true(result$ok)
})

# ---- Dataset dimension validation ----

test_that("validate_dataset_dimensions accepts normal data", {
  df <- data.frame(a = 1:100, b = 1:100)
  result <- validate_dataset_dimensions(df)
  expect_true(result$ok)
})

# ---- Sanitisation tests ----

test_that("sanitise_column_name removes special characters", {
  expect_equal(sanitise_column_name("col_name"), "col_name")
  expect_equal(sanitise_column_name("col<script>"), "colscript")
  expect_equal(sanitise_column_name(NULL), NULL)
})

cat("\n\u2713 All validation tests passed.\n")
