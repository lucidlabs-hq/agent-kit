---
name: linear
description: Linear project management integration. Use for creating issues, updating status, and syncing work with Linear board.
allowed-tools: Bash, Read, Write
argument-hint: [create|update|sync|status]
---

# Linear Integration

Manage Linear issues and projects directly from Claude Code via MCP.

## Prerequisites: MCP Setup

### First-Time Setup

```bash
# 1. Add Linear MCP server to Claude Code
claude mcp add --transport http linear-server https://mcp.linear.app/mcp

# 2. Authenticate (opens browser)
/mcp
```

### Environment Variables (Alternative)

For automated workflows, use API key authentication:

```bash
# In .env or shell
export LINEAR_API_KEY=lin_api_...
```

Get your API key from: https://linear.app/lucid-labs-agents/settings/api

---

## Lucid Labs Linear Workspace

**Workspace:** `lucid-labs-agents`
**URL:** https://linear.app/lucid-labs-agents

---

## Discovery-Driven Development (DDD) Status Flow

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

| Status | Purpose | What Happens Here |
|--------|---------|-------------------|
| **Backlog** | Idea without commitment | Capture, no prioritization |
| **Exploration** | Reduce uncertainty | Timeboxed spike, learning focus |
| **Decision** | Steering point | Proceed/Iterate/Pivot/Drop |
| **Delivery** | Validated implementation | Measurable progress |
| **Review** | QA/Stakeholder check | Validation before completion |
| **Done** | Shipped | Ready for production |
| **Dropped** | Valid end state | Insight gained, not pursuing |

### Maintenance Flow (No Exploration)

```
Backlog → Decision → Delivery → Review → Done
```

Or for small ops tasks:
```
Backlog → Delivery → Done
```

---

## Work Types (Mandatory Label)

| Work Type | Description | Skips Exploration? |
|-----------|-------------|-------------------|
| **Exploration** | Research, spike, uncertainty reduction | No |
| **Delivery** | Implementation of validated solution | N/A (after Exploration) |
| **Maintenance** | Bug fix, security patch, ops | Yes |

---

## Project Naming Convention

**Format:** `[Domain] Capability / Area`

**Examples:**
- `[Agents] Ticket Classification`
- `[Agents] Browser Automation`
- `[AI] Meeting Summarization`
- `[Platform] Infrastructure & Ops`
- `[Integration] External API Access`

---

## Commands

### `/linear create`

Create a new Linear issue for current work.

**Interactive flow:**
1. Ask for issue title
2. Ask for description
3. Select work type (Exploration/Delivery/Maintenance)
4. Select project (or create new)
5. Set initial status based on work type

**MCP Command:**
```
Create a Linear issue with:
- Title: [title]
- Description: [description]
- Team: lucid-labs-agents
- Project: [project-name]
- Labels: [work-type]
- Status: [appropriate-status]
```

### `/linear update`

Update current issue status.

**Usage:**
```
/linear update [issue-id] [status]
```

**Status transitions:**
- `exploration` → Move to Exploration
- `decision` → Move to Decision
- `delivery` → Move to Delivery
- `review` → Move to Review
- `done` → Move to Done
- `dropped` → Move to Dropped

### `/linear sync`

Sync local work with Linear board.

**Actions:**
1. Check for new issues assigned to you
2. Update issue status based on local progress
3. Add comments for work completed

### `/linear status`

Show current Linear status and assigned issues.

**Output:**
```
## Linear Status

**Workspace:** lucid-labs-agents
**Your Issues:**

| ID | Title | Status | Project |
|----|-------|--------|---------|
| ABC-123 | Feature X | In Exploration | [Agents] Feature |

**Recent Activity:**
- [timestamp] Issue ABC-123 moved to Exploration
```

---

## Session Workflow Integration

### Session Start (`/prime`)

```
1. Check Linear for:
   - Issues assigned to you in Exploration/Delivery
   - New issues in Backlog you created
   - Issues needing Decision

2. Ask: "Woran möchtest du arbeiten?"
   - Show top 3 issues
   - Option to create new issue
```

### Session End (`/session-end`)

```
1. Update current issue status
2. Add work summary as comment
3. Set next action if incomplete
4. Show updated Linear board state
```

---

## MCP Tool Reference

With Linear MCP connected, you have these tools:

| Tool | Purpose |
|------|---------|
| `linear_create_issue` | Create new issue |
| `linear_update_issue` | Update issue properties |
| `linear_search_issues` | Find issues |
| `linear_get_issue` | Get issue details |
| `linear_create_project` | Create new project |
| `linear_add_comment` | Add comment to issue |

### Example: Create Issue

```
Use linear_create_issue:
- title: "Implement user authentication"
- teamId: [lucid-labs-agents team ID]
- projectId: [project ID]
- labelIds: [Exploration label ID]
- stateId: [Exploration state ID]
```

---

## Labels Reference

### Mandatory
- **Exploration** - Research/spike work
- **Delivery** - Implementation work
- **Maintenance** - Bug fixes, ops, updates

### Optional
- **Bug** - Defect fix
- **Security** - Security-related
- **Tech Debt** - Technical debt reduction
- **Performance** - Performance improvement
- **Ops** - Operations task

---

## Best Practices

### 1. One Issue Per Feature

Create a Linear issue before starting any feature:
```
/linear create
```

### 2. Status Reflects Reality

Update status when work state changes:
- Started research? → Exploration
- Have findings? → Decision
- Implementing? → Delivery
- Need review? → Review

### 3. End Session Clean

Always run `/session-end` to:
- Update issue status
- Add progress comment
- Enable team visibility

### 4. Link Commits to Issues

Include issue ID in commits:
```
feat(auth): implement login flow

Implements ABC-123
```

---

## Troubleshooting

### MCP Connection Issues

```bash
# Clear cached auth
rm -rf ~/.mcp-auth

# Re-authenticate
/mcp
```

### API Key Auth

```bash
# Set environment variable
export LINEAR_API_KEY=lin_api_...

# Verify connection
# Use Linear MCP search to test
```

---

## References

- [Linear MCP Docs](https://linear.app/docs/mcp)
- [Linear API](https://developers.linear.app/)
- [OAuth 2.0 Setup](https://linear.app/developers/oauth-2-0-authentication)
