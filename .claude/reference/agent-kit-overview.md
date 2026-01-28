# Agent Kit: AI-Gestützte Softwareentwicklung

> **Lucid Labs GmbH - Agent Kit**
> Ein Production-Ready Framework für die Entwicklung von AI-Agenten und intelligenten Anwendungen.

---

## Executive Summary

### Was ist das Agent Kit?

Das Agent Kit ist ein **modulares Starter-Framework** für die Entwicklung von AI-gestützten Anwendungen. Es kombiniert bewährte Entwicklungsmethoden mit modernsten AI-Technologien und ermöglicht Teams, schnell und qualitativ hochwertig AI-Agenten zu bauen.

### Kernversprechen

| Aspekt | Ohne Agent Kit | Mit Agent Kit |
|--------|----------------|---------------|
| **Projektstart** | Wochen für Setup | < 10 Minuten |
| **Qualität** | Inkonsistent | Standardisiert |
| **AI-Integration** | Ad-hoc | Strukturiert |
| **Wiederverwendung** | Schwierig | Eingebaut |
| **Skalierung** | Manuell | Automatisiert |

### Zielgruppe

- **Entwickler**: Schneller Start mit Best Practices
- **Tech Leads**: Governance und Qualitätssicherung
- **Projektmanager**: Transparente Workflows
- **Kunden**: Nachvollziehbare Lieferungen

---

## Das Problem

### Herausforderungen bei AI-Projekten

**1. Fehlende Struktur**
- Jedes Projekt startet bei Null
- Keine einheitlichen Patterns
- Wissen geht zwischen Projekten verloren

**2. AI-Qualitätsrisiken**
- AI generiert Code ohne Kontext
- Keine systematische Validierung
- Schwer nachvollziehbare Entscheidungen

**3. Ineffiziente Workflows**
- Vermischung von Planung und Umsetzung
- Keine klaren Phasengrenzen
- Scope Creep durch AI

**4. Fehlende Transparenz**
- Kunden verstehen AI-Arbeit nicht
- Fortschritt schwer messbar
- Keine standardisierte Berichterstattung

---

## Die Lösung: Agent Kit

### Drei Säulen

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AGENT KIT                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐          │
│   │                 │   │                 │   │                 │          │
│   │   METHODOLOGY   │   │   TECHNOLOGY    │   │   GOVERNANCE    │          │
│   │                 │   │                 │   │                 │          │
│   │   • AIDD        │   │   • Mastra      │   │   • Linear      │          │
│   │   • PIV Loop    │   │   • Convex      │   │   • Productive  │          │
│   │   • TDD         │   │   • Next.js     │   │   • Code Review │          │
│   │                 │   │                 │   │                 │          │
│   │   WIE wir       │   │   WOMIT wir     │   │   WIE wir       │          │
│   │   arbeiten      │   │   bauen         │   │   liefern       │          │
│   │                 │   │                 │   │                 │          │
│   └─────────────────┘   └─────────────────┘   └─────────────────┘          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Säule 1: Methodology

### AIDD - Adaptive AI Discovery & Delivery

AIDD ist unsere Entwicklungsmethodik, die Discovery (Erkunden) und Delivery (Liefern) bewusst trennt.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AIDD WORKFLOW                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│     EXPLORATION              DECISION              DELIVERY                  │
│     ───────────              ────────              ────────                  │
│                                                                              │
│     • Recherche              • Proceed?            • Implementieren          │
│     • Prototypen             • Pivot?              • Testen                  │
│     • Validieren             • Drop?               • Deployen                │
│     • Lernen                 • Iterate?                                      │
│                                                                              │
│     Kein Zeitdruck           Bewusste              Verbindliche              │
│                              Entscheidung          Timeline                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Kernprinzipien:**

1. **Explizite Entscheidungen**: Kein stilles Übergehen von Exploration zu Delivery
2. **Zeitdruck nur in Delivery**: Exploration hat keine Deadline
3. **Transparenz für Kunden**: Entscheidungen werden kommuniziert
4. **Fokus auf Wert**: Service, Entscheidungen, Wert - nicht Tasks

### PIV Loop - Plan, Implement, Validate

Der PIV Loop ist unser operativer Workflow für jede Aufgabe.

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│             │     │             │     │             │
│    PLAN     │────▶│  IMPLEMENT  │────▶│  VALIDATE   │
│             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
       │                                       │
       │                                       │
       ▼                                       │
┌─────────────┐                               │
│   ITERATE   │◀──────────────────────────────┘
└─────────────┘
```

| Phase | Erlaubt | Verboten |
|-------|---------|----------|
| **Plan** | Recherche, Analyse, Tests definieren | Code schreiben |
| **Implement** | Tests schreiben, dann Code | Scope ändern |
| **Validate** | Prüfen, Tests ausführen | Bugs fixen (→ neuer Zyklus) |

**Regel**: Nie zwei Phasen gleichzeitig. Jeder Fix startet einen neuen PIV-Zyklus.

### TDD - Test Driven Development

Tests sind das Erfolgskriterium für AI-generierte Implementierungen.

```
┌─────────┐        ┌─────────┐        ┌───────────┐
│   RED   │───────▶│  GREEN  │───────▶│ REFACTOR  │
│         │        │         │        │           │
│ Test    │        │ Code    │        │ Improve   │
│ schlägt │        │ besteht │        │ Code,     │
│ fehl    │        │ Test    │        │ Tests     │
│         │        │         │        │ bleiben   │
│         │        │         │        │ grün      │
└─────────┘        └─────────┘        └───────────┘
```

**Warum TDD mit AI?**

| Ohne TDD | Mit TDD |
|----------|---------|
| AI rät Verhalten | Tests definieren erwartetes Verhalten |
| Nachträgliche Tests validieren Bugs | Tests fangen Bugs vor Merge |
| Unklare Erfolgskriterien | Grüne Tests = Erfolg |

---

## Säule 2: Technology

### Stack Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           LUCID LABS AI STACK                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                           CLIENTS                                    │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │    │
│  │  │  Web App    │  │  CLI Tool   │  │ Python SDK  │                  │    │
│  │  │  (Next.js)  │  │  (Optional) │  │  (Optional) │                  │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                  │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      AI LAYER (WÄHLBAR)                              │    │
│  │                                                                      │    │
│  │  ┌─────────────────────────┐    ┌─────────────────────────────┐     │    │
│  │  │     VERCEL AI SDK       │ OR │         MASTRA              │     │    │
│  │  │     (Prototypen)        │    │   (Production Agents)       │     │    │
│  │  └─────────────────────────┘    └─────────────────────────────┘     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      DATA LAYER (WÄHLBAR)                            │    │
│  │                                                                      │    │
│  │  ┌─────────────────────────┐    ┌─────────────────────────────┐     │    │
│  │  │        CONVEX           │ OR │       POSTGRES              │     │    │
│  │  │   (Realtime, Simple)    │    │   (SQL, Flexible)           │     │    │
│  │  └─────────────────────────┘    └─────────────────────────────┘     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                           OPTIONAL COMPONENTS                                │
│                                                                              │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐   │
│  │   Portkey     │ │     n8n       │ │    Python     │ │  LangChain    │   │
│  │ (LLM Gateway) │ │ (Automation)  │ │  (Compute)    │ │  (Chains)     │   │
│  └───────────────┘ └───────────────┘ └───────────────┘ └───────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Komponenten im Detail

#### AI Layer

| Komponente | Wann nutzen? | Stärken |
|------------|--------------|---------|
| **Mastra** | Production Agents, Tools, Workflows | Strukturiert, Type-safe, Decision Layer |
| **Vercel AI SDK** | Schnelle Prototypen, Chat UI | Einfach, Streaming, Wenig Setup |

**Mastra Design Principle:**
> Mastra ist ein kontrollierter Decision & Explanation Layer. Agents rechnen nicht - sie evaluieren vorverarbeitete Ergebnisse und generieren Entscheidungen.

#### Data Layer

| Komponente | Wann nutzen? | Stärken |
|------------|--------------|---------|
| **Convex** | Realtime Apps, schnelles Setup | Automatische Sync, Built-in Vector, Type-safe |
| **Postgres** | SQL-Anforderungen, Pinecone | Standard, Flexibel, Maximale Kontrolle |

#### Optional Components

| Komponente | Zweck |
|------------|-------|
| **Portkey** | LLM Gateway mit Cost Tracking, Multi-Model Routing, Guardrails |
| **n8n** | Workflow Automation, Externe Integrationen, Scheduling |
| **Python Workers** | PDF Parsing, OCR, Statistik, ML Compute |
| **LangChain** | Komplexe Agent-Chains, LangGraph |
| **Pinecone** | Vector Database für RAG |
| **Greptile** | Automatische PR Reviews, Bug Detection |

### LLM Provider

| Provider | Use Case |
|----------|----------|
| **Anthropic Claude** (Primary) | Komplexe Reasoning, Qualität |
| **Azure OpenAI** (Optional) | GDPR-konform, EU Data Residency |

---

## Säule 3: Governance

### Linear Integration

Linear ist unser Execution-System für die technische Arbeit.

**Status Flow:**
```
Backlog → Exploration → Decision → Delivery → Review → Done
                           ↓
                        Dropped (valides Ende)
```

| Status | Bedeutung | Deadline? |
|--------|-----------|-----------|
| **Exploration** | Timeboxed Recherche | Nein |
| **Decision** | Steuerungspunkt | Nein |
| **Delivery** | Implementierung | **Ja** |
| **Review** | QA und Validation | Nein |

### Productive.io Integration

Productive.io ist das System of Record für Kundenwert.

```
┌───────────────────────────────────────────────────────────────┐
│                                                                │
│   PRODUCTIVE.IO                    LINEAR                      │
│   ──────────────                   ──────                      │
│   System of Record                 Execution System            │
│   für Kundenwert                   für technische Arbeit       │
│                                                                │
│   • Kunden (Companies)             • Technische Umsetzung      │
│   • Delivery Units (Projects)      • Exploration → Delivery    │
│   • Budget & Abrechnung            • Maintenance               │
│   • Kunden-Reporting                                           │
│                                                                │
└───────────────────────────────────────────────────────────────┘
```

### Delivery Units

Was wir liefern:

| Typ | Beschreibung | Beispiel |
|-----|--------------|----------|
| **Agent** | Produktiver KI-Agent | Ticket-Klassifikation |
| **Workflow** | Automatisierte Abläufe | Onboarding-Prozess |
| **GPT/Prompt** | Prompt oder Prompt-Set | Meeting Summarizer |
| **Integration** | Externe Anbindungen | CRM-Connector |
| **Workshop** | Einzelner Workshop | AI Strategy Workshop |
| **Advisory** | Analyse, Beratung | AI Readiness Assessment |

---

## Der Entwicklungsworkflow

### Session-basiertes Arbeiten

```
┌─────────────────────────────────────────────────────────────────┐
│  SESSION START                                                   │
│  /prime                                                          │
│  → Check Linear für aktive Issues                               │
│  → Frage: "Woran möchtest du arbeiten?"                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  DEVELOPMENT                                                     │
│  /plan-feature     - Feature planen                             │
│  /execute          - Plan implementieren                        │
│  /validate         - Compliance prüfen                          │
│  /commit           - Änderungen committen                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  SESSION END                                                     │
│  /session-end                                                    │
│  → Linear Ticket Status aktualisieren                           │
│  → Work Summary als Kommentar                                   │
│  → Git Compliance verifizieren                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Skills (Befehle)

| Skill | Beschreibung | Phase |
|-------|--------------|-------|
| `/prime` | Projekt-Kontext laden | Start |
| `/plan-feature` | Feature-Plan erstellen | Planning |
| `/execute` | Plan implementieren | Implementation |
| `/validate` | Compliance prüfen | Validation |
| `/commit` | Änderungen committen | Implementation |
| `/session-end` | Session beenden, Linear aktualisieren | Ende |

---

## Projekt-Setup

### Neues Projekt erstellen

```bash
# Im Agent Kit Verzeichnis
./scripts/create-agent-project.sh --interactive
```

### Konfigurationsoptionen

Das Script fragt nach:

**1. AI Layer (wähle eins):**
- Mastra (Production Agents)
- Vercel AI SDK (Prototypen)

**2. Database (wähle eins):**
- Convex (Realtime, Simple)
- Postgres (SQL, Pinecone)

**3. Optional Components:**
- Portkey (LLM Gateway)
- n8n (Automation)
- Python Workers (Compute)
- LangChain (Complex Chains)
- Terraform (IaC)

### Projekt-Struktur

```
project/
├── frontend/                 # Next.js Application
│   ├── app/                  # App Router
│   ├── components/           # React Components
│   └── lib/                  # Utilities
│
├── mastra/                   # AI Agent Layer (wenn gewählt)
│   └── src/
│       ├── agents/           # Agent Definitionen
│       ├── tools/            # Agent Tools
│       └── workflows/        # Multi-Step Workflows
│
├── convex/                   # Database (wenn gewählt)
│   ├── schema.ts             # Datenbank Schema
│   └── functions/            # Queries, Mutations
│
├── .claude/                  # Entwickler-Konfiguration
│   ├── PRD.md                # Product Requirements
│   ├── skills/               # Claude Code Skills
│   └── reference/            # Best Practices
│
├── CLAUDE.md                 # Entwicklungsregeln
└── WORKFLOW.md               # Workflow-Guide
```

---

## Vorteile

### Für Entwickler

- **Schneller Start**: Projekt in < 10 Minuten aufsetzen
- **Klare Patterns**: Keine Unsicherheit, wie etwas gebaut wird
- **AI-Unterstützung**: Claude Code mit eingebauten Best Practices
- **Wiederverwendung**: Skills und Patterns zwischen Projekten teilen

### Für Tech Leads

- **Konsistenz**: Alle Projekte folgen denselben Standards
- **Qualitätssicherung**: TDD und automatische Reviews
- **Governance**: Klare Regeln in CLAUDE.md
- **Skalierung**: Template für beliebig viele Projekte

### Für Projektmanager

- **Transparenz**: Linear-Integration zeigt Fortschritt
- **Phasentrennung**: Klar erkennbar, wo wir stehen
- **Entscheidungspunkte**: AIDD macht Steuerung möglich
- **Reporting**: Productive.io für Kunden-Reports

### Für Kunden

- **Nachvollziehbarkeit**: Entscheidungen werden dokumentiert
- **Qualität**: Standardisierte, getestete Lieferungen
- **Transparenz**: Fortschritt im Service Dashboard
- **Flexibilität**: Exploration ohne Zeitdruck möglich

---

## Beispiel: AI Agent Projekt

### Szenario: Ticket-Klassifikations-Agent

**Ziel**: Ein Agent, der eingehende Support-Tickets automatisch klassifiziert.

### Phase 1: Exploration

```
Status: Exploration
Aktivitäten:
- Bestehende Ticket-Daten analysieren
- Klassifikations-Kategorien definieren
- Prototyp mit Vercel AI SDK bauen
- Accuracy messen

Ergebnis: Proof of Concept mit 85% Accuracy
```

### Phase 2: Decision

```
Entscheidung: PROCEED

Begründung:
- 85% Accuracy erfüllt Anforderung (> 80%)
- Integration mit CRM technisch machbar
- ROI: 20h/Woche Zeitersparnis

Nächster Schritt: Delivery
```

### Phase 3: Delivery

```
PIV Loop 1: Datenmodell
├─ PLAN: Schema für Tickets definieren
├─ IMPLEMENT: Convex Schema + Types erstellen
└─ VALIDATE: TypeScript check ✓

PIV Loop 2: Agent
├─ PLAN: Mastra Agent mit Classification Tool
├─ IMPLEMENT: TDD - Tests zuerst, dann Code
└─ VALIDATE: 17 Tests passing ✓

PIV Loop 3: Integration
├─ PLAN: CRM Webhook + n8n Workflow
├─ IMPLEMENT: n8n Flow erstellen
└─ VALIDATE: E2E Test ✓
```

### Ergebnis

- **Delivery Unit**: Agent - Ticket Classification
- **Linear**: [Agents] Ticket Classification → Done
- **Productive.io**: Delivery Unit abgeschlossen, Report generiert

---

## Upstream/Downstream Modell

### Konzept

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           lucidlabs/                                     │
│                                                                          │
│   ┌─────────────────────┐                ┌──────────────────────────┐   │
│   │ lucidlabs-agent-kit │    PROMOTE     │       projects/          │   │
│   │     (UPSTREAM)      │◄───────────────│                          │   │
│   │                     │                │  ┌────────────────────┐   │   │
│   │  • Generic Skills   │ SYNC/INIT      │  │  customer-portal   │   │   │
│   │  • Boilerplate      │───────────────►│  │   (DOWNSTREAM)     │   │   │
│   │  • Best Practices   │                │  │                    │   │   │
│   └─────────────────────┘                │  │  • Domain Logic    │   │   │
│                                          │  │  • Project PRD     │   │   │
│                                          │  │  • Custom Agents   │   │   │
│                                          │  └────────────────────┘   │   │
│                                          └──────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Workflows

| Aktion | Richtung | Befehl |
|--------|----------|--------|
| **Projekt erstellen** | Upstream → Downstream | `./scripts/create-agent-project.sh` |
| **Pattern promoten** | Downstream → Upstream | `/promote` |
| **Updates synchronisieren** | Upstream → Downstream | `/sync` |

### Was wird promotet?

| ✅ Promotable | ❌ Nicht Promotable |
|---------------|---------------------|
| Skills (`.claude/skills/`) | PRD (`.claude/PRD.md`) |
| Reference Docs | App Pages |
| UI Components | Domain Agents |
| Utility Functions | Database Schema |

---

## Qualitätssicherung

### Automatisierte Checks

```bash
pnpm run validate    # TypeScript + ESLint
pnpm run test        # Unit Tests (Vitest)
pnpm run build       # Production Build
```

### Code Review Layers

| Layer | Tool | Prüft |
|-------|------|-------|
| **Automatisch** | ESLint, TypeScript | Syntax, Types |
| **TDD** | Vitest | Funktionalität |
| **AI Review** | Greptile (optional) | Bugs, Security |
| **Human Review** | GitHub PR | Architektur, Design |

### Pre-Production Checklist

Vor jedem Production Deploy:

```
/pre-production

Checks:
├─ Build erfolgreich?
├─ TypeScript fehlerfrei?
├─ ESLint bestanden?
├─ Tests grün?
├─ Security Scan?
└─ E2E Tests (kritische Flows)?
```

---

## Zusammenfassung

### Das Agent Kit ist:

1. **Ein Framework** - Nicht ein einzelnes Produkt, sondern eine Plattform für viele Projekte

2. **Methodengetrieben** - AIDD, PIV, TDD als Grundlage für qualitativ hochwertige AI-Entwicklung

3. **Modular** - Wähle die Komponenten, die du brauchst (Mastra/Vercel AI SDK, Convex/Postgres, etc.)

4. **Wiederverwendbar** - Patterns fließen zwischen Projekten (Promote/Sync)

5. **Transparent** - Linear und Productive.io für Tracking und Reporting

### Der Unterschied:

| Traditionell | Mit Agent Kit |
|--------------|---------------|
| Jedes Projekt neu | Template-basiert |
| Ad-hoc AI-Integration | Strukturierte AI Layer |
| Unklare Phasen | AIDD + PIV |
| Manuelle Tests | TDD-First |
| Isolierte Learnings | Promote/Sync Workflow |

### In einem Satz:

> **Agent Kit ermöglicht es Teams, AI-gestützte Anwendungen schnell, konsistent und qualitativ hochwertig zu entwickeln - mit klaren Methoden, bewährten Technologien und transparenter Governance.**

---

## Appendix

### Glossar

| Begriff | Definition |
|---------|------------|
| **AIDD** | Adaptive AI Discovery & Delivery - Methodik mit Exploration und Delivery Phasen |
| **PIV** | Plan-Implement-Validate - Operativer Entwicklungszyklus |
| **TDD** | Test-Driven Development - Tests vor Code schreiben |
| **Mastra** | AI Agent Framework für Production |
| **Convex** | Realtime Database mit Vector Search |
| **Skill** | Claude Code Befehl (z.B. `/plan-feature`) |
| **Delivery Unit** | Was wir an Kunden liefern (Agent, Workflow, etc.) |
| **Upstream** | Das Agent Kit Template |
| **Downstream** | Projekte, die vom Template erstellt wurden |

### Weiterführende Dokumentation

| Dokument | Inhalt |
|----------|--------|
| `CLAUDE.md` | Entwicklungsregeln und Konventionen |
| `WORKFLOW.md` | Detaillierter Workflow-Guide |
| `.claude/PRD.md` | Product Requirements Template |
| `.claude/reference/aidd-methodology.md` | AIDD im Detail |
| `.claude/reference/design-system.md` | UI/UX Guidelines |

---

*Lucid Labs GmbH - Agent Kit*
*Version 1.0 - Januar 2026*
