# How to start the app (step-by-step)

You need **R** and **RStudio** installed. If you don’t have them, install R from [r-project.org](https://www.r-project.org/) then RStudio from [posit.co/download](https://posit.co/download/rstudio-desktop/).

The app runs only on your machine; your data is not sent to any external server.

---

## Step 1: Open the project in RStudio

1. Open **RStudio**.
2. Go to **File → Open Project…** (or **File → Open Folder…** if you don’t see “Open Project”).
3. Go to the folder that contains **`run_app.R`** and the **`shiny-app`** folder.
4. If you see a file **`SensehubAutoML.Rproj`**, open that (double‑click or “Open Project”).  
   Otherwise, open the folder that contains it.

You should see the project name in the top-right of RStudio and files like `run_app.R` in the **Files** pane (usually right side or in a tab).

---

## Step 2: Install packages (first time only)

The app needs a set of R packages. You only do this **once** per machine (or after an R upgrade).

1. In RStudio, find the **Console** — the pane at the **bottom** where you can type.
2. Click in the Console so your cursor is there.
3. Type (or copy and paste) exactly:
   ```r
   source("install_packages.R")
   ```
4. Press **Enter**.

Wait until it finishes (it can take a few minutes). When it’s done you’ll see something like “Done.” and the `>` prompt again. If you get errors, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or [RUN_FROM_RSTUDIO.md](RUN_FROM_RSTUDIO.md).

---

## Step 3: Start the app

1. In the **Console** (same bottom pane), type (recommended — validates first, then runs):
   ```r
   source("launch_sensehub.R")
   ```
   Or to skip validation: `source("run_app.R")`
2. Press **Enter**.

**What happens:**

- In the Console you’ll see lines like:
  - `Sensehub launcher: validating...`
  - `Validation passed. Starting app...`
  - `Launching Sensehub AutoM/L (Shiny app)...`
  - `Listening on http://127.0.0.1:3840`
- A browser window (or the RStudio Viewer) will open with the app. The address will be something like **http://127.0.0.1:3840**.

That’s it — the app is running. Use it in the browser (Upload data → Configure → Advanced → Run, etc.).

---

## Step 4: Stop the app

- In the **Console** in RStudio, press **Ctrl+C** (Windows/Linux) or **Cmd+.** (Mac), or click the **Stop** icon (red square) in the Console toolbar.  
- The browser tab will stop working; you can close it.  
- To run again, repeat **Step 3** (`source("run_app.R")`).

---

## If the app doesn’t open

- **Nothing in the Console when you run `source("run_app.R")`?**  
  R might not be in the right folder. In the Console, run:
  ```r
  setwd("C:/path/to/your/project/folder")
  ```
  (Replace with the real path to the folder that contains `run_app.R`.) Then run `source("run_app.R")` again.

- **“shiny-app not found” or “server.R not found”?**  
  You’re not in the project folder, or the project is incomplete. Open the **full** project (the folder that has both `run_app.R` and a folder called `shiny-app`).

- **Packages missing?**  
  Run Step 2 again (`source("install_packages.R")`). If it still fails, see [RUN_FROM_RSTUDIO.md](RUN_FROM_RSTUDIO.md) for the full package list.

---

**Quick recap:** Open project → `source("install_packages.R")` once → `source("launch_sensehub.R")` to start. Stop with Ctrl+C (or Stop) in the Console. If something breaks, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
