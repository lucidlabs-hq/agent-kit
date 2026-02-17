# PIV Workflow Model (Mandatory)

> **Planning -> Implementation -> Validation -> Iteration**
> This is the mandatory working model for all Lucid Labs projects.
> Referenced from CLAUDE.md and AGENTS.md.

---

## Core Principle

This project strictly follows the **PIV workflow model**:

1. Planning
2. Implementation
3. Validation
4. Iteration

The PIV Loop is **mandatory** and must **not be shortened, skipped, or mixed**.

Claude MUST always operate in exactly **one** PIV phase at a time and must be able to clearly state which phase it is currently in.

---

## Mapping: PIV <-> Project Commands (Binding)

### 1. Planning
Allowed commands:
- `plan-feature`
- `create-prd`
- `init-project`
- Analysis and audit tasks without execution

Purpose:
- Understand the problem
- Structure the solution
- Prepare decisions

Rules:
- NO code
- NO implementation
- NO technical assumptions
- ONLY analysis, structure, plans, scope definitions, and constraints

---

### 2. Implementation
Allowed commands:
- `execute`

Purpose:
- Implement **exactly** what was approved in the Planning phase

Rules:
- No scope expansion
- No new ideas
- No silent changes
- Implementation must strictly follow the approved plan

---

### 3. Validation
Allowed commands:
- `validate`
- `self-audit`
- `code-review`

Purpose:
- Verify against:
  - PRD
  - CLAUDE.md
  - AGENTS.md
  - Reference documents
  - Approved plan

Rules:
- Explicitly surface deviations
- Highlight risks and inconsistencies
- NO fixes
- NO new implementation

---

### 4. Iteration
Purpose:
- Derive the next PIV cycle

Rules:
- Suggestions only
- NO implementation
- Every iteration MUST start again with **Planning**

---

## Mandatory Meta Rules (Non-Negotiable)

- NEVER combine multiple PIV phases in one response
- NEVER jump directly from Planning to Implementation
- EVERY new task starts with Planning
- If information is missing -> STOP and ask
- Technical decisions are ONLY allowed if explicitly defined in:
  - `CLAUDE.md`
  - `AGENTS.md`
  - `.claude/reference/*`

### Two-Strike Rule (Roadblock Protocol)

**If the same approach fails twice -> STOP. No guesswork.**

When you encounter an error or roadblock:

1. **First attempt fails:** Adjust and try a different variation
2. **Second attempt fails:** STOP immediately. Do NOT try a third time with guesswork
3. **Research phase:** Perform targeted research (web search, docs, codebase analysis)
4. **Report findings:** Present what you learned to the user before proceeding
5. **Only continue** with a clear, evidence-based approach

---

## Command Enforcement

Claude MUST:
- Use the existing project commands
- Respect the defined project structure
- Never invent new workflows
- Never take shortcuts in the process

Any deviation from the PIV model is considered an error.
