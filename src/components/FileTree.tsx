import { Card, CardContent } from "@/components/ui/card";
import { cn } from "@/lib/utils";

const FileTree = ({ className }: { className?: string }) => (
  <Card className={cn("rounded-2xl border border-border/60 bg-muted/40 font-mono text-sm shadow-card backdrop-blur-sm", className)}>
    <CardContent className="pt-5 pb-5">
      <pre className="whitespace-pre-wrap text-muted-foreground">
        {`project/
  run_app.R          ← open this in RStudio, then Source
  shiny-app/
    R/
    server.R
    ui.R
    global.R`}
      </pre>
    </CardContent>
  </Card>
);

export default FileTree;
