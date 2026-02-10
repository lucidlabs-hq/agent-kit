/**
 * TicketTable Component
 *
 * Full table display for tickets with sorting and filtering.
 * Supports URL-based filters for shareability.
 */

"use client";

import { useState, useMemo } from "react";
import { useSearchParams, useRouter, usePathname } from "next/navigation";
import { TicketRow } from "./TicketRow";
import { Button } from "@/components/ui/button";
import type { Ticket, StrategicGoal, TicketStatus, WorkType } from "@/lib/types/domain";
import { TICKET_STATUS_ORDER, TICKET_STATUS_LABELS, WORK_TYPE_LABELS } from "@/lib/types/domain";
import { cn } from "@/lib/utils";
import { X } from "lucide-react";

interface TicketTableProps {
  goals: StrategicGoal[];
  onTicketClick?: (ticket: Ticket) => void;
  tickets: Ticket[];
}

export function TicketTable({ goals, onTicketClick, tickets }: TicketTableProps) {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [expandedId, setExpandedId] = useState<string | null>(null);

  const statusFilter = searchParams.get("status") as TicketStatus | null;
  const workTypeFilter = searchParams.get("workType") as WorkType | null;
  const goalFilter = searchParams.get("goal");

  const updateFilter = (key: string, value: string | null) => {
    const params = new URLSearchParams(searchParams);
    if (value) {
      params.set(key, value);
    } else {
      params.delete(key);
    }
    router.push(`${pathname}?${params.toString()}`);
  };

  const clearFilters = () => {
    router.push(pathname);
  };

  const hasFilters = statusFilter || workTypeFilter || goalFilter;

  const filteredTickets = useMemo(() => {
    return tickets.filter((ticket) => {
      if (statusFilter && ticket.status !== statusFilter) return false;
      if (workTypeFilter && ticket.workType !== workTypeFilter) return false;
      if (goalFilter && ticket.strategicGoalId !== goalFilter) return false;
      return true;
    });
  }, [tickets, statusFilter, workTypeFilter, goalFilter]);

  const goalMap = useMemo(() => {
    return new Map(goals.map((g) => [g._id, g]));
  }, [goals]);

  const handleToggle = (ticketId: string) => {
    setExpandedId(expandedId === ticketId ? null : ticketId);
    if (onTicketClick) {
      const ticket = tickets.find((t) => t._id === ticketId);
      if (ticket) onTicketClick(ticket);
    }
  };

  return (
    <div className="space-y-4">
      {/* Filters */}
      <div className="flex flex-wrap items-center gap-2">
        {/* Status Filter */}
        <div className="flex items-center gap-1">
          {TICKET_STATUS_ORDER.map((status) => (
            <button
              key={status}
              onClick={() =>
                updateFilter("status", statusFilter === status ? null : status)
              }
              className={cn(
                "cursor-pointer rounded-md px-2 py-1 text-xs transition-colors",
                statusFilter === status
                  ? "bg-indigo-100 text-indigo-700"
                  : "text-slate-500 hover:bg-slate-100"
              )}
            >
              {TICKET_STATUS_LABELS[status]}
            </button>
          ))}
        </div>

        {/* Work Type Filter */}
        <div className="flex items-center gap-1 border-l border-slate-200 pl-2">
          {(["standard", "maintenance"] as WorkType[]).map((type) => (
            <button
              key={type}
              onClick={() =>
                updateFilter("workType", workTypeFilter === type ? null : type)
              }
              className={cn(
                "cursor-pointer rounded-md px-2 py-1 text-xs transition-colors",
                workTypeFilter === type
                  ? "bg-indigo-100 text-indigo-700"
                  : "text-slate-500 hover:bg-slate-100"
              )}
            >
              {WORK_TYPE_LABELS[type]}
            </button>
          ))}
        </div>

        {/* Goal Filter */}
        {goals.length > 0 && (
          <div className="flex items-center gap-1 border-l border-slate-200 pl-2">
            {goals.map((goal) => (
              <button
                key={goal._id}
                onClick={() =>
                  updateFilter("goal", goalFilter === goal._id ? null : goal._id)
                }
                className={cn(
                  "cursor-pointer rounded-md px-2 py-1 text-xs transition-colors",
                  goalFilter === goal._id
                    ? "bg-indigo-100 text-indigo-700"
                    : "text-slate-500 hover:bg-slate-100"
                )}
              >
                {goal.name}
              </button>
            ))}
          </div>
        )}

        {/* Clear Filters */}
        {hasFilters && (
          <Button
            variant="ghost"
            size="sm"
            onClick={clearFilters}
            className="ml-auto"
          >
            <X className="mr-1 size-3" />
            Clear
          </Button>
        )}
      </div>

      {/* Table */}
      <div className="overflow-hidden rounded-xl border border-slate-200">
        <table className="w-full">
          <thead className="bg-slate-50">
            <tr className="border-b border-slate-200 text-left text-xs font-medium text-slate-500">
              <th className="px-4 py-3 w-24">ID</th>
              <th className="px-4 py-3">Title</th>
              <th className="px-4 py-3 w-32">Status</th>
              <th className="px-4 py-3 w-28">Type</th>
              <th className="px-4 py-3 w-36">Goal</th>
              <th className="px-4 py-3 w-24">Risk</th>
            </tr>
          </thead>
          <tbody>
            {filteredTickets.length === 0 ? (
              <tr>
                <td
                  colSpan={6}
                  className="px-4 py-8 text-center text-sm text-slate-500"
                >
                  {hasFilters
                    ? "No tickets match the current filters."
                    : "No tickets found."}
                </td>
              </tr>
            ) : (
              filteredTickets.map((ticket) => (
                <TicketRow
                  key={ticket._id}
                  ticket={ticket}
                  goal={goalMap.get(ticket.strategicGoalId || "") || null}
                  expanded={expandedId === ticket._id}
                  onToggle={() => handleToggle(ticket._id)}
                />
              ))
            )}
          </tbody>
        </table>
      </div>

      <div className="text-xs text-slate-400">
        Showing {filteredTickets.length} of {tickets.length} tickets
      </div>
    </div>
  );
}
