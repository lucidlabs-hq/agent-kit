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

**Session-Zusammenfassung anzeigen (KOMPAKT):**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  SESSION BEENDET                                              [project-name]    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  BEARBEITETE TICKETS                              ZEIT: 3h 30min               │
│  ───────────────────────────────────────────────────────────────────────────── │
│  ✓ CUS-42   Login Feature implementieren          Delivery      2h 15min       │
│  ◐ CUS-45   Error Handling verbessern            In Progress    1h 15min       │
│                                                                                 │
│  COMMITS (4)                                                                    │
│  ───────────────────────────────────────────────────────────────────────────── │
│  abc1234  feat(auth): implement login flow                                      │
│  def5678  fix(api): handle edge cases                                           │
│  ghi9012  feat(prime): add ASCII banner                                         │
│  jkl3456  docs: update time tracking                                            │
│                                                                                 │
│  BUDGET: ████████████████████░░░░░░░░░░░░░░░░░░░░░ 48% (48h/100h)              │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Wichtig:** Diese Zusammenfassung ist bewusst KOMPAKT gehalten. Details werden in Report-Datei gespeichert.

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

## 6. Improvement Analyzer (VOR Checkout!)

**WICHTIG:** Dieser Schritt analysiert die Session und gibt dem Entwickler konkrete Verbesserungsvorschläge.

### 6.1 Session-Analyse durchführen

Analysiere während der Session:
- Wie oft musste Claude nachfragen?
- Welche Informationen fehlten?
- Welche Anweisungen waren unklar?
- Wie effizient war die Zusammenarbeit?

### 6.2 Kompakte Ausgabe (im Terminal)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  IMPROVEMENT ANALYZER                                                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  SESSION SCORE: ████████░░ 78/100                                              │
│                                                                                 │
│  TOP 3 VERBESSERUNGEN FÜR NÄCHSTE SESSION:                                     │
│  ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                 │
│  1. ⚡ Mehr Kontext bei Feature-Requests                                        │
│     → Nächstes Mal: "Kontext: [Situation], Problem: [X], Ziel: [Y]"            │
│                                                                                 │
│  2. 📋 Akzeptanzkriterien definieren                                           │
│     → Nächstes Mal: Was muss funktionieren, damit Feature "fertig" ist?        │
│                                                                                 │
│  3. 🎯 Scope klar eingrenzen                                                   │
│     → Nächstes Mal: "Nur X, nicht Y" explizit angeben                          │
│                                                                                 │
│  ─────────────────────────────────────────────────────────────────────────────  │
│  📄 Vollständiger Report: ~/.claude-time/reports/[project]-[date].md           │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 6.3 Vollständiger Report (in Datei)

Speichere detaillierten Report in `~/.claude-time/reports/[project]-YYYY-MM-DD.md`:

```markdown
# Session Report: [project-name]
**Datum:** 2026-01-28
**Dauer:** 3h 30min
**Entwickler:** Adam

---

## Bearbeitete Tickets

| Ticket | Titel | Status | Zeit |
|--------|-------|--------|------|
| CUS-42 | Login Feature | ✓ Erledigt | 2h 15min |
| CUS-45 | Error Handling | ◐ In Progress | 1h 15min |

---

## Commits

- `abc1234` feat(auth): implement login flow
- `def5678` fix(api): handle edge cases
- `ghi9012` feat(prime): add ASCII banner
- `jkl3456` docs: update time tracking

---

## Improvement Patterns Analyzer

### Top Recurring Issues (diese Session)

| Pattern | Häufigkeit | Zeit-Impact |
|---------|------------|-------------|
| Missing Context | 3x | ~15min |
| Vage Anforderungen | 2x | ~10min |
| Fehlende Beispiele | 1x | ~5min |

### Detaillierte Analyse

#### 1. Missing Context (3x gefunden)

**Was passiert ist:**
- Anfrage ohne Hintergrund-Information
- Claude musste Rückfragen stellen

**Beispiele aus dieser Session:**
- ❌ "Mach das Feature fertig"
- ❌ "Fix den Bug"

**Besser nächstes Mal:**
```
✅ "Kontext: [aktuelle Situation]
   Problem: [konkretes Problem]
   Ziel: [gewünschtes Ergebnis]
   Einschränkungen: [falls vorhanden]"
```

**Geschätzter Zeitgewinn:** ~5min pro Anfrage

---

#### 2. Vage Anforderungen (2x gefunden)

**Was passiert ist:**
- Anforderungen waren interpretierbar
- Mehrere Implementierungen wären möglich gewesen

**Beispiele aus dieser Session:**
- ❌ "Mach die UI besser"
- ❌ "Optimiere das"

**Besser nächstes Mal:**
```
✅ "Ändere den Button von grau auf blau"
✅ "Reduziere die Ladezeit von 3s auf unter 1s"
```

**Geschätzter Zeitgewinn:** ~5min pro Anfrage

---

## Session-Metriken

| Metrik | Wert | Benchmark |
|--------|------|-----------|
| Nachfragen von Claude | 4 | < 2 ideal |
| Scope-Änderungen | 1 | 0 ideal |
| Rework nötig | 0 | 0 ideal |
| Effizienz-Score | 78% | > 85% ideal |

---

## Empfohlene Templates

### Feature Request Template
```
Kontext: [Was ist die aktuelle Situation?]
Problem: [Was funktioniert nicht / fehlt?]
Ziel: [Was soll am Ende rauskommen?]
Akzeptanzkriterien:
- [ ] Kriterium 1
- [ ] Kriterium 2
Einschränkungen: [Was soll NICHT gemacht werden?]
```

### Bug Report Template
```
Erwartetes Verhalten: [Was sollte passieren?]
Aktuelles Verhalten: [Was passiert stattdessen?]
Reproduktion: [Schritte zum Reproduzieren]
Relevanter Code: [Datei:Zeile oder Snippet]
```

---

*Report generiert: 2026-01-28 17:30*
```

### 6.4 Pattern-Tracking über Zeit

Die Improvement Patterns werden in `~/.claude-time/patterns/[project].json` aggregiert:

```json
{
  "project": "customer-portal",
  "patterns": {
    "missing_context": {
      "total_occurrences": 34,
      "sessions_affected": 12,
      "trend": "improving",
      "last_30_days": 8
    },
    "vague_requirements": {
      "total_occurrences": 26,
      "sessions_affected": 10,
      "trend": "stable",
      "last_30_days": 6
    }
  },
  "overall_score_trend": [72, 75, 78, 80, 78]
}
```

### 6.5 Was wird analysiert?

| Pattern | Erkennung |
|---------|-----------|
| **Missing Context** | Claude fragt "Was meinst du mit...?" oder "Kannst du mehr Kontext geben?" |
| **Vage Anforderungen** | Mehrere Interpretationen möglich, Claude fragt nach Präferenz |
| **Fehlende Beispiele** | Claude fragt "Hast du ein Beispiel?" |
| **Scope Creep** | Anforderungen ändern sich während Implementierung |
| **Fehlende Akzeptanzkriterien** | Unklar wann Feature "fertig" ist |

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
