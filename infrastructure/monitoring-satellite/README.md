# Monitoring Satellite Server

> Separate server for monitoring all Lucid Labs infrastructure.

## Why Separate?

The monitoring server **must** be separate from LUCIDLABS-HQ:
- If HQ goes down, monitoring still works
- Alerts can be sent even during outages
- Independent failure domain

## Server Specs

| Property | Value |
|----------|-------|
| **Provider** | Elestio (Hetzner) |
| **Size** | SMALL-1C-2G |
| **Architecture** | ARM64 (Ampere Altra) |
| **Cost** | ~€15/month |
| **Domain** | monitoring.lucidlabs.de or status.lucidlabs.de |

## Quick Start

```bash
# 1. Provision SMALL-1C-2G server on Elestio

# 2. SSH into server
ssh root@<monitoring-server-ip>

# 3. Install Docker (if not pre-installed)
curl -fsSL https://get.docker.com | sh

# 4. Clone and start
git clone git@github.com:lucidlabs-hq/agent-kit.git /tmp/agent-kit
cp -r /tmp/agent-kit/infrastructure/monitoring-satellite /opt/monitoring
cd /opt/monitoring
docker compose up -d

# 5. Access Uptime Kuma
# http://<server-ip>:80
```

## Monitors to Configure

After setup, add these monitors in Uptime Kuma:

### LUCIDLABS-HQ Projects

| Monitor | URL | Interval |
|---------|-----|----------|
| Invoice Frontend | `https://invoice.lucidlabs.de/api/health` | 60s |
| Invoice Mastra | `https://invoice.lucidlabs.de/api/agent/health` | 60s |

### Infrastructure

| Monitor | Type | Target |
|---------|------|--------|
| HQ Server | Ping | `projects.lucidlabs.de` |
| HQ SSH | TCP Port | `projects.lucidlabs.de:22` |

## Alerting

Configure notifications in Uptime Kuma:
- **Slack** - #alerts channel
- **Email** - admin@lucidlabs.de
- **Telegram** - Optional

## Status Page

Uptime Kuma can serve a public status page:

1. Go to Status Pages in Uptime Kuma
2. Create "Lucid Labs Status"
3. Add monitors
4. Share URL: `https://status.lucidlabs.de`

## Backup

Uptime Kuma data is stored in Docker volume `uptime_kuma_data`.

```bash
# Backup
docker run --rm -v uptime_kuma_data:/data -v $(pwd):/backup alpine \
  tar czf /backup/uptime-kuma-backup.tar.gz /data

# Restore
docker run --rm -v uptime_kuma_data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/uptime-kuma-backup.tar.gz -C /
```

---

**Last Updated:** January 2026
