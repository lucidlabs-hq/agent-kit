# Audit: Client Service Reporting Dashboard

> Gap-Analyse zwischen PRD-Vision und aktuellem Agent Kit Stand

## Executive Summary

Das Agent Kit hat die **Grundarchitektur** für Linear + Productive.io Integration.
Für die vollständige Realisierung des Service Dashboards fehlen jedoch mehrere **Skills, Templates und Datenstrukturen**.

---

## Ist-Zustand (Was wir haben)

### Skills vorhanden

| Skill | Funktion | Status |
|-------|----------|--------|
| `/linear` | Execution-Tracking, DDD-Flow | ✅ Vollständig |
| `/productizer` | Bridge Linear ↔ Productive.io | ✅ Vollständig |
| `/prime` | Session-Start, Linear-Check | ✅ Vollständig |
| `/session-end` | Session-Ende, Status-Update | ✅ Vollständig |
| `/meeting-decisions` | AIDD-Entscheidungen aus tldv.io Transkripten | ✅ Vollständig |
| `/budget` | Kontingent-Tracking | ✅ Vollständig |

### Dokumentation vorhanden

| Dokument | Inhalt | Status |
|----------|--------|--------|
| `linear-setup.md` | MCP Setup, OAuth | ✅ Vollständig |
| `productive-integration.md` | API, Delivery Units, Webhooks | ✅ Vollständig |

### Architektur vorhanden

```
✅ Zwei-System-Architektur (Linear + Productive.io)
✅ DDD Status Flow (Exploration → Decision → Delivery)
✅ Delivery Unit Konzept
✅ Productizer Bridge Konzept
```

---

## Soll-Zustand (PRD-Anforderungen)

### Stufe 1 – Service Reporting (MVP)

| Anforderung | Beschreibung | Status |
|-------------|--------------|--------|
| Delivery Units aus Productive.io | Projekte als Services darstellen | 🟡 Konzept da, kein Pull |
| Business-Status | Service-Status für Kunden | 🟡 Mapping definiert |
| Time Tracking | Kontingent-Verbrauch anzeigen | ❌ Fehlt |
| Kunden-Dashboard | Read-only Portal | ❌ Fehlt |

### Stufe 2 – Execution-Anbindung

| Anforderung | Beschreibung | Status |
|-------------|--------------|--------|
| Linear-Verknüpfung | Delivery Unit ↔ Linear Project | 🟡 Konzept da |
| Decision-Zusammenfassungen | AIDD-Entscheidungen | ❌ Fehlt |
| Delivery-Fortschritt | Task-Completion-Ratio | ❌ Fehlt |

### Stufe 3 – KI-gestützte Analyse

| Anforderung | Beschreibung | Status |
|-------------|--------------|--------|
| KI-Summaries | Automatische Zusammenfassungen | ❌ Fehlt |
| Thematische Cluster | Service-Gruppierung | ❌ Fehlt |
| Impact-Narrative | Wertbeschreibung generieren | ❌ Fehlt |

### Stufe 4 – Kosten & Agent-Transparenz

| Anforderung | Beschreibung | Status |
|-------------|--------------|--------|
| Agent-Laufzeiten | Coding Agent Tracking | ❌ Fehlt |
| Token-Kosten | LLM-Kosten erfassen | ❌ Fehlt |
| Kombinierte Aufwände | Mensch + Agent | ❌ Fehlt |

### Stufe 5 – Productized Service Platform

| Anforderung | Beschreibung | Status |
|-------------|--------------|--------|
| Kunden-Login | Auth für Portal | ❌ Fehlt |
| Service-Portfolio | Alle Services eines Kunden | ❌ Fehlt |
| Laufende Wertkommunikation | Automatische Updates | ❌ Fehlt |

---

## Gap-Analyse: Was fehlt?

### 1. CRITICAL: Customer Portal Template

**Problem:** Kein Frontend für das Kunden-Dashboard.

**Benötigt:**
- Next.js App Template für Portal
- Convex Auth für Kunden-Login
- Dynamic Routes: `/[customer-slug]`
- Read-only Dashboard Components

**Aufwand:** Eigenständiges Projekt (Downstream)

---

### 2. ~~CRITICAL: Decision Logging Skill~~ ✅ IMPLEMENTED

**Status:** Implementiert als `/meeting-decisions` Skill

**Workflow:**
- Meeting mit tldv.io aufzeichnen
- Transkript exportieren in `.meetings/[date]/`
- `/meeting-decisions .meetings/[date]` ausführen
- Entscheidungsvorschläge reviewen und übernehmen

---

### 3. ~~CRITICAL: Kontingent/Budget Skill~~ ✅ IMPLEMENTED

**Status:** Implementiert als `/budget` Skill

**Funktionen:**
- `/budget status [customer]` - Kontingent-Status anzeigen
- `/budget report [customer]` - Budget-Report generieren
- `/budget warn` - Alle Kunden auf niedriges Kontingent prüfen

**Hinweis:** Read-only Zugriff auf Productive.io (Budgets, Time Entries)

---

### 4. HIGH: Report Generation Enhancement

**Problem:** `/productizer report` ist zu simpel für PRD-Anforderungen.

**Benötigt:**
- Verschiedene Report-Templates pro Delivery Unit Type
- Workshop Report Layout
- Agent Report Layout
- GPT/Prompt Report Layout
- Advisory Report Layout

**Aufwand:** Productizer Skill erweitern

---

### 5. HIGH: Customer Onboarding

**Status:** Manuell in Productive.io

**Workflow:**
- Kunden manuell in Productive.io anlegen
- Delivery Units (Projekte) erstellen
- Via `/productizer sync` Daten abrufen
- Reports via `/productizer report` generieren

---

### 6. MEDIUM: Impact Tracking

**Problem:** Wert/Nutzen wird nicht systematisch erfasst.

**Benötigt:**
- Impact-Felder pro Delivery Unit
- Qualitative + Quantitative Metriken
- KI-gestützte Impact-Zusammenfassung

**Aufwand:** Custom Fields in Productive.io + Skill

---

### 7. MEDIUM: KI-Summary Generation

**Problem:** Keine automatischen Kunden-Summaries.

**Benötigt:**
- LLM-Integration für Summary-Generierung
- Prompt-Templates für verschiedene Report-Typen
- Tonalität: Kunde, nicht Entwickler

**Aufwand:** Mastra Agent oder Skill Extension

---

### 8. FUTURE: Agent Cost Tracking

**Problem:** LLM-Kosten werden nicht erfasst.

**Benötigt:**
- LiteLLM Cost Tracking Integration
- Token-Verbrauch pro Session
- Zuordnung zu Delivery Unit
- Aggregation im Reporting

**Aufwand:** Infrastruktur-Erweiterung

---

### 9. FUTURE: Check-in System

**Problem:** Kein automatischer Arbeitsstart auf Delivery Unit.

**Benötigt:**
- `/checkin [delivery-unit]` Command
- Startet: Time Tracking + Linear Context + Agent
- `/checkout` für Session-Ende

**Aufwand:** Workflow-Integration

---

## Priorisierte Roadmap

### Phase 1: MVP Foundation ✅ COMPLETE

| # | Item | Typ | Status |
|---|------|-----|--------|
| 1 | `/meeting-decisions` Skill | Neuer Skill | ✅ Implementiert |
| 2 | `/budget` Skill | Neuer Skill | ✅ Implementiert |
| 3 | Customer via Productive.io | Manuell | ✅ Workflow definiert |
| 4 | Deadline Communication | Skill Update | ✅ Nur in Delivery |

### Phase 2: Customer Experience (Next)

| # | Item | Typ | Status |
|---|------|-----|--------|
| 5 | Report Templates erweitern | Skill Update | 🟡 Offen |
| 6 | Customer Portal PRD | Dokumentation | 🟡 Offen |
| 7 | Impact Tracking | Custom Fields | 🟡 Offen |
| 8 | KI-Summary Generation | Mastra Agent | 🟡 Offen |

### Phase 3: Advanced Features (Future)

| # | Item | Typ | Status |
|---|------|-----|--------|
| 9 | Agent Cost Tracking | Infrastruktur | ❌ Future |
| 10 | Check-in System | Workflow | ❌ Future |
| 11 | Real-time Portal Updates | Webhooks | ❌ Future |

---

## Implementierte Skills

### `/meeting-decisions` ✅

```yaml
name: meeting-decisions
description: Extract AIDD decisions from tldv.io meeting transcripts
argument-hint: [folder-path]
```

**Workflow:**
- Meeting mit tldv.io aufzeichnen
- Transkript + Notizen in `.meetings/[date]/` ablegen
- `/meeting-decisions .meetings/[date]` ausführen
- Entscheidungsvorschläge reviewen

**Location:** `.claude/skills/meeting-decisions/SKILL.md`

### `/budget` ✅

```yaml
name: budget
description: Track and report customer kontingent usage
argument-hint: [status|report|warn]
```

**Commands:**
- `/budget status [customer]` - Zeige Kontingent-Status
- `/budget report [customer]` - Generiere Budget-Report
- `/budget warn` - Prüfe alle Kunden auf niedriges Kontingent

**Location:** `.claude/skills/budget/SKILL.md`

**Hinweis:** Read-Only Zugriff auf Productive.io

---

## Custom Fields für Productive.io

Um die PRD vollständig zu unterstützen, benötigen wir folgende Custom Fields:

### Project (Delivery Unit) Level

| Field | Typ | Werte | Zweck |
|-------|-----|-------|-------|
| `delivery_unit_type` | Dropdown | Agent, GPT, Workflow, Integration, Workshop, Advisory | Typ-Klassifikation |
| `aidd_phase` | Dropdown | Exploration, Decision, Delivery, Done | Aktueller AIDD-Status |
| `linear_project_id` | Text | Linear ID | Verknüpfung |
| `customer_visible` | Boolean | true/false | Im Portal zeigen? |
| `value_summary` | Text | Freitext | Kunden-Wertbeschreibung |
| `impact_quantitative` | Text | z.B. "4h/Woche gespart" | Messbarer Impact |
| `impact_qualitative` | Text | z.B. "Schnellere Reaktion" | Qualitativer Impact |
| `next_focus` | Text | Freitext | Nächster Schritt |

### Company (Customer) Level

| Field | Typ | Werte | Zweck |
|-------|-----|-------|-------|
| `portal_slug` | Text | kebab-case | URL-Slug für Portal |
| `portal_enabled` | Boolean | true/false | Portal aktiviert? |
| `primary_contact_email` | Text | Email | Portal-Login |

---

## Nächste Schritte

1. ~~**Skills implementieren:**~~ ✅ `/decision`, `/budget`, `/customer` implementiert
2. **Custom Fields:** In Productive.io einrichten (delivery_unit_type, aidd_phase, etc.)
3. **Customer Portal:** Als eigenes Downstream-Projekt anlegen
4. **Report-Templates:** Pro Delivery Unit Type erweitern (Agent, Workshop, Advisory, etc.)

---

## Zusammenfassung

| Kategorie | Vorhanden | Fehlend |
|-----------|-----------|---------|
| **Architektur** | ✅ Komplett | - |
| **Linear Integration** | ✅ Komplett | - |
| **Productive.io Basis** | ✅ Komplett (Read-Only) | - |
| **Decision Tracking** | ✅ `/meeting-decisions` (tldv.io) | - |
| **Budget Tracking** | ✅ `/budget` Skill | - |
| **Customer Management** | 🟡 Manuell in Productive.io | - |
| **Report Templates** | 🟡 Basic | Erweiterte Layouts per Service-Typ |
| **Customer Portal** | ❌ | Eigenes Projekt (Downstream) |
| **KI-Summaries** | ❌ | Mastra Agent |
| **Agent Costs** | ❌ | Future |
| **Deadline Communication** | ✅ In Delivery only | - |

**Hinweis:** Productive.io Integration ist **Read-Only**:
- ✅ Budgets und Time Entries lesen
- ✅ Projekte/Delivery Units abrufen
- ❌ Projekte werden manuell in Productive.io angelegt

**Fazit:** Die MVP-Skills sind implementiert:
- ✅ `/meeting-decisions` für AIDD-Entscheidungen aus tldv.io
- ✅ `/budget` Skill für Kontingent-Tracking (Read-Only)
- ✅ Customer Management manuell via Productive.io

**Noch offen:**
1. Customer Portal als Downstream-Projekt
2. Erweiterte Report-Templates per Delivery Unit Type
3. KI-Summary Generation (Future)
