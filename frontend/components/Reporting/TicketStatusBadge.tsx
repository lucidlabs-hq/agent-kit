/**
 * TicketStatusBadge Component
 *
 * Visual status indicator for ticket workflow states.
 * Uses indigo intensity scale per design system.
 */

import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import type { TicketStatus } from "@/lib/types/domain";
import { TICKET_STATUS_LABELS } from "@/lib/types/domain";

interface TicketStatusBadgeProps {
  size?: "default" | "sm";
  status: TicketStatus;
}

const STATUS_STYLES: Record<TicketStatus, string> = {
  backlog: "bg-slate-100 text-slate-600",
  decision: "bg-violet-100 text-violet-700",
  delivery: "bg-indigo-100 text-indigo-700",
  done: "bg-emerald-100 text-emerald-700",
  dropped: "bg-slate-200 text-slate-500",
  exploration: "bg-amber-100 text-amber-700",
  review: "bg-cyan-100 text-cyan-700",
};

export function TicketStatusBadge({
  size = "default",
  status,
}: TicketStatusBadgeProps) {
  return (
    <Badge
      className={cn(
        STATUS_STYLES[status],
        size === "sm" && "px-1.5 py-0.5 text-[10px]"
      )}
    >
      {TICKET_STATUS_LABELS[status]}
    </Badge>
  );
}
