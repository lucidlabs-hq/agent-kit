/**
 * Mock Data Example Template
 *
 * Use this pattern to create mock data for development.
 * Copy and adapt for your specific domain.
 *
 * IMPORTANT: All timestamps must be static strings (SSR-safe).
 */

import type {
  User,
  Task,
  AgentActivity,
  AgentStatus,
  Workflow,
  WorkflowStep,
} from "../types";

// ============================================================================
// USERS
// ============================================================================

export const mockUsers: User[] = [
  {
    id: "user-001",
    email: "admin@example.com",
    name: "Alex Admin",
    role: "admin",
    avatarUrl: "/avatars/admin.png",
    createdAt: "2026-01-01T00:00:00.000Z",
    updatedAt: "2026-01-15T10:00:00.000Z",
  },
  {
    id: "user-002",
    email: "user@example.com",
    name: "Taylor User",
    role: "user",
    createdAt: "2026-01-05T09:00:00.000Z",
    updatedAt: "2026-01-15T10:00:00.000Z",
  },
];

export const currentUser = mockUsers[0];

// ============================================================================
// TASKS
// ============================================================================

export const mockTasks: Task[] = [
  {
    id: "task-001",
    title: "Review quarterly report",
    description: "Review and approve the Q4 financial report.",
    status: "pending",
    priority: "high",
    assigneeId: "user-001",
    dueDate: "2026-01-20T17:00:00.000Z",
    createdAt: "2026-01-10T09:00:00.000Z",
    updatedAt: "2026-01-15T10:00:00.000Z",
  },
  {
    id: "task-002",
    title: "Update documentation",
    description: "Update the API documentation with new endpoints.",
    status: "in_progress",
    priority: "medium",
    assigneeId: "user-002",
    createdAt: "2026-01-12T14:00:00.000Z",
    updatedAt: "2026-01-15T11:30:00.000Z",
  },
  {
    id: "task-003",
    title: "Fix login bug",
    description: "Users report intermittent login failures.",
    status: "completed",
    priority: "urgent",
    assigneeId: "user-001",
    createdAt: "2026-01-08T08:00:00.000Z",
    updatedAt: "2026-01-14T16:00:00.000Z",
  },
];

// ============================================================================
// AI AGENT
// ============================================================================

export const mockAgentStatus: AgentStatus = {
  agentId: "assistant-001",
  status: "idle",
  lastActivityAt: "2026-01-15T10:30:00.000Z",
  stats: {
    totalProcessed: 156,
    successCount: 148,
    errorCount: 8,
  },
};

export const mockAgentActivities: AgentActivity[] = [
  {
    id: "activity-001",
    agentId: "assistant-001",
    type: "analyzing",
    message: "Analyzing incoming request...",
    createdAt: "2026-01-15T10:30:00.000Z",
  },
  {
    id: "activity-002",
    agentId: "assistant-001",
    type: "generating",
    message: "Generating response draft...",
    createdAt: "2026-01-15T10:29:00.000Z",
  },
  {
    id: "activity-003",
    agentId: "assistant-001",
    type: "completed",
    message: "Task completed successfully.",
    createdAt: "2026-01-15T10:25:00.000Z",
  },
];

// ============================================================================
// WORKFLOWS
// ============================================================================

export const mockWorkflowSteps: WorkflowStep[] = [
  {
    id: "step-001",
    order: 1,
    title: "Receive Request",
    description: "Parse and validate incoming request.",
    status: "completed",
    isAutomated: true,
  },
  {
    id: "step-002",
    order: 2,
    title: "Analyze Content",
    description: "AI analyzes the request content.",
    status: "completed",
    isAutomated: true,
  },
  {
    id: "step-003",
    order: 3,
    title: "Generate Response",
    description: "Create draft response for review.",
    status: "active",
    isAutomated: true,
    output: {
      type: "text",
      content: "Draft response content here...",
    },
  },
  {
    id: "step-004",
    order: 4,
    title: "Review & Approve",
    description: "Human reviews and approves the response.",
    status: "pending",
    isAutomated: false,
  },
  {
    id: "step-005",
    order: 5,
    title: "Send Response",
    description: "Deliver the approved response.",
    status: "pending",
    isAutomated: true,
  },
];

export const mockWorkflow: Workflow = {
  id: "workflow-001",
  name: "Customer Support Workflow",
  description: "Handles incoming customer support requests.",
  steps: mockWorkflowSteps,
  triggerType: "event",
};

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Get task by ID
 */
export function getTaskById(id: string): Task | undefined {
  return mockTasks.find((task) => task.id === id);
}

/**
 * Get user by ID
 */
export function getUserById(id: string): User | undefined {
  return mockUsers.find((user) => user.id === id);
}

/**
 * Get tasks by status
 */
export function getTasksByStatus(status: Task["status"]): Task[] {
  return mockTasks.filter((task) => task.status === status);
}

/**
 * Get activities for agent
 */
export function getAgentActivities(agentId: string): AgentActivity[] {
  return mockAgentActivities
    .filter((activity) => activity.agentId === agentId)
    .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
}
