/**
 * Utils Test Suite
 *
 * Unit tests for utility functions.
 * Demonstrates TDD pattern for the Agent Kit.
 */

import { describe, it, expect } from "vitest";
import { cn } from "../utils";

describe("cn", () => {
  it("returns empty string for no inputs", () => {
    expect(cn()).toBe("");
  });

  it("returns single class unchanged", () => {
    expect(cn("text-red-500")).toBe("text-red-500");
  });

  it("merges multiple classes", () => {
    expect(cn("p-4", "m-2")).toBe("p-4 m-2");
  });

  it("handles conditional classes", () => {
    const isActive = true;
    const isDisabled = false;

    expect(cn("base", isActive && "active", isDisabled && "disabled")).toBe(
      "base active"
    );
  });

  it("resolves Tailwind conflicts (last wins)", () => {
    // p-2 should override p-4
    expect(cn("p-4", "p-2")).toBe("p-2");
  });

  it("handles array of classes", () => {
    expect(cn(["p-4", "m-2"])).toBe("p-4 m-2");
  });

  it("handles object syntax", () => {
    expect(
      cn({
        "text-red-500": true,
        "text-blue-500": false,
      })
    ).toBe("text-red-500");
  });

  it("handles mixed inputs", () => {
    expect(
      cn("base", ["array-class"], { "object-class": true }, false && "ignored")
    ).toBe("base array-class object-class");
  });

  it("handles undefined and null gracefully", () => {
    expect(cn("valid", undefined, null, "also-valid")).toBe("valid also-valid");
  });
});
