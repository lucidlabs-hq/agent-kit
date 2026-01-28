# Deployment Targets Reference

> **Purpose:** Definiert die verfügbaren Deployment-Ziele und wie Projekte dort deployt werden.

---

## Deployment-Optionen

Bei jedem Projekt muss entschieden werden, wo es deployt wird:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DEPLOYMENT TARGET                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  [1] LUCIDLABS-HQ (Recommended)                                             │
│      Shared Elestio instance für alle Lucid Labs Projekte                   │
│      → projects.lucidlabs.de / *.lucidlabs.app                              │
│      → Ressourcen werden geteilt                                            │
│      → Günstiger, schneller Setup                                           │
│      → GitHub Actions deployt automatisch                                   │
│                                                                             │
│  [2] DEDICATED                                                              │
│      Eigener Elestio Server für diesen Kunden/Projekt                       │
│      → customer.example.com                                                 │
│      → Via Terraform provisioniert                                          │
│      → Isolierte Ressourcen                                                 │
│      → Höhere Kosten, volle Kontrolle                                       │
│                                                                             │
│  [3] LOCAL-ONLY                                                             │
│      Kein Cloud-Deployment                                                  │
│      → Nur lokale Entwicklung                                               │
│      → Kein CI/CD                                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Option 1: LUCIDLABS-HQ (Shared Instance)

### Architektur

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LUCIDLABS-HQ ELESTIO SERVER                         │
│                         (projects.lucidlabs.de)                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                         Caddy (Reverse Proxy)                         │ │
│  │                                                                       │ │
│  │  invoice.lucidlabs.app  →  invoice-stack:3000                        │ │
│  │  neola.lucidlabs.app    →  neola-stack:3000                          │ │
│  │  casavi.lucidlabs.app   →  casavi-stack:3000                         │ │
│  │                                                                       │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│  │  invoice-stack  │  │   neola-stack   │  │  casavi-stack   │            │
│  │                 │  │                 │  │                 │            │
│  │  - frontend     │  │  - frontend     │  │  - frontend     │            │
│  │  - mastra       │  │  - mastra       │  │  - mastra       │            │
│  │  - (n8n)        │  │  - (n8n)        │  │  - (n8n)        │            │
│  │                 │  │                 │  │                 │            │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘            │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                      Shared Services (optional)                       │ │
│  │                                                                       │ │
│  │  - Uptime Kuma (monitoring.lucidlabs.app)                            │ │
│  │  - n8n Shared (n8n.lucidlabs.app) - für übergreifende Workflows      │ │
│  │                                                                       │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Server-Spezifikation & Kosten

**Empfohlene Konfiguration:**

| Komponente | Empfehlung | Notizen |
|------------|------------|---------|
| **Provider** | Hetzner (via Elestio) | Bestes Preis/Leistung in EU |
| **CPU Arch** | **Ampere Altra (ARM64)** | Besser als Intel/AMD für unseren Stack |
| **Region** | Falkenstein (fsn1) | EU/GDPR compliant |

**Server-Größen & Kosten:**

| Größe | Specs | Kosten/Monat | Use Case |
|-------|-------|--------------|----------|
| **SMALL-1C-2G** | 1 vCPU, 2GB RAM, 20GB | ~€15 | Monitoring, kleine Tools |
| **MEDIUM-2C-4G** | 2 vCPU, 4GB RAM, 40GB | ~€29 | 3-5 Projekte (Start) |
| **LARGE-4C-8G** | 4 vCPU, 8GB RAM, 80GB | ~€59 | 5-10 Projekte |
| **XLARGE-8C-16G** | 8 vCPU, 16GB RAM, 160GB | ~€99 | 10+ Projekte, High Traffic |

**Empfehlung für LUCIDLABS-HQ:**
- Start: **MEDIUM-2C-4G-CAX** (Ampere) ~€29/mo
- Bei >5 Projekten: Upgrade auf LARGE
- Monitoring Satellite: SMALL-1C-2G ~€15/mo

**Warum Ampere Altra?**
- 20-30% günstiger bei gleicher Leistung
- Energieeffizienter
- Node.js/Next.js/Caddy/n8n alle ARM64-kompatibel
- Zukunftssicher (ARM ist der Trend)

**Wann Intel/AMD wählen?**
- Legacy Software ohne ARM-Support
- Spezielle x86-only Dependencies
- Kunde verlangt es explizit

### Verzeichnisstruktur auf Server

```
/opt/lucidlabs/
├── caddy/
│   ├── Caddyfile              # Zentrale Routing-Config
│   └── docker-compose.yml     # Caddy + shared services
│
├── projects/
│   ├── invoice-accounting-assistant/
│   │   └── docker-compose.yml
│   ├── neola/
│   │   └── docker-compose.yml
│   └── casavi-sandbox-seeder/
│       └── docker-compose.yml
│
└── registry.json              # Welche Projekte sind deployt
```

### registry.json

```json
{
  "server": {
    "name": "lucidlabs-hq",
    "host": "projects.lucidlabs.de",
    "ip": "xxx.xxx.xxx.xxx",
    "provider": "elestio",
    "created": "2026-01-28"
  },
  "projects": [
    {
      "name": "invoice-accounting-assistant",
      "subdomain": "invoice.lucidlabs.app",
      "port": 3001,
      "repo": "lucidlabs-hq/invoice-accounting-assistant",
      "status": "active",
      "deployed": "2026-01-28"
    }
  ]
}
```

### Caddyfile (zentral)

```
# /opt/lucidlabs/caddy/Caddyfile

# Invoice Accounting Assistant
invoice.lucidlabs.app {
    reverse_proxy invoice-accounting-assistant-frontend-1:3000

    handle /api/agent/* {
        reverse_proxy invoice-accounting-assistant-mastra-1:4000
    }
}

# Neola
neola.lucidlabs.app {
    reverse_proxy neola-frontend-1:3000
}

# Monitoring
monitoring.lucidlabs.app {
    reverse_proxy uptime-kuma:3001
}
```

### GitHub Actions für LUCIDLABS-HQ

```yaml
# .github/workflows/deploy-hq.yml
name: Deploy to Lucid Labs HQ

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Lucid Labs HQ
        env:
          HQ_HOST: ${{ secrets.LUCIDLABS_HQ_HOST }}
          HQ_SSH_KEY: ${{ secrets.LUCIDLABS_HQ_SSH_KEY }}
          PROJECT_NAME: ${{ github.event.repository.name }}
        run: |
          mkdir -p ~/.ssh
          echo "$HQ_SSH_KEY" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan -H $HQ_HOST >> ~/.ssh/known_hosts

          # Sync code to server
          rsync -avz --delete \
            --exclude='.git' \
            --exclude='node_modules' \
            ./ root@$HQ_HOST:/opt/lucidlabs/projects/$PROJECT_NAME/

          # Build and restart
          ssh root@$HQ_HOST << EOF
            cd /opt/lucidlabs/projects/$PROJECT_NAME
            docker compose -p $PROJECT_NAME up -d --build
          EOF
```

---

## Option 2: DEDICATED (Eigener Server)

### Wann DEDICATED?

- Kunde verlangt isolierte Infrastruktur
- Compliance-Anforderungen (eigener Server)
- Hohe Last erwartet
- Separate Abrechnung gewünscht

### Terraform Provisioning

```hcl
# terraform/environments/customer-name/main.tf

module "elestio_server" {
  source = "../../modules/elestio"

  project_name = "customer-project"
  server_name  = "customer-prod"

  server_type  = "SMALL-1C-2G"  # oder größer
  provider_name = "hetzner"
  datacenter   = "fsn1"

  ssh_keys = [var.ssh_public_key]
}

module "convex" {
  source = "../../modules/convex"

  project_name = "customer-project"
}
```

### GitHub Actions für DEDICATED

```yaml
# .github/workflows/deploy-dedicated.yml
name: Deploy to Dedicated Server

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Dedicated Server
        env:
          SERVER_HOST: ${{ secrets.DEDICATED_HOST }}
          SERVER_SSH_KEY: ${{ secrets.DEDICATED_SSH_KEY }}
        run: |
          # Similar to HQ but with dedicated host
          ssh root@$SERVER_HOST << 'EOF'
            cd /opt/app
            git pull origin main
            docker compose up -d --build
          EOF
```

---

## Projekt-Konfiguration

### DEPLOYMENT-CONFIG.md (pro Projekt)

Jedes Projekt hat eine Deployment-Konfiguration in `.claude/DEPLOYMENT-CONFIG.md`:

```yaml
# .claude/DEPLOYMENT-CONFIG.md

deployment:
  target: LUCIDLABS-HQ  # LUCIDLABS-HQ | DEDICATED | LOCAL-ONLY

  # Nur bei LUCIDLABS-HQ
  hq:
    subdomain: invoice
    domain: lucidlabs.app
    port_offset: 1  # 3001, 4001, etc.

  # Nur bei DEDICATED
  dedicated:
    terraform_env: customer-name
    domain: app.customer.com

  # Convex (immer Cloud)
  convex:
    project: invoice-accounting-assistant
    team: lucid-labs

  # Secrets (Referenz, nicht Werte!)
  secrets:
    - ANTHROPIC_API_KEY
    - OPENAI_API_KEY
    - CONVEX_DEPLOY_KEY
```

---

## Workflow: Neues Projekt deployen

### Bei /init-project

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DEPLOYMENT KONFIGURATION                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Wo soll das Projekt deployt werden?                                        │
│                                                                             │
│  [1] LUCIDLABS-HQ (Recommended)                                             │
│      → invoice.lucidlabs.app                                                │
│      → Shared resources, schneller setup                                    │
│                                                                             │
│  [2] DEDICATED                                                              │
│      → Eigener Server via Terraform                                         │
│      → Für Kunden mit Compliance-Anforderungen                              │
│                                                                             │
│  [3] LOCAL-ONLY                                                             │
│      → Kein Cloud-Deployment (später konfigurierbar)                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Nach Auswahl LUCIDLABS-HQ

1. `DEPLOYMENT-CONFIG.md` wird erstellt
2. Subdomain wird reserviert
3. GitHub Secrets werden konfiguriert (manuell oder via gh CLI)
4. `.github/workflows/deploy-hq.yml` wird erstellt
5. Projekt wird zu `registry.json` auf HQ Server hinzugefügt

---

## Erstmalige HQ Server Einrichtung

**Dieses Projekt (invoice-accounting-assistant) ist der Startschuss!**

### Schritt 1: Elestio Server erstellen

```bash
# Via Terraform oder Elestio UI
cd terraform/environments/lucidlabs-hq
terraform init
terraform apply
```

### Schritt 2: Basis-Setup auf Server

```bash
ssh root@projects.lucidlabs.de

# Verzeichnisstruktur
mkdir -p /opt/lucidlabs/{caddy,projects}

# Caddy setup
cd /opt/lucidlabs/caddy
# Caddyfile + docker-compose.yml erstellen

# Registry initialisieren
echo '{"server":{"name":"lucidlabs-hq"},"projects":[]}' > /opt/lucidlabs/registry.json
```

### Schritt 3: GitHub Organization Secrets

```bash
# Diese Secrets werden für ALLE Projekte benötigt
gh secret set LUCIDLABS_HQ_HOST --org lucidlabs-hq
gh secret set LUCIDLABS_HQ_SSH_KEY --org lucidlabs-hq
```

### Schritt 4: Erstes Projekt deployen

```bash
# Im invoice-accounting-assistant Repo
git push origin main
# → GitHub Actions deployt automatisch
```

---

## Checkliste: Neues Projekt auf HQ deployen

```markdown
## Deployment Checklist

### Vor dem ersten Deploy
- [ ] DEPLOYMENT-CONFIG.md existiert mit target: LUCIDLABS-HQ
- [ ] Subdomain gewählt (z.B. invoice.lucidlabs.app)
- [ ] .github/workflows/deploy-hq.yml existiert
- [ ] Convex Projekt erstellt und CONVEX_DEPLOY_KEY als Repo Secret

### Erster Deploy
- [ ] Push to main → GitHub Actions läuft
- [ ] Projekt erscheint auf Server unter /opt/lucidlabs/projects/
- [ ] Caddyfile wurde aktualisiert (manuell oder automatisch)
- [ ] Subdomain erreichbar

### Nach Deploy
- [ ] Health Check: https://[subdomain].lucidlabs.app/api/health
- [ ] Monitoring in Uptime Kuma hinzugefügt
- [ ] registry.json aktualisiert
```

---

## Verwandte Dokumente

- `architecture.md` - Gesamtarchitektur
- `deployment-best-practices.md` - Docker & CI/CD Details
- `terraform/` - IaC Templates

---

**Version:** 1.0
**Last Updated:** January 2026
**Maintainer:** Lucid Labs GmbH
