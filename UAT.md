# User Acceptance Testing (UAT) — Sensehub AutoM/L

Use this to run a quick smoke check and a standard UAT path before handing off to testers.

---

## Before UAT: smoke check

On a machine with **R 4.2+** and **RStudio**, with the project open (project root = folder containing `run_app.R`):

1. **Validate setup**
   ```r
   source("validate_r_app.R")
   ```
   Fix any reported missing packages or files (see [RUN_FROM_RSTUDIO.md](RUN_FROM_RSTUDIO.md)).

2. **Start the app**
   ```r
   source("run_app.R")
   ```
   The app should open in your browser (e.g. http://127.0.0.1:3840).

3. **Run the golden path** (below). If it completes without errors, you’re ready for UAT.

---

## UAT scope

**In scope**

- Running the app from RStudio (open project → install packages once → `source("run_app.R")`).
- Full wizard: **Upload → Configure → Advanced → Run & Results**.
- Upload: CSV or sample data (Iris, mtcars, Diamonds).
- Configure: choose target, predictors (auto or manual), problem type, metric.
- Advanced: leave defaults or change budget/folds/imbalance/ensemble.
- Run: training runs, leaderboard and model cards appear.
- Results: Leaderboard, Diagnostics (ROC, confusion matrix, etc.), Export (download bundle, CSV, PNGs).

**Out of scope for this UAT**

- React landing page (optional; not required for the Shiny wizard).
- Docker or server deployment.
- Very large datasets or exotic file types beyond CSV/Excel/samples.

---

## Golden path (standard test)

One path all testers can follow for comparable results:

| Step | Action | What to check |
|------|--------|----------------|
| 1 | Open project in RStudio, run `source("validate_r_app.R")` | All checks pass. |
| 2 | Run `source("run_app.R")` | App opens in browser. |
| 3 | **Upload:** Click “Iris (classify)” (or upload a small CSV). | Data loads; preview and health show. |
| 4 | **Configure:** Leave target as e.g. Species; leave Auto-select on (or pick a few predictors). | Problem type and metric set; no errors. |
| 5 | **Advanced:** Leave defaults. Click Next to **Run**. | Step 4 is visible. |
| 6 | **Run:** Click “Start training”. | Progress and log appear; training completes. |
| 7 | **Results:** Open **Leaderboard** tab. | Table shows models and metric. |
| 8 | **Results:** Open **Diagnostics** (e.g. ROC, Confusion matrix). | Plots render. |
| 9 | **Export:** Click “Export all” (or download Predictions CSV). | File downloads. |

If all steps complete without errors, the smoke check / golden path passes.

---

## Reporting issues

- **GitHub:** Open an issue at [github.com/Bransolo1/model-muse/issues](https://github.com/Bransolo1/model-muse/issues). Include: what you did, what you expected, what happened, and (if possible) R version and any error messages.
- **Internal:** If your team uses another channel (email, Slack, etc.), report there and include the same details.

---

## Requirements reminder

- **R** 4.2 or higher  
- **RStudio**  
- **Packages:** Run `source("install_packages.R")` once before first run (see [RUN_FROM_RSTUDIO.md](RUN_FROM_RSTUDIO.md)).
