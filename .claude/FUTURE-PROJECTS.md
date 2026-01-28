# Future Projects & Tech Stack Backlog

> **Purpose:** Ideen-Backlog für zukünftige Projekte und Tech-Stack Erweiterungen.
> Dies ist KEIN Sprint-Backlog, sondern ein Ideenspeicher.

---

## Infrastructure

### Monitoring Satellite Server
- **Was:** Separater kleiner Server für Monitoring & Observability
- **Stack:** Uptime Kuma, evtl. Grafana, Prometheus
- **Server:** SMALL-1C-2G auf Elestio
- **Domain:** monitoring.lucidlabs.de oder status.lucidlabs.app
- **Priorität:** Medium
- **Notizen:**
  - Überwacht alle LUCIDLABS-HQ Projekte
  - Status Page für Kunden
  - Alerting via Slack/Email

### Centralized Logging
- **Was:** Log-Aggregation für alle Projekte
- **Stack:** Loki + Grafana oder LogTail
- **Priorität:** Low
- **Notizen:**
  - Alle Container logs an einem Ort
  - Debugging über Projekte hinweg

---

## Platform Tools

### Lucid Labs Website
- **Was:** Eigene Website von Framer portieren
- **Stack:** Next.js 15, Tailwind, shadcn/ui
- **Domain:** lucidlabs.de
- **Priorität:** Medium
- **Notizen:**
  - Agent Demos einbetten
  - Portfolio/Case Studies
  - Interaktive AI-Showcases

### Agent Demo Hub
- **Was:** Zentrale Demo-Seite für alle Agents
- **Stack:** Next.js + Mastra
- **Priorität:** Medium
- **Notizen:**
  - Showcase für Kunden
  - Live-Demos der verschiedenen Agents
  - Eingebettet in Website

### Report Generator Platform
- **Was:** Dashboards und Reports für Kunden
- **Stack:** Next.js, Charts, PDF Export
- **Priorität:** Medium
- **Notizen:**
  - Service-Reports aus Productive.io
  - Projekt-Dashboards
  - Automatisierte Berichte

---

## Agent Projects (Ideen)

### Document Intelligence Suite
- **Was:** Sammlung von Dokumenten-Agents
- **Use Cases:**
  - Vertragsanalyse
  - Rechnungsverarbeitung (invoice-accounting-assistant)
  - Dokumentenklassifikation
- **Priorität:** High (teilweise in Arbeit)

### Customer Service Agent
- **Was:** AI-gestützter Kundenservice
- **Stack:** Mastra + n8n + CRM Integration
- **Priorität:** Low

### Knowledge Base Agent
- **Was:** RAG-basierter Wissens-Agent
- **Stack:** Mastra + Convex Vector Search
- **Priorität:** Medium

---

## Developer Experience

### CLI Tool für Agent Kit
- **Was:** `lucid` CLI für schnelleres Arbeiten
- **Commands:**
  - `lucid init` - Neues Projekt
  - `lucid deploy` - Deploy zu HQ
  - `lucid status` - Projekt-Status
- **Priorität:** Low

### Shared Component Library
- **Was:** Wiederverwendbare UI-Komponenten
- **Stack:** shadcn/ui basiert, als npm Package
- **Priorität:** Low

---

## How to Use

### Neue Idee hinzufügen

```markdown
### [Projekt Name]
- **Was:** [Kurzbeschreibung]
- **Stack:** [Technologien]
- **Priorität:** High | Medium | Low
- **Notizen:**
  - [Details]
```

### Idee zu echtem Projekt machen

1. Erstelle Linear Issue mit Details
2. Verschiebe Eintrag in "In Progress" Sektion unten
3. Nach `/init-project` hier entfernen

---

## In Progress

_Projekte die gerade umgesetzt werden:_

### invoice-accounting-assistant
- **Status:** PRD fertig, Phase 1 in Arbeit
- **Linear:** [Link einfügen]

### LUCIDLABS-HQ Server
- **Status:** Setup läuft
- **Linear:** -

---

## Done

_Abgeschlossene Projekte (zur Referenz):_

- _Noch keine_

---

**Last Updated:** 2026-01-28
