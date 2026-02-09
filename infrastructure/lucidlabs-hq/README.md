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

### Sudoers Configuration (One-Time Setup)

The deployment scripts run remotely via `ssh lucidlabs-hq "sudo ..."`. By default, sudo requires
an interactive password prompt, which breaks non-interactive SSH commands. To solve this, we
configure **passwordless sudo for specific commands only** via `/etc/sudoers.d/`.

**Why this is needed:**
- `deploy-project.sh` runs locally and connects to the server via SSH
- On the server it needs `sudo` to: run `add-project.sh`, manage Docker containers, write to `/opt/lucidlabs/`
- Without sudoers config, every SSH command would hang waiting for a password

**What is allowed without password:**
- Deploy scripts in `/opt/lucidlabs/scripts/` (owned by root, not writable by nightwing)
- Docker commands (`docker`, `docker compose`)
- All other sudo operations still require a password

**Security model:**
- Only deployment-related commands are passwordless
- Scripts are owned by `root:root` with `755` permissions — nightwing cannot modify them
- This is a standard Linux automation pattern (same as CI/CD agents, Ansible, etc.)

#### Setup (run once on the server with your sudo password)

```bash
ssh lucidlabs-hq

# Create sudoers drop-in file
echo 'nightwing ALL=(ALL) NOPASSWD: /opt/lucidlabs/scripts/*.sh, /usr/bin/docker, /usr/bin/docker-compose' \
  | sudo tee /etc/sudoers.d/lucidlabs-deploy

# Lock down permissions (required by sudo, will refuse to load otherwise)
sudo chmod 440 /etc/sudoers.d/lucidlabs-deploy

# Validate syntax (IMPORTANT: broken sudoers can lock you out of sudo entirely)
sudo visudo -c
# Expected output: /etc/sudoers: parsed OK
#                  /etc/sudoers.d/lucidlabs-deploy: parsed OK
```

#### Verify it works

```bash
# From your local machine (should NOT prompt for password):
ssh lucidlabs-hq "sudo /opt/lucidlabs/scripts/add-project.sh --help"
ssh lucidlabs-hq "sudo docker ps"
```

#### Current server state (configured 2026-02-09)

```
File:    /etc/sudoers.d/lucidlabs-deploy
Owner:   root:root
Mode:    440 (-r--r-----)
Content: nightwing ALL=(ALL) NOPASSWD: /opt/lucidlabs/scripts/*.sh, /usr/bin/docker, /usr/bin/docker-compose
```

### Server Permissions Model

The `/opt/lucidlabs/` directory is **owned by root**. The deploy user `nightwing` cannot write
directly to it. All file operations in `/opt/lucidlabs/` are performed via **docker volume mounts**:

```bash
# How deploy-project.sh writes to root-owned directories:
# 1. rsync files to /tmp/deploy-<project>/ (nightwing has write access)
# 2. Use docker to copy from /tmp to /opt/lucidlabs (docker runs as root)
sudo docker run --rm \
    -v /opt/lucidlabs:/opt/lucidlabs \
    -v /tmp:/tmp \
    alpine sh -c 'cp -a /tmp/deploy-<project>/. /opt/lucidlabs/projects/<project>/'
```

**Why this pattern:**
- nightwing cannot `mkdir`, `cp`, or `mv` in `/opt/lucidlabs/` directly
- `sudo mkdir` is not in the sudoers allowlist (intentionally restricted)
- `sudo docker` IS in the allowlist, so docker containers can write to mounted volumes
- This avoids adding generic commands like `mkdir`, `cp`, `mv` to sudoers

**Directory ownership on server:**

| Path | Owner | Purpose |
|------|-------|---------|
| `/opt/lucidlabs/` | root:root | Base directory |
| `/opt/lucidlabs/scripts/` | root:root | Deploy scripts (not writable by nightwing) |
| `/opt/lucidlabs/projects/` | root:root | Project directories |
| `/opt/lucidlabs/caddy/` | root:root | Caddy config |
| `/opt/lucidlabs/registry.json` | root:root | Port registry |
| `/tmp/deploy-*` | nightwing | Staging area (ephemeral) |

### Server Dependencies

Software available on LUCIDLABS-HQ (verified 2026-02-09):

| Tool | Available | Notes |
|------|-----------|-------|
| python3 | Yes | Used for all JSON operations in scripts |
| jq | **No** | Not installed. All scripts use python3 instead |
| docker | Yes | Via `sudo docker` (passwordless) |
| docker compose | Yes | Plugin for docker CLI |
| rsync | Yes | For file sync |
| curl | Yes | For health checks |
| ss | Yes | For port conflict detection |
| caddy | Yes | Inside `lucidlabs-caddy` container only |

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

## Tested Deployments

Live-tested deployment runs (to verify scripts work end-to-end):

| Date | Project | Command | Result |
|------|---------|---------|--------|
| 2026-02-09 | cotinga-test-suite | `deploy-project.sh --skip-github --has-convex` | All steps passed, HTTP 200 on frontend + Convex |
| 2026-02-09 | client-service-reporting | `add-project.sh --dry-run --has-convex` | Dry-run: correct port detection (3070, 3212, 6793) |
| 2026-02-09 | (new project sim) | `add-project.sh --dry-run --has-convex --has-mastra` | Dry-run: correct next ports (3080, 3218, 6798, 4050) |

### Known Issues Found During Testing

| Issue | Root Cause | Fix Applied |
|-------|-----------|-------------|
| `jq: command not found` on server | jq not installed on LUCIDLABS-HQ | Rewrote all JSON ops to use python3 |
| `sudo mkdir: permission denied` via SSH | Only docker/scripts in sudoers | Use `sudo docker run alpine` for file ops |
| `container name already in use` | Convex started with different compose project name | Detect existing containers, restart instead of recreate |
| rsync permission denied to `/opt/lucidlabs/` | Directory owned by root | Rsync to `/tmp` staging, then docker cp to final location |

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
# Check registry.json for allocated ports (python3, jq not installed)
ssh lucidlabs-hq 'python3 -c "import json; [print(p[\"name\"], p.get(\"ports\", p.get(\"services\",{}))) for p in json.load(open(\"/opt/lucidlabs/registry.json\"))[\"projects\"]]"'
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
