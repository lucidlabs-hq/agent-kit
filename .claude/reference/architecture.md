# Agent Kit - Platform Architecture Reference

Technical architecture for the AI Agent Platform.

---

## Table of Contents

1. [Platform Philosophy](#1-platform-philosophy)
2. [High-Level Architecture](#2-high-level-architecture)
3. [Technology Stack](#3-technology-stack)
4. [Project Structure](#4-project-structure)
5. [Repository Model](#5-repository-model)
6. [Service Architecture](#6-service-architecture)
7. [Deployment Model](#7-deployment-model)

---

## 1. Platform Philosophy

### Core Principles

1. **Platform first, projects second**
   - Infrastructure and conventions are shared
   - Business logic lives only in projects

2. **One project = one repository**
   - Each project is independently deployable
   - Push to `main` triggers deployment

3. **Shared host, isolated stacks**
   - One Elestio server
   - Multiple Docker Compose stacks
   - No shared runtime state between projects

4. **Deterministic by default**
   - AI components are optional and controlled
   - Infrastructure works without AI assumptions

5. **Local equals production**
   - Docker Compose locally
   - Docker Compose on Elestio
   - Same topology, different environment variables

### What This Platform Is

- A **foundation** on which independent projects can be built and deployed
- A **stable infrastructure** for multiple small AI-backed projects
- **Consistent best practices** across projects
- **Simple local development**
- **Push-based deployment** to a shared Elestio host

### What This Platform Is NOT

- Not a product
- Not a single agent
- Not a monolithic runtime

---

## 2. High-Level Architecture

### Shared Elestio Host

```
┌─────────────────────────────────────────────────────────┐
│                    Shared Elestio Host                  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │              Reverse Proxy (Caddy)                │ │
│  │        Routing, TLS, project separation            │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │               Project Stack A                     │ │
│  │        (Docker Compose, isolated)                  │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │               Project Stack B                     │ │
│  │        (Docker Compose, isolated)                  │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

Each project:
- Runs its own containers
- Owns its own ports internally
- Can be started, stopped, or redeployed independently

### Project Stack Architecture

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
│     Auth        │  │                 │  │   (optional)    │
└─────────────────┘  └─────────────────┘  └─────────────────┘
              │               │               │
              └───────────────┼───────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     AI Models (LiteLLM)                         │
│          Claude Opus/Sonnet/Haiku, Gemini, Custom               │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Technology Stack

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
| **Files** | Convex File Storage | File storage & serving |

### Authentication

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Auth Framework** | Better Auth | Modern TypeScript auth |
| **Database Adapter** | Convex Adapter | Session/user storage in Convex |
| **Providers** | OAuth, Magic Link, Password | Flexible auth methods |
| **Sessions** | Convex tables | Real-time session sync |

**Integration:** [Better Auth + Convex](https://www.better-auth.com/docs/integrations/convex)

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

## 4. Project Structure

### Repository Structure

```
project/
├── frontend/                    # Next.js App
│   ├── app/                     # App Router Pages
│   │   ├── api/                 # API Routes
│   │   └── [features]/          # Feature pages
│   ├── components/
│   │   ├── [Feature]/           # Feature-specific components
│   │   └── ui/                  # shadcn/ui components
│   └── lib/
│       ├── types.ts             # TypeScript definitions
│       ├── api-client.ts        # HTTP client
│       └── utils.ts             # Helpers (cn(), etc.)
│
├── mastra/                      # AI Agent Layer
│   └── src/
│       ├── index.ts             # Entry point & HTTP server
│       ├── agents/              # AI Agent definitions
│       ├── tools/               # Agent tools
│       └── workflows/           # Multi-step workflows
│
├── convex/                      # Realtime Database
│   ├── schema.ts                # Database schema
│   ├── functions/               # Queries, mutations, actions
│   └── _generated/              # Auto-generated types
│
├── n8n/                         # Workflow Automation (optional)
│   └── workflows/               # Pre-built templates
│
├── .claude/                     # Claude Agent Configuration
│   ├── agents/                  # Custom subagents
│   ├── skills/                  # Slash commands
│   ├── reference/               # Best practice docs
│   └── PRD.md                   # Product requirements
│
├── docker-compose.yml           # Production stack
├── docker-compose.dev.yml       # Local development
└── .github/workflows/           # CI/CD pipelines
```

---

## 5. Repository Model

### Template Repository (Upstream)

**Purpose:**
- Scaffolding
- Conventions
- Best practices
- Documentation

**Responsibilities:**
- Create new projects
- Enforce structure
- Share patterns

**Non-responsibilities:**
- Deployment
- Business logic
- Runtime state

### Project Repositories (Downstream)

Each project repository:
- Is created from the template
- Contains a complete Docker Compose setup
- Includes its own CI/CD workflow
- Is independently deployable

---

## 6. Service Architecture

### Reverse Proxy (Shared)

- Runs once per host
- Handles:
  - HTTPS
  - Domain or path routing
  - Forwarding to project stacks
- Does not contain business logic

### Project Stack (Per Project)

Each project stack may include:
- **Mastra** - Decision / explanation layer
- **Python services** - Analysis, tooling (optional)
- **Convex** - State & orchestration
- **Frontend** - User interface (optional)

The platform **does not mandate** which services a project must include.

### Convex Integration

```typescript
// Frontend usage with Convex
'use client';

import { useQuery, useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';

// Queries (reactive, real-time)
const tasks = useQuery(api.functions.queries.listTasks);

// Mutations
const createTask = useMutation(api.functions.mutations.createTask);
await createTask({ title: 'New task' });

// Actions (for external APIs like Mastra)
const processTask = useAction(api.functions.actions.processWithAgent);
await processTask({ taskId, prompt: 'Analyze this task' });
```

### Mastra Integration

```typescript
// Convex action calling Mastra
export const processWithAgent = action({
  args: {
    taskId: v.id('tasks'),
    prompt: v.string(),
  },
  handler: async (ctx, args) => {
    const response = await fetch(`${process.env.MASTRA_URL}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: args.prompt }),
    });
    return response.json();
  },
});
```

---

## 7. Deployment Model

### Trigger

- Push to `main` branch

### Mechanism

- GitHub Actions
- SSH connection to Elestio
- `docker compose up -d --build`

No additional tooling required.

### Environment Separation

- `.env.example` committed
- `.env` provided per environment
- Secrets managed via GitHub repository secrets

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

---

## Explicit Non-Goals (Platform Level)

The platform does NOT:
- Manage deployments centrally
- Orchestrate cross-project communication
- Enforce a single agent pattern
- Impose a monolithic runtime

Each project remains autonomous.

---

## Key Takeaway

This architecture is designed so that:
- Adding a new project is cheap
- Removing a project is trivial
- Failures are isolated
- Best practices evolve centrally

**The platform stays boring. The projects carry the complexity.**

---

## Related References

- `design-system.md` - UI/UX Guidelines
- `mastra-best-practices.md` - AI Agent Patterns
- `deployment-best-practices.md` - Docker & CI/CD
- `scaling.md` - Stateless patterns
- `convex/README.md` - Convex setup guide
- `mastra/README.md` - Mastra setup guide

---

**Version:** 2.0
**Last Updated:** January 2026
**Maintainer:** Lucid Labs GmbH
