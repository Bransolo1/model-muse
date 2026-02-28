# ============================================================================
# Module: Run & Results (Step 4) — Premium Sensehub Design v2
# ============================================================================

theme_sensehub <- function(base_size = 13) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = "#ffffff", color = NA),
      panel.background = ggplot2::element_rect(fill = "#ffffff", color = NA),
      text             = ggplot2::element_text(color = "#333", family = "Inter"),
      axis.text        = ggplot2::element_text(color = "#888"),
      axis.title       = ggplot2::element_text(color = "#555", face = "plain", size = 11),
      panel.grid.major = ggplot2::element_line(color = "#f0ece6", linewidth = 0.4),
      panel.grid.minor = ggplot2::element_blank(),
      strip.text       = ggplot2::element_text(color = "#ff8c00", face = "bold", size = 12),
      plot.title       = ggplot2::element_text(color = "#1a1a1a", face = "bold",
                                                size = 15, margin = ggplot2::margin(b = 8)),
      plot.subtitle    = ggplot2::element_text(color = "#888", size = 11,
                                                margin = ggplot2::margin(b = 12)),
      plot.caption     = ggplot2::element_text(color = "#bbb", size = 9),
      legend.text      = ggplot2::element_text(color = "#666", size = 10),
      legend.title     = ggplot2::element_text(color = "#555", face = "bold", size = 10),
      plot.margin      = ggplot2::margin(16, 16, 12, 12)
    )
}


mod_results_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Section header
    tags$div(
      class = "sh-section-header",
      tags$div(class = "sh-section-icon", icon("rocket")),
      tags$div(
        tags$h4("Run & Results"),
        tags$p("Train multiple models, rank them, and explore what worked best.")
      )
    ),

    # Config summary + run button
    card(
      class = "sh-accent",
      card_body(
        uiOutput(ns("config_summary")),
        uiOutput(ns("validation_gate")),
        tags$hr(style = "border-color: #e8e4de;"),
        layout_columns(
          col_widths = c(4, 4, 4),
          actionButton(ns("run_btn"),
                       tagList(icon("play"), " Start training"),
                       class = "btn-primary btn-lg w-100"),
          actionButton(ns("stop_btn"),
                       tagList(icon("stop"), " Stop waiting"),
                       class = "btn-outline-danger btn-lg w-100"),
          downloadButton(ns("export_bundle"),
                         tagList(icon("download"), " Export all"),
                         class = "btn-outline-secondary btn-lg w-100")
        )
      )
    ),

    # Progress with elapsed timer
    card(
      class = "mt-3",
      card_header(tags$span(icon("terminal", style = "color: #ff8c00; margin-right: 6px;"), "Training progress")),
      card_body(
        tags$div(
          class = "d-flex align-items-center gap-3 mb-2",
          uiOutput(ns("status_badge")),
          uiOutput(ns("live_indicator")),
          tags$div(id = "elapsed-display", class = "elapsed-timer", "")
        ),
        uiOutput(ns("progress_bar")),
        verbatimTextOutput(ns("run_log"), placeholder = TRUE)
      )
    ),

    # Results overview stats
    uiOutput(ns("results_overview")),

    # Results tabs
    conditionalPanel(
      condition = sprintf("output['%s']", ns("has_results")),

      navset_card_tab(
        title = "Results",
        id    = ns("results_tabs"),

        nav_panel("Leaderboard",
          DT::dataTableOutput(ns("leaderboard"))
        ),

        nav_panel("Model cards",
          uiOutput(ns("model_cards"))
        ),

        nav_panel("Radar",
          tags$p(class = "small", style = "color: #999;",
                 "Compare models across performance, stability, speed, and interpretability."),
          plotOutput(ns("radar_plot"), height = "450px")
        ),

        nav_panel("Diagnostics",
          uiOutput(ns("diagnostics_ui"))
        ),

        nav_panel("Explain",
          tags$p(class = "small", style = "color: #999;",
                 "Feature importance shows associations, not causes. Correlated features can share importance."),
          uiOutput(ns("explain_ui")),
          tags$hr(style = "border-color: #e8e4de;"),
          tags$h5("SHAP Waterfall", style = "color: #ff8c00; font-weight: 700;"),
          tags$p(class = "small", style = "color: #999;",
                 "Shows how each feature pushes the prediction from the baseline for a single observation. ",
                 "SHAP computation is expensive — click the button below to compute on demand."),
          tags$div(
            class = "sh-callout sh-callout-warning mb-2",
            icon("triangle-exclamation", style = "color: #f59e0b;"),
            tags$span("SHAP values require many model predictions. Expect 10\u201360 seconds for typical datasets.")
          ),
          uiOutput(ns("shap_obs_selector_ui")),
          actionButton(ns("compute_shap_btn"),
                       tagList(icon("calculator"), " Compute SHAP values"),
                       class = "btn-outline-secondary btn-sm mb-3"),
          plotOutput(ns("shap_waterfall_plot"), height = "400px"),
          tags$hr(style = "border-color: #e8e4de;"),
          tags$h5("Partial Dependence Plots", style = "color: #ff8c00; font-weight: 700;"),
          tags$p(class = "small", style = "color: #999;",
                 "Shows the average effect of each feature on the prediction."),
          uiOutput(ns("pdp_selector_ui")),
          plotOutput(ns("pdp_plot"), height = "350px"),
          tags$hr(style = "border-color: #e8e4de;"),
          tags$h5("Individual Conditional Expectation (ICE)", style = "color: #ff8c00; font-weight: 700;"),
          tags$p(class = "small", style = "color: #999;",
                 "Shows how predictions change for individual observations."),
          plotOutput(ns("ice_plot"), height = "350px")
        ),

        nav_panel("Drift",
          tags$h5("Data Drift Detection", style = "color: #ff8c00; font-weight: 700;"),
          tags$p(class = "small", style = "color: #999;",
                 "Compares train vs test distributions using KS test (numeric) or Chi-squared (categorical). ",
                 "Drifted features (p < 0.05) may indicate deployment risk."),
          DT::dataTableOutput(ns("drift_table")),
          plotOutput(ns("drift_plot"), height = "300px")
        ),

        nav_panel("CV Folds",
          tags$h5("Cross-Validation Fold Performance", style = "color: #ff8c00; font-weight: 700;"),
          tags$p(class = "small", style = "color: #999;",
                 "Shows how each model performed across individual CV folds. Large variation suggests instability."),
          plotOutput(ns("cv_folds_plot"), height = "400px")
        ),

        nav_panel("Predictions",
          DT::dataTableOutput(ns("predictions_table"))
        ),

        nav_panel("Confidence",
          uiOutput(ns("confidence_ui"))
        ),

        nav_panel("Export",
          tags$h5("Download outputs", style = "color: #ff8c00; font-weight: 700;"),
          tags$p(class = "small mb-3", style = "color: #999;",
                 "Download individual results or the full reproducibility bundle."),
          layout_columns(
            col_widths = c(3, 3, 3, 3),
            downloadButton(ns("dl_predictions"), tagList(icon("file-csv"), " Predictions"),
                           class = "btn-outline-secondary w-100"),
            downloadButton(ns("dl_leaderboard"), tagList(icon("ranking-star"), " Leaderboard"),
                           class = "btn-outline-secondary w-100"),
            downloadButton(ns("dl_leaderboard_json"), tagList(icon("code"), " JSON"),
                           class = "btn-outline-secondary w-100"),
            downloadButton(ns("dl_fitted_model"), tagList(icon("box"), " Model (.rds)"),
                           class = "btn-outline-secondary w-100")
          )
        )
      )
    )
  )
}


mod_results_server <- function(id, rv, training_limiter = NULL) {
  moduleServer(id, function(input, output, session) {

    output$has_results <- reactive(!is.null(rv$results))
    outputOptions(output, "has_results", suspendWhenHidden = FALSE)

    # ---- Disable/enable run button based on status ----
    observe({
      if (rv$run_status == "running") {
        shinyjs::disable("run_btn")
        shinyjs::html("run_btn", '<i class="fa fa-spinner fa-spin"></i> Training\u2026')
      } else {
        shinyjs::enable("run_btn")
        shinyjs::html("run_btn", '<i class="fa fa-play"></i> Start training')
      }
    })

    # ---- Disable export buttons until results exist ----
    observe({
      export_ids <- c("export_bundle", "dl_predictions", "dl_leaderboard",
                      "dl_leaderboard_json", "dl_fitted_model")
      if (is.null(rv$results)) {
        for (eid in export_ids) shinyjs::disable(eid)
      } else {
        for (eid in export_ids) shinyjs::enable(eid)
      }
    })

    # ---- Validation gate ----
    output$validation_gate <- renderUI({
      issues <- character(0)
      if (is.null(rv$raw_data))       issues <- c(issues, "No dataset uploaded")
      if (is.null(rv$target_col))     issues <- c(issues, "No target column selected")
      if (is.null(rv$predictor_cols) || length(rv$predictor_cols) == 0)
        issues <- c(issues, "No predictor columns selected")
      if (is.null(rv$problem_type))   issues <- c(issues, "Problem type not set")
      if (is.null(rv$metric))         issues <- c(issues, "Success metric not set")

      if (length(issues) > 0) {
        tags$div(
          class = "sh-callout sh-callout-warning",
          style = "margin: 8px 0;",
          tags$div(
            icon("triangle-exclamation", style = "color: #f59e0b; margin-top: 2px;"),
            tags$div(
              tags$strong("Before you can run:"),
              tags$ul(
                style = "margin: 4px 0 0 16px; font-size: 0.85rem;",
                lapply(issues, function(i) tags$li(i))
              )
            )
          )
        )
      } else {
        tags$div(
          class = "sh-callout sh-callout-success",
          style = "margin: 8px 0;",
          icon("check-circle", style = "color: #10b981;"),
          tags$span("Ready to train. Click ",
                    tags$strong("Start training"),
                    " or press ",
                    tags$span(class = "kbd-hint",
                              style = "background: rgba(16,185,129,0.1); border-color: rgba(16,185,129,0.2); color: #10b981;",
                              "Ctrl+\u21b5"),
                    " to begin.")
        )
      }
    })

    # ---- Config summary ----
    output$config_summary <- renderUI({
      req(rv$target_col, rv$problem_type)
      tags$div(
        class = "d-flex flex-wrap gap-2 mb-2",
        tags$span(class = "sh-badge sh-badge-orange",
                  icon("bullseye", style = "font-size: 0.65rem;"),
                  paste("Target:", rv$target_col)),
        tags$span(class = "sh-badge sh-badge-orange",
                  paste("Type:", rv$problem_type)),
        tags$span(class = "sh-badge sh-badge-orange",
                  paste("Metric:", metric_label(rv$metric))),
        tags$span(class = "sh-badge sh-badge-muted",
                  if (rv$auto_predictors) "Predictors: Auto"
                  else paste(length(rv$predictor_cols), "predictors")),
        tags$span(class = "sh-badge sh-badge-muted",
                  paste("Budget:", rv$advanced$tuning_budget)),
        tags$span(class = "sh-badge sh-badge-muted",
                  sprintf("CV: %d\u00d7%d", rv$advanced$cv_folds, rv$advanced$cv_repeats))
      )
    })

    # ---- Live indicator ----
    output$live_indicator <- renderUI({
      if (rv$run_status == "running") {
        tags$div(class = "live-indicator running",
                 tags$div(class = "pulse-dot"),
                 "TRAINING")
      }
    })

    # ---- Progress bar ----
    output$progress_bar <- renderUI({
      if (rv$run_status == "running") {
        tags$div(
          style = "margin: 8px 0;",
          tags$div(
            class = "progress",
            style = "height: 6px;",
            tags$div(
              class = "progress-bar progress-bar-striped progress-bar-animated",
              style = "width: 100%;",
              role = "progressbar"
            )
          )
        )
      }
    })

    # ---- Run training with confirmation ----
    observeEvent(input$run_btn, {
      req(rv$raw_data, rv$target_col, rv$predictor_cols, rv$problem_type, rv$metric)
      # Prevent double-submission
      if (rv$run_status == "running") return()

      # Send confirmation dialog
      session$sendCustomMessage("showConfirmDialog", list(
        title = "Start training?",
        body = sprintf(
          "We'll train %s models on %s rows with %d predictors using %s budget. This may take a few minutes.",
          switch(rv$advanced$tuning_budget, quick = "3", standard = "8", thorough = "8"),
          format(nrow(rv$raw_data), big.mark = ","),
          length(rv$predictor_cols),
          rv$advanced$tuning_budget
        ),
        confirmLabel = "Start training \u25b6",
        inputId = session$ns("confirmed_run")
      ))
    })

    observeEvent(input$confirmed_run, {
      req(rv$raw_data, rv$target_col, rv$predictor_cols, rv$problem_type, rv$metric)

      # Rate limit training runs
      if (!is.null(training_limiter)) {
        rate_check <- training_limiter$check()
        if (!rate_check$ok) {
          showNotification(
            sprintf("\u23f3 %s", rate_check$message),
            type = "warning", duration = 5
          )
          return()
        }
      }

      log_user_action("start_training", session$token, list(
        target = rv$target_col,
        n_predictors = length(rv$predictor_cols),
        problem_type = rv$problem_type,
        budget = rv$advanced$tuning_budget,
        n_rows = nrow(rv$raw_data)
      ))

      current_run_id <- paste0("run_", format(Sys.time(), "%Y%m%d_%H%M%S"))
      rv$run_id     <- current_run_id
      rv$run_status <- "running"
      rv$run_log    <- c("Starting run\u2026")

      # Start elapsed timer
      session$sendCustomMessage("startTimer", list())

      config <- list(
        target       = rv$target_col,
        predictors   = rv$predictor_cols,
        problem_type = rv$problem_type,
        time_col     = rv$time_col,
        metric       = rv$metric,
        advanced     = rv$advanced,
        seed         = GLOBAL_SEED
      )

      validation <- validate_config(rv$raw_data, config)
      if (!validation$ok) {
        rv$run_status <- "error"
        rv$run_log <- c(rv$run_log, paste("\u2717", validation$message))
        session$sendCustomMessage("stopTimer", list())
        return()
      }
      rv$run_log <- c(rv$run_log, validation$warnings, "Validation passed \u2713")

      data_snapshot <- rv$raw_data
      future_promise({
        run_full_pipeline(data_snapshot, config)
      }) %...>% (function(results) {
        # Ignore late results if user stopped or started a new run
        if (rv$run_status == "stopped") return()
        if (!identical(rv$run_id, current_run_id)) return()
        rv$results    <- results
        rv$run_status <- "done"
        rv$run_log    <- c(rv$run_log, results$log, "\u2713 Run complete.")
        session$sendCustomMessage("stopTimer", list())
        showNotification("\u2713 Training complete!", type = "message", duration = 5)
      }) %...!% (function(err) {
        if (rv$run_status == "stopped") return()
        if (!identical(rv$run_id, current_run_id)) return()
        rv$run_status <- "error"
        rv$run_log    <- c(rv$run_log, paste("\u2717 Error:", err$message))
        session$sendCustomMessage("stopTimer", list())
        showNotification(paste("\u2717 Training failed:", err$message), type = "error", duration = 10)
      })
    })

    observeEvent(input$stop_btn, {
      if (rv$run_status == "running") {
        rv$run_status <- "stopped"
        rv$run_log <- c(rv$run_log, "\u23f9 Stopped waiting for results.")
        rv$run_log <- c(rv$run_log, "\u26a0 The background computation will finish naturally but results will be discarded.")
        session$sendCustomMessage("stopTimer", list())
        showNotification(
          "\u23f9 Stopped waiting. Background job will finish but results will be ignored.",
          type = "warning", duration = 5
        )
      }
    })

    # ---- Status badge ----
    output$status_badge <- renderUI({
      badge_class <- switch(rv$run_status,
        running = "sh-badge sh-badge-orange",
        done    = "sh-badge sh-badge-success",
        error   = "sh-badge sh-badge-danger",
        "sh-badge sh-badge-muted"
      )
      icon_name <- switch(rv$run_status,
        running = "spinner",
        done    = "check-circle",
        error   = "circle-xmark",
        "circle"
      )
      tags$span(class = badge_class,
                icon(icon_name, style = "font-size: 0.7rem;"),
                toupper(rv$run_status))
    })

    output$run_log <- renderText({ paste(rv$run_log, collapse = "\n") })

    # ---- Results overview (stat cards) ----
    output$results_overview <- renderUI({
      req(rv$results)
      lb <- rv$results$leaderboard
      req(lb, nrow(lb) > 0)

      best_score <- lb$`Metric (mean)`[1]
      best_model <- lb$`Model name`[1]
      n_models   <- nrow(lb)

      tags$div(
        class = "d-flex gap-3 mt-3 mb-1",
        style = "animation: cardEntrance 0.45s var(--sh-ease) both;",
        tags$div(class = "stat-card", style = "flex: 1;",
                 tags$div(class = "stat-value", sprintf("%.4f", best_score)),
                 tags$div(class = "stat-label", paste("Best", metric_label(rv$metric)))),
        tags$div(class = "stat-card", style = "flex: 1;",
                 tags$div(class = "stat-value", style = "font-size: 1rem;", best_model),
                 tags$div(class = "stat-label", "Best model")),
        tags$div(class = "stat-card", style = "flex: 1;",
                 tags$div(class = "stat-value", n_models),
                 tags$div(class = "stat-label", "Models trained")),
        tags$div(class = "stat-card", style = "flex: 1;",
                 tags$div(class = "stat-value",
                          if (!is.null(rv$results$ensemble)) "\u2713" else "\u2014"),
                 tags$div(class = "stat-label", "Ensemble"))
      )
    })

    # ---- Leaderboard ----
    output$leaderboard <- DT::renderDataTable({
      req(rv$results$leaderboard)
      DT::datatable(
        rv$results$leaderboard,
        options  = list(pageLength = 20, dom = "t", ordering = TRUE),
        rownames = FALSE, class = "compact stripe hover"
      ) %>%
        DT::formatStyle("Rank", fontWeight = "bold", color = "#ff8c00")
    })

    # ---- Model cards ----
    output$model_cards <- renderUI({
      req(rv$results$model_summaries)
      summaries <- rv$results$model_summaries
      card_list <- lapply(seq_along(summaries), function(i) {
        s <- summaries[[i]]
        rank_icon <- if (i == 1) icon("trophy", style = "color: #ff8c00;") else icon("medal", style = "color: #ccc;")
        card(
          class = "sh-accent",
          card_header(
            tags$div(
              class = "d-flex align-items-center gap-2",
              rank_icon,
              tags$span(style = "color: #ff8c00; font-weight: 700;",
                        paste0("#", i, " ", s$model_name))
            )
          ),
          card_body(
            tags$div(
              class = "stat-value", style = "font-size: 1.4rem;",
              sprintf("%.4f", s$metric_mean)
            ),
            tags$div(class = "stat-label",
                     sprintf("%s \u00b1 %.4f", metric_label(rv$metric), s$metric_se)),
            tags$div(class = "mt-2",
                     tags$span(class = "sh-badge sh-badge-muted",
                               icon("clock", style = "font-size: 0.6rem;"),
                               sprintf("%.1fs", s$runtime_secs))),
            if (!is.null(s$notes) && nchar(s$notes) > 0)
              tags$p(class = "small mt-2", style = "color: #999;", s$notes)
          )
        )
      })
      n_cols <- min(3, length(card_list))
      col_w  <- rep(12 %/% n_cols, length(card_list))
      layout_columns(col_widths = col_w, !!!card_list)
    })

    # ---- Radar chart ----
    output$radar_plot <- renderPlot({
      req(rv$results$radar_data)
      radar <- rv$results$radar_data

      ggplot2::ggplot(radar,
                      ggplot2::aes(x = dimension, y = value,
                                   fill = model, group = model)) +
        ggplot2::geom_col(position = "dodge", alpha = 0.85, width = 0.7) +
        ggplot2::coord_polar() +
        ggplot2::scale_fill_manual(
          values = c("#ff8c00", "#ff6600", "#1a1a1a", "#10b981", "#3b82f6", "#8b5cf6")
        ) +
        ggplot2::scale_y_continuous(limits = c(0, 1), breaks = c(0.25, 0.5, 0.75, 1)) +
        theme_sensehub() +
        ggplot2::theme(
          axis.text.y = ggplot2::element_blank(),
          axis.ticks  = ggplot2::element_blank(),
          panel.grid.major = ggplot2::element_line(color = "#f0ece6", linewidth = 0.3),
          legend.position = "bottom"
        ) +
        ggplot2::labs(title = "Model Comparison", x = NULL, y = NULL, fill = "Model")
    })

    # ---- Diagnostics ----
    output$diagnostics_ui <- renderUI({
      req(rv$results)
      ns <- session$ns
      if (rv$problem_type == "classification") {
        # Determine number of classes for messaging
        target_col <- rv$results$config_target %||% rv$target_col
        req(target_col %in% names(rv$results$predictions))
        n_classes <- dplyr::n_distinct(rv$results$predictions[[target_col]])
        tagList(
          tags$h5("ROC Curve", style = "color: #ff8c00; font-weight: 700;"),
          plotOutput(ns("roc_plot"), height = "350px"),
          tags$hr(style = "border-color: #e8e4de;"),
          tags$h5("Confusion Matrix", style = "color: #ff8c00; font-weight: 700;"),
          plotOutput(ns("confusion_plot"), height = "350px"),
          tags$hr(style = "border-color: #e8e4de;"),
        tags$h5("Precision\u2013Recall Curve", style = "color: #ff8c00; font-weight: 700;"),
          if (n_classes > 2)
            tags$div(class = "sh-callout sh-callout-info",
                     icon("circle-info", style = "color: #ff8c00;"),
                     "PR curve is shown for the first class (one-vs-rest). Multi-class PR is not natively supported.")
          else NULL,
          plotOutput(ns("pr_plot"), height = "350px"),
          tags$hr(style = "border-color: #e8e4de;"),
          tags$h5("Gain Chart", style = "color: #ff8c00; font-weight: 700;"),
          tags$p(class = "small", style = "color: #999;",
                 if (n_classes > 2)
                   "Binary-only metric. Showing for the first class vs rest."
                 else
                   "Shows what percentage of the positive class you capture by scoring the top N% of observations."),
          plotOutput(ns("gain_plot"), height = "350px"),
          tags$hr(style = "border-color: #e8e4de;"),
          tags$h5("Lift Chart", style = "color: #ff8c00; font-weight: 700;"),
          tags$p(class = "small", style = "color: #999;",
                 if (n_classes > 2)
                   "Binary-only metric. Showing for the first class vs rest."
                 else
                   "Shows how much better the model is than random selection at each decile."),
          plotOutput(ns("lift_plot"), height = "350px")
        )
      } else {
        tagList(
          tags$h5("Residuals vs Predicted", style = "color: #ff8c00; font-weight: 700;"),
          plotOutput(ns("residuals_plot"), height = "350px"),
          tags$hr(style = "border-color: #e8e4de;"),
          tags$h5("Actual vs Predicted", style = "color: #ff8c00; font-weight: 700;"),
          plotOutput(ns("actual_vs_pred_plot"), height = "350px"),
          tags$hr(style = "border-color: #e8e4de;"),
          tags$h5("Residual Distribution", style = "color: #ff8c00; font-weight: 700;"),
          plotOutput(ns("residual_dist_plot"), height = "300px"),
          uiOutput(ns("pred_interval_ui"))
        )
      }
    })

    output$roc_plot <- renderPlot({
      req(rv$results$roc_data)
      roc <- rv$results$roc_data
      p <- autoplot(roc) + theme_sensehub()
      if (".level" %in% names(roc)) {
        p <- p + labs(title = "One-vs-Rest ROC Curves (Multi-class)")
      } else {
        p <- p + labs(title = "ROC Curve")
      }
      p
    })

    output$confusion_plot <- renderPlot({
      req(rv$results$predictions)
      preds <- rv$results$predictions
      req(".pred_class" %in% names(preds))
      target_col <- rv$results$config_target %||% rv$target_col
      tryCatch({
        cm <- yardstick::conf_mat(preds, truth = !!rlang::sym(target_col),
                                   estimate = .pred_class)
        autoplot(cm, type = "heatmap") +
          theme_sensehub() +
          ggplot2::scale_fill_gradient(low = "#fff8f0", high = "#ff8c00") +
          labs(title = "Confusion Matrix")
      }, error = function(e) {
        ggplot2::ggplot() +
          ggplot2::annotate("text", x = 0.5, y = 0.5,
                            label = "Confusion matrix unavailable",
                            size = 5, color = "#999") + theme_sensehub()
      })
    })

    output$pr_plot <- renderPlot({
      req(rv$results$predictions)
      preds <- rv$results$predictions
      target_col <- rv$results$config_target %||% rv$target_col
      tryCatch({
        prob_cols <- grep("^\\.pred_", names(preds), value = TRUE)
        prob_cols <- setdiff(prob_cols, c(".pred_class", ".pred"))
        req(length(prob_cols) > 0)
        # Use event-level probability (first factor level per tidymodels convention)
        truth_vec <- preds[[target_col]]
        event_level <- levels(truth_vec)[1]
        event_prob_col <- paste0(".pred_", event_level)
        if (!event_prob_col %in% prob_cols) event_prob_col <- prob_cols[1]
        pr_data <- yardstick::pr_curve(preds, truth = !!rlang::sym(target_col),
                                        !!rlang::sym(event_prob_col))
        autoplot(pr_data) + theme_sensehub() + labs(title = paste0("Precision\u2013Recall Curve (event: ", event_level, ")"))
      }, error = function(e) {
        ggplot2::ggplot() +
          ggplot2::annotate("text", x = 0.5, y = 0.5,
                            label = "PR curve unavailable",
                            size = 5, color = "#999") + theme_sensehub()
      })
    })

    # ---- Gain chart (classification) ----
    output$gain_plot <- renderPlot({
      req(rv$results$predictions, rv$problem_type == "classification")
      preds <- rv$results$predictions
      target_col <- rv$results$config_target %||% rv$target_col
      tryCatch({
        prob_cols <- grep("^\\.pred_", names(preds), value = TRUE)
        prob_cols <- setdiff(prob_cols, c(".pred_class", ".pred"))
        req(length(prob_cols) > 0)
        # Use event-level probability
        truth_vec <- preds[[target_col]]
        event_level <- levels(truth_vec)[1]
        event_prob_col <- paste0(".pred_", event_level)
        if (!event_prob_col %in% prob_cols) event_prob_col <- prob_cols[1]
        gain_data <- yardstick::gain_curve(preds, truth = !!rlang::sym(target_col),
                                            !!rlang::sym(event_prob_col))
        autoplot(gain_data) + theme_sensehub() + labs(title = "Cumulative Gain Chart")
      }, error = function(e) {
        ggplot2::ggplot() +
          ggplot2::annotate("text", x = 0.5, y = 0.5,
                            label = "Gain chart unavailable", size = 5, color = "#999") +
          theme_sensehub()
      })
    })

    # ---- Lift chart (classification) ----
    output$lift_plot <- renderPlot({
      req(rv$results$predictions, rv$problem_type == "classification")
      preds <- rv$results$predictions
      target_col <- rv$results$config_target %||% rv$target_col
      tryCatch({
        prob_cols <- grep("^\\.pred_", names(preds), value = TRUE)
        prob_cols <- setdiff(prob_cols, c(".pred_class", ".pred"))
        req(length(prob_cols) > 0)
        truth_vec <- preds[[target_col]]
        event_level <- levels(truth_vec)[1]
        event_prob_col <- paste0(".pred_", event_level)
        if (!event_prob_col %in% prob_cols) event_prob_col <- prob_cols[1]
        lift_data <- yardstick::lift_curve(preds, truth = !!rlang::sym(target_col),
                                            !!rlang::sym(event_prob_col))
        autoplot(lift_data) + theme_sensehub() +
          ggplot2::geom_hline(yintercept = 1, lty = 2, color = "#ccc") +
          ggplot2::labs(title = paste0("Lift Chart (event: ", event_level, ")"),
                        caption = "Values > 1 mean the model is better than random")
      }, error = function(e) {
        ggplot2::ggplot() +
          ggplot2::annotate("text", x = 0.5, y = 0.5,
                            label = "Lift chart unavailable", size = 5, color = "#999") +
          theme_sensehub()
      })
    })

    output$residuals_plot <- renderPlot({
      req(rv$results$residuals_data)
      ggplot(rv$results$residuals_data, aes(.pred, .resid)) +
        geom_point(alpha = 0.4, color = "#ff8c00") +
        geom_hline(yintercept = 0, lty = 2, color = "#ccc") +
        geom_smooth(method = "loess", color = "#3b82f6", se = FALSE, linewidth = 0.8) +
        facet_wrap(~model) + theme_sensehub() +
        labs(title = "Residuals vs Predicted", x = "Predicted", y = "Residual",
             caption = "Blue line = loess smoother (should be flat)")
    })

    output$actual_vs_pred_plot <- renderPlot({
      req(rv$results$predictions)
      preds <- rv$results$predictions
      target_col <- rv$results$config_target %||% rv$target_col
      req(".pred" %in% names(preds), target_col %in% names(preds))
      ggplot(preds, aes(x = .pred, y = !!rlang::sym(target_col))) +
        geom_point(alpha = 0.4, color = "#ff8c00") +
        geom_abline(slope = 1, intercept = 0, lty = 2, color = "#ccc") +
        theme_sensehub() +
        labs(title = "Actual vs Predicted", x = "Predicted", y = "Actual")
    })

    # ---- Residual distribution ----
    output$residual_dist_plot <- renderPlot({
      req(rv$results$residuals_data)
      ggplot(rv$results$residuals_data, aes(x = .resid)) +
        geom_histogram(fill = "#ff8c00", alpha = 0.8, bins = 40, color = "white", linewidth = 0.2) +
        geom_vline(xintercept = 0, lty = 2, color = "#333") +
        theme_sensehub() +
        labs(title = "Residual Distribution", x = "Residual", y = "Count",
             caption = "Should be symmetric and centered at zero")
    })

    # ---- Prediction interval plot (regression with show_uncertainty) ----
    output$pred_interval_ui <- renderUI({
      req(rv$results$confidence$pred_intervals)
      ns <- session$ns
      tagList(
        tags$hr(style = "border-color: #e8e4de;"),
        tags$h5("Prediction Intervals", style = "color: #ff8c00; font-weight: 700;"),
        tags$p(class = "small", style = "color: #999;",
               rv$results$intervals_note %||% "90% conformal prediction intervals."),
        plotOutput(ns("pred_interval_plot"), height = "400px")
      )
    })

    output$pred_interval_plot <- renderPlot({
      req(rv$results$confidence$pred_intervals)
      pi_data <- rv$results$confidence$pred_intervals
      ggplot2::ggplot(pi_data, ggplot2::aes(x = .pred)) +
        ggplot2::geom_ribbon(ggplot2::aes(ymin = .pred_lower, ymax = .pred_upper),
                              fill = "#ff8c00", alpha = 0.15) +
        ggplot2::geom_point(ggplot2::aes(y = actual), color = "#ff8c00", alpha = 0.4, size = 1.5) +
        ggplot2::geom_abline(slope = 1, intercept = 0, lty = 2, color = "#ccc") +
        theme_sensehub() +
        ggplot2::labs(title = "Actual vs Predicted with 90% Prediction Intervals",
                      x = "Predicted", y = "Actual",
                      caption = sprintf("Coverage: %.1f%%",
                                        (rv$results$confidence$interval_coverage %||% 0) * 100))
    })

    # ---- Explain: importance ----
    output$explain_ui <- renderUI({
      if (is.null(rv$results$importance)) {
        if (!requireNamespace("vip", quietly = TRUE)) {
          return(tags$div(
            class = "sh-callout sh-callout-warning",
            icon("triangle-exclamation", style = "color: #f59e0b;"),
            tags$div(
              tags$strong("Feature importance unavailable"),
              tags$p(class = "small mb-0", style = "color: #888;",
                     "Install the 'vip' package: ",
                     tags$code("install.packages('vip')", style = "color: #ff8c00;"))
            )
          ))
        }
        return(tags$div(
          class = "sh-callout sh-callout-info",
          icon("circle-info", style = "color: #ff8c00;"),
          "Feature importance data not available for this run."
        ))
      }
      tagList(
        tags$h5("Feature importance", style = "color: #ff8c00; font-weight: 700;"),
        plotOutput(session$ns("importance_plot"), height = "400px")
      )
    })

    output$importance_plot <- renderPlot({
      req(rv$results$importance)
      imp <- rv$results$importance
      top <- head(imp, 15)
      top$variable <- factor(top$variable, levels = rev(top$variable))

      ggplot(top, aes(variable, importance)) +
        geom_col(fill = "#ff8c00", alpha = 0.9, width = 0.7) +
        geom_text(aes(label = sprintf("%.3f", importance)),
                  hjust = -0.1, size = 3, color = "#888") +
        coord_flip() + theme_sensehub() +
        ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.15))) +
        labs(title = "Top 15 Features (Permutation Importance)", x = NULL, y = "Importance")
    })

    # ---- SHAP waterfall ----
    output$shap_obs_selector_ui <- renderUI({
      req(rv$results$split)
      ns <- session$ns
      n_train <- nrow(rsample::training(rv$results$split))
      numericInput(ns("shap_obs_idx"), "Observation to explain:",
                   value = 1, min = 1, max = min(n_train, 100), step = 1,
                   width = "200px")
    })

    # ---- SHAP: on-demand computation gated behind button ----
    shap_cache <- reactiveVal(NULL)

    observeEvent(input$compute_shap_btn, {
      req(rv$results$confidence$final_fit, rv$results$split)
      obs_idx <- input$shap_obs_idx %||% 1
      cache_key <- paste0(rv$run_id, "_", obs_idx)

      # Check cache
      cached <- shap_cache()
      if (!is.null(cached) && identical(cached$cache_key, cache_key)) return()

      showNotification("Computing SHAP values\u2026 this may take 10\u201360 seconds.",
                       id = "shap_computing", duration = NULL, type = "message")

      shap <- compute_shap_values(
        rv$results$confidence$final_fit,
        rsample::training(rv$results$split),
        list(
          target = rv$results$config_target %||% rv$target_col,
          predictors = rv$predictor_cols,
          problem_type = rv$problem_type
        ),
        n_obs = obs_idx
      )

      removeNotification("shap_computing")

      if (!is.null(shap)) {
        shap$cache_key <- cache_key
        shap_cache(shap)
        showNotification("\u2713 SHAP values computed.", type = "message", duration = 3)
      } else {
        showNotification("\u2717 SHAP computation failed.", type = "error", duration = 5)
      }
    })

    output$shap_waterfall_plot <- renderPlot({
      shap <- shap_cache()
      if (is.null(shap)) {
        return(ggplot2::ggplot() +
          ggplot2::annotate("text", x = 0.5, y = 0.5,
                            label = "Click 'Compute SHAP values' to generate this plot",
                            size = 4.5, color = "#999") +
          theme_sensehub())
      }

      sv <- head(shap$shap_values, 12)
      sv$feature <- factor(sv$feature, levels = rev(sv$feature))

      ggplot2::ggplot(sv, ggplot2::aes(x = feature, y = shap_value,
                                        fill = shap_value > 0)) +
        ggplot2::geom_col(width = 0.7, show.legend = FALSE) +
        ggplot2::scale_fill_manual(values = c("TRUE" = "#ff8c00", "FALSE" = "#3b82f6")) +
        ggplot2::coord_flip() +
        theme_sensehub() +
        ggplot2::labs(
          title = sprintf("SHAP Waterfall \u2014 Observation #%d", shap$obs_index),
          subtitle = sprintf("Baseline: %.3f | Prediction: %.3f",
                             shap$baseline, shap$prediction),
          x = NULL, y = "SHAP value (contribution)"
        )
    })

    # ---- PDP selector ----
    output$pdp_selector_ui <- renderUI({
      req(rv$results$importance)
      top_features <- head(rv$results$importance$variable, 10)
      ns <- session$ns
      selectInput(ns("pdp_feature"), "Feature to plot:",
                  choices = top_features, selected = top_features[1], width = "300px")
    })

    # ---- PDP plot ----
    output$pdp_plot <- renderPlot({
      req(rv$results$confidence$final_fit, input$pdp_feature, rv$results$split)
      showNotification("Computing PDP\u2026", id = "pdp_computing", duration = NULL, type = "message")
      on.exit(removeNotification("pdp_computing"))
      tryCatch({
        final_wf <- rv$results$confidence$final_fit$.workflow[[1]]
        train_data <- rsample::training(rv$results$split)
        feature <- input$pdp_feature
        if (!feature %in% names(train_data)) return(NULL)
        feat_vals <- train_data[[feature]]

        # Subsample training data for speed (max 500 rows for PDP)
        if (nrow(train_data) > 500) {
          train_data <- train_data[sample(nrow(train_data), 500), ]
        }

        if (is.numeric(feat_vals)) {
          grid_vals <- seq(min(feat_vals, na.rm = TRUE),
                          max(feat_vals, na.rm = TRUE), length.out = 25)
        } else {
          grid_vals <- unique(na.omit(feat_vals))
          if (length(grid_vals) == 0) return(NULL)
        }

        pdp_data <- purrr::map_dfr(grid_vals, function(val) {
          modified <- train_data
          modified[[feature]] <- val
          preds <- predict(final_wf, modified)
        if (".pred" %in% names(preds)) {
            tibble::tibble(feature_value = val, prediction = mean(preds$.pred, na.rm = TRUE))
          } else if (".pred_class" %in% names(preds)) {
            prob_preds <- predict(final_wf, modified, type = "prob")
            # Use event-level probability — derive from TRAINING data, not predictions (which may be NULL)
            event_prob_col <- NULL
            tryCatch({
              target_col_pdp <- rv$results$config_target %||% rv$target_col
              train_target <- train_data[[target_col_pdp]]
              if (is.factor(train_target)) {
                event_level <- levels(train_target)[1]
                event_prob_col <- paste0(".pred_", event_level)
              }
            }, error = function(e) NULL)
            if (!is.null(event_prob_col) && event_prob_col %in% names(prob_preds)) {
              tibble::tibble(feature_value = val, prediction = mean(prob_preds[[event_prob_col]], na.rm = TRUE))
            } else {
              tibble::tibble(feature_value = val, prediction = mean(prob_preds[[1]], na.rm = TRUE))
            }
          } else {
            tibble::tibble(feature_value = val, prediction = NA_real_)
          }
        })

        if (is.numeric(feat_vals)) {
          ggplot2::ggplot(pdp_data, ggplot2::aes(x = feature_value, y = prediction)) +
            ggplot2::geom_line(color = "#ff8c00", linewidth = 1.2) +
            ggplot2::geom_point(color = "#ff8c00", size = 1, alpha = 0.5) +
            theme_sensehub() +
            ggplot2::labs(title = paste("Partial Dependence:", feature),
                          x = feature, y = "Average prediction")
        } else {
          ggplot2::ggplot(pdp_data, ggplot2::aes(x = feature_value, y = prediction)) +
            ggplot2::geom_col(fill = "#ff8c00", alpha = 0.9, width = 0.6) +
            theme_sensehub() +
            ggplot2::labs(title = paste("Partial Dependence:", feature),
                          x = feature, y = "Average prediction")
        }
      }, error = function(e) {
        ggplot2::ggplot() +
          ggplot2::annotate("text", x = 0.5, y = 0.5,
                            label = paste("PDP unavailable:", e$message),
                            size = 4, color = "#999") + theme_sensehub()
      })
    })

    # ---- ICE plot ----
    output$ice_plot <- renderPlot({
      req(rv$results$confidence$final_fit, input$pdp_feature, rv$results$split)
      showNotification("Computing ICE plot\u2026", id = "ice_computing", duration = NULL, type = "message")
      on.exit(removeNotification("ice_computing"))
      tryCatch({
        final_wf <- rv$results$confidence$final_fit$.workflow[[1]]
        train_data <- rsample::training(rv$results$split)
        feature <- input$pdp_feature

        if (!feature %in% names(train_data) || !is.numeric(train_data[[feature]])) {
          return(ggplot2::ggplot() +
            ggplot2::annotate("text", x = 0.5, y = 0.5,
                              label = "ICE plots require a numeric feature",
                              size = 4, color = "#999") + theme_sensehub())
        }

        # Limit to 30 observations and 20 grid points for performance
        sample_idx <- sample(nrow(train_data), min(30, nrow(train_data)))
        grid_vals <- seq(min(train_data[[feature]], na.rm = TRUE),
                        max(train_data[[feature]], na.rm = TRUE), length.out = 20)

        ice_data <- purrr::map_dfr(sample_idx, function(i) {
          purrr::map_dfr(grid_vals, function(val) {
            row <- train_data[i, ]
            row[[feature]] <- val
            pred <- predict(final_wf, row)
            if (".pred" %in% names(pred)) {
              tibble::tibble(obs_id = i, feature_value = val, prediction = pred$.pred)
            } else {
              prob_pred <- predict(final_wf, row, type = "prob")
              # Use event-level probability — derive from TRAINING data, not predictions (which may be NULL)
              event_prob_col_ice <- NULL
              tryCatch({
                target_col_ice <- rv$results$config_target %||% rv$target_col
                train_target_ice <- train_data[[target_col_ice]]
                if (is.factor(train_target_ice)) {
                  event_level_ice <- levels(train_target_ice)[1]
                  event_prob_col_ice <- paste0(".pred_", event_level_ice)
                }
              }, error = function(e) NULL)
              if (!is.null(event_prob_col_ice) && event_prob_col_ice %in% names(prob_pred)) {
                tibble::tibble(obs_id = i, feature_value = val, prediction = prob_pred[[event_prob_col_ice]])
              } else {
                tibble::tibble(obs_id = i, feature_value = val, prediction = prob_pred[[1]])
              }
            }
          })
        })

        ggplot2::ggplot(ice_data,
                        ggplot2::aes(x = feature_value, y = prediction, group = obs_id)) +
          ggplot2::geom_line(alpha = 0.12, color = "#ff8c00") +
          ggplot2::stat_summary(ggplot2::aes(group = 1), fun = mean,
                                geom = "line", color = "#1a1a1a", linewidth = 1.5) +
          theme_sensehub() +
          ggplot2::labs(title = paste("ICE Plot:", feature),
                        x = feature, y = "Prediction",
                        caption = "Bold line = PDP (average)")
      }, error = function(e) {
        ggplot2::ggplot() +
          ggplot2::annotate("text", x = 0.5, y = 0.5,
                            label = paste("ICE unavailable:", e$message),
                            size = 4, color = "#999") + theme_sensehub()
      })
    })

    # ---- Drift table ----
    output$drift_table <- DT::renderDataTable({
      req(rv$results$drift_data)
      dt <- rv$results$drift_data
      dt$status <- ifelse(dt$drifted, "\u26a0 Drifted", "\u2713 Stable")
      DT::datatable(
        dt[, c("feature", "type", "statistic", "p_value", "status")],
        options = list(pageLength = 15, dom = "frtip", ordering = TRUE),
        rownames = FALSE, class = "compact stripe hover"
      ) %>% DT::formatStyle(
        "status",
        color = DT::styleEqual(c("\u26a0 Drifted", "\u2713 Stable"),
                                c("#ef4444", "#10b981")),
        fontWeight = "bold"
      )
    })

    output$drift_plot <- renderPlot({
      req(rv$results$drift_data)
      drift <- rv$results$drift_data %>%
        dplyr::filter(!is.na(p_value)) %>%
        dplyr::arrange(p_value) %>%
        head(15)

      ggplot2::ggplot(drift, ggplot2::aes(x = reorder(feature, -p_value),
                                           y = -log10(p_value + 1e-10),
                                           fill = drifted)) +
        ggplot2::geom_col(width = 0.7, alpha = 0.9) +
        ggplot2::geom_hline(yintercept = -log10(0.05), lty = 2, color = "#ef4444") +
        ggplot2::scale_fill_manual(values = c("TRUE" = "#ef4444", "FALSE" = "#10b981"),
                                   labels = c("TRUE" = "Drifted", "FALSE" = "Stable")) +
        ggplot2::coord_flip() +
        theme_sensehub() +
        ggplot2::labs(title = "Feature Drift Significance",
                      x = NULL, y = "-log10(p-value)",
                      caption = "Red dashed line = p = 0.05 threshold",
                      fill = "Status")
    })

    # ---- CV Folds plot ----
    output$cv_folds_plot <- renderPlot({
      req(rv$results$tune_results)
      tryCatch({
        fold_data <- rv$results$tune_results %>%
          workflowsets::rank_results(rank_metric = rv$metric, select_best = TRUE) %>%
          dplyr::filter(.metric == rv$metric)

        req(nrow(fold_data) > 0)

        # Get fold-level metrics from the best config of each model
        fold_metrics <- purrr::map_dfr(fold_data$wflow_id, function(wf_id) {
          res <- workflowsets::extract_workflow_set_result(rv$results$tune_results, wf_id)
          best_params <- tune::select_best(res, metric = rv$metric)
          # Compute join columns explicitly to avoid fragile `.` reference in pipe
          join_cols <- intersect(names(best_params),
                                 names(tune::collect_metrics(res, summarize = FALSE)))
          join_cols <- setdiff(join_cols, c(".metric", ".estimator", ".estimate", ".config", "n", "mean", "std_err"))
          fold_preds <- tune::collect_metrics(res, summarize = FALSE) %>%
            dplyr::filter(.metric == rv$metric)
          if (length(join_cols) > 0) {
            fold_preds <- dplyr::semi_join(fold_preds, best_params, by = join_cols)
          }
          if (nrow(fold_preds) > 0) {
            fold_preds %>% dplyr::mutate(model = wf_id)
          } else {
            NULL
          }
        })

        req(nrow(fold_metrics) > 0)

        ggplot2::ggplot(fold_metrics, ggplot2::aes(x = model, y = .estimate, fill = model)) +
          ggplot2::geom_boxplot(alpha = 0.8, width = 0.6, show.legend = FALSE,
                                 color = "#888", outlier.color = "#ef4444") +
          ggplot2::geom_jitter(width = 0.15, alpha = 0.4, size = 1.5, color = "#333") +
          ggplot2::scale_fill_manual(
            values = c("#ff8c00", "#ff6600", "#10b981", "#3b82f6", "#8b5cf6",
                       "#f59e0b", "#ef4444", "#06b6d4", "#84cc16", "#ec4899")
          ) +
          ggplot2::coord_flip() +
          theme_sensehub() +
          ggplot2::labs(
            title = sprintf("CV Fold Performance (%s)", metric_label(rv$metric)),
            x = NULL, y = metric_label(rv$metric),
            caption = "Each point = one fold. Wider box = more variance."
          )
      }, error = function(e) {
        ggplot2::ggplot() +
          ggplot2::annotate("text", x = 0.5, y = 0.5,
                            label = "CV fold data unavailable",
                            size = 5, color = "#999") + theme_sensehub()
      })
    })

    # ---- Predictions ----
    output$predictions_table <- DT::renderDataTable({
      req(rv$results$predictions)
      DT::datatable(
        head(rv$results$predictions, 500),
        options = list(pageLength = 20, scrollX = TRUE, dom = "frtip"),
        rownames = FALSE, class = "compact stripe hover"
      )
    })

    # ---- Confidence ----
    output$confidence_ui <- renderUI({
      req(rv$results)
      has_cal <- !is.null(rv$results$calibration_data)
      has_intervals <- !is.null(rv$results$intervals_note)
      has_pred_intervals <- !is.null(rv$results$confidence$pred_intervals)

      if (!has_cal && !has_intervals && !has_pred_intervals) {
        return(tags$div(
          class = "sh-callout sh-callout-info",
          icon("circle-info", style = "color: #ff8c00;"),
          tags$div(
            tags$strong("No confidence data available."),
            tags$p(class = "small mb-0", style = "color: #888;",
                   if (rv$problem_type == "regression")
                     "Enable 'Show uncertainty intervals' in Advanced settings to see prediction intervals here."
                   else
                     "Calibration data was not generated for this run.")
          )
        ))
      }

      tagList(
        if (has_cal) {
          tagList(
            tags$h5("Probability calibration", style = "color: #ff8c00; font-weight: 700;"),
            tags$p(class = "small", style = "color: #999;",
                   "A well-calibrated model: predicted 0.8 \u2192 correct ~80% of the time."),
            plotOutput(session$ns("calibration_plot"), height = "350px"),
            if (!is.null(rv$results$brier_score))
              tags$div(
                class = "sh-callout sh-callout-info", style = "margin-top: 8px;",
                icon("chart-simple", style = "color: #ff8c00;"),
                sprintf("Brier score: %.4f (lower is better, 0 = perfect)", rv$results$brier_score)
              )
          )
        },
        if (has_intervals)
          tags$div(
            class = "sh-callout sh-callout-info",
            icon("circle-info", style = "color: #ff8c00;"),
            rv$results$intervals_note
          )
      )
    })

    output$calibration_plot <- renderPlot({
      req(rv$results$calibration_data)
      ggplot(rv$results$calibration_data, aes(predicted_prob, observed_freq)) +
        geom_abline(lty = 2, color = "#e8e4de") +
        geom_point(size = 3, color = "#ff8c00") +
        geom_line(color = "#ff8c00", linewidth = 0.8) + theme_sensehub() +
        labs(title = "Reliability Curve", x = "Predicted probability", y = "Observed frequency")
    })

    # ---- Downloads ----
    output$dl_predictions <- downloadHandler(
      filename = function() paste0(rv$run_id %||% "export", "_predictions.csv"),
      content  = function(file) {
        req(rv$results$predictions)
        readr::write_csv(rv$results$predictions, file)
      }
    )

    output$dl_leaderboard <- downloadHandler(
      filename = function() paste0(rv$run_id %||% "export", "_leaderboard.csv"),
      content  = function(file) {
        req(rv$results$leaderboard)
        readr::write_csv(rv$results$leaderboard, file)
      }
    )

    output$dl_leaderboard_json <- downloadHandler(
      filename = function() paste0(rv$run_id %||% "export", "_leaderboard.json"),
      content  = function(file) {
        req(rv$results$leaderboard)
        jsonlite::write_json(rv$results$leaderboard, file, pretty = TRUE)
      }
    )

    output$dl_fitted_model <- downloadHandler(
      filename = function() paste0(rv$run_id %||% "export", "_fitted_model.rds"),
      content  = function(file) {
        req(rv$results$confidence$final_fit)
        saveRDS(rv$results$confidence$final_fit, file)
      }
    )

    output$export_bundle <- downloadHandler(
      filename = function() paste0(rv$run_id %||% "export", "_bundle.zip"),
      content  = function(file) {
        req(rv$results)
        config <- list(
          target       = rv$target_col,
          predictors   = rv$predictor_cols,
          problem_type = rv$problem_type,
          metric       = rv$metric,
          advanced     = rv$advanced,
          seed         = GLOBAL_SEED
        )
        export_bundle(rv$results, config, rv$run_id, file)
      }
    )
  })
}
