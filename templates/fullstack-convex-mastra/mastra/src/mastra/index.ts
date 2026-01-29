/**
 * Mastra Instance Export
 *
 * Entry point for Mastra CLI (npx mastra dev).
 * Exports the configured Mastra instance for Studio UI.
 */

import { Mastra } from "@mastra/core";
import { invoiceAssistant } from "../agents/assistant";
import { invoiceProcessingWorkflow } from "../workflows";

export const mastra = new Mastra({
  agents: {
    invoiceAssistant,
  },
  workflows: {
    invoiceProcessing: invoiceProcessingWorkflow,
  },
});
