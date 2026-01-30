---
name: deploy
description: Deploy project to LUCIDLABS-HQ server. Handles SSH access, Caddyfile updates, and Docker deployment.
allowed-tools: Bash, Read, Write
argument-hint: [setup|caddy|status|logs]
---

# Deploy to LUCIDLABS-HQ

Deployment Skill für Projekte auf dem shared LUCIDLABS-HQ Server.

## Voraussetzungen

### SSH Access

SSH Config muss eingerichtet sein (~/.ssh/config):

```
# User-Zugang (für Status, Logs, etc.)
Host lucidlabs-hq
    HostName 91.98.70.29
    User DEIN-USERNAME
    IdentityFile ~/.ssh/id_ed25519
    Port 2222

# Root-Zugang (für Caddyfile-Änderungen)
Host lucidlabs-hq-root
    HostName 91.98.70.29
    User root
    IdentityFile ~/.ssh/id_ed25519
    Port 2222
```

**Siehe:** .claude/reference/ssh-keys.md für Setup-Anleitung.

### Root Access für Caddyfile

Caddyfile-Änderungen erfordern root-Zugang. Claude Code kann dies automatisch durchführen wenn der Root-SSH-Zugang konfiguriert ist.

**Test ob Root-Zugang funktioniert:**

```bash
ssh -p 2222 root@91.98.70.29 "echo 'Root access OK'"
```

Falls kein Root-Zugang: Admin bitten, deinen Public Key zu `/root/.ssh/authorized_keys` hinzuzufügen.

---

## Befehle

### /deploy setup - Erstes Deployment vorbereiten

Prüft und erstellt alle benötigten Deployment-Dateien:

1. **Prüfen:**
   - docker-compose.yml vorhanden?
   - frontend/Dockerfile vorhanden?
   - frontend/app/api/health/route.ts vorhanden?
   - .claude/DEPLOYMENT-CONFIG.md vorhanden?
   - .github/workflows/deploy-hq.yml vorhanden?

2. **Erstellen falls fehlend**

### docker-compose.yml Template

```yaml
services:
  frontend:
    build:
      context: ./frontend
      args:
        NEXT_PUBLIC_CONVEX_URL: ${NEXT_PUBLIC_CONVEX_URL}
    container_name: PROJECT-NAME-frontend
    environment:
      - NODE_ENV=production
    ports:
      - "30XX:3000"  # Unique port per project
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  default:
    name: lucidlabs-network
    external: true
```

---

### /deploy caddy - Caddyfile Entry hinzufügen

**Automatisch via Claude Code (empfohlen):**

Claude kann den Caddyfile-Eintrag direkt hinzufügen wenn SSH-Root-Zugang konfiguriert ist:

```bash
# SSH Config für root (~/.ssh/config)
Host lucidlabs-hq-root
    HostName 91.98.70.29
    User root
    IdentityFile ~/.ssh/id_ed25519
    Port 2222
```

**Claude führt dann automatisch aus:**

```bash
ssh -p 2222 root@91.98.70.29 << 'EOF'
# Backup
cp /opt/lucidlabs/caddy/Caddyfile /opt/lucidlabs/caddy/Caddyfile.backup.$(date +%Y%m%d)

# Entry hinzufügen
cat >> /opt/lucidlabs/caddy/Caddyfile << 'CADDY'

# === PROJECT-NAME ===
project-name.lucidlabs.de {
    reverse_proxy project-name-frontend:3000

    log {
        output file /data/logs/project-name.log {
            roll_size 10mb
            roll_keep 5
        }
    }
}
CADDY

# Caddy neu starten
cd /opt/lucidlabs/caddy && docker compose restart caddy

# SSL-Zertifikat wird automatisch via Let's Encrypt ausgestellt
echo "Done. Checking logs..."
docker logs lucidlabs-caddy 2>&1 | tail -10
EOF
```

**Manuell (falls kein Root-Zugang):**

```bash
# 1. Als root auf Server verbinden
ssh root@91.98.70.29 -p 2222

# 2. Caddyfile bearbeiten
vim /opt/lucidlabs/caddy/Caddyfile

# 3. Folgenden Block am Ende hinzufügen (siehe unten)

# 4. Caddy neu starten
cd /opt/lucidlabs/caddy && docker compose restart caddy

# 5. SSL-Zertifikat prüfen (automatisch via Let's Encrypt)
docker logs lucidlabs-caddy 2>&1 | tail -20
```

**Caddyfile Block:**

```
# === PROJECT-NAME ===
project-name.lucidlabs.de {
    reverse_proxy project-name-frontend:3000

    log {
        output file /data/logs/project-name.log {
            roll_size 10mb
            roll_keep 5
        }
    }
}
```

**Wichtig:**
- Container-Name muss mit docker-compose.yml übereinstimmen
- SSL-Zertifikat wird automatisch von Let's Encrypt ausgestellt
- DNS muss bereits auf 91.98.70.29 zeigen

---

### /deploy status - Deployment Status prüfen

```bash
# SSH Verbindung testen
ssh lucidlabs-hq "echo Connected"

# Container Status
ssh lucidlabs-hq "docker ps | grep PROJECT-NAME"

# Health Check
curl -s https://project-name.lucidlabs.de/api/health | jq .

# Logs prüfen
ssh lucidlabs-hq "docker logs PROJECT-NAME-frontend --tail 50"
```

---

### /deploy logs - Logs anzeigen

```bash
# Live Logs
ssh lucidlabs-hq "docker logs -f PROJECT-NAME-frontend"

# Letzte 100 Zeilen
ssh lucidlabs-hq "docker logs PROJECT-NAME-frontend --tail 100"

# Caddy Access Logs
ssh lucidlabs-hq "sudo tail -f /opt/lucidlabs/caddy/data/logs/project-name.log"
```

---

## Server-Architektur

```
LUCIDLABS-HQ (91.98.70.29)
===========================

Caddy (Port 80/443)
├── project-a.lucidlabs.de  →  project-a-frontend:3000
├── project-b.lucidlabs.de  →  project-b-frontend:3000
└── project-c.lucidlabs.de  →  project-c-frontend:3000

Docker Containers (lucidlabs-network)
├── project-a-frontend (Port 3001)
├── project-b-frontend (Port 3002)
└── project-c-frontend (Port 3003)
```

---

## Port-Zuweisung

| Projekt | Frontend | Convex Backend | Convex Dashboard | Container Name |
|---------|----------|----------------|------------------|----------------|
| cotinga-test-suite | 3050 | 3214 | 6794 | cotinga-frontend |
| invoice | 3060 | 3216 | 6796 | invoice-frontend |

**Wichtig:**
- Ports intern (3000) sind für alle gleich - Caddy routet nach Container-Name!
- Jedes Projekt braucht eigene Convex-Instanz (siehe Convex Isolation)

---

## ⚠️ Convex Project Isolation (MANDATORY)

**JEDES Projekt MUSS seine eigene Convex-Instanz haben!**

### Warum?

- Schema-Konflikte zwischen Projekten
- Daten-Kollisionen
- Debugging-Chaos bei shared Instance

### Separate Convex-Instanz einrichten

1. **docker-compose.convex.yml erstellen:**

```yaml
# =============================================================================
# PROJECT-NAME - Convex Instance (Project Isolation!)
# =============================================================================

services:
  convex-backend:
    image: ghcr.io/get-convex/convex-backend:latest
    container_name: PROJECT-convex-backend
    ports:
      - "32XX:3210"   # Unique port!
      - "32X1:3211"
    volumes:
      - PROJECT-convex-data:/convex/data
    environment:
      - CONVEX_SITE_URL=https://PROJECT-convex.lucidlabs.de
    networks:
      - lucidlabs-network
    restart: unless-stopped

  convex-dashboard:
    image: ghcr.io/get-convex/convex-dashboard:latest
    container_name: PROJECT-convex-dashboard
    ports:
      - "67XX:6791"   # Unique port!
    environment:
      - CONVEX_BACKEND_URL=http://convex-backend:3210
    depends_on:
      - convex-backend
    networks:
      - lucidlabs-network

volumes:
  PROJECT-convex-data:

networks:
  lucidlabs-network:
    external: true
```

2. **Convex starten:**

```bash
ssh -p 2222 root@91.98.70.29 "cd /opt/lucidlabs/projects/PROJECT && docker compose -f docker-compose.convex.yml up -d"
```

3. **Caddy-Eintrag für Convex:**

```
# === PROJECT Convex Backend ===
PROJECT-convex.lucidlabs.de {
    reverse_proxy PROJECT-convex-backend:3210
    log { ... }
}
```

4. **Frontend .env.local aktualisieren:**

```env
NEXT_PUBLIC_CONVEX_URL=https://PROJECT-convex.lucidlabs.de
```

5. **Frontend neu bauen:**

```bash
NEXT_PUBLIC_CONVEX_URL=https://PROJECT-convex.lucidlabs.de docker compose build --no-cache frontend
docker compose up -d frontend
```

---

## Deployment Workflow

### Erstes Deployment (Vollständig)

```
1. /deploy setup                    # Dateien erstellen
2. Port-Allokation dokumentieren    # port-registry.md
3. Convex-Instanz einrichten        # Separate Instance!
4. Files zum Server übertragen      # rsync (siehe unten)
5. Caddyfile Entries                # Frontend + Convex
6. Build & Start                    # docker compose
7. /deploy status                   # Prüfen
```

### Files zum Server übertragen (rsync)

**Git Clone funktioniert oft nicht** (Deploy Keys disabled). Stattdessen rsync:

```bash
# Sync project files to server
rsync -avz --delete -e "ssh -p 2222" \
  --exclude 'node_modules' \
  --exclude '.next' \
  --exclude '.git' \
  --exclude 'dist' \
  /path/to/local/project/ \
  root@91.98.70.29:/opt/lucidlabs/projects/PROJECT/
```

### Build mit Convex URL

**WICHTIG:** `NEXT_PUBLIC_CONVEX_URL` muss als Build-Arg übergeben werden:

```bash
# Auf dem Server:
cd /opt/lucidlabs/projects/PROJECT

# .env.local erstellen
cat > .env.local << 'EOF'
CONVEX_URL=http://PROJECT-convex-backend:3210
NEXT_PUBLIC_CONVEX_URL=https://PROJECT-convex.lucidlabs.de
EOF

# Build mit --no-cache (wichtig bei URL-Änderungen!)
NEXT_PUBLIC_CONVEX_URL=https://PROJECT-convex.lucidlabs.de \
  docker compose build --no-cache frontend

# Start
docker compose up -d frontend
```

### Updates

```bash
# 1. Lokal: Changes committen und pushen
git push origin main

# 2. Server: Sync und rebuild
rsync -avz -e "ssh -p 2222" --exclude 'node_modules' --exclude '.next' \
  ./ root@91.98.70.29:/opt/lucidlabs/projects/PROJECT/

ssh -p 2222 root@91.98.70.29 "cd /opt/lucidlabs/projects/PROJECT && \
  NEXT_PUBLIC_CONVEX_URL=https://PROJECT-convex.lucidlabs.de \
  docker compose build --no-cache frontend && \
  docker compose up -d frontend"
```

### Rollback

```bash
# Lokales Repo zurücksetzen und neu syncen
git checkout HEAD~1
rsync -avz -e "ssh -p 2222" --exclude 'node_modules' ./ root@91.98.70.29:/opt/lucidlabs/projects/PROJECT/
ssh -p 2222 root@91.98.70.29 "cd /opt/lucidlabs/projects/PROJECT && docker compose up -d --build"
```

---

## Troubleshooting

### Connection refused auf Port 22

LUCIDLABS-HQ nutzt **Port 2222**:

```bash
ssh -p 2222 user@91.98.70.29
```

### Container startet nicht

```bash
# Build Logs prüfen
ssh lucidlabs-hq "cd /opt/lucidlabs/projects/PROJECT-NAME && docker compose logs --tail 100"

# Manuell bauen
ssh lucidlabs-hq "cd /opt/lucidlabs/projects/PROJECT-NAME && docker compose build --no-cache"
```

### SSL-Zertifikat fehlt

```bash
# Caddy Logs prüfen
ssh lucidlabs-hq "docker logs lucidlabs-caddy-caddy-1 | grep -i cert"

# DNS prüfen
dig project-name.lucidlabs.de
```

### Permission denied bei Caddyfile

Caddyfile gehört root - du brauchst root-Zugang:

```bash
ssh root@91.98.70.29 -p 2222
# Oder: Admin bitten, deinen User zu sudoers hinzuzufügen
```

---

## n8n MCP Integration (Empfohlen)

Statt direktem SSH-Zugang kann Claude über n8n MCP Server Deployments durchführen.

### Setup

1. **n8n MCP Server hinzufügen:**

```bash
claude mcp add n8n -- npx -y @anthropic-ai/mcp-server-n8n
```

2. **Credentials in ~/.claude.json konfigurieren:**

```json
{
  "mcpServers": {
    "n8n": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-n8n"],
      "env": {
        "N8N_HOST": "https://a1-automate.lucidlabs.de",
        "N8N_API_KEY": "your-n8n-api-key"
      }
    }
  }
}
```

3. **Claude Code neu starten** damit MCP Server verbindet.

### Verfügbare n8n Tools

| Tool | Beschreibung |
|------|--------------|
| `list_workflows` | Alle Workflows auflisten |
| `execute_workflow` | Workflow ausführen |
| `get_executions` | Execution History |
| `create_workflow` | Neuen Workflow erstellen |

### Deployment Workflows in n8n

Erstelle Workflows in n8n für:

**1. Deploy Project:**
- Webhook Trigger mit Project Name
- SSH Node für `docker compose up -d --build`
- Slack/Email Notification

**2. Add Caddyfile Entry:**
- Webhook Trigger mit Domain + Container Name
- SSH Node für Caddyfile Update
- SSH Node für `docker compose restart caddy`

**3. Health Check:**
- HTTP Request Node
- Conditional für Status
- Alert bei Failure

### Vorteile von n8n für Deployments

| Feature | SSH Direkt | n8n MCP |
|---------|-----------|---------|
| Audit Trail | ❌ | ✅ Execution History |
| Retry Logic | ❌ | ✅ Built-in |
| Notifications | ❌ | ✅ Slack, Email, etc. |
| Approval Flow | ❌ | ✅ Wait Node |
| Scheduling | ❌ | ✅ Cron Trigger |

### Beispiel: Deploy via n8n

```
Claude: "Deploy cotinga-test-suite"
  ↓
n8n MCP: execute_workflow("deploy-project", {project: "cotinga-test-suite"})
  ↓
n8n Workflow:
  1. Git Pull
  2. Docker Build
  3. Docker Up
  4. Health Check
  5. Slack Notification
  ↓
Claude: "Deployment erfolgreich. Health Check: OK"
```

---

## Referenzen

- .claude/reference/deployment-targets.md - LUCIDLABS-HQ vs DEDICATED
- .claude/reference/deployment-best-practices.md - Docker, CI/CD Details
- .claude/reference/ssh-keys.md - SSH Setup Anleitung
- .claude/reference/mcp-servers.md - MCP Server Übersicht
- .claude/DEPLOYMENT-CONFIG.md - Projekt-spezifische Config
