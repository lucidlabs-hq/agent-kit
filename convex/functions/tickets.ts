/**
 * Ticket Queries
 *
 * Read-only operations for Linear tickets.
 * Tickets are synced from Linear and should not be modified directly.
 */

import { mutation, query } from "../_generated/server";
import { v } from "convex/values";

// ============================================================================
// QUERIES
// ============================================================================

/**
 * Get all tickets for a client
 */
export const getByClient = query({
  args: { clientId: v.id("clients") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("tickets")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .collect();
  },
});

/**
 * Get tickets by status for a client
 */
export const getByStatus = query({
  args: {
    clientId: v.id("clients"),
    status: v.union(
      v.literal("backlog"),
      v.literal("exploration"),
      v.literal("decision"),
      v.literal("delivery"),
      v.literal("review"),
      v.literal("done"),
      v.literal("dropped")
    ),
  },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("tickets")
      .withIndex("by_status", (q) =>
        q.eq("clientId", args.clientId).eq("status", args.status)
      )
      .collect();
  },
});

/**
 * Get ticket by ID
 */
export const getById = query({
  args: { id: v.id("tickets") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

/**
 * Get ticket by Linear ID
 */
export const getByLinearId = query({
  args: { linearId: v.string() },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("tickets")
      .withIndex("by_linear_id", (q) => q.eq("linearId", args.linearId))
      .first();
  },
});

/**
 * Get dashboard statistics for a client
 */
export const getDashboardStats = query({
  args: { clientId: v.id("clients") },
  handler: async (ctx, args) => {
    const tickets = await ctx.db
      .query("tickets")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .collect();

    const byStatus = {
      backlog: 0,
      decision: 0,
      delivery: 0,
      done: 0,
      dropped: 0,
      exploration: 0,
      review: 0,
    };

    const byWorkType = {
      maintenance: 0,
      standard: 0,
    };

    const byRiskLevel = {
      high: 0,
      low: 0,
      medium: 0,
      unassessed: 0,
    };

    for (const ticket of tickets) {
      byStatus[ticket.status]++;
      byWorkType[ticket.workType]++;

      if (ticket.riskLevel) {
        byRiskLevel[ticket.riskLevel]++;
      } else {
        byRiskLevel.unassessed++;
      }
    }

    return {
      byRiskLevel,
      byStatus,
      byWorkType,
      total: tickets.length,
    };
  },
});

/**
 * Get tickets grouped by strategic goal
 */
export const getByStrategicGoal = query({
  args: { strategicGoalId: v.id("strategicGoals") },
  handler: async (ctx, args) => {
    const goal = await ctx.db.get(args.strategicGoalId);
    if (!goal) {
      throw new Error("Strategic goal not found");
    }

    const allTickets = await ctx.db
      .query("tickets")
      .withIndex("by_client", (q) => q.eq("clientId", goal.clientId))
      .collect();

    return allTickets.filter(
      (ticket) => ticket.strategicGoalId === args.strategicGoalId
    );
  },
});

/**
 * Get tickets in active workflow states (exploration, decision, delivery, review)
 */
export const getActiveTickets = query({
  args: { clientId: v.id("clients") },
  handler: async (ctx, args) => {
    const tickets = await ctx.db
      .query("tickets")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .collect();

    const activeStatuses = ["exploration", "decision", "delivery", "review"];
    return tickets.filter((ticket) => activeStatuses.includes(ticket.status));
  },
});

// ============================================================================
// MUTATIONS (for Linear Sync)
// ============================================================================

/**
 * Upsert ticket from Linear sync
 * Creates or updates a ticket based on Linear ID
 */
export const upsertFromLinear = mutation({
  args: {
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
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("tickets")
      .withIndex("by_linear_id", (q) => q.eq("linearId", args.linearId))
      .first();

    if (existing) {
      await ctx.db.patch(existing._id, {
        explorationFindings: args.explorationFindings,
        explorationRound: args.explorationRound,
        identifier: args.identifier,
        linearUpdatedAt: args.linearUpdatedAt,
        riskLevel: args.riskLevel,
        status: args.status,
        strategicGoalId: args.strategicGoalId,
        title: args.title,
        userStory: args.userStory,
        workType: args.workType,
      });
      return existing._id;
    }

    return await ctx.db.insert("tickets", args);
  },
});

/**
 * Update ticket exploration data (used during meeting mode)
 */
export const updateExploration = mutation({
  args: {
    id: v.id("tickets"),
    explorationFindings: v.optional(v.string()),
    explorationRound: v.optional(v.number()),
    riskLevel: v.optional(
      v.union(v.literal("low"), v.literal("medium"), v.literal("high"))
    ),
  },
  handler: async (ctx, args) => {
    const { id, ...updates } = args;

    const ticket = await ctx.db.get(id);
    if (!ticket) {
      throw new Error("Ticket not found");
    }

    const cleanUpdates = Object.fromEntries(
      Object.entries(updates).filter(([, value]) => value !== undefined)
    );

    await ctx.db.patch(id, cleanUpdates);
    return await ctx.db.get(id);
  },
});

/**
 * Link ticket to strategic goal
 */
export const linkToStrategicGoal = mutation({
  args: {
    strategicGoalId: v.optional(v.id("strategicGoals")),
    ticketId: v.id("tickets"),
  },
  handler: async (ctx, args) => {
    const ticket = await ctx.db.get(args.ticketId);
    if (!ticket) {
      throw new Error("Ticket not found");
    }

    if (args.strategicGoalId) {
      const goal = await ctx.db.get(args.strategicGoalId);
      if (!goal) {
        throw new Error("Strategic goal not found");
      }
    }

    await ctx.db.patch(args.ticketId, {
      strategicGoalId: args.strategicGoalId,
    });
    return await ctx.db.get(args.ticketId);
  },
});
