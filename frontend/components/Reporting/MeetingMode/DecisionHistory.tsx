/**
 * DecisionHistory Component
 *
 * Display of past decisions for a ticket.
 * Shows exploration rounds with outcomes.
 */

import { Badge } from "@/components/ui/badge";
import type { Decision } from "@/lib/types/domain";
import { DECISION_OUTCOME_LABELS } from "@/lib/types/domain";
import { cn } from "@/lib/utils";
import { CheckCircle, RefreshCw, XCircle } from "lucide-react";

interface DecisionHistoryProps {
  decisions: Decision[];
}

const OUTCOME_STYLES: Record<string, { bg: string; icon: React.ReactNode; text: string }> = {
  go: {
    bg: "bg-emerald-100",
    icon: <CheckCircle className="size-4 text-emerald-600" />,
    text: "text-emerald-700",
  },
  iterate: {
    bg: "bg-amber-100",
    icon: <RefreshCw className="size-4 text-amber-600" />,
    text: "text-amber-700",
  },
  "no-go": {
    bg: "bg-red-100",
    icon: <XCircle className="size-4 text-red-600" />,
    text: "text-red-700",
  },
};

export function DecisionHistory({ decisions }: DecisionHistoryProps) {
  if (decisions.length === 0) {
    return (
      <div className="rounded-lg border border-dashed border-slate-200 p-4 text-center">
        <p className="text-sm text-slate-500">No decisions recorded yet.</p>
      </div>
    );
  }

  const sortedDecisions = [...decisions].sort(
    (a, b) => b.explorationRound - a.explorationRound
  );

  return (
    <div className="space-y-3">
      <p className="text-xs font-medium text-slate-500">Decision History</p>
      <div className="space-y-2">
        {sortedDecisions.map((decision) => {
          const style = OUTCOME_STYLES[decision.outcome];
          return (
            <div
              key={decision._id}
              className={cn("rounded-lg p-3", style.bg)}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  {style.icon}
                  <span className={cn("text-sm font-medium", style.text)}>
                    {DECISION_OUTCOME_LABELS[decision.outcome]}
                  </span>
                </div>
                <Badge variant="muted" className="text-[10px]">
                  Round {decision.explorationRound}
                </Badge>
              </div>
              <p className="mt-2 text-sm text-slate-700">{decision.reasoning}</p>
              <p className="mt-1 text-[10px] text-slate-400">
                by {decision.createdByEmail}
              </p>
            </div>
          );
        })}
      </div>
    </div>
  );
}
