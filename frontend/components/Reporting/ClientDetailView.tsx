/**
 * Client Detail View Component
 *
 * Client-side component showing client overview with stats and recent activity.
 */

"use client";

import { useQuery } from "convex/react";
import { api } from "@convex/_generated/api";
import { ClientDetailHeader } from "@/components/Reporting/ClientDetailHeader";
import { DashboardStats } from "@/components/Reporting/DashboardStats";
import { TicketStatusBadge } from "@/components/Reporting/TicketStatusBadge";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { toId } from "@/lib/convex-helpers";
import Link from "next/link";
import type { Client, Contingent, DashboardStats as DashboardStatsType, StrategicGoal } from "@/lib/types/domain";
import { ArrowRight, Target, Loader2 } from "lucide-react";
import { useConvexConfig } from "@/components/providers/convex-provider";
import { ConvexNotConfigured } from "@/components/Reporting/ConvexNotConfigured";

interface ClientDetailViewProps {
  clientId: string;
}

export function ClientDetailView({ clientId }: ClientDetailViewProps) {
  const { isConfigured } = useConvexConfig();

  if (!isConfigured) {
    return <ConvexNotConfigured subtitle="To view client details, configure your Convex deployment." />;
  }

  return <ClientDetailViewContent clientId={clientId} />;
}

function ClientDetailViewContent({ clientId }: ClientDetailViewProps) {
  const clientData = useQuery(api["functions/clients"].getById, {
    id: toId<"clients">(clientId),
  });
  const contingentData = useQuery(api["functions/contingents"].getByClient, {
    clientId: toId<"clients">(clientId),
  });
  const statsData = useQuery(api["functions/tickets"].getDashboardStats, {
    clientId: toId<"clients">(clientId),
  });
  const ticketsData = useQuery(api["functions/tickets"].getActiveTickets, {
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

  const defaultStats: DashboardStatsType = {
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

  const stats = statsData || defaultStats;
  const recentTickets = (ticketsData || []).slice(0, 5);
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
        <div className="grid gap-6 lg:grid-cols-3">
          {/* Stats Card */}
          <Card>
            <CardHeader>
              <CardTitle>Ticket Overview</CardTitle>
            </CardHeader>
            <CardContent>
              <DashboardStats stats={stats} />
            </CardContent>
          </Card>

          {/* Recent Tickets */}
          <Card className="lg:col-span-2">
            <CardHeader className="flex-row items-center justify-between">
              <CardTitle>Recent Activity</CardTitle>
              <Link
                href={`/reporting/${clientId}/tickets`}
                className="flex cursor-pointer items-center gap-1 text-sm text-indigo-600 hover:text-indigo-700"
              >
                View all
                <ArrowRight className="size-3.5" />
              </Link>
            </CardHeader>
            <CardContent>
              {recentTickets.length === 0 ? (
                <p className="py-4 text-center text-sm text-slate-500">
                  No active tickets.
                </p>
              ) : (
                <div className="space-y-3">
                  {recentTickets.map((ticket) => (
                    <div
                      key={ticket._id}
                      className="flex items-center justify-between rounded-lg border border-slate-100 p-3"
                    >
                      <div className="flex items-center gap-3">
                        <span className="font-mono text-xs text-slate-400">
                          {ticket.identifier}
                        </span>
                        <span className="text-sm font-medium text-slate-900">
                          {ticket.title}
                        </span>
                      </div>
                      <TicketStatusBadge status={ticket.status} />
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Strategic Goals */}
          <Card className="lg:col-span-3">
            <CardHeader className="flex-row items-center justify-between">
              <CardTitle>Strategic Goals</CardTitle>
              <Link
                href={`/reporting/${clientId}/goals`}
                className="flex cursor-pointer items-center gap-1 text-sm text-indigo-600 hover:text-indigo-700"
              >
                Manage
                <ArrowRight className="size-3.5" />
              </Link>
            </CardHeader>
            <CardContent>
              {goals.length === 0 ? (
                <p className="py-4 text-center text-sm text-slate-500">
                  No strategic goals defined.
                </p>
              ) : (
                <div className="flex flex-wrap gap-3">
                  {goals.map((goal) => (
                    <div
                      key={goal._id}
                      className="flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2"
                    >
                      <Target className="size-4 text-indigo-500" />
                      <span className="text-sm font-medium text-slate-900">
                        {goal.name}
                      </span>
                      <Badge variant="muted" className="text-[10px]">
                        #{goal.order}
                      </Badge>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
