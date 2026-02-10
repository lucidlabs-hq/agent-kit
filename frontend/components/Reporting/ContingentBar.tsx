/**
 * ContingentBar Component
 *
 * Horizontal bar showing hours utilization.
 * Colors indicate utilization level (green/amber/red).
 */

import { cn } from "@/lib/utils";

interface ContingentBarProps {
  showLabel?: boolean;
  totalHours: number;
  usedHours: number;
}

export function ContingentBar({
  showLabel = false,
  totalHours,
  usedHours,
}: ContingentBarProps) {
  const percent = totalHours > 0 ? (usedHours / totalHours) * 100 : 0;
  const clampedPercent = Math.min(percent, 100);

  const getBarColor = () => {
    if (percent >= 90) return "bg-red-500";
    if (percent >= 70) return "bg-amber-500";
    return "bg-emerald-500";
  };

  const remainingHours = Math.max(totalHours - usedHours, 0);

  return (
    <div className="w-full">
      {showLabel && (
        <div className="mb-1 flex items-center justify-between text-xs text-slate-500">
          <span>
            {usedHours}h / {totalHours}h used
          </span>
          <span>{remainingHours}h remaining</span>
        </div>
      )}
      <div className="h-2 w-full overflow-hidden rounded-full bg-slate-100">
        <div
          className={cn("h-full transition-all", getBarColor())}
          style={{ width: `${clampedPercent}%` }}
        />
      </div>
      {!showLabel && (
        <span className="mt-0.5 block text-[10px] text-slate-400">
          {Math.round(percent)}%
        </span>
      )}
    </div>
  );
}
