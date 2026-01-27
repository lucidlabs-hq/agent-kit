/**
 * Mastra Entry Point
 *
 * Main entry for the Mastra AI agent server.
 * Exports agents, tools, and workflows for use in the application.
 */

import { Mastra } from "@mastra/core";
import { assistant } from "./agents/assistant";

// Initialize Mastra instance
export const mastra = new Mastra({
  agents: {
    assistant,
  },
});

// Export individual components for direct use
export { assistant } from "./agents/assistant";
export * from "./tools";
export * from "./workflows";

// Start server if run directly
if (import.meta.url === `file://${process.argv[1]}`) {
  const port = process.env.PORT ?? 4000;

  console.log(`[Mastra] Starting server on port ${port}...`);

  // Mastra provides built-in HTTP server
  mastra.serve({
    port: Number(port),
  });

  console.log(`[Mastra] Server running at http://localhost:${port}`);
}
