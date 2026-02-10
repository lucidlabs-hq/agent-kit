---
name: mastra-mcp
description: Configure Mastra as MCP Server to expose agents and tools via Model Context Protocol. Enables Claude Desktop and other MCP clients to use Mastra tools.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, Glob, Grep
argument-hint: [setup|client|server|claude-config]
---

# Mastra MCP Skill

Konfiguriere Mastra als MCP Server oder Client für das Model Context Protocol.

## Konzept

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MASTRA MCP ARCHITECTURE                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   MCP SERVER MODE                    MCP CLIENT MODE                 │
│   ──────────────                    ────────────────                 │
│   Mastra → exposes tools            Mastra → uses external tools    │
│   to MCP clients                    from MCP servers                │
│                                                                      │
│   ┌─────────────┐                  ┌─────────────┐                  │
│   │   Mastra    │                  │   External  │                  │
│   │   Tools     │─────────────────►│   MCP       │                  │
│   │   Agents    │   MCP Protocol   │   Server    │                  │
│   └─────────────┘                  └─────────────┘                  │
│         │                                │                          │
│         ▼                                ▼                          │
│   ┌─────────────┐                  ┌─────────────┐                  │
│   │   Claude    │                  │   Mastra    │                  │
│   │   Desktop   │                  │   Agent     │                  │
│   └─────────────┘                  └─────────────┘                  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Installation

```bash
# In deinem Mastra-Projekt
pnpm add @mastra/mcp
```

---

## Commands

### `/mastra-mcp setup`

Vollständige MCP-Konfiguration für ein Mastra-Projekt einrichten.

**Was wird erstellt:**
1. MCP Server Entry Point (`src/mcp-server.ts`)
2. Claude Desktop Config (`claude_desktop_config.json`)
3. Package.json Script (`mcp:serve`)

### `/mastra-mcp server`

MCP Server Code für Mastra Tools generieren.

### `/mastra-mcp client [server-url]`

MCP Client konfigurieren um externe Tools zu nutzen.

### `/mastra-mcp claude-config`

Claude Desktop Konfiguration für den lokalen MCP Server generieren.

---

## MCP Server Mode

Exponiere deine Mastra Tools als MCP Server für Claude Desktop und andere Clients.

### Server Implementation

Erstelle `src/mcp-server.ts`:

```typescript
/**
 * Mastra MCP Server
 *
 * Exposes Mastra tools via Model Context Protocol.
 * Use with Claude Desktop or any MCP-compatible client.
 */

import { MCPServer } from '@mastra/mcp/server';
import { tools } from './tools';

const server = new MCPServer({
  name: 'mastra-tools',
  version: '1.0.0',
  tools: Object.values(tools),
});

// Stdio transport for Claude Desktop
server.start();
```

### Package.json Script

```json
{
  "scripts": {
    "mcp:serve": "bun run src/mcp-server.ts"
  }
}
```

### Claude Desktop Config

Pfad: `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS)

```json
{
  "mcpServers": {
    "mastra-tools": {
      "command": "bun",
      "args": ["run", "mcp:serve"],
      "cwd": "/path/to/your/mastra/project"
    }
  }
}
```

---

## MCP Client Mode

Nutze externe MCP Server Tools in deinen Mastra Agents.

### Client Implementation

```typescript
import { MCPClient } from '@mastra/mcp';

// Stdio Transport (lokales CLI Tool)
const localClient = new MCPClient({
  command: 'npx',
  args: ['-y', '@anthropic/mcp-server-filesystem'],
});

// HTTP Transport (Remote Server)
const remoteClient = new MCPClient({
  url: 'https://mcp-server.example.com/api',
});

// Tools entdecken
const tools = await client.getTools();

// In Agent verwenden
const agent = new Agent({
  tools: {
    ...tools,
    // eigene Tools
  },
});
```

---

## Project File Structure

Nach `/mastra-mcp setup`:

```
mastra/
├── src/
│   ├── index.ts           # Hauptserver
│   ├── mcp-server.ts      # MCP Server Entry Point
│   ├── tools/
│   │   └── index.ts       # Exportierte Tools
│   └── agents/
│       └── assistant.ts   # Agent Definition
│
├── claude_desktop_config.json  # Claude Config (kopieren!)
└── package.json               # Mit mcp:serve Script
```

---

## Transport Typen

### Stdio (Standard für Claude Desktop)

```typescript
// Server startet via command line
// Input/Output über stdin/stdout
const server = new MCPServer({ ... });
server.start(); // Stdio mode
```

### HTTP Streamable (Modern)

```typescript
// Server über HTTP
// Protocol version 2025-03-26
const server = new MCPServer({
  transport: 'http',
  port: 3100,
});
```

### SSE (Legacy)

```typescript
// Server-Sent Events
// Protocol version 2024-11-05
// Fallback wenn HTTP Streamable nicht funktioniert
```

---

## Beliebte MCP Server

### Anthropic Official

```bash
# Filesystem Access
npx @anthropic/mcp-server-filesystem

# Git Operations
npx @anthropic/mcp-server-git

# Memory/Knowledge Base
npx @anthropic/mcp-server-memory
```

### Community

```bash
# n8n Workflows
npx @anthropic-ai/mcp-server-n8n

# Notion
npx @anthropic-ai/mcp-server-notion

# Slack
npx @anthropic-ai/mcp-server-slack
```

---

## Debugging

### Server Logs

```bash
# MCP Server mit Debug Output starten
DEBUG=mastra:mcp bun run mcp:serve
```

### Claude Desktop Logs

```bash
# macOS
tail -f ~/Library/Logs/Claude/mcp*.log
```

### Test MCP Connection

```bash
# MCP Inspector Tool
npx @modelcontextprotocol/inspector stdio bun run mcp:serve
```

---

## Best Practices

### 1. Tool Granularität

```
❌ Ein großes "do_everything" Tool
✅ Kleine, fokussierte Tools
```

### 2. Input Validation

```typescript
// Zod Schemas für robuste Validation
inputSchema: z.object({
  query: z.string().min(1).max(1000),
  limit: z.number().int().min(1).max(100).default(10),
}),
```

### 3. Error Handling

```typescript
execute: async (args) => {
  try {
    // Tool logic
  } catch (error) {
    return {
      error: true,
      message: error instanceof Error ? error.message : 'Unknown error',
    };
  }
},
```

### 4. Idempotenz

```
Tools sollten bei mehrfachem Aufruf
mit gleichen Parametern das gleiche
Ergebnis liefern.
```

---

## Referenzen

- [Mastra MCP Documentation](https://mastra.ai/docs/mcp/overview)
- [Mastra MCP Package](https://www.npmjs.com/package/@mastra/mcp)
- [Model Context Protocol Spec](https://spec.modelcontextprotocol.io/)
- [MCP Servers Registry](https://mcpservers.org/)
- [Claude Desktop MCP Guide](https://docs.anthropic.com/claude/docs/mcp)
