/**
 * Convex Mutations
 *
 * Write operations for the database.
 * Changes trigger reactive updates in subscribed clients.
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";

// ============================================================================
// USER MUTATIONS
// ============================================================================

export const createUser = mutation({
  args: {
    email: v.string(),
    name: v.string(),
    avatarUrl: v.optional(v.string()),
    role: v.union(v.literal("admin"), v.literal("user"), v.literal("viewer")),
  },
  handler: async (ctx, args) => {
    // Check if user already exists
    const existing = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", args.email))
      .first();

    if (existing) {
      throw new Error("User with this email already exists");
    }

    return await ctx.db.insert("users", args);
  },
});

export const updateUser = mutation({
  args: {
    id: v.id("users"),
    name: v.optional(v.string()),
    avatarUrl: v.optional(v.string()),
    role: v.optional(v.union(v.literal("admin"), v.literal("user"), v.literal("viewer"))),
  },
  handler: async (ctx, args) => {
    const { id, ...updates } = args;

    // Remove undefined values
    const cleanUpdates = Object.fromEntries(
      Object.entries(updates).filter(([, v]) => v !== undefined)
    );

    await ctx.db.patch(id, cleanUpdates);
    return await ctx.db.get(id);
  },
});

// ============================================================================
// TASK MUTATIONS
// ============================================================================

export const createTask = mutation({
  args: {
    title: v.string(),
    description: v.optional(v.string()),
    status: v.optional(
      v.union(
        v.literal("pending"),
        v.literal("in_progress"),
        v.literal("completed"),
        v.literal("cancelled")
      )
    ),
    priority: v.optional(
      v.union(
        v.literal("low"),
        v.literal("medium"),
        v.literal("high"),
        v.literal("urgent")
      )
    ),
    assigneeId: v.optional(v.id("users")),
    dueDate: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("tasks", {
      title: args.title,
      description: args.description,
      status: args.status ?? "pending",
      priority: args.priority ?? "medium",
      assigneeId: args.assigneeId,
      dueDate: args.dueDate,
    });
  },
});

export const updateTask = mutation({
  args: {
    id: v.id("tasks"),
    title: v.optional(v.string()),
    description: v.optional(v.string()),
    status: v.optional(
      v.union(
        v.literal("pending"),
        v.literal("in_progress"),
        v.literal("completed"),
        v.literal("cancelled")
      )
    ),
    priority: v.optional(
      v.union(
        v.literal("low"),
        v.literal("medium"),
        v.literal("high"),
        v.literal("urgent")
      )
    ),
    assigneeId: v.optional(v.id("users")),
    dueDate: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const { id, ...updates } = args;

    const cleanUpdates = Object.fromEntries(
      Object.entries(updates).filter(([, v]) => v !== undefined)
    );

    await ctx.db.patch(id, cleanUpdates);
    return await ctx.db.get(id);
  },
});

export const deleteTask = mutation({
  args: { id: v.id("tasks") },
  handler: async (ctx, args) => {
    await ctx.db.delete(args.id);
  },
});

// ============================================================================
// AGENT ACTIVITY MUTATIONS
// ============================================================================

export const logAgentActivity = mutation({
  args: {
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
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("agentActivities", args);
  },
});

// ============================================================================
// WORKFLOW MUTATIONS
// ============================================================================

export const createWorkflow = mutation({
  args: {
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
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("workflows", {
      ...args,
      enabled: true,
    });
  },
});

export const updateWorkflow = mutation({
  args: {
    id: v.id("workflows"),
    name: v.optional(v.string()),
    description: v.optional(v.string()),
    enabled: v.optional(v.boolean()),
    steps: v.optional(
      v.array(
        v.object({
          id: v.string(),
          order: v.number(),
          title: v.string(),
          description: v.optional(v.string()),
          isAutomated: v.boolean(),
        })
      )
    ),
  },
  handler: async (ctx, args) => {
    const { id, ...updates } = args;

    const cleanUpdates = Object.fromEntries(
      Object.entries(updates).filter(([, v]) => v !== undefined)
    );

    await ctx.db.patch(id, cleanUpdates);
    return await ctx.db.get(id);
  },
});

export const startWorkflowExecution = mutation({
  args: { workflowId: v.id("workflows") },
  handler: async (ctx, args) => {
    const workflow = await ctx.db.get(args.workflowId);
    if (!workflow) {
      throw new Error("Workflow not found");
    }
    if (!workflow.enabled) {
      throw new Error("Workflow is disabled");
    }

    const firstStep = workflow.steps.find((s) => s.order === 1);

    return await ctx.db.insert("workflowExecutions", {
      workflowId: args.workflowId,
      status: "running",
      currentStepId: firstStep?.id,
      startedAt: Date.now(),
    });
  },
});

export const updateWorkflowExecution = mutation({
  args: {
    id: v.id("workflowExecutions"),
    status: v.optional(
      v.union(
        v.literal("running"),
        v.literal("completed"),
        v.literal("failed"),
        v.literal("cancelled")
      )
    ),
    currentStepId: v.optional(v.string()),
    error: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const { id, ...updates } = args;

    const cleanUpdates: Record<string, unknown> = Object.fromEntries(
      Object.entries(updates).filter(([, v]) => v !== undefined)
    );

    // Add completedAt if status is terminal
    if (updates.status && ["completed", "failed", "cancelled"].includes(updates.status)) {
      cleanUpdates.completedAt = Date.now();
    }

    await ctx.db.patch(id, cleanUpdates);
    return await ctx.db.get(id);
  },
});
