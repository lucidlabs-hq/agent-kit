# Mastra AI Agent Layer

Mastra is a framework for building AI agents with tools, memory, and workflows.

## Overview

This directory contains:
- **Agents**: AI agent definitions with instructions and capabilities
- **Tools**: Functions agents can call to interact with external systems
- **Workflows**: Multi-step processes combining agent actions

## Setup

```bash
cd mastra
pnpm install
```

## Development

```bash
# Start development server (uses Bun)
pnpm run dev

# Type check
pnpm run type-check
```

## Project Structure

```
mastra/
├── src/
│   ├── index.ts          # Main entry point
│   ├── agents/
│   │   └── assistant.ts  # General assistant agent
│   ├── tools/
│   │   └── index.ts      # Tool definitions
│   └── workflows/
│       └── index.ts      # Workflow definitions
├── package.json
└── tsconfig.json
```

## Creating Agents

```typescript
import { Agent } from "@mastra/core";

export const myAgent = new Agent({
  name: "my-agent",
  instructions: `Your agent instructions here...`,
  model: {
    provider: "ANTHROPIC",
    name: "claude-sonnet-4-20250514",
  },
  tools: {
    // Add tools the agent can use
  },
});
```

## Creating Tools

```typescript
import { createTool } from "@mastra/core";
import { z } from "zod";

export const myTool = createTool({
  id: "my_tool",
  description: "What this tool does",
  inputSchema: z.object({
    param: z.string().describe("Parameter description"),
  }),
  outputSchema: z.object({
    result: z.string(),
  }),
  execute: async ({ param }) => {
    // Tool implementation
    return { result: "Done" };
  },
});
```

## Creating Workflows

```typescript
import { Workflow, Step } from "@mastra/core";
import { z } from "zod";

const workflow = new Workflow({
  name: "my-workflow",
  triggerSchema: z.object({
    input: z.string(),
  }),
});

const step1 = new Step({
  id: "step-1",
  execute: async ({ context }) => {
    return { result: "step 1 done" };
  },
});

const step2 = new Step({
  id: "step-2",
  execute: async ({ context }) => {
    const prev = context.stepResults["step-1"];
    return { final: prev.result + " + step 2" };
  },
});

workflow.step(step1).then(step2).commit();
```

## Available Models

Configure different models in your agents:

| Provider | Model | Use Case |
|----------|-------|----------|
| ANTHROPIC | claude-opus-4-20250514 | Complex reasoning |
| ANTHROPIC | claude-sonnet-4-20250514 | General purpose |
| ANTHROPIC | claude-3-5-haiku-20241022 | Fast, high-volume |
| OPENAI | gpt-4-turbo | Alternative |
| AZURE_OPENAI | gpt-4 | EU data residency |

## Environment Variables

```env
# Anthropic
ANTHROPIC_API_KEY=sk-ant-...

# OpenAI (if using)
OPENAI_API_KEY=sk-...

# Azure OpenAI (if using)
AZURE_OPENAI_API_KEY=...
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
AZURE_OPENAI_API_VERSION=2024-02-15-preview

# LiteLLM Proxy (optional - for unified access)
LITELLM_PROXY_URL=http://localhost:4000
LITELLM_API_KEY=...
```

## Integration with Convex

Call Convex from tools:

```typescript
import { ConvexHttpClient } from "convex/browser";

const convex = new ConvexHttpClient(process.env.CONVEX_URL!);

export const dbTool = createTool({
  id: "db_query",
  execute: async ({ query }) => {
    const results = await convex.query(api.functions.queries.search, { query });
    return { results };
  },
});
```

## Integration with n8n

Trigger n8n workflows from Mastra:

```typescript
export const n8nTool = createTool({
  id: "trigger_workflow",
  execute: async ({ workflowId, data }) => {
    const response = await fetch(`${N8N_URL}/webhook/${workflowId}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    return await response.json();
  },
});
```

## Documentation

- [Mastra Docs](https://docs.mastra.dev/)
- [Vercel AI SDK](https://sdk.vercel.ai/docs)
- [Anthropic API](https://docs.anthropic.com/)
