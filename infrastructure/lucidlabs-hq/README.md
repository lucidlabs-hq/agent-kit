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
│  │  invoice.lucidlabs.de  →  invoice-frontend:3000                     │ │
│  │  project2.lucidlabs.de →  project2-frontend:3000                    │ │
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

## Elestio Setup (Step-by-Step)

### Phase 1: Provision Server in Elestio

1. **Elestio Dashboard** → Deploy New Service → Docker Compose
2. **Select Provider:** Hetzner Cloud
3. **Select Region:** Europe, Germany (Falkenstein)
4. **Select Server:** MEDIUM-2C-4G-CAX (Ampere ARM64, ~€29/mo)
5. **Pipeline Name:** `lucidlabs-hq` (cannot be changed!)
6. **Docker Compose:** Paste content from `docker-compose.bootstrap.yml`:

```yaml
services:
  caddy:
    image: caddy:2-alpine
    container_name: lucidlabs-caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - caddy_data:/data
      - caddy_config:/config
    command: caddy respond --listen :80 "LUCIDLABS-HQ OK - Run setup.sh"

  watchtower:
    image: containrrr/watchtower
    container_name: lucidlabs-watchtower
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - TZ=Europe/Berlin
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_POLL_INTERVAL=300
      - WATCHTOWER_LABEL_ENABLE=true

networks:
  lucidlabs-network:
    name: lucidlabs-network

volumes:
  caddy_data:
  caddy_config:
```

7. **Create Service** → Wait for provisioning (~5 min)

### Phase 2: Configure Server

After Elestio shows "Running":

```bash
# 1. Via Elestio Web-Terminal (erstmal, bis SSH Key eingerichtet)

# 2. Clone agent-kit
git clone https://github.com/lucidlabs-hq/agent-kit.git /tmp/agent-kit

# 3. Run setup script
cd /tmp/agent-kit/infrastructure/lucidlabs-hq
chmod +x setup.sh scripts/*.sh
./setup.sh

# 4. Elestio nginx entfernen (belegt Port 80)
docker stop elestio-nginx
docker rm elestio-nginx

# 5. Caddy starten
cd /opt/lucidlabs/caddy
docker compose up -d

# 6. Verify
curl http://localhost/health  # Should show "OK"
docker ps                     # Should show caddy + watchtower
```

### Phase 2b: SSH absichern (Optional aber empfohlen)

```bash
# SSH Port auf 2222 ändern
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# Systemd Socket Override (WICHTIG!)
mkdir -p /etc/systemd/system/ssh.socket.d/
cat > /etc/systemd/system/ssh.socket.d/port.conf << 'EOF'
[Socket]
ListenStream=
ListenStream=0.0.0.0:2222
ListenStream=[::]:2222
EOF

systemctl daemon-reload
systemctl restart ssh.socket ssh.service

# In Elestio Firewall: Port 2222 TCP hinzufügen!
```

### Phase 3: Configure DNS

At your DNS provider, add:

```
*.lucidlabs.de.  A  <server-ip>
```

Or individual subdomains as needed.

### Phase 4: Deploy First Project

```bash
# On the server
cd /opt/lucidlabs
./scripts/add-project.sh invoice-accounting-assistant invoice
# Follow the output instructions
```

---

## Quick Reference

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
| `docker-compose.bootstrap.yml` | **Elestio initial setup** (use this first!) |
| `docker-compose.yml` | Full Caddy setup (after setup.sh) |
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
*.lucidlabs.de.  A  <server-ip>
```

Or individual records:

```
invoice.lucidlabs.de.  A  <server-ip>
project2.lucidlabs.de. A  <server-ip>
```

## Monitoring

Monitoring (Uptime Kuma) runs on a **separate server** to ensure alerts work even if HQ goes down.

See: `infrastructure/monitoring-satellite/` (separate setup)

The monitoring server checks:
- `https://invoice.lucidlabs.de/api/health`
- `https://<project>.lucidlabs.de/api/health`
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

## Elestio Kompatibilität

Wir haben Elestio's Standard-nginx durch unser Caddy ersetzt. **Elestio funktioniert weiterhin:**

| Feature | Status |
|---------|--------|
| Dashboard | ✅ Funktioniert |
| Web-Terminal | ✅ Funktioniert |
| SSH Key Management | ✅ Funktioniert |
| Firewall | ✅ Funktioniert |
| Backups | ✅ Funktioniert |
| Logs | ✅ Funktioniert |
| Auto-SSL (Elestio) | ❌ Ersetzt durch Caddy |
| nginx (Elestio) | ❌ Ersetzt durch Caddy |

**Was wir geändert haben:**

```bash
# Elestio nginx entfernt (belegt Port 80/443)
docker stop elestio-nginx
docker rm elestio-nginx

# Unser Caddy übernimmt Reverse Proxy + Auto-SSL
```

**SSH Port geändert:**
- Standard: 22
- Neu: **2222** (Sicherheit)
- Systemd Socket Override in `/etc/systemd/system/ssh.socket.d/port.conf`

---

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
