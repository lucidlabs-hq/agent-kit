/**
 * Client Queries and Mutations
 *
 * CRUD operations for client management.
 * Clients are manually managed in MVP, productive.io sync in Stage 2.
 */

import { mutation, query } from "../_generated/server";
import { v } from "convex/values";

// ============================================================================
// QUERIES
// ============================================================================

/**
 * Get all active clients
 */
export const getAll = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db
      .query("clients")
      .filter((q) => q.eq(q.field("isActive"), true))
      .collect();
  },
});

/**
 * Get all clients including inactive
 */
export const getAllIncludingInactive = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db.query("clients").collect();
  },
});

/**
 * Get client by ID
 */
export const getById = query({
  args: { id: v.id("clients") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

/**
 * Get client by Linear team key
 */
export const getByLinearTeamKey = query({
  args: { linearTeamKey: v.string() },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("clients")
      .withIndex("by_linear_team_key", (q) =>
        q.eq("linearTeamKey", args.linearTeamKey)
      )
      .first();
  },
});

// ============================================================================
// MUTATIONS
// ============================================================================

/**
 * Create a new client
 */
export const create = mutation({
  args: {
    linearTeamKey: v.string(),
    name: v.string(),
    productiveId: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("clients")
      .withIndex("by_linear_team_key", (q) =>
        q.eq("linearTeamKey", args.linearTeamKey)
      )
      .first();

    if (existing) {
      throw new Error(
        `Client with Linear team key "${args.linearTeamKey}" already exists`
      );
    }

    return await ctx.db.insert("clients", {
      isActive: true,
      linearTeamKey: args.linearTeamKey,
      name: args.name,
      productiveId: args.productiveId,
    });
  },
});

/**
 * Update an existing client
 */
export const update = mutation({
  args: {
    id: v.id("clients"),
    isActive: v.optional(v.boolean()),
    linearTeamKey: v.optional(v.string()),
    name: v.optional(v.string()),
    productiveId: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const { id, ...updates } = args;

    const client = await ctx.db.get(id);
    if (!client) {
      throw new Error("Client not found");
    }

    const cleanUpdates = Object.fromEntries(
      Object.entries(updates).filter(([, value]) => value !== undefined)
    );

    await ctx.db.patch(id, cleanUpdates);
    return await ctx.db.get(id);
  },
});

/**
 * Deactivate a client (soft delete)
 */
export const deactivate = mutation({
  args: { id: v.id("clients") },
  handler: async (ctx, args) => {
    const client = await ctx.db.get(args.id);
    if (!client) {
      throw new Error("Client not found");
    }

    await ctx.db.patch(args.id, { isActive: false });
    return await ctx.db.get(args.id);
  },
});
