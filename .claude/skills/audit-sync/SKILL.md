---
name: audit-sync
description: Cross-project audit and sync. Backs up, bootstraps, promotes, syncs, and verifies all downstream projects.
disable-model-invocation: true
allowed-tools: Bash, Read
argument-hint: [--dry-run] [--project <name>]
---

# Audit Sync

## Objective

Bring all downstream projects up to date with the upstream agent-kit. Runs a 5-phase workflow: Backup, Bootstrap, Promote, Sync, Verify.

## Usage

```bash
# From upstream agent-kit directory
./scripts/audit-sync.sh --dry-run        # Preview
./scripts/audit-sync.sh                   # Full audit
./scripts/audit-sync.sh --project neola   # Single project
```

## Phases

| Phase | Action |
|-------|--------|
| 1. Backup | rsync + git bundle of every project to ~/.lucidlabs-backups/ |
| 2. Bootstrap | Fix broken projects (missing sync scripts, .upstream-sync.json) |
| 3. Promote | Process promote queues from all projects (creates PRs) |
| 4. Sync | Run sync-upstream.sh --all in each project |
| 5. Verify | Check .upstream-sync.json, zone markers, scripts, promote queues |

## Pre-requisites

- Must be run from upstream agent-kit directory
- python3, rsync, git required
- gh CLI recommended (for promotion PR creation)

## Flags

| Flag | Effect |
|------|--------|
| --dry-run | Preview without changes |
| --project NAME | Process single project |
| --backup-dir PATH | Custom backup location |
| --skip-promote | Skip promote phase |
| --skip-bootstrap | Skip bootstrap phase |
| --skip-backup | Skip backup (dangerous) |
| --yes | Auto-confirm all prompts |
