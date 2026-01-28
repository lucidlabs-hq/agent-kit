# AI-Assisted Development Patterns

> Guidelines for effective AI-assisted development using Claude Code, Cursor, and similar AI IDEs.

---

## Table of Contents

1. [File Context](#1-file-context)
2. [Prompt Patterns](#2-prompt-patterns)
3. [Code Structure](#3-code-structure)
4. [File Headers](#4-file-headers)
5. [Anti-Patterns](#5-anti-patterns)
6. [Best Practices](#6-best-practices)

---

## 1. File Context

### Using @filename References

Always use `@filename` syntax to reference specific files in prompts:

```markdown
In @FeatureDetail.tsx, add error handling for the API call.
Following the pattern in @FeatureList.tsx, implement pagination.
```

**Benefits:**
- AI can read the referenced file context
- More accurate suggestions
- Better understanding of existing patterns

### File Size Limits

**Keep files under 300 lines** for optimal AI comprehension:

| Range | Status |
|-------|--------|
| 100-250 lines | Good |
| 250-300 lines | Acceptable |
| > 300 lines | Split into smaller files |

**Why?**
- AI context windows are limited
- Smaller files = better understanding
- Easier to maintain and review

---

## 2. Prompt Patterns

### Targeted Changes

**Good:**
```
In @FeatureDetail.tsx, add error handling to the fetchData function.
Use the error handling pattern from @error-handling.md.
```

**Bad:**
```
Fix the feature detail page.
```

### Consistency Prompts

**Good:**
```
Following the pattern in @FeatureList.tsx, implement the same loading state in @FeatureDetail.tsx.
```

**Bad:**
```
Make it consistent.
```

### Multi-File Changes

**Good:**
```
Update @types.ts to add the FeatureStatus type, then update @FeatureList.tsx to use it.
```

**Bad:**
```
Update all files that use feature status.
```

---

## 3. Code Structure

### One Component Per File

**Good:**
```typescript
// FeatureDetail.tsx
export function FeatureDetail({ featureId }: { featureId: string }) {
  // Component implementation
}
```

**Bad:**
```typescript
// Dashboard.tsx
export function FeatureDetail() { /* ... */ }
export function FeatureList() { /* ... */ }
export function FeatureFilters() { /* ... */ }
```

### Explicit Prop Types

**Good:**
```typescript
interface FeatureDetailProps {
  featureId: string
  onUpdate?: (feature: Feature) => void
}

export function FeatureDetail({ featureId, onUpdate }: FeatureDetailProps) {
  // Implementation
}
```

**Bad:**
```typescript
export function FeatureDetail(props: any) {
  // Implementation
}
```

### JSDoc Comments

**Good:**
```typescript
/**
 * Fetches feature data from the API with error handling.
 * @param featureId - The unique identifier for the feature
 * @returns Promise resolving to feature data or null if not found
 * @throws {Error} If API request fails
 */
async function fetchFeature(featureId: string): Promise<Feature | null> {
  // Implementation
}
```

**Bad:**
```typescript
async function fetchFeature(featureId: string) {
  // Implementation
}
```

### Named Exports Over Default Exports

**Good:**
```typescript
export function FeatureDetail() { /* ... */ }
export type { FeatureDetailProps }
```

**Bad:**
```typescript
export default function FeatureDetail() { /* ... */ }
```

**Why?**
- Better for AI to understand exports
- Easier to refactor
- Clearer import statements

---

## 4. File Headers

Every code file should start with a summary comment:

```typescript
/**
 * FeatureDetail Component
 *
 * Displays detailed information about a single feature, including:
 * - Feature metadata (ID, status, priority)
 * - Workflow steps and current state
 * - Related decisions and actions
 * - Timeline of events
 *
 * Uses Aside panel pattern for editing and workflow details.
 */
```

---

## 5. Anti-Patterns

### Barrel Exports

**Problem:**
```typescript
// components/index.ts
export * from './FeatureDetail'
export * from './FeatureList'
export * from './FeatureFilters'
```

**Why avoid:**
- AI can't easily trace imports
- Harder to understand dependencies
- Can cause circular dependencies

**Better:**
```typescript
// Import directly
import { FeatureDetail } from '@/components/Dashboard/FeatureDetail'
```

### Files > 500 Lines

**Problem:**
- AI loses context
- Harder to maintain
- Slower to process

**Solution:**
Split into smaller, focused files:
- `FeatureDetail.tsx` (main component)
- `FeatureDetailHeader.tsx` (header section)
- `FeatureDetailTimeline.tsx` (timeline section)
- `FeatureDetailActions.tsx` (action buttons)

### Implicit Types

**Problem:**
```typescript
function processFeature(data) {
  return data.map(item => item.id)
}
```

**Better:**
```typescript
function processFeature(data: Feature[]): string[] {
  return data.map(item => item.id)
}
```

### Mixed Concerns

**Problem:**
```typescript
// Bad: Component + API logic + utilities
export function FeatureDetail() {
  async function fetchData() { /* API call */ }
  function formatDate() { /* utility */ }
  return <div>...</div>
}
```

**Better:**
```typescript
// Component
import { fetchFeature } from '@/lib/api/features'
import { formatDate } from '@/lib/utils/date'

export function FeatureDetail() {
  // Component logic only
}
```

---

## 6. Best Practices

### Summary

1. **Use `@filename`** for file references
2. **Keep files < 300 lines** (ideally 100-250)
3. **One component per file**
4. **Explicit prop types** (no `any`)
5. **JSDoc comments** for complex functions
6. **Named exports** over default exports
7. **File headers** with summary
8. **Separate concerns** (components, API, utilities)
9. **Targeted prompts** with context
10. **Consistency patterns** across files
11. **English-only code** - All code, comments, variable names must be in English
12. **Never copy chat content** - Never copy content from chat conversations directly into code. Always refactor and adapt.

### Example: Refactoring for AI

**Before (AI-unfriendly):**
```typescript
// Dashboard.tsx (600 lines)
export default function Dashboard() {
  // Everything in one file
}
```

**After (AI-friendly):**
```typescript
// Dashboard.tsx (150 lines)
import { DashboardHeader } from './DashboardHeader'
import { FeatureList } from './FeatureList'
import { FilterSidebar } from './FilterSidebar'

export function Dashboard() {
  // Composition of smaller components
}

// DashboardHeader.tsx (80 lines)
export function DashboardHeader() { /* ... */ }

// FeatureList.tsx (200 lines)
export function FeatureList() { /* ... */ }

// FilterSidebar.tsx (120 lines)
export function FilterSidebar() { /* ... */ }
```

---

## Related References

- `error-handling.md` - Error handling patterns
- `design-system.md` - UI component patterns
- `mastra-best-practices.md` - AI agent patterns
