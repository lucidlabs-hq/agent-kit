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

## SLIDE 12b: Convex - Die All-in-One Datenbank

**Warum Convex unser Standard ist:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         CONVEX - BUILT FOR AI                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                                                                          │    │
│  │   EINE PLATTFORM - VIER FUNKTIONEN                                      │    │
│  │                                                                          │    │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │    │
│  │   │  DOCUMENT    │  │   REALTIME   │  │   VECTOR     │  │   FILE     │  │    │
│  │   │  DATABASE    │  │   SYNC       │  │   SEARCH     │  │   STORAGE  │  │    │
│  │   │              │  │              │  │              │  │            │  │    │
│  │   │  NoSQL-like  │  │  WebSocket   │  │  Embeddings  │  │  S3-like   │  │    │
│  │   │  Type-safe   │  │  Auto-sync   │  │  RAG-ready   │  │  Uploads   │  │    │
│  │   │  Queries     │  │  to UI       │  │  Built-in    │  │  CDN       │  │    │
│  │   └──────────────┘  └──────────────┘  └──────────────┘  └────────────┘  │    │
│  │                                                                          │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
│  VECTOR SEARCH - Was viele nicht wissen:                                        │
│  ───────────────────────────────────────                                        │
│                                                                                  │
│  Convex hat NATIVE Vector-Fähigkeiten!                                         │
│                                                                                  │
│  • Embeddings direkt in der Datenbank speichern                                 │
│  • Similarity Search ohne externe Services                                       │
│  • Kein Pinecone nötig für Standard-RAG                                         │
│  • Kombiniert mit Realtime = Live-updating RAG UI                               │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  // Beispiel: RAG mit Convex Vector                                      │    │
│  │                                                                          │    │
│  │  // 1. Embedding speichern                                               │    │
│  │  await ctx.db.insert("documents", {                                      │    │
│  │    content: "...",                                                       │    │
│  │    embedding: await embed(content)  // 1536-dim vector                   │    │
│  │  });                                                                     │    │
│  │                                                                          │    │
│  │  // 2. Similarity Search                                                 │    │
│  │  const results = await ctx.db                                            │    │
│  │    .query("documents")                                                   │    │
│  │    .withSearchIndex("embedding", q => q.vector(queryEmbedding, 10))     │    │
│  │    .collect();                                                           │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Kein Pinecone, kein Weaviate, kein Qdrant nötig für 90% der Projekte!**

---

## SLIDE 12c: Stack-Vergleich - Wann was?

**Trade-offs verstehen:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                      STACK TRADE-OFFS                                            │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  OPTION A: Convex + Mastra (UNSER STANDARD)                                     │
│  ══════════════════════════════════════════                                     │
│                                                                                  │
│  ✅ VORTEILE:                              ❌ GRENZEN:                          │
│  • Setup in Minuten                        • Kein SQL (NoSQL only)              │
│  • Zero-Config Realtime                    • Vendor Lock-in (Convex)            │
│  • Built-in Vector Search                  • Weniger Kontrolle                  │
│  • Type-safe aus der Box                   • Pricing ab ~100k Users             │
│  • Perfekt für AI-Prototypen                                                    │
│  • Ein Service statt 4                                                          │
│                                                                                  │
│  → IDEAL FÜR: 90% unserer Projekte, bis ~50k aktive User                       │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  OPTION B: Postgres + Pinecone + Mastra                                         │
│  ══════════════════════════════════════                                         │
│                                                                                  │
│  ✅ VORTEILE:                              ❌ GRENZEN:                          │
│  • Volle SQL-Power                         • Mehr Setup-Aufwand                 │
│  • Enterprise-proven                       • Kein native Realtime               │
│  • Keine Vendor Lock-in                    • 3 Services zu managen              │
│  • Skaliert unbegrenzt                     • Mehr Kosten bei kleinen Projekten  │
│  • Pinecone = Enterprise RAG                                                    │
│                                                                                  │
│  → IDEAL FÜR: Enterprise, >100k User, SQL-Requirements, GDPR                   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## SLIDE 12d: Skalierungspfad

**Wann upgraden wir den Stack?**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                      SKALIERUNGSPFAD                                             │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  PHASE 1: MVP & Early Stage                    PHASE 2: Growth                  │
│  ═════════════════════════                     ═══════════════                  │
│  Users: 0 - 10.000                             Users: 10.000 - 100.000          │
│                                                                                  │
│  ┌─────────────────────────────┐               ┌─────────────────────────────┐  │
│  │  Convex + Mastra            │               │  Convex + Mastra            │  │
│  │  Vercel (optional)          │       →       │  + Portkey (Cost Control)   │  │
│  │                             │               │  + n8n (Integrations)       │  │
│  │  Kosten: ~$50-200/Monat     │               │  Kosten: ~$500-2000/Monat   │  │
│  └─────────────────────────────┘               └─────────────────────────────┘  │
│                                                                                  │
│  Fokus: Schnell launchen                       Fokus: Stabilisieren             │
│  Speed > Perfektion                            Monitoring einführen             │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  PHASE 3: Scale                                PHASE 4: Enterprise              │
│  ══════════════                                ═══════════════════              │
│  Users: 100.000 - 1.000.000                    Users: >1.000.000 oder GDPR      │
│                                                                                  │
│  ┌─────────────────────────────┐               ┌─────────────────────────────┐  │
│  │  Convex ODER Postgres       │               │  Postgres + Pinecone        │  │
│  │  + Portkey                  │       →       │  + Azure OpenAI (GDPR)      │  │
│  │  + n8n                      │               │  + Portkey + n8n            │  │
│  │  + Redis (Caching)          │               │  + Terraform (IaC)          │  │
│  │  Kosten: ~$2000-10.000/M    │               │  Kosten: $10.000+/Monat     │  │
│  └─────────────────────────────┘               └─────────────────────────────┘  │
│                                                                                  │
│  Fokus: Performance                            Fokus: Compliance                │
│  Convex-Grenzen evaluieren                     Full Control, Self-hosted        │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ENTSCHEIDUNGSMATRIX                                                            │
│  ═══════════════════                                                            │
│                                                                                  │
│  "Wann wechseln wir von Convex zu Postgres?"                                    │
│                                                                                  │
│  ┌──────────────────────────────────┬─────────────────────────────────────────┐ │
│  │  TRIGGER                         │  AKTION                                 │ │
│  ├──────────────────────────────────┼─────────────────────────────────────────┤ │
│  │  >100k aktive User               │  Kosten evaluieren, ggf. Postgres       │ │
│  │  SQL zwingend nötig              │  Postgres von Anfang an                 │ │
│  │  GDPR/Banken/Versicherung        │  Postgres + EU-Hosting                  │ │
│  │  >10M Vektoren für RAG           │  Pinecone statt Convex Vectors          │ │
│  │  Multi-Region nötig              │  Postgres + Custom Setup                │ │
│  └──────────────────────────────────┴─────────────────────────────────────────┘ │
│                                                                                  │
│  WICHTIG: 90% der Projekte bleiben IMMER in Phase 1-2!                          │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Kernaussage:** Mit Convex + Mastra starten, bei Bedarf skalieren. Nicht voreilig Enterprise-Stack wählen!

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

## SLIDE 17b: Ablaufdiagramm - Der komplette Prozess

**So funktioniert die Entwicklung mit Agent Kit:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                  │
│                        LUCID LABS ENTWICKLUNGSPROZESS                           │
│                        ══════════════════════════════                           │
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                           GITHUB                                         │    │
│  │                    (Zentrale Verwaltung)                                 │    │
│  │                                                                          │    │
│  │   ┌─────────────────────┐         ┌─────────────────────────────────┐   │    │
│  │   │                     │         │                                 │   │    │
│  │   │   AGENT KIT         │         │      PROJEKT REPOS              │   │    │
│  │   │   (Template)        │         │                                 │   │    │
│  │   │                     │         │   • customer-portal             │   │    │
│  │   │   lucidlabs-hq/     │         │   • internal-dashboard          │   │    │
│  │   │   agent-kit         │         │   • ai-assistant                │   │    │
│  │   │                     │         │   • ...                         │   │    │
│  │   └──────────┬──────────┘         └──────────────┬──────────────────┘   │    │
│  │              │                                   │                       │    │
│  └──────────────┼───────────────────────────────────┼───────────────────────┘    │
│                 │                                   │                            │
│                 │ Clone/Init                        │ Clone                      │
│                 ▼                                   ▼                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                                                                          │    │
│  │                      ENTWICKLER WORKSTATION                              │    │
│  │                                                                          │    │
│  │   ┌─────────────────────────────────────────────────────────────────┐   │    │
│  │   │                                                                  │   │    │
│  │   │  1. NEUES PROJEKT STARTEN                                       │   │    │
│  │   │  ════════════════════════                                       │   │    │
│  │   │                                                                  │   │    │
│  │   │  $ cd agent-kit                                                 │   │    │
│  │   │  $ /init-project customer-portal                                │   │    │
│  │   │                                                                  │   │    │
│  │   │  → Stack-Empfehlung basierend auf Projektbeschreibung           │   │    │
│  │   │  → Projekt wird in projects/ erstellt                           │   │    │
│  │   │  → GitHub Repo wird automatisch angelegt                        │   │    │
│  │   │  → Linear Projekt wird erstellt                                 │   │    │
│  │   │                                                                  │   │    │
│  │   └─────────────────────────────────────────────────────────────────┘   │    │
│  │                              │                                           │    │
│  │                              ▼                                           │    │
│  │   ┌─────────────────────────────────────────────────────────────────┐   │    │
│  │   │                                                                  │   │    │
│  │   │  2. ENTWICKLUNG (PIV Loop)                                      │   │    │
│  │   │  ═════════════════════════                                      │   │    │
│  │   │                                                                  │   │    │
│  │   │  $ cd projects/customer-portal                                  │   │    │
│  │   │  $ claude                     ← AI-Assistent starten            │   │    │
│  │   │                                                                  │   │    │
│  │   │  ┌─────────┐   ┌───────────┐   ┌──────────┐   ┌────────┐       │   │    │
│  │   │  │  PLAN   │──▶│ IMPLEMENT │──▶│ VALIDATE │──▶│ COMMIT │       │   │    │
│  │   │  │         │   │           │   │          │   │        │       │   │    │
│  │   │  │/plan-   │   │ /execute  │   │/validate │   │/commit │       │   │    │
│  │   │  │feature  │   │           │   │          │   │        │       │   │    │
│  │   │  └─────────┘   └───────────┘   └──────────┘   └────────┘       │   │    │
│  │   │       │                                            │            │   │    │
│  │   │       └────────────── ITERATE ◀────────────────────┘            │   │    │
│  │   │                                                                  │   │    │
│  │   │  → Folgt AIDD Methodology (Exploration → Decision → Delivery)   │   │    │
│  │   │  → Tests als Erfolgskriterium (TDD)                             │   │    │
│  │   │  → Linear Ticket wird automatisch aktualisiert                  │   │    │
│  │   │                                                                  │   │    │
│  │   └─────────────────────────────────────────────────────────────────┘   │    │
│  │                              │                                           │    │
│  │                              ▼                                           │    │
│  │   ┌─────────────────────────────────────────────────────────────────┐   │    │
│  │   │                                                                  │   │    │
│  │   │  3. BEST PRACTICES ZURÜCKFÜHREN                                 │   │    │
│  │   │  ══════════════════════════════                                 │   │    │
│  │   │                                                                  │   │    │
│  │   │  Entwickler entdeckt ein gutes Pattern?                         │   │    │
│  │   │                                                                  │   │    │
│  │   │  $ /promote                                                     │   │    │
│  │   │                                                                  │   │    │
│  │   │  ┌──────────────────────────────────────────────────────────┐  │   │    │
│  │   │  │  "Welche Patterns sollen ins Template?"                   │  │   │    │
│  │   │  │                                                           │  │   │    │
│  │   │  │  [x] Neuer /pdf-analyze Skill                            │  │   │    │
│  │   │  │  [x] Verbesserter Error Handler                          │  │   │    │
│  │   │  │  [ ] Kunden-spezifischer Code  ← Bleibt im Projekt       │  │   │    │
│  │   │  └──────────────────────────────────────────────────────────┘  │   │    │
│  │   │                                                                  │   │    │
│  │   └─────────────────────────────────────────────────────────────────┘   │    │
│  │                                                                          │    │
│  └──────────────────────────────────────────────────────────────────────────┘    │
│                 │                                                                │
│                 │ Push / Pull Request                                            │
│                 ▼                                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                                                                          │    │
│  │                      GITHUB PULL REQUEST                                 │    │
│  │                    (Qualitätskontrolle)                                  │    │
│  │                                                                          │    │
│  │   ┌──────────────────────────────────────────────────────────────────┐  │    │
│  │   │                                                                   │  │    │
│  │   │  PR: "feat: add pdf-analyze skill from customer-portal"          │  │    │
│  │   │                                                                   │  │    │
│  │   │  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐            │  │    │
│  │   │  │   REVIEW    │──▶│   APPROVE   │──▶│    MERGE    │            │  │    │
│  │   │  │             │   │             │   │             │            │  │    │
│  │   │  │ Team prüft: │   │ Passt ins   │   │ Jetzt im    │            │  │    │
│  │   │  │ • Generisch?│   │ Template!   │   │ Template    │            │  │    │
│  │   │  │ • Getestet? │   │             │   │ verfügbar   │            │  │    │
│  │   │  │ • Dokument? │   │             │   │             │            │  │    │
│  │   │  └─────────────┘   └─────────────┘   └─────────────┘            │  │    │
│  │   │                                                                   │  │    │
│  │   └──────────────────────────────────────────────────────────────────┘  │    │
│  │                                                                          │    │
│  └──────────────────────────────────────────────────────────────────────────┘    │
│                 │                                                                │
│                 │ Sync                                                           │
│                 ▼                                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                                                                          │    │
│  │                    ALLE PROJEKTE PROFITIEREN                            │    │
│  │                                                                          │    │
│  │   ┌───────────────┐  ┌───────────────┐  ┌───────────────┐               │    │
│  │   │ Projekt A     │  │ Projekt B     │  │ Projekt C     │               │    │
│  │   │               │  │               │  │               │               │    │
│  │   │ $ /sync       │  │ $ /sync       │  │ $ /sync       │               │    │
│  │   │ → Neue Skills │  │ → Neue Skills │  │ → Neue Skills │               │    │
│  │   │   verfügbar!  │  │   verfügbar!  │  │   verfügbar!  │               │    │
│  │   └───────────────┘  └───────────────┘  └───────────────┘               │    │
│  │                                                                          │    │
│  │   → Einmal entwickelt, überall verfügbar                                │    │
│  │   → Qualitätsgesichert durch PR-Review                                  │    │
│  │   → Dokumentiert und getestet                                           │    │
│  │                                                                          │    │
│  └──────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## SLIDE 17c: Executive Summary für Geschäftsführung

**Der Kreislauf in Kurzform:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                  │
│                     AGENT KIT - SO FUNKTIONIERT ES                              │
│                                                                                  │
│         ┌──────────────────────────────────────────────────────────┐            │
│         │                      GITHUB                               │            │
│         │              (Agent Kit Template)                         │            │
│         │                                                           │            │
│         │   Best Practices │ Skills │ Boilerplate │ Standards      │            │
│         └──────────────────────────┬───────────────────────────────┘            │
│                                    │                                             │
│                    ┌───────────────┼───────────────┐                            │
│                    │               │               │                            │
│                    ▼               ▼               ▼                            │
│              ┌──────────┐   ┌──────────┐   ┌──────────┐                         │
│              │Projekt A │   │Projekt B │   │Projekt C │                         │
│              │ Kunde 1  │   │ Kunde 2  │   │ Intern   │                         │
│              └────┬─────┘   └────┬─────┘   └────┬─────┘                         │
│                   │              │              │                                │
│                   └──────────────┴──────────────┘                                │
│                                  │                                               │
│                                  │ Neue Best Practice?                           │
│                                  ▼                                               │
│                         ┌───────────────┐                                        │
│                         │  PULL REQUEST │ ← Team Review                          │
│                         │  → MERGE      │                                        │
│                         └───────┬───────┘                                        │
│                                 │                                                │
│                                 ▼ Zurück ins Template                            │
│         ┌──────────────────────────────────────────────────────────┐            │
│         │           GITHUB (Template jetzt besser!)                 │            │
│         └──────────────────────────────────────────────────────────┘            │
│                                                                                  │
│  ════════════════════════════════════════════════════════════════════════════   │
│                                                                                  │
│   ✅ Wissen geht nicht verloren        ✅ Einheitliche Standards                │
│   ✅ Alle Projekte profitieren         ✅ Schnelles Onboarding neuer Devs       │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## SLIDE 17d: Business Value - Zeitersparnis

**Was bringt das konkret?**

| Aktivität | Ohne Agent Kit | Mit Agent Kit |
|-----------|----------------|---------------|
| **Projekt aufsetzen** | 2-3 Tage | 10 Minuten |
| **Stack-Entscheidungen** | Lange Diskussionen | Tool gibt Empfehlung |
| **Neue Patterns** | Jedes Projekt neu | 1x entwickeln, überall nutzen |
| **Onboarding neuer Devs** | 2-4 Wochen | 2-3 Tage |
| **Qualitätssicherung** | Manuell, inkonsistent | Automatisiert, einheitlich |

**ROI-Rechnung:**

```
Annahme: 5 neue Projekte pro Jahr

Zeitersparnis Projekt-Setup:         5 × 2 Tage    = 10 Tage
Zeitersparnis durch Patterns:        5 × 5 Tage    = 25 Tage
Zeitersparnis Onboarding (2 Devs):   2 × 10 Tage   = 20 Tage
──────────────────────────────────────────────────────────────
GESAMT PRO JAHR:                                    = 55 Tage
```

---

## SLIDE 17e: Der Qualitätskreislauf

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

## SLIDE 17f: Was wird promotet, was nicht?

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

## SLIDE 17g: Bidirektionaler Wissensfluss

**Beide Richtungen im Detail:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                  │
│                    BIDIREKTIONALER WISSENSFLUSS                                 │
│                                                                                  │
│                                                                                  │
│   ┌───────────────────────────────────────────────────────────────────────┐     │
│   │                         AGENT KIT TEMPLATE                             │     │
│   │                          (GitHub Repository)                           │     │
│   │                                                                        │     │
│   │   📚 Skills  │  📋 Reference Docs  │  🧩 Components  │  🛠️ Scripts    │     │
│   └───────────────────────────────────────────────────────────────────────┘     │
│                              │                    ▲                              │
│                              │                    │                              │
│              ┌───────────────┘                    └───────────────┐              │
│              │                                                    │              │
│              │  SYNC                                    PROMOTE   │              │
│              │  (Template → Projekt)                    (Projekt → Template)     │
│              │                                                    │              │
│              │  "Ich hole mir die                       "Ich gebe Best          │
│              │   neuesten Best Practices"               Practices zurück"       │
│              │                                                    │              │
│              ▼                                                    │              │
│   ┌───────────────────────────────────────────────────────────────────────┐     │
│   │                        KUNDENPROJEKT                                   │     │
│   │                                                                        │     │
│   │   /sync                                                   /promote    │     │
│   │   ─────                                                   ────────    │     │
│   │                                                                        │     │
│   │   • Neue Skills automatisch verfügbar    • Pattern funktioniert gut?  │     │
│   │   • Bug-Fixes aus Template               • Generisch genug?           │     │
│   │   • Verbesserte Components               • → PR ans Template!         │     │
│   │   • Aktualisierte Docs                                                │     │
│   │                                                                        │     │
│   └───────────────────────────────────────────────────────────────────────┘     │
│                                                                                  │
│                                                                                  │
│   ════════════════════════════════════════════════════════════════════════════  │
│                                                                                  │
│   BEISPIEL SYNC:                           BEISPIEL PROMOTE:                    │
│   ──────────────                           ─────────────────                    │
│                                                                                  │
│   Template bekommt neuen                   Projekt entwickelt besseren          │
│   /visual-verify Skill                     Error Handler                        │
│            │                                          │                          │
│            ▼                                          ▼                          │
│   Entwickler im Projekt:                   Entwickler:                          │
│   $ /sync                                  $ /promote                           │
│            │                                          │                          │
│            ▼                                          ▼                          │
│   "Neuer Skill verfügbar!                  Pull Request → Review → Merge        │
│    Jetzt kann ich /visual-verify                      │                          │
│    nutzen"                                            ▼                          │
│                                            Alle anderen Projekte                │
│                                            können den Handler                   │
│                                            jetzt auch nutzen!                   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Der Effekt: Das Team wird immer klüger!**

```
Zeit ────────────────────────────────────────────────────────────────────────▶

Projekt 1: ═══════════════════════════════════════════════════════════════════
            └──Entdeckt Pattern A──┘ └──Promote──┘
                                                  │
Projekt 2: ════════════════════════════════════════════════════════════════════
                                     └──Sync──┘   │
                                     Pattern A!   │
                                                  │
Projekt 3: ═══════════════════════════════════════════════════════════════════
                                           └──Sync──┘ └──Entdeckt Pattern B──┘
                                           Pattern A!               │
                                                                    │ Promote
Template:  ════════════════════════════════════════════════════════════════════
                              Pattern A           Pattern A + B
                              hinzugefügt         verfügbar

→ ERGEBNIS: Kollektives Lernen über alle Projekte hinweg!
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

## SLIDE 18b: n8n Workflow Generation (Optional)

**Wenn Kunde n8n-Lösung erwartet:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                     N8N WORKFLOW GENERATION                                      │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  WANN N8N?                                                                       │
│  ─────────                                                                       │
│  • Kunde erwartet n8n-Lösung ("Wir wollen das in n8n haben")                    │
│  • Wir demonstrieren n8n-Expertise                                               │
│  • Externe Integrationen zentral (CRM, ERP, Email)                              │
│  • Kunde soll Workflows selbst anpassen können                                   │
│                                                                                  │
│  WAS WIRD GENERIERT?                                                             │
│  ───────────────────                                                             │
│  • Vorkonfigurierter Workflow (JSON)                                            │
│  • Mastra Agent Endpoints eingebaut                                              │
│  • Dokumentierte Notes im Workflow                                               │
│  • Import-ready für n8n                                                          │
│                                                                                  │
│  WORKFLOW-VARIANTEN:                                                             │
│  ┌─────────────────────┬────────────────────────────────────────┐               │
│  │ Basis               │ Webhook → Mastra Agent → Response       │               │
│  │ Email-Trigger       │ IMAP/Email → Agent → Antwort           │               │
│  │ Scheduled           │ Cron → Agent → Aktion                   │               │
│  │ CRM Integration     │ HubSpot/Salesforce → Agent → Update    │               │
│  └─────────────────────┴────────────────────────────────────────┘               │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Ablauf bei Projekt-Setup:**

```
/init-project customer-portal
     ↓
Stack-Empfehlung → n8n ausgewählt? → JA
     ↓
"Soll ich n8n Workflow generieren?"
[1] Basis-Workflow
[2] Email-Trigger
[3] Scheduled
[4] Später manuell
     ↓
n8n/workflows/agent-workflow.json erstellt
     ↓
Import in n8n → Credentials setzen → Fertig!
```

**Vorteil:** Kunde sieht sofort einen funktionierenden n8n Workflow mit unseren Agenten.

---

## SLIDE 18c: Skill Sharing - Clone & Publish

**Skills direkt zwischen Projekten teilen:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          SKILL SHARING                                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│                        CENTRAL REPOSITORY                                        │
│                     lucidlabs-hq/agent-kit                                      │
│                                                                                  │
│         ┌───────────────────────────────────────────────────────┐               │
│         │  /clone-skill pdf-analyzer                             │               │
│         │         ↓                                              │               │
│         │  Skill wird ins Projekt kopiert                       │               │
│         └───────────────────────────────────────────────────────┘               │
│                                                                                  │
│         ┌───────────────────────────────────────────────────────┐               │
│         │  Developer baut coolen Skill                          │               │
│         │         ↓                                              │               │
│         │  /publish-skill meeting-notes                         │               │
│         │         ↓                                              │               │
│         │  PR → Review → Merge                                  │               │
│         │         ↓                                              │               │
│         │  Alle Projekte können ihn jetzt nutzen!               │               │
│         └───────────────────────────────────────────────────────┘               │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  COMMANDS:                                                                       │
│                                                                                  │
│  /clone-skill --list              Verfügbare Skills auflisten                   │
│  /clone-skill [name]              Skill ins Projekt klonen                      │
│  /clone-skill --import            Aus Claude.ai Cloud importieren              │
│  /publish-skill [name]            Skill mit Team teilen (via PR)               │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Vorteil:** Entwickler können sofort von den Patterns anderer profitieren - ohne vollständigen Sync.

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

## SLIDE 19b: Self-Learning Loop mit PromptFoo

**Kundenagenten, die sich kontinuierlich verbessern:**

> Jeder Agent, den wir für Kunden entwickeln, wird mit PromptFoo ausgestattet.
> Das bedeutet: Der Agent wird nach Go-Live nicht schlechter, sondern **besser**.

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         SELF-LEARNING LOOP                                       │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│                    ┌─────────────────────────────────┐                          │
│                    │                                 │                          │
│                    │      PRODUCTION AGENT           │                          │
│                    │                                 │                          │
│                    │   "Klassifiziere dieses Ticket" │                          │
│                    │                                 │                          │
│                    └───────────────┬─────────────────┘                          │
│                                    │                                             │
│                                    │ Real-World Usage                            │
│                                    ▼                                             │
│    ┌───────────────────────────────────────────────────────────────────────┐    │
│    │                                                                        │    │
│    │                         PROMPTFOO                                      │    │
│    │                    (Evaluation Engine)                                 │    │
│    │                                                                        │    │
│    │   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐              │    │
│    │   │   TEST       │   │   MEASURE    │   │   COMPARE    │              │    │
│    │   │              │   │              │   │              │              │    │
│    │   │ • Test Cases │   │ • Accuracy   │   │ • v1 vs v2   │              │    │
│    │   │ • Edge Cases │   │ • Latency    │   │ • Models     │              │    │
│    │   │ • Red Team   │   │ • Cost       │   │ • Prompts    │              │    │
│    │   └──────────────┘   └──────────────┘   └──────────────┘              │    │
│    │                                                                        │    │
│    └───────────────────────────────┬────────────────────────────────────────┘    │
│                                    │                                             │
│                                    │ Insights & Improvements                     │
│                                    ▼                                             │
│                    ┌─────────────────────────────────┐                          │
│                    │                                 │                          │
│                    │      IMPROVED AGENT v2          │                          │
│                    │                                 │                          │
│                    │   Bessere Prompts               │                          │
│                    │   Optimierte Parameter          │                          │
│                    │   Weniger Fehler                │                          │
│                    │                                 │                          │
│                    └─────────────────────────────────┘                          │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## SLIDE 19c: PromptFoo - Wie wir es einsetzen

**Drei Einsatzbereiche in Kundenprojekten:**

> Wenn wir einen Agent für einen Kunden entwickeln, setzen wir PromptFoo in allen drei Bereichen ein:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                      PROMPTFOO EINSATZBEREICHE                                   │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  1. PROMPT EVALUATION                                                            │
│  ════════════════════                                                            │
│                                                                                  │
│  "Funktioniert mein Prompt?"                                                    │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │  Test Cases           │  Expected Output      │  Result                    │ │
│  │  ─────────────────────┼───────────────────────┼─────────────────────────── │ │
│  │  "Rechnung bezahlen"  │  billing              │  ✓ billing                 │ │
│  │  "Passwort vergessen" │  account              │  ✓ account                 │ │
│  │  "API funktioniert n" │  technical            │  ✗ billing (FEHLER!)       │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                  │
│  → Fehler gefunden! Prompt anpassen, erneut testen.                             │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  2. MODEL COMPARISON                                                             │
│  ═══════════════════                                                             │
│                                                                                  │
│  "Welches Modell ist besser für diese Aufgabe?"                                 │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │  Model              │  Accuracy  │  Latency    │  Cost/1000   │  Winner   │ │
│  │  ───────────────────┼────────────┼─────────────┼──────────────┼────────── │ │
│  │  Claude Sonnet      │  94%       │  1.2s       │  $0.15       │           │ │
│  │  Claude Haiku       │  89%       │  0.4s       │  $0.02       │  ← BEST   │ │
│  │  GPT-4o             │  91%       │  0.8s       │  $0.10       │           │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                  │
│  → Haiku reicht für Klassifikation! 85% Kostenersparnis.                        │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  3. RED TEAMING (Security)                                                       │
│  ═════════════════════════                                                       │
│                                                                                  │
│  "Kann der Agent manipuliert werden?"                                           │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │  Attack Vector           │  Agent Response        │  Status                │ │
│  │  ────────────────────────┼────────────────────────┼─────────────────────── │ │
│  │  Prompt Injection        │  Blocked               │  ✓ SAFE                │ │
│  │  Jailbreak Attempt       │  Refused               │  ✓ SAFE                │ │
│  │  Data Exfiltration       │  Leaked user email!    │  ✗ VULNERABLE          │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                  │
│  → Sicherheitslücke gefunden! Guardrails hinzufügen.                            │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## SLIDE 19d: PromptFoo - Der Workflow

**So verbessern sich Kundenagenten kontinuierlich:**

> Dieser Workflow läuft für jeden Agenten, den wir ausliefern - automatisch, messbar, nachhaltig.

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                     PROMPTFOO WORKFLOW                                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  DEVELOPMENT                          PRODUCTION                                 │
│  ───────────                          ──────────                                 │
│                                                                                  │
│  ┌─────────────────┐                  ┌─────────────────┐                       │
│  │ 1. Agent bauen  │                  │ 4. Agent live   │                       │
│  │                 │                  │                 │                       │
│  │ Mastra Agent    │                  │ Real Users      │                       │
│  │ + Prompts       │                  │ Real Data       │                       │
│  └────────┬────────┘                  └────────┬────────┘                       │
│           │                                    │                                 │
│           ▼                                    │                                 │
│  ┌─────────────────┐                          │                                 │
│  │ 2. Tests        │                          │                                 │
│  │    definieren   │                          │                                 │
│  │                 │                          │                                 │
│  │ promptfooconfig │                          │                                 │
│  │ + test cases    │                          │                                 │
│  └────────┬────────┘                          │                                 │
│           │                                    │                                 │
│           ▼                                    │                                 │
│  ┌─────────────────┐                          │                                 │
│  │ 3. Evaluation   │◀─────────────────────────┘                                 │
│  │    ausführen    │     Feedback Loop                                          │
│  │                 │     (neue Edge Cases)                                       │
│  │ npx promptfoo   │                                                            │
│  │ eval            │                                                            │
│  └────────┬────────┘                                                            │
│           │                                                                      │
│           ▼                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                                                                          │    │
│  │   ERGEBNIS: 94% Accuracy │ 0.8s Latency │ $0.05/Request │ 0 Vulnerab.  │    │
│  │                                                                          │    │
│  │   ✓ Alle Tests bestanden → Deploy!                                      │    │
│  │   ✗ Tests fehlgeschlagen → Prompt verbessern, zurück zu Schritt 1       │    │
│  │                                                                          │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  COMMANDS:                                                                       │
│                                                                                  │
│  /promptfoo init      Projekt initialisieren (erstellt promptfooconfig.yaml)   │
│  /promptfoo eval      Tests ausführen                                           │
│  /promptfoo compare   Modelle/Prompts vergleichen                               │
│  /promptfoo redteam   Security-Scan durchführen                                 │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  CI/CD INTEGRATION:                                                              │
│                                                                                  │
│  • GitHub Action: Tests laufen bei jedem PR                                     │
│  • Blocking: PR wird nur gemerged wenn Tests grün                               │
│  • Monthly: Automatischer Red-Team Scan                                         │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Kernidee:** Agenten sind nie "fertig" - sie werden kontinuierlich besser.

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
│  │   │   • Kunde will n8n-Lösung sehen                                      │ │  │
│  │   │                                                                      │ │  │
│  │   │   → Workflow wird bei /init-project auto-generiert!                  │ │  │
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
