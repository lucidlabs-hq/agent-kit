---
name: budget
description: Track and report customer kontingent usage from Productive.io. Monitor budget consumption and warn on low kontingent.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, WebFetch
argument-hint: [status|report|warn]
---

# Budget Tracking Skill

Track customer kontingent (budget/hours) usage via Productive.io Time Entries.

## Integration Mode

**Read-Only** - This skill reads data from Productive.io but does not write:
- ✅ Read budgets and kontingent
- ✅ Read time entries
- ✅ Aggregate hours per project
- ❌ Create projects (done manually in Productive.io)
- ❌ Create time entries (done manually in Productive.io)

## Purpose

Budget tracking is essential for:
- Customer transparency on hours consumed
- Proactive warnings before kontingent exhaustion
- Accurate invoicing and reporting
- Resource planning

---

## Commands

### `/budget status [customer]`

Show current kontingent status for a customer.

**Output:**
```
┌─────────────────────────────────────────────────────┐
│  BUDGET STATUS: [Customer Name]                     │
├─────────────────────────────────────────────────────┤
│  Delivery Unit          Booked    Used    Remaining │
│  ─────────────────────  ──────    ────    ───────── │
│  Agent: Support Bot      40h      28h       12h     │
│  Workshop: AI Training   16h      16h        0h ⚠️  │
│  Advisory: Strategy       8h       4h        4h     │
├─────────────────────────────────────────────────────┤
│  TOTAL                   64h      48h       16h     │
│  Usage: ████████████░░░░ 75%                        │
└─────────────────────────────────────────────────────┘
```

**Data Sources:**
1. Productive.io → Budget per Delivery Unit
2. Productive.io → Time Entries (logged hours)
3. Calculate: Remaining = Booked - Used

### `/budget report [customer]`

Generate a detailed budget report for customer communication.

**Report Contents:**
1. Executive Summary
2. Budget Overview (all Delivery Units)
3. Time Entry Details (by service)
4. Burn Rate Analysis
5. Recommendations

**Output Format:** Markdown for customer-ready sharing

### `/budget warn`

Check all customers for low kontingent and generate warnings.

**Thresholds:**
- 🟢 **Healthy:** > 50% remaining
- 🟡 **Attention:** 20-50% remaining
- 🔴 **Critical:** < 20% remaining
- ⚠️ **Exhausted:** 0% remaining

**Actions:**
1. List all customers with < 50% remaining
2. Highlight critical/exhausted kontingents
3. Suggest follow-up actions

---

## Productive.io API Integration

### Fetching Budgets

```bash
# Get all budgets for organization
curl -X GET "https://api.productive.io/api/v2/budgets" \
  -H "Content-Type: application/vnd.api+json" \
  -H "X-Auth-Token: ${PRODUCTIVE_API_TOKEN}" \
  -H "X-Organization-Id: ${PRODUCTIVE_ORG_ID}"
```

**Budget Response Fields:**
```json
{
  "data": {
    "id": "budget_id",
    "attributes": {
      "name": "Monthly Retainer",
      "budget_type": "time_and_materials",
      "total_hours": 40,
      "spent_hours": 28,
      "remaining_hours": 12
    },
    "relationships": {
      "project": { "data": { "id": "project_id" } },
      "company": { "data": { "id": "company_id" } }
    }
  }
}
```

### Fetching Time Entries

```bash
# Get time entries for a project
curl -X GET "https://api.productive.io/api/v2/time_entries?filter[project_id]=PROJECT_ID" \
  -H "Content-Type: application/vnd.api+json" \
  -H "X-Auth-Token: ${PRODUCTIVE_API_TOKEN}" \
  -H "X-Organization-Id: ${PRODUCTIVE_ORG_ID}"
```

**Time Entry Response Fields:**
```json
{
  "data": {
    "id": "time_entry_id",
    "attributes": {
      "date": "2026-01-15",
      "time": 120,
      "note": "Agent development session"
    },
    "relationships": {
      "person": { "data": { "id": "person_id" } },
      "service": { "data": { "id": "service_id" } },
      "task": { "data": { "id": "task_id" } }
    }
  }
}
```

---

## Budget Report Template

```markdown
# Budget Report: [Customer Name]

**Report Period:** [Start Date] - [End Date]
**Generated:** [Current Date]

## Executive Summary

[Customer Name] hat aktuell **[X]h von [Y]h** des gebuchten Kontingents verbraucht.
Das entspricht einer Auslastung von **[Z]%**.

## Kontingent-Übersicht

| Delivery Unit | Typ | Gebucht | Verbraucht | Verbleibend | Status |
|--------------|-----|---------|------------|-------------|--------|
| [Name] | [Type] | [X]h | [Y]h | [Z]h | 🟢/🟡/🔴 |

## Aktivitäten im Berichtszeitraum

### [Delivery Unit 1]

| Datum | Aktivität | Dauer |
|-------|-----------|-------|
| [Date] | [Description] | [Hours] |

**Gesamt:** [X]h

### [Delivery Unit 2]

...

## Burn-Rate Analyse

- **Durchschnittlicher Verbrauch:** [X]h pro Woche
- **Geschätzte Restlaufzeit:** [Y] Wochen
- **Empfohlene Handlung:** [Recommendation]

## Empfehlungen

1. [Recommendation based on usage patterns]
2. [Recommendation for next period]
3. [Recommendation for kontingent adjustment]

---

*Report generiert via /budget skill*
*Datenquelle: Productive.io*
```

---

## Workflow Integration

```
Session Start              During Work              Reporting
─────────────              ───────────              ─────────
/prime                     Log time in             /budget status
↓                          Productive.io           /budget report
Check kontingent           ↓                       ↓
status                     Time accumulates        Customer update
```

### Automated Checks

Consider adding to `/prime`:
```
1. Check customer kontingent status
2. Warn if < 20% remaining
3. Block work if 0% remaining (optional)
```

---

## Configuration

### Environment Variables

```env
# Productive.io API Access
PRODUCTIVE_API_TOKEN=your-api-token
PRODUCTIVE_ORG_ID=your-organization-id
```

### Customer Mapping

Store customer → Productive.io mapping in `.productive-config`:

```yaml
customers:
  customer-slug:
    productive_company_id: "123456"
    productive_project_ids:
      - "789012"  # Main project
      - "345678"  # Secondary project
    kontingent_warning_threshold: 0.2  # 20%
    kontingent_critical_threshold: 0.1  # 10%
```

---

## Alert Templates

### Low Kontingent Warning (Internal)

```markdown
⚠️ LOW KONTINGENT ALERT

Customer: [Name]
Delivery Unit: [Name]
Remaining: [X]h ([Y]%)
Burn Rate: [Z]h/week
Estimated Empty: [Date]

Action Required:
- [ ] Contact customer about extension
- [ ] Review planned work scope
- [ ] Prioritize remaining hours
```

### Kontingent Exhausted (Internal)

```markdown
🔴 KONTINGENT EXHAUSTED

Customer: [Name]
Delivery Unit: [Name]
Status: 0h remaining

Immediate Actions:
1. Pause non-critical work
2. Contact customer
3. Document incomplete items

Do NOT continue work without:
- [ ] Customer approval for extension
- [ ] New kontingent booked in Productive.io
```

### Customer Notification (Draft)

```markdown
Betreff: Kontingent-Update für [Service Name]

Hallo [Contact],

Ihr aktueller Kontingent-Status für [Service Name]:

- Gebucht: [X]h
- Verbraucht: [Y]h
- Verbleibend: [Z]h

[If low:]
Um die Kontinuität unserer Zusammenarbeit zu gewährleisten,
empfehlen wir eine Aufstockung des Kontingents.

[Options for extension]

Bei Fragen stehen wir gerne zur Verfügung.

Mit freundlichen Grüßen,
[Team]
```

---

## Checklist

Before running budget commands:

- [ ] Productive.io API credentials configured?
- [ ] Customer mapping exists in `.productive-config`?
- [ ] Time entries up to date in Productive.io?

After generating reports:

- [ ] Review for accuracy?
- [ ] Customer-appropriate language?
- [ ] Recommendations actionable?
- [ ] Follow-up tasks created if needed?
