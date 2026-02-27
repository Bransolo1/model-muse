import { Card, CardContent } from "@/components/ui/card";
import { cn } from "@/lib/utils";

const Testimonials = ({ className }: { className?: string }) => (
  <div className={cn("grid gap-6 sm:grid-cols-2", className)}>
    <Card className="premium-card border-l-4 border-l-primary/50">
      <CardContent className="pt-5 pb-5 pl-6">
        <p className="text-base italic leading-relaxed text-muted-foreground">&ldquo;I could get from spreadsheet to ranked models without a stats background.&rdquo;</p>
      </CardContent>
    </Card>
    <Card className="premium-card border-l-4 border-l-primary/50">
      <CardContent className="pt-5 pb-5 pl-6">
        <p className="text-base italic leading-relaxed text-muted-foreground">&ldquo;Defaults are sensible so we can trust and explain the results.&rdquo;</p>
      </CardContent>
    </Card>
  </div>
);

export default Testimonials;
