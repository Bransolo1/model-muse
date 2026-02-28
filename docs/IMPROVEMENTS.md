# Improvement Opportunities

Suggestions to make Sensehub AutoM/L feel more premium while staying on-brand and avoiding impact on stability or load time.

---

## Low‑Effort, Low‑Risk Improvements

| Area | Suggestion | Impact | Stability |
|------|------------|--------|-----------|
| **Spacing** | Increase `padding` on `.card-body` from 20px to 24px for key sections | More breathing room | None |
| **Section headers** | Add subtle `letter-spacing: -0.02em` to section titles | Slightly more refined typography | None |
| **Empty states** | Use consistent `.sh-empty-state` class with icon + muted text | Consistent placeholder UX | None |
| **Progress bar** | Ensure `shiny-plot-output` and progress bars use primary gradient | Brand consistency | None |

---

## Medium‑Effort Improvements (No New Dependencies)

| Area | Suggestion | Impact | Stability |
|------|------------|--------|-----------|
| **Plot loading** | Add `shiny::plotOutput(..., fill = TRUE)` for responsive layout | Better responsiveness | None |
| **Table zebra** | Use `--sh-border-subtle` for alternating row background instead of gray | More on-brand | None |
| **Focus rings** | Ensure all interactive elements use `--sh-primary-glow` for focus | Accessibility + brand | None |
| **Download buttons** | Add subtle icon animation on hover (e.g. `transform: translateY(-1px)`) | Micro-interaction | None |

---

## Future Considerations (Optional)

| Area | Suggestion | Notes |
|------|------------|-------|
| **Skeleton loaders** | Extend `.sh-skeleton` for plot placeholders | Already have shimmer skeleton; extend for plots |
| **Dark mode** | Add `prefers-color-scheme: dark` variant | CSS-only; no new JS |
| **High‑contrast** | Add `@media (prefers-contrast: high)` overrides | Accessibility |
| **Print styles** | `@media print` to hide sidebar, simplify charts | Export-friendly |

---

## Avoid (Impact on Stability or Load)

- **Heavy JS libraries** (e.g. full animation libs): Use CSS animations only.
- **External fonts beyond Inter**: Already loaded; avoid extra requests.
- **Complex plot rendering**: Keep ggplot2; avoid switching to heavy JS chart libs.
- **Large images or assets**: Keep icons inline or SVG.

---

## Brand Reference

- **Primary**: `#ff8c00` / `#ff6600` (orange gradient)
- **Background**: `#f8f6f3`, surface: `#ffffff`
- **Text**: `#1a1a1a`, `#555`, `#999`
- **Sidebar**: `#0f1117`
- **Success / Warning / Danger**: `#10b981`, `#f59e0b`, `#ef4444`
