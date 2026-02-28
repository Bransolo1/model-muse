# ============================================================================
# Sensehub AutoM/L — ui.R
# Premium 4-step wizard: Upload → Configure → Advanced → Run & Results
# Dark sidebar · Warm amber accents · Frosted glass · Brand-consistent
# ============================================================================

wizard_steps <- c(
  "1  Upload"     = "upload",
  "2  Configure"  = "configure",
  "3  Advanced"   = "advanced",
  "4  Run"        = "results"
)

ui <- page_navbar(
  title = tags$span(
    tags$span(
      style = "display: inline-flex; align-items: center; justify-content: center;
               width: 32px; height: 32px; border-radius: 10px;
               background: linear-gradient(135deg, #ff8c00, #ff6600);
               margin-right: 10px; box-shadow: 0 2px 8px rgba(255,140,0,0.3);",
      icon("bolt", style = "color: #fff; font-size: 0.85rem;")
    ),
    tags$span("Sensehub", style = "font-weight: 700; letter-spacing: -0.5px; color: #1a1a1a;"),
    tags$span(" AutoM/L", style = "font-weight: 700; letter-spacing: -0.5px; color: #ff8c00;")
  ),
  theme = bs_theme(
    version    = 5,
    bg         = "#f8f6f3",
    fg         = "#1a1a1a",
    primary    = "#ff8c00",
    secondary  = "#f0ece6",
    success    = "#10b981",
    warning    = "#f59e0b",
    danger     = "#ef4444",
    base_font  = font_google("Inter"),
    heading_font = font_google("Inter"),
    font_scale = 0.92,
    "navbar-bg"          = "#ffffff",
    "card-bg"            = "#ffffff",
    "card-border-color"  = "#e8e4de",
    "body-bg"            = "#f8f6f3",
    "input-bg"           = "#ffffff",
    "input-color"        = "#1a1a1a",
    "input-border-color" = "#d4d0c8",
    "btn-font-weight"    = 600
  ),
  fillable = TRUE,

  header = tagList(
    shinyjs::useShinyjs(),
    tags$head(
      # JetBrains Mono for code/monospace elements (non-blocking)
      tags$link(
        href = "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&display=swap",
        rel = "stylesheet"
      ),

    tags$style(HTML("
    /* ================================================================
       SENSEHUB PREMIUM DESIGN SYSTEM v2
       Brand-aligned with landing: https://auto-model-buddy.lovable.app/
       Primary: orange (#ff8c00); bg: warm off-white (#f8f6f3); dark sidebar (#0f1117).
       ================================================================ */

    /* ---------- DESIGN TOKENS ---------- */
    :root {
      --sh-bg: #f8f6f3;
      --sh-surface: #ffffff;
      --sh-border: #e8e4de;
      --sh-border-subtle: #f0ece6;
      --sh-text: #1a1a1a;
      --sh-text-secondary: #555;
      --sh-text-muted: #999;
      --sh-primary: #ff8c00;
      --sh-primary-dark: #e67e00;
      --sh-primary-light: #fff8f0;
      --sh-primary-glow: rgba(255, 140, 0, 0.15);
      --sh-success: #10b981;
      --sh-success-light: #ecfdf5;
      --sh-warning: #f59e0b;
      --sh-warning-light: #fffbeb;
      --sh-danger: #ef4444;
      --sh-danger-light: #fef2f2;
      --sh-info: #3b82f6;
      --sh-info-light: #eff6ff;
      --sh-sidebar-bg: #0f1117;
      --sh-sidebar-surface: rgba(255, 255, 255, 0.04);
      --sh-sidebar-border: rgba(255, 255, 255, 0.06);
      --sh-sidebar-text: #8a8a96;
      --sh-radius: 14px;
      --sh-radius-sm: 8px;
      --sh-radius-xs: 6px;
      --sh-shadow-xs: 0 1px 2px rgba(0,0,0,0.03);
      --sh-shadow-sm: 0 1px 3px rgba(0,0,0,0.04), 0 4px 12px rgba(0,0,0,0.03);
      --sh-shadow-md: 0 4px 6px rgba(0,0,0,0.04), 0 10px 24px rgba(0,0,0,0.06);
      --sh-shadow-lg: 0 8px 16px rgba(0,0,0,0.06), 0 20px 40px rgba(0,0,0,0.08);
      --sh-shadow-glow: 0 0 24px rgba(255, 140, 0, 0.12);
      --sh-ease: cubic-bezier(0.4, 0, 0.2, 1);
      --sh-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
      --sh-transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    }

    /* ---------- GLOBAL RESETS ---------- */
    body { font-family: 'Inter', -apple-system, sans-serif !important; }

    /* ---------- NAVBAR ---------- */
    .navbar {
      box-shadow: 0 1px 0 var(--sh-border), var(--sh-shadow-xs) !important;
      backdrop-filter: blur(12px) !important;
      border-bottom: none !important;
    }
    .navbar-brand { font-size: 1rem !important; }

    /* ---------- SIDEBAR (DARK PREMIUM) ---------- */
    .bslib-sidebar-layout > .sidebar {
      background: var(--sh-sidebar-bg) !important;
      border-right: 1px solid var(--sh-sidebar-border) !important;
      box-shadow: 4px 0 24px rgba(0,0,0,0.15) !important;
    }
    .bslib-sidebar-layout > .sidebar .sidebar-title,
    .bslib-sidebar-layout > .sidebar h5 {
      color: #e8e8ec !important;
    }
    .bslib-sidebar-layout > .sidebar p {
      color: var(--sh-sidebar-text) !important;
    }
    .bslib-sidebar-layout > .sidebar hr {
      border-color: var(--sh-sidebar-border) !important;
      opacity: 1;
    }

    /* ---------- CARDS (PREMIUM) ---------- */
    .card {
      border-radius: var(--sh-radius) !important;
      border: 1px solid var(--sh-border) !important;
      box-shadow: var(--sh-shadow-sm) !important;
      transition: var(--sh-transition) !important;
      overflow: hidden;
      animation: cardEntrance 0.45s var(--sh-ease) both;
    }
    .card:hover {
      box-shadow: var(--sh-shadow-md) !important;
      transform: translateY(-2px);
    }
    .card.sh-accent {
      border-left: 4px solid var(--sh-primary) !important;
    }
    .card-header {
      background: transparent !important;
      border-bottom: 1px solid var(--sh-border) !important;
      font-weight: 600;
      color: var(--sh-text) !important;
      padding: 14px 20px !important;
      font-size: 0.9rem;
    }
    .card-body { padding: 20px !important; }

    @keyframes cardEntrance {
      from { opacity: 0; transform: translateY(12px); }
      to { opacity: 1; transform: translateY(0); }
    }

    /* Stagger card animations */
    .card:nth-child(1) { animation-delay: 0s; }
    .card:nth-child(2) { animation-delay: 0.08s; }
    .card:nth-child(3) { animation-delay: 0.16s; }
    .card:nth-child(4) { animation-delay: 0.24s; }

    /* ---------- SECTION HEADERS ---------- */
    .sh-section-header {
      display: flex;
      align-items: flex-start;
      gap: 16px;
      margin-bottom: 24px;
      animation: fadeSlideIn 0.5s var(--sh-ease) both;
    }
    .sh-section-icon {
      width: 48px;
      height: 48px;
      border-radius: 14px;
      background: linear-gradient(135deg, #ff8c00, #ff6600);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-size: 1.1rem;
      flex-shrink: 0;
      box-shadow: 0 4px 14px rgba(255, 140, 0, 0.3);
      transition: transform 0.35s var(--sh-spring);
    }
    .sh-section-icon:hover {
      transform: scale(1.08) rotate(-4deg);
    }
    .sh-section-header h4 {
      font-size: 1.4rem;
      font-weight: 700;
      color: var(--sh-text);
      margin: 0 0 4px 0;
      letter-spacing: -0.4px;
    }
    .sh-section-header p {
      color: var(--sh-text-muted);
      font-size: 0.88rem;
      margin: 0;
      line-height: 1.5;
    }

    @keyframes fadeSlideIn {
      from { opacity: 0; transform: translateX(-10px); }
      to { opacity: 1; transform: translateX(0); }
    }

    /* ---------- BUTTONS ---------- */
    .btn-primary {
      background: linear-gradient(135deg, #ff8c00, #ff6600) !important;
      border: none !important;
      color: #fff !important;
      font-weight: 600;
      border-radius: var(--sh-radius-sm) !important;
      box-shadow: 0 2px 8px rgba(255, 140, 0, 0.25);
      letter-spacing: 0.01em;
      transition: var(--sh-transition) !important;
      position: relative;
      overflow: hidden;
    }
    .btn-primary::after {
      content: '';
      position: absolute;
      inset: 0;
      background: linear-gradient(135deg, transparent 30%, rgba(255,255,255,0.15) 50%, transparent 70%);
      transform: translateX(-100%);
      transition: transform 0.6s ease;
    }
    .btn-primary:hover::after {
      transform: translateX(100%);
    }
    .btn-primary:hover {
      background: linear-gradient(135deg, #ff9922, #ff7711) !important;
      box-shadow: 0 4px 16px rgba(255, 140, 0, 0.4) !important;
      transform: translateY(-1px);
    }
    .btn-primary:active {
      transform: translateY(0);
      box-shadow: 0 1px 4px rgba(255, 140, 0, 0.3) !important;
    }
    .btn-outline-secondary {
      border-color: var(--sh-border) !important;
      color: var(--sh-text-secondary) !important;
      border-radius: var(--sh-radius-sm) !important;
      transition: var(--sh-transition) !important;
      background: transparent !important;
    }
    .btn-outline-secondary:hover {
      background: var(--sh-primary-light) !important;
      border-color: var(--sh-primary) !important;
      color: var(--sh-primary) !important;
    }
    .btn-outline-danger {
      border-radius: var(--sh-radius-sm) !important;
      transition: var(--sh-transition) !important;
    }
    .btn-outline-danger:hover {
      transform: translateY(-1px);
      box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2) !important;
    }
    .btn-lg {
      padding: 12px 20px !important;
      font-size: 0.9rem !important;
    }

    /* ---------- BADGES ---------- */
    .badge.bg-primary { background: var(--sh-primary) !important; }
    .badge.bg-success { background: var(--sh-success) !important; }
    .sh-badge {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 5px 12px;
      border-radius: 20px;
      font-size: 0.78rem;
      font-weight: 600;
      letter-spacing: 0.01em;
      transition: var(--sh-transition);
    }
    .sh-badge:hover {
      transform: scale(1.03);
    }
    .sh-badge-orange {
      background: var(--sh-primary-light);
      color: var(--sh-primary);
      border: 1px solid rgba(255, 140, 0, 0.15);
    }
    .sh-badge-muted {
      background: var(--sh-border-subtle);
      color: var(--sh-text-secondary);
    }
    .sh-badge-success {
      background: var(--sh-success-light);
      color: var(--sh-success);
      border: 1px solid rgba(16, 185, 129, 0.15);
    }
    .sh-badge-danger {
      background: var(--sh-danger-light);
      color: var(--sh-danger);
      border: 1px solid rgba(239, 68, 68, 0.15);
    }
    .sh-badge-info {
      background: var(--sh-info-light);
      color: var(--sh-info);
      border: 1px solid rgba(59, 130, 246, 0.15);
    }

    /* ---------- FORM CONTROLS ---------- */
    .form-control, .form-select {
      border-radius: var(--sh-radius-xs) !important;
      border-color: var(--sh-border) !important;
      background-color: var(--sh-surface) !important;
      color: var(--sh-text) !important;
      transition: var(--sh-transition) !important;
      padding: 10px 14px !important;
      font-size: 0.88rem !important;
    }
    .form-control:focus, .form-select:focus {
      border-color: var(--sh-primary) !important;
      box-shadow: 0 0 0 3px var(--sh-primary-glow) !important;
      outline: none !important;
    }
    .form-select option {
      background: var(--sh-surface) !important;
      color: var(--sh-text) !important;
    }
    .form-control.is-valid {
      border-color: var(--sh-success) !important;
      box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1) !important;
    }
    .form-control.is-invalid {
      border-color: var(--sh-danger) !important;
      box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1) !important;
    }
    .form-control[type='file'] {
      background: var(--sh-surface) !important;
      color: var(--sh-text-secondary) !important;
      border-color: var(--sh-border) !important;
      border-radius: var(--sh-radius-xs) !important;
      padding: 8px !important;
    }
    .form-control[type='file']::-webkit-file-upload-button {
      background: linear-gradient(135deg, #ff8c00, #ff6600) !important;
      color: #fff !important;
      border: none !important;
      padding: 8px 20px !important;
      border-radius: var(--sh-radius-xs) !important;
      font-weight: 600;
      cursor: pointer;
      transition: var(--sh-transition);
    }
    .form-control[type='file']::-webkit-file-upload-button:hover {
      background: linear-gradient(135deg, #ff9922, #ff7711) !important;
    }
    .control-label, .form-label, label {
      color: var(--sh-text-secondary) !important;
      font-weight: 500;
      font-size: 0.82rem;
      letter-spacing: 0.01em;
    }
    .form-check-input:checked {
      background-color: var(--sh-primary) !important;
      border-color: var(--sh-primary) !important;
    }
    .form-check-label { color: var(--sh-text-secondary) !important; }
    .radio-group label, .shiny-options-group label { color: var(--sh-text) !important; }

    /* Selectize */
    .selectize-control .selectize-input {
      background: var(--sh-surface) !important;
      color: var(--sh-text) !important;
      border-color: var(--sh-border) !important;
      border-radius: var(--sh-radius-xs) !important;
      padding: 8px 12px !important;
      transition: var(--sh-transition);
    }
    .selectize-control .selectize-input.focus {
      border-color: var(--sh-primary) !important;
      box-shadow: 0 0 0 3px var(--sh-primary-glow) !important;
    }
    .selectize-control .selectize-input .item { color: var(--sh-text) !important; }
    .selectize-dropdown {
      background: var(--sh-surface) !important;
      border: 1px solid var(--sh-border) !important;
      border-radius: var(--sh-radius-sm) !important;
      box-shadow: var(--sh-shadow-lg) !important;
      z-index: 10000 !important;
      color: var(--sh-text) !important;
      overflow: hidden;
    }
    .selectize-dropdown .active { background: var(--sh-primary) !important; color: #fff !important; }
    .selectize-dropdown .option {
      color: var(--sh-text) !important;
      padding: 10px 14px !important;
      transition: background 0.15s ease;
    }
    .selectize-dropdown .option:hover {
      background: var(--sh-primary-light) !important;
      color: var(--sh-primary) !important;
    }

    /* Picker */
    .bootstrap-select .btn {
      background: var(--sh-surface) !important;
      color: var(--sh-text) !important;
      border-color: var(--sh-border) !important;
      border-radius: var(--sh-radius-xs) !important;
      transition: var(--sh-transition);
    }
    .bootstrap-select .btn:focus {
      border-color: var(--sh-primary) !important;
      box-shadow: 0 0 0 3px var(--sh-primary-glow) !important;
    }
    .bootstrap-select .dropdown-menu {
      background: var(--sh-surface) !important;
      border: 1px solid var(--sh-border) !important;
      border-radius: var(--sh-radius-sm) !important;
      box-shadow: var(--sh-shadow-lg) !important;
      overflow: hidden;
    }
    .bootstrap-select .dropdown-menu li.selected a { background: var(--sh-primary) !important; color: #fff !important; }
    .bootstrap-select .dropdown-menu li a:hover { background: var(--sh-primary-light) !important; color: var(--sh-primary) !important; }

    /* Sliders */
    .irs--shiny .irs-bar { background: linear-gradient(90deg, #ff8c00, #ff6600) !important; }
    .irs--shiny .irs-handle {
      border-color: var(--sh-primary) !important;
      box-shadow: 0 2px 6px rgba(255,140,0,0.3) !important;
      transition: transform 0.2s var(--sh-spring);
    }
    .irs--shiny .irs-handle:hover {
      transform: scale(1.2);
    }
    .irs--shiny .irs-single {
      background: var(--sh-primary) !important;
      border-radius: 4px !important;
    }
    .irs--shiny .irs-line { background: var(--sh-border) !important; }

    /* ---------- NAVIGATION TABS ---------- */
    .nav-link {
      color: var(--sh-text-muted) !important;
      border-radius: var(--sh-radius-sm) var(--sh-radius-sm) 0 0 !important;
      transition: var(--sh-transition) !important;
      font-weight: 500;
      padding: 10px 16px !important;
      position: relative;
    }
    .nav-link:hover {
      color: var(--sh-text-secondary) !important;
      background: var(--sh-primary-light) !important;
    }
    .nav-link.active {
      color: var(--sh-primary) !important;
      border-bottom: 2px solid var(--sh-primary) !important;
      background: transparent !important;
      font-weight: 600;
    }

    /* ---------- DATA TABLES ---------- */
    table.dataTable { color: var(--sh-text) !important; }
    table.dataTable thead th {
      color: var(--sh-primary) !important;
      border-bottom: 2px solid var(--sh-border) !important;
      font-weight: 600;
      font-size: 0.82rem;
      text-transform: uppercase;
      letter-spacing: 0.04em;
      padding: 12px 14px !important;
    }
    table.dataTable tbody tr {
      transition: all 0.2s ease;
    }
    table.dataTable tbody tr:hover {
      background: var(--sh-primary-light) !important;
      transform: scale(1.002);
    }
    table.dataTable tbody td {
      padding: 10px 14px !important;
      font-size: 0.85rem;
      border-bottom-color: var(--sh-border-subtle) !important;
    }
    .dataTables_wrapper .dataTables_filter input {
      border-radius: var(--sh-radius-xs) !important;
      border: 1px solid var(--sh-border) !important;
      padding: 6px 12px !important;
    }
    .dataTables_wrapper .dataTables_filter input:focus {
      border-color: var(--sh-primary) !important;
      box-shadow: 0 0 0 3px var(--sh-primary-glow) !important;
      outline: none !important;
    }
    .dataTables_wrapper .dataTables_info { color: var(--sh-text-muted) !important; }
    .dataTables_wrapper .dataTables_paginate .paginate_button.current {
      background: var(--sh-primary) !important;
      border-color: var(--sh-primary) !important;
      color: #fff !important;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button:hover:not(.disabled) {
      background: var(--sh-primary-light) !important;
      border-color: var(--sh-primary) !important;
      color: var(--sh-primary) !important;
    }

    /* ---------- PLOT CONTAINERS (brand-aligned) ---------- */
    .shiny-plot-output {
      border-radius: var(--sh-radius-sm);
      overflow: hidden;
      background: var(--sh-surface);
      box-shadow: var(--sh-shadow-xs);
    }

    /* ---------- DROPDOWNS ---------- */
    .dropdown-menu {
      background: var(--sh-surface) !important;
      border: 1px solid var(--sh-border) !important;
      border-radius: var(--sh-radius-sm) !important;
      box-shadow: var(--sh-shadow-lg) !important;
      overflow: hidden;
      animation: dropdownSlide 0.2s var(--sh-ease);
    }
    @keyframes dropdownSlide {
      from { opacity: 0; transform: translateY(-4px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .dropdown-menu .dropdown-item {
      transition: all 0.15s ease;
      padding: 8px 16px;
    }
    .dropdown-menu .dropdown-item:hover { background: var(--sh-primary-light) !important; color: var(--sh-primary) !important; }
    .dropdown-menu .dropdown-item.active { background: var(--sh-primary) !important; color: #fff !important; }

    /* ---------- CALLOUT BOXES ---------- */
    .sh-callout {
      border-radius: var(--sh-radius-sm);
      padding: 14px 18px;
      font-size: 0.85rem;
      display: flex;
      align-items: flex-start;
      gap: 10px;
      line-height: 1.5;
      animation: calloutFade 0.35s var(--sh-ease) both;
    }
    @keyframes calloutFade {
      from { opacity: 0; transform: translateY(4px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .sh-callout-info {
      background: var(--sh-primary-light);
      border: 1px solid rgba(255, 140, 0, 0.2);
      color: var(--sh-text-secondary);
    }
    .sh-callout-warning {
      background: var(--sh-warning-light);
      border: 1px solid rgba(245, 158, 11, 0.25);
      color: var(--sh-text-secondary);
    }
    .sh-callout-success {
      background: var(--sh-success-light);
      border: 1px solid rgba(16, 185, 129, 0.2);
      color: var(--sh-text);
    }
    .sh-callout-danger {
      background: var(--sh-danger-light);
      border: 1px solid rgba(239, 68, 68, 0.2);
      color: var(--sh-text);
    }

    /* ---------- ALERTS ---------- */
    .alert-info {
      background: var(--sh-primary-light) !important;
      border-color: rgba(255, 140, 0, 0.2) !important;
      color: var(--sh-text) !important;
      border-radius: var(--sh-radius-sm) !important;
    }

    /* ---------- SCROLLBAR ---------- */
    ::-webkit-scrollbar { width: 6px; height: 6px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb {
      background: #ccc;
      border-radius: 3px;
    }
    ::-webkit-scrollbar-thumb:hover { background: #aaa; }

    /* ---------- SIDEBAR CONTROLS ---------- */
    .session-controls {
      margin-top: 8px;
      padding-top: 12px;
      border-top: 1px solid var(--sh-sidebar-border);
    }
    .session-controls label { color: var(--sh-sidebar-text) !important; }
    .session-controls .btn {
      background: var(--sh-sidebar-surface) !important;
      border-color: var(--sh-sidebar-border) !important;
      color: var(--sh-sidebar-text) !important;
    }
    .session-controls .btn:hover {
      background: rgba(255,140,0,0.1) !important;
      border-color: rgba(255,140,0,0.3) !important;
      color: var(--sh-primary) !important;
    }
    .session-controls .form-control[type='file'] {
      background: var(--sh-sidebar-surface) !important;
      border-color: var(--sh-sidebar-border) !important;
      color: var(--sh-sidebar-text) !important;
      font-size: 0.7rem !important;
      padding: 4px !important;
    }

    select.form-select, select.form-control {
      background-color: var(--sh-surface) !important;
      color: var(--sh-text) !important;
      border-color: var(--sh-border) !important;
      border-radius: var(--sh-radius-xs) !important;
    }

    /* ============================================
       ANIMATED PROGRESS STEPPER (DARK SIDEBAR)
       ============================================ */
    .wizard-stepper {
      display: flex;
      flex-direction: column;
      gap: 0;
      position: relative;
      padding: 4px 0;
    }
    .wizard-stepper .step-item {
      display: flex;
      align-items: center;
      gap: 14px;
      padding: 10px 12px;
      cursor: pointer;
      border-radius: 10px;
      transition: all 0.3s var(--sh-ease);
      position: relative;
    }
    .wizard-stepper .step-item:hover {
      background: var(--sh-sidebar-surface);
    }
    .wizard-stepper .step-item .step-circle {
      width: 34px;
      height: 34px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 0.75rem;
      font-weight: 700;
      border: 2px solid rgba(255,255,255,0.12);
      color: var(--sh-sidebar-text);
      background: var(--sh-sidebar-surface);
      transition: all 0.35s var(--sh-ease);
      flex-shrink: 0;
    }
    .wizard-stepper .step-item.step-done .step-circle {
      background: var(--sh-success);
      border-color: var(--sh-success);
      color: #fff;
      box-shadow: 0 0 10px rgba(16, 185, 129, 0.3);
    }
    .wizard-stepper .step-item.step-active .step-circle {
      background: linear-gradient(135deg, #ff8c00, #ff6600);
      border-color: #ff8c00;
      color: #fff;
      box-shadow: 0 0 16px rgba(255, 140, 0, 0.5);
      animation: stepPulse 2.5s ease-in-out infinite;
    }
    .wizard-stepper .step-item.step-locked .step-circle {
      opacity: 0.25;
    }
    .wizard-stepper .step-item .step-label {
      font-size: 0.84rem;
      font-weight: 500;
      color: var(--sh-sidebar-text);
      transition: all 0.25s ease;
      flex: 1;
    }
    .wizard-stepper .step-item.step-active .step-label {
      color: #ff8c00;
      font-weight: 600;
    }
    .wizard-stepper .step-item.step-done .step-label {
      color: #d0d0d8;
    }
    .wizard-stepper .step-item.step-locked .step-label {
      opacity: 0.3;
    }
    .wizard-stepper .step-item.step-locked {
      pointer-events: none;
      cursor: not-allowed;
    }
    /* Step completion mini-badges */
    .step-completion-badge {
      font-size: 0.6rem;
      padding: 2px 6px;
      border-radius: 10px;
      font-weight: 600;
      white-space: nowrap;
    }
    .step-completion-badge.done {
      background: rgba(16, 185, 129, 0.15);
      color: #10b981;
    }
    .step-completion-badge.pending {
      background: rgba(255, 255, 255, 0.06);
      color: rgba(255, 255, 255, 0.25);
    }

    /* Connector line */
    .wizard-stepper .step-connector {
      width: 2px;
      height: 14px;
      margin-left: 28px;
      background: rgba(255,255,255,0.06);
      transition: background 0.35s ease;
      border-radius: 1px;
    }
    .wizard-stepper .step-connector.connector-done {
      background: var(--sh-success);
      box-shadow: 0 0 6px rgba(16, 185, 129, 0.2);
    }

    @keyframes stepPulse {
      0%, 100% { box-shadow: 0 0 10px rgba(255, 140, 0, 0.3); }
      50% { box-shadow: 0 0 24px rgba(255, 140, 0, 0.55); }
    }

    /* Hide native radio group */
    #wizard_step.shiny-input-radiogroup { display: none; }

    /* ============================================
       PANEL TRANSITIONS
       ============================================ */
    .tab-pane {
      animation: panelFadeIn 0.4s var(--sh-ease) both;
    }
    @keyframes panelFadeIn {
      from { opacity: 0; transform: translateY(8px); }
      to { opacity: 1; transform: translateY(0); }
    }

    /* ============================================
       SKELETON LOADING
       ============================================ */
    .skeleton {
      background: linear-gradient(90deg, var(--sh-border) 25%, var(--sh-border-subtle) 50%, var(--sh-border) 75%);
      background-size: 200% 100%;
      animation: shimmerSkeleton 1.5s ease-in-out infinite;
      border-radius: var(--sh-radius-xs);
    }
    .skeleton-text { height: 14px; width: 80%; margin: 8px 0; }
    .skeleton-title { height: 20px; width: 50%; margin: 12px 0; }
    .skeleton-chart { height: 200px; width: 100%; margin: 16px 0; }
    .skeleton-card { height: 120px; width: 100%; margin: 12px 0; border-radius: var(--sh-radius); }
    .skeleton-row { display: flex; gap: 12px; margin: 8px 0; }
    .skeleton-circle { width: 34px; height: 34px; border-radius: 50%; flex-shrink: 0; }

    @keyframes shimmerSkeleton {
      0% { background-position: 200% 0; }
      100% { background-position: -200% 0; }
    }

    /* ============================================
       DRAG & DROP UPLOAD ZONE
       ============================================ */
    .upload-dropzone {
      border: 2px dashed var(--sh-border);
      border-radius: var(--sh-radius);
      padding: 32px;
      text-align: center;
      transition: var(--sh-transition);
      background: var(--sh-surface);
      cursor: pointer;
    }
    .upload-dropzone:hover, .upload-dropzone.dragover {
      border-color: var(--sh-primary);
      background: var(--sh-primary-light);
      box-shadow: 0 0 20px rgba(255, 140, 0, 0.08);
    }
    .upload-dropzone .drop-icon {
      font-size: 2.5rem;
      color: var(--sh-primary);
      margin-bottom: 12px;
      transition: transform 0.35s var(--sh-spring);
    }
    .upload-dropzone:hover .drop-icon {
      transform: translateY(-4px) scale(1.05);
    }

    /* ============================================
       LIVE TRAINING INDICATOR
       ============================================ */
    .live-indicator {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 3px 10px;
      border-radius: 20px;
      font-size: 0.72rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    .live-indicator.running {
      background: rgba(255, 140, 0, 0.1);
      color: var(--sh-primary);
    }
    .live-indicator .pulse-dot {
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: var(--sh-primary);
      animation: pulseDot 1.5s ease-in-out infinite;
    }
    @keyframes pulseDot {
      0%, 100% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.4; transform: scale(0.7); }
    }

    /* ============================================
       ELAPSED TIMER
       ============================================ */
    .elapsed-timer {
      font-family: 'JetBrains Mono', monospace;
      font-size: 1.6rem;
      font-weight: 700;
      color: var(--sh-primary);
      letter-spacing: 1px;
      text-align: center;
      padding: 12px 0;
      opacity: 0.9;
    }

    /* ============================================
       KEYBOARD SHORTCUT HINTS
       ============================================ */
    .kbd-hint {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 2px 7px;
      border-radius: 4px;
      background: var(--sh-sidebar-surface);
      border: 1px solid var(--sh-sidebar-border);
      font-family: 'JetBrains Mono', monospace;
      font-size: 0.6rem;
      color: var(--sh-sidebar-text);
      margin-left: 8px;
    }

    /* ============================================
       TOOLTIP SYSTEM
       ============================================ */
    .sh-tooltip {
      position: relative;
      cursor: help;
    }
    .sh-tooltip::after {
      content: attr(data-tooltip);
      position: absolute;
      bottom: calc(100% + 6px);
      left: 50%;
      transform: translateX(-50%) scale(0.95);
      background: var(--sh-sidebar-bg);
      color: #e0e0e0;
      border-left: 3px solid var(--sh-primary);
      padding: 6px 12px;
      border-radius: 6px;
      font-size: 0.75rem;
      font-weight: 400;
      white-space: nowrap;
      pointer-events: none;
      opacity: 0;
      transition: all 0.2s var(--sh-ease);
      z-index: 100;
      box-shadow: var(--sh-shadow-lg);
    }
    .sh-tooltip:hover::after {
      opacity: 1;
      transform: translateX(-50%) scale(1);
    }

    /* ============================================
       ONBOARDING TOUR
       ============================================ */
    .tour-overlay {
      position: fixed;
      inset: 0;
      background: rgba(0,0,0,0.6);
      z-index: 9998;
      backdrop-filter: blur(4px);
      animation: overlayFade 0.3s ease;
    }
    @keyframes overlayFade {
      from { opacity: 0; }
      to { opacity: 1; }
    }
    .tour-tooltip {
      position: fixed;
      z-index: 9999;
      background: var(--sh-surface);
      border: 2px solid var(--sh-primary);
      border-radius: var(--sh-radius);
      padding: 20px 24px;
      max-width: 380px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.2), var(--sh-shadow-glow);
      animation: tourFadeIn 0.35s var(--sh-ease);
    }
    .tour-tooltip h5 {
      color: var(--sh-primary);
      margin-bottom: 6px;
      font-weight: 700;
      font-size: 1rem;
    }
    .tour-tooltip p {
      color: var(--sh-text-secondary);
      font-size: 0.85rem;
      margin-bottom: 16px;
      line-height: 1.5;
    }
    .tour-tooltip .tour-actions {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .tour-tooltip .tour-step-indicator {
      color: var(--sh-text-muted);
      font-size: 0.75rem;
      font-weight: 500;
    }
    .tour-tooltip .tour-progress {
      display: flex;
      gap: 4px;
    }
    .tour-tooltip .tour-progress-dot {
      width: 6px;
      height: 6px;
      border-radius: 50%;
      background: var(--sh-border);
      transition: all 0.2s ease;
    }
    .tour-tooltip .tour-progress-dot.active {
      background: var(--sh-primary);
      width: 18px;
      border-radius: 3px;
    }
    @keyframes tourFadeIn {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }

    /* ============================================
       SIDEBAR NAV BUTTONS (DARK THEME)
       ============================================ */
    .bslib-sidebar-layout > .sidebar .btn-outline-secondary {
      background: var(--sh-sidebar-surface) !important;
      border-color: var(--sh-sidebar-border) !important;
      color: var(--sh-sidebar-text) !important;
    }
    .bslib-sidebar-layout > .sidebar .btn-outline-secondary:hover {
      background: rgba(255,140,0,0.08) !important;
      border-color: rgba(255,140,0,0.3) !important;
      color: var(--sh-primary) !important;
    }
    .bslib-sidebar-layout > .sidebar .btn-primary {
      background: linear-gradient(135deg, #ff8c00, #ff6600) !important;
      border: none !important;
      box-shadow: 0 2px 10px rgba(255, 140, 0, 0.35) !important;
    }
    .bslib-sidebar-layout > .sidebar .btn-primary:hover {
      box-shadow: 0 4px 18px rgba(255, 140, 0, 0.5) !important;
    }

    /* ============================================
       VERBATIM TEXT (run log)
       ============================================ */
    pre.shiny-text-output, .shiny-text-output {
      background: #fafaf8 !important;
      border: 1px solid var(--sh-border) !important;
      border-radius: var(--sh-radius-xs) !important;
      padding: 14px 16px !important;
      font-family: 'JetBrains Mono', monospace !important;
      font-size: 0.8rem !important;
      color: var(--sh-text-secondary) !important;
      max-height: 200px;
      overflow-y: auto;
    }

    /* ============================================
       PROGRESS BAR
       ============================================ */
    .progress {
      background: var(--sh-border) !important;
      border-radius: 4px !important;
      overflow: hidden;
    }
    .progress-bar {
      background: linear-gradient(90deg, #ff8c00, #ff6600, #ff8c00) !important;
      background-size: 200% 100%;
      animation: progressShimmer 2s linear infinite;
    }
    @keyframes progressShimmer {
      0% { background-position: 200% 0; }
      100% { background-position: -200% 0; }
    }

    /* ============================================
       SHINY SWITCH INPUT
       ============================================ */
    .bootstrap-switch {
      border-radius: 20px !important;
      border-color: var(--sh-border) !important;
    }
    .bootstrap-switch .bootstrap-switch-handle-on.bootstrap-switch-warning {
      background: var(--sh-primary) !important;
      color: #fff !important;
      border-radius: 20px 0 0 20px !important;
    }

    /* ============================================
       NOTIFICATION TOASTS
       ============================================ */
    .shiny-notification {
      border-radius: var(--sh-radius-sm) !important;
      border: 1px solid var(--sh-border) !important;
      box-shadow: var(--sh-shadow-lg) !important;
      font-family: 'Inter', sans-serif !important;
      animation: toastSlide 0.4s var(--sh-spring) both;
      backdrop-filter: blur(12px);
    }
    @keyframes toastSlide {
      from { opacity: 0; transform: translateX(20px); }
      to { opacity: 1; transform: translateX(0); }
    }

    /* ============================================
       CONFIRMATION MODAL
       ============================================ */
    .sh-modal-overlay {
      position: fixed;
      inset: 0;
      background: rgba(0,0,0,0.5);
      z-index: 9998;
      backdrop-filter: blur(4px);
      animation: overlayFade 0.25s ease;
    }
    .sh-modal {
      position: fixed;
      z-index: 9999;
      background: var(--sh-surface);
      border: 1px solid var(--sh-border);
      border-radius: var(--sh-radius);
      padding: 28px;
      max-width: 440px;
      width: 90%;
      top: 50%; left: 50%;
      transform: translate(-50%, -50%);
      box-shadow: 0 24px 80px rgba(0,0,0,0.15);
      animation: modalEntrance 0.35s var(--sh-spring) both;
    }
    @keyframes modalEntrance {
      from { opacity: 0; transform: translate(-50%, -50%) scale(0.95); }
      to { opacity: 1; transform: translate(-50%, -50%) scale(1); }
    }

    /* ============================================
       RESET BUTTON
       ============================================ */
    .btn-reset {
      background: transparent !important;
      border: 1px solid rgba(239, 68, 68, 0.2) !important;
      color: var(--sh-sidebar-text) !important;
      font-size: 0.72rem !important;
      border-radius: var(--sh-radius-xs) !important;
      padding: 4px 10px !important;
    }
    .btn-reset:hover {
      background: rgba(239, 68, 68, 0.08) !important;
      border-color: rgba(239, 68, 68, 0.4) !important;
      color: var(--sh-danger) !important;
    }

    /* ============================================
       GENERAL POLISH
       ============================================ */
    .navset-card-tab { border-radius: var(--sh-radius) !important; }
    .navset-card-tab > .nav { border-bottom: 1px solid var(--sh-border) !important; }

    /* Smooth transitions on interactive elements */
    a, button, .btn, input, select, .form-control, .form-select, .card {
      transition: var(--sh-transition);
    }

    /* Main content area */
    .bslib-sidebar-layout > .main { background: var(--sh-bg) !important; }

    /* ============================================
       STAT CARDS (for results overview)
       ============================================ */
    .stat-card {
      background: var(--sh-surface);
      border: 1px solid var(--sh-border);
      border-radius: var(--sh-radius-sm);
      padding: 16px 20px;
      text-align: center;
      transition: var(--sh-transition);
    }
    .stat-card:hover {
      transform: translateY(-2px);
      box-shadow: var(--sh-shadow-md);
    }
    .stat-card .stat-value {
      font-size: 1.6rem;
      font-weight: 800;
      color: var(--sh-primary);
      letter-spacing: -0.5px;
      line-height: 1.2;
    }
    .stat-card .stat-label {
      font-size: 0.72rem;
      font-weight: 600;
      color: var(--sh-text-muted);
      text-transform: uppercase;
      letter-spacing: 0.06em;
      margin-top: 4px;
    }

    /* ============================================
       VERSION FOOTER
       ============================================ */
    .sh-footer {
      padding: 16px 0 8px;
      border-top: 1px solid var(--sh-sidebar-border);
      margin-top: 16px;
      text-align: center;
    }
    .sh-footer span {
      font-size: 0.6rem;
      color: rgba(255,255,255,0.2);
      letter-spacing: 0.04em;
    }
  ")),

    # ---- Animated stepper + step gating + elapsed timer JS ----
    tags$script(HTML("
      $(document).ready(function() {
        // Build visual stepper
        var steps = ['upload', 'configure', 'advanced', 'results'];
        var labels = ['Upload', 'Configure', 'Advanced', 'Run'];
        var icons = ['\\u2191', '\\u2699', '\\u2699', '\\u25B6'];
        var $stepper = $('<div class=\"wizard-stepper\" id=\"visual-stepper\"></div>');

        steps.forEach(function(step, i) {
          if (i > 0) {
            $stepper.append('<div class=\"step-connector\" id=\"conn-' + i + '\"></div>');
          }
          $stepper.append(
            '<div class=\"step-item\" data-step=\"' + step + '\" id=\"step-' + step + '\">' +
              '<div class=\"step-circle\">' + (i + 1) + '</div>' +
              '<span class=\"step-label\">' + labels[i] + '</span>' +
              '<span class=\"step-completion-badge pending\" id=\"badge-' + step + '\"></span>' +
            '</div>'
          );
        });

        var $radio = $('#wizard_step');
        $radio.before($stepper);

        $stepper.on('click', '.step-item:not(.step-locked)', function() {
          var step = $(this).data('step');
          Shiny.setInputValue('wizard_step', step);
        });

        function updateStepper() {
          var current = $('input[name=\"wizard_step\"]:checked').val() || 'upload';
          var idx = steps.indexOf(current);

          steps.forEach(function(step, i) {
            var $item = $('#step-' + step);
            $item.removeClass('step-active step-done');
            if (i === idx) {
              $item.addClass('step-active');
            } else if (i < idx) {
              $item.addClass('step-done');
              $item.find('.step-circle').html('\\u2713');
            } else {
              $item.find('.step-circle').html(i + 1);
            }
          });

          for (var i = 1; i < steps.length; i++) {
            var $conn = $('#conn-' + i);
            if (i <= idx) $conn.addClass('connector-done');
            else $conn.removeClass('connector-done');
          }
        }

        $(document).on('shiny:inputchanged', function(e) {
          if (e.name === 'wizard_step') {
            setTimeout(updateStepper, 50);
          }
        });

        // Step gating with completion badges
        Shiny.addCustomMessageHandler('stepGating', function(state) {
          var steps = ['upload', 'configure', 'advanced', 'results'];
          steps.forEach(function(step, i) {
            var $item = $('#step-' + step);
            var $badge = $('#badge-' + step);
            if (step !== 'upload' && !state[step]) {
              $item.addClass('step-locked');
              $badge.removeClass('done').addClass('pending').html('\\uD83D\\uDD12');
            } else {
              $item.removeClass('step-locked');
              if (state[step] && step !== 'results') {
                $badge.removeClass('pending').addClass('done').html('\\u2713');
              } else {
                $badge.html('');
              }
            }
          });
          updateStepper();
        });

        setTimeout(updateStepper, 200);

        // ---- Elapsed timer ----
        var timerInterval = null;
        var startTime = null;
        Shiny.addCustomMessageHandler('startTimer', function(msg) {
          startTime = Date.now();
          if (timerInterval) clearInterval(timerInterval);
          timerInterval = setInterval(function() {
            var elapsed = Math.floor((Date.now() - startTime) / 1000);
            var mins = Math.floor(elapsed / 60);
            var secs = elapsed % 60;
            var display = (mins > 0 ? mins + 'm ' : '') + secs + 's';
            $('#elapsed-display').text(display);
          }, 200);
        });
        Shiny.addCustomMessageHandler('stopTimer', function(msg) {
          if (timerInterval) {
            clearInterval(timerInterval);
            timerInterval = null;
          }
        });

        // ---- Confirmation dialog ----
        Shiny.addCustomMessageHandler('showConfirmDialog', function(msg) {
          var html = '<div class=\"sh-modal-overlay\" id=\"confirm-overlay\"></div>' +
            '<div class=\"sh-modal\" id=\"confirm-modal\">' +
              '<h5 style=\"color: #1a1a1a; font-weight: 700; margin-bottom: 8px;\">' + msg.title + '</h5>' +
              '<p style=\"color: #555; font-size: 0.88rem; line-height: 1.5; margin-bottom: 20px;\">' + msg.body + '</p>' +
              '<div style=\"display: flex; gap: 8px; justify-content: flex-end;\">' +
                '<button class=\"btn btn-outline-secondary btn-sm\" id=\"confirm-cancel\">Cancel</button>' +
                '<button class=\"btn btn-primary btn-sm\" id=\"confirm-ok\">' + (msg.confirmLabel || 'Confirm') + '</button>' +
              '</div>' +
            '</div>';
          $('body').append(html);
          $('#confirm-cancel, #confirm-overlay').on('click', function() {
            $('#confirm-overlay, #confirm-modal').remove();
          });
          $('#confirm-ok').on('click', function() {
            $('#confirm-overlay, #confirm-modal').remove();
            Shiny.setInputValue(msg.inputId, Math.random());
          });
        });
      });

      // ---- Dropzone → fileInput bridge ----
      $(document).on('click', '[id$=\"dropzone\"]', function() {
        $(this).closest('.card-body').find('input[type=\"file\"]').trigger('click');
      });
      // Drag-and-drop visual feedback
      $(document).on('dragover', '[id$=\"dropzone\"]', function(e) {
        e.preventDefault();
        $(this).addClass('dragover');
      });
      $(document).on('dragleave drop', '[id$=\"dropzone\"]', function(e) {
        $(this).removeClass('dragover');
      });
      $(document).on('drop', '[id$=\"dropzone\"]', function(e) {
        e.preventDefault();
        var files = e.originalEvent.dataTransfer.files;
        if (files.length > 0) {
          var fileInput = $(this).closest('.card-body').find('input[type=\"file\"]')[0];
          var dt = new DataTransfer();
          dt.items.add(files[0]);
          fileInput.files = dt.files;
          $(fileInput).trigger('change');
        }
      });

      // ---- Keyboard shortcuts ----
      $(document).on('keydown', function(e) {
        if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
          e.preventDefault();
          var $runBtn = $('[id$=\"-run_btn\"]');
          if ($runBtn.length) $runBtn.click();
        }
        if (e.key === 'ArrowRight' && !$(e.target).is('input, textarea, select')) {
          e.preventDefault();
          $('#next_step').click();
        }
        if (e.key === 'ArrowLeft' && !$(e.target).is('input, textarea, select')) {
          e.preventDefault();
          $('#prev_step').click();
        }
        if (e.key === '?' && !$(e.target).is('input, textarea, select')) {
          e.preventDefault();
          var msg = 'Keyboard Shortcuts:\\n\\n' +
            '\\u2190 / \\u2192  Navigate steps\\n' +
            'Ctrl+Enter  Start training\\n' +
            'R  Reset all\\n' +
            '?  Show this help';
          alert(msg);
        }
        if (e.key === 'r' && !e.ctrlKey && !e.metaKey && !$(e.target).is('input, textarea, select')) {
          e.preventDefault();
          if (confirm('Reset all settings and data? This cannot be undone.')) {
            var $resetBtn = $('#reset_all');
            if ($resetBtn.length) $resetBtn.click();
          }
        }
      });

      // ---- Onboarding tour ----
      $(document).ready(function() {
        var tourSeen = localStorage.getItem('sensehub_tour_v2');
        if (tourSeen) return;

        var tourSteps = [
          { title: 'Welcome to Sensehub \\u2728', text: 'Build production-ready ML models in 4 steps. No code required \\u2014 just upload, configure, and run.' },
          { title: 'Smart Navigation', text: 'Steps unlock as you progress. Use the glowing sidebar to jump between completed steps.' },
          { title: 'Power User Mode', text: 'Use \\u2190/\\u2192 arrows to navigate, Ctrl+Enter to run training, R to reset, and ? for help anytime.' },
          { title: 'Deep Insights', text: 'After training, explore SHAP waterfall plots, drift detection, partial dependence, and a model comparison radar chart.' },
          { title: 'Ready to go!', text: 'Upload a dataset or click a sample dataset button to start building models right away.' }
        ];

        var currentStep = 0;

        function buildProgressDots(total, active) {
          var html = '<div class=\"tour-progress\">';
          for (var i = 0; i < total; i++) {
            html += '<div class=\"tour-progress-dot' + (i === active ? ' active' : '') + String.fromCharCode(34) + '></div>';
          }
          html += '</div>';
          return html;
        }

        function showTourStep(idx) {
          $('.tour-overlay, .tour-tooltip').remove();
          if (idx >= tourSteps.length) {
            localStorage.setItem('sensehub_tour_v2', 'true');
            return;
          }

          var step = tourSteps[idx];
          $('body').append('<div class=\"tour-overlay\"></div>');
          var tooltip = '<div class=\"tour-tooltip\" style=\"top: 50%; left: 50%; transform: translate(-50%, -50%);\">' +
            '<h5>' + step.title + '</h5>' +
            '<p>' + step.text + '</p>' +
            '<div class=\"tour-actions\">' +
              buildProgressDots(tourSteps.length, idx) +
              '<div>' +
                (idx > 0 ? '<button class=\"btn btn-outline-secondary btn-sm me-2\" id=\"tour-back\">Back</button>' : '') +
                (idx < tourSteps.length - 1 ?
                  '<button class=\"btn btn-primary btn-sm\" id=\"tour-next\">Next</button>' :
                  '<button class=\"btn btn-primary btn-sm\" id=\"tour-done\">Get Started \\u2192</button>') +
              '</div>' +
            '</div>' +
          '</div>';
          $('body').append(tooltip);

          $('#tour-next').on('click', function() { showTourStep(idx + 1); });
          $('#tour-back').on('click', function() { showTourStep(idx - 1); });
          $('#tour-done').on('click', function() {
            $('.tour-overlay, .tour-tooltip').remove();
            localStorage.setItem('sensehub_tour_v2', 'true');
          });
          $('.tour-overlay').on('click', function() {
            $('.tour-overlay, .tour-tooltip').remove();
            localStorage.setItem('sensehub_tour_v2', 'true');
          });
        }

        setTimeout(function() { showTourStep(0); }, 1200);
      });
    "))
    )  # close tags$head
  ),  # close tagList (header)

  # ---- Single nav panel with sidebar wizard ----
  nav_panel(
    title = "Wizard",
    icon  = icon("wand-magic-sparkles"),

    layout_sidebar(
      fillable = TRUE,

      sidebar = sidebar(
        width = 280,
        title = tags$div(
          tags$div(
            style = "display: flex; align-items: center; gap: 10px; margin-bottom: 6px;",
            tags$div(
              style = "width: 36px; height: 36px; border-radius: 10px;
                       background: linear-gradient(135deg, #ff8c00, #ff6600);
                       display: flex; align-items: center; justify-content: center;
                       box-shadow: 0 3px 12px rgba(255,140,0,0.35);",
              icon("bolt", style = "color: #fff; font-size: 0.9rem;")
            ),
            tags$div(
              tags$h5("Model Builder",
                       style = "margin: 0; color: #e8e8ec; font-weight: 700;
                                font-size: 1rem; letter-spacing: -0.3px;"),
              tags$p(
                style = "color: #666; font-size: 0.72rem; margin: 2px 0 0 0; letter-spacing: 0.02em;",
                "Upload \u2192 Configure \u2192 Run"
              )
            )
          )
        ),

        tags$hr(style = "border-color: rgba(255,255,255,0.06); margin: 12px 0;"),

        radioButtons(
          "wizard_step", label = NULL,
          choiceNames  = names(wizard_steps),
          choiceValues = unname(wizard_steps),
          selected     = "upload"
        ),

        tags$hr(style = "border-color: rgba(255,255,255,0.06); margin: 12px 0;"),

        div(
          class = "d-flex justify-content-between",
          style = "gap: 8px;",
          actionButton("prev_step",
                       tagList(icon("arrow-left"), tags$span(class = "kbd-hint", "\u2190")),
                       class = "btn-outline-secondary btn-sm",
                       style = "flex: 1;"),
          actionButton("next_step",
                       tagList("Next ", icon("arrow-right"), tags$span(class = "kbd-hint", "\u2192")),
                       class = "btn-primary btn-sm",
                       style = "flex: 2;")
        ),

        tags$div(
          style = "margin-top: 8px;",
          actionButton("reset_all", tagList(icon("rotate-left"), " Reset"),
                       class = "btn-reset w-100 btn-sm")
        ),

        # Session save/restore
        tags$div(
          class = "session-controls",
          tags$label("Session", style = "color: rgba(255,255,255,0.3); font-size: 0.7rem;
                      font-weight: 600; text-transform: uppercase; letter-spacing: 0.08em;"),
          tags$div(
            class = "d-flex gap-1 mt-1",
            downloadButton("save_session", icon("download"),
                           class = "btn-outline-secondary btn-sm", style = "flex: 1;"),
            tags$div(
              style = "flex: 1;",
              fileInput("restore_session", label = NULL,
                        accept = ".rds", buttonLabel = icon("upload"),
                        placeholder = "Restore")
            )
          )
        ),

        # Footer
        tags$div(
          class = "sh-footer",
          tags$span("Sensehub v2.0 \u00b7 tidymodels engine")
        )
      ),

      # ---- Wizard panels ----
      conditionalPanel("input.wizard_step == 'upload'",    mod_upload_ui("upload")),
      conditionalPanel("input.wizard_step == 'configure'", mod_configure_ui("configure")),
      conditionalPanel("input.wizard_step == 'advanced'",  mod_advanced_ui("advanced")),
      conditionalPanel("input.wizard_step == 'results'",   mod_results_ui("results"))
    )
  )
)
