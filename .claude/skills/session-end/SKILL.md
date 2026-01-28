---
name: session-end
description: End development session cleanly. Updates Linear tickets, checks Git compliance, ensures clean state for next session.
allowed-tools: Bash, Read, Write
---

# Session End

Clean up and sync state before ending a development session.

## Why Session End?

1. **Linear Visibility** - Team knows current status
2. **Clean State** - Next session can resume easily
3. **Compliance Check** - Catch issues before they accumulate
4. **Reporting** - Enable progress tracking and analytics

---

## Session End Checklist

```
┌─────────────────────────────────────────────────────────────────┐
│                     SESSION END CHECKLIST                        │
├─────────────────────────────────────────────────────────────────┤
│  [ ] 1. Git Status Clean                                        │
│  [ ] 2. Linear Ticket Updated                                   │
│  [ ] 3. Work Summary Added                                      │
│  [ ] 4. PROJECT-STATUS.md Updated                               │
│  [ ] 5. No Uncommitted Changes (or WIP commit)                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Process

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
