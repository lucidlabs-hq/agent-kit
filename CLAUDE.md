# Agent Kit

> **AI Agent Starter Kit by Lucid Labs GmbH**
> Reusable boilerplate for rapid AI agent project development

## UPSTREAM REPOSITORY - READ-ONLY RULES (NON-NEGOTIABLE)

**THIS IS THE UPSTREAM TEMPLATE REPOSITORY.** It is the single source of truth for all Lucid Labs projects.

### What This Repo Is For

| Allowed | NOT Allowed |
|---------|-------------|
| Spawning new projects via `create-agent-project.sh` | Direct feature development |
| Receiving promoted patterns via `/promote` (always through PR) | Running `pnpm run dev` or any dev server |
| Serving as sync source for downstream projects | Direct code changes without PR |
| Maintaining shared reference docs and skills | Any `git push origin main` |

### Hard Rules

1. **NEVER push directly to main.** Branch Protection enforces this. All changes go through Pull Requests.
2. **NEVER develop features here.** This is a template, not a project. Feature work happens in downstream projects under `../projects/`.
3. **NEVER start dev servers here.** No `pnpm run dev`, no `npx convex dev`, no Mastra. This repo has no running application.
4. **Changes come ONLY from two sources:**
   - **Promote** (`/promote`): Battle-tested patterns from downstream projects, always via PR
   - **Direct edits**: Only for template infrastructure (scripts, reference docs, CLAUDE.md rules), always via PR
5. **If you are a Claude session working in a downstream project:** You must NEVER create, modify, or delete files in this repository. Use `/promote` or `/sync` skills instead.
6. **If you are a Claude session working directly in this repo:** Every change MUST go through a feature branch and Pull Request. No exceptions, no `--admin` merge bypasses.

### Detection Rule for AI Agents

**Before making any file change, check:**
```
Is the current working directory inside lucidlabs-agent-kit/?
  YES → You are in the UPSTREAM. Only template maintenance is allowed.
        Create a branch. Make changes. Open a PR.
  NO  → You are in a downstream project. Normal development rules apply.
        NEVER touch files in ../../lucidlabs-agent-kit/ directly.
```

---

## Open Questions

- TODO: Resolve state management conflict: `architecture.md` mentions Zustand, but rules forbid external state libs. For now, use React hooks only.

## Quick Start

```bash
# Alle Befehle über pnpm run
pnpm install                     # Dependencies (NEVER npm/yarn)
pnpm run dev                     # Dev Server (Bun Runtime)
pnpm run build                   # Production Build (Node.js)
```

## Session Rules

| Rule | Action |
|------|--------|
| **Auto-start Frontend** | ALWAYS start `pnpm run dev` in background at session start |
| **Auto-start Convex** | ALWAYS start `npx convex dev` in background at session start (keeps functions synced) |
| **Auto-start Mastra** | If project has `mastra/` directory, ALWAYS start Mastra dev server in background at session start |
| **Keep Servers Running** | ALL project services (frontend, Convex, Mastra) must run throughout the session |
| **Report URL** | Tell user the localhost URL after each server starts |
| **Convex Sync** | After creating/modifying Convex schema or functions, wait for Convex dev to sync (watch the terminal) |

### Config Backup Rule (MANDATORY)

**BEFORE modifying any configuration file, ALWAYS create a backup first.**

This applies to: workflow files (`.github/workflows/`), `docker-compose.yml`, `Caddyfile`, `package.json`, `.env` files, `tsconfig.json`, CI/CD configs, and any other infrastructure/config file that is already working in production.

**Procedure:**

1. **Create backup directory:** `.backups/<date>/` in the project root (e.g. `.backups/2026-02-11/`)
2. **Copy the original file** before making changes: `cp path/to/config .backups/<date>/config.backup`
3. **For git-tracked files:** Also use `git show HEAD:path/to/file > .backups/<date>/filename.backup` to preserve the last committed version
4. **Document changes:** Create `.backups/<date>/CHANGES.md` listing what was changed and why

**Backup directory is gitignored.** Add `.backups/` to `.gitignore` if not already present.

**Why:** Configuration files that are already working in production must never be blindly overwritten. If something breaks, we need the ability to instantly restore the previous version without digging through git history.

```bash
# Example: Before modifying deploy-hq.yml
mkdir -p .backups/2026-02-11
cp .github/workflows/deploy-hq.yml .backups/2026-02-11/deploy-hq.yml.backup
# Now safe to edit .github/workflows/deploy-hq.yml
```

### Full-Stack Component Rule (MANDATORY)

**Every project component chosen at setup MUST be started in dev mode AND deployed to production.**

When a project includes these directories, the corresponding services are MANDATORY:

| Directory | Dev Command | Production |
|-----------|-------------|------------|
| `frontend/` | `pnpm run dev` | docker-compose: `frontend` service |
| `convex/` | `npx convex dev` | docker-compose.convex.yml |
| `mastra/` | `cd mastra && pnpm run dev` | docker-compose: `mastra` service |
| `n8n/` | docker-compose.dev.yml | docker-compose: `n8n` service |

**No partial deployments.** If a component exists in the repo, it MUST be deployed. If a service is missing from docker-compose.yml, add it before deploying.

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

**LLM Access:** Via Portkey AI Gateway (centralized key management, cost tracking, fallbacks)

### AI Gateway

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Gateway** | Portkey | LLM Proxy, cost tracking, fallbacks |
| **Endpoint** | `http://lucidlabs-portkey:8787` | Internal HQ access |
| **Dashboard** | portkey.lucidlabs.de (optional) | Cost monitoring |

### Authentication

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Framework** | Better Auth | Modern TypeScript auth |
| **Database** | Convex Adapter | Session/user storage |
| **Login Method** | Magic Link only (via Resend) | Passwordless authentication |
| **Sessions** | Convex tables | Reactive, automatic sync |

**Integration:** [Better Auth + Convex](https://www.better-auth.com/docs/integrations/convex)

**MANDATORY Auth Rule:**
- **Magic Links via Resend** is the ONLY authentication method. No passwords, no OAuth, no social login.
- All projects use `magicLinkClient()` plugin in `auth-client.ts`
- Email delivery is handled by Resend
- Accounts are admin-created only (no self-signup)
- This is non-negotiable across all LUCIDLABS-HQ projects

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

### CI/CD Pipeline

Every project uses a PR-based workflow with two GitHub Actions workflows:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | PR against `main` | Lint + Type-Check + Build (parallel) |
| `deploy-hq.yml` | Push to `main` (after merge) | Rsync + Docker Build + Convex Deploy + Health Check |

**Security (mandatory):**
- All Actions pinned to commit SHAs (not tags) - see CVE-2025-30066
- Only first-party Actions allowed (`actions/checkout`, `actions/setup-node`, `pnpm/action-setup`)
- Minimal permissions (`contents: read`)
- SSH keys only in deploy job

**Branch Protection (mandatory for all repos):**
- Required status checks: `lint`, `type-check`, `build`
- Required 1 approving review
- No direct push to main

**Templates:** `.github/workflow-templates/` in Agent Kit.
**Full docs:** `.claude/reference/ci-cd-security.md`

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
| **Sessions** | Better Auth + Convex |
| **File storage** | Convex file storage |

**Benefits:**
- Automatic real-time updates to UI
- Type-safe queries and mutations
- Built-in vector search for RAG
- Self-hosted or cloud deployment

### Convex Project Isolation (MANDATORY)

**JEDES Projekt MUSS seine eigene Convex-Instanz haben - lokal UND in Production!**

| Rule | Details |
|------|---------|
| **Project-specific setup** | Each project has its own `convex/` folder and `docker-compose.dev.yml` |
| **Unique container names** | Use project-prefixed names (e.g., `cotinga-convex-backend`, not `convex-backend`) |
| **Unique ports** | Check `.claude/reference/port-registry.md` before choosing ports |
| **Working directory** | ALWAYS `cd` to the project root before running `npx convex` commands |
| **No shared backends** | NEVER connect a project to another project's Convex backend |
| **Production isolation** | Each project gets own Convex container on LUCIDLABS-HQ |

**Warum?** Shared Convex-Instanzen führen zu Schema-Konflikten, Daten-Kollisionen und Debugging-Chaos.

Siehe: `.claude/reference/convex-self-hosted.md` → "Project Isolation"

### Port Registry Rule (MANDATORY)

**Before starting any dev server, ALWAYS check the port registry to avoid conflicts.**

See: `.claude/reference/port-registry.md`

#### Local Development Ports

```bash
# Before choosing ports, scan all projects:
for proj in ../projects/*; do
  [ -f "$proj/docker-compose.dev.yml" ] && echo "=== $(basename $proj) ===" && \
  grep -oE '"[0-9]+:' "$proj/docker-compose.dev.yml" | tr -d '":'
done
```

**NEVER use locally:**
- Port 3000 (standard Next.js - conflicts with everything)
- Port 3210 (standard Convex - use mapped ports)
- Any port already registered by another project

#### Production Ports (LUCIDLABS-HQ)

Production ports müssen AUCH registriert werden, um Caddy-Konflikte zu vermeiden:

| Service Type | Port Range | Example |
|--------------|------------|---------|
| **Frontend** | 3050-3099 | cotinga: 3050, invoice: 3060 |
| **Mastra API** | 4050-4099 | cotinga: 4050, invoice: 4060 |
| **Convex Backend** | 3210-3299 | cotinga: 3214, invoice: 3216 |
| **Convex Dashboard** | 6790-6799 | cotinga: 6794, invoice: 6796 |

**Registrierung:** Update `/opt/lucidlabs/registry.json` auf dem Server nach Deployment.

```bash
# CORRECT: Run from project directory
cd /path/to/my-project
npx convex dev --once

# WRONG: Running convex from wrong directory
cd /some/other/path
npx convex dev  # May connect to wrong backend!
```

---

## AI-Coding Principles

**Siehe:** `.claude/reference/ai-coding-principles.md` für vollständige Dokumentation.

### Zod-First Development

```typescript
// 1. Schema definieren (Single Source of Truth)
const UserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2),
  role: z.enum(['admin', 'user']),
});

// 2. Type ableiten (nie manuell!)
type User = z.infer<typeof UserSchema>;

// 3. Validation bei Boundaries
const user = UserSchema.parse(input);
```

### Sorting für Konsistenz

| Was | Sortierung |
|-----|------------|
| **Imports** | Gruppiert + alphabetisch |
| **Object Keys** | Alphabetisch |
| **Interface Props** | Alphabetisch |
| **Tailwind Classes** | Logische Gruppen (via Plugin) |

### Code für AI optimieren

| Prinzip | Warum |
|---------|-------|
| **Explizit > Implizit** | AI versteht benannte Konstanten besser |
| **Flache Strukturen** | Weniger Nesting = einfacher für AI |
| **Konsistente Namen** | AI erkennt Patterns schneller |
| **Max 300 Zeilen** | Kleinere Dateien = besserer Kontext |

### Spec-First Workflow

1. **Spec schreiben** - Requirements, Schemas, Edge Cases
2. **Tests definieren** - Was muss funktionieren?
3. **AI implementieren lassen** - Mit klarem Kontext
4. **Review + Validate** - Subagents + manuelle Prüfung

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
| `.claude/reference/aidd-methodology.md` | **AIDD: Adaptive AI Discovery & Delivery workflow** |
| `.claude/reference/linear-setup.md` | **Linear MCP setup, OAuth, troubleshooting** |
| `.claude/reference/productive-integration.md` | **Productive.io API, Delivery Units, Reporting** |
| `.claude/reference/service-dashboard-audit.md` | Service Dashboard implementation status |
| `.claude/reference/minio-integration.md` | **MinIO S3-compatible file storage** |
| `.claude/reference/ai-framework-choice.md` | **Mastra vs Vercel AI SDK decision guide** |
| `.claude/reference/llm-configuration.md` | **LLM model selection, pricing, Portkey config** |
| `.claude/reference/mcp-servers.md` | **All MCP servers (Linear, MinIO, n8n, PromptFoo)** |
| `.claude/reference/azure-openai-integration.md` | **Azure OpenAI (GDPR-konform, optional)** |
| `.claude/reference/ai-coding-principles.md` | Zod-first, sorting, AI-optimized patterns |
| `.claude/reference/architecture.md` | Platform architecture, tech stack |
| `.claude/reference/design-system.md` | UI/UX, Tailwind v4, shadcn/ui |
| `.claude/reference/error-handling.md` | Error handling patterns |
| `.claude/reference/auth-architecture.md` | **Centralized BetterAuth, cross-subdomain SSO, roles** |
| `.claude/reference/betterauth-convex-setup.md` | **BetterAuth + Convex setup guide, pitfalls, Docker config** |
| `.claude/reference/ssr-hydration.md` | SSR, hydration, Date.now() pitfalls |
| `.claude/reference/mastra-best-practices.md` | AI agents, tools, workflows |
| `.claude/reference/deployment-best-practices.md` | Docker, Caddy, Elestio, CI/CD |
| `.claude/reference/deployment-targets.md` | **LUCIDLABS-HQ vs DEDICATED deployment** |
| `.claude/reference/git-workflow.md` | Solo vs Team Git workflow, PRs |
| `.claude/reference/ssh-keys.md` | **SSH Key Anleitung für Entwickler** |
| `.claude/reference/watchtower.md` | **Automatic Docker container updates** |
| `.claude/reference/scaling.md` | Stateless patterns, Convex scaling |
| `.claude/reference/ci-cd-security.md` | **CI/CD security: SHA-pinning, workflow architecture, branch protection** |
| `.claude/reference/session-handoff.md` | **Projekt-Wechsel ohne Session-Neustart** |
| `.claude/reference/pnpm-workspaces.md` | **pnpm Workspace setup for Monorepo CI** |
| `.claude/reference/promote-sync.md` | **Promote & Sync architecture between upstream/downstream** |
| `.claude/reference/task-system.md` | Task tracking, custom subagents, Swarm |
| `convex/README.md` | Convex database setup, queries, mutations |
| `mastra/README.md` | Mastra setup guide |
| `WORKFLOW.md` | Complete development workflow guide |

---

## Tech Stack Documentation Rule

**MANDATORY:** When adding new technology to the stack (downstream or upstream):

1. **Update CLAUDE.md** - Add to Tech Stack table
2. **Create reference doc** - `.claude/reference/<technology>.md`
3. **Update AGENTS.md** - Keep in sync with CLAUDE.md
4. **Update infrastructure docs** - If deployment-related

This ensures all AI agents and developers have current knowledge.

---

## README Port Documentation Rule (MANDATORY)

**Every project README.md MUST include a Ports section documenting both development and production ports.**

The section must contain two tables:

1. **Development** - Service name, port, localhost URL
2. **Production** - Service name, internal port, external port, domain

When adding or changing ports (in docker-compose.yml, package.json scripts, or env defaults), the README Ports section MUST be updated in the same commit.

---

## New Project Initialization Rule

**MANDATORY:** When creating a new project from this template:

1. **Update SEO Metadata** - Change `frontend/app/layout.tsx`:
   ```typescript
   export const metadata: Metadata = {
     title: "Project Name | Description",
     description: "Project description for search engines",
   };
   ```
   - **NEVER** leave "Agent Kit | AI Agent Starter" in production projects
   - Use the actual project name and customer-relevant description

2. **Update Package Names** - Change `package.json` in frontend/mastra/backend
3. **Create PRD** - `.claude/PRD.md` with project requirements
4. **Update README.md** - Project-specific documentation

This ensures branding and SEO are correct from the start.

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

## Downstream Project Rule (MANDATORY)

**When working in a downstream project (identified by `.claude/PROJECT-CONTEXT.md` with `type: downstream`):**

**ALL new files MUST be created in the CURRENT project, NEVER in the upstream repository.**

| Action | Create In |
|--------|-----------|
| New workflows | `./n8n/workflows/` (current project) |
| New skills | `./.claude/skills/` (current project) |
| New components | `./frontend/components/` (current project) |
| New tools | `./mastra/src/tools/` (current project) |
| New reference docs | `./.claude/reference/` (current project) |

**Check before creating:**
1. Read `.claude/PROJECT-CONTEXT.md` to identify project type
2. If `type: downstream` → create files HERE
3. If `type: upstream` or file doesn't exist → you're in the template

**Exception:** Use `/promote` skill to intentionally copy proven patterns TO upstream.

### Upstream Interaction Rules (HARD BOUNDARY)

**From a downstream project, the ONLY permitted interactions with upstream are:**

| Permitted | How | Direct File Access? |
|-----------|-----|---------------------|
| Pull updates | `/sync` skill or `./scripts/sync-upstream.sh` | READ only (copies TO downstream) |
| Push patterns | `/promote` skill or `./scripts/promote.sh` | Creates PR in upstream (never direct push) |
| Spawn new project | `./scripts/create-agent-project.sh` | READ only (copies FROM upstream) |

**FORBIDDEN from any downstream project session:**
- `cd ../../lucidlabs-agent-kit && [any write operation]`
- Writing, editing, or deleting ANY file under `../../lucidlabs-agent-kit/`
- `git push` to ANY branch in the upstream repo (use scripts which handle branching)
- Opening the upstream repo as a working directory

**This is a hard boundary.** The upstream is a curated knowledge base, not a workspace. Treat it like a package registry: you consume from it (`/sync`) and contribute to it (`/promote`), but you never write to it directly.

**Rationale:** Downstream projects are customer-specific. Creating files in upstream pollutes the shared template and causes sync conflicts.

---

## Git Workflow (MANDATORY)

### PR-Only Rule (Non-Negotiable)

**ALL changes to `main` MUST go through Pull Requests.** Direct pushes to main are blocked by Branch Protection.

```
Feature Branch  →  PR (CI: lint + type-check + build)  →  Review  →  Merge  →  Auto-Deploy
```

**This applies to everyone: developers, AI agents, admins. No exceptions.**

| Allowed | NOT Allowed |
|---------|-------------|
| `git push origin feature/my-branch` | `git push origin main` |
| `gh pr create` | Direct commits on main |
| `/pr` skill | `git push --force origin main` |

**Use the `/pr` skill** to create branches, commit, push, and open PRs in one flow.

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

### Dev Server Start Rule (MANDATORY)

**ALWAYS** before starting a dev server:

1. **Check what's running** on the target port:
   ```bash
   lsof -i:3000  # or :4000 for backend
   ```

2. **Show the user** what's currently running (if anything)

3. **Kill existing process** if needed:
   ```bash
   lsof -ti:3000 | xargs kill -9
   ```

4. **Start server and show port**:
   ```bash
   pnpm run dev
   # Output must show: "Local: http://localhost:PORT"
   ```

This ensures the user always knows:
- What was running before
- Which port the new server is on
- No silent conflicts or port switches

**ALWAYS show clickable links AND Convex credentials** in output:
```
┌──────────────────┬──────┬───────────────────────┐
│     Service      │ Port │         Link          │
├──────────────────┼──────┼───────────────────────┤
│ Frontend         │ 8080 │ http://localhost:8080 │
│ Mastra API       │ 8081 │ http://localhost:8081 │
│ Convex Backend   │ 8082 │ http://localhost:8082 │
│ Convex Dashboard │ 8083 │ http://localhost:8083 │
│ Mastra Studio    │ 8085 │ http://localhost:8085 │
└──────────────────┴──────┴───────────────────────┘

Convex Login:
  Dashboard:      http://localhost:8083
  Deployment URL: http://localhost:8082
  Admin Key:      [run: docker exec <container> ./generate_admin_key.sh]
```

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
3. **UI Changes:** Use `/visual-verify` for quick verification
4. Write E2E tests only for critical production flows (10%)

### Visual Verification vs E2E

| Development (90%) | Production (10%) |
|-------------------|------------------|
| `/visual-verify` | E2E Tests |
| agent-browser | Playwright |
| Sekunden | Minuten |
| Jede UI-Änderung | Login, Checkout, Payment |

**Regel:** `/visual-verify` für Development, E2E nur für kritische Flows.

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

## Task Management (MANDATORY)

**REGEL:** Bei jeder nicht-trivialen Aufgabe MUSS die Task-Funktion verwendet werden.

### Wann Tasks erstellen

| Situation | Task erstellen? |
|-----------|-----------------|
| Multi-Step Implementierung | ✓ JA |
| Setup/Konfiguration | ✓ JA |
| Bug mit mehreren Dateien | ✓ JA |
| Einfache Textänderung | ✗ NEIN |
| Einzelne Funktion hinzufügen | ✗ NEIN |

### Task Workflow

```
1. TaskCreate     → Aufgabe anlegen (subject, description, activeForm)
2. TaskUpdate     → Dependencies setzen (addBlockedBy)
3. TaskUpdate     → Status: in_progress (vor Beginn)
4. [Arbeit]       → Implementierung
5. TaskUpdate     → Status: completed (nach Abschluss)
6. TaskList       → Nächste Aufgabe finden
```

### Beispiel

```
# Tasks erstellen
TaskCreate: "Setup Convex Docker"
TaskCreate: "Create Schema"
TaskCreate: "Install Dependencies"

# Dependencies
TaskUpdate #2: addBlockedBy [#1]
TaskUpdate #3: addBlockedBy [#1]

# Arbeiten
TaskUpdate #1: status=in_progress
[docker compose up]
TaskUpdate #1: status=completed

TaskList → zeigt #2 und #3 als verfügbar
```

### Vorteile

- **Tracking:** Fortschritt ist sichtbar
- **Kontext:** Bei Unterbrechung weiß man wo man war
- **Dependencies:** Reihenfolge ist klar
- **Kommunikation:** User sieht was passiert

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
├── linear/SKILL.md
├── session-end/SKILL.md
├── productizer/SKILL.md
├── visual-verify/SKILL.md
├── pre-production/SKILL.md
├── deploy/SKILL.md
├── screenshot/SKILL.md
└── update-readme/SKILL.md
```

### Available Skills

| Skill | Purpose | Phase |
|-------|---------|-------|
| `/start` | Entry point - create or open project | Any |
| `/checkout-project` | Clone existing project from GitHub | Any |
| `/prime` | Load project context + check Linear | Any |
| `/linear` | Linear project management (create/update/sync) | Any |
| `/create-prd` | Create Product Requirements | Planning |
| `/plan-feature` | Plan feature implementation | Planning |
| `/init-project` | Initialize new project | Planning |
| `/execute` | Execute implementation plan | Implementation |
| `/commit` | Create formatted commit | Implementation |
| `/update-readme` | Update documentation | Implementation |
| `/visual-verify` | UI verification via agent-browser (fast) | Validation |
| `/browser` | Interactive browser automation (open, click, fill, screenshot) | Any |
| `/pre-production` | Security & Quality Check before deploy | Validation |
| `/deploy` | Deploy to LUCIDLABS-HQ (SSH, Caddyfile, n8n MCP) | Deployment |
| `/mistral` | Setup Mistral AI for EU-friendly LLM + PDF analysis | Setup |
| `/promptfoo` | LLM evaluation & prompt testing | Validation |
| `/llm-evaluate` | LLM cost/performance evaluation, model selection | Planning |
| `/screenshot` | Visual verification screenshots | Validation |
| `/session-end` | End session, update Linear, clean state | Any |
| `/productizer` | Bridge Linear ↔ Productive.io for customer reporting | Any |
| `/notion-publish` | Publish markdown to Notion (private pages) | Any |
| `/clone-skill` | Clone skills from central repository | Any |
| `/publish-skill` | Share your skills with the team | Any |
| `/promote` | Promote patterns to upstream | Any |
| `/sync` | Sync updates from upstream | Any |

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
# Database (Convex - self-hosted, NEVER use convex.cloud)
NEXT_PUBLIC_CONVEX_URL=http://localhost:3210

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

### Two-Strike Rule (Roadblock Protocol)

**If the same approach fails twice → STOP. No guesswork.**

When you encounter an error or roadblock:

1. **First attempt fails:** Adjust and try a different variation
2. **Second attempt fails:** STOP immediately. Do NOT try a third time with guesswork
3. **Research phase:** Perform targeted research (web search, docs, codebase analysis)
4. **Report findings:** Present what you learned to the user before proceeding
5. **Only continue** with a clear, evidence-based approach

**This rule is absolute.** Blindly retrying with variations is not engineering — it's gambling. Every action must be intentional and informed. If you don't understand why something failed, you don't have enough information to fix it.

**Examples of violations:**
- Trying 3 different file paths hoping one works
- Retrying a deploy command with slightly different flags
- Guessing package names or config options

**Correct behavior:**
- First SSH path fails → try the alternative you know about
- Second path fails → STOP, inspect the server (`docker inspect`, `find`, etc.) to discover the actual path
- Only proceed when you have concrete evidence of the correct approach

---

## Command Enforcement

Claude MUST:
- Use the existing project commands
- Respect the defined project structure
- Never invent new workflows
- Never take shortcuts in the process

Any deviation from the PIV model is considered an error.

<!-- UPSTREAM-SYNC-END -->
<!-- Everything ABOVE this marker is synced from upstream agent-kit. -->
<!-- Everything BELOW this marker is project-specific and will NOT be overwritten by sync. -->

---

**Last Updated:** February 2026
**Maintainer:** Lucid Labs GmbH
**Version:** 1.1
