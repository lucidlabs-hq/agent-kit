/**
 * Mastra Tools Registry
 *
 * Export all tools for use by agents.
 * Tools are functions that agents can call to interact with external systems.
 */

import { createTool } from "@mastra/core";
import { z } from "zod";

// ============================================================================
// EXAMPLE TOOLS - Replace with your domain-specific tools
// ============================================================================

/**
 * Search tool - searches for information
 *
 * Example tool that demonstrates the Mastra tool pattern.
 * Replace with your actual search implementation.
 */
export const searchTool = createTool({
  id: "search",
  description: "Search for information in the knowledge base",
  inputSchema: z.object({
    query: z.string().describe("The search query"),
    limit: z.number().optional().describe("Maximum results to return"),
  }),
  outputSchema: z.object({
    results: z.array(
      z.object({
        id: z.string(),
        title: z.string(),
        content: z.string(),
        score: z.number(),
      })
    ),
  }),
  execute: async ({ query, limit = 10 }) => {
    // TODO: Implement actual search logic
    // This could call Convex vector search, external APIs, etc.

    console.log(`[SearchTool] Searching for: ${query} (limit: ${limit})`);

    // Placeholder response
    return {
      results: [
        {
          id: "result-1",
          title: "Example Result",
          content: `Search results for: ${query}`,
          score: 0.95,
        },
      ],
    };
  },
});

/**
 * Create task tool - creates a new task
 */
export const createTaskTool = createTool({
  id: "create_task",
  description: "Create a new task in the system",
  inputSchema: z.object({
    title: z.string().describe("Task title"),
    description: z.string().optional().describe("Task description"),
    priority: z
      .enum(["low", "medium", "high", "urgent"])
      .optional()
      .describe("Task priority"),
  }),
  outputSchema: z.object({
    taskId: z.string(),
    success: z.boolean(),
  }),
  execute: async ({ title, description, priority = "medium" }) => {
    // TODO: Call Convex mutation to create task
    console.log(`[CreateTaskTool] Creating task: ${title}`);

    return {
      taskId: `task-${Date.now()}`,
      success: true,
    };
  },
});

/**
 * Send notification tool - sends a notification
 */
export const sendNotificationTool = createTool({
  id: "send_notification",
  description: "Send a notification to a user or channel",
  inputSchema: z.object({
    recipient: z.string().describe("Recipient email or channel"),
    message: z.string().describe("Notification message"),
    type: z.enum(["email", "slack", "webhook"]).describe("Notification type"),
  }),
  outputSchema: z.object({
    sent: z.boolean(),
    messageId: z.string().optional(),
  }),
  execute: async ({ recipient, message, type }) => {
    // TODO: Implement actual notification logic
    console.log(`[NotificationTool] Sending ${type} to ${recipient}: ${message}`);

    return {
      sent: true,
      messageId: `msg-${Date.now()}`,
    };
  },
});

// Export all tools
export const tools = {
  search: searchTool,
  createTask: createTaskTool,
  sendNotification: sendNotificationTool,
};
