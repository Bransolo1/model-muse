# Running the app from RStudio

You can run **Sensehub AutoM/L** entirely from RStudio. Colleagues only need:

- **R** (4.2+)
- **RStudio**
- This codebase (e.g. clone of the repo or a copy of the project folder)

No Node.js or command line is required for the main app.

**In a corporate environment with strict IT?** See **[docs/DELIVERY_NO_IT.md](docs/DELIVERY_NO_IT.md)** for how to deliver and run this without new infrastructure or tickets.

---

## 1. Open the project in RStudio

- **File → Open Project…** (or double‑click the `.Rproj` file if present).
- Choose the **project folder** (the one that contains `run_app.R` and the `shiny-app` folder).

---

## 2. Install R packages (first time only)

The Shiny app uses these packages. Install once:

```r
install.packages(c(
  "shiny", "bslib", "DT", "shinyWidgets", "shinyjs",
  "tidymodels", "recipes", "parsnip", "workflows", "workflowsets",
  "tune", "rsample", "yardstick", "dials", "stacks", "probably",
  "glmnet", "ranger", "xgboost", "kknn", "kernlab", "discrim", "naivebayes", "rpart",
  "promises", "future",
  "dplyr", "tidyr", "purrr", "readr", "forcats", "readxl", "lubridate",
  "ggplot2", "jsonlite", "vip", "themis"
))
```

If any fail, install them individually. Optional: `earth` (for MARS models).

---

## 3. Run the app

In RStudio:

- Open **`run_app.R`** in the editor.
- **Source** it: `Ctrl+Shift+S` (Windows/Linux) or `Cmd+Shift+S` (Mac), or run:

```r
source("run_app.R")
```

The Shiny app will start and open in your browser (or RStudio Viewer).

---

## 4. If you don’t have the full codebase

You must have the **full** project, including the **`shiny-app`** folder with:

- `server.R`, `ui.R`, `global.R`
- `shiny-app/R/` (all R helper and module files)

If you only have part of the repo and get an error when running `run_app.R`, clone the full repository:

```r
# In R, or in a terminal:
# git clone https://github.com/Bransolo1/model-muse.git
# Then open the cloned folder in RStudio and run run_app.R
```

---

## 5. React landing page (optional)

The **React** site in the project root (`src/`, `package.json`, etc.) is a separate marketing/landing front end. To build or run it you need **Node.js** and:

```bash
npm install
npm run dev
```

Colleagues who only need the **AutoML wizard** can ignore the React app and run everything from RStudio using **`run_app.R`** as above.
