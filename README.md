# Sensehub AutoM/L

**Quick start:** [Run from RStudio](RUN_FROM_RSTUDIO.md)

The app runs from **RStudio** on your machine — no servers, no Docker, no Node.js for the main app. Open the project, install R packages once, and run `source("run_app.R")`. **Requires R 4.2+**.

## Run from RStudio

1. **Open this project in RStudio** (File → Open Project → choose this folder, or use the `SensehubAutoML.Rproj` file).
2. **Install R packages** once (see [RUN_FROM_RSTUDIO.md](RUN_FROM_RSTUDIO.md) for the list).
3. **Run the app:** open `run_app.R` and source it (`Ctrl+Shift+S` / `Cmd+Shift+S`), or run `source("run_app.R")`.

The Shiny AutoML wizard will open in your browser. Full instructions: **[RUN_FROM_RSTUDIO.md](RUN_FROM_RSTUDIO.md)**. One-page overview: **[docs/CHEATSHEET.md](docs/CHEATSHEET.md)**.

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

## Tech

- **Main app:** R Shiny, tidymodels, bslib.
- **Optional frontend:** Vite, TypeScript, React, shadcn-ui, Tailwind CSS.
