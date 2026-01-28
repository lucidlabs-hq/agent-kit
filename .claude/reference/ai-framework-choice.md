# AI Framework Choice: Mastra vs Vercel AI SDK

> Flexibilität für unterschiedliche Projektanforderungen

## Overview

Agent Kit unterstützt **zwei AI-Framework-Optionen**:

| Framework | Best For | Complexity |
|-----------|----------|------------|
| **Vercel AI SDK** | Simple chat, streaming, quick prototypes | Low |
| **Mastra** | Complex agents, tools, workflows | Medium-High |
| **Beide kombiniert** | Full-featured applications | High |

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AI FRAMEWORK DECISION TREE                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   Brauche ich...                                                     │
│                                                                      │
│   ├── Nur Chat/Streaming? ────────────► Vercel AI SDK               │
│   │                                                                  │
│   ├── Einfache Tools (< 5)? ──────────► Vercel AI SDK               │
│   │                                                                  │
│   ├── Komplexe Multi-Step Agents? ────► Mastra                      │
│   │                                                                  │
│   ├── Workflow Orchestration? ────────► Mastra + n8n                │
│   │                                                                  │
│   └── Beides (Chat UI + Agents)? ─────► Vercel AI SDK + Mastra      │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Option 1: Vercel AI SDK (Minimal)

### Wann verwenden?

- ✅ Chat-Interface mit Streaming
- ✅ Einfache Tool-Calls (< 5 Tools)
- ✅ Quick Prototypes
- ✅ Serverless-friendly
- ❌ Komplexe Multi-Agent Orchestration
- ❌ Long-running Workflows

### Installation

```bash
pnpm add ai @ai-sdk/anthropic
```

### Beispiel: Chat Route

```typescript
// app/api/chat/route.ts
import { anthropic } from '@ai-sdk/anthropic';
import { streamText } from 'ai';

export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: anthropic('claude-sonnet-4-20250514'),
    messages,
    tools: {
      getWeather: {
        description: 'Get weather for a location',
        parameters: z.object({
          location: z.string(),
        }),
        execute: async ({ location }) => {
          // Tool implementation
          return { temperature: 20, condition: 'sunny' };
        },
      },
    },
  });

  return result.toDataStreamResponse();
}
```

### Beispiel: useChat Hook

```typescript
// components/Chat.tsx
'use client';
import { useChat } from 'ai/react';

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } = useChat();

  return (
    <div>
      {messages.map((m) => (
        <div key={m.id} className={m.role === 'user' ? 'text-right' : ''}>
          {m.content}
        </div>
      ))}
      <form onSubmit={handleSubmit}>
        <input
          value={input}
          onChange={handleInputChange}
          disabled={isLoading}
          placeholder="Type a message..."
        />
      </form>
    </div>
  );
}
```

### MCP Support (AI SDK 6+)

```typescript
import { experimental_createMCPClient } from 'ai';

const mcpClient = await experimental_createMCPClient({
  transport: {
    type: 'sse',
    url: 'http://localhost:3001/mcp',
  },
});

const tools = await mcpClient.tools();
```

---

## Option 2: Mastra (Full-Featured)

### Wann verwenden?

- ✅ Complex Multi-Step Agents
- ✅ Tool Orchestration (> 5 Tools)
- ✅ Memory & Context Management
- ✅ Workflow Automation
- ✅ RAG Pipelines
- ❌ Overhead für simple Chat

### Installation

```bash
pnpm add @mastra/core @mastra/mcp
```

### Beispiel: Agent Definition

```typescript
// mastra/src/agents/support-agent.ts
import { Agent } from '@mastra/core';
import { anthropic } from '@mastra/anthropic';

export const supportAgent = new Agent({
  name: 'support-agent',
  instructions: `You are a helpful customer support agent.
    - Answer questions about our products
    - Create support tickets when needed
    - Escalate complex issues`,
  model: anthropic('claude-sonnet-4-20250514'),
  tools: [
    createTicketTool,
    searchKnowledgeBaseTool,
    escalateTool,
  ],
});
```

### Beispiel: Tool Definition

```typescript
// mastra/src/tools/create-ticket.ts
import { createTool } from '@mastra/core';
import { z } from 'zod';

export const createTicketTool = createTool({
  name: 'create-ticket',
  description: 'Create a support ticket in the system',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    priority: z.enum(['low', 'medium', 'high']),
  }),
  execute: async ({ title, description, priority }) => {
    // Create ticket in system
    const ticket = await db.tickets.create({ title, description, priority });
    return { ticketId: ticket.id, status: 'created' };
  },
});
```

### MCP Server (Mastra als Provider)

```typescript
// mastra/src/mcp-server.ts
import { MCPServer } from '@mastra/core';
import { supportAgent } from './agents/support-agent';

const server = new MCPServer({
  agents: [supportAgent],
  tools: [createTicketTool, searchKnowledgeBaseTool],
});

// Expose via SSE or stdio
server.start({ transport: 'sse', port: 3001 });
```

---

## Option 3: Kombiniert (Empfohlen für Full Apps)

### Architektur

```
┌─────────────────────────────────────────────────────────────────────┐
│                    COMBINED ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   FRONTEND (Next.js)                                                 │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                                                              │   │
│   │   Vercel AI SDK                                             │   │
│   │   • useChat() for streaming UI                              │   │
│   │   • Simple interactions                                     │   │
│   │                                                              │   │
│   └──────────────────────────┬──────────────────────────────────┘   │
│                              │                                       │
│                              ▼                                       │
│   BACKEND                                                            │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                                                              │   │
│   │   ┌─────────────────┐      ┌─────────────────┐              │   │
│   │   │ /api/chat       │      │ /api/agents/*   │              │   │
│   │   │ (Vercel AI SDK) │      │ (Mastra)        │              │   │
│   │   │                 │      │                 │              │   │
│   │   │ Simple chat     │      │ Complex agents  │              │   │
│   │   │ Quick responses │      │ Multi-step      │              │   │
│   │   └─────────────────┘      └─────────────────┘              │   │
│   │                                                              │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Beispiel: Combined Setup

```typescript
// app/api/chat/route.ts (Vercel AI SDK)
import { anthropic } from '@ai-sdk/anthropic';
import { streamText } from 'ai';

export async function POST(req: Request) {
  const { messages } = await req.json();

  // Simple chat - use Vercel AI SDK directly
  return streamText({
    model: anthropic('claude-sonnet-4-20250514'),
    messages,
  }).toDataStreamResponse();
}
```

```typescript
// app/api/agents/support/route.ts (Mastra)
import { supportAgent } from '@/mastra/agents/support-agent';

export async function POST(req: Request) {
  const { input, context } = await req.json();

  // Complex agent - use Mastra
  const result = await supportAgent.run({
    input,
    context,
  });

  return Response.json(result);
}
```

### Frontend: Unified Interface

```typescript
// hooks/useAI.ts
import { useChat } from 'ai/react';

export function useAI(mode: 'simple' | 'agent' = 'simple') {
  const chatHook = useChat({
    api: mode === 'simple' ? '/api/chat' : '/api/agents/support',
  });

  return chatHook;
}
```

---

## Project Configuration

### Option A: Vercel AI SDK Only

```
frontend/
├── app/
│   └── api/
│       └── chat/
│           └── route.ts      # Vercel AI SDK
└── package.json              # ai, @ai-sdk/anthropic
```

**package.json:**
```json
{
  "dependencies": {
    "ai": "^4.0.0",
    "@ai-sdk/anthropic": "^1.0.0"
  }
}
```

### Option B: Mastra Only

```
frontend/
├── app/
│   └── api/
│       └── agents/
│           └── [agent]/
│               └── route.ts  # Mastra agents
mastra/
├── src/
│   ├── agents/
│   ├── tools/
│   └── index.ts
└── package.json              # @mastra/core
```

### Option C: Combined (Recommended)

```
frontend/
├── app/
│   └── api/
│       ├── chat/
│       │   └── route.ts      # Simple (Vercel AI SDK)
│       └── agents/
│           └── [agent]/
│               └── route.ts  # Complex (Mastra)
mastra/
├── src/
│   ├── agents/
│   ├── tools/
│   └── workflows/
└── package.json
```

---

## create-agent-project.sh Update

Das Scaffold-Script fragt jetzt nach der AI-Framework-Wahl:

```bash
# Während des Setups:
echo "AI Framework Choice:"
echo "1) Vercel AI SDK only (simple chat, quick prototypes)"
echo "2) Mastra only (complex agents, workflows)"
echo "3) Both (recommended for full applications)"
read -p "Choice [3]: " ai_choice
```

---

## Decision Guide

| Requirement | Vercel AI SDK | Mastra | Both |
|-------------|---------------|--------|------|
| Chat UI with streaming | ✅ | 🟡 | ✅ |
| Simple tool calls | ✅ | ✅ | ✅ |
| Complex multi-step agents | ❌ | ✅ | ✅ |
| Workflow orchestration | ❌ | ✅ | ✅ |
| RAG pipeline | 🟡 | ✅ | ✅ |
| Memory management | ❌ | ✅ | ✅ |
| MCP Server exposure | 🟡 | ✅ | ✅ |
| Minimal bundle size | ✅ | ❌ | ❌ |
| Quick prototyping | ✅ | ❌ | 🟡 |

---

## MCP Integration Matrix

| Framework | As MCP Client | As MCP Server |
|-----------|---------------|---------------|
| **Vercel AI SDK** | ✅ experimental_createMCPClient | 🟡 via mcp-handler |
| **Mastra** | ✅ MCPClient | ✅ MCPServer |

### Shared MCP Servers

Beide Frameworks können dieselben MCP Server nutzen:

```typescript
// Shared MCP config
const mcpConfig = {
  linear: 'https://mcp.linear.app/mcp',
  minio: 'http://localhost:3001/minio-mcp',
  n8n: 'http://localhost:3002/n8n-mcp',
};
```

---

## Referenzen

- [Vercel AI SDK Docs](https://sdk.vercel.ai/docs)
- [Vercel AI SDK MCP](https://ai-sdk.dev/docs/ai-sdk-core/mcp-tools)
- [Mastra Documentation](https://mastra.ai/docs)
- [Mastra MCP Overview](https://mastra.ai/docs/mcp/overview)
