/**
 * Decision Queries and Mutations
 *
 * Operations for recording exploration decisions in meeting mode.
 * Decisions capture the outcome of ticket exploration rounds.
 */

import { mutation, query } from "../_generated/server";
import { v } from "convex/values";

// ============================================================================
// QUERIES
// ============================================================================

/**
 * Get all decisions for a ticket
 */
export const getByTicket = query({
  args: { ticketId: v.id("tickets") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("decisions")
      .withIndex("by_ticket", (q) => q.eq("ticketId", args.ticketId))
      .collect();
  },
});

/**
 * Get decision by ID
 */
export const getById = query({
  args: { id: v.id("decisions") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

/**
 * Get latest decision for a ticket
 */
export const getLatestByTicket = query({
  args: { ticketId: v.id("tickets") },
  handler: async (ctx, args) => {
    const decisions = await ctx.db
      .query("decisions")
      .withIndex("by_ticket", (q) => q.eq("ticketId", args.ticketId))
      .collect();

    if (decisions.length === 0) {
      return null;
    }

    return decisions.reduce((latest, current) =>
      current.explorationRound > latest.explorationRound ? current : latest
    );
  },
});

/**
 * Get decision history with ticket details
 */
export const getHistoryByTicket = query({
  args: { ticketId: v.id("tickets") },
  handler: async (ctx, args) => {
    const ticket = await ctx.db.get(args.ticketId);
    if (!ticket) {
      throw new Error("Ticket not found");
    }

    const decisions = await ctx.db
      .query("decisions")
      .withIndex("by_ticket", (q) => q.eq("ticketId", args.ticketId))
      .collect();

    return {
      decisions: decisions.sort(
        (a, b) => a.explorationRound - b.explorationRound
      ),
      ticket,
    };
  },
});

// ============================================================================
// MUTATIONS
// ============================================================================

/**
 * Create a new decision
 */
export const create = mutation({
  args: {
    createdByEmail: v.string(),
    explorationRound: v.number(),
    outcome: v.union(
      v.literal("go"),
      v.literal("iterate"),
      v.literal("no-go")
    ),
    reasoning: v.string(),
    ticketId: v.id("tickets"),
  },
  handler: async (ctx, args) => {
    const ticket = await ctx.db.get(args.ticketId);
    if (!ticket) {
      throw new Error("Ticket not found");
    }

    const existingDecision = await ctx.db
      .query("decisions")
      .withIndex("by_ticket", (q) => q.eq("ticketId", args.ticketId))
      .collect()
      .then((decisions) =>
        decisions.find((d) => d.explorationRound === args.explorationRound)
      );

    if (existingDecision) {
      throw new Error(
        `Decision for exploration round ${args.explorationRound} already exists`
      );
    }

    const decisionId = await ctx.db.insert("decisions", {
      createdByEmail: args.createdByEmail,
      explorationRound: args.explorationRound,
      outcome: args.outcome,
      reasoning: args.reasoning,
      ticketId: args.ticketId,
    });

    await ctx.db.patch(args.ticketId, {
      explorationRound: args.explorationRound,
    });

    return decisionId;
  },
});

/**
 * Update decision reasoning (for corrections)
 */
export const updateReasoning = mutation({
  args: {
    id: v.id("decisions"),
    reasoning: v.string(),
  },
  handler: async (ctx, args) => {
    const decision = await ctx.db.get(args.id);
    if (!decision) {
      throw new Error("Decision not found");
    }

    await ctx.db.patch(args.id, { reasoning: args.reasoning });
    return await ctx.db.get(args.id);
  },
});
