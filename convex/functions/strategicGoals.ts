/**
 * Strategic Goals Queries and Mutations
 *
 * CRUD operations for client strategic goals.
 * Goals are used to categorize and prioritize tickets.
 */

import { mutation, query } from "../_generated/server";
import { v } from "convex/values";

// ============================================================================
// QUERIES
// ============================================================================

/**
 * Get all strategic goals for a client
 */
export const getByClient = query({
  args: { clientId: v.id("clients") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("strategicGoals")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .collect()
      .then((goals) => goals.sort((a, b) => a.order - b.order));
  },
});

/**
 * Get active strategic goals for a client
 */
export const getActiveByClient = query({
  args: { clientId: v.id("clients") },
  handler: async (ctx, args) => {
    const goals = await ctx.db
      .query("strategicGoals")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .collect();

    return goals
      .filter((goal) => goal.isActive)
      .sort((a, b) => a.order - b.order);
  },
});

/**
 * Get strategic goal by ID
 */
export const getById = query({
  args: { id: v.id("strategicGoals") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

// ============================================================================
// MUTATIONS
// ============================================================================

/**
 * Create a new strategic goal
 */
export const create = mutation({
  args: {
    clientId: v.id("clients"),
    description: v.string(),
    name: v.string(),
    order: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const client = await ctx.db.get(args.clientId);
    if (!client) {
      throw new Error("Client not found");
    }

    const existingGoals = await ctx.db
      .query("strategicGoals")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .collect();

    const order = args.order ?? existingGoals.length + 1;

    return await ctx.db.insert("strategicGoals", {
      clientId: args.clientId,
      description: args.description,
      isActive: true,
      name: args.name,
      order,
    });
  },
});

/**
 * Update a strategic goal
 */
export const update = mutation({
  args: {
    id: v.id("strategicGoals"),
    description: v.optional(v.string()),
    isActive: v.optional(v.boolean()),
    name: v.optional(v.string()),
    order: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const { id, ...updates } = args;

    const goal = await ctx.db.get(id);
    if (!goal) {
      throw new Error("Strategic goal not found");
    }

    const cleanUpdates = Object.fromEntries(
      Object.entries(updates).filter(([, value]) => value !== undefined)
    );

    await ctx.db.patch(id, cleanUpdates);
    return await ctx.db.get(id);
  },
});

/**
 * Delete a strategic goal
 */
export const remove = mutation({
  args: { id: v.id("strategicGoals") },
  handler: async (ctx, args) => {
    const goal = await ctx.db.get(args.id);
    if (!goal) {
      throw new Error("Strategic goal not found");
    }

    await ctx.db.delete(args.id);
  },
});

/**
 * Reorder strategic goals
 */
export const reorder = mutation({
  args: {
    clientId: v.id("clients"),
    goalIds: v.array(v.id("strategicGoals")),
  },
  handler: async (ctx, args) => {
    for (let i = 0; i < args.goalIds.length; i++) {
      await ctx.db.patch(args.goalIds[i], { order: i + 1 });
    }
  },
});
