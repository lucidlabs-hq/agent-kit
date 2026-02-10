/**
 * Client Tickets View Component
 *
 * Client-side component showing ticket list with filtering.
 */

"use client";

import { useQuery } from "convex/react";
import { api } from "@convex/_generated/api";
import { ClientDetailHeader } from "@/components/Reporting/ClientDetailHeader";
import { TicketTable } from "@/components/Reporting/TicketTable";
import { toId } from "@/lib/convex-helpers";
import type { Client, Contingent, Ticket, StrategicGoal } from "@/lib/types/domain";
import { Loader2 } from "lucide-react";
import { useConvexConfig } from "@/components/providers/convex-provider";
import { ConvexNotConfigured } from "@/components/Reporting/ConvexNotConfigured";

interface ClientTicketsViewProps {
  clientId: string;
}

export function ClientTicketsView({ clientId }: ClientTicketsViewProps) {
  const { isConfigured } = useConvexConfig();

  if (!isConfigured) {
    return <ConvexNotConfigured subtitle="To view tickets, configure your Convex deployment." />;
  }

  return <ClientTicketsViewContent clientId={clientId} />;
}

function ClientTicketsViewContent({ clientId }: ClientTicketsViewProps) {
  const clientData = useQuery(api["functions/clients"].getById, {
    id: toId<"clients">(clientId),
  });
  const contingentData = useQuery(api["functions/contingents"].getByClient, {
    clientId: toId<"clients">(clientId),
  });
  const ticketsData = useQuery(api["functions/tickets"].getByClient, {
    clientId: toId<"clients">(clientId),
  });
  const goalsData = useQuery(api["functions/strategicGoals"].getActiveByClient, {
    clientId: toId<"clients">(clientId),
  });

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

  const goals: StrategicGoal[] = (goalsData || []).map((g) => ({
    _id: g._id,
    clientId: g.clientId,
    description: g.description,
    isActive: g.isActive,
    name: g.name,
    order: g.order,
  }));

  return (
    <div className="flex flex-col">
      <ClientDetailHeader client={client} contingent={contingent} />

      <div className="px-8 py-6">
        <TicketTable tickets={tickets} goals={goals} />
      </div>
    </div>
  );
}
