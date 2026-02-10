/**
 * AgendaList Component
 *
 * List of tickets on the meeting agenda.
 * Highlights current ticket being discussed.
 */

"use client";

import { TicketStatusBadge } from "../TicketStatusBadge";
import { Badge } from "@/components/ui/badge";
import type { Ticket } from "@/lib/types/domain";
import { cn } from "@/lib/utils";
import { CheckCircle2, Circle, PlayCircle } from "lucide-react";

interface AgendaListProps {
  completedTicketIds: string[];
  currentTicketId: string | null;
  onSelectTicket: (ticketId: string) => void;
  tickets: Ticket[];
}

export function AgendaList({
  completedTicketIds,
  currentTicketId,
  onSelectTicket,
  tickets,
}: AgendaListProps) {
  if (tickets.length === 0) {
    return (
      <div className="rounded-lg border border-dashed border-slate-200 p-6 text-center">
        <p className="text-sm text-slate-500">No tickets on agenda.</p>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      <p className="text-xs font-medium text-slate-500">
        Agenda ({completedTicketIds.length} / {tickets.length} completed)
      </p>
      <div className="space-y-1">
        {tickets.map((ticket, index) => {
          const isCompleted = completedTicketIds.includes(ticket._id);
          const isCurrent = currentTicketId === ticket._id;

          return (
            <button
              key={ticket._id}
              onClick={() => onSelectTicket(ticket._id)}
              className={cn(
                "flex w-full cursor-pointer items-center gap-3 rounded-lg px-3 py-2 text-left transition-colors",
                isCurrent
                  ? "bg-indigo-50 ring-1 ring-indigo-200"
                  : "hover:bg-slate-50"
              )}
            >
              <span className="flex-shrink-0">
                {isCompleted ? (
                  <CheckCircle2 className="size-4 text-emerald-500" />
                ) : isCurrent ? (
                  <PlayCircle className="size-4 text-indigo-500" />
                ) : (
                  <Circle className="size-4 text-slate-300" />
                )}
              </span>
              <span className="flex-1 min-w-0">
                <span
                  className={cn(
                    "block truncate text-sm font-medium",
                    isCompleted ? "text-slate-400" : "text-slate-900"
                  )}
                >
                  {ticket.title}
                </span>
                <span className="flex items-center gap-2 mt-0.5">
                  <span className="text-[10px] font-mono text-slate-400">
                    {ticket.identifier}
                  </span>
                  <TicketStatusBadge status={ticket.status} size="sm" />
                </span>
              </span>
              <Badge variant="muted" className="flex-shrink-0 text-[10px]">
                #{index + 1}
              </Badge>
            </button>
          );
        })}
      </div>
    </div>
  );
}
