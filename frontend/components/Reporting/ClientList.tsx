/**
 * ClientList Component
 *
 * Grid layout for displaying client cards.
 * Used on the reporting dashboard overview.
 */

"use client";

import { ClientCard } from "./ClientCard";
import type { Client, Contingent, DashboardStats } from "@/lib/types/domain";

interface ClientWithData {
  client: Client;
  contingent: Contingent | null;
  stats: DashboardStats;
}

interface ClientListProps {
  clients: ClientWithData[];
}

export function ClientList({ clients }: ClientListProps) {
  if (clients.length === 0) {
    return (
      <div className="rounded-xl border border-dashed border-slate-200 p-12 text-center">
        <p className="text-sm text-slate-500">No clients found.</p>
        <p className="mt-1 text-xs text-slate-400">
          Create a client to get started.
        </p>
      </div>
    );
  }

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {clients.map(({ client, contingent, stats }) => (
        <ClientCard
          key={client._id}
          client={client}
          contingent={contingent}
          stats={stats}
        />
      ))}
    </div>
  );
}
