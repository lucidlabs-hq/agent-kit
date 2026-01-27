/**
 * ClassificationPill Component
 *
 * Editable attribute as a pill with icon + value + chevron.
 * Used for classification dropdowns (Raum, Bauteil, Störungstyp).
 *
 * Icon system:
 * - Default: Tag icon (classification attributes)
 * - Custom: Pass icon prop for specific meanings
 *   - AlertCircle: Priority/Urgency
 *   - GitBranch: Assignment type
 *   - User: Contact person
 *
 * Rules:
 * - Gray background (neutral)
 * - Single line icon (same stroke as chevron)
 * - Value text
 * - Chevron always visible
 * - No label prefix like "Raum:"
 *
 * States:
 * - Default: light gray
 * - Hover: slightly darker
 * - Focus: Indigo outline
 * - Open: White + Indigo outline
 * - Disabled: reduced opacity
 */

"use client";

import { useState, useRef, useEffect } from "react";
import { ChevronDown, Tag } from "lucide-react";
import { cn } from "@/lib/utils";

interface ClassificationPillProps<T extends string> {
  /** Current selected value */
  value: T;
  /** Available options */
  options: readonly T[];
  /** Labels for each option */
  labels: Record<T, string>;
  /** Change handler */
  onChange: (value: T) => void;
  /** Disabled state */
  disabled?: boolean;
  /** Full width (default true) */
  fullWidth?: boolean;
  /** Custom icon (defaults to Tag) */
  icon?: React.ReactNode;
}

export function ClassificationPill<T extends string>({
  value,
  options,
  labels,
  onChange,
  disabled,
  fullWidth = true,
  icon,
}: ClassificationPillProps<T>) {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  // Close dropdown on outside click
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }
    if (isOpen) {
      document.addEventListener("mousedown", handleClickOutside);
    }
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [isOpen]);

  return (
    <div ref={containerRef} className={cn("relative", fullWidth && "w-full")}>
      {/* Pill Button */}
      <button
        type="button"
        onClick={() => !disabled && setIsOpen(!isOpen)}
        disabled={disabled}
        className={cn(
          "flex items-center gap-2 rounded-md px-3 py-2 text-sm transition-all",
          fullWidth && "w-full",
          isOpen
            ? "bg-white ring-2 ring-primary"
            : "bg-slate-100 hover:bg-slate-200",
          disabled && "cursor-not-allowed opacity-50",
          !disabled && "cursor-pointer"
        )}
      >
        {/* Icon - custom or default Tag icon */}
        {icon || <Tag className="size-4 text-slate-400" strokeWidth={1.5} />}

        {/* Value */}
        <span className="flex-1 text-left text-slate-900">
          {labels[value]}
        </span>

        {/* Chevron */}
        <ChevronDown
          className={cn(
            "size-4 text-slate-400 transition-transform",
            isOpen && "rotate-180"
          )}
        />
      </button>

      {/* Dropdown */}
      {isOpen && (
        <div className="absolute left-0 right-0 top-full z-20 mt-1 max-h-60 overflow-auto rounded-md border border-slate-200 bg-white py-1 shadow-lg">
          {options.map((option) => (
            <button
              key={option}
              type="button"
              onClick={() => {
                onChange(option);
                setIsOpen(false);
              }}
              className={cn(
                "flex w-full cursor-pointer items-center px-3 py-2 text-left text-sm transition-colors",
                option === value
                  ? "bg-primary/5 text-primary"
                  : "text-slate-700 hover:bg-slate-50"
              )}
            >
              {labels[option]}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
