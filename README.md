# Sensehub AutoM/L

**Quick start:** [Run from RStudio](RUN_FROM_RSTUDIO.md)

Runnable from **RStudio** so colleagues can use the app by opening this codebase (no Node required for the main app). **Requires R 4.2+**.

**Corporate / strict IT?** See **[docs/DELIVERY_NO_IT.md](docs/DELIVERY_NO_IT.md)** for delivering and running the app without new servers or IT tickets (RStudio-only, no Docker).

## Run from RStudio (recommended for colleagues)

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

- **`run_app.R`** – Single entry point to run the Shiny app from RStudio.
- **`shiny-app/`** – R Shiny AutoML wizard (tidymodels). Must be present (clone full repo if missing).
- **`R/`** – Shared R utilities.
- **`src/`** – Optional Vite + React frontend (shadcn, Tailwind).
- **`.github/workflows/`** – CI (e.g. sensehub-ci).

## Tech

- **Main app:** R Shiny, tidymodels, bslib.
- **Optional frontend:** Vite, TypeScript, React, shadcn-ui, Tailwind CSS.
