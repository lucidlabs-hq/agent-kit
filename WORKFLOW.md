# Agent Kit - Development Workflow Guide

This guide explains the complete development workflow for Agent Kit projects.

## Table of Contents

1. [Upstream/Downstream Model](#upstreamdownstream-model)
2. [Quick Reference](#quick-reference)
3. [PRD-First Development](#prd-first-development)
4. [The PIV Loop](#the-piv-loop)
5. [Skills](#skills)
6. [Step-by-Step Workflow](#step-by-step-workflow)
7. [Best Practices](#best-practices)

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

# 2. Run the scaffolding script
./scripts/create-agent-project.sh ../projects/my-project

# 3. Move to the new project
cd ../projects/my-project

# 4. Install dependencies
cd frontend && pnpm install && cd ..

# 5. Initialize git repo and push
git init
gh repo create lucidlabs-hq/my-project --private --source=. --push

# 6. Start developing
/create-prd              # Create project requirements
/prime                   # Load context
/plan-feature login      # Plan first feature
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
# Morning: Prime Claude and check status
/prime

# During day: Implement features
/plan-feature X
/execute
/validate
/commit

# Before lunch/end of day
pnpm run validate  # Quick sanity check
/commit            # Commit work in progress
```

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
