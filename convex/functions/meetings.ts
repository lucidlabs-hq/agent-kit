/**
 * Meeting Session Management
 *
 * Operations for managing client meeting sessions.
 * Meetings track agenda items and decisions for audit trail.
 */

import { mutation, query } from "../_generated/server";
import { v } from "convex/values";

// ============================================================================
// QUERIES
// ============================================================================

/**
 * Get all meetings for a client
 */
export const getByClient = query({
  args: { clientId: v.id("clients") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("meetings")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .collect();
  },
});

/**
 * Get meeting by ID
 */
export const getById = query({
  args: { id: v.id("meetings") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

/**
 * Get active (ongoing) meeting for a client
 */
export const getActiveMeeting = query({
  args: { clientId: v.id("clients") },
  handler: async (ctx, args) => {
    const meetings = await ctx.db
      .query("meetings")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .collect();

    return meetings.find((meeting) => !meeting.endedAt) ?? null;
  },
});

/**
 * Get meeting with full details (tickets, decisions)
 */
export const getWithDetails = query({
  args: { id: v.id("meetings") },
  handler: async (ctx, args) => {
    const meeting = await ctx.db.get(args.id);
    if (!meeting) {
      throw new Error("Meeting not found");
    }

    const agendaTickets = await Promise.all(
      meeting.agendaTicketIds.map((ticketId) => ctx.db.get(ticketId))
    );

    const decisions = await Promise.all(
      meeting.decisionIds.map((decisionId) => ctx.db.get(decisionId))
    );

    return {
      agendaTickets: agendaTickets.filter(Boolean),
      decisions: decisions.filter(Boolean),
      meeting,
    };
  },
});

/**
 * Get recent meetings for a client
 */
export const getRecentByClient = query({
  args: {
    clientId: v.id("clients"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const meetings = await ctx.db
      .query("meetings")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .collect();

    const sorted = meetings
      .filter((m) => m.endedAt)
      .sort((a, b) => (b.startedAt > a.startedAt ? 1 : -1));

    return args.limit ? sorted.slice(0, args.limit) : sorted;
  },
});

// ============================================================================
// MUTATIONS
// ============================================================================

/**
 * Start a new meeting
 */
export const start = mutation({
  args: {
    agendaTicketIds: v.array(v.id("tickets")),
    clientId: v.id("clients"),
    createdByEmail: v.string(),
  },
  handler: async (ctx, args) => {
    const client = await ctx.db.get(args.clientId);
    if (!client) {
      throw new Error("Client not found");
    }

    const activeMeeting = await ctx.db
      .query("meetings")
      .withIndex("by_client", (q) => q.eq("clientId", args.clientId))
      .collect()
      .then((meetings) => meetings.find((m) => !m.endedAt));

    if (activeMeeting) {
      throw new Error("An active meeting already exists for this client");
    }

    for (const ticketId of args.agendaTicketIds) {
      const ticket = await ctx.db.get(ticketId);
      if (!ticket) {
        throw new Error(`Ticket ${ticketId} not found`);
      }
    }

    const now = new Date().toISOString();

    return await ctx.db.insert("meetings", {
      agendaTicketIds: args.agendaTicketIds,
      clientId: args.clientId,
      createdByEmail: args.createdByEmail,
      decisionIds: [],
      startedAt: now,
    });
  },
});

/**
 * Add a decision to an active meeting
 */
export const addDecision = mutation({
  args: {
    decisionId: v.id("decisions"),
    meetingId: v.id("meetings"),
  },
  handler: async (ctx, args) => {
    const meeting = await ctx.db.get(args.meetingId);
    if (!meeting) {
      throw new Error("Meeting not found");
    }

    if (meeting.endedAt) {
      throw new Error("Cannot add decision to ended meeting");
    }

    const decision = await ctx.db.get(args.decisionId);
    if (!decision) {
      throw new Error("Decision not found");
    }

    if (meeting.decisionIds.includes(args.decisionId)) {
      return meeting;
    }

    await ctx.db.patch(args.meetingId, {
      decisionIds: [...meeting.decisionIds, args.decisionId],
    });

    return await ctx.db.get(args.meetingId);
  },
});

/**
 * Add a ticket to meeting agenda
 */
export const addAgendaTicket = mutation({
  args: {
    meetingId: v.id("meetings"),
    ticketId: v.id("tickets"),
  },
  handler: async (ctx, args) => {
    const meeting = await ctx.db.get(args.meetingId);
    if (!meeting) {
      throw new Error("Meeting not found");
    }

    if (meeting.endedAt) {
      throw new Error("Cannot modify ended meeting");
    }

    const ticket = await ctx.db.get(args.ticketId);
    if (!ticket) {
      throw new Error("Ticket not found");
    }

    if (meeting.agendaTicketIds.includes(args.ticketId)) {
      return meeting;
    }

    await ctx.db.patch(args.meetingId, {
      agendaTicketIds: [...meeting.agendaTicketIds, args.ticketId],
    });

    return await ctx.db.get(args.meetingId);
  },
});

/**
 * End a meeting
 */
export const end = mutation({
  args: { id: v.id("meetings") },
  handler: async (ctx, args) => {
    const meeting = await ctx.db.get(args.id);
    if (!meeting) {
      throw new Error("Meeting not found");
    }

    if (meeting.endedAt) {
      throw new Error("Meeting already ended");
    }

    const now = new Date().toISOString();

    await ctx.db.patch(args.id, { endedAt: now });

    return await ctx.db.get(args.id);
  },
});

/**
 * Cancel a meeting (deletes it)
 */
export const cancel = mutation({
  args: { id: v.id("meetings") },
  handler: async (ctx, args) => {
    const meeting = await ctx.db.get(args.id);
    if (!meeting) {
      throw new Error("Meeting not found");
    }

    if (meeting.decisionIds.length > 0) {
      throw new Error("Cannot cancel meeting with recorded decisions");
    }

    await ctx.db.delete(args.id);
  },
});
