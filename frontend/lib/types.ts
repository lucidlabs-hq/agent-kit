/**
 * Agent Kit - Core TypeScript Definitions
 *
 * Generic, reusable types for AI agent applications.
 * Extend these types for your specific domain.
 */

// ============================================================================
// CORE TYPES - Extend these for your domain
// ============================================================================

/**
 * Base entity with common fields
 */
export interface BaseEntity {
  id: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * User type for authentication
 */
export interface User extends BaseEntity {
  email: string;
  name: string;
  avatarUrl?: string;
  role: "admin" | "user" | "viewer";
}

/**
 * Task status for workflow management
 */
export type TaskStatus = "pending" | "in_progress" | "completed" | "cancelled";

/**
 * Priority levels
 */
export type Priority = "low" | "medium" | "high" | "urgent";

/**
 * Generic task type - extend for your domain
 */
export interface Task extends BaseEntity {
  title: string;
  description?: string;
  status: TaskStatus;
  priority: Priority;
  assigneeId?: string;
  dueDate?: string;
}

// ============================================================================
// AI AGENT TYPES
// ============================================================================

/**
 * Agent status types
 */
export type AgentStatusType = "idle" | "processing" | "waiting" | "error";

/**
 * Agent activity types
 */
export type AgentActivityType =
  | "analyzing"
  | "generating"
  | "waiting_approval"
  | "completed"
  | "error";

/**
 * AI Agent configuration
 */
export interface AgentConfig {
  id: string;
  name: string;
  description: string;
  model: string;
  systemPrompt?: string;
  tools: string[];
  enabled: boolean;
}

/**
 * Agent activity log entry
 */
export interface AgentActivity {
  id: string;
  agentId: string;
  type: AgentActivityType;
  message: string;
  metadata?: Record<string, unknown>;
  createdAt: string;
}

/**
 * Agent status with current state
 */
export interface AgentStatus {
  agentId: string;
  status: AgentStatusType;
  currentTaskId?: string;
  lastActivityAt?: string;
  stats: {
    totalProcessed: number;
    successCount: number;
    errorCount: number;
  };
}

// ============================================================================
// WORKFLOW TYPES
// ============================================================================

/**
 * Workflow step status
 */
export type WorkflowStepStatus = "pending" | "active" | "completed" | "skipped";

/**
 * Workflow step definition
 */
export interface WorkflowStep {
  id: string;
  order: number;
  title: string;
  description?: string;
  status: WorkflowStepStatus;
  isAutomated: boolean;
  output?: {
    type: "text" | "email" | "task" | "notification";
    content: string;
  };
}

/**
 * Workflow definition
 */
export interface Workflow {
  id: string;
  name: string;
  description?: string;
  steps: WorkflowStep[];
  triggerType: "manual" | "scheduled" | "event";
}

/**
 * Workflow execution instance
 */
export interface WorkflowExecution extends BaseEntity {
  workflowId: string;
  status: "running" | "completed" | "failed" | "cancelled";
  currentStepId?: string;
  startedAt: string;
  completedAt?: string;
  error?: string;
}

// ============================================================================
// UI TYPES
// ============================================================================

/**
 * Navigation item
 */
export interface NavItem {
  title: string;
  href: string;
  icon?: string;
  badge?: number | string;
  disabled?: boolean;
}

/**
 * Toast notification type
 */
export type ToastType = "success" | "error" | "warning" | "info";

/**
 * Filter option
 */
export interface FilterOption<T = string> {
  label: string;
  value: T;
  count?: number;
}

// ============================================================================
// API TYPES
// ============================================================================

/**
 * Paginated response
 */
export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  hasMore: boolean;
}

/**
 * API error response
 */
export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

// ============================================================================
// LABEL MAPPINGS
// ============================================================================

export const TASK_STATUS_LABELS: Record<TaskStatus, string> = {
  pending: "Pending",
  in_progress: "In Progress",
  completed: "Completed",
  cancelled: "Cancelled",
};

export const PRIORITY_LABELS: Record<Priority, string> = {
  low: "Low",
  medium: "Medium",
  high: "High",
  urgent: "Urgent",
};

export const AGENT_STATUS_LABELS: Record<AgentStatusType, string> = {
  idle: "Idle",
  processing: "Processing",
  waiting: "Waiting",
  error: "Error",
};

export const AGENT_ACTIVITY_LABELS: Record<AgentActivityType, string> = {
  analyzing: "Analyzing",
  generating: "Generating",
  waiting_approval: "Waiting for Approval",
  completed: "Completed",
  error: "Error",
};

// ============================================================================
// UTILITY TYPES
// ============================================================================

/**
 * Make all properties optional recursively
 */
export type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

/**
 * Extract ID type from entity
 */
export type EntityId<T extends { id: unknown }> = T["id"];

/**
 * Omit common fields for creation
 */
export type CreateInput<T extends BaseEntity> = Omit<T, "id" | "createdAt" | "updatedAt">;

/**
 * Partial update input
 */
export type UpdateInput<T extends BaseEntity> = Partial<Omit<T, "id" | "createdAt" | "updatedAt">>;
