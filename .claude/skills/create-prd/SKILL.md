---
name: create-prd
description: Create a Product Requirements Document from conversation. Use when starting a new project or defining product requirements.
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep
argument-hint: [project-name]
---

# Create PRD: Generate Product Requirements Document

## Overview

Generate a comprehensive Product Requirements Document (PRD) based on conversation context. This PRD will serve as the single source of truth for project-specific requirements.

**Important:** The PRD is the ONLY project-specific file. All other Agent Kit files are reusable.

## Output File

Write the PRD to: `.claude/PRD.md`

If a PRD already exists, ask before overwriting.

## Before Starting

### 1. Gather Project Context

Ask the user for (if not already discussed):

- **Project Name:** What is this project called?
- **Client/Domain:** Who is this for? What industry?
- **Core Problem:** What problem are we solving?
- **Target Users:** Who will use this?
- **MVP Scope:** What's the minimum viable product?

### 2. Reference Agent Kit Standards

Read these files to ensure PRD aligns with our standards:

- `CLAUDE.md` - Tech stack and code standards
- `.claude/reference/architecture.md` - Architecture patterns
- `.claude/reference/design-system.md` - UI/UX standards
- `.claude/reference/mastra-best-practices.md` - AI agent patterns

## PRD Structure

Create a well-structured PRD with the following sections:

---

```markdown
# [Project Name] - Product Requirements Document

> **Note:** This PRD contains project-specific requirements.
> All technical standards are inherited from Agent Kit (`CLAUDE.md`).

**Version:** 1.0
**Status:** Draft | In Progress | Production-Ready
**Last Updated:** [Date]

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Vision & Principles](#vision--principles)
3. [Problem & Solution](#problem--solution)
4. [Target Users](#target-users)
5. [MVP Scope](#mvp-scope)
6. [User Stories](#user-stories)
7. [Feature Specification](#feature-specification)
8. [Domain Model](#domain-model)
9. [AI Agent Specification](#ai-agent-specification)
10. [API Specification](#api-specification)
11. [Implementation Phases](#implementation-phases)
12. [Success Criteria](#success-criteria)
13. [Risks & Mitigations](#risks--mitigations)

---

## Executive Summary

### Vision

[2-3 sentences describing the product vision]

### The Difference

| Traditional Approach | Our Approach |
|---------------------|--------------|
| [Old way] | [New way with AI] |

### What We're Building

[Concise description of the product]

### MVP Goals

**Goal:** [One sentence MVP goal]

**Success measured by:**
- [Metric 1]
- [Metric 2]
- [Metric 3]

---

## Vision & Principles

### Core Principles

1. **[Principle 1]**
   - [Description]

2. **[Principle 2]**
   - [Description]

3. **[Principle 3]**
   - [Description]

---

## Problem & Solution

### The Problem

[Detailed problem description]

### Our Solution

[How we solve it]

### Key Differentiators

- [Differentiator 1]
- [Differentiator 2]

---

## Target Users

### Primary Persona

**[Persona Name]**
- Role: [Job title/role]
- Tech Comfort: [Low/Medium/High]
- Key Needs:
  - [Need 1]
  - [Need 2]

### Secondary Personas

[If applicable]

---

## MVP Scope

### In Scope

**Core Functionality:**
- [Feature 1]
- [Feature 2]

**Technical:**
- [Tech requirement 1]
- [Tech requirement 2]

### Out of Scope

- [Deferred feature 1]
- [Deferred feature 2]

---

## User Stories

### Primary Stories

**US-1: [Story Title]**
> As a [user type], I want to [action], so that [benefit].

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

**US-2: [Story Title]**
> As a [user type], I want to [action], so that [benefit].

[Continue for 5-8 primary stories]

---

## Feature Specification

### Feature 1: [Feature Name]

**Purpose:** [Why this feature exists]

**Functionality:**
- [Function 1]
- [Function 2]

**UI/UX:**
- [UI element 1]
- [UI element 2]

[Continue for each feature]

---

## Domain Model

### Key Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| [Entity 1] | [Description] | id, name, ... |
| [Entity 2] | [Description] | id, name, ... |

### Entity Relationships

```
[Entity A] 1--* [Entity B]
[Entity B] *--1 [Entity C]
```

### Enums/Categories

| Enum | Values | Description |
|------|--------|-------------|
| [Category] | value1, value2, value3 | [Purpose] |

---

## AI Agent Specification

### Agent: [Agent Name]

**Purpose:** [What the agent does]

**Personality:**
- [Trait 1]
- [Trait 2]

**Capabilities:**
1. [Capability 1]
2. [Capability 2]

**Tools:**

| Tool | Purpose | Input | Output |
|------|---------|-------|--------|
| [Tool 1] | [Purpose] | [Input] | [Output] |

### Agent Instructions (System Prompt Summary)

```
[Key points from system prompt]
```

---

## API Specification

### Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /api/[resource] | [Purpose] |
| POST | /api/[resource] | [Purpose] |

### Example: [Endpoint Name]

**Request:**
```json
{
  "field": "value"
}
```

**Response:**
```json
{
  "id": "uuid",
  "field": "value"
}
```

---

## Implementation Phases

### Phase 1: Foundation

**Goal:** [Phase goal]

**Deliverables:**
- [Deliverable 1]
- [Deliverable 2]

**Validation:**
- [How to verify completion]

### Phase 2: Core Features

**Goal:** [Phase goal]

**Deliverables:**
- [Deliverable 1]
- [Deliverable 2]

### Phase 3: Polish & Launch

**Goal:** [Phase goal]

**Deliverables:**
- [Deliverable 1]
- [Deliverable 2]

---

## Success Criteria

### MVP Success Definition

**Functional Requirements:**
- [Requirement 1]
- [Requirement 2]

**Quality Indicators:**
- [Indicator 1]
- [Indicator 2]

### Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| [Metric 1] | [Target] | [How measured] |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Medium | High | [Mitigation strategy] |
| [Risk 2] | Low | Medium | [Mitigation strategy] |

---

## Technical References

> **Note:** Technical implementation details are in Agent Kit reference files.

| Topic | Reference |
|-------|-----------|
| Tech Stack | `CLAUDE.md` |
| Architecture | `.claude/reference/architecture.md` |
| Design System | `.claude/reference/design-system.md` |
| AI Agents | `.claude/reference/mastra-best-practices.md` |
| Deployment | `.claude/reference/deployment-best-practices.md` |

---

**Version History:**
- v1.0 - Initial PRD
```

---

## Instructions

### 1. Extract Requirements

- Review the entire conversation history
- Identify explicit requirements and implicit needs
- Note technical constraints and preferences
- Capture user goals and success criteria

### 2. Synthesize Information

- Organize requirements into appropriate sections
- Fill in reasonable assumptions where details are missing
- Maintain consistency across sections
- Ensure alignment with Agent Kit standards

### 3. Write the PRD

- Use clear, professional language
- Include concrete examples
- Use markdown formatting (headings, lists, code blocks, checkboxes)
- Keep Executive Summary concise but comprehensive

### 4. Quality Checks

- All required sections present
- User stories have clear benefits
- MVP scope is realistic
- Aligns with Agent Kit tech stack (CLAUDE.md)
- Implementation phases are actionable
- Success criteria are measurable

## After Creating PRD

### 1. Update PROJECT-STATUS.md

```markdown
## Project Info
- **Project:** [Name]
- **PRD:** Created [date]
- **Phase:** Planning
```

### 2. Output Confirmation

Provide:
1. Confirm the PRD was written to `.claude/PRD.md`
2. Brief summary of contents
3. Assumptions made (if any)
4. Suggested next steps

### 3. Next Steps

Recommend:
```
1. Review the PRD and refine if needed
2. Run /prime to load project context
3. Start planning with /plan-feature [first-feature]
```

## Notes

- If critical information is missing, ask clarifying questions BEFORE generating
- The PRD should be project-specific; technical standards come from CLAUDE.md
- For AI agent projects, emphasize the Agent Specification section
- For CRUD apps, emphasize Feature Specification and API sections
