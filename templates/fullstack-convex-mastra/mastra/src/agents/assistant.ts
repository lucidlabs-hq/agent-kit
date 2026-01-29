/**
 * Invoice Assistant Agent
 *
 * AI agent for invoice processing and accounting tasks.
 * Mastra v1 syntax with dynamic model selection.
 *
 * Created: 29. Januar 2026
 */

import { Agent } from "@mastra/core/agent";
import { tools } from "../tools";
import { getLLMConfig } from "../config/llm";

const llmConfig = getLLMConfig();

/**
 * Invoice Assistant
 *
 * Specialized agent for:
 * - Invoice data extraction
 * - Validation and error checking
 * - Accounting categorization
 * - Answering invoice-related questions
 */
export const invoiceAssistant = new Agent({
  id: "invoice-assistant",
  name: "Invoice Assistant",
  instructions: `You are an AI assistant specialized in invoice processing and accounting.

## Your Role
Help users process, validate, and categorize invoices for accounting purposes.

## Capabilities
- Extract structured data from invoice documents
- Validate invoice completeness and correctness
- Categorize expenses according to German accounting standards (SKR03/SKR04)
- Answer questions about invoices and accounting rules
- Flag invoices that require manual review

## Guidelines
1. Always verify vendor information and amounts
2. Check for required fields: vendor, date, amount, tax rate
3. Apply German VAT rules (19% standard, 7% reduced)
4. Flag high-value invoices (>5000 EUR) for approval
5. Be precise with numbers - accounting requires accuracy

## Response Format
When processing invoices, provide structured output:
- Vendor name and ID
- Invoice date and number
- Line items with amounts
- Tax calculation
- Recommended account code (SKR03)
- Any warnings or issues

## Language
Respond in the same language as the user's input.
German for German input, English for English input.`,

  // v1: String format "provider/model"
  // Uses config to switch between Ollama (local) and Claude (prod)
  model: llmConfig.provider === "ollama"
    ? `ollama/${llmConfig.model}`
    : `anthropic/${llmConfig.model}`,

  tools: {
    search: tools.search,
    createTask: tools.createTask,
  },
});

// Export for backward compatibility
export const assistant = invoiceAssistant;
