/**
 * DashboardStats Component
 *
 * Overview metrics display for tickets.
 * Shows status breakdown with mini badges.
 */

import { TicketStatusBadge } from "./TicketStatusBadge";
import type { DashboardStats as DashboardStatsType } from "@/lib/types/domain";
import { TICKET_STATUS_ORDER } from "@/lib/types/domain";

interface DashboardStatsProps {
  stats: DashboardStatsType;
}

export function DashboardStats({ stats }: DashboardStatsProps) {
  const activeStatuses = TICKET_STATUS_ORDER.filter(
    (status) => status !== "done" && status !== "dropped"
  );

  return (
    <div className="space-y-4">
      <div className="flex items-baseline gap-2">
        <span className="text-2xl font-semibold text-slate-900">
          {stats.total}
        </span>
        <span className="text-sm text-slate-500">total tickets</span>
      </div>

      <div className="flex flex-wrap gap-2">
        {activeStatuses.map((status) => {
          const count = stats.byStatus[status];
          if (count === 0) return null;
          return (
            <div key={status} className="flex items-center gap-1">
              <TicketStatusBadge status={status} size="sm" />
              <span className="text-xs font-medium text-slate-600">
                {count}
              </span>
            </div>
          );
        })}
      </div>

      <div className="flex gap-4 text-xs text-slate-500">
        <span>
          <span className="font-medium text-emerald-600">
            {stats.byStatus.done}
          </span>{" "}
          done
        </span>
        <span>
          <span className="font-medium text-slate-400">
            {stats.byStatus.dropped}
          </span>{" "}
          dropped
        </span>
      </div>
    </div>
  );
}
