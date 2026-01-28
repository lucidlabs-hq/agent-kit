# MCP Servers Overview

> Alle Model Context Protocol Server für Agent Kit (Stand: Januar 2026)

## Übersicht

```
┌─────────────────────────────────────────────────────────────────────┐
│                     AGENT KIT MCP ECOSYSTEM                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   PROJECT MANAGEMENT        FILE & DATA           AI & TESTING       │
│   ──────────────────        ──────────           ────────────        │
│   ┌─────────────┐          ┌─────────────┐      ┌─────────────┐     │
│   │   Linear    │          │    MinIO    │      │  PromptFoo  │     │
│   │   (Issues)  │          │   (Files)   │      │   (Eval)    │     │
│   └─────────────┘          └─────────────┘      └─────────────┘     │
│                                                                      │
│   AUTOMATION                DEVELOPMENT          DOCUMENTATION       │
│   ──────────                ───────────          ─────────────       │
│   ┌─────────────┐          ┌─────────────┐      ┌─────────────┐     │
│   │     n8n     │          │   Mastra    │      │  Mastra Docs│     │
│   │ (Workflows) │          │  (Agents)   │      │   Server    │     │
│   └─────────────┘          └─────────────┘      └─────────────┘     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## MCP Server Konfiguration

### Schnellstart: Alle Server hinzufügen

```bash
# Linear (Project Management)
claude mcp add --transport http linear-server https://mcp.linear.app/mcp

# MinIO (File Storage)
claude mcp add minio-server -- npx -y @minio/mcp-server-aistor

# n8n (Workflow Automation)
claude mcp add n8n-server -- npx -y @anthropic-ai/mcp-server-n8n

# PromptFoo (LLM Evaluation)
claude mcp add promptfoo -- npx promptfoo@latest mcp --transport stdio

# Mastra Docs (Framework Documentation)
claude mcp add mastra-docs -- npx -y @mastra/mcp-docs-server
```

---

## Server Details

### 1. Linear MCP Server

**Zweck:** Issue Tracking, Project Management, DDD Status Flow

| Feature | Verfügbar |
|---------|-----------|
| Issues lesen/erstellen | ✅ |
| Status ändern | ✅ |
| Kommentare hinzufügen | ✅ |
| Projects verwalten | ✅ |
| Labels/Tags | ✅ |

**Setup:**
```bash
claude mcp add --transport http linear-server https://mcp.linear.app/mcp
# Bei erstem Aufruf: OAuth Login im Browser
```

**Tools:**
- `list_issues` - Issues auflisten
- `create_issue` - Issue erstellen
- `update_issue` - Issue aktualisieren
- `add_comment` - Kommentar hinzufügen

**Referenz:** [Linear Setup](./../reference/linear-setup.md)

---

### 2. MinIO MCP Server

**Zweck:** S3-kompatible File Storage für Dokumente, Reports, Artefakte

| Feature | Verfügbar |
|---------|-----------|
| Buckets verwalten | ✅ |
| Dateien upload/download | ✅ |
| Presigned URLs | ✅ |
| Policies | ✅ |

**Setup:**
```bash
claude mcp add minio-server -- npx -y @minio/mcp-server-aistor
```

**Environment Variables:**
```env
MINIO_ENDPOINT=minio.example.com
MINIO_ACCESS_KEY=your-key
MINIO_SECRET_KEY=your-secret
MINIO_USE_SSL=true
```

**Tools:**
- `list_buckets` - Buckets auflisten
- `list_bucket_contents` - Objekte auflisten
- `get_object` - Datei herunterladen
- `put_object` - Datei hochladen

**Referenz:** [MinIO Integration](./../reference/minio-integration.md)

---

### 3. n8n MCP Server

**Zweck:** Workflow Automation, Agent Trigger, External Integrations

| Feature | Verfügbar |
|---------|-----------|
| Workflows auflisten | ✅ |
| Workflows ausführen | ✅ |
| Workflow erstellen | ✅ |
| Execution History | ✅ |

**Setup (Option A - Community):**
```bash
claude mcp add n8n-server -- npx -y @anthropic-ai/mcp-server-n8n
```

**Setup (Option B - n8n Native):**
n8n hat native MCP-Unterstützung via **MCP Server Trigger** Node.

**Environment Variables:**
```env
N8N_HOST=https://n8n.example.com
N8N_API_KEY=your-api-key
```

**Tools:**
- `list_workflows` - Workflows auflisten
- `execute_workflow` - Workflow ausführen
- `get_executions` - Execution History

**Referenz:** [n8n Workflow Skill](./../skills/n8n-workflow/SKILL.md)

---

### 4. PromptFoo MCP Server

**Zweck:** LLM Evaluation, Prompt Testing, Red Teaming, Self-Learning

| Feature | Verfügbar |
|---------|-----------|
| Evaluations ausführen | ✅ |
| Prompts vergleichen | ✅ |
| Red Team Scans | ✅ |
| Ergebnisse abrufen | ✅ |

**Setup:**
```bash
claude mcp add promptfoo -- npx promptfoo@latest mcp --transport stdio
```

**Environment Variables:**
```env
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
PROMPTFOO_CACHE_PATH=.promptfoo/cache
```

**Tools:**
- `run_eval` - Evaluation ausführen
- `compare_prompts` - Prompts vergleichen
- `run_redteam` - Security Scan
- `get_results` - Ergebnisse abrufen

**Referenz:** [PromptFoo Skill](./../skills/promptfoo/SKILL.md)

---

### 5. Mastra MCP Server (Als Provider)

**Zweck:** Mastra Agents als MCP Tools exponieren

| Feature | Verfügbar |
|---------|-----------|
| Agents als Tools | ✅ |
| Tools exponieren | ✅ |
| SSE Transport | ✅ |
| stdio Transport | ✅ |

**Setup (Server starten):**
```typescript
// mastra/src/mcp-server.ts
import { MCPServer } from '@mastra/core';
import { supportAgent } from './agents/support-agent';

const server = new MCPServer({
  agents: [supportAgent],
  tools: [createTicketTool],
});

server.start({ transport: 'sse', port: 3001 });
```

**Claude Konfiguration:**
```json
{
  "mcpServers": {
    "mastra": {
      "transport": "sse",
      "url": "http://localhost:3001/mcp"
    }
  }
}
```

**Referenz:** [AI Framework Choice](./../reference/ai-framework-choice.md)

---

### 6. Mastra Docs MCP Server

**Zweck:** Mastra Framework Dokumentation für Claude

**Setup:**
```bash
claude mcp add mastra-docs -- npx -y @mastra/mcp-docs-server
```

**Features:**
- Vollständige Mastra Dokumentation
- Code-Beispiele
- Changelog
- Blog Posts

---

## Kombinierte Konfiguration

### settings.json (Vollständig)

```json
{
  "mcpServers": {
    "linear": {
      "transport": "http",
      "url": "https://mcp.linear.app/mcp"
    },
    "minio": {
      "command": "npx",
      "args": ["-y", "@minio/mcp-server-aistor"],
      "env": {
        "MINIO_ENDPOINT": "minio.example.com",
        "MINIO_ACCESS_KEY": "${MINIO_ACCESS_KEY}",
        "MINIO_SECRET_KEY": "${MINIO_SECRET_KEY}",
        "MINIO_USE_SSL": "true"
      }
    },
    "n8n": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-n8n"],
      "env": {
        "N8N_HOST": "${N8N_HOST}",
        "N8N_API_KEY": "${N8N_API_KEY}"
      }
    },
    "promptfoo": {
      "command": "npx",
      "args": ["promptfoo@latest", "mcp", "--transport", "stdio"],
      "env": {
        "ANTHROPIC_API_KEY": "${ANTHROPIC_API_KEY}",
        "OPENAI_API_KEY": "${OPENAI_API_KEY}"
      }
    },
    "mastra-docs": {
      "command": "npx",
      "args": ["-y", "@mastra/mcp-docs-server"]
    }
  }
}
```

---

## MCP Server Status

| Server | Offiziell | Transport | Auth |
|--------|-----------|-----------|------|
| Linear | ✅ Anthropic Partner | HTTP (SSE) | OAuth 2.0 |
| MinIO | ✅ Offiziell | stdio | API Key |
| n8n | 🟡 Community + Native | stdio/SSE | API Key |
| PromptFoo | ✅ Offiziell | stdio/HTTP | API Keys |
| Mastra | ✅ Offiziell | stdio/SSE | - |

---

## Troubleshooting

### MCP Server nicht erreichbar

```bash
# Server Status prüfen
claude mcp list

# Server entfernen und neu hinzufügen
claude mcp remove [server-name]
claude mcp add [server-name] ...
```

### OAuth Probleme (Linear)

```bash
# Auth Cache löschen
rm -rf ~/.mcp-auth

# Neu authentifizieren
# (in Claude Session /mcp ausführen)
```

### Environment Variables nicht geladen

```bash
# Prüfen ob .env geladen wird
echo $MINIO_ACCESS_KEY

# Oder direkt in Settings setzen (nicht empfohlen für Secrets)
```

---

## Referenzen

- [Model Context Protocol Spec](https://modelcontextprotocol.io/)
- [Anthropic MCP Announcement](https://www.anthropic.com/news/model-context-protocol)
- [Claude Code MCP Docs](https://code.claude.com/docs/en/mcp)
- [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
