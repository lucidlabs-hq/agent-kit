---
name: productizer
description: Bridge between Linear (execution) and Productive.io (customer value). Translates internal work into customer-facing service reports.
allowed-tools: Bash, Read, Write
argument-hint: [sync|report|setup]
---

# Productizer

Übersetzt interne Arbeit in kundenverständliche Service-Darstellung.

## Integration Mode

**Read from Productive.io, Display for Customers:**
- ✅ Read projects/Delivery Units from Productive.io
- ✅ Read budgets and time entries
- ✅ Aggregate data for customer reporting
- ✅ Enrich with Linear status (when linked)
- ❌ Create/modify projects in Productive.io (done manually)
- ❌ Create time entries (done manually)

## Konzept

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRODUCTIFYER                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   INPUT                              OUTPUT                      │
│   ─────                              ──────                      │
│   • Productive.io Projects           • Customer Portal Data      │
│   • Linear Status (wenn vorhanden)   • Service Dashboards        │
│   • AIDD Decisions                   • Value Reports             │
│   • Time Entries                     • Progress Updates          │
│                                                                  │
│   TRANSLATION                                                    │
│   ───────────                                                    │
│   "In Delivery, 8/12 tasks"    →    "In Umsetzung, guter        │
│                                      Fortschritt"                │
│                                                                  │
│   "Exploration complete,       →    "Analyse abgeschlossen,     │
│    pivot to RAG"                     optimaler Ansatz gefunden"  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Commands

### `/productizer setup [customer-name]`

Richtet einen neuen Kunden für Reporting ein.

**Schritte:**
1. Prüfe ob Kunde in Productive.io existiert
2. Erstelle Customer Portal Konfiguration
3. Verknüpfe existierende Delivery Units
4. Generiere Initial-Report

**Output:**
```
Customer Setup: [customer-name]
─────────────────────────────────

✓ Productive.io Company: Found (ID: 12345)
✓ Delivery Units: 3 active projects
✓ Portal Config: Created
✓ Initial Report: Generated

Next Steps:
1. Review portal config in .productizer/[customer]/config.json
2. Add Linear project links where applicable
3. Share portal credentials with customer
```

### `/productizer sync`

Synchronisiert Daten zwischen Productive.io und Linear.

**Schritte:**
1. Fetch Productive.io Projects (Delivery Units)
2. Fetch verknüpfte Linear Projects
3. Aggregiere Status und Fortschritt
4. Update Kundenportal-Daten

**Output:**
```
Productizer Sync
─────────────────

Syncing 12 Delivery Units across 4 customers...

Customer: Acme Corp
├── KI-Support-Agent       Linear: In Delivery   → Portal: "In Umsetzung"
├── CRM Integration        Linear: In Review     → Portal: "Fast fertig"
└── Workshop Series        Productive: Active    → Portal: "Läuft"

Customer: Beta GmbH
├── Email Automation       Linear: Done          → Portal: "Deployed"
└── Meeting Summarizer     No Linear             → Portal: "In Planung"

✓ Synced 12 Delivery Units
✓ Updated 4 Customer Portals
```

### `/productizer report [customer-name]`

Generiert Kunden-Report für Portal.

**Output Format:**

```markdown
# Service Report: [Customer Name]
Generated: 2026-01-28

## Ihre Services im Überblick

| Service | Typ | Phase | Deadline | Status |
|---------|-----|-------|----------|--------|
| KI-Support-Agent | Agent | Delivery | 15.02.2026 | 🟢 On Track |
| CRM Integration | Integration | Review | - | 🟡 In Prüfung |

---

## Active Services

### KI-Support-Agent
**Typ:** Agent
**Phase:** 🔨 Delivery
**Deadline:** 15. Februar 2026
**Status:** 🟢 On Track
**Value:** Automatisiert Support-Anfragen, spart geschätzt 4h/Woche

**Letzte Entscheidung:**
> RAG-basierter Ansatz gewählt für bessere Kontrolle und schnellere Anpassung

**Geplante Lieferung:**
- Agent-Training mit echten Daten
- Testphase mit Support-Team

---

### CRM Integration
**Typ:** Integration
**Phase:** 🔍 Review
**Deadline:** -
**Status:** 🟡 In Prüfung
**Value:** Echtzeit-Sync zwischen CRM und internen Systemen

**Letzte Entscheidung:**
> Native API Integration statt Middleware für bessere Performance

**Nächste Schritte:**
- Finale Abnahme
- Go-Live vorbereiten
```

**Note:** Deadlines only appear for services in Delivery phase.

---

## Delivery Unit Mapping

### Status Translation

| Linear Status | AIDD Phase | Customer Portal | Show Deadline? |
|---------------|------------|-----------------|----------------|
| Backlog | - | "Geplant" | ❌ No |
| Exploration | Exploration | "In Analyse" | ❌ No |
| Decision | Decision | "Entscheidung steht an" | ❌ No |
| Delivery | Delivery | "In Umsetzung" | ✅ YES |
| Review | Review | "In Prüfung" | ❌ No |
| Done | Done | "Abgeschlossen" | ❌ No |

**Important:** Deadlines are ONLY communicated in Delivery phase (committed timeline).

### Progress Indicators

| Completion | Label | Visual |
|------------|-------|--------|
| 0-20% | "Gestartet" | [██░░░░░░░░] |
| 21-40% | "In Arbeit" | [████░░░░░░] |
| 41-60% | "Guter Fortschritt" | [██████░░░░] |
| 61-80% | "Weit fortgeschritten" | [████████░░] |
| 81-99% | "Fast fertig" | [█████████░] |
| 100% | "Abgeschlossen" | [██████████] |

---

## Konfiguration

### Projektstruktur

```
.productizer/
├── config.json              # Globale Konfiguration
└── customers/
    ├── acme-corp/
    │   ├── config.json      # Kunden-spezifisch
    │   ├── mappings.json    # Productive ↔ Linear Links
    │   └── reports/
    │       └── 2026-01/
    │           └── report.md
    └── beta-gmbh/
        └── ...
```

### Global Config

```json
{
  "productive": {
    "api_token_env": "PRODUCTIVE_API_TOKEN",
    "org_id_env": "PRODUCTIVE_ORG_ID",
    "base_url": "https://api.productive.io/api/v2"
  },
  "linear": {
    "use_mcp": true
  },
  "portal": {
    "base_url": "https://portal.lucidlabs.de",
    "default_language": "de"
  },
  "sync": {
    "auto_sync": false,
    "sync_interval_hours": 24
  }
}
```

### Customer Config

```json
{
  "customer_id": "12345",
  "name": "Acme Corp",
  "productive_company_id": "67890",
  "portal_slug": "acme-corp",
  "language": "de",
  "delivery_units": [
    {
      "productive_project_id": "111",
      "linear_project_id": "ABC-123",
      "name": "KI-Support-Agent",
      "type": "Agent",
      "customer_visible": true
    }
  ],
  "contacts": [
    {
      "email": "contact@acme.com",
      "portal_access": true
    }
  ]
}
```

---

## Workflow Integration

### Bei Projekt-Start

```
1. /linear create          → Linear Issue für technische Arbeit
2. /productizer setup     → Productive.io Project (Delivery Unit)
3. Verknüpfung speichern   → In mappings.json
```

### Bei Status-Änderung

```
1. Linear Status ändern    → Exploration → Decision → Delivery
2. /productizer sync      → Portal wird aktualisiert
3. Kunde sieht Update      → Automatisch im Dashboard
```

### Bei Projekt-Abschluss

```
1. Linear: Done            → Technische Arbeit fertig
2. Productive.io: Close    → Delivery Unit abgeschlossen
3. /productizer report    → Finaler Wert-Report für Kunden
```

---

## Kundenportal-Architektur

### Schneller Setup für neue Kunden

```
┌─────────────────────────────────────────────────────────────────┐
│  CUSTOMER PORTAL ARCHITECTURE                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Next.js App (Template)                                        │
│   ├── /[customer-slug]        Dynamic customer routes           │
│   ├── Auth via Convex         Customer login                    │
│   └── Data from Productizer  Aggregated service data           │
│                                                                  │
│   Deployment:                                                    │
│   ├── Main Portal: portal.lucidlabs.de                          │
│   └── Customer: portal.lucidlabs.de/[slug]                      │
│                                                                  │
│   Data Flow:                                                     │
│   Productive.io → Productizer → Convex → Portal UI             │
│        ↑                                                        │
│      Linear (when applicable)                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Neuer Kunde in Minuten

```bash
# 1. Kunde in Productive.io anlegen (manuell oder API)

# 2. Productizer Setup
/productizer setup "Neuer Kunde GmbH"

# 3. Portal-Zugang erstellen (Convex Auth)
# → Automatisch via Setup oder manuell

# 4. Kunde kann sich einloggen
# → portal.lucidlabs.de/neuer-kunde-gmbh
```

---

## API Integration (für Portal)

### Productive.io Fetch

```typescript
// Fetch customer projects
async function fetchDeliveryUnits(companyId: string) {
  const response = await fetch(
    `${PRODUCTIVE_BASE_URL}/projects?filter[company_id]=${companyId}`,
    {
      headers: {
        'X-Auth-Token': process.env.PRODUCTIVE_API_TOKEN,
        'X-Organization-Id': process.env.PRODUCTIVE_ORG_ID,
        'Content-Type': 'application/vnd.api+json'
      }
    }
  );
  return response.json();
}
```

### Linear Enrichment (via MCP)

```
// When Linear project is linked
Use Linear MCP to get:
- Current status
- Recent activity
- Task completion ratio
```

### Portal Data Structure

```typescript
interface CustomerPortalData {
  customer: {
    name: string;
    slug: string;
  };
  activeServices: ServiceStatus[];
  deliveredValue: DeliveredItem[];
  recentDecisions: Decision[];
  nextFocus: FocusItem[];
}

interface ServiceStatus {
  name: string;
  type: DeliveryUnitType;
  status: PortalStatus;
  progress: number;
  valueSummary: string;
  lastUpdate: Date;
}
```

---

## Customer Communication Rules

### What to Include

✅ **Service-level information**
- Service name and type
- Current phase (Exploration/Decision/Delivery/Done)
- Deadlines (ONLY in Delivery phase)
- Business value and impact
- Decisions made and their rationale

✅ **Metrics**
- Kontingent usage (hours)
- Progress indicators (phase-based)
- Value delivered

### What to Exclude

❌ **No task-level details**
- Individual tickets/issues
- Technical implementation details
- Sprint/iteration details

❌ **No developer names**
- Team member identities
- Who worked on what
- Individual contributions

❌ **No internal process**
- Code changes
- Technical debt discussions
- Internal meetings

### Focus: Service → Decisions → Value

| Area | Customer Sees |
|------|---------------|
| **Service** | What they're getting |
| **Decisions** | Why we chose this approach |
| **Value** | What benefit they receive |
| **Deadline** | When Delivery completes (only in Delivery) |

---

## Best Practices

### 1. Kundensprache verwenden

```
❌ "Sprint 3, 8/12 Story Points"
✅ "Guter Fortschritt, Lieferung geplant für 15. Februar"
```

### 2. Wert kommunizieren

```
❌ "Agent deployed"
✅ "KI-Agent automatisiert jetzt 40% der Support-Anfragen"
```

### 3. Entscheidungen erklären

```
❌ "Pivot zu RAG"
✅ "Nach Analyse: RAG-Ansatz gewählt für bessere Kontrolle
    und schnellere Anpassung"
```

### 4. Deadlines nur in Delivery

```
❌ Exploration: "Deadline: 15. Februar"
✅ Delivery: "Liefertermin: 15. Februar"
```

### 5. Regelmäßig syncen

```
/productizer sync  # Mindestens wöchentlich
```

---

## Referenzen

- [Productive.io Integration](./../reference/productive-integration.md)
- [Linear Workflow](./../skills/linear/SKILL.md)
- [AIDD Methodik](./../reference/architecture.md)
