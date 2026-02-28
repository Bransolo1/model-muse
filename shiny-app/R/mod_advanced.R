# ============================================================================
# Module: Advanced (Step 3) — Premium Sensehub Design v2
# ============================================================================

mod_advanced_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Section header
    tags$div(
      class = "sh-section-header",
      tags$div(class = "sh-section-icon", icon("sliders")),
      tags$div(
        tags$h4("Advanced options"),
        tags$p("These are optional. Safe defaults are pre-selected for most datasets.")
      )
    ),

    # Info callout
    tags$div(
      class = "sh-callout sh-callout-info mb-4",
      icon("circle-info", style = "color: #ff8c00; margin-top: 2px;"),
      tags$span("Defaults are carefully tuned for most datasets. Skip ahead to ",
                tags$strong("Run"), " if you\u2019re happy with them.",
                tags$span(class = "kbd-hint", style = "margin-left: 8px; background: rgba(255,140,0,0.1); border-color: rgba(255,140,0,0.2); color: #ff8c00;",
                          "\u2192"))
    ),

    layout_columns(
      col_widths = c(6, 6),

      # ---- Tuning budget ----
      card(
        class = "sh-accent",
        card_header(
          tags$span(
            icon("gauge-high", style = "color: #ff8c00; margin-right: 6px;"),
            "Tuning budget",
            tags$span(class = "sh-tooltip", `data-tooltip` = "Controls how many hyperparameter combinations to try",
                      icon("circle-question", style = "color: #ccc; font-size: 0.7rem; margin-left: 6px;"))
          )
        ),
        card_body(
          radioButtons(
            ns("tuning_budget"), label = NULL,
            choiceNames = list(
              tags$span(tags$strong("Quick"),
                        tags$small(style = "color: #999;", " \u2014 fast scan, ~5 configs/model")),
              tags$span(tags$strong("Standard"),
                        tags$small(style = "color: #999;", " \u2014 recommended, ~15 configs")),
              tags$span(tags$strong("Thorough"),
                        tags$small(style = "color: #999;", " \u2014 exhaustive, Bayesian search"))
            ),
            choiceValues = c("quick", "standard", "thorough"),
            selected = "standard"
          ),
          uiOutput(ns("runtime_estimate"))
        )
      ),

      # ---- Cross-validation ----
      card(
        class = "sh-accent",
        card_header(
          tags$span(
            icon("arrows-spin", style = "color: #ff8c00; margin-right: 6px;"),
            "Cross-validation",
            tags$span(class = "sh-tooltip", `data-tooltip` = "How many times to split & evaluate",
                      icon("circle-question", style = "color: #ccc; font-size: 0.7rem; margin-left: 6px;"))
          )
        ),
        card_body(
          sliderInput(ns("cv_folds"), "Folds",
                      min = 3, max = 10, value = 5, step = 1),
          sliderInput(ns("cv_repeats"), "Repeats",
                      min = 1, max = 5, value = 1, step = 1),
          tags$p(class = "small", style = "color: #999;",
                 icon("info-circle", style = "font-size: 0.7rem;"),
                 " More folds = steadier estimates, slower runtime. Repeats reduce variance of CV estimate.")
        )
      ),

      # ---- Class imbalance (classification only) ----
      uiOutput(ns("imbalance_card")),

      # ---- Extras ----
      card(
        class = "sh-accent",
        card_header(tags$span(icon("flask", style = "color: #ff8c00; margin-right: 6px;"), "Extras")),
        card_body(
          checkboxInput(ns("ensemble"), "Blend top models (ensemble)", value = TRUE),
          tags$small(class = "d-block mb-2", style = "color: #999; margin-top: -4px;",
                     "Stacks predictions from best models for improved accuracy."),
          checkboxInput(ns("show_uncertainty"), "Show uncertainty intervals", value = FALSE),
          tags$small(class = "d-block mb-2", style = "color: #999; margin-top: -4px;",
                     "Computes prediction intervals for regression outputs."),
          checkboxInput(ns("auto_feature_eng"), "Auto feature engineering", value = TRUE),
          tags$small(class = "d-block", style = "color: #999; margin-top: -4px;",
                     "Adds interaction terms, polynomial features, and date-part extraction.")
        )
      )
    ),

    # Model catalogue preview
    card(
      class = "mt-3",
      card_header(tags$span(icon("robot", style = "color: #ff8c00; margin-right: 6px;"), "Models to train")),
      card_body(uiOutput(ns("model_catalogue_ui")))
    ),

    # System requirements & ML guide
    card(
      class = "mt-3",
      card_header(tags$span(icon("book-open", style = "color: #ff8c00; margin-right: 6px;"), "Requirements & ML guide")),
      card_body(
        tags$div(
          class = "small",
          tags$h6("System requirements", style = "color: #1a1a1a; font-weight: 700; margin-bottom: 8px;"),
          tags$ul(
            style = "color: #666; line-height: 1.8; padding-left: 1.2rem;",
            tags$li(tags$strong("R \u2265 4.1"), " with tidymodels ecosystem installed"),
            tags$li(tags$strong("RAM:"), " \u22654 GB for datasets under 50k rows; \u22658 GB for larger datasets"),
            tags$li(tags$strong("Packages:"), " glmnet, ranger, xgboost, kknn, kernlab, rpart (all pre-loaded)"),
            tags$li(tags$strong("Optional:"), " earth (MARS), themis (SMOTE), vip (feature importance)"),
            tags$li(tags$strong("Disk:"), " ~500 MB for R + packages; training artefacts are ephemeral")
          ),
          tags$hr(style = "border-color: #e8e4de;"),
          tags$h6("When to use each model", style = "color: #1a1a1a; font-weight: 700; margin-bottom: 8px;"),
          tags$table(
            class = "table table-sm", style = "font-size: 0.78rem; color: #555;",
            tags$thead(
              tags$tr(
                tags$th("Model"), tags$th("Best for"), tags$th("Min rows"), tags$th("Interpretability")
              )
            ),
            tags$tbody(
              tags$tr(tags$td("Elastic Net"), tags$td("Linear patterns, high-dim data"), tags$td("20+"), tags$td("\u2b50\u2b50\u2b50\u2b50")),
              tags$tr(tags$td("Decision Tree"), tags$td("Small data, explainability"), tags$td("10+"), tags$td("\u2b50\u2b50\u2b50\u2b50\u2b50")),
              tags$tr(tags$td("Random Forest"), tags$td("General-purpose, robust"), tags$td("50+"), tags$td("\u2b50\u2b50\u2b50")),
              tags$tr(tags$td("XGBoost"), tags$td("Competitions, large data"), tags$td("100+"), tags$td("\u2b50\u2b50")),
              tags$tr(tags$td("SVM"), tags$td("Complex boundaries, small-medium data"), tags$td("30+"), tags$td("\u2b50")),
              tags$tr(tags$td("K-NN"), tags$td("Small data, no assumptions"), tags$td("20+"), tags$td("\u2b50\u2b50\u2b50")),
              tags$tr(tags$td("Naive Bayes"), tags$td("Text/sparse, fast baseline"), tags$td("10+"), tags$td("\u2b50\u2b50\u2b50\u2b50")),
              tags$tr(tags$td("MARS"), tags$td("Small data, nonlinear patterns"), tags$td("30+"), tags$td("\u2b50\u2b50\u2b50\u2b50"))
            )
          ),
          tags$div(
            class = "sh-callout sh-callout-info mt-2",
            icon("lightbulb", style = "color: #ff8c00;"),
            tags$span("For datasets under 200 rows, Decision Tree, Elastic Net, and MARS tend to perform ",
                      "best because they have fewer parameters to learn and are less prone to overfitting.")
          )
        )
      )
    )
  )
}


mod_advanced_server <- function(id, rv) {
  moduleServer(id, function(input, output, session) {

    output$imbalance_card <- renderUI({
      ns <- session$ns
      if (!is.null(rv$problem_type) && rv$problem_type == "classification") {
        card(
          class = "sh-accent",
          card_header(
            tags$span(
              icon("scale-unbalanced", style = "color: #ff8c00; margin-right: 6px;"),
              "Class imbalance",
              tags$span(class = "sh-tooltip", `data-tooltip` = "Handle imbalanced target classes",
                        icon("circle-question", style = "color: #ccc; font-size: 0.7rem; margin-left: 6px;"))
            )
          ),
          card_body(
            radioButtons(
              ns("imbalance"), label = NULL,
              choiceNames = list(
                tags$span(tags$strong("None"),
                          tags$small(style = "color: #999;", " \u2014 use data as-is")),
                tags$span(tags$strong("Class weights"),
                          tags$small(style = "color: #999;", " \u2014 upweight rare classes (ranger + xgboost)")),
                tags$span(tags$strong("SMOTE"),
                          tags$small(style = "color: #999;",
                                     if (requireNamespace("themis", quietly = TRUE))
                                       " \u2014 synthetic oversampling"
                                     else
                                       " \u2014 requires 'themis' package (not installed)"))
              ),
              choiceValues = c("none", "class_weights", "smote"),
              selected = "none"
            ),
            # Show class balance
            uiOutput(ns("class_balance_ui"))
          )
        )
      } else {
        NULL
      }
    })

    # Class balance bars
    output$class_balance_ui <- renderUI({
      req(rv$raw_data, rv$target_col, rv$problem_type == "classification")
      ns <- session$ns
      plotOutput(ns("class_balance_plot"), height = "100px")
    })

    output$class_balance_plot <- renderPlot({
      req(rv$raw_data, rv$target_col)
      col <- rv$raw_data[[rv$target_col]]
      if (is.numeric(col) && dplyr::n_distinct(col) > 10) return(NULL)

      df <- data.frame(class = as.character(col))
      ggplot2::ggplot(df, ggplot2::aes(x = forcats::fct_infreq(class))) +
        ggplot2::geom_bar(fill = "#ff8c00", alpha = 0.8, width = 0.6) +
        ggplot2::coord_flip() +
        theme_sensehub(base_size = 10) +
        ggplot2::theme(
          plot.margin = ggplot2::margin(2, 8, 2, 2),
          axis.title = ggplot2::element_blank()
        )
    })

    output$runtime_estimate <- renderUI({
      req(rv$raw_data)
      n_rows <- nrow(rv$raw_data)
      budget <- input$tuning_budget %||% "standard"
      folds  <- input$cv_folds %||% 5
      reps   <- input$cv_repeats %||% 1

      base_per_fold <- dplyr::case_when(
        n_rows < 1000  ~ 2,
        n_rows < 10000 ~ 8,
        n_rows < 50000 ~ 30,
        TRUE           ~ 90
      )

      n_models <- switch(budget, quick = 3, standard = 8, thorough = 8)
      grid_size <- switch(budget, quick = 5, standard = 15, thorough = 30)
      total_fits <- n_models * grid_size * folds * reps
      est_secs <- total_fits * base_per_fold / 4

      est_label <- if (est_secs < 60) {
        sprintf("~%d seconds", round(est_secs))
      } else if (est_secs < 3600) {
        sprintf("~%d minutes", round(est_secs / 60))
      } else {
        sprintf("~%.1f hours", est_secs / 3600)
      }

      callout_class <- if (est_secs > 600) "sh-callout sh-callout-warning" else "sh-callout sh-callout-info"

      tags$div(
        class = callout_class,
        style = "margin-top: 8px;",
        icon("clock", style = "color: #ff8c00;"),
        tags$div(
          tags$span(sprintf("Estimated runtime: %s", est_label),
                    style = "font-weight: 600;"),
          tags$br(),
          tags$small(style = "color: #999;",
                     sprintf("%s total fits \u00b7 %d models \u00d7 %d configs \u00d7 %d folds \u00d7 %d repeats",
                             format(total_fits, big.mark = ","), n_models, grid_size, folds, reps))
        )
      )
    })

    # ---- Model catalogue ----
    output$model_catalogue_ui <- renderUI({
      budget <- input$tuning_budget %||% "standard"

      problem <- rv$problem_type %||% "classification"

      models <- list(
        list(name = "Elastic Net (glmnet)", icon = "chart-line", desc = "Regularised linear model", type = "always",
             reqs = "Any size \u00b7 Numeric predictors \u00b7 Fast", small_data = TRUE, modes = c("classification", "regression")),
        list(name = "Random Forest (ranger)", icon = "tree", desc = "Ensemble of decision trees", type = "always",
             reqs = "\u226550 rows \u00b7 Handles mixed types \u00b7 Medium", small_data = TRUE, modes = c("classification", "regression")),
        list(name = "XGBoost", icon = "bolt", desc = "Gradient-boosted trees", type = "always",
             reqs = "\u2265100 rows recommended \u00b7 Tuning-heavy \u00b7 Slow", small_data = FALSE, modes = c("classification", "regression")),
        list(name = "SVM (kernlab)", icon = "circle-nodes", desc = "Support vector machine", type = "standard",
             reqs = "\u226450k rows \u00b7 Needs normalisation \u00b7 Medium", small_data = TRUE, modes = c("classification", "regression")),
        list(name = "K-NN (kknn)", icon = "arrow-up-right-dots", desc = "Nearest neighbours", type = "standard",
             reqs = "\u226410k rows ideal \u00b7 Needs normalisation \u00b7 Fast", small_data = TRUE, modes = c("classification", "regression")),
        list(name = "Naive Bayes", icon = "brain", desc = "Probabilistic classifier", type = "standard",
             reqs = "Any size \u00b7 Classification only \u00b7 Very fast", small_data = TRUE, modes = c("classification")),
        list(name = "Decision Tree (rpart)", icon = "sitemap", desc = "Single interpretable tree", type = "standard",
             reqs = "Any size \u00b7 Most interpretable \u00b7 Very fast", small_data = TRUE, modes = c("classification", "regression"))
      )

      # Add MARS only if earth is installed
      if (exists("HAS_EARTH") && isTRUE(HAS_EARTH)) {
        models <- c(models, list(
          list(name = "MARS (earth)", icon = "water", desc = "Multivariate adaptive regression splines", type = "standard",
               reqs = "\u226530 rows \u00b7 Captures nonlinearity \u00b7 Fast", small_data = TRUE, modes = c("classification", "regression"))
        ))
      }

      # Filter by problem type
      models <- models[purrr::map_lgl(models, ~ problem %in% .x$modes)]

      show_models <- if (budget == "quick") {
        models[purrr::map_lgl(models, ~ .x$type == "always")]
      } else {
        models
      }

      n_rows <- if (!is.null(rv$raw_data)) nrow(rv$raw_data) else 0
      is_small <- n_rows > 0 && n_rows < 200

      tags$div(
        if (is_small)
          tags$div(
            class = "sh-callout sh-callout-info mb-3",
            icon("circle-info", style = "color: #ff8c00; margin-top: 2px;"),
            tags$div(
              tags$strong(sprintf("Small dataset detected (%d rows)", n_rows)),
              tags$p(class = "small mb-0", style = "color: #888;",
                     "Models marked with \u2b50 are particularly well-suited for small datasets. ",
                     "Consider Decision Tree and Elastic Net for best interpretability.")
            )
          ),
        tags$div(
          class = "d-flex flex-wrap gap-2",
          lapply(show_models, function(m) {
            small_badge <- if (is_small && isTRUE(m$small_data)) "\u2b50 " else ""
            tags$div(
              class = "stat-card", style = "flex: 1; min-width: 160px;",
              icon(m$icon, style = "color: #ff8c00; font-size: 1.2rem; margin-bottom: 6px;"),
              tags$div(class = "stat-label", style = "font-size: 0.78rem; text-transform: none;",
                       paste0(small_badge, m$name)),
              tags$div(style = "font-size: 0.68rem; color: #bbb; margin-top: 2px;", m$desc),
              tags$div(style = "font-size: 0.62rem; color: #999; margin-top: 4px; font-style: italic;",
                       m$reqs)
            )
          })
        )
      )
    })

    observe({
      rv$advanced <- list(
        tuning_budget    = input$tuning_budget    %||% "standard",
        cv_folds         = input$cv_folds         %||% 5,
        cv_repeats       = input$cv_repeats       %||% 1,
        imbalance        = input$imbalance        %||% "none",
        ensemble         = isTRUE(input$ensemble),
        show_uncertainty = isTRUE(input$show_uncertainty),
        auto_feature_eng = isTRUE(input$auto_feature_eng)
      )
    })
  })
}
