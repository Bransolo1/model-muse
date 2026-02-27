import { LucideIcon } from "lucide-react";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { cn } from "@/lib/utils";

interface FeatureCardProps {
  icon: LucideIcon;
  title: string;
  desc: string;
  className?: string;
}

const FeatureCard = ({ icon: Icon, title, desc, className }: FeatureCardProps) => (
  <Card className={cn("premium-card overflow-hidden", className)}>
    <CardHeader className="space-y-4">
      <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-primary/15 to-primary/5 text-primary">
        <Icon className="h-6 w-6" strokeWidth={1.75} />
      </div>
      <h3 className="font-display text-lg font-semibold tracking-tight text-foreground">{title}</h3>
    </CardHeader>
    <CardContent>
      <p className="text-sm leading-relaxed text-muted-foreground">{desc}</p>
    </CardContent>
  </Card>
);

export default FeatureCard;
