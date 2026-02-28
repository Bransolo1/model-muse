# Sensehub AutoM/L

A guided AutoML experience for non-experts, built with R Shiny and the tidymodels ecosystem. Production-hardened with input validation, structured logging, rate limiting, and CI/CD.

---

## Architecture Overview

```
shiny-app/
├── global.R                    # Package loading, config init, logging init
├── server.R                    # Module orchestration, rate limiting, session management
├── ui.R                        # bslib wizard UI with 4-step sidebar navigation
├── Dockerfile                  # Production container (non-root, healthcheck)
├── .env.example                # Required environment variables (never commit .env)
├── .gitignore
├── .dockerignore
├── R/
│   ├── config.R                # Centralised config from env vars with fail-fast
│   ├── utils_logging.R         # Structured JSON logging (scrubs secrets)
│   ├── utils_validation.R      # Upload validation, rate limiting, input sanitisation
│   ├── modeling.R              # Core ML pipeline (parse, validate, preprocess, train)
│   ├── export.R                # Reproducibility bundle export (zip)
│   ├── mod_upload.R            # Step 1: Upload with file validation & rate limiting
│   ├── mod_configure.R         # Step 2: Target, predictors, problem type, metric
│   ├── mod_advanced.R          # Step 3: Tuning budget, CV, imbalance, ensemble
│   └── mod_results.R           # Step 4: Training, leaderboard, diagnostics, export
└── tests/
    ├── test_pipeline.R         # ML pipeline unit tests
    └── test_validation.R       # Security & validation unit tests
```

---

## Security Model

| Threat | Mitigation |
|---|---|
| **Malicious file upload** | Server-side file type, size, and extension validation before processing |
| **RDS deserialization** | Disabled by default (`SENSEHUB_ALLOW_RDS=FALSE`); logged when enabled |
| **Path traversal** | Filename sanitisation; no user input in file paths |
| **Resource exhaustion** | Rate limiting on uploads (3s) and training (15s); row/column limits |
| **Secrets in logs** | Structured logger scrubs keys matching `password`, `token`, `secret`, `key` |
| **Double-submission** | Training button disabled during runs; confirmation dialog required |

**No secrets are stored in code.** All configuration is via environment variables (see `.env.example`).

---

## Quick Start

### Prerequisites

- **R ≥ 4.3** and **RStudio** (or any R IDE)
- **rlang ≤ 1.1.6** (must be pinned first)

### 1. Pin rlang

```r
# install.packages("remotes")
remotes::install_version("rlang", version = "1.1.6")
```

### 2. Install dependencies

```r
install.packages(c(
  "shiny", "bslib", "DT", "shinyWidgets", "shinyjs",
  "tidymodels", "recipes", "parsnip", "workflows", "workflowsets",
  "tune", "rsample", "yardstick", "dials", "stacks", "probably",
  "glmnet", "ranger", "xgboost", "kknn", "kernlab", "discrim",
  "naivebayes", "rpart",
  "promises", "future",
  "dplyr", "tidyr", "purrr", "readr", "forcats", "readxl",
  "lubridate", "ggplot2", "jsonlite",
  "vip", "themis"
))
```

### 3. Configure environment (optional)

```bash
cp .env.example .env
# Edit .env to customise upload limits, rate limiting, etc.
```

### 4. Run the app

```r
setwd("path/to/shiny-app")
shiny::runApp()
```

---

## Environment Variables

All variables have safe defaults. Override via `.env` or system environment.

| Variable | Default | Description |
|---|---|---|
| `SENSEHUB_MAX_UPLOAD_MB` | `100` | Maximum upload file size in MB |
| `SENSEHUB_MAX_ROWS` | `5000000` | Maximum dataset rows |
| `SENSEHUB_MAX_COLUMNS` | `2000` | Maximum dataset columns |
| `SENSEHUB_ALLOW_RDS` | `FALSE` | Allow RDS uploads (security risk) |
| `SENSEHUB_RATE_LIMIT_SECS` | `15` | Cooldown between training runs |
| `SENSEHUB_MAX_WORKERS` | `2` | Parallel workers for async training |
| `SENSEHUB_SEED` | `42` | Global random seed |
| `SENSEHUB_LOG_LEVEL` | `info` | Logging verbosity |

---

## Running Tests

```r
setwd("path/to/shiny-app")

# All tests
testthat::test_dir("tests/")

# Individual test files
testthat::test_file("tests/test_pipeline.R")
testthat::test_file("tests/test_validation.R")
```

---

## CI/CD

GitHub Actions workflow at `.github/workflows/sensehub-ci.yml` runs on push/PR to `main`:

1. **R environment setup** (4.3.2)
2. **Package restore** (renv or fallback install)
3. **Lint** via `lintr` (warnings only, configurable to strict)
4. **Unit tests** via `testthat`

---

## Docker Deployment

```bash
cd shiny-app

# Build
docker build -t sensehub .

# Run (with env vars)
docker run -d \
  -p 3838:3838 \
  -e SENSEHUB_MAX_UPLOAD_MB=50 \
  -e SENSEHUB_ALLOW_RDS=FALSE \
  --name sensehub \
  sensehub

# Access at http://localhost:3838
```

The container:
- Uses `rocker/shiny:4.3.2` base image
- Runs as **non-root** user `sensehub`
- Includes a **healthcheck** (`curl` to port 3838)
- Does **not bake secrets** into the image
- Uses `.dockerignore` to exclude `.env` and renv cache

---

## Posit Connect Deployment

1. Set environment variables in the Posit Connect dashboard (Vars tab)
2. Deploy via `rsconnect::deployApp(".")` or git-backed deployment
3. Logs appear in the Posit Connect log viewer (JSON-structured)

---

## Features

- **4-step wizard** with friendly microcopy and safe defaults
- **Data health check** (missingness, types, IDs, duplicates)
- **Auto predictor selection** excluding suspected ID columns
- **Problem type inference** (classification, regression)
- **Smart metric defaults** (ROC AUC, PR AUC for rare classes, RMSE)
- **Model-specific preprocessing** (normalisation only for glmnet/SVM/KNN)
- **Async training** via `future` — UI never freezes
- **Tuning budgets**: Quick, Standard, Thorough (Bayesian)
- **Model catalogue**: Elastic Net, Random Forest, XGBoost, SVM, KNN, Naive Bayes, Decision Tree, MARS
- **Ensemble via stacks** when it improves performance
- **SHAP waterfall** for individual prediction explanations
- **Partial Dependence & ICE plots** for feature effects
- **Data drift detection** (KS test / Chi-squared)
- **Conformal prediction intervals** (honest split-conformal)
- **Full export bundle** with config, seed, predictions, fitted model
- **Session save/restore** for resuming work

---

## Observability

Structured JSON logs are emitted to stderr (captured by all deployment platforms):

```json
{"ts":"2025-01-15T10:30:00+0000","level":"INFO","msg":"User action: start_training","data":{"action":"start_training","n_rows":1000,"budget":"standard"}}
```

Sensitive fields (`password`, `token`, `secret`, `key`) are automatically scrubbed from log data.

---

## Security Notes

1. **No secrets in the repository.** Use environment variables for all configuration.
2. **No database or SQL.** Data is uploaded per-session and held in memory only.
3. **RDS uploads are disabled by default** because `readRDS()` can execute arbitrary R code during deserialization.
4. **File uploads are validated** server-side for type, extension, and size before any processing.
5. **Rate limiting** prevents abuse of upload and training endpoints.
6. **Session files** are validated for expected structure before restoration.
