/**
 * Domain Types - Client Service Reporting
 *
 * Zod schemas for runtime validation and TypeScript types.
 * Single source of truth for domain model types.
 */

import { z } from "zod";

// ============================================================================
// TICKET STATUS
// ============================================================================

export const TicketStatusSchema = z.enum([
  "backlog",
  "exploration",
  "decision",
  "delivery",
  "review",
  "done",
  "dropped",
]);

export type TicketStatus = z.infer<typeof TicketStatusSchema>;

export const TICKET_STATUS_LABELS: Record<TicketStatus, string> = {
  backlog: "Backlog",
  decision: "Decision",
  delivery: "Delivery",
  done: "Done",
  dropped: "Dropped",
  exploration: "Exploration",
  review: "Review",
};

export const TICKET_STATUS_ORDER: TicketStatus[] = [
  "backlog",
  "exploration",
  "decision",
  "delivery",
  "review",
  "done",
  "dropped",
];

// ============================================================================
// WORK TYPE
// ============================================================================

export const WorkTypeSchema = z.enum(["standard", "maintenance"]);

export type WorkType = z.infer<typeof WorkTypeSchema>;

export const WORK_TYPE_LABELS: Record<WorkType, string> = {
  maintenance: "Maintenance",
  standard: "Standard",
};

// ============================================================================
// RISK LEVEL
// ============================================================================

export const RiskLevelSchema = z.enum(["low", "medium", "high"]);

export type RiskLevel = z.infer<typeof RiskLevelSchema>;

export const RISK_LEVEL_LABELS: Record<RiskLevel, string> = {
  high: "High",
  low: "Low",
  medium: "Medium",
};

// ============================================================================
// DECISION OUTCOME
// ============================================================================

export const DecisionOutcomeSchema = z.enum(["go", "iterate", "no-go"]);

export type DecisionOutcome = z.infer<typeof DecisionOutcomeSchema>;

export const DECISION_OUTCOME_LABELS: Record<DecisionOutcome, string> = {
  go: "Go",
  iterate: "Iterate",
  "no-go": "No-Go",
};

// ============================================================================
// CONTINGENT SOURCE
// ============================================================================

export const ContingentSourceSchema = z.enum(["manual", "productive"]);

export type ContingentSource = z.infer<typeof ContingentSourceSchema>;

export const CONTINGENT_SOURCE_LABELS: Record<ContingentSource, string> = {
  manual: "Manual",
  productive: "Productive.io",
};

// ============================================================================
// CLIENT
// ============================================================================

export const ClientSchema = z.object({
  _id: z.string(),
  isActive: z.boolean(),
  linearTeamKey: z.string(),
  name: z.string(),
  productiveId: z.string().optional(),
});

export type Client = z.infer<typeof ClientSchema>;

export const CreateClientSchema = z.object({
  linearTeamKey: z.string().min(1, "Linear team key is required"),
  name: z.string().min(1, "Name is required"),
  productiveId: z.string().optional(),
});

export type CreateClientInput = z.infer<typeof CreateClientSchema>;

// ============================================================================
// STRATEGIC GOAL
// ============================================================================

export const StrategicGoalSchema = z.object({
  _id: z.string(),
  clientId: z.string(),
  description: z.string(),
  isActive: z.boolean(),
  name: z.string(),
  order: z.number(),
});

export type StrategicGoal = z.infer<typeof StrategicGoalSchema>;

export const CreateStrategicGoalSchema = z.object({
  clientId: z.string(),
  description: z.string().min(1, "Description is required"),
  name: z.string().min(1, "Name is required"),
  order: z.number().optional(),
});

export type CreateStrategicGoalInput = z.infer<typeof CreateStrategicGoalSchema>;

// ============================================================================
// TICKET
// ============================================================================

export const TicketSchema = z.object({
  _id: z.string(),
  clientId: z.string(),
  explorationFindings: z.string().optional(),
  explorationRound: z.number().optional(),
  identifier: z.string(),
  linearId: z.string(),
  linearUpdatedAt: z.string(),
  riskLevel: RiskLevelSchema.optional(),
  status: TicketStatusSchema,
  strategicGoalId: z.string().optional(),
  title: z.string(),
  userStory: z.string().optional(),
  workType: WorkTypeSchema,
});

export type Ticket = z.infer<typeof TicketSchema>;

// ============================================================================
// DECISION
// ============================================================================

export const DecisionSchema = z.object({
  _id: z.string(),
  createdByEmail: z.string(),
  explorationRound: z.number(),
  outcome: DecisionOutcomeSchema,
  reasoning: z.string(),
  ticketId: z.string(),
});

export type Decision = z.infer<typeof DecisionSchema>;

export const CreateDecisionSchema = z.object({
  createdByEmail: z.string().email("Invalid email"),
  explorationRound: z.number().min(1, "Exploration round must be at least 1"),
  outcome: DecisionOutcomeSchema,
  reasoning: z.string().min(1, "Reasoning is required"),
  ticketId: z.string(),
});

export type CreateDecisionInput = z.infer<typeof CreateDecisionSchema>;

// ============================================================================
// CONTINGENT
// ============================================================================

export const ContingentSchema = z.object({
  _id: z.string(),
  clientId: z.string(),
  lastUpdatedAt: z.string(),
  period: z.string().optional(),
  source: ContingentSourceSchema,
  totalHours: z.number(),
  usedHours: z.number(),
});

export type Contingent = z.infer<typeof ContingentSchema>;

export const CreateContingentSchema = z.object({
  clientId: z.string(),
  period: z.string().optional(),
  totalHours: z.number().min(0, "Total hours must be non-negative"),
  usedHours: z.number().min(0, "Used hours must be non-negative").optional(),
});

export type CreateContingentInput = z.infer<typeof CreateContingentSchema>;

// ============================================================================
// MEETING
// ============================================================================

export const MeetingSchema = z.object({
  _id: z.string(),
  agendaTicketIds: z.array(z.string()),
  clientId: z.string(),
  createdByEmail: z.string(),
  decisionIds: z.array(z.string()),
  endedAt: z.string().optional(),
  startedAt: z.string(),
});

export type Meeting = z.infer<typeof MeetingSchema>;

export const StartMeetingSchema = z.object({
  agendaTicketIds: z.array(z.string()),
  clientId: z.string(),
  createdByEmail: z.string().email("Invalid email"),
});

export type StartMeetingInput = z.infer<typeof StartMeetingSchema>;

// ============================================================================
// DASHBOARD STATS
// ============================================================================

export const DashboardStatsSchema = z.object({
  byRiskLevel: z.object({
    high: z.number(),
    low: z.number(),
    medium: z.number(),
    unassessed: z.number(),
  }),
  byStatus: z.object({
    backlog: z.number(),
    decision: z.number(),
    delivery: z.number(),
    done: z.number(),
    dropped: z.number(),
    exploration: z.number(),
    review: z.number(),
  }),
  byWorkType: z.object({
    maintenance: z.number(),
    standard: z.number(),
  }),
  total: z.number(),
});

export type DashboardStats = z.infer<typeof DashboardStatsSchema>;

// ============================================================================
// CONTINGENT UTILIZATION
// ============================================================================

export const ContingentUtilizationSchema = z.object({
  contingent: ContingentSchema,
  remainingHours: z.number(),
  utilizationPercent: z.number(),
});

export type ContingentUtilization = z.infer<typeof ContingentUtilizationSchema>;
