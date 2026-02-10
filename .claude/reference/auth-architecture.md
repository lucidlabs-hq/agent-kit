# Auth Architecture - Centralized BetterAuth for LUCIDLABS-HQ

> Centralized authentication across all `*.lucidlabs.de` projects using BetterAuth with cross-subdomain cookies.

## Overview

All LUCIDLABS-HQ projects share a single authentication database. Users log in once and access all their authorized projects without separate credentials.

```
                          ┌──────────────────────────────┐
                          │   lucidlabs-convex:3210       │
                          │   (Shared Auth Database)      │
                          │                               │
                          │  API:  convex.lucidlabs.de    │
                          │  HTTP: auth.lucidlabs.de      │
                          │                               │
                          │  Tables: user, session,       │
                          │  account, verification,       │
                          │  organization, member,        │
                          │  invitation                   │
                          └──────────┬───────────────────┘
                                     │
                Cross-subdomain cookie: .lucidlabs.de
                                     │
           ┌─────────────┬───────────┴─────────┬─────────────┐
           │             │                     │             │
      reporting.     cotinga.             invoice.       [future].
      lucidlabs.de   lucidlabs.de         lucidlabs.de   lucidlabs.de
           │             │                     │             │
      Own Convex     Own Convex            Own Convex     Own Convex
      (3212)         (3214)                (3216)         (...)
      Project Data   Project Data          Project Data   Project Data
```

## Key Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Auth database | Shared `lucidlabs-convex:3210` | SSO across projects |
| Login method | Magic Link | Admin-controlled access |
| Self-signup | Disabled | Admin creates accounts |
| Login UX | Embedded per project | No separate auth domain |
| Org model | BetterAuth Organizations = Clients | Reuse existing concept |
| Cookie scope | `.lucidlabs.de` | Cross-subdomain SSO |

## Infrastructure: Two Ports, Two Domains

The shared Convex instance exposes **two ports** with distinct purposes:

| Port | Domain | Purpose |
|------|--------|---------|
| **3210** | `convex.lucidlabs.de` | Convex API (queries, mutations, deploy) |
| **3211** | `auth.lucidlabs.de` | Convex HTTP Actions (BetterAuth endpoints) |

**Caddy entries:**
```
convex.lucidlabs.de → lucidlabs-convex:3210   (API)
auth.lucidlabs.de   → lucidlabs-convex:3211   (HTTP Actions)
```

**Why two domains?** Convex serves API (client connections, deploys) on port 3210 and HTTP actions (custom HTTP routes registered in `http.ts`) on port 3211. BetterAuth auth endpoints (`/api/auth/*`) are Convex HTTP actions, so they need port 3211.

## Dual Convex Connection

Each project connects to TWO Convex instances:

```typescript
// Project data (project-specific Convex)
const projectConvex = new ConvexReactClient(
  process.env.NEXT_PUBLIC_CONVEX_URL!  // e.g., https://csr-convex.lucidlabs.de
);

// Auth data (shared Convex)
const authConvex = new ConvexReactClient(
  process.env.NEXT_PUBLIC_AUTH_CONVEX_URL!  // https://convex.lucidlabs.de
);
```

## Environment Variables

### Server-side (runtime, NOT build args)

```env
# Auth Convex API (port 3210) — for Convex client operations
AUTH_CONVEX_URL=https://convex.lucidlabs.de

# Auth HTTP Actions (port 3211) — for BetterAuth endpoint proxying
AUTH_CONVEX_SITE_URL=https://auth.lucidlabs.de

# Shared secret (must match across all projects)
BETTER_AUTH_SECRET=<shared-secret>

# Enable/disable auth (runtime check)
NEXT_PUBLIC_AUTH_ENABLED=true
```

### Client-side (build-time, NEXT_PUBLIC_)

```env
# Auth Convex URL for React client
NEXT_PUBLIC_AUTH_CONVEX_URL=https://convex.lucidlabs.de

# Convex site URL for client auth config
NEXT_PUBLIC_CONVEX_SITE_URL=https://auth.lucidlabs.de

# App URL for redirects
NEXT_PUBLIC_APP_URL=https://<subdomain>.lucidlabs.de

# Project-specific Convex
NEXT_PUBLIC_CONVEX_URL=https://<abbr>-convex.lucidlabs.de
```

### Shared Convex env vars (set via `npx convex env set`)

```env
BETTER_AUTH_SECRET=<shared-secret>
SITE_URL=https://auth.lucidlabs.de
RESEND_API_KEY=<resend-api-key>
```

**IMPORTANT:** `AUTH_CONVEX_URL` and `AUTH_CONVEX_SITE_URL` are **server-only** env vars. They must NOT be `NEXT_PUBLIC_*` prefixed, must NOT be Docker build args, and must be read at **runtime** (not module scope). See "Docker Standalone Deployment" below.

## Docker Standalone Deployment

### The Build-Time Baking Problem

Next.js standalone builds bake module-scope `process.env` reads into compiled chunks. During `docker build`, server-only env vars (like `AUTH_CONVEX_URL`) are absent, causing auth to permanently resolve as "not configured".

### Required Pattern: Lazy Init

```typescript
// ❌ WRONG — baked at build time as undefined
const authUrl = process.env.AUTH_CONVEX_URL;
const authUtils = createAuth();

// ✅ CORRECT — read at request time
let cached: AuthUtils | null = null;
function getAuth(): AuthUtils | null {
  if (cached) return cached;
  const url = process.env.AUTH_CONVEX_URL;       // runtime read
  const siteUrl = process.env.AUTH_CONVEX_SITE_URL; // runtime read
  if (!url || !siteUrl) return null;
  cached = initAuth(url, siteUrl);
  return cached;
}
```

### Required: outputFileTracingIncludes

The `require("@convex-dev/better-auth/nextjs")` is inside a conditional branch that never executes during build. Next.js file tracer (`@vercel/nft`) doesn't detect it, so the module is excluded from `.next/standalone/`. Fix in `next.config.ts`:

```typescript
outputFileTracingIncludes: {
  "/api/*": [
    "./node_modules/@convex-dev/better-auth/**/*",
    "./node_modules/better-auth/**/*",
  ],
},
```

### Required: force-dynamic

Add to `app/api/auth/[...all]/route.ts`:
```typescript
export const dynamic = "force-dynamic";
```

## File Structure

```
frontend/
├── lib/
│   ├── auth-server.ts      # Server-side auth (lazy-init pattern)
│   ├── auth-client.ts      # Client-side auth (createAuthClient)
│   ├── auth-helpers.ts     # Middleware session validation
│   └── convex.ts           # Dual Convex clients (project + auth)
├── middleware.ts            # Route protection
├── next.config.ts           # outputFileTracingIncludes for better-auth
├── app/
│   ├── login/page.tsx      # Magic Link login page
│   ├── admin/page.tsx      # User/org management (admin only)
│   └── api/auth/[...all]/  # BetterAuth catch-all route (force-dynamic)
└── components/
    ├── auth/
    │   ├── login-form.tsx   # Magic Link form
    │   ├── user-menu.tsx    # Avatar + logout dropdown
    │   └── require-auth.tsx # Client-side auth gate
    └── providers/
        └── ConvexClientProvider.tsx  # Dual provider wrapper

convex-auth/                    # Shared auth Convex project (gitignored)
├── convex/
│   ├── http.ts             # HTTP router (registers auth routes)
│   ├── auth.config.ts      # CustomJWT config for Convex auth
│   ├── convex.config.ts    # Component config
│   └── betterAuth/
│       ├── auth.ts         # BetterAuth config + Resend email
│       ├── schema.ts       # Auto-generated BetterAuth schema
│       └── adapter.ts      # Convex adapter
├── schema.ts               # Root schema (reference)
└── package.json            # Dependencies
```

## Deploying Auth Functions

Auth functions must be deployed to the **shared Convex** (not project-specific):

```bash
cd convex-auth

# Generate admin key
ssh -p 2222 lucidlabs-hq 'sudo docker exec lucidlabs-convex /convex/generate_admin_key.sh' | tail -1

# Deploy
npx convex deploy \
  --url https://convex.lucidlabs.de \
  --admin-key "<generated-admin-key>" \
  --yes

# Set env vars (one-time)
npx convex env set BETTER_AUTH_SECRET "<secret>" \
  --url https://convex.lucidlabs.de --admin-key "<key>"
npx convex env set SITE_URL "https://auth.lucidlabs.de" \
  --url https://convex.lucidlabs.de --admin-key "<key>"
npx convex env set RESEND_API_KEY "<resend-key>" \
  --url https://convex.lucidlabs.de --admin-key "<key>"
```

## Email Delivery (Resend)

Magic link emails are sent via Resend HTTP API from the Convex HTTP action.

| Setting | Value |
|---------|-------|
| **Provider** | Resend |
| **From** | `onboarding@resend.dev` (temporary) |
| **Final from** | `noreply@lucidlabs.de` (requires domain verification) |

**TODO:** Verify `lucidlabs.de` domain in Resend dashboard (https://resend.com/domains). Add SPF and DKIM DNS records, then update `from` in `convex-auth/convex/betterAuth/auth.ts`.

## Roles & Permissions

| Role | Access | Created By |
|------|--------|------------|
| **admin** | All projects, user management, full CRUD | System seed |
| **team** | Assigned projects, extended features | Admin |
| **customer** | Own org's projects, view + comment only | Admin via Magic Link |

## Initial Admin User

| Field | Value |
|-------|-------|
| **Email** | adam.kassama@lucidlabs.de |
| **Name** | Adam Kassama |
| **Role** | admin (full access) |

## Auth Flow

### Magic Link Login
1. User visits `reporting.lucidlabs.de/dashboard`
2. Middleware checks session cookie → no session → redirect to `/login`
3. User enters email → frontend calls `/api/auth/sign-in/magic-link`
4. Next.js handler proxies to `auth.lucidlabs.de/api/auth/sign-in/magic-link`
5. Convex HTTP action creates verification token, sends email via Resend
6. User clicks link → token verified → session created
7. Cookie set on `.lucidlabs.de` → user redirected to dashboard
8. User can now access `cotinga.lucidlabs.de` without logging in again

### Cross-Subdomain SSO
- Session cookie: `better-auth.session_token`
- Domain: `.lucidlabs.de`
- Secure: `true`
- SameSite: `lax`

## Development

When `NEXT_PUBLIC_AUTH_ENABLED=false`:
- Middleware passes all requests through
- No auth checks on any route
- ConvexClientProvider uses project-only connection
- Good for offline/local development

When `NEXT_PUBLIC_AUTH_ENABLED=true`:
- Middleware redirects unauthenticated users to `/login`
- `/api/auth/*` and `/login` are public paths (no auth check)
- Requires `AUTH_CONVEX_URL` and `AUTH_CONVEX_SITE_URL` in `.env.local`

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `better-auth` | 1.4.9 | Auth framework |
| `@convex-dev/better-auth` | latest | Convex integration |

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| 503 "Auth not configured" | Env vars read at build time | Use lazy-init pattern (see above) |
| 404 on `/api/auth/*` | Missing `outputFileTracingIncludes` | Add to `next.config.ts` (see above) |
| 404 from auth.lucidlabs.de | Auth functions not deployed | Deploy `convex-auth/` to shared Convex |
| 500 on magic link | Resend domain not verified | Use `onboarding@resend.dev` or verify domain |
| No login redirect | `NEXT_PUBLIC_AUTH_ENABLED=false` | Set to `true` and restart dev server |

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Shared Convex SPOF | Persistent volume, include in backup strategy |
| Cookie scope too wide | `.lucidlabs.de` only, `secure: true`, `sameSite: lax` |
| Dual connections complexity | Abstracted in `lib/convex.ts`, clear naming |
| Build-time env baking | Lazy-init + `outputFileTracingIncludes` + `force-dynamic` |
