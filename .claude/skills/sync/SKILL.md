---
name: sync
description: Sync updates from upstream agent-kit to this downstream project. Use when the template has new skills or patterns.
disable-model-invocation: true
allowed-tools: Bash, Read
argument-hint: [--dry-run]
---

# Sync Updates from Upstream

Pull updates from the upstream agent-kit template into this downstream project.

## Self-Bootstrap (Automatic)

**If `scripts/sync-upstream.sh` does not exist in this project, bootstrap first:**

```bash
# 1. Detect upstream path
UPSTREAM="../../lucidlabs-agent-kit"

# 2. Verify upstream exists
if [ ! -f "$UPSTREAM/CLAUDE.md" ]; then
  echo "ERROR: Upstream agent-kit not found at $UPSTREAM"
  echo "Expected structure: lucidlabs/lucidlabs-agent-kit/ alongside lucidlabs/projects/"
  exit 1
fi

# 3. Create scripts directory
mkdir -p scripts

# 4. Copy sync scripts
cp "$UPSTREAM/scripts/sync-upstream.sh" scripts/sync-upstream.sh
chmod +x scripts/sync-upstream.sh
cp "$UPSTREAM/scripts/promote.sh" scripts/promote.sh
chmod +x scripts/promote.sh

# 5. Create version tracking file
UPSTREAM_HEAD=$(cd "$UPSTREAM" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
cat > .upstream-sync.json << EOF
{
  "upstream_repo": "lucidlabs-hq/agent-kit",
  "last_sync_commit": "$UPSTREAM_HEAD",
  "last_sync_date": "$(date +%Y-%m-%d)",
  "synced_files": {}
}
EOF

echo "Bootstrapped sync infrastructure. Now running sync..."
```

After bootstrap, proceed with normal sync below.

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

| Syncable | Description |
|----------|-------------|
| `.claude/skills/*` | Claude Code skills |
| `.claude/reference/*` | Best practice documentation |
| `frontend/components/ui/*` | Generic UI components |
| `frontend/lib/utils.ts` | Utility functions |
| `frontend/lib/hooks/*` | Generic React hooks |
| `scripts/*` | Utility scripts |
| `CLAUDE.md` | Development rules (respects zone marker) |
| `WORKFLOW.md` | Workflow documentation |

## What Does NOT Get Synced

| Not Synced | Reason |
|------------|--------|
| `.claude/PRD.md` | Project-specific requirements |
| `frontend/app/*` | Project-specific pages |
| `mastra/src/agents/*` | Domain-specific agents |
| `convex/*` | Project-specific database |

## CLAUDE.md Zone Marker

CLAUDE.md has a zone marker that divides upstream content from project-specific content:

```markdown
<!-- UPSTREAM-SYNC-END -->
```

- Content BEFORE the marker can be synced from upstream
- Content AFTER the marker is project-specific and never overwritten
- If the marker is missing, sync will WARN and skip CLAUDE.md

## Version Tracking

After syncing, update `.upstream-sync.json` with the current upstream HEAD:

```bash
UPSTREAM_HEAD=$(cd ../../lucidlabs-agent-kit && git rev-parse --short HEAD)
# Update last_sync_commit and last_sync_date in .upstream-sync.json
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

## Reference

See `.claude/reference/promote-sync.md` for the full architecture documentation.
