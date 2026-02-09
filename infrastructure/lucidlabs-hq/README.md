# LUCIDLABS-HQ Infrastructure

> Shared multi-project server infrastructure for Lucid Labs projects.

## Quick Start: Deploy a New Project

```bash
# One command from your local machine:
./scripts/deploy-project.sh \
  --name "my-project" \
  --abbreviation "mp" \
  --subdomain "myproject" \
  --has-convex
```

This single command handles: GitHub repo creation, server provisioning, port allocation, Caddyfile update, code sync, Convex startup, frontend build, and health check.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LUCIDLABS-HQ SERVER                                 │
│                         (projects.lucidlabs.de)                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                         Caddy (Reverse Proxy)                         │ │
│  │                         Auto-SSL via Let's Encrypt                    │ │
│  │                                                                       │ │
│  │  cotinga.lucidlabs.de    →  cts-frontend:3000                        │ │
│  │  reporting.lucidlabs.de  →  csr-frontend:3000                        │ │
│  │  invoice.lucidlabs.de    →  iaa-frontend:3000                        │ │
│  │  *-convex.lucidlabs.de   →  *-convex-backend:3210                    │ │
│  │                                                                       │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│  │  cotinga-stack  │  │   csr-stack     │  │   iaa-stack     │            │
│  │                 │  │                 │  │                 │            │
│  │  - frontend     │  │  - frontend     │  │  - frontend     │            │
│  │  - convex       │  │  - convex       │  │  - convex       │            │
│  │                 │  │                 │  │  - mastra       │            │
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
| **SSH Port** | 2222 |
| **Cost** | ~EUR29/month |

---

## Port Allocation

Ports are auto-allocated by `add-project.sh`. Each project gets a block:

| Service | Range | Step | Description |
|---------|-------|------|-------------|
| Frontend | 3050-3099 | +10 | Next.js app, maps to internal :3000 |
| Convex Backend | 3210-3299 | +2 | Convex API, maps to internal :3210 |
| Convex Dashboard | 6790-6899 | +2 | Convex UI, maps to internal :6791 |
| Mastra | 4050-4099 | +10 | AI agent API, maps to internal :4000 |

### Current Allocations

| Project | Abbr | Frontend | Convex BE | Convex Dash | Mastra | Status |
|---------|------|----------|-----------|-------------|--------|--------|
| cotinga-test-suite | cts | 3050 | 3214 | 6794 | - | deployed |
| invoice-accounting | iaa | 3060 | 3216 | 6796 | 4050 | pending |
| client-service-reporting | csr | 3070 | 3212 | 6793 | - | deployed |

---

## Deployment Scripts

### `add-project.sh` (Server-Side)

Runs on LUCIDLABS-HQ with sudo. Automates server provisioning:

```bash
sudo /opt/lucidlabs/scripts/add-project.sh \
  --name "my-project" \
  --abbreviation "mp" \
  --subdomain "myproject" \
  --has-convex \
  --has-mastra
```

**What it does:**
1. Creates project folder at `/opt/lucidlabs/projects/<name>/`
2. Auto-allocates ports from registry.json
3. Generates `.env` with Convex URL
4. Backups Caddyfile, appends routing entries
5. Validates Caddyfile with `caddy validate`, rollback on failure
6. Reloads Caddy (SSL auto-provisioned)
7. Generates `docker-compose.convex.yml`
8. Updates registry.json

**Flags:**
- `--dry-run` - Preview changes without applying
- `--has-convex` - Include Convex database instance
- `--has-mastra` - Include Mastra AI agent routing

**Idempotent:** Safe to re-run. Skips existing entries.

### `deploy-project.sh` (Local)

Runs from developer machine. End-to-end orchestration:

```bash
./scripts/deploy-project.sh \
  --name "my-project" \
  --abbreviation "mp" \
  --subdomain "myproject" \
  --has-convex
```

**10-step flow:**

| Step | Action |
|------|--------|
| 1 | Verify SSH to server |
| 2 | Verify `gh` CLI authenticated |
| 3 | Create GitHub repo (if not exists) |
| 4 | Set GitHub secrets |
| 5 | Push code to GitHub |
| 6 | Sync `add-project.sh` to server |
| 7 | Run `add-project.sh` remotely |
| 8 | Rsync project code to server |
| 9 | Start Convex + build frontend |
| 10 | Health check on HTTPS URL |

**Flags:**
- `--skip-github` - Skip GitHub steps (repo already exists)
- `--skip-provision` - Skip server provisioning (already provisioned)
- `--dry-run` - Preview without changes

---

## Directory Structure (on server)

```
/opt/lucidlabs/
├── caddy/
│   ├── docker-compose.yml    # Caddy + shared services
│   ├── Caddyfile             # Central routing
│   └── .env                  # Caddy environment
│
├── projects/
│   ├── cotinga-test-suite/
│   │   ├── docker-compose.yml
│   │   ├── docker-compose.convex.yml
│   │   ├── .env
│   │   └── frontend/
│   ├── client-service-reporting/
│   │   ├── docker-compose.yml
│   │   ├── docker-compose.convex.yml
│   │   ├── .env
│   │   └── frontend/
│   └── [other-projects]/
│
├── scripts/
│   └── add-project.sh        # Server provisioning
│
├── logs/                     # Centralized logs
├── backups/                  # Backup storage
└── registry.json             # Project registry (source of truth)
```

---

## SSH Configuration

### Developer Machine (`~/.ssh/config`)

```
Host lucidlabs-hq
  HostName <server-ip>
  User nightwing
  Port 2222
  IdentityFile ~/.ssh/lucidlabs-hq

Host lucidlabs-hq-root
  HostName <server-ip>
  User root
  Port 2222
  IdentityFile ~/.ssh/lucidlabs-hq
```

### Sudoers (One-Time Setup)

For non-interactive deployment via SSH:

```bash
ssh lucidlabs-hq
echo 'nightwing ALL=(ALL) NOPASSWD: /opt/lucidlabs/scripts/*.sh, /usr/bin/docker, /usr/bin/docker compose' | sudo tee /etc/sudoers.d/lucidlabs-deploy
sudo chmod 440 /etc/sudoers.d/lucidlabs-deploy
sudo visudo -c  # validate syntax
```

---

## Elestio Setup (First-Time Only)

### Phase 1: Provision Server

1. Elestio Dashboard -> Deploy New Service -> Docker Compose
2. Provider: Hetzner Cloud, Region: Falkenstein
3. Server: MEDIUM-2C-4G-CAX (Ampere ARM64)
4. Pipeline Name: `lucidlabs-hq`
5. Paste `docker-compose.bootstrap.yml`
6. Create Service (~5 min)

### Phase 2: Configure Server

```bash
# Via Elestio Web-Terminal
git clone https://github.com/lucidlabs-hq/agent-kit.git /tmp/agent-kit
cd /tmp/agent-kit/infrastructure/lucidlabs-hq
chmod +x setup.sh scripts/*.sh
./setup.sh

# Remove Elestio nginx (occupies port 80)
docker stop elestio-nginx && docker rm elestio-nginx

# Start Caddy
cd /opt/lucidlabs/caddy && docker compose up -d
curl http://localhost/health  # Should show "OK"
```

### Phase 3: DNS

```
*.lucidlabs.de.  A  <server-ip>
```

### Phase 4: Deploy First Project

```bash
./scripts/deploy-project.sh --name my-first-project --abbreviation mfp --subdomain myproject --has-convex
```

---

## Files in This Directory

| File | Purpose |
|------|---------|
| `docker-compose.bootstrap.yml` | Elestio initial setup |
| `docker-compose.yml` | Full Caddy setup (after setup.sh) |
| `Caddyfile` | Reverse proxy routing (template) |
| `registry.json` | Project registry (ports, URLs, status) |
| `setup.sh` | Initial server setup |
| `scripts/add-project.sh` | Automated server provisioning |
| `templates/project-docker-compose.yml` | Project template |
| `templates/github-workflow-hq.yml` | CI/CD template |

## GitHub Secrets

Organization-level (`github.com/lucidlabs-hq`):

| Secret | Description |
|--------|-------------|
| `LUCIDLABS_HQ_HOST` | Server IP or hostname |
| `LUCIDLABS_HQ_SSH_KEY` | SSH private key |

Per-project:

| Secret | Description |
|--------|-------------|
| `NEXT_PUBLIC_CONVEX_URL` | Convex URL for this project |
| `LINEAR_API_KEY` | Linear API key (if needed) |
| `ANTHROPIC_API_KEY` | Anthropic API key (if needed) |

---

## Monitoring

Monitoring (Uptime Kuma) runs on a **separate server** for independence.

See: `infrastructure/monitoring-satellite/`

Monitored endpoints per project:
- `https://<subdomain>.lucidlabs.de`
- `https://<abbr>-convex.lucidlabs.de/version`

---

## Troubleshooting

### SSH connection refused

```bash
# HQ uses port 2222, not 22
ssh -p 2222 nightwing@<server-ip>
```

### Container not starting

```bash
ssh lucidlabs-hq "docker logs <container-name> --tail 50"
ssh lucidlabs-hq "docker compose -p <project-name> ps"
```

### Caddyfile syntax error

```bash
# add-project.sh creates backups automatically
ssh lucidlabs-hq "ls /opt/lucidlabs/caddy/Caddyfile.bak.*"
# Restore: sudo cp Caddyfile.bak.<timestamp> Caddyfile
```

### SSL certificate issues

```bash
ssh lucidlabs-hq "docker exec lucidlabs-caddy caddy reload --config /etc/caddy/Caddyfile"
# Check: dig <subdomain>.lucidlabs.de (must point to server IP)
```

### Port conflict

```bash
ssh lucidlabs-hq "ss -tlnp | grep <port>"
# Check registry.json for allocated ports
ssh lucidlabs-hq "cat /opt/lucidlabs/registry.json | jq '.projects[].ports'"
```

---

## Backup Strategy

```bash
# Daily backup (add to cron)
DATE=$(date +%Y%m%d)
tar -czf /opt/lucidlabs/backups/registry-$DATE.tar.gz /opt/lucidlabs/registry.json
docker exec lucidlabs-caddy tar -czf - /data > /opt/lucidlabs/backups/caddy-$DATE.tar.gz
find /opt/lucidlabs/backups -mtime +7 -delete
```

## Scaling

- **Vertical:** Upgrade to LARGE-4C-8G (~EUR59/mo) in Elestio
- **Horizontal:** Move high-traffic projects to dedicated servers

---

**Last Updated:** February 2026
**Maintainer:** Lucid Labs GmbH
