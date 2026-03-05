# Stage 4 (Run & Results) — UX Audit & Product Backlog

## Competitor Benchmark

| Feature | Sensehub | DataRobot | H2O | MLJAR | PyCaret |
|---------|----------|-----------|-----|-------|---------|
| Model leaderboard | ✅ | ✅ Rich (badges, deployment readiness) | ✅ | ✅ (auto-report) | ✅ |
| SHAP explainability | ✅ On-demand | ✅ Row-level, top-5 features | ✅ Auto | ✅ Auto | ✅ Auto |
| Feature importance | ⚠️ Sometimes unavailable | ✅ Permutation + SHAP + tree-based | ✅ | ✅ Golden features | ✅ |
| Drift detection | ✅ KS/Chi-sq | ✅ Production monitoring | ✅ MLOps dashboard | ❌ | ❌ |
| Fairness/bias detection | ❌ | ✅ | ✅ | ✅ (v1.0+) | ❌ |
| Automated reporting | ❌ | ✅ PDF/HTML | ✅ | ✅ HTML reports | ✅ |
| Model deployment | ❌ | ✅ One-click | ✅ MLOps | ❌ | ❌ |
| Real-time training progress | ⚠️ Timer only | ✅ Per-model progress | ✅ | ✅ | ✅ |
| Hyperparameter visualization | ❌ | ✅ | ✅ | ✅ | ✅ |
| Model comparison (multi-axis) | ✅ Radar | ✅ | ✅ | ✅ | ✅ |
| Confusion matrix | ✅ | ✅ Interactive | ✅ | ✅ | ✅ |
| Calibration/reliability | ✅ | ✅ | ✅ | ❌ | ✅ |
| Prediction intervals | ✅ Conformal | ✅ | ❌ | ❌ | ❌ |
| Session save/restore | ✅ | ✅ | ✅ | ❌ | ❌ |
| Ensemble stacking | ✅ | ✅ Blender | ✅ | ✅ | ✅ |
| Natural language summary | ✅ "Plain English" | ✅ AI Insights | ❌ | ❌ | ❌ |
| PDP/ICE plots | ✅ | ✅ | ✅ | ✅ | ✅ |
| Export bundle | ✅ ZIP | ✅ | ✅ | ✅ | ✅ |

---

## Jira-Style Product Backlog

### Epic 1: Training Experience

| ID | Title | Priority | Type | Status | Description |
|----|-------|----------|------|--------|-------------|
| TRN-1 | Real-time per-model training progress | P1 | Enhancement | To Do | Replace indeterminate progress bar with per-model status updates (e.g., "Training model 3/8: XGBoost..."). DataRobot and MLJAR show model-by-model progress. |
| TRN-2 | Granular training log with model timings | P2 | Enhancement | To Do | Append individual model training times to the run log as each model completes (e.g., "[18:25:12] ✓ ranger trained in 8.3s"). |
| TRN-3 | Cancel training (kill background job) | P2 | Enhancement | To Do | Currently "Stop waiting" only ignores results; add actual cancellation of the future worker. |
| TRN-4 | Re-run with different settings | P3 | Enhancement | To Do | After training completes, allow quick re-run with modified config without resetting the whole wizard. |
| TRN-5 | Hide "Ready to train" message after completion | P3 | Bug | To Do | The "Ready to train" callout persists after training finishes; should be hidden when results are shown. |

### Epic 2: Leaderboard & Model Cards

| ID | Title | Priority | Type | Status | Description |
|----|-------|----------|------|--------|-------------|
| LDR-1 | Model type icons/badges in leaderboard | P2 | Enhancement | To Do | Add algorithm-type badges (e.g., 🌲 tree, ⚡ boosted, 🔮 SVM) next to model names like DataRobot's leaderboard. |
| LDR-2 | Column tooltips on leaderboard headers | P2 | Enhancement | To Do | Add "(?)" tooltips explaining METRIC (MEAN), METRIC (SE), RUNTIME for non-expert users. |
| LDR-3 | Hide empty NOTES column when unused | P3 | Enhancement | To Do | Leaderboard shows blank NOTES column; hide it if no models have notes. |
| LDR-4 | Clickable model cards → detail view | P2 | Enhancement | To Do | Clicking a model card should show model-specific diagnostics (hyperparams, per-class metrics). Competitor standard. |
| LDR-5 | Hyperparameter display per model | P1 | Enhancement | To Do | Show best hyperparameters for each model. All competitors (H2O, DataRobot, MLJAR) surface this. Critical for transparency. |
| LDR-6 | "Recommended for deployment" badge | P3 | Enhancement | To Do | DataRobot marks top models with deployment readiness badges. Add "★ Best pick" badge to recommended model. |
| LDR-7 | Qualitative metric labels | P2 | Enhancement | To Do | Add "Excellent / Good / Fair / Poor" labels next to metric values so non-experts can interpret results. |

### Epic 3: Explainability

| ID | Title | Priority | Type | Status | Description |
|----|-------|----------|------|--------|-------------|
| XAI-1 | Fix feature importance availability | P1 | Bug | To Do | "Feature importance data not available for this run" — investigate and fix `vip` integration so importance is reliably computed. |
| XAI-2 | Auto-compute SHAP for top observation | P3 | Enhancement | To Do | Show SHAP for observation #1 by default after training completes, instead of requiring manual button click. |
| XAI-3 | SHAP summary plot (beeswarm) | P1 | Enhancement | To Do | Add global SHAP summary (beeswarm/violin) showing feature importance across all observations. DataRobot and H2O both offer this. |
| XAI-4 | Feature interaction effects | P3 | Enhancement | To Do | Add 2D PDP / interaction plots for top feature pairs. Available in DataRobot and MLJAR. |
| XAI-5 | Natural language SHAP explanation | P2 | Enhancement | To Do | Generate a sentence like "This prediction was most influenced by Petal.Width (↑ 0.32) and Sepal.Length (↓ 0.15)." |

### Epic 4: Diagnostics & Charts

| ID | Title | Priority | Type | Status | Description |
|----|-------|----------|------|--------|-------------|
| DIA-1 | Show AUC values on ROC curves | P2 | Enhancement | To Do | Display "AUC = 0.998" annotation on each ROC facet. Standard practice. |
| DIA-2 | Interactive confusion matrix tooltips | P3 | Enhancement | To Do | Hover on cells to see count + percentage. |
| DIA-3 | Add diagonal reference to calibration curve | P2 | Enhancement | To Do | Show the perfect-calibration diagonal line on the reliability curve for comparison. |
| DIA-4 | Fix Brier score icon (⚠️ → ℹ️) | P3 | Bug | To Do | Warning icon on a good Brier score (0.059) is misleading; use info icon instead. |
| DIA-5 | Per-class precision/recall/F1 table | P2 | Enhancement | To Do | Add a per-class metrics table alongside the confusion matrix. DataRobot shows this prominently. |
| DIA-6 | Click-to-expand plots | P3 | Enhancement | To Do | Allow users to click any chart to view it in a full-screen modal for closer inspection. |

### Epic 5: Drift & Monitoring

| ID | Title | Priority | Type | Status | Description |
|----|-------|----------|------|--------|-------------|
| DFT-1 | Distribution comparison plots per feature | P2 | Enhancement | To Do | Show train vs test distribution overlays for each feature (histogram or density). H2O MLOps does this. |
| DFT-2 | Drift severity levels | P3 | Enhancement | To Do | Replace binary Stable/Drifted with Low/Medium/High severity based on p-value thresholds. |
| DFT-3 | Hide pagination when all data fits on one page | P3 | Enhancement | To Do | Drift table shows Previous/1/Next even with only 4 rows. |

### Epic 6: Predictions & Confidence

| ID | Title | Priority | Type | Status | Description |
|----|-------|----------|------|--------|-------------|
| PRD-1 | Add row count badge to predictions table | P3 | Enhancement | To Do | Show "Showing first 500 of N rows" notice above the table. |
| PRD-2 | Hide technical columns by default | P3 | Enhancement | To Do | `.ROW` and `.CONFIG` columns are internal; hide or collapse them by default. |
| PRD-3 | Confidence bands on calibration curve | P3 | Enhancement | To Do | Add bootstrap confidence intervals around the calibration line. |
| PRD-4 | Prediction distribution per class (multi-panel) | P2 | Enhancement | To Do | Show separate histograms per target class, not just the first class's probability. |

### Epic 7: Export & Reporting

| ID | Title | Priority | Type | Status | Description |
|----|-------|----------|------|--------|-------------|
| EXP-1 | Auto-generated HTML/PDF report | P1 | Enhancement | To Do | Generate a downloadable summary report with all key charts and metrics. MLJAR auto-generates these. This is a major competitor gap. |
| EXP-2 | SVG/PDF chart export options | P3 | Enhancement | To Do | Currently PNG only; add vector format options for publication-quality charts. |
| EXP-3 | Download progress indicators | P3 | Enhancement | To Do | Show brief confirmation toast after each successful download. |
| EXP-4 | Export reproducible R script | P2 | Enhancement | To Do | Generate a standalone R script that reproduces the entire pipeline outside of the Shiny app. |

### Epic 8: Fairness & Governance (Competitor Gap)

| ID | Title | Priority | Type | Status | Description |
|----|-------|----------|------|--------|-------------|
| FAR-1 | Fairness metrics dashboard | P1 | Enhancement | To Do | Add demographic parity, equalized odds metrics when user specifies a sensitive attribute. MLJAR, DataRobot, and H2O all offer this. Major gap. |
| FAR-2 | Bias detection warnings | P2 | Enhancement | To Do | Automatically flag potential bias when sensitive columns (gender, race, age) are detected in predictors. |
| FAR-3 | Model card (governance) export | P2 | Enhancement | To Do | Generate a model card document (as per Google's Model Cards paper) with intended use, metrics, limitations, ethical considerations. |

### Epic 9: UX Polish & Accessibility

| ID | Title | Priority | Type | Status | Description |
|----|-------|----------|------|--------|-------------|
| UXP-1 | Tooltips on all metric abbreviations | P2 | Enhancement | To Do | Add "(?)" hover tooltips for SE, ROC AUC, Brier score, -log10(p-value), CV folds, etc. |
| UXP-2 | Ensemble stat card clarity | P3 | Enhancement | To Do | "ENSEMBLE" card shows "—" with no context; show "✓ Used" or "✗ Skipped" with tooltip explaining why. |
| UXP-3 | Radar chart axis labels and scale | P2 | Enhancement | To Do | Add scale markers (0.0, 0.5, 1.0) and tooltips explaining how each dimension is computed. |
| UXP-4 | CV Folds chart: avoid misleading truncated axis | P2 | Enhancement | To Do | X-axis starts at 0.98 instead of 0.0; add note or show full range to avoid exaggerating differences. |
| UXP-5 | Keyboard navigation for result tabs | P3 | Enhancement | To Do | Allow Tab/arrow key navigation between result tabs for accessibility. |
| UXP-6 | Dark mode support | P3 | Enhancement | To Do | Add toggle for dark theme using CSS custom properties already in place. |
| UXP-7 | Loading skeletons for result tabs | P3 | Enhancement | To Do | Show skeleton loaders when switching between tabs that require rendering time. |

---

## Priority Summary

| Priority | Count | Focus |
|----------|-------|-------|
| **P1 — Must Have** | 5 | Feature importance fix, hyperparams, training progress, auto-report, fairness |
| **P2 — Should Have** | 16 | Tooltips, model badges, SHAP summary, AUC labels, distribution plots |
| **P3 — Nice to Have** | 19 | Polish items, dark mode, SVG export, click-to-expand |

## Top 5 Recommendations (Highest Impact)

1. **Auto-generated HTML report** (EXP-1) — Every major competitor does this. Users need shareable artifacts.
2. **Real-time per-model training progress** (TRN-1) — The indeterminate progress bar provides no useful information.
3. **Hyperparameter display** (LDR-5) — Users cannot see what the best parameters are. This is table stakes for ML tools.
4. **Fix feature importance** (XAI-1) — The "not available" message undermines trust in the platform.
5. **Fairness metrics** (FAR-1) — Growing regulatory requirement. MLJAR already ships this. Major differentiation opportunity.
