---
name: plan-feature
description: Create comprehensive feature implementation plan with deep codebase analysis. Use before implementing any feature.
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep, Bash
argument-hint: [feature-name]
---

# Plan Feature

## Feature: $ARGUMENTS

## Mission

Transform a feature request into a **comprehensive implementation plan** through systematic codebase analysis and strategic planning.

**Core Principle:** We do NOT write code in this phase. Our goal is to create a context-rich plan that enables one-pass implementation success.

**Key Philosophy:** Context is King. The plan must contain ALL information needed for implementation.

## Planning Process

### Phase 1: Feature Understanding

**Deep Feature Analysis:**

- Extract the core problem being solved
- Identify user value and business impact
- Determine feature type: New Capability / Enhancement / Refactor / Bug Fix
- Assess complexity: Low / Medium / High
- Map affected systems (Frontend, Backend, Agent, Database)

**Create User Story Format:**

```
As a <type of user>
I want to <action/goal>
So that <benefit/value>
```

### Phase 2: Codebase Intelligence

**Use specialized analysis:**

**1. Check PRD for Requirements**

Read `.claude/PRD.md` to understand:
- Related features
- Domain model
- User stories
- Success criteria

**2. Project Structure Analysis**

- Map directory structure and patterns
- Identify service/component boundaries
- Find related implementations

**3. Pattern Recognition**

- Search for similar implementations in codebase
- Check `CLAUDE.md` for project rules
- Check `.claude/reference/` for best practices

**4. Integration Points**

- Frontend components affected
- API endpoints needed
- Agent tools required (if AI feature)
- Database schema changes

**Clarify Ambiguities:**

If requirements are unclear, ask the user before continuing.

### Phase 3: Research & Documentation

**Gather Documentation:**

- Find relevant library docs
- Locate implementation examples
- Identify common gotchas

**Compile References:**

```markdown
## Relevant Documentation

- [Link](https://example.com)
  - Section: [Relevant section]
  - Why: [Reason needed]
```

### Phase 4: Strategic Thinking

**Consider:**

- How does this fit existing architecture?
- What are critical dependencies?
- What could go wrong? (Edge cases, errors)
- How will this be tested?
- Performance implications?
- Security considerations?

### Phase 5: Generate Plan

Create plan with this structure:

---

```markdown
# Feature: [feature-name]

## Feature Description

[Detailed description]

## User Story

As a [user type]
I want to [action]
So that [benefit]

## Feature Metadata

**Type:** [New Capability/Enhancement/Refactor/Bug Fix]
**Complexity:** [Low/Medium/High]
**Systems Affected:** [Frontend/Backend/Agent/Database]
**Dependencies:** [Libraries or services]

---

## CONTEXT REFERENCES

### Files to Read Before Implementing

| File | Lines | Why |
|------|-------|-----|
| `path/to/file.tsx` | 15-45 | Pattern reference |
| `path/to/types.ts` | 100-120 | Types to extend |

### Files to Create

| File | Purpose |
|------|---------|
| `path/to/new.tsx` | [Purpose] |

### Documentation to Read

- [Link](url) - Section: X - Why: Y

### Patterns to Follow

**Component Pattern:**
```typescript
// Example from codebase
```

---

## IMPLEMENTATION PLAN

### Phase 1: Foundation
- [ ] Set up base structures
- [ ] Create types/interfaces

### Phase 2: Core Implementation
- [ ] Implement main logic
- [ ] Create components

### Phase 3: Integration
- [ ] Connect to existing systems
- [ ] Wire up routing

### Phase 4: Testing
- [ ] Unit tests
- [ ] Manual validation

---

## STEP-BY-STEP TASKS

### Task 1: CREATE `path/to/file.tsx`

- **IMPLEMENT:** [Specific detail]
- **PATTERN:** Reference file:line
- **VALIDATE:** `pnpm run lint && pnpm run type-check`

### Task 2: UPDATE `path/to/existing.tsx`

- **IMPLEMENT:** [What to change]
- **GOTCHA:** [Issues to avoid]
- **VALIDATE:** `pnpm run test`

[Continue with all tasks...]

---

## VALIDATION COMMANDS

### Level 1: Syntax
```bash
cd frontend && pnpm run lint
cd frontend && pnpm run type-check
```

### Level 2: Tests
```bash
pnpm run test
```

### Level 3: Build
```bash
cd frontend && pnpm run build
```

### Level 4: Manual Testing
1. Start dev server: `pnpm run dev`
2. Test feature at [URL]
3. Verify [specific behavior]

---

## ACCEPTANCE CRITERIA

- [ ] Feature implements all functionality
- [ ] All validation commands pass
- [ ] TypeScript has no errors
- [ ] Tests cover main scenarios
- [ ] Mobile responsive (if UI)

---

## COMPLETION CHECKLIST

- [ ] All tasks completed
- [ ] All validations passed
- [ ] Manual testing confirms feature works
- [ ] Ready for `/commit`
```

---

## Output

### Save Plan

**Filename:** `.agents/plans/{kebab-case-name}.md`

Examples:
- `add-dashboard-overview.md`
- `implement-ticket-classification.md`
- `fix-auth-redirect.md`

### Update PROJECT-STATUS.md

After creating plan, update PROJECT-STATUS.md:

```markdown
## Active Plan

**Plan:** `.agents/plans/[plan-name].md`
**Feature:** [Feature description]
**Phase:** Planning Complete
**Progress:** 0/[X] tasks

### Next Task
- **Task:** Task 1 - [Description]
- **Status:** Ready to start
```

Add to Recent Activity:
```markdown
| [Today] | plan | Created plan: [feature-name] |
```

### Report

Provide:
- Summary of feature and approach
- Full path to plan file
- Complexity assessment
- Key implementation risks
- Confidence score for one-pass success (/10)

### Next Steps

```
Plan created! To implement:
1. Run /execute .agents/plans/[plan-name].md
2. Or review the plan first and adjust if needed
```
