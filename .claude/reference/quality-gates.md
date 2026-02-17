# Quality Gates

> **Gate architecture, change size classification, visual verification, subagent triggers, and failure protocol.**
> Referenced by: /execute, /commit, /pr, /pre-production skills.
> Last Updated: February 2026

---

## Change Size Classification

Before running gates, classify the change size. This determines which gates are required:

| Level | Criteria | Example |
|-------|----------|---------|
| **S (Small)** | 1-2 files, config only, no UI | Fix typo, update env var, tweak config |
| **M (Medium)** | 3-10 files, single component/feature | Add a new component, refactor a module |
| **L (Large)** | 10+ files, new feature with UI, multi-component | New page, new workflow, major refactor |

### How to Classify

Count the changed files and check what was touched:

```
git diff --stat main..HEAD
```

| What Changed | Minimum Level |
|-------------|---------------|
| Only config/docs | S |
| Backend-only (API, DB, tools) | M |
| Any UI files (components/, app/) | M |
| New page or multi-component feature | L |
| New skill, new workflow, new service | L |

**The level determines which gates run:**

| Gate | S | M | L |
|------|---|---|---|
| Architecture Guard | - | YES | YES |
| Design System Guard (UI) | - | YES | YES |
| SSR Safety Checker | - | YES | YES |
| Unit Tests | YES | YES | YES |
| **Smoke Test (server + API)** | - | **YES** | **YES** |
| **Visual Verification (browser)** | - | - | **YES (ask first)** |

---

## Gate Architecture

| Gate | Trigger | Subagent(s) | Blocking? |
|------|---------|-------------|-----------|
| **Post-Implementation** | After `/execute` | architecture-guard | YES |
| **Post-UI-Change** | After UI file changes | design-system-guard, ssr-safety-checker | YES |
| **Post-Mastra-Change** | After mastra/ changes | mastra-validator | YES |
| **Visual Verification** | After `/execute` (L-level with UI) | agent-browser | YES |
| **Pre-Commit** | Before `/commit` | test-runner, code-reviewer, security-guard | YES |
| **Pre-PR** | Before `/pr` | code-reviewer, error-handling-reviewer | YES |
| **Pre-Deploy** | Before `/deploy` | strix (full scan), pnpm audit | YES |

---

## Post-Implementation Gate

Run after `/execute` completes implementation:

1. **architecture-guard** on all changed files
2. **design-system-guard** if UI files were modified
3. **ssr-safety-checker** if React components were modified
4. **mastra-validator** if mastra/ files were modified

All CRITICAL findings must be fixed before proceeding.

---

## Smoke Test (M and L Level)

**Triggers when:** Change size is M or L. Runs proactively without asking the user.

Quick automated check that the application still runs:

1. **Dev server running?** Start if not.
2. **Main page responds?** `curl` returns 200.
3. **API endpoints reachable?** Health check returns 200.
4. **If error:** Try refresh/restart. If still broken, fix the code.

This catches build errors, missing imports, and broken routes before any manual verification.

---

## Visual Verification Gate (L-Level with UI)

**Triggers when:** Change size is L (Large) AND UI files were modified.

**IMPORTANT: Ask the user before starting.** The agent says:

> "This was a large feature ([X] files changed). Shall I verify the UI in the browser with screenshots?"

**If user confirms,** proceed with verification. **If user declines,** skip but note it.

### Verification Steps

1. **Open each affected page** in agent-browser
2. **Take screenshot** of each page (desktop viewport)
3. **Check for errors:**
   - Page loads without blank screen or error
   - Layout matches expected structure (snapshot -i)
   - Key interactive elements are present and clickable
4. **Mobile viewport** check (375x812) for responsive pages
5. **If issues found:**
   - Fix the issue in code
   - Re-verify (loop back to step 1)
   - Continue only when all pages work
6. **Report result** with screenshots

### Fix Loop

```
Verify → Issue Found? → YES → Fix Code → Re-verify
                      → NO  → PASS → Continue to /commit
```

**The agent does NOT skip to commit if visual issues are found.** Fix first, verify again, then proceed.

---

## Pre-Commit Gate

Run before `/commit` creates a commit:

1. `pnpm run test` - fail = STOP
2. `pnpm run lint` - fail = STOP
3. `pnpm run type-check` - fail = STOP
4. **code-reviewer** subagent on `git diff --cached`
5. CRITICAL = STOP, WARNINGS = user decides

---

## Pre-PR Gate

Run before `/pr` creates a pull request:

1. **code-reviewer** on `git diff main..HEAD`
2. **error-handling-reviewer** on API routes
3. **architecture-guard** final check
4. Results included in PR description under "Quality Gate Results"

---

## Pre-Deploy Gate

Run before `/deploy` pushes to production:

1. Full test suite (`pnpm run test`)
2. `pnpm audit` for dependency vulnerabilities
3. Strix security scan against local app (if configured)
4. All CRITICAL and HIGH findings must be resolved

---

## Unit Test Enforcement

| Rule | Requirement |
|------|------------|
| **New functions** | Every new function MUST have unit tests |
| **Test pass** | `pnpm run test` MUST be green before commit |
| **Coverage minimum** | 60% lines, 50% branches |
| **Test pyramid** | 60% Unit (Vitest) / 30% Integration / 10% E2E (Playwright) |

---

## Failure Protocol

| Severity | Action |
|----------|--------|
| **CRITICAL** | STOP immediately. No exceptions. Fix required. |
| **HIGH** | STOP. Fix required before proceeding. |
| **WARNING** | List all warnings. User decides whether to proceed. |
| **INFO** | Document and continue. |

### Escalation

- If a gate blocks and the fix is unclear, ask the user for guidance
- Never bypass a gate with `--force` or `--no-verify`
- Document any user-approved exceptions in the commit message

---

**Version:** 1.0
**Maintainer:** Lucid Labs GmbH
