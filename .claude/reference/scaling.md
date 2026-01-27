# Scaling Guide

> Scaling considerations, stateless patterns, and production-ready architecture.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Stateless Containers](#2-stateless-containers)
3. [Session Storage](#3-session-storage)
4. [Caching Strategy](#4-caching-strategy)
5. [Database Connections](#5-database-connections)
6. [Static Assets](#6-static-assets)
7. [Load Balancing](#7-load-balancing)
8. [Monitoring](#8-monitoring)
9. [Best Practices](#9-best-practices)

---

## 1. Overview

**Principle:** Containers must be stateless - no local file storage, no in-memory state between requests.

### Horizontal Scaling

```
                    Load Balancer
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    Container 1     Container 2     Container N
         │               │               │
         └───────────────┴───────────────┘
                         │
                    PostgreSQL
                  (shared state)
```

### Requirements for Scaling

- ✅ Stateless containers
- ✅ Shared session storage (PostgreSQL)
- ✅ Shared cache (PostgreSQL)
- ✅ Connection pooling
- ✅ Health checks

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

// ✅ Good: Object storage (S3/MinIO)
export async function saveFile(file: File) {
  await s3.putObject({
    Bucket: 'files',
    Key: file.name,
    Body: file
  })
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

// ✅ Good: PostgreSQL cache (table-based)
export async function getCached(key: string) {
  return await db.select().from(cache).where(eq(cache.key, key))
  // Persistent across containers
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

// ✅ Good: PostgreSQL sessions (via BetterAuth)
export async function getSession(id: string) {
  return await db.select().from(sessions).where(eq(sessions.id, id))
  // Shared across containers
}
```

---

## 3. Session Storage

### PostgreSQL Sessions (BetterAuth)

**PostgreSQL-First Strategy:** Sessions stored in PostgreSQL via BetterAuth.

```typescript
// BetterAuth handles sessions automatically
import { auth } from '@/lib/auth'

const session = await auth.api.getSession({
  headers: await import('next/headers').then(m => m.headers()),
})
```

**Benefits:**
- ✅ Persistent across container restarts
- ✅ Shared across multiple containers
- ✅ No Redis dependency
- ✅ Single database backup

### Session Table (BetterAuth)

```typescript
// Created automatically by BetterAuth
export const sessions = pgTable('sessions', {
  id: text('id').primaryKey(),
  userId: text('user_id').notNull(),
  expiresAt: timestamp('expires_at').notNull(),
  token: text('token').notNull(),
})
```

---

## 4. Caching Strategy

### PostgreSQL Cache (Table-Based)

**PostgreSQL-First Strategy:** Use PostgreSQL tables for caching.

```typescript
// db/schema/cache.ts
export const cache = pgTable('cache', {
  key: text('key').primaryKey(),
  value: jsonb('value').notNull(),
  expiresAt: timestamp('expires_at').notNull(),
  createdAt: timestamp('created_at').defaultNow(),
})
```

### Cache Implementation

```typescript
// lib/cache.ts
export async function getCached<T>(
  key: string,
  fetcher: () => Promise<T>,
  ttl: number = 3600
): Promise<T> {
  // Check cache
  const cached = await db
    .select()
    .from(cache)
    .where(sql`key = ${key} AND expires_at > NOW()`)
    .limit(1)

  if (cached.length > 0) {
    return cached[0].value as T
  }

  // Fetch and cache
  const data = await fetcher()
  const expiresAt = new Date(Date.now() + ttl * 1000)

  await db.insert(cache).values({
    key,
    value: data as any,
    expiresAt,
  }).onConflictDoUpdate({
    target: cache.key,
    set: { value: data as any, expiresAt },
  })

  return data
}

// Cleanup expired entries
export async function cleanupCache() {
  await db.delete(cache).where(sql`expires_at < NOW()`)
}
```

### Next.js Caching

```typescript
// Use Next.js built-in caching
export const revalidate = 60 // Revalidate every 60 seconds

export default async function Page() {
  const data = await fetchData() // Cached by Next.js
  return <Component data={data} />
}
```

---

## 5. Database Connections

### Connection Pooling

```typescript
// lib/db.ts
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'

const client = postgres(process.env.DATABASE_URL!, {
  max: 20, // Max connections per container
  idle_timeout: 30,
  connect_timeout: 10,
})

export const db = drizzle(client)
```

### Connection Limits

| Scenario | Max Connections |
|----------|-----------------|
| Single container | 20 |
| 3 containers | 60 (20 × 3) |
| PostgreSQL default | 100 |

**Configure PostgreSQL:**

```sql
-- Increase max connections if needed
ALTER SYSTEM SET max_connections = 200;
```

### Error Handling

```typescript
try {
  const result = await db.select().from(resources)
  return result
} catch (error) {
  if (error.code === 'ECONNREFUSED') {
    console.error('[Database] Connection refused')
  }
  throw error
}
```

---

## 6. Static Assets

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

### Object Storage (S3/MinIO)

```typescript
// lib/storage.ts
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3'

const s3 = new S3Client({
  endpoint: process.env.S3_ENDPOINT,
  credentials: {
    accessKeyId: process.env.S3_ACCESS_KEY!,
    secretAccessKey: process.env.S3_SECRET_KEY!,
  }
})

export async function uploadFile(file: File, key: string) {
  await s3.send(new PutObjectCommand({
    Bucket: process.env.S3_BUCKET!,
    Key: key,
    Body: file,
    ContentType: file.type
  }))

  return `${process.env.CDN_URL}/${key}`
}
```

---

## 7. Load Balancing

### Elestio Load Balancing

Elestio handles load balancing automatically for multiple containers.

**Requirements:**
- Stateless containers
- Shared session storage (PostgreSQL)
- Health checks implemented

### Health Checks

```typescript
// app/api/health/route.ts
export async function GET() {
  const checks = {
    database: await checkDatabase(),
    cache: await checkPostgresCache(),
    timestamp: new Date().toISOString()
  }

  const healthy = checks.database && checks.cache

  return Response.json(checks, {
    status: healthy ? 200 : 503
  })
}

async function checkDatabase(): Promise<boolean> {
  try {
    await db.execute(sql`SELECT 1`)
    return true
  } catch {
    return false
  }
}

async function checkPostgresCache(): Promise<boolean> {
  try {
    await db.select().from(cache).limit(1)
    return true
  } catch {
    return false
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

## 8. Monitoring

### Application Metrics

Track these metrics:
- Request rate (requests/second)
- Response time (p50, p95, p99)
- Error rate (errors/second)
- Database query time
- Cache hit rate
- Active connections

### Prometheus Metrics (Optional)

```typescript
// app/api/metrics/route.ts
export async function GET() {
  const metrics = `
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",status="200"} ${requestCount}

# HELP http_request_duration_seconds Request duration
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds{method="GET",le="0.1"} ${fastRequests}
http_request_duration_seconds{method="GET",le="0.5"} ${mediumRequests}
  `.trim()

  return new Response(metrics, {
    headers: { 'Content-Type': 'text/plain' }
  })
}
```

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

---

## 9. Best Practices

### Summary

| Category | DO | DON'T |
|----------|-------|---------|
| **State** | PostgreSQL for sessions/cache | In-memory state |
| **Files** | S3/MinIO for uploads | Local filesystem |
| **Sessions** | BetterAuth + PostgreSQL | Local session storage |
| **Cache** | PostgreSQL tables | In-memory cache |
| **Connections** | Connection pooling (max 20) | Unlimited connections |
| **Assets** | CDN for static files | Serve from container |

### Scaling Checklist

Before scaling to multiple containers:

- [ ] No local file storage?
- [ ] No in-memory state?
- [ ] Sessions in PostgreSQL (BetterAuth)?
- [ ] Cache in PostgreSQL?
- [ ] Connection pooling configured?
- [ ] Health check implemented?
- [ ] Structured logging?
- [ ] CDN for static assets?

### Troubleshooting

**Issue: Session lost between requests**
- Ensure BetterAuth is using PostgreSQL adapter
- Check session table exists
- Verify DATABASE_URL is correct

**Issue: Database connection errors**
- Check connection pool size (max 20)
- Verify PostgreSQL max_connections
- Use connection pooling (PgBouncer) if needed

**Issue: Cache inconsistency**
- Ensure using PostgreSQL cache, not in-memory
- Check cache TTL settings
- Implement cache invalidation

---

## Related References

- `database-strategy.md` - PostgreSQL-first strategy
- `deployment-best-practices.md` - Docker & Elestio
- `auth-setup.md` - BetterAuth configuration

---

**Version:** 1.0
**Last Updated:** January 2026
**Maintainer:** KI-Schmiede
