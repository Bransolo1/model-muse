import { Link } from "react-router-dom";
import NavLink from "./NavLink";
import ThemeToggle from "./ThemeToggle";
import { cn } from "@/lib/utils";

const Navbar = ({ className }: { className?: string }) => {
  return (
    <header
      className={cn(
        "sticky top-0 z-50 w-full border-b border-border/60 bg-background/80 shadow-nav backdrop-blur-xl supports-[backdrop-filter]:bg-background/70",
        className
      )}
    >
      <div className="container flex h-16 items-center">
        <Link
          to="/"
          className="mr-8 flex items-center gap-2 font-display text-lg font-semibold tracking-tight text-foreground transition-opacity hover:opacity-90"
          aria-label="Sensehub AutoM/L home"
        >
          <span className="font-bold">Sensehub</span>
          <span className="font-bold text-primary">AutoM/L</span>
        </Link>
        <nav className="flex flex-1 items-center justify-end gap-6 text-sm font-medium" aria-label="Main navigation">
          <NavLink to="/" className="relative inline-block py-1 after:absolute after:bottom-0 after:left-0 after:h-0.5 after:w-0 after:rounded-full after:bg-primary after:transition-all after:duration-200 hover:after:w-full">
            Home
          </NavLink>
          <ThemeToggle />
        </nav>
      </div>
    </header>
  );
};

export default Navbar;
