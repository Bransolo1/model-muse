# ============================================================================
# Shiny AutoML Wizard — server.R
# 4-step wizard with rate limiting, logging, validation, and session management.
# ============================================================================

server <- function(input, output, session) {

  # ---- Session logging ----
  session_token <- session$token
  app_log("info", "New session started", list(session = substr(session_token, 1, 8)))

  onSessionEnded(function() {
    # Explicitly clear sensitive data from memory on session end
    tryCatch({
      rv$raw_data       <- NULL
      rv$schema         <- NULL
      rv$health         <- NULL
      rv$results        <- NULL
      rv$run_log        <- character(0)
      rv$predictor_cols <- NULL
      rv$target_col     <- NULL
    }, error = function(e) NULL)  # rv may already be destroyed

    app_log("info", "Session ended — data cleared", list(session = substr(session_token, 1, 8)))
  })

  # ---- Rate limiter for expensive operations ----
  training_limiter <- create_rate_limiter(cooldown_secs = app_config("rate_limit_secs"))
  upload_limiter   <- create_rate_limiter(cooldown_secs = 3)

  # ---- Shared reactive values ----
  rv <- reactiveValues(
    raw_data       = NULL,
    schema         = NULL,
    health         = NULL,
    target_col     = NULL,
    predictor_cols = NULL,
    auto_predictors = TRUE,
    problem_type   = NULL,
    time_col       = NULL,
    metric         = NULL,
    advanced       = list(
      tuning_budget   = "standard",
      cv_folds        = 5,
      cv_repeats      = 1,
      imbalance       = "none",
      ensemble        = TRUE,
      show_uncertainty = FALSE,
      auto_feature_eng = TRUE
    ),
    run_id         = NULL,
    run_status     = "idle",
    run_log        = character(0),
    results        = NULL
  )

  # ---- Step completion tracking ----
  step_complete <- reactive({
    list(
      upload    = !is.null(rv$raw_data),
      configure = !is.null(rv$target_col) && !is.null(rv$predictor_cols) &&
                  length(rv$predictor_cols) > 0 && !is.null(rv$problem_type),
      advanced  = TRUE,
      results   = TRUE
    )
  })

  # ---- Step navigation (4 steps) with gating ----
  step_order <- c("upload", "configure", "advanced", "results")

  can_access_step <- function(step) {
    sc <- step_complete()
    idx <- match(step, step_order)
    if (idx == 1) return(TRUE)
    all(unlist(sc[step_order[1:(idx - 1)]]))
  }

  observeEvent(input$next_step, {
    idx <- match(input$wizard_step, step_order)
    if (!is.na(idx) && idx < length(step_order)) {
      next_step <- step_order[idx + 1]
      if (can_access_step(next_step)) {
        updateRadioButtons(session, "wizard_step", selected = next_step)
      }
    }
  })

  observeEvent(input$prev_step, {
    idx <- match(input$wizard_step, step_order)
    if (!is.na(idx) && idx > 1) {
      updateRadioButtons(session, "wizard_step",
                         selected = step_order[idx - 1])
    }
  })

  # ---- Step gating: disable inaccessible steps via JS ----
  observe({
    sc <- step_complete()
    session$sendCustomMessage("stepGating", list(
      upload    = sc$upload,
      configure = sc$configure,
      advanced  = sc$upload && sc$configure,
      results   = sc$upload && sc$configure
    ))
  })

  # Upload step: no auto-advance; user clicks Next when ready

  # ---- Reset all (with confirmation via JS) ----
  observeEvent(input$reset_all, {
    session$sendCustomMessage("showConfirmDialog", list(
      title = "Reset everything?",
      body = "This will clear your dataset, configuration, and any training results. This cannot be undone.",
      confirmLabel = "Reset all \u2716",
      inputId = "confirmed_reset"
    ))
  })

  observeEvent(input$confirmed_reset, {
    log_user_action("reset_all", session_token)

    rv$raw_data       <- NULL
    rv$schema         <- NULL
    rv$health         <- NULL
    rv$target_col     <- NULL
    rv$predictor_cols <- NULL
    rv$auto_predictors <- TRUE
    rv$problem_type   <- NULL
    rv$time_col       <- NULL
    rv$metric         <- NULL
    rv$advanced       <- list(
      tuning_budget = "standard", cv_folds = 5, cv_repeats = 1,
      imbalance = "none", ensemble = TRUE, show_uncertainty = FALSE,
      auto_feature_eng = TRUE
    )
    rv$run_id         <- NULL
    rv$run_status     <- "idle"
    rv$run_log        <- character(0)
    rv$results        <- NULL

    training_limiter$reset()

    updateRadioButtons(session, "wizard_step", selected = "upload")
    showNotification("All settings reset.", type = "message", duration = 3)
  })

  # ---- Session save/restore ----
  output$save_session <- downloadHandler(
    filename = function() {
      paste0("sensehub_session_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".rds")
    },
    content = function(file) {
      log_user_action("save_session", session_token)
      session_state <- list(
        raw_data       = rv$raw_data,
        schema         = rv$schema,
        health         = rv$health,
        target_col     = rv$target_col,
        predictor_cols = rv$predictor_cols,
        auto_predictors = rv$auto_predictors,
        problem_type   = rv$problem_type,
        time_col       = rv$time_col,
        metric         = rv$metric,
        advanced       = rv$advanced,
        results        = rv$results,
        run_id         = rv$run_id,
        run_status     = rv$run_status,
        run_log        = rv$run_log
      )
      saveRDS(session_state, file)
    }
  )

  observeEvent(input$restore_session, {
    req(input$restore_session)
    log_user_action("restore_session", session_token,
                    list(file = input$restore_session$name))

    # Validate the restore file
    upload_check <- validate_upload(
      input$restore_session$datapath,
      input$restore_session$name,
      input$restore_session$size
    )
    if (!upload_check$ok) {
      showNotification(paste("\u2717", upload_check$message), type = "error")
      return()
    }

    # RDS safety check
    if (!app_config("allow_rds_upload")) {
      # Session restore is always RDS — allow it but log
      app_log("warn", "Session restore from RDS file",
              list(session = substr(session_token, 1, 8),
                   file = input$restore_session$name))
    }

    tryCatch({
      state <- readRDS(input$restore_session$datapath)

      # Validate structure — must be a named list with expected keys
      required_keys <- c("raw_data", "target_col", "problem_type")
      if (!is.list(state) || !all(required_keys %in% names(state))) {
        showNotification("Invalid session file format.", type = "error")
        return()
      }

      rv$raw_data       <- state$raw_data
      rv$schema         <- state$schema
      rv$health         <- state$health
      rv$target_col     <- state$target_col
      rv$predictor_cols <- state$predictor_cols
      rv$auto_predictors <- state$auto_predictors
      rv$problem_type   <- state$problem_type
      rv$time_col       <- state$time_col
      rv$metric         <- state$metric
      rv$advanced       <- state$advanced
      rv$results        <- state$results
      rv$run_id         <- state$run_id
      rv$run_status     <- state$run_status %||% "idle"
      rv$run_log        <- state$run_log %||% character(0)

      showNotification("Session restored successfully!", type = "message")
    }, error = function(e) {
      log_error("Session restore failed", error = e,
                context = "restore_session")
      showNotification(paste("Failed to restore session:", e$message),
                       type = "error")
    })
  })

  # ---- Wire up modules (pass rate limiters) ----
  mod_upload_server("upload", rv, upload_limiter)
  mod_configure_server("configure", rv)
  mod_advanced_server("advanced", rv)
  mod_results_server("results", rv, training_limiter)
}
