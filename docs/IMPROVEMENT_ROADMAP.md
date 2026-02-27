# How the application can be improved

Prioritised, actionable improvements for the **React landing page**, **Shiny run flow**, **docs**, and **overall product**. Pick by impact and effort.

---

## 1. Landing page (React)

### High impact, low effort

| Improvement | Why | What to do |
|-------------|-----|------------|
| **Dark mode** | `next-themes` is installed and `index.css` has `.dark` tokens, but there’s no toggle. Many users expect it. | Wrap the app in `ThemeProvider` from `next-themes`, add a theme toggle in the Navbar (icon + “Dark/Light”), and ensure all key components use semantic tokens (they already do). |
| **SEO and share** | If the landing is ever deployed, search and link previews matter. | In `index.html`: add `<meta name="description" content="...">`, optional Open Graph tags (`og:title`, `og:description`, `og:image`). |
| **Favicon** | Currently `placeholder.svg`. | Replace with a real favicon (e.g. Sensehub/AutoML mark) and reference it in `index.html`. |

### Medium impact

| Improvement | Why | What to do |
|-------------|-----|------------|
| **Fewer toast systems** | Both Radix `Toaster` and `Sonner` are rendered; the app doesn’t use either for user actions. | Use one system (e.g. Sonner only) and remove the other to avoid confusion and bundle size. |
| **React Query** | `QueryClientProvider` is present but there are no `useQuery`/`useMutation` calls. | Either add a real need (e.g. future “fetch release notes” or API) or remove React Query until needed. |
| **Lazy load below-fold** | PipelineDiagram, Testimonials, FileTree only matter after scroll. | Use `React.lazy()` + `Suspense` for those sections (or a single “BelowFold” chunk) to shrink initial JS and improve LCP. |
| **More tests for Index** | Only App and NotFound are well covered. | Add tests for Index: Quick Start copy button copies correct R code, key sections (e.g. “Get Started”, “Quick Start”) are present, optional a11y (heading order). |

### Nice to have

| Improvement | Why | What to do |
|-------------|-----|------------|
| **Heading hierarchy** | One quick pass to ensure a single `h1` and logical `h2`/`h3` order on the page. | Audit Index.tsx; fix any duplicate or skipped levels. |
| **Focus trap in modals** | If you add dialogs later (e.g. “Before you run”). | Use Radix Dialog (already in deps); it handles focus. |
| **Print styles** | Some users print the Quick Start. | Add a small `@media print` block: hide nav/orb, simplify background, ensure code blocks don’t break. |

---

## 2. Shiny app and run flow

### When you have the full Shiny codebase

| Improvement | Why | What to do |
|-------------|-----|------------|
| **Dropzone null check** | UX_AUDIT: file input selector in drop handler can be `undefined` if DOM structure changes. | In the drop handler, check the found element and fallback to normal file input before using it. |
| **Step gating** | UI and server must agree on which steps are accessible. | Keep step order and `can_access_step()` in sync; document in a short “Wizard steps” comment in server.R or a small R doc. |
| **First-run hint** | New users may run `source("run_app.R")` before installing packages. | run_app.R already checks `requireNamespace("shiny")` and errors; consider a friendlier message: “Install packages first — see RUN_FROM_RSTUDIO.md.” |

### Documentation

| Improvement | Why | What to do |
|-------------|-----|------------|
| **Minimum R version** | Colleagues may be on old R. | In README and RUN_FROM_RSTUDIO.md state “R 4.2+ (or 4.x recommended).” |
| **Pre-handoff checklist** | Reduces “missing shiny-app” or wrong folder. | Add a short **CHECKLIST.md** or section in DELIVERY_NO_IT: “Full folder including shiny-app?”, “run_app.R at project root?”, “Package list run once?”. |

---

## 3. Repo and DX

| Improvement | Why | What to do |
|-------------|-----|------------|
| **CI for React** | Catch lint and test failures before merge. | In `.github/workflows/`: add a job that runs `npm ci && npm run lint && npm run test` (and optionally `npm run build`) on PR/push. |
| **Version or changelog** | Easier to say “we’re on 1.2” when talking to stakeholders. | Add a `CHANGELOG.md` or a version line in README; tag releases if you use GitHub releases. |
| **Contributing** | Helps new devs. | Add CONTRIBUTING.md: how to run React vs Shiny, where to find docs, code style (e.g. existing ESLint), and that the Shiny app is the main product. |

---

## 4. Product and UX (beyond code)

| Improvement | Why | What to do |
|-------------|-----|------------|
| **Sample dataset** | First-run experience: “Try with sample data” reduces friction. | If the Shiny app doesn’t already, add a “Load sample” that drops a small CSV and pre-fills target/predictors (or document where the sample lives). |
| **One-page “cheat sheet”** | Non-technical stakeholders forget the four steps. | Add a single-page PDF or page in the app: “1. Upload 2. Choose target 3. Optional settings 4. Run & export” with one line each; link from README and landing. |
| **Error messages in plain language** | e.g. “Missing server.R” is already good; “Package X not found” can point to RUN_FROM_RSTUDIO. | Review run_app.R and Shiny server messages; where possible add a short “What to do” (e.g. “Install packages — see RUN_FROM_RSTUDIO.md”). |

---

## Suggested order

1. **Quick wins:** Favicon, meta description, optional removal of one toast system and React Query if unused.  
2. **High value:** Dark mode (if you care about landing polish), first-run/friendlier run_app.R message, minimum R version in docs.  
3. **When touching Shiny:** Dropzone null check, step gating doc, optional pre-handoff checklist.  
4. **Ongoing:** More Index tests, CI for React, CONTRIBUTING.md, then lazy loading and print styles if you need the gains.

If you tell me which area you want to tackle first (e.g. “dark mode” or “run flow docs”), I can outline concrete steps or patches next.
