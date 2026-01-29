# {{PROJECT_NAME}}

AI-powered full-stack application with Convex database and Mastra AI agents.

**Created:** {{DATE}}

---

## Quick Start

### Prerequisites

- Node.js 20+
- pnpm
- Docker Desktop

### 1. Install Dependencies

```bash
pnpm run install:all
```

### 2. Configure Environment

```bash
cd frontend
cp .env.example .env.local
```

### 3. Start Development

```bash
# Start everything at once (recommended)
pnpm run dev
```

This starts all services in parallel:
- **Convex** → Backend (:3210) + Dashboard (:6791)
- **Frontend** → Next.js (:3000)
- **Mastra Studio** → AI Dev UI (:4111)

### 4. Open Services

| Service | URL |
|---------|-----|
| **Frontend** | http://localhost:3000 |
| **Admin Dashboard** | http://localhost:3000/admin |
| **Convex Dashboard** | http://localhost:6791 |
| **Mastra Studio** | http://localhost:4111 |

### 5. Convex Dashboard Login

Open http://localhost:6791 and enter:

| Field | Value |
|-------|-------|
| Deployment URL | `http://localhost:3210` |
| Admin Key | *(see below)* |

**Generate the Admin Key:**
```bash
docker exec convex-backend /convex/generate_admin_key.sh
```

Copy the full string starting with `convex-self-hosted|...`

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend                              │
│                   (Next.js 16 + React 19)                   │
│                    http://localhost:3000                     │
│                    Admin: /admin                             │
└─────────────────────────┬───────────────────────────────────┘
                          │
          ┌───────────────┴───────────────┐
          │                               │
          ▼                               ▼
┌─────────────────────┐       ┌─────────────────────┐
│       Convex        │       │       Mastra        │
│   (Realtime DB)     │       │   (AI Agents)       │
│  Backend:  :3210    │       │  Studio: :4111      │
│  Dashboard: :6791   │       │                     │
└─────────────────────┘       └─────────────────────┘
```

---

## Stack Overview

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Next.js 16 + React 19 | App Router, Server Components |
| **Styling** | Tailwind CSS 4 | Utility-first CSS |
| **Components** | shadcn/ui + Radix | Accessible UI components |
| **Database** | Convex (self-hosted) | Realtime reactive database |
| **AI Agents** | Mastra v1 | AI workflows and agents |
| **Auth** | Better Auth | Email/OAuth (disabled in dev) |

---

## Commands Reference

### Root Level (Recommended)

| Command | Description |
|---------|-------------|
| `pnpm run dev` | Start all services (Convex + Frontend + Mastra Studio) |
| `pnpm run dev:frontend` | Start Next.js only (port 3000) |
| `pnpm run dev:studio` | Start Mastra Studio (port 4111) |
| `pnpm run dev:mastra` | Start Mastra API only (port 4000) |
| `pnpm run dev:convex` | Start Convex + Dashboard (ports 3210, 6791) |
| `pnpm run dev:convex:bg` | Start Convex in background |
| `pnpm run stop` | Stop Docker containers |
| `pnpm run stop:all` | Stop everything (Docker + Node) |
| `pnpm run build` | Build frontend for production |
| `pnpm run validate` | Type-check + lint |
| `pnpm run health` | Check Mastra health |
| `pnpm run install:all` | Install all dependencies |

### Frontend (cd frontend)

| Command | Description |
|---------|-------------|
| `pnpm run dev` | Start Next.js dev server |
| `pnpm run build` | Production build |
| `pnpm run validate` | Type-check + lint |

### Mastra (cd mastra)

| Command | Description |
|---------|-------------|
| `pnpm run dev` | Start custom Hono server (port 4000) |
| `pnpm run dev:studio` | Start Mastra Studio (port 4111) |
| `pnpm run health` | Check server health |
| `pnpm run demo:workflow` | Run demo workflow |

---

## Project Structure

```
project/
├── frontend/                 # Next.js App
│   ├── app/                  # App Router pages
│   ├── components/           # React components
│   │   ├── ui/               # shadcn/ui components
│   │   └── admin/            # Admin dashboard
│   ├── lib/                  # Utilities
│   └── convex/               # Convex schema & functions
│
├── mastra/                   # AI Agent Layer
│   └── src/
│       ├── mastra/           # Mastra instance (for Studio)
│       ├── agents/           # Agent definitions
│       ├── tools/            # Agent tools
│       └── workflows/        # Multi-step workflows
│
├── docker-compose.dev.yml    # Local Convex + Dashboard
└── package.json              # Root orchestration scripts
```

---

## Environment Variables

### Frontend (.env.local)
```bash
NEXT_PUBLIC_CONVEX_URL=http://localhost:3210
NEXT_PUBLIC_MASTRA_URL=http://localhost:4111
NEXT_PUBLIC_AUTH_ENABLED=false
```

### Production
```bash
NEXT_PUBLIC_AUTH_ENABLED=true
BETTER_AUTH_SECRET=<openssl rand -base64 32>
```

---

## Troubleshooting

### Port already in use
```bash
pnpm run stop:all
```

### Convex Dashboard shows login
See [Convex Dashboard Login](#5-convex-dashboard-login) above.

### Docker not running
```bash
open -a Docker
# Wait for Docker Desktop to start, then:
pnpm run dev
```

---

**Template Version:** 1.0
**Maintainer:** Lucid Labs GmbH
