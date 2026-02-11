---
name: prime
description: Load project context and show current status. Use at the start of a session or when context is needed.
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Write, AskUserQuestion
---

# Prime: Load Project Context

## Objective

Build comprehensive understanding of the codebase AND show current project status so work can resume immediately.

---

## IMPORTANT: Agent Kit Command Scope

You are operating inside the Lucid Labs Agent Kit.

When rendering the session start screen, command list, or skill overview:

- ONLY list commands that are explicitly defined as part of the Lucid Labs Agent Kit
- These commands are Agent-Kit-specific (e.g. /prime, /plan-feature, /skills, /tickets, etc.)
- DO NOT list Claude-native commands in the Agent Kit command list
- DO NOT introduce new commands, aliases, or variations
- DO NOT extrapolate or "helpfully" extend the command set

**Standard Claude Code commands remain available** (e.g. /help, /clear, /config, etc.)
They are just not listed in the Agent Kit session commands block.

Deviation from the defined Agent Kit command set is considered an error.

---

## Process

### -1. CONTEXT DETECTION (ALLERERSTER SCHRITT!)

**KRITISCH:** Bevor irgendetwas anderes passiert, MUSS der Kontext erkannt werden.

```bash
# 1. Aktuelles Verzeichnis prüfen
pwd

# 2. Prüfen ob PROJECT-CONTEXT.md existiert
cat .claude/PROJECT-CONTEXT.md 2>/dev/null
```

**Kontext-Entscheidungsbaum:**

```
Existiert .claude/PROJECT-CONTEXT.md?
├── JA → Lese type: Feld
│   ├── type: downstream → DOWNSTREAM PROJEKT
│   │   └── Lese active_project.name und active_project.prd
│   └── type: upstream → UPSTREAM (Agent Kit Template)
│
└── NEIN → Prüfe Verzeichnisname
    ├── "lucidlabs-agent-kit" → Wahrscheinlich UPSTREAM
    └── Anderer Name → Wahrscheinlich DOWNSTREAM (uninitialisiert)
```

**Context Header anzeigen (IMMER vor Boot Screen):**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CONTEXT                                                                    │
│  ───────                                                                    │
│                                                                             │
│  Working Directory: /Users/.../projects/invoice-accounting-assistant       │
│  Repository Type:   DOWNSTREAM                                              │
│  Active Project:    invoice-accounting-assistant                            │
│  PRD:               .claude/PRD.md                                          │
│  Upstream:          ../../lucidlabs-agent-kit                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Oder für Upstream (Agent Kit Template):**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CONTEXT                                                                    │
│  ───────                                                                    │
│                                                                             │
│  Working Directory: /Users/.../lucidlabs-agent-kit                          │
│  Repository Type:   UPSTREAM (Agent Kit Template)                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**WICHTIG: Im Upstream-Modus → Projekt-Auswahl anbieten (siehe Abschnitt 0.0)**

**Falls Downstream aber kein PROJECT-CONTEXT.md:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CONTEXT                                                                    │
│  ───────                                                                    │
│                                                                             │
│  Working Directory: /Users/.../projects/some-project                        │
│  Repository Type:   DOWNSTREAM (uninitialisiert)                            │
│                                                                             │
│  ⚠️  PROJECT-CONTEXT.md fehlt. Erstelle es mit:                             │
│      → Führe /init-project aus, oder                                        │
│      → Erstelle .claude/PROJECT-CONTEXT.md manuell                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Nach Context-Erkennung:**
- Falls UPSTREAM → Weiter mit Projekt-Auswahl (0.0)
- Falls DOWNSTREAM → Weiter mit Boot Sequence (0.1)

---

### 0.0 Projekt-Auswahl (NUR im UPSTREAM-Modus)

**Wann:** Wenn Claude im `lucidlabs-agent-kit` Verzeichnis gestartet wird (Upstream).

**Workflow:**

1. **Projekte auflisten:**

```bash
# Projekte-Ordner ist auf gleicher Ebene wie agent-kit
PROJECTS_DIR="$(dirname "$(pwd)")/projects"
ls -1 "$PROJECTS_DIR" 2>/dev/null | grep -v "^\."
```

2. **Projekt-Liste anzeigen:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  VERFÜGBARE PROJEKTE                                                        │
│  ───────────────────                                                        │
│                                                                             │
│  [1] casavi-sandbox-seeder         Zuletzt: 28.01.2026                      │
│  [2] client-service-reporting      Zuletzt: 29.01.2026                      │
│  [3] invoice-accounting-assistant  Zuletzt: 29.01.2026                      │
│  [4] neola                         Zuletzt: 23.01.2026                      │
│  [5] satellite                     Zuletzt: 29.01.2026                      │
│                                                                             │
│  ───────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  [N] Neues Projekt erstellen                                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

An welchem Projekt möchtest du heute arbeiten?
```

3. **Nach Auswahl → Handoff-Bestätigung:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  PROJEKT AUSGEWÄHLT: invoice-accounting-assistant                           │
│                                                                             │
│  Pfad: /Users/.../projects/invoice-accounting-assistant                     │
│                                                                             │
│  ───────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  Okay, wollen wir loslegen?                                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

4. **Bei Bestätigung → Automatischer Session-Handoff (KEIN /clear nötig!):**

**KRITISCH:** Nach Bestätigung durch den User erfolgt der Handoff automatisch:

a) **Working Directory wechseln:**
   ```bash
   cd /Users/.../projects/[gewähltes-projekt]
   ```

b) **Handoff-Bestätigung anzeigen:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  ✓ SESSION HANDOFF COMPLETE                                                 │
│                                                                             │
│  ───────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  Neues Working Directory:                                                   │
│  /Users/.../projects/invoice-accounting-assistant                           │
│                                                                             │
│  ⚠️  WICHTIG: Ich arbeite ab jetzt NUR in diesem Projekt.                   │
│      Das Upstream Repository (lucidlabs-agent-kit) wird NICHT verändert.    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

c) **Context Header für neues Projekt anzeigen**

d) **Boot Screen mit verfügbaren Skills**

e) **Dann:** Normaler /prime Flow für Downstream (ab 0.1)

---

**Handoff-Regeln:**

| Regel | Beschreibung |
|-------|--------------|
| **Kein Session-Neustart** | Alles passiert in der gleichen Claude-Session |
| **Kein /clear nötig** | Working Directory wird gewechselt, Kontext bleibt erhalten |
| **Explizite Bestätigung** | Handoff wird visuell bestätigt |
| **Upstream-Schutz** | Nach Handoff: KEINE Änderungen am Agent Kit mehr |
| **Projekt-Fokus** | Alle weiteren Aktionen betreffen nur das gewählte Projekt |

---

### 0. Session Intro & Begrüßung (ZUERST!)

#### 0.1 Boot Sequence

**WICHTIG:** Der Name kommt IMMER aus `developer.json`. Kein Hardcoding!

```bash
TIME_DIR="$HOME/.claude-time"
DEVELOPER_FILE="$TIME_DIR/developer.json"

if [ -f "$DEVELOPER_FILE" ]; then
  DEVELOPER_NAME=$(cat "$DEVELOPER_FILE" | jq -r '.name')
fi
```

**Boot Screen Layout (exakt so rendern):**

```
LUCID LABS
───────────────────────────────────────────────────────────────────────────────

 █████╗  ██████╗ ███████╗███╗   ██╗████████╗    ██╗  ██╗██╗████████╗
██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝    ██║ ██╔╝██║╚══██╔══╝
███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║       █████╔╝ ██║   ██║
██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║       ██╔═██╗ ██║   ██║
██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║       ██║  ██╗██║   ██║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚═╝   ╚═╝

{{RANDOM_GREETING}}

───────────────────────────────────────────────────────────────────────────────

{ ────────────────── { * {{RANDOM_AGENT_LOG}} * } ────────────────── }

───────────────────────────────────────────────────────────────────────────────

/agentdocs       Explore Agent Kit documentation
/skills          List available Agent Kit skills
/clone-skill     Clone skills from central repository
/publish-skill   Share your skills with the team
/tickets         Show assigned Linear tickets
/new-ticket      Create a new Linear issue
/todos           Open local TODOs and notes
/future          View planned features and improvements
/status          Show system and session status
/notion-publish  Publish markdown to Notion (private)
/session-end     End session and persist context
───────────────────────────────────────────────────────────────────────────────
Tip: Type a command or select an option number below.
```

**Danach folgt: Deployed Projects (0.1.0), dann Security Reminders (0.1.0b), dann Tickets/Options-Block (0.3).**

---

#### 0.1.0 Deployed Projects Overview (NACH Boot Screen)

**IMMER anzeigen** nach dem Boot Screen. Lese `infrastructure/lucidlabs-hq/registry.json` (lokal oder aus upstream) und zeige alle deployed Projekte.

```bash
# Registry finden (downstream oder upstream)
REGISTRY=""
if [ -f "infrastructure/lucidlabs-hq/registry.json" ]; then
  REGISTRY="infrastructure/lucidlabs-hq/registry.json"
elif [ -f "$(dirname "$(pwd)")/../lucidlabs-agent-kit/infrastructure/lucidlabs-hq/registry.json" ]; then
  REGISTRY="$(dirname "$(pwd)")/../lucidlabs-agent-kit/infrastructure/lucidlabs-hq/registry.json"
fi
```

**Deployed Projects anzeigen:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  DEPLOYED PROJECTS (LUCIDLABS-HQ)                                          │
│  ────────────────────────────────                                          │
│                                                                             │
│  cotinga-test-suite                                                        │
│    URL:    https://cotinga.lucidlabs.de                                    │
│    Convex: https://cts-convex.lucidlabs.de                                │
│    Repo:   https://github.com/lucidlabs-hq/cotinga-test-suite             │
│                                                                             │
│  client-service-reporting                                                   │
│    URL:    https://reporting.lucidlabs.de                                  │
│    Convex: https://csr-convex.lucidlabs.de                                │
│    Repo:   https://github.com/lucidlabs-hq/client-service-reporting       │
│                                                                             │
│  invoice-accounting-assistant                        Status: pending       │
│    URL:    https://invoice.lucidlabs.de              (not yet deployed)    │
│    Repo:   https://github.com/lucidlabs-hq/invoice-accounting-assistant   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Rendering-Regeln:**
- Nur Projekte mit `status: "deployed"` oder `status: "provisioned"` als aktiv anzeigen
- Projekte mit `status: "pending"` mit Hinweis `(not yet deployed)` markieren
- URL immer als klickbarer Link
- Repo immer als `https://github.com/<repo>` Link
- Convex URL nur anzeigen wenn vorhanden (nicht null)
- Sortierung: deployed first, dann pending

**Daten aus registry.json:**
```json
{
  "projects": [
    {
      "name": "...",
      "url": "https://...",
      "convexUrl": "https://...",
      "repo": "lucidlabs-hq/...",
      "status": "deployed|pending|provisioned"
    }
  ]
}
```

---

#### 0.1.0b Security Reminders Check (NACH Deployed Projects)

**Prüfe Security-Reminders bei Session-Start.**

```bash
# Security Reminders laden
REMINDERS_FILE=".claude/reference/security-reminders.json"
if [ ! -f "$REMINDERS_FILE" ]; then
  # Versuche upstream
  REMINDERS_FILE="$(dirname "$(pwd)")/../lucidlabs-agent-kit/.claude/reference/security-reminders.json"
fi
```

**Logik:**
1. Lese alle Reminders mit `status: "pending"`
2. Vergleiche `due` Datum mit heutigem Datum
3. Falls `due` <= heute: Reminder ist **OVERDUE** (rot/warn)
4. Falls `due` <= heute + 14 Tage: Reminder ist **DUE SOON** (gelb/info)
5. Sonst: nicht anzeigen

**Anzeige (nur wenn fällige Reminders existieren):**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  SECURITY REMINDERS                                                        │
│  ──────────────────                                                        │
│                                                                             │
│  [OVERDUE] SSH Key Rotation                                 Due: 2026-05-09│
│            Rotate SSH keys for LUCIDLABS-HQ                                │
│            Ref: .claude/reference/ssh-keys.md                              │
│                                                                             │
│  [DUE SOON] Create dedicated deploy user                    Due: 2026-08-09│
│             If team has grown: Create 'deploy' user                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Falls keine Reminders fällig:** Block nicht anzeigen (stille Prüfung).

---

#### 0.1.1 Data Pools (random pick exactly one)

**GREETING_POOL** (pick 1, use `developer.name` from JSON):
```
Welcome back, {{developer.name}}.
Welcome, {{developer.name}}. Session initialized.
Welcome, {{developer.name}}. Ready when you are.
Welcome, {{developer.name}}. Systems over scripts.
Welcome, {{developer.name}}. Let's build something solid.
Welcome, {{developer.name}}. This will compile. Eventually.
```

**AGENT_LOG_POOL** (pick 1):
```
AGENT LOG: THIS STARTED AS A SMALL CHANGE
AGENT LOG: HUMAN IN THE LOOP. FOR NOW.
AGENT LOG: AUTONOMOUS, BUT NOT UNSUPERVISED
AGENT LOG: DESIGNED FOR CLARITY. REALITY MAY VARY
AGENT LOG: OPTIMIZED FOR THINKING, NOT SPEED
AGENT LOG: WORKS ON MY MACHINE
AGENT LOG: TEMPORARY FIX. DO NOT REMOVE
AGENT LOG: TODO – REFACTOR LATER
```

---

#### 0.1.2 Rendering Rules

```
BOOT SCREEN =
  HEADER (static: "LUCID LABS")
  LOGO (static: AGENT KIT block letters)
  GREETING (random, exactly one line from GREETING_POOL)
  DIVIDER
  AGENT_LOG (random, exactly one line from AGENT_LOG_POOL, in { } format)
  DIVIDER
  COMMAND CHEAT SHEET (static)
  CONTEXTUAL WORK OPTIONS (dynamic, from Linear/TODOs)
```

**Rules:**
- NUR eine Begrüßung zur Zeit
- NUR ein Agent Log zur Zeit
- Keine Listen, keine Bulletpoints, keine Humor-Sektionen
- Keine neuen Sprüche erfinden - nur aus den Pools wählen

---

#### 0.2 Developer-Check & Setup

**Prüfe Developer-Konfiguration:**

```bash
TIME_DIR="$HOME/.claude-time"
DEVELOPER_FILE="$TIME_DIR/developer.json"

# Prüfe ob Developer-Datei existiert
if [ -f "$DEVELOPER_FILE" ]; then
  DEVELOPER_NAME=$(cat "$DEVELOPER_FILE" | grep '"name"' | cut -d'"' -f4)
fi
```

**Falls KEIN Developer konfiguriert (erstes Mal):**

```
{ ──────────────── { * BOOT SEQUENCE * } ──────────────── }

First time setup detected.

lucid labs
────────────────────────────────────────────────────────────────────────────

 █████╗  ██████╗ ███████╗███╗   ██╗████████╗    ██╗  ██╗██╗████████╗
██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝    ██║ ██╔╝██║╚══██╔══╝
███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║       █████╔╝ ██║   ██║
██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║       ██╔═██╗ ██║   ██║
██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║       ██║  ██╗██║   ██║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚═╝   ╚═╝

A modular engineering toolkit for building AI agents

// Setting up your developer profile...

────────────────────────────────────────────────────────────────────────────
```

**Setup-Fragen (AskUserQuestion verwenden):**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│   DEVELOPER SETUP                                                               │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   Wie heißt du?                                                                 │
│   > _                                                                           │
│                                                                                 │
│   Deine E-Mail?                                                                 │
│   > _                                                                           │
│                                                                                 │
│   Dein Kürzel (für Commits, z.B. "adam")?                                      │
│   > _                                                                           │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   Linear & Productive.io werden später konfiguriert,                           │
│   wenn du die entsprechenden Skills nutzt.                                     │
│                                                                                 │
│   (Gespeichert in ~/.claude-time/developer.json)                               │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

Dann speichern in `~/.claude-time/developer.json`:

```json
{
  "name": "Adam Kassama",
  "email": "adam@lucidlabs.de",
  "handle": "adam",
  "role": "engineer",
  "created": "2026-01-28",
  "updated": "2026-01-28",

  "linear": {
    "user_id": "usr_abc123def456",
    "display_name": "Adam K.",
    "email": "adam@lucidlabs.de",
    "default_team_id": "team_xyz789",
    "default_team_key": "CUS",
    "workspace": "lucid-labs-agents"
  },

  "productive": {
    "person_id": "12345",
    "organization_id": "67890",
    "email": "adam@lucidlabs.de",
    "default_service_id": null,
    "default_activity_type_id": "11111",
    "rate_card_id": null
  },

  "time_tracking": {
    "total_minutes_all_time": 0,
    "first_session": null,
    "last_session": null
  },

  "preferences": {
    "boot_humor": true,
    "dashboard_style": "compact",
    "auto_sync_to_productive": false,
    "show_budget_warnings": true
  }
}
```

**Felder-Erklärung:**

| Feld | Zweck | Wann abfragen | API Source |
|------|-------|---------------|------------|
| `name` | Begrüßung, Reports | Erstes Setup | User Input |
| `email` | Identifikation, Matching | Erstes Setup | User Input |
| `handle` | Kurz-ID für Commits | Erstes Setup | User Input |
| `linear.user_id` | API Queries (assignee filter) | Bei erstem `/linear` | Linear API: `viewer.id` |
| `linear.default_team_id` | Issue Creation | Bei erstem `/linear` | Linear API: `teams` |
| `linear.default_team_key` | Issue Prefix (CUS-xxx) | Bei erstem `/linear` | Linear API: `team.key` |
| `productive.person_id` | Time Entry Creation | Bei `/productive setup` | Productive API: `people` (match by email) |
| `productive.organization_id` | API Header | Bei `/productive setup` | Productive API Settings |
| `productive.default_activity_type_id` | Time Entry Type | Bei `/productive setup` | Productive API: `activity_types` |
| `time_tracking.*` | Aggregierte Statistiken | Automatisch | Berechnet |
| `preferences.*` | UX-Anpassung | Optional | User Input |

**Wie werden die IDs ermittelt?**

```
LINEAR:
1. /linear status → OAuth via MCP
2. Query: viewer { id, email, name }
3. Query: teams { nodes { id, key, name } }
4. Speichere in developer.json

PRODUCTIVE:
1. /productive setup
2. GET /api/v2/people?filter[email]={email}
3. Speichere person_id
4. GET /api/v2/activity_types
5. Zeige Auswahl, speichere default
```

**Falls Developer EXISTIERT (normale Session):**

Zeige die Boot Sequence aus 0.1 mit:
- Zufälliger Boot Subline
- Welcome mit Developer-Name aus JSON
- Zufälliger Humor Comment

Dann direkt weiter zu **0.3 Session-Optionen** (Tickets, etc.).

#### 0.2.1 Stale Session Recovery (VOR Session-Start!)

**KRITISCH:** Before starting a new session, check if a previous session crashed without `/session-end`.

```bash
TIME_DIR="$HOME/.claude-time"
PROJECT_NAME=$(basename "$(pwd)")
CURRENT_SESSION="$TIME_DIR/current-session.txt"
HEARTBEAT_FILE="$TIME_DIR/heartbeat-${PROJECT_NAME}.txt"
HEARTBEAT_PID_FILE="$TIME_DIR/heartbeat-${PROJECT_NAME}.pid"
SESSION_FILE="$TIME_DIR/sessions/$PROJECT_NAME.json"
STALE_THRESHOLD=600  # 10 minutes (2x heartbeat interval)
MAX_SESSION_SECONDS=28800  # 8 hours cap
```

**Recovery-Logik:**

```
Existiert current-session.txt?
├── NEIN → Alles sauber, weiter zu 0.3
└── JA → Vorherige Session wurde nicht beendet!
    │
    ├── Existiert heartbeat-{project}.txt?
    │   ├── JA → Lese letzten Heartbeat-Epoch als End-Time
    │   └── NEIN → Verwende Start-Epoch + 30min als geschaetzte Dauer
    │
    ├── Berechne Dauer: END_EPOCH - START_EPOCH
    │   └── Cap bei MAX_SESSION_SECONDS (8h)
    │
    ├── Speichere recovered Session in sessions/{project}.json:
    │   {
    │     "date": "2026-02-11",
    │     "start": "14:00",
    │     "end": "15:25",
    │     "duration_minutes": 85,
    │     "recovered": true,
    │     "recovery_source": "heartbeat" | "estimated",
    │     "linear_issue": null,
    │     "commits": [],
    │     "synced_to_productive": false
    │   }
    │
    ├── Zeige Recovery-Banner:
    │
    │   ┌──────────────────────────────────────────────────────────────────────┐
    │   │  SESSION RECOVERY                                                    │
    │   │  ────────────────                                                    │
    │   │                                                                      │
    │   │  Previous session did not end cleanly.                               │
    │   │  Recovered: ~85 min (via heartbeat)                                  │
    │   │  Saved to: ~/.claude-time/sessions/{project}.json                    │
    │   │                                                                      │
    │   └──────────────────────────────────────────────────────────────────────┘
    │
    └── Aufraeumen:
        rm -f "$CURRENT_SESSION"
        rm -f "$HEARTBEAT_FILE"
        kill $(cat "$HEARTBEAT_PID_FILE" 2>/dev/null) 2>/dev/null
        rm -f "$HEARTBEAT_PID_FILE"
```

**Recovery-Schritte als Bash:**

```bash
if [ -f "$CURRENT_SESSION" ]; then
  # Previous session was not ended cleanly
  mkdir -p "$TIME_DIR/sessions"
  START_EPOCH=$(grep "^Started:" "$CURRENT_SESSION" | awk '{print $2}')

  if [ -f "$HEARTBEAT_FILE" ]; then
    END_EPOCH=$(cat "$HEARTBEAT_FILE")
    RECOVERY_SOURCE="heartbeat"
  else
    # No heartbeat found - estimate 30 min session
    END_EPOCH=$((START_EPOCH + 1800))
    RECOVERY_SOURCE="estimated"
  fi

  # Calculate duration with 8h cap
  DURATION_SECONDS=$((END_EPOCH - START_EPOCH))
  if [ "$DURATION_SECONDS" -gt "$MAX_SESSION_SECONDS" ]; then
    DURATION_SECONDS=$MAX_SESSION_SECONDS
  fi
  DURATION_MINUTES=$((DURATION_SECONDS / 60))

  # Extract time components for session record
  START_TIME=$(date -r "$START_EPOCH" "+%H:%M" 2>/dev/null || date -d "@$START_EPOCH" "+%H:%M" 2>/dev/null)
  END_TIME=$(date -r "$END_EPOCH" "+%H:%M" 2>/dev/null || date -d "@$END_EPOCH" "+%H:%M" 2>/dev/null)
  SESSION_DATE=$(date -r "$START_EPOCH" "+%Y-%m-%d" 2>/dev/null || date -d "@$START_EPOCH" "+%Y-%m-%d" 2>/dev/null)

  # Save recovered session to sessions/{project}.json
  # (append to existing sessions array or create new file)

  # Show recovery banner
  # Clean up stale files
  rm -f "$CURRENT_SESSION" "$HEARTBEAT_FILE"
  kill "$(cat "$HEARTBEAT_PID_FILE" 2>/dev/null)" 2>/dev/null
  rm -f "$HEARTBEAT_PID_FILE"
fi
```

---

#### 0.3 Session-Optionen anzeigen

Nach der Begrüßung zeige die Arbeitsoptionen:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  Woran möchtest du heute arbeiten?                                          │
│                                                                             │
│  ───────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  MEINE LINEAR TICKETS (dir zugewiesen)                                      │
│  ─────────────────────────────────────                                      │
│                                                                             │
│  [1] CUS-42  Login Feature implementieren        Delivery       5h 30min    │
│  [2] CUS-45  Error Handling verbessern          Exploration    1h 15min    │
│  [3] CUS-48  API Dokumentation                  Backlog        0h 00min    │
│                                                                             │
│  ───────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  WEITERE OPTIONEN                                                           │
│  ────────────────                                                           │
│                                                                             │
│  [4] Future Plans      - Geplante Features & Verbesserungen                 │
│  [5] Lokale TODOs      - Deine persönlichen Notizen                         │
│  [6] Neues Ticket      - Neues Linear Issue erstellen                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Linear Query für "Meine Tickets":**
```
Linear MCP Query:
- Team: [aktuelles Team aus Projekt]
- Assignee: ME (der eingeloggte User)
- Status: NOT Done, NOT Cancelled
- Sort: Status (Delivery first), then Updated
```

**Future Plans laden:**
```bash
# Show next 10 open items from future-plans.md
cat .claude/reference/future-plans.md 2>/dev/null | grep -E "^- \[ \]" | head -10
```

**Lokale TODOs laden:**
```bash
# Prüfe ob lokale TODO-Datei existiert
cat ~/.claude-time/todos/[project-name].md 2>/dev/null
```

---

### 0.4 Session Dashboard anzeigen

**WICHTIG:** Zeige bei jedem Session-Start das Time Tracking Dashboard!

#### 0.1 Session-Daten laden

```bash
# Prüfe ob Time Tracking Verzeichnis existiert
TIME_DIR="$HOME/.claude-time"
PROJECT_NAME=$(basename "$(pwd)")

# Erstelle Verzeichnis falls nicht vorhanden
mkdir -p "$TIME_DIR/sessions"

# Lade Session-Daten für dieses Projekt
SESSION_FILE="$TIME_DIR/sessions/$PROJECT_NAME.json"
```

#### 0.2 Dashboard anzeigen

Zeige das Dashboard im folgenden Format:

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   SESSION DASHBOARD                                     [project-name]    ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   AKTIVITÄT (letzte 8 Wochen)                                                 ║
║   ───────────────────────────────────────────────────────────────────────     ║
║                                                                               ║
║        Dez    Jan    Jan    Jan    Jan                                        ║
║        W49    W01    W02    W03    W04                                        ║
║                                                                               ║
║   Mo   ·  ·   ░  ·   ▒  ·   ░  ▒   █  ░                                       ║
║   Di   ·  ·   ·  ░   ▒  ░   ▒  ░   ░  █                                       ║
║   Mi   ·  ·   ░  ░   █  ▒   ░  █   ▒  ░                                       ║
║   Do   ·  ·   ·  ▒   ░  █   ▒  ░   █  ▒                                       ║
║   Fr   ·  ·   ░  ░   ▒  ░   █  ▒   ░  ░                                       ║
║                                                                               ║
║   Legende:  ·  keine   ░  < 1h   ▒  1-3h   █  > 3h                           ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   STATISTIK                                                                   ║
║   ─────────                                                                   ║
║                                                                               ║
║   Gesamtzeit:        24h 30min      │  Sessions:           12                 ║
║   Diese Woche:       5h 15min       │  Aktive Tage:        8/30               ║
║   Heute:             0h 00min       │  Ø pro Session:      2h 02min           ║
║                                                                               ║
║   Längste Session:   4h 30min       │  Peak Hour:          10:00-11:00        ║
║   Aktueller Streak:  3 Tage         │  Längster Streak:    7 Tage             ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   LETZTE SESSIONS                                                             ║
║   ───────────────                                                             ║
║                                                                               ║
║   27.01.2026   Mo   14:00 - 17:30   3h 30min   CUS-42   ✓ synced              ║
║   26.01.2026   So   10:15 - 12:45   2h 30min   CUS-41   ✓ synced              ║
║   24.01.2026   Fr   09:00 - 11:00   2h 00min   CUS-40   ✓ synced              ║
║   23.01.2026   Do   13:30 - 15:15   1h 45min   CUS-39   ○ pending             ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   KONTINGENT (via Productive.io)                      [Acme Corp]             ║
║   ──────────────────────────────                                              ║
║                                                                               ║
║   Budget:     100h    Verbraucht:    45h    Verbleibend:    55h              ║
║                                                                               ║
║   ████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  45%    ║
║                                                                               ║
║   Prognose: Bei aktuellem Tempo noch ~4 Wochen bis Budget aufgebraucht       ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

#### 0.3 Neue Session starten

Nach dem Dashboard automatisch neue Session registrieren:

```bash
TIME_DIR="$HOME/.claude-time"
PROJECT_NAME=$(basename "$(pwd)")

# Write session file with epoch for crash-safe duration calculation
cat > "$TIME_DIR/current-session.txt" << EOF
Started: $(date +%s)
StartISO: $(date -Iseconds)
Project: $PROJECT_NAME
EOF

# Start heartbeat background process (writes epoch every 5 min)
(while true; do date +%s > "$TIME_DIR/heartbeat-${PROJECT_NAME}.txt"; sleep 300; done) &
HEARTBEAT_PID=$!
echo "$HEARTBEAT_PID" > "$TIME_DIR/heartbeat-${PROJECT_NAME}.pid"
```

**WICHTIG:** The heartbeat runs in background and writes the current epoch to `heartbeat-{project}.txt` every 300 seconds (5 minutes). If the session crashes, the next `/prime` can use this file to determine the approximate end time of the crashed session.

**Falls keine Daten vorhanden (erstes Mal):**

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   SESSION DASHBOARD                                     [project-name]    ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Willkommen! Dies ist deine erste Session in diesem Projekt.                ║
║                                                                               ║
║   Das Time Tracking wird automatisch gestartet.                              ║
║   Am Ende der Session: /session-end                                          ║
║                                                                               ║
║   ────────────────────────────────────────────────────────────────────────   ║
║                                                                               ║
║   Für Kontingent-Tracking:                                                   ║
║   Konfiguriere ~/.claude-time/project-mapping.json                           ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

### 1. Check Linear for Active Work

Query Linear for issues assigned to you or recently updated:

```
Use Linear MCP to search:
- Team: lucid-labs-agents
- Assignee: me
- Status: Exploration, Decision, Delivery, Review
- Sort: Updated (descending)
```

**Show:**
```
## Linear Status

| ID | Title | Status | Project |
|----|-------|--------|---------|
| ABC-123 | Feature X | Exploration | [Agents] Project |

**New since last session:**
- [list any new issues or comments]

Woran möchtest du arbeiten?
1. [ABC-123] Continue Feature X
2. [New] Start something new
3. [Skip] Just explore codebase
```

### 2. Read Project Status

Read `PROJECT-STATUS.md` to understand:
- Current project name and phase
- Active plan (if any)
- Last task worked on
- Recent activity

```bash
cat PROJECT-STATUS.md 2>/dev/null || echo "No PROJECT-STATUS.md found"
```

### 2. Read Core Documentation

- Read `CLAUDE.md` (project rules and conventions)
- Read `.claude/PRD.md` (product requirements)
- Read key files in `.claude/reference/` as needed

### 3. Analyze Project Structure

List all tracked files:
```bash
git ls-files | head -50
```

Show directory structure:
```bash
find . -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/.next/*' | head -30
```

### 4. Check Active Plan

If PROJECT-STATUS.md shows an active plan:

```bash
# Read the active plan
cat .agents/plans/[active-plan].md 2>/dev/null
```

Identify:
- Current phase
- Completed tasks
- Next task to work on

### 5. Check Git Status

```bash
# Current branch
git branch --show-current

# Recent commits
git log -5 --oneline

# Uncommitted changes
git status --short
```

### 6. Verify Environment

```bash
# Check Node version
node -v

# Check if dependencies installed
ls frontend/node_modules 2>/dev/null && echo "Dependencies installed" || echo "Run: cd frontend && pnpm install"
```

---

## Output Report

### Project Status Summary

```markdown
## Project Status

**Project:** [Name from PROJECT-STATUS.md or PRD]
**Phase:** [Current phase]
**Branch:** [Git branch]

### Active Plan
[If active plan exists:]
- **Plan:** `.agents/plans/[plan-name].md`
- **Feature:** [Feature being implemented]
- **Progress:** [X/Y tasks completed]
- **Next Task:** [Description of next task]

[If no active plan:]
- No active plan. Ready to start new feature.

### Recent Activity
- [Last 3-5 activities from PROJECT-STATUS.md]
```

### Codebase Overview

```markdown
## Codebase Overview

**Tech Stack:**
- Frontend: Next.js [version], React, TypeScript
- Styling: Tailwind CSS v4
- Backend: [Mastra if exists]
- Database: [Convex if configured]

**Structure:**
- `frontend/` - Next.js application
- `mastra/` - AI agent layer (if exists)
- `.claude/` - Documentation & skills
- `.agents/plans/` - Implementation plans
```

### Ready to Work

```markdown
## Ready to Work

### Linear Issues (Active)
[Show issues from Linear in Exploration/Delivery status]

### If Continuing Active Issue:
Issue: [ABC-123] Feature X
Status: [Exploration/Delivery]
Next: [What to do next based on status]

### If Starting New Feature:
1. Create Linear issue first: `/linear create`
2. Then plan: `/plan-feature [feature-name]`

### Available Skills
| Skill | Description |
|-------|-------------|
| `/linear` | Manage Linear issues |
| `/plan-feature` | Create new implementation plan |
| `/execute [plan]` | Execute a plan |
| `/validate` | Run all validation checks |
| `/commit` | Create formatted commit |
| `/session-end` | End session, update Linear |
```

---

## Resume Work Flow

If there's an active plan with incomplete tasks:

1. **Show the next task clearly:**
   ```
   RESUME POINT

   Plan: .agents/plans/[plan-name].md
   Task: [Task number and description]
   File: [File to work on]

   Ready to continue? Say "continue" or ask questions.
   ```

2. **Offer to continue:**
   - If user says "continue", proceed with the next task
   - If user wants different work, suggest `/plan-feature`

---

## Quick Resume (TL;DR)

At the end, always provide a one-liner:

```
Quick Resume: [One sentence summary of what to do next]
```

Examples:
- "Quick Resume: [ABC-123] Continue Exploration - research authentication options"
- "Quick Resume: [ABC-123] Ready for Decision - present findings"
- "Quick Resume: [ABC-123] In Delivery - implement Task 3 from plan"
- "Quick Resume: No active issues. Create one with /linear create"

## Session End Reminder

At appropriate stopping points, remind:

```
Bevor du gehst: /session-end
→ Updates Linear ticket status
→ Adds work summary
→ Ensures clean state for next session
```

---

## NOCH ZU IMPLEMENTIEREN

Die folgenden Features sind konzipiert aber noch nicht vollständig implementiert:

### 1. Productive.io Skill (FEHLT NOCH)

```
/productive setup [customer]   - Kunden einrichten
/productive sync               - Zeit zu Productive.io syncen
/productive budget             - Kontingent-Status anzeigen
```

**Benötigt:**
- API-Integration mit Productive.io
- Projekt-Mapping (Linear Project → Productive.io Service)
- Automatischer Zeit-Sync bei /session-end

### 2. Lokale TODOs (FEHLT NOCH)

```
~/.claude-time/todos/[project-name].md
```

**Format:**
```markdown
# Lokale TODOs - customer-portal

## Offen
- [ ] Error Boundary für API Calls
- [ ] Loading States vereinheitlichen

## Ideen
- [ ] Dark Mode Support evaluieren
```

**Skill:**
```
/todo add "Neues TODO"
/todo list
/todo done [id]
```

### 3. Zeit-Daten Persistenz (TEILWEISE)

Die JSON-Struktur ist definiert, aber das tatsächliche Speichern/Laden
muss noch als Code implementiert werden.

**Benötigt:**
- Hook bei Session-Start (Zeit merken)
- Hook bei Session-End (Zeit speichern)
- JSON read/write Utilities

### 4. Kontingent-Anzeige (FEHLT NOCH)

Die Kontingent-Daten kommen von Productive.io und werden im Dashboard angezeigt.

**Benötigt:**
- Productive.io API für Budget-Abfrage
- Caching der Daten (nicht bei jeder Session API call)
- Prognose-Berechnung
