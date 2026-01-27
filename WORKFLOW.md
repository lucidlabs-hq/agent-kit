# Agent Kit - Development Workflow Guide

This guide explains the complete development workflow for Agent Kit projects.

## Table of Contents

1. [Quick Reference](#quick-reference)
2. [PRD-First Development](#prd-first-development)
3. [The PIV Loop](#the-piv-loop)
4. [Slash Commands](#slash-commands)
5. [Step-by-Step Workflow](#step-by-step-workflow)
6. [Best Practices](#best-practices)

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

## Slash Commands

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
