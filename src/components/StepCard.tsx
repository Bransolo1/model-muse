import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { cn } from "@/lib/utils";

interface StepCardProps {
  num: string;
  title: string;
  desc: string;
  className?: string;
}

const StepCard = ({ num, title, desc, className }: StepCardProps) => (
  <Card className={cn("premium-card overflow-hidden", className)}>
    <CardHeader className="space-y-3 pb-2">
      <span className="inline-block rounded-lg bg-primary/10 px-2.5 py-1 font-mono text-xs font-semibold text-primary">{num}</span>
      <h3 className="font-display text-lg font-semibold tracking-tight text-foreground">{title}</h3>
    </CardHeader>
    <CardContent>
      <p className="text-sm leading-relaxed text-muted-foreground">{desc}</p>
    </CardContent>
  </Card>
);

export default StepCard;
