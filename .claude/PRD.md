# lucidlabs-agent-kit - Product Requirements Document

> **Note:** This PRD defines the agent-kit itself as a product.
> All technical standards are defined in `CLAUDE.md`.

**Version:** 1.0
**Status:** Production-Ready
**Last Updated:** January 2026
**Owner:** Lucid Labs GmbH

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Vision & Principles](#vision--principles)
3. [Problem & Solution](#problem--solution)
4. [Target Users](#target-users)
5. [Scope](#scope)
6. [Architecture](#architecture)
7. [Skills Model](#skills-model)
8. [Success Criteria](#success-criteria)
9. [Quality Attributes](#quality-attributes)

---

## Executive Summary

### Vision

`lucidlabs-agent-kit` is a **production-ready, modular starter kit** for AI agent projects that standardizes modern agent architectures, enables skill-based development, and enforces PRD-First + PIV workflows.

### The Difference

| Traditional Approach | Agent Kit Approach |
|---------------------|-------------------|
| Ad-hoc project setup | Standardized bootstrap (<10 min) |
| Inconsistent patterns | Unified conventions (CLAUDE.md) |
| Mixed concerns | Clear separation (Skills vs Tools) |
| Scattered learnings | Controlled pattern promotion |

### What We're Building

A reusable boilerplate that serves as the **upstream foundation** for all Lucid Labs GmbH AI agent projects. It defines structure, rules, and interfaces - not domain logic or business features.

### Goals

1. Standardized agent project starts (<10 minutes)
2. Skill-based, modular development
3. Clear separation: Kit vs Project, Skill vs Tool
4. Controlled promotion of best practices
5. Compatibility with Claude Code latest standards (v2.1.3+)

---

## Vision & Principles

### Core Principles

1. **Upstream / Downstream Model**
   - Agent Kit is upstream (generic, reusable)
   - Projects are downstream (domain-specific)
   - Changes flow upstream via promotion

2. **Skills are First-Class Citizens**
   - Development capabilities modeled as Claude Code Skills
   - Skills guide Claude's behavior
   - Skills follow AgentSkills.io open standard

3. **Commands Orchestrate, Skills Execute**
   - Skills contain instructions, not business logic
   - Mastra tools contain executable code
   - Clear separation of concerns

4. **PRD-First, PIV-Driven**
   - Every project starts with a PRD
   - Plan → Implement → Validate loop
   - No implementation without planning

5. **Promotion over Merge**
   - Reusability is consciously evaluated
   - Patterns promoted, not copied
   - Domain logic stays downstream

---

## Problem & Solution

### The Problem

Without a central agent kit, AI projects suffer from:

- Inconsistent agent structures across projects
- Mixed responsibilities (prompts vs code)
- Hard-to-reuse learnings
- Unclear AI governance
- High friction for new projects

### Our Solution

Agent Kit provides:

- **Unified patterns** in CLAUDE.md
- **Explicit ownership boundaries** (upstream/downstream)
- **Standard skill format** (SKILL.md with frontmatter)
- **Separated concerns** (Skills vs Mastra Tools)
- **Documented workflows** (PRD-First, PIV Loop)

### Key Differentiators

- Follows Claude Code v2.1.3+ standards (January 2026)
- AgentSkills.io open standard compliance
- Zero domain logic in upstream
- Self-documenting via CLAUDE.md

---

## Target Users

### Primary Persona: Agent Developer

**Role:** Developer building AI-powered applications
**Tech Comfort:** High
**Key Needs:**
- Fast project bootstrap
- Clear patterns to follow
- Reusable skill templates
- Consistent development workflow

### Secondary Persona: Tech Lead

**Role:** Technical decision maker
**Key Needs:**
- Governance and standards
- Reproducible setups
- Quality assurance patterns

---

## Scope

### In Scope

**Core Functionality:**
- Next.js 16 frontend boilerplate
- Mastra AI agent scaffold
- Convex database template
- Claude Code skills (8 core skills)
- Docker deployment configs
- Terraform IaC templates

**Documentation:**
- CLAUDE.md (development rules)
- WORKFLOW.md (process guide)
- Reference docs (.claude/reference/)
- Skill documentation (.claude/skills/README.md)

### Out of Scope

- Domain-specific business logic
- Concrete agent implementations
- Client-specific features
- UI components beyond boilerplate
- Production data or secrets

---

## Architecture

### High-Level Structure

```
agent-kit/
├── frontend/           # Next.js 16 Application
├── mastra/             # AI Agent Layer
│   └── src/
│       ├── agents/     # Agent definitions
│       ├── tools/      # Executable tools (CODE)
│       └── workflows/  # Multi-step workflows
├── convex/             # Database Layer
├── .claude/
│   ├── skills/         # Claude Code Skills (INSTRUCTIONS)
│   ├── reference/      # Best practice docs
│   └── PRD.md          # This document
├── CLAUDE.md           # Development rules
└── WORKFLOW.md         # Process guide
```

### Ownership Boundaries

| Layer | Ownership | Contains |
|-------|-----------|----------|
| Agent Kit | Lucid Labs GmbH | Patterns, interfaces, boilerplate |
| Downstream Project | Project Team | Domain logic, features, data |

---

## Skills Model

### Claude Code Skills vs Mastra Tools

| Aspect | Claude Code Skill | Mastra Tool |
|--------|------------------|-------------|
| **Purpose** | Guide Claude's behavior | Execute code |
| **Format** | SKILL.md (Markdown) | TypeScript code |
| **Location** | `.claude/skills/` | `mastra/src/tools/` |
| **Invocation** | `/skill-name` | Agent tool call |
| **Contains** | Instructions, prompts | Business logic |

### Core Skills (v1.0)

| Skill | Purpose | PIV Phase |
|-------|---------|-----------|
| `/start` | Entry point - create or open project | Any |
| `/checkout-project` | Clone existing project from GitHub | Any |
| `/create-prd` | Create Product Requirements | Planning |
| `/plan-feature` | Plan feature implementation | Planning |
| `/execute` | Execute implementation plan | Implementation |
| `/commit` | Create formatted commit | Implementation |
| `/prime` | Load project context | Any |
| `/init-project` | Initialize downstream project | Planning |
| `/screenshot` | Visual verification | Validation |
| `/update-readme` | Update documentation | Implementation |
| `/promote` | Promote patterns to upstream | Any |
| `/sync` | Sync updates from upstream | Any |

### Skill Ownership Rules

| Layer | Owns |
|-------|------|
| Agent Kit | Skill patterns, interfaces, core skills |
| Downstream | Project-specific skill implementations |

**Rule:** Agent Kit contains generic development skills. Domain-specific skills belong in downstream projects.

---

## Success Criteria

### MVP Success Definition

**Functional Requirements:**
- New project bootstrapped in <10 minutes
- All 8 core skills functional
- Skills compatible with Claude Code v2.1.3+
- Documentation complete and accurate

**Quality Indicators:**
- Zero domain logic in upstream
- Clear separation of Skills vs Tools
- PRD-First workflow enforced
- PIV Loop documented and followed

### Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Bootstrap Time | <10 min | Time to first dev server |
| Skill Coverage | 8 core | Count of SKILL.md files |
| Doc Completeness | 100% | All sections filled |

---

## Quality Attributes

1. **Deterministic** - Same inputs produce same outputs
2. **Reproducible** - Setups work consistently
3. **Observable** - Logging and monitoring built-in
4. **Auditable** - Changes tracked and reviewable
5. **Secure** - No secrets in code, safe defaults
6. **Minimal Magic** - Explicit over implicit

---

## Technical References

| Topic | Reference |
|-------|-----------|
| Development Rules | `CLAUDE.md` |
| Workflow Guide | `WORKFLOW.md` |
| Architecture | `.claude/reference/architecture.md` |
| Design System | `.claude/reference/design-system.md` |
| Skills Overview | `.claude/skills/README.md` |
| Claude Code Docs | https://code.claude.com/docs/en/skills |

---

## Open Questions

- [ ] Versioning strategy for the kit
- [ ] Automation level of promotion workflow
- [ ] Community vs internal usage scope

---

**Version History:**
- v1.0 - Initial PRD with Skills Model (January 2026)
