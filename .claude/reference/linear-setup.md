# Linear Setup Guide

> Complete setup instructions for Linear integration with Claude Code.

## Overview

| What | When | Where |
|------|------|-------|
| MCP Server hinzufügen | Einmalig pro Maschine | Terminal |
| OAuth Login | Einmalig pro Maschine | Browser |
| Token refresh | Nur bei Problemen | Claude Session |

---

## Einmalige Einrichtung (pro Maschine)

### Schritt 1: Linear MCP Server hinzufügen

```bash
claude mcp add --transport http linear-server https://mcp.linear.app/mcp
```

**Was passiert:**
- Fügt Linear als MCP Server zu Claude Code hinzu
- Konfiguration wird in `~/.claude/` gespeichert
- Muss nur einmal pro Maschine ausgeführt werden

### Schritt 2: OAuth Authentifizierung

Starte eine Claude Session und führe aus:

```
/mcp
```

**Was passiert:**
1. Browser öffnet sich
2. Linear Login-Seite erscheint
3. Mit Lucid Labs Account einloggen
4. Berechtigung für Claude Code erteilen
5. Token wird in `~/.mcp-auth/` gespeichert

**Workspace:** Du wirst automatisch mit `lucid-labs-agents` verbunden.

### Schritt 3: Verbindung testen

```
/linear status
```

Sollte zeigen:
- Workspace: lucid-labs-agents
- Deine zugewiesenen Issues
- Verbindungsstatus

---

## Nach der Einrichtung

### Normaler Workflow

Nach der einmaligen Einrichtung funktioniert Linear automatisch:

```
/prime              # Zeigt Linear Issues
/linear create      # Neues Issue erstellen
/linear update      # Issue Status ändern
/session-end        # Linear updaten am Ende
```

### Keine erneute Anmeldung nötig

- Token bleibt in `~/.mcp-auth/` gespeichert
- Gilt für alle Projekte auf dieser Maschine
- Hält mehrere Wochen/Monate

---

## Troubleshooting

### Problem: "MCP connection failed"

```bash
# Token-Cache löschen
rm -rf ~/.mcp-auth

# Neu authentifizieren
# In Claude Session:
/mcp
```

### Problem: "Linear MCP not found"

```bash
# MCP Server erneut hinzufügen
claude mcp add --transport http linear-server https://mcp.linear.app/mcp
```

### Problem: "Unauthorized" oder "401 Error"

Token abgelaufen - neu authentifizieren:

```
/mcp
```

### Problem: WSL auf Windows

Nutze SSE Endpoint statt HTTP:

```bash
claude mcp add --transport sse linear-server https://mcp.linear.app/sse
```

---

## Alternative: API Key (für Automation)

Für CI/CD oder automatisierte Workflows ohne interaktives Login:

### API Key erstellen

1. https://linear.app/lucid-labs-agents/settings/api
2. "Personal API keys" → "Create key"
3. Name: z.B. "Claude Code CI"
4. Key kopieren (wird nur einmal angezeigt!)

### Environment Variable setzen

```bash
# In .env oder shell profile
export LINEAR_API_KEY=lin_api_...
```

**Hinweis:** API Key ist für Automation gedacht. Für normale Entwicklung ist OAuth besser (automatische Token-Erneuerung).

---

## Zusammenfassung

```
┌─────────────────────────────────────────────────────────────────┐
│                    LINEAR SETUP                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   EINMALIG (pro Maschine)                                       │
│   ───────────────────────                                       │
│   1. claude mcp add --transport http \                          │
│         linear-server https://mcp.linear.app/mcp                │
│   2. /mcp (in Claude Session → Browser Login)                   │
│                                                                  │
│   DANACH (automatisch)                                          │
│   ────────────────────                                          │
│   Token in ~/.mcp-auth/ gespeichert                             │
│   Funktioniert für alle Projekte                                │
│   Kein erneutes Login nötig                                     │
│                                                                  │
│   BEI PROBLEMEN                                                  │
│   ─────────────                                                  │
│   rm -rf ~/.mcp-auth && /mcp                                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Neue Teammitglieder

Wenn jemand neu im Team ist:

1. **Lucid Labs Linear Account** - Einladung zu `lucid-labs-agents` Workspace
2. **Claude Code installieren** - Falls noch nicht vorhanden
3. **MCP Setup** - Die zwei Befehle oben ausführen
4. **Fertig** - Linear funktioniert in allen Projekten

---

## Referenzen

- [Linear MCP Docs](https://linear.app/docs/mcp)
- [Linear API Docs](https://developers.linear.app/)
- [OAuth 2.0 Setup](https://linear.app/developers/oauth-2-0-authentication)
