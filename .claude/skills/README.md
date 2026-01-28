# Agent Kit Skills

Skills extend Claude's capabilities in this project. Each skill is a directory with a `SKILL.md` file.

## Available Skills

| Skill | Description | Phase |
|-------|-------------|-------|
| `/start` | Entry point - create or open project | Any |
| `/checkout-project` | Clone existing project from GitHub | Any |
| `/prime` | Load project context + check Linear | Any |
| `/linear` | **Linear project management (create/update/sync)** | Any |
| `/meeting-decisions` | **Extract AIDD decisions from tldv.io transcripts** | Decision |
| `/create-prd` | Create Product Requirements Document | Planning |
| `/plan-feature` | Plan feature implementation | Planning |
| `/init-project` | Initialize new project | Planning |
| `/execute` | Execute implementation plan | Implementation |
| `/commit` | Create formatted git commit | Implementation |
| `/update-readme` | Update README file | Implementation |
| `/visual-verify` | **UI Verification via agent-browser (fast)** | Validation |
| `/pre-production` | **Security & Quality Check vor Deploy** | Validation |
| `/screenshot` | Visual verification screenshots | Validation |
| `/session-end` | **End session, update Linear, clean state** | Any |
| `/productizer` | **Bridge Linear ↔ Productive.io for customer reporting** | Any |
| `/notion-publish` | **Publish markdown to Notion (private pages)** | Any |
| `/budget` | **Track customer kontingent from Productive.io** | Any |
| `/n8n-workflow` | **Generate n8n workflows for agents** | Implementation |
| `/promptfoo` | **LLM evaluation & self-learning prompts** | Validation |
| `/promote` | Promote patterns to upstream | Any |
| `/sync` | Sync updates from upstream | Any |

## Linear Integration

All projects sync with Linear for issue tracking.

```
Session Start              During Session           Session End
─────────────              ──────────────           ───────────
/prime                     /linear create           /session-end
↓                          /linear update           ↓
Check Linear issues        /linear sync             Update ticket
Ask what to work on                                 Add summary
                                                    Git compliance
```

**Status Flow (DDD):** `Backlog → Exploration → Decision → Delivery → Review → Done`

**MCP Setup:**
```bash
claude mcp add --transport http linear-server https://mcp.linear.app/mcp
```

---

## Productive.io Integration

Productive.io ist das **System of Record für Kundenwert**.

```
┌───────────────────────────────────────────────────────────────┐
│  PRODUCTIVE.IO          PRODUCTIZER           LINEAR          │
│  (Kundenwert)           (Bridge)              (Execution)     │
│       │                     │                     │           │
│  Delivery Units ───────►    │    ◄──────────── Projects       │
│                             ▼                                 │
│                    CUSTOMER PORTAL                            │
└───────────────────────────────────────────────────────────────┘
```

**Commands:**
```
/productizer setup [customer]   # Neuen Kunden einrichten
/productizer sync               # Daten synchronisieren
/productizer report [customer]  # Kunden-Report generieren
/budget status [customer]       # Kontingent-Status anzeigen
/budget report [customer]       # Budget-Report generieren
/customer setup [name]          # Neuen Kunden einrichten
/customer list                  # Alle Kunden anzeigen
/decision [type]                # AIDD-Entscheidung dokumentieren
```

---

## Customer Communication Rules

All customer-facing communication must follow these rules:

| Include | Exclude |
|---------|---------|
| ✅ Service-level information | ❌ Task-level details |
| ✅ Current phase | ❌ Individual tickets |
| ✅ Deadlines (Delivery only) | ❌ Developer names |
| ✅ Business value | ❌ Technical details |
| ✅ Decisions made | ❌ Sprint/iteration info |

**Focus:** Service → Decisions → Value

### Deadline Communication

| Phase | Show Deadline? |
|-------|---------------|
| Exploration | ❌ No |
| Decision | ❌ No |
| **Delivery** | ✅ **YES** |
| Review | ❌ No |
| Done | ❌ No |

Deadlines are only communicated when work is in **Delivery phase** (committed timeline).

---

## Visual Verification Strategy

```
Development (90%)          Production (10%)
─────────────────          ────────────────
/visual-verify             E2E Tests
agent-browser              Playwright
Sekunden                   Minuten
Interaktiv                 Automatisiert
Jede UI-Änderung           Nur kritische Flows
```

**Regel:** `/visual-verify` für schnelle UI-Checks während Development. E2E Tests nur für kritische Production-Flows (Login, Checkout, Payment).

## Skill Format (Claude Code v2.1.3+)

Each skill uses the SKILL.md format with YAML frontmatter:

```yaml
---
name: skill-name
description: What this skill does and when to use it
disable-model-invocation: true
allowed-tools: Read, Write, Bash
argument-hint: [args]
---

# Instructions

[Markdown content with instructions for Claude]
```

## Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Display name (defaults to directory name) |
| `description` | Yes | What the skill does and when to use it |
| `disable-model-invocation` | No | `true` = only user can invoke |
| `allowed-tools` | No | Tools Claude can use without asking |
| `argument-hint` | No | Hint for autocomplete (e.g., `[feature-name]`) |
| `context` | No | `fork` to run in subagent |
| `agent` | No | Subagent type (Explore, Plan, general-purpose) |

## Creating New Skills

1. Create directory: `.claude/skills/my-skill/`
2. Create `SKILL.md` with frontmatter + instructions
3. Optionally add supporting files:
   - `template.md` - Templates for Claude to fill
   - `examples/` - Example outputs
   - `scripts/` - Utility scripts

## Skill vs Mastra Tool

| Concept | What It Is | Location |
|---------|-----------|----------|
| **Claude Code Skill** | Instructions/prompts for Claude | `.claude/skills/` |
| **Mastra Tool** | Executable code for AI agents | `mastra/src/tools/` |

Skills guide Claude's behavior. Mastra tools are actual code implementations.

## Custom Subagents (v2.1.16+)

In addition to skills, Agent Kit includes custom subagents in `.claude/agents/`.

| Location | Contains |
|----------|----------|
| `.claude/skills/` | Skills (prompts for workflows) |
| `.claude/agents/` | Subagents (specialized AI assistants) |

### Available Agents

| Agent | Purpose | Model |
|-------|---------|-------|
| `code-reviewer` | Code quality & security review | Sonnet |
| `architecture-guard` | CLAUDE.md compliance checking | Haiku |
| `test-runner` | Test execution & reporting | Haiku |
| `session-closer` | Session cleanup, Git check, Linear sync | Haiku |

### Skill vs Agent

| Aspect | Skill | Subagent |
|--------|-------|----------|
| Invocation | `/skill-name` | Automatic or explicit |
| Context | Main conversation | Separate context |
| Purpose | Workflow instructions | Specialized task execution |
| Persistence | Same session | Fresh per invocation |

See `.claude/reference/task-system.md` for complete agent documentation.

## Documentation

- [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
- [Claude Code Subagents Docs](https://code.claude.com/docs/en/sub-agents)
- [Agent Skills Standard](https://agentskills.io)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
