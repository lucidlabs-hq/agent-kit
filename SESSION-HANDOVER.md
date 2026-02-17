# Session Handover — 2026-02-17 (Session 3)

> **Branch:** `feat/agent-kit-cleanup`
> **PR:** https://github.com/lucidlabs-hq/agent-kit/pull/7 (approved, not yet merged)
> **Context:** 5% remaining — handover for next session

---

## Current State

PR #7 is approved but has **5 Greptile review findings** that should be fixed before merge.

---

## TODO: Fix Greptile Findings (Priority Order)

### Fix 1: Rollback in deploy-hq.yml is non-functional (HIGH)
**File:** `.github/workflow-templates/deploy-hq.yml` ~line 269
**Problem:** Rollback step captures `PREV_IMAGE` but never uses it. `rsync --delete` already replaced source files, and `docker image prune` removed old images. Running `docker compose up -d` just rebuilds the same broken code.
**Fix:** Before rsync, back up current source to a versioned directory. On rollback, restore from backup and rebuild. Example:
```bash
# Before rsync: backup current
ssh nightwing@host "cp -a /opt/lucidlabs/projects/$PROJECT/.deploy-backup || true"
# On rollback: restore backup
ssh nightwing@host "cp -a /opt/lucidlabs/projects/$PROJECT/.deploy-backup/. /opt/lucidlabs/projects/$PROJECT/ && docker compose up -d --build"
```

### Fix 2: `echo` can corrupt file content in sync (MEDIUM)
**File:** `scripts/sync-upstream.sh` ~line 212
**Problem:** `echo "$var"` interprets `-e`/`-n` as flags and adds extra newlines.
**Fix:** Replace with `printf '%s\n'`:
```bash
{
    printf '%s\n' "$upstream_before_marker"
    printf '%s\n' "$downstream_tail"
} > "$downstream_file"
```

### Fix 3: Upstream check blocks when local is ahead (MEDIUM)
**File:** `scripts/promote.sh` ~line 638
**Problem:** `LOCAL_HEAD != REMOTE_HEAD` blocks in both directions. Should only block when remote is ahead.
**Fix:** Use directional check:
```bash
BEHIND_COUNT=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
if [[ "$BEHIND_COUNT" -gt 0 ]]; then
```

### Fix 4: Dead variables in sync-upstream.sh (LOW)
**File:** `scripts/sync-upstream.sh` lines 139, 196
**Problem:** `upstream_content` and `UPSTREAM_HEAD_FULL` assigned but never used.
**Fix:** Remove both dead variables.

### Fix 5: secrets not accessible in GitHub Actions `if` (MEDIUM)
**File:** `.github/workflow-templates/deploy-hq.yml` ~line 275
**Problem:** `secrets` context not reliably available in step `if` conditions.
**Fix:** Change to `if: always()` and check inside the `run` block:
```bash
if [ -z "$SLACK_WEBHOOK_URL" ]; then echo "No webhook, skipping"; exit 0; fi
```

---

## TODO: After Greptile Fixes

1. **Push fixes** to `feat/agent-kit-cleanup`
2. **Merge PR #7** (squash and merge)
3. **Pattern Registry** — planen und implementieren
   - Use-Case Labels bei Promotions
   - Suchbar bei neuem PRD
   - Integration in `/promote` Flow

---

## NEW RULE for Promote Queue

**Context Window Management Rule:**
> Bei 5% verbleibendem Kontextfenster MUSS eine SESSION-HANDOVER.md erstellt werden.
> Kein weiterer Code wird geschrieben. Stattdessen: aktuellen Stand dokumentieren,
> offene TODOs auflisten, und die naechste Session vorbereiten.

This should be added to `.claude/reference/session-rules.md` as a mandatory rule.

---

## Files That Need Changes

| File | Fixes |
|------|-------|
| `.github/workflow-templates/deploy-hq.yml` | #1 (rollback), #5 (slack if) |
| `scripts/sync-upstream.sh` | #2 (printf), #4 (dead vars) |
| `scripts/promote.sh` | #3 (directional check) |

---

## How to Continue

```bash
cd /Users/adamkassama/Documents/coding/repos/lucidlabs/lucidlabs-agent-kit
claude

# Tell Claude:
"Lies SESSION-HANDOVER.md. Fixe die 5 Greptile Findings auf feat/agent-kit-cleanup,
push, dann merge PR #7. Danach Pattern Registry."
```
