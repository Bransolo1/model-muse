# Running the app from RStudio

You can run **Sensehub AutoM/L** entirely from RStudio. Colleagues only need:

- **R** (4.2+)
- **RStudio**
- This codebase (e.g. clone of the repo or a copy of the project folder)

No Node.js or command line is required for the main app. The app’s look and feel (colours, typography, controls) is aligned with the Sensehub landing page at [auto-model-buddy.lovable.app](https://auto-model-buddy.lovable.app/).

**In a corporate environment with strict IT?** See **[docs/DELIVERY_NO_IT.md](docs/DELIVERY_NO_IT.md)** for how to deliver and run this without new infrastructure or tickets.

---

## 1. Open the project in RStudio

- **File → Open Project…** (or double‑click the `SensehubAutoML.Rproj` file if present).
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

1. Open **`run_app.R`** in the editor (or leave it closed).
2. In the **Console** (bottom pane), run:

```r
source("run_app.R")
```

Or use **Source** (`Ctrl+Shift+S` / `Cmd+Shift+S`) with `run_app.R` focused.

**What you’ll see:** The Console will print `Run app: starting...`, then `Launching Sensehub AutoM/L (Shiny app)...`, then Shiny’s `Listening on http://127.0.0.1:3840`. The app opens in your browser or RStudio Viewer.

If nothing appears in the Console, set the working directory to the project folder: run `setwd("/path/to/your/Github project")` (use your actual path), then run `source("run_app.R")` again. Alternatively, you can set the environment variable `SENSEHUB_PROJECT_DIR` to that path so the script can switch to it automatically when needed.

---

## 4. If you don’t have the full codebase

You must have the **full** project, including the **`shiny-app`** folder with:

- `server.R`, `ui.R`, `global.R`
- `shiny-app/R/` (all R helper and module files)

If you only have part of the repo and get an error when running `run_app.R`, get the full project via RStudio: **File → New Project → Version Control → Git**, paste the repository URL `https://github.com/Bransolo1/model-muse`, choose a folder, and click Create. Then run `source("run_app.R")` in the Console.

---

## 5. React landing page (optional)

The **React** site in the project root (`src/`, `package.json`, etc.) is a separate marketing/landing front end. To build or run it you need **Node.js** and a terminal (e.g. RStudio’s Terminal pane or a system terminal):

```bash
npm install
npm run dev
```

Colleagues who only need the **AutoML wizard** can ignore the React app and run everything from RStudio using **`run_app.R`** as above.
