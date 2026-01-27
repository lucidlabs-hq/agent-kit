# Deployment Best Practices Reference

Best practices for deploying Neola AI projects with Docker and Elestio.

---

## Table of Contents

1. [Docker Setup](#1-docker-setup)
2. [Elestio Configuration](#2-elestio-configuration)
3. [Environment Management](#3-environment-management)
4. [CI/CD with GitHub Actions](#4-cicd-with-github-actions)
5. [Production Checklist](#5-production-checklist)

---

## 1. Docker Setup

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
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

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

### Backend Dockerfile (Mastra)

```dockerfile
# backend/Dockerfile
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

### Docker Compose

```yaml
# docker-compose.yml
services:
  frontend:
    build:
      context: ./frontend
      args:
        NEXT_PUBLIC_API_URL: http://backend:4000
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - backend
    restart: unless-stopped

  backend:
    build:
      context: ./backend
    ports:
      - "4000:4000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/Neola
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

  db:
    image: pgvector/pgvector:pg16
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=Neola
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
    restart: unless-stopped

volumes:
  postgres_data:
```

### Development Docker Compose

```yaml
# docker-compose.dev.yml
services:
  db:
    image: pgvector/pgvector:pg16
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=Neola_dev
    volumes:
      - postgres_dev_data:/var/lib/postgresql/data

volumes:
  postgres_dev_data:
```

---

## 2. Elestio Configuration

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
    targetPort: "3000"
    public: true
    path: "/"
    isAuth: false

  - protocol: "HTTPS"
    targetProtocol: "HTTP"
    listeningPort: "444"
    targetPort: "4000"
    public: true
    path: "/api"
    isAuth: false

environments:
  - key: "NODE_ENV"
    value: "production"
  - key: "DATABASE_URL"
    value: "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}"
  - key: "ANTHROPIC_API_KEY"
    value: ""
  - key: "OPENAI_API_KEY"
    value: ""

lifeCycle:
  postInstall: "docker compose exec backend pnpm run db:push"
  postUpdate: "docker compose exec backend pnpm run db:push"
```

### Production Docker Compose for Elestio

```yaml
# docker-compose.prod.yml
services:
  frontend:
    image: ${CI_REGISTRY_IMAGE}/frontend:${CI_COMMIT_SHA}
    ports:
      - "172.17.0.1:3000:3000"
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_API_URL=https://${DOMAIN}:444
    restart: always

  backend:
    image: ${CI_REGISTRY_IMAGE}/backend:${CI_COMMIT_SHA}
    ports:
      - "172.17.0.1:4000:4000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    restart: always

  db:
    image: pgvector/pgvector:pg16
    environment:
      - POSTGRES_USER=${POSTGRES_USER:-postgres}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB:-Neola}
    volumes:
      - ./postgres_data:/var/lib/postgresql/data
    restart: always
```

---

## 3. Environment Management

### Environment Variables Structure

```
# .env.local (Development)
NODE_ENV=development
DATABASE_URL=postgresql://postgres:password@localhost:5432/Neola_dev

# AI
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...

# Next.js
NEXT_PUBLIC_API_URL=http://localhost:4000

# Optional: Integrations
CASAVI_API_KEY=
CASAVI_API_URL=

# .env.production (Production - in Elestio)
NODE_ENV=production
DATABASE_URL=postgresql://...

ANTHROPIC_API_KEY=...
OPENAI_API_KEY=...

NEXT_PUBLIC_API_URL=https://api.Neola.example.com

CASAVI_API_KEY=...
CASAVI_API_URL=https://api.casavi.de
```

### Environment Validation

```typescript
// lib/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string().url(),
  ANTHROPIC_API_KEY: z.string().min(1),
  OPENAI_API_KEY: z.string().optional(),
  NEXT_PUBLIC_API_URL: z.string().url(),
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

export const env = validateEnv();
```

---

## 4. CI/CD with GitHub Actions

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
          cd ../backend && pnpm install
          
      - name: Lint
        run: |
          cd frontend && pnpm run lint
          cd ../backend && pnpm run lint
          
      - name: Type check
        run: |
          cd frontend && pnpm exec tsc --noEmit
          cd ../backend && pnpm exec tsc --noEmit
          
      - name: Test
        run: |
          cd frontend && pnpm run test
          cd ../backend && pnpm run test

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    permissions:
      contents: read
      packages: write
      
    steps:
      - uses: actions/checkout@v4
      
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Build and push frontend
        uses: docker/build-push-action@v5
        with:
          context: ./frontend
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/frontend:${{ github.sha }}
          
      - name: Build and push backend
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/backend:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Deploy to Elestio
        uses: elestio/actions-deploy@v1
        with:
          api-key: ${{ secrets.ELESTIO_API_KEY }}
          project-id: ${{ secrets.ELESTIO_PROJECT_ID }}
          image-tag: ${{ github.sha }}
```

### PR Preview Workflow

```yaml
# .github/workflows/pr-preview.yml
name: PR Preview

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy PR Preview
        # Use your preview deployment service
        run: echo "Deploy preview for PR ${{ github.event.pull_request.number }}"
```

---

## 5. Production Checklist

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
- [ ] All required env vars documented
- [ ] Secrets stored securely (not in repo)
- [ ] Production env vars set in Elestio

### Database
- [ ] Migrations tested on staging
- [ ] Backup strategy in place
- [ ] Connection pooling configured

### Performance
- [ ] Images optimized
- [ ] Bundle size checked
- [ ] Caching configured

### Security
- [ ] HTTPS enforced
- [ ] CORS configured correctly
- [ ] API rate limiting in place
- [ ] Input validation on all endpoints

### Monitoring
- [ ] Error tracking configured (Sentry)
- [ ] Logging configured
- [ ] Health checks in place
- [ ] Alerting set up
```

### Health Check Endpoint

```typescript
// app/api/health/route.ts
export async function GET() {
  const checks = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    services: {
      database: await checkDatabase(),
      mastra: await checkMastra(),
    },
  };

  const allHealthy = Object.values(checks.services).every(s => s === 'ok');

  return Response.json(checks, {
    status: allHealthy ? 200 : 503,
  });
}

async function checkDatabase(): Promise<'ok' | 'error'> {
  try {
    await db.execute(sql`SELECT 1`);
    return 'ok';
  } catch {
    return 'error';
  }
}

async function checkMastra(): Promise<'ok' | 'error'> {
  try {
    const agent = mastra.getAgent('sabine');
    return agent ? 'ok' : 'error';
  } catch {
    return 'error';
  }
}
```

### Rollback Strategy

```bash
# Rollback to previous version
docker compose down
docker compose -f docker-compose.prod.yml up -d --pull always

# Or with specific image tag
CI_COMMIT_SHA=previous_hash docker compose -f docker-compose.prod.yml up -d
```

---

## Commands

```bash
# Local development with Docker
docker compose -f docker-compose.dev.yml up -d  # Start DB
cd frontend && bun dev                           # Start frontend
cd backend && bun run dev                        # Start backend

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

## 6. Monitoring & Logging

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

### Prometheus Metrics (Optional)

```typescript
// app/api/metrics/route.ts
export async function GET() {
  const metrics = `
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",status="200"} 1234

# HELP http_request_duration_seconds Request duration
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds{method="GET",le="0.1"} 1000
  `.trim()

  return new Response(metrics, {
    headers: { 'Content-Type': 'text/plain' }
  })
}
```

### Readiness Check

```typescript
// app/api/ready/route.ts
export async function GET() {
  const isReady = await checkReadiness()

  return Response.json({ ready: isReady }, {
    status: isReady ? 200 : 503
  })
}
```

---

## 7. Troubleshooting

### Health Check Fails

**Symptoms:** Elestio reports unhealthy service

**Solution:**
- Check `/api/health` endpoint returns 200
- Verify all dependencies accessible
- Check logs: `docker compose logs -f`

### Environment Variables Not Set

**Symptoms:** Application fails to start

**Solution:**
- Verify all required ENV vars set in Elestio
- Check ENV var names (case-sensitive)
- Restart service after setting ENV vars

### Database Connection Fails

**Symptoms:** Health check reports database: error

**Solution:**
- Verify `DATABASE_URL` format
- Check PostgreSQL service is running
- Verify network connectivity

---

## Related References

- `scaling.md` - Scaling considerations
- `database-strategy.md` - PostgreSQL setup
- `error-handling.md` - Error patterns

---

## Resources

- [Docker Documentation](https://docs.docker.com)
- [Elestio Documentation](https://docs.elest.io)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Next.js Deployment](https://nextjs.org/docs/deployment)

---

**Version:** 2.0
**Last Updated:** January 2026
**Maintainer:** KI-Schmiede
