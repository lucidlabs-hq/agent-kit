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
- `synced_files` is populated automatically during sync — each synced path is recorded with the upstream commit SHA

---

## Pattern Registry

The Pattern Registry is a central catalog of all available patterns in the upstream agent-kit. It enables discovery, staleness checking, and enriched sync/promote displays.

### Registry File: `pattern-registry.json`

Located at the upstream root. Auto-generated — never edit manually.

```json
{
  "$schema_version": "1.0.0",
  "generated_at": "2026-02-18T14:30:00Z",
  "generated_from_commit": "8b71059",
  "pattern_count": 117,
  "categories": {
    "skill":     { "count": 35, "base_path": ".claude/skills" },
    "reference": { "count": 49, "base_path": ".claude/reference" },
    "component": { "count": 20, "base_path": "frontend/components/ui" },
    "utility":   { "count": 3,  "base_path": "frontend/lib" },
    "hook":      { "count": 0,  "base_path": "frontend/lib/hooks" },
    "script":    { "count": 10, "base_path": "scripts" }
  },
  "patterns": [
    {
      "id": "skill/commit",
      "name": "commit",
      "category": "skill",
      "path": ".claude/skills/commit/SKILL.md",
      "description": "Commit conventions and pre-commit workflow",
      "version": "226397f",
      "added_date": "2026-01-27",
      "last_modified": "2026-02-17",
      "size_bytes": 4805
    }
  ]
}
```

### Pattern ID Convention

`{category}/{name}` — e.g. `skill/commit`, `reference/code-standards`, `script/promote`

| Category | Source | Name Derivation |
|----------|--------|-----------------|
| skill | `.claude/skills/*/SKILL.md` | Directory name |
| reference | `.claude/reference/*.md` | Filename sans `.md` |
| component | `frontend/components/ui/*.tsx` | Filename sans `.tsx` |
| utility | `frontend/lib/*.ts` | Filename sans `.ts` |
| hook | `frontend/hooks/*.ts` | Filename sans extension |
| script | `scripts/*.sh` | Filename sans `.sh` |

### Scripts

**Generator:** `scripts/pattern-registry.sh`

```bash
./scripts/pattern-registry.sh              # Generate registry
./scripts/pattern-registry.sh --dry-run    # Preview without writing
./scripts/pattern-registry.sh --quiet      # Suppress progress output
./scripts/pattern-registry.sh --json       # Write file + print JSON
```

Scans the filesystem and git history. Extracts descriptions from YAML frontmatter (skills), blockquotes (reference docs), or uses `"{name} {category}"` as fallback.

**Discovery CLI:** `scripts/pattern-list.sh`

```bash
./scripts/pattern-list.sh                           # List all patterns
./scripts/pattern-list.sh --category skill           # Filter by category
./scripts/pattern-list.sh --search "auth"            # Search name/description
./scripts/pattern-list.sh --project neola            # Staleness report
./scripts/pattern-list.sh --new-since abc1234        # Changes since commit
./scripts/pattern-list.sh --json                     # JSON output
```

The staleness report (`--project`) compares the registry against the project's `synced_files` in `.upstream-sync.json` and shows up-to-date, stale, and missing counts.

### Integration

| System | Behavior |
|--------|----------|
| **Promote** (`promote.sh`) | Auto-regenerates `pattern-registry.json` after copying files, includes it in the PR commit |
| **Sync** (`sync-upstream.sh`) | Registry included in `SYNCABLE_PATHS`, scan display enriched with pattern descriptions, `synced_files` populated per-file, staleness summary shown after sync |
| **Pattern List** | Auto-regenerates registry if missing or stale (>1 hour) |

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
├── pattern-registry.json          # Auto-generated pattern catalog
├── scripts/
│   ├── promote.sh                 # Promotion script (updates registry)
│   ├── sync-upstream.sh           # Sync script (populates synced_files)
│   ├── pattern-registry.sh        # Registry generator
│   ├── pattern-list.sh            # Discovery CLI
│   ├── drift-detect.sh            # Cross-project drift detection
│   ├── audit-sync.sh              # Orchestrated fleet sync
│   ├── bootstrap-sync.sh          # One-time bootstrap for existing projects
│   └── create-agent-project.sh    # Includes sync infra in new projects
├── .claude/
│   ├── skills/
│   │   ├── promote/SKILL.md       # Promotion instructions
│   │   ├── sync/SKILL.md          # Sync instructions (with self-bootstrap)
│   │   └── audit-sync/SKILL.md    # Fleet audit & sync instructions
│   └── reference/
│       └── promote-sync.md        # This document
└── CLAUDE.md                      # Has <!-- UPSTREAM-SYNC-END --> marker

downstream (projects/*/):
├── pattern-registry.json          # Synced from upstream (read-only reference)
├── scripts/
│   ├── promote.sh                 # Copied from upstream
│   └── sync-upstream.sh           # Copied from upstream
├── .upstream-sync.json            # Version tracking (synced_files populated)
└── CLAUDE.md                      # Has zone marker
```

---

## Downstream Project Rule (MANDATORY)

When working in a downstream project (identified by `.claude/PROJECT-CONTEXT.md` with `type: downstream`):

**ALL new files MUST be created in the CURRENT project, NEVER in the upstream repository.**

| Action | Create In |
|--------|-----------|
| New workflows | `./n8n/workflows/` (current project) |
| New skills | `./.claude/skills/` (current project) |
| New components | `./frontend/components/` (current project) |
| New tools | `./mastra/src/tools/` (current project) |
| New reference docs | `./.claude/reference/` (current project) |

**Check before creating:**
1. Read `.claude/PROJECT-CONTEXT.md` to identify project type
2. If `type: downstream` -> create files HERE
3. If `type: upstream` or file doesn't exist -> you're in the template

**Exception:** Use `/promote` skill to intentionally copy proven patterns TO upstream.

### Upstream Interaction Rules (HARD BOUNDARY)

From a downstream project, the ONLY permitted interactions with upstream are:

| Permitted | How | Direct File Access? |
|-----------|-----|---------------------|
| Pull updates | `/sync` skill or `./scripts/sync-upstream.sh` | READ only (copies TO downstream) |
| Push patterns | `/promote` skill or `./scripts/promote.sh` | Creates PR in upstream (never direct push) |
| Spawn new project | `./scripts/create-agent-project.sh` | READ only (copies FROM upstream) |

**FORBIDDEN from any downstream project session:**
- `cd ../../lucidlabs-agent-kit && [any write operation]`
- Writing, editing, or deleting ANY file under `../../lucidlabs-agent-kit/`
- `git push` to ANY branch in the upstream repo (use scripts which handle branching)
- Opening the upstream repo as a working directory

**This is a hard boundary.** The upstream is a curated knowledge base, not a workspace. Treat it like a package registry: you consume from it (`/sync`) and contribute to it (`/promote`), but you never write to it directly.

---

## Rules

1. **Promotions ALWAYS go through PRs** - Never push directly to upstream main
2. **Sync before promote** - Always check for upstream changes first
3. **Domain keywords = warning** - Files with `ticket`, `customer`, `invoice`, etc. need extra review
4. **Zone markers are mandatory** - New projects get them from template, legacy projects get them from bootstrap
5. **One pattern at a time** - Small, focused promotions are easier to review

---

## Drift Detection

### Script: `scripts/drift-detect.sh`

Detects how far behind each downstream project is relative to upstream HEAD. Can be run from upstream OR downstream.

```bash
./scripts/drift-detect.sh                   # Full drift report
./scripts/drift-detect.sh --project neola   # Single project
./scripts/drift-detect.sh --json            # Machine-readable output
./scripts/drift-detect.sh --quiet           # Compact table (for /prime)
```

### Per-Project Metrics

| Metric | Source | Description |
|--------|--------|-------------|
| `commits_behind` | `git rev-list --count` | Commits since last sync |
| `days_behind` | `.upstream-sync.json` date vs today | Calendar days |
| `files_changed` | `git diff --name-only` | Files changed in upstream |
| `score` | Infrastructure checks (9 items) | Sync readiness score |
| `promote_queue` | `.agents/promote-queue.md` | Pending promotion items |

### Status Classification

| Status | Criteria | Color |
|--------|----------|-------|
| CURRENT | 0 commits behind | Green |
| RECENT | 1-3 commits behind | Yellow |
| STALE | 4+ commits behind | Red |
| BROKEN | Missing .upstream-sync.json | Red |

---

## Fleet Audit & Sync

### Script: `scripts/audit-sync.sh`

Orchestrates bringing ALL downstream projects up to date with upstream. Runs a 5-phase workflow.

```bash
./scripts/audit-sync.sh --dry-run              # Preview plan
./scripts/audit-sync.sh                         # Full audit
./scripts/audit-sync.sh --project neola         # Single project
./scripts/audit-sync.sh --skip-promote --yes    # Sync-only, automated
```

### Phases

| Phase | Action | Details |
|-------|--------|---------|
| 1. Backup | Safe copy of every project | rsync + git bundle to `~/.lucidlabs-backups/` |
| 2. Bootstrap | Fix broken projects | Copy sync scripts, create .upstream-sync.json |
| 3. Promote | Process promote queues | Run promote.sh per project, creates PRs |
| 4. Sync | Sync from enriched upstream | Run sync-upstream.sh --all per project |
| 5. Verify | Confirm success | Check sync commit, zone markers, scripts |

### Why Promote BEFORE Sync

If we sync first, promoted patterns from downstream would conflict with newly-synced upstream versions. By promoting first:
1. Downstream improvements become part of upstream HEAD
2. Promotion PRs are merged to enrich upstream
3. Sync then distributes the complete upstream to all projects

### Backup Strategy (3 Layers)

1. **rsync** — Full directory copy (excluding node_modules, .next, dist)
2. **git bundle** — Portable complete git history
3. **manifest.json** — Metadata (branch, commit, dirty state, file count, size)

Backups are stored at `~/.lucidlabs-backups/audit-<timestamp>/` with a JSON manifest.

---

## References

- `.claude/skills/promote/SKILL.md` - Promotion skill instructions
- `.claude/skills/sync/SKILL.md` - Sync skill instructions
- `scripts/promote.sh` - Promotion script (auto-updates registry)
- `scripts/sync-upstream.sh` - Sync script (populates `synced_files`)
- `scripts/pattern-registry.sh` - Pattern registry generator
- `scripts/pattern-list.sh` - Pattern discovery CLI
- `scripts/drift-detect.sh` - Cross-project drift detection
- `scripts/audit-sync.sh` - Orchestrated fleet audit & sync
- `scripts/bootstrap-sync.sh` - Bootstrap script for existing projects
- `pattern-registry.json` - Central pattern catalog (auto-generated)
