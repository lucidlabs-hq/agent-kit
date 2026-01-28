# Time Tracking Konzept für Claude Code Sessions

> **Status:** Konzept
> **Ziel:** Automatisches Tracking der Entwicklungszeit pro Session, Entwickler und Projekt

---

## Problem

Wir brauchen eine Möglichkeit zu wissen:
1. Wie viel Zeit jeder Entwickler in Claude Sessions verbracht hat
2. Wie viel Zeit insgesamt an einem Projekt gearbeitet wurde
3. Diese Daten für Productive.io Zeiterfassung nutzen
4. Kunden-Kontingente überwachen (Product as Service)

---

## Lösung: Lokales Time Tracking

### Architektur

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           TIME TRACKING ARCHITEKTUR                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                        ENTWICKLER WORKSTATION                            │   │
│   │                                                                          │   │
│   │   ┌─────────────────┐         ┌─────────────────────────────────────┐   │   │
│   │   │  Claude Session │────────▶│  ~/.claude-time/                     │   │   │
│   │   │                 │         │                                      │   │   │
│   │   │  /session-start │         │  sessions/                           │   │   │
│   │   │  ... Arbeit ... │         │  └── 2026-01-28-customer-portal.json │   │   │
│   │   │  /session-end   │         │                                      │   │   │
│   │   └─────────────────┘         │  developer.json  (Name, Email)       │   │   │
│   │                               │                                      │   │   │
│   │                               └─────────────────────────────────────┘   │   │
│   │                                              │                           │   │
│   │                                              │ /time-sync (optional)     │   │
│   │                                              ▼                           │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                                  │                               │
│                                                  │ HTTPS API                     │
│                                                  ▼                               │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                         PRODUCTIVE.IO                                    │   │
│   │                                                                          │   │
│   │   POST /time_entries                                                     │   │
│   │   {                                                                      │   │
│   │     "person_id": "...",                                                  │   │
│   │     "service_id": "...",   ← Delivery Unit                               │   │
│   │     "date": "2026-01-28",                                                │   │
│   │     "time": 180,           ← Minuten                                     │   │
│   │     "note": "Claude Session: Feature X implementiert"                    │   │
│   │   }                                                                      │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Implementierung

### 1. Lokales Tracking (Automatisch)

**Session-Datei:** `~/.claude-time/sessions/YYYY-MM-DD-project-name.json`

```json
{
  "project": "customer-portal",
  "developer": "max.mustermann@lucidlabs.de",
  "date": "2026-01-28",
  "sessions": [
    {
      "id": "abc123",
      "start": "2026-01-28T09:15:00Z",
      "end": "2026-01-28T11:45:00Z",
      "duration_minutes": 150,
      "linear_issue": "CUS-42",
      "activities": [
        { "type": "planning", "description": "/plan-feature login" },
        { "type": "implementation", "description": "/execute" },
        { "type": "validation", "description": "/validate" }
      ],
      "commits": ["abc1234", "def5678"],
      "synced_to_productive": false
    },
    {
      "id": "def456",
      "start": "2026-01-28T14:00:00Z",
      "end": "2026-01-28T16:30:00Z",
      "duration_minutes": 150,
      "linear_issue": "CUS-43",
      "activities": [...],
      "synced_to_productive": false
    }
  ],
  "total_minutes": 300
}
```

### 2. Entwickler-Konfiguration

**Datei:** `~/.claude-time/developer.json`

```json
{
  "name": "Max Mustermann",
  "email": "max.mustermann@lucidlabs.de",
  "productive_person_id": "12345",
  "default_activity_type": "Development"
}
```

### 3. Projekt-Mapping

**Datei:** `~/.claude-time/project-mapping.json`

```json
{
  "customer-portal": {
    "productive_project_id": "67890",
    "productive_service_id": "11111",
    "linear_team": "CUS",
    "customer": "Acme Corp",
    "budget_hours": 100,
    "hourly_rate": 150
  },
  "internal-dashboard": {
    "productive_project_id": "99999",
    "productive_service_id": "22222",
    "linear_team": "INT",
    "customer": "Internal",
    "budget_hours": null,
    "hourly_rate": null
  }
}
```

---

## Skills / Hooks

### Hook: Session Start (automatisch)

```typescript
// .claude/hooks/session-start.ts
// Wird bei jedem Claude Start ausgeführt

export async function onSessionStart() {
  const session = {
    id: crypto.randomUUID(),
    start: new Date().toISOString(),
    project: getProjectName(), // aus package.json oder Ordnername
  };

  await saveSession(session);
  return session;
}
```

### Hook: Session End

```typescript
// .claude/hooks/session-end.ts
// Wird bei /session-end ausgeführt

export async function onSessionEnd(sessionId: string) {
  const session = await loadSession(sessionId);

  session.end = new Date().toISOString();
  session.duration_minutes = calculateDuration(session.start, session.end);

  // Sammle Aktivitäten aus der Session
  session.activities = await collectActivities();
  session.commits = await getSessionCommits();
  session.linear_issue = await getCurrentLinearIssue();

  await saveSession(session);

  // Zusammenfassung anzeigen
  return {
    duration: session.duration_minutes,
    activities: session.activities.length,
    commits: session.commits.length,
  };
}
```

### Skill: /time-report

```
/time-report [project] [zeitraum]

Beispiele:
/time-report customer-portal today
/time-report customer-portal week
/time-report customer-portal 2026-01
```

**Output:**

```
┌─────────────────────────────────────────────────────────────────┐
│  TIME REPORT: customer-portal                                    │
│  Zeitraum: 2026-01-28                                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Entwickler        Sessions    Zeit        Linear Issues         │
│  ─────────────────────────────────────────────────────────────  │
│  Max Mustermann    2           5h 00min    CUS-42, CUS-43       │
│  Anna Schmidt      1           2h 30min    CUS-44               │
│  ─────────────────────────────────────────────────────────────  │
│  GESAMT            3           7h 30min                          │
│                                                                  │
│  Budget: 100h │ Verbraucht: 45h │ Verbleibend: 55h              │
│  ████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 45%      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Skill: /time-sync

```
/time-sync [project]

Synct alle nicht-synchronisierten Sessions zu Productive.io
```

**Flow:**

```
┌─────────────────┐
│  /time-sync     │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Lade alle Sessions mit             │
│  synced_to_productive: false        │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Für jede Session:                  │
│                                     │
│  POST /time_entries                 │
│  {                                  │
│    person_id: developer.id,         │
│    service_id: project.service_id,  │
│    date: session.date,              │
│    time: session.duration_minutes,  │
│    note: "Linear: CUS-42 ..."       │
│  }                                  │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Markiere als synced                │
│  synced_to_productive: true         │
│  productive_time_entry_id: "..."    │
└─────────────────────────────────────┘
```

---

## Dashboard Integration

### Kunden-Dashboard (Service Dashboard)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                  │
│  ACME CORP - SERVICE DASHBOARD                                                  │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  KONTINGENT ÜBERSICHT                                                           │
│  ════════════════════                                                           │
│                                                                                  │
│  Gebuchtes Kontingent:     100 Stunden                                          │
│  Verbraucht:               45 Stunden (45%)                                     │
│  Verbleibend:              55 Stunden                                           │
│                                                                                  │
│  ████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 45%        │
│                                                                                  │
│  ZEITVERWENDUNG (letzte 30 Tage)                                                │
│  ═══════════════════════════════                                                │
│                                                                                  │
│  Delivery Unit          Stunden    Status                                       │
│  ───────────────────────────────────────────────────────────                    │
│  Agent: Ticket-Bot      20h        ✅ Abgeschlossen                             │
│  Workflow: Onboarding   15h        🔄 In Arbeit                                 │
│  Integration: CRM       10h        📋 Geplant                                   │
│                                                                                  │
│  LETZTE AKTIVITÄTEN                                                             │
│  ══════════════════                                                             │
│                                                                                  │
│  28.01.2026  │  5h 00min  │  Login-Feature implementiert                       │
│  27.01.2026  │  3h 30min  │  API-Endpoints erstellt                            │
│  26.01.2026  │  4h 00min  │  Datenmodell finalisiert                           │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Datenfluss

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                  │
│                           DATENFLUSS ÜBERSICHT                                  │
│                                                                                  │
│                                                                                  │
│   ENTWICKLER                                                                    │
│   ──────────                                                                    │
│                                                                                  │
│   ┌───────────────┐                                                             │
│   │ Claude        │                                                             │
│   │ Session       │────▶ ~/.claude-time/sessions/*.json                        │
│   └───────────────┘      (LOKAL, nicht in Git)                                  │
│                                 │                                                │
│                                 │ /time-sync                                     │
│                                 ▼                                                │
│   ┌───────────────────────────────────────────────────────────────────────┐     │
│   │                        PRODUCTIVE.IO                                   │     │
│   │                                                                        │     │
│   │   Time Entries ──────────────────────────────────────────────▶ Budget │     │
│   │       │                                                         │      │     │
│   │       │                                                         │      │     │
│   │       ▼                                                         ▼      │     │
│   │   ┌─────────────┐                                    ┌─────────────┐  │     │
│   │   │ Projekt A   │                                    │ Kontingent  │  │     │
│   │   │ (Kunde 1)   │                                    │ Tracking    │  │     │
│   │   └─────────────┘                                    └─────────────┘  │     │
│   └───────────────────────────────────────────────────────────────────────┘     │
│                                 │                                                │
│                                 │ API                                            │
│                                 ▼                                                │
│   ┌───────────────────────────────────────────────────────────────────────┐     │
│   │                     SERVICE DASHBOARD                                  │     │
│   │                     (Kunden-Portal)                                    │     │
│   │                                                                        │     │
│   │   • Kontingent-Übersicht                                              │     │
│   │   • Zeitverwendung pro Delivery Unit                                  │     │
│   │   • Fortschritt (Linear Status)                                       │     │
│   │   • Rechnungsgrundlage                                                │     │
│   └───────────────────────────────────────────────────────────────────────┘     │
│                                                                                  │
│   KUNDE                                                                         │
│   ─────                                                                         │
│                                                                                  │
│   ✅ Sieht genau, wofür Zeit verwendet wurde                                    │
│   ✅ Kann Kontingent-Verbrauch nachvollziehen                                   │
│   ✅ Transparente Abrechnung                                                    │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Implementierungsplan

### Phase 1: Lokales Tracking (Sofort)

- [ ] Hook für Session Start/End erstellen
- [ ] Lokale JSON-Datei Struktur
- [ ] `/time-report` Skill

### Phase 2: Productive.io Sync (Kurz)

- [ ] `/time-sync` Skill
- [ ] Productive.io API Integration
- [ ] Projekt-Mapping Konfiguration

### Phase 3: Dashboard (Mittel)

- [ ] Service Dashboard API Endpunkt
- [ ] Kontingent-Anzeige im Dashboard
- [ ] Zeitverwendungs-Übersicht

### Phase 4: Automatisierung (Später)

- [ ] Automatisches Sync bei `/session-end`
- [ ] Warnungen bei Kontingent-Grenze
- [ ] Monatliche Reports

---

## Wichtige Prinzipien

1. **Lokal First:** Daten bleiben auf dem Entwickler-Rechner
2. **Nicht in Git:** `~/.claude-time/` ist global, nicht pro Repo
3. **Opt-in Sync:** Sync zu Productive.io ist explizite Aktion
4. **Transparenz:** Kunde sieht nur aggregierte Daten, keine Details
5. **Datenschutz:** Entwickler-Details bleiben intern

---

## Offene Fragen

1. **Granularität:** Pro Session oder pro Aktivität tracken?
2. **Pausen:** Wie erkennen wir Pausen innerhalb einer Session?
3. **Korrektur:** Wie kann ein Entwickler Zeit nachträglich korrigieren?
4. **Team-Aggregation:** Wie sammeln wir Daten von mehreren Entwicklern?

---

*Erstellt: 28. Januar 2026*
*Status: Konzept zur Review*
