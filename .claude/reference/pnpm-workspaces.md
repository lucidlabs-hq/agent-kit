# pnpm Workspaces for Monorepo CI

> **Mandatory for all LUCIDLABS-HQ projects with multiple packages (frontend, mastra, etc.)**
> Last updated: 2026-02-11

## Background

Agent Kit projects are monorepos containing multiple packages (`frontend/`, `mastra/`, etc.). Without proper workspace configuration, CI pipelines break because:

- `pnpm install` only installs dependencies for the root package
- Sub-packages can't resolve each other's dependencies
- Lockfile inconsistencies between local and CI environments
- Gitignored files (like `.next/`) cause build failures when CI tries to access them

**Lesson learned from client-service-reporting:** A working local dev setup does NOT guarantee a working CI pipeline. pnpm workspaces make the monorepo structure explicit.

---

## Setup

### 1. Root `pnpm-workspace.yaml`

Every monorepo project MUST have this file in the project root:

```yaml
packages:
  - "frontend"
  - "mastra"
```

Only list directories that contain a `package.json`. Omit components that don't exist in your project.

### 2. Root `package.json`

The root `package.json` provides workspace-level scripts:

```json
{
  "name": "@lucidlabs/project-name",
  "private": true,
  "scripts": {
    "dev": "pnpm --filter frontend dev",
    "build": "pnpm --filter frontend build",
    "lint": "pnpm --filter frontend lint",
    "type-check": "pnpm --filter frontend type-check",
    "validate": "pnpm --filter frontend validate"
  }
}
```

### 3. Single Root Lockfile

With workspaces, there is ONE `pnpm-lock.yaml` at the project root. Sub-packages do NOT have their own lockfiles.

```
project/
├── pnpm-workspace.yaml      # Workspace definition
├── pnpm-lock.yaml            # Single lockfile (ROOT)
├── package.json              # Root with workspace scripts
├── frontend/
│   └── package.json          # No lockfile here
└── mastra/
    └── package.json          # No lockfile here
```

**Migration from sub-package lockfiles:**
1. Delete `frontend/pnpm-lock.yaml` (and any other sub-package lockfiles)
2. Run `pnpm install` from the project root
3. Commit the new root-level `pnpm-lock.yaml`

---

## CI Pattern: Root Install + Filter

### The Pattern

```yaml
steps:
  - name: Install dependencies
    run: pnpm install --frozen-lockfile
    # Runs from project root, installs ALL workspace packages

  - name: Lint
    run: pnpm --filter frontend lint
    # Runs lint in the frontend package only

  - name: Build
    run: pnpm --filter frontend build
    # Runs build in the frontend package only
```

### Why NOT `cd frontend && pnpm install`

| Approach | Problem |
|----------|---------|
| `cd frontend && pnpm install` | Ignores workspace, creates separate lockfile, misses cross-package deps |
| `cd frontend && pnpm run build` | Works locally but fails in CI if install was done at wrong level |
| **`pnpm install` (root) + `pnpm --filter frontend build`** | Correct: respects workspace, uses root lockfile, resolves all deps |

---

## pnpm Version Alignment

**The pnpm version MUST match between local development and CI.**

### Check Local Version

```bash
pnpm --version
# e.g., 9.15.4
```

### Pin in CI

```yaml
- name: Setup pnpm
  uses: pnpm/action-setup@c5ba7f7862a0f64c1b1a05fbac13e0b8e86ba08c # v4
  with:
    version: 9  # Major version - pnpm/action-setup resolves latest 9.x
```

### Pin in `package.json` (optional but recommended)

```json
{
  "packageManager": "pnpm@9.15.4"
}
```

This enables Corepack to enforce the exact version. CI will warn if a different version is used.

### Common Failure Mode

```
ERR_PNPM_FROZEN_LOCKFILE  Cannot install with "frozen-lockfile" because
pnpm-lock.yaml is not up-to-date with package.json
```

**Fix:** Regenerate lockfile with the CI pnpm version:
```bash
pnpm install --no-frozen-lockfile
# Then commit the updated pnpm-lock.yaml
```

---

## Gitignored Files and Build Fallbacks

### Problem

Files in `.gitignore` (like `.next/`, `node_modules/`, build artifacts) don't exist in CI. If your build process assumes they exist, it fails.

### Common Cases

| File/Directory | Issue | Solution |
|----------------|-------|----------|
| `.next/` | Next.js cache not in CI | Build runs fresh, no issue |
| `node_modules/` | Not in git | `pnpm install --frozen-lockfile` creates it |
| `.env.local` | Secrets not in git | Use GitHub Secrets + CI env vars |
| `generated/` | Auto-generated files | Add generation step to CI before build |
| `convex/_generated/` | Convex codegen | Run `npx convex codegen` before build if needed |

### Rule

**If a file is gitignored, the CI pipeline must either:**
1. Generate it as a build step, OR
2. Not depend on it at all

Never assume gitignored files exist in CI.

---

## cache-dependency-path

When using root-level `pnpm install` with workspaces, you do NOT need `cache-dependency-path` in the `actions/setup-node` step:

```yaml
# NOT needed with workspace root install:
# cache-dependency-path: frontend/pnpm-lock.yaml

# Instead, the default works (root pnpm-lock.yaml):
- uses: actions/setup-node@49933ea5288caeca8642d1e84afbd3f7d6820020 # v4
  with:
    node-version: 22
    cache: "pnpm"
    # cache auto-detects root pnpm-lock.yaml
```

---

## Checklist for New Projects

- [ ] `pnpm-workspace.yaml` exists in project root
- [ ] Root `package.json` has `--filter` scripts
- [ ] Single `pnpm-lock.yaml` at root (no sub-package lockfiles)
- [ ] CI uses `pnpm install` at root level
- [ ] CI uses `pnpm --filter <package>` for package-specific commands
- [ ] pnpm version matches between local and CI
- [ ] No build steps depend on gitignored files

---

## References

- [pnpm Workspaces](https://pnpm.io/workspaces)
- [pnpm --filter](https://pnpm.io/filtering)
- [pnpm in CI](https://pnpm.io/continuous-integration)
- `.claude/reference/ci-cd-security.md` - CI/CD security and workflow architecture
