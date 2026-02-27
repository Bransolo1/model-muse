import { cn } from "@/lib/utils";

const PipelineDiagram = ({ className }: { className?: string }) => (
  <div className={cn("flex flex-wrap items-center justify-center gap-3", className)}>
    {["Upload", "Set goal", "Optional", "Results"].map((step, i) => (
      <span
        key={step}
        className="rounded-full border-2 border-border/60 bg-card/90 px-5 py-2.5 text-sm font-semibold text-foreground shadow-card backdrop-blur-sm transition-all hover:border-primary/40 hover:shadow-card-hover"
      >
        <span className="mr-1.5 font-mono text-xs text-primary">{String(i + 1).padStart(2, "0")}</span>
        {step}
      </span>
    ))}
  </div>
);

export default PipelineDiagram;
