# Full-Stack Template: Convex + Mastra

AI-powered full-stack application with Convex database and Mastra AI agents.

## Stack Overview

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Next.js 16 + React 19 | App Router, Server Components |
| **Styling** | Tailwind CSS 4 | Utility-first CSS |
| **Components** | shadcn/ui + Radix | Accessible UI components |
| **Database** | Convex (self-hosted) | Realtime reactive database |
| **AI Agents** | Mastra v1 | AI workflows and agents |
| **Auth** | Better Auth | Email/OAuth authentication |
| **LLM (dev)** | Ollama (phi3:mini) | Offline development |
| **LLM (prod)** | Portkey → Claude | Production AI |

## Quick Start

```bash
# 1. Start services
docker run -d --name convex-local -p 3210:3210 ghcr.io/get-convex/convex-backend:latest

# 2. Start frontend
cd frontend && pnpm install && pnpm run dev

# 3. Start Mastra (separate terminal)
cd mastra && pnpm install && pnpm run dev
```

## Structure

```
project/
├── frontend/                 # Next.js App
│   ├── src/
│   │   ├── app/              # App Router pages
│   │   ├── components/       # React components
│   │   │   ├── ui/           # shadcn/ui components
│   │   │   └── providers/    # Context providers
│   │   └── lib/              # Utilities
│   └── convex/               # Convex schema & functions
│
├── mastra/                   # AI Agent Layer
│   └── src/
│       ├── agents/           # Agent definitions
│       ├── tools/            # Agent tools
│       ├── workflows/        # Multi-step workflows
│       └── config/           # LLM configuration
│
└── .claude/                  # Claude Code config
    ├── skills/               # Skills (deploy, etc.)
    └── LLM-CONFIG.md         # LLM documentation
```

## Features

### Admin Dashboard
- Stack overview
- Service health monitoring
- Agent/Workflow status
- Documentation browser

### Authentication
- Email/Password
- OAuth providers (GitHub, Google)
- Offline dev mode (auth disabled)

### AI Workflows
- Demo invoice processing workflow
- Extensible agent system
- Tool-based architecture

## Commands

### Frontend
```bash
pnpm run dev          # Start dev server
pnpm run build        # Production build
pnpm run validate     # Type-check + lint
```

### Mastra
```bash
pnpm run dev          # Start with hot-reload
pnpm run health       # Check health
pnpm run demo:workflow # Test workflow
```

### Docker
```bash
# Convex
docker run -d --name convex-local -p 3210:3210 ghcr.io/get-convex/convex-backend:latest

# Stop
docker stop convex-local && docker rm convex-local
```

## Environment Variables

### Frontend (.env.local)
```bash
NEXT_PUBLIC_CONVEX_URL=http://localhost:3210
NEXT_PUBLIC_MASTRA_URL=http://localhost:4000
NEXT_PUBLIC_AUTH_ENABLED=false
```

### Production
```bash
NEXT_PUBLIC_AUTH_ENABLED=true
BETTER_AUTH_SECRET=<openssl rand -base64 32>
LLM_PROVIDER=anthropic
LLM_MODEL=claude-sonnet-4-5-20250514
```

---

**Template Version:** 1.0
**Created:** January 2026
