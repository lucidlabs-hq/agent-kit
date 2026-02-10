/**
 * Client Meeting View Component
 *
 * Client-side component for meeting mode.
 * Supports starting, running, and ending meetings.
 */

"use client";

import { useCallback } from "react";
import { useQuery, useMutation } from "convex/react";
import { api } from "@convex/_generated/api";
import { ClientDetailHeader } from "@/components/Reporting/ClientDetailHeader";
import { MeetingPanel } from "@/components/Reporting/MeetingMode/MeetingPanel";
import { toId } from "@/lib/convex-helpers";
import type {
  Client,
  Contingent,
  Ticket,
  Meeting,
  Decision,
  DecisionOutcome,
} from "@/lib/types/domain";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";
import { useConvexConfig } from "@/components/providers/convex-provider";
import { ConvexNotConfigured } from "@/components/Reporting/ConvexNotConfigured";

interface ClientMeetingViewProps {
  clientId: string;
}

// TODO: Replace with actual user email from auth
const CURRENT_USER_EMAIL = "user@example.com";

export function ClientMeetingView({ clientId }: ClientMeetingViewProps) {
  const { isConfigured } = useConvexConfig();

  if (!isConfigured) {
    return <ConvexNotConfigured subtitle="To use meeting mode, configure your Convex deployment." />;
  }

  return <ClientMeetingViewContent clientId={clientId} />;
}

function ClientMeetingViewContent({ clientId }: ClientMeetingViewProps) {
  const clientData = useQuery(api["functions/clients"].getById, {
    id: toId<"clients">(clientId),
  });
  const contingentData = useQuery(api["functions/contingents"].getByClient, {
    clientId: toId<"clients">(clientId),
  });
  const ticketsData = useQuery(api["functions/tickets"].getByClient, {
    clientId: toId<"clients">(clientId),
  });
  const activeMeeting = useQuery(api["functions/meetings"].getActiveMeeting, {
    clientId: toId<"clients">(clientId),
  });

  // Get decisions for active meeting's tickets
  const meetingDetails = useQuery(
    api["functions/meetings"].getWithDetails,
    activeMeeting ? { id: toId<"meetings">(activeMeeting._id) } : "skip"
  );

  const startMeeting = useMutation(api["functions/meetings"].start);
  const endMeeting = useMutation(api["functions/meetings"].end);
  const createDecision = useMutation(api["functions/decisions"].create);
  const addDecisionToMeeting = useMutation(api["functions/meetings"].addDecision);

  const handleStartMeeting = useCallback(
    async (ticketIds: string[]) => {
      try {
        await startMeeting({
          clientId: toId<"clients">(clientId),
          agendaTicketIds: ticketIds.map((id) => toId<"tickets">(id)),
          createdByEmail: CURRENT_USER_EMAIL,
        });
        toast.success("Meeting started");
      } catch (err) {
        const error = err as Error;
        toast.error(`Failed to start meeting: ${error.message}`);
      }
    },
    [clientId, startMeeting]
  );

  const handleEndMeeting = useCallback(async () => {
    if (!activeMeeting) return;

    try {
      await endMeeting({ id: toId<"meetings">(activeMeeting._id) });
      toast.success("Meeting ended");
    } catch (err) {
      const error = err as Error;
      toast.error(`Failed to end meeting: ${error.message}`);
    }
  }, [activeMeeting, endMeeting]);

  const handleRecordDecision = useCallback(
    async (ticketId: string, outcome: DecisionOutcome, reasoning: string) => {
      if (!activeMeeting) return;

      const ticket = ticketsData?.find((t) => t._id === ticketId);
      if (!ticket) return;

      try {
        const decisionId = await createDecision({
          ticketId: toId<"tickets">(ticketId),
          outcome,
          reasoning,
          explorationRound: (ticket.explorationRound || 0) + 1,
          createdByEmail: CURRENT_USER_EMAIL,
        });

        await addDecisionToMeeting({
          meetingId: toId<"meetings">(activeMeeting._id),
          decisionId: toId<"decisions">(decisionId),
        });

        toast.success(`Decision recorded: ${outcome}`);
      } catch (err) {
        const error = err as Error;
        toast.error(`Failed to record decision: ${error.message}`);
      }
    },
    [activeMeeting, ticketsData, createDecision, addDecisionToMeeting]
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

  const meeting: Meeting | null = activeMeeting
    ? {
        _id: activeMeeting._id,
        agendaTicketIds: activeMeeting.agendaTicketIds,
        clientId: activeMeeting.clientId,
        createdByEmail: activeMeeting.createdByEmail,
        decisionIds: activeMeeting.decisionIds,
        endedAt: activeMeeting.endedAt,
        startedAt: activeMeeting.startedAt,
      }
    : null;

  const decisions: Decision[] = (meetingDetails?.decisions || []).map((d) => ({
    _id: d._id,
    createdByEmail: d.createdByEmail,
    explorationRound: d.explorationRound,
    outcome: d.outcome,
    reasoning: d.reasoning,
    ticketId: d.ticketId,
  }));

  return (
    <div className="flex flex-col">
      <ClientDetailHeader client={client} contingent={contingent} />

      <div className="px-8 py-6">
        <MeetingPanel
          tickets={tickets}
          meeting={meeting}
          decisions={decisions}
          onStartMeeting={handleStartMeeting}
          onEndMeeting={handleEndMeeting}
          onRecordDecision={handleRecordDecision}
        />
      </div>
    </div>
  );
}
