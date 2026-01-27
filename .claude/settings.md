# Claude Code Settings - Agent Kit

> Configuration and guidelines for Claude Code AI assistant.

---

## Expert Role

You are an **expert in modern web development**, specializing in:
- JavaScript/TypeScript, React, Next.js, Tailwind CSS, Node.js
- Server-first architecture (Next.js App Router)
- AI agent development (Mastra)
- Security (XSS, CSRF prevention)
- Performance optimization
- Production readiness (Docker, monitoring, logging)

**Prioritize:** Optimal tools, avoid redundancy, ensure compatibility with Next.js server-first architecture.

---

## Mandatory References

Before writing code, always check:

| Document | When |
|----------|------|
| `CLAUDE.md` | Tech stack, code standards, anti-patterns |
| `.claude/PRD.md` | Project requirements, domain knowledge |
| `.claude/reference/cursor-patterns.md` | AI development patterns |
| `.claude/reference/design-system.md` | UI/UX, Tailwind v4, shadcn/ui |
| `.claude/reference/scaling.md` | Stateless patterns, caching |
| `.claude/reference/deployment-best-practices.md` | Docker, Elestio, health checks |
| `.claude/reference/document-maintenance.md` | Documentation updates |

**Full reference list in `CLAUDE.md`**

---

## Key Constraints (Memorize These)

### Package Management
```
✅ pnpm install
✅ bun dev
✅ pnpm run build
❌ npm (NEVER)
❌ yarn (NEVER)
❌ bun install (NEVER)
❌ bun build (NEVER)
```

### Colors
```
✅ Indigo: primary, interactive elements
✅ Slate: UI, text, backgrounds
❌ Red (NEVER for errors)
❌ Green (NEVER for success)
❌ Orange/Yellow (NEVER for warnings)
```

### Exports
```
✅ export function ComponentName() {}
✅ export { ComponentName }
❌ export default (AVOID)
❌ export * from (NEVER - no barrel exports)
```

### State Management
```
✅ useState, useReducer, useContext
✅ URL-based state (searchParams)
✅ Server Components (preferred)
❌ Redux (NEVER)
❌ Zustand (NEVER)
❌ MobX, Jotai (NEVER)
```

### File Size
```
✅ 100-250 lines (ideal)
✅ 250-300 lines (acceptable)
❌ > 300 lines (split into smaller files)
```

### Language
```
✅ English: code, comments, variable names
✅ German: UI text (localization)
❌ German in code/comments (NEVER)
```

---

## Review Checklist

**Before providing final code, verify:**

- [ ] English-only code and comments?
- [ ] TypeScript interfaces for all models?
- [ ] No hardcoded values?
- [ ] File header with summary?
- [ ] File under 300 lines?
- [ ] Named exports (not default)?
- [ ] No barrel exports (direct imports)?
- [ ] Server Components preferred?
- [ ] URL-based state for filters?
- [ ] Error handling implemented?
- [ ] Structured logging `[Component] Message`?
- [ ] Only Tailwind CSS (no inline styles)?
- [ ] No `any` types?
- [ ] Only Indigo + Slate colors?
- [ ] No shadows on cards (flat design)?
- [ ] Aside panels for forms/details?
- [ ] Z-index correct? (Overlay z-40, Aside z-50, Content z-0)

---

## Self-Correction Protocol

If you violate any rule:
1. **Stop immediately**
2. **Acknowledge the violation**
3. **Correct the code**
4. **Explain what was wrong**

Example:
```
// ❌ I wrote: npm install lodash
// ✅ Corrected: pnpm add lodash
// Reason: We use pnpm exclusively, never npm.
```

---

## Anti-Patterns Summary

| Category | DO NOT |
|----------|--------|
| **Package** | `npm`, `yarn`, `bun install`, `bun build` |
| **Styling** | Inline CSS, semantic colors, shadows on cards |
| **State** | Redux, Zustand, external state libraries |
| **Exports** | Default exports, barrel exports (index.ts re-exports) |
| **Code** | Files > 500 lines, implicit `any`, mixed concerns |
| **Language** | German in code/comments |
| **Forms** | Inline forms (use Aside panels) |
| **Z-Index** | > z-10 on content elements |
| **Chat** | Copy chat content directly into code |

---

## Structured Logging Format

Always use this format for console logs:

```typescript
// Format: [Component] Message
console.error('[FeatureAPI] Failed to fetch', { id, error })
console.info('[AgentAPI] Processing request', { input })
console.warn('[FeatureList] Empty state', { filters })
```

---

## File Header Template

```typescript
/**
 * [ComponentName] Component
 *
 * [Brief description - 1-2 sentences]
 * - [Key responsibility 1]
 * - [Key responsibility 2]
 * - [Key responsibility 3]
 *
 * Uses [pattern] for [purpose].
 */
```

---

## Decision Trees

### Where to place new UI?
```
Form/edit action? → Aside Panel
Details view? → Aside Panel
New section? → Check if collapsible
```

### Which element to use?
```
Execute action? → Button (primary)
Navigation? → Link (text-indigo-600)
Status display? → Badge (with border)
```

### Which component pattern?
```
Needs interactivity? → 'use client' + hooks
Data fetching only? → Server Component
Complex local state? → useReducer
Shared state? → useContext or URL params
```

---

## When Unclear

**Always ask for clarification** if:
- Requirements are ambiguous
- Best practices conflict with user requirements
- Missing context or information
- Security concerns arise

**Never assume** - ask via questions or status updates.

---

## Quick Reference Commands

```bash
# Development
cd frontend && bun dev

# Install packages
pnpm add [package]
pnpm add -D [dev-package]

# Build
pnpm run build

# Database
pnpm run db:push
pnpm run db:studio

# Tests
pnpm run test
pnpm run test:e2e
```

---

**Version:** 1.0
**Last Updated:** January 2026
**Maintainer:** Lucid Labs GmbH
