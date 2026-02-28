# Sensehub AutoM/L — Project Structure

Repo: [Bransolo1/model-muse](https://github.com/Bransolo1/model-muse)

## Root

- `run_app.R` — Entry point to run the Shiny app from RStudio
- `install_packages.R` — Install all R dependencies
- `validate_r_app.R` — Validate R setup and packages
- `package.json` — Vite + React (optional landing page)
- `SensehubAutoML.Rproj` — RStudio project file
- `README.md`, `RUN_FROM_RSTUDIO.md`, `START_APP.md`, `UAT.md`, `CHECKLIST.md`, `DEPENDENCIES.md`, `STRUCTURE.md`

## Shiny App (`shiny-app/`)

- `server.R`, `ui.R`, `global.R` — Core Shiny files
- **`R/`** — App logic:
  - `config.R` — Environment/config
  - `utils_logging.R`, `utils_validation.R` — Utilities
  - `modeling.R` — Core pipeline (parse, train, evaluate)
  - `export.R` — Export bundle
  - `mod_upload.R`, `mod_configure.R`, `mod_advanced.R`, `mod_results.R` — Shiny modules
- `tests/` — testthat tests
- `Dockerfile`, `.env.example`, `.dockerignore`

## React Frontend (`src/`) — Optional

- `main.tsx`, `App.tsx` — React root
- `pages/` — Index, NotFound
- `components/` — Navbar, HeroOrb, FeatureCard, etc.
- `components/ui/` — shadcn components
- `lib/`, `hooks/` — Utils, toast

## Docs (`docs/`)

- (Sharing/handoff is in RUN_FROM_RSTUDIO.md §6 and CHECKLIST.md)
- `CHEATSHEET.md` — Quick reference
- `IMPROVEMENTS.md` — Future improvement ideas

## CI & Static

- `.github/workflows/` — sensehub-ci.yml (R), react-ci.yml (React)
- `public/` — favicon, robots.txt

## Commands

- **Shiny:** `source("run_app.R")` from project root in RStudio
- **React:** `npm install && npm run dev` (optional)
