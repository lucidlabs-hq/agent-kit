/**
 * Toaster Component
 *
 * Design spec:
 * - Light blue gradient background (matching AKTION section)
 * - Position: bottom-right
 * - Same radius as cards (rounded-xl)
 * - Subtle border
 */

"use client";

import { Check, RefreshCw, Info, AlertTriangle } from "lucide-react";
import { Toaster as Sonner, type ToasterProps } from "sonner";

const Toaster = ({ ...props }: ToasterProps) => {
  return (
    <Sonner
      position="bottom-right"
      className="toaster group"
      toastOptions={{
        classNames: {
          toast:
            "group toast border border-divider rounded-xl shadow-lg bg-gradient-to-b from-indigo-50/40 via-indigo-50/15 to-indigo-50/40",
          title: "text-slate-800 text-sm font-medium",
          description: "text-slate-500 text-sm",
          icon: "text-slate-600",
        },
      }}
      icons={{
        success: <Check className="size-4 text-slate-600" strokeWidth={2} />,
        info: <Info className="size-4 text-slate-600" strokeWidth={2} />,
        warning: (
          <AlertTriangle className="size-4 text-slate-600" strokeWidth={2} />
        ),
        error: (
          <AlertTriangle className="size-4 text-slate-600" strokeWidth={2} />
        ),
        loading: (
          <RefreshCw
            className="size-4 animate-spin text-slate-600"
            strokeWidth={2}
          />
        ),
      }}
      {...props}
    />
  );
};

export { Toaster };
