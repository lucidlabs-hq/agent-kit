/**
 * Convex Queries
 *
 * Read-only database operations.
 * These run reactively - UI updates automatically when data changes.
 */

import { query } from "../_generated/server";
import { v } from "convex/values";

// ============================================================================
// USER QUERIES
// ============================================================================

export const getUser = query({
  args: { email: v.string() },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", args.email))
      .first();
  },
});

export const listUsers = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db.query("users").collect();
  },
});

// ============================================================================
// TASK QUERIES
// ============================================================================

export const getTask = query({
  args: { id: v.id("tasks") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

export const listTasks = query({
  args: {
    status: v.optional(
      v.union(
        v.literal("pending"),
        v.literal("in_progress"),
        v.literal("completed"),
        v.literal("cancelled")
      )
    ),
  },
  handler: async (ctx, args) => {
    if (args.status) {
      return await ctx.db
        .query("tasks")
        .withIndex("by_status", (q) => q.eq("status", args.status!))
        .collect();
    }
    return await ctx.db.query("tasks").collect();
  },
});

export const getTasksByAssignee = query({
  args: { assigneeId: v.id("users") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("tasks")
      .withIndex("by_assignee", (q) => q.eq("assigneeId", args.assigneeId))
      .collect();
  },
});

// ============================================================================
// AGENT ACTIVITY QUERIES
// ============================================================================

export const listAgentActivities = query({
  args: {
    agentId: v.optional(v.string()),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    let query = ctx.db.query("agentActivities");

    if (args.agentId) {
      query = query.withIndex("by_agent", (q) => q.eq("agentId", args.agentId!));
    }

    const results = await query.order("desc").collect();

    if (args.limit) {
      return results.slice(0, args.limit);
    }
    return results;
  },
});

// ============================================================================
// WORKFLOW QUERIES
// ============================================================================

export const getWorkflow = query({
  args: { id: v.id("workflows") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

export const listWorkflows = query({
  args: {
    enabled: v.optional(v.boolean()),
  },
  handler: async (ctx, args) => {
    const workflows = await ctx.db.query("workflows").collect();

    if (args.enabled !== undefined) {
      return workflows.filter((w) => w.enabled === args.enabled);
    }
    return workflows;
  },
});

export const getWorkflowExecutions = query({
  args: {
    workflowId: v.id("workflows"),
    status: v.optional(
      v.union(
        v.literal("running"),
        v.literal("completed"),
        v.literal("failed"),
        v.literal("cancelled")
      )
    ),
  },
  handler: async (ctx, args) => {
    let query = ctx.db
      .query("workflowExecutions")
      .withIndex("by_workflow", (q) => q.eq("workflowId", args.workflowId));

    const results = await query.collect();

    if (args.status) {
      return results.filter((e) => e.status === args.status);
    }
    return results;
  },
});
