# Troubleshooting — Sensehub AutoM/L

Use this when something goes wrong. **Where to report issues:** see [UAT.md](UAT.md) (or your team’s issue tracker).

---

## App won’t start

1. **Check you’re in the right folder**
   - In RStudio Console, run: `getwd()`
   - You should see a path that ends with the folder containing `run_app.R` and the `shiny-app` folder.
   - If not: **File → Open Project…** and choose that folder, or run:  
     `setwd("C:/path/to/your/project/folder")`  
     (replace with your actual path).

2. **Validate setup**
   - In the Console run: `source("validate_r_app.R")`
   - Fix any **FAIL** lines it prints (e.g. missing packages, missing files).
   - If it says “Missing packages”, run: `source("install_packages.R")` and try again.

3. **Still failing?**
   - Note the **exact error message** from the Console (copy/paste).
   - Check the **log file** (if you have one): see [Where are the log files?](#where-are-the-log-files) below.
   - Share the error and (if possible) the last 20 lines of the log file when reporting.

---

## “Packages missing” or install errors

1. Run once: `source("install_packages.R")`
2. If it errors on a specific package, install it by name, e.g.:  
   `install.packages("shiny")`  
   Then run `source("install_packages.R")` again.
3. Full list of required packages: see [RUN_FROM_RSTUDIO.md](RUN_FROM_RSTUDIO.md).
4. If you’re behind a corporate proxy, you may need to set `options(repos = ...)` or use a mirror; ask your IT or a colleague.

---

## Training fails or app crashes during “Run”

1. **Check the Run log** in the app (the text area under the Run button). It often shows the first line of the error.
2. **Check the log file** (if file logging is enabled): see [Where are the log files?](#where-are-the-log-files).  
   Open the file and look at the **last 20–30 lines** for `"level":"ERROR"` or stack traces.
3. **Common causes**
   - **Too little data** (e.g. &lt; 10 rows, or only one class in the target). Use a larger dataset or a different target.
   - **Wrong column types** (e.g. target has too many unique numbers). Try a different target or problem type.
   - **Out of memory** on very large data. Reduce rows/columns or use a smaller tuning budget.
4. When reporting, include: the **Run log** text from the app and (if possible) the **last 20 lines of the log file**.

---

## Export or download fails

1. **Training must have completed** (status “DONE”) before export works.
2. If a specific export (e.g. “Download bundle”) fails, check the **log file** for errors (see below).
3. When reporting, include: which export failed and the **error message** (and log snippet if you have it).

---

## Where are the log files?

If file logging is enabled, logs are written to a **log directory** on your machine:

- **Windows:** `%LOCALAPPDATA%\Sensehub\logs\`  
  (e.g. `C:\Users\YourName\AppData\Local\Sensehub\logs\`)
- **macOS:** `~/Library/Application Support/Sensehub/logs/`
- **Linux:** `~/.local/share/Sensehub/logs/`

The main log file is usually named with the date, e.g. `sensehub_2025-02-27.log`.  
**To share with support:** open the file, go to the end, copy the last 20–30 lines (or the lines around the time the error happened).

---

## Quick recap

| Problem              | What to do |
|----------------------|------------|
| App won’t start      | Check `getwd()`, run `source("validate_r_app.R")`, fix FAILs, then `source("run_app.R")` or `source("launch_sensehub.R")`. |
| Packages missing     | Run `source("install_packages.R")`; if one fails, install it with `install.packages("name")`. |
| Training fails       | Check Run log in app + log file (last 20 lines). Report both. |
| Export fails         | Ensure run is DONE; check log file; report the error and log snippet. |
| Wrong folder         | Open project in RStudio (File → Open Project) or `setwd("path/to/project")`. |

For step-by-step startup, see **[START_APP.md](START_APP.md)**. For UAT and where to report issues, see **[UAT.md](UAT.md)**.
