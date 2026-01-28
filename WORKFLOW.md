# Agent Kit - Development Workflow Guide

This guide explains the complete development workflow for Agent Kit projects.

## Table of Contents

1. [Linear Integration](#linear-integration)
2. [Discovery-Driven Development](#discovery-driven-development)
3. [Upstream/Downstream Model](#upstreamdownstream-model)
4. [Quick Reference](#quick-reference)
5. [PRD-First Development](#prd-first-development)
6. [The PIV Loop](#the-piv-loop)
7. [Skills](#skills)
8. [Step-by-Step Workflow](#step-by-step-workflow)
9. [Best Practices](#best-practices)

---

## Linear Integration

All projects use Linear for issue tracking and project management.

### Workspace

- **URL:** https://linear.app/lucid-labs-agents
- **Team:** Lucid Labs Agents

### Einmalige Einrichtung (pro Maschine)

```bash
# 1. Linear MCP Server hinzufügen (einmalig)
claude mcp add --transport http linear-server https://mcp.linear.app/mcp

# 2. In einer Claude Session authentifizieren (einmalig)
/mcp
# → Browser öffnet sich
# → Mit Lucid Labs Account einloggen
# → Berechtigung erteilen
# → Token wird in ~/.mcp-auth/ gespeichert
```

**Das war's!** Nach der einmaligen Einrichtung funktioniert Linear automatisch in allen Projekten.

### Was ist einmalig, was wiederholt sich?

| Aktion | Wann | Häufigkeit |
|--------|------|------------|
| `claude mcp add ...` | Setup | Einmalig pro Maschine |
| `/mcp` (OAuth Login) | Setup | Einmalig pro Maschine |
| `/prime` | Session Start | Jede Session |
| `/linear create/update` | Während Arbeit | Bei Bedarf |
| `/session-end` | Session Ende | Jede Session |

### Bei Problemen

```bash
# Token-Cache löschen und neu authentifizieren
rm -rf ~/.mcp-auth

# Dann in Claude Session:
/mcp
```

Siehe `.claude/reference/linear-setup.md` für vollständige Dokumentation.

---

## Productive.io Integration

Productive.io ist das **System of Record für Kundenwert** - alle Delivery Units, Budgets und Reporting.

### Zwei-System-Architektur

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│   PRODUCTIVE.IO                    LINEAR                        │
│   ──────────────                   ──────                        │
│   System of Record                 Execution System              │
│   für Kundenwert                   für technische Arbeit         │
│                                                                  │
│   • Kunden (Companies)             • Technische Umsetzung        │
│   • Delivery Units (Projects)      • Exploration → Delivery      │
│   • Budget & Abrechnung            • Maintenance                 │
│   • Kunden-Reporting                                             │
│                                                                  │
│                    ┌──────────────┐                              │
│                    │ PRODUCTIZER  │                              │
│                    │   (Bridge)   │                              │
│                    └──────────────┘                              │
│                           │                                      │
│                           ▼                                      │
│               ┌────────────────────┐                             │
│               │  CUSTOMER PORTAL   │                             │
│               └────────────────────┘                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Delivery Units

| Typ | Beschreibung | Linear nötig? |
|-----|--------------|---------------|
| Agent | Produktiver KI-Agent | Ja |
| GPT / Prompt | Prompt oder Prompt-Set | Nein (meist) |
| Workflow | Automatisierte Abläufe | Ja |
| Integration | Externe Anbindungen | Ja |
| Workshop | Einzelner Workshop | Nein |
| Advisory | Analyse, Beratung | Nein |

### Regel

```
Productive.io Project = Delivery Unit (IMMER)
Linear Project        = Nur wenn technische Execution
```

### Productizer Skill

```bash
/productizer setup [customer]   # Neuen Kunden einrichten
/productizer sync               # Daten synchronisieren
/productizer report [customer]  # Kunden-Report generieren
```

Siehe `.claude/reference/productive-integration.md` für vollständige Dokumentation.

### Session Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                     LINEAR-INTEGRATED SESSION                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   SESSION START                SESSION END                       │
│   ─────────────                ───────────                       │
│   /prime                       /session-end                      │
│   ↓                            ↓                                 │
│   Check Linear issues          Update ticket status              │
│   Show active work             Add work summary                  │
│   Ask what to work on          Verify Git compliance             │
│                                                                  │
│                    DURING SESSION                                │
│                    ──────────────                                │
│                    /linear create  - New issue                   │
│                    /linear update  - Change status               │
│                    /linear sync    - Sync state                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Commands

| Command | Purpose |
|---------|---------|
| `/linear create` | Create new Linear issue |
| `/linear update` | Update issue status |
| `/linear sync` | Sync local work with Linear |
| `/linear status` | Show current Linear state |
| `/session-end` | End session, update Linear |

---

## Discovery-Driven Development

We use **Discovery-Driven Development (DDD)** - a status flow designed for evidence-based decisions.

### Status Flow

```
[ Backlog ]
     |
     v
[ Exploration ]    ← Timeboxed research/spike
     |
     v
[ Decision ]       ← Steering point
   /   |     \
  v    v      v
[Delivery] [Exploration] [Dropped]
    |           ^
    v           |
[ Review ] -----+
    |
    v
[ Done ]
```

### Status Definitions

| Status | Purpose | What Happens |
|--------|---------|--------------|
| **Backlog** | Idea capture | No commitment, no prioritization |
| **Exploration** | Reduce uncertainty | Timeboxed spike, learning focus |
| **Decision** | Steering point | Proceed / Iterate / Pivot / Drop |
| **Delivery** | Implementation | Validated solution, measurable progress |
| **Review** | Validation | QA, stakeholder review |
| **Done** | Shipped | Ready for production |
| **Dropped** | Valid end | Insight gained, not pursuing |

### Work Types

| Type | Description | Skips Exploration? |
|------|-------------|-------------------|
| **Exploration** | Research, spike | No |
| **Delivery** | Implementation | After exploration |
| **Maintenance** | Bug fix, ops | Yes |

### Maintenance Flow

For known problems with known solutions:

```
Backlog → Decision → Delivery → Review → Done
```

Or for small tasks:
```
Backlog → Delivery → Done
```

### Project Naming

**Format:** `[Domain] Capability / Area`

**Examples:**
- `[Agents] Ticket Classification`
- `[AI] Meeting Summarization`
- `[Platform] Infrastructure & Ops`
- `[Integration] External API Access`

### Labels

**Mandatory:**
- Work Type: `Exploration` | `Delivery` | `Maintenance`

**Optional:**
- `Bug`, `Security`, `Tech Debt`, `Performance`, `Ops`

---

---

## Upstream/Downstream Model

Agent Kit uses a **template-based architecture** where the kit serves as the upstream source and all projects are downstream consumers.

### Folder Structure

```
lucidlabs/                              # Workspace root
│
├── lucidlabs-agent-kit/                # UPSTREAM (this template)
│   ├── .claude/
│   │   ├── skills/                     # Generic skills (promotable)
│   │   ├── reference/                  # Best practices (promotable)
│   │   └── PRD.md                      # Template PRD (not promotable)
│   ├── frontend/
│   │   ├── components/ui/              # Generic UI (promotable)
│   │   └── app/                        # Boilerplate pages
│   ├── mastra/
│   │   └── src/tools/                  # Generic tools (promotable)
│   └── scripts/
│       ├── create-agent-project.sh     # Creates downstream projects
│       ├── promote.sh                  # Promotes patterns upstream
│       └── sync-upstream.sh            # Syncs updates downstream
│
└── projects/                           # DOWNSTREAM projects
    ├── customer-portal/                # Each is own git repo
    │   ├── .claude/PRD.md              # Project-specific PRD
    │   └── ...
    ├── internal-dashboard/
    └── ai-assistant/
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Upstream** | The agent-kit template – contains only generic, reusable patterns |
| **Downstream** | Individual projects – contain domain-specific logic and PRD |
| **Promote** | Move generic patterns FROM downstream TO upstream |
| **Sync** | Pull updates FROM upstream TO downstream |

### Decision Flow: Where Does Code Belong?

```
Is this code domain-specific?
│
├─ YES → Keep in downstream project
│        Examples: Customer schema, domain agents, app pages
│
└─ NO → Could be promoted to upstream
        │
        ├─ Is it a reusable pattern?
        │   └─ YES → Promote via ./scripts/promote.sh
        │
        └─ Is it project-specific but not domain logic?
            └─ Keep in downstream (e.g., deployment configs)
```

### Workflow Commands Summary

| What You Want | Where To Run | Command |
|---------------|--------------|---------|
| Create new project | `lucidlabs-agent-kit/` | `./scripts/create-agent-project.sh ../projects/[name]` |
| Promote patterns | `projects/[name]/` | `./scripts/promote.sh --upstream ../../lucidlabs-agent-kit` |
| Sync from template | `projects/[name]/` | `./scripts/sync-upstream.sh` |
| Preview promotion | `projects/[name]/` | `./scripts/promote.sh --upstream ... --dry-run` |

---

### Creating a New Project

**Step-by-step:**

```bash
# 1. Navigate to the template
cd ~/coding/repos/lucidlabs/lucidlabs-agent-kit

# 2. Run the scaffolding script (interactive)
./scripts/create-agent-project.sh --interactive

# Script will ask:
# - Project name
# - Components (Frontend, Mastra, Convex, etc.)
# - GitHub repo creation (default: yes)
# - Linear project creation (default: yes)

# 3. Move to the new project
cd ../projects/my-project

# 4. Install dependencies
cd frontend && pnpm install && cd ..

# 5. Start Claude session
claude

# 6. Start developing (Linear-first)
/linear create           # Create first Linear issue
/plan-feature login      # Plan first feature
/execute                 # Implement
/session-end             # Update Linear when done
```

---

### Promoting Patterns to Upstream

**When to promote:**
- You created a generic skill that could help other projects
- You built a reusable UI component
- You documented a best practice
- You wrote a utility function with no domain logic

**Step-by-step:**

```bash
# 1. Navigate to your downstream project
cd ~/coding/repos/lucidlabs/projects/customer-portal

# 2. Preview what can be promoted
./scripts/promote.sh --upstream ../../lucidlabs-agent-kit --dry-run

# 3. Run the promotion
./scripts/promote.sh --upstream ../../lucidlabs-agent-kit

# 4. Select files to promote (interactive)
#    → Enter numbers: 1,2,3 or 'all'

# 5. Script creates PR in upstream repo
#    → Review and merge the PR

# 6. Done! Pattern is now in the template
```

**Promotable vs Non-Promotable:**

| ✅ Promote These | ❌ Never Promote |
|-----------------|------------------|
| `.claude/skills/*` | `.claude/PRD.md` |
| `.claude/reference/*` | `frontend/app/*` (pages) |
| `frontend/components/ui/*` | `mastra/src/agents/*` |
| `frontend/lib/utils.ts` | `convex/schema.ts` |
| `frontend/lib/hooks/*` | Domain-specific code |
| `scripts/*` (generic) | Project configs |

---

### Syncing Updates from Upstream

**When to sync:**
- New skill added to template
- Best practice documentation updated
- UI component improved
- Bug fix in shared utility

**Option A: Cherry-pick specific commits**

```bash
# 1. Add template as remote (one-time)
cd ~/coding/repos/lucidlabs/projects/customer-portal
git remote add template ../../lucidlabs-agent-kit

# 2. Fetch latest
git fetch template

# 3. See what's new
git log template/main --oneline -10

# 4. Cherry-pick what you need
git cherry-pick abc1234
```

**Option B: Manual file copy**

```bash
# 1. Compare differences
diff -r ../../lucidlabs-agent-kit/.claude/skills .claude/skills

# 2. Copy specific files
cp ../../lucidlabs-agent-kit/.claude/skills/new-skill/SKILL.md \
   .claude/skills/new-skill/SKILL.md

# 3. Commit
git add .
git commit -m "chore: sync new-skill from upstream"
```

**Option C: Sync script (recommended)**

```bash
# Run the sync script
./scripts/sync-upstream.sh

# Interactively select what to sync
# → Shows diff, lets you choose files
```

---

### Best Practices for Upstream/Downstream

1. **Never edit upstream directly for project work**
   - Always create a downstream project first
   - Promote patterns back after they're proven

2. **Keep upstream minimal**
   - Only generic, domain-agnostic code
   - If it mentions a business concept, it's downstream

3. **Sync regularly**
   - Check upstream monthly for new patterns
   - Pull improvements into active projects

4. **Small, focused promotions**
   - One pattern per PR
   - Easier to review and merge

5. **Test patterns in isolation**
   - Before promoting, verify it works without project context
   - Remove any project-specific imports

---

## Quick Reference

```bash
# New project setup
./scripts/create-agent-project.sh my-project --interactive

# Development workflow
/create-prd        # Step 1: Create requirements (if starting fresh)
/plan-feature X    # Step 2: Plan implementation
/execute           # Step 3: Implement the plan
/validate          # Step 4: Verify compliance
/commit            # Step 5: Commit changes

# Daily commands
pnpm run dev       # Start development server
pnpm run validate  # Quick check before commit
```

---

## PRD-First Development

Every project starts with a **Product Requirements Document (PRD)**.

### Why PRD-First?

1. **Clarity** - Forces you to think through requirements before coding
2. **Alignment** - AI agents understand exactly what to build
3. **Consistency** - All features traced back to requirements
4. **Quality** - Validation checks against PRD, not assumptions

### Creating Your PRD

#### Option A: Interactive Creation

```bash
/create-prd
```

Claude will guide you through:
- Project overview
- User personas
- Core features
- Data model
- AI agent definitions

#### Option B: Edit Template Directly

Edit `.claude/PRD.md`:

```markdown
# My Project - Product Requirements Document

## 1. Overview
**Project:** My AI Agent Project
**Description:** A system that does X for Y users
**Target Users:** Developers, business users

## 2. Core Features

### Feature: Task Management
- Description: Users can create and manage tasks
- User Story: As a user, I want to create tasks so that I can track my work
- Acceptance Criteria:
  - [ ] Can create tasks with title and description
  - [ ] Can mark tasks as complete
  - [ ] Can filter by status

## 3. Data Model
[Define your entities here]

## 4. AI Agents
[Define your agents here]
```

---

## The PIV Loop

Agent Kit uses the **PIV (Plan-Implement-Validate)** workflow:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│             │     │             │     │             │
│    PLAN     │────▶│  IMPLEMENT  │────▶│  VALIDATE   │
│             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
       │                                       │
       │                                       │
       ▼                                       │
┌─────────────┐                               │
│  ITERATE    │◀──────────────────────────────┘
└─────────────┘
```

### Phase Rules

| Phase | Allowed Actions | NOT Allowed |
|-------|-----------------|-------------|
| **Plan** | Research, analyze, document | Write code |
| **Implement** | Execute approved plan | Change scope |
| **Validate** | Check compliance, test | Fix issues |
| **Iterate** | Create next plan | Skip planning |

### Key Principles

1. **One phase at a time** - Never mix phases
2. **Planning is mandatory** - No implementation without a plan
3. **Validation catches issues** - Don't fix in validate phase
4. **Iterate restarts PIV** - Each cycle begins with planning

---

## TDD: Test-Driven Development

Agent Kit nutzt **Test-Driven Development (TDD)** als integralen Teil des PIV-Loops. Tests sind das **Erfolgskriterium** für AI-generierte Implementierungen.

### Warum TDD mit AI?

| Ohne TDD | Mit TDD |
|----------|---------|
| AI rät Verhalten | Tests definieren erwartetes Verhalten |
| Nachträgliche Tests validieren Bugs | Tests fangen Bugs vor Merge |
| Unklare Erfolgskriterien | Grüne Tests = Erfolg |
| Viele Korrektur-Iterationen | AI hat klares Ziel |

### TDD im PIV-Loop

```
┌─────────────────────────────────────────────────────────────────┐
│                     PIV + TDD WORKFLOW                           │
│                                                                  │
│   PLAN                 IMPLEMENT               VALIDATE          │
│   ────                 ─────────               ────────          │
│   1. Feature specs     3. Write TEST first     5. pnpm run test  │
│   2. Test cases        4. Write CODE until     6. All green?     │
│      definieren           test passes                            │
│                                                                  │
│   "Was soll es tun?"   "Test → Code → Refactor" "Alles grün?"   │
└─────────────────────────────────────────────────────────────────┘
```

### Der Red-Green-Refactor Zyklus

```
┌─────────┐        ┌─────────┐        ┌───────────┐
│   RED   │───────▶│  GREEN  │───────▶│ REFACTOR  │
│         │        │         │        │           │
│ Write   │        │ Write   │        │ Improve   │
│ failing │        │ minimal │        │ code,     │
│ test    │        │ code to │        │ tests     │
│         │        │ pass    │        │ stay green│
└─────────┘        └─────────┘        └───────────┘
     │                                      │
     └──────────── Next Test ◀──────────────┘
```

### Wann TDD anwenden?

| Situation | TDD? | Grund |
|-----------|------|-------|
| Neue Utility-Funktion | ✅ Ja | Klare Input/Output, testbar |
| Zod Schema | ✅ Ja | Validation Edge Cases |
| API Route | ✅ Ja | Request/Response Contract |
| Mastra Tool | ✅ Ja | Input/Output definiert |
| Business Logic | ✅ Ja | Kritisch, muss korrekt sein |
| UI Component Logik | ✅ Ja | Interaktionen, States |
| UI Styling | ❌ Nein | Visuell prüfen mit `/visual-verify` |
| Triviale Getter/Setter | ❌ Nein | Kein Mehrwert |
| Framework Boilerplate | ❌ Nein | Next.js kümmert sich |

### TDD Workflow Schritt für Schritt

#### In der Plan-Phase

Definiere Testfälle als Teil der Acceptance Criteria:

```markdown
## Feature: calculateTotal

### Test Cases
- [ ] Returns 0 for empty cart
- [ ] Sums item prices correctly
- [ ] Applies discount percentage
- [ ] Throws error for negative prices
- [ ] Handles floating point precision
```

#### In der Implement-Phase

**Schritt 1: Test schreiben (RED)**

```typescript
// lib/__tests__/calculate-total.test.ts
import { describe, it, expect } from 'vitest';
import { calculateTotal } from '../calculate-total';

describe('calculateTotal', () => {
  it('returns 0 for empty cart', () => {
    expect(calculateTotal([])).toBe(0);
  });

  it('sums item prices correctly', () => {
    const items = [{ price: 10 }, { price: 20 }];
    expect(calculateTotal(items)).toBe(30);
  });

  it('applies discount percentage', () => {
    const items = [{ price: 100 }];
    expect(calculateTotal(items, 10)).toBe(90); // 10% off
  });
});
```

**Schritt 2: Test ausführen - muss fehlschlagen**

```bash
pnpm run test
# ❌ FAIL - calculateTotal is not defined
```

**Schritt 3: Minimalen Code schreiben (GREEN)**

```typescript
// lib/calculate-total.ts
interface CartItem {
  price: number;
}

export function calculateTotal(
  items: CartItem[],
  discountPercent: number = 0
): number {
  const subtotal = items.reduce((sum, item) => sum + item.price, 0);
  return subtotal * (1 - discountPercent / 100);
}
```

**Schritt 4: Test ausführen - muss bestehen**

```bash
pnpm run test
# ✅ PASS - All tests passing
```

**Schritt 5: Refactoren (optional)**

Verbessere den Code, Tests müssen weiterhin grün bleiben.

#### In der Validate-Phase

```bash
# Alle Tests ausführen
pnpm run test

# Mit Coverage
pnpm run test -- --coverage

# Spezifische Datei
pnpm run test calculate-total
```

### Test-Datei-Struktur

```
frontend/
├── lib/
│   ├── __tests__/           # Unit Tests
│   │   ├── utils.test.ts
│   │   ├── schemas.test.ts
│   │   └── calculate-total.test.ts
│   ├── utils.ts
│   ├── schemas.ts
│   └── calculate-total.ts
├── components/
│   └── [Feature]/
│       ├── __tests__/       # Component Tests
│       │   └── feature.test.tsx
│       └── index.tsx
└── app/
    └── api/
        └── [route]/
            ├── __tests__/   # API Tests
            │   └── route.test.ts
            └── route.ts
```

### Best Practices

1. **Test-First, immer** - Schreibe den Test bevor du den Code schreibst
2. **Ein Test, ein Verhalten** - Jeder Test prüft genau eine Sache
3. **Aussagekräftige Namen** - `it('returns 0 for empty cart')` nicht `it('test1')`
4. **Edge Cases zuerst** - Leere Arrays, null, undefined, Grenzwerte
5. **Unabhängige Tests** - Tests dürfen nicht voneinander abhängen
6. **Schnelle Tests** - Unit Tests sollten < 100ms dauern

### AI-Prompt für TDD

Wenn du AI bittest, eine Funktion zu implementieren:

```
Implementiere die Funktion calculateTotal mit TDD:

1. Schreibe zuerst die Tests in lib/__tests__/calculate-total.test.ts
2. Führe die Tests aus (sie müssen fehlschlagen)
3. Implementiere die Funktion in lib/calculate-total.ts
4. Führe die Tests erneut aus (sie müssen bestehen)

Test Cases:
- Returns 0 for empty cart
- Sums item prices correctly
- Applies discount percentage
```

---

## Task System & Custom Agents (v2.1.16+)

Claude Code v2.1.16+ introduces native Task tracking and custom Subagents that integrate with the PIV workflow.

### Task-Enhanced PIV Loop

```
┌─────────────────────────────────────────────────────────────────┐
│                         PIV + TASKS                              │
│                                                                  │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐      │
│   │    PLAN     │────▶│  IMPLEMENT  │────▶│  VALIDATE   │      │
│   │             │     │  + Tasks    │     │  + Agents   │      │
│   └─────────────┘     └─────────────┘     └─────────────┘      │
│                              │                    │             │
│                              ▼                    ▼             │
│                       TaskCreate/Update    code-reviewer       │
│                       Progress Tracking    architecture-guard  │
│                                            test-runner         │
└─────────────────────────────────────────────────────────────────┘
```

### Using Tasks in `/execute`

When running `/execute`, Claude can optionally track progress:

```
/execute my-feature.md

> Creating tasks for plan...
> [████████░░░░░░░░] 2/5 tasks complete
> Currently: Implementing API endpoint...
```

### Custom Subagents

Agent Kit includes specialized agents in `.claude/agents/`:

| Agent | Purpose | Model | When Used |
|-------|---------|-------|-----------|
| `code-reviewer` | Code quality & security | Sonnet | After code changes |
| `architecture-guard` | CLAUDE.md compliance | Haiku | Before committing |
| `test-runner` | Test execution | Haiku | After implementation |

### Example: Full PIV with Tasks and Agents

```bash
# 1. Plan (no tasks needed)
/plan-feature user-auth

# 2. Execute with task tracking
/execute user-auth
# → Creates tasks from plan
# → Shows progress as each completes

# 3. Validate with agents
/validate
# → code-reviewer checks quality
# → architecture-guard checks compliance
# → test-runner executes tests

# 4. Commit
/commit
```

### When to Use Tasks

| Scenario | Use Tasks? |
|----------|------------|
| 3+ implementation steps | Yes |
| Complex refactoring | Yes |
| Bug fix (1-2 files) | No |
| Documentation update | No |

See `.claude/reference/task-system.md` for complete documentation.

---

## Skills

> **Note:** As of Claude Code v2.1.3 (January 2026), slash commands have been merged into skills.
> Skills are stored in `.claude/skills/` with `SKILL.md` files. See [Claude Code Skills Docs](https://code.claude.com/docs/en/skills).

### `/create-prd`

Creates a new Product Requirements Document interactively.

**When to use:**
- Starting a new project
- Adding major new functionality
- Clarifying unclear requirements

**Example:**
```
/create-prd

> What is the name of your project?
my-task-manager

> What problem does it solve?
Helps teams track and manage tasks with AI assistance
```

### `/plan-feature [name]`

Creates an implementation plan for a feature.

**When to use:**
- Before implementing any non-trivial feature
- When requirements are clear in PRD
- To get a structured approach

**Example:**
```
/plan-feature task-creation

> Creates plan in .agents/plans/task-creation.md
```

**Output includes:**
- Files to create/modify
- Implementation steps
- Dependencies
- Test cases

### `/execute [plan]`

Executes an approved implementation plan.

**When to use:**
- After plan is reviewed and approved
- When ready to write code

**Example:**
```
/execute task-creation

> Implementing task creation feature...
> Created: frontend/components/TaskForm/index.tsx
> Modified: convex/schema.ts
> ...
```

### `/validate`

Validates implementation against standards.

**When to use:**
- After completing implementation
- Before committing changes
- When unsure about compliance

**Checks:**
- TypeScript errors
- ESLint violations
- PRD compliance
- CLAUDE.md rules

**Example:**
```
/validate

> Checking TypeScript... ✓
> Checking ESLint... ✓
> Checking PRD compliance... ✓
> All checks passed!
```

### `/commit`

Creates a properly formatted commit.

**When to use:**
- After validation passes
- When ready to save changes

**Example:**
```
/commit

> feat(tasks): implement task creation feature
>
> - Add TaskForm component
> - Add createTask mutation
> - Add task creation UI
```

### `/prime`

Primes Claude with codebase understanding.

**When to use:**
- Starting a new session
- After major changes
- When Claude seems confused

**Example:**
```
/prime

> Analyzing codebase structure...
> Reading PRD...
> Understanding current state...
> Ready!
```

---

## Step-by-Step Workflow

### Starting a New Project

```bash
# 1. Create project from template
./scripts/create-agent-project.sh my-project --interactive

# 2. Navigate to project
cd my-project

# 3. Install dependencies
cd frontend && pnpm install

# 4. Create your PRD
/create-prd

# 5. Review and refine PRD
# Edit .claude/PRD.md as needed

# 6. Start implementing features
/plan-feature first-feature
```

### Implementing a Feature

```bash
# 1. Plan the feature
/plan-feature user-authentication

# 2. Review the plan
# Check .agents/plans/user-authentication.md

# 3. Execute the plan
/execute user-authentication

# 4. Validate implementation
/validate

# 5. Fix any issues, re-validate

# 6. Commit changes
/commit
```

### Daily Development Flow

```bash
# Morning: Prime Claude and check Linear
/prime
# → Shows your Linear issues
# → Asks what to work on

# Start work on issue
/linear update ABC-123 exploration  # If starting research
/linear update ABC-123 delivery     # If implementing

# During day: Implement features
/plan-feature X
/execute
/validate
/commit

# Before lunch/end of day
/session-end
# → Updates Linear ticket
# → Checks Git compliance
# → Saves progress state
```

### End of Session Checklist

The `/session-end` command ensures:

- [ ] Git working tree is clean
- [ ] Last commit follows conventions
- [ ] Linear ticket status is current
- [ ] Work summary added as comment
- [ ] PROJECT-STATUS.md updated

---

## Best Practices

### 1. Keep PRD Updated

- Update PRD when requirements change
- Mark completed features
- Add new features before implementing

### 2. Small, Focused Plans

- Plan one feature at a time
- Keep plans under 1 hour of work
- Split large features into sub-features

### 3. Validate Often

- Run `/validate` after each change
- Fix issues immediately
- Don't accumulate technical debt

### 4. Meaningful Commits

- Commit after each feature
- Use conventional commit format
- Include context in commit message

### 5. Use Mock Data

- Start with mock data
- Implement API later
- Keep mock data SSR-safe (no `Date.now()`)

### 6. Server Components First

- Default to Server Components
- Add `"use client"` only when needed
- Keep interactivity at leaf nodes

### 7. Follow Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | kebab-case | `task-form.tsx` |
| Components | PascalCase | `TaskForm` |
| Functions | camelCase | `createTask` |
| Constants | UPPER_SNAKE | `MAX_TASKS` |

---

## Troubleshooting

### "Plan not found"

```bash
# List available plans
ls .agents/plans/

# Create the plan first
/plan-feature feature-name
```

### "Validation fails"

```bash
# Run detailed checks
pnpm run type-check  # TypeScript errors
pnpm run lint        # ESLint issues

# Fix issues and retry
/validate
```

### "Claude seems confused"

```bash
# Re-prime Claude
/prime

# If still confused, provide context
# "I'm working on X feature from the PRD section Y"
```

### "Feature doesn't match PRD"

```bash
# Check PRD requirements
cat .claude/PRD.md

# Update implementation or PRD as needed
/validate
```

---

## Example Session

```bash
# === Morning ===

/prime
> Analyzing codebase... Ready!

# === Plan a feature ===

/plan-feature task-list

> Created plan: .agents/plans/task-list.md
>
> ## Task List Feature
>
> ### Files to Create
> - frontend/components/TaskList/index.tsx
> - frontend/components/TaskList/task-item.tsx
>
> ### Files to Modify
> - convex/schema.ts (add tasks table)
> - convex/functions/queries.ts (add listTasks)
>
> ### Steps
> 1. Add tasks table to schema
> 2. Create listTasks query
> 3. Build TaskItem component
> 4. Build TaskList component
> 5. Add to dashboard page

# === Review plan, then execute ===

/execute task-list

> Implementing task list feature...
> ✓ Updated convex/schema.ts
> ✓ Updated convex/functions/queries.ts
> ✓ Created frontend/components/TaskList/task-item.tsx
> ✓ Created frontend/components/TaskList/index.tsx
> ✓ Updated frontend/app/page.tsx
> Done!

# === Validate ===

/validate

> Checking TypeScript... ✓
> Checking ESLint... ✓
> Checking PRD compliance... ✓
> All checks passed!

# === Commit ===

/commit

> feat(tasks): implement task list feature
>
> - Add tasks table to Convex schema
> - Add listTasks query
> - Create TaskItem and TaskList components
> - Display tasks on dashboard
```

---

## Next Steps

1. Read [CLAUDE.md](./CLAUDE.md) for coding standards
2. Review [.claude/PRD.md](./.claude/PRD.md) template
3. Explore component READMEs in each directory
4. Start building!

---

**Happy building!** 🚀
