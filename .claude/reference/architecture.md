# Agent Kit - Technical Architecture Reference

Technical architecture, tech stack, and project structure.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Technology Stack](#2-technology-stack)
3. [Frontend Architecture](#3-frontend-architecture)
4. [Mastra Architecture](#4-mastra-architecture)
5. [Convex Architecture](#5-convex-architecture)
6. [API Endpoints](#6-api-endpoints)
7. [Deployment](#7-deployment)

---

## 1. System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        User / Browser                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Next.js 15 (App Router)                      │
│              Dashboard, Realtime Updates, Streaming             │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│     Convex      │  │     Mastra      │  │      n8n        │
│  Realtime DB    │  │   AI Agents     │  │   Workflows     │
│  Vector Search  │  │   Tools/Logic   │  │  Integrations   │
└─────────────────┘  └─────────────────┘  └─────────────────┘
              │               │               │
              └───────────────┼───────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     AI Models (LiteLLM)                         │
│          Claude Opus/Sonnet/Haiku, OpenAI, Custom               │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Technology Stack

### Frontend

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Framework** | Next.js 15 (App Router) | Full-stack React framework |
| **Language** | TypeScript (strict) | Type safety |
| **Styling** | Tailwind CSS 4 | Utility-first CSS |
| **Components** | shadcn/ui + Radix | Accessible, composable UI |
| **Icons** | Lucide React | Consistent iconography |
| **State** | React Context + URL state | Client state management |
| **Forms** | react-hook-form + Zod | Form validation |
| **Package Manager** | pnpm | Fast, reliable |
| **Dev Server** | bun dev | Ultra-fast development |

### Backend (Mastra)

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Framework** | Mastra | AI Agent framework (TypeScript) |
| **Runtime** | Bun (dev) / Node.js (prod) | JavaScript runtime |
| **API** | Hono | Lightweight HTTP framework |
| **Server** | @hono/node-server | HTTP server |

### Database (Convex)

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Database** | Convex | Realtime reactive database |
| **Schema** | TypeScript | Type-safe schema definition |
| **Queries** | Convex Functions | Reactive data fetching |
| **Mutations** | Convex Functions | Type-safe writes |
| **Actions** | Convex Functions | External API calls |
| **Vector Search** | Convex Vector Index | Built-in RAG support |
| **Auth** | Convex Auth | Built-in authentication |
| **Files** | Convex File Storage | File storage & serving |

### AI/LLM

| Component | Technology | Use Case |
|-----------|-----------|----------|
| **Primary LLM** | Claude Opus 4.5 | Complex reasoning |
| **Standard LLM** | Claude Sonnet 4 | General purpose |
| **Fast LLM** | Claude Haiku / Gemini Flash | Classification, quick decisions |
| **Embeddings** | OpenAI text-embedding-3-small | RAG vector search |

### Infrastructure

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Hosting** | Elestio | Self-hosted Docker containers |
| **Reverse Proxy** | Caddy | Auto HTTPS, routing |
| **Container** | Docker Compose | Containerization |
| **IaC** | Terraform | Infrastructure as Code |
| **CI/CD** | GitHub Actions | Automated testing & deployment |
| **Monitoring** | Sentry / LogTail | Error tracking & logging |

---

## 3. Frontend Architecture

### Project Structure

```
frontend/
├── app/
│   ├── api/
│   │   └── health/route.ts           # Health check
│   ├── dashboard/
│   │   └── page.tsx                  # Main dashboard
│   ├── layout.tsx                    # Root layout
│   ├── page.tsx                      # Home page
│   └── globals.css                   # Tailwind imports
│
├── components/
│   ├── Layout/                       # Layout components
│   │   ├── app-shell.tsx
│   │   ├── app-header.tsx
│   │   └── app-sidebar.tsx
│   └── ui/                           # shadcn/ui components
│       ├── button.tsx
│       ├── card.tsx
│       ├── badge.tsx
│       └── ...
│
├── lib/
│   ├── types.ts                      # TypeScript definitions
│   ├── utils.ts                      # cn() helper, etc.
│   └── mock/                         # Mock data templates
│       ├── README.md
│       └── mock-data.example.ts
│
├── package.json
├── tsconfig.json
├── next.config.ts
└── postcss.config.mjs
```

### Key Patterns

**Server Components (Default):**
```tsx
// app/dashboard/page.tsx
export default async function DashboardPage() {
  // Server-side data fetching
  return <Dashboard />;
}
```

**Client Components (Interactive):**
```tsx
// components/interactive-widget.tsx
'use client';

import { useState } from 'react';

export function InteractiveWidget() {
  const [state, setState] = useState(false);
  // ...
}
```

**Convex Integration:**
```tsx
// Using Convex queries
'use client';

import { useQuery } from 'convex/react';
import { api } from '@/convex/_generated/api';

export function TaskList() {
  const tasks = useQuery(api.functions.queries.listTasks, { status: 'active' });

  if (!tasks) return <Loading />;
  return <ul>{tasks.map(t => <li key={t._id}>{t.title}</li>)}</ul>;
}
```

---

## 4. Mastra Architecture

### Project Structure

```
mastra/
├── src/
│   ├── index.ts                      # Entry point & HTTP server
│   ├── agents/
│   │   └── assistant.ts              # AI agent definitions
│   ├── tools/
│   │   └── index.ts                  # Tool registry
│   └── workflows/
│       └── index.ts                  # Workflow definitions
│
├── package.json
├── tsconfig.json
└── Dockerfile
```

### Agent Pattern

```typescript
// agents/assistant.ts
import { Agent } from '@mastra/core';

export const assistant = new Agent({
  name: 'assistant',
  instructions: `You are a helpful AI assistant.`,
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

### Tool Pattern

```typescript
// tools/index.ts
import { createTool } from '@mastra/core';
import { z } from 'zod';

export const searchTool = createTool({
  id: 'search',
  description: 'Search for information',
  inputSchema: z.object({
    query: z.string(),
  }),
  execute: async ({ context }) => {
    // Implementation
    return { results: [] };
  },
});
```

---

## 5. Convex Architecture

### Project Structure

```
convex/
├── schema.ts                         # Database schema
├── functions/
│   ├── queries.ts                    # Read operations
│   ├── mutations.ts                  # Write operations
│   └── actions.ts                    # External API calls
├── _generated/                       # Auto-generated types
│   ├── api.d.ts
│   └── dataModel.d.ts
└── README.md
```

### Schema Definition

```typescript
// schema.ts
import { defineSchema, defineTable } from 'convex/server';
import { v } from 'convex/values';

export default defineSchema({
  users: defineTable({
    name: v.string(),
    email: v.string(),
    role: v.union(v.literal('admin'), v.literal('user')),
  }).index('by_email', ['email']),

  tasks: defineTable({
    title: v.string(),
    status: v.union(v.literal('pending'), v.literal('completed')),
    assigneeId: v.optional(v.id('users')),
    createdAt: v.number(),
  }).index('by_status', ['status']),

  documents: defineTable({
    title: v.string(),
    content: v.string(),
    embedding: v.array(v.float64()),
  }).vectorIndex('by_embedding', {
    vectorField: 'embedding',
    dimensions: 1536,
  }),
});
```

### Query Pattern

```typescript
// functions/queries.ts
import { query } from './_generated/server';
import { v } from 'convex/values';

export const listTasks = query({
  args: {
    status: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    if (args.status) {
      return await ctx.db
        .query('tasks')
        .withIndex('by_status', (q) => q.eq('status', args.status))
        .collect();
    }
    return await ctx.db.query('tasks').collect();
  },
});
```

### Mutation Pattern

```typescript
// functions/mutations.ts
import { mutation } from './_generated/server';
import { v } from 'convex/values';

export const createTask = mutation({
  args: {
    title: v.string(),
    assigneeId: v.optional(v.id('users')),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert('tasks', {
      title: args.title,
      status: 'pending',
      assigneeId: args.assigneeId,
      createdAt: Date.now(),
    });
  },
});
```

### Action Pattern (External APIs)

```typescript
// functions/actions.ts
import { action } from './_generated/server';
import { v } from 'convex/values';

export const processWithAgent = action({
  args: {
    taskId: v.id('tasks'),
    prompt: v.string(),
  },
  handler: async (ctx, args) => {
    // Call Mastra agent
    const response = await fetch(`${process.env.MASTRA_URL}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: args.prompt }),
    });

    const result = await response.json();
    return result;
  },
});
```

---

## 6. API Endpoints

### Mastra API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/api/chat` | Chat with agent |
| POST | `/api/workflow/:name` | Run workflow |

### Convex API

Convex functions are accessed via the Convex client, not REST endpoints.

```typescript
// Frontend usage
import { useQuery, useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';

// Queries (reactive)
const tasks = useQuery(api.functions.queries.listTasks);

// Mutations
const createTask = useMutation(api.functions.mutations.createTask);
await createTask({ title: 'New task' });

// Actions (for external APIs)
const processTask = useAction(api.functions.actions.processWithAgent);
await processTask({ taskId, prompt: 'Analyze this task' });
```

---

## 7. Deployment

### Docker Services

```yaml
# docker-compose.yml
services:
  caddy:           # Reverse proxy, auto HTTPS
  frontend:        # Next.js application
  mastra:          # AI agent server
  n8n:             # Workflow automation (optional)
```

### Environment Variables

```env
# Convex
NEXT_PUBLIC_CONVEX_URL=https://your-project.convex.cloud
CONVEX_DEPLOY_KEY=...

# AI Models
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...

# Mastra
NEXT_PUBLIC_MASTRA_URL=http://localhost:4000
PORT=4000

# n8n (optional)
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=...
```

### Terraform Deployment

```bash
cd terraform
terraform init
terraform apply -var-file=environments/prod.tfvars
```

---

## Related References

- `design-system.md` - UI/UX Guidelines
- `mastra-best-practices.md` - AI Agent Patterns
- `deployment-best-practices.md` - Docker & CI/CD
- `convex/README.md` - Convex setup guide
- `mastra/README.md` - Mastra setup guide
- `terraform/README.md` - Deployment guide
