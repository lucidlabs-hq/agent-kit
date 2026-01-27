/**
 * SeverityScale Component
 *
 * Text-based Segmented Control for severity/intensity selection.
 * PRD: Text segments (not gradient) for clear readability.
 *
 * Features:
 * - 5-level scale (1-5)
 * - Text-based segments
 * - Active segment highlighting
 * - Keyboard accessible
 */

"use client";

import { cn } from "@/lib/utils";

interface SeverityScaleProps {
  /** Current value (1-5) */
  value: 1 | 2 | 3 | 4 | 5;
  /** Change handler */
  onChange: (value: 1 | 2 | 3 | 4 | 5) => void;
  /** Disabled state */
  disabled?: boolean;
  /** Optional label */
  label?: string;
  /** Optional labels for each level */
  levelLabels?: [string, string, string, string, string];
}

// Default level labels
const DEFAULT_LEVEL_LABELS: [string, string, string, string, string] = [
  "Minimal",
  "Gering",
  "Mittel",
  "Hoch",
  "Kritisch",
];

export function SeverityScale({
  value,
  onChange,
  disabled,
  label,
  levelLabels = DEFAULT_LEVEL_LABELS,
}: SeverityScaleProps) {
  return (
    <div className="space-y-2">
      {/* Label - Label role */}
      {label && (
        <span className="text-xs text-slate-500">{label}</span>
      )}

      {/* Segmented Control - Full width */}
      <div
        className={cn(
          "flex w-full rounded-lg bg-surface-2 p-0.5",
          disabled && "cursor-not-allowed opacity-50"
        )}
        role="radiogroup"
        aria-label={label || "Severity scale"}
      >
        {[1, 2, 3, 4, 5].map((level) => {
          const isSelected = level === value;

          return (
            <button
              key={level}
              type="button"
              role="radio"
              aria-checked={isSelected}
              aria-label={`${levelLabels[level - 1]} (Stufe ${level})`}
              onClick={() => !disabled && onChange(level as 1 | 2 | 3 | 4 | 5)}
              disabled={disabled}
              className={cn(
                "flex-1 rounded-md py-1.5 text-xs font-medium transition-all",
                isSelected
                  ? "bg-white text-slate-900 shadow-sm"
                  : "text-slate-500 hover:text-slate-700",
                !disabled && "cursor-pointer"
              )}
            >
              {levelLabels[level - 1]}
            </button>
          );
        })}
      </div>
    </div>
  );
}
