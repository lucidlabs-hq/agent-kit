# Task System & Swarm Orchestration

> Reference documentation for Claude Code's Task system and multi-agent coordination.

**Version:** Claude Code 2.1.16+
**Last Updated:** January 2026

---

## Table of Contents

1. [Task System Overview](#task-system-overview)
2. [Task Tools](#task-tools)
3. [Custom Subagents](#custom-subagents)
4. [Swarm Patterns](#swarm-patterns)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

---

## Task System Overview

Claude Code v2.1.16+ introduced a native Task system for progress tracking and multi-agent coordination.

### Key Benefits

- Visual progress tracking in terminal
- Task dependencies with auto-unblocking
- Multi-agent coordination (Swarm)
- Session-resumable work tracking

### When to Use Tasks

| Scenario | Recommended |
|----------|-------------|
| Multi-step implementation (3+ tasks) | Yes |
| Complex debugging session | Yes |
| Simple single-file edit | No |
| Research/exploration | No |
| User explicitly requests tracking | Yes |

### Task Lifecycle

```
pending → in_progress → completed
                     ↘ deleted
```

### Integration with PIV Workflow

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

---

## Task Tools

### TaskCreate

Creates a new task with optional dependencies.

**Parameters:**
- `subject` (required): Imperative form title ("Implement X", "Add Y")
- `description` (optional): Detailed description
- `activeForm` (optional): Present continuous form for spinner ("Implementing X")

**Example:**
```javascript
TaskCreate({
  subject: "Implement user authentication",
  description: "Add login/logout functionality with JWT tokens",
  activeForm: "Implementing authentication"
})
```

### TaskUpdate

Updates task status, adds dependencies, or deletes tasks.

**Status Updates:**
```javascript
// Start working on a task
TaskUpdate({ taskId: "1", status: "in_progress" })

// Complete a task
TaskUpdate({ taskId: "1", status: "completed" })

// Delete a task
TaskUpdate({ taskId: "1", status: "deleted" })
```

**Dependencies:**
```javascript
// Task 2 waits for Task 1 to complete
TaskUpdate({ taskId: "2", addBlockedBy: ["1"] })

// Task 1 blocks Tasks 2 and 3
TaskUpdate({ taskId: "1", addBlocks: ["2", "3"] })
```

### TaskList

Shows all tasks with their current status.

```javascript
TaskList()
// Returns: id, subject, status, owner, blockedBy
```

### TaskGet

Gets full details of a specific task.

```javascript
TaskGet({ taskId: "1" })
// Returns: subject, description, status, blocks, blockedBy
```

---

## Custom Subagents

Custom subagents extend Claude's capabilities with specialized assistants. They live in `.claude/agents/`.

### Available Agents in Agent Kit

| Agent | Purpose | Model | When to Use |
|-------|---------|-------|-------------|
| `code-reviewer` | Code quality & security | Sonnet | After code changes |
| `architecture-guard` | CLAUDE.md compliance | Haiku | Before committing |
| `test-runner` | Test execution | Haiku | After implementation |

### Built-in Subagents (Claude Code)

| Agent | Purpose | Tools |
|-------|---------|-------|
| `Explore` | Codebase search | Read-only |
| `Plan` | Architecture planning | Read-only |
| `Bash` | Command execution | Bash only |
| `general-purpose` | Complex multi-step | All tools |

### Agent File Format

```yaml
---
name: agent-name
description: When Claude should use this agent
tools: Read, Grep, Glob           # Allowed tools
model: sonnet                      # sonnet, opus, haiku, or inherit
permissionMode: default            # default, acceptEdits, plan, etc.
---

System prompt for the agent...
```

### Using Agents

Agents are invoked automatically when Claude determines they're useful, or explicitly:

```
Use the code-reviewer agent to review my recent changes
Run architecture-guard on the components/ directory
Have test-runner execute the auth tests
```

### Creating Custom Agents

1. Create file: `.claude/agents/my-agent.md`
2. Add YAML frontmatter with name, description, tools
3. Write system prompt in markdown body
4. Agent is available immediately (no restart needed)

---

## Swarm Patterns

Swarm orchestration enables multiple agents working together on complex tasks.

### Pattern 1: Parallel Research

Launch multiple Explore agents to investigate different areas simultaneously:

```
Task({ subagent_type: "Explore", prompt: "Find authentication files" })
Task({ subagent_type: "Explore", prompt: "Find API route handlers" })
Task({ subagent_type: "Explore", prompt: "Find database schema" })
```

All three run in parallel, results synthesized by main conversation.

### Pattern 2: Sequential Pipeline

Create dependent tasks that auto-unblock:

```javascript
TaskCreate({ subject: "1. Research existing patterns" })
TaskCreate({ subject: "2. Create implementation plan" })
TaskCreate({ subject: "3. Implement core feature" })
TaskCreate({ subject: "4. Add tests" })
TaskCreate({ subject: "5. Code review" })

// Set up dependencies
TaskUpdate({ taskId: "2", addBlockedBy: ["1"] })
TaskUpdate({ taskId: "3", addBlockedBy: ["2"] })
TaskUpdate({ taskId: "4", addBlockedBy: ["3"] })
TaskUpdate({ taskId: "5", addBlockedBy: ["4"] })
```

### Pattern 3: Review After Implementation

```
1. Complete implementation tasks
2. TaskCreate({ subject: "Code Review" })
3. Claude automatically invokes code-reviewer agent
4. Review results feed back to main conversation
5. Fix any issues identified
```

### Pattern 4: Parallel Implementation with Shared Dependencies

```javascript
// Foundation task
TaskCreate({ subject: "Create shared types" })

// Parallel tasks that depend on foundation
TaskCreate({ subject: "Implement API endpoint" })
TaskCreate({ subject: "Implement UI component" })
TaskCreate({ subject: "Implement tests" })

TaskUpdate({ taskId: "2", addBlockedBy: ["1"] })
TaskUpdate({ taskId: "3", addBlockedBy: ["1"] })
TaskUpdate({ taskId: "4", addBlockedBy: ["1"] })

// Final task depends on all parallel tasks
TaskCreate({ subject: "Integration testing" })
TaskUpdate({ taskId: "5", addBlockedBy: ["2", "3", "4"] })
```

### Pattern 5: Background Agent Work

Run agents in the background while continuing main conversation:

```javascript
Task({
  subagent_type: "code-reviewer",
  prompt: "Review all files in src/components/",
  run_in_background: true
})
```

Press `Ctrl+B` to background a running foreground task.

---

## Best Practices

### Task Naming

| Good | Bad |
|------|-----|
| "Create user authentication types" | "Step 1" |
| "Add login API endpoint" | "Do the thing" |
| "Fix null pointer in auth service" | "Fix bug" |
| "Update README with new features" | "Docs" |

### Subject vs ActiveForm

- **subject**: Imperative form ("Create types", "Add endpoint")
- **activeForm**: Present continuous ("Creating types", "Adding endpoint")

### When NOT to Use Tasks

- Quick questions/answers
- Single-file edits
- Exploration/research only
- Reading documentation
- Simple commits

### Agent Selection Guide

| Task Type | Recommended Agent |
|-----------|------------------|
| Code review after changes | `code-reviewer` |
| Check CLAUDE.md compliance | `architecture-guard` |
| Run and report tests | `test-runner` |
| Search codebase | Built-in `Explore` |
| Plan implementation | Built-in `Plan` |
| Complex multi-step work | Built-in `general-purpose` |

### Environment Variables

```bash
# Disable task system (revert to old TodoWrite)
CLAUDE_CODE_ENABLE_TASKS=false

# Disable background task functionality
CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1

# Set auto-compaction threshold (default 95%)
CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50
```

---

## Troubleshooting

### Tasks Not Visible After "Clear Context"

Tasks are session-scoped. Clearing context creates a new session.

**Solution:** Don't clear context mid-work, or accept that tasks reset.

### Agent Not Being Invoked

Check:
1. Agent file has valid YAML frontmatter
2. `name` field matches expected name
3. `description` clearly states when to use it
4. File is in `.claude/agents/` directory
5. File extension is `.md`

### Background Task Permission Denied

Background tasks prompt for permissions upfront. If denied, task fails.

**Solution:** Resume in foreground to grant permissions interactively:
```
Resume the code-reviewer agent in foreground
```

### Task Dependencies Not Working

Ensure:
1. Task IDs are strings: `addBlockedBy: ["1"]` not `addBlockedBy: [1]`
2. Blocking task exists before adding dependency
3. No circular dependencies

### Agent Using Wrong Model

Check `model` field in agent frontmatter:
- `sonnet` - Claude Sonnet (balanced)
- `opus` - Claude Opus (most capable)
- `haiku` - Claude Haiku (fastest)
- `inherit` - Same as main conversation

---

---

## Protection Proxy

For safe production database access, Agent Kit includes a read-only protection proxy.

### Purpose

The proxy intercepts API calls and blocks write operations, protecting production data from accidental modifications.

### Architecture

```
Script → localhost:3333 → Proxy → (blocks writes) → Production API
                            ↑
                     Credentials passed
                     via CLI arguments
                     (NOT in project)
```

### Key Security Features

1. **Credentials externalized** - Never stored in project files
2. **CLI argument passing** - `--api-key "$(cat ~/.credentials/key.txt)"`
3. **Physical separation** - Proxy runs as separate process
4. **Automatic blocking** - POST/PUT/PATCH/DELETE blocked by default

### Quick Start

```bash
# Terminal 1: Start proxy (credentials via CLI)
./scripts/templates/read-only-proxy.ts \
  --api-url https://api.example.com \
  --api-key "$(cat ~/.credentials/my-key.txt)"

# Terminal 2: Run scripts (no credentials needed)
USE_PROXY=true npx tsx scripts/fetch-data.ts
```

### What Gets Blocked

| Method | Path | Action |
|--------|------|--------|
| GET | Any | ALLOWED |
| POST | /auth/* | ALLOWED |
| POST | Other | BLOCKED (403) |
| PUT | Any | BLOCKED (403) |
| DELETE | Any | BLOCKED (403) |

See `.claude/agents/protection-proxy.md` for complete documentation.

---

## References

- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Changelog](https://code.claude.com/docs/en/changelog)
- [Claude Code Settings](https://code.claude.com/docs/en/settings)
