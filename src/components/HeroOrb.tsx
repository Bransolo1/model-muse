import { cn } from "@/lib/utils";

const HeroOrb = ({ className }: { className?: string }) => {
  return (
    <div
      className={cn(
        "pointer-events-none absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 h-[420px] w-[420px] rounded-full bg-gradient-orange opacity-[0.22] blur-[100px] animate-pulse-glow print:hidden",
        className
      )}
      aria-hidden
    />
  );
};

export default HeroOrb;
