---
name: prime
description: Load project context and show current status. Use at the start of a session or when context is needed.
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Write, AskUserQuestion
---

# Prime: Load Project Context

## Objective

Build comprehensive understanding of the codebase AND show current project status so work can resume immediately.

## Process

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

**Boot Sequence Output:**

```
{ ──────────────── { * BOOT SEQUENCE * } ──────────────── }

{{BOOT_SUBLINE}}

Welcome back, {{developer.name}}.

lucid labs
────────────────────────────────────────────────────────────────────────────

 █████╗  ██████╗ ███████╗███╗   ██╗████████╗    ██╗  ██╗██╗████████╗
██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝    ██║ ██╔╝██║╚══██╔══╝
███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║       █████╔╝ ██║   ██║
██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║       ██╔═██╗ ██║   ██║
██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║       ██║  ██╗██║   ██║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚═╝   ╚═╝

A modular engineering toolkit for building AI agents

{{HUMOR_COMMENT}}

────────────────────────────────────────────────────────────────────────────

Type /docs to explore the Agent Kit documentation.
```

#### 0.1.1 Boot Sublines (rotierend, zufällig wählen)

**Technisch-trocken:**
- `Initializing systems. Assumptions included.`
- `Booting agent environment. No promises made.`
- `Loading tools, patterns, and questionable decisions.`

**Nerd-ironisch:**
- `Compiling intent. Please stand by.`
- `Starting session. This started as a small change.`
- `Spinning up agents. Human supervision enabled.`

**Meta/selbstironisch (Favoriten):**
- `Initializing systems. Works on our machine.`
- `Boot sequence complete. Reality may vary.`
- `Systems ready. Optimism level: cautious.`

#### 0.1.2 Humor Comments (rotierend, Kommentar-Syntax)

- `// Temporary fix. Do not remove.`
- `// This works. Do not touch.`
- `// TODO: refactor later`
- `// This started as a small change.`
- `// Works on my machine.`
- `// We'll clean this up in v2.`
- `// The agent understands the system. Mostly.`
- `// Human in the loop. For now.`
- `// Autonomous, but not unsupervised.`
- `// Designed for clarity. Reality may vary.`
- `// Optimized for thinking, not speed.`
- `// Fewer prompts. Better systems.`

#### 0.1.3 Welcome Varianten

Alle nutzen `{{developer.name}}` aus `developer.json`:

- `Welcome back, {{developer.name}}.` (Default)
- `Welcome, {{developer.name}}. Session initialized.`
- `Welcome, {{developer.name}}. Ready when you are.`
- `Welcome, {{developer.name}}. Systems over scripts.`
- `Welcome, {{developer.name}}. Let's build something solid.`

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
  "name": "Adam",
  "email": "adam@lucidlabs.de",
  "handle": "adam",
  "role": "engineer",
  "created": "2026-01-28",

  "linear": {
    "user_id": "abc123",
    "display_name": "Adam K.",
    "default_team": "lucid-labs-agents"
  },

  "productive": {
    "person_id": "12345",
    "default_activity_type": "Development"
  },

  "preferences": {
    "boot_humor": true,
    "dashboard_style": "compact",
    "auto_sync_time": false
  }
}
```

**Felder-Erklärung:**

| Feld | Zweck | Wann abfragen |
|------|-------|---------------|
| `name` | Begrüßung, Reports | Erstes Setup |
| `email` | Identifikation | Erstes Setup |
| `handle` | Kurz-ID für Commits | Erstes Setup |
| `linear.user_id` | Linear API Queries | Bei erstem `/linear` |
| `linear.display_name` | Ticket-Anzeige | Bei erstem `/linear` |
| `productive.person_id` | Zeit-Sync | Bei erstem `/productive setup` |
| `preferences.*` | UX-Anpassung | Optional, später |

**Falls Developer EXISTIERT (normale Session):**

Zeige die Boot Sequence aus 0.1 mit:
- Zufälliger Boot Subline
- Welcome mit Developer-Name aus JSON
- Zufälliger Humor Comment

Dann direkt weiter zu **0.3 Session-Optionen** (Tickets, etc.).

#### 0.3 Session-Optionen anzeigen

Nach der Begrüßung zeige die Arbeitsoptionen:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│   Woran möchtest du heute arbeiten?                                            │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   MEINE LINEAR TICKETS (dir zugewiesen)                                        │
│   ─────────────────────────────────────                                         │
│                                                                                 │
│   [1] CUS-42  Login Feature implementieren          Delivery    ⏱ 5h 30min     │
│   [2] CUS-45  Error Handling verbessern            Exploration  ⏱ 1h 15min     │
│   [3] CUS-48  API Dokumentation                    Backlog      ⏱ 0h 00min     │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   WEITERE OPTIONEN                                                              │
│   ────────────────                                                              │
│                                                                                 │
│   [4] 📋 Future Plans      - Geplante Features & Verbesserungen                │
│   [5] 📝 Lokale TODOs      - Deine persönlichen Notizen                        │
│   [6] 🆕 Neues Ticket      - Neues Linear Issue erstellen                      │
│   [7] 🔍 Frei erkunden     - Codebase ohne spezifisches Ziel                   │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   Wähle [1-7] oder beschreibe, was du tun möchtest:                            │
│   > _                                                                           │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
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
# Prüfe ob Future Plans existieren
cat .claude/reference/LOCAL-future-plans.md 2>/dev/null | grep "## Zu Implementieren" -A 20
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
║   🕐 SESSION DASHBOARD                                     [project-name]    ║
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
# Session-Start Zeit speichern
echo "Session gestartet: $(date -Iseconds)" >> "$TIME_DIR/current-session.txt"
echo "Project: $PROJECT_NAME" >> "$TIME_DIR/current-session.txt"
```

**Falls keine Daten vorhanden (erstes Mal):**

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   🕐 SESSION DASHBOARD                                     [project-name]    ║
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
