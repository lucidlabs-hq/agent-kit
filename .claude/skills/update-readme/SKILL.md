---
name: update-readme
description: Update README with current project status and features. Use after completing features.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash
---

# Update README

Update the README.md file to reflect the current state of the project.

## When to Use

- After completing a major feature
- When project status has changed significantly
- Before releasing or sharing the project
- When the README is out of date

## Process

### 1. Gather Current State

Read these files to understand current project state:

```bash
# Project status
cat PROJECT-STATUS.md

# Current features and PRD
cat .claude/PRD.md 2>/dev/null || echo "No PRD found"

# Recent commits
git log -10 --oneline

# Current README
cat README.md
```

### 2. Identify Updates Needed

Compare current README with:
- Features completed (from PROJECT-STATUS.md)
- Current tech stack (from package.json)
- Available skills (from .claude/skills/)
- Recent changes (from git log)

### 3. Update Sections

#### Project Title & Description

Ensure it matches the current project name and description from PRD.

#### Features Section

Update to reflect implemented features:

```markdown
## Features

- [x] Feature 1 - Brief description
- [x] Feature 2 - Brief description
- [ ] Feature 3 - Planned
```

#### Tech Stack Section

Verify tech stack is accurate:

```markdown
## Tech Stack

- **Frontend:** Next.js, React, TypeScript
- **Styling:** Tailwind CSS v4, shadcn/ui
- **Backend:** [if applicable]
- **Database:** [if applicable]
```

#### Getting Started Section

Ensure setup instructions are current:

```markdown
## Getting Started

1. Clone the repository
2. Install dependencies: `cd frontend && pnpm install`
3. Copy environment variables: `cp frontend/.env.example frontend/.env.local`
4. Start development server: `cd frontend && pnpm run dev`
```

#### Skills Section

Update available skills:

```markdown
## Available Skills (Claude Code)

| Skill | Description |
|-------|-------------|
| `/create-prd` | Create a new PRD interactively |
| `/plan-feature` | Plan feature implementation |
| `/execute` | Execute an implementation plan |
| `/validate` | Validate compliance with standards |
| `/commit` | Create formatted commit |
| `/prime` | Prime Claude with codebase understanding |
```

#### Project Status Section (Optional)

Add brief status if relevant:

```markdown
## Status

**Current Phase:** [Phase from PROJECT-STATUS.md]
**Last Updated:** [Date]

See `PROJECT-STATUS.md` for detailed progress tracking.
```

### 4. Preserve Important Content

Do NOT remove or overwrite:
- License information
- Contributing guidelines
- Contact information
- Custom sections added by the user

### 5. Format Consistently

- Use consistent heading levels
- Keep formatting clean and readable
- Follow existing README style
- Use proper markdown syntax

## Output

After updating README, provide:

```markdown
## README Updated

### Changes Made
- [List of sections updated]

### Sections Added
- [New sections if any]

### Current Status
- Features documented: X
- Tech stack updated: Yes/No
- Skills documented: X

### Verification
Run `cat README.md | head -50` to preview changes
```

## Notes

- Keep README concise - link to detailed docs instead of duplicating
- Ensure all commands and URLs are correct
- Update version numbers if applicable
- Don't add placeholder content - only document what exists
