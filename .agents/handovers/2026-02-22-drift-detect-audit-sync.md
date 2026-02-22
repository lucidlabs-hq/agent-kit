# Session Handover: Drift Detection + Audit-Sync

**Date:** 2026-02-22
**Branch:** `feat/prime-promote-audit`
**Last Commit:** `81fb44f` — feat: add drift detection + audit-sync for cross-project fleet management

---

## Status: Was wurde erledigt

### 1. Drift Detection (DONE)
- `scripts/drift-detect.sh` erstellt und getestet
- Zeigt per-project: commits behind, days, files changed, infra score, promote queue
- Flags: `--json`, `--quiet`, `--project <name>`
- Auto-detect upstream vs downstream context
- In `/prime` SKILL.md als Section 0.0.3 integriert

### 2. Audit-Sync Orchestrierung (DONE)
- `scripts/audit-sync.sh` erstellt und dry-run getestet
- 5 Phasen: Backup → Bootstrap → Promote → Sync → Verify
- Backup: rsync + git bundle + manifest.json
- Flags: `--dry-run`, `--project`, `--skip-promote`, `--yes`

### 3. Bug Fixes (DONE)
- `.DS_Store` / `Thumbs.db` / `.swp` Filterung in `sync-upstream.sh` (2 find-Kommandos)
- `.DS_Store` Filterung in `promote.sh` (1 find-Kommando)
- `is_blacklisted()` in `promote.sh`: Overly broad substring matching → prefix + basename matching

### 4. Documentation (DONE)
- `/prime` SKILL.md: Section 0.0.3 Fleet Drift Overview
- `.claude/skills/audit-sync/SKILL.md`: Neuer Skill
- `.claude/reference/promote-sync.md`: Drift + Audit Sections
- `credentials.example.json`: Template (leere Werte)
- `.gitignore` + `.claude/settings.json`: Credential-Schutz

---

## Status: Was noch OFFEN ist

### PRIORITÄT 1: PR mergen + Audit durchführen
1. Branch `feat/prime-promote-audit` pushen und PR erstellen
2. PR reviewen und mergen
3. `./scripts/audit-sync.sh --dry-run` ausführen (Preview)
4. Promote Queues abarbeiten:
   - client-service-reporting: 17 Items (größte Queue)
   - neola: 4 Items (Format-Fix nötig: `##` statt `###`)
   - ll-decision-briefing: 1 Item
5. `./scripts/audit-sync.sh` ausführen (alle 11 Projekte syncen)

### PRIORITÄT 2: Prime Skill Flexibilität
- Prime SKILL.md ist über Projekte stark divergiert (1022-1853 Zeilen)
- Upstream hat 1508 Zeilen, client-service-reporting hat 1853 (+345 custom)
- **Lösung konzipieren:** Zone-Marker auch für Prime (upstream-base + project-specific)
- Wertvolle project-spezifische Sections:
  - `0.1.3 Service Boot` (client-service-reporting)
  - `0.1.4 Credentials & Logins` (client-service-reporting)
  - `0.1.0a Dev Services starten` (neola)
  - `0.1.0c Repository Security Scan` (n8n-v2-migration, client-service-reporting)
  - `0.0.8 Session Handover Resume` (client-service-reporting)

### PRIORITÄT 3: Feature Log → Markdown + Ordnerstruktur
- Aktuell existieren `feature-log.md` in 3 Projekten (neola 10.8KB, n8n 4.7KB, csr 4.6KB)
- **Idee:** `.agents/` Ordnerstruktur standardisieren:
  ```
  .agents/
  ├── feature-log.md          # Feature-Historie
  ├── handovers/              # Session-Handover Dateien
  │   └── YYYY-MM-DD-*.md
  ├── promote-queue.md        # Promote-Kandidaten
  └── plans/                  # Aktive Implementierungspläne
  ```
- Session Handover nur in cotinga-test-suite aktiv genutzt (15 Dateien)
- Andere Projekte haben leere `handovers/` Ordner

### PRIORITÄT 4: Context Guard Hook
- In client-service-reporting wurde ein `context-guard.sh` Hook angefangen
- Prüft Transcript-Größe nach jeder Claude-Antwort
- Triggert automatisch Handover bei 10% verbleibend
- Events: `Stop` + `PreCompact`
- **TODO:** Upstream-fähig machen und in alle Projekte syncen

### PRIORITÄT 5: Dev-Umgebung Quick Commands in /prime
- Übersicht aller Start/Stop Befehle im Boot Screen anzeigen
- Pro Projekt: Frontend, Convex, Mastra, n8n Services
- **TODO:** In Prime SKILL.md als Section einbauen

---

## Drift-Report (Stand 2026-02-22)

```
PROJECT                     SYNC AT    BEHIND  DAYS  SCORE  PROMOTE
ll-decision-briefing        c406085         0     0   9/9        1
client-service-reporting    7dbf253         8    11   9/9       17
cotinga-test-suite          7dbf253         8    11   8/9        0
n8n-v2-migration            7dbf253         8    11   8/9        0
invoice-accounting-assistant 7dbf253        8    11   8/9        0
neola                       7dbf253         8    11   8/9        4*
immoware-agent-poc          7dbf253         8    11   8/9        0
casavi-agent-suite          7dbf253         8    11   7/9        0
satellite                   7dbf253         8    11   7/9        0
casavi-sandbox-seeder       BROKEN        ---   ---   4/9        0
prompt-eval                 BROKEN        ---   ---   4/9        0
```
*neola: 4 Items, aber anderes Format (## statt ###)

---

## Relevante Dateien

| Datei | Beschreibung |
|-------|-------------|
| `scripts/drift-detect.sh` | Cross-Project Drift Detection |
| `scripts/audit-sync.sh` | Fleet Audit & Sync Orchestrierung |
| `scripts/sync-upstream.sh` | Upstream → Downstream Sync (Bug Fixes) |
| `scripts/promote.sh` | Downstream → Upstream Promote (Bug Fixes) |
| `.claude/skills/audit-sync/SKILL.md` | Audit-Sync Skill |
| `.claude/skills/prime/SKILL.md` | Prime mit 0.0.3 Fleet Drift |
| `.claude/reference/promote-sync.md` | Referenz-Doku (aktualisiert) |
| `.agents/plans/` | 7 aktive Pläne (siehe Roadmap unten) |

## Aktive Pläne

| Plan | Thema |
|------|-------|
| `2026-02-17-1600-claude-md-router-quality-gates` | CLAUDE.md Router + Quality Gates |
| `2026-02-17-deploy-automation-and-sync` | Deploy Automation |
| `2026-02-18-next-steps-security-quality` | Security + Quality |
| `2026-02-19-compound-engineering-adoption` | Compound Engineering |
| `2026-02-19-upstream-downstream-sync` | Sync-Architektur |
| `betterauth-org-plugin-and-roles` | Auth Plugin |
| `integrate-task-system-and-swarm` | Task System |

---

## Nächste Session: Empfohlener Start

1. `/prime` → Drift Overview wird jetzt automatisch angezeigt
2. PR `feat/prime-promote-audit` pushen + mergen
3. Promote Queues abarbeiten (client-service-reporting zuerst)
4. `./scripts/audit-sync.sh` ausführen
5. Dann: Compound Engineering beginnen

---

## Neue Regeln (für upstream CLAUDE.md / reference)

### Context Guard nach Git Commits

**Regel:** Nach jedem `git commit` MUSS der Agent den Context-Window-Status prüfen.

| Schwelle | Aktion |
|----------|--------|
| >30% verbleibend | Weiterarbeiten |
| 10-30% verbleibend | Warnung anzeigen, Handover-Datei vorbereiten |
| <10% verbleibend | STOP — sofort Handover-Datei erstellen und Session beenden |

**Begründung:** Ein Commit markiert typischerweise den Abschluss einer Arbeitseinheit. Das ist der ideale Zeitpunkt, den Context-Status zu prüfen und ggf. eine saubere Übergabe vorzubereiten, bevor der Kontext verloren geht.

**Implementation:** Als Regel in CLAUDE.md + als Hook in `.claude/settings.json` (PostToolUse auf Bash mit git commit pattern).

### Audit Persistence Rule

**Regel:** Jeder Audit (Dependency-Analyse, Security-Scan, Code-Audit, Model-Audit, etc.) MUSS als Datei in `.agents/audits/` gespeichert werden.

```
.agents/audits/
  YYYY-MM-DD-<kategorie>-<beschreibung>.md
```

**Kategorien:** workflow-dependency, security, code, model, infrastructure, performance

**Regeln:**
1. IMMER als Datei speichern, nie nur im Chat anzeigen
2. Datum im Dateinamen (Chronologie)
3. Kategorie im Dateinamen (Filterung)
4. Audit enthält: Datum, Kontext, Ergebnis-Zusammenfassung, Detail-Daten
5. Beim nächsten `/prime` werden aktuelle Audits referenziert

**Why:** Audits dauern 5-15 Minuten Agent-Arbeit. Ohne Persistenz muss bei jeder Session wiederholt werden.

**TODO für upstream:**
- `.claude/reference/governance-rules.md` — als neue Governance Rule
- `CLAUDE.md` — Kurzreferenz in Governance-Tabelle
- `.agents/audits/` — Ordner im Template (done)
