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
/pr
  |
  v
1. Detect current branch (expect feature branch from /execute)
2. Validate (lint + type-check)
3. Analyze changes vs main
4. Push branch
5. Create PR with CI checks
6. Report PR URL
```

**Expected state:** You are on a feature branch created by `/execute`. Commits are already there from `/commit`.

## Step 1: Detect Branch State

```bash
CURRENT_BRANCH=$(git branch --show-current)
```

**Decision tree:**

```
On which branch?
├── feature/* or fix/* or refactor/* or docs/* or chore/*
│   → Already on feature branch. Continue to Step 2.
│
├── main (with unpushed commits)
│   → FALLBACK: Create branch, move commits off main.
│   → git checkout -b feature/<name>
│   → git checkout main && git reset --hard origin/main
│   → git checkout feature/<name>
│   → Warn: "Next time, use /execute to create the branch first."
│
└── main (no unpushed commits)
    → ERROR: Nothing to PR. Run /execute first.
```

## Step 2: Validate Before Pushing

```bash
cd frontend && pnpm run validate
```

If validation fails: STOP. Fix the issues first.

If `pnpm run validate` does not exist, run lint and type-check separately:
```bash
cd frontend && pnpm run lint && pnpm run type-check
```

## Step 3: Analyze Changes

```bash
git status
git log --oneline main..HEAD
git diff --stat main..HEAD
```

Understand what is being pushed. Review all commits on the branch. Never push files that:
- Contain secrets (`.env`, credentials)
- Are build artifacts (`.next/`, `node_modules/`)
- Are unrelated to the current task

## Step 4: Push Branch

```bash
git push -u origin "$CURRENT_BRANCH"
```

## Step 5: Create Pull Request

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
