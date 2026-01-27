# Mastra AI Framework Best Practices Reference

Best practices for building AI agents, tools, and workflows with Mastra.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Project Structure](#2-project-structure)
3. [Agent Definition](#3-agent-definition)
4. [Tools](#4-tools)
5. [Workflows](#5-workflows)
6. [RAG & Knowledge](#6-rag--knowledge)
7. [Integration Patterns](#7-integration-patterns)
8. [Error Handling](#8-error-handling)
9. [Testing](#9-testing)
10. [Production](#10-production)

---

## 1. Overview

Mastra is a TypeScript-first AI framework for building agents, tools, and workflows.

### Key Concepts

| Concept | Description |
|---------|-------------|
| Agent | AI entity with instructions and tools |
| Tool | Function the agent can call |
| Workflow | Multi-step process with state |
| Memory | Conversation history |
| RAG | Retrieval-augmented generation |

---

## 2. Project Structure

### Agent Kit Mastra Structure

```
mastra/
├── src/
│   ├── index.ts              # Mastra instance & server
│   ├── agents/
│   │   └── assistant.ts      # Agent definitions
│   ├── tools/
│   │   └── index.ts          # Tool registry
│   └── workflows/
│       └── index.ts          # Workflow definitions
├── package.json
├── tsconfig.json
├── Dockerfile
└── README.md
```

---

## 3. Agent Definition

### Basic Agent

```typescript
// agents/assistant.ts
import { Agent } from '@mastra/core';

export const assistant = new Agent({
  name: 'assistant',
  instructions: `You are a helpful AI assistant.

Your capabilities:
- Answer questions accurately
- Help with task management
- Provide explanations and guidance

Always be helpful, accurate, and concise.`,
  model: {
    provider: 'ANTHROPIC',
    name: 'claude-sonnet-4-20250514',
    toolChoice: 'auto',
  },
  tools: {
    // Add tools here
  },
});
```

### System Prompt Best Practices

```typescript
// agents/instructions.ts
export const ASSISTANT_INSTRUCTIONS = `
## Your Role
You are [description of role and purpose].

## Capabilities
- [Capability 1]
- [Capability 2]
- [Capability 3]

## Guidelines
1. [Guideline 1]
2. [Guideline 2]
3. [Guideline 3]

## Response Format
[Describe expected response format]
`.trim();
```

---

## 4. Tools

### Tool Definition Pattern

```typescript
// tools/searchTool.ts
import { createTool } from '@mastra/core';
import { z } from 'zod';

export const searchTool = createTool({
  id: 'search',
  description: 'Search for information in the knowledge base',
  inputSchema: z.object({
    query: z.string().describe('The search query'),
    limit: z.number().default(5).describe('Max results to return'),
  }),
  outputSchema: z.object({
    results: z.array(z.object({
      title: z.string(),
      content: z.string(),
      score: z.number(),
    })),
    totalCount: z.number(),
  }),
  execute: async ({ context }) => {
    const { query, limit } = context;

    // Implementation here
    const results = await performSearch(query, limit);

    return {
      results,
      totalCount: results.length,
    };
  },
});
```

### External API Tool

```typescript
// tools/externalApi.ts
import { createTool } from '@mastra/core';
import { z } from 'zod';

export const fetchDataTool = createTool({
  id: 'fetch-data',
  description: 'Fetch data from external API',
  inputSchema: z.object({
    resourceId: z.string(),
  }),
  outputSchema: z.object({
    data: z.any().nullable(),
    error: z.string().optional(),
  }),
  execute: async ({ context }) => {
    const { resourceId } = context;

    try {
      const response = await fetch(
        `${process.env.API_URL}/resources/${resourceId}`,
        {
          headers: {
            'Authorization': `Bearer ${process.env.API_KEY}`,
          },
        }
      );

      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }

      const data = await response.json();
      return { data };
    } catch (error) {
      return {
        data: null,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  },
});
```

---

## 5. Workflows

### Basic Workflow

```typescript
// workflows/taskProcessing.ts
import { Workflow, Step } from '@mastra/core';
import { z } from 'zod';

export const taskProcessingWorkflow = new Workflow({
  name: 'task-processing',
  triggerSchema: z.object({
    taskId: z.string(),
    taskData: z.object({
      title: z.string(),
      description: z.string(),
    }),
  }),
});

// Step 1: Analyze
const analyzeStep = new Step({
  id: 'analyze',
  execute: async ({ context, mastra }) => {
    const agent = mastra.getAgent('assistant');
    const result = await agent.generate(
      `Analyze this task: ${context.triggerData.taskData.title}`
    );

    return {
      analysis: result.text,
    };
  },
});

// Step 2: Process
const processStep = new Step({
  id: 'process',
  execute: async ({ context }) => {
    const { analysis } = context.getStepResult('analyze');

    // Process based on analysis
    return {
      processed: true,
      details: analysis,
    };
  },
});

// Wire up the workflow
taskProcessingWorkflow
  .step(analyzeStep)
  .then(processStep)
  .commit();
```

### Conditional Branching

```typescript
// Workflow with conditions
workflow
  .step(classifyStep)
  .then(checkConditionStep)
  .then(pathAStep, {
    when: { 'check-condition.result': 'A' },
  })
  .then(pathBStep, {
    when: { 'check-condition.result': 'B' },
  })
  .commit();
```

---

## 6. RAG & Knowledge

### Using Convex Vector Search

```typescript
// tools/knowledge/search.ts
import { createTool } from '@mastra/core';
import { z } from 'zod';
import { api } from '@/convex/_generated/api';
import { ConvexHttpClient } from 'convex/browser';

const convex = new ConvexHttpClient(process.env.CONVEX_URL!);

export const searchKnowledge = createTool({
  id: 'search-knowledge',
  description: 'Search the knowledge base for relevant information',
  inputSchema: z.object({
    query: z.string(),
    limit: z.number().default(5),
  }),
  execute: async ({ context }) => {
    const { query, limit } = context;

    // Use Convex vector search
    const results = await convex.action(api.functions.actions.searchDocuments, {
      query,
      limit,
    });

    return {
      results: results.map(r => ({
        content: r.content,
        score: r.score,
        source: r.metadata.source,
      })),
    };
  },
});
```

---

## 7. Integration Patterns

### Mastra Instance Setup

```typescript
// index.ts
import { Mastra } from '@mastra/core';
import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { cors } from 'hono/cors';

import { assistant } from './agents/assistant';
import { taskProcessingWorkflow } from './workflows';

// Initialize Mastra
export const mastra = new Mastra({
  agents: {
    assistant,
  },
  workflows: {
    taskProcessing: taskProcessingWorkflow,
  },
  logger: {
    level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  },
});

// HTTP Server
const app = new Hono();

app.use('*', cors());

app.get('/health', (c) => c.json({ status: 'ok' }));

app.post('/api/chat', async (c) => {
  const { message, threadId } = await c.req.json();
  const agent = mastra.getAgent('assistant');
  const response = await agent.generate(message, { threadId });
  return c.json({ response: response.text });
});

app.post('/api/workflow/:name', async (c) => {
  const { name } = c.req.param();
  const data = await c.req.json();
  const workflow = mastra.getWorkflow(name);
  const result = await workflow.execute({ triggerData: data });
  return c.json({ result });
});

const port = parseInt(process.env.PORT || '4000');
console.log(`Mastra server running on port ${port}`);
serve({ fetch: app.fetch, port });
```

### Frontend Integration

```typescript
// lib/mastra-client.ts
const MASTRA_URL = process.env.NEXT_PUBLIC_MASTRA_URL || 'http://localhost:4000';

export async function chatWithAgent(message: string, threadId?: string) {
  const response = await fetch(`${MASTRA_URL}/api/chat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message, threadId }),
  });

  if (!response.ok) {
    throw new Error('Failed to chat with agent');
  }

  return response.json();
}

export async function runWorkflow(name: string, data: Record<string, unknown>) {
  const response = await fetch(`${MASTRA_URL}/api/workflow/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });

  if (!response.ok) {
    throw new Error('Failed to run workflow');
  }

  return response.json();
}
```

---

## 8. Error Handling

### Tool Error Handling

```typescript
export const riskyTool = createTool({
  id: 'risky-tool',
  // ...
  execute: async ({ context }) => {
    try {
      const result = await riskyOperation();
      return { success: true, data: result };
    } catch (error) {
      // Log error
      console.error('[riskyTool] Error:', error);

      // Return structured error
      return {
        success: false,
        error: {
          code: 'OPERATION_FAILED',
          message: error instanceof Error ? error.message : 'Unknown error',
        },
      };
    }
  },
});
```

### Workflow Error Handling

```typescript
const workflow = new Workflow({
  name: 'with-error-handling',
  onError: async (error, context) => {
    console.error('[Workflow] Error:', error);
    // Notify, log, cleanup
  },
});
```

---

## 9. Testing

### Tool Testing

```typescript
// tools/__tests__/searchTool.test.ts
import { describe, it, expect } from 'vitest';
import { searchTool } from '../searchTool';

describe('searchTool', () => {
  it('should return results for valid query', async () => {
    const result = await searchTool.execute({
      context: {
        query: 'test query',
        limit: 5,
      },
    });

    expect(result.results).toBeDefined();
    expect(Array.isArray(result.results)).toBe(true);
  });

  it('should respect limit parameter', async () => {
    const result = await searchTool.execute({
      context: {
        query: 'test',
        limit: 3,
      },
    });

    expect(result.results.length).toBeLessThanOrEqual(3);
  });
});
```

### Agent Testing

```typescript
// agents/__tests__/assistant.test.ts
import { describe, it, expect } from 'vitest';
import { assistant } from '../assistant';

describe('Assistant Agent', () => {
  it('should respond to basic query', async () => {
    const response = await assistant.generate('Hello, how are you?');

    expect(response.text).toBeDefined();
    expect(response.text.length).toBeGreaterThan(0);
  });
});
```

---

## 10. Production

### Environment Variables

```env
# AI Models
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...          # Optional

# Convex
CONVEX_URL=https://your-project.convex.cloud

# Server
PORT=4000
NODE_ENV=production

# Mastra
MASTRA_LOG_LEVEL=info
```

### Health Check

```typescript
app.get('/health', (c) => {
  return c.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
  });
});
```

### Monitoring

```typescript
// Structured logging
import { mastra } from '@/mastra';

mastra.on('agent:generate:start', ({ agent, prompt }) => {
  console.log(JSON.stringify({
    event: 'agent_generate_start',
    agent: agent.name,
    promptLength: prompt.length,
    timestamp: new Date().toISOString(),
  }));
});

mastra.on('tool:execute:end', ({ tool, duration, success }) => {
  console.log(JSON.stringify({
    event: 'tool_execute_end',
    tool: tool.id,
    duration,
    success,
    timestamp: new Date().toISOString(),
  }));
});
```

---

## Resources

- [Mastra Documentation](https://mastra.dev/docs)
- [Mastra GitHub](https://github.com/mastra-ai/mastra)
- [AI Agent Patterns](https://mastra.dev/docs/patterns)
