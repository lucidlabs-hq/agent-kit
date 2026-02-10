/**
 * TicketRow Component
 *
 * Single row in the ticket table.
 * Displays ticket details with status badge.
 */

"use client";

import { Badge } from "@/components/ui/badge";
import { TicketStatusBadge } from "./TicketStatusBadge";
import type { Ticket, StrategicGoal } from "@/lib/types/domain";
import { WORK_TYPE_LABELS, RISK_LEVEL_LABELS } from "@/lib/types/domain";
import { cn } from "@/lib/utils";
import { AlertTriangle, ChevronDown, ChevronRight, Target } from "lucide-react";

interface TicketRowProps {
  expanded?: boolean;
  goal: StrategicGoal | null;
  onToggle?: () => void;
  ticket: Ticket;
}

export function TicketRow({
  expanded = false,
  goal,
  onToggle,
  ticket,
}: TicketRowProps) {
  return (
    <>
      <tr
        onClick={onToggle}
        className={cn(
          "border-b border-slate-100 transition-colors",
          onToggle && "cursor-pointer hover:bg-slate-50"
        )}
      >
        <td className="px-4 py-3">
          <div className="flex items-center gap-2">
            {onToggle && (
              <span className="text-slate-400">
                {expanded ? (
                  <ChevronDown className="size-4" />
                ) : (
                  <ChevronRight className="size-4" />
                )}
              </span>
            )}
            <span className="font-mono text-xs text-slate-400">
              {ticket.identifier}
            </span>
          </div>
        </td>
        <td className="px-4 py-3">
          <span className="text-sm font-medium text-slate-900">
            {ticket.title}
          </span>
        </td>
        <td className="px-4 py-3">
          <TicketStatusBadge status={ticket.status} />
        </td>
        <td className="px-4 py-3">
          <Badge variant="muted" className="text-[10px]">
            {WORK_TYPE_LABELS[ticket.workType]}
          </Badge>
        </td>
        <td className="px-4 py-3">
          {goal ? (
            <span className="flex items-center gap-1 text-xs text-slate-600">
              <Target className="size-3" />
              {goal.name}
            </span>
          ) : (
            <span className="text-xs text-slate-400">-</span>
          )}
        </td>
        <td className="px-4 py-3">
          {ticket.riskLevel ? (
            <span
              className={cn(
                "flex items-center gap-1 text-xs font-medium",
                ticket.riskLevel === "high" && "text-red-600",
                ticket.riskLevel === "medium" && "text-amber-600",
                ticket.riskLevel === "low" && "text-slate-500"
              )}
            >
              {ticket.riskLevel === "high" && (
                <AlertTriangle className="size-3" />
              )}
              {RISK_LEVEL_LABELS[ticket.riskLevel]}
            </span>
          ) : (
            <span className="text-xs text-slate-400">-</span>
          )}
        </td>
      </tr>

      {expanded && ticket.explorationFindings && (
        <tr className="bg-slate-50">
          <td colSpan={6} className="px-4 py-3">
            <div className="pl-6">
              <p className="text-xs font-medium text-slate-500">
                Exploration Findings (Round {ticket.explorationRound || 1})
              </p>
              <p className="mt-1 text-sm text-slate-700 whitespace-pre-wrap">
                {ticket.explorationFindings}
              </p>
            </div>
          </td>
        </tr>
      )}
    </>
  );
}
