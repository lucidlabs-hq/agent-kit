/**
 * Client Goals View Component
 *
 * Client-side component for strategic goals management.
 */

"use client";

import { useCallback, useState } from "react";
import { useQuery, useMutation } from "convex/react";
import { api } from "@convex/_generated/api";
import { ClientDetailHeader } from "@/components/Reporting/ClientDetailHeader";
import { StrategicGoalList } from "@/components/Reporting/StrategicGoalList";
import { GoalFormSheet, GoalFormData } from "@/components/Reporting/GoalFormSheet";
import { toId } from "@/lib/convex-helpers";
import type { Client, Contingent, Ticket, StrategicGoal } from "@/lib/types/domain";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";
import { useConvexConfig } from "@/components/providers/convex-provider";
import { ConvexNotConfigured } from "@/components/Reporting/ConvexNotConfigured";

interface ClientGoalsViewProps {
  clientId: string;
}

export function ClientGoalsView({ clientId }: ClientGoalsViewProps) {
  const { isConfigured } = useConvexConfig();

  if (!isConfigured) {
    return <ConvexNotConfigured subtitle="To manage goals, configure your Convex deployment." />;
  }

  return <ClientGoalsViewContent clientId={clientId} />;
}

function ClientGoalsViewContent({ clientId }: ClientGoalsViewProps) {
  const [formOpen, setFormOpen] = useState(false);
  const [formMode, setFormMode] = useState<"create" | "edit">("create");
  const [editingGoal, setEditingGoal] = useState<StrategicGoal | null>(null);

  const clientData = useQuery(api["functions/clients"].getById, {
    id: toId<"clients">(clientId),
  });
  const contingentData = useQuery(api["functions/contingents"].getByClient, {
    clientId: toId<"clients">(clientId),
  });
  const goalsData = useQuery(api["functions/strategicGoals"].getByClient, {
    clientId: toId<"clients">(clientId),
  });
  const ticketsData = useQuery(api["functions/tickets"].getByClient, {
    clientId: toId<"clients">(clientId),
  });

  const createGoal = useMutation(api["functions/strategicGoals"].create);
  const updateGoal = useMutation(api["functions/strategicGoals"].update);
  const removeGoal = useMutation(api["functions/strategicGoals"].remove);
  const reorderGoals = useMutation(api["functions/strategicGoals"].reorder);

  const handleCreate = useCallback(() => {
    setEditingGoal(null);
    setFormMode("create");
    setFormOpen(true);
  }, []);

  const handleEdit = useCallback(
    (goalId: string) => {
      const goal = goalsData?.find((g) => g._id === goalId);
      if (goal) {
        setEditingGoal({
          _id: goal._id,
          clientId: goal.clientId,
          description: goal.description,
          isActive: goal.isActive,
          name: goal.name,
          order: goal.order,
        });
        setFormMode("edit");
        setFormOpen(true);
      }
    },
    [goalsData]
  );

  const handleFormSubmit = useCallback(
    async (data: GoalFormData) => {
      if (formMode === "create") {
        await createGoal({
          clientId: toId<"clients">(clientId),
          name: data.name,
          description: data.description,
        });
        toast.success("Goal created");
      } else if (editingGoal) {
        await updateGoal({
          id: toId<"strategicGoals">(editingGoal._id),
          name: data.name,
          description: data.description,
        });
        toast.success("Goal updated");
      }
    },
    [clientId, createGoal, updateGoal, formMode, editingGoal]
  );

  const handleDelete = useCallback(
    (goalId: string) => {
      if (!confirm("Are you sure you want to delete this goal?")) return;

      removeGoal({ id: toId<"strategicGoals">(goalId) })
        .then(() => toast.success("Goal deleted"))
        .catch((err: Error) => toast.error(`Failed to delete goal: ${err.message}`));
    },
    [removeGoal]
  );

  const handleReorder = useCallback(
    (goalIds: string[]) => {
      reorderGoals({
        clientId: toId<"clients">(clientId),
        goalIds: goalIds.map((id) => toId<"strategicGoals">(id)),
      }).catch((err: Error) => toast.error(`Failed to reorder goals: ${err.message}`));
    },
    [clientId, reorderGoals]
  );

  if (clientData === undefined) {
    return (
      <div className="flex items-center justify-center py-16">
        <Loader2 className="size-6 animate-spin text-slate-400" />
      </div>
    );
  }

  if (clientData === null) {
    return (
      <div className="flex items-center justify-center py-16">
        <p className="text-sm text-slate-500">Client not found.</p>
      </div>
    );
  }

  const client: Client = {
    _id: clientData._id,
    isActive: clientData.isActive,
    linearTeamKey: clientData.linearTeamKey,
    name: clientData.name,
    productiveId: clientData.productiveId,
  };

  const contingent: Contingent | null = contingentData
    ? {
        _id: contingentData._id,
        clientId: contingentData.clientId,
        lastUpdatedAt: contingentData.lastUpdatedAt,
        period: contingentData.period,
        source: contingentData.source,
        totalHours: contingentData.totalHours,
        usedHours: contingentData.usedHours,
      }
    : null;

  const goals: StrategicGoal[] = (goalsData || []).map((g) => ({
    _id: g._id,
    clientId: g.clientId,
    description: g.description,
    isActive: g.isActive,
    name: g.name,
    order: g.order,
  }));

  const tickets: Ticket[] = (ticketsData || []).map((t) => ({
    _id: t._id,
    clientId: t.clientId,
    explorationFindings: t.explorationFindings,
    explorationRound: t.explorationRound,
    identifier: t.identifier,
    linearId: t.linearId,
    linearUpdatedAt: t.linearUpdatedAt,
    riskLevel: t.riskLevel,
    status: t.status,
    strategicGoalId: t.strategicGoalId,
    title: t.title,
    userStory: t.userStory,
    workType: t.workType,
  }));

  return (
    <div className="flex flex-col">
      <ClientDetailHeader client={client} contingent={contingent} />

      <div className="px-8 py-6">
        <StrategicGoalList
          goals={goals}
          tickets={tickets}
          onCreate={handleCreate}
          onEdit={handleEdit}
          onDelete={handleDelete}
          onReorder={handleReorder}
        />
      </div>

      <GoalFormSheet
        open={formOpen}
        onOpenChange={setFormOpen}
        onSubmit={handleFormSubmit}
        initialData={
          editingGoal
            ? { name: editingGoal.name, description: editingGoal.description }
            : undefined
        }
        mode={formMode}
      />
    </div>
  );
}
