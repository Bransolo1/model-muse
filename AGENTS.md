# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

Sensehub AutoM/L is a dual-stack project:
- **R Shiny AutoML Wizard** (`shiny-app/`): The primary product. A 4-step ML wizard using tidymodels. Runs on port 3840.
- **React Landing Page** (`src/`): Optional marketing/landing page. Vite + React + TypeScript + Tailwind CSS.

No database or external services required; all data stays in-memory per-session.

### Running services

- **Shiny app**: `Rscript -e 'shiny::runApp(appDir = normalizePath("shiny-app"), host = "0.0.0.0", port = 3840L, launch.browser = FALSE)'`
- **React dev server**: `npm run dev` (Vite, defaults to port 8080 or next available)

### Lint and test commands

See `README.md` and `CONTRIBUTING.md` for standard commands. Key summary:

| Stack | Lint | Test | Build |
|-------|------|------|-------|
| React/TS | `npm run lint` | `npm run test` | `npm run build` |
| R/Shiny | `Rscript -e 'library(lintr); lint_dir("shiny-app/R/", linters = list(line_length_linter(240)))'` | See CI workflow below | N/A |

R unit tests (from `shiny-app/` directory):
```sh
cd shiny-app && Rscript -e '
library(testthat)
source("R/config.R"); source("R/utils_logging.R"); source("R/utils_validation.R")
source("R/modeling.R"); source("R/export.R")
test_dir("tests/", reporter = "summary")
'
```

### Known issues

- The Shiny app UI loads correctly, but sessions crash on initialization with Shiny 1.13.0 / R 4.5.2 due to a reactive context error at `server.R` line 97. The CI uses R 4.3.2, which may have a different Shiny version. This is a pre-existing issue.
- React tests in `src/pages/Index.test.tsx` and `src/pages/QuickStart.test.tsx` have pre-existing failures (7 of 14 tests fail) due to React testing library compatibility issues ("Should not already be working" errors).
- ESLint reports 1 pre-existing error in `tailwind.config.ts` (`@typescript-eslint/no-require-imports`) and 2 warnings.

### R environment notes

- R packages are installed to `/usr/local/lib/R/site-library/`. This directory must be writable (`sudo chmod 777 /usr/local/lib/R/site-library/` if needed).
- System dependencies required for R package compilation: `libcurl4-openssl-dev libssl-dev libxml2-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev`.
- `testthat` and `lintr` are not in `install_packages.R` but are needed for CI-style lint/test. Install separately.
- Validation: `Rscript validate_r_app.R` from project root checks structure, packages, and config loading.
