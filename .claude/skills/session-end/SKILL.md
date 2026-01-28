---
name: session-end
description: End development session cleanly. Updates Linear tickets, checks Git compliance, ensures clean state for next session.
allowed-tools: Bash, Read, Write
---

# Session End

Clean up and sync state before ending a development session.

## Why Session End?

1. **Time Tracking** - Session-Dauer wird gespeichert
2. **Linear Visibility** - Team knows current status
3. **Clean State** - Next session can resume easily
4. **Compliance Check** - Catch issues before they accumulate
5. **Reporting** - Enable progress tracking and analytics

---

## Session End Checklist

```
┌─────────────────────────────────────────────────────────────────┐
│                     SESSION END CHECKLIST                        │
├─────────────────────────────────────────────────────────────────┤
│  [ ] 0. Time Tracking - Session gespeichert                     │
│  [ ] 1. Git Status Clean                                        │
│  [ ] 2. Linear Ticket Updated                                   │
│  [ ] 3. Work Summary Added                                      │
│  [ ] 4. PROJECT-STATUS.md Updated                               │
│  [ ] 5. No Uncommitted Changes (or WIP commit)                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Process

### 0. Time Tracking - Session speichern (ZUERST!)

**Session-Dauer berechnen und speichern:**

```bash
TIME_DIR="$HOME/.claude-time"
PROJECT_NAME=$(basename "$(pwd)")
SESSION_FILE="$TIME_DIR/sessions/$PROJECT_NAME.json"
CURRENT_SESSION="$TIME_DIR/current-session.txt"

# Lies Session-Startzeit
if [ -f "$CURRENT_SESSION" ]; then
  START_TIME=$(grep "Session gestartet:" "$CURRENT_SESSION" | head -1 | cut -d: -f2-)
fi
```

**Session-Zusammenfassung anzeigen:**

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   🕐 SESSION BEENDET                                       [project-name]    ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Diese Session:                                                              ║
║   ──────────────                                                              ║
║                                                                               ║
║   Start:      14:00 Uhr                                                       ║
║   Ende:       17:30 Uhr                                                       ║
║   Dauer:      3h 30min                                                        ║
║                                                                               ║
║   Linear:     CUS-42 (Delivery)                                               ║
║   Commits:    3 (abc1234, def5678, ghi9012)                                  ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Projekt-Gesamt:   28h 00min (+3h 30min heute)                              ║
║                                                                               ║
║   ████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 48%       ║
║   Budget: 100h │ Verbraucht: 48h │ Verbleibend: 52h                          ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

**Session-Daten speichern:**

Die Session wird in `~/.claude-time/sessions/[project].json` gespeichert:

```json
{
  "sessions": [
    {
      "date": "2026-01-28",
      "start": "14:00",
      "end": "17:30",
      "duration_minutes": 210,
      "linear_issue": "CUS-42",
      "commits": ["abc1234", "def5678", "ghi9012"],
      "synced_to_productive": false
    }
  ]
}
```

**Frage nach Productive.io Sync:**

```
Soll ich die Session zu Productive.io synchronisieren? [Y/n]

→ JA: /time-sync wird ausgeführt
→ NEIN: Session bleibt als "pending" markiert
```

---

### 1. Check Git Status

```bash
# Show current branch and status
git branch --show-current
git status --short

# Check for uncommitted changes
git diff --stat
```

**If uncommitted changes exist:**
- Ask: "Soll ich die Änderungen committen oder als WIP markieren?"
- Option A: Create proper commit with `/commit`
- Option B: Create WIP commit: `git commit -am "WIP: [description]"`

### 2. Verify Last Commit Compliance

```bash
# Show last commit
git log -1 --oneline

# Check commit message format
git log -1 --format="%s"
```

**Verify:**
- [ ] Conventional commit format (`feat:`, `fix:`, `docs:`, etc.)
- [ ] No AI attribution (no Co-Authored-By)
- [ ] Descriptive message

### 3. Run Quick Validation

```bash
cd frontend && pnpm run validate
```

**If validation fails:**
- Report issues but don't block
- Add to Linear ticket as blocker for next session

### 4. Update Linear Ticket

Query current active issue and update:

```
Use Linear MCP:
1. Get current issue (from PROJECT-STATUS.md or ask)
2. Update status if needed:
   - Still in Exploration? Stay there
   - Exploration complete? → Decision
   - Implementing? → Delivery
   - Ready for review? → Review
3. Add comment with work summary
```

**Comment Format:**
```markdown
## Session Update - [Date]

### Completed
- [What was done]

### Next Steps
- [What needs to happen next]

### Blockers (if any)
- [Any issues blocking progress]
```

### 5. Update PROJECT-STATUS.md

```markdown
# Project Status

**Last Updated:** [timestamp]
**Linear Issue:** [ABC-123]
**Status:** [Current status]

## Last Session
- [Summary of work done]

## Next Session
- [What to pick up]

## Active Plan
- File: `.agents/plans/[plan].md`
- Progress: [X/Y tasks]
```

---

## Output Report

```markdown
## Session End Report

### Git Status
- Branch: `feature/xyz`
- Last Commit: `abc1234 feat: implement feature`
- Working Tree: Clean ✓

### Validation
- TypeScript: ✓
- ESLint: ✓
- Build: [not run / ✓]

### Linear
- Issue: ABC-123
- Status: Exploration → Delivery
- Comment: Added work summary

### Ready for Next Session
- PROJECT-STATUS.md updated
- Linear ticket current
- No pending changes

**Quick Resume:** [One sentence for next session]
```

---

## Automatic Triggers

Consider running `/session-end` when:
- User says "bye", "fertig", "Feierabend"
- Before switching to different project
- After completing a feature
- End of day

---

## Skip Session End

If skipping (e.g., quick break):
```
⚠️ Skipping session-end. Remember to run it before long breaks!
```

---

## Integration with session-closer Agent

This skill invokes the `session-closer` agent for:
- Git compliance verification
- Automated ticket updates
- Comprehensive status reporting

The agent runs automatically when `/session-end` is called.
