# Code Standards

> **Language, naming, style, TypeScript, React/Next.js, state management, and anti-patterns.**
> Referenced by: architecture-guard, code-reviewer subagents.
> Last Updated: February 2026

---

## Language & Naming

| Rule | Example |
|------|---------|
| **English only** | All code, comments, function names, variable names, type names, file headers |
| **No German in code** | Comments, JSDoc, function names must be English. UI strings can be localized. |
| **Descriptive names** | `isLoading`, `handleClick`, `canSubmit` |
| **TypeScript interfaces** | All models as interfaces |
| **File headers** | Summary comment at top of each file (in English) |
| **PascalCase** | Components, Types, Interfaces |
| **camelCase** | Functions, variables |
| **UPPER_SNAKE_CASE** | Constants |
| **kebab-case** | File names (`.ts`), URL paths |

---

## Code Style

| Rule | Details |
|------|---------|
| **Functional components** | No class components |
| **Arrow functions** | `const fn = () => {}` |
| **Early returns** | For readability |
| **Named exports** | Prefer over default exports |
| **No barrel exports** | Import directly, not via index.ts |
| **File size** | Max 300 lines (split if larger) |

---

## TypeScript

| Rule | Details |
|------|---------|
| **Strict mode** | Always `strict: true` in tsconfig |
| **No `any`** | Use explicit types |
| **Zod schemas** | For validation at boundaries |
| **Explicit return types** | For public functions |

---

## React/Next.js

| Rule | Details |
|------|---------|
| **Server Components** | Default for data fetching |
| **`'use client'`** | Only when needed (interactivity) |
| **Suspense** | Wrap with lightweight fallbacks |
| **next/dynamic** | For non-critical components |
| **next/image** | Optimize images |
| **No dynamic values in SSR** | No `Date.now()`, `Math.random()` in module scope |
| **Clickable = cursor-pointer** | All clickable elements must have `cursor-pointer` |

### SSR/Hydration

**NEVER** use in Server Components or at module level:
- `Date.now()` or `new Date()` for dynamic values
- `Math.random()`
- Browser APIs (`window`, `localStorage`)

These values differ between server and client and cause **Hydration Mismatch**.

```typescript
// WRONG - causes Hydration Error
export const mockData = {
  createdAt: new Date().toISOString(), // Server != Client
};

// CORRECT - static values for mock data
export const mockData = {
  createdAt: "2026-01-13T10:00:00.000Z",
};

// CORRECT - dynamic values only in useEffect
"use client";
const [time, setTime] = useState<string>();
useEffect(() => setTime(new Date().toISOString()), []);
```

Full reference: `.claude/reference/ssr-hydration.md`

---

## State Management

| Allowed | Not Allowed |
|---------|-------------|
| `useState` | Redux |
| `useReducer` | MobX |
| `useContext` | Zustand |
| URL-based state (`searchParams`) | Jotai |
| Server Components (preferred) | External state libraries |

**Philosophy:** Server Components first. Client state only when necessary. URL-based state for filters (link-sharing).

---

## Anti-Patterns

**DO NOT:**

| Category | Anti-Pattern |
|----------|--------------|
| **Styling** | Inline CSS, semantic colors (red/green), shadows on cards |
| **State** | Redux, Zustand, external state libraries |
| **Exports** | Default exports, barrel exports (index.ts re-exports) |
| **Code** | Files > 500 lines, implicit `any`, mixed concerns |
| **Package** | `npm`, `yarn`, `bun install`, `bun build` |
| **Language** | German in code/comments (UI text can be localized) |
| **Forms** | Inline forms (use Aside panels) |
| **Z-Index** | > z-10 on content elements |
| **Chat** | Copy chat content directly into code |
| **SSR** | `Date.now()`, `Math.random()`, `window` in module scope |
| **References** | External tool/product names in code comments |
| **UI Elements** | Creating new UI components without asking permission first |

---

## UI Element Creation Rule

**ALWAYS ask for permission before creating new UI elements.**

1. **First:** Check if an existing UI element in the codebase can be reused
2. **If no existing element fits:** Ask the user for permission before creating a new one
3. **If permission granted:** Design/concept the new element together with the user

**Examples:**
- Need a tab navigation? Check `components/ui/` for existing tabs/pills
- Need a dropdown? Use existing ClassificationPill or dropdown patterns
- Need a new pattern entirely? Ask: "I need a [X] element that doesn't exist yet. May I create one?"

---

## Decision Trees

### Where to place new UI?

```
Form/edit       -> Aside Panel
Details view    -> Aside Panel
New section     -> Check if collapsible
```

### Which element to use?

```
Execute action  -> Button (primary)
Navigation      -> Link
Status display  -> Badge (with border)
```

---

**Version:** 1.0
**Maintainer:** Lucid Labs GmbH
