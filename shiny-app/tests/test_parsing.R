# ============================================================================
# tests/test_parsing.R — Tests for parse_dataset and delimiter detection
# Run with: testthat::test_file("tests/test_parsing.R")
# ============================================================================

library(testthat)

# App root: test_dir() runs with cwd = tests/, so R/ is one level up
app_root <- if (file.exists("R/config.R")) "." else ".."
source(file.path(app_root, "R/config.R"))
source(file.path(app_root, "R/utils_logging.R"))
source(file.path(app_root, "R/utils_validation.R"))
source(file.path(app_root, "R/modeling.R"))

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

# ---- Delimiter detection tests ----

test_that("detect_delimiter picks comma for CSV-like .txt", {
  tmp <- tempfile(fileext = ".txt")
  writeLines(c("a,b,c", "1,2,3", "4,5,6"), tmp)
  expect_equal(detect_delimiter(tmp), ",")
  unlink(tmp)
})

test_that("detect_delimiter picks tab for TSV-like .txt", {
  tmp <- tempfile(fileext = ".txt")
  writeLines(c("a\tb\tc", "1\t2\t3", "4\t5\t6"), tmp)
  expect_equal(detect_delimiter(tmp), "\t")
  unlink(tmp)
})

test_that("detect_delimiter picks semicolon for semicolon-delimited .txt", {
  tmp <- tempfile(fileext = ".txt")
  writeLines(c("a;b;c", "1;2;3", "4;5;6"), tmp)
  expect_equal(detect_delimiter(tmp), ";")
  unlink(tmp)
})

test_that("detect_delimiter picks pipe for pipe-delimited .txt", {
  tmp <- tempfile(fileext = ".txt")
  writeLines(c("a|b|c", "1|2|3", "4|5|6"), tmp)
  expect_equal(detect_delimiter(tmp), "|")
  unlink(tmp)
})

test_that("detect_delimiter errors on single-column undelimited text", {
  tmp <- tempfile(fileext = ".txt")
  writeLines(c("justonecolumn", "row2", "row3"), tmp)
  expect_error(detect_delimiter(tmp), "Could not detect a delimiter")
  unlink(tmp)
})

# ---- parse_dataset tests ----

test_that("parse_dataset reads CSV correctly", {
  tmp <- tempfile(fileext = ".csv")
  readr::write_csv(tibble::tibble(a = 1:20, b = rnorm(20)), tmp)
  result <- parse_dataset(tmp, "test.csv")
  expect_true(is.list(result))
  expect_equal(ncol(result$data), 2)
  expect_equal(nrow(result$data), 20)
  unlink(tmp)
})

test_that("parse_dataset reads TSV correctly", {
  tmp <- tempfile(fileext = ".tsv")
  readr::write_tsv(tibble::tibble(a = 1:20, b = rnorm(20)), tmp)
  result <- parse_dataset(tmp, "test.tsv")
  expect_equal(ncol(result$data), 2)
  unlink(tmp)
})

test_that("parse_dataset reads comma-delimited .txt correctly", {
  tmp <- tempfile(fileext = ".txt")
  writeLines(c("x,y,z", paste(1:20, 21:40, 41:60, sep = ",")), tmp)
  result <- parse_dataset(tmp, "test.txt")
  expect_equal(ncol(result$data), 3)
  unlink(tmp)
})

test_that("parse_dataset rejects RDS when SENSEHUB_ALLOW_RDS is FALSE", {
  tmp <- tempfile(fileext = ".rds")
  saveRDS(data.frame(a = 1:20, b = 1:20), tmp)
  Sys.setenv(SENSEHUB_ALLOW_RDS = "FALSE")
  expect_error(parse_dataset(tmp, "test.rds"), "RDS uploads are disabled")
  unlink(tmp)
})

test_that("parse_dataset accepts RDS when SENSEHUB_ALLOW_RDS is TRUE", {
  tmp <- tempfile(fileext = ".rds")
  saveRDS(data.frame(a = 1:20, b = 1:20), tmp)
  Sys.setenv(SENSEHUB_ALLOW_RDS = "TRUE")
  cfg <- getOption("sensehub.config")
  if (is.null(cfg)) cfg <- list()
  cfg$allow_rds_upload <- TRUE
  options(sensehub.config = cfg)
  on.exit({ cfg$allow_rds_upload <- FALSE; options(sensehub.config = cfg) }, add = TRUE)
  result <- parse_dataset(tmp, "test.rds")
  expect_equal(ncol(result$data), 2)
  Sys.setenv(SENSEHUB_ALLOW_RDS = "FALSE")
  unlink(tmp)
})

test_that("parse_dataset rejects < 2 columns", {
  tmp <- tempfile(fileext = ".csv")
  readr::write_csv(tibble::tibble(x = 1:20), tmp)
  expect_error(parse_dataset(tmp, "test.csv"), "at least 2 columns")
  unlink(tmp)
})

test_that("parse_dataset rejects < 10 rows", {
  tmp <- tempfile(fileext = ".csv")
  readr::write_csv(tibble::tibble(x = 1:5, y = 1:5), tmp)
  expect_error(parse_dataset(tmp, "test.csv"), "at least 10 rows")
  unlink(tmp)
})

test_that("parse_dataset rejects unsupported extension", {
  tmp <- tempfile(fileext = ".json")
  writeLines("{}", tmp)
  expect_error(parse_dataset(tmp, "test.json"), "Unsupported file type")
  unlink(tmp)
})

test_that("parse_dataset returns schema and health", {
  tmp <- tempfile(fileext = ".csv")
  readr::write_csv(tibble::tibble(id = 1:100, val = rnorm(100), cat = sample(letters[1:3], 100, replace = TRUE)), tmp)
  result <- parse_dataset(tmp, "test.csv")
  expect_true("schema" %in% names(result))
  expect_true("health" %in% names(result))
  expect_true("id" %in% result$health$suspected_ids)
  unlink(tmp)
})

cat("\n\u2713 All parsing tests passed.\n")
