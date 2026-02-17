# Session Rules

> **Auto-start rules, config backup, and full-stack component requirements.**
> Referenced by: /prime skill, session startup.
> Last Updated: February 2026

---

## Auto-Start Rules

| Rule | Action |
|------|--------|
| **Auto-start Frontend** | ALWAYS start `pnpm run dev` in background at session start |
| **Auto-start Convex** | ALWAYS start `npx convex dev` in background at session start (keeps functions synced) |
| **Auto-start Mastra** | If project has `mastra/` directory, ALWAYS start Mastra dev server in background at session start |
| **Keep Servers Running** | ALL project services (frontend, Convex, Mastra) must run throughout the session |
| **Report URL** | Tell user the localhost URL after each server starts |
| **Convex Sync** | After creating/modifying Convex schema or functions, wait for Convex dev to sync (watch the terminal) |

---

## Config Backup Rule (MANDATORY)

**BEFORE modifying any configuration file, ALWAYS create a backup first.**

This applies to: workflow files (`.github/workflows/`), `docker-compose.yml`, `Caddyfile`, `package.json`, `.env` files, `tsconfig.json`, CI/CD configs, and any other infrastructure/config file that is already working in production.

### Procedure

1. **Create backup directory:** `.backups/<date>/` in the project root (e.g. `.backups/2026-02-11/`)
2. **Copy the original file** before making changes: `cp path/to/config .backups/<date>/config.backup`
3. **For git-tracked files:** Also use `git show HEAD:path/to/file > .backups/<date>/filename.backup` to preserve the last committed version
4. **Document changes:** Create `.backups/<date>/CHANGES.md` listing what was changed and why

**Backup directory is gitignored.** Add `.backups/` to `.gitignore` if not already present.

**Why:** Configuration files that are already working in production must never be blindly overwritten. If something breaks, we need the ability to instantly restore the previous version without digging through git history.

```bash
# Example: Before modifying deploy-hq.yml
mkdir -p .backups/2026-02-11
cp .github/workflows/deploy-hq.yml .backups/2026-02-11/deploy-hq.yml.backup
# Now safe to edit .github/workflows/deploy-hq.yml
```

---

## Full-Stack Component Rule (MANDATORY)

**Every project component chosen at setup MUST be started in dev mode AND deployed to production.**

When a project includes these directories, the corresponding services are MANDATORY:

| Directory | Dev Command | Production |
|-----------|-------------|------------|
| `frontend/` | `pnpm run dev` | docker-compose: `frontend` service |
| `convex/` | `npx convex dev` | docker-compose.convex.yml |
| `mastra/` | `cd mastra && pnpm run dev` | docker-compose: `mastra` service |
| `n8n/` | docker-compose.dev.yml | docker-compose: `n8n` service |

**No partial deployments.** If a component exists in the repo, it MUST be deployed. If a service is missing from docker-compose.yml, add it before deploying.

---

**Version:** 1.0
**Maintainer:** Lucid Labs GmbH
