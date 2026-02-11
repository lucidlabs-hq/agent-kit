---
name: pr
description: Create a feature branch, commit changes, push, and open a Pull Request. The standard way to ship changes. Use after implementation is complete.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, Grep, Glob
argument-hint: [branch-name or description]
---

# Create Pull Request

The standard workflow for shipping changes. Creates a branch, commits, pushes, and opens a PR.

**This is the ONLY way to get code into `main`.** Direct pushes are blocked by Branch Protection.

## Flow

```
/pr "add dashboard filters"
  |
  v
1. Validate (lint + type-check)
2. Create branch: feature/add-dashboard-filters
3. Stage + commit changes
4. Push branch
5. Create PR with CI checks
6. Report PR URL
```

## Step 1: Validate Before Committing

```bash
cd frontend && pnpm run validate
```

If validation fails: STOP. Fix the issues first.

If `pnpm run validate` does not exist, run lint and type-check separately:
```bash
cd frontend && pnpm run lint && pnpm run type-check
```

## Step 2: Analyze Changes

```bash
git status
git diff --stat
```

Understand what is being committed. Never commit files that:
- Contain secrets (`.env`, credentials)
- Are build artifacts (`.next/`, `node_modules/`)
- Are unrelated to the current task

## Step 3: Determine Branch Name

From the argument or the changes, create a descriptive branch name:

| Pattern | Example |
|---------|---------|
| `feature/<description>` | `feature/add-dashboard-filters` |
| `fix/<description>` | `fix/auth-redirect-loop` |
| `refactor/<description>` | `refactor/extract-api-client` |
| `docs/<description>` | `docs/update-readme-ports` |
| `chore/<description>` | `chore/update-dependencies` |

Rules:
- Lowercase, kebab-case
- Short but descriptive (3-5 words max)
- No ticket numbers unless specifically requested

## Step 4: Create Branch and Commit

```bash
# Ensure we branch from latest main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/<branch-name>

# Stage relevant files (be specific, not git add -A)
git add <specific files>

# Commit with conventional message
git commit -m "<type>(<scope>): <description>

<optional body with details>"
```

### Commit Message Rules

- Conventional format: `feat(scope): description`
- Under 72 characters for the first line
- Imperative mood ("add" not "added")
- NO `Co-Authored-By` or AI attribution
- Body for details if needed

## Step 5: Push Branch

```bash
git push -u origin feature/<branch-name>
```

## Step 6: Create Pull Request

```bash
gh pr create \
  --title "<type>(<scope>): <description>" \
  --body "$(cat <<'PREOF'
## Summary

<1-3 bullet points describing the changes>

## Changes

<list of key files changed and why>

## Test Plan

- [ ] CI passes (lint + type-check + build)
- [ ] <manual verification steps if applicable>
PREOF
)"
```

## Step 7: Report Result

```markdown
## PR Created

**Branch:** feature/<branch-name>
**PR:** <URL from gh pr create>
**CI Status:** Running (lint + type-check + build)

### Changes
- <X files changed, Y insertions, Z deletions>

### Next Steps
- Wait for CI checks to pass
- Get review approval
- Merge -> Auto-deploy
```

## After PR is Merged

The deploy workflow runs automatically:
1. Rsync code to LUCIDLABS-HQ server
2. Docker Compose build + restart
3. Convex functions deploy
4. Health check

**You do NOT need to do anything after merge.** Deployment is fully automated.

## Handling CI Failures

If CI fails on the PR:

```bash
# Fix the issue locally
git add <fixed files>
git commit -m "fix: resolve CI failure"
git push
```

The PR will automatically re-run CI checks.

## Quick Reference

```bash
# Full flow in one go (after changes are ready):
git checkout main && git pull origin main
git checkout -b feature/my-change
git add <files>
git commit -m "feat(scope): my change"
git push -u origin feature/my-change
gh pr create --title "feat(scope): my change" --body "Summary of changes"
```

## Notes

- ALWAYS branch from latest `main`
- ALWAYS use specific `git add <files>` (not `git add -A`)
- NEVER push directly to `main` (Branch Protection will reject it)
- NEVER include AI attribution in commits
- Keep PRs focused - one feature/fix per PR
- If PR touches multiple concerns, consider splitting into multiple PRs
