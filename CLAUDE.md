# Agent Kit

> **AI Agent Starter Kit by Lucidlabs**
> Reusable boilerplate for rapid AI agent project development

## Open Questions

- TODO: Resolve state management conflict: `architecture.md` mentions Zustand, but rules forbid external state libs. For now, use React hooks only.

## Quick Start

```bash
# Alle Befehle über pnpm run
pnpm install                     # Dependencies (NEVER npm/yarn)
pnpm run dev                     # Dev Server (Bun Runtime)
pnpm run build                   # Production Build (Node.js)
```

## Project Overview

**Project-specific details belong in:**
- `.claude/PRD.md` - Product Requirements Document
- `.claude/skills/` - Claude Code skills (v2.1.3+)

**This file contains:**
- Tech stack & conventions
- Code standards
- Development patterns
- Reference documentation links

---

## Tech Stack

### Frontend

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Framework** | Next.js 15+ (App Router) | Full-stack React framework |
| **Language** | TypeScript 5+ (strict) | Type safety |
| **Styling** | Tailwind CSS 4 | Utility-first CSS (ONLY Tailwind) |
| **Components** | shadcn/ui + Radix UI | Accessible, composable UI |
| **Icons** | Lucide React | Consistent iconography |
| **Forms** | react-hook-form + Zod | Form validation |

### Backend

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **AI Framework** | Mastra | AI Agent orchestration |
| **Runtime** | Bun (dev), Node.js (prod) | Fast development, stable production |
| **Database** | Convex | Realtime reactive database |
| **Vector Store** | Convex Vector Search | Built-in embeddings for RAG |
| **Workflows** | n8n (optional) | Automation & integrations |
| **API** | Convex Functions | Type-safe queries/mutations |

### AI Models

| Role | Model | Use Case |
|------|-------|----------|
| **Primary** | Claude Opus 4.5 | Complex reasoning, quality |
| **Fast** | Gemini 3 Flash / Claude Haiku | High-volume, speed |
| **Coding** | Claude Sonnet 4.5 | Code generation |

**LLM Access:** Via LiteLLM Proxy (centralized key management, cost tracking, fallbacks)

### Authentication

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Framework** | Convex Auth | Built-in authentication |
| **Features** | OAuth, Magic Link, Password | Standard auth flows |
| **Sessions** | Convex tables | Reactive, automatic sync |

### Runtime & Package Manager

**Prinzip:** Ein Interface (`pnpm run`), Scripts entscheiden intern über Runtime.

#### Einheitliches Interface

```bash
# Dependencies
pnpm install                     # Einmalig

# Entwicklung (nutzt intern Bun)
pnpm run dev                     # Dev Server (Bun Runtime)
pnpm run lint                    # ESLint
pnpm run type-check              # TypeScript
pnpm run validate                # Lint + Type-check

# Production (nutzt intern Node.js)
pnpm run build                   # Production Build
pnpm run start                   # Production Server
```

#### Wie es funktioniert

| Script | Intern | Runtime |
|--------|--------|---------|
| `dev` | `bun next dev` | Bun (schnell) |
| `build` | `next build` | Node.js (stabil) |
| `start` | `next start` | Node.js (stabil) |

#### NIEMALS verwenden

| Verboten | Grund |
|----------|-------|
| `npm ...` | Falscher Paketmanager |
| `yarn ...` | Falscher Paketmanager |
| `bun install` | Inkonsistente Lockfiles |
| Direkt `bun dev` | Immer über `pnpm run` |

### Deployment

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Production** | Elestio | Self-hosted Docker (data privacy) |
| **Prototypes** | Vercel | Quick deployments, previews |
| **Container** | Docker Compose | Containerization |
| **CI/CD** | GitHub Actions | Automated testing & deployment |
| **Monitoring** | Sentry / LogTail | Error tracking & logging |

---

## shadcn/ui

### Setup

shadcn/ui ist bereits konfiguriert (`components.json`):

```json
{
  "style": "new-york",
  "rsc": true,
  "tailwind": { "cssVariables": true },
  "aliases": {
    "ui": "@/components/ui",
    "utils": "@/lib/utils"
  }
}
```

### Komponenten hinzufügen

```bash
# Einzelne Komponente
npx shadcn@latest add button

# Mehrere Komponenten
npx shadcn@latest add card dialog tabs
```

### Vorhandene UI-Komponenten

| Komponente | Pfad | Server/Client |
|------------|------|---------------|
| `Button` | `components/ui/button.tsx` | Server |
| `Badge` | `components/ui/badge.tsx` | Server |
| `Card` | `components/ui/card.tsx` | Server |
| `Avatar` | `components/ui/avatar.tsx` | Server |
| `Separator` | `components/ui/separator.tsx` | Server |

### Wichtige Regeln

- **Server Components bevorzugen** - shadcn mit `rsc: true` konfiguriert
- **Radix UI nur wenn nötig** - Für komplexe Interaktion (Dialog, Dropdown)
- **Anpassen erlaubt** - shadcn-Komponenten können modifiziert werden
- **Flat Design** - Keine Shadows, nur Borders

---

## Vercel AI SDK

### Für Prototypen & Chat-UIs

Das Vercel AI SDK eignet sich für schnelle AI-Prototypen:

```bash
pnpm add ai @ai-sdk/anthropic
```

### Beispiel: Chat-Route

```typescript
// app/api/chat/route.ts
import { anthropic } from "@ai-sdk/anthropic";
import { streamText } from "ai";

export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: anthropic("claude-sonnet-4-20250514"),
    messages,
  });

  return result.toDataStreamResponse();
}
```

### Beispiel: useChat Hook

```typescript
// components/Chat.tsx
"use client";
import { useChat } from "ai/react";

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit } = useChat();

  return (
    <form onSubmit={handleSubmit}>
      {messages.map((m) => (
        <div key={m.id}>{m.content}</div>
      ))}
      <input value={input} onChange={handleInputChange} />
    </form>
  );
}
```

### Wann Vercel AI SDK vs Mastra?

| Use Case | Tool |
|----------|------|
| Chat-UI, Streaming | Vercel AI SDK |
| Complex Agents, Tools | Mastra |
| Quick Prototypes | Vercel AI SDK |
| Production Workflows | Mastra |

---

## Vercel Deployment

### Für Prototypen

```bash
# Vercel CLI installieren
pnpm add -g vercel

# Deployment
vercel

# Production
vercel --prod
```

### vercel.json (optional)

```json
{
  "framework": "nextjs",
  "buildCommand": "pnpm run build",
  "installCommand": "pnpm install"
}
```

### Environment Variables

In Vercel Dashboard oder via CLI:
```bash
vercel env add ANTHROPIC_API_KEY
```

---

## Project Structure

```
project/
├── frontend/                    # Next.js App
│   ├── app/                     # App Router Pages
│   │   ├── api/                 # API Routes
│   │   └── [features]/          # Feature pages
│   ├── components/
│   │   ├── [Feature]/           # Feature-specific components
│   │   └── ui/                  # shadcn/ui components
│   └── lib/
│       ├── types.ts             # TypeScript definitions
│       ├── api-client.ts        # HTTP client
│       └── utils.ts             # Helpers (cn(), etc.)
│
├── mastra/                      # AI Agent Layer
│   └── src/
│       ├── agents/              # AI Agent definitions
│       ├── tools/               # Agent tools
│       └── workflows/           # Multi-step workflows
│
├── convex/                      # Realtime Database
│   ├── schema.ts                # Database schema
│   └── functions/               # Queries, mutations, actions
│
├── n8n/                         # Workflow Automation (optional)
│   └── workflows/               # Pre-built templates
│
├── .claude/                     # Claude Agent Configuration
│   ├── commands/                # Slash commands
│   ├── reference/               # Best practice docs
│   └── PRD.md                   # Product requirements
│
├── .agents/                     # Agent work products
│   └── plans/                   # Feature implementation plans
│
└── docker-compose.yml           # Local development
```

---

## Code Standards

### Language & Naming

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

### Code Style

| Rule | Details |
|------|---------|
| **Functional components** | No class components |
| **Arrow functions** | `const fn = () => {}` |
| **Early returns** | For readability |
| **Named exports** | Prefer over default exports |
| **No barrel exports** | Import directly, not via index.ts |
| **File size** | Max 300 lines (split if larger) |

### TypeScript

| Rule | Details |
|------|---------|
| **Strict mode** | Always `strict: true` in tsconfig |
| **No `any`** | Use explicit types |
| **Zod schemas** | For validation at boundaries |
| **Explicit return types** | For public functions |

### React/Next.js

| Rule | Details |
|------|---------|
| **Server Components** | Default for data fetching |
| **`'use client'`** | Only when needed (interactivity) |
| **Suspense** | Wrap with lightweight fallbacks |
| **next/dynamic** | For non-critical components |
| **next/image** | Optimize images |
| **No dynamic values in SSR** | No `Date.now()`, `Math.random()` in module scope |
| **Clickable = cursor-pointer** | All clickable elements must have `cursor-pointer` |

#### SSR/Hydration - Wichtig!

**NIEMALS** in Server Components oder auf Modul-Ebene verwenden:
- `Date.now()` oder `new Date()` für dynamische Werte
- `Math.random()`
- Browser-APIs (`window`, `localStorage`)

Diese Werte unterscheiden sich zwischen Server und Client → **Hydration Mismatch**.

```typescript
// ❌ FALSCH - verursacht Hydration Error
export const mockData = {
  createdAt: new Date().toISOString(), // Server ≠ Client
};

// ✅ RICHTIG - feste Werte für Mock-Daten
export const mockData = {
  createdAt: "2026-01-13T10:00:00.000Z",
};

// ✅ RICHTIG - dynamische Werte nur in useEffect
"use client";
const [time, setTime] = useState<string>();
useEffect(() => setTime(new Date().toISOString()), []);
```

Siehe: `.claude/reference/ssr-hydration.md`

### State Management

| Allowed | Not Allowed |
|---------|-------------|
| `useState` | Redux |
| `useReducer` | MobX |
| `useContext` | Zustand |
| URL-based state (`searchParams`) | Jotai |
| Server Components (preferred) | External state libraries |

**Philosophy:** Server Components first. Client state only when necessary. URL-based state for filters (link-sharing).

---

## Database Strategy: Convex

**Principle:** Reactive by default, type-safe, real-time sync.

| Data Type | Technology |
|-----------|------------|
| **Application data** | Convex tables |
| **Vector search (RAG)** | Convex vector indexes |
| **Sessions** | Convex Auth |
| **File storage** | Convex file storage |

**Benefits:**
- Automatic real-time updates to UI
- Type-safe queries and mutations
- Built-in vector search for RAG
- Self-hosted or cloud deployment

---

## Decision Trees

### Where to place new UI?

```
Form/edit → Aside Panel
Details view → Aside Panel
New section → Check if collapsible
```

### Which element to use?

```
Execute action → Button (primary)
Navigation → Link
Status display → Badge (with border)
```

---

## Reference Documentation

| Document | When to Read |
|----------|--------------|
| `.claude/PRD.md` | Product requirements, features, domain knowledge |
| `.claude/reference/architecture.md` | System overview, tech stack, project structure |
| `.claude/reference/design-system.md` | UI/UX, Tailwind v4 @theme inline, shadcn/ui |
| `.claude/reference/error-handling.md` | Error handling patterns |
| `.claude/reference/ssr-hydration.md` | SSR, hydration, Date.now() pitfalls |
| `.claude/reference/testing-and-logging.md` | Tests, logging, monitoring |
| `.claude/reference/deployment-best-practices.md` | Docker, Caddy, Elestio, CI/CD |
| `.claude/reference/scaling.md` | Stateless patterns, session storage |
| `.claude/reference/cursor-patterns.md` | AI-assisted development guidelines |
| `.claude/reference/document-maintenance.md` | Doc updates, versioning |
| `convex/README.md` | Convex database setup, queries, mutations |
| `mastra/README.md` | AI agents, tools, workflows |
| `n8n/README.md` | Workflow automation templates |
| `terraform/README.md` | Infrastructure as Code deployment |
| `WORKFLOW.md` | Complete development workflow guide |

---

## Review Checklist

Before committing code:

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
- [ ] No `Date.now()`/`Math.random()` in SSR code?
- [ ] Clickable elements have `cursor-pointer`?

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
| **SSR** | `Date.now()`, `Math.random()`, `window` in module scope (→ Hydration Error) |
| **References** | External tool/product names in code comments (no inspiration sources) |
| **UI Elements** | Creating new UI components without asking permission first |

---

## UI Element Creation Rule (MANDATORY)

**ALWAYS ask for permission before creating new UI elements.**

When implementing features that require UI components:

1. **First:** Check if an existing UI element in the codebase can be reused
2. **If no existing element fits:** Ask the user for permission before creating a new one
3. **If permission granted:** Design/concept the new element together with the user

**Rationale:** UI consistency requires that all elements follow the established design system. New elements need to be consciously designed and approved, not invented ad-hoc during implementation.

**Examples:**
- Need a tab navigation? → Check `components/ui/` for existing tabs/pills
- Need a dropdown? → Use existing ClassificationPill or dropdown patterns
- Need a new pattern entirely? → Ask: "I need a [X] element that doesn't exist yet. May I create one?"

---

## Git Commits

### Commit Message Rules

| Rule | Example |
|------|---------|
| **Only relevant changes** | Describe what was actually changed |
| **No AI attribution** | NEVER use Co-Authored-By, no AI tool mentions |
| **Conventional format** | `feat:`, `fix:`, `docs:`, `refactor:` |
| **Concise** | Summary line under 72 characters |

**IMPORTANT:** NEVER include `Co-Authored-By: Claude <noreply@anthropic.com>` or any AI tool attribution in commit messages. Multiple developers work on this project - commit messages should focus on WHAT was changed, not WHO or WHAT tool was used.

### Good Commit Message

```
feat(frontend): implement SabineAgentView component

- Add AgentAvatar with animated status indicators
- Add ActivityFeed with icons and timestamps
- Add StatsDisplay for daily statistics
- Fix SSR hydration with static timestamps
```

### Bad Commit Message

```
feat: add new feature

This was created with AI assistance.

Co-Authored-By: AI Tool <noreply@example.com>
```

---

## Commands

**Alle Befehle über `pnpm run` - einheitliches Interface.**

### Frontend

```bash
cd frontend
pnpm install                     # Dependencies (einmalig)
pnpm run dev                     # Dev Server (port 3000)
pnpm run lint                    # ESLint
pnpm run type-check              # TypeScript
pnpm run validate                # Lint + Type-check
pnpm run self-audit              # Full compliance check
pnpm run build                   # Production Build
pnpm run start                   # Production Server
```

### Backend

```bash
cd backend
pnpm install                     # Dependencies (einmalig)
pnpm run dev                     # Dev Server (port 4000)

# Convex
npx convex dev                   # Start Convex dev server
npx convex deploy                # Deploy to cloud
```

### Testing

```bash
cd frontend
pnpm run test                    # E2E tests (Playwright)
pnpm run test:ui                 # E2E with UI
pnpm run test:headed             # E2E with visible browser
```

---

## Testing Strategy

### Testing Pyramid

```
        ┌───────────┐
        │    E2E    │  10% - Critical flows only
        │    (10)   │
        ├───────────┤
        │Integration│  30% - API, DB
        │    (30)   │
        ├───────────┤
        │   Unit    │  60% - Logic, Utils
        │   (60)    │
        └───────────┘
```

### Rules

| Type | When to Write | Tools |
|------|---------------|-------|
| **Unit** | Business logic, utilities | Vitest |
| **Integration** | API endpoints, DB operations | Vitest + Supertest |
| **E2E** | Critical user flows only | Playwright |

### E2E Testing Guidelines

**ONLY write E2E tests for:**
- Critical user journeys (login, main workflows)
- Features that touch multiple systems
- High-risk functionality

**DO NOT write E2E tests for:**
- Simple CRUD operations
- Individual components (use unit tests)
- Edge cases (use integration tests)

### Test Organization

```
frontend/
├── e2e/
│   ├── pages/              # Page Objects
│   │   └── ControlboardPage.ts
│   └── specs/              # Test files
│       └── controlboard.spec.ts
└── src/
    └── lib/
        └── __tests__/      # Unit tests
```

### Page Objects Pattern

```typescript
// e2e/pages/ExamplePage.ts
export class ExamplePage {
  readonly page: Page;
  readonly header: Locator;

  constructor(page: Page) {
    this.page = page;
    this.header = page.locator("h1");
  }

  async goto() {
    await this.page.goto("/example");
  }
}
```

### When Implementing Features

1. Write unit tests for business logic (60%)
2. Write integration tests for API/DB (30%)
3. Write E2E tests only for critical flows (10%)

**Reference:** `.claude/reference/testing-and-logging.md`

---

## Development Workflow

### Feature Implementation Flow

```
/plan-feature → /execute → /validation:self-audit → /commit
```

| Step | Command | Purpose |
|------|---------|---------|
| 1. Plan | `/plan-feature [name]` | Create implementation plan |
| 2. Implement | `/execute [plan]` | Execute the plan |
| 3. Audit | `/validation:self-audit` | Verify compliance with all standards |
| 4. Commit | `/commit` | Create formatted commit |

### Self-Audit Checklist

After implementing any feature, verify:

**Automated (via `pnpm run self-audit`):**
- [ ] TypeScript passes
- [ ] ESLint passes
- [ ] Build succeeds
- [ ] No `any` types
- [ ] No Date.now()/Math.random() in SSR
- [ ] No inline styles
- [ ] No console.log statements
- [ ] Files under 300 lines

**Manual (check reference docs):**
- [ ] `design-system.md` - Colors, shadows, components
- [ ] `ssr-hydration.md` - SSR safety
- [ ] `PRD.md` - Feature matches specification
- [ ] Test in browser - Responsive, interactions
- [ ] Visual verification via agent-browser (for UI features)

---

## Skills (Claude Code v2.1.3+)

This project uses Claude Code Skills instead of legacy commands. Skills follow the [Agent Skills](https://agentskills.io) open standard.

### Skill Location

```
.claude/skills/
├── README.md
├── create-prd/SKILL.md
├── plan-feature/SKILL.md
├── execute/SKILL.md
├── commit/SKILL.md
├── prime/SKILL.md
├── init-project/SKILL.md
├── screenshot/SKILL.md
└── update-readme/SKILL.md
```

### Available Skills

| Skill | Purpose | PIV Phase |
|-------|---------|-----------|
| `/create-prd` | Create Product Requirements | Planning |
| `/plan-feature` | Plan feature implementation | Planning |
| `/execute` | Execute implementation plan | Implementation |
| `/commit` | Create formatted commit | Implementation |
| `/prime` | Load project context | Any |
| `/init-project` | Initialize new project | Planning |
| `/screenshot` | Visual verification | Validation |
| `/update-readme` | Update documentation | Implementation |
| `/promote` | Promote patterns to upstream | Any |

### Skill vs Mastra Tool

| Concept | What It Is | Location |
|---------|-----------|----------|
| **Claude Code Skill** | Instructions/prompts for Claude | `.claude/skills/` |
| **Mastra Tool** | Executable code for AI agents | `mastra/src/tools/` |

Skills are prompts that guide Claude's behavior. Mastra tools are actual code implementations that agents can execute.

### Creating New Skills

1. Create directory: `.claude/skills/my-skill/`
2. Create `SKILL.md` with YAML frontmatter:

```yaml
---
name: my-skill
description: What this skill does and when to use it
disable-model-invocation: true
allowed-tools: Read, Write, Bash
argument-hint: [args]
---

# Instructions

[Markdown content with instructions]
```

See: https://code.claude.com/docs/en/skills

---

## Environment Variables

```env
# Database (Convex)
NEXT_PUBLIC_CONVEX_URL=https://your-project.convex.cloud
# Or for self-hosted:
# NEXT_PUBLIC_CONVEX_URL=http://localhost:3210

# AI
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...

# n8n (optional)
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme

# App
NODE_ENV=development
PORT=3000
```

---

## IDE & Agent Configurations

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Claude Code instructions (this file) |
| `AGENTS.md` | AI Agent rules (Cursor, etc.) |

**IMPORTANT:** Both files MUST be updated together. When modifying rules in `CLAUDE.md`, also update `AGENTS.md` to keep them synchronized.

### Documentation Sync Rule

When updating project rules:
1. Update `CLAUDE.md` first
2. Update `AGENTS.md` with the same changes
3. Verify both files have consistent rules

---

## MCP Servers

Claude Code can be extended with MCP servers:

```bash
# Playwright for E2E Tests
claude mcp add playwright npx @playwright/mcp@latest

# GitHub for Issue/PR Management
claude mcp add github -- npx @modelcontextprotocol/server-github
```

---

## Agent Browser (Visual Testing Tool)

### Overview

The project uses `agent-browser` for automated visual testing and verification. This tool allows AI agents to interact with the browser, take screenshots, and verify UI implementations.

**Repository:** https://github.com/vercel-labs/agent-browser

### Installation Location

- **Package:** `frontend/package.json` (devDependencies)
- **Binary:** `frontend/node_modules/.bin/agent-browser`
- **Chromium:** Downloaded via `pnpm exec agent-browser install`

### Setup Commands

```bash
cd frontend

# Install as dev dependency (already done)
pnpm add -D agent-browser

# Download Chromium browser (required once)
pnpm exec agent-browser install
```

### Usage

```bash
cd frontend

# Start agent-browser session
pnpm exec agent-browser

# Available commands in session:
# - goto <url>         Navigate to URL
# - screenshot         Take screenshot
# - click <id>         Click element by accessibility ID
# - type <id> <text>   Type text into element
# - snapshot           Get accessibility tree snapshot
```

### Visual Verification Workflow

After implementing visual features, use agent-browser to verify:

1. Start dev server: `pnpm run dev`
2. In another terminal: `pnpm exec agent-browser`
3. Navigate: `goto http://localhost:3000/<page>`
4. Take screenshot: `screenshot`
5. Verify UI matches specification

### Important Notes

- **Dev dependency only** - Not included in production builds
- **Requires Chromium** - Run `agent-browser install` after fresh clone
- **Local only** - For development verification, not CI/CD

---

## Visual Verification Rule

### Ask Before Taking Screenshots

**IMPORTANT:** Screenshots should only be taken on user request. Always ask the user before starting the screenshot workflow.

When implementing features with visual UI changes:

1. **Complete the implementation** first
2. **Ask the user** if they want visual verification screenshots
3. **Only if confirmed**, use agent-browser to capture the current state
4. **Compare against PRD** to ensure specification compliance

### When to Offer

Offer visual verification for:
- New UI components
- Layout changes
- Styling updates
- Header/Footer modifications
- Any PRD-specified visual changes

### Workflow

```
Implementation → Ask user "Soll ich Screenshots zur Verifizierung machen?" → (If yes) Start dev server → agent-browser → screenshot → Verify against PRD
```

**DO NOT** automatically take screenshots after implementing features. Always ask first.

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

## When Unclear

**Always ask for clarification** if:
- Requirements are ambiguous
- Best practices conflict with user requirements
- Missing context or information
- Security concerns arise

**Never assume** - ask via status updates or questions.

---

## Mandatory Working Model: PIV Loop (Required)

This project strictly follows the **PIV workflow model**:

1. Planning
2. Implementation
3. Validation
4. Iteration

The PIV Loop is **mandatory** and must **not be shortened, skipped, or mixed**.

Claude MUST always operate in exactly **one** PIV phase at a time and must be able to clearly state which phase it is currently in.

---

## Mapping: PIV ↔ Project Commands (Binding)

### 1. Planning
Allowed commands:
- `plan-feature`
- `create-prd`
- `init-project`
- Analysis and audit tasks without execution

Purpose:
- Understand the problem
- Structure the solution
- Prepare decisions

Rules:
- NO code
- NO implementation
- NO technical assumptions
- ONLY analysis, structure, plans, scope definitions, and constraints

---

### 2. Implementation
Allowed commands:
- `execute`

Purpose:
- Implement **exactly** what was approved in the Planning phase

Rules:
- No scope expansion
- No new ideas
- No silent changes
- Implementation must strictly follow the approved plan

---

### 3. Validation
Allowed commands:
- `validate`
- `self-audit`
- `code-review`

Purpose:
- Verify against:
  - PRD
  - CLAUDE.md
  - AGENTS.md
  - Reference documents
  - Approved plan

Rules:
- Explicitly surface deviations
- Highlight risks and inconsistencies
- NO fixes
- NO new implementation

---

### 4. Iteration
Purpose:
- Derive the next PIV cycle

Rules:
- Suggestions only
- NO implementation
- Every iteration MUST start again with **Planning**

---

## Mandatory Meta Rules (Non-Negotiable)

- NEVER combine multiple PIV phases in one response
- NEVER jump directly from Planning to Implementation
- EVERY new task starts with Planning
- If information is missing → STOP and ask
- Technical decisions are ONLY allowed if explicitly defined in:
  - `CLAUDE.md`
  - `AGENTS.md`
  - `.claude/reference/*`

---

## Command Enforcement

Claude MUST:
- Use the existing project commands
- Respect the defined project structure
- Never invent new workflows
- Never take shortcuts in the process

Any deviation from the PIV model is considered an error.


---

**Last Updated:** January 2026
**Maintainer:** Lucidlabs
**Version:** 1.0
