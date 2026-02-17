# Agent Kit - AI Context Document

> This document is optimized for AI model consumption. It provides structured context about the Agent Kit framework for use in other AI models or chat contexts.

---

## IDENTITY

**Name:** Agent Kit
**Creator:** Lucid Labs GmbH
**Type:** Software Development Framework for AI-powered Applications
**Version:** 1.0 (January 2026)

---

## CORE CONCEPT

The Agent Kit is a modular starter framework that combines:
1. **Methodology** - How development work is structured
2. **Technology** - What tools and stack are used
3. **Governance** - How work is tracked and delivered

It follows an "upstream/downstream" model:
- **Upstream** = The Agent Kit template (reusable patterns)
- **Downstream** = Projects created from the template (specific implementations)

---

## PHILOSOPHY

### Principle 1: Explicit Phases

Work is divided into distinct, non-overlapping phases. An AI or developer must always be able to state which phase they are in. Phases cannot be mixed.

### Principle 2: AI as Decision Layer

AI agents (like Mastra) function as "Decision & Explanation Layers" - they do NOT perform calculations. They receive pre-processed structured data (JSON) and produce decisions with explanations. Computation happens in separate workers (Python, Convex actions).

### Principle 3: Tests Define Success

Tests are written BEFORE implementation. They serve as the success criteria for AI-generated code. If tests pass, the implementation is correct.

### Principle 4: Exploration vs Delivery

Exploration (research, prototyping) has no deadline. Delivery (implementation) has deadlines. There is always an explicit decision point between them.

### Principle 5: Value Over Tasks

The focus is on deliverable value units (Agents, Workflows, Integrations), not on individual tasks. Linear tracks execution, Productive.io tracks customer value.

---

## METHODOLOGY

### AIDD (Adaptive AI Discovery & Delivery)

```
EXPLORATION → DECISION → DELIVERY
    ↓            ↓          ↓
  Research    Proceed?   Implement
  Prototype    Pivot?      Test
  Validate     Drop?      Deploy
   Learn     Iterate?
```

**Decision Options:**
- **Proceed** → Move to Delivery
- **Pivot** → Change direction, back to Exploration
- **Drop** → Stop work (valid outcome)
- **Iterate** → Continue Exploration

### PIV Loop (Plan-Implement-Validate)

```
PLAN → IMPLEMENT → VALIDATE → (ITERATE)
```

**Phase Rules:**

| Phase | Allowed Actions | Forbidden Actions |
|-------|-----------------|-------------------|
| PLAN | Research, analyze, define tests | Write implementation code |
| IMPLEMENT | Write tests, write code | Change scope |
| VALIDATE | Run tests, verify compliance | Fix bugs (start new cycle) |

**Iteration Rule:** Every bug fix starts a NEW PIV cycle. Never combine phases.

### TDD (Test-Driven Development)

```
RED → GREEN → REFACTOR
```

1. **RED** - Write test that fails
2. **GREEN** - Write minimal code to pass test
3. **REFACTOR** - Improve code, keep tests green

**Purpose:** Tests define expected behavior. AI generates code to satisfy tests, not vice versa.

---

## TECHNOLOGY STACK

### Required Components

| Layer | Technology | Purpose |
|-------|------------|---------|
| Frontend | Next.js 16 | Web application framework |
| Language | TypeScript | Type safety |
| Styling | Tailwind CSS 4 | Utility-first styling |
| Components | shadcn/ui | Accessible UI components |

### Selectable Components (Choose One Per Category)

**AI Layer:**
| Option | When to Use | Characteristics |
|--------|-------------|-----------------|
| Mastra | Production agents, tools, workflows | Structured, type-safe, decision layer |
| Vercel AI SDK | Quick prototypes, chat UI | Simple streaming, fast setup |

**Data Layer:**
| Option | When to Use | Characteristics |
|--------|-------------|-----------------|
| Convex | Realtime apps, quick setup | Automatic sync, built-in vectors |
| Postgres | SQL requirements, Pinecone | Standard SQL, maximum flexibility |

### Optional Components

| Component | Purpose | When to Add |
|-----------|---------|-------------|
| Portkey | LLM gateway, cost tracking, multi-model | Need cost tracking or model routing |
| n8n | Workflow automation, integrations | External service connections |
| Python Workers | PDF parsing, OCR, ML compute | Heavy data processing |
| LangChain | Complex agent chains | Mastra insufficient |
| Terraform | Infrastructure as Code | Production infrastructure |

### LLM Providers

| Provider | Role | Use Case |
|----------|------|----------|
| Claude (Anthropic) | Primary | Complex reasoning, quality |
| Azure OpenAI | Optional | GDPR compliance, EU data |

---

## GOVERNANCE SYSTEMS

### Linear (Execution Tracking)

**Status Flow:**
```
Backlog → Exploration → Decision → Delivery → Review → Done
                           ↓
                        Dropped
```

**Key Principle:** Only "Delivery" has deadlines. Exploration is timeboxed but not deadline-driven.

### Productive.io (Customer Value)

| Concept | Definition |
|---------|------------|
| Company | Customer organization |
| Project | Customer engagement |
| Delivery Unit | What we deliver (Agent, Workflow, GPT, Integration, Workshop, Advisory) |
| Budget | Hours/money allocated |
| Invoice | Billing document |

### Relationship

```
Productive.io (WHAT we deliver for value)
     ↓
Linear (HOW we execute the work)
```

---

## PROJECT STRUCTURE

```
project/
├── frontend/           # Next.js application
│   ├── app/            # App Router pages
│   ├── components/     # React components
│   └── lib/            # Utilities and types
│
├── mastra/             # AI Agent layer (if selected)
│   └── src/
│       ├── agents/     # Agent definitions
│       ├── tools/      # Agent tools
│       └── workflows/  # Multi-step workflows
│
├── convex/             # Database (if selected)
│   ├── schema.ts       # Database schema
│   └── functions/      # Queries, mutations
│
├── .claude/            # AI configuration
│   ├── PRD.md          # Product requirements
│   ├── skills/         # Claude Code skills
│   └── reference/      # Best practices
│
├── CLAUDE.md           # Development rules
└── WORKFLOW.md         # Workflow guide
```

---

## SKILLS (Commands)

Skills are Claude Code commands that guide development:

| Skill | Purpose | Phase |
|-------|---------|-------|
| `/prime` | Load project context | Any |
| `/plan-feature` | Create implementation plan | Planning |
| `/execute` | Implement according to plan | Implementation |
| `/validate` | Verify compliance | Validation |
| `/commit` | Create formatted commit | Implementation |
| `/session-end` | End session, update Linear | Any |

---

## MASTRA DESIGN PRINCIPLE

```
MASTRA               PYTHON/WORKERS       CONVEX/POSTGRES
──────               ──────────────       ───────────────
Decision Layer       Computation          State & Sync

• Decides            • Calculates         • Stores
• Explains           • Parses             • Versions
• Formulates         • Aggregates         • Syncs
• Validates          • Statistics         • Realtime

INPUT: Structured    INPUT: Raw data      INPUT: Anything
       JSON                 (PDF, etc.)

OUTPUT: Decision +   OUTPUT: Pure         OUTPUT: Queries
        Reasoning           JSON                  Mutations
```

---

## UPSTREAM/DOWNSTREAM MODEL

**Upstream (Agent Kit Template):**
- Generic skills
- Boilerplate code
- Best practice documentation
- Reusable components

**Downstream (Individual Projects):**
- Domain-specific logic
- Project PRD
- Custom agents
- Application code

**Workflows:**
| Action | Direction | Command |
|--------|-----------|---------|
| Create project | Upstream → Downstream | `./scripts/create-agent-project.sh` |
| Share pattern | Downstream → Upstream | `/promote` |
| Get updates | Upstream → Downstream | `/sync` |

---

## DELIVERY UNITS

What can be delivered to customers:

| Type | Description | Example |
|------|-------------|---------|
| Agent | Productive AI agent | Ticket classification |
| Workflow | Automated processes | Onboarding flow |
| GPT/Prompt | Prompt or prompt set | Meeting summarizer |
| Integration | External connections | CRM connector |
| Workshop | Single workshop | AI strategy session |
| Advisory | Analysis, consulting | AI readiness assessment |

---

## QUALITY ASSURANCE

### Validation Layers

1. **Automated** - TypeScript, ESLint
2. **TDD** - Vitest unit tests
3. **AI Review** - Greptile (optional)
4. **Human Review** - GitHub PR

### Pre-Production Checks

```
/pre-production

├─ Build successful?
├─ TypeScript clean?
├─ ESLint passed?
├─ Tests green?
├─ Security scan?
└─ E2E tests (critical flows)?
```

---

## KEY CONSTRAINTS

1. **Never combine PIV phases** in one response
2. **Never jump** from Planning to Implementation without explicit transition
3. **Every task** starts with Planning
4. **If information missing** → Stop and ask
5. **Technical decisions** only from CLAUDE.md, AGENTS.md, or reference docs
6. **English** for all code and comments
7. **No external state libraries** (Redux, Zustand) - React hooks only
8. **pnpm only** - Never npm or yarn

---

## SUMMARY FOR AI CONSUMPTION

The Agent Kit is a framework for building AI-powered applications with:

1. **Clear methodology**: AIDD separates exploration from delivery, PIV structures every task, TDD ensures quality
2. **Modular tech stack**: Choose Mastra or Vercel AI SDK for AI, Convex or Postgres for data
3. **Governance integration**: Linear for execution, Productive.io for customer value
4. **Reusability**: Upstream/downstream model enables pattern sharing

When working with Agent Kit projects:
- Always identify current PIV phase
- Follow the established skills workflow
- Use tests as success criteria
- Keep AI agents as decision layers, not computation engines
- Track work in Linear, value in Productive.io

---

*This document is designed for AI model context. Use it to understand the Agent Kit framework when assisting with Agent Kit projects.*
