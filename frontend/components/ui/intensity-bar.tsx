/**
 * IntensityBar Component
 *
 * Visual-only intensity scale without text labels.
 * Uses Indigo gradient: light (left) to intense (right).
 *
 * Rules:
 * - 5 bars
 * - No text, no tooltip in default
 * - Click to select
 * - Selection stays visible
 * - Colors: Indigo gradient only
 */

"use client";

import { cn } from "@/lib/utils";

interface IntensityBarProps {
  /** Current value (1-5) */
  value: 1 | 2 | 3 | 4 | 5;
  /** Change handler */
  onChange: (value: 1 | 2 | 3 | 4 | 5) => void;
  /** Disabled state */
  disabled?: boolean;
  /** Optional label above the bars */
  label?: string;
}

// Indigo intensity colors for selected state (light to intense)
const INTENSITY_COLORS_SELECTED = [
  "bg-indigo-200", // Level 1 selected
  "bg-indigo-300", // Level 2 selected
  "bg-indigo-400", // Level 3 selected
  "bg-indigo-500", // Level 4 selected
  "bg-indigo-600", // Level 5 selected
];

export function IntensityBar({
  value,
  onChange,
  disabled,
  label,
}: IntensityBarProps) {
  return (
    <div className="space-y-2">
      {/* Optional label */}
      {label && (
        <span className="text-xs text-slate-500">{label}</span>
      )}

      {/* Bar scale with numbers inside */}
      <div
        className={cn(
          "flex gap-1",
          disabled && "cursor-not-allowed opacity-50"
        )}
        role="radiogroup"
        aria-label={label || "Intensity scale"}
      >
        {[1, 2, 3, 4, 5].map((level) => {
          const isSelected = level <= value;
          const isExactValue = level === value;

          return (
            <button
              key={level}
              type="button"
              role="radio"
              aria-checked={isExactValue}
              aria-label={`Stufe ${level}`}
              onClick={() => !disabled && onChange(level as 1 | 2 | 3 | 4 | 5)}
              disabled={disabled}
              className={cn(
                "h-6 flex-1 rounded-md transition-all flex items-center justify-center text-[10px] font-medium",
                isSelected
                  ? cn(INTENSITY_COLORS_SELECTED[level - 1], level >= 4 ? "text-white" : "text-indigo-700")
                  : "bg-slate-200 text-slate-400 hover:bg-slate-300",
                !disabled && "cursor-pointer"
              )}
            >
              {level}
            </button>
          );
        })}
      </div>
    </div>
  );
}
