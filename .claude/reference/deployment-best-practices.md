# Deployment Best Practices Reference

Best practices for deploying Agent Kit projects with Docker and Elestio.

---

## Table of Contents

1. [Deployment Philosophy](#1-deployment-philosophy)
2. [Docker Setup](#2-docker-setup)
3. [Elestio Configuration](#3-elestio-configuration)
4. [Environment Management](#4-environment-management)
5. [CI/CD with GitHub Actions](#5-cicd-with-github-actions)
6. [Monitoring & Logging](#6-monitoring--logging)
7. [Production Checklist](#7-production-checklist)

---

## 1. Deployment Philosophy

### Local Equals Production

```
┌─────────────────────────────────────────────────────────┐
│                     LOCAL DEV                           │
│                                                         │
│    docker compose -f docker-compose.dev.yml up          │
│    Same topology, local URLs                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                     PRODUCTION                          │
│                                                         │
│    docker compose up -d                                 │
│    Same topology, production URLs                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Push-Based Deployment

1. Push to `main` branch
2. GitHub Actions triggers
3. SSH to Elestio
4. `docker compose up -d --build`

No additional tooling required.

---

## 2. Docker Setup

### Frontend Dockerfile

```dockerfile
# frontend/Dockerfile
FROM node:22-alpine AS base

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Dependencies stage
FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Build stage
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build arguments for environment
ARG NEXT_PUBLIC_CONVEX_URL
ENV NEXT_PUBLIC_CONVEX_URL=$NEXT_PUBLIC_CONVEX_URL

ARG NEXT_PUBLIC_MASTRA_URL
ENV NEXT_PUBLIC_MASTRA_URL=$NEXT_PUBLIC_MASTRA_URL

RUN pnpm run build

# Production stage
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy built application
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
```

### Mastra Dockerfile

```dockerfile
# mastra/Dockerfile
FROM node:22-alpine AS base

RUN corepack enable && corepack prepare pnpm@latest --activate

FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm run build

FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 mastra

COPY --from=builder --chown=mastra:nodejs /app/dist ./dist
COPY --from=builder --chown=mastra:nodejs /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

USER mastra

EXPOSE 4000
ENV PORT=4000

CMD ["node", "dist/index.js"]
```

### Docker Compose (Production)

```yaml
# docker-compose.yml
services:
  caddy:
    image: caddy:2-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    restart: unless-stopped

  frontend:
    build:
      context: ./frontend
      args:
        NEXT_PUBLIC_CONVEX_URL: ${NEXT_PUBLIC_CONVEX_URL}
        NEXT_PUBLIC_MASTRA_URL: ${NEXT_PUBLIC_MASTRA_URL}
    environment:
      - NODE_ENV=production
    depends_on:
      - mastra
    restart: unless-stopped

  mastra:
    build:
      context: ./mastra
    environment:
      - NODE_ENV=production
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - CONVEX_URL=${CONVEX_URL}
    restart: unless-stopped

volumes:
  caddy_data:
  caddy_config:
```

### Docker Compose (Development)

```yaml
# docker-compose.dev.yml
services:
  # Only services needed for local development
  # Convex runs via `npx convex dev`
  # Frontend runs via `pnpm run dev`
  # Mastra runs via `pnpm run dev`

  # Optional: n8n for workflow development
  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=changeme
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
```

### Caddyfile

```
{$DOMAIN} {
    # Frontend
    reverse_proxy frontend:3000

    # Mastra API
    handle /api/agent/* {
        reverse_proxy mastra:4000
    }
}
```

---

## 3. Elestio Configuration

### elestio.yml

```yaml
# elestio.yml
config:
  runTime: "dockerCompose"
  version: "1"

ports:
  - protocol: "HTTPS"
    targetProtocol: "HTTP"
    listeningPort: "443"
    targetPort: "80"
    public: true
    path: "/"
    isAuth: false

environments:
  - key: "NODE_ENV"
    value: "production"
  - key: "NEXT_PUBLIC_CONVEX_URL"
    value: ""
  - key: "CONVEX_URL"
    value: ""
  - key: "ANTHROPIC_API_KEY"
    value: ""
  - key: "OPENAI_API_KEY"
    value: ""
  - key: "DOMAIN"
    value: ""

lifeCycle:
  postInstall: "docker compose up -d --build"
  postUpdate: "docker compose up -d --build"
```

---

## 4. Environment Management

### Environment Variables Structure

```env
# .env.example (committed to repo)

# Convex (Required)
NEXT_PUBLIC_CONVEX_URL=
CONVEX_URL=
CONVEX_DEPLOY_KEY=

# AI Models (Required)
ANTHROPIC_API_KEY=
OPENAI_API_KEY=

# Mastra
NEXT_PUBLIC_MASTRA_URL=http://localhost:4000
PORT=4000

# Domain (Production)
DOMAIN=

# n8n (Optional)
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=
```

### Environment Validation

```typescript
// lib/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  NEXT_PUBLIC_CONVEX_URL: z.string().url(),
  ANTHROPIC_API_KEY: z.string().min(1),
  OPENAI_API_KEY: z.string().optional(),
  NEXT_PUBLIC_MASTRA_URL: z.string().url(),
});

export type Env = z.infer<typeof envSchema>;

export function validateEnv(): Env {
  const parsed = envSchema.safeParse(process.env);

  if (!parsed.success) {
    console.error('❌ Invalid environment variables:');
    console.error(parsed.error.format());
    throw new Error('Invalid environment variables');
  }

  return parsed.data;
}
```

---

## 5. CI/CD with GitHub Actions

### Build and Deploy Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 9

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'pnpm'

      - name: Install dependencies
        run: |
          cd frontend && pnpm install
          cd ../mastra && pnpm install

      - name: Lint
        run: |
          cd frontend && pnpm run lint
          cd ../mastra && pnpm run lint

      - name: Type check
        run: |
          cd frontend && pnpm run type-check
          cd ../mastra && pnpm exec tsc --noEmit

      - name: Test
        run: |
          cd frontend && pnpm run test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Elestio
        env:
          ELESTIO_HOST: ${{ secrets.ELESTIO_HOST }}
          ELESTIO_SSH_KEY: ${{ secrets.ELESTIO_SSH_KEY }}
        run: |
          mkdir -p ~/.ssh
          echo "$ELESTIO_SSH_KEY" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan -H $ELESTIO_HOST >> ~/.ssh/known_hosts

          ssh root@$ELESTIO_HOST << 'EOF'
            cd /opt/app
            git pull origin main
            docker compose up -d --build
          EOF
```

---

## 6. Monitoring & Logging

### Monitoring Strategy

**Phase 1 (Current):**
- Uptime Kuma for health monitoring
- Structured logging to stdout
- Basic health check endpoints

**Phase 2 (Optional later):**
- Sentry for error tracking
- LogTail for log aggregation
- Prometheus metrics

### Uptime Kuma Setup

Uptime Kuma provides simple, self-hosted uptime monitoring.

```yaml
# Add to docker-compose.yml (or run separately)
services:
  uptime-kuma:
    image: louislam/uptime-kuma:1
    volumes:
      - uptime-kuma-data:/app/data
    ports:
      - "3001:3001"
    restart: unless-stopped

volumes:
  uptime-kuma-data:
```

**Configure monitors:**
1. Access Uptime Kuma at `http://localhost:3001`
2. Add HTTP monitor for `/api/health` endpoint
3. Set check interval (e.g., every 60 seconds)
4. Configure notifications (Email, Slack, Discord, etc.)

### Structured Logging

**Format:** `[Component] Message`

```typescript
console.error('[API] Failed to fetch resource', {
  resourceId: params.id,
  userId: req.headers.get('user-id'),
  error: error.message,
  timestamp: new Date().toISOString()
})
```

### JSON Format (Production)

For production logging (Elestio captures stdout):

```typescript
console.log(JSON.stringify({
  level: 'error',
  component: 'API',
  message: 'Request failed',
  resourceId: params.id,
  timestamp: new Date().toISOString(),
  error: {
    message: error.message,
    stack: error.stack
  }
}))
```

### Health Check Endpoint

```typescript
// app/api/health/route.ts
export async function GET() {
  const checks = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    services: {
      convex: await checkConvex(),
      mastra: await checkMastra(),
    },
  };

  const allHealthy = Object.values(checks.services).every(s => s === 'ok');

  return Response.json(checks, {
    status: allHealthy ? 200 : 503,
  });
}

async function checkConvex(): Promise<'ok' | 'error'> {
  try {
    // Convex health check via a simple query
    return 'ok';
  } catch {
    return 'error';
  }
}

async function checkMastra(): Promise<'ok' | 'error'> {
  try {
    const response = await fetch(`${process.env.NEXT_PUBLIC_MASTRA_URL}/health`);
    return response.ok ? 'ok' : 'error';
  } catch {
    return 'error';
  }
}
```

### Sentry Integration

```bash
pnpm add @sentry/nextjs
```

```typescript
// sentry.client.config.ts
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
})
```

---

## 7. Production Checklist

### Before Deployment

```markdown
## Pre-Deployment Checklist

### Code Quality
- [ ] All tests passing
- [ ] No TypeScript errors
- [ ] No linting errors
- [ ] Code review completed
- [ ] Security vulnerabilities checked

### Environment
- [ ] All required env vars documented in .env.example
- [ ] Secrets stored in GitHub Secrets (not in repo)
- [ ] Production env vars set in Elestio

### Convex
- [ ] Schema deployed: `npx convex deploy`
- [ ] Functions tested
- [ ] Vector indexes created (if using RAG)

### Mastra
- [ ] Agents tested
- [ ] Tools validated
- [ ] Health endpoint working

### Performance
- [ ] Images optimized
- [ ] Bundle size checked
- [ ] Caching configured

### Security
- [ ] HTTPS enforced (Caddy handles this)
- [ ] CORS configured correctly
- [ ] API rate limiting in place
- [ ] Input validation on all endpoints

### Monitoring
- [ ] Error tracking configured (Sentry)
- [ ] Logging configured
- [ ] Health checks in place
- [ ] Alerting set up
```

### Rollback Strategy

```bash
# Rollback to previous commit
ssh root@$ELESTIO_HOST << 'EOF'
  cd /opt/app
  git checkout HEAD~1
  docker compose up -d --build
EOF
```

---

## Commands Summary

```bash
# Local development
docker compose -f docker-compose.dev.yml up -d  # Start optional services
cd frontend && pnpm run dev                      # Start frontend
cd mastra && pnpm run dev                        # Start Mastra
npx convex dev                                   # Start Convex dev

# Build for production
docker compose build

# Deploy locally
docker compose up -d

# View logs
docker compose logs -f

# Stop all services
docker compose down
```

---

## Related References

- `architecture.md` - Platform architecture
- `scaling.md` - Stateless patterns
- `error-handling.md` - Error patterns

---

**Version:** 2.0
**Last Updated:** January 2026
**Maintainer:** Lucid Labs GmbH
