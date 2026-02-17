# Project Rules

> **Tech stack documentation, README ports, project initialization, skill enforcement, skills catalog, task management, and development workflow.**
> Referenced by: /prime, /init-project, /execute skills.
> Last Updated: February 2026

---

## Tech Stack Documentation Rule (MANDATORY)

When adding new technology to the stack (downstream or upstream):

1. **Update CLAUDE.md** - Add to Tech Stack table
2. **Create reference doc** - `.claude/reference/<technology>.md`
3. **Update AGENTS.md** - Keep in sync with CLAUDE.md
4. **Update infrastructure docs** - If deployment-related

---

## README Port Documentation Rule (MANDATORY)

Every project `README.md` MUST include a Ports section with two tables:

1. **Development** - Service name, port, localhost URL
2. **Production** - Service name, internal port, external port, domain

When adding or changing ports (in docker-compose.yml, package.json scripts, or env defaults), the README Ports section MUST be updated in the same commit.

---

## New Project Initialization Rule (MANDATORY)

When creating a new project from this template:

1. **Update SEO Metadata** - Change `frontend/app/layout.tsx`:
   ```typescript
   export const metadata: Metadata = {
     title: "Project Name | Description",
     description: "Project description for search engines",
   };
   ```
   - **NEVER** leave "Agent Kit | AI Agent Starter" in production projects
2. **Update Package Names** - Change `package.json` in frontend/mastra/backend
3. **Create PRD** - `.claude/PRD.md` with project requirements
4. **Update README.md** - Project-specific documentation

---

## Skill Enforcement Rule (MANDATORY)

All standard operations MUST go through their designated skills. No bash workarounds.

| Operation | Required Skill | NOT Allowed |
|-----------|---------------|-------------|
| Commit code | `/commit` | Raw `git commit` |
| Create PR | `/pr` | Raw `gh pr create` |
| Promote to upstream | `/promote` | Manual file copy + push |
| Sync from upstream | `/sync` | Manual `cp` from agent-kit |
| Deploy | `/deploy` | Manual SSH + docker commands |
| End session | `/session-end` | Just closing the terminal |

**Why:** Skills encode best practices, enforce checklists, and ensure consistency.

**Exception:** During skill development itself, raw commands are permitted to test and debug the skill being built.

---

## Available Skills

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
| `/browser` | Interactive browser automation | Any |
| `/pre-production` | Security & Quality Check before deploy | Validation |
| `/deploy` | Deploy to LUCIDLABS-HQ | Deployment |
| `/mistral` | Setup Mistral AI for EU-friendly LLM | Setup |
| `/promptfoo` | LLM evaluation & prompt testing | Validation |
| `/llm-evaluate` | LLM cost/performance evaluation | Planning |
| `/screenshot` | Visual verification screenshots | Validation |
| `/session-end` | End session, update Linear, clean state | Any |
| `/time-report` | Cross-project time report | Any |
| `/productizer` | Bridge Linear <> Productive.io | Any |
| `/notion-publish` | Publish markdown to Notion | Any |
| `/clone-skill` | Clone skills from central repository | Any |
| `/publish-skill` | Share your skills with the team | Any |
| `/promote` | Promote patterns to upstream | Any |
| `/sync` | Sync updates from upstream | Any |

### Skill vs Mastra Tool

| Concept | What It Is | Location |
|---------|-----------|----------|
| **Claude Code Skill** | Instructions/prompts for Claude | `.claude/skills/` |
| **Mastra Tool** | Executable code for AI agents | `mastra/src/tools/` |

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

## Development Workflow

### Feature Implementation Flow

```
/plan-feature -> /execute (creates branch) -> /validation:self-audit -> /commit -> /pr
```

| Step | Command | Purpose |
|------|---------|---------|
| 1. Plan | `/plan-feature [name]` | Create implementation plan |
| 2. Implement | `/execute [plan]` | Create feature branch + execute the plan |
| 3. Audit | `/validation:self-audit` | Verify compliance with all standards |
| 4. Commit | `/commit` | Create formatted commit (on feature branch) |
| 5. Ship | `/pr` | Push branch + open Pull Request |

### Self-Audit Checklist

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

Use the Task function for every non-trivial task.

### When to Create Tasks

| Situation | Create Task? |
|-----------|-------------|
| Multi-step implementation | YES |
| Setup/configuration | YES |
| Bug across multiple files | YES |
| Simple text change | NO |
| Adding a single function | NO |

### Task Workflow

```
1. TaskCreate     -> Create task (subject, description, activeForm)
2. TaskUpdate     -> Set dependencies (addBlockedBy)
3. TaskUpdate     -> Status: in_progress (before starting)
4. [Work]         -> Implementation
5. TaskUpdate     -> Status: completed (after finishing)
6. TaskList       -> Find next task
```

---

## Plan Naming Convention

```
Format:    YYYY-MM-DD-HHmm-description.md
Location:  .agents/plans/
Archive:   .agents/plans/archive/ (for completed plans)
Sorting:   Newest plan = highest timestamp = last edited
Session:   Read newest plan from .agents/plans/ at session start
```

---

**Version:** 1.0
**Maintainer:** Lucid Labs GmbH
