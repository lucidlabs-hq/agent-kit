# Agent Kit

> **AI Agent Starter Kit by Lucidlabs**
>
> A production-ready boilerplate for building AI-powered applications with Next.js, Mastra, Convex, and n8n.

## Overview

Agent Kit provides a complete foundation for building AI agent applications:

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Frontend** | Next.js 15 + shadcn/ui | Dashboard, UI, streaming |
| **AI Agents** | Mastra | Agent definitions, tools, workflows |
| **Database** | Convex | Realtime sync, vector search |
| **Workflows** | n8n | Automation, integrations |
| **Deployment** | Docker + Caddy | Self-hosted, auto HTTPS |
| **Infrastructure** | Terraform | Infrastructure as Code |

## Quick Start

### Option 1: Use the Scaffold Script (Recommended)

```bash
# Clone the template
git clone https://github.com/lucidlabs/agent-kit.git
cd agent-kit

# Run interactive setup
./scripts/create-agent-project.sh --interactive

# Or with a name directly
./scripts/create-agent-project.sh my-agent-project
```

The script lets you choose which components to include:
- Frontend (Next.js)
- Mastra (AI Agents)
- Convex (Database)
- n8n (Workflows)
- Terraform (Infrastructure)

### Option 2: Manual Setup

```bash
# Clone and rename
git clone https://github.com/lucidlabs/agent-kit.git my-project
cd my-project
rm -rf .git && git init

# Install dependencies
cd frontend && pnpm install
cd ../mastra && pnpm install

# Initialize Convex
npx convex init

# Start development
pnpm run dev
```

## Project Structure

```
agent-kit/
├── frontend/                 # Next.js 15 Application
│   ├── app/                  # App Router pages
│   ├── components/           # React components
│   │   └── ui/               # shadcn/ui components
│   └── lib/                  # Utilities & types
│
├── mastra/                   # AI Agent Layer
│   └── src/
│       ├── agents/           # Agent definitions
│       ├── tools/            # Agent tools
│       └── workflows/        # Multi-step workflows
│
├── convex/                   # Realtime Database
│   ├── schema.ts             # Database schema
│   └── functions/            # Queries, mutations, actions
│
├── n8n/                      # Workflow Automation
│   └── workflows/            # Pre-built workflow templates
│
├── terraform/                # Infrastructure as Code
│   ├── main.tf               # Elestio deployment
│   └── environments/         # Dev/prod configurations
│
├── scripts/
│   └── create-agent-project.sh  # Project scaffolding
│
├── .claude/                  # Claude Code configuration
│   ├── PRD.md                # Product Requirements
│   ├── skills/               # Claude Code skills (v2.1.3+)
│   └── reference/            # Best practices
│
├── docker-compose.yml        # Production deployment
├── Caddyfile                 # Reverse proxy config
├── CLAUDE.md                 # Development rules
└── WORKFLOW.md               # Development workflow guide
```

## Development Workflow

Agent Kit follows a **PRD-First** development approach:

```
┌─────────────────────────────────────────────────────────────────┐
│  1. Define Requirements                                         │
│     Edit .claude/PRD.md with your product requirements          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  2. Plan Features                                               │
│     /plan-feature [feature-name]                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  3. Implement                                                   │
│     /execute [plan]                                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  4. Validate                                                    │
│     /validate                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  5. Commit                                                      │
│     /commit                                                     │
└─────────────────────────────────────────────────────────────────┘
```

See [WORKFLOW.md](./WORKFLOW.md) for detailed instructions.

## Available Skills (Claude Code v2.1.3+)

Skills extend Claude's capabilities. Invoke with `/skill-name`.

| Skill | Description | PIV Phase |
|-------|-------------|-----------|
| `/create-prd` | Create a new PRD interactively | Planning |
| `/plan-feature` | Plan feature implementation | Planning |
| `/execute` | Execute an implementation plan | Implementation |
| `/commit` | Create formatted commit | Implementation |
| `/prime` | Load project context | Any |
| `/init-project` | Initialize new downstream project | Planning |
| `/screenshot` | Visual verification with agent-browser | Validation |
| `/update-readme` | Update README with current status | Implementation |

Skills are stored in `.claude/skills/` with `SKILL.md` files. See [Claude Code Skills Docs](https://code.claude.com/docs/en/skills).

### Package Scripts

```bash
# Frontend
cd frontend
pnpm run dev          # Start dev server (Bun)
pnpm run build        # Production build (Node.js)
pnpm run lint         # Run ESLint
pnpm run type-check   # TypeScript check
pnpm run validate     # Lint + type-check

# Mastra
cd mastra
pnpm run dev          # Start agent server
pnpm run build        # Build for production

# Convex
npx convex dev        # Start Convex dev server
npx convex deploy     # Deploy to cloud
```

## Environment Variables

Create `.env.local` from the template:

```bash
cp .env.example .env.local
```

Required variables:

```env
# Convex
NEXT_PUBLIC_CONVEX_URL=https://your-project.convex.cloud

# AI Models
ANTHROPIC_API_KEY=sk-ant-...

# Optional
OPENAI_API_KEY=sk-...
```

## Deployment

### Local Docker

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f
```

### Elestio (Production)

```bash
cd terraform
terraform init
terraform apply -var-file=environments/prod.tfvars
```

See [terraform/README.md](./terraform/README.md) for details.

### Vercel (Quick Deploy)

For quick prototypes, deploy frontend to Vercel:

```bash
cd frontend
vercel
```

## Tech Stack

### Frontend
- **Next.js 15** - App Router, Server Components
- **React 19** - Latest React features
- **TypeScript 5** - Strict mode
- **Tailwind CSS 4** - Utility-first styling
- **shadcn/ui** - Accessible component library

### Backend
- **Mastra** - AI agent framework
- **Convex** - Reactive database + vector search
- **n8n** - Workflow automation

### AI Models (via LiteLLM)
- Claude Opus 4.5 - Complex reasoning
- Claude Sonnet 4 - General purpose
- Claude Haiku - Fast, high-volume

### Deployment
- **Docker** - Containerization
- **Caddy** - Reverse proxy, auto HTTPS
- **Terraform** - Infrastructure as Code
- **Elestio** - Self-hosted platform

## Documentation

| Document | Purpose |
|----------|---------|
| [CLAUDE.md](./CLAUDE.md) | Development rules & conventions |
| [WORKFLOW.md](./WORKFLOW.md) | Step-by-step workflow guide |
| [.claude/PRD.md](./.claude/PRD.md) | Product requirements template |
| [convex/README.md](./convex/README.md) | Database setup |
| [mastra/README.md](./mastra/README.md) | AI agents guide |
| [n8n/README.md](./n8n/README.md) | Workflow templates |
| [terraform/README.md](./terraform/README.md) | Deployment guide |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the PIV workflow (Plan → Implement → Validate)
4. Submit a pull request

## License

MIT License - See [LICENSE](./LICENSE) for details.

---

**Built with care by [Lucidlabs](https://lucidlabs.de)**
