import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import CopyCodeButton from "./CopyCodeButton";

describe("CopyCodeButton", () => {
  beforeEach(() => {
    vi.stubGlobal("navigator", {
      clipboard: {
        writeText: vi.fn().mockResolvedValue(undefined),
      },
    });
  });

  it("renders with default label", () => {
    render(<CopyCodeButton text="foo" />);
    expect(screen.getByRole("button", { name: /copy to clipboard/i })).toBeInTheDocument();
  });

  it("calls clipboard.writeText on click", async () => {
    render(<CopyCodeButton text="hello" />);
    fireEvent.click(screen.getByRole("button"));
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith("hello");
  });

  it("shows Copied after click", async () => {
    render(<CopyCodeButton text="x" />);
    fireEvent.click(screen.getByRole("button"));
    expect(await screen.findByRole("button", { name: /copied/i })).toBeInTheDocument();
  });
});
