# Promote & Sync Architecture

> **How patterns flow between upstream (agent-kit) and downstream (projects)**
> Last updated: 2026-02-11

## Overview

Every project makes us smarter. The promote/sync system ensures learnings flow in both directions:

- **Promote** (Downstream → Upstream): Battle-tested patterns from projects get promoted to the template
- **Sync** (Upstream → Downstream): Template improvements get pulled into existing projects

```
┌─────────────────┐       promote        ┌──────────────────┐
│   Downstream    │  ──────────────────→  │     Upstream     │
│   (Projects)    │                       │   (Agent Kit)    │
│                 │  ←──────────────────  │                  │
└─────────────────┘       sync            └──────────────────┘
```

**Core philosophy:** Promote PATTERNS (guardrails, best practices, skills), not PROJECT COPIES.

---

## What Flows

### Promotable (Downstream → Upstream)

| Path | Description |
|------|-------------|
| `.claude/skills/*` | Claude Code skills |
| `.claude/reference/*` | Best practice documentation |
| `frontend/components/ui/*` | Generic UI components |
| `frontend/lib/utils.ts` | Utility functions |
| `frontend/lib/hooks/*` | Generic React hooks |
| `scripts/*` | Utility scripts |

### Non-Promotable (Stay in Project)

| Path | Reason |
|------|--------|
| `.claude/PRD.md` | Project-specific requirements |
| `frontend/app/*` | Project-specific pages/routes |
| `mastra/src/agents/*` | Domain-specific AI agents |
| `convex/*` | Project-specific database schema |
| `.env*` | Environment secrets |

---


## Promote Queue (MANDATORY for Downstream Projects)

Every downstream project MUST maintain a promote queue file at `.agents/promote-queue.md`.

### Purpose

The promote queue is a living document that tracks patterns, skills, and reference docs that are candidates for upstream promotion. It serves as:

1. **Discovery log** - Captures reusable patterns as they emerge during development
2. **Review list** - Gives the maintainer a clear list of what to review and pull
3. **Sync checkpoint** - When running `/prime` in upstream, the queue is scanned across all projects

### Queue File Format

**Location:** `.agents/promote-queue.md`

```markdown
# Promote Queue

Items pending promotion to upstream agent-kit.

## Pending

### [Pattern/Skill Name]
- **Source:** `.claude/reference/my-pattern.md`
- **Date added:** 2026-02-17
- **Category:** reference-doc | skill | component | script | hook
- **Description:** Brief explanation of what this pattern does and why it belongs in upstream
- **Status:** pending

### [Another Pattern]
- **Source:** `.claude/skills/my-skill/SKILL.md`
- **Date added:** 2026-02-15
- **Category:** skill
- **Description:** Reusable skill for X that works across all projects
- **Status:** pending

## Promoted

### [Already Promoted Pattern]
- **Source:** `.claude/reference/old-pattern.md`
- **Date promoted:** 2026-02-10
- **PR:** #42
- **Status:** promoted
```

### Queue Rules

| Rule | Details |
|------|---------|
| **Add immediately** | When you discover a reusable pattern, add it to the queue right away |
| **Description required** | Every item MUST explain what it does and why it's reusable |
| **Category required** | Must specify: reference-doc, skill, component, script, or hook |
| **No app-specific items** | Do NOT queue domain-specific features (meeting-import, invoice-parsing) |
| **Promote via skill** | Only use `/promote` to execute promotion - never copy files manually |
| **Track status** | Move items from Pending to Promoted after successful PR merge |

### What Belongs in the Queue

| Belongs | Does NOT Belong |
|---------|-----------------|
| Generic dev practices | App-specific workflows |
| Reusable skills | Domain-specific agents |
| Technology reference docs | Project-specific PRDs |
| Utility scripts | Customer data schemas |
| UI patterns (generic) | Business logic |
| Error handling patterns | API integrations (app-specific) |

### Scanning Queues from Upstream

When `/prime` runs in upstream mode, it should scan all downstream promote queues:

```bash
for proj in ../projects/*; do
  QUEUE="$proj/.agents/promote-queue.md"
  if [ -f "$QUEUE" ]; then
    echo "=== $(basename $proj) ==="
    grep -A2 "^### " "$QUEUE" | grep -v "^--$"
  fi
done
```

---
## Promote Flow (Downstream → Upstream)

### Using `/promote` Skill

```bash
# From the downstream project directory
./scripts/promote.sh --upstream ../../lucidlabs-agent-kit
```

### Steps

```
1. FETCH     → Pull latest upstream (git fetch origin)
2. DIFF      → Check for upstream changes since last sync
3. SYNC      → If changes exist: sync first, then promote
4. DETECT    → Find promotable changes (whitelist/blacklist)
5. SELECT    → Choose files to promote (interactive)
6. BRANCH    → Create feature branch in upstream
7. COPY      → Transfer files
8. PR        → Create Pull Request (MANDATORY - never push to main)
9. REVIEW    → Code review
10. MERGE    → Merge after approval
```

### Pre-Promotion Checklist

- [ ] Is the pattern truly generic (no domain keywords)?
- [ ] Was upstream synced first?
- [ ] Feature branch created (not on main)?
- [ ] PR will be created (not direct push)?

---

## Sync Flow (Upstream → Downstream)

### Using `/sync` Skill

```bash
# From the downstream project directory
./scripts/sync-upstream.sh

# Options
./scripts/sync-upstream.sh --dry-run    # Preview only
./scripts/sync-upstream.sh --all        # Sync everything
```

### How It Works

1. Scans upstream for new/modified files in syncable paths
2. Shows a numbered list of available updates
3. User selects which files to sync
4. Shows diff preview
5. Applies changes after confirmation

---

## Version Tracking: `.upstream-sync.json`

Every downstream project has a tracking file at the project root:

```json
{
  "upstream_repo": "lucidlabs-hq/agent-kit",
  "last_sync_commit": "523ea90",
  "last_sync_date": "2026-02-11",
  "synced_files": {
    ".claude/reference/ci-cd-security.md": "523ea90",
    ".claude/skills/pr/SKILL.md": "523ea90",
    "CLAUDE.md": "523ea90"
  }
}
```

| Field | Purpose |
|-------|---------|
| `upstream_repo` | GitHub repo identifier |
| `last_sync_commit` | Upstream commit SHA at last sync |
| `last_sync_date` | Date of last sync |
| `synced_files` | Per-file tracking of which upstream commit each was synced from |

### Benefits

- `git log <last_sync_commit>..HEAD` shows what changed since last sync
- Per-file tracking enables selective sync
- Sync script updates this file automatically after each sync

---

## CLAUDE.md Zone Marker

### Problem

CLAUDE.md cannot be blindly overwritten during sync because downstream projects add project-specific sections (welcome messages, project-specific rules, etc.).

### Solution

A zone marker divides CLAUDE.md into two parts:

```markdown
## Expert Role
...
(upstream content above)

<!-- UPSTREAM-SYNC-END -->

## Project-Specific Rules
...
(downstream-only content below - never touched by sync)
```

### Sync Behavior

| Scenario | Behavior |
|----------|----------|
| Marker present | Sync replaces content BEFORE the marker, preserves everything AFTER |
| Marker absent (legacy) | Sync WARNS and skips CLAUDE.md entirely |
| New project | Marker is included by default from template |

---

## Bootstrapping

### Problem

Existing downstream projects don't have the sync infrastructure (`sync-upstream.sh`, `promote.sh`, `.upstream-sync.json`).

### Solution: `bootstrap-sync.sh`

Run once from the upstream agent-kit to bootstrap all downstream projects:

```bash
cd /path/to/lucidlabs-agent-kit
./scripts/bootstrap-sync.sh
```

This script:
1. Finds all projects in `../projects/`
2. Copies `scripts/sync-upstream.sh` and `scripts/promote.sh`
3. Creates `.upstream-sync.json` with current upstream HEAD
4. Makes scripts executable

### Self-Bootstrap via `/sync` Skill

If a project runs `/sync` but doesn't have the scripts yet, the skill will:
1. Copy scripts from upstream
2. Create `.upstream-sync.json`
3. Proceed with normal sync

This makes the bootstrapping problem self-healing.

### New Projects

`create-agent-project.sh` includes sync infrastructure from the start:
- Copies `scripts/sync-upstream.sh` and `scripts/promote.sh`
- Creates `.upstream-sync.json` with the current upstream HEAD commit

---

## Directory Structure

```
upstream (lucidlabs-agent-kit)/
├── scripts/
│   ├── promote.sh               # Promotion script
│   ├── sync-upstream.sh          # Sync script
│   ├── bootstrap-sync.sh         # One-time bootstrap for existing projects
│   └── create-agent-project.sh   # Includes sync infra in new projects
├── .claude/
│   ├── skills/
│   │   ├── promote/SKILL.md      # Promotion instructions
│   │   └── sync/SKILL.md         # Sync instructions (with self-bootstrap)
│   └── reference/
│       └── promote-sync.md       # This document
└── CLAUDE.md                     # Has <!-- UPSTREAM-SYNC-END --> marker

downstream (projects/*/):
├── scripts/
│   ├── promote.sh               # Copied from upstream
│   └── sync-upstream.sh          # Copied from upstream
├── .upstream-sync.json           # Version tracking
└── CLAUDE.md                     # Has zone marker
```

---

## Rules

1. **Promotions ALWAYS go through PRs** - Never push directly to upstream main
2. **Sync before promote** - Always check for upstream changes first
3. **Domain keywords = warning** - Files with `ticket`, `customer`, `invoice`, etc. need extra review
4. **Zone markers are mandatory** - New projects get them from template, legacy projects get them from bootstrap
5. **One pattern at a time** - Small, focused promotions are easier to review

---

## References

- `.claude/skills/promote/SKILL.md` - Promotion skill instructions
- `.claude/skills/sync/SKILL.md` - Sync skill instructions
- `scripts/promote.sh` - Promotion script
- `scripts/sync-upstream.sh` - Sync script
- `scripts/bootstrap-sync.sh` - Bootstrap script for existing projects
