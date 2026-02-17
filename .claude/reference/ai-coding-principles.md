# AI-Coding Principles

> Patterns und Prinzipien, die AI-gestützte Entwicklung vereinfachen und verbessern.

---

## Table of Contents

1. [Zod-First Development](#1-zod-first-development)
2. [Sorting & Ordering](#2-sorting--ordering)
3. [Explicit over Implicit](#3-explicit-over-implicit)
4. [Flat Structures](#4-flat-structures)
5. [Consistent Naming](#5-consistent-naming)
6. [Single Responsibility](#6-single-responsibility)
7. [Tooling](#7-tooling)

---

## 1. Zod-First Development

**Zod ist das Fundament für AI-Coding.** Schemas definieren die Wahrheit über Datenstrukturen.

### Warum Zod für AI-Coding kritisch ist

| Aspekt | Ohne Zod | Mit Zod |
|--------|----------|---------|
| **Type Safety** | TypeScript-only (compile time) | Runtime + Compile time |
| **Validation** | Manuell, fehleranfällig | Automatisch, konsistent |
| **Documentation** | Separate Docs nötig | Schema IS Documentation |
| **AI Context** | AI muss Typen raten | AI sieht exakte Struktur |
| **Error Messages** | Generisch | Präzise, strukturiert |

### Schema-First Pattern

```typescript
// ✅ RICHTIG: Schema zuerst, dann Type ableiten
import { z } from 'zod';

// 1. Schema definieren (Single Source of Truth)
export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(2).max(100),
  role: z.enum(['admin', 'user', 'guest']),
  createdAt: z.string().datetime(),
  metadata: z.record(z.string()).optional(),
});

// 2. Type ableiten (nie manuell definieren!)
export type User = z.infer<typeof UserSchema>;

// 3. Validation bei Boundaries
export function createUser(input: unknown): User {
  return UserSchema.parse(input); // Throws bei Invalid
}

// 4. Safe Parsing für Error Handling
export function tryCreateUser(input: unknown) {
  const result = UserSchema.safeParse(input);
  if (!result.success) {
    console.error('[User] Validation failed:', result.error.flatten());
    return null;
  }
  return result.data;
}
```

### Zod in API Routes

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2),
  role: z.enum(['admin', 'user']).default('user'),
});

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const data = CreateUserSchema.parse(body);

    // data ist jetzt typsicher und validiert
    const user = await createUser(data);

    return NextResponse.json(user, { status: 201 });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', details: error.flatten() },
        { status: 400 }
      );
    }
    throw error;
  }
}
```

### Zod in Convex

```typescript
// convex/schema.ts - Convex verwendet eigene Validators
import { defineSchema, defineTable } from 'convex/server';
import { v } from 'convex/values';

export default defineSchema({
  users: defineTable({
    email: v.string(),
    name: v.string(),
    role: v.union(v.literal('admin'), v.literal('user')),
  }),
});

// Für Frontend-Validation: Zod Schema parallel
// lib/schemas/user.ts
import { z } from 'zod';

export const UserFormSchema = z.object({
  email: z.string().email('Ungültige E-Mail'),
  name: z.string().min(2, 'Name zu kurz'),
  role: z.enum(['admin', 'user']),
});
```

### Zod in Mastra Tools

```typescript
// mastra/src/tools/createTask.ts
import { createTool } from '@mastra/core';
import { z } from 'zod';

export const createTaskTool = createTool({
  id: 'create-task',
  description: 'Creates a new task with title and optional priority',

  // Zod Schema definiert Input
  inputSchema: z.object({
    title: z.string().min(1).describe('Task title'),
    priority: z.enum(['low', 'medium', 'high']).default('medium'),
    dueDate: z.string().datetime().optional(),
  }),

  // Zod Schema definiert Output
  outputSchema: z.object({
    taskId: z.string(),
    created: z.boolean(),
  }),

  execute: async ({ context }) => {
    // context ist bereits validiert und typsicher
    const { title, priority, dueDate } = context;
    // ...
  },
});
```

### Zod Best Practices

| Regel | Beispiel |
|-------|----------|
| **Schema neben Type** | Nie `interface` ohne Schema |
| **Infer statt Duplicate** | `type X = z.infer<typeof XSchema>` |
| **Describe für AI** | `.describe('Explanation')` |
| **Defaults explizit** | `.default('value')` |
| **Enums statt Strings** | `z.enum(['a', 'b'])` nicht `z.string()` |
| **Strict Objects** | `.strict()` für keine Extra-Keys |

---

## 2. Sorting & Ordering

**Konsistente Sortierung macht Code vorhersagbar für AI und Menschen.**

### Warum Sorting wichtig ist

| Aspekt | Ohne Sorting | Mit Sorting |
|--------|--------------|-------------|
| **Determinismus** | AI generiert zufällige Reihenfolgen | Vorhersagbare Ausgabe |
| **Git Diffs** | Chaotische Diffs | Minimale, saubere Diffs |
| **Merge Conflicts** | Häufig | Selten |
| **Code Review** | Mühsam | Schnell scannbar |

### Import Sorting

```typescript
// ✅ RICHTIG: Gruppiert und alphabetisch

// 1. React/Next (Framework)
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';

// 2. External Libraries (alphabetisch)
import { z } from 'zod';

// 3. Internal Absolute Imports (alphabetisch)
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Input } from '@/components/ui/input';

// 4. Internal Relative Imports
import { formatDate } from './utils';

// 5. Types (am Ende)
import type { User } from '@/lib/types';
```

### Object Key Sorting

```typescript
// ✅ RICHTIG: Alphabetisch sortiert
const config = {
  apiKey: process.env.API_KEY,
  baseUrl: 'https://api.example.com',
  debug: false,
  timeout: 5000,
};

// ✅ RICHTIG: Interface Properties alphabetisch
interface User {
  createdAt: Date;
  email: string;
  id: string;
  name: string;
  role: 'admin' | 'user';
  updatedAt: Date;
}

// ✅ RICHTIG: Zod Schema Properties alphabetisch
const UserSchema = z.object({
  createdAt: z.string().datetime(),
  email: z.string().email(),
  id: z.string().uuid(),
  name: z.string(),
  role: z.enum(['admin', 'user']),
  updatedAt: z.string().datetime(),
});
```

### Tailwind Class Sorting

```tsx
// ✅ RICHTIG: Logische Reihenfolge (via Prettier Plugin)
// Layout → Flexbox → Spacing → Sizing → Typography → Colors → Effects

<div className="flex items-center justify-between gap-4 p-4 w-full text-sm text-slate-700 bg-slate-50 border rounded-lg hover:bg-slate-100">
```

### Switch/Case Sorting

```typescript
// ✅ RICHTIG: Alphabetisch oder nach Häufigkeit
switch (status) {
  case 'active':
    return <ActiveBadge />;
  case 'completed':
    return <CompletedBadge />;
  case 'pending':
    return <PendingBadge />;
  default:
    return <UnknownBadge />;
}
```

---

## 3. Explicit over Implicit

**Explizite Werte sind für AI leichter zu verstehen und zu generieren.**

### Keine Magic Numbers

```typescript
// ❌ FALSCH: Magic Numbers
if (users.length > 50) { ... }
await delay(3000);
const maxRetries = 3;

// ✅ RICHTIG: Benannte Konstanten
const MAX_USERS_PER_PAGE = 50;
const DEBOUNCE_MS = 3000;
const MAX_RETRY_ATTEMPTS = 3;

if (users.length > MAX_USERS_PER_PAGE) { ... }
await delay(DEBOUNCE_MS);
```

### Explizite Return Types

```typescript
// ❌ FALSCH: Impliziter Return Type
function getUser(id: string) {
  return db.users.find(u => u.id === id);
}

// ✅ RICHTIG: Expliziter Return Type
function getUser(id: string): User | undefined {
  return db.users.find(u => u.id === id);
}

// ✅ RICHTIG: Async mit explizitem Type
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return UserSchema.parse(await response.json());
}
```

### Explizite Default Values

```typescript
// ❌ FALSCH: Implizite Defaults
function createConfig(options?: Partial<Config>) {
  return { ...defaultConfig, ...options };
}

// ✅ RICHTIG: Explizite Defaults mit Zod
const ConfigSchema = z.object({
  debug: z.boolean().default(false),
  maxRetries: z.number().default(3),
  timeout: z.number().default(5000),
});

function createConfig(options: unknown): Config {
  return ConfigSchema.parse(options);
}
```

### Explizite Error Handling

```typescript
// ❌ FALSCH: Implizites Error Handling
try {
  await doSomething();
} catch (e) {
  console.log(e);
}

// ✅ RICHTIG: Explizit und strukturiert
try {
  await doSomething();
} catch (error) {
  if (error instanceof ValidationError) {
    console.error('[Validation] Invalid input:', error.message);
    return { success: false, error: 'VALIDATION_ERROR' };
  }
  if (error instanceof NetworkError) {
    console.error('[Network] Request failed:', error.message);
    return { success: false, error: 'NETWORK_ERROR' };
  }
  throw error; // Unknown errors re-throw
}
```

---

## 4. Flat Structures

**Flache Strukturen sind einfacher für AI zu verarbeiten und zu generieren.**

### Flache Komponenten-Hierarchie

```typescript
// ❌ FALSCH: Tief verschachtelt
<Card>
  <CardHeader>
    <CardTitle>
      <TitleWrapper>
        <Icon />
        <Text>{title}</Text>
      </TitleWrapper>
    </CardTitle>
  </CardHeader>
</Card>

// ✅ RICHTIG: Flach und lesbar
<Card>
  <CardHeader icon={<Icon />} title={title} />
  <CardContent>{children}</CardContent>
</Card>
```

### Flache Conditional Logic

```typescript
// ❌ FALSCH: Tief verschachtelt
if (user) {
  if (user.isActive) {
    if (user.hasPermission) {
      return doAction();
    } else {
      return 'No permission';
    }
  } else {
    return 'Inactive';
  }
} else {
  return 'No user';
}

// ✅ RICHTIG: Early Returns (flach)
if (!user) return 'No user';
if (!user.isActive) return 'Inactive';
if (!user.hasPermission) return 'No permission';

return doAction();
```

### Flache Datenstrukturen

```typescript
// ❌ FALSCH: Tief verschachtelt
interface DeepUser {
  profile: {
    personal: {
      name: {
        first: string;
        last: string;
      };
    };
  };
}

// ✅ RICHTIG: Flach
interface User {
  firstName: string;
  lastName: string;
  email: string;
}
```

### Flache File Structure

```
// ❌ FALSCH: Zu tief
src/
  features/
    users/
      components/
        forms/
          create/
            CreateUserForm.tsx

// ✅ RICHTIG: Maximal 2-3 Ebenen
src/
  components/
    users/
      CreateUserForm.tsx
      UserList.tsx
      UserCard.tsx
```

---

## 5. Consistent Naming

**Konsistente Namen ermöglichen AI, Patterns zu erkennen und fortzusetzen.**

### Naming Conventions

| Element | Convention | Beispiel |
|---------|------------|----------|
| **Components** | PascalCase | `UserCard`, `TaskList` |
| **Functions** | camelCase, verb-first | `getUser`, `createTask` |
| **Constants** | UPPER_SNAKE_CASE | `MAX_RETRY_ATTEMPTS` |
| **Files** | kebab-case | `user-card.tsx` |
| **Schemas** | PascalCase + Schema | `UserSchema`, `TaskSchema` |
| **Types** | PascalCase | `User`, `Task` |
| **Hooks** | use + PascalCase | `useUser`, `useTasks` |
| **Handlers** | handle + Event | `handleClick`, `handleSubmit` |
| **Booleans** | is/has/can prefix | `isLoading`, `hasError`, `canSubmit` |

### Consistent Patterns

```typescript
// ✅ Queries: get/fetch/list
function getUser(id: string): User { ... }
async function fetchUsers(): Promise<User[]> { ... }
function listActiveUsers(): User[] { ... }

// ✅ Mutations: create/update/delete
function createUser(data: CreateUserInput): User { ... }
function updateUser(id: string, data: UpdateUserInput): User { ... }
function deleteUser(id: string): void { ... }

// ✅ Checks: is/has/can
function isValidEmail(email: string): boolean { ... }
function hasPermission(user: User, action: string): boolean { ... }
function canAccessResource(user: User, resource: Resource): boolean { ... }

// ✅ Transformers: to/from/format
function toApiFormat(user: User): ApiUser { ... }
function fromApiFormat(data: ApiUser): User { ... }
function formatDate(date: Date): string { ... }
```

---

## 6. Single Responsibility

**Kleine, fokussierte Einheiten sind für AI einfacher zu verstehen.**

### File Size Limits

| Type | Max Lines | Action if Exceeded |
|------|-----------|-------------------|
| Component | 150 | Split into subcomponents |
| Utility | 100 | Split by domain |
| Hook | 80 | Extract logic to utilities |
| API Route | 100 | Extract to service layer |
| **Any File** | **300** | **Mandatory split** |

### One Export per File (Components)

```typescript
// ❌ FALSCH: Multiple Components
// components/user.tsx
export function UserCard() { ... }
export function UserList() { ... }
export function UserAvatar() { ... }

// ✅ RICHTIG: One Component per File
// components/users/user-card.tsx
export function UserCard() { ... }

// components/users/user-list.tsx
export function UserList() { ... }

// components/users/user-avatar.tsx
export function UserAvatar() { ... }
```

### Focused Functions

```typescript
// ❌ FALSCH: Multiple Responsibilities
function processUser(user: User) {
  // Validates
  if (!user.email) throw new Error('No email');

  // Transforms
  const normalized = { ...user, email: user.email.toLowerCase() };

  // Saves
  await db.users.insert(normalized);

  // Notifies
  await sendWelcomeEmail(user.email);
}

// ✅ RICHTIG: Single Responsibility
function validateUser(user: User): void {
  UserSchema.parse(user);
}

function normalizeUser(user: User): User {
  return { ...user, email: user.email.toLowerCase() };
}

async function saveUser(user: User): Promise<void> {
  await db.users.insert(user);
}

async function notifyNewUser(email: string): Promise<void> {
  await sendWelcomeEmail(email);
}

// Orchestration
async function createUser(input: unknown): Promise<User> {
  const user = UserSchema.parse(input);
  const normalized = normalizeUser(user);
  await saveUser(normalized);
  await notifyNewUser(normalized.email);
  return normalized;
}
```

---

## 7. Tooling

### Empfohlene Tools für AI-Coding

| Tool | Purpose | Install |
|------|---------|---------|
| **eslint-plugin-import** | Import sorting | `pnpm add -D eslint-plugin-import` |
| **prettier-plugin-tailwindcss** | Tailwind class sorting | `pnpm add -D prettier-plugin-tailwindcss` |
| **@trivago/prettier-plugin-sort-imports** | Import grouping | `pnpm add -D @trivago/prettier-plugin-sort-imports` |
| **eslint-plugin-sort-keys-fix** | Object key sorting | `pnpm add -D eslint-plugin-sort-keys-fix` |

### ESLint Config

```javascript
// .eslintrc.js
module.exports = {
  plugins: ['import', 'sort-keys-fix'],
  rules: {
    'import/order': [
      'error',
      {
        groups: [
          'builtin',
          'external',
          'internal',
          'parent',
          'sibling',
          'index',
          'type',
        ],
        'newlines-between': 'always',
        alphabetize: { order: 'asc' },
      },
    ],
    'sort-keys-fix/sort-keys-fix': 'warn',
  },
};
```

### Prettier Config

```javascript
// prettier.config.js
module.exports = {
  plugins: [
    'prettier-plugin-tailwindcss',
    '@trivago/prettier-plugin-sort-imports',
  ],
  importOrder: [
    '^react',
    '^next',
    '<THIRD_PARTY_MODULES>',
    '^@/(.*)$',
    '^[./]',
  ],
  importOrderSeparation: true,
  importOrderSortSpecifiers: true,
};
```

---

## 8. Spec-Driven Development

**Vor dem Code kommt die Spezifikation.** AI arbeitet besser mit klarer Struktur.

### Das Spec-First Pattern

```markdown
# Feature: [Name]

## Requirements
- [ ] Requirement 1
- [ ] Requirement 2

## Data Model (Zod Schema)
```typescript
const FeatureSchema = z.object({...})
```

## API Endpoints
- POST /api/feature - Create
- GET /api/feature/:id - Read

## UI Components
- FeatureCard
- FeatureList

## Edge Cases
- What if user is not authenticated?
- What if data is empty?

## Tests to Write
- Unit: FeatureSchema validation
- Integration: API endpoints
- E2E: Critical user flow
```

### Warum Spec-First für AI

| Aspekt | Ohne Spec | Mit Spec |
|--------|-----------|----------|
| **AI Output** | Rät Struktur | Folgt Plan |
| **Iterations** | Viele Korrekturen | Weniger Runden |
| **Konsistenz** | Variiert | Vorhersagbar |
| **Testing** | Nachträglich | Von Anfang an |

---

## 9. Testing mit AI

**Tests sind Feedback-Loops für AI.** Starke Tests = bessere AI-Ergebnisse.

### Wann welchen Test schreiben?

| Ich erstelle... | Dann schreibe ich... |
|-----------------|---------------------|
| **Zod Schema** | Unit Test für Validation |
| **Utility Function** | Unit Test mit Edge Cases |
| **API Route** | Integration Test |
| **Convex Mutation** | Integration Test |
| **Mastra Tool** | Integration Test |
| **Kritischer User Flow** | E2E Test |
| **Multi-Step Form** | E2E Test |

### Test-First für AI-Code

```typescript
// 1. Test zuerst schreiben (von Hand oder AI)
describe('UserSchema', () => {
  it('validates correct user', () => {
    const result = UserSchema.safeParse({
      email: 'test@example.com',
      name: 'Test User',
    });
    expect(result.success).toBe(true);
  });

  it('rejects invalid email', () => {
    const result = UserSchema.safeParse({
      email: 'invalid',
      name: 'Test',
    });
    expect(result.success).toBe(false);
  });
});

// 2. AI implementiert gegen Tests
// 3. Tests geben Feedback
// 4. AI korrigiert basierend auf Test-Output
```

### AI als Test-Generator

```typescript
// Prompt: "Generate edge case tests for this schema"
const UserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  role: z.enum(['admin', 'user']),
});

// AI generiert:
describe('UserSchema edge cases', () => {
  it('rejects empty string name', () => {...});
  it('rejects name over 100 chars', () => {...});
  it('rejects unknown role', () => {...});
  it('handles unicode in name', () => {...});
});
```

### Kein Test nötig für

- Triviale Getter/Setter
- Framework-Code (Next.js Routing)
- UI Styling (visuell prüfen)
- Generierter Boilerplate

---

## 10. Context Packaging

**AI ist nur so gut wie der Kontext.** Relevante Informationen explizit machen.

### Was AI wissen muss

| Context | Beispiel |
|---------|----------|
| **Tech Stack** | "Next.js 16, Convex, Tailwind 4, Better Auth" |
| **Constraints** | "No external state libs, max 300 lines/file" |
| **Patterns** | "Use Zod schemas, sort imports alphabetically" |
| **Anti-Patterns** | "No shadows, no inline styles, no barrel exports" |
| **Related Code** | Vorhandene Komponenten, Schemas, Utils |

### CLAUDE.md als Context-Quelle

Die CLAUDE.md ist der primäre Context für AI:
- Tech Stack definiert
- Code Standards festgelegt
- Anti-Patterns dokumentiert
- Reference Docs verlinkt

### Prompt-Verbesserung

```markdown
# ❌ Vager Prompt
"Create a user form"

# ✅ Context-reicher Prompt
"Create a user form following our patterns:
- Use Zod schema from lib/schemas/user.ts
- Use react-hook-form with zodResolver
- Style with Tailwind (no shadows, Slate colors)
- Place in Aside panel (see design-system.md)
- Validate on submit, show errors inline"
```

---

## 11. Quality Gates für AI-Code

**AI-Code braucht strengere Kontrollen.** Automation als Sicherheitsnetz.

### Automated Quality Gates

```bash
# In CI/CD Pipeline oder pre-commit
pnpm run lint          # ESLint (inkl. import sorting)
pnpm run type-check    # TypeScript strict
pnpm run test          # Tests müssen passieren
pnpm run build         # Build muss funktionieren
```

### AI-on-AI Review

Nutze Subagents für Code Review:

```markdown
# Nach Implementation
1. code-reviewer Agent für Qualität
2. architecture-guard Agent für CLAUDE.md Compliance
3. ssr-safety-checker Agent für Hydration
4. design-system-guard Agent für UI
```

### Human Review Checklist

Nach AI-generiertem Code:

- [ ] Verstehe ich jeden Teil des Codes?
- [ ] Passt es zur existierenden Architektur?
- [ ] Sind Edge Cases behandelt?
- [ ] Keine Magic Numbers oder hardcoded Values?
- [ ] Zod Schemas statt manueller Validation?
- [ ] Tests geschrieben/aktualisiert?

---

## 12. Tech-Stack-spezifische Patterns

### Next.js 16 + AI

```typescript
// Server Components für AI einfacher
// Klare Trennung: Server holt Daten, Client rendert

// app/users/page.tsx (Server Component)
export default async function UsersPage() {
  // Daten holen - AI versteht das Pattern
  return <UserList />;
}

// components/users/user-list.tsx (Client wenn interaktiv)
'use client';
export function UserList() {
  const users = useQuery(api.users.list);
  // ...
}
```

### Convex + AI

```typescript
// Schema-first macht AI-Arbeit einfacher
// convex/schema.ts
export default defineSchema({
  users: defineTable({
    email: v.string(),
    name: v.string(),
    role: v.union(v.literal('admin'), v.literal('user')),
  }).index('by_email', ['email']),
});

// AI kann daraus ableiten:
// - Queries
// - Mutations
// - Frontend Types
```

### Mastra + AI

```typescript
// Zod Schemas in Tools = AI versteht Input/Output
export const tool = createTool({
  id: 'process-data',
  inputSchema: z.object({...}),  // AI sieht was rein geht
  outputSchema: z.object({...}), // AI sieht was raus kommt
  execute: async ({ context }) => {
    // AI kann Implementation ableiten
  },
});
```

### Tailwind + AI

```typescript
// Semantic class names für AI-Verständnis
// ❌ Schwer für AI
className="mt-4 mb-2 px-3 py-1.5 text-sm"

// ✅ Einfacher für AI (mit Kommentar)
className="mt-4 mb-2 px-3 py-1.5 text-sm" // Card padding, small text
```

---

## Summary Checklist

### Code Quality (Vor dem Commit)

- [ ] Zod Schemas für alle Datenstrukturen?
- [ ] Types via `z.infer<>` abgeleitet (nicht manuell)?
- [ ] Imports sortiert und gruppiert?
- [ ] Object Keys alphabetisch?
- [ ] Tailwind Classes sortiert?
- [ ] Keine Magic Numbers (Konstanten verwendet)?
- [ ] Explizite Return Types?
- [ ] Flache Strukturen (max 2-3 Nesting)?
- [ ] Konsistente Naming Conventions?
- [ ] Files unter 300 Zeilen?

### AI Workflow (Vor der Implementation)

- [ ] Spec/Plan geschrieben?
- [ ] Relevanter Context identifiziert?
- [ ] Tests definiert (vor Code)?
- [ ] Edge Cases dokumentiert?

### Nach AI-generiertem Code

- [ ] Code verstanden und reviewed?
- [ ] Tests geschrieben/aktualisiert?
- [ ] Lint + Type-Check bestanden?
- [ ] Build funktioniert?
- [ ] Subagents für Validation genutzt?

---

## Sources

Best Practices basierend auf:
- [Addy Osmani: My LLM coding workflow going into 2026](https://addyosmani.com/blog/ai-coding-workflow/)
- [Claude Code Best Practices](https://www.builder.io/blog/claude-code)
- [Agentic Coding Research 2026](https://research.aimultiple.com/agentic-coding/)

---

**Version:** 1.0
**Last Updated:** January 2026
**Maintainer:** Lucid Labs GmbH
