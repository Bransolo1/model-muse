# ============================================================================
# Module: Upload (Step 1) — With input validation & rate limiting
# ============================================================================

mod_upload_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      class = "sh-section-header",
      tags$div(class = "sh-section-icon", icon("cloud-arrow-up")),
      tags$div(
        tags$h4("Upload your dataset"),
        tags$p("Drop in a CSV, Excel, or RDS file. We\u2019ll scan it instantly and show you what we found.")
      )
    ),

    layout_columns(
      col_widths = c(6, 6),

      card(
        class = "sh-accent",
        card_header(tags$span(icon("file-csv", style = "color: #ff8c00; margin-right: 6px;"), "Dataset file")),
        card_body(
          tags$div(
            class = "upload-dropzone",
            id = ns("dropzone"),
            tags$div(class = "drop-icon", icon("cloud-arrow-up")),
            tags$p(style = "color: #888; font-size: 0.88rem; margin: 0 0 8px;",
                   "Drag & drop or click to choose"),
            tags$p(style = "color: #bbb; font-size: 0.75rem; margin: 0;",
                   sprintf("CSV, TSV, Excel%s \u2022 Max %d MB",
                           if (isTRUE(app_config("allow_rds_upload"))) ", or RDS" else "",
                           app_config("max_upload_mb")))
          ),

          fileInput(ns("file"), label = NULL,
                    accept = c(".csv", ".tsv", ".txt", ".xlsx", ".xls",
                               if (isTRUE(app_config("allow_rds_upload"))) ".rds" else NULL),
                    placeholder = "Choose file\u2026"),

          tags$div(
            style = "margin: 14px 0;",
            tags$label("Or try a sample dataset:",
                       style = "color: #999; font-size: 0.82rem; font-weight: 500;"),
            tags$div(
              class = "d-flex gap-2 mt-2",
              actionButton(ns("load_iris"), "Iris (classify)",
                           class = "btn-outline-secondary btn-sm",
                           icon = icon("seedling")),
              actionButton(ns("load_mtcars"), "mtcars (regress)",
                           class = "btn-outline-secondary btn-sm",
                           icon = icon("car")),
              actionButton(ns("load_diamonds"), "Diamonds (regress)",
                           class = "btn-outline-secondary btn-sm",
                           icon = icon("gem"))
            )
          ),

          tags$div(
            style = "min-height: 30px;",
            uiOutput(ns("upload_msg_ui"))
          )
        )
      ),

      card(
        class = "sh-accent",
        card_header(tags$span(icon("heartbeat", style = "color: #ff8c00; margin-right: 6px;"), "Data health")),
        card_body(uiOutput(ns("health_ui")))
      )
    ),

    card(
      class = "mt-3",
      card_header(tags$span(icon("chart-pie", style = "color: #ff8c00; margin-right: 6px;"), "Column types")),
      card_body(uiOutput(ns("col_types_ui")))
    ),

    card(
      class = "mt-3",
      card_header(tags$span(icon("th", style = "color: #ff8c00; margin-right: 6px;"), "Missingness pattern")),
      card_body(uiOutput(ns("missing_heatmap_ui")))
    ),

    card(
      class = "mt-3",
      card_header(
        tags$div(
          class = "d-flex justify-content-between align-items-center w-100",
          tags$span(icon("table", style = "color: #ff8c00; margin-right: 6px;"), "Preview"),
          uiOutput(ns("preview_dims_badge"), inline = TRUE)
        )
      ),
      card_body(DT::dataTableOutput(ns("preview_table")))
    )
  )
}


mod_upload_server <- function(id, rv, upload_limiter = NULL) {
  moduleServer(id, function(input, output, session) {

    # ---- File upload with validation ----
    observeEvent(input$file, {
      req(input$file)

      # Rate limit
      if (!is.null(upload_limiter)) {
        rate_check <- upload_limiter$check()
        if (!rate_check$ok) {
          showNotification(rate_check$message, type = "warning", duration = 3)
          return()
        }
      }

      # Validate file before processing
      upload_check <- validate_upload(
        input$file$datapath,
        input$file$name,
        input$file$size
      )
      if (!upload_check$ok) {
        showNotification(paste("\u2717", upload_check$message), type = "error", duration = 5)
        app_log("warn", "Upload rejected", list(
          file = input$file$name,
          reason = upload_check$message
        ))
        return()
      }

      # Block RDS if not allowed
      ext <- tolower(tools::file_ext(input$file$name))
      if (ext == "rds" && !isTRUE(app_config("allow_rds_upload"))) {
        showNotification(
          "\u2717 RDS uploads are disabled for security. Use CSV or Excel instead.",
          type = "error", duration = 5
        )
        app_log("warn", "RDS upload blocked by policy",
                list(file = input$file$name))
        return()
      }

      log_user_action("file_upload", session$token,
                      list(file = input$file$name, size = input$file$size))

      tryCatch({
        # Rename to a safe random filename before processing (OWASP best practice)
        safe_path <- sanitise_upload_path(input$file$datapath, input$file$name)

        parsed <- timed_operation("parse_dataset", {
          parse_dataset(safe_path, input$file$name)
        })

        # Validate dimensions
        dim_check <- validate_dataset_dimensions(parsed$data)
        if (!dim_check$ok) {
          showNotification(paste("\u2717", dim_check$message), type = "error", duration = 5)
          return()
        }

        rv$raw_data <- parsed$data
        rv$schema   <- parsed$schema
        rv$health   <- parsed$health
      }, error = function(e) {
        log_error("Upload processing failed", error = e, context = "file_upload")
        showNotification(paste("\u2717 Upload failed:", e$message), type = "error")
      })
    })

    # ---- Sample datasets ----
    observeEvent(input$load_iris, {
      log_user_action("load_sample", NULL, list(dataset = "iris"))
      rv$raw_data <- tibble::as_tibble(iris)
      rv$schema   <- build_schema(rv$raw_data)
      rv$health   <- build_health_check(rv$raw_data, rv$schema)
    })

    observeEvent(input$load_mtcars, {
      log_user_action("load_sample", NULL, list(dataset = "mtcars"))
      rv$raw_data <- tibble::as_tibble(mtcars, rownames = "car_name")
      rv$schema   <- build_schema(rv$raw_data)
      rv$health   <- build_health_check(rv$raw_data, rv$schema)
    })

    observeEvent(input$load_diamonds, {
      log_user_action("load_sample", NULL, list(dataset = "diamonds"))
      rv$raw_data <- tibble::as_tibble(ggplot2::diamonds[sample(nrow(ggplot2::diamonds), 2000), ])
      rv$schema   <- build_schema(rv$raw_data)
      rv$health   <- build_health_check(rv$raw_data, rv$schema)
    })

    # ---- Upload message ----
    output$upload_msg_ui <- renderUI({
      req(rv$raw_data)
      tags$div(
        class = "sh-callout sh-callout-success",
        style = "margin-top: 8px;",
        icon("check-circle", style = "color: #10b981;"),
        tags$span(
          sprintf("\u2713 Loaded %s rows \u00d7 %s columns",
                  format(nrow(rv$raw_data), big.mark = ","),
                  ncol(rv$raw_data))
        )
      )
    })

    # ---- Dataset preview ----
    output$preview_table <- DT::renderDataTable({
      req(rv$raw_data)
      DT::datatable(
        head(rv$raw_data, 200),
        options = list(pageLength = 10, scrollX = TRUE, dom = "frtip"),
        rownames = FALSE, class = "compact stripe hover"
      )
    })

    output$preview_dims_badge <- renderUI({
      req(rv$raw_data)
      tags$span(class = "sh-badge sh-badge-muted",
                sprintf("Showing top %d of %s rows",
                        min(200, nrow(rv$raw_data)),
                        format(nrow(rv$raw_data), big.mark = ",")))
    })

    # ---- Health check UI ----
    output$health_ui <- renderUI({
      if (is.null(rv$health)) {
        return(tags$div(
          tags$div(class = "skeleton skeleton-row",
                   tags$div(class = "skeleton skeleton-circle"),
                   tags$div(style = "flex: 1;",
                            tags$div(class = "skeleton skeleton-text"),
                            tags$div(class = "skeleton skeleton-text", style = "width: 60%;"))),
          tags$div(class = "skeleton skeleton-text"),
          tags$div(class = "skeleton skeleton-text", style = "width: 40%;")
        ))
      }

      h <- rv$health

      tags$div(
        class = "small",
        tags$div(
          class = "d-flex flex-wrap gap-2 mb-3",
          tags$span(class = "sh-badge sh-badge-orange",
                    icon("table-list", style = "font-size: 0.7rem;"),
                    sprintf("%s rows", format(h$n_rows, big.mark = ","))),
          tags$span(class = "sh-badge sh-badge-muted",
                    icon("table-columns", style = "font-size: 0.7rem;"),
                    sprintf("%d cols", h$n_cols)),
          if (h$total_missing == 0)
            tags$span(class = "sh-badge sh-badge-success",
                      icon("check", style = "font-size: 0.7rem;"), "No missing")
          else
            tags$span(class = "sh-badge sh-badge-danger",
                      icon("exclamation", style = "font-size: 0.7rem;"),
                      sprintf("%d missing", h$total_missing))
        ),

        if (h$duplicate_rows > 0)
          tags$div(
            class = "sh-callout sh-callout-warning", style = "margin-bottom: 8px;",
            icon("triangle-exclamation", style = "color: #f59e0b;"),
            sprintf("%d duplicate rows found. Consider deduplication.", h$duplicate_rows)
          ),

        if (length(h$near_constant) > 0)
          tags$div(
            class = "sh-callout sh-callout-warning", style = "margin-bottom: 8px;",
            icon("minus-circle", style = "color: #f59e0b;"),
            tags$span("Near-constant columns: ",
                      tags$code(paste(h$near_constant, collapse = ", "),
                                style = "color: #ff8c00; font-family: 'JetBrains Mono', monospace; font-size: 0.78rem;"))
          ),

        if (length(h$suspected_ids) > 0)
          tags$p(
            style = "color: #555; margin-bottom: 6px;",
            icon("fingerprint", style = "color: #999;"),
            " Suspected IDs: ",
            tags$code(paste(h$suspected_ids, collapse = ", "),
                      style = "color: #ff8c00; font-family: 'JetBrains Mono', monospace; font-size: 0.82rem;")
          ),

        if (length(h$suspected_dates) > 0)
          tags$p(
            style = "color: #555;",
            icon("calendar", style = "color: #999;"),
            " Date columns: ",
            tags$code(paste(h$suspected_dates, collapse = ", "),
                      style = "color: #ff8c00; font-family: 'JetBrains Mono', monospace; font-size: 0.82rem;")
          )
      )
    })

    # ---- Column types overview ----
    output$col_types_ui <- renderUI({
      if (is.null(rv$schema)) {
        return(tags$div(
          class = "skeleton skeleton-chart", style = "height: 60px;"
        ))
      }

      type_counts <- table(rv$schema$inferred_type)
      type_colors <- c(
        numeric = "#ff8c00", categorical = "#3b82f6",
        date = "#10b981", logical = "#8b5cf6", unknown = "#999"
      )

      total <- sum(type_counts)
      tags$div(
        class = "d-flex flex-wrap gap-3",
        lapply(names(type_counts), function(t) {
          pct <- round(type_counts[t] / total * 100)
          col <- type_colors[t] %||% "#999"
          tags$div(
            class = "stat-card", style = sprintf("flex: 1; min-width: 100px; border-left: 3px solid %s;", col),
            tags$div(class = "stat-value", type_counts[t]),
            tags$div(class = "stat-label", t),
            tags$div(
              style = sprintf("height: 3px; background: %s; width: %d%%; border-radius: 2px; margin-top: 8px; opacity: 0.5;",
                              col, pct)
            )
          )
        })
      )
    })

    # ---- Missingness heatmap ----
    output$missing_heatmap_ui <- renderUI({
      req(rv$raw_data)
      if (sum(is.na(rv$raw_data)) == 0) {
        return(tags$div(
          class = "sh-callout sh-callout-success",
          icon("check-circle", style = "color: #10b981;"),
          tags$span("No missing values \u2014 your data is clean.")
        ))
      }
      plotOutput(session$ns("missing_heatmap_plot"), height = "300px")
    })

    output$missing_heatmap_plot <- renderPlot({
      req(rv$raw_data)
      data <- rv$raw_data
      if (nrow(data) > 500) data <- data[sample(nrow(data), 500), ]

      cols_with_na <- names(data)[purrr::map_lgl(data, ~ any(is.na(.x)))]
      if (length(cols_with_na) == 0) return(NULL)

      miss_df <- data[, cols_with_na, drop = FALSE] %>%
        dplyr::mutate(row_id = dplyr::row_number()) %>%
        tidyr::pivot_longer(-row_id, names_to = "column", values_to = "value") %>%
        dplyr::mutate(missing = is.na(value))

      ggplot2::ggplot(miss_df, ggplot2::aes(x = column, y = row_id, fill = missing)) +
        ggplot2::geom_tile() +
        ggplot2::scale_fill_manual(
          values = c("FALSE" = "#f0ece6", "TRUE" = "#ff8c00"),
          labels = c("Present", "Missing"), name = NULL
        ) +
        theme_sensehub() +
        ggplot2::theme(
          axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
          axis.text.y = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank(),
          panel.grid = ggplot2::element_blank(),
          legend.position = "bottom"
        ) +
        ggplot2::labs(x = NULL, y = "Rows (sampled)", title = "Missingness Pattern")
    })
  })
}
