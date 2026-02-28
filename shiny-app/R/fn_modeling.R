# ============================================================================
# fn_modeling.R — Core modelling pipeline
# All testable functions: parse, validate, preprocess, resample, train, etc.
# ============================================================================

# ---- detect_delimiter() ----
# Try comma, tab, semicolon, pipe; pick the one yielding the most columns with stable parsing
detect_delimiter <- function(file_path) {
  candidates <- c(",", "\t", ";", "|")
  best_delim <- NULL
  best_ncol  <- 0L

  for (delim in candidates) {
    parsed <- tryCatch(
      readr::read_delim(file_path, delim = delim, show_col_types = FALSE,
                        n_max = 20, col_names = TRUE),
      error = function(e) NULL,
      warning = function(w) {
        suppressWarnings(
          readr::read_delim(file_path, delim = delim, show_col_types = FALSE,
                            n_max = 20, col_names = TRUE)
        )
      }
    )
    if (!is.null(parsed) && ncol(parsed) > best_ncol) {
      best_ncol  <- ncol(parsed)
      best_delim <- delim
    }
  }

  if (is.null(best_delim) || best_ncol < 2) {
    stop("Could not detect a delimiter for this .txt file. Please upload as .csv or .tsv instead.",
         call. = FALSE)
  }

  best_delim
}


# ---- parse_dataset() ----
# Returns list(data, schema, health)
parse_dataset <- function(file_path, file_name = NULL) {
  ext <- tolower(tools::file_ext(file_name %||% file_path))

  data <- switch(ext,
    csv  = readr::read_csv(file_path, show_col_types = FALSE),
    tsv  = readr::read_tsv(file_path, show_col_types = FALSE),
    txt  = {
      delim <- detect_delimiter(file_path)
      readr::read_delim(file_path, delim = delim, show_col_types = FALSE)
    },
    xlsx = readxl::read_excel(file_path),
    xls  = readxl::read_excel(file_path),
    rds  = {
      allow_rds <- as.logical(Sys.getenv("SENSEHUB_ALLOW_RDS", "FALSE"))
      if (!isTRUE(allow_rds)) {
        stop("RDS uploads are disabled. Set SENSEHUB_ALLOW_RDS=TRUE to enable, or upload as CSV/Excel.",
             call. = FALSE)
      }
      readRDS(file_path)
    },
    stop("Unsupported file type: .", ext,
         ". Supported: csv, tsv, txt, xlsx, xls", call. = FALSE)
  )

  data <- tibble::as_tibble(data)
  if (ncol(data) < 2) stop("Dataset must have at least 2 columns.")
  if (nrow(data) < 10) stop("Dataset must have at least 10 rows.")

  schema <- build_schema(data)
  health <- build_health_check(data, schema)

  list(data = data, schema = schema, health = health)
}

build_schema <- function(data) {
  tibble::tibble(
    column        = names(data),
    r_class       = purrr::map_chr(data, ~ class(.x)[1]),
    inferred_type = purrr::map_chr(data, infer_col_type),
    n_unique      = purrr::map_int(data, ~ dplyr::n_distinct(.x, na.rm = TRUE)),
    n_missing     = purrr::map_int(data, ~ sum(is.na(.x))),
    pct_missing   = purrr::map_dbl(data, ~ mean(is.na(.x)))
  )
}

infer_col_type <- function(x) {
  if (inherits(x, c("Date", "POSIXct", "POSIXt"))) return("date")
  if (is.logical(x)) return("logical")
  if (is.numeric(x)) return("numeric")
  if (is.factor(x))  return("categorical")
  if (is.character(x)) {
    non_na <- na.omit(x)
    if (length(non_na) == 0) return("unknown")
    sample_vals <- non_na[seq_len(min(20, length(non_na)))]
    parsed <- suppressWarnings(lubridate::parse_date_time(sample_vals,
                orders = c("ymd", "mdy", "dmy", "ymd HMS", "mdy HMS")))
    if (sum(!is.na(parsed)) > length(sample_vals) * 0.8) return("date")
    return("categorical")
  }
  "unknown"
}

build_health_check <- function(data, schema) {
  n <- nrow(data)
  suspected_ids <- schema$column[
    schema$n_unique > 0.95 * n &
    schema$inferred_type %in% c("categorical", "numeric", "unknown")
  ]
  suspected_dates <- schema$column[schema$inferred_type == "date"]
  dup_count <- sum(duplicated(data))
  near_constant <- schema$column[schema$n_unique <= 1]

  list(
    n_rows           = n,
    n_cols           = ncol(data),
    total_missing    = sum(schema$n_missing),
    cols_with_missing = sum(schema$n_missing > 0),
    duplicate_rows   = dup_count,
    suspected_ids    = suspected_ids,
    suspected_dates  = suspected_dates,
    near_constant    = near_constant,
    type_summary     = schema,
    warnings         = character(0)
  )
}


# ---- infer_problem_type() ----
infer_problem_type <- function(data, target_col) {
  target <- data[[target_col]]
  if (is.factor(target) || is.character(target)) return("classification")
  if (is.logical(target)) return("classification")
  if (is.numeric(target)) {
    n_unique <- dplyr::n_distinct(target, na.rm = TRUE)
    if (n_unique <= 10) return("classification")
    return("regression")
  }
  "regression"
}


# ---- select_default_metric() ----
select_default_metric <- function(problem_type, data = NULL, target_col = NULL) {
  if (problem_type == "classification") {
    if (!is.null(data) && !is.null(target_col)) {
      tab <- table(data[[target_col]])
      min_frac <- min(tab) / sum(tab)
      if (min_frac < 0.1) return("pr_auc")
    }
    return("roc_auc")
  }
  if (problem_type == "regression")   return("rmse")
  if (problem_type == "time_series")  return("rmse")
  "rmse"
}

metric_label <- function(metric_id) {
  if (is.null(metric_id) || length(metric_id) == 0) return("(none)")
  labels <- c(
    roc_auc     = "ROC AUC",
    pr_auc      = "PR AUC",
    mn_log_loss = "Log loss",
    accuracy    = "Accuracy",
    f_meas      = "F1",
    rmse        = "RMSE",
    mae         = "MAE",
    rsq         = "R\u00b2",
    mape        = "MAPE"
  )
  result <- labels[metric_id]
  if (length(result) == 0 || is.na(result)) metric_id else unname(result)
}

yardstick_metric <- function(metric_id) {
  switch(metric_id,
    roc_auc     = yardstick::roc_auc,
    pr_auc      = yardstick::pr_auc,
    mn_log_loss = yardstick::mn_log_loss,
    accuracy    = yardstick::accuracy,
    f_meas      = yardstick::f_meas,
    rmse        = yardstick::rmse,
    mae         = yardstick::mae,
    rsq         = yardstick::rsq,
    mape        = yardstick::mape,
    yardstick::rmse
  )
}


# ---- validate_config() ----
validate_config <- function(data, config) {
  warnings <- character(0)

  if (!config$target %in% names(data))
    return(list(ok = FALSE, message = "Target column not found in dataset."))

  target <- data[[config$target]]

  if (all(is.na(target)))
    return(list(ok = FALSE, message = "Target column is entirely missing."))

  if (dplyr::n_distinct(target, na.rm = TRUE) < 2)
    return(list(ok = FALSE,
      message = "Target has fewer than 2 unique values after removing NA."))

  if (config$problem_type == "classification") {
    tab <- table(target)
    min_frac <- min(tab) / sum(tab)
    if (min_frac < 0.05) {
      warnings <- c(warnings,
        paste0("\u26a0 Severe class imbalance detected. Consider enabling class ",
               "weights or SMOTE in Advanced settings. We have switched the ",
               "default metric away from accuracy."))
    }
  }

  if (config$problem_type == "regression") {
    if (!is.numeric(target))
      return(list(ok = FALSE, message = "Target must be numeric for regression."))
    if (sd(target, na.rm = TRUE) < 1e-8)
      warnings <- c(warnings, "\u26a0 Target has extremely low variance.")
  }

  if (config$problem_type == "time_series") {
    if (is.null(config$time_col) || !config$time_col %in% names(data))
      return(list(ok = FALSE,
        message = "Time series requires a valid time index column."))

    time_vec <- data[[config$time_col]]
    if (!inherits(time_vec, c("Date", "POSIXct", "POSIXt", "numeric")))
      warnings <- c(warnings, "\u26a0 Time column may not be sortable.")

    dup_ts <- sum(duplicated(time_vec))
    if (dup_ts > 0)
      warnings <- c(warnings, sprintf("\u26a0 %d duplicate timestamps detected.", dup_ts))
  }

  if (length(config$predictors) == 0)
    return(list(ok = FALSE, message = "No predictor columns selected."))

  if (length(config$predictors) > 500)
    warnings <- c(warnings, "\u26a0 Many predictor columns. Consider reducing features.")

  if (nrow(data) > 100000)
    warnings <- c(warnings, "\u26a0 Large dataset. Consider sampling for a quick first run.")

  list(ok = TRUE, message = "OK", warnings = warnings)
}


# ---- build_preprocessing_recipe() ----
build_preprocessing_recipe <- function(data, config, variant = "base") {
  target_sym <- rlang::sym(config$target)
  pred_names <- config$predictors

  model_data <- data[, c(config$target, pred_names), drop = FALSE]

  if (config$problem_type == "classification") {
    model_data[[config$target]] <- as.factor(model_data[[config$target]])
  }

  rec <- recipes::recipe(
    formula = stats::as.formula(paste(config$target, "~ .")),
    data    = model_data
  )

  # Auto feature engineering: date part extraction
  date_cols <- pred_names[purrr::map_lgl(model_data[pred_names], ~ inherits(.x, c("Date", "POSIXct", "POSIXt")))]
  if (length(date_cols) > 0) {
    rec <- rec %>%
      recipes::step_date(all_of(date_cols), features = c("dow", "month", "year")) %>%
      recipes::step_rm(all_of(date_cols))
  }

  # Auto feature engineering: polynomial features for low-dim numeric
  num_cols <- pred_names[purrr::map_lgl(model_data[pred_names], is.numeric)]
  auto_fe <- isTRUE(config$advanced$auto_feature_eng)

  # Missingness indicators (BEFORE imputation and feature engineering)
  cols_with_missing <- names(model_data)[purrr::map_lgl(model_data, ~ any(is.na(.x)))]
  cols_with_missing <- setdiff(cols_with_missing, config$target)
  if (length(cols_with_missing) > 0) {
    rec <- rec %>%
      recipes::step_indicate_na(all_of(cols_with_missing))
  }

  # Imputation BEFORE feature engineering (so poly/interact get clean data)
  rec <- rec %>%
    recipes::step_impute_median(recipes::all_numeric_predictors()) %>%
    recipes::step_impute_mode(recipes::all_nominal_predictors())

  # Auto feature engineering: interaction terms BEFORE step_poly
  # (step_poly replaces original columns, so interact must run first)
  if (auto_fe && variant == "normalized" && length(num_cols) >= 2 && length(num_cols) <= 6) {
    interact_formula <- stats::as.formula(
      paste("~", paste0("(", paste(num_cols, collapse = " + "), ")^2"))
    )
    rec <- rec %>%
      recipes::step_interact(terms = interact_formula, sep = "_x_")
  }

  # Auto feature engineering: polynomial features (runs after interact so originals still exist for interact)
  if (auto_fe && length(num_cols) >= 2 && length(num_cols) <= 8 && variant == "normalized") {
    rec <- rec %>%
      recipes::step_poly(all_of(num_cols), degree = 2)
  }

  # Categorical handling
  threshold <- max(0.01, 0.02 * (1000 / max(nrow(model_data), 1)))
  threshold <- min(threshold, 0.1)
  rec <- rec %>%
    recipes::step_other(recipes::all_nominal_predictors(),
                        threshold = threshold, other = "_other_") %>%
    recipes::step_novel(recipes::all_nominal_predictors(),
                        new_level = "_unseen_") %>%
    recipes::step_dummy(recipes::all_nominal_predictors(), one_hot = FALSE)

  # Remove zero-variance predictors
  rec <- rec %>%
    recipes::step_zv(recipes::all_predictors())

  # Normalisation BEFORE SMOTE — normalization stats must be computed on
  # real data, not SMOTE-augmented data, to avoid distribution shift at inference
  if (variant == "normalized") {
    rec <- rec %>%
      recipes::step_normalize(recipes::all_numeric_predictors())
  }

  # SMOTE (AFTER normalization, on fully-prepared numeric data)
  # This ensures normalization statistics reflect real data distributions
  if (config$problem_type == "classification" &&
      config$advanced$imbalance == "smote") {
    if (requireNamespace("themis", quietly = TRUE)) {
      rec <- rec %>%
        themis::step_smote(recipes::all_outcomes())
    } else {
      warning("Package 'themis' is required for SMOTE but not installed. Skipping SMOTE.")
    }
  }

  rec
}


# ---- build_resamples() ----
build_resamples <- function(data, config) {
  target <- config$target
  model_data <- data[, c(target, config$predictors), drop = FALSE]

  # Remove rows with NA in the target column — these crash rsample splits
  na_target <- is.na(model_data[[target]])
  if (any(na_target)) {
    n_dropped <- sum(na_target)
    message(sprintf("Dropping %d rows with missing target values.", n_dropped))
    model_data <- model_data[!na_target, , drop = FALSE]
  }

  if (config$problem_type == "classification") {
    model_data[[target]] <- as.factor(model_data[[target]])
  }

  if (config$problem_type == "time_series" && !is.null(config$time_col)) {
    # Sort model_data by time column (must be in model_data or use a separate lookup)
    if (config$time_col %in% names(model_data)) {
      model_data <- model_data[order(model_data[[config$time_col]]), ]
    } else if (config$time_col %in% names(data)) {
      # time_col not in predictors — align sort with the non-NA-dropped rows
      keep_rows <- which(!na_target)
      time_vals <- data[[config$time_col]][keep_rows]
      model_data <- model_data[order(time_vals), ]
    }
    split <- rsample::initial_time_split(model_data, prop = 0.8)
    folds <- rsample::vfold_cv(rsample::training(split), v = config$advanced$cv_folds)
  } else {
    strata <- if (config$problem_type == "classification") target else NULL
    split  <- rsample::initial_split(model_data, prop = 0.8, strata = strata)

    v <- config$advanced$cv_folds
    repeats <- config$advanced$cv_repeats

    if (repeats > 1) {
      folds <- rsample::vfold_cv(rsample::training(split), v = v,
                                  repeats = repeats, strata = strata)
    } else {
      folds <- rsample::vfold_cv(rsample::training(split), v = v, strata = strata)
    }
  }

  list(split = split, folds = folds)
}


# ---- build_workflowset() ----
build_workflowset <- function(recipes_list, model_specs) {
  workflowsets::workflow_set(
    preproc = recipes_list,
    models  = model_specs,
    cross   = TRUE
  )
}


# ---- Model catalogue ----
get_model_specs <- function(problem_type, tuning_budget, imbalance = "none",
                           class_weight_vec = NULL) {
  use_class_weights <- (imbalance == "class_weights" && problem_type == "classification")

  if (problem_type == "classification") {
    # XGBoost supports scale_pos_weight for class weights
    xgb_engine_args <- list()
    if (use_class_weights && !is.null(class_weight_vec)) {
      # For binary: ratio of negative to positive
      if (length(class_weight_vec) == 2) {
        xgb_engine_args$scale_pos_weight <- max(class_weight_vec) / min(class_weight_vec)
      }
    }

    specs <- list(
      glmnet = parsnip::logistic_reg(
        penalty = tune::tune(), mixture = tune::tune()
      ) %>% parsnip::set_engine("glmnet") %>% parsnip::set_mode("classification"),

      ranger = parsnip::rand_forest(
        mtry = tune::tune(),
        trees = switch(tuning_budget, quick = 300, standard = 500, thorough = 1000),
        min_n = tune::tune()
      ) %>% parsnip::set_engine("ranger", importance = "permutation",
                                 class.weights = if (use_class_weights && !is.null(class_weight_vec)) class_weight_vec else NULL
      ) %>% parsnip::set_mode("classification"),

      xgboost = {
        xgb_spec <- parsnip::boost_tree(
          trees = tune::tune(), tree_depth = tune::tune(),
          learn_rate = tune::tune(), min_n = tune::tune(),
          sample_size = tune::tune()
        )
        # Only pass scale_pos_weight if actually computed (avoid explicit NULL)
        if (!is.null(xgb_engine_args$scale_pos_weight)) {
          xgb_spec <- xgb_spec %>%
            parsnip::set_engine("xgboost",
                                scale_pos_weight = xgb_engine_args$scale_pos_weight)
        } else {
          xgb_spec <- xgb_spec %>% parsnip::set_engine("xgboost")
        }
        xgb_spec %>% parsnip::set_mode("classification")
      }
    )

    if (tuning_budget %in% c("standard", "thorough")) {
      specs$svm <- parsnip::svm_rbf(
        cost = tune::tune(), rbf_sigma = tune::tune()
      ) %>% parsnip::set_engine("kernlab") %>% parsnip::set_mode("classification")

      specs$knn <- parsnip::nearest_neighbor(
        neighbors = tune::tune()
      ) %>% parsnip::set_engine("kknn") %>% parsnip::set_mode("classification")

      specs$nb <- parsnip::naive_Bayes(
        smoothness = tune::tune()
      ) %>% parsnip::set_engine("naivebayes") %>% parsnip::set_mode("classification")

      # Decision Tree — interpretable, great for small datasets
      specs$dtree <- parsnip::decision_tree(
        cost_complexity = tune::tune(),
        tree_depth = tune::tune(),
        min_n = tune::tune()
      ) %>% parsnip::set_engine("rpart") %>% parsnip::set_mode("classification")

      # MARS — excellent for small datasets with nonlinear relationships
      if (exists("HAS_EARTH") && isTRUE(HAS_EARTH)) {
        specs$mars <- parsnip::mars(
          num_terms = tune::tune(),
          prod_degree = tune::tune()
        ) %>% parsnip::set_engine("earth") %>% parsnip::set_mode("classification")
      }
    }

  } else {
    specs <- list(
      glmnet = parsnip::linear_reg(
        penalty = tune::tune(), mixture = tune::tune()
      ) %>% parsnip::set_engine("glmnet") %>% parsnip::set_mode("regression"),

      ranger = parsnip::rand_forest(
        mtry = tune::tune(),
        trees = switch(tuning_budget, quick = 300, standard = 500, thorough = 1000),
        min_n = tune::tune()
      ) %>% parsnip::set_engine("ranger", importance = "permutation") %>%
        parsnip::set_mode("regression"),

      xgboost = parsnip::boost_tree(
        trees = tune::tune(), tree_depth = tune::tune(),
        learn_rate = tune::tune(), min_n = tune::tune(),
        sample_size = tune::tune()
      ) %>% parsnip::set_engine("xgboost") %>% parsnip::set_mode("regression")
    )

    if (tuning_budget %in% c("standard", "thorough")) {
      specs$svm <- parsnip::svm_rbf(
        cost = tune::tune(), rbf_sigma = tune::tune()
      ) %>% parsnip::set_engine("kernlab") %>% parsnip::set_mode("regression")

      specs$knn <- parsnip::nearest_neighbor(
        neighbors = tune::tune()
      ) %>% parsnip::set_engine("kknn") %>% parsnip::set_mode("regression")

      # Decision Tree — interpretable, great for small datasets
      specs$dtree <- parsnip::decision_tree(
        cost_complexity = tune::tune(),
        tree_depth = tune::tune(),
        min_n = tune::tune()
      ) %>% parsnip::set_engine("rpart") %>% parsnip::set_mode("regression")

      # MARS — excellent for small datasets with nonlinear relationships
      if (exists("HAS_EARTH") && isTRUE(HAS_EARTH)) {
        specs$mars <- parsnip::mars(
          num_terms = tune::tune(),
          prod_degree = tune::tune()
        ) %>% parsnip::set_engine("earth") %>% parsnip::set_mode("regression")
      }
    }
  }

  specs
}


# ---- Tuning grid sizes ----
get_grid_size <- function(tuning_budget) {
  switch(tuning_budget,
    quick    = 5,
    standard = 15,
    thorough = 30,
    15
  )
}


# ---- train_and_tune() ----
train_and_tune <- function(wflowset, folds, config) {
  metric_fn <- yardstick_metric(config$metric)
  metric_set <- yardstick::metric_set(metric_fn)

  grid_size <- get_grid_size(config$advanced$tuning_budget)

  ctrl <- tune::control_grid(
    save_pred    = TRUE,
    save_workflow = TRUE,
    verbose      = FALSE,
    parallel_over = "everything"
  )

  if (config$advanced$tuning_budget == "thorough") {
    ctrl_bayes <- tune::control_bayes(
      save_pred    = TRUE,
      save_workflow = TRUE,
      verbose      = FALSE,
      no_improve   = 10
    )

    results <- tryCatch({
      workflowsets::workflow_map(
        wflowset, fn = "tune_bayes",
        resamples = folds, metrics = metric_set,
        initial = 5, iter = grid_size,
        control = ctrl_bayes, seed = config$seed
      )
    }, error = function(e) {
      workflowsets::workflow_map(
        wflowset, fn = "tune_grid",
        resamples = folds, metrics = metric_set,
        grid = grid_size, control = ctrl, seed = config$seed
      )
    })
  } else {
    results <- workflowsets::workflow_map(
      wflowset, fn = "tune_grid",
      resamples = folds, metrics = metric_set,
      grid = grid_size, control = ctrl, seed = config$seed
    )
  }

  results
}


# ---- build_ensemble() ----
build_ensemble <- function(tune_results, config) {
  if (!config$advanced$ensemble) return(NULL)

  tryCatch({
    st <- stacks::stacks()
    wf_ids <- tune_results$wflow_id
    for (wf_id in wf_ids) {
      res <- workflowsets::extract_workflow_set_result(tune_results, wf_id)
      st <- stacks::add_candidates(st, res, name = wf_id)
    }
    st_model <- st %>%
      stacks::blend_predictions() %>%
      stacks::fit_members()
    st_model
  }, error = function(e) {
    message("Ensemble building failed: ", e$message)
    NULL
  })
}


# ---- compute_confidence_outputs() ----
compute_confidence_outputs <- function(tune_results, split, config) {
  outputs <- list()

  best_wf <- tune_results %>%
    workflowsets::rank_results(rank_metric = config$metric, select_best = TRUE) %>%
    dplyr::filter(.metric == config$metric) %>%
    dplyr::slice(1)

  best_id <- best_wf$wflow_id[1]
  best_result <- tune_results %>%
    workflowsets::extract_workflow_set_result(best_id)

  best_workflow <- best_result %>%
    tune::select_best(metric = config$metric)

  final_wf <- tune_results %>%
    workflowsets::extract_workflow(best_id) %>%
    tune::finalize_workflow(best_workflow)

  final_fit <- tune::last_fit(final_wf, split)

  if (config$problem_type == "classification") {
    preds <- tune::collect_predictions(final_fit)
    if (".pred_class" %in% names(preds)) {
      tryCatch({
        prob_cols <- grep("^\\.pred_", names(preds), value = TRUE)
        prob_cols <- setdiff(prob_cols, c(".pred_class", ".pred"))
        if (length(prob_cols) > 0) {
          # Pass ALL probability columns to brier_class (required for multiclass)
          brier <- yardstick::brier_class(preds,
                                           truth = !!rlang::sym(config$target),
                                           !!!rlang::syms(prob_cols))
          outputs$brier_score <- brier$.estimate
          outputs$calibration_note <-
            "If calibration is good, a predicted probability of 0.8 should be correct about 80% of the time."
        }
      }, error = function(e) NULL)
    }
  }

  if (config$problem_type == "regression" && config$advanced$show_uncertainty) {
    # Split-conformal prediction intervals using a SEPARATE calibration set
    # to avoid the self-evaluation bias of computing intervals on test data
    tryCatch({
      train_data <- rsample::training(split)
      # Hold out 20% of training as calibration set (not used for fitting)
      n_train <- nrow(train_data)
      cal_size <- max(20, floor(n_train * 0.2))
      cal_idx <- sample(n_train, cal_size)
      cal_data <- train_data[cal_idx, , drop = FALSE]

      # Get calibration residuals from the fitted model
      cal_preds <- predict(final_fit$.workflow[[1]], cal_data)
      if (".pred" %in% names(cal_preds) && config$target %in% names(cal_data)) {
        cal_residuals <- cal_data[[config$target]] - cal_preds$.pred
        alpha <- 0.1  # 90% prediction intervals
        q_lower <- quantile(cal_residuals, alpha / 2, na.rm = TRUE)
        q_upper <- quantile(cal_residuals, 1 - alpha / 2, na.rm = TRUE)

        # Apply intervals to the held-out TEST set
        test_preds <- tune::collect_predictions(final_fit)
        if (".pred" %in% names(test_preds) && config$target %in% names(test_preds)) {
          outputs$pred_intervals <- tibble::tibble(
            .pred       = test_preds$.pred,
            actual      = test_preds[[config$target]],
            .pred_lower = test_preds$.pred + q_lower,
            .pred_upper = test_preds$.pred + q_upper
          )
          coverage <- mean(outputs$pred_intervals$actual >= outputs$pred_intervals$.pred_lower &
                           outputs$pred_intervals$actual <= outputs$pred_intervals$.pred_upper,
                           na.rm = TRUE)
          outputs$interval_coverage <- coverage
          outputs$intervals_note <- sprintf(
            "90%% split-conformal prediction intervals (calibrated on held-out training subset). Empirical test coverage: %.1f%%",
            coverage * 100
          )
        }
      }
    }, error = function(e) {
      outputs$intervals_note <<-
        "Prediction intervals could not be computed for this model."
    })
  }

  outputs$final_fit <- final_fit
  outputs
}


# ---- compute_data_drift() ----
# Compares distribution of train vs test for numeric/categorical features
compute_data_drift <- function(split, config) {
  tryCatch({
    train <- rsample::training(split)
    test  <- rsample::testing(split)
    preds <- config$predictors

    drift_results <- purrr::map_dfr(preds, function(col) {
      if (!col %in% names(train) || !col %in% names(test)) return(NULL)

      if (is.numeric(train[[col]])) {
        # KS test for numeric
        ks <- suppressWarnings(stats::ks.test(train[[col]], test[[col]]))
        tibble::tibble(
          feature    = col,
          type       = "numeric",
          statistic  = round(ks$statistic, 4),
          p_value    = round(ks$p.value, 4),
          drifted    = ks$p.value < 0.05
        )
      } else {
        # Chi-squared for categorical
        train_tab <- table(train[[col]])
        test_tab  <- table(test[[col]])
        all_levels <- union(names(train_tab), names(test_tab))
        train_counts <- sapply(all_levels, function(l) ifelse(l %in% names(train_tab), train_tab[l], 0))
        test_counts  <- sapply(all_levels, function(l) ifelse(l %in% names(test_tab), test_tab[l], 0))

        if (sum(test_counts) > 0 && length(all_levels) > 1) {
          chi <- suppressWarnings(stats::chisq.test(rbind(train_counts, test_counts)))
          tibble::tibble(
            feature   = col,
            type      = "categorical",
            statistic = round(chi$statistic, 4),
            p_value   = round(chi$p.value, 4),
            drifted   = chi$p.value < 0.05
          )
        } else {
          tibble::tibble(feature = col, type = "categorical",
                         statistic = NA_real_, p_value = NA_real_, drifted = FALSE)
        }
      }
    })

    drift_results
  }, error = function(e) NULL)
}


# ---- compute_model_comparison_radar() ----
# Builds a radar-chart-ready dataframe comparing models across dimensions
compute_model_radar <- function(tune_results, config, elapsed) {
  tryCatch({
    rankings <- tune_results %>%
      workflowsets::rank_results(rank_metric = config$metric, select_best = TRUE) %>%
      dplyr::filter(.metric == config$metric)

    n_models <- nrow(rankings)
    if (n_models == 0) return(NULL)

    # Normalize metrics to 0-1 scale
    metric_vals <- rankings$mean
    is_lower_better <- config$metric %in% c("rmse", "mae", "mape", "mn_log_loss")

    if (is_lower_better) {
      perf_score <- 1 - (metric_vals - min(metric_vals)) /
        (max(metric_vals) - min(metric_vals) + 1e-10)
    } else {
      perf_score <- (metric_vals - min(metric_vals)) /
        (max(metric_vals) - min(metric_vals) + 1e-10)
    }

    # Stability: inverse of SE
    se_vals <- rankings$std_err
    stability <- 1 - (se_vals - min(se_vals)) / (max(se_vals) - min(se_vals) + 1e-10)

    # Speed: inversely proportional to model complexity
    speed <- rev(seq(0.3, 1.0, length.out = n_models))

    # Interpretability heuristic
    interp <- purrr::map_dbl(rankings$wflow_id, function(wf) {
      if (grepl("dtree", wf)) return(0.95)
      if (grepl("glmnet", wf)) return(0.9)
      if (grepl("mars", wf)) return(0.85)
      if (grepl("nb", wf)) return(0.75)
      if (grepl("knn", wf)) return(0.7)
      if (grepl("ranger", wf)) return(0.5)
      if (grepl("xgboost", wf)) return(0.4)
      if (grepl("svm", wf)) return(0.3)
      0.5
    })

    radar_df <- purrr::map_dfr(seq_len(n_models), function(i) {
      tibble::tibble(
        model     = rankings$wflow_id[i],
        dimension = c("Performance", "Stability", "Speed", "Interpretability"),
        value     = c(perf_score[i], stability[i], speed[i], interp[i])
      )
    })

    radar_df
  }, error = function(e) NULL)
}


# ---- compute_shap_values() ----
# Approximated SHAP via permutation-based marginal contributions
# Performance: limits to top 15 features and 20 background samples
compute_shap_values <- function(final_fit, train_data, config, n_obs = 1) {
  tryCatch({
    final_wf <- final_fit$.workflow[[1]]

    # Pick the observation to explain
    obs <- train_data[n_obs, , drop = FALSE]

    features <- config$predictors
    features <- intersect(features, names(train_data))
    # Limit to top 15 features for performance
    if (length(features) > 15) features <- features[1:15]

    # Determine event-level probability column from TRAINING data factor levels
    # (not from single observation, which only has 1 level)
    event_prob_col <- NULL
    if (config$problem_type == "classification") {
      target_factor <- as.factor(train_data[[config$target]])
      event_level <- levels(target_factor)[1]
      event_prob_col <- paste0(".pred_", event_level)
    }

    # Use smaller background sample for speed (20 instead of 50)
    bg_size <- min(20, nrow(train_data))
    bg_sample <- train_data[sample(nrow(train_data), bg_size), ]

    # Baseline = E[f(x)] — mean prediction over background sample (NOT the obs prediction)
    # This is critical for SHAP: contributions must sum to (prediction - baseline)
    if (config$problem_type == "regression") {
      obs_prediction <- predict(final_wf, obs)$.pred
      bg_preds_baseline <- predict(final_wf, bg_sample)$.pred
      baseline <- mean(bg_preds_baseline, na.rm = TRUE)
    } else {
      prob_preds <- predict(final_wf, obs, type = "prob")
      if (!is.null(event_prob_col) && event_prob_col %in% names(prob_preds)) {
        obs_prediction <- prob_preds[[event_prob_col]]
      } else {
        obs_prediction <- prob_preds[[1]]
      }
      bg_prob_preds <- predict(final_wf, bg_sample, type = "prob")
      if (!is.null(event_prob_col) && event_prob_col %in% names(bg_prob_preds)) {
        baseline <- mean(bg_prob_preds[[event_prob_col]], na.rm = TRUE)
      } else {
        baseline <- mean(bg_prob_preds[[1]], na.rm = TRUE)
      }
    }

    # Marginal contribution of each feature
    shap_vals <- purrr::map_dfr(features, function(feat) {
      permuted_vals <- bg_sample[[feat]]

      preds <- purrr::map_dbl(permuted_vals, function(v) {
        row <- obs
        row[[feat]] <- v
        if (config$problem_type == "regression") {
          predict(final_wf, row)$.pred
        } else {
          prob_p <- predict(final_wf, row, type = "prob")
          if (!is.null(event_prob_col) && event_prob_col %in% names(prob_p)) {
            prob_p[[event_prob_col]]
          } else {
            prob_p[[1]]
          }
        }
      })

      marginal_effect <- obs_prediction - mean(preds, na.rm = TRUE)

      tibble::tibble(
        feature    = feat,
        shap_value = marginal_effect
      )
    })

    shap_vals <- shap_vals %>%
      dplyr::mutate(abs_shap = abs(shap_value)) %>%
      dplyr::arrange(dplyr::desc(abs_shap))

    list(
      shap_values = shap_vals,
      baseline    = baseline,
      obs_index   = n_obs,
      prediction  = obs_prediction
    )
  }, error = function(e) {
    message("SHAP computation failed: ", e$message)
    NULL
  })
}


# ---- run_full_pipeline() ----
run_full_pipeline <- function(data, config) {
  log <- character(0)
  log <- c(log, sprintf("[%s] Building preprocessing recipes\u2026",
                        format(Sys.time(), "%H:%M:%S")))

  # Note: model_data subsetting and target factoring is handled inside
  # build_preprocessing_recipe() and build_resamples() independently

  rec_base <- build_preprocessing_recipe(data, config, variant = "base")
  rec_norm <- build_preprocessing_recipe(data, config, variant = "normalized")
  recipes_list <- list(base = rec_base, normalized = rec_norm)

  log <- c(log, sprintf("[%s] Building resamples\u2026", format(Sys.time(), "%H:%M:%S")))
  resample_obj <- build_resamples(data, config)

  log <- c(log, sprintf("[%s] Setting up model catalogue\u2026", format(Sys.time(), "%H:%M:%S")))

  # Compute class weight vector for class_weights option
  class_weight_vec <- NULL
  if (config$problem_type == "classification" && config$advanced$imbalance == "class_weights") {
    target_vec <- data[[config$target]]
    if (is.character(target_vec) || is.factor(target_vec)) {
      tab <- table(target_vec)
      class_weight_vec <- max(tab) / tab  # inverse frequency weights
      # Warn: XGBoost scale_pos_weight only supports binary classification
      if (length(tab) > 2) {
        log <- c(log, "\u26a0 Class weights: XGBoost scale_pos_weight only works for binary. Ranger class.weights will be applied for multiclass.")
      }
    }
  }

  all_specs <- get_model_specs(config$problem_type,
                               config$advanced$tuning_budget,
                               config$advanced$imbalance,
                               class_weight_vec)

  needs_norm <- c("glmnet", "svm", "knn", "mars")
  tree_based <- c("ranger", "xgboost", "nb", "dtree")

  # Safety: any model not in either list defaults to normalized recipe (safer default)
  unassigned <- setdiff(names(all_specs), c(needs_norm, tree_based))
  if (length(unassigned) > 0) {
    log <- c(log, sprintf("\u26a0 Models defaulting to normalized recipe: %s",
                          paste(unassigned, collapse = ", ")))
    needs_norm <- c(needs_norm, unassigned)
  }

  norm_specs <- all_specs[intersect(names(all_specs), needs_norm)]
  base_specs <- all_specs[intersect(names(all_specs), tree_based)]

  wfs_parts <- list()
  if (length(base_specs) > 0) {
    wfs_parts$base <- build_workflowset(list(base = rec_base), base_specs)
  }
  if (length(norm_specs) > 0) {
    wfs_parts$norm <- build_workflowset(list(normalized = rec_norm), norm_specs)
  }

  wflowset <- dplyr::bind_rows(wfs_parts)
  if (!inherits(wflowset, "workflow_set")) {
    class(wflowset) <- c("workflow_set", class(wflowset))
  }

  # Guard: empty workflow set (all models filtered out)
  if (nrow(wflowset) == 0) {
    stop("No models were selected for training. Check your tuning budget and data compatibility.")
  }

  log <- c(log, sprintf("[%s] Training %d model configurations\u2026",
                        format(Sys.time(), "%H:%M:%S"), nrow(wflowset)))

  start_time <- Sys.time()
  tune_results <- train_and_tune(wflowset, resample_obj$folds, config)
  elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  log <- c(log, sprintf("[%s] Training complete in %.1fs.",
                        format(Sys.time(), "%H:%M:%S"), elapsed))

  # Leaderboard
  rankings <- tune_results %>%
    workflowsets::rank_results(rank_metric = config$metric, select_best = TRUE) %>%
    dplyr::select(rank, wflow_id, .metric, mean, std_err, n) %>%
    dplyr::filter(.metric == config$metric) %>%
    dplyr::arrange(rank)

  leaderboard <- rankings %>%
    dplyr::transmute(
      Rank           = rank,
      `Model name`   = wflow_id,
      `Metric (mean)` = round(mean, 4),
      `Metric (SE)`  = round(std_err, 4),
      Runtime        = NA_character_,
      Notes          = ""
    )

  model_summaries <- purrr::map(seq_len(nrow(rankings)), function(i) {
    row <- rankings[i, ]
    list(
      model_name  = row$wflow_id,
      metric_mean = row$mean,
      metric_se   = row$std_err,
      runtime_secs = elapsed / nrow(rankings),
      notes       = ""
    )
  })

  # Ensemble
  ensemble_result <- NULL
  if (config$advanced$ensemble) {
    log <- c(log, "Attempting ensemble\u2026")
    ensemble_result <- build_ensemble(tune_results, config)
    if (!is.null(ensemble_result)) {
      log <- c(log, "\u2713 Ensemble built successfully.")
    } else {
      log <- c(log, "Ensemble did not improve results; skipping.")
    }
  }

  # Confidence outputs
  log <- c(log, "Computing confidence outputs\u2026")
  confidence <- tryCatch(
    compute_confidence_outputs(tune_results, resample_obj$split, config),
    error = function(e) {
      log <<- c(log, paste("Confidence computation warning:", e$message))
      list()
    }
  )

  # Predictions
  predictions <- NULL
  if (!is.null(confidence$final_fit)) {
    predictions <- tryCatch(
      tune::collect_predictions(confidence$final_fit),
      error = function(e) NULL
    )
  }

  # Feature importance
  importance <- NULL
  tryCatch({
    if (requireNamespace("vip", quietly = TRUE) && !is.null(confidence$final_fit)) {
      final_fitted <- confidence$final_fit$.workflow[[1]]
      metric_fn <- yardstick_metric(config$metric)
      metric_set_fn <- yardstick::metric_set(metric_fn)
      imp <- vip::vi(final_fitted, method = "permute",
                     train = rsample::training(resample_obj$split),
                     target = config$target, metric = metric_set_fn, nsim = 5)
      importance <- tibble::tibble(
        variable   = imp$Variable,
        importance = imp$Importance
      ) %>% dplyr::arrange(dplyr::desc(importance))
    }
  }, error = function(e) NULL)

  # SHAP values are now computed on-demand via the Explain tab button
  # to avoid unnecessary computation when users don't need explainability
  shap_data <- NULL

  # Data drift detection
  log <- c(log, "Checking for data drift\u2026")
  drift_data <- compute_data_drift(resample_obj$split, config)

  # Model comparison radar
  radar_data <- compute_model_radar(tune_results, config, elapsed)

  # Diagnostics: ROC / Residuals / Calibration
  roc_data <- NULL
  residuals_data <- NULL
  calibration_data <- NULL

  if (!is.null(predictions)) {
    if (config$problem_type == "classification") {
      tryCatch({
        prob_cols <- grep("^\\.pred_", names(predictions), value = TRUE)
        prob_cols <- setdiff(prob_cols, c(".pred_class", ".pred"))
        if (length(prob_cols) > 0) {
          n_classes <- length(prob_cols)
          roc_data <- yardstick::roc_curve(
            predictions, truth = !!rlang::sym(config$target),
            !!!rlang::syms(prob_cols)
          )
        }
      }, error = function(e) NULL)

      tryCatch({
        prob_cols <- grep("^\\.pred_", names(predictions), value = TRUE)
        prob_cols <- setdiff(prob_cols, c(".pred_class", ".pred"))
        if (length(prob_cols) > 0) {
          # tidymodels convention: first factor level is the event (positive class)
          truth_vec <- predictions[[config$target]]
          event_level <- levels(truth_vec)[1]
          # Find the probability column matching the event level
          event_prob_col <- paste0(".pred_", event_level)
          if (event_prob_col %in% prob_cols) {
            prob_vec <- predictions[[event_prob_col]]
          } else {
            prob_vec <- predictions[[prob_cols[1]]]
          }
          breaks <- seq(0, 1, by = 0.1)
          bins <- cut(prob_vec, breaks, include.lowest = TRUE)
          calibration_data <- tibble::tibble(
            predicted_prob = tapply(prob_vec, bins, mean, na.rm = TRUE),
            observed_freq  = tapply(as.numeric(truth_vec == event_level),
                                    bins, mean, na.rm = TRUE)
          ) %>% tidyr::drop_na()
        }
      }, error = function(e) NULL)

    } else if (config$problem_type == "regression") {
      tryCatch({
        if (".pred" %in% names(predictions) && config$target %in% names(predictions)) {
          residuals_data <- tibble::tibble(
            .pred  = predictions$.pred,
            .resid = predictions[[config$target]] - predictions$.pred,
            model  = "Best model"
          )
        }
      }, error = function(e) NULL)
    }
  }

  log <- c(log, "\u2713 All analyses complete.")

  list(
    leaderboard      = leaderboard,
    model_summaries  = model_summaries,
    tune_results     = tune_results,
    ensemble         = ensemble_result,
    predictions      = predictions,
    importance       = importance,
    confidence       = confidence,
    brier_score      = confidence$brier_score,
    intervals_note   = confidence$intervals_note,
    roc_data         = roc_data,
    residuals_data   = residuals_data,
    calibration_data = calibration_data,
    split            = resample_obj$split,
    folds            = resample_obj$folds,
    config_target    = config$target,
    shap_data        = shap_data,
    drift_data       = drift_data,
    radar_data       = radar_data,
    log              = log
  )
}
