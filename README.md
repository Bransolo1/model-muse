# Sensehub AutoM/L

**Quick start:** [Run from RStudio](RUN_FROM_RSTUDIO.md) · **Step-by-step:** [START_APP.md](START_APP.md)

The app runs from **RStudio** on your machine — no servers, no Docker, no Node.js for the main app. **The app runs only on your machine; your data is not sent to any external server.** Requires R 4.2+.

- **New to RStudio?** Follow **[START_APP.md](START_APP.md)** (open project → install packages once → run one line → app opens in browser).
- **Already use RStudio?** Open the project, run `source("install_packages.R")` once, then **`source("launch_sensehub.R")`** (validates then runs) or `source("run_app.R")`.
- **Something broke?** See **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** (log file location, what to share when reporting). See [RUN_FROM_RSTUDIO.md](RUN_FROM_RSTUDIO.md) for details.

## Run from RStudio

1. **Open this project in RStudio** (File → Open Project → choose this folder, or use the `SensehubAutoML.Rproj` file).
2. **Install R packages** once (see [RUN_FROM_RSTUDIO.md](RUN_FROM_RSTUDIO.md) or run `source("install_packages.R")`).
3. **Run the app:** in the Console run **`source("launch_sensehub.R")`** (validates then runs) or `source("run_app.R")`. Or open `launch_sensehub.R` and Source it (`Ctrl+Shift+S` / `Cmd+Shift+S`).

The Shiny AutoML wizard will open in your browser. Full instructions: **[RUN_FROM_RSTUDIO.md](RUN_FROM_RSTUDIO.md)**. One-page overview: **[docs/CHEATSHEET.md](docs/CHEATSHEET.md)**.

## UAT and smoke check

Before handoff or UAT: run `source("validate_r_app.R")` then `source("run_app.R")` and follow the **golden path** in **[UAT.md](UAT.md)** (Upload → Configure → Advanced → Run → check Leaderboard and Export). See [UAT.md](UAT.md) for scope and where to report issues.

## Optional: React landing page

The React frontend in `src/` is optional (marketing/landing). To run it you need Node.js:

```sh
npm i
npm run dev
```

## Testing (React)

With Node.js installed, from the project root:

```sh
npm install
npm run test    # unit tests (Vitest)
npm run lint    # ESLint
npm run build   # production build
```

## Structure

- **`run_app.R`** — Entry point to run the Shiny app from RStudio.
- **`shiny-app/`** — R Shiny AutoML wizard (tidymodels). Must be present (clone full repo if missing).
- **`src/`** — Optional Vite + React frontend (shadcn, Tailwind).
- **`docs/`** — Delivery guide, cheatsheet, improvements.
- **`.github/workflows/`** — CI (sensehub-ci, react-ci).

## Disclaimer

No warranty; use at your own risk. Data stays on your machine. The app does not send your data to any external server.

## Tech

- **Main app:** R Shiny, tidymodels, bslib.
- **Optional frontend:** Vite, TypeScript, React, shadcn-ui, Tailwind CSS.
