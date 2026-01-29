/**
 * Mastra Tools Registry
 *
 * Export all tools for use by agents.
 * Mastra v1 syntax with @mastra/core/tools import.
 *
 * Created: 29. Januar 2026
 */

import { createTool } from "@mastra/core/tools";
import { z } from "zod";

// ============================================================================
// INVOICE TOOLS
// ============================================================================

/**
 * Search Tool
 * Searches for information in the knowledge base
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
  execute: async ({ context }) => {
    const { query, limit = 10 } = context;
    console.log(`[SearchTool] Searching for: ${query} (limit: ${limit})`);

    // Demo: Return mock results
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
 * Create Task Tool
 * Creates a new task in the system
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
  execute: async ({ context }) => {
    const { title, description, priority = "medium" } = context;
    console.log(`[CreateTaskTool] Creating task: ${title}`);

    return {
      taskId: `task-${Date.now()}`,
      success: true,
    };
  },
});

// ============================================================================
// EXPORTS
// ============================================================================

export const tools = {
  search: searchTool,
  createTask: createTaskTool,
};
