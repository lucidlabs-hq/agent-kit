# Lucid Labs AI Stack 2026

> **Vollständige Referenz für den Tech Stack**
> Was ist Standard? Was ist optional? Wann nutze ich was?

---

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
│  │   │    NEXT.JS 16   │  ← STANDARD: Immer dabei                             │  │
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
│  │   │                             │    │                             │      │  │
│  │   │   Features:                 │    │   Features:                 │      │  │
│  │   │   • Streaming out-of-box    │    │   • Decision Layer          │      │  │
│  │   │   • useChat Hook            │    │   • Type-safe Tools         │      │  │
│  │   │   • Minimal Setup           │    │   • Workflow Engine         │      │  │
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
│  │   │   • Type-safety wichtig     │    │   • Bestehende DB           │      │  │
│  │   │                             │    │                             │      │  │
│  │   │   Features:                 │    │   Features:                 │      │  │
│  │   │   • Automatic Sync          │    │   • SQL Standard            │      │  │
│  │   │   • Built-in Vector Search  │    │   • Prisma/Drizzle ORM      │      │  │
│  │   │   • File Storage            │    │   • pgvector oder Pinecone  │      │  │
│  │   │   • Type-safe Functions     │    │   • Migrations              │      │  │
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
│  │   │                                                                      │ │  │
│  │   │   → Ohne Portkey: Direkt zu Anthropic/OpenAI API                     │ │  │
│  │   │   → Self-hosted möglich (Open Source)                                │ │  │
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
│  │   │                                                                      │ │  │
│  │   │   Prinzip:                                                           │ │  │
│  │   │   → Mastra bekommt NUR strukturiertes JSON                           │ │  │
│  │   │   → Nie Rohdaten (PDFs, CSVs) an LLM                                 │ │  │
│  │   │   → Deterministische Logik hier, nicht im Agent                      │ │  │
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
│  │   │   • Komplexe Automatisierungen                                       │ │  │
│  │   │   • Email/Slack Notifications                                        │ │  │
│  │   │                                                                      │ │  │
│  │   │   → Self-hosted via Elestio                                          │ │  │
│  │   │   → Visual Workflow Builder                                          │ │  │
│  │   └─────────────────────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                      ADVANCED AI (SELTEN)                                  │  │
│  │                                                                            │  │
│  │   ┌─────────────────────────┐    ┌─────────────────────────────┐          │  │
│  │   │       LANGCHAIN         │    │        PINECONE             │          │  │
│  │   │                         │    │                             │          │  │
│  │   │   Wann:                 │    │   Wann:                     │          │  │
│  │   │   • Mastra reicht nicht │    │   • Convex Vector zu klein  │          │  │
│  │   │   • Complex Chains      │    │   • Enterprise RAG          │          │  │
│  │   │   • LangGraph Stateful  │    │   • Millionen Vektoren      │          │  │
│  │   │                         │    │   • Mit Postgres             │          │  │
│  │   └─────────────────────────┘    └─────────────────────────────┘          │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                         INFRASTRUCTURE                                     │  │
│  │                                                                            │  │
│  │   ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐           │  │
│  │   │    TERRAFORM    │  │      MINIO      │  │    GREPTILE     │           │  │
│  │   │                 │  │                 │  │                 │           │  │
│  │   │   Wann:         │  │   Wann:         │  │   Wann:         │           │  │
│  │   │   • Production  │  │   • File Storage│  │   • Auto PR     │           │  │
│  │   │   • Multi-Env   │  │   • S3-compat   │  │     Reviews     │           │  │
│  │   │   • IaC nötig   │  │   • Self-hosted │  │   • Bug Detect  │           │  │
│  │   └─────────────────┘  └─────────────────┘  └─────────────────┘           │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Komponenten-Referenz

### STANDARD (Immer dabei)

| Komponente | Rolle | Was es macht |
|------------|-------|--------------|
| **Next.js 16** | Frontend | Web App mit App Router, Server Components, shadcn/ui |
| **Claude** | LLM | Primärer AI Provider - Opus (Qualität), Sonnet (Code), Haiku (Speed) |
| **Linear** | Execution | Issue Tracking, AIDD Status Flow, Sprint Planning |
| **Productive.io** | Customer Value | Delivery Units, Budgets, Kunden-Reporting |

### WÄHLBAR (Eins pro Kategorie)

| Kategorie | Option A | Option B | Default |
|-----------|----------|----------|---------|
| **AI Layer** | Vercel AI SDK (Prototyp) | Mastra (Production) | Mastra |
| **Database** | Convex (Realtime) | Postgres (SQL) | Convex |

### OPTIONAL (Nach Bedarf)

| Komponente | Wann hinzufügen? | Typischer Use Case |
|------------|------------------|---------------------|
| **Portkey** | Cost Tracking, Multi-Model | Enterprise, Multi-Tenant |
| **Python Workers** | PDF/OCR, ML, Statistik | Dokumentenverarbeitung |
| **n8n** | Externe Integrationen | CRM/ERP Anbindung |
| **LangChain** | Mastra reicht nicht | Komplexe Agent-Chains |
| **Pinecone** | Große Vector DBs | Enterprise RAG |
| **Terraform** | Production Deploy | Multi-Environment |
| **MinIO** | File Storage | S3-kompatibel, Self-hosted |
| **Greptile** | Auto Code Review | CI/CD Pipeline |
| **Azure OpenAI** | GDPR-Compliance | EU Data Residency |

---

## Verantwortlichkeiten: Wer macht was?

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    WER MACHT WAS IM STACK?                                       │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   MASTRA / VERCEL AI SDK        PYTHON WORKERS          CONVEX / POSTGRES       │
│   ══════════════════════        ══════════════          ════════════════        │
│   "Decision & Explanation"      "Computation"           "State & Sync"          │
│                                                                                  │
│   • Entscheidet                 • Rechnet               • Speichert             │
│   • Erklärt                     • Parst                 • Versioniert           │
│   • Formuliert                  • Aggregiert            • Synchronisiert        │
│   • Validiert Kontext           • Statistik             • Realtime Updates      │
│                                                                                  │
│   INPUT:                        INPUT:                  INPUT:                  │
│   Strukturiertes JSON           Rohdaten (PDF, etc.)    Alles                   │
│                                                                                  │
│   OUTPUT:                       OUTPUT:                 OUTPUT:                 │
│   Entscheidung + Begründung     Reines Analyse-JSON     Queries & Mutations     │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   N8N                           PORTKEY                 LINEAR / PRODUCTIVE     │
│   ═══                           ═══════                 ═══════════════════     │
│   "Automation"                  "Gateway"               "Governance"            │
│                                                                                  │
│   • Webhooks                    • Routing               • Tracking              │
│   • Scheduling                  • Cost Tracking         • Reporting             │
│   • Integrations                • Rate Limiting         • Budgets               │
│   • Notifications               • Fallbacks             • Customer Value        │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Entscheidungsmatrix: Projekt-Komplexität

### Stufe 1: MVP / Prototype (1-2 Wochen)

```
✅ Next.js + Vercel AI SDK + Convex
❌ Kein Mastra, keine Workers, kein n8n
```

| Komponente | Status |
|------------|--------|
| Frontend | Next.js 16 |
| AI Layer | Vercel AI SDK |
| Database | Convex |
| LLM | Claude direkt |
| Extras | Keine |

**Beispiele:** Chat-Demo, Quick POC, interne Tools

---

### Stufe 2: Standard Projekt (2-8 Wochen)

```
✅ Next.js + Mastra + Convex
⚪ Optional: n8n für Integrationen
```

| Komponente | Status |
|------------|--------|
| Frontend | Next.js 16 |
| AI Layer | **Mastra** |
| Database | Convex |
| LLM | Claude direkt |
| Extras | n8n (optional) |

**Beispiele:** Ticket-Agent, Klassifikations-Agent, Workflow-Automation

---

### Stufe 3: Enterprise Projekt (8+ Wochen)

```
✅ Next.js + Mastra + Convex/Postgres + Portkey + n8n
⚪ Optional: Python Workers, Pinecone
```

| Komponente | Status |
|------------|--------|
| Frontend | Next.js 16 |
| AI Layer | **Mastra** |
| Database | Convex oder **Postgres** |
| LLM | Claude via **Portkey** |
| Automation | **n8n** |
| Compute | Python Workers (optional) |
| Vectors | Pinecone (optional) |
| IaC | **Terraform** |

**Beispiele:** Multi-Tenant SaaS, Enterprise RAG, komplexe Analyse-Plattform

---

### Stufe 4: GDPR / Compliance Projekt

```
✅ Alles von Stufe 3 + Azure OpenAI
```

| Komponente | Status |
|------------|--------|
| LLM | **Azure OpenAI** (primär) |
| Fallback | Claude via Portkey |
| Data | **Postgres** (EU-hosted) |
| Hosting | **Elestio** (EU) |

**Beispiele:** Banken, Versicherungen, Healthcare

---

## Quick Reference: Wann was?

### AI Layer Entscheidung

```
Brauche ich Tools/Agents/Workflows?
│
├─ NEIN → Vercel AI SDK
│         • Chat UI, Streaming
│         • Minimal Setup
│
└─ JA → Mastra
        • Structured Tools
        • Multi-Step Workflows
        • Type-safe Outputs
```

### Database Entscheidung

```
Brauche ich Realtime Sync?
│
├─ JA → Convex
│       • Automatic UI Updates
│       • Built-in Vector Search
│       • Type-safe Functions
│
└─ NEIN → Postgres
          │
          ├─ SQL nötig? → Postgres + Prisma
          │
          └─ Pinecone gewünscht? → Postgres + Pinecone
```

### Optional Components Entscheidung

```
Brauche ich...

Cost Tracking pro Kunde?      → Portkey
PDF/OCR/ML Processing?        → Python Workers
Externe Integrationen?        → n8n
Millionen Vektoren?           → Pinecone
GDPR/EU Data Residency?       → Azure OpenAI
Auto Code Reviews?            → Greptile
S3-compatible Storage?        → MinIO
Multi-Environment Deploy?     → Terraform
```

---

## Init-Projekt Empfehlung

Bei `/init-project` wird nach Projektbeschreibung gefragt und eine Empfehlung gegeben:

```
┌─────────────────────────────────────────────────────────────────┐
│  PROJEKT SETUP                                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Beschreibe dein Projekt in 1-2 Sätzen:                         │
│  > _                                                             │
│                                                                  │
│  Beispiele:                                                      │
│  • "Chat-Bot für Kundenservice"                                  │
│  • "Ticket-Klassifikation mit CRM-Integration"                   │
│  • "Enterprise RAG für interne Dokumente"                        │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Basierend auf deiner Beschreibung empfehle ich:                │
│                                                                  │
│  STUFE 2: Standard Projekt                                       │
│                                                                  │
│  ✅ Next.js 16 (Frontend)                                        │
│  ✅ Mastra (AI Layer) - wegen Tools                              │
│  ✅ Convex (Database) - Realtime für UI                          │
│  ⚪ n8n - für CRM-Integration                                    │
│                                                                  │
│  Einverstanden? [Y/n]                                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

*Lucid Labs GmbH - AI Stack 2026*
*Letzte Aktualisierung: Januar 2026*
