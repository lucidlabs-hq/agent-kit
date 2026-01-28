# Agent Kit - Präsentation für NotebookLM

> Dieses Dokument ist als Slide-Struktur für NotebookLM aufgebaut. Jeder Abschnitt entspricht einer Folie oder Foliengruppe.

---

## SLIDE 1: Titelfolie

**Agent Kit**
*AI-Gestützte Softwareentwicklung*

Lucid Labs GmbH
Januar 2026

---

## SLIDE 2: Das Problem

**AI-Projekte scheitern oft an:**

1. **Fehlender Struktur**
   - Jedes Projekt startet bei Null
   - Wissen geht verloren

2. **AI-Qualitätsrisiken**
   - AI generiert Code ohne Kontext
   - Keine systematische Validierung

3. **Ineffiziente Workflows**
   - Vermischung von Planung und Umsetzung
   - Scope Creep durch AI

4. **Fehlende Transparenz**
   - Fortschritt schwer messbar
   - Kunden verstehen AI-Arbeit nicht

---

## SLIDE 3: Die Lösung

**Agent Kit - Drei Säulen:**

```
┌─────────────────────────────────────────────────────────┐
│                                                          │
│  METHODOLOGY     TECHNOLOGY      GOVERNANCE              │
│                                                          │
│  Wie wir         Womit wir       Wie wir                 │
│  arbeiten        bauen           liefern                 │
│                                                          │
│  • AIDD          • Mastra        • Linear                │
│  • PIV Loop      • Convex        • Productive.io         │
│  • TDD           • Next.js       • Code Review           │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## SLIDE 4: Philosophie - Kernprinzipien

**5 Grundprinzipien:**

1. **Explizite Phasen** - Keine Vermischung von Arbeitsschritten
2. **AI als Decision Layer** - AI entscheidet, rechnet nicht
3. **Tests definieren Erfolg** - Tests vor Code
4. **Exploration vs Delivery** - Trennung von Forschung und Umsetzung
5. **Wert vor Tasks** - Fokus auf Liefereinheiten

---

## SLIDE 5: AIDD Methodik - Übersicht

**Adaptive AI Discovery & Delivery**

```
EXPLORATION      →      DECISION      →      DELIVERY
─────────────           ─────────            ────────

Recherche               Proceed?             Implementieren
Prototypen              Pivot?               Testen
Validieren              Drop?                Deployen
Lernen                  Iterate?

KEIN ZEITDRUCK          BEWUSSTE             VERBINDLICHE
                        ENTSCHEIDUNG         TIMELINE
```

---

## SLIDE 6: AIDD - Entscheidungspunkte

**Am Decision-Punkt gibt es 4 Optionen:**

| Option | Bedeutung | Nächster Schritt |
|--------|-----------|------------------|
| **Proceed** | Weiter zur Delivery | Implementierung starten |
| **Pivot** | Richtung ändern | Zurück zu Exploration |
| **Drop** | Arbeit stoppen | Valides Ende |
| **Iterate** | Weiterforschen | In Exploration bleiben |

**Wichtig:** "Drop" ist ein gültiges Ergebnis, kein Scheitern.

---

## SLIDE 7: PIV Loop - Der operative Zyklus

**Plan - Implement - Validate**

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│             │     │             │     │             │
│    PLAN     │────▶│  IMPLEMENT  │────▶│  VALIDATE   │
│             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
       │                                       │
       └───────────── ITERATE ◀────────────────┘
```

**Regel:** Nie zwei Phasen gleichzeitig. Jeder Fix = neuer Zyklus.

---

## SLIDE 8: PIV Loop - Phasenregeln

**Was ist in jeder Phase erlaubt?**

| Phase | ✅ Erlaubt | ❌ Verboten |
|-------|-----------|------------|
| **PLAN** | Recherche, Analyse, Tests definieren | Code schreiben |
| **IMPLEMENT** | Tests schreiben, Code schreiben | Scope ändern |
| **VALIDATE** | Prüfen, Tests ausführen | Bugs fixen |

**Bei Bugs:** Neuen PIV-Zyklus starten, nicht innerhalb Validate fixen.

---

## SLIDE 9: TDD - Test Driven Development

**Warum TDD mit AI?**

```
┌─────────┐        ┌─────────┐        ┌───────────┐
│   RED   │───────▶│  GREEN  │───────▶│ REFACTOR  │
│         │        │         │        │           │
│  Test   │        │  Code   │        │  Improve  │
│  fails  │        │  passes │        │  Code     │
└─────────┘        └─────────┘        └───────────┘
```

| Ohne TDD | Mit TDD |
|----------|---------|
| AI rät Verhalten | Tests definieren Verhalten |
| Nachträgliche Tests | Tests fangen Bugs vorher |
| Unklare Erfolge | Grüne Tests = Erfolg |

---

## SLIDE 10: Technology Stack - Übersicht

**Modularer Stack:**

```
┌─────────────────────────────────────────────────────────┐
│                        CLIENTS                           │
│     Web App (Next.js)  │  CLI  │  Python SDK            │
├─────────────────────────────────────────────────────────┤
│                     AI LAYER (wählbar)                   │
│     Mastra (Production)  │  Vercel AI SDK (Prototype)   │
├─────────────────────────────────────────────────────────┤
│                    DATA LAYER (wählbar)                  │
│     Convex (Realtime)  │  Postgres (SQL)                │
├─────────────────────────────────────────────────────────┤
│                    OPTIONAL                              │
│     Portkey  │  n8n  │  Python  │  LangChain            │
└─────────────────────────────────────────────────────────┘
```

---

## SLIDE 11: AI Layer - Mastra vs Vercel AI SDK

**Wann welches Tool?**

| Kriterium | Mastra | Vercel AI SDK |
|-----------|--------|---------------|
| **Use Case** | Production Agents | Prototypen |
| **Features** | Tools, Workflows, Multi-Step | Chat UI, Streaming |
| **Komplexität** | Strukturiert, Type-safe | Einfach, schnell |
| **Setup** | Mehr Konfiguration | Minimal |

**Mastra Design Principle:**
> "Agents rechnen nicht. Sie evaluieren vorverarbeitete Ergebnisse."

---

## SLIDE 12: Data Layer - Convex vs Postgres

**Wann welche Datenbank?**

| Kriterium | Convex | Postgres |
|-----------|--------|----------|
| **Use Case** | Realtime Apps | SQL-Anforderungen |
| **Vector Search** | Built-in | Pinecone / pgvector |
| **Setup** | Einfach | Mehr Konfiguration |
| **Kontrolle** | Managed | Maximal |

---

## SLIDE 13: Optional Components

**Nach Bedarf hinzufügen:**

| Komponente | Zweck | Wann nutzen? |
|------------|-------|--------------|
| **Portkey** | LLM Gateway, Cost Tracking | Multi-Model, Budgets |
| **n8n** | Workflow Automation | Externe Integrationen |
| **Python** | PDF, OCR, ML Compute | Heavy Processing |
| **LangChain** | Complex Agent Chains | Mastra reicht nicht |
| **Terraform** | Infrastructure as Code | Production Setup |

---

## SLIDE 14: Governance - Linear

**Execution Tracking:**

```
Backlog → Exploration → Decision → Delivery → Review → Done
                           ↓
                        Dropped
```

| Status | Deadline? | Zweck |
|--------|-----------|-------|
| Exploration | Nein | Zeitboxed Recherche |
| Decision | Nein | Steuerungspunkt |
| **Delivery** | **Ja** | Implementierung |
| Review | Nein | QA und Validation |

---

## SLIDE 15: Governance - Productive.io

**Customer Value Tracking:**

| Konzept | Bedeutung |
|---------|-----------|
| **Company** | Kundenorganisation |
| **Project** | Kundenengagement |
| **Delivery Unit** | Was wir liefern |
| **Budget** | Verfügbare Zeit/Geld |

**Beziehung:**
- Productive.io = WAS wir für Wert liefern
- Linear = WIE wir die Arbeit ausführen

---

## SLIDE 16: Delivery Units

**Was wir an Kunden liefern:**

| Typ | Beschreibung | Beispiel |
|-----|--------------|----------|
| **Agent** | Produktiver KI-Agent | Ticket-Klassifikation |
| **Workflow** | Automatisierte Abläufe | Onboarding-Prozess |
| **GPT/Prompt** | Prompt oder Set | Meeting Summarizer |
| **Integration** | Externe Anbindung | CRM-Connector |
| **Workshop** | Einzelner Workshop | AI Strategy |
| **Advisory** | Analyse, Beratung | Readiness Assessment |

---

## SLIDE 17: Der Entwicklungsworkflow

**Session-basiertes Arbeiten:**

```
SESSION START
/prime
→ Check Linear für aktive Issues
→ "Woran möchtest du arbeiten?"

            ↓

DEVELOPMENT
/plan-feature → /execute → /validate → /commit

            ↓

SESSION END
/session-end
→ Linear Ticket aktualisieren
→ Git Compliance prüfen
```

---

## SLIDE 18: Upstream/Downstream Modell

**Template-basierte Entwicklung:**

```
┌──────────────────────────────────────────────────────────┐
│                                                           │
│  UPSTREAM                         DOWNSTREAM              │
│  (Agent Kit)                      (Projekte)              │
│                                                           │
│  • Generic Skills     ──SYNC──▶   • Domain Logic          │
│  • Boilerplate                    • Project PRD           │
│  • Best Practices    ◀─PROMOTE─   • Custom Agents         │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

Patterns fließen zwischen Projekten!

---

## SLIDE 19: Projekt-Setup

**In unter 10 Minuten:**

```bash
./scripts/create-agent-project.sh --interactive
```

**Wählbar:**
1. AI Layer: Mastra oder Vercel AI SDK
2. Database: Convex oder Postgres
3. Optional: Portkey, n8n, Python, LangChain

**Ergebnis:** Vollständiges Projekt mit:
- Frontend (Next.js)
- AI Layer (nach Wahl)
- Database (nach Wahl)
- Entwicklungsdokumentation
- Skills und Workflows

---

## SLIDE 20: Beispiel - Ticket Agent

**Szenario:** Agent zur Ticket-Klassifikation

**Phase 1: Exploration**
- Ticket-Daten analysieren
- Kategorien definieren
- Prototyp bauen
- Ergebnis: 85% Accuracy

**Phase 2: Decision**
- Proceed (85% > 80% Anforderung)
- ROI: 20h/Woche Zeitersparnis

**Phase 3: Delivery**
- PIV 1: Datenmodell
- PIV 2: Agent mit TDD
- PIV 3: CRM-Integration

---

## SLIDE 21: Qualitätssicherung

**Validierung auf 4 Ebenen:**

| Ebene | Tool | Prüft |
|-------|------|-------|
| **Automatisch** | TypeScript, ESLint | Syntax, Types |
| **TDD** | Vitest | Funktionalität |
| **AI Review** | Greptile | Bugs, Security |
| **Human Review** | GitHub PR | Architektur |

**Pre-Production:**
`/pre-production` prüft Build, Tests, Security

---

## SLIDE 22: Vorteile - Für Teams

**Für Entwickler:**
- Schneller Projektstart (< 10 Min)
- Klare Patterns, keine Unsicherheit
- AI-Unterstützung mit Best Practices

**Für Tech Leads:**
- Konsistenz über alle Projekte
- TDD + automatische Reviews
- Governance via CLAUDE.md

**Für Projektmanager:**
- Transparenz durch Linear
- Klare Phasentrennung
- Steuerungspunkte durch AIDD

---

## SLIDE 23: Vorteile - Für Kunden

**Für Kunden:**

1. **Nachvollziehbarkeit**
   - Entscheidungen dokumentiert
   - Transparenter Fortschritt

2. **Qualität**
   - Standardisierte Lieferungen
   - Getesteter Code

3. **Flexibilität**
   - Exploration ohne Zeitdruck
   - Pivot jederzeit möglich

4. **Reporting**
   - Fortschritt in Productive.io
   - Service Dashboard Zugang

---

## SLIDE 24: Zusammenfassung

**Agent Kit ist:**

1. **Ein Framework** - Plattform für viele Projekte

2. **Methodengetrieben** - AIDD, PIV, TDD als Grundlage

3. **Modular** - Wähle passende Komponenten

4. **Wiederverwendbar** - Promote/Sync zwischen Projekten

5. **Transparent** - Linear + Productive.io Tracking

---

## SLIDE 25: Der Unterschied

| Traditionell | Mit Agent Kit |
|--------------|---------------|
| Jedes Projekt neu | Template-basiert |
| Ad-hoc AI-Integration | Strukturierte AI Layer |
| Unklare Phasen | AIDD + PIV |
| Manuelle Tests | TDD-First |
| Isolierte Learnings | Promote/Sync Workflow |

---

## SLIDE 26: In einem Satz

> **Agent Kit ermöglicht es Teams, AI-gestützte Anwendungen schnell, konsistent und qualitativ hochwertig zu entwickeln - mit klaren Methoden, bewährten Technologien und transparenter Governance.**

---

## SLIDE 27: Kontakt & Nächste Schritte

**Lucid Labs GmbH**

Nächste Schritte:
1. Agent Kit Repository klonen
2. Erstes Projekt mit `create-agent-project.sh` erstellen
3. `/prime` ausführen und loslegen

**Dokumentation:**
- `CLAUDE.md` - Entwicklungsregeln
- `WORKFLOW.md` - Workflow-Guide
- `.claude/reference/` - Best Practices

---

## APPENDIX A: Glossar

| Begriff | Definition |
|---------|------------|
| **AIDD** | Adaptive AI Discovery & Delivery |
| **PIV** | Plan-Implement-Validate Loop |
| **TDD** | Test-Driven Development |
| **Mastra** | AI Agent Framework |
| **Convex** | Realtime Database |
| **Skill** | Claude Code Befehl (z.B. `/prime`) |
| **Delivery Unit** | Liefereinheit (Agent, Workflow, etc.) |
| **Upstream** | Agent Kit Template |
| **Downstream** | Abgeleitetes Projekt |

---

## APPENDIX B: Skills Übersicht

| Skill | Beschreibung | Phase |
|-------|--------------|-------|
| `/prime` | Projekt-Kontext laden | Start |
| `/plan-feature` | Feature planen | Planning |
| `/execute` | Plan implementieren | Implementation |
| `/validate` | Compliance prüfen | Validation |
| `/commit` | Änderungen committen | Implementation |
| `/session-end` | Session beenden | Ende |

---

## APPENDIX C: Stack Entscheidungsmatrix

| Anforderung | AI Layer | Database |
|-------------|----------|----------|
| Chat Prototype | Vercel AI SDK | Convex |
| Production Agent | Mastra | Convex |
| SQL + Pinecone | Mastra | Postgres |
| Simple RAG | Either | Convex |
| Complex Analysis | Mastra + Python | Either |

---

*Diese Slide-Struktur ist für NotebookLM optimiert. Jeder Abschnitt mit "SLIDE" kann als einzelne Folie verwendet werden.*
