# Pattern Registry

The Pattern Registry is a central catalog of every reusable pattern in the upstream agent-kit. It answers three questions that were previously impossible to answer across ~10 downstream projects:

1. **What patterns exist?** — Browse and search the full catalog
2. **What's stale?** — Compare any downstream project against the latest upstream
3. **What changed?** — See which patterns were added or modified since a given commit

---

## Architecture

```
upstream (lucidlabs-agent-kit)
├── pattern-registry.json            <-- generated catalog (118+ patterns)
├── scripts/
│   ├── pattern-registry.sh          <-- generator (scans filesystem + git)
│   └── pattern-list.sh              <-- discovery CLI (query + staleness)
│
├── scripts/promote.sh               <-- auto-updates registry on promotion
└── scripts/sync-upstream.sh          <-- syncs registry, populates synced_files

downstream (projects/*)
├── pattern-registry.json            <-- synced copy (read-only reference)
└── .upstream-sync.json              <-- now tracks per-file versions in synced_files
```

### How It Fits Into Promote/Sync

```
  Downstream Project                          Upstream Agent-Kit
  ─────────────────                          ──────────────────

       /promote ──────────────────────→  promote.sh
                                          │
                                          ├── copies files
                                          ├── runs pattern-registry.sh  ← auto
                                          ├── commits (registry included)
                                          └── opens PR

       /sync    ←──────────────────────  sync-upstream.sh
                                          │
                                          ├── shows enriched file list (with descriptions)
                                          ├── copies selected files
                                          ├── populates synced_files in .upstream-sync.json
                                          └── shows pattern coverage summary
```

---

## Quick Start

### 1. Generate the Registry

```bash
./scripts/pattern-registry.sh
```

This scans all pattern directories, queries git for version/date metadata, extracts descriptions, and writes `pattern-registry.json` to the repo root.

Options:
```bash
./scripts/pattern-registry.sh --dry-run    # Print JSON to stdout, don't write file
./scripts/pattern-registry.sh --quiet      # Suppress progress output
./scripts/pattern-registry.sh --json       # Write file AND print JSON to stdout
```

### 2. Browse Patterns

```bash
# List everything
./scripts/pattern-list.sh

# Filter by category
./scripts/pattern-list.sh --category skill
./scripts/pattern-list.sh --category reference
./scripts/pattern-list.sh --category component

# Search by name or description
./scripts/pattern-list.sh --search "auth"
./scripts/pattern-list.sh --search "deploy"
```

### 3. Check Staleness for a Project

```bash
./scripts/pattern-list.sh --project neola
```

Output:
```
  ╔═══════════════════════════════════════════════════════════════════╗
  ║              PATTERN STALENESS REPORT                             ║
  ╚═══════════════════════════════════════════════════════════════════╝

  Project:     neola
  Last sync:   7dbf253 (2026-02-11)
  Registry:    8b71059 (118 patterns)

  ✓ Up-to-date:  85  (72%)
  ⚠ Stale:        3  ( 3%)
  ✖ Missing:     30  (25%)

  Stale patterns:
    ~ reference/code-standards              abc1234 → def5678
    ~ skill/commit                          abc1234 → def5678
    ~ scripts/promote.sh                    abc1234 → def5678
```

This compares the project's `.upstream-sync.json` `synced_files` against the registry versions.

### 4. See What Changed Since Last Sync

```bash
# What patterns changed since commit abc1234?
./scripts/pattern-list.sh --new-since abc1234
```

### 5. JSON Output

Every command supports `--json` for programmatic use:

```bash
./scripts/pattern-list.sh --category skill --json
./scripts/pattern-list.sh --project neola --json
```

---

## Pattern Categories

The registry tracks six categories of reusable patterns:

| Category | Location | Count | Description |
|----------|----------|-------|-------------|
| **skill** | `.claude/skills/*/SKILL.md` | 35 | Claude Code skills (commit, deploy, sync, etc.) |
| **reference** | `.claude/reference/*.md` | 49 | Best practice documentation and standards |
| **component** | `frontend/components/ui/*.tsx` | 20 | Reusable UI components (button, card, etc.) |
| **utility** | `frontend/lib/*.ts` | 3 | Utility functions and helpers |
| **hook** | `frontend/hooks/*.ts` | 0 | React hooks (directory exists, not yet populated) |
| **script** | `scripts/*.sh` | 11 | Shell scripts (deploy, promote, sync, etc.) |

### Pattern ID Convention

Every pattern gets a unique ID: `{category}/{name}`

Examples:
- `skill/commit` — the commit skill
- `reference/code-standards` — the code standards doc
- `component/button` — the button UI component
- `script/promote` — the promote script

Name derivation:
- Skills: directory name (`.claude/skills/commit/` -> `commit`)
- Reference: filename without `.md` (`code-standards.md` -> `code-standards`)
- Components: filename without `.tsx`
- Scripts: filename without `.sh`

---

## Registry Schema

`pattern-registry.json` is auto-generated. Never edit it manually.

```json
{
  "$schema_version": "1.0.0",
  "generated_at": "2026-02-18T14:30:00Z",
  "generated_from_commit": "8b71059",
  "pattern_count": 118,
  "categories": {
    "skill":     { "count": 35, "base_path": ".claude/skills" },
    "reference": { "count": 49, "base_path": ".claude/reference" },
    "component": { "count": 20, "base_path": "frontend/components/ui" },
    "utility":   { "count": 3,  "base_path": "frontend/lib" },
    "hook":      { "count": 0,  "base_path": "frontend/lib/hooks" },
    "script":    { "count": 11, "base_path": "scripts" }
  },
  "patterns": [
    {
      "id": "skill/commit",
      "name": "commit",
      "category": "skill",
      "path": ".claude/skills/commit/SKILL.md",
      "description": "Create a well-formatted git commit with PROJECT-STATUS.md updates.",
      "version": "226397f",
      "added_date": "2026-01-27",
      "last_modified": "2026-02-17",
      "size_bytes": 4805
    }
  ]
}
```

| Field | Description |
|-------|-------------|
| `id` | Unique pattern identifier (`category/name`) |
| `name` | Human-readable name |
| `category` | One of: skill, reference, component, utility, hook, script |
| `path` | Relative path from repo root to the pattern file |
| `description` | Extracted from YAML frontmatter (skills), blockquotes (reference), or auto-generated |
| `version` | Short SHA of the last git commit that touched this file |
| `added_date` | Date of the first git commit that added this file |
| `last_modified` | Date of the most recent git commit that modified this file |
| `size_bytes` | File size in bytes |

---

## How `synced_files` Tracking Works

Previously, downstream `.upstream-sync.json` files had `synced_files: {}` — always empty. Now, every time `/sync` runs:

1. The sync script copies selected files from upstream to downstream
2. For each copied file, it records `"path": "upstream_commit_sha"` in `synced_files`
3. The staleness CLI (`--project`) compares these recorded versions against the registry

**Before (empty):**
```json
{
  "upstream_repo": "lucidlabs-agent-kit",
  "last_sync_commit": "7dbf253",
  "last_sync_date": "2026-02-11",
  "synced_files": {}
}
```

**After running /sync:**
```json
{
  "upstream_repo": "lucidlabs-agent-kit",
  "last_sync_commit": "8b71059",
  "last_sync_date": "2026-02-18",
  "synced_files": {
    ".claude/skills/commit/SKILL.md": "8b71059",
    ".claude/reference/code-standards.md": "8b71059",
    "scripts/promote.sh": "8b71059",
    "pattern-registry.json": "8b71059"
  }
}
```

This enables per-file staleness detection: if upstream updates `code-standards.md` in a later commit, the staleness report will flag it as stale for that project.

---

## Automatic Behaviors

| Trigger | What Happens |
|---------|-------------|
| `/promote` from downstream | Registry auto-regenerates in the upstream PR branch |
| `/sync` from downstream | Registry is synced as a regular file; `synced_files` populated; coverage summary shown |
| `pattern-list.sh` called | If registry is missing or older than 1 hour, auto-regenerates before querying |

---

## Common Workflows

### "What skills are available?"
```bash
./scripts/pattern-list.sh --category skill
```

### "Is my project up to date?"
```bash
./scripts/pattern-list.sh --project my-project
```

### "What changed since I last synced?"
```bash
# Find your last sync commit
cat ../projects/my-project/.upstream-sync.json | python3 -c "import json,sys; print(json.load(sys.stdin)['last_sync_commit'])"
# abc1234

# See what changed
./scripts/pattern-list.sh --new-since abc1234
```

### "I promoted a pattern, is the registry updated?"
Yes — `promote.sh` auto-runs `pattern-registry.sh` after copying files. The regenerated registry is included in the PR commit.

### "I want to rebuild the registry from scratch"
```bash
./scripts/pattern-registry.sh
```

Idempotent. Safe to run any time. Output is deterministic (same content, different timestamp).

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `pattern-registry.json` not found | Run `./scripts/pattern-registry.sh` |
| Staleness shows all "missing" | Run `/sync --all` in the downstream project to populate `synced_files` |
| Pattern count seems wrong | Registry reflects current filesystem; run generator to refresh |
| `--project` can't find project | Ensure project exists at `../projects/<name>` with `.upstream-sync.json` |
| Description is just "name category" | File lacks extractable description (no YAML frontmatter or blockquote) |

---

## Related Documentation

- `.claude/reference/promote-sync.md` — Full promote/sync architecture
- `.claude/reference/pattern-registry.md` — AI agent reference for working with the registry
- `scripts/pattern-registry.sh` — Generator source
- `scripts/pattern-list.sh` — Discovery CLI source
