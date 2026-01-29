/**
 * Invoice Processing Workflows
 *
 * Mastra v1 workflows for invoice processing demo.
 * Simplified linear workflow without complex variable mapping.
 *
 * Created: 29. Januar 2026
 */

import { createStep, createWorkflow } from "@mastra/core/workflows";
import { z } from "zod";

// ============================================================================
// SIMPLE DEMO WORKFLOW
// ============================================================================

/**
 * Step 1: Parse and Validate Invoice
 * Combines parsing and validation in one step
 */
const processInvoiceStep = createStep({
  id: "process-invoice",
  inputSchema: z.object({
    invoiceId: z.string(),
    rawContent: z.string(),
  }),
  outputSchema: z.object({
    id: z.string(),
    vendor: z.string(),
    amount: z.number(),
    currency: z.string(),
    date: z.string(),
    category: z.string(),
    accountCode: z.string(),
    taxRate: z.number(),
    valid: z.boolean(),
    warnings: z.array(z.string()),
  }),
  execute: async ({ inputData }) => {
    console.log(`[ProcessInvoice] Processing: ${inputData.invoiceId}`);

    // Demo: Mock extraction and validation
    const amount = 1250.00;
    const warnings: string[] = [];

    if (amount > 5000) {
      warnings.push("High value invoice - requires approval");
    }

    const result = {
      id: inputData.invoiceId,
      vendor: "Demo Vendor GmbH",
      amount,
      currency: "EUR",
      date: "2026-01-29",
      category: "Operating Expenses",
      accountCode: "6300",
      taxRate: 19.0,
      valid: true,
      warnings,
    };

    console.log(`[ProcessInvoice] Result: ${result.vendor}, ${result.amount} EUR`);
    return result;
  },
});

/**
 * Step 2: Store Result
 * Saves the processed invoice
 */
const storeResultStep = createStep({
  id: "store-result",
  inputSchema: z.object({
    id: z.string(),
    vendor: z.string(),
    amount: z.number(),
    currency: z.string(),
    date: z.string(),
    category: z.string(),
    accountCode: z.string(),
    taxRate: z.number(),
    valid: z.boolean(),
    warnings: z.array(z.string()),
  }),
  outputSchema: z.object({
    success: z.boolean(),
    recordId: z.string(),
    summary: z.string(),
  }),
  execute: async ({ inputData }) => {
    console.log(`[StoreResult] Storing: ${inputData.id}`);

    const recordId = `rec_${Date.now()}`;
    const requiresApproval = inputData.warnings.length > 0;

    const summary = [
      `Invoice ${inputData.id} processed successfully`,
      `Vendor: ${inputData.vendor}`,
      `Amount: ${inputData.amount} ${inputData.currency}`,
      `Category: ${inputData.category}`,
      `Account: ${inputData.accountCode}`,
      requiresApproval ? "Requires approval" : "Auto-approved",
    ].join(" | ");

    console.log(`[StoreResult] Saved as: ${recordId}`);

    return {
      success: true,
      recordId,
      summary,
    };
  },
});

// ============================================================================
// WORKFLOW
// ============================================================================

/**
 * Invoice Processing Workflow (Demo)
 *
 * Simple workflow: Process → Store
 */
export const invoiceProcessingWorkflow = createWorkflow({
  id: "invoice-processing",
  inputSchema: z.object({
    invoiceId: z.string(),
    rawContent: z.string(),
  }),
  outputSchema: z.object({
    success: z.boolean(),
    recordId: z.string(),
    summary: z.string(),
  }),
})
  .then(processInvoiceStep)
  .then(storeResultStep)
  .commit();

// ============================================================================
// EXPORTS
// ============================================================================

export const workflows = {
  invoiceProcessing: invoiceProcessingWorkflow,
};
