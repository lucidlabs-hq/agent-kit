# Agent Kit

> **AI Agent Starter Kit by Lucid Labs GmbH**
>
> A production-ready boilerplate for building AI-powered applications with Next.js, Mastra, Convex, and n8n.

## ⚠️ Important: This is a Template Repository

**Do NOT develop directly in this repository.** Agent Kit is an **upstream template** – you create new projects from it, then promote reusable patterns back.

### Recommended Folder Structure

```
lucidlabs/                              # Your workspace root
│
├── lucidlabs-agent-kit/                # UPSTREAM TEMPLATE (this repo)
│   ├── .claude/skills/                 # Generic development skills
│   ├── frontend/                       # Next.js boilerplate
│   ├── mastra/                         # Agent layer boilerplate
│   └── scripts/
│       ├── create-agent-project.sh     # Creates downstream projects
│       └── promote.sh                  # Promotes patterns upstream
│
└── projects/                           # DOWNSTREAM PROJECTS
    ├── customer-portal/                # Project A (own git repo)
    ├── internal-dashboard/             # Project B (own git repo)
    └── ai-assistant/                   # Project C (own git repo)
```

### Bidirectional Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           lucidlabs/                                    │
│                                                                         │
│   ┌─────────────────────┐                ┌──────────────────────────┐  │
│   │ lucidlabs-agent-kit │    PROMOTE     │       projects/          │  │
│   │     (UPSTREAM)      │◄───────────────│                          │  │
│   │                     │                │  ┌────────────────────┐  │  │
│   │  • Generic skills   │ SYNC/INIT      │  │  customer-portal   │  │  │
│   │  • Boilerplate      │───────────────►│  │   (DOWNSTREAM)     │  │  │
│   │  • Best practices   │                │  │                    │  │  │
│   └─────────────────────┘                │  │  • Domain logic    │  │  │
│                                          │  │  • Project PRD     │  │  │
│                                          │  │  • Custom agents   │  │  │
│                                          │  └────────────────────┘  │  │
│                                          └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

See [Upstream/Downstream Workflow](#upstreamdownstream-workflow) for step-by-step instructions.

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
│   ├── create-agent-project.sh  # Project scaffolding
│   ├── promote.sh               # Promote patterns upstream
│   └── sync-upstream.sh         # Sync updates downstream
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
| `/start` | Entry point in template - create or open project | Any |
| `/checkout-project` | Clone existing project from GitHub | Any |
| `/create-prd` | Create a new PRD interactively | Planning |
| `/plan-feature` | Plan feature implementation | Planning |
| `/execute` | Execute an implementation plan | Implementation |
| `/commit` | Create formatted commit | Implementation |
| `/prime` | Load project context | Any |
| `/init-project` | Initialize new downstream project | Planning |
| `/screenshot` | Visual verification with agent-browser | Validation |
| `/update-readme` | Update README with current status | Implementation |
| `/promote` | Promote patterns to upstream agent-kit | Any |
| `/sync` | Sync updates from upstream agent-kit | Any |

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
| [scripts/promote.sh](./scripts/promote.sh) | Promote patterns to upstream |
| [scripts/sync-upstream.sh](./scripts/sync-upstream.sh) | Sync updates from upstream |
| [convex/README.md](./convex/README.md) | Database setup |
| [mastra/README.md](./mastra/README.md) | AI agents guide |
| [n8n/README.md](./n8n/README.md) | Workflow templates |
| [terraform/README.md](./terraform/README.md) | Deployment guide |

## Upstream/Downstream Workflow

### The Model

Agent Kit uses a **template-based workflow** with bidirectional synchronization:

| Term | Meaning | Location |
|------|---------|----------|
| **Upstream** | This template repository | `lucidlabs/lucidlabs-agent-kit/` |
| **Downstream** | Projects created from template | `lucidlabs/projects/[name]/` |

---

### 1. Initial Setup (One-Time)

Set up the folder structure on your machine:

```bash
# Create workspace structure
mkdir -p ~/coding/repos/lucidlabs/projects

# Clone the upstream template
cd ~/coding/repos/lucidlabs
git clone git@github.com:lucidlabs-hq/agent-kit.git lucidlabs-agent-kit

# Verify structure
ls -la ~/coding/repos/lucidlabs/
# Should show:
#   lucidlabs-agent-kit/
#   projects/
```

---

### 2. Creating a New Project (Upstream → Downstream)

**When:** Starting a new client project or internal tool.

```bash
# Navigate to the upstream template
cd ~/coding/repos/lucidlabs/lucidlabs-agent-kit

# Create new project in projects/ folder
./scripts/create-agent-project.sh ../projects/customer-portal

# Or with interactive mode
./scripts/create-agent-project.sh --interactive
# → Enter name: customer-portal
# → Creates: ../projects/customer-portal/
```

**What happens:**
1. Script copies boilerplate to `../projects/[name]/`
2. Initializes fresh git repo
3. Updates package.json, README with project name
4. Project is ready for development

**Next steps in the new project:**
```bash
cd ../projects/customer-portal
pnpm install
/create-prd          # Create project-specific PRD
/plan-feature login  # Start first feature
```

---

### 3. Promoting Patterns (Downstream → Upstream)

**When:** You developed something generic in a project that should be shared.

```bash
# In your downstream project
cd ~/coding/repos/lucidlabs/projects/customer-portal

# Run promotion script (points to upstream template)
./scripts/promote.sh --upstream ../../lucidlabs-agent-kit

# Or preview first (dry run)
./scripts/promote.sh --upstream ../../lucidlabs-agent-kit --dry-run
```

**Interactive session:**
```
╔═══════════════════════════════════════════════════════════════════╗
║                      PATTERN PROMOTION                            ║
╚═══════════════════════════════════════════════════════════════════╝

ℹ Downstream: ~/coding/repos/lucidlabs/projects/customer-portal
ℹ Upstream:   ~/coding/repos/lucidlabs/lucidlabs-agent-kit

▶ Scanning for promotable changes...

Promotable changes found:

  [1] .claude/skills/code-review/SKILL.md (NEW)
  [2] .claude/reference/api-patterns.md (NEW)
  [3] frontend/components/ui/data-table.tsx (MODIFIED)

Enter numbers to promote (e.g., 1,2 or 'all'): 1,2

▶ Creating branch: promote/20260127-from-customer-portal
✔ Copied: .claude/skills/code-review/SKILL.md
✔ Copied: .claude/reference/api-patterns.md
✔ Committed 2 files

Create GitHub PR? [Y/n] y
✔ PR created: https://github.com/lucidlabs-hq/agent-kit/pull/42
```

**What gets promoted:**

| ✅ Promotable | ❌ Not Promotable |
|---------------|-------------------|
| `.claude/skills/*` | `.claude/PRD.md` (project-specific) |
| `.claude/reference/*` | `frontend/app/*` (pages) |
| `frontend/components/ui/*` | `mastra/src/agents/*` (domain) |
| `frontend/lib/utils.ts` | `convex/*` (schema) |
| `frontend/lib/hooks/*` | Any domain-specific code |
| `scripts/*` | |

---

### 4. Syncing Updates (Upstream → Downstream)

**When:** The template got new skills/patterns you want in your project.

**Option A: Cherry-pick specific commits**
```bash
# In your downstream project
cd ~/coding/repos/lucidlabs/projects/customer-portal

# Add upstream remote (one-time)
git remote add template ../../lucidlabs-agent-kit

# Fetch latest from template
git fetch template

# See what changed
git log template/main --oneline -10

# Cherry-pick specific commits
git cherry-pick <commit-hash>
```

**Option B: Manual sync of specific files**
```bash
# Compare what's different
git diff template/main -- .claude/skills/

# Copy specific files
cp ../../lucidlabs-agent-kit/.claude/skills/new-skill/SKILL.md \
   .claude/skills/new-skill/SKILL.md

# Commit the sync
git add .claude/skills/new-skill/
git commit -m "chore: sync new-skill from upstream template"
```

**Option C: Sync script (recommended)**
```bash
# Run sync script
./scripts/sync-upstream.sh

# Interactive selection of what to sync
# Syncs: skills, reference docs, UI components, scripts
```

---

### 5. Quick Reference

| Task | Location | Command |
|------|----------|---------|
| **Create new project** | In `lucidlabs-agent-kit/` | `./scripts/create-agent-project.sh ../projects/[name]` |
| **Promote to upstream** | In `projects/[name]/` | `./scripts/promote.sh --upstream ../../lucidlabs-agent-kit` |
| **Sync from upstream** | In `projects/[name]/` | `./scripts/sync-upstream.sh` or manual cherry-pick |
| **Preview promotion** | In `projects/[name]/` | `./scripts/promote.sh --upstream ... --dry-run` |

---

### Best Practices

1. **Keep agent-kit clean** – Only generic, reusable patterns
2. **Domain logic stays downstream** – Client-specific code never goes upstream
3. **Small promotions** – Promote one pattern at a time for easier review
4. **Test in isolation** – Verify patterns work without project context
5. **Document patterns** – Add comments explaining usage
6. **Sync regularly** – Pull useful updates from upstream monthly

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

**Built with care by [Lucid Labs GmbH](https://lucidlabs.de)**
