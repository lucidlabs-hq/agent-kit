# Agent Kit

> **AI Agent Starter Kit by Lucidlabs**
>
> A production-ready boilerplate for building AI-powered applications with Next.js, Mastra, Convex, and n8n.

## ⚠️ Important: This is a Template Repository

**Do NOT develop directly in this repository.** Agent Kit is an **upstream template** – you create new projects from it, then promote reusable patterns back.

```
┌─────────────────────────────────────────────────────────────────┐
│  UPSTREAM (This Repo)                                           │
│  github.com/lucidlabs-hq/agent-kit                              │
│                                                                 │
│  • Generic skills, UI components, scripts                       │
│  • Never edited directly for client projects                    │
└─────────────────────────────────────────────────────────────────┘
        │                                     ▲
        │ clone + scaffold                    │ ./scripts/promote.sh
        ▼                                     │
┌─────────────────────────────────────────────────────────────────┐
│  DOWNSTREAM (Your Project)                                      │
│  github.com/lucidlabs-hq/client-project                         │
│                                                                 │
│  • Custom PRD, domain agents, app pages                         │
│  • Develops generic patterns → promotes back                    │
└─────────────────────────────────────────────────────────────────┘
```

See [Upstream/Downstream Workflow](#upstreamdownstream-workflow) for details.

---

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
git clone git@github.com:lucidlabs-hq/agent-kit.git
cd agent-kit

# Run interactive setup - creates a NEW project directory
./scripts/create-agent-project.sh --interactive

# Or with a name directly
./scripts/create-agent-project.sh my-client-project
```

The script:
1. Creates a new directory outside agent-kit
2. Copies selected components
3. Initializes a fresh git repo
4. Sets up the project structure

Components you can include:
- Frontend (Next.js)
- Mastra (AI Agents)
- Convex (Database)
- n8n (Workflows)
- Terraform (Infrastructure)

### Option 2: Manual Setup

```bash
# Clone directly into your project name
git clone git@github.com:lucidlabs-hq/agent-kit.git my-client-project
cd my-client-project

# IMPORTANT: Remove template git history
rm -rf .git
git init

# Create your own repo
gh repo create lucidlabs-hq/my-client-project --private --source=. --push

# Install dependencies
cd frontend && pnpm install
cd ../mastra && pnpm install

# Initialize Convex
npx convex init

# Start development
pnpm run dev
```

**⚠️ Never push changes back to `lucidlabs-hq/agent-kit` directly. Use the promotion workflow instead.**

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
| `/promote` | Promote patterns to upstream agent-kit | Any |

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
| [.claude/skills/README.md](./.claude/skills/README.md) | Skills documentation |
| [scripts/promote.sh](./scripts/promote.sh) | Pattern promotion script |
| [convex/README.md](./convex/README.md) | Database setup |
| [mastra/README.md](./mastra/README.md) | AI agents guide |
| [n8n/README.md](./n8n/README.md) | Workflow templates |
| [terraform/README.md](./terraform/README.md) | Deployment guide |

## Upstream/Downstream Workflow

### The Model

Agent Kit uses a **template-based workflow** where:

| Term | Meaning | Example |
|------|---------|---------|
| **Upstream** | This template repository | `lucidlabs-hq/agent-kit` |
| **Downstream** | Projects created from template | `lucidlabs-hq/client-project` |

### Creating a New Project

```bash
# 1. Clone agent-kit locally (if not already)
git clone git@github.com:lucidlabs-hq/agent-kit.git ~/templates/agent-kit

# 2. Create new project
cd ~/templates/agent-kit
./scripts/create-agent-project.sh my-new-project

# 3. The new project is created at ~/templates/my-new-project
cd ~/templates/my-new-project

# 4. Create repo and push
gh repo create lucidlabs-hq/my-new-project --private --source=. --push
```

### Promoting Patterns Back

When you develop something reusable in a downstream project (new skill, UI component, utility):

```bash
# In your downstream project
cd ~/projects/my-client-project

# Run promotion script
./scripts/promote.sh --upstream ~/templates/agent-kit

# Interactive selection:
# Promotable changes found:
#   [1] .claude/skills/code-review/SKILL.md (NEW)
#   [2] frontend/components/ui/data-table.tsx (NEW)
#
# Enter numbers to promote: 1,2
#
# ✔ Branch created: promote/20260127-from-my-client-project
# ✔ PR created: https://github.com/lucidlabs-hq/agent-kit/pull/1
```

### What Gets Promoted

| Promotable ✅ | Not Promotable ❌ |
|---------------|-------------------|
| `.claude/skills/*` | `.claude/PRD.md` |
| `.claude/reference/*` | `frontend/app/*` |
| `frontend/components/ui/*` | `mastra/src/agents/*` |
| `frontend/lib/utils.ts` | `convex/*` |
| `frontend/lib/hooks/*` | Domain-specific code |
| `scripts/*` | |

### Getting Upstream Updates

When agent-kit gets new features you want:

```bash
# In your downstream project
cd ~/projects/my-client-project

# Add upstream remote (once)
git remote add upstream git@github.com:lucidlabs-hq/agent-kit.git

# Fetch updates
git fetch upstream

# Cherry-pick specific commits
git cherry-pick <commit-hash>

# OR compare and copy manually
git diff upstream/main -- .claude/skills/
```

### Best Practices

1. **Keep agent-kit clean** – Only generic, reusable patterns
2. **Domain logic stays downstream** – Client-specific code never goes upstream
3. **Small promotions** – Promote one pattern at a time for easier review
4. **Test in isolation** – Verify patterns work without project context
5. **Document patterns** – Add comments explaining usage

---

## Contributing

Contributions to the template are welcome via the promotion workflow:

1. Create a downstream project
2. Develop and test your pattern
3. Use `./scripts/promote.sh` to create a PR
4. Ensure no domain-specific code is included
5. PR will be reviewed and merged

## License

MIT License - See [LICENSE](./LICENSE) for details.

---

**Built with care by [Lucidlabs](https://lucidlabs.de)**
