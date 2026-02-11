# CI/CD Security Best Practices

> **Mandatory for all LUCIDLABS-HQ projects**
> Last updated: 2026-02-11

## Background

In March 2025, the GitHub Action `tj-actions/changed-files` was compromised (CVE-2025-30066). The attack leaked CI secrets from 218 repositories. Root cause: Actions referenced by tag (`@v4`) - attacker re-pointed the tag to malicious code.

**Lesson learned:** All Actions must be pinned to commit SHAs. Tags are mutable, SHAs are not.

---

## Rules (Non-Negotiable)

### 1. SHA-Pinning for All Actions

```yaml
# WRONG - tag can be redirected by attacker
- uses: actions/checkout@v4

# CORRECT - commit SHA is immutable
- uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4
```

**Approved Actions with Pinned SHAs:**

| Action | SHA | Version | Last Verified |
|--------|-----|---------|---------------|
| `actions/checkout` | `34e114876b0b11c390a56381ad16ebd13914f8d5` | v4 | 2026-02-11 |
| `actions/setup-node` | `49933ea5288caeca8642d1e84afbd3f7d6820020` | v4 | 2026-02-11 |
| `pnpm/action-setup` | `c5ba7f7862a0f64c1b1a05fbac13e0b8e86ba08c` | v4 | 2026-02-11 |

### 2. Only First-Party Actions

**Allowed:**
- `actions/checkout`
- `actions/setup-node`
- `pnpm/action-setup`

**Forbidden:** Everything else. If you need SSH, do it inline with `run:`. If you need deployment, script it. No third-party actions.

### 3. Minimal Permissions

```yaml
permissions:
  contents: read  # Read-only, no write access
```

Never grant more permissions than needed. Default should be `contents: read`.

### 4. Secrets Hygiene

- SSH keys only in the `deploy` job, never in CI
- Always use `--frozen-lockfile` with `pnpm install`
- Never echo secrets to logs
- Convex admin key is generated at deploy time from the server container, never stored as a secret

### 5. Concurrency Control

```yaml
concurrency:
  group: deploy-hq
  cancel-in-progress: false  # Don't cancel running deploys
```

Prevents overlapping deployments. `cancel-in-progress: false` ensures running deploys complete.

---

## Workflow Architecture

Every project has two workflow files:

| File | Trigger | Purpose |
|-------|---------|-------|
| `.github/workflows/ci.yml` | `pull_request` against `main` | Lint + Type-Check + Build (parallel) |
| `.github/workflows/deploy-hq.yml` | `push` to `main` (after merge) | Rsync + Docker Build + Convex Deploy + Health Check |

### CI Pipeline (`ci.yml`)

Three parallel jobs that must all pass before a PR can be merged:

```
PR opened/updated
  |
  +-- lint (parallel)
  +-- type-check (parallel)
  +-- build (parallel)
  |
  v
All green? -> PR can be merged
```

### Deploy Pipeline (`deploy-hq.yml`)

Sequential steps after merge to main:

```
Merge to main
  |
  v
1. Checkout code
2. Setup SSH (nightwing@lucidlabs-hq:2222)
3. Rsync code to server
4. Docker Compose build + restart
5. Deploy Convex functions
6. Health check
```

---

## Workspace-Aware CI (Monorepo Projects)

Agent Kit projects are monorepos with multiple packages. CI must respect the pnpm workspace structure.

### Pattern: Root Install + Filter

```yaml
steps:
  - name: Install dependencies
    run: pnpm install --frozen-lockfile
    # Installs ALL workspace packages from root

  - name: Lint
    run: pnpm --filter frontend lint

  - name: Build
    run: pnpm --filter frontend build
```

### Requirements

| Requirement | Details |
|-------------|---------|
| **`pnpm-workspace.yaml`** | Must exist in project root listing all packages |
| **Single lockfile** | One `pnpm-lock.yaml` at root, none in sub-packages |
| **Root install** | `pnpm install` from project root, not from sub-package |
| **`--filter` for jobs** | Use `pnpm --filter <package>` instead of `cd <package>` |
| **No `cache-dependency-path`** | Not needed when installing from root (auto-detects root lockfile) |

### pnpm Version Pinning

The pnpm version in CI must match the local development version:

```yaml
- uses: pnpm/action-setup@c5ba7f7862a0f64c1b1a05fbac13e0b8e86ba08c # v4
  with:
    version: 9  # Must match local pnpm version
```

Optionally pin exact version in root `package.json`:
```json
{
  "packageManager": "pnpm@9.15.4"
}
```

**Full documentation:** `.claude/reference/pnpm-workspaces.md`

---

## Templates

Workflow templates are available in the Agent Kit:

```
lucidlabs-agent-kit/.github/workflow-templates/
  ci.yml           # CI template
  deploy-hq.yml    # Deploy template (replace __PLACEHOLDER__ values)
```

### Using Templates

1. Copy template to project `.github/workflows/`
2. Replace `__PROJECT_NAME__` with actual project name
3. Replace `__SUBDOMAIN__` with production subdomain
4. Add `--exclude='mastra/node_modules'` if project has Mastra
5. Set up required secrets in GitHub

---

## Required Secrets

| Secret | Scope | Description |
|--------|-------|-------------|
| `LUCIDLABS_HQ_HOST` | Org-level | Server IP address |
| `LUCIDLABS_HQ_SSH_KEY` | Org-level | SSH private key for nightwing user |
| `NEXT_PUBLIC_CONVEX_URL` | Repo-level | Project-specific Convex URL |
| *(no CONVEX_DEPLOY_KEY)* | - | Admin key generated at deploy time via `docker exec <abbr>-convex-backend /convex/generate_admin_key.sh` |

---

## Branch Protection

After setting up workflows, enable branch protection via `gh` CLI:

```bash
gh api repos/OWNER/REPO/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["lint","type-check","build"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null
```

This ensures:
- All three CI checks must pass
- At least 1 approving review required
- Stale reviews are dismissed on new pushes
- No direct pushes to main

---

## References

- [CVE-2025-30066 - CISA Advisory](https://www.cisa.gov/news-events/alerts/2025/03/18/supply-chain-compromise-third-party-tj-actionschanged-files-cve-2025-30066-and-reviewdogaction)
- [GitHub Actions SHA Pinning Guide](https://www.stepsecurity.io/blog/pinning-github-actions-for-enhanced-security-a-complete-guide)
- [GitHub Actions Security Cheat Sheet](https://blog.gitguardian.com/github-actions-security-cheat-sheet/)
- [OpenSSF: Securing CI/CD](https://openssf.org/blog/2025/06/11/maintainers-guide-securing-ci-cd-pipelines-after-the-tj-actions-and-reviewdog-supply-chain-attacks/)
