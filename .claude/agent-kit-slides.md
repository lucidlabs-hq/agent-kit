# Agent Kit - Präsentation für NotebookLM

> **Zweck:** Diese Slides sind für die Präsentation an die Geschäftsführung gedacht.
> Sie zeigen unseren Tech Stack, warum wir diese Tools gewählt haben, und welche Bereiche wir damit abdecken.

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

## SLIDE 10: Tech Stack - Kurzübersicht

**Das Gesamtsystem auf einen Blick:**

```
┌─────────────────────────────────────────────────────────────────┐
│                     LUCID LABS AI STACK 2026                     │
├─────────────────────────────────────────────────────────────────┤
│  STANDARD (immer dabei)                                          │
│  ───────────────────────                                         │
│  Next.js 15 │ Claude │ Linear │ Productive.io                   │
├─────────────────────────────────────────────────────────────────┤
│  WÄHLBAR (eins pro Kategorie)                                    │
│  ─────────────────────────────                                   │
│  AI:   Mastra (Production)  │  Vercel AI SDK (Prototype)        │
│  DB:   Convex (Realtime)    │  Postgres (SQL)                   │
├─────────────────────────────────────────────────────────────────┤
│  OPTIONAL (nach Bedarf)                                          │
│  ───────────────────────                                         │
│  Portkey │ n8n │ Python │ LangChain │ Pinecone │ Terraform      │
└─────────────────────────────────────────────────────────────────┘
```

**Detaillierte Stack-Referenz:** Siehe Anhang A

---

## SLIDE 10b: Stack-Abdeckung - Alle Bereiche

**Unser Stack deckt alle relevanten AI-Kategorien ab:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    LUCID LABS STACK - VOLLSTÄNDIGE ABDECKUNG                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌─────────────────────────────┐    ┌─────────────────────────────────────────┐ │
│  │   FOUNDATION MODELS         │    │   AUTOMATION / AGENTEN                  │ │
│  │   ════════════════════      │    │   ═══════════════════════               │ │
│  │                             │    │                                         │ │
│  │   ✅ Anthropic (Claude)     │    │   ✅ Mastra (Primary)                   │ │
│  │   ✅ Azure OpenAI (GDPR)    │    │   ✅ n8n (Workflows)                    │ │
│  │   ✅ Mistral (EU, schnell)  │    │   ⚪ LangChain (Complex)                │ │
│  │   ⚪ OpenAI (via Portkey)   │    │                                         │ │
│  │   ⚪ Gemini (via Portkey)   │    │   → 100% abgedeckt                      │ │
│  │                             │    │                                         │ │
│  │   → 100% abgedeckt          │    └─────────────────────────────────────────┘ │
│  └─────────────────────────────┘                                                │
│                                                                                  │
│  ┌─────────────────────────────┐    ┌─────────────────────────────────────────┐ │
│  │   ORCHESTRATION             │    │   EVALUATION & OBSERVABILITY           │ │
│  │   ═════════════             │    │   ═══════════════════════════          │ │
│  │                             │    │                                         │ │
│  │   ✅ Vercel AI SDK          │    │   ✅ Promptfoo (Evaluation)             │ │
│  │   ✅ Portkey (Gateway)      │    │   ⚪ Helicone (Observability)           │ │
│  │   ✅ Mastra (Agents)        │    │   ⚪ Portkey (Cost Tracking)            │ │
│  │                             │    │                                         │ │
│  │   → 100% abgedeckt          │    │   → 80% abgedeckt (ausreichend)         │ │
│  └─────────────────────────────┘    └─────────────────────────────────────────┘ │
│                                                                                  │
│  ┌─────────────────────────────┐    ┌─────────────────────────────────────────┐ │
│  │   CLOUD / HOSTING           │    │   DATA / STORAGE                        │ │
│  │   ══════════════            │    │   ══════════════                        │ │
│  │                             │    │                                         │ │
│  │   ✅ Elestio (Self-hosted)  │    │   ✅ Convex (Realtime + Vector)         │ │
│  │   ✅ Azure (GDPR)           │    │   ⚪ Postgres (SQL)                     │ │
│  │   ⚪ Vercel (Prototypen)    │    │   ⚪ Pinecone (Enterprise RAG)          │ │
│  │                             │    │   ⚪ MinIO (S3 Storage)                 │ │
│  │   → 100% abgedeckt          │    │                                         │ │
│  │                             │    │   → 100% abgedeckt                      │ │
│  └─────────────────────────────┘    └─────────────────────────────────────────┘ │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│  LEGENDE:  ✅ = Im Stack (Standard/Gesetzt)   ⚪ = Optional (nach Bedarf)       │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## SLIDE 10c: Warum dieser Stack?

**Unsere Entscheidungskriterien:**

| Kriterium | Wie wir entscheiden |
|-----------|---------------------|
| **Geschwindigkeit** | Schnell starten, schnell iterieren |
| **GDPR** | EU-Hosting möglich, deutsche Daten in Deutschland |
| **Kosten** | Self-hosted wo sinnvoll, managed wo nötig |
| **Flexibilität** | Modular - Komponenten austauschbar |
| **Wartung** | Wenige Tools, die viel können |

**Was wir NICHT machen:**
- ❌ Zu viele Tools gleichzeitig einführen
- ❌ Komplexität ohne klaren Nutzen
- ❌ Vendor Lock-in

---

## SLIDE 10d: Foundation Models im Detail

**Unsere LLM-Strategie:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    LLM PROVIDER STRATEGIE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PRIMARY (Standard)                                              │
│  ─────────────────                                               │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  ANTHROPIC CLAUDE                                           ││
│  │  • Opus 4.5   → Komplexe Reasoning, höchste Qualität        ││
│  │  • Sonnet 4   → Code, Balance aus Speed/Qualität            ││
│  │  • Haiku      → Schnelle Tasks, hohe Volumen                ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│  GDPR / EU (wenn nötig)                                          │
│  ─────────────────────                                           │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  AZURE OPENAI          │  MISTRAL                           ││
│  │  • GPT-4o, GPT-4 Turbo │  • Mistral Large, Medium           ││
│  │  • EU Data Residency   │  • EU Company (Paris)              ││
│  │  • Für Banken/Vers.    │  • Schnell & günstig               ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│  VIA PORTKEY (optional, alle anderen)                            │
│  ────────────────────────────────────                            │
│  OpenAI │ Google Gemini │ Llama │ 1,600+ weitere Models         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Warum Mistral?**
- EU-Unternehmen (Paris) → GDPR-freundlich
- Sehr gute Performance bei niedrigeren Kosten
- Wir haben es bereits erfolgreich eingesetzt

---

## SLIDE 11: Wer macht was?

**Verantwortlichkeiten im Stack:**

```
┌─────────────────────────────────────────────────────────────────┐
│  MASTRA            PYTHON WORKERS      CONVEX/POSTGRES          │
│  ──────            ──────────────      ────────────────         │
│  Decision Layer    Computation         State & Sync             │
│                                                                  │
│  • Entscheidet     • Rechnet           • Speichert              │
│  • Erklärt         • Parst             • Synchronisiert         │
│  • Formuliert      • Aggregiert        • Realtime               │
├─────────────────────────────────────────────────────────────────┤
│  N8N               PORTKEY             LINEAR/PRODUCTIVE        │
│  ───               ───────             ─────────────────        │
│  Automation        Gateway             Governance               │
│                                                                  │
│  • Webhooks        • Routing           • Tracking               │
│  • Scheduling      • Cost Tracking     • Reporting              │
│  • Integrations    • Fallbacks         • Budgets                │
└─────────────────────────────────────────────────────────────────┘
```

---

## SLIDE 12: Projektkomplexität

**Welcher Stack für welches Projekt?**

| Stufe | Projekt-Typ | Stack |
|-------|-------------|-------|
| **1** | MVP/Prototype | Vercel AI SDK + Convex |
| **2** | Standard Agent | Mastra + Convex |
| **3** | Enterprise | + Portkey + n8n |
| **4** | GDPR/Compliance | + Azure OpenAI + Postgres |

---

## SLIDE 13: Governance - Linear

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

## SLIDE 14: Governance - Productive.io

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

## SLIDE 15: Delivery Units

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

## SLIDE 16: Der Entwicklungsworkflow

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

## SLIDE 17: Upstream/Downstream Modell

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

## SLIDE 17b: Wie funktioniert der Workflow?

**Der Entwicklungs-Kreislauf:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        AGENT KIT ENTWICKLUNGSKREISLAUF                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   1. PROJEKT ERSTELLEN                                                          │
│   ════════════════════                                                          │
│                                                                                  │
│   /init-project customer-portal                                                 │
│        │                                                                         │
│        ▼                                                                         │
│   ┌─────────────────┐                ┌─────────────────────────────────┐        │
│   │   Agent Kit     │ ──────────────▶│  projects/customer-portal/      │        │
│   │   (Template)    │   Kopiert      │  (Neues Projekt)                │        │
│   └─────────────────┘   Boilerplate  └─────────────────────────────────┘        │
│                                                                                  │
│                                                                                  │
│   2. IM PROJEKT ENTWICKELN                                                      │
│   ════════════════════════                                                      │
│                                                                                  │
│   cd projects/customer-portal                                                   │
│   claude                                                                        │
│   /plan-feature → /execute → /validate → /commit                               │
│                                                                                  │
│   → Neue Skills entstehen                                                       │
│   → Neue Patterns werden entdeckt                                               │
│   → Best Practices etabliert                                                    │
│                                                                                  │
│                                                                                  │
│   3. BEST PRACTICES ZURÜCKFÜHREN (PROMOTE)                                      │
│   ════════════════════════════════════════                                      │
│                                                                                  │
│   /promote                                                                       │
│        │                                                                         │
│        ▼                                                                         │
│   ┌─────────────────────────────────┐                                           │
│   │  "Welche Patterns sind generisch │                                           │
│   │   und sollten ins Template?"     │                                           │
│   │                                  │                                           │
│   │  [x] .claude/skills/new-skill/   │                                           │
│   │  [x] lib/utils/helper.ts         │                                           │
│   │  [ ] Domain-spezifischer Code    │ ← Bleibt im Projekt                      │
│   └─────────────────────────────────┘                                           │
│        │                                                                         │
│        ▼                                                                         │
│   ┌─────────────────────────────────┐                                           │
│   │  GitHub Pull Request erstellt   │                                           │
│   │  → Review durch Team            │                                           │
│   │  → Merge ins Template           │                                           │
│   └─────────────────────────────────┘                                           │
│                                                                                  │
│                                                                                  │
│   4. UPDATES HOLEN (SYNC)                                                       │
│   ═══════════════════════                                                       │
│                                                                                  │
│   /sync                                                                          │
│        │                                                                         │
│        ▼                                                                         │
│   ┌─────────────────┐                ┌─────────────────────────────────┐        │
│   │   Agent Kit     │ ──────────────▶│  projects/customer-portal/      │        │
│   │ (neue Version)  │   Sync neue    │  (bestehendes Projekt)          │        │
│   └─────────────────┘   Skills       └─────────────────────────────────┘        │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## SLIDE 17c: Warum dieser Workflow?

**Kontinuierliche Verbesserung:**

| Problem | Lösung |
|---------|--------|
| "Jedes Projekt erfindet das Rad neu" | Template mit Best Practices |
| "Wissen geht verloren" | Promote zurück ins Template |
| "Alte Projekte haben keine neuen Features" | Sync holt Updates |
| "Keine Qualitätskontrolle" | PR-Review vor Merge |

**Der Effekt:**

```
Projekt 1 → Entdeckt Pattern A → Promote → PR → Review → Merge
                                                    ↓
Projekt 2 ←──────────────────────────────── Sync ──┘
Projekt 3 ←──────────────────────────────── Sync ──┘
Projekt 4 ←──────────────────────────────── Sync ──┘

→ Alle Projekte profitieren von den Learnings!
```

**Qualitätssicherung:**
- Jedes Promote geht durch einen Pull Request
- Team reviewed ob das Pattern generisch genug ist
- Nur getestete, dokumentierte Patterns kommen rein

---

## SLIDE 17d: Was wird promotet, was nicht?

**Klare Trennung:**

| ✅ PROMOTABLE (generisch) | ❌ NICHT PROMOTABLE (projekt-spezifisch) |
|---------------------------|------------------------------------------|
| Skills (`.claude/skills/`) | PRD (`.claude/PRD.md`) |
| Reference Docs | App Pages (`app/`) |
| UI Components (`components/ui/`) | Domain Agents |
| Utility Functions (`lib/utils/`) | Database Schema |
| Scripts | Projekt-Konfiguration |

**Beispiele:**

```
✅ Ein neuer /pdf-analyze Skill         → Ins Template
✅ Ein verbesserter Error Handler       → Ins Template
✅ Eine generische DataTable Component  → Ins Template

❌ Kunden-spezifische API Integration   → Bleibt im Projekt
❌ Domain-spezifisches Datenmodell      → Bleibt im Projekt
❌ Projekt-PRD                          → Bleibt im Projekt
```

---

## SLIDE 18: Projekt-Setup

**In unter 10 Minuten:**

```bash
./scripts/create-agent-project.sh --interactive
```

**Intelligente Empfehlung:**
1. Beschreibe dein Projekt
2. Erhalte Stack-Empfehlung basierend auf Komplexität
3. Bestätige oder passe an
4. Projekt wird erstellt

---

## SLIDE 19: Qualitätssicherung

**Validierung auf 4 Ebenen:**

| Ebene | Tool | Prüft |
|-------|------|-------|
| **Automatisch** | TypeScript, ESLint | Syntax, Types |
| **TDD** | Vitest | Funktionalität |
| **AI Review** | Greptile | Bugs, Security |
| **Human Review** | GitHub PR | Architektur |

---

## SLIDE 20: Vorteile

**Für alle Stakeholder:**

| Rolle | Vorteil |
|-------|---------|
| **Entwickler** | Schneller Start, klare Patterns |
| **Tech Lead** | Konsistenz, Governance |
| **PM** | Transparenz, Phasen |
| **Kunde** | Qualität, Nachvollziehbarkeit |

---

## SLIDE 21: Zusammenfassung

**Agent Kit ist:**

1. **Ein Framework** - Plattform für viele Projekte
2. **Methodengetrieben** - AIDD, PIV, TDD
3. **Modular** - Wähle passende Komponenten
4. **Wiederverwendbar** - Promote/Sync
5. **Transparent** - Linear + Productive.io

---

## SLIDE 22: In einem Satz

> **Agent Kit ermöglicht es Teams, AI-gestützte Anwendungen schnell, konsistent und qualitativ hochwertig zu entwickeln - mit klaren Methoden, bewährten Technologien und transparenter Governance.**

---

## SLIDE 23: Was bewusst NICHT im Stack ist (noch)

**Bewertung: Zusätzliche Tools**

| Tool | Kategorie | Status | Begründung |
|------|-----------|--------|------------|
| **Langfuse** | Observability | 🔵 Future | Portkey + Promptfoo reichen erstmal |
| **Temporal** | Workflows | ❌ Nicht nötig | n8n + Mastra decken das ab |
| **LlamaIndex** | Orchestration | ❌ Nicht nötig | Mastra + Convex Vector reichen |
| **OpenTelemetry** | Tracing | 🔵 Future | Erst bei komplexem Debugging |
| **Autogen** | RPA | ❌ Nicht nötig | Mastra ist unser Agent Framework |

**Prinzip:** Weniger Tools = schnellere Bewegung

---

## SLIDE 24: Future Plan (Nach Bedarf)

**Diese Tools evaluieren wir, wenn der Bedarf entsteht:**

| Tool | Wann relevant? | Trigger |
|------|----------------|---------|
| **Langfuse** | Tracing & Prompt-Mgmt | Multi-Step Agent Debugging nötig |
| **OpenTelemetry** | Full-Stack Tracing | Performance-Probleme in Prod |
| **Helicone** | LLM Observability | Portkey reicht nicht mehr |

**Nicht auf der Roadmap:**
- Temporal (n8n reicht)
- LlamaIndex (Mastra reicht)
- Autogen (Mastra ist besser)

---

## SLIDE 25: Nächste Schritte

1. Agent Kit Repository klonen
2. `/init-project` ausführen
3. Projektbeschreibung eingeben
4. Stack-Empfehlung erhalten
5. Loslegen!

---

# ANHANG A: Vollständige Stack-Referenz

## Das Gesamtbild

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           LUCID LABS AI STACK 2026                               │
│                                                                                  │
│  ═══════════════════════════════════════════════════════════════════════════════ │
│  ║                         IMMER DABEI (STANDARD)                              ║ │
│  ═══════════════════════════════════════════════════════════════════════════════ │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                              CLIENTS                                       │  │
│  │                                                                            │  │
│  │   ┌─────────────────┐                                                      │  │
│  │   │    NEXT.JS 15   │  ← STANDARD: Immer dabei                             │  │
│  │   │    (Frontend)   │    • App Router, Server Components                   │  │
│  │   │                 │    • shadcn/ui, Tailwind CSS 4                       │  │
│  │   │                 │    • TypeScript strict                               │  │
│  │   └─────────────────┘                                                      │  │
│  │                                                                            │  │
│  │   ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐           │  │
│  │   │   CLI Tool      │  │   Python SDK    │  │     Mobile      │           │  │
│  │   │   (Optional)    │  │   (Optional)    │  │    (Später)     │           │  │
│  │   └─────────────────┘  └─────────────────┘  └─────────────────┘           │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                       │                                          │
│                                       ▼                                          │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                           LLM PROVIDER                                     │  │
│  │                                                                            │  │
│  │   ┌─────────────────────────────────────────────────────────────────────┐ │  │
│  │   │                    ANTHROPIC CLAUDE                                  │ │  │
│  │   │                      (STANDARD)                                      │ │  │
│  │   │                                                                      │ │  │
│  │   │   • Claude Opus 4.5    → Complex Reasoning, Qualität                 │ │  │
│  │   │   • Claude Sonnet 4    → Code Generation, Balance                    │ │  │
│  │   │   • Claude Haiku       → Schnelle Tasks, Volumen                     │ │  │
│  │   └─────────────────────────────────────────────────────────────────────┘ │  │
│  │                                                                            │  │
│  │   ┌─────────────────────────────────────────────────────────────────────┐ │  │
│  │   │                    AZURE OPENAI (OPTIONAL)                           │ │  │
│  │   │                                                                      │ │  │
│  │   │   • Für GDPR-Compliance                                              │ │  │
│  │   │   • EU Data Residency                                                │ │  │
│  │   │   • Wenn Kunde Azure-only verlangt                                   │ │  │
│  │   └─────────────────────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                       │                                          │
│                                       ▼                                          │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                         PROJECT MANAGEMENT                                 │  │
│  │                            (STANDARD)                                      │  │
│  │                                                                            │  │
│  │   ┌─────────────────────────┐    ┌─────────────────────────────┐          │  │
│  │   │        LINEAR           │    │      PRODUCTIVE.IO          │          │  │
│  │   │   Execution Tracking    │    │    Customer Value           │          │  │
│  │   │                         │    │                             │          │  │
│  │   │   • Issues & Status     │    │   • Delivery Units          │          │  │
│  │   │   • AIDD Workflow       │    │   • Budgets & Zeit          │          │  │
│  │   │   • Sprint Planning     │    │   • Kunden-Reporting        │          │  │
│  │   └─────────────────────────┘    └─────────────────────────────┘          │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ═══════════════════════════════════════════════════════════════════════════════ │
│  ║                      WÄHLBAR (EINS PRO KATEGORIE)                           ║ │
│  ═══════════════════════════════════════════════════════════════════════════════ │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                      AI LAYER - Wähle eins:                                │  │
│  │                                                                            │  │
│  │   ┌─────────────────────────────┐    ┌─────────────────────────────┐      │  │
│  │   │      VERCEL AI SDK          │ OR │          MASTRA             │      │  │
│  │   │      (Prototypen)           │    │    (Production Agents)      │      │  │
│  │   │                             │    │                             │      │  │
│  │   │   Wann:                     │    │   Wann:                     │      │  │
│  │   │   • Schnelle Demos          │    │   • Production-ready        │      │  │
│  │   │   • Chat-UI                 │    │   • Tools & Workflows       │      │  │
│  │   │   • Keine Tools nötig       │    │   • Multi-Step Agents       │      │  │
│  │   │   • POC in 1-2 Tagen        │    │   • Structured Outputs      │      │  │
│  │   └─────────────────────────────┘    └─────────────────────────────┘      │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                       │                                          │
│                                       ▼                                          │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                     DATA LAYER - Wähle eins:                               │  │
│  │                                                                            │  │
│  │   ┌─────────────────────────────┐    ┌─────────────────────────────┐      │  │
│  │   │          CONVEX             │ OR │        POSTGRES             │      │  │
│  │   │    (Realtime, Simple)       │    │    (SQL, Flexible)          │      │  │
│  │   │                             │    │                             │      │  │
│  │   │   Wann:                     │    │   Wann:                     │      │  │
│  │   │   • Realtime UI nötig       │    │   • SQL-Anforderungen       │      │  │
│  │   │   • Schnelles Setup         │    │   • Pinecone gewünscht      │      │  │
│  │   │   • Built-in Vectors ok     │    │   • Max. Kontrolle          │      │  │
│  │   └─────────────────────────────┘    └─────────────────────────────┘      │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ═══════════════════════════════════════════════════════════════════════════════ │
│  ║                         OPTIONAL (NACH BEDARF)                              ║ │
│  ═══════════════════════════════════════════════════════════════════════════════ │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                         LLM GATEWAY                                        │  │
│  │                                                                            │  │
│  │   ┌─────────────────────────────────────────────────────────────────────┐ │  │
│  │   │                       PORTKEY                                        │ │  │
│  │   │                                                                      │ │  │
│  │   │   Wann hinzufügen:                                                   │ │  │
│  │   │   • Cost Tracking pro Kunde/Team nötig                               │ │  │
│  │   │   • Multi-Model Routing (1,600+ Models)                              │ │  │
│  │   │   • Guardrails & Rate Limiting                                       │ │  │
│  │   │   • Fallback & Load Balancing                                        │ │  │
│  │   └─────────────────────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                        COMPUTE LAYER                                       │  │
│  │                                                                            │  │
│  │   ┌─────────────────────────────────────────────────────────────────────┐ │  │
│  │   │                    PYTHON WORKERS                                    │ │  │
│  │   │                     (via Elestio)                                    │ │  │
│  │   │                                                                      │ │  │
│  │   │   Wann hinzufügen:                                                   │ │  │
│  │   │   • PDF Parsing, OCR                                                 │ │  │
│  │   │   • Data Aggregation & Statistik                                     │ │  │
│  │   │   • ML Models (nicht LLM)                                            │ │  │
│  │   │   • Heavy Computation                                                │ │  │
│  │   └─────────────────────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                       AUTOMATION LAYER                                     │  │
│  │                                                                            │  │
│  │   ┌─────────────────────────────────────────────────────────────────────┐ │  │
│  │   │                          N8N                                         │ │  │
│  │   │                                                                      │ │  │
│  │   │   Wann hinzufügen:                                                   │ │  │
│  │   │   • Externe Integrationen (CRM, ERP, etc.)                           │ │  │
│  │   │   • Scheduled Jobs & Cron                                            │ │  │
│  │   │   • Webhook Handling                                                 │ │  │
│  │   │   • Email/Slack Notifications                                        │ │  │
│  │   └─────────────────────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                      ADVANCED AI (SELTEN)                                  │  │
│  │                                                                            │  │
│  │   ┌─────────────────────────┐    ┌─────────────────────────────┐          │  │
│  │   │       LANGCHAIN         │    │        PINECONE             │          │  │
│  │   │   Komplexe Chains       │    │   Enterprise Vector DB      │          │  │
│  │   └─────────────────────────┘    └─────────────────────────────┘          │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                         INFRASTRUCTURE                                     │  │
│  │                                                                            │  │
│  │   ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐           │  │
│  │   │    TERRAFORM    │  │      MINIO      │  │    GREPTILE     │           │  │
│  │   │   IaC, Deploy   │  │   S3 Storage    │  │   Code Review   │           │  │
│  │   └─────────────────┘  └─────────────────┘  └─────────────────┘           │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## ANHANG B: Komponenten-Referenz mit Links

### STANDARD (Immer dabei)

| Komponente | Rolle | Website |
|------------|-------|---------|
| **Next.js 15** | Frontend Framework | [nextjs.org](https://nextjs.org) |
| **Claude** | LLM Provider | [anthropic.com](https://www.anthropic.com) |
| **Linear** | Issue Tracking | [linear.app](https://linear.app) |
| **Productive.io** | Customer Value | [productive.io](https://productive.io) |
| **Tailwind CSS 4** | Styling | [tailwindcss.com](https://tailwindcss.com) |
| **shadcn/ui** | UI Components | [ui.shadcn.com](https://ui.shadcn.com) |

### LLM PROVIDER (Alle verfügbar)

| Provider | Rolle | Wann? | Website |
|----------|-------|-------|---------|
| **Anthropic Claude** | Primary LLM | Standard, höchste Qualität | [anthropic.com](https://anthropic.com) |
| **Mistral** | EU LLM | GDPR-freundlich, schnell, günstig | [mistral.ai](https://mistral.ai) |
| **Azure OpenAI** | GDPR LLM | Banken, Versicherungen, EU Data | [azure.microsoft.com](https://azure.microsoft.com/en-us/products/ai-services/openai-service) |
| **OpenAI** | Via Portkey | Wenn Claude nicht passt | [openai.com](https://openai.com) |
| **Google Gemini** | Via Portkey | Spezialfälle | [ai.google.dev](https://ai.google.dev) |

### WÄHLBAR (Eins pro Kategorie)

| Komponente | Rolle | Wann? | Website |
|------------|-------|-------|---------|
| **Mastra** | AI Agents (Production) | Tools, Workflows, Multi-Step | [mastra.ai](https://mastra.ai) |
| **Vercel AI SDK** | AI (Prototype) | Chat, Streaming, Quick POC | [sdk.vercel.ai](https://sdk.vercel.ai) |
| **Convex** | Database (Realtime) | Realtime, Built-in Vector | [convex.dev](https://convex.dev) |
| **Postgres** | Database (SQL) | SQL, Pinecone, Max Control | [postgresql.org](https://postgresql.org) |

### OPTIONAL (Nach Bedarf)

| Komponente | Rolle | Wann? | Website |
|------------|-------|-------|---------|
| **Portkey** | LLM Gateway | Cost Tracking, Multi-Model | [portkey.ai](https://portkey.ai) |
| **n8n** | Automation | Externe Integrationen | [n8n.io](https://n8n.io) |
| **Python Workers** | Compute | PDF, OCR, ML | - |
| **LangChain** | Advanced AI | Complex Chains | [langchain.com](https://langchain.com) |
| **Pinecone** | Vector DB | Enterprise RAG | [pinecone.io](https://pinecone.io) |
| **Terraform** | IaC | Production Deploy | [terraform.io](https://terraform.io) |
| **MinIO** | Storage | S3-compatible | [min.io](https://min.io) |
| **Greptile** | Code Review | Auto PR Reviews | [greptile.com](https://greptile.com) |
| **Azure OpenAI** | GDPR LLM | EU Data Residency | [azure.microsoft.com](https://azure.microsoft.com/en-us/products/ai-services/openai-service) |
| **Elestio** | Hosting | Self-hosted | [elest.io](https://elest.io) |

---

## ANHANG C: Entscheidungsmatrix

### Nach Projektkomplexität

| Stufe | Projekttyp | Stack | Zeitrahmen |
|-------|------------|-------|------------|
| **1** | MVP/Prototype | Vercel AI SDK + Convex | 1-2 Wochen |
| **2** | Standard Agent | Mastra + Convex | 2-8 Wochen |
| **3** | Enterprise | + Portkey + n8n | 8+ Wochen |
| **4** | GDPR/Compliance | + Azure OpenAI + Postgres | 8+ Wochen |

### Quick Decision Trees

**AI Layer:**
```
Brauche ich Tools/Workflows? → JA → Mastra
                             → NEIN → Vercel AI SDK
```

**Database:**
```
Brauche ich Realtime? → JA → Convex
                      → NEIN → Brauche ich SQL? → JA → Postgres
                                                → NEIN → Convex
```

**Optional Components:**
```
Cost Tracking?        → Portkey
Externe APIs?         → n8n
PDF/ML Processing?    → Python Workers
EU Data Residency?    → Azure OpenAI
Enterprise Vectors?   → Pinecone
```

---

## ANHANG D: Glossar

| Begriff | Definition |
|---------|------------|
| **AIDD** | Adaptive AI Discovery & Delivery - Methodik |
| **PIV** | Plan-Implement-Validate Loop |
| **TDD** | Test-Driven Development |
| **Mastra** | AI Agent Framework für Production |
| **Convex** | Realtime Database mit Vector Search |
| **Skill** | Claude Code Befehl (z.B. `/prime`) |
| **Delivery Unit** | Liefereinheit (Agent, Workflow, etc.) |
| **Upstream** | Agent Kit Template |
| **Downstream** | Abgeleitetes Projekt |
| **Decision Layer** | AI evaluiert, rechnet nicht |

---

*Diese Slide-Struktur ist für NotebookLM optimiert.*
*Lucid Labs GmbH - Januar 2026*
