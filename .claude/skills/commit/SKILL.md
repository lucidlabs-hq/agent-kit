---
name: commit
description: Create a well-formatted git commit with PROJECT-STATUS.md updates. Use after completing implementation.
disable-model-invocation: true
allowed-tools: Read, Write, Bash
---

# Create Commit

Create a well-formatted commit with automatic PROJECT-STATUS.md and README updates.

## Step 0: Branch Safety Check

```bash
CURRENT_BRANCH=$(git branch --show-current)
```

**If on `main`:**

```
⚠️  WARNING: You are committing to main directly.
    All changes should go through feature branches.

    Expected workflow:
    1. /execute creates a feature branch
    2. /commit commits on the feature branch
    3. /pr pushes and creates a Pull Request

    Continue anyway? (Only for hotfixes or initial setup)
```

Ask user for confirmation before proceeding on `main`. For normal feature work, suggest running `/execute` first to create the branch.

**If on a feature branch:** Continue normally.

## Step 1: Analyze Changes

Run these commands to understand what's being committed:

```bash
git status
git diff HEAD --stat
git diff HEAD
```

## Step 2: Determine Commit Type

| Type | When to Use | Updates README? |
|------|-------------|-----------------|
| `feat` | New feature | Yes |
| `fix` | Bug fix | Yes |
| `docs` | Documentation only | No |
| `style` | Formatting, no code change | No |
| `refactor` | Code restructure | No |
| `test` | Adding tests | No |
| `chore` | Build, dependencies | No |
| `perf` | Performance improvement | Yes |

## Step 3: Stage Changes

```bash
git add -A
```

Or stage specific files:
```bash
git add path/to/file
```

## Step 4: Create Commit Message

Use Conventional Commits format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Scopes (Examples)

| Scope | Description |
|-------|-------------|
| `ui` | UI components |
| `api` | API endpoints |
| `agent` | AI agent |
| `db` | Database schema |
| `auth` | Authentication |
| `config` | Configuration |
| `skills` | Claude Code skills |

### Example Commits

```bash
# Feature
git commit -m "feat(ui): add dashboard overview component"

# Bug fix
git commit -m "fix(api): handle null response in ticket endpoint"

# With body
git commit -m "feat(agent): implement ticket classification

- Add ClassifyTicket tool
- Integrate with Sabine agent
- Add confidence scoring"
```

## Step 5: Update PROJECT-STATUS.md

After committing, update `PROJECT-STATUS.md`:

### Add to Recent Activity

```markdown
| Date | Type | Description |
|------|------|-------------|
| [Today] | [feat/fix/etc] | [Commit description] |
```

### Update Active Plan Progress (if applicable)

If working on a plan, mark completed tasks:

```markdown
### Completed Tasks
- [x] Task that was just completed
```

## Step 6: Update README (for Notable Changes)

**Only for `feat`, `fix`, `perf` commits:**

### If Feature Added

Add to README "Features" or "Current Status" section:

```markdown
## Features

- [New feature description]
```

### If Bug Fixed

Add to README "Recent Changes" or "Changelog" section:

```markdown
## Recent Changes

- Fixed: [Bug description]
```

## Step 7: Commit Tracking Updates

If PROJECT-STATUS.md or README were updated:

```bash
git add PROJECT-STATUS.md README.md
git commit --amend --no-edit
# Or create a separate commit:
git commit -m "docs: update project status and readme"
```

## Step 8: Verify Commit

```bash
git log -1 --oneline
git show --stat HEAD
```

## Output Report

```markdown
## Commit Created

**Hash:** [short hash]
**Type:** [feat/fix/etc]
**Message:** [commit message]

### Files Changed
- [X files changed, Y insertions, Z deletions]

### Tracking Updated
- PROJECT-STATUS.md: [Yes/No]
- README.md: [Yes/No - only for feat/fix/perf]

### Next Steps
- [Continue with next task / Run /validate / Push to remote]
```

## Notes

- Keep description under 72 characters
- Use imperative mood ("add" not "added")
- Reference issue numbers if applicable: `fix(api): handle null response (#42)`
- For breaking changes, add `BREAKING CHANGE:` in footer
- Always update PROJECT-STATUS.md for visibility
- Only update README for user-visible changes (feat, fix, perf)
- NEVER include AI attribution (Co-Authored-By) in commits
