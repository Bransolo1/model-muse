# Sensehub AutoM/L — Dependencies

All dependencies are documented here. Keep this file in sync with `install_packages.R` and `package.json`.

---

## R / Shiny App (Primary)

**R version:** 4.2+ recommended

**Install:** `source("install_packages.R")` from project root in RStudio

| Category | Packages |
|----------|----------|
| **Shiny & UI** | shiny, bslib, DT, shinyWidgets, shinyjs |
| **Tidymodels** | tidymodels, recipes, parsnip, workflows, workflowsets, tune, rsample, yardstick, dials, stacks, probably |
| **Model engines** | glmnet, ranger, xgboost, kknn, kernlab, discrim, naivebayes, rpart |
| **Async** | promises, future, parallelly |
| **Data & viz** | dplyr, tidyr, purrr, readr, forcats, readxl, lubridate, ggplot2, jsonlite, vip, themis |
| **Optional** | earth (MARS), dotenv (.env support) |

**Validation:** `source("validate_r_app.R")` checks all required packages and project structure.

---

## React Landing Page (Optional)

**Node.js:** 18+ recommended

**Install:** `npm install` from project root

**Run:** `npm run dev` (development) or `npm run build` (production)

The React app is a separate marketing/landing front end. Colleagues who only need the AutoML wizard can ignore it and run everything from RStudio via `source("run_app.R")`.

---

## Integration Points

- **Shiny app** runs standalone; no Node.js required
- **Config:** `shiny-app/R/config.R` loads from env vars (see `shiny-app/.env.example`). Prefer `SENSEHUB_*` vars; optional `.env` via dotenv
- **Modules:** server.R wires mod_upload, mod_configure, mod_advanced, mod_results; all share `rv` reactive values
- **Entry point:** `run_app.R` → sets wd to shiny-app → Shiny loads global.R (config, utils, modules)
