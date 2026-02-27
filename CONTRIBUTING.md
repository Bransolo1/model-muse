# Contributing to Sensehub AutoM/L (model-muse)

Thanks for your interest in contributing. This project has two main parts: the **Shiny AutoML app** (what colleagues run) and an optional **React landing page** (marketing/docs).

## What lives where

- **Main app:** R Shiny wizard in `shiny-app/`. Colleagues run it from RStudio via `run_app.R`. This is the primary product.
- **Landing page:** Vite + React in `src/`. Optional; used for marketing and the “Quick Start” instructions. Requires Node.js to develop or build.
- **Docs:** `README.md`, `RUN_FROM_RSTUDIO.md`, `docs/` (e.g. DELIVERY_NO_IT.md, IMPROVEMENT_ROADMAP.md).

## Running the Shiny app

1. Open the project in RStudio (File → Open Project → this folder).
2. Install R packages (see RUN_FROM_RSTUDIO.md for the list).
3. Run `source("run_app.R")` or open `run_app.R` and Source.

Requires **R 4.2+**.

## Running the React landing page

From the project root:

```sh
npm install
npm run dev
```

Then open the URL shown (e.g. http://localhost:5173).

## Code style and checks

- **React/TypeScript:** ESLint. Run `npm run lint`. We use the existing config (e.g. React Hooks, TypeScript).
- **R:** When editing the Shiny app, follow the lint rules used in CI (see `.github/workflows/`). The Shiny CI lints `shiny-app/R/`.
- **React tests:** Vitest + Testing Library. Run `npm run test` (or `npm run test:watch`).

## Pull requests

- Keep the **run flow** intact: `run_app.R` must remain the single entry point for the Shiny app; the Quick Start on the landing page should match RUN_FROM_RSTUDIO.md.
- If you change the package list (install block or RUN_FROM_RSTUDIO.md), ensure it stays in sync with what the Shiny app’s `global.R` (and related R code) actually loads.
- React CI runs on push/PR for `src/` and related frontend files (lint + test + build). Shiny CI runs for `shiny-app/`.

## Docs

- New user-facing steps or run instructions → update README and/or RUN_FROM_RSTUDIO.md (and the landing Quick Start if it’s copy-paste R code).
- Corporate/no-IT delivery → docs/DELIVERY_NO_IT.md and CHECKLIST.md.
- Improvement ideas → docs/IMPROVEMENT_ROADMAP.md.

If you’re unsure where to put something, open an issue or ask in a PR.
