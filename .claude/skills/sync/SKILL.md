---
name: sync
description: Sync updates from upstream agent-kit to this downstream project. Use when the template has new skills or patterns.
disable-model-invocation: true
allowed-tools: Bash, Read
argument-hint: [--dry-run]
---

# Sync Updates from Upstream

Pull updates from the upstream agent-kit template into this downstream project.

## Expected Folder Structure

```
lucidlabs/
├── lucidlabs-agent-kit/        # Upstream template
└── projects/
    └── [this-project]/         # You are here (downstream)
```

## Quick Start

```bash
# Preview what can be synced (dry run)
./scripts/sync-upstream.sh --dry-run

# Run sync (default path: ../../lucidlabs-agent-kit)
./scripts/sync-upstream.sh

# Custom upstream path (if different structure)
./scripts/sync-upstream.sh --upstream /path/to/agent-kit

# Sync all without selection
./scripts/sync-upstream.sh --all
```

## What Gets Synced

| Syncable ✅ | Description |
|-------------|-------------|
| `.claude/skills/*` | Claude Code skills |
| `.claude/reference/*` | Best practice documentation |
| `frontend/components/ui/*` | Generic UI components |
| `frontend/lib/utils.ts` | Utility functions |
| `frontend/lib/hooks/*` | Generic React hooks |
| `scripts/*` | Utility scripts |
| `CLAUDE.md` | Development rules |
| `WORKFLOW.md` | Workflow documentation |

## What Does NOT Get Synced

| Not Synced ❌ | Reason |
|---------------|--------|
| `.claude/PRD.md` | Project-specific requirements |
| `frontend/app/*` | Project-specific pages |
| `mastra/src/agents/*` | Domain-specific agents |
| `convex/*` | Project-specific database |

## Example Session

```
╔═══════════════════════════════════════════════════════════════════╗
║                      UPSTREAM SYNC                                ║
╚═══════════════════════════════════════════════════════════════════╝

ℹ Downstream: ~/coding/repos/lucidlabs/projects/customer-portal
ℹ Upstream:   ~/coding/repos/lucidlabs/lucidlabs-agent-kit

▶ Scanning for syncable updates...

  [1] .claude/skills/code-review/SKILL.md (NEW)
  [2] .claude/reference/api-patterns.md (MODIFIED)
  [3] frontend/lib/utils.ts (MODIFIED)

Enter numbers to sync (e.g., 1,2,3 or 'all' or 'q' to quit): 1,2

▶ Preview of changes:

--- .claude/skills/code-review/SKILL.md (NEW) ---
+ New file from upstream

--- .claude/reference/api-patterns.md (MODIFIED) ---
- Old content
+ New content from upstream

Apply these changes? [y/N]: y

▶ Syncing files...
✓ Synced: .claude/skills/code-review/SKILL.md
✓ Synced: .claude/reference/api-patterns.md

✓ Synced 2 file(s) from upstream

Suggested commit:

  git add .
  git commit -m "chore: sync updates from upstream agent-kit"
```

## Options

| Option | Description |
|--------|-------------|
| `--upstream PATH` | Path to agent-kit (default: `../../lucidlabs-agent-kit`) |
| `--dry-run` | Preview without changes |
| `--all` | Sync all without selection |
| `--help` | Show help |

## When to Sync

Sync from upstream when:
- New skills were added to the template
- Best practice documentation was updated
- Bug fixes were made to shared utilities
- UI components were improved

## Related Commands

| Direction | Command | Description |
|-----------|---------|-------------|
| Upstream → Downstream | `/sync` | This skill |
| Downstream → Upstream | `/promote` | Promote patterns to template |

## Manual Alternative

If you prefer manual control:

```bash
# Add upstream as git remote (one-time)
git remote add template ../../lucidlabs-agent-kit

# Fetch latest
git fetch template

# See what changed
git log template/main --oneline -10

# Cherry-pick specific commits
git cherry-pick <commit-hash>

# Or diff and copy manually
diff -r ../../lucidlabs-agent-kit/.claude/skills .claude/skills
```
