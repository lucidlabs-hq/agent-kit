---
name: init-project
description: Initialize a new project from Agent Kit boilerplate. Use when creating a new downstream project.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash
argument-hint: [project-name]
---

# Initialize New Project

Set up a new project based on the Agent Kit boilerplate.

## Project Details

**Project Name:** $ARGUMENTS

If no argument provided, ask for:
- Project name (kebab-case, e.g., `my-project`)
- Project description (one sentence)
- Client/Domain (e.g., "Property Management", "E-Commerce")

## Initialization Steps

### 1. Verify Boilerplate Structure

```bash
# Check required directories exist
ls -la frontend/
ls -la .claude/
ls -la .agents/
```

### 2. Update Project Metadata

**Update `frontend/package.json`:**
```json
{
  "name": "[project-name]",
  "description": "[project-description]",
  "version": "0.1.0"
}
```

**Update `README.md`:**
- Change "Agent Kit" to project name
- Update description
- Keep structure and commands documentation

**Update `frontend/app/layout.tsx`:**
- Change title to project name
- Update description

**Update `frontend/app/page.tsx`:**
- Update heading and welcome text for the project

### 3. Update PROJECT-STATUS.md

```markdown
## Quick Status

| Field | Value |
|-------|-------|
| **Project** | [Project Name] |
| **Phase** | Initialization |
| **Active Plan** | None |
| **Last Updated** | [Today] |

## Current Focus

**Status:** Project initialized, ready for PRD creation

**Next Steps:**
1. Create PRD with `/create-prd`
2. Run `/prime` to verify setup
3. Plan first feature with `/plan-feature`
```

### 4. Configure Environment

Create `.env.local` from template:

```bash
cat > frontend/.env.local.example << 'EOF'
# Database (Convex)
NEXT_PUBLIC_CONVEX_URL=https://your-project.convex.cloud

# AI
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...

# App
NODE_ENV=development
NEXT_PUBLIC_API_URL=http://localhost:4000
EOF
```

### 5. Update Docker Configuration

**Update `docker-compose.yml`:**
- Change service names to project name

**Update `docker-compose.dev.yml`:**
- Change service names to `[project-name]_dev`

### 6. Install Dependencies

```bash
cd frontend
pnpm install
```

### 7. Create Initial Commit

```bash
git add -A
git commit -m "chore: initialize [project-name] from Agent Kit

- Update package.json with project name
- Configure environment templates
- Update Docker configuration
- Ready for PRD creation"
```

### 8. Verify Setup

```bash
# Start dev server
cd frontend && pnpm run dev &
sleep 3

# Verify it works
curl -s http://localhost:3000/api/health

# Stop server
pkill -f "next dev"
```

## Output

Provide summary:

### Project Initialized

- **Name:** [project-name]
- **Location:** [current directory]
- **Tech Stack:** Next.js 16, TypeScript, Tailwind v4, shadcn/ui

### Files Modified

| File | Change |
|------|--------|
| `frontend/package.json` | Updated name |
| `README.md` | Updated project info |
| `PROJECT-STATUS.md` | Initialized tracking |
| `frontend/app/layout.tsx` | Updated title |
| `frontend/app/page.tsx` | Updated welcome |
| `docker-compose*.yml` | Updated service names |
| `.env.local.example` | Created |

### Next Steps

```
1. Copy frontend/.env.local.example to frontend/.env.local
2. Fill in API keys (ANTHROPIC_API_KEY)
3. Create PRD: /create-prd
4. Start development: cd frontend && pnpm run dev
```

### Available Skills

| Skill | Description |
|-------|-------------|
| `/create-prd` | Create Product Requirements Document |
| `/prime` | Load project context |
| `/plan-feature` | Create feature implementation plan |
| `/execute` | Execute an implementation plan |
| `/validate` | Run all validation checks |
| `/commit` | Create formatted commit |

## Notes

- Remember to use `pnpm` for package management (never npm/yarn)
- Use `pnpm run dev` for development server
- Follow patterns in `.claude/reference/` docs
- PRD is the only project-specific file; everything else is reusable
