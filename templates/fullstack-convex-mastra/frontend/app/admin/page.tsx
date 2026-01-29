/**
 * Admin Dashboard
 *
 * Stack overview, service health, and documentation browser.
 *
 * Created: 29. Januar 2026
 */

import { Suspense } from "react";
import { StackOverview } from "@/components/admin/StackOverview";
import { ServiceHealth } from "@/components/admin/ServiceHealth";
import { QuickActions } from "@/components/admin/QuickActions";

export default function AdminPage() {
  return (
    <div className="min-h-screen bg-zinc-950 text-zinc-100">
      {/* Header */}
      <header className="border-b border-zinc-800 px-6 py-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-xl font-semibold">Admin Dashboard</h1>
            <p className="text-sm text-zinc-500">{{PROJECT_NAME}}</p>
          </div>
          <div className="flex items-center gap-2 text-sm text-zinc-500">
            <span className="inline-block h-2 w-2 rounded-full bg-emerald-500" />
            Development Mode
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="p-6">
        <div className="mx-auto max-w-6xl space-y-6">
          {/* Service Health */}
          <Suspense fallback={<ServiceHealthSkeleton />}>
            <ServiceHealth />
          </Suspense>

          {/* Stack Overview */}
          <StackOverview />

          {/* Quick Actions */}
          <QuickActions />
        </div>
      </main>
    </div>
  );
}

function ServiceHealthSkeleton() {
  return (
    <div className="rounded-lg border border-zinc-800 bg-zinc-900 p-6">
      <div className="h-6 w-32 animate-pulse rounded bg-zinc-800" />
      <div className="mt-4 grid grid-cols-3 gap-4">
        {[1, 2, 3].map((i) => (
          <div key={i} className="h-24 animate-pulse rounded-lg bg-zinc-800" />
        ))}
      </div>
    </div>
  );
}
