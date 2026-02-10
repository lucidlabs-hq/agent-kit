/**
 * StrategicGoalList Component
 *
 * List of strategic goals with reorder support.
 * Displays linked ticket counts per goal.
 */

"use client";

import { StrategicGoalCard } from "./StrategicGoalCard";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import type { StrategicGoal, Ticket } from "@/lib/types/domain";
import { Plus } from "lucide-react";

interface StrategicGoalListProps {
  goals: StrategicGoal[];
  onCreate?: () => void;
  onDelete?: (goalId: string) => void;
  onEdit?: (goalId: string) => void;
  onReorder?: (goalIds: string[]) => void;
  tickets: Ticket[];
}

export function StrategicGoalList({
  goals,
  onCreate,
  onDelete,
  onEdit,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  onReorder,
  tickets,
}: StrategicGoalListProps) {
  // TODO: Implement drag-and-drop reordering with _onReorder
  const getLinkedCount = (goalId: string) => {
    return tickets.filter((t) => t.strategicGoalId === goalId).length;
  };

  if (goals.length === 0) {
    return (
      <Card className="flex flex-col items-center justify-center p-12 text-center">
        <div className="rounded-full bg-slate-100 p-3">
          <Plus className="size-6 text-slate-400" />
        </div>
        <h3 className="mt-4 text-sm font-medium text-slate-900">
          No strategic goals yet
        </h3>
        <p className="mt-1 text-sm text-slate-500">
          Create goals to categorize and prioritize tickets.
        </p>
        {onCreate && (
          <Button onClick={onCreate} className="mt-4">
            <Plus className="mr-2 size-4" />
            Create Goal
          </Button>
        )}
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <p className="text-sm text-slate-500">
          {goals.length} goal{goals.length !== 1 ? "s" : ""} • Drag to reorder
        </p>
        {onCreate && (
          <Button variant="secondary" size="sm" onClick={onCreate}>
            <Plus className="mr-1 size-3.5" />
            Add Goal
          </Button>
        )}
      </div>

      <div className="space-y-2">
        {goals.map((goal) => (
          <StrategicGoalCard
            key={goal._id}
            goal={goal}
            linkedTicketCount={getLinkedCount(goal._id)}
            onEdit={onEdit ? () => onEdit(goal._id) : undefined}
            onDelete={onDelete ? () => onDelete(goal._id) : undefined}
          />
        ))}
      </div>
    </div>
  );
}
