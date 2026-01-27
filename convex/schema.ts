/**
 * Convex Database Schema
 *
 * Define your database tables here.
 * See: https://docs.convex.dev/database/schemas
 *
 * This is a template - customize for your domain.
 */

import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // ============================================================================
  // USERS
  // ============================================================================

  users: defineTable({
    email: v.string(),
    name: v.string(),
    avatarUrl: v.optional(v.string()),
    role: v.union(v.literal("admin"), v.literal("user"), v.literal("viewer")),
  })
    .index("by_email", ["email"]),

  // ============================================================================
  // TASKS (Example - customize for your domain)
  // ============================================================================

  tasks: defineTable({
    title: v.string(),
    description: v.optional(v.string()),
    status: v.union(
      v.literal("pending"),
      v.literal("in_progress"),
      v.literal("completed"),
      v.literal("cancelled")
    ),
    priority: v.union(
      v.literal("low"),
      v.literal("medium"),
      v.literal("high"),
      v.literal("urgent")
    ),
    assigneeId: v.optional(v.id("users")),
    dueDate: v.optional(v.number()), // Unix timestamp
  })
    .index("by_status", ["status"])
    .index("by_assignee", ["assigneeId"])
    .index("by_priority", ["priority"]),

  // ============================================================================
  // AI AGENT LOGS
  // ============================================================================

  agentActivities: defineTable({
    agentId: v.string(),
    type: v.union(
      v.literal("analyzing"),
      v.literal("generating"),
      v.literal("waiting_approval"),
      v.literal("completed"),
      v.literal("error")
    ),
    message: v.string(),
    metadata: v.optional(v.any()),
    taskId: v.optional(v.id("tasks")),
  })
    .index("by_agent", ["agentId"])
    .index("by_type", ["type"]),

  // ============================================================================
  // WORKFLOWS
  // ============================================================================

  workflows: defineTable({
    name: v.string(),
    description: v.optional(v.string()),
    triggerType: v.union(
      v.literal("manual"),
      v.literal("scheduled"),
      v.literal("event")
    ),
    steps: v.array(
      v.object({
        id: v.string(),
        order: v.number(),
        title: v.string(),
        description: v.optional(v.string()),
        isAutomated: v.boolean(),
      })
    ),
    enabled: v.boolean(),
  })
    .index("by_trigger", ["triggerType"]),

  workflowExecutions: defineTable({
    workflowId: v.id("workflows"),
    status: v.union(
      v.literal("running"),
      v.literal("completed"),
      v.literal("failed"),
      v.literal("cancelled")
    ),
    currentStepId: v.optional(v.string()),
    startedAt: v.number(),
    completedAt: v.optional(v.number()),
    error: v.optional(v.string()),
  })
    .index("by_workflow", ["workflowId"])
    .index("by_status", ["status"]),

  // ============================================================================
  // VECTOR SEARCH (for RAG)
  // ============================================================================

  documents: defineTable({
    title: v.string(),
    content: v.string(),
    embedding: v.optional(v.array(v.float64())),
    metadata: v.optional(v.any()),
  })
    .vectorIndex("by_embedding", {
      vectorField: "embedding",
      dimensions: 1536, // OpenAI ada-002 dimensions
      filterFields: [],
    }),
});
