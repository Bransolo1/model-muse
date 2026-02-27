# UX audit: every feature, flow & critical errors

End-to-end audit of **React frontend** and **Shiny app** (wizard, dropdowns, interactions). Critical errors are called out and fixed (React) or listed for fix in the repo (Shiny).

---

## Part 1: React frontend

### 1.1 Navigation

| Feature | Location | Status / fix |
|--------|----------|--------------|
| **Skip link** | Index.tsx | ✅ Present; visible on focus; targets `#main`. |
| **Navbar logo** | Navbar.tsx | ✅ Fixed: added `aria-label="Sensehub AutoM/L home"` for screen readers. |
| **Nav link (Home)** | NavLink.tsx | ✅ Active state by pathname; keyboard focusable. |
| **404 “Go back”** | NotFound.tsx | ✅ **Fixed:** Button only shown when `history.length > 1`. Prevents useless back when opened in new tab or direct link. "Return to Home" always shown. |
| **404 focus** | NotFound.tsx | ✅ Buttons have `focus:ring-2` for keyboard users. |

### 1.2 Hero & CTAs

| Feature | Location | Status / fix |
|--------|----------|--------------|
| **Get Started / Explore Features** | Index.tsx | ✅ In-page anchors (`#get-started`, `#features`); work without JS; show target in status bar. |
| **Reduced motion** | Index.tsx | ✅ Hero uses static `<h1>` when `prefers-reduced-motion: reduce`. |
| **Section IDs** | Index.tsx | ✅ `id="main"`, `id="features"`, `id="get-started"`; `aria-labelledby` on sections. |

### 1.3 Quick Start (code blocks)

| Feature | Location | Status / fix |
|--------|----------|--------------|
| **Copy code** | Index.tsx | ✅ **Fixed:** Each code block has a **Copy** button (CopyCodeButton) with “Copied!” feedback and `aria-label`. |
| **Region label** | Index.tsx | ✅ Wrapper has `role="region"` and `aria-label="Quick Start code blocks"`. |
| **RStudio instructions** | Index.tsx | ✅ Short line: “open run_app.R … Full instructions in RUN_FROM_RSTUDIO.md”. |

### 1.4 Error boundary

| Feature | Location | Status / fix |
|--------|----------|--------------|
| **Try again / Go home** | ErrorBoundary.tsx | ✅ **Fixed:** “Try again” has `autoFocus` so keyboard users land on recovery; both controls have focus rings. |

### 1.5 Other React elements

| Feature | Location | Notes |
|--------|----------|--------|
| Feature cards | FeatureCard.tsx | Presentational; no interaction. |
| Step cards | StepCard.tsx | Presentational. |
| Pipeline diagram | PipelineDiagram.tsx | Presentational. |
| Testimonials | Testimonials.tsx | Presentational. |
| File tree | FileTree.tsx | Presentational. |
| Model catalogue | Index.tsx | List with icons; `key={m.name}`. |
| Stats (4 steps, 9+ models…) | Index.tsx | `key={label}`; no interaction. |

### 1.6 React critical errors addressed

- **404 “Go back” with no history** → Only show button when `history.length > 1`.
- **No copy for code** → Copy button per block with feedback.
- **Error boundary focus** → `autoFocus` on “Try again” + focus rings.
- **Logo link a11y** → `aria-label` on navbar logo link.
- **Quick Start discoverability** → Explicit mention of `run_app.R` and RUN_FROM_RSTUDIO.md.

---

## Part 2: Shiny app (wizard, dropdowns, flows)

*The Shiny app lives in `shiny-app/` in the full repo. These points are for when you edit that codebase.*

### 2.1 User flows

| Flow | Description | Critical issues / recommendations |
|------|-------------|-----------------------------------|
| **Step navigation** | 4 steps: Upload → Configure → Advanced → Run. `wizard_step` radio (hidden), Prev/Next buttons, sidebar stepper. | **Gating:** Server gates steps via `can_access_step()`; JS sends `stepGating` to disable locked steps. Ensure JS and server stay in sync (e.g. same step order). |
| **Upload** | File input + dropzone; dropzone triggers hidden file input. | **Critical:** In `drop` handler, `$(this).closest('.card-body').find('input[type="file"]')[0]` can be `undefined` if DOM structure changes. Add null check and fallback to normal file input. |
| **Configure** | Target/predictors/problem type (likely selectInput / pickerInput). | Ensure all dropdowns have a safe default or “Choose…” and that server uses `req()` so no step advance with missing choices. |
| **Advanced** | Tuning, CV, imbalance, etc. | Same: defaults and `req()` where needed. |
| **Run & Results** | Training trigger, then results. | Rate limiter and async; show clear “Training…” state and errors. |

### 2.2 Dropdowns & form controls

| Control | ui.R / modules | Recommendations |
|---------|----------------|------------------|
| **selectInput / selectize** | Styled in CSS. | Ensure option lists are not empty when step is visible; if populated from reactive data, use `req()` before rendering. |
| **pickerInput (bootstrap-select)** | Styled. | Same; handle “no choices” (e.g. no predictors yet) with disabled control or message. |
| **radioButtons (wizard_step)** | Hidden; driven by sidebar + JS. | Sidebar must reflect server state; avoid double-click on Next/Prev (disable button briefly if needed). |
| **fileInput (restore_session)** | Session restore. | Accept only `.rds`; server already validates structure. Show clear error if file invalid. |
| **Sliders** | Styled (irs--shiny). | Ensure min/max and default are valid. |

### 2.3 Shiny critical errors to fix in repo

1. **Dropzone → fileInput (ui.R JS)**  
   In the `drop` handler, `fileInput` may be `undefined`. Add:
   ```js
   var fileInput = $(this).closest('.card-body').find('input[type="file"]')[0];
   if (!fileInput) return;
   ```
   before using `fileInput.files` and triggering change.

2. **Confirm dialog (reset / cancel)**  
   Custom modal uses `Shiny.setInputValue(msg.inputId, Math.random())`. Ensure `msg.inputId` and overlay removal don’t run if the modal was already closed (double-click).

3. **Keyboard shortcut “R” (reset)**  
   Uses `confirm()`. Consider matching server-side reset confirmation (e.g. same modal as “Reset all” button) for consistency.

4. **Tour**  
   Uses `localStorage.getItem('sensehub_tour_v2')`. Provide a way to restart the tour (e.g. “Help” or “?” with “Show tour again”) for returning users.

5. **Step gating**  
   If a user opens the app with a bookmarked URL or restored session, ensure `wizard_step` and sidebar both reflect the same step and that locked steps are not clickable (JS + server).

6. **Session restore**  
   Server validates required keys; show a clear, user-facing message when the file is invalid (not just in logs).

### 2.4 Shiny UX recommendations (non-blocking)

- **Labels:** Ensure every `selectInput`/`pickerInput` has a visible label or `aria-label`.
- **Loading:** Use existing skeleton styles during training; avoid blank panels.
- **Errors:** Surface validation/training errors in the UI (toast or inline), not only in console.
- **Next/Prev:** Optional: briefly disable after click to prevent double submission.

---

## Summary

- **React:** All listed UX features and critical errors have been addressed (skip link, nav a11y, 404 back, copy code, error boundary focus, Quick Start copy + RStudio reference).
- **Shiny:** Critical fixes are documented above (dropzone null check, confirm/tour/step gating, session restore messaging); apply them in the `shiny-app/` codebase in the repo.

For a single “run from RStudio” experience, colleagues use **run_app.R** and **RUN_FROM_RSTUDIO.md** as in the README.
