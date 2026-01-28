# LUCIDLABS-HQ Infrastructure

> Shared multi-project server infrastructure for Lucid Labs projects.

## Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LUCIDLABS-HQ SERVER                                 │
│                         (projects.lucidlabs.de)                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                         Caddy (Reverse Proxy)                         │ │
│  │                                                                       │ │
│  │  invoice.lucidlabs.app  →  invoice-frontend:3000                     │ │
│  │  project2.lucidlabs.app →  project2-frontend:3000                    │ │
│  │  ...                                                                  │ │
│  │                                                                       │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│  │  invoice-stack  │  │  project2-stack │  │    ...          │            │
│  │                 │  │                 │  │                 │            │
│  │  - frontend     │  │  - frontend     │  │                 │            │
│  │  - mastra       │  │  - mastra       │  │                 │            │
│  │                 │  │                 │  │                 │            │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘            │
│                                                                             │
│                          lucidlabs-network                                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Server Specs

| Property | Value |
|----------|-------|
| **Provider** | Elestio (Hetzner) |
| **Size** | MEDIUM-2C-4G-CAX |
| **Architecture** | ARM64 (Ampere Altra) |
| **OS** | Ubuntu 22.04 |
| **Cost** | ~€29/month |

## Directory Structure (on server)

```
/opt/lucidlabs/
├── caddy/
│   ├── docker-compose.yml    # Caddy + shared services
│   ├── Caddyfile             # Central routing
│   └── .env                  # Caddy environment
│
├── projects/
│   ├── invoice-accounting-assistant/
│   │   ├── docker-compose.yml
│   │   ├── .env
│   │   ├── frontend/
│   │   └── mastra/
│   └── [other-projects]/
│
├── logs/                     # Centralized logs
├── backups/                  # Backup storage
└── registry.json             # Project registry
```

## Quick Start

### 1. Initial Server Setup

```bash
# SSH into server
ssh root@projects.lucidlabs.de

# Clone this repo or copy files
git clone git@github.com:lucidlabs-hq/agent-kit.git /tmp/agent-kit

# Run setup
cd /tmp/agent-kit/infrastructure/lucidlabs-hq
chmod +x setup.sh
./setup.sh
```

### 2. Add New Project

```bash
# On the server
cd /opt/lucidlabs
./scripts/add-project.sh my-project myproject

# Follow the output instructions:
# 1. Fill in .env
# 2. Add Caddy entry
# 3. Deploy code
```

### 3. Deploy Project

```bash
# Via GitHub Actions (recommended)
# - Push to main branch
# - Actions workflow deploys automatically

# Or manually
ssh root@projects.lucidlabs.de
cd /opt/lucidlabs/projects/my-project
docker compose -p my-project up -d --build
```

## Files in This Directory

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Base Caddy setup |
| `Caddyfile` | Reverse proxy routing |
| `registry.json` | Project tracking |
| `setup.sh` | Initial server setup |
| `scripts/add-project.sh` | Add new project |
| `scripts/deploy-project.sh` | Deploy/update project |
| `templates/project-docker-compose.yml` | Project template |
| `templates/github-workflow-hq.yml` | CI/CD template |

## GitHub Secrets (Organization Level)

Set these secrets at `github.com/lucidlabs-hq` → Settings → Secrets:

| Secret | Description |
|--------|-------------|
| `LUCIDLABS_HQ_HOST` | Server IP or hostname |
| `LUCIDLABS_HQ_SSH_KEY` | SSH private key (deploy key) |

Per-project secrets:

| Secret | Description |
|--------|-------------|
| `CONVEX_DEPLOY_KEY` | Convex deployment key |
| `ANTHROPIC_API_KEY` | Anthropic API key |
| `OPENAI_API_KEY` | OpenAI API key (optional) |

## DNS Configuration

Configure at your DNS provider:

```
*.lucidlabs.app.  A  <server-ip>
```

Or individual records:

```
invoice.lucidlabs.app.  A  <server-ip>
project2.lucidlabs.app. A  <server-ip>
```

## Monitoring

Monitoring (Uptime Kuma) runs on a **separate server** to ensure alerts work even if HQ goes down.

See: `infrastructure/monitoring-satellite/` (separate setup)

The monitoring server checks:
- `https://invoice.lucidlabs.app/api/health`
- `https://<project>.lucidlabs.app/api/health`
- Server SSH connectivity

## Backup Strategy

```bash
# Daily backup script (add to cron)
#!/bin/bash
DATE=$(date +%Y%m%d)
tar -czf /opt/lucidlabs/backups/registry-$DATE.tar.gz /opt/lucidlabs/registry.json
docker exec lucidlabs-caddy tar -czf - /data > /opt/lucidlabs/backups/caddy-$DATE.tar.gz

# Keep last 7 days
find /opt/lucidlabs/backups -mtime +7 -delete
```

## Scaling

When the server needs more resources:

1. **Vertical scaling**: Upgrade to LARGE-4C-8G or XLARGE-8C-16G in Elestio
2. **Horizontal scaling**: Move high-traffic projects to dedicated servers

## Troubleshooting

### View logs

```bash
# Caddy logs
docker compose -f /opt/lucidlabs/caddy/docker-compose.yml logs -f caddy

# Project logs
docker compose -p invoice-accounting-assistant logs -f

# All containers
docker ps
docker logs <container-id>
```

### Restart services

```bash
# Restart Caddy (after Caddyfile changes)
cd /opt/lucidlabs/caddy
docker compose restart caddy

# Restart project
cd /opt/lucidlabs/projects/invoice-accounting-assistant
docker compose -p invoice-accounting-assistant restart
```

### SSL certificate issues

```bash
# Force certificate renewal
docker exec lucidlabs-caddy caddy reload --config /etc/caddy/Caddyfile
```

---

**Last Updated:** January 2026
**Maintainer:** Lucid Labs GmbH
