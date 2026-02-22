# Plan: Fleet Audit Rollout — Alle Projekte auf Stand bringen

**Erstellt:** 2026-02-22
**Status:** PENDING
**Branch:** feat/prime-promote-audit (PR #12)

---

## Ziel

Alle 11 downstream Projekte auf den aktuellen Upstream-Stand bringen, ohne dass projektspezifische Anpassungen verloren gehen.

## Kernregel

> **Projektspezifische Dinge dürfen NIEMALS verloren gehen.**
> Vor jedem Sync: Backup erstellen, projektspezifische Dateien identifizieren und sichern.

---

## Phase 0: Vorbereitung

- [ ] PR #12 mergen (drift-detect + audit-sync)
- [ ] Upstream auf `main` zurückwechseln, pull
- [ ] `./scripts/drift-detect.sh` ausführen → Baseline-Report
- [ ] Promote Queues abarbeiten (BEVOR sync!):
  - [ ] client-service-reporting: 17 Items reviewen + promoten
  - [ ] neola: 4 Items (Format-Fix ## → ### zuerst)
  - [ ] ll-decision-briefing: 1 Item
- [ ] Promotion-PRs mergen → Upstream HEAD aktualisieren

---

## Phase 1: Projekt-für-Projekt Audit

**Reihenfolge:** Einfachste zuerst (geringste Divergenz), komplexeste zuletzt.

### Vorgehen pro Projekt

```
1. PAUSE     → Entwicklung im Projekt pausieren
2. CLONE     → Projekt klonen als Backup: cp -R project project-backup-YYYYMMDD
3. IDENTIFY  → Projektspezifische Dateien identifizieren:
               - .claude/PRD.md
               - .claude/PROJECT-CONTEXT.md
               - Prime SKILL.md (custom sections!)
               - .agents/feature-log.md
               - .agents/promote-queue.md
               - .agents/handovers/*
               - frontend/app/* (Projekt-Pages)
               - convex/* (Schema + Functions)
               - mastra/src/agents/* (Domain-Agents)
               - .env*, .env.local
               - docker-compose*.yml (Projekt-Ports)
4. BACKUP    → git bundle + rsync (via audit-sync.sh Phase 1)
5. SYNC      → ./scripts/sync-upstream.sh --all
6. VERIFY    → Diff: backup vs synced version
               → Prüfen: Alle projektspezifischen Dateien noch da?
               → Prüfen: CLAUDE.md Zone-Marker intakt?
               → Prüfen: Prime SKILL.md custom sections erhalten?
7. COMMIT    → git commit -m "chore: sync upstream agent-kit (HEAD)"
8. RESUME    → Entwicklung wieder freigeben
```

### Batch 1: Minimale Projekte (Score 7/9, wenig Custom)

| # | Projekt | Custom | Risiko | Notizen |
|---|---------|--------|--------|---------|
| 1 | prompt-eval | Keine | Niedrig | Erst bootstrappen, dann sync |
| 2 | casavi-sandbox-seeder | Keine | Niedrig | Erst bootstrappen, dann sync |
| 3 | immoware-agent-poc | Minimal | Niedrig | 1 Commit, POC |
| 4 | satellite | Minimal | Niedrig | 5 Commits, leicht |
| 5 | casavi-agent-suite | Minimal | Niedrig | 2 Commits |

### Batch 2: Mittlere Projekte (Score 8/9, moderate Custom)

| # | Projekt | Custom | Risiko | Notizen |
|---|---------|--------|--------|---------|
| 6 | invoice-accounting-assistant | PRD, Mastra Agents | Mittel | Convex Schema beachten |
| 7 | cotinga-test-suite | 15 Handover-Dateien | Mittel | Handovers sichern |
| 8 | n8n-v2-migration | Security Scan, Feature Log | Mittel | Custom Prime sections |

### Batch 3: Komplexe Projekte (Score 9/9, viel Custom)

| # | Projekt | Custom | Risiko | Notizen |
|---|---------|--------|--------|---------|
| 9 | neola | Dev Services JSON, Feature Log (10.8KB) | Hoch | Prime hat custom Dev Services section |
| 10 | ll-decision-briefing | PROJECT-CONTEXT.md | Mittel | Frisch erstellt, fast aktuell |
| 11 | client-service-reporting | 345 custom Prime lines, 17 promote items | Höchstes | Größte Divergenz, meiste Custom sections |

---

## Phase 2: Verifikation

- [ ] `./scripts/drift-detect.sh` → Alle 11 Projekte CURRENT
- [ ] `./scripts/drift-detect.sh --json > fleet-audit-result.json` → Archivieren
- [ ] Pro Projekt: Git log prüfen (sync commit vorhanden)
- [ ] Pro Projekt: Prime SKILL.md custom sections intakt
- [ ] Pro Projekt: Feature Logs, Handovers, PRDs unverändert

---

## Phase 3: Nachbereitung

- [ ] Stale Pläne in `.agents/plans/` aufräumen
- [ ] Feature Logs auf Markdown-Format standardisieren
- [ ] `.agents/` Ordnerstruktur dokumentieren:
  ```
  .agents/
  ├── audits/              # Persistente Audit-Ergebnisse (YYYY-MM-DD-kategorie-beschreibung.md)
  ├── feature-log.md       # Feature-Historie
  ├── handovers/           # Session-Handover Dateien
  ├── plans/               # Aktive Implementierungspläne
  └── promote-queue.md     # Promote-Kandidaten
  ```
- [ ] Audit Persistence Rule in `governance-rules.md` aufnehmen
- [ ] Audit Persistence Rule in `CLAUDE.md` Governance-Tabelle referenzieren
- [ ] Context Guard Hook als upstream Pattern etablieren
- [ ] Context Check nach git commit als Regel in CLAUDE.md
- [ ] Compound Engineering starten

---

## Neue Governance Regeln (in diesem Audit einführen)

### Audit Persistence Rule
Jeder Audit MUSS als Datei in `.agents/audits/` gespeichert werden.
Kategorien: workflow-dependency, security, code, model, infrastructure, performance
Format: `YYYY-MM-DD-<kategorie>-<beschreibung>.md`

### Context Check nach Git Commits
Nach jedem `git commit` Context-Window-Status prüfen.
Bei <10%: Sofort Handover-Datei erstellen.

---

## Projektspezifische Dateien — Checkliste

Diese Dateien/Ordner MÜSSEN nach dem Sync unverändert sein:

| Pfad | Typ | Schutz |
|------|-----|--------|
| `.claude/PRD.md` | Projekt-Requirements | Nicht syncbar (Blacklist) |
| `.claude/PROJECT-CONTEXT.md` | Projekt-Kontext | Nicht syncbar |
| `.claude/skills/prime/SKILL.md` | Prime (custom sections) | Zone-Marker prüfen! |
| `.agents/feature-log.md` | Feature-Historie | Nicht syncbar |
| `.agents/handovers/*` | Session-Handovers | Nicht syncbar |
| `.agents/promote-queue.md` | Promote-Kandidaten | Nicht syncbar |
| `frontend/app/*` | Projekt-Pages | Nicht syncbar (Blacklist) |
| `convex/*` | Schema + Functions | Nicht syncbar (Blacklist) |
| `mastra/src/agents/*` | Domain-Agents | Nicht syncbar (Blacklist) |
| `.env*` | Secrets | Nicht syncbar (Blacklist) |
| `docker-compose*.yml` | Projekt-Ports | Nicht syncbar |
| `.linear-config` | Linear Setup | Nicht syncbar |

**ACHTUNG Prime SKILL.md:** Hat KEINEN Zone-Marker → wird komplett überschrieben beim Sync!
→ VOR dem Sync: Custom sections sichern, NACH dem Sync: wieder einfügen.
→ Langfristig: Zone-Marker auch für Prime einführen (Prio 2 Feature).

---

## Risiko-Matrix

| Risiko | Mitigation |
|--------|------------|
| Projektspezifische Prime sections verloren | Backup + manuelle Prüfung |
| CLAUDE.md Zone-Marker fehlt | Sync-Script warnt und skippt |
| Merge-Konflikte | Projekt ist pausiert → keine parallelen Änderungen |
| Convex Schema überschrieben | Blacklist in sync-upstream.sh verhindert das |
| Feature Log gelöscht | Nicht in SYNCABLE_PATHS → wird nicht angefasst |
| Git History verloren | git bundle als Backup |

---

## Zeitschätzung

- Batch 1 (5 einfache): ~30min
- Batch 2 (3 mittlere): ~45min
- Batch 3 (3 komplexe): ~60min
- Verifikation: ~15min
- **Gesamt: ~2.5h**
