/**
 * Contingent Queries and Mutations
 *
 * Operations for managing client hour contingents.
 * Manual entry for MVP, productive.io sync in Stage 2.
 */

import { mutation, query } from "../_generated/server";
import { v } from "convex/values";

// ============================================================================
// QUERIES
// ============================================================================

/**
 * Get contingent for a client
 */
export const getByClient = query({
  args: { clientId: v.id("clients") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("contingents")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .first();
  },
});

/**
 * Get all contingents for a client (historical)
 */
export const getAllByClient = query({
  args: { clientId: v.id("clients") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("contingents")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .collect();
  },
});

/**
 * Get contingent by ID
 */
export const getById = query({
  args: { id: v.id("contingents") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

/**
 * Get contingent utilization percentage
 */
export const getUtilization = query({
  args: { clientId: v.id("clients") },
  handler: async (ctx, args) => {
    const contingent = await ctx.db
      .query("contingents")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .first();

    if (!contingent) {
      return null;
    }

    const utilizationPercent =
      contingent.totalHours > 0
        ? Math.round((contingent.usedHours / contingent.totalHours) * 100)
        : 0;

    const remainingHours = contingent.totalHours - contingent.usedHours;

    return {
      contingent,
      remainingHours,
      utilizationPercent,
    };
  },
});

// ============================================================================
// MUTATIONS
// ============================================================================

/**
 * Create a new contingent for a client
 */
export const create = mutation({
  args: {
    clientId: v.id("clients"),
    period: v.optional(v.string()),
    totalHours: v.number(),
    usedHours: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const client = await ctx.db.get(args.clientId);
    if (!client) {
      throw new Error("Client not found");
    }

    const now = new Date().toISOString();

    return await ctx.db.insert("contingents", {
      clientId: args.clientId,
      lastUpdatedAt: now,
      period: args.period,
      source: "manual",
      totalHours: args.totalHours,
      usedHours: args.usedHours ?? 0,
    });
  },
});

/**
 * Update contingent values
 */
export const update = mutation({
  args: {
    id: v.id("contingents"),
    period: v.optional(v.string()),
    totalHours: v.optional(v.number()),
    usedHours: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const { id, ...updates } = args;

    const contingent = await ctx.db.get(id);
    if (!contingent) {
      throw new Error("Contingent not found");
    }

    const cleanUpdates = Object.fromEntries(
      Object.entries(updates).filter(([, value]) => value !== undefined)
    );

    const now = new Date().toISOString();

    await ctx.db.patch(id, {
      ...cleanUpdates,
      lastUpdatedAt: now,
    });

    return await ctx.db.get(id);
  },
});

/**
 * Add hours to used contingent
 */
export const addUsedHours = mutation({
  args: {
    hours: v.number(),
    id: v.id("contingents"),
  },
  handler: async (ctx, args) => {
    const contingent = await ctx.db.get(args.id);
    if (!contingent) {
      throw new Error("Contingent not found");
    }

    const now = new Date().toISOString();
    const newUsedHours = contingent.usedHours + args.hours;

    await ctx.db.patch(args.id, {
      lastUpdatedAt: now,
      usedHours: newUsedHours,
    });

    return await ctx.db.get(args.id);
  },
});

/**
 * Sync contingent from productive.io (Stage 2)
 */
export const syncFromProductive = mutation({
  args: {
    clientId: v.id("clients"),
    period: v.optional(v.string()),
    totalHours: v.number(),
    usedHours: v.number(),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("contingents")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .first();

    const now = new Date().toISOString();

    if (existing) {
      await ctx.db.patch(existing._id, {
        lastUpdatedAt: now,
        period: args.period,
        source: "productive",
        totalHours: args.totalHours,
        usedHours: args.usedHours,
      });
      return existing._id;
    }

    return await ctx.db.insert("contingents", {
      clientId: args.clientId,
      lastUpdatedAt: now,
      period: args.period,
      source: "productive",
      totalHours: args.totalHours,
      usedHours: args.usedHours,
    });
  },
});
