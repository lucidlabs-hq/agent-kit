/**
 * Mastra Entry Point
 *
 * Invoice Accounting Assistant - AI agent server.
 * Mastra v1 with Hono HTTP server.
 *
 * Created: 29. Januar 2026
 */

import { Mastra } from "@mastra/core";
import { Hono } from "hono";
import { cors } from "hono/cors";
import { invoiceAssistant } from "./agents/assistant";
import { invoiceProcessingWorkflow } from "./workflows";

// Initialize Mastra instance
export const mastra = new Mastra({
  agents: {
    invoiceAssistant,
  },
  workflows: {
    invoiceProcessing: invoiceProcessingWorkflow,
  },
});

// Export individual components for direct use
export { invoiceAssistant } from "./agents/assistant";
export * from "./tools";
export * from "./workflows";

// HTTP Server
const app = new Hono();

app.use("*", cors());

// Health check
app.get("/health", (c) => {
  return c.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    agents: ["invoiceAssistant"],
    workflows: ["invoiceProcessing"],
  });
});

// Chat endpoint
app.post("/api/chat", async (c) => {
  try {
    const { message, threadId } = await c.req.json();
    const agent = mastra.getAgent("invoiceAssistant");
    const response = await agent.generate(message, { threadId });
    return c.json({ response: response.text });
  } catch (error) {
    console.error("[Chat] Error:", error);
    return c.json({ error: "Failed to generate response" }, 500);
  }
});

// Workflow endpoint
app.post("/api/workflow/:name", async (c) => {
  try {
    const { name } = c.req.param();
    const data = await c.req.json();
    const workflow = mastra.getWorkflow(name);

    if (!workflow) {
      return c.json({ error: `Workflow ${name} not found` }, 404);
    }

    const run = await workflow.createRun();
    const result = await run.start({ inputData: data });
    return c.json({ result });
  } catch (error) {
    console.error("[Workflow] Error:", error);
    return c.json({ error: "Failed to run workflow" }, 500);
  }
});

// Start server if run directly
const port = process.env.PORT ?? 4000;

console.log(`[Mastra] Starting Invoice Assistant server...`);
console.log(`[Mastra] Port: ${port}`);

export default {
  port: Number(port),
  fetch: app.fetch,
};

console.log(`[Mastra] Server running at http://localhost:${port}`);
console.log(`[Mastra] Endpoints:`);
console.log(`  GET  /health`);
console.log(`  POST /api/chat`);
console.log(`  POST /api/workflow/:name`);
