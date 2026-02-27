# Quick handoff checklist — Sensehub AutoM/L

Use this when giving the project to a colleague.

## Before you hand off

- [ ] You’re sharing the **full project folder** (has `run_app.R` and a `shiny-app` folder).
- [ ] The `shiny-app` folder contains `server.R`, `ui.R`, `global.R` (and the rest of the app).

## Tell your colleague

1. **Open the project** — In RStudio: File → Open Project → choose the folder that contains `run_app.R`.
2. **Install packages (first time only)** — Run the `install.packages(...)` block from **RUN_FROM_RSTUDIO.md** in the R console.
3. **Run the app** — Open `run_app.R` and click **Source**, or run `source("run_app.R")` in the console. The app opens in the browser.

**Requires:** R 4.2+ and RStudio.

Full instructions: **RUN_FROM_RSTUDIO.md**. No-IT delivery: **docs/DELIVERY_NO_IT.md**.
