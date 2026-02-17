# Agent Kit

> **AI Agent Starter Kit by Lucid Labs GmbH**
>
> A production-ready boilerplate for building AI-powered applications with Next.js, Mastra, Convex, and n8n.

## ⚠️ Important: This is a Template Repository

**Do NOT develop directly in this repository.** Agent Kit is an **upstream template** – you create new projects from it, then promote reusable patterns back.

### Recommended Folder Structure

```
lucidlabs/                              # Your workspace root
│
├── lucidlabs-agent-kit/                # UPSTREAM TEMPLATE (this repo)
│   ├── .claude/skills/                 # Generic development skills
│   ├── frontend/                       # Next.js boilerplate
│   ├── mastra/                         # Agent layer boilerplate
│   └── scripts/
│       ├── create-agent-project.sh     # Creates downstream projects
│       └── promote.sh                  # Promotes patterns upstream
│
└── projects/                           # DOWNSTREAM PROJECTS
    ├── customer-portal/                # Project A (own git repo)
    ├── internal-dashboard/             # Project B (own git repo)
    └── ai-assistant/                   # Project C (own git repo)
```

### Bidirectional Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           lucidlabs/                                    │
│                                                                         │
│   ┌─────────────────────┐                ┌──────────────────────────┐  │
│   │ lucidlabs-agent-kit │    PROMOTE     │       projects/          │  │
│   │     (UPSTREAM)      │◄───────────────│                          │  │
│   │                     │                │  ┌────────────────────┐  │  │
│   │  • Generic skills   │ SYNC/INIT      │  │  customer-portal   │  │  │
│   │  • Boilerplate      │───────────────►│  │   (DOWNSTREAM)     │  │  │
│   │  • Best practices   │                │  │                    │  │  │
│   └─────────────────────┘                │  │  • Domain logic    │  │  │
│                                          │  │  • Project PRD     │  │  │
│                                          │  │  • Custom agents   │  │  │
│                                          │  └────────────────────┘  │  │
│                                          └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

See [Upstream/Downstream Workflow](#upstreamdownstream-workflow) for step-by-step instructions.

---

## Architecture Overview

### CLAUDE.md Router Pattern

CLAUDE.md is a **lightweight router** (~250 lines) that points AI agents to the right reference document for each context. All detailed rules, standards, and patterns live in `.claude/reference/`.

```
CLAUDE.md (Router, ~250 lines)
  │
  ├── Upstream Protection Rules (always loaded)
  ├── Context-Aware Reference Loading Table
  ├── Quality Gates Summary
  └── Reference Documentation Index
        │
        ▼
.claude/reference/ (46 specialized documents)
  ├── code-standards.md        → Language, naming, TypeScript, React, anti-patterns
  ├── session-rules.md         → Auto-start rules, config backup
  ├── project-rules.md         → Skills catalog, task management, workflow
  ├── quality-gates.md         → Gate architecture, subagents, failure protocol
  ├── architecture.md          → Platform architecture, tech stack
  ├── design-system.md         → UI/UX, Tailwind v4, shadcn/ui
  ├── piv-workflow.md          → PIV phases (Plan/Implement/Validate)
  ├── promote-sync.md          → Upstream/downstream rules
  ├── git-workflow.md          → PR workflow, commit messages
  ├── testing-strategy.md      → Test pyramid, Vitest, Playwright
  └── ... (36 more specialized docs)
```

**Why?** AI agents load only the doc they need for the current task, keeping context efficient. Previously, CLAUDE.md was 1251 lines — now it's 253.

### Quality Gate Architecture

Every code change passes through mandatory quality gates. The **Change Size Classification (S/M/L)** determines which gates run:

```
Implementation ──► Classify (S/M/L) ──► Post-Implementation Gate ──► Visual Verification (L only)
                                              │                              │
                                         architecture-guard           agent-browser
                                         design-system-guard          open pages
                                         ssr-safety-checker           screenshot
                                         mastra-validator             fix loop
                                                                            │
                                                                            ▼
                              Commit ──► Pre-Commit Gate ──► PR ──► Pre-PR Gate ──► Deploy
                                              │                        │
                                         test-runner               code-reviewer
                                         code-reviewer             error-handling-reviewer
                                         (lint, type-check)        architecture-guard
```

**Change Size Classification:**

| Level | Criteria | Visual Verification? |
|-------|----------|---------------------|
| **S (Small)** | 1-2 files, config/docs only | No |
| **M (Medium)** | 3-10 files, single component | No |
| **L (Large)** | 10+ files, new feature with UI | **YES** |

**Gates by Level:**

| Gate | S | M | L |
|------|---|---|---|
| Architecture Guard | - | YES | YES |
| Design System / SSR Guards | - | YES | YES |
| Unit Tests | YES | YES | YES |
| **Visual Verification** | - | - | **YES** |
| Pre-Commit (lint, test, review) | YES | YES | YES |
| Pre-PR (review, architecture) | YES | YES | YES |

**Visual Verification Gate (L-level with UI):**

When triggered, the agent communicates clearly to the user, then:
1. Starts the dev server
2. Opens each affected page in agent-browser
3. Takes screenshots (desktop + mobile)
4. Checks for errors, layout issues, broken interactions
5. **If issues found:** fixes the code and re-verifies (loop until clean)
6. Only proceeds to commit when all pages work

**Failure Protocol:** CRITICAL/HIGH = STOP. WARNING = user decides. INFO = continue.

See `.claude/reference/quality-gates.md` for full documentation.

### Subagent Architecture

Specialized AI subagents are invoked automatically by skills and quality gates:

| Agent | Model | Purpose | Triggered By |
|-------|-------|---------|-------------|
| **architecture-guard** | Haiku | CLAUDE.md compliance, pattern validation | `/execute`, `/pr` |
| **code-reviewer** | Sonnet | Code quality, security, best practices | `/commit`, `/pr` |
| **design-system-guard** | Haiku | UI compliance (colors, typography, layout) | `/execute` (UI changes) |
| **ssr-safety-checker** | Haiku | Hydration mismatch detection | `/execute` (component changes) |
| **mastra-validator** | Haiku | Mastra framework compliance | `/execute` (mastra/ changes) |
| **error-handling-reviewer** | Haiku | API error handling patterns | `/pr` |
| **test-runner** | Haiku | Test execution, coverage validation | `/commit` |
| **session-closer** | Haiku | Session cleanup, Linear sync | `/session-end` |

Agents are defined in `.claude/agents/` and invoked automatically when appropriate.

### Skill Workflow

Skills encode best practices into repeatable commands:

```
/prime ──► /plan-feature ──► /execute ──► /commit ──► /pr ──► /deploy
  │            │                 │            │          │         │
  │            │                 │            │          │         │
  Load      Create plan     Implement +   Quality    Quality   Security
  context   from PRD        quality gates  gate +     gate +    scan +
  + Linear                               commit     push PR    deploy
```

| Phase | Skill | What It Does |
|-------|-------|-------------|
| **Context** | `/prime` | Load project context, check Linear, show dashboard |
| **Planning** | `/plan-feature` | Create implementation plan from requirements |
| **Implementation** | `/execute` | Execute plan with TDD, run quality gates |
| **Commit** | `/commit` | Pre-commit gate (test+lint+review), formatted commit |
| **Ship** | `/pr` | Pre-PR gate (review+architecture), push branch, create PR |
| **Deploy** | `/deploy` | Pre-deploy gate (security), deploy to LUCIDLABS-HQ |

## Overview

Agent Kit provides a complete foundation for building AI agent applications:

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Frontend** | Next.js 15 + shadcn/ui | Dashboard, UI, streaming |
| **AI Agents** | Mastra | Agent definitions, tools, workflows |
| **Database** | Convex | Realtime sync, vector search |
| **File Storage** | MinIO | S3-compatible object storage |
| **LLM Gateway** | Portkey | Multi-model routing, cost tracking |
| **Workflows** | n8n | Automation, integrations |
| **Deployment** | Docker + Caddy | Self-hosted, auto HTTPS |

## Quick Start

### Option 1: Use the Scaffold Script (Recommended)

```bash
# Clone the template
git clone git@github.com:lucidlabs-hq/agent-kit.git
cd agent-kit

# Run interactive setup - creates a NEW project directory
./scripts/create-agent-project.sh --interactive

# Or with a name directly
./scripts/create-agent-project.sh my-client-project
```

The script:
1. Creates a new directory outside agent-kit
2. Copies selected components
3. Initializes a fresh git repo
4. Sets up the project structure

Components you can include:
- Frontend (Next.js)
- Mastra (AI Agents)
- Convex (Database)
- n8n (Workflows)
- Terraform (Infrastructure)

### Option 2: Manual Setup

```bash
# Clone directly into your project name
git clone git@github.com:lucidlabs-hq/agent-kit.git my-client-project
cd my-client-project

# IMPORTANT: Remove template git history
rm -rf .git
git init

# Create your own repo
gh repo create lucidlabs-hq/my-client-project --private --source=. --push

# Install dependencies
cd frontend && pnpm install
cd ../mastra && pnpm install

# Initialize Convex
npx convex init

# Start development
pnpm run dev
```

**⚠️ Never push changes back to `lucidlabs-hq/agent-kit` directly. Use the promotion workflow instead.**

## Project Structure

```
agent-kit/
├── frontend/                 # Next.js 15 Application
│   ├── app/                  # App Router pages
│   ├── components/           # React components
│   │   └── ui/               # shadcn/ui components
│   └── lib/                  # Utilities & types
│
├── mastra/                   # AI Agent Layer
│   └── src/
│       ├── agents/           # Agent definitions
│       ├── tools/            # Agent tools
│       └── workflows/        # Multi-step workflows
│
├── convex/                   # Realtime Database
│   ├── schema.ts             # Database schema
│   └── functions/            # Queries, mutations, actions
│
├── n8n/                      # Workflow Automation
│   └── workflows/            # Pre-built workflow templates
│
├── terraform/                # Infrastructure as Code
│   ├── main.tf               # Elestio deployment
│   └── environments/         # Dev/prod configurations
│
├── scripts/
│   ├── create-agent-project.sh  # Project scaffolding
│   ├── promote.sh               # Promote patterns upstream
│   └── sync-upstream.sh         # Sync updates downstream
│
├── .claude/                  # Claude Code configuration
│   ├── PRD.md                # Product Requirements
│   ├── skills/               # Claude Code skills (v2.1.3+)
│   └── reference/            # Best practices
│
├── docker-compose.yml        # Production deployment
├── Caddyfile                 # Reverse proxy config
├── CLAUDE.md                 # Development rules
└── WORKFLOW.md               # Development workflow guide
```

## Development Workflow

Agent Kit follows **Discovery-Driven Development (DDD)** with Linear integration.

### Linear Integration

All projects use [Linear](https://linear.app/lucid-labs-agents) for issue tracking.

#### Einmalige Einrichtung (pro Maschine)

```bash
# 1. MCP Server hinzufügen
claude mcp add --transport http linear-server https://mcp.linear.app/mcp

# 2. In Claude Session authentifizieren
/mcp
# → Browser öffnet sich → Mit Lucid Labs Account einloggen → Fertig!
```

**Danach:** Token bleibt in `~/.mcp-auth/` gespeichert. Kein erneutes Login nötig.

**Bei Problemen:** `rm -rf ~/.mcp-auth` und `/mcp` erneut ausführen.

Siehe `.claude/reference/linear-setup.md` für Details.

### Productive.io Integration

Productive.io ist das **System of Record für Kundenwert** - alle Delivery Units, Budgets und Reporting.

```
┌───────────────────────────────────────────────────────────────┐
│  PRODUCTIVE.IO          PRODUCTIZER           LINEAR          │
│  (Kundenwert)           (Bridge)              (Execution)     │
│       │                     │                     │           │
│  Companies ────────────►    │    ◄──────────── Projects       │
│  Delivery Units ───────►    │    ◄──────────── Status         │
│  Budgets ──────────────►    │                                 │
│                             │                                 │
│                             ▼                                 │
│                    CUSTOMER PORTAL                            │
│                    (Service Dashboard)                        │
└───────────────────────────────────────────────────────────────┘
```

**Delivery Units** = Was wir liefern (Agent, Workflow, Workshop, Advisory, etc.)

```bash
# Productizer Skill
/productizer setup [customer]   # Neuen Kunden einrichten
/productizer sync               # Linear ↔ Productive.io sync
/productizer report [customer]  # Kunden-Report generieren
```

Siehe `.claude/reference/productive-integration.md` für Details.

### AIDD: Adaptive AI Discovery & Delivery

Agent Kit follows the **AIDD methodology** - AI-driven, Decision-driven development that emphasizes explicit decision points between exploration and delivery.

```
┌─────────────────────────────────────────────────────────────────────┐
│                         AIDD WORKFLOW                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   EXPLORATION          DECISION           DELIVERY                   │
│   ───────────          ────────           ────────                   │
│   • Research           /decision          • Implement                │
│   • Prototype          • proceed          • Test                     │
│   • Validate           • pivot            • Deploy                   │
│   • Learn              • drop                                        │
│                        • iterate                                     │
│                                                                      │
│   No deadline          Gate               Committed timeline         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Principles:**
- **Explicit Decisions:** No silent transitions from exploration to delivery
- **Deadlines Only in Delivery:** Exploration has no deadline pressure
- **Customer Transparency:** Decisions translated to customer language
- **Focus on Value:** Service, Decisions, Value - not tasks or developers

See `.claude/reference/aidd-methodology.md` for complete documentation.

### PIV: Plan-Implement-Validate

Agent Kit folgt dem **PIV-Workflow** - ein striktes Phasenmodell für AI-gestützte Entwicklung.

#### Warum PIV?

| Problem ohne PIV | Lösung mit PIV |
|------------------|----------------|
| AI implementiert ohne Plan | Erst planen, dann umsetzen |
| Scope-Creep durch AI | Strenge Phasentrennung |
| Qualitätsprobleme | Validation als Pflicht-Gate |
| Unklare Erfolgskriterien | Tests definieren Erfolg |

#### Die Phasen

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    PLAN     │────▶│  IMPLEMENT  │────▶│  VALIDATE   │
│ /plan-feature│     │  /execute   │     │  /validate  │
└─────────────┘     └─────────────┘     └─────────────┘
       │                                       │
       └───────────── ITERATE ◀────────────────┘
```

| Phase | Erlaubt | Verboten |
|-------|---------|----------|
| **Plan** | Recherche, Analyse, Tests definieren | Code schreiben |
| **Implement** | Tests schreiben, dann Code | Scope ändern |
| **Validate** | Prüfen, Tests ausführen | Bugs fixen (→ neuer Zyklus) |

**Regel:** Nie zwei Phasen gleichzeitig. Jeder Fix startet einen neuen PIV-Zyklus.

#### TDD im PIV-Loop

Wir nutzen **Test-Driven Development (TDD)** innerhalb des PIV-Loops:

1. **Plan-Phase:** Testfälle als Acceptance Criteria definieren
2. **Implement-Phase:** Test zuerst schreiben → Code implementieren → Test muss grün sein
3. **Validate-Phase:** `pnpm run test` - alle Tests müssen bestehen

```
RED ──────▶ GREEN ──────▶ REFACTOR
Test fails   Code passes   Improve code
             the test      tests stay green
```

Siehe [WORKFLOW.md](./WORKFLOW.md#the-piv-loop) für Details.

### Discovery-Driven Development Status Flow

```
Backlog → Exploration → Decision → Delivery → Review → Done
                           ↓
                        Dropped (valid end state)
```

| Status | Purpose | Deadline? |
|--------|---------|-----------|
| **Exploration** | Timeboxed research to reduce uncertainty | No |
| **Decision** | Steering point: proceed, iterate, pivot, or drop | No |
| **Delivery** | Implementation of validated solution | **YES** |
| **Review** | QA and stakeholder validation | No |

### Session-Based Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  SESSION START                                                   │
│  /prime                                                          │
│  → Check Linear for active issues                               │
│  → Ask: "Woran möchtest du arbeiten?"                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  DEVELOPMENT                                                     │
│  /linear create    - Create Linear issue                        │
│  /plan-feature     - Plan implementation                        │
│  /execute          - Implement the plan                         │
│  /validate         - Verify compliance                          │
│  /commit           - Commit changes                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  SESSION END                                                     │
│  /session-end                                                    │
│  → Update Linear ticket status                                  │
│  → Add work summary as comment                                  │
│  → Verify Git compliance                                        │
│  → Ensure clean state for next session                          │
└─────────────────────────────────────────────────────────────────┘
```

See [WORKFLOW.md](./WORKFLOW.md) for detailed instructions.

## Available Skills (Claude Code v2.1.3+)

Skills extend Claude's capabilities. Invoke with `/skill-name`.

| Skill | Description | Phase |
|-------|-------------|-------|
| `/start` | Entry point in template - create or open project | Any |
| `/checkout-project` | Clone existing project from GitHub | Any |
| `/prime` | Load project context + check Linear | Any |
| `/linear` | Linear project management (create/update/sync) | Any |
| `/meeting-decisions` | **Extract AIDD decisions from tldv.io transcripts** | Decision |
| `/create-prd` | Create a new PRD interactively | Planning |
| `/plan-feature` | Plan feature implementation | Planning |
| `/init-project` | Initialize new downstream project | Planning |
| `/execute` | Execute an implementation plan | Implementation |
| `/commit` | Create formatted commit | Implementation |
| `/update-readme` | Update README with current status | Implementation |
| `/visual-verify` | UI verification via agent-browser (fast) | Validation |
| `/pre-production` | Security & Quality Check before deploy | Validation |
| `/screenshot` | Visual verification screenshots | Validation |
| `/session-end` | End session, update Linear, clean state | Any |
| `/productizer` | Bridge Linear ↔ Productive.io for reporting | Any |
| `/budget` | **Track customer kontingent from Productive.io** | Any |
| `/n8n-workflow` | **Generate n8n workflows for agents** | Implementation |
| `/promptfoo` | **LLM evaluation & self-learning prompts** | Validation |
| `/promote` | Promote patterns to upstream agent-kit | Any |
| `/sync` | Sync updates from upstream agent-kit | Any |

Skills are stored in `.claude/skills/` with `SKILL.md` files. See [Claude Code Skills Docs](https://code.claude.com/docs/en/skills).

## Custom Subagents (Claude Code v2.1.16+)

Agent Kit includes custom subagents for specialized tasks. Located in `.claude/agents/`.

| Agent | Purpose | Model | When Used |
|-------|---------|-------|-----------|
| `code-reviewer` | Code quality & security review | Sonnet | After code changes |
| `architecture-guard` | CLAUDE.md compliance check | Haiku | Before committing |
| `test-runner` | Test execution & reporting | Haiku | After implementation |
| `session-closer` | Session cleanup & Linear sync | Haiku | End of session |

### Using Agents

Agents are invoked automatically when appropriate, or explicitly:

```
Use the code-reviewer agent to review my recent changes
Run architecture-guard on the components/ directory
Have test-runner execute the authentication tests
```

### Creating Custom Agents

Add a `.md` file to `.claude/agents/`:

```yaml
---
name: my-agent
description: When to use this agent
tools: Read, Grep, Glob
model: sonnet
---

Agent instructions here...
```

See [Claude Code Subagents Docs](https://code.claude.com/docs/en/sub-agents) and `.claude/reference/task-system.md` for details.

### Package Scripts

```bash
# Frontend
cd frontend
pnpm run dev          # Start dev server (Bun)
pnpm run build        # Production build (Node.js)
pnpm run lint         # Run ESLint
pnpm run type-check   # TypeScript check
pnpm run validate     # Lint + type-check

# Mastra
cd mastra
pnpm run dev          # Start agent server
pnpm run build        # Build for production

# Convex
npx convex dev        # Start Convex dev server
npx convex deploy     # Deploy to cloud
```

## Environment Variables

Create `.env.local` from the template:

```bash
cp .env.example .env.local
```

Required variables:

```env
# Convex
NEXT_PUBLIC_CONVEX_URL=https://your-project.convex.cloud

# AI Models
ANTHROPIC_API_KEY=sk-ant-...

# Productive.io (für Customer Reporting)
PRODUCTIVE_API_TOKEN=your-api-token
PRODUCTIVE_ORG_ID=your-org-id

# Optional
OPENAI_API_KEY=sk-...
```

### Productive.io Setup

1. Productive.io → Settings → API integrations
2. "Generate new token" → Token sicher speichern
3. Organization ID aus URL: `app.productive.io/org-id/...`

## Deployment

### Local Docker

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f
```

### Elestio (Production)

```bash
cd terraform
terraform init
terraform apply -var-file=environments/prod.tfvars
```

See [terraform/README.md](./terraform/README.md) for details.

### Vercel (Quick Deploy)

For quick prototypes, deploy frontend to Vercel:

```bash
cd frontend
vercel
```

## Tech Stack

### Stack Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           LUCID LABS AI STACK                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                           CLIENTS                                    │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐  │    │
│  │  │  Web App    │  │  CLI Tool   │  │ Python SDK  │  │   Mobile   │  │    │
│  │  │  (Next.js)  │  │  (Optional) │  │  (Optional) │  │  (Later)   │  │    │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └─────┬──────┘  │    │
│  └─────────┼────────────────┼────────────────┼───────────────┼─────────┘    │
│            └────────────────┴────────────────┴───────────────┘              │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      AI LAYER (WÄHLE EINS)                           │    │
│  │                                                                      │    │
│  │  ┌─────────────────────────┐    ┌─────────────────────────────┐     │    │
│  │  │     VERCEL AI SDK       │ OR │         MASTRA              │     │    │
│  │  │     (Prototypen)        │    │   (Production Agents)       │     │    │
│  │  │                         │    │                             │     │    │
│  │  │  • Schnelle Prototypen  │    │  • Decision & Explanation   │     │    │
│  │  │  • Chat UI              │    │  • Tools & Workflows        │     │    │
│  │  │  • Streaming            │    │  • Multi-Step Agents        │     │    │
│  │  └─────────────────────────┘    └─────────────────────────────┘     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      DATA LAYER (WÄHLE EINS)                         │    │
│  │                                                                      │    │
│  │  ┌─────────────────────────┐    ┌─────────────────────────────┐     │    │
│  │  │        CONVEX           │ OR │       POSTGRES              │     │    │
│  │  │   (Realtime, Simple)    │    │   (Classic, Flexible)       │     │    │
│  │  │                         │    │                             │     │    │
│  │  │  • Realtime Sync        │    │  • SQL Standard             │     │    │
│  │  │  • Built-in Vector      │    │  • Mit Pinecone/pgvector    │     │    │
│  │  │  • Type-safe Functions  │    │  • Prisma/Drizzle ORM       │     │    │
│  │  └─────────────────────────┘    └─────────────────────────────┘     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                           OPTIONAL COMPONENTS                                │
│                                                                              │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐   │
│  │   Portkey     │ │     n8n       │ │    Python     │ │  LangChain    │   │
│  │ (LLM Gateway) │ │ (Automation)  │ │  (Compute)    │ │  (Chains)     │   │
│  └───────────────┘ └───────────────┘ └───────────────┘ └───────────────┘   │
│                                                                              │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐   │
│  │   Pinecone    │ │   Greptile    │ │    MinIO      │ │  Terraform    │   │
│  │  (Vectors)    │ │ (Code Review) │ │ (S3 Storage)  │ │    (IaC)      │   │
│  └───────────────┘ └───────────────┘ └───────────────┘ └───────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Stack Selection Guide

| Was brauchst du? | AI Layer | Database | Optional |
|------------------|----------|----------|----------|
| Chat Prototype | Vercel AI SDK | Convex | - |
| Production Agent | Mastra | Convex | Portkey |
| SQL + Pinecone | Mastra | Postgres | Pinecone |
| Complex Analysis | Mastra | Either | Python Workers |
| Automation | Mastra | Convex | n8n |

Bei Projekt-Initialisierung (`./scripts/create-agent-project.sh --interactive`) wirst du durch alle Optionen geführt.

### Frontend
- **Next.js 15** - App Router, Server Components
- **React 19** - Latest React features
- **TypeScript 5** - Strict mode
- **Tailwind CSS 4** - Utility-first styling
- **shadcn/ui** - Accessible component library

### AI Layer
- **Mastra** - Production agents, tools, workflows, decision layer
- **Vercel AI SDK** - Simple chat, streaming, quick prototypes

### Database
- **Convex** - Realtime sync, built-in vector search, type-safe
- **Postgres** - SQL standard, Pinecone-kompatibel, maximale Kontrolle

### AI Models

| Provider | Models | Use Case |
|----------|--------|----------|
| **Anthropic** (Primary) | Claude Opus 4.5, Sonnet 4, Haiku | General purpose, complex reasoning |
| **Azure OpenAI** (Optional) | GPT-4o, GPT-4 Turbo | GDPR-konform, EU Data Residency |

### Optional Components

| Component | Purpose |
|-----------|---------|
| **Portkey** | LLM Gateway, Cost Tracking, Multi-Model, Guardrails |
| **n8n** | Workflow automation, integrations, scheduling |
| **Python Workers** | PDF parsing, OCR, statistics, ML compute |
| **LangChain** | Complex chains, LangGraph, advanced agents |
| **Pinecone** | Vector database (with Postgres) |
| **Greptile** | AI code review, bug detection |
| **MinIO** | S3-compatible file storage |
| **Terraform** | Infrastructure as Code |

### Deployment
- **Docker** - Containerization
- **Caddy** - Reverse proxy, auto HTTPS
- **Terraform** - Infrastructure as Code
- **Elestio** - Self-hosted platform

## Documentation

### Core Documents

| Document | Purpose |
|----------|---------|
| [CLAUDE.md](./CLAUDE.md) | **Router** — Points AI agents to the right reference doc (~250 lines) |
| [AGENTS.md](./AGENTS.md) | Mirror of CLAUDE.md rules for Cursor/Windsurf/other AI IDEs |
| [WORKFLOW.md](./WORKFLOW.md) | Step-by-step development workflow guide |

### Reference Documentation (`.claude/reference/`)

**Code & Standards:**

| Document | Purpose |
|----------|---------|
| `code-standards.md` | Language, naming, style, TypeScript, React, anti-patterns |
| `design-system.md` | UI/UX, Tailwind v4, shadcn/ui components |
| `shadcn-ui-setup.md` | shadcn/ui configuration and usage |
| `ssr-hydration.md` | SSR safety, hydration mismatch prevention |
| `error-handling.md` | Error handling patterns |

**Architecture & Infrastructure:**

| Document | Purpose |
|----------|---------|
| `architecture.md` | Platform architecture, tech stack, project structure |
| `deployment-best-practices.md` | Docker, Caddy, Elestio, CI/CD |
| `deployment-targets.md` | LUCIDLABS-HQ vs DEDICATED deployment |
| `ci-cd-security.md` | SHA-pinning, workflow architecture, branch protection |
| `scaling.md` | Stateless patterns, Convex scaling |
| `port-registry.md` | Port allocations, conflict checking |

**Workflow & Process:**

| Document | Purpose |
|----------|---------|
| `project-rules.md` | Skills catalog, task management, dev workflow |
| `quality-gates.md` | Gate architecture, subagents, test enforcement |
| `session-rules.md` | Auto-start rules, config backup, full-stack components |
| `piv-workflow.md` | PIV phases (Plan/Implement/Validate) |
| `git-workflow.md` | PR workflow, commit messages, branch lifecycle |
| `testing-strategy.md` | Test pyramid, Vitest, Playwright |
| `code-review-checklist.md` | Pre-commit review checklist |
| `promote-sync.md` | Upstream/downstream flow, downstream rules |

**AI & Agents:**

| Document | Purpose |
|----------|---------|
| `ai-framework-choice.md` | Mastra vs Vercel AI SDK decision guide |
| `mastra-best-practices.md` | AI agents, tools, workflows |
| `llm-configuration.md` | LLM model selection, pricing, Portkey config |
| `vercel-ai-sdk.md` | Vercel AI SDK examples and setup |
| `mcp-servers.md` | All MCP servers overview |

**Auth & Database:**

| Document | Purpose |
|----------|---------|
| `auth-architecture.md` | Centralized BetterAuth, cross-subdomain SSO, roles |
| `betterauth-convex-setup.md` | BetterAuth + Convex setup guide |
| `convex-self-hosted.md` | Convex self-hosted setup, project isolation |

**Integrations:**

| Document | Purpose |
|----------|---------|
| `linear-setup.md` | Linear MCP setup, OAuth, troubleshooting |
| `productive-integration.md` | Productive.io API, Delivery Units, Reporting |
| `aidd-methodology.md` | AIDD: Adaptive AI Discovery & Delivery |
| `minio-integration.md` | MinIO S3-compatible file storage |
| `azure-openai-integration.md` | Azure OpenAI (GDPR-compliant, optional) |

**Roadmap & Meta:**

| Document | Purpose |
|----------|---------|
| `future-plans.md` | Feature roadmap with checkboxes |
| `task-system.md` | Task tracking, custom subagents |
| `time-tracking-concept.md` | Time tracking architecture |
| `session-handoff.md` | Project switching without session restart |

## Upstream/Downstream Workflow

### The Model

Agent Kit uses a **template-based workflow** with bidirectional synchronization:

| Term | Meaning | Location |
|------|---------|----------|
| **Upstream** | This template repository | `lucidlabs/lucidlabs-agent-kit/` |
| **Downstream** | Projects created from template | `lucidlabs/projects/[name]/` |

---

### 1. Initial Setup (One-Time)

Set up the folder structure on your machine:

```bash
# Create workspace structure
mkdir -p ~/coding/repos/lucidlabs/projects

# Clone the upstream template
cd ~/coding/repos/lucidlabs
git clone git@github.com:lucidlabs-hq/agent-kit.git lucidlabs-agent-kit

# Verify structure
ls -la ~/coding/repos/lucidlabs/
# Should show:
#   lucidlabs-agent-kit/
#   projects/
```

---

### 2. Creating a New Project (Upstream → Downstream)

**When:** Starting a new client project or internal tool.

```bash
# Navigate to the upstream template
cd ~/coding/repos/lucidlabs/lucidlabs-agent-kit

# Create new project in projects/ folder
./scripts/create-agent-project.sh ../projects/customer-portal

# Or with interactive mode
./scripts/create-agent-project.sh --interactive
# → Enter name: customer-portal
# → Creates: ../projects/customer-portal/
```

**What happens:**
1. Script copies boilerplate to `../projects/[name]/`
2. Initializes fresh git repo
3. Updates package.json, README with project name
4. Project is ready for development

**Next steps in the new project:**
```bash
cd ../projects/customer-portal
pnpm install
/create-prd          # Create project-specific PRD
/plan-feature login  # Start first feature
```

---

### 3. Promoting Patterns (Downstream → Upstream)

**When:** You developed something generic in a project that should be shared.

```bash
# In your downstream project
cd ~/coding/repos/lucidlabs/projects/customer-portal

# Run promotion script (points to upstream template)
./scripts/promote.sh --upstream ../../lucidlabs-agent-kit

# Or preview first (dry run)
./scripts/promote.sh --upstream ../../lucidlabs-agent-kit --dry-run
```

**Interactive session:**
```
╔═══════════════════════════════════════════════════════════════════╗
║                      PATTERN PROMOTION                            ║
╚═══════════════════════════════════════════════════════════════════╝

ℹ Downstream: ~/coding/repos/lucidlabs/projects/customer-portal
ℹ Upstream:   ~/coding/repos/lucidlabs/lucidlabs-agent-kit

▶ Scanning for promotable changes...

Promotable changes found:

  [1] .claude/skills/code-review/SKILL.md (NEW)
  [2] .claude/reference/api-patterns.md (NEW)
  [3] frontend/components/ui/data-table.tsx (MODIFIED)

Enter numbers to promote (e.g., 1,2 or 'all'): 1,2

▶ Creating branch: promote/20260127-from-customer-portal
✔ Copied: .claude/skills/code-review/SKILL.md
✔ Copied: .claude/reference/api-patterns.md
✔ Committed 2 files

Create GitHub PR? [Y/n] y
✔ PR created: https://github.com/lucidlabs-hq/agent-kit/pull/42
```

**What gets promoted:**

| ✅ Promotable | ❌ Not Promotable |
|---------------|-------------------|
| `.claude/skills/*` | `.claude/PRD.md` (project-specific) |
| `.claude/reference/*` | `frontend/app/*` (pages) |
| `frontend/components/ui/*` | `mastra/src/agents/*` (domain) |
| `frontend/lib/utils.ts` | `convex/*` (schema) |
| `frontend/lib/hooks/*` | Any domain-specific code |
| `scripts/*` | |

---

### 4. Syncing Updates (Upstream → Downstream)

**When:** The template got new skills/patterns you want in your project.

**Option A: Cherry-pick specific commits**
```bash
# In your downstream project
cd ~/coding/repos/lucidlabs/projects/customer-portal

# Add upstream remote (one-time)
git remote add template ../../lucidlabs-agent-kit

# Fetch latest from template
git fetch template

# See what changed
git log template/main --oneline -10

# Cherry-pick specific commits
git cherry-pick <commit-hash>
```

**Option B: Manual sync of specific files**
```bash
# Compare what's different
git diff template/main -- .claude/skills/

# Copy specific files
cp ../../lucidlabs-agent-kit/.claude/skills/new-skill/SKILL.md \
   .claude/skills/new-skill/SKILL.md

# Commit the sync
git add .claude/skills/new-skill/
git commit -m "chore: sync new-skill from upstream template"
```

**Option C: Sync script (recommended)**
```bash
# Run sync script
./scripts/sync-upstream.sh

# Interactive selection of what to sync
# Syncs: skills, reference docs, UI components, scripts
```

---

### 5. Quick Reference

| Task | Location | Command |
|------|----------|---------|
| **Create new project** | In `lucidlabs-agent-kit/` | `./scripts/create-agent-project.sh ../projects/[name]` |
| **Promote to upstream** | In `projects/[name]/` | `./scripts/promote.sh --upstream ../../lucidlabs-agent-kit` |
| **Sync from upstream** | In `projects/[name]/` | `./scripts/sync-upstream.sh` or manual cherry-pick |
| **Preview promotion** | In `projects/[name]/` | `./scripts/promote.sh --upstream ... --dry-run` |

---

### Best Practices

1. **Keep agent-kit clean** – Only generic, reusable patterns
2. **Domain logic stays downstream** – Client-specific code never goes upstream
3. **Small promotions** – Promote one pattern at a time for easier review
4. **Test in isolation** – Verify patterns work without project context
5. **Document patterns** – Add comments explaining usage
6. **Sync regularly** – Pull useful updates from upstream monthly

---

## Repository Protection

The upstream agent-kit is protected by a 4-layer system to prevent accidental modifications. Every layer operates independently - even if one fails, the others catch it.

### Protection Layers

| Layer | Mechanism | Purpose |
|-------|-----------|---------|
| **GitHub** | Branch Protection + CODEOWNERS | No direct pushes to main, all changes need PR review |
| **Git Hook** | `.githooks/pre-commit` | Blocks any `git commit` without explicit authorization |
| **Claude Code** | `.claude/settings.json` PreToolUse hook | Blocks AI agents from editing files |
| **Filesystem** | `chflags uchg` (macOS) | OS-level immutability on all tracked files |

### Why This Exists

The upstream template is the foundation for all Lucid Labs projects. Changes here propagate to every downstream project via `/sync`. A single accidental modification can break infrastructure across multiple projects. These layers ensure that every change is intentional, reviewed, and traceable.

### Making Changes (Admin Only)

All legitimate changes follow this procedure:

1. **Create a feature branch** - `git checkout -b feat/my-change`
2. **Unlock the filesystem** - `./scripts/unlock-upstream.sh`
3. **Start an authorized session** - `ALLOW_UPSTREAM_EDIT=1 ALLOW_UPSTREAM_COMMIT=1 claude`
4. **Make changes and commit** on the feature branch
5. **Push and create PR** - `git push -u origin feat/my-change && gh pr create`
6. **Re-lock the filesystem** - `./scripts/lock-upstream.sh`
7. **Merge after review**

For pattern promotions from downstream projects, use `./scripts/promote.sh` which handles authorization automatically.

### Lock/Unlock Scripts

```bash
# Lock all tracked files (run after changes are complete)
./scripts/lock-upstream.sh

# Check lock status
./scripts/lock-upstream.sh --status

# Unlock for maintenance (admin only)
./scripts/unlock-upstream.sh
```

---

## Security Practices

Agent Kit includes built-in security workflows for pre-production checks.

### Pre-Production Checks

Before deploying to production, run security and quality checks:

```bash
# MVP/Staging deployment (quick, ~5 min)
/pre-production mvp

# Production deployment (full audit, ~15-30 min)
/pre-production production
```

### Security Check Levels

| Level | Checks | When to Use |
|-------|--------|-------------|
| **MVP** | Build, TypeScript, ESLint, Quick security scan | Internal demos, staging |
| **Production** | Full security audit, E2E tests, vulnerability scan | Customer-facing releases |

### Security Tools

| Tool | Purpose |
|------|---------|
| **Strix AI** | Automated security scanning |
| **ESLint** | Code quality & security rules |
| **TypeScript** | Type safety |
| **Playwright** | E2E testing for critical flows |

### Security Response Matrix

| Severity | Action | Blocks Deploy? |
|----------|--------|----------------|
| **Critical** | Fix immediately | Yes |
| **High** | Fix before release | Yes |
| **Medium** | Document, fix within sprint | No |
| **Low** | Add to backlog | No |

See `.claude/skills/pre-production/SKILL.md` for detailed checklists.

---

## Contributing

Contributions to the template are welcome via the promotion workflow:

1. Create a downstream project
2. Develop and test your pattern
3. Use `./scripts/promote.sh` to create a PR
4. Ensure no domain-specific code is included
5. PR will be reviewed and merged

## License

MIT License - See [LICENSE](./LICENSE) for details.

---

**Built with care by [Lucid Labs GmbH](https://lucidlabs.de)**
