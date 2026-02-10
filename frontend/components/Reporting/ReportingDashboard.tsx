/**
 * Reporting Dashboard Client Component
 *
 * Client-side component for the reporting dashboard.
 * Fetches and displays all clients with stats and contingent status.
 */

"use client";

import { useState, useCallback } from "react";
import { useQuery, useMutation } from "convex/react";
import { api } from "@convex/_generated/api";
import { AppHeader } from "@/components/Layout/app-header";
import { ClientCard } from "@/components/Reporting/ClientCard";
import { ClientFormSheet, ClientFormData } from "@/components/Reporting/ClientFormSheet";
import { Button } from "@/components/ui/button";
import { useConvexConfig } from "@/components/providers/convex-provider";
import { toId } from "@/lib/convex-helpers";
import { Plus, Loader2 } from "lucide-react";
import { ConvexNotConfigured } from "@/components/Reporting/ConvexNotConfigured";
import { toast } from "sonner";
import type { Client, Contingent, DashboardStats } from "@/lib/types/domain";

export function ReportingDashboard() {
  const { isConfigured } = useConvexConfig();

  if (!isConfigured) {
    return <ConvexSetupMessage />;
  }

  return <ReportingDashboardContent />;
}

function ConvexSetupMessage() {
  return (
    <div className="flex flex-col">
      <AppHeader
        title="Client Reporting"
        subtitle="Monitor client service delivery and contingent usage"
      />
      <ConvexNotConfigured subtitle="To use the reporting dashboard, configure your Convex deployment." />
    </div>
  );
}

function ReportingDashboardContent() {
  const [formOpen, setFormOpen] = useState(false);
  const clients = useQuery(api["functions/clients"].getAll);
  const createClient = useMutation(api["functions/clients"].create);

  const handleCreateClient = useCallback(
    async (data: ClientFormData) => {
      await createClient({
        name: data.name,
        linearTeamKey: data.linearTeamKey,
        productiveId: data.productiveId,
      });
      toast.success("Client created");
    },
    [createClient]
  );

  if (clients === undefined) {
    return (
      <div className="flex flex-col">
        <AppHeader
          title="Client Reporting"
          subtitle="Monitor client service delivery and contingent usage"
        />
        <div className="flex items-center justify-center px-8 py-16">
          <Loader2 className="size-6 animate-spin text-slate-400" />
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col">
      <AppHeader
        title="Client Reporting"
        subtitle="Monitor client service delivery and contingent usage"
        rightContent={
          <Button onClick={() => setFormOpen(true)} className="cursor-pointer">
            <Plus className="mr-2 size-4" />
            Add Client
          </Button>
        }
      />

      <div className="px-8 pb-8">
        <ClientListWithData clients={clients} />
      </div>

      <ClientFormSheet
        open={formOpen}
        onOpenChange={setFormOpen}
        onSubmit={handleCreateClient}
        mode="create"
      />
    </div>
  );
}

interface ClientListWithDataProps {
  clients: Array<{
    _id: string;
    isActive: boolean;
    linearTeamKey: string;
    name: string;
    productiveId?: string;
  }>;
}

function ClientListWithData({ clients }: ClientListWithDataProps) {
  const clientsWithData = clients.map((client) => {
    const clientData: Client = {
      _id: client._id,
      isActive: client.isActive,
      linearTeamKey: client.linearTeamKey,
      name: client.name,
      productiveId: client.productiveId,
    };

    return {
      client: clientData,
      clientId: client._id,
    };
  });

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {clientsWithData.length === 0 ? (
        <div className="col-span-full rounded-xl border border-dashed border-slate-200 p-12 text-center">
          <p className="text-sm text-slate-500">No clients found.</p>
          <p className="mt-1 text-xs text-slate-400">
            Create a client to get started.
          </p>
        </div>
      ) : (
        clientsWithData.map(({ client, clientId }) => (
          <ClientCardWithData key={clientId} client={client} />
        ))
      )}
    </div>
  );
}

interface ClientCardWithDataProps {
  client: Client;
}

function ClientCardWithData({ client }: ClientCardWithDataProps) {
  const stats = useQuery(api["functions/tickets"].getDashboardStats, {
    clientId: toId<"clients">(client._id),
  });
  const contingent = useQuery(api["functions/contingents"].getByClient, {
    clientId: toId<"clients">(client._id),
  });

  const defaultStats: DashboardStats = {
    byRiskLevel: { high: 0, low: 0, medium: 0, unassessed: 0 },
    byStatus: {
      backlog: 0,
      decision: 0,
      delivery: 0,
      done: 0,
      dropped: 0,
      exploration: 0,
      review: 0,
    },
    byWorkType: { maintenance: 0, standard: 0 },
    total: 0,
  };

  const contingentData: Contingent | null = contingent
    ? {
        _id: contingent._id,
        clientId: contingent.clientId,
        lastUpdatedAt: contingent.lastUpdatedAt,
        period: contingent.period,
        source: contingent.source,
        totalHours: contingent.totalHours,
        usedHours: contingent.usedHours,
      }
    : null;

  return (
    <ClientCard
      client={client}
      contingent={contingentData}
      stats={stats || defaultStats}
    />
  );
}
