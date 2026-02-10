/**
 * Convex Not Configured Component
 *
 * Displays a setup message when Convex is not configured.
 */

"use client";

import { AlertCircle } from "lucide-react";

interface ConvexNotConfiguredProps {
  title?: string;
  subtitle?: string;
}

export function ConvexNotConfigured({
  title = "Convex Not Configured",
  subtitle = "To use this feature, configure your Convex deployment.",
}: ConvexNotConfiguredProps) {
  return (
    <div className="flex flex-col items-center justify-center px-8 py-16">
      <div className="rounded-xl border border-amber-200 bg-amber-50 p-6 text-center">
        <AlertCircle className="mx-auto mb-3 size-8 text-amber-500" />
        <h3 className="mb-2 font-medium text-slate-900">{title}</h3>
        <p className="mb-4 text-sm text-slate-600">{subtitle}</p>
        <div className="rounded-lg bg-slate-900 p-3 text-left font-mono text-xs text-slate-100">
          <p className="text-slate-400"># Add to .env.local:</p>
          <p>NEXT_PUBLIC_CONVEX_URL=https://your-project.convex.cloud</p>
        </div>
      </div>
    </div>
  );
}
