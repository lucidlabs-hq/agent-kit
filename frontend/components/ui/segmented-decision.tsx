/**
 * SegmentedDecision Component
 *
 * Segmented control for operative decisions (not form inputs).
 * Same visual pattern as SeverityScale.
 *
 * Use this for:
 * - Semantic choices that affect workflow
 * - Decisions with operational impact
 * - NOT for typical form radio/checkbox inputs
 *
 * Features:
 * - Single selection (mutually exclusive)
 * - Text-based segments (no icons, no radio circles)
 * - Active segment highlighting
 * - Keyboard accessible
 * - Optional icon next to label (e.g., Layers for scope)
 */

"use client";

import { cn } from "@/lib/utils";

interface SegmentedDecisionOption<T extends string> {
  value: T;
  label: string;
}

interface SegmentedDecisionProps<T extends string> {
  /** Available options */
  options: SegmentedDecisionOption<T>[];
  /** Current selected value */
  value: T;
  /** Change handler */
  onChange: (value: T) => void;
  /** Disabled state */
  disabled?: boolean;
  /** Optional label */
  label?: string;
  /** Optional icon to display next to label */
  icon?: React.ReactNode;
}

export function SegmentedDecision<T extends string>({
  options,
  value,
  onChange,
  disabled,
  label,
  icon,
}: SegmentedDecisionProps<T>) {
  return (
    <div className="space-y-2">
      {/* Label with optional icon */}
      {label && (
        <span className="flex items-center gap-1.5 text-xs text-slate-500">
          {icon}
          {label}
        </span>
      )}

      {/* Segmented Control - Full width */}
      <div
        className={cn(
          "flex w-full rounded-lg bg-surface-2 p-0.5",
          disabled && "cursor-not-allowed opacity-50"
        )}
        role="radiogroup"
        aria-label={label || "Decision"}
      >
        {options.map((option) => {
          const isSelected = option.value === value;

          return (
            <button
              key={option.value}
              type="button"
              role="radio"
              aria-checked={isSelected}
              onClick={() => !disabled && onChange(option.value)}
              disabled={disabled}
              className={cn(
                "flex-1 rounded-md py-1.5 text-xs font-medium transition-all",
                isSelected
                  ? "bg-white text-slate-900 shadow-sm"
                  : "text-slate-500 hover:text-slate-700",
                !disabled && "cursor-pointer"
              )}
            >
              {option.label}
            </button>
          );
        })}
      </div>
    </div>
  );
}
