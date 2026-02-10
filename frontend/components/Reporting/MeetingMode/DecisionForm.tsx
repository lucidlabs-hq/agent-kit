/**
 * DecisionForm Component
 *
 * Form for recording go/iterate/no-go decisions.
 * Requires reasoning before submission.
 */

"use client";

import { useState } from "react";
import { SegmentedDecision } from "@/components/ui/segmented-decision";
import { Button } from "@/components/ui/button";
import type { Ticket, DecisionOutcome } from "@/lib/types/domain";
import { DECISION_OUTCOME_LABELS } from "@/lib/types/domain";
import { Send } from "lucide-react";

interface DecisionFormProps {
  disabled?: boolean;
  onDecision: (outcome: DecisionOutcome, reasoning: string) => void;
  ticket: Ticket;
}

const DECISION_OPTIONS: { value: DecisionOutcome; label: string }[] = [
  { value: "go", label: DECISION_OUTCOME_LABELS.go },
  { value: "iterate", label: DECISION_OUTCOME_LABELS.iterate },
  { value: "no-go", label: DECISION_OUTCOME_LABELS["no-go"] },
];

export function DecisionForm({ disabled, onDecision, ticket }: DecisionFormProps) {
  const [outcome, setOutcome] = useState<DecisionOutcome>("go");
  const [reasoning, setReasoning] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!reasoning.trim()) return;
    onDecision(outcome, reasoning.trim());
    setReasoning("");
  };

  const currentRound = (ticket.explorationRound || 0) + 1;

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <p className="text-xs font-medium text-slate-500">
          Decision for Exploration Round {currentRound}
        </p>
        <p className="mt-1 text-sm font-medium text-slate-900">{ticket.title}</p>
        <p className="mt-0.5 font-mono text-xs text-slate-400">
          {ticket.identifier}
        </p>
      </div>

      {ticket.explorationFindings && (
        <div className="rounded-lg bg-slate-50 p-3">
          <p className="text-xs font-medium text-slate-500">
            Current Exploration Findings
          </p>
          <p className="mt-1 text-sm text-slate-700 whitespace-pre-wrap">
            {ticket.explorationFindings}
          </p>
        </div>
      )}

      <SegmentedDecision
        options={DECISION_OPTIONS}
        value={outcome}
        onChange={setOutcome}
        disabled={disabled}
        label="Decision Outcome"
      />

      <div>
        <label
          htmlFor="reasoning"
          className="block text-xs font-medium text-slate-500"
        >
          Reasoning (required)
        </label>
        <textarea
          id="reasoning"
          value={reasoning}
          onChange={(e) => setReasoning(e.target.value)}
          disabled={disabled}
          placeholder="Explain the decision rationale..."
          className="mt-1 w-full rounded-lg border border-slate-200 px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 focus:border-indigo-300 focus:outline-none focus:ring-1 focus:ring-indigo-200 disabled:opacity-50"
          rows={4}
          required
        />
      </div>

      <Button type="submit" disabled={disabled || !reasoning.trim()}>
        <Send className="mr-2 size-4" />
        Record Decision
      </Button>
    </form>
  );
}
