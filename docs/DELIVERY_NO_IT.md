# Delivering the app without involving IT

**Context:** You work in a large corporation with strict IT. You want to get Sensehub AutoM/L to a functional level through RStudio **without** requesting new servers, hosting, or formal approval. This doc describes the delivery path that avoids IT tickets.

---

## Core idea: no new infrastructure

- **No central server** — The app runs on each user’s machine when they run it from RStudio. No Shiny Server, RStudio Connect, or VM to approve.
- **No Docker** — Docker often triggers security review and approved images. For “sneaking to functional,” skip it. You can add it later if IT gets involved.
- **No Node for colleagues** — The main app is the Shiny wizard. Colleagues only need R and RStudio; they never need to run the React landing page unless you choose to share it another way.
- **What you need** — R (4.2+) and RStudio, which many analytics teams already have approved as “R for analysis.” The app is “an R project you run like any other script.”

---

## How colleagues run the app

1. **Get the project** — They receive the project folder (see “How to deliver” below).
2. **Open in RStudio** — File → Open Project → select the folder (or double‑click the `SensehubAutoML.Rproj` file).
3. **Install packages once** — They run the `install.packages(...)` block from [RUN_FROM_RSTUDIO.md](../RUN_FROM_RSTUDIO.md) in the R console. All from CRAN; no internal repos required unless your company mandates one.
4. **Run one script** — Open `run_app.R` and **Source** it (e.g. Ctrl+Shift+S). The Shiny app opens in their browser (localhost). No URL to register with IT; it’s a local process.

So from IT’s perspective: people are “running an R script in RStudio.” No new software stack, no new hosting, no firewall rules for a new app URL.

---

## How to deliver the project to colleagues

Pick one that fits your environment:

| Method | When to use |
|--------|-------------|
| **ZIP of the repo** | Email or shared drive. They unzip, open the folder in RStudio. Easiest; no git. |
| **Shared drive / network folder** | Copy the full project folder to a path colleagues can read. They open that folder as the RStudio project. |
| **Git via RStudio (if git is allowed)** | File → New Project → Version Control → Git, paste repo URL. Good for updates. |
| **Internal Git (GitLab, Azure Repos, etc.)** | Same as above; use your corporate git URL. No public GitHub needed. |

**Important:** They must get the **full** project, including the **`shiny-app`** folder with `server.R`, `ui.R`, `global.R`, and everything under `shiny-app/R/`. If any of that is missing, `run_app.R` will stop with a clear message.

---

## Pre-handoff checklist

Before you give the project to a colleague, confirm:

- [ ] The folder you’re sharing is the **full project** (contains `run_app.R` at the top level and a **`shiny-app`** folder with `server.R`, `ui.R`, `global.R`).
- [ ] You’ve told them to **open this folder in RStudio** (File → Open Project), not a subfolder.
- [ ] They know to run the **install.packages(...)** block from [RUN_FROM_RSTUDIO.md](../RUN_FROM_RSTUDIO.md) **once** before the first run.
- [ ] They know to **Source `run_app.R`** (or run `source("run_app.R")`) to start the app.

See also **[CHECKLIST.md](../CHECKLIST.md)** for a short printable checklist.

---

## What to say if someone asks

- **“What is this?”** — “An R Shiny app for automated machine learning. We run it from RStudio like any other R project.”
- **“Where is it hosted?”** — “It’s not hosted. Each user runs it locally from RStudio; it opens in their browser on their machine.”
- **“Do we need to install anything?”** — “R and RStudio, which we already use for analytics. Plus some CRAN packages the first time; the list is in the project.”
- **“Is this approved?”** — You’re using existing, approved tools (R, RStudio, CRAN). If your policy requires approval for *any* new code, that’s a separate question; this doc only avoids *new infrastructure* (servers, Docker, etc.).

---

## React landing page (optional)

- Colleagues **don’t need** the React app to use the AutoML wizard. The wizard is the Shiny app they run from RStudio.
- If you want the landing page visible without involving IT:
  - **Option A:** Don’t host it. The “front door” is README + RUN_FROM_RSTUDIO.md in the project.
  - **Option B:** Build the React app locally (`npm run build`), commit the `dist/` output to a repo, and use **GitHub Pages** (or similar) to serve the static site. That’s “a static website from a repo,” which some environments allow without an IT ticket. Only do this if your policy allows.

---

## When to involve IT later

Consider involving IT when you need:

- A **shared URL** so many people use one deployed instance (Shiny Server, RStudio Connect, etc.).
- **Docker** for consistent, locked-down environments.
- **Central auth** (SSO, LDAP) or audit logging.
- **Approved base images / repos** for R or packages.

Until then, the “RStudio + run one script” path keeps the app functional without new infrastructure or tickets.
