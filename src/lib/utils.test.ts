import { describe, it, expect } from "vitest";
import { cn } from "./utils";

describe("cn (utils)", () => {
  it("merges class names", () => {
    expect(cn("a", "b")).toBe("a b");
  });

  it("handles tailwind merge (later overrides)", () => {
    expect(cn("p-4", "p-2")).toBe("p-2");
  });

  it("handles undefined and false", () => {
    expect(cn("a", undefined, false, "b")).toBe("a b");
  });
});
