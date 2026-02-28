import { lazy, Suspense } from "react";
import {
  Zap,
  Brain,
  BarChart3,
  Shield,
  Layers,
  Rocket,
  Sparkles,
  Bot,
  Database,
  LineChart,
} from "lucide-react";
import { motion } from "framer-motion";
import Navbar from "@/components/Navbar";
import HeroOrb from "@/components/HeroOrb";
import FeatureCard from "@/components/FeatureCard";
import StepCard from "@/components/StepCard";
import { Badge } from "@/components/ui/badge";
import CopyCodeButton from "@/components/CopyCodeButton";

const PipelineDiagram = lazy(() => import("@/components/PipelineDiagram"));
const Testimonials = lazy(() => import("@/components/Testimonials"));
const FileTree = lazy(() => import("@/components/FileTree"));

const FEATURES = [
  { icon: Brain, title: "Smart inference", desc: "The app figures out what kind of prediction you need and how to measure it — no stats degree required." },
  { icon: Zap, title: "Runs in the background", desc: "Training doesn’t freeze the screen. You can keep an eye on progress without waiting on a spinner." },
  { icon: Shield, title: "Sensible defaults", desc: "Splits and metrics are chosen to be fair and defensible so you can trust the results out of the box." },
  { icon: Layers, title: "Auto-blended models", desc: "When it helps, the app combines the best models into one — no extra steps for you." },
  { icon: BarChart3, title: "Clear diagnostics", desc: "Charts and metrics that show how good each model is and what’s driving its predictions." },
  { icon: Rocket, title: "One-click export", desc: "Download a single bundle with everything needed to share or reproduce the work later." },
];

const STEPS = [
  { num: "01", title: "Upload", desc: "Drop your spreadsheet (CSV) or try a sample. The app checks it and shows a quick summary." },
  { num: "02", title: "Choose what to predict", desc: "Pick the column you want to predict and which columns to use. The app can suggest these for you." },
  { num: "03", title: "Optional settings", desc: "Leave these as-is, or adjust quality vs. speed and a few advanced knobs if someone asks you to." },
  { num: "04", title: "Run & results", desc: "Run training and get a ranked list of models, simple performance numbers, and one-click export." },
];

const Index = () => {
  const prefersReducedMotion = typeof window !== "undefined" && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  return (
    <div className="relative min-h-screen">
      <a
        href="#main"
        className="sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[100] focus:w-auto focus:h-auto focus:p-4 focus:m-0 focus:overflow-visible focus:[clip:auto] focus:rounded-md focus:bg-primary focus:text-primary-foreground focus:outline-none focus:ring-2 focus:ring-ring"
      >
        Skip to main content
      </a>
      <Navbar />
      <main id="main" className="container py-16 md:py-28" role="main">
        {/* Hero */}
        <section className="relative flex flex-col items-center gap-10 overflow-hidden px-4 py-28 md:py-36 text-center" aria-labelledby="hero-heading">
          <div className="absolute inset-0 bg-glow pointer-events-none" aria-hidden />
          <HeroOrb />
          <Badge variant="secondary" className="mb-1 rounded-full px-3 py-1 text-xs font-medium">Guided · no code required</Badge>
          {prefersReducedMotion ? (
            <h1 id="hero-heading" className="relative font-display text-4xl font-bold tracking-tight text-foreground sm:text-5xl md:text-6xl lg:text-7xl">
              Sensehub <span className="text-gradient-orange">AutoM/L</span>
            </h1>
          ) : (
            <motion.h1
              id="hero-heading"
              initial={{ opacity: 0, y: 24 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, ease: [0.22, 1, 0.36, 1] }}
              className="relative font-display text-4xl font-bold tracking-tight text-foreground sm:text-5xl md:text-6xl lg:text-7xl"
            >
              Sensehub <span className="text-gradient-orange">AutoM/L</span>
            </motion.h1>
          )}
          <p className="relative max-w-2xl text-lg leading-relaxed text-muted-foreground md:text-xl">
            Upload your data, choose what to predict, and get a ranked list of models with clear metrics and one-click export. No expertise required — the app guides you and uses sensible defaults.
          </p>
          <div className="relative flex flex-wrap justify-center gap-4">
            <a
              href="#get-started"
              className="inline-flex h-12 items-center justify-center rounded-full bg-gradient-orange px-8 text-base font-semibold text-primary-foreground shadow-glow transition-all duration-200 hover:-translate-y-0.5 hover:shadow-glow-strong focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
            >
              Get Started
            </a>
            <a
              href="#features"
              className="inline-flex h-12 items-center justify-center rounded-full border-2 border-border/60 bg-card/80 px-8 text-base font-semibold text-muted-foreground backdrop-blur-sm transition-all duration-200 hover:border-primary/50 hover:text-foreground hover:shadow-card focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
            >
              Explore Features
            </a>
          </div>
          <div className="relative flex flex-wrap justify-center gap-6 pt-12 sm:gap-10">
            {[["4", "Simple steps"], ["9+", "Model types"], ["3", "Speed options"], ["∞", "Your datasets"]].map(
              ([value, label]) => (
                <div key={label} className="rounded-2xl border border-border/50 bg-card/60 px-6 py-4 text-center backdrop-blur-sm">
                  <div className="font-display text-2xl font-bold text-foreground md:text-3xl">{value}</div>
                  <div className="mt-0.5 text-sm font-medium text-muted-foreground">{label}</div>
                </div>
              )
            )}
          </div>
        </section>

        {/* Features */}
        <section id="features" className="scroll-mt-24 py-20 md:py-28" aria-labelledby="features-heading">
          <h2 id="features-heading" className="font-display mb-3 text-center text-3xl font-bold tracking-tight md:text-4xl">What you get</h2>
          <p className="mb-14 text-center text-muted-foreground md:text-lg">Clear outcomes without the jargon</p>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {FEATURES.map((f, i) => (
              <FeatureCard key={f.title} icon={f.icon} title={f.title} desc={f.desc} />
            ))}
          </div>
        </section>

        {/* Pipeline */}
        <section className="py-20 md:py-28">
          <h2 className="font-display mb-3 text-center text-3xl font-bold tracking-tight md:text-4xl">How it works</h2>
          <p className="mb-14 text-center text-muted-foreground md:text-lg">Four steps from data to ranked models</p>
          <Suspense fallback={<div className="mx-auto h-32 animate-pulse rounded-2xl bg-muted/50" aria-hidden />}>
            <PipelineDiagram className="mx-auto" />
          </Suspense>
        </section>

        {/* Steps */}
        <section className="py-20 md:py-28">
          <h2 className="font-display mb-3 text-center text-3xl font-bold tracking-tight md:text-4xl">Your path through the app</h2>
          <p className="mb-14 text-center text-muted-foreground md:text-lg">Upload → set your goal → optional settings → results</p>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {STEPS.map((step) => (
              <StepCard key={step.num} num={step.num} title={step.title} desc={step.desc} />
            ))}
          </div>
        </section>

        {/* Testimonials */}
        <section className="py-20 md:py-28">
          <h2 className="font-display mb-3 text-center text-3xl font-bold tracking-tight md:text-4xl">Built for teams</h2>
          <p className="mb-14 text-center text-muted-foreground md:text-lg">From analysts to domain experts</p>
          <Suspense fallback={<div className="mx-auto max-w-4xl h-48 animate-pulse rounded-2xl bg-muted/50" aria-hidden />}>
            <Testimonials className="max-w-4xl mx-auto" />
          </Suspense>
        </section>

        {/* Get Started */}
        <section id="get-started" className="scroll-mt-24 py-20 md:py-28" aria-labelledby="get-started-heading">
          <h2 id="get-started-heading" className="font-display mb-3 text-center text-3xl font-bold tracking-tight md:text-4xl">Quick Start</h2>
          <p className="mb-14 text-center text-muted-foreground md:text-lg">Open the project in RStudio, then two steps</p>
          <div className="mx-auto max-w-2xl space-y-6" role="region" aria-label="Quick Start code blocks">
            <p className="text-center text-sm text-muted-foreground">
              <strong>Step 0:</strong> Open this folder in RStudio (File → Open Project → choose the folder that contains <code className="rounded bg-muted px-1">run_app.R</code>).
            </p>
            <div className="rounded-2xl border border-border/60 bg-muted/40 p-5 font-mono text-sm shadow-card backdrop-blur-sm">
              <div className="flex items-center justify-between gap-2 mb-2">
                <span className="text-muted-foreground"># 1. Install packages (first time only)</span>
                <CopyCodeButton
                  text={`install.packages(c(
  "shiny", "bslib", "DT", "shinyWidgets", "shinyjs",
  "tidymodels", "recipes", "parsnip", "workflows", "workflowsets",
  "tune", "rsample", "yardstick", "dials", "stacks", "probably",
  "glmnet", "ranger", "xgboost", "kknn", "kernlab", "discrim", "naivebayes", "rpart",
  "promises", "future",
  "dplyr", "tidyr", "purrr", "readr", "forcats", "readxl", "lubridate",
  "ggplot2", "jsonlite", "vip", "themis"
))`}
                />
              </div>
              <pre className="whitespace-pre-wrap break-all">
                {`install.packages(c(
  "shiny", "bslib", "DT", "shinyWidgets", "shinyjs",
  "tidymodels", "recipes", "parsnip", "workflows", "workflowsets",
  "tune", "rsample", "yardstick", "dials", "stacks", "probably",
  "glmnet", "ranger", "xgboost", "kknn", "kernlab", "discrim", "naivebayes", "rpart",
  "promises", "future",
  "dplyr", "tidyr", "purrr", "readr", "forcats", "readxl", "lubridate",
  "ggplot2", "jsonlite", "vip", "themis"
))`}
              </pre>
              <p className="mt-2 text-xs text-muted-foreground">Optional: <code>earth</code> (MARS), <code>parallelly</code> (parallel tuning).</p>
            </div>
            <div className="rounded-2xl border border-border/60 bg-muted/40 p-5 font-mono text-sm shadow-card backdrop-blur-sm">
              <div className="flex items-center justify-between gap-2 mb-2">
                <span className="text-muted-foreground"># 2. Run the app</span>
                <CopyCodeButton text='source("run_app.R")' />
              </div>
              <pre>source(&quot;run_app.R&quot;)</pre>
              <p className="mt-3 text-xs text-muted-foreground">
                Or: open <code>run_app.R</code> in the editor and click Source (Ctrl+Shift+S / Cmd+Shift+S). The app opens in your browser.
              </p>
            </div>
            <p className="text-center text-sm text-muted-foreground">
              Full instructions in <strong>RUN_FROM_RSTUDIO.md</strong>.
            </p>
            <p className="text-center text-sm text-muted-foreground">
              Not running the app yourself? Someone on your team can open the project and run it; the four steps above are what you&apos;ll see inside — upload data, choose what to predict, optional settings, then results.
            </p>
            <Suspense fallback={<div className="max-w-md mx-auto h-40 animate-pulse rounded-2xl bg-muted/50" aria-hidden />}>
              <FileTree className="max-w-md mx-auto" />
            </Suspense>
          </div>
        </section>

        {/* Model catalogue */}
        <section className="py-20 md:py-28">
          <h2 className="font-display mb-3 text-center text-3xl font-bold tracking-tight md:text-4xl">Models under the hood</h2>
          <p className="mb-14 text-center text-muted-foreground md:text-lg">The app tries many model types and ranks them for you</p>
          <div className="grid gap-4 sm:grid-cols-2 md:grid-cols-3">
            {[
              { name: "glmnet", sub: "Regularised linear/logistic", icon: LineChart },
              { name: "Random Forest", sub: "ranger engine", icon: Layers },
              { name: "XGBoost", sub: "Gradient boosted trees", icon: Zap },
              { name: "Decision Tree", sub: "Interpretable, small-data", icon: Layers },
              { name: "SVM", sub: "Radial basis kernel", icon: Bot },
              { name: "KNN", sub: "Nearest neighbours", icon: Database },
              { name: "Naive Bayes", sub: "Probabilistic classifier", icon: Brain },
              { name: "MARS", sub: "Nonlinear splines (optional)", icon: LineChart },
              { name: "Ensemble", sub: "Stacked blending", icon: Sparkles },
            ].map((m) => (
              <div
                key={m.name}
                className="premium-card flex items-center gap-4 rounded-2xl p-5"
              >
                <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
                  <m.icon className="h-5 w-5" />
                </div>
                <div>
                  <div className="font-semibold text-foreground">{m.name}</div>
                  <div className="text-sm text-muted-foreground">{m.sub}</div>
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Footer */}
        <footer className="mt-4 border-t border-border/60 py-14 text-center">
          <div className="font-display text-lg font-semibold text-foreground">Sensehub <span className="text-primary">AutoM/L</span></div>
          <p className="mt-2 text-sm text-muted-foreground">Built with R Shiny · tidymodels · bslib</p>
        </footer>
      </main>
    </div>
  );
};

export default Index;
