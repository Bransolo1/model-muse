# ============================================================================
# Module: Configure (Step 2) — Premium Sensehub Design v2
# ============================================================================

mod_configure_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Section header
    tags$div(
      class = "sh-section-header",
      tags$div(class = "sh-section-icon", icon("crosshairs")),
      tags$div(
        tags$h4("Configure your model"),
        tags$p("We auto-detect the best settings from your data. Override anything that doesn\u2019t look right.")
      )
    ),

    layout_columns(
      col_widths = c(6, 6),

      # ---- Left: Target + Problem Type ----
      card(
        class = "sh-accent",
        card_header(tags$span(icon("bullseye", style = "color: #ff8c00; margin-right: 6px;"), "What to predict")),
        card_body(
          selectInput(ns("target"), "Target column", choices = NULL, width = "100%"),
          uiOutput(ns("target_summary")),
          uiOutput(ns("target_dist_ui")),
          tags$hr(style = "border-color: #e8e4de;"),
          tags$label("Problem type",
                     class = "form-label sh-tooltip",
                     `data-tooltip` = "Classification for categories, regression for numbers"),
          radioButtons(
            ns("problem_type"), label = NULL,
            choiceNames = list(
              tags$span(icon("tags"), " Classification",
                        tags$small(style = "color: #999;", " \u2014 predict a category")),
              tags$span(icon("chart-line"), " Regression",
                        tags$small(style = "color: #999;", " \u2014 predict a number")),
              tags$span(icon("wand-magic-sparkles"), " Auto-detect",
                        tags$small(style = "color: #999;", " \u2014 we\u2019ll figure it out"))
            ),
            choiceValues = c("classification", "regression", "auto"),
            selected = "auto"
          ),
          uiOutput(ns("inferred_badge")),
          tags$hr(style = "border-color: #e8e4de;"),
          tags$label("Success metric",
                     class = "form-label sh-tooltip",
                     `data-tooltip` = "How we rank models. Auto picks the best default."),
          selectInput(ns("metric"), NULL, choices = c("(auto)" = "auto"), width = "100%"),
          uiOutput(ns("metric_note"))
        )
      ),

      # ---- Right: Predictors ----
      card(
        class = "sh-accent",
        card_header(tags$span(icon("table-columns", style = "color: #ff8c00; margin-right: 6px;"), "Predictor columns")),
        card_body(
          switchInput(ns("auto_select"), label = "Auto-select",
                      value = TRUE, size = "small",
                      onLabel = "Auto", offLabel = "Manual",
                      onStatus = "warning"),
          conditionalPanel(
            condition = sprintf("!input['%s']", ns("auto_select")),
            pickerInput(
              ns("manual_predictors"), label = NULL, choices = NULL,
              multiple = TRUE,
              options = list(
                `actions-box` = TRUE, `live-search` = TRUE,
                `selected-text-format` = "count > 3",
                `count-selected-text` = "{0} columns selected",
                style = "btn-outline-secondary"
              ),
              width = "100%"
            )
          ),
          uiOutput(ns("predictor_summary")),
          tags$hr(style = "border-color: #e8e4de;"),
          uiOutput(ns("correlation_warning")),
          uiOutput(ns("excluded_ui"))
        )
      )
    ),

    # Correlation heatmap
    card(
      class = "mt-3",
      card_header(tags$span(icon("grip", style = "color: #ff8c00; margin-right: 6px;"), "Correlation matrix")),
      card_body(
        uiOutput(ns("correlation_heatmap_ui"))
      )
    )
  )
}


mod_configure_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {

    # ---- Smart target column heuristic ----
    guess_target_column <- function(data, schema, health) {
      cols <- names(data)
      n <- nrow(data)

      # Exclude suspected IDs and date columns
      excluded <- character(0)
      if (!is.null(health)) {
        excluded <- c(health$suspected_ids, health$suspected_dates)
      }
      candidates <- setdiff(cols, excluded)
      if (length(candidates) == 0) candidates <- cols

      # Exclude columns with near-unique values (>95% unique = likely ID)
      if (!is.null(schema)) {
        near_unique <- schema$column[schema$n_unique > 0.95 * n]
        candidates <- setdiff(candidates, near_unique)
        if (length(candidates) == 0) candidates <- setdiff(cols, excluded)
      }

      # Score candidates
      scores <- purrr::map_dbl(candidates, function(col) {
        x <- data[[col]]
        nu <- dplyr::n_distinct(x, na.rm = TRUE)
        pct_missing <- mean(is.na(x))
        score <- 0
        # Penalise high missingness
        score <- score - pct_missing * 5
        # Prefer categorical with reasonable cardinality for classification
        if (is.factor(x) || is.character(x)) {
          if (nu >= 2 && nu <= 20) score <- score + 3
          else if (nu > 20) score <- score - 1
        }
        # Prefer numeric with variance for regression
        if (is.numeric(x)) {
          if (nu > 10 && !is.na(sd(x, na.rm = TRUE)) && sd(x, na.rm = TRUE) > 1e-8) {
            score <- score + 2
          }
          if (nu <= 10 && nu >= 2) score <- score + 3  # low-cardinality numeric = classification
        }
        # Prefer columns named like targets
        if (grepl("target|label|class|outcome|y$|response|status", col, ignore.case = TRUE)) {
          score <- score + 5
        }
        score
      })

      best <- candidates[which.max(scores)]
      best
    }

    observeEvent(rv$raw_data, {
      cols <- names(rv$raw_data)
      guess <- tryCatch(
        guess_target_column(rv$raw_data, rv$schema, rv$health),
        error = function(e) cols[length(cols)]
      )
      updateSelectInput(session, "target", choices = cols, selected = guess)
      showNotification(
        sprintf("\U0001f9e0 Guessed target: %s — change if wrong.", guess),
        type = "message", duration = 5
      )
    }, ignoreInit = TRUE, ignoreNULL = TRUE)

    observeEvent(input$target, {
      req(nzchar(input$target))
      rv$target_col <- input$target
    }, ignoreInit = TRUE)

    # ---- Target summary with distribution preview ----
    output$target_summary <- renderUI({
      req(rv$raw_data, rv$target_col)
      col <- rv$raw_data[[rv$target_col]]
      if (is.null(col)) return(NULL)

      if (is.numeric(col)) {
        tags$div(
          class = "small mt-2 d-flex flex-wrap align-items-center gap-2",
          tags$span(class = "sh-badge sh-badge-orange",
                    icon("hashtag", style = "font-size: 0.65rem;"), "Numeric"),
          tags$span(style = "color: #666;",
            sprintf("%.2f \u2013 %.2f | Mean: %.2f | %d missing",
                    min(col, na.rm = TRUE), max(col, na.rm = TRUE),
                    mean(col, na.rm = TRUE), sum(is.na(col))))
        )
      } else {
        lvls <- sort(table(col), decreasing = TRUE)
        tags$div(
          class = "small mt-2 d-flex flex-wrap align-items-center gap-2",
          tags$span(class = "sh-badge sh-badge-info",
                    icon("tags", style = "font-size: 0.65rem;"),
                    paste(length(lvls), "classes")),
          tags$span(style = "color: #666;",
            paste(head(names(lvls), 4), collapse = ", ")),
          if (sum(is.na(col)) > 0)
            tags$span(class = "sh-badge sh-badge-danger",
                      sprintf("%d missing", sum(is.na(col))))
        )
      }
    })

    # ---- Target distribution mini-plot ----
    output$target_dist_ui <- renderUI({
      req(rv$raw_data, rv$target_col)
      plotOutput(session$ns("target_dist_plot"), height = "120px")
    })

    output$target_dist_plot <- renderPlot({
      req(rv$raw_data, rv$target_col)
      col <- rv$raw_data[[rv$target_col]]
      if (is.null(col)) return(NULL)

      df <- data.frame(value = col)

      if (is.numeric(col)) {
        ggplot2::ggplot(df, ggplot2::aes(x = value)) +
          ggplot2::geom_histogram(fill = "#ff8c00", alpha = 0.8, bins = 30,
                                  color = "white", linewidth = 0.2) +
          theme_sensehub(base_size = 10) +
          ggplot2::theme(
            plot.margin = ggplot2::margin(4, 4, 4, 4),
            axis.title = ggplot2::element_blank()
          ) +
          ggplot2::labs(title = NULL)
      } else {
        lvls <- sort(table(col), decreasing = TRUE)
        top <- head(names(lvls), 8)
        df <- df[df$value %in% top, , drop = FALSE]
        df$value <- factor(df$value, levels = top)

        ggplot2::ggplot(df, ggplot2::aes(x = value)) +
          ggplot2::geom_bar(fill = "#3b82f6", alpha = 0.85, width = 0.7) +
          theme_sensehub(base_size = 10) +
          ggplot2::theme(
            plot.margin = ggplot2::margin(4, 4, 4, 4),
            axis.title = ggplot2::element_blank(),
            axis.text.x = ggplot2::element_text(angle = 30, hjust = 1, size = 8)
          ) +
          ggplot2::labs(title = NULL)
      }
    })

    inferred_type <- reactive({
      req(rv$raw_data, rv$target_col)
      infer_problem_type(rv$raw_data, rv$target_col)
    })

    observeEvent(input$problem_type, {
      chosen <- input$problem_type
      if (is.null(chosen)) return()
      if (chosen == "auto") {
        if (!is.null(rv$raw_data) && !is.null(rv$target_col)) {
          rv$problem_type <- inferred_type()
        }
      } else {
        rv$problem_type <- chosen
      }
      rv$time_col <- NULL
    }, ignoreInit = TRUE)

    observeEvent(rv$target_col, {
      if (!is.null(input$problem_type) && input$problem_type == "auto" &&
          !is.null(rv$raw_data)) {
        rv$problem_type <- inferred_type()
      }
    }, ignoreInit = TRUE, ignoreNULL = TRUE)

    output$inferred_badge <- renderUI({
      req(input$problem_type == "auto", rv$raw_data, rv$target_col)
      inf <- inferred_type()
      reason <- if (inf == "classification") {
        "Target is categorical or has \u226410 unique values"
      } else {
        "Target is numeric with >10 unique values"
      }
      tags$div(
        class = "mt-2",
        tags$span(class = "sh-badge sh-badge-orange",
                  icon("magic"), sprintf(" Detected: %s", inf)),
        tags$small(style = "color: #999; display: block; margin-top: 4px;", reason)
      )
    })

    observeEvent(rv$problem_type, {
      req(rv$problem_type)
      metrics <- switch(rv$problem_type,
        classification = c(
          "(auto)" = "auto", "ROC AUC" = "roc_auc", "PR AUC" = "pr_auc",
          "Log loss" = "mn_log_loss", "Accuracy" = "accuracy", "F1" = "f_meas"
        ),
        regression = c(
          "(auto)" = "auto", "RMSE" = "rmse", "MAE" = "mae",
          "R\u00b2" = "rsq", "MAPE" = "mape"
        ),
        c("(auto)" = "auto")
      )
      updateSelectInput(session, "metric", choices = metrics)
    }, ignoreInit = TRUE, ignoreNULL = TRUE)

    observeEvent(input$metric, {
      chosen_metric <- input$metric
      if (is.null(chosen_metric) || chosen_metric == "auto") {
        if (!is.null(rv$problem_type)) {
          rv$metric <- select_default_metric(rv$problem_type, rv$raw_data, rv$target_col)
        }
      } else {
        rv$metric <- chosen_metric
      }
    }, ignoreInit = TRUE)

    observeEvent(rv$problem_type, {
      if (is.null(input$metric) || input$metric == "auto") {
        rv$metric <- select_default_metric(rv$problem_type, rv$raw_data, rv$target_col)
      }
    }, ignoreInit = TRUE, ignoreNULL = TRUE, priority = -1)

    output$metric_note <- renderUI({
      req(rv$metric)
      tags$span(class = "sh-badge sh-badge-muted",
                icon("chart-simple", style = "font-size: 0.7rem;"),
                sprintf("Using: %s", metric_label(rv$metric)))
    })

    available_cols <- reactive({
      req(rv$raw_data, rv$target_col)
      setdiff(names(rv$raw_data), rv$target_col)
    })

    id_cols <- reactive({
      req(rv$health)
      rv$health$suspected_ids
    })

    observeEvent(rv$target_col, {
      req(rv$raw_data)
      cols <- setdiff(names(rv$raw_data), rv$target_col)
      ids <- tryCatch(id_cols(), error = function(e) character(0))
      if (is.null(ids)) ids <- character(0)
      updatePickerInput(session, "manual_predictors",
                        choices = cols, selected = setdiff(cols, ids))
    }, ignoreInit = TRUE, ignoreNULL = TRUE)

    observeEvent(list(input$auto_select, rv$target_col, rv$raw_data), {
      auto <- isTRUE(input$auto_select)
      rv$auto_predictors <- auto
      if (auto) {
        if (is.null(rv$raw_data) || is.null(rv$target_col)) return()
        ids <- tryCatch(id_cols(), error = function(e) character(0))
        if (is.null(ids)) ids <- character(0)
        rv$predictor_cols <- setdiff(available_cols(), ids)
      } else {
        rv$predictor_cols <- input$manual_predictors
      }
    }, ignoreInit = TRUE)

    observeEvent(input$manual_predictors, {
      if (!isTRUE(input$auto_select)) {
        rv$predictor_cols <- input$manual_predictors
      }
    }, ignoreInit = TRUE)

    output$predictor_summary <- renderUI({
      req(rv$predictor_cols)
      n <- length(rv$predictor_cols)
      tags$div(
        class = "mt-2",
        tags$span(class = "sh-badge sh-badge-orange",
                  icon("columns", style = "font-size: 0.65rem;"),
                  sprintf("%d predictor%s selected", n, if (n != 1) "s" else ""))
      )
    })

    output$correlation_warning <- renderUI({
      req(rv$raw_data, rv$predictor_cols)
      num_cols <- rv$predictor_cols[
        purrr::map_lgl(rv$raw_data[rv$predictor_cols], is.numeric)
      ]
      if (length(num_cols) < 2) return(NULL)

      tryCatch({
        cor_mat <- cor(rv$raw_data[num_cols], use = "pairwise.complete.obs")
        diag(cor_mat) <- 0
        high_cor <- which(abs(cor_mat) > 0.9, arr.ind = TRUE)
        if (nrow(high_cor) == 0) return(NULL)

        pairs <- unique(apply(high_cor, 1, function(r) {
          paste(sort(c(colnames(cor_mat)[r[1]], colnames(cor_mat)[r[2]])),
                collapse = " \u2194 ")
        }))

        tags$div(
          class = "sh-callout sh-callout-warning",
          tags$div(
            icon("triangle-exclamation", style = "color: #f59e0b; margin-top: 2px;"),
            tags$div(
              tags$strong("Highly correlated predictors (r > 0.9):"),
              tags$ul(
                style = "margin: 4px 0 0 16px; font-size: 0.82rem;",
                lapply(head(pairs, 5), function(p)
                  tags$li(tags$code(p, style = "font-family: 'JetBrains Mono', monospace; color: #ff8c00;")))
              ),
              tags$small(style = "color: #999;",
                         "Consider removing one from each pair to improve model stability.")
            )
          )
        )
      }, error = function(e) NULL)
    })

    # ---- Correlation heatmap ----
    output$correlation_heatmap_ui <- renderUI({
      req(rv$raw_data, rv$predictor_cols)
      num_cols <- rv$predictor_cols[
        purrr::map_lgl(rv$raw_data[rv$predictor_cols], is.numeric)
      ]
      if (length(num_cols) < 2) {
        return(tags$div(
          class = "sh-callout sh-callout-info",
          icon("circle-info", style = "color: #ff8c00;"),
          "Need at least 2 numeric predictors for a correlation matrix."
        ))
      }
      plotOutput(session$ns("correlation_heatmap_plot"), height = "350px")
    })

    output$correlation_heatmap_plot <- renderPlot({
      req(rv$raw_data, rv$predictor_cols)
      num_cols <- rv$predictor_cols[
        purrr::map_lgl(rv$raw_data[rv$predictor_cols], is.numeric)
      ]
      if (length(num_cols) < 2) return(NULL)

      # Limit to top 15 to keep readable
      truncated <- FALSE
      if (length(num_cols) > 15) {
        truncated <- TRUE
        num_cols <- num_cols[1:15]
      }

      cor_mat <- cor(rv$raw_data[num_cols], use = "pairwise.complete.obs")

      cor_df <- expand.grid(Var1 = colnames(cor_mat), Var2 = colnames(cor_mat),
                            stringsAsFactors = FALSE)
      cor_df$value <- as.vector(cor_mat)

      ggplot2::ggplot(cor_df, ggplot2::aes(x = Var1, y = Var2, fill = value)) +
        ggplot2::geom_tile(color = "white", linewidth = 0.5) +
        ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", value)),
                           size = 2.8, color = ifelse(abs(cor_df$value) > 0.6, "white", "#333")) +
        ggplot2::scale_fill_gradient2(
          low = "#3b82f6", mid = "#f8f6f3", high = "#ff8c00",
          midpoint = 0, limits = c(-1, 1), name = "r"
        ) +
        theme_sensehub() +
        ggplot2::theme(
          axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, size = 9),
          axis.text.y = ggplot2::element_text(size = 9),
          panel.grid = ggplot2::element_blank(),
          legend.position = "right"
        ) +
        ggplot2::labs(x = NULL, y = NULL,
                     title = if (truncated) sprintf("Predictor Correlation Matrix (showing 15 of %d numeric)", length(rv$predictor_cols[purrr::map_lgl(rv$raw_data[rv$predictor_cols], is.numeric)])) else "Predictor Correlation Matrix")
    })

    output$excluded_ui <- renderUI({
      req(rv$auto_predictors, rv$health)
      excluded <- rv$health$suspected_ids
      if (length(excluded) == 0) return(NULL)

      tags$div(
        class = "small", style = "color: #888; margin-top: 8px;",
        tags$p(
          icon("filter", style = "color: #ff8c00;"),
          tags$strong(" Auto-excluded (suspected IDs):")
        ),
        tags$ul(
          style = "list-style: none; padding-left: 1rem;",
          lapply(excluded, function(col) {
            tags$li(
              icon("minus", class = "text-muted me-1"),
              tags$code(col, style = "color: #ff8c00; font-family: 'JetBrains Mono', monospace;")
            )
          })
        )
      )
    })
  })
}
