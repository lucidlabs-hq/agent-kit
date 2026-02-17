# Port Registry

> **MANDATORY:** Every downstream project MUST use unique ports. Check this registry before starting development.

---

## Current Port Allocation

| Project | Frontend | Convex Backend | Convex Dashboard | HTTP Actions | Other |
|---------|----------|----------------|------------------|--------------|-------|
| **casavi-sandbox-seeder** | - | - | - | - | 80, 443 |
| **client-service-reporting** | - | 3212 | 6793 | 3213 | |
| **cotinga-test-suite** | - | 9990 | 9991 | 9992 | |
| **invoice-accounting-assistant** | - | 8082 | 8083 | 8084 | 5678 (n8n) |
| **neola** | - | - | - | - | 5432 (postgres) |
| **satellite** | 3000 | - | - | - | 3001, 61208 |
| **casavi-agent-suite** | 8030 | 8032 | 8033 | 8034 | |
| **immoware-agent-poc** | 8060 | 8062 | 8063 | 8064 | (reserved) |

---

## Reserved Port Ranges

| Range | Status | Notes |
|-------|--------|-------|
| 3000-3099 | ⚠️ Avoid | Standard Next.js, conflicts likely |
| 3210-3219 | ⚠️ Avoid | Standard Convex internal ports |
| 5432 | 🔒 Reserved | PostgreSQL |
| 5678 | 🔒 Reserved | n8n |
| 6379 | 🔒 Reserved | Redis |
| 8030-8039 | ✓ casavi-agent-suite | |
| 8060-8069 | ✓ immoware-agent-poc | |
| 8080-8089 | ⚠️ Avoid | Common HTTP proxy port |
| 9990-9999 | ✓ cotinga-test-suite | |

---

## How to Choose Ports for New Projects

1. **Check this registry** for existing allocations
2. **Pick a free 10-port block** in the 8xxx range (e.g., 8070-8079)
3. **Use this mapping within your block:**

| Offset | Service |
|--------|---------|
| +0 | Frontend (Next.js) |
| +1 | Mastra API |
| +2 | Convex Backend |
| +3 | Convex Dashboard |
| +4 | HTTP Actions |
| +5 | n8n (if used) |
| +6-9 | Reserved |

4. **Update this registry** and commit

---

## docker-compose.dev.yml Template

```yaml
# =============================================================================
# [PROJECT_NAME] - Local Development
# Port Block: 80X0-80X9
# =============================================================================

services:
  backend:
    image: ghcr.io/get-convex/convex-backend:latest
    container_name: [project-slug]-convex-backend
    ports:
      - "80X2:3210"   # Convex Backend API
      - "80X4:3211"   # HTTP Actions
    volumes:
      - [project-slug]-convex-data:/convex/data
    environment:
      - CONVEX_SITE_URL=http://localhost:80X0

  dashboard:
    image: ghcr.io/get-convex/convex-dashboard:latest
    container_name: [project-slug]-convex-dashboard
    ports:
      - "80X3:6791"
    environment:
      - CONVEX_BACKEND_URL=http://backend:3210
    depends_on:
      - backend

volumes:
  [project-slug]-convex-data:
```

---


## Package.json Port Coding (MANDATORY)

**Ports MUST be hardcoded in `package.json` scripts.** Never rely on framework defaults.

### Why

- Services start on the correct port immediately - no configuration guessing
- Port conflicts are visible in code review
- New developers can see all ports at a glance
- CI/CD and Docker use the same source of truth

### Frontend package.json

```json
{
  "scripts": {
    "dev": "next dev -p 8070",
    "build": "next build",
    "start": "next start -p 8070"
  }
}
```

### Mastra package.json

```json
{
  "scripts": {
    "dev": "PORT=8071 bun run --watch src/index.ts",
    "start": "PORT=8071 node dist/index.js"
  }
}
```

### docker-compose.dev.yml

```yaml
services:
  backend:
    ports:
      - "8072:3210"   # Convex Backend
      - "8074:3211"   # HTTP Actions
  dashboard:
    ports:
      - "8073:6791"   # Convex Dashboard
```

### Validation

Before starting a dev server, ALWAYS:

```bash
# 1. Check port-registry.md for your assigned range
# 2. Verify nothing is running on your ports
lsof -i:8070 -i:8071 -i:8072 -i:8073

# 3. Start services
pnpm run dev
```

---

## Production Port Allocation (LUCIDLABS-HQ)

**WICHTIG:** Production-Ports müssen AUCH registriert werden, um Caddy Reverse Proxy Konflikte zu vermeiden!

### Current Production Ports

| Project | Frontend | Convex Backend | Convex Dashboard | Caddy Domain |
|---------|----------|----------------|------------------|--------------|
| **cotinga-test-suite** | 3050 | 3214 | 6794 | cotinga-test-suite.lucidlabs.de |
| **client-service-reporting** | 3070 | 3212 | 6793 | reporting.lucidlabs.de |
| **invoice-assistant** | 3060 | 3216 | 6796 | invoice.lucidlabs.de |
| **(Template)** | 30X0 | 32X4 | 67X4 | project.lucidlabs.de |

### Production Port Ranges

| Service Type | Port Range | Notes |
|--------------|------------|-------|
| **Frontends** | 3050-3099 | Increment by 10 per project |
| **Convex Backends** | 3210-3299 | Use 3214, 3216, 3218... |
| **Convex Dashboards** | 6790-6799 | Use 6794, 6796, 6798... |
| **Mastra APIs** | 4050-4099 | If project needs Mastra |

### Registry Location

Production-Registry auf dem Server: `/opt/lucidlabs/registry.json`

```bash
# Check registry on server
ssh -p 2222 root@91.98.70.29 "cat /opt/lucidlabs/registry.json"
```

### Caddy Entry Template

```
# === [Project Name] ===
[project].lucidlabs.de {
    reverse_proxy [project]-frontend:3000

    log {
        output file /data/logs/[project].log {
            roll_size 10mb
            roll_keep 5
        }
    }
}
```

---

## Checking for Conflicts

### Local

```bash
# Show all ports in use by projects
for proj in ../projects/*; do
  if [ -f "$proj/docker-compose.dev.yml" ]; then
    echo "=== $(basename $proj) ==="
    grep -oE '"[0-9]+:' "$proj/docker-compose.dev.yml" | tr -d '":'
  fi
done

# Check what's running now
lsof -i -P | grep LISTEN | grep -E ":[0-9]{4} "
```

### Production

```bash
# Check running containers on server
ssh -p 2222 root@91.98.70.29 "docker ps --format '{{.Names}}\t{{.Ports}}'"

# Check Caddyfile
ssh -p 2222 root@91.98.70.29 "cat /opt/lucidlabs/caddy/Caddyfile"
```

---

**Last Updated:** 2026-02-09
