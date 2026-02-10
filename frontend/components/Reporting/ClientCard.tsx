/**
 * ClientCard Component
 *
 * Summary card for a single client.
 * Displays name, Linear key, ticket stats, and contingent bar.
 */

"use client";

import Link from "next/link";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ContingentBar } from "./ContingentBar";
import { TicketStatusBadge } from "./TicketStatusBadge";
import type { Client, Contingent, DashboardStats } from "@/lib/types/domain";
import { TICKET_STATUS_ORDER } from "@/lib/types/domain";
import { ArrowRight, Play } from "lucide-react";

interface ClientCardProps {
  client: Client;
  contingent: Contingent | null;
  stats: DashboardStats;
}

export function ClientCard({ client, contingent, stats }: ClientCardProps) {
  const activeStatuses = TICKET_STATUS_ORDER.filter(
    (status) => status !== "done" && status !== "dropped" && status !== "backlog"
  );

  const activeCount = activeStatuses.reduce(
    (acc, status) => acc + stats.byStatus[status],
    0
  );

  return (
    <Card className="flex flex-col p-4 transition-colors hover:border-indigo-200">
      <div className="flex items-start justify-between">
        <div>
          <h3 className="font-semibold text-slate-900">{client.name}</h3>
          <Badge variant="muted" className="mt-1">
            {client.linearTeamKey}
          </Badge>
        </div>
        <div className="text-right">
          <span className="text-2xl font-semibold text-slate-900">
            {activeCount}
          </span>
          <span className="block text-xs text-slate-500">active</span>
        </div>
      </div>

      <div className="mt-4 flex flex-wrap gap-1.5">
        {activeStatuses.map((status) => {
          const count = stats.byStatus[status];
          if (count === 0) return null;
          return (
            <div key={status} className="flex items-center gap-1">
              <TicketStatusBadge status={status} size="sm" />
              <span className="text-[10px] font-medium text-slate-500">
                {count}
              </span>
            </div>
          );
        })}
      </div>

      <div className="mt-4 flex-1" />

      {contingent && (
        <div className="mt-4">
          <ContingentBar
            totalHours={contingent.totalHours}
            usedHours={contingent.usedHours}
          />
        </div>
      )}

      <div className="mt-4 flex items-center gap-2 border-t border-slate-100 pt-4">
        <Link
          href={`/reporting/${client._id}`}
          className="flex flex-1 cursor-pointer items-center justify-center gap-1.5 rounded-md py-1.5 text-sm text-slate-600 transition-colors hover:bg-slate-50"
        >
          View Details
          <ArrowRight className="size-3.5" />
        </Link>
        <Link
          href={`/reporting/${client._id}/meeting`}
          className="flex cursor-pointer items-center gap-1.5 rounded-md bg-indigo-50 px-3 py-1.5 text-sm font-medium text-indigo-600 transition-colors hover:bg-indigo-100"
        >
          <Play className="size-3.5" />
          Meeting
        </Link>
      </div>
    </Card>
  );
}
