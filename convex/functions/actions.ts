/**
 * Convex Actions
 *
 * Server-side functions that can call external APIs.
 * Use for AI model calls, third-party integrations, etc.
 *
 * Actions are NOT reactive - use mutations/queries for database ops.
 */

import { action } from "../_generated/server";
import { v } from "convex/values";
import { api } from "../_generated/api";

// ============================================================================
// AI AGENT ACTIONS
// ============================================================================

/**
 * Process a task with the AI agent
 *
 * This is a template - implement your actual AI logic here.
 * Consider using Mastra for complex agent workflows.
 */
export const processTaskWithAgent = action({
  args: {
    taskId: v.id("tasks"),
    agentId: v.string(),
  },
  handler: async (ctx, args) => {
    // Log start
    await ctx.runMutation(api.functions.mutations.logAgentActivity, {
      agentId: args.agentId,
      type: "analyzing",
      message: `Starting analysis of task ${args.taskId}`,
      taskId: args.taskId,
    });

    try {
      // TODO: Implement your AI logic here
      // Example: Call Mastra agent, OpenAI, Anthropic, etc.

      // Simulate processing
      await new Promise((resolve) => setTimeout(resolve, 1000));

      // Log completion
      await ctx.runMutation(api.functions.mutations.logAgentActivity, {
        agentId: args.agentId,
        type: "completed",
        message: `Successfully processed task ${args.taskId}`,
        taskId: args.taskId,
      });

      return { success: true, taskId: args.taskId };
    } catch (error) {
      // Log error
      await ctx.runMutation(api.functions.mutations.logAgentActivity, {
        agentId: args.agentId,
        type: "error",
        message: `Error processing task: ${error instanceof Error ? error.message : "Unknown error"}`,
        taskId: args.taskId,
      });

      throw error;
    }
  },
});

// ============================================================================
// VECTOR SEARCH ACTIONS
// ============================================================================

/**
 * Generate embedding for text
 *
 * Replace with your actual embedding provider.
 */
export const generateEmbedding = action({
  args: { text: v.string() },
  handler: async (_ctx, args) => {
    // TODO: Call your embedding provider (OpenAI, Azure, etc.)
    // Example with OpenAI:
    //
    // const response = await fetch("https://api.openai.com/v1/embeddings", {
    //   method: "POST",
    //   headers: {
    //     "Content-Type": "application/json",
    //     Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
    //   },
    //   body: JSON.stringify({
    //     model: "text-embedding-ada-002",
    //     input: args.text,
    //   }),
    // });
    // const data = await response.json();
    // return data.data[0].embedding;

    // Placeholder: Return empty array
    console.log(`Would generate embedding for: ${args.text.substring(0, 50)}...`);
    return new Array(1536).fill(0);
  },
});

/**
 * Search documents by similarity
 */
export const searchDocuments = action({
  args: {
    query: v.string(),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    // Generate embedding for query
    const embedding = await ctx.runAction(api.functions.actions.generateEmbedding, {
      text: args.query,
    });

    // Search using vector index
    const results = await ctx.vectorSearch("documents", "by_embedding", {
      vector: embedding,
      limit: args.limit ?? 10,
    });

    // Fetch full documents
    const documents = await Promise.all(
      results.map(async (result) => {
        const doc = await ctx.runQuery(api.functions.queries.getDocument, {
          id: result._id,
        });
        return {
          ...doc,
          score: result._score,
        };
      })
    );

    return documents;
  },
});

// ============================================================================
// WEBHOOK ACTIONS
// ============================================================================

/**
 * Call n8n webhook
 *
 * Use this to trigger n8n workflows from Convex.
 */
export const triggerN8nWorkflow = action({
  args: {
    webhookUrl: v.string(),
    payload: v.any(),
  },
  handler: async (_ctx, args) => {
    const response = await fetch(args.webhookUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(args.payload),
    });

    if (!response.ok) {
      throw new Error(`n8n webhook failed: ${response.status}`);
    }

    return await response.json();
  },
});
