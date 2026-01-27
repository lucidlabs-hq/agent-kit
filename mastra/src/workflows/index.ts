/**
 * Mastra Workflows
 *
 * Define multi-step workflows that combine agent actions.
 * Workflows can be triggered manually, on schedule, or by events.
 */

import { Workflow, Step } from "@mastra/core";
import { z } from "zod";

// ============================================================================
// EXAMPLE WORKFLOW - Task Processing
// ============================================================================

/**
 * Task Processing Workflow
 *
 * A template workflow that demonstrates the Mastra workflow pattern.
 * Customize steps for your specific use case.
 */
export const taskProcessingWorkflow = new Workflow({
  name: "task-processing",
  description: "Process a task through analysis, action, and notification",
  triggerSchema: z.object({
    taskId: z.string(),
    userId: z.string().optional(),
  }),
});

// Step 1: Analyze the task
const analyzeStep = new Step({
  id: "analyze",
  description: "Analyze the task and determine required actions",
  execute: async ({ context }) => {
    const { taskId } = context.trigger;

    console.log(`[Workflow] Analyzing task: ${taskId}`);

    // TODO: Implement analysis logic
    // This could call an agent, database query, etc.

    return {
      taskId,
      analysis: {
        category: "general",
        priority: "medium",
        requiredActions: ["process", "notify"],
      },
    };
  },
});

// Step 2: Execute action
const executeStep = new Step({
  id: "execute",
  description: "Execute the determined action",
  execute: async ({ context }) => {
    const { analysis } = context.stepResults.analyze;

    console.log(`[Workflow] Executing actions: ${analysis.requiredActions.join(", ")}`);

    // TODO: Implement action execution
    // This could call tools, external APIs, etc.

    return {
      executed: true,
      actions: analysis.requiredActions,
      timestamp: new Date().toISOString(),
    };
  },
});

// Step 3: Send notification
const notifyStep = new Step({
  id: "notify",
  description: "Send notification about completion",
  execute: async ({ context }) => {
    const { taskId } = context.trigger;
    const { executed } = context.stepResults.execute;

    if (!executed) {
      return { notified: false, reason: "Execution failed" };
    }

    console.log(`[Workflow] Sending completion notification for task: ${taskId}`);

    // TODO: Implement notification logic

    return {
      notified: true,
      taskId,
      completedAt: new Date().toISOString(),
    };
  },
});

// Connect steps in sequence
taskProcessingWorkflow
  .step(analyzeStep)
  .then(executeStep)
  .then(notifyStep)
  .commit();

// ============================================================================
// CONDITIONAL WORKFLOW EXAMPLE
// ============================================================================

/**
 * Conditional Workflow
 *
 * Demonstrates branching logic in workflows.
 */
export const conditionalWorkflow = new Workflow({
  name: "conditional-processing",
  description: "Process with conditional branching based on analysis",
  triggerSchema: z.object({
    input: z.string(),
    type: z.enum(["urgent", "normal"]),
  }),
});

const classifyStep = new Step({
  id: "classify",
  execute: async ({ context }) => {
    const { type } = context.trigger;
    return { isUrgent: type === "urgent" };
  },
});

const urgentPathStep = new Step({
  id: "urgent-path",
  execute: async () => {
    console.log("[Workflow] Taking urgent path");
    return { path: "urgent", priority: "high" };
  },
});

const normalPathStep = new Step({
  id: "normal-path",
  execute: async () => {
    console.log("[Workflow] Taking normal path");
    return { path: "normal", priority: "medium" };
  },
});

// Conditional branching
conditionalWorkflow
  .step(classifyStep)
  .then(urgentPathStep, {
    when: ({ stepResults }) => stepResults.classify.isUrgent,
  })
  .then(normalPathStep, {
    when: ({ stepResults }) => !stepResults.classify.isUrgent,
  })
  .commit();

// ============================================================================
// EXPORTS
// ============================================================================

export const workflows = {
  taskProcessing: taskProcessingWorkflow,
  conditional: conditionalWorkflow,
};
