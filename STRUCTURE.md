# model-muse – folder structure reference

Local mirror of [Bransolo1/model-muse](https://github.com/Bransolo1/model-muse). This file is for AI/tooling to refer to the repo layout.

## Root

- `package.json` – Vite + React + shadcn (TypeScript)
- `vite.config.ts`, `tsconfig*.json`, `tailwind.config.ts`, `postcss.config.js`, `eslint.config.js`, `vitest.config.ts`, `components.json`
- `index.html` – Vite entry
- `.gitignore`, `README.md`
- `bun.lockb` / `package-lock.json` – lockfiles (use npm)

## Frontend (`src/`)

- `main.tsx` – React root
- `App.tsx` – Router, QueryClient, Toaster, Sonner, TooltipProvider
- `index.css`, `App.css` – Tailwind + CSS variables
- `vite-env.d.ts`
- **`src/pages/`** – `Index.tsx`, `NotFound.tsx`
- **`src/components/`** – `Navbar.tsx`, `NavLink.tsx`, `HeroOrb.tsx`, `FeatureCard.tsx`, `StepCard.tsx`, `FileTree.tsx`, `PipelineDiagram.tsx`, `Testimonials.tsx`
- **`src/components/ui/`** – shadcn components (e.g. `button`, `card`, `badge`, `toast`, `toaster`, `tooltip`, `sonner`, …)
- **`src/lib/`** – `utils.ts` (cn)
- **`src/hooks/`** – `use-toast.ts`
- **`src/test/`** – `setup.ts`

## R / Shiny

- **`R/`** – Shared R: `config.R`, `utils_logging.R`
- **`shiny-app/`** – Full Shiny app: `server.R`, `ui.R`, `global.R`, `R/` (config, modules, utils), `tests/`, `Dockerfile`, `.env.example`, etc.

## CI & static

- **`.github/workflows/`** – `sensehub-ci.yml` (R lint + tests for `shiny-app/`)
- **`public/`** – `favicon.ico`, `placeholder.svg`, `robots.txt`

## Commands

- `npm i` then `npm run dev` – frontend
- Shiny: from `shiny-app/`, `R -e "shiny::runApp()"` (after installing R deps)
