---
name: docs
description: Browse Agent Kit documentation directly in terminal. Use for quick access to architecture, skills, workflows, and reference docs.
disable-model-invocation: true
allowed-tools: Read, Glob, Bash
argument-hint: [section]
---

# Docs: Terminal Documentation Browser

Browse the Lucid Labs Agent Kit documentation without leaving the terminal.

---

## Usage

```
/docs                    # Show documentation overview
/docs [section]          # Jump directly to section
/docs search [query]     # Search across all docs
```

---

## Sections

When called without argument, show this menu:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│   AGENT KIT DOCUMENTATION                                                       │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   GETTING STARTED                                                               │
│   [1] overview        - Was ist das Agent Kit?                                  │
│   [2] quickstart      - Schnellstart für neue Projekte                          │
│   [3] stack           - Tech Stack Übersicht                                    │
│                                                                                 │
│   ARCHITECTURE                                                                  │
│   [4] architecture    - Systemarchitektur & Patterns                            │
│   [5] aidd            - AIDD Workflow (Adaptive AI Discovery & Delivery)        │
│   [6] piv             - PIV Loop (Plan-Implement-Validate)                      │
│                                                                                 │
│   DEVELOPMENT                                                                   │
│   [7] skills          - Alle verfügbaren Skills                                 │
│   [8] mastra          - AI Agents & Tools mit Mastra                            │
│   [9] convex          - Realtime Database                                       │
│   [10] design         - Design System & UI Patterns                             │
│                                                                                 │
│   INTEGRATION                                                                   │
│   [11] linear         - Linear Project Management                               │
│   [12] mcp            - MCP Server Setup                                        │
│   [13] productive     - Productive.io Time Tracking                             │
│                                                                                 │
│   DEPLOYMENT                                                                    │
│   [14] deployment     - Docker, Elestio, CI/CD                                  │
│   [15] scaling        - Skalierung & Performance                                │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   Wähle [1-15] oder tippe einen Suchbegriff:                                   │
│   > _                                                                           │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Section Mappings

| Section | File(s) |
|---------|---------|
| `overview` | `.claude/agent-kit-for-ai.md` |
| `quickstart` | `CLAUDE.md` (Quick Start section) |
| `stack` | `.claude/agent-kit-stack-overview.md` |
| `architecture` | `.claude/reference/architecture.md` |
| `aidd` | `.claude/reference/aidd-methodology.md` |
| `piv` | `CLAUDE.md` (PIV Loop section) |
| `skills` | `.claude/skills/README.md` + list all skills |
| `mastra` | `.claude/reference/mastra-best-practices.md`, `mastra/README.md` |
| `convex` | `convex/README.md` |
| `design` | `.claude/reference/design-system.md` |
| `linear` | `.claude/reference/linear-setup.md` |
| `mcp` | `.claude/reference/mcp-servers.md` |
| `productive` | `.claude/reference/productive-integration.md` |
| `deployment` | `.claude/reference/deployment-best-practices.md` |
| `scaling` | `.claude/reference/scaling.md` |

---

## Direct Section Access

### `/docs overview`

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│   AGENT KIT OVERVIEW                                                            │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   Das Agent Kit ist ein modulares Engineering Toolkit für AI-Agent-Projekte.   │
│                                                                                 │
│   KERNKONZEPTE:                                                                 │
│                                                                                 │
│   • Upstream/Downstream Model                                                   │
│     - Agent Kit = Upstream (Template)                                           │
│     - Dein Projekt = Downstream (Fork)                                          │
│     - /sync holt Updates, /promote teilt Verbesserungen                        │
│                                                                                 │
│   • AIDD Workflow                                                               │
│     - Exploration → Decision → Delivery → Review                               │
│     - Linear-basiertes Ticket-Management                                        │
│                                                                                 │
│   • PIV Loop                                                                    │
│     - Plan → Implement → Validate                                               │
│     - Keine Phase überspringen!                                                 │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   Weiter: [stack] [architecture] [skills] [zurück]                             │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### `/docs skills`

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│   VERFÜGBARE SKILLS                                                             │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   SESSION                                                                       │
│   /prime              Load project context, start session                       │
│   /session-end        End session, update Linear, save time                     │
│                                                                                 │
│   PLANNING                                                                      │
│   /create-prd         Create Product Requirements Document                      │
│   /plan-feature       Plan feature implementation                               │
│   /init-project       Initialize new downstream project                         │
│                                                                                 │
│   IMPLEMENTATION                                                                │
│   /execute            Execute an implementation plan                            │
│   /commit             Create formatted git commit                               │
│                                                                                 │
│   VALIDATION                                                                    │
│   /visual-verify      UI verification via agent-browser                         │
│   /pre-production     Security & quality check before deploy                    │
│                                                                                 │
│   INTEGRATION                                                                   │
│   /linear             Linear project management                                 │
│   /productizer        Bridge Linear ↔ Productive.io                            │
│   /docs               This documentation browser                                │
│                                                                                 │
│   MAINTENANCE                                                                   │
│   /sync               Sync updates from upstream                                │
│   /promote            Promote patterns to upstream                              │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   Detail: /docs skill [name]    Beispiel: /docs skill commit                   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### `/docs stack`

Zeige den Inhalt von `.claude/agent-kit-stack-overview.md` formatiert an.

### `/docs skill [name]`

```bash
# Lade Skill-Definition
cat .claude/skills/[name]/SKILL.md
```

Zeige formatiert:
- Name & Description
- Allowed Tools
- Usage Examples
- Process Steps

---

## Search

### `/docs search [query]`

```bash
# Suche in allen Dokumenten
grep -r -i "[query]" .claude/ --include="*.md" | head -20
```

**Output:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│   SUCHERGEBNISSE: "convex"                                                      │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   [1] CLAUDE.md:142                                                             │
│       "Database: Convex - Realtime reactive database"                           │
│                                                                                 │
│   [2] .claude/reference/architecture.md:78                                      │
│       "Convex provides automatic real-time updates to UI"                       │
│                                                                                 │
│   [3] .claude/agent-kit-stack-overview.md:45                                    │
│       "STANDARD: Convex (Realtime, Type-safe, Built-in Vector)"                │
│                                                                                 │
│   ─────────────────────────────────────────────────────────────────────────     │
│                                                                                 │
│   Öffnen: Wähle [1-3] für Details                                              │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Navigation

Innerhalb jeder Section:

| Key | Action |
|-----|--------|
| `[zurück]` | Zurück zum Hauptmenü |
| `[weiter]` | Nächste verwandte Section |
| `[1-n]` | Springe zu Subsection |
| `q` | Beenden |

---

## Implementation Notes

1. **Alle Docs im Terminal** - Kein Finder, kein Browser
2. **Formatierte Ausgabe** - ASCII-Boxes für Lesbarkeit
3. **Navigation** - Einfache Zahlen/Keywords
4. **Search** - Grep-basiert, schnell
5. **Context-aware** - Zeigt relevante "Weiter"-Links

---

## Examples

```bash
# Starte Docs-Browser
/docs

# Direkt zu Skills
/docs skills

# Skill-Details
/docs skill commit

# Suche
/docs search "linear"

# Stack Übersicht
/docs stack
```
