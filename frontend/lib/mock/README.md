# Mock Data Pattern

This directory contains example mock data for development and testing.

## Usage

Mock data is used during development to:
- Test UI components without a backend
- Provide realistic sample data for demos
- Enable rapid prototyping

## Guidelines

### SSR Safety (CRITICAL)

**NEVER use in mock data:**
- `Date.now()`
- `Math.random()`
- `new Date()` without a static value
- Any dynamic values that differ between server and client

These cause hydration mismatches in Next.js.

**ALWAYS use:**
- Static ISO timestamp strings: `"2026-01-15T10:00:00.000Z"`
- Fixed IDs: `"task-001"`, `"user-abc123"`
- Deterministic values

### Example Pattern

```typescript
// ✅ CORRECT - Static timestamps
export const mockTasks: Task[] = [
  {
    id: "task-001",
    title: "Review proposal",
    status: "pending",
    createdAt: "2026-01-15T10:00:00.000Z",
    updatedAt: "2026-01-15T10:00:00.000Z",
  },
];

// ❌ WRONG - Dynamic values
export const badMockData = {
  createdAt: new Date().toISOString(), // SSR mismatch!
  id: `task-${Math.random()}`,          // SSR mismatch!
};
```

## Files

- `mock-data.example.ts` - Template with all entity types
- `mock-tasks.ts` - Task entity examples
- `mock-users.ts` - User entity examples
- `mock-workflows.ts` - Workflow state examples

## Replacing with Real Data

In production:
1. Replace mock imports with API calls
2. Use React Query or SWR for data fetching
3. Add loading and error states
