# Changelog

All notable changes to the Sensehub AutoM/L project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

- **Usability for colleagues:** TROUBLESHOOTING.md (app won’t start, packages missing, training/export fails, log file location). File-based logging: logs written to a date-named file in the Sensehub log dir (Windows: `%LOCALAPPDATA%\\Sensehub\\logs\\`; macOS/Linux: see TROUBLESHOOTING.md). `launch_sensehub.R` — one script to validate then run the app. `launch_sensehub.bat` — Windows double-click launcher (no RStudio). Minimal R package: DESCRIPTION, NAMESPACE, `R/run_app.R`; `sensehub::run_app()` from project root (after `devtools::load_all(".")`). In-app error display: training and validation failures show a notification and point to the log file / TROUBLESHOOTING when file logging is available.
- `app_config()` helper in `shiny-app/R/config.R` to read config from `options(sensehub.config)`; `rate_limit_secs` added to app config (env: `SENSEHUB_RATE_LIMIT_SECS`, default 15).
- RUN_FROM_RSTUDIO: “What you’ll see” and troubleshooting (setwd / `SENSEHUB_PROJECT_DIR`).
- Dark mode toggle on the React landing page (ThemeProvider + Navbar toggle).
- SEO meta description and Open Graph tags in `index.html`.
- Favicon (`public/favicon.svg`) for the landing page.
- Lazy loading for below-the-fold components (PipelineDiagram, Testimonials, FileTree) on the landing page.
- Pre-handoff checklist in RUN_FROM_RSTUDIO.md (§6) and CHECKLIST.md.
- CONTRIBUTING.md (how to run Shiny vs React, code style, PR notes).
- CHANGELOG.md (this file).
- GitHub Actions workflow for React (lint, test, build) in `.github/workflows/react-ci.yml`.
- One-page cheat sheet at docs/CHEATSHEET.md.
- Index page tests (Quick Start sections, copy button).
- Print styles in `src/index.css` for the landing page.

### Changed

- Single toast system: Radix Toaster removed; Sonner only, with theme tied to light/dark mode.
- React Query removed from the app until needed (no current use of useQuery/useMutation).
- run_app.R: friendlier first-run message when the `shiny` package is missing (points to RUN_FROM_RSTUDIO.md).
- README: explicit “Requires R 4.2+” for the run-from-RStudio path.
- Sonner component accepts a `theme` prop so toasts follow light/dark.

### Fixed

- **ui.R:** Error sourcing ui.R — fixed unescaped double-quote in tour progress-dots JS (use `String.fromCharCode(34)` for the closing quote).

---

## Earlier work

- Landing page: premium styling, skip link, ErrorBoundary, CopyCodeButton for code blocks, reduced-motion support, accessibility improvements.
- run_app.R: host set to 127.0.0.1 for localhost-only binding; setwd/on.exit and package checks in place.
- Docs: RUN_FROM_RSTUDIO.md, CHEATSHEET.md, IMPROVEMENTS.md, CHECKLIST.md.
