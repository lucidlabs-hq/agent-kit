/**
 * ChoiceGroup Component
 *
 * Unified choice selector for radio and checkbox inputs.
 * Replaces native radio/checkbox with styled card-like options.
 *
 * Features:
 * - Radio (single select) or Checkbox (multi select) mode
 * - Card-style options with hover states
 * - Optional descriptions per option
 * - Optional nested content when selected
 * - Keyboard accessible
 */

"use client";

import { Check } from "lucide-react";
import { cn } from "@/lib/utils";

export interface ChoiceOption<T extends string = string> {
  /** Unique value identifier */
  value: T;
  /** Display label */
  label: string;
  /** Optional description */
  description?: string;
  /** Optional nested content shown when selected */
  nestedContent?: React.ReactNode;
}

interface ChoiceGroupProps<T extends string = string> {
  /** Available options */
  options: ChoiceOption<T>[];
  /** Current selected value(s) */
  value: T | T[] | null;
  /** Change handler */
  onChange: (value: T | T[]) => void;
  /** Selection mode: radio (single) or checkbox (multi) */
  mode?: "radio" | "checkbox";
  /** Disabled state */
  disabled?: boolean;
  /** Optional label for the group */
  label?: string;
  /** Layout direction */
  direction?: "vertical" | "horizontal";
  /** Compact mode (smaller padding) */
  compact?: boolean;
}

export function ChoiceGroup<T extends string = string>({
  options,
  value,
  onChange,
  mode = "radio",
  disabled,
  label,
  direction = "vertical",
  compact = false,
}: ChoiceGroupProps<T>) {
  const isMultiSelect = mode === "checkbox";

  // Get selected values as array for easier checking
  const selectedValues: T[] = Array.isArray(value)
    ? value
    : value
      ? [value]
      : [];

  const handleSelect = (optionValue: T) => {
    if (disabled) return;

    if (isMultiSelect) {
      // Toggle selection in checkbox mode
      const newValues = selectedValues.includes(optionValue)
        ? selectedValues.filter((v) => v !== optionValue)
        : [...selectedValues, optionValue];
      onChange(newValues);
    } else {
      // Single selection in radio mode
      onChange(optionValue);
    }
  };

  return (
    <div className="space-y-2">
      {/* Group Label */}
      {label && (
        <span className="block text-xs font-medium text-slate-500">{label}</span>
      )}

      {/* Options */}
      <div
        className={cn(
          "flex gap-2",
          direction === "vertical" ? "flex-col" : "flex-row flex-wrap"
        )}
        role={isMultiSelect ? "group" : "radiogroup"}
        aria-label={label}
      >
        {options.map((option) => {
          const isSelected = selectedValues.includes(option.value);

          return (
            <div key={option.value} className="space-y-2">
              <button
                type="button"
                role={isMultiSelect ? "checkbox" : "radio"}
                aria-checked={isSelected}
                onClick={() => handleSelect(option.value)}
                disabled={disabled}
                className={cn(
                  "flex w-full items-start gap-3 rounded-lg text-left transition-all",
                  compact ? "px-3 py-2" : "px-4 py-3",
                  isSelected
                    ? "bg-primary/5 ring-1 ring-primary/30"
                    : "bg-surface-2 hover:bg-slate-200 hover:ring-1 hover:ring-border/60",
                  disabled && "cursor-not-allowed opacity-50",
                  !disabled && "cursor-pointer"
                )}
              >
                {/* Selection Indicator */}
                <div
                  className={cn(
                    "mt-0.5 flex size-5 shrink-0 items-center justify-center rounded-full border-2 transition-colors",
                    isSelected
                      ? "border-primary bg-primary text-white"
                      : "border-slate-300 bg-white"
                  )}
                >
                  {isSelected && <Check className="size-3" strokeWidth={3} />}
                </div>

                {/* Label + Description */}
                <div className="flex-1">
                  <span
                    className={cn(
                      "text-sm font-medium",
                      isSelected ? "text-slate-800" : "text-slate-700"
                    )}
                  >
                    {option.label}
                  </span>
                  {option.description && (
                    <p className="mt-0.5 text-xs text-slate-500">
                      {option.description}
                    </p>
                  )}
                </div>
              </button>

              {/* Nested Content (shown when selected) */}
              {isSelected && option.nestedContent && (
                <div className="ml-8 animate-in fade-in slide-in-from-top-1 duration-150">
                  {option.nestedContent}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

/**
 * Simpler toggle variant for single on/off choices
 * Supports "details on demand" via info icon + tooltip
 */
interface ChoiceToggleProps {
  /** Display label */
  label: string;
  /** Optional tooltip text (shown on info icon hover) */
  tooltip?: string;
  /** Current state */
  checked: boolean;
  /** Change handler */
  onChange: (checked: boolean) => void;
  /** Disabled state */
  disabled?: boolean;
  /** Compact mode - minimal inline style */
  compact?: boolean;
}

/**
 * Compact inline radio group for single-select choices
 * Same visual style as compact ChoiceToggle but for radio selections
 */
interface InlineRadioGroupProps<T extends string = string> {
  /** Available options */
  options: { value: T; label: string }[];
  /** Current selected value */
  value: T | null;
  /** Change handler */
  onChange: (value: T) => void;
  /** Disabled state */
  disabled?: boolean;
  /** Optional label for the group */
  label?: string;
}

export function InlineRadioGroup<T extends string = string>({
  options,
  value,
  onChange,
  disabled,
  label,
}: InlineRadioGroupProps<T>) {
  return (
    <div className="space-y-1">
      {label && (
        <span className="block text-xs font-medium text-slate-500">{label}</span>
      )}
      <div className="flex flex-wrap gap-x-4 gap-y-1">
        {options.map((option) => {
          const isSelected = value === option.value;
          return (
            <button
              key={option.value}
              type="button"
              role="radio"
              aria-checked={isSelected}
              onClick={() => !disabled && onChange(option.value)}
              disabled={disabled}
              className={cn(
                "flex items-center gap-2 py-1",
                disabled && "cursor-not-allowed opacity-50",
                !disabled && "cursor-pointer"
              )}
            >
              {/* Radio Indicator */}
              <div
                className={cn(
                  "flex size-4 shrink-0 items-center justify-center rounded-full border-2 transition-colors",
                  isSelected
                    ? "border-primary"
                    : "border-slate-300"
                )}
              >
                {isSelected && (
                  <div className="size-2 rounded-full bg-primary" />
                )}
              </div>
              {/* Label */}
              <span
                className={cn(
                  "text-sm",
                  isSelected ? "text-slate-700" : "text-slate-500"
                )}
              >
                {option.label}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

export function ChoiceToggle({
  label,
  tooltip,
  checked,
  onChange,
  disabled,
  compact = false,
}: ChoiceToggleProps) {
  // Compact mode: minimal inline row without background
  // Tooltip appears on hover of entire row (no visible info icon)
  if (compact) {
    return (
      <div className="group relative flex items-center gap-2 py-1">
        {/* Checkbox */}
        <button
          type="button"
          role="checkbox"
          aria-checked={checked}
          onClick={() => !disabled && onChange(!checked)}
          disabled={disabled}
          title={tooltip}
          className={cn(
            "flex size-4 shrink-0 items-center justify-center rounded border transition-colors",
            checked
              ? "border-primary bg-primary text-white"
              : "border-slate-300 bg-white",
            disabled && "cursor-not-allowed opacity-50",
            !disabled && "cursor-pointer"
          )}
        >
          {checked && <Check className="size-2.5" strokeWidth={3} />}
        </button>

        {/* Label */}
        <button
          type="button"
          onClick={() => !disabled && onChange(!checked)}
          disabled={disabled}
          title={tooltip}
          className={cn(
            "text-sm",
            checked ? "text-slate-700" : "text-slate-500",
            !disabled && "cursor-pointer"
          )}
        >
          {label}
        </button>

        {/* Tooltip on hover (no visible icon) */}
        {tooltip && (
          <div className="pointer-events-none absolute bottom-full left-0 z-50 mb-2 w-48 rounded-lg bg-slate-800 px-3 py-2 text-xs text-white opacity-0 shadow-lg transition-opacity group-hover:opacity-100">
            {tooltip}
            <div className="absolute left-4 top-full border-4 border-transparent border-t-slate-800" />
          </div>
        )}
      </div>
    );
  }

  // Non-compact mode: card-style with background
  return (
    <button
      type="button"
      role="checkbox"
      aria-checked={checked}
      onClick={() => !disabled && onChange(!checked)}
      disabled={disabled}
      className={cn(
        "flex w-full items-start gap-3 rounded-lg px-4 py-3 text-left transition-all",
        checked
          ? "bg-primary/5 ring-1 ring-primary/30"
          : "bg-surface-2 hover:bg-slate-200 hover:ring-1 hover:ring-border/60",
        disabled && "cursor-not-allowed opacity-50",
        !disabled && "cursor-pointer"
      )}
    >
      {/* Checkbox Indicator */}
      <div
        className={cn(
          "mt-0.5 flex size-5 shrink-0 items-center justify-center rounded border-2 transition-colors",
          checked
            ? "border-primary bg-primary text-white"
            : "border-slate-300 bg-white"
        )}
      >
        {checked && <Check className="size-3" strokeWidth={3} />}
      </div>

      {/* Label */}
      <span
        className={cn(
          "flex-1 text-sm font-medium",
          checked ? "text-slate-800" : "text-slate-700"
        )}
      >
        {label}
      </span>
    </button>
  );
}
