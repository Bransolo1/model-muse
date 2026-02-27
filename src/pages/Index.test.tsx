import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { ThemeProvider } from "next-themes";
import Index from "./Index";

const wrapper = ({ children }: { children: React.ReactNode }) => (
  <ThemeProvider attribute="class" defaultTheme="light">
    <MemoryRouter>{children}</MemoryRouter>
  </ThemeProvider>
);

describe("Index", () => {
  beforeEach(() => {
    vi.stubGlobal("navigator", {
      clipboard: {
        writeText: vi.fn().mockResolvedValue(undefined),
      },
    });
    vi.stubGlobal("window", {
      ...window,
      matchMedia: vi.fn().mockReturnValue({ matches: false }),
    });
  });

  it("renders skip link and main content", () => {
    render(<Index />, { wrapper });
    expect(screen.getByText(/skip to main content/i)).toBeInTheDocument();
    expect(screen.getByRole("main")).toBeInTheDocument();
  });

  it("renders Get Started CTA and Quick Start section", () => {
    render(<Index />, { wrapper });
    expect(screen.getByRole("link", { name: /get started/i })).toBeInTheDocument();
    expect(screen.getByRole("heading", { name: /quick start/i })).toBeInTheDocument();
  });

  it("renders Quick Start code blocks with install and run steps", () => {
    render(<Index />, { wrapper });
    expect(screen.getByText(/install packages \(first time only\)/i)).toBeInTheDocument();
    expect(screen.getByText(/run the app/i)).toBeInTheDocument();
    expect(screen.getByText(/source\(.run_app\.R.\)/)).toBeInTheDocument();
    expect(screen.getByText(/install.packages\(c/)).toBeInTheDocument();
  });

  it("copy button for run step copies source(\"run_app.R\")", async () => {
    render(<Index />, { wrapper });
    const runStepHeading = screen.getByText(/run the app/i);
    const codeBlock = runStepHeading.closest("div")?.querySelector("pre")?.parentElement;
    const copyButtons = screen.getAllByRole("button", { name: /copy to clipboard/i });
    // Second copy button is for source("run_app.R")
    const runCopyButton = copyButtons[1];
    fireEvent.click(runCopyButton);
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith('source("run_app.R")');
  });

  it("has single h1 for Sensehub AutoM/L", () => {
    render(<Index />, { wrapper });
    const h1s = screen.getAllByRole("heading", { level: 1 });
    expect(h1s).toHaveLength(1);
    expect(h1s[0]).toHaveTextContent(/Sensehub.*AutoM\/L/);
  });
});
