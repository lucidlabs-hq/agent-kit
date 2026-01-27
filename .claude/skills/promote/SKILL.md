---
name: promote
description: Promote generic patterns from this project back to the upstream agent-kit. Use when you have reusable patterns to share.
disable-model-invocation: true
allowed-tools: Bash, Read
argument-hint: [--upstream <path>]
---

# Promote Patterns to Upstream

Promote generic, reusable patterns from this downstream project back to the upstream agent-kit template.

## Quick Start

```bash
# Run promotion script
./scripts/promote.sh --upstream ~/templates/agent-kit

# Preview only (dry run)
./scripts/promote.sh --upstream ~/templates/agent-kit --dry-run
```

## What Gets Promoted

| Promotable | Description |
|------------|-------------|
| `.claude/skills/*` | Claude Code skills |
| `.claude/reference/*` | Best practice documentation |
| `frontend/components/ui/*` | Generic UI components |
| `frontend/lib/utils.ts` | Utility functions |
| `frontend/lib/hooks/*` | Generic React hooks |
| `scripts/*` | Utility scripts |

## What Does NOT Get Promoted

| Blacklisted | Reason |
|-------------|--------|
| `.claude/PRD.md` | Project-specific requirements |
| `frontend/app/*` | Project-specific pages |
| `mastra/src/agents/*` | Domain-specific agents |
| `convex/*` | Project-specific database |

## Promotion Flow

1. **DETECT** - Script finds new/modified files in promotable paths
2. **SELECT** - You choose which changes to promote
3. **REVIEW** - See diffs and confirm
4. **PROMOTE** - Files copied, branch created, PR optional

## Domain Keyword Warning

The script warns if files contain domain-specific keywords like:
- `ticket`, `customer`, `invoice`, `order`
- `product`, `user`, `account`, `payment`

These indicate the code may not be generic enough for the template.

## Options

| Option | Description |
|--------|-------------|
| `--upstream PATH` | Path to agent-kit (required) |
| `--dry-run` | Preview without changes |
| `--all` | Promote all without selection |
| `--help` | Show help |

## Example Session

```
╔════════════════════════════════════════════════════════════════╗
║              PATTERN PROMOTION                                 ║
╚════════════════════════════════════════════════════════════════╝

ℹ Downstream: /Users/dev/projects/my-project
ℹ Upstream:   /Users/dev/templates/agent-kit

▶ Scanning for promotable changes...

Promotable changes found:

  [1] .claude/skills/code-review/SKILL.md (NEW)
  [2] .claude/reference/api-patterns.md (NEW)
  [3] frontend/components/ui/data-table.tsx (MODIFIED)

Enter numbers to promote (e.g., 1,2 or 'all'): 1,2

▶ Creating branch: promote/20260127-from-my-project
✔ Copied: .claude/skills/code-review/SKILL.md
✔ Copied: .claude/reference/api-patterns.md
✔ Committed 2 files

Create GitHub PR? [Y/n] y
✔ PR created: https://github.com/lucidlabs/agent-kit/pull/42
```

## Best Practices

1. **Review before promoting** - Ensure code is truly generic
2. **Remove domain references** - Clean up project-specific names
3. **Test in isolation** - Verify patterns work without project context
4. **Document changes** - Add comments explaining the pattern
5. **Small promotions** - Promote one pattern at a time for easier review
