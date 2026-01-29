---
name: deploy
description: Deploy invoice-accounting-assistant to HQ server. Runs tests first (TDD), then builds and deploys. Use when ready to push changes to staging/production.
disable-model-invocation: true
allowed-tools: Bash, Read, Write
argument-hint: [environment]
---

# Deploy to HQ Server

Deployment workflow with TDD integration. Tests MUST pass before deployment.

---

## Usage

```
/deploy           # Deploy to production (default)
/deploy staging   # Deploy to staging (same as production for now)
```

---

## Pre-Flight Checklist

Before deployment, verify:

1. [ ] All tests pass
2. [ ] TypeScript compiles without errors
3. [ ] ESLint passes
4. [ ] No uncommitted changes
5. [ ] On main branch (or approved branch)

---

## Step 1: Pre-Deployment Validation (TDD)

**KRITISCH:** Deployment wird abgebrochen wenn Tests fehlschlagen.

### 1.1 Run All Tests

```bash
cd frontend

# Unit Tests
pnpm run test

# Type Check
pnpm run type-check

# Lint
pnpm run lint
```

### 1.2 Check for Uncommitted Changes

```bash
git status --porcelain
```

If there are changes:
```
⚠️  Uncommitted changes detected!

Options:
1. Commit changes first: /commit
2. Stash changes: git stash
3. Abort deployment
```

### 1.3 Verify Branch

```bash
git branch --show-current
```

Warn if not on `main`:
```
⚠️  Not on main branch (currently on: feature/xyz)

Continue anyway? [y/N]
```

---

## Step 2: Build Verification

### 2.1 Production Build

```bash
cd frontend
pnpm run build
```

If build fails:
```
❌ Build failed! Fix errors before deploying.

Common issues:
- TypeScript errors
- Missing dependencies
- Environment variables not set
```

---

## Step 3: Deploy to HQ Server

### 3.1 Sync Code to Server

```bash
rsync -avz --delete \
  -e "ssh -p 2222" \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='.next' \
  --exclude='.env.local' \
  ./ nightwing@91.98.70.29:/opt/lucidlabs/projects/invoice/
```

### 3.2 Build & Start on Server

```bash
ssh -p 2222 nightwing@91.98.70.29 << 'EOF'
  cd /opt/lucidlabs/projects/invoice

  # Build and deploy
  docker compose -f docker-compose.hq.yml -p invoice up -d --build

  # Wait for health check
  sleep 15

  # Show status
  docker compose -f docker-compose.hq.yml -p invoice ps
EOF
```

### 3.3 Health Check

```bash
curl -f https://invoice.lucidlabs.de/api/health || echo "Health check failed!"
```

---

## Step 4: Post-Deployment

### 4.1 Verify Deployment

```
┌─────────────────────────────────────────────────────────────────┐
│  ✅ DEPLOYMENT SUCCESSFUL                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  URL: https://invoice.lucidlabs.de                              │
│  Time: [timestamp]                                               │
│  Branch: main                                                    │
│  Commit: [short-hash]                                            │
│                                                                  │
│  Services:                                                       │
│  ├─ invoice-frontend  ✅ Running                                │
│  ├─ invoice-mastra    ✅ Running                                │
│  ├─ lucidlabs-convex  ✅ Running                                │
│  └─ lucidlabs-portkey ✅ Running                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Rollback (if needed)

If deployment fails:
```bash
ssh -p 2222 nightwing@91.98.70.29 << 'EOF'
  cd /opt/lucidlabs/projects/invoice

  # Rollback to previous version
  git checkout HEAD~1
  docker compose -f docker-compose.hq.yml -p invoice up -d --build
EOF
```

---

## TDD Integration

This deployment skill is integrated with the TDD workflow:

```
┌──────────────────────────────────────────────────────────────────┐
│                      DEVELOPMENT WORKFLOW                         │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. Write Test (RED)                                              │
│     └─► pnpm run test                                            │
│                                                                   │
│  2. Implement Feature                                             │
│     └─► pnpm run test (GREEN)                                    │
│                                                                   │
│  3. Refactor                                                      │
│     └─► pnpm run test (still GREEN)                              │
│                                                                   │
│  4. Commit                                                        │
│     └─► /commit                                                   │
│                                                                   │
│  5. Deploy                                                        │
│     └─► /deploy                                                   │
│         ├─► Tests (must pass)                                    │
│         ├─► Build (must succeed)                                 │
│         └─► Deploy to HQ                                         │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Quick Commands

```bash
# Full deployment (with tests)
/deploy

# Skip tests (NOT RECOMMENDED)
# Only use in emergencies
pnpm run deploy:force

# Check deployment status
ssh -p 2222 nightwing@91.98.70.29 "docker ps | grep invoice"

# View logs
ssh -p 2222 nightwing@91.98.70.29 "docker logs invoice-frontend --tail 50"
```

---

## Environment-Specific Notes

### Production URLs
- Frontend: https://invoice.lucidlabs.de
- API: https://invoice.lucidlabs.de/api
- Health: https://invoice.lucidlabs.de/api/health

### Server Details
- Host: 91.98.70.29
- SSH Port: 2222
- User: nightwing
- Project Path: /opt/lucidlabs/projects/invoice

---

**Version:** 1.0
**Created:** 29. Januar 2026
