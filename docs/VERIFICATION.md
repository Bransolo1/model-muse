# Quick Start & run_app.R verification

This document records checks that the landing-page code blocks and `run_app.R` preserve **integrity**, **stability**, **functionality**, **UX**, and **underlying model compatibility**.

---

## 1. Code block integrity

- **Install block**  
  The R snippet in `src/pages/Index.tsx` (Quick Start Step 1) is valid R: `install.packages(c("pkg1", "pkg2", ...))` with correct quoting and commas. The same string is passed to `CopyCodeButton`, so copy-paste from the button yields runnable code.

- **Run block**  
  Step 2 uses `source("run_app.R")`. This assumes the R session working directory is the **project root** (folder containing `run_app.R`), which Step 0 enforces (“Open this folder in RStudio”).

- **Consistency**  
  The package list in Index.tsx matches `RUN_FROM_RSTUDIO.md` and the `library(...)` calls in the Shiny app’s `global.R` (see §3).

---

## 2. run_app.R behaviour

- **Logic**  
  - Resolves `shiny-app` and `shiny-app/server.R`; stops with clear messages if missing.  
  - `owd <- setwd(shiny_app_dir)` then `on.exit(setwd(owd))` so the app runs with working directory `shiny-app/`, then restores the previous directory.  
  - `shiny::runApp(host = "127.0.0.1", launch.browser = TRUE)`.

- **Stability**  
  No other logic was changed. `host = "127.0.0.1"` only restricts the server to localhost (intended for no-IT / corporate use). App behaviour and models are unchanged.

- **Functionality**  
  Browsers and Shiny still work as before; only the network binding is localhost.

---

## 3. Package list vs Shiny app (model / app compatibility)

The Shiny app’s `global.R` (repo: `Bransolo1/model-muse`, `shiny-app/global.R`) loads:

| Category        | Packages |
|-----------------|----------|
| Core Shiny & UI | shiny, bslib, DT, shinyWidgets, shinyjs |
| Tidymodels      | tidymodels, recipes, parsnip, workflows, workflowsets, tune, rsample, yardstick, dials, stacks, probably |
| Engines         | glmnet, ranger, xgboost, kknn, kernlab, discrim, naivebayes, rpart |
| Async           | promises, future |
| Utilities       | dplyr, tidyr, purrr, readr, forcats, readxl, lubridate, ggplot2, jsonlite |
| Extra           | vip, themis (used in app) |

Optional (not in the main install block):

- **earth** – MARS models; `global.R` uses `requireNamespace("earth", quietly = TRUE)`.
- **parallelly** – `availableCores()` for `future::plan(multisession)`; falls back to 1 worker if absent.

The Quick Start install block and `RUN_FROM_RSTUDIO.md` include exactly the packages from the table above. Optional packages are documented (landing page note + RUN_FROM_RSTUDIO). No underlying model code was changed; only the run flow and host setting were adjusted.

---

## 4. UX

- **Flow**  
  Step 0 (open project) → Step 1 (install once) → Step 2 (`source("run_app.R")` or open and Source). No conflicting instructions (e.g. no standalone “setwd” or “run from shiny-app” in the Quick Start).

- **File tree**  
  Shows project root with `run_app.R` and `shiny-app/` underneath, matching “open project, then source run_app.R”.

- **Copy**  
  Copy button copies the exact R string; displayed `<pre>` matches. Optional packages are noted below the install block.

---

## 5. Summary

| Area           | Status |
|----------------|--------|
| Code block R   | Valid; copy-paste runs. |
| run_app.R      | Unchanged except `host = "127.0.0.1"`; setwd/on.exit/runApp correct. |
| Package list   | Matches global.R and RUN_FROM_RSTUDIO; optionals documented. |
| UX / flow      | Consistent; no conflicting steps. |
| Model / app    | No model or app code changed; dependencies aligned. |

If the repo’s `shiny-app/R/config.R` or other files require extra packages (e.g. `dotenv`), install those separately; the listed set covers `global.R` and the documented run flow.
