# Productive.io Integration Guide

> System of Record für Kundenleistung, Projekte und Reporting.

## Übersicht: Zwei-System-Architektur

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         LUCID LABS WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   PRODUCTIVE.IO                           LINEAR                         │
│   ──────────────                          ──────                         │
│   System of Record                        Execution System               │
│   für Kundenwert                          für technische Arbeit          │
│                                                                          │
│   • Kunden (Companies)                    • Technische Umsetzung         │
│   • Delivery Units (Projects)             • Discovery-Driven Dev         │
│   • Budget & Abrechnung                   • Exploration → Delivery       │
│   • Kunden-Reporting                      • Maintenance & Ops            │
│                                                                          │
│                         ┌──────────────┐                                 │
│                         │ PRODUCTIFYER │                                 │
│                         │   (Bridge)   │                                 │
│                         └──────────────┘                                 │
│                                │                                         │
│                                ▼                                         │
│                    ┌────────────────────┐                                │
│                    │  CUSTOMER PORTAL   │                                │
│                    │  (Service Dashboard)│                                │
│                    └────────────────────┘                                │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Grundprinzip

> Nicht alles, was wir liefern, ist Software.
> Aber alles, was wir liefern, ist **reportbar**.

| System | Verantwortung | Wann nutzen? |
|--------|---------------|--------------|
| **Productive.io** | Kundenwert, Projekte, Geld | Immer (jede Delivery Unit) |
| **Linear** | Technische Execution | Nur bei Code/Ops-Arbeit |

---

## Delivery Units

**Delivery Units** sind die zentrale Einheit für Leistungssteuerung und Reporting.

### Typen von Delivery Units

| Typ | Beschreibung | Linear nötig? |
|-----|--------------|---------------|
| **Agent** | Produktiver KI-Agent | Ja |
| **GPT / Prompt** | Prompt oder Prompt-Set | Nein (meist) |
| **Workflow / Automation** | Automatisierte Abläufe | Ja |
| **Integration** | Anbindung externer Systeme | Ja |
| **Cloud / Telemetry Skill** | Infrastruktur, Monitoring | Ja |
| **Workshop** | Einzelner Workshop | Nein |
| **Workshop Series** | Mehrteilige Trainings | Nein |
| **Advisory / Audit** | Analyse, Beratung | Nein |

### Regel

```
Productive.io Project = Delivery Unit (immer)
Linear Project        = Nur wenn technische Execution
```

---

## Productive.io API

### Authentifizierung

```bash
# Required Headers für alle Requests
X-Auth-Token: {api-token}
X-Organization-Id: {org-id}
Content-Type: application/vnd.api+json
```

### API Token erstellen

1. Productive.io → Settings → API integrations
2. "Generate new token"
3. Token sicher speichern (wird nur einmal angezeigt)

### Environment Variables

```bash
# In .env
PRODUCTIVE_API_TOKEN=your-api-token
PRODUCTIVE_ORG_ID=your-org-id
PRODUCTIVE_BASE_URL=https://api.productive.io/api/v2
```

---

## Wichtige Endpoints

### Companies (Kunden)

```bash
# Liste aller Kunden
GET /api/v2/companies

# Kunden nach Status filtern
GET /api/v2/companies?filter[status]=1  # Active

# Einzelner Kunde
GET /api/v2/companies/{id}
```

**Wichtige Felder:**
- `name` - Kundenname
- `billing_name` - Rechnungsname
- `custom_fields` - Erweiterbare Metadaten
- `tag_list` - Tags für Kategorisierung

### Projects (Delivery Units)

```bash
# Alle Projekte eines Kunden
GET /api/v2/projects?filter[company_id]={customer-id}

# Aktive Projekte
GET /api/v2/projects?filter[status]=1

# Projekt mit Beziehungen
GET /api/v2/projects/{id}?include=company,project_manager
```

**Wichtige Felder:**
- `name` - Projektname (Delivery Unit Titel)
- `project_type_id` - 1: internal, 2: client
- `company` - Zugehöriger Kunde
- `custom_fields` - Für Delivery Unit Type, Status etc.

### Webhooks (Real-time Updates)

```bash
# Webhook erstellen
POST /api/v2/webhooks
{
  "data": {
    "type": "webhooks",
    "attributes": {
      "name": "Project Updates",
      "event_id": 10,  // Project Updated
      "target_url": "https://your-app.com/webhooks/productive",
      "type_id": 1     // Webhook
    }
  }
}
```

**Relevante Events:**
| Event ID | Event | Nutzen |
|----------|-------|--------|
| 5 | Project New | Neue Delivery Unit |
| 10 | Project Updated | Status-Änderung |
| 29 | Company New | Neuer Kunde |
| 30 | Company Updated | Kundenänderung |

---

## Rate Limits

| Typ | Limit |
|-----|-------|
| Standard | 100 requests / 10 sec |
| Standard | 4000 requests / 30 min |
| Reports | 10 requests / 30 sec |

---

## Custom Fields für Delivery Units

Um Delivery Unit Typen und AIDD-Status in Productive.io abzubilden:

### Empfohlene Custom Fields

| Field | Typ | Werte |
|-------|-----|-------|
| `delivery_unit_type` | Dropdown | Agent, GPT, Workflow, Integration, Cloud, Workshop, Workshop Series, Advisory |
| `aidd_phase` | Dropdown | Exploration, Decision, Delivery, Done |
| `linear_project_id` | Text | Linear Project ID (wenn vorhanden) |
| `customer_visible` | Boolean | Im Kundenportal anzeigen? |
| `value_summary` | Text | Kundenverständliche Zusammenfassung |

---

## Productizer: Bridge zwischen Systemen

Der Productizer übersetzt:

```
INPUT                           OUTPUT
─────                           ──────
Productive.io Projects    →     Customer Portal
+ AIDD Decisions          →     Service Dashboard
+ Linear Metadata         →     Value Reporting
```

### Transformation Logic

```
┌─────────────────────────────────────────────────────────────────┐
│  INTERN (Tool-Sicht)              EXTERN (Kunden-Sicht)         │
├─────────────────────────────────────────────────────────────────┤
│  Project: "Agent Development"  →  "KI-Assistent für Support"    │
│  Status: "In Delivery"         →  "In Umsetzung"                │
│  Tasks: 12 open, 8 done        →  "Fortschritt: Gut"            │
│  Sprint: Week 3                →  "Nächster Meilenstein: Q1"    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Kunden-Portal Struktur

Jeder Kunde sieht:

### Active Services
```
┌─────────────────────────────────────────────────────────────────┐
│  ACTIVE SERVICES                                                 │
├─────────────────────────────────────────────────────────────────┤
│  ✅ KI-Support-Agent         In Umsetzung    [██████░░░░] 60%   │
│  🔄 Workflow Automation      In Exploration  [██░░░░░░░░] 20%   │
│  ✅ CRM Integration          In Review       [█████████░] 90%   │
└─────────────────────────────────────────────────────────────────┘
```

### Delivered Value
```
┌─────────────────────────────────────────────────────────────────┐
│  DELIVERED VALUE (Q1 2026)                                       │
├─────────────────────────────────────────────────────────────────┤
│  📦 Email-Klassifikation     Deployed        Spart 4h/Woche     │
│  📦 Meeting Summarizer       Deployed        100+ Meetings      │
│  📦 Onboarding Workshop      Completed       Team enabled       │
└─────────────────────────────────────────────────────────────────┘
```

### Decisions & Progress
```
┌─────────────────────────────────────────────────────────────────┐
│  RECENT DECISIONS                                                │
├─────────────────────────────────────────────────────────────────┤
│  2026-01-20  Agent Architektur: RAG statt Fine-Tuning           │
│              → Schnellere Iteration, bessere Kontrolle          │
│                                                                  │
│  2026-01-15  CRM Integration: Native API statt Middleware       │
│              → Direktere Anbindung, weniger Latenz              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Setup für neuen Kunden

### 1. In Productive.io

```
1. Company anlegen
   - Name, Billing Info, Kontakte
   - Tags: z.B. "AI-First", "Enterprise"

2. Erstes Project (Delivery Unit) anlegen
   - Name: Kundenverständlich
   - Type: Client (project_type_id: 2)
   - Custom Fields: delivery_unit_type, aidd_phase
```

### 2. In Linear (wenn technisch)

```
1. Project anlegen
   - Name: [Domain] Customer - Feature
   - Labels: Work Type (Exploration/Delivery/Maintenance)

2. Productive Project ID verknüpfen
   - In Project Description oder Custom Field
```

### 3. Im Kundenportal

```
1. Kunde automatisch sichtbar (via Productive.io Sync)
2. Delivery Units erscheinen als Services
3. Login-Credentials bereitstellen
```

---

## Zusammenfassung

| Aspekt | System | Grund |
|--------|--------|-------|
| Kunde anlegen | Productive.io | System of Record |
| Delivery Unit erstellen | Productive.io | Immer, für jeden Service |
| Technische Arbeit | Linear | Nur wenn Code/Ops |
| Kunden-Reporting | Productizer → Portal | Aggregiert beide |
| Budget/Abrechnung | Productive.io | Finanzielles SoR |

---

## Referenzen

- [Productive.io API Docs](https://developer.productive.io/)
- [Productive.io Webhooks](https://developer.productive.io/webhooks.html)
- [AIDD Workflow](./../skills/linear/SKILL.md)
- [Productizer Skill](./../skills/productizer/SKILL.md)
