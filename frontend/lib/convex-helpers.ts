/**
 * Convex Helper Types
 *
 * Type helpers for working with Convex IDs in the frontend.
 * Convex IDs are branded strings for type safety.
 */

import type { Id, TableNames } from "@convex/_generated/dataModel";

/**
 * Cast a string to a Convex ID type.
 * Use this when you have a string ID from URL params or other sources
 * that needs to be passed to Convex queries/mutations.
 */
export function toId<T extends TableNames>(id: string): Id<T> {
  return id as Id<T>;
}

/**
 * Type alias for common table names
 */
export type ClientId = Id<"clients">;
export type TicketId = Id<"tickets">;
export type StrategicGoalId = Id<"strategicGoals">;
export type ContingentId = Id<"contingents">;
export type DecisionId = Id<"decisions">;
export type MeetingId = Id<"meetings">;
