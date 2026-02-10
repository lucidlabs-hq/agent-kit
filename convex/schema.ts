/**
 * Convex Database Schema
 *
 * Domain model for AI Agent Kit with Client Service Reporting.
 * See: https://docs.convex.dev/database/schemas
 */

import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // ============================================================================
  // USERS
  // ============================================================================

  users: defineTable({
    avatarUrl: v.optional(v.string()),
    email: v.string(),
    name: v.string(),
    role: v.union(v.literal("admin"), v.literal("user"), v.literal("viewer")),
  }).index("by_email", ["email"]),

  // ============================================================================
  // TASKS (Generic task management)
  // ============================================================================

  tasks: defineTable({
    assigneeId: v.optional(v.id("users")),
    description: v.optional(v.string()),
    dueDate: v.optional(v.number()),
    priority: v.union(
      v.literal("low"),
      v.literal("medium"),
      v.literal("high"),
      v.literal("urgent")
    ),
    status: v.union(
      v.literal("pending"),
      v.literal("in_progress"),
      v.literal("completed"),
      v.literal("cancelled")
    ),
    title: v.string(),
  })
    .index("by_status", ["status"])
    .index("by_assignee", ["assigneeId"])
    .index("by_priority", ["priority"]),

  // ============================================================================
  // AI AGENT LOGS
  // ============================================================================

  agentActivities: defineTable({
    agentId: v.string(),
    message: v.string(),
    metadata: v.optional(v.any()),
    taskId: v.optional(v.id("tasks")),
    type: v.union(
      v.literal("analyzing"),
      v.literal("generating"),
      v.literal("waiting_approval"),
      v.literal("completed"),
      v.literal("error")
    ),
  })
    .index("by_agent", ["agentId"])
    .index("by_type", ["type"]),

  // ============================================================================
  // WORKFLOWS
  // ============================================================================

  workflows: defineTable({
    description: v.optional(v.string()),
    enabled: v.boolean(),
    name: v.string(),
    steps: v.array(
      v.object({
        description: v.optional(v.string()),
        id: v.string(),
        isAutomated: v.boolean(),
        order: v.number(),
        title: v.string(),
      })
    ),
    triggerType: v.union(
      v.literal("manual"),
      v.literal("scheduled"),
      v.literal("event")
    ),
  }).index("by_trigger", ["triggerType"]),

  workflowExecutions: defineTable({
    completedAt: v.optional(v.number()),
    currentStepId: v.optional(v.string()),
    error: v.optional(v.string()),
    startedAt: v.number(),
    status: v.union(
      v.literal("running"),
      v.literal("completed"),
      v.literal("failed"),
      v.literal("cancelled")
    ),
    workflowId: v.id("workflows"),
  })
    .index("by_workflow", ["workflowId"])
    .index("by_status", ["status"]),

  // ============================================================================
  // VECTOR SEARCH (for RAG)
  // ============================================================================

  documents: defineTable({
    content: v.string(),
    embedding: v.optional(v.array(v.float64())),
    metadata: v.optional(v.any()),
    title: v.string(),
  }).vectorIndex("by_embedding", {
    vectorField: "embedding",
    dimensions: 1536,
    filterFields: [],
  }),

  // ============================================================================
  // CLIENT SERVICE REPORTING - MVP (Stage 1)
  // ============================================================================

  /**
   * Clients (manually managed for MVP, productive.io sync in Stage 2)
   */
  clients: defineTable({
    isActive: v.boolean(),
    linearTeamKey: v.string(),
    name: v.string(),
    productiveId: v.optional(v.string()),
  }).index("by_linear_team_key", ["linearTeamKey"]),

  /**
   * Strategic goals per client
   */
  strategicGoals: defineTable({
    clientId: v.id("clients"),
    description: v.string(),
    isActive: v.boolean(),
    name: v.string(),
    order: v.number(),
  }).index("by_client", ["clientId"]),

  /**
   * Linear tickets (read-only sync from Linear)
   */
  tickets: defineTable({
    clientId: v.id("clients"),
    explorationFindings: v.optional(v.string()),
    explorationRound: v.optional(v.number()),
    identifier: v.string(),
    linearId: v.string(),
    linearUpdatedAt: v.string(),
    riskLevel: v.optional(
      v.union(v.literal("low"), v.literal("medium"), v.literal("high"))
    ),
    status: v.union(
      v.literal("backlog"),
      v.literal("exploration"),
      v.literal("decision"),
      v.literal("delivery"),
      v.literal("review"),
      v.literal("done"),
      v.literal("dropped")
    ),
    strategicGoalId: v.optional(v.id("strategicGoals")),
    title: v.string(),
    userStory: v.optional(v.string()),
    workType: v.union(v.literal("standard"), v.literal("maintenance")),
  })
    .index("by_client", ["clientId"])
    .index("by_status", ["clientId", "status"])
    .index("by_linear_id", ["linearId"]),

  /**
   * Decisions (created in Meeting Mode)
   */
  decisions: defineTable({
    createdByEmail: v.string(),
    explorationRound: v.number(),
    outcome: v.union(
      v.literal("go"),
      v.literal("iterate"),
      v.literal("no-go")
    ),
    reasoning: v.string(),
    ticketId: v.id("tickets"),
  }).index("by_ticket", ["ticketId"]),

  /**
   * Contingents (manual for MVP, productive.io sync in Stage 2)
   */
  contingents: defineTable({
    clientId: v.id("clients"),
    lastUpdatedAt: v.string(),
    period: v.optional(v.string()),
    source: v.union(v.literal("manual"), v.literal("productive")),
    totalHours: v.number(),
    usedHours: v.number(),
  }).index("by_client", ["clientId"]),

  /**
   * Meeting sessions for audit trail
   */
  meetings: defineTable({
    agendaTicketIds: v.array(v.id("tickets")),
    clientId: v.id("clients"),
    createdByEmail: v.string(),
    decisionIds: v.array(v.id("decisions")),
    endedAt: v.optional(v.string()),
    startedAt: v.string(),
  }).index("by_client", ["clientId"]),
});
