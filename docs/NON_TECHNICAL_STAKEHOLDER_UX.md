# UX for non-technical stakeholders

**Audience:** Business users, domain experts, and managers who will use or evaluate Sensehub AutoM/L but are not data scientists.

---

## Does the current flow make sense?

**Short answer:** The **wizard order** (Upload → Configure → Advanced → Run) is correct and matches how people think: “I have data → I say what I want to predict → (optional settings) → I get results.” Some **labels and copy** use data-science jargon that can confuse or intimidate non-technical users.

---

## What works well for non-technical users

| Element | Why it works |
|--------|----------------|
| **4-step wizard** | Clear sequence: add data → set goal → (optional tweaks) → see results. |
| **“No expertise required”** | Reduces fear that they need a stats background. |
| **“Guided” / “wizard”** | Signals that the app will lead them, not the other way around. |
| **“Ranked leaderboard of models”** | Outcome-focused: they get a ranked list, not “tuning output.” |
| **“Auto-detected for you”** (Configure) | Reassures that they don’t have to know problem type up front. |
| **“Optional” for Advanced** | Makes it clear they can skip tuning and use defaults. |
| **“One-Click Export”** | Concrete outcome: they can take something away (report, bundle). |

---

## Where it can confuse non-technical stakeholders

| Current copy / concept | Issue | Plain-language alternative |
|------------------------|--------|-----------------------------|
| **“Powered by tidymodels”** | Meaningless to non-technical users. | Omit on stakeholder-facing surfaces, or use: “Built on proven open-source ML tools.” |
| **“Stratified splits, class-aware metrics”** | Jargon. | “Splits data fairly and picks the right metrics for your problem.” |
| **“Stacked Ensembles”** | Jargon. | “Combines top models automatically when it helps.” |
| **“ROC curves, calibration plots, feature importance”** | Jargon. | “Charts and metrics that explain how good the model is and what drove it.” |
| **“CV folds” / “Tuning budget”** | Jargon. | “How much time to spend searching for the best setup” or “Quality vs. speed.” |
| **“Configure” (step name)** | Vague. | “Choose what to predict” or “Set your prediction goal.” |
| **“Advanced” (step name)** | Can sound mandatory. | “Optional settings” or “Fine-tune (optional).” |
| **“Target” / “predictors”** (in app) | DS terms. | “What to predict” / “Which columns to use to predict it.” |
| **Quick Start = R code only** | Assumes they run R. | Add a short “What you’ll see” flow (steps in the app) for evaluators who never run R. |

---

## Recommended flow narrative (for copy and training)

Use this story when you write copy or explain the product to non-technical stakeholders:

1. **Upload** — “Add your spreadsheet (CSV). The app checks it and shows a quick summary.”
2. **Choose what to predict** — “Pick the column you want to predict and which columns to use. The app can suggest these for you.”
3. **Optional settings** — “You can leave these as-is. Change them only if someone asks you to (e.g. ‘use more tuning’).”
4. **Run & results** — “Run the training. You get a ranked list of models, simple performance numbers, and the option to export everything for your team or for compliance.”

That keeps the same **data science flow** (upload → configure → optional tuning → run) but in **outcome-focused, non-technical language**.

---

## Concrete changes applied (landing page)

- **Feature and step copy** on the landing page has been adjusted so that:
  - Jargon is reduced or paired with a short plain-language explanation.
  - Step names and descriptions align with the “Upload → Set goal → Optional settings → Results” story.
- **“What you’ll see”** (or similar) can be added so stakeholders who only read the docs understand the in-app flow without running R.

---

## For the Shiny app (when you edit that codebase)

- Use **tooltips or help text** next to “Target”, “Predictors”, “Problem type”, “CV folds”, “Tuning budget” (e.g. “Column you want to predict”, “Time spent searching for best settings”).
- Consider **two modes** or labels: “Simple” (minimal options, plain language) vs “Advanced” (current terms) for power users.
- **Results screen:** Lead with “Best model” and “Ranking” and simple metrics; put “ROC”, “calibration”, “SHAP” in expandable or “Details” sections so non-technical users aren’t overwhelmed.

---

## Summary

- **Flow:** The current UX flow is sound for non-technical stakeholders: it follows a clear, outcome-oriented sequence (data in → goal set → optional settings → results).
- **Gap:** Jargon in labels and feature descriptions can make it feel more technical than it is. The recommendations above keep the same data-science logic but make the experience understandable and safe for non-technical audiences.
