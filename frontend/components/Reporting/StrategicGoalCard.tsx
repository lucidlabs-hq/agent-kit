/**
 * StrategicGoalCard Component
 *
 * Single goal display card with linked tickets count.
 * Supports edit/delete actions.
 */

"use client";

import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import type { StrategicGoal } from "@/lib/types/domain";
import { cn } from "@/lib/utils";
import { GripVertical, Pencil, Trash2, Target } from "lucide-react";

interface StrategicGoalCardProps {
  goal: StrategicGoal;
  linkedTicketCount: number;
  onDelete?: () => void;
  onEdit?: () => void;
}

export function StrategicGoalCard({
  goal,
  linkedTicketCount,
  onDelete,
  onEdit,
}: StrategicGoalCardProps) {
  return (
    <Card
      className={cn(
        "flex items-start gap-3 p-4",
        !goal.isActive && "opacity-50"
      )}
    >
      <div className="cursor-grab text-slate-300 hover:text-slate-400">
        <GripVertical className="size-5" />
      </div>

      <div className="flex-1">
        <div className="flex items-center gap-2">
          <Target className="size-4 text-indigo-500" />
          <h3 className="font-medium text-slate-900">{goal.name}</h3>
          {!goal.isActive && (
            <Badge variant="muted" className="text-[10px]">
              Inactive
            </Badge>
          )}
        </div>
        <p className="mt-1 text-sm text-slate-500">{goal.description}</p>
        <div className="mt-2 flex items-center gap-2">
          <Badge variant="default" className="text-[10px]">
            {linkedTicketCount} ticket{linkedTicketCount !== 1 ? "s" : ""}
          </Badge>
          <span className="text-[10px] text-slate-400">
            Priority #{goal.order}
          </span>
        </div>
      </div>

      <div className="flex items-center gap-1">
        {onEdit && (
          <Button
            variant="ghost"
            size="icon"
            className="size-8"
            onClick={onEdit}
          >
            <Pencil className="size-3.5 text-slate-400" />
          </Button>
        )}
        {onDelete && (
          <Button
            variant="ghost"
            size="icon"
            className="size-8"
            onClick={onDelete}
          >
            <Trash2 className="size-3.5 text-slate-400" />
          </Button>
        )}
      </div>
    </Card>
  );
}
