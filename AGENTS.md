# Agent Kit - AI Agent Rules

> **AI Agent Starter Kit by Lucid Labs GmbH**
> This file is for AI tools other than Claude Code (Cursor, Windsurf, etc.).
> **CLAUDE.md is the source of truth.** This file mirrors its rules.

---

## Source of Truth

**All development rules, code standards, and workflows are defined in `CLAUDE.md`.**
This file provides the same rules in a format consumable by Cursor, Windsurf, and other AI IDEs.

When in doubt, `CLAUDE.md` takes precedence.

---

## UPSTREAM REPOSITORY - READ-ONLY RULES

**THIS IS THE UPSTREAM TEMPLATE REPOSITORY.** Direct edits are not allowed.

1. **NEVER push directly to main.** All changes go through Pull Requests.
2. **NEVER develop features here.** Feature work happens in downstream projects.
3. **NEVER start dev servers here.** This repo has no running application.
4. **Downstream sessions:** NEVER modify files in this repository. Use `/promote` or `/sync`.

### 4-Layer Protection

| Layer | Mechanism | Blocks |
|-------|-----------|--------|
| GitHub | Branch Protection | Direct pushes to main |
| Git Hook | `.githooks/pre-commit` | Unauthorized commits |
| AI Agent | `.claude/settings.json` hook | Edit/Write operations |
| Filesystem | `chflags uchg` (macOS) | Any file modification |

---

## Tech Stack

### Core (Always)

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 15+ (App Router), TypeScript 5+ (strict) |
| Styling | Tailwind CSS 4 (ONLY Tailwind, no inline CSS) |
| Components | shadcn/ui + Radix UI |
| Package Manager | pnpm (NEVER npm/yarn/bun install) |
| Runtime | Bun (dev), Node.js (prod) |

### Selectable Modules

| Module | Technology | When to Use |
|--------|-----------|-------------|
| Database | Convex | Realtime, type-safe, built-in vector search |
| Auth | Better Auth + Magic Links (via Resend) | Passwordless, admin-created accounts only |
| AI Agents | Mastra | Production agents, tools, workflows |
| AI Prototypes | Vercel AI SDK | Chat UIs, streaming, quick prototypes |
| LLM Gateway | Portkey | Multi-model routing, cost tracking, fallbacks |
| Workflows | n8n | Automation, integrations, scheduling |
| File Storage | MinIO | S3-compatible self-hosted storage |

### AI Models

| Role | Model | Use Case |
|------|-------|----------|
| Primary | Claude Opus 4.5 | Complex reasoning, quality |
| Fast | Gemini Flash / Claude Haiku | High-volume, speed |
| Coding | Claude Sonnet 4.5 | Code generation |

**LLM Access:** Via Portkey AI Gateway (centralized key management, cost tracking, fallbacks)

### Deployment

| Layer | Technology |
|-------|-----------|
| Production | Elestio (self-hosted Docker) |
| Prototypes | Vercel |
| Container | Docker Compose |
| CI/CD | GitHub Actions (SHA-pinned, PR-based) |

---

## Code Standards

### Language & Naming

- **English only** - All code, comments, function names
- **PascalCase** - Components, Types, Interfaces
- **camelCase** - Functions, variables
- **UPPER_SNAKE_CASE** - Constants
- **kebab-case** - File names, URL paths
- **Max 300 lines** per file

### Code Style

- Functional components (no class components)
- Arrow functions: `const fn = () => {}`
- Early returns for readability
- Named exports (no default exports)
- No barrel exports (import directly)

### TypeScript

- `strict: true` always
- No `any` - use explicit types
- Zod schemas for validation at boundaries
- Explicit return types for public functions

### React/Next.js

- Server Components by default
- `'use client'` only when needed
- No `Date.now()`, `Math.random()`, `window` in module scope (hydration mismatch)
- Clickable elements must have `cursor-pointer`

### State Management

| Allowed | NOT Allowed |
|---------|-------------|
| `useState`, `useReducer`, `useContext` | Redux, MobX, Zustand, Jotai |
| URL-based state (`searchParams`) | External state libraries |
| Server Components (preferred) | |

---

## Anti-Patterns

| Category | DO NOT |
|----------|--------|
| Styling | Inline CSS, shadows on cards, semantic colors |
| State | External state libraries |
| Exports | Default exports, barrel exports |
| Code | Files > 500 lines, implicit `any` |
| Package | `npm`, `yarn`, `bun install` |
| Language | German in code/comments |
| SSR | `Date.now()`, `Math.random()`, `window` in module scope |

---

## Git Workflow (PR-Only)

**ALL changes to `main` MUST go through Pull Requests.** No exceptions.

- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`
- **NEVER** include `Co-Authored-By` or AI tool attribution
- Summary line under 72 characters

---

## PIV Workflow (Mandatory)

**Planning -> Implementation -> Validation -> Iteration**

Never combine phases. Never skip phases. See `.claude/reference/piv-workflow.md`.

---

## Reference Documentation

| Document | Topic |
|----------|-------|
| `.claude/PRD.md` | Product requirements |
| `.claude/reference/code-standards.md` | Language, naming, style, TypeScript, React, anti-patterns |
| `.claude/reference/session-rules.md` | Auto-start rules, config backup, full-stack components |
| `.claude/reference/project-rules.md` | Tech stack docs, README ports, init, skills, tasks, workflow |
| `.claude/reference/quality-gates.md` | Gate architecture, subagents, test enforcement |
| `.claude/reference/architecture.md` | Platform architecture, tech stack, project structure |
| `.claude/reference/design-system.md` | UI/UX, Tailwind v4 |
| `.claude/reference/piv-workflow.md` | PIV phases and rules |
| `.claude/reference/testing-strategy.md` | Testing pyramid |
| `.claude/reference/quick-commands.md` | CLI commands |
| `.claude/reference/error-handling.md` | Error patterns |
| `.claude/reference/ssr-hydration.md` | SSR safety |
| `.claude/reference/code-review-checklist.md` | Pre-commit checks |
| `.claude/reference/git-workflow.md` | PR workflow, commit messages |
| `.claude/reference/deployment-best-practices.md` | Docker, CI/CD |
| `.claude/reference/ci-cd-security.md` | SHA-pinning, workflow architecture |
| `.claude/reference/portkey-gateway.md` | LLM Gateway setup |
| `.claude/reference/llm-configuration.md` | LLM model selection, pricing |
| `.claude/reference/mastra-best-practices.md` | AI agents |
| `.claude/reference/vercel-ai-sdk.md` | Prototyping |
| `.claude/reference/shadcn-ui-setup.md` | Component library |
| `.claude/reference/agent-browser-setup.md` | Visual testing |
| `.claude/reference/promote-sync.md` | Upstream/downstream flow, downstream rules |
| `.claude/reference/auth-architecture.md` | BetterAuth, SSO, roles |
| `.claude/reference/convex-self-hosted.md` | Convex setup, project isolation |
| `.claude/reference/port-registry.md` | Port allocations, conflict checking |
| `.claude/reference/future-plans.md` | Feature roadmap |

---

## Sync Rule

**This file MUST stay in sync with `CLAUDE.md`.** When updating `CLAUDE.md`, update this file too.

---

**Last Updated:** February 2026
**Maintainer:** Lucid Labs GmbH
**Version:** 2.0
