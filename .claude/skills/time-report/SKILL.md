---
name: time-report
description: Cross-project time report. Aggregates all session data from ~/.claude-time/sessions/. Use to see how much time was spent across all projects.
disable-model-invocation: true
allowed-tools: Bash, Read
argument-hint: [all | this-week | this-month | last-month | {project-name}]
---

# Time Report: Cross-Project Session Overview

## Objective

Read ALL session files from `~/.claude-time/sessions/*.json` and produce an aggregated time report. Supports filtering by period or project name.

---

## Arguments

| Argument | Description |
|----------|-------------|
| `all` (default) | All sessions ever recorded |
| `this-week` | Current calendar week (Monday-Sunday) |
| `this-month` | Current calendar month |
| `last-month` | Previous calendar month |
| `{project-name}` | Filter to a specific project |

---

## Process

### 1. Load All Session Data

```bash
TIME_DIR="$HOME/.claude-time"
SESSIONS_DIR="$TIME_DIR/sessions"
DEVELOPER_FILE="$TIME_DIR/developer.json"

# List all session files
ls "$SESSIONS_DIR"/*.json 2>/dev/null

# Read developer name
DEVELOPER_NAME=$(cat "$DEVELOPER_FILE" 2>/dev/null | grep '"name"' | cut -d'"' -f4)
```

### 2. Parse Each Session File

For each `*.json` in `$SESSIONS_DIR`:
- The filename (without `.json`) is the project name
- Read the `sessions` array
- Each entry has: `date`, `start`, `end`, `duration_minutes`, `recovered` (optional), `synced_to_productive`

### 3. Apply Filter

Based on the argument:

| Filter | Logic |
|--------|-------|
| `all` | No filtering |
| `this-week` | Compare `date` to current week range |
| `this-month` | Compare `date` to current month (YYYY-MM) |
| `last-month` | Compare `date` to previous month (YYYY-MM) |
| `{project}` | Only read `sessions/{project}.json` |

### 4. Aggregate

For each project:
- Count sessions
- Sum `duration_minutes`
- Find last active date
- Count recovered sessions

Cross-project totals:
- Total sessions
- Total time
- Total recovered

### 5. Format Duration

Convert minutes to human-readable:
```
85 min  → 1h 25min
210 min → 3h 30min
```

---

## Output Format

```
TIME REPORT                                    Developer: {name}
Period: {filter description}                   Generated: {date}
────────────────────────────────────────────────────────────────────
Project                     Sessions    Total Time     Last Active
────────────────────────────────────────────────────────────────────
n8n-v2-migration            1           1h 37min       2026-02-11
client-service-reporting    3           5h 15min       2026-02-10
cotinga-test-suite          7           12h 45min      2026-02-09
────────────────────────────────────────────────────────────────────
TOTAL                       11          19h 37min

RECOVERED: 2 sessions (approximate duration marked with ~)

────────────────────────────────────────────────────────────────────
Sessions data: ~/.claude-time/sessions/
```

### If Project-Specific Filter

When filtering by project name, show individual sessions:

```
TIME REPORT: {project-name}                    Developer: {name}
Period: all                                    Generated: {date}
────────────────────────────────────────────────────────────────────

Date          Start    End      Duration    Ticket     Status
────────────────────────────────────────────────────────────────────
2026-02-11    02:33    04:10    1h 37min    -          pending
2026-02-10    14:00    17:30    3h 30min    CUS-42     synced
2026-02-09    09:15    11:00    1h 45min    CUS-41     pending
────────────────────────────────────────────────────────────────────
TOTAL: 3 sessions, 6h 52min

Recovered: 1 session (~)     Synced: 1     Pending: 2
```

---

## Edge Cases

| Case | Handling |
|------|----------|
| No session files exist | Show: "No sessions recorded yet. Start tracking with `/prime`." |
| Project not found | Show: "No sessions found for project '{name}'." |
| Recovered sessions | Mark with `~` prefix on duration, count separately |
| Zero duration | Show as `< 1min` |
| Session file corrupted | Skip with warning: "Could not parse {file}" |

---

## No Productive.io Sync

This skill is read-only. It does NOT sync to Productive.io. For syncing, use `/time-sync` (future feature).
