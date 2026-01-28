# Scaling Guide

> Scaling considerations, stateless patterns, and production-ready architecture.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Stateless Containers](#2-stateless-containers)
3. [Convex for State](#3-convex-for-state)
4. [Static Assets](#4-static-assets)
5. [Load Balancing](#5-load-balancing)
6. [Monitoring](#6-monitoring)
7. [Best Practices](#7-best-practices)

---

## 1. Overview

**Principle:** Containers must be stateless - no local file storage, no in-memory state between requests.

### Horizontal Scaling

```
                    Load Balancer (Caddy)
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    Container 1     Container 2     Container N
         │               │               │
         └───────────────┴───────────────┘
                         │
                       Convex
                  (shared state)
```

### Requirements for Scaling

- ✅ Stateless containers
- ✅ Shared state in Convex (reactive, real-time)
- ✅ Shared cache in Convex
- ✅ Sessions handled by Convex Auth
- ✅ Health checks
- ✅ No local file storage

---

## 2. Stateless Containers

### No Local File Storage

```typescript
// ❌ Bad: Local file storage
import fs from 'fs'

export async function saveFile(file: File) {
  await fs.promises.writeFile(`/tmp/${file.name}`, file)
  // Files lost when container restarts
}

// ✅ Good: Convex file storage
import { useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';

const generateUploadUrl = useMutation(api.files.generateUploadUrl);

export async function saveFile(file: File) {
  const uploadUrl = await generateUploadUrl();
  await fetch(uploadUrl, {
    method: 'POST',
    body: file,
  });
}
```

### No In-Memory State

```typescript
// ❌ Bad: In-memory state
const cache = new Map()

export function getCached(key: string) {
  return cache.get(key)
  // Lost when container restarts
}

// ✅ Good: Convex for shared state
import { useQuery } from 'convex/react';
import { api } from '@/convex/_generated/api';

export function useCachedData(key: string) {
  // Convex handles caching and real-time updates
  return useQuery(api.cache.get, { key });
}
```

### No Local Sessions

```typescript
// ❌ Bad: Local session storage
const sessions = new Map()

export function getSession(id: string) {
  return sessions.get(id)
  // Lost when container restarts
}

// ✅ Good: Better Auth + Convex handles sessions
import { authClient } from '@/lib/auth-client';

export function useSession() {
  const { data: session, isPending } = authClient.useSession();
  // Session stored in Convex, shared across all containers
  return { session, isPending };
}
```

---

## 3. Convex for State

### Why Convex for Scaling

| Feature | Benefit |
|---------|---------|
| **Managed service** | No infrastructure to manage |
| **Real-time sync** | Automatic updates across containers |
| **Built-in auth** | Sessions handled automatically |
| **File storage** | No S3 setup needed |
| **Vector search** | Built-in for RAG |
| **Transactional** | ACID guarantees |

### Session Storage (Better Auth + Convex)

Better Auth with Convex adapter stores sessions in Convex tables, providing:
- Automatic scaling across containers
- Real-time session sync
- Type-safe session data

```typescript
// lib/auth-client.ts
import { createAuthClient } from 'better-auth/react';

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL,
});

// Frontend: Check authentication
function ProtectedPage() {
  const { data: session, isPending } = authClient.useSession();

  if (isPending) return <Loading />;
  if (!session) return <Redirect to="/login" />;

  return <ProtectedContent />;
}
```

### Cache Pattern with Convex

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from 'convex/server';
import { v } from 'convex/values';

export default defineSchema({
  cache: defineTable({
    key: v.string(),
    value: v.any(),
    expiresAt: v.number(),
  }).index('by_key', ['key']),
});

// convex/functions/cache.ts
import { query, mutation } from './_generated/server';
import { v } from 'convex/values';

export const get = query({
  args: { key: v.string() },
  handler: async (ctx, args) => {
    const cached = await ctx.db
      .query('cache')
      .withIndex('by_key', (q) => q.eq('key', args.key))
      .first();

    if (!cached) return null;
    if (cached.expiresAt < Date.now()) {
      // Expired - will be cleaned up by scheduled function
      return null;
    }

    return cached.value;
  },
});

export const set = mutation({
  args: {
    key: v.string(),
    value: v.any(),
    ttlSeconds: v.number(),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query('cache')
      .withIndex('by_key', (q) => q.eq('key', args.key))
      .first();

    const data = {
      key: args.key,
      value: args.value,
      expiresAt: Date.now() + args.ttlSeconds * 1000,
    };

    if (existing) {
      await ctx.db.patch(existing._id, data);
    } else {
      await ctx.db.insert('cache', data);
    }
  },
});
```

---

## 4. Static Assets

### CDN (Recommended)

```typescript
// next.config.ts
const nextConfig = {
  assetPrefix: process.env.CDN_URL || '',
  images: {
    domains: ['cdn.example.com'],
  }
}
```

### Convex File Storage

For user uploads, use Convex File Storage:

```typescript
// convex/functions/files.ts
import { mutation, query } from './_generated/server';

export const generateUploadUrl = mutation({
  handler: async (ctx) => {
    return await ctx.storage.generateUploadUrl();
  },
});

export const getFileUrl = query({
  args: { storageId: v.id('_storage') },
  handler: async (ctx, args) => {
    return await ctx.storage.getUrl(args.storageId);
  },
});
```

---

## 5. Load Balancing

### Elestio Load Balancing

Elestio handles load balancing automatically for multiple containers.

**Requirements:**
- Stateless containers
- Shared state in Convex
- Health checks implemented

### Health Checks

```typescript
// app/api/health/route.ts
export async function GET() {
  const checks = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    services: {
      convex: await checkConvex(),
      mastra: await checkMastra(),
    }
  }

  const healthy = Object.values(checks.services).every(s => s === 'ok');

  return Response.json(checks, {
    status: healthy ? 200 : 503
  })
}

async function checkConvex(): Promise<'ok' | 'error'> {
  try {
    // Simple query to verify Convex connection
    const response = await fetch(process.env.NEXT_PUBLIC_CONVEX_URL!);
    return response.ok ? 'ok' : 'error';
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

## 6. Monitoring

### Monitoring Strategy

**Phase 1 (Current):**
- Uptime Kuma for health monitoring and alerting
- Structured logging to stdout
- Convex Dashboard for database metrics

**Phase 2 (Optional later):**
- Sentry for error tracking
- LogTail for log aggregation

### Uptime Kuma

Simple, self-hosted uptime monitoring:

```yaml
# Can run alongside project stack or separately
uptime-kuma:
  image: louislam/uptime-kuma:1
  volumes:
    - uptime-kuma-data:/app/data
  ports:
    - "3001:3001"
  restart: unless-stopped
```

**Configure monitors for:**
- `/api/health` - Main application health
- `/api/ready` - Readiness check
- Mastra `/health` - AI agent service

### Key Metrics to Track

| Metric | Source | Purpose |
|--------|--------|---------|
| Uptime | Uptime Kuma | Service availability |
| Response time | Uptime Kuma | Performance baseline |
| Query performance | Convex Dashboard | Database health |
| Function execution | Convex Dashboard | Backend performance |

### Structured Logging

```typescript
// Always use structured logging for scaling
console.log(JSON.stringify({
  level: 'info',
  component: 'API',
  message: 'Request handled',
  duration: 45,
  containerId: process.env.HOSTNAME,
  timestamp: new Date().toISOString()
}))
```

### Convex Dashboard

Use the Convex Dashboard for:
- Query performance monitoring
- Function execution logs
- Database usage metrics
- Real-time debugging

---

## 7. Best Practices

### Summary

| Category | DO | DON'T |
|----------|-------|---------|
| **State** | Convex for all shared state | In-memory state |
| **Files** | Convex File Storage | Local filesystem |
| **Sessions** | Better Auth + Convex | Local session storage |
| **Cache** | Convex tables | In-memory cache |
| **Assets** | CDN for static files | Serve from container |

### Scaling Checklist

Before scaling to multiple containers:

- [ ] No local file storage?
- [ ] No in-memory state?
- [ ] Sessions via Better Auth + Convex?
- [ ] Cache in Convex tables?
- [ ] Health check implemented?
- [ ] Structured logging?
- [ ] CDN for static assets?

### Troubleshooting

**Issue: Session lost between requests**
- Ensure using Convex Auth (not local sessions)
- Check Convex connection URL is correct
- Verify `ConvexProvider` wraps app

**Issue: State not syncing**
- Use `useQuery` for reactive data
- Ensure mutations are awaited
- Check Convex Dashboard for errors

**Issue: Files not persisting**
- Use Convex File Storage, not local fs
- Verify storage ID is saved correctly
- Check file size limits

---

## Convex Scaling Benefits

Convex simplifies scaling because:

1. **No database infrastructure** - Convex is fully managed
2. **No session infrastructure** - Convex Auth handles it
3. **No cache infrastructure** - Use Convex tables
4. **No file storage setup** - Built-in file storage
5. **Real-time by default** - All queries are reactive

This means your containers can be truly stateless, making horizontal scaling trivial.

---

## Related References

- `architecture.md` - Platform architecture
- `deployment-best-practices.md` - Docker & Elestio
- `convex/README.md` - Convex setup

---

**Version:** 2.0
**Last Updated:** January 2026
**Maintainer:** Lucid Labs GmbH
