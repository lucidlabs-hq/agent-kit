/**
 * Types Test Suite
 *
 * Unit tests for type definitions and label mappings.
 * Demonstrates testing constants and type guards.
 */

import { describe, it, expect } from "vitest";
import {
  TASK_STATUS_LABELS,
  PRIORITY_LABELS,
  AGENT_STATUS_LABELS,
  AGENT_ACTIVITY_LABELS,
  type TaskStatus,
  type Priority,
  type AgentStatusType,
  type AgentActivityType,
} from "../types";

describe("TASK_STATUS_LABELS", () => {
  it("has labels for all TaskStatus values", () => {
    const statuses: TaskStatus[] = [
      "pending",
      "in_progress",
      "completed",
      "cancelled",
    ];

    statuses.forEach((status) => {
      expect(TASK_STATUS_LABELS[status]).toBeDefined();
      expect(typeof TASK_STATUS_LABELS[status]).toBe("string");
    });
  });

  it("returns correct labels", () => {
    expect(TASK_STATUS_LABELS.pending).toBe("Pending");
    expect(TASK_STATUS_LABELS.in_progress).toBe("In Progress");
    expect(TASK_STATUS_LABELS.completed).toBe("Completed");
    expect(TASK_STATUS_LABELS.cancelled).toBe("Cancelled");
  });
});

describe("PRIORITY_LABELS", () => {
  it("has labels for all Priority values", () => {
    const priorities: Priority[] = ["low", "medium", "high", "urgent"];

    priorities.forEach((priority) => {
      expect(PRIORITY_LABELS[priority]).toBeDefined();
      expect(typeof PRIORITY_LABELS[priority]).toBe("string");
    });
  });

  it("returns correct labels", () => {
    expect(PRIORITY_LABELS.low).toBe("Low");
    expect(PRIORITY_LABELS.medium).toBe("Medium");
    expect(PRIORITY_LABELS.high).toBe("High");
    expect(PRIORITY_LABELS.urgent).toBe("Urgent");
  });
});

describe("AGENT_STATUS_LABELS", () => {
  it("has labels for all AgentStatusType values", () => {
    const statuses: AgentStatusType[] = [
      "idle",
      "processing",
      "waiting",
      "error",
    ];

    statuses.forEach((status) => {
      expect(AGENT_STATUS_LABELS[status]).toBeDefined();
      expect(typeof AGENT_STATUS_LABELS[status]).toBe("string");
    });
  });

  it("returns correct labels", () => {
    expect(AGENT_STATUS_LABELS.idle).toBe("Idle");
    expect(AGENT_STATUS_LABELS.processing).toBe("Processing");
    expect(AGENT_STATUS_LABELS.waiting).toBe("Waiting");
    expect(AGENT_STATUS_LABELS.error).toBe("Error");
  });
});

describe("AGENT_ACTIVITY_LABELS", () => {
  it("has labels for all AgentActivityType values", () => {
    const activities: AgentActivityType[] = [
      "analyzing",
      "generating",
      "waiting_approval",
      "completed",
      "error",
    ];

    activities.forEach((activity) => {
      expect(AGENT_ACTIVITY_LABELS[activity]).toBeDefined();
      expect(typeof AGENT_ACTIVITY_LABELS[activity]).toBe("string");
    });
  });

  it("returns correct labels", () => {
    expect(AGENT_ACTIVITY_LABELS.analyzing).toBe("Analyzing");
    expect(AGENT_ACTIVITY_LABELS.generating).toBe("Generating");
    expect(AGENT_ACTIVITY_LABELS.waiting_approval).toBe("Waiting for Approval");
    expect(AGENT_ACTIVITY_LABELS.completed).toBe("Completed");
    expect(AGENT_ACTIVITY_LABELS.error).toBe("Error");
  });
});
