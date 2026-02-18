# Agent Kit

> **AI Agent Starter Kit by Lucid Labs GmbH**
> Reusable boilerplate for rapid AI agent project development

## UPSTREAM REPOSITORY - READ-ONLY RULES (NON-NEGOTIABLE)

**THIS IS THE UPSTREAM TEMPLATE REPOSITORY.** It is the single source of truth for all Lucid Labs projects.

### What This Repo Is For

| Allowed | NOT Allowed |
|---------|-------------|
| Spawning new projects via `create-agent-project.sh` | Direct feature development |
| Receiving promoted patterns via `/promote` (always through PR) | Running `pnpm run dev` or any dev server |
| Serving as sync source for downstream projects | Direct code changes without PR |
| Maintaining shared reference docs and skills | Any `git push origin main` |

### Hard Rules

1. **NEVER push directly to main.** Branch Protection enforces this. All changes go through Pull Requests.
2. **NEVER develop features here.** This is a template, not a project. Feature work happens in downstream projects under `../projects/`.
3. **NEVER start dev servers here.** No `pnpm run dev`, no `npx convex dev`, no Mastra. This repo has no running application.
4. **Changes come ONLY from two sources:**
   - **Promote** (`/promote`): Battle-tested patterns from downstream projects, always via PR
   - **Direct edits**: Only for template infrastructure (scripts, reference docs, CLAUDE.md rules), always via PR
5. **If you are a Claude session working in a downstream project:** You must NEVER create, modify, or delete files in this repository. Use `/promote` or `/sync` skills instead.
6. **If you are a Claude session working directly in this repo:** Every change MUST go through a feature branch and Pull Request. No exceptions, no `--admin` merge bypasses.

### Detection Rule for AI Agents

**Before making any file change, check:**
```
Is the current working directory inside lucidlabs-agent-kit/?
  YES → You are in the UPSTREAM. Only template maintenance is allowed.
        Create a branch. Make changes. Open a PR.
  NO  → You are in a downstream project. Normal development rules apply.
        NEVER touch files in ../../lucidlabs-agent-kit/ directly.
```

### 4-Layer Protection System

This repository is protected by four independent layers. Each layer must be explicitly bypassed for legitimate changes:

| Layer | Mechanism | What It Blocks |
|-------|-----------|----------------|
| **1. GitHub** | Branch Protection + CODEOWNERS | Direct pushes to main, merges without review |
| **2. Git Hook** | `.githooks/pre-commit` | Any `git commit` without authorization |
| **3. Claude Code** | `.claude/settings.json` PreToolUse hook | Edit/Write operations by AI agents |
| **4. Filesystem** | `chflags uchg` (macOS) | Any process modifying tracked files |

### Admin Procedures (Maintainer Only)

**Why are these protections in place?**

The upstream agent-kit is the foundation for all Lucid Labs projects. A single accidental change here propagates to every downstream project via `/sync`. The 4-layer system ensures that changes are always intentional, reviewed, and traceable. Even the repository maintainer must follow these steps - the process is the protection.

**Procedure for direct upstream changes:**

1. Create a feature branch: `git checkout -b feat/my-change`
2. Unlock filesystem: `./scripts/unlock-upstream.sh`
3. Start Claude session with: `ALLOW_UPSTREAM_EDIT=1 ALLOW_UPSTREAM_COMMIT=1 claude`
4. Make changes, commit to feature branch
5. Push branch and create PR: `gh pr create`
6. Re-lock filesystem: `./scripts/lock-upstream.sh`
7. Merge PR after review

**These env vars are NOT shortcuts.** They exist because automated protection must have a controlled override path. The override is documented here (not in error messages) to keep the barrier intentionally high.

---

## Quick Start

```bash
pnpm install                     # Dependencies (NEVER npm/yarn)
pnpm run dev                     # Dev Server (Bun Runtime)
pnpm run build                   # Production Build (Node.js)
```

---

## Project Overview

**Project-specific details belong in:**
- `.claude/PRD.md` - Product Requirements Document
- `.claude/skills/` - Claude Code skills

**This file is a ROUTER.** It points to the right reference doc for each context. All detailed rules, standards, and patterns live in `.claude/reference/`.

---

## Context-Aware Reference Loading

**Read the reference doc that matches your current task.** Do not load all docs at once.

| When you are... | Read |
|-----------------|------|
| Writing code (style, naming, TypeScript) | `code-standards.md` |
| Implementing UI components | `design-system.md` + `shadcn-ui-setup.md` |
| Working with SSR/hydration | `ssr-hydration.md` |
| Writing tests | `testing-strategy.md` |
| Setting up a session / starting servers | `session-rules.md` |
| Creating a new project | `project-rules.md` |
| Committing or creating PRs | `git-workflow.md` + `quality-gates.md` |
| Working with Convex | `convex-self-hosted.md` |
| Building AI agents (Mastra) | `mastra-best-practices.md` |
| Choosing AI framework | `ai-framework-choice.md` |
| Deploying to production | `deployment-best-practices.md` + `deployment-targets.md` |
| Configuring CI/CD | `ci-cd-security.md` |
| Managing ports | `port-registry.md` |
| Setting up auth | `auth-architecture.md` + `betterauth-convex-setup.md` |
| Promoting/syncing upstream | `promote-sync.md` |
| Discovering patterns / staleness | `pattern-registry.md` |
| Managing Linear issues | `linear-setup.md` |
| Handling errors | `error-handling.md` |
| Reviewing code | `code-review-checklist.md` |
| Working with LLM config | `llm-configuration.md` |
| Feature workflow (PIV) | `piv-workflow.md` |

---

## Quality Gates (MANDATORY)

Every code change passes through quality gates. See `quality-gates.md` for full architecture.

**Change Size Classification (S/M/L):** Determines which gates run.

| Gate | S | M | L |
|------|---|---|---|
| Architecture Guard | - | YES | YES |
| Unit Tests | YES | YES | YES |
| **Visual Verification (agent-browser)** | - | - | **YES** |

**Summary:**
- **After implementation:** architecture-guard + domain-specific guards
- **L-level with UI:** Visual Verification via agent-browser (open pages, screenshot, verify, fix loop)
- **Before commit:** tests + lint + type-check + code-reviewer
- **Before PR:** code-reviewer + error-handling-reviewer
- **Before deploy:** full test suite + security scan

**Failure protocol:** CRITICAL/HIGH = STOP. WARNING = user decides. INFO = continue.

---

## Reference Documentation Index

| Document | Purpose |
|----------|---------|
| `code-standards.md` | Language, naming, style, TypeScript, React, anti-patterns |
| `session-rules.md` | Auto-start rules, config backup, full-stack components |
| `project-rules.md` | Tech stack docs, README ports, init, skills, tasks, workflow |
| `quality-gates.md` | Gate architecture, subagents, test enforcement, failure protocol |
| `architecture.md` | Platform architecture, tech stack, project structure |
| `design-system.md` | UI/UX, Tailwind v4, shadcn/ui |
| `shadcn-ui-setup.md` | shadcn/ui setup, components, rules |
| `ssr-hydration.md` | SSR, hydration, Date.now() pitfalls |
| `testing-strategy.md` | Test pyramid, patterns, page objects |
| `git-workflow.md` | PR workflow, commit messages, branch lifecycle |
| `code-review-checklist.md` | Pre-commit review checklist |
| `ai-coding-principles.md` | Zod-first, sorting, AI-optimized patterns |
| `ai-framework-choice.md` | Mastra vs Vercel AI SDK decision guide |
| `llm-configuration.md` | LLM model selection, pricing, Portkey config |
| `mcp-servers.md` | All MCP servers (Linear, MinIO, n8n, PromptFoo) |
| `mastra-best-practices.md` | AI agents, tools, workflows |
| `auth-architecture.md` | Centralized BetterAuth, cross-subdomain SSO, roles |
| `betterauth-convex-setup.md` | BetterAuth + Convex setup guide |
| `convex-self-hosted.md` | Convex self-hosted setup, project isolation |
| `port-registry.md` | Port allocations, conflict checking |
| `promote-sync.md` | Promote & sync architecture, downstream rules |
| `pattern-registry.md` | Pattern catalog, discovery CLI, staleness detection |
| `deployment-best-practices.md` | Docker, Caddy, Elestio, CI/CD |
| `deployment-targets.md` | LUCIDLABS-HQ vs DEDICATED deployment |
| `ci-cd-security.md` | SHA-pinning, workflow architecture, branch protection |
| `pnpm-workspaces.md` | pnpm Workspace setup for Monorepo CI |
| `error-handling.md` | Error handling patterns |
| `scaling.md` | Stateless patterns, Convex scaling |
| `piv-workflow.md` | PIV loop phases, command mapping, meta rules |
| `task-system.md` | Task tracking, custom subagents |
| `linear-setup.md` | Linear MCP setup, OAuth, troubleshooting |
| `productive-integration.md` | Productive.io API, Delivery Units, Reporting |
| `future-plans.md` | Feature roadmap with checkboxes |
| `time-tracking-concept.md` | Time tracking architecture, heartbeat mechanism |
| `session-handoff.md` | Project switching without session restart |
| `quick-commands.md` | All pnpm run commands |
| `agent-browser-setup.md` | Visual testing with agent-browser |
| `vercel-ai-sdk.md` | Vercel AI SDK examples and setup |
| `azure-openai-integration.md` | Azure OpenAI (GDPR-compliant, optional) |
| `ssh-keys.md` | SSH Key guide for developers |
| `watchtower.md` | Automatic Docker container updates |
| `minio-integration.md` | MinIO S3-compatible file storage |

---

## Environment Variables

```env
# Database (Convex - self-hosted, NEVER use convex.cloud)
NEXT_PUBLIC_CONVEX_URL=http://localhost:3210

# AI
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...

# n8n (optional)
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme

# App
NODE_ENV=development
PORT=3000
```

---

## Expert Role

You are an **expert in modern web development**, specializing in:
- JavaScript/TypeScript, React, Next.js, Tailwind CSS, Node.js
- Server-first architecture (Next.js App Router)
- AI agent development (Mastra)
- Security (XSS, CSRF prevention)
- Performance optimization
- Production readiness (Docker, monitoring, logging)

**Prioritize:** Optimal tools, avoid redundancy, ensure compatibility with Next.js server-first architecture.

---

## When Unclear

**Always ask for clarification** if:
- Requirements are ambiguous
- Best practices conflict with user requirements
- Missing context or information
- Security concerns arise

**Never assume** - ask via status updates or questions.

---

## Mandatory Working Model: PIV Loop (Required)

This project strictly follows the **PIV workflow model**: Planning -> Implementation -> Validation -> Iteration.

The PIV Loop is **mandatory** and must **not be shortened, skipped, or mixed**. Claude MUST always operate in exactly **one** PIV phase at a time.

See `.claude/reference/piv-workflow.md` for complete phase rules, command mapping, and meta rules.

**Key rules:**
- NEVER combine multiple PIV phases in one response
- NEVER jump directly from Planning to Implementation
- EVERY new task starts with Planning
- If information is missing -> STOP and ask (Two-Strike Rule)


<!-- UPSTREAM-SYNC-END -->
<!-- Everything ABOVE this marker is synced from upstream agent-kit. -->
<!-- Everything BELOW this marker is project-specific and will NOT be overwritten by sync. -->

---

**Last Updated:** February 2026
**Maintainer:** Lucid Labs GmbH
**Version:** 2.0
