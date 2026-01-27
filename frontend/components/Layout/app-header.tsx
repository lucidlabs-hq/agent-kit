/**
 * AppHeader Component
 *
 * Flexible header component for different page modes.
 * Customize for your application needs.
 */

import { ArrowLeft } from "lucide-react";

type HeaderMode = "default" | "detail";

interface AppHeaderProps {
  mode?: HeaderMode;
  /** Page title */
  title?: string;
  /** Subtitle or description */
  subtitle?: string;
  /** Show back button (detail mode) */
  onBack?: () => void;
  /** Custom right-side content */
  rightContent?: React.ReactNode;
}

export function AppHeader({
  mode = "default",
  title,
  subtitle,
  onBack,
  rightContent,
}: AppHeaderProps) {
  // Detail mode: Back button + optional right content
  if (mode === "detail") {
    return (
      <header className="flex items-center justify-between px-8 pb-4 pt-[46px]">
        {/* Left: Back button */}
        {onBack && (
          <button
            onClick={onBack}
            className="flex cursor-pointer items-center gap-1.5 text-sm text-slate-500 transition-colors hover:text-slate-700"
            aria-label="Go back"
          >
            <ArrowLeft className="size-4" />
            <span>Back</span>
          </button>
        )}

        {/* Right: Custom content */}
        {rightContent && (
          <div className="flex items-center gap-2.5">
            {rightContent}
          </div>
        )}
      </header>
    );
  }

  // Default mode: Title + subtitle
  return (
    <header className="flex items-start justify-between px-8 pb-4 pt-[46px]">
      <div>
        {title && (
          <h1 className="text-xl font-semibold text-slate-900">
            {title}
          </h1>
        )}
        {subtitle && (
          <p className="mt-1 text-sm text-slate-500">
            {subtitle}
          </p>
        )}
      </div>
      {rightContent && (
        <div className="flex items-center gap-2.5">
          {rightContent}
        </div>
      )}
    </header>
  );
}
