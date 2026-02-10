/**
 * MeetingPanel Component
 *
 * Main container for meeting mode.
 * Manages agenda, current ticket, and decision recording.
 */

"use client";

import { useState } from "react";
import { AgendaList } from "./AgendaList";
import { DecisionForm } from "./DecisionForm";
import { DecisionHistory } from "./DecisionHistory";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import type { Ticket, Meeting, Decision, DecisionOutcome } from "@/lib/types/domain";
import { Play, Square, CheckCircle2 } from "lucide-react";

interface MeetingPanelProps {
  decisions: Decision[];
  meeting: Meeting | null;
  onEndMeeting: () => void;
  onRecordDecision: (
    ticketId: string,
    outcome: DecisionOutcome,
    reasoning: string
  ) => void;
  onStartMeeting: (ticketIds: string[]) => void;
  tickets: Ticket[];
}

export function MeetingPanel({
  decisions,
  meeting,
  onEndMeeting,
  onRecordDecision,
  onStartMeeting,
  tickets,
}: MeetingPanelProps) {
  const [selectedTicketIds, setSelectedTicketIds] = useState<string[]>([]);
  const [currentTicketId, setCurrentTicketId] = useState<string | null>(null);

  const availableTickets = tickets.filter(
    (t) => t.status === "exploration" || t.status === "decision"
  );

  const agendaTickets = meeting
    ? tickets.filter((t) => meeting.agendaTicketIds.includes(t._id))
    : [];

  const currentTicket = agendaTickets.find((t) => t._id === currentTicketId);

  const completedTicketIds = decisions
    .map((d) => d.ticketId)
    .filter((id, index, self) => self.indexOf(id) === index);

  const currentDecisions = currentTicket
    ? decisions.filter((d) => d.ticketId === currentTicket._id)
    : [];

  const handleToggleTicket = (ticketId: string) => {
    setSelectedTicketIds((prev) =>
      prev.includes(ticketId)
        ? prev.filter((id) => id !== ticketId)
        : [...prev, ticketId]
    );
  };

  const handleStartMeeting = () => {
    onStartMeeting(selectedTicketIds);
    setSelectedTicketIds([]);
    if (selectedTicketIds.length > 0) {
      setCurrentTicketId(selectedTicketIds[0]);
    }
  };

  const handleRecordDecision = (outcome: DecisionOutcome, reasoning: string) => {
    if (!currentTicket) return;
    onRecordDecision(currentTicket._id, outcome, reasoning);

    const currentIndex = agendaTickets.findIndex(
      (t) => t._id === currentTicketId
    );
    const nextTicket = agendaTickets[currentIndex + 1];
    if (nextTicket) {
      setCurrentTicketId(nextTicket._id);
    }
  };

  if (!meeting) {
    return (
      <Card className="p-6">
        <div className="mb-6">
          <h2 className="text-lg font-semibold text-slate-900">Start Meeting</h2>
          <p className="mt-1 text-sm text-slate-500">
            Select tickets to discuss in this meeting.
          </p>
        </div>

        {availableTickets.length === 0 ? (
          <div className="rounded-lg border border-dashed border-slate-200 p-8 text-center">
            <p className="text-sm text-slate-500">
              No tickets in exploration or decision status.
            </p>
          </div>
        ) : (
          <>
            <div className="mb-4 space-y-2">
              {availableTickets.map((ticket) => (
                <label
                  key={ticket._id}
                  className="flex cursor-pointer items-center gap-3 rounded-lg border border-slate-200 p-3 transition-colors hover:bg-slate-50"
                >
                  <input
                    type="checkbox"
                    checked={selectedTicketIds.includes(ticket._id)}
                    onChange={() => handleToggleTicket(ticket._id)}
                    className="size-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500"
                  />
                  <div className="flex-1">
                    <p className="text-sm font-medium text-slate-900">
                      {ticket.title}
                    </p>
                    <p className="text-xs text-slate-400">{ticket.identifier}</p>
                  </div>
                </label>
              ))}
            </div>

            <Button
              onClick={handleStartMeeting}
              disabled={selectedTicketIds.length === 0}
            >
              <Play className="mr-2 size-4" />
              Start Meeting ({selectedTicketIds.length} tickets)
            </Button>
          </>
        )}
      </Card>
    );
  }

  const allCompleted = agendaTickets.every((t) =>
    completedTicketIds.includes(t._id)
  );

  return (
    <div className="grid gap-6 lg:grid-cols-3">
      {/* Agenda Sidebar */}
      <Card className="p-4 lg:col-span-1">
        <AgendaList
          tickets={agendaTickets}
          currentTicketId={currentTicketId}
          completedTicketIds={completedTicketIds}
          onSelectTicket={setCurrentTicketId}
        />

        <div className="mt-4 border-t border-slate-100 pt-4">
          {allCompleted ? (
            <Button onClick={onEndMeeting} className="w-full">
              <CheckCircle2 className="mr-2 size-4" />
              End Meeting
            </Button>
          ) : (
            <Button
              variant="secondary"
              onClick={onEndMeeting}
              className="w-full"
            >
              <Square className="mr-2 size-4" />
              End Meeting Early
            </Button>
          )}
        </div>
      </Card>

      {/* Main Content */}
      <div className="space-y-6 lg:col-span-2">
        {currentTicket ? (
          <>
            <Card className="p-6">
              <DecisionForm
                ticket={currentTicket}
                onDecision={handleRecordDecision}
              />
            </Card>

            {currentDecisions.length > 0 && (
              <Card className="p-6">
                <DecisionHistory decisions={currentDecisions} />
              </Card>
            )}
          </>
        ) : (
          <Card className="flex items-center justify-center p-12">
            <p className="text-sm text-slate-500">
              Select a ticket from the agenda to begin.
            </p>
          </Card>
        )}
      </div>
    </div>
  );
}
