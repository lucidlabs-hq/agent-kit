---
name: init-project
description: Initialize a new project from Agent Kit boilerplate. Use when creating a new downstream project.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
argument-hint: [project-name]
---

# Initialize New Project

Create a new downstream project from the Agent Kit template.

## Expected Folder Structure

```
lucidlabs/
├── lucidlabs-agent-kit/            ← You are here (upstream)
└── projects/
    └── [project-name]/             ← Will be created here
```

## Project Details

**Project Name:** $ARGUMENTS

If no argument provided, ask for:
- Project name (kebab-case, e.g., `customer-portal`)
- Project description (one sentence)

---

## Step 0: Template oder Custom?

**ZUERST:** Frage ob der User ein Template nutzen möchte:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PROJEKT SETUP                                                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Wie möchtest du starten?                                                │
│                                                                          │
│  [1] TEMPLATE (Recommended)                                              │
│      → Fertiges Setup mit Demo-Projekt                                   │
│      → Dokumentation + Admin Dashboard                                   │
│      → Sofort lauffähig                                                  │
│                                                                          │
│  [2] CUSTOM                                                              │
│      → Stack individuell zusammenstellen                                 │
│      → Für spezielle Anforderungen                                       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Bei [1] TEMPLATE:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  VERFÜGBARE TEMPLATES                                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  [1] fullstack-convex-mastra (Recommended)                               │
│      • Next.js 16 + React 19                                             │
│      • Convex (self-hosted) + Better Auth                                │
│      • Mastra v1 AI Agents                                               │
│      • Demo Invoice Workflow                                             │
│      • Admin Dashboard                                                   │
│      • Offline dev mode (Ollama)                                         │
│                                                                          │
│  [2] Mehr Templates coming soon...                                       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

Bei Template-Auswahl:
1. Kopiere Template nach `../projects/[project-name]/`
2. Ersetze Platzhalter mit Projektnamen
3. Erstelle PROJECT-CONTEXT.md und PRD.md
4. Springe zu Step 4 (Handoff)

### Bei [2] CUSTOM:

Weiter mit der manuellen Stack-Konfiguration unten.

---

## Step 0b: Intelligente Stack-Empfehlung (nur bei CUSTOM)

**WICHTIG:** Bevor du die Stack-Konfiguration zeigst, frage nach dem Projekt:

### 0.1 Projekt verstehen

Frage den User:

```
Beschreibe dein Projekt in 1-2 Sätzen:

Beispiele:
• "Chat-Bot für Kundenservice"
• "Ticket-Klassifikation mit CRM-Integration"
• "Enterprise RAG für interne Dokumente"
• "Schneller Prototyp für Demo nächste Woche"
```

### 0.2 Komplexitätsstufe ermitteln

Analysiere die Beschreibung und ordne sie einer Stufe zu:

| Stufe | Erkennungsmerkmale | Empfehlung |
|-------|-------------------|------------|
| **1: MVP/Prototype** | "Demo", "POC", "schnell", "einfach", "Chat" | Vercel AI SDK + Convex |
| **2: Standard** | "Agent", "Tool", "Workflow", "Klassifikation" | Mastra + Convex |
| **3: Enterprise** | "Multi-Tenant", "Enterprise", "viele User", "CRM/ERP" | Mastra + Convex + Portkey + n8n |
| **4: GDPR/Compliance** | "Bank", "Versicherung", "GDPR", "EU-Daten" | + Azure OpenAI + Postgres |

### 0.3 Empfehlung zeigen

```
┌─────────────────────────────────────────────────────────────────────────┐
│  STACK-EMPFEHLUNG                                                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Basierend auf: "[User-Beschreibung]"                                   │
│                                                                          │
│  Erkannte Stufe: STUFE 2 - Standard Projekt                             │
│                                                                          │
│  EMPFOHLENER STACK:                                                      │
│                                                                          │
│  ✅ Next.js 15        (Frontend)           - Standard                    │
│  ✅ Mastra            (AI Layer)           - wegen Tools/Workflows       │
│  ✅ Convex            (Database)           - Realtime für UI             │
│  ⚪ n8n               (Automation)         - optional, für Integrationen │
│                                                                          │
│  NICHT EMPFOHLEN für dieses Projekt:                                    │
│  ❌ Vercel AI SDK     - Projekt braucht Tools                           │
│  ❌ Portkey           - kein Multi-Tenant/Cost-Tracking nötig           │
│  ❌ Python Workers    - keine PDF/ML-Verarbeitung                       │
│                                                                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Mit dieser Empfehlung fortfahren? [Y/n]                                │
│  Oder: "Anpassen" für manuelle Auswahl                                  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Empfehlungslogik

**Stufe 1: MVP/Prototype**
```
✅ Next.js 15
✅ Vercel AI SDK      ← Schnell, einfach
✅ Convex             ← Einfaches Setup
❌ Mastra, n8n, Portkey, Python, Terraform
```

**Stufe 2: Standard Projekt**
```
✅ Next.js 15
✅ Mastra             ← Production-ready Agents
✅ Convex             ← Realtime, Type-safe
⚪ n8n                ← Optional für Integrationen
❌ Portkey, Python, LangChain, Terraform
```

**Stufe 3: Enterprise Projekt**
```
✅ Next.js 15
✅ Mastra             ← Volle Agent-Kapazität
✅ Convex oder Postgres
✅ Portkey            ← Cost Tracking, Multi-Model
✅ n8n                ← Externe Integrationen
⚪ Python Workers     ← Falls PDF/ML nötig
⚪ Terraform          ← Falls Multi-Environment
```

**Stufe 4: GDPR/Compliance**
```
✅ Next.js 15
✅ Mastra
✅ Postgres           ← EU-hosted möglich
✅ Azure OpenAI       ← GDPR-konform
✅ Portkey            ← Routing & Fallback
✅ n8n
✅ Terraform          ← IaC für Compliance
```

---

## Step 1: Stack Configuration (falls manuell gewählt)

Falls User "Anpassen" wählt, zeige die manuelle Konfiguration:

### Core Stack (Choose one each)

```
┌─────────────────────────────────────────────────────────────────┐
│  STACK CONFIGURATION                                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  AI LAYER (wähle eins):                                          │
│  ├─ [1] Mastra (Production Agents, Tools, Workflows)             │
│  └─ [2] Vercel AI SDK (Schnelle Prototypen, Chat UI)             │
│                                                                  │
│  DATABASE (wähle eins):                                          │
│  ├─ [1] Convex (Realtime, Simple Setup, Built-in Vector)         │
│  └─ [2] Postgres (SQL Standard, Pinecone-kompatibel)             │
│                                                                  │
│  FRONTEND:                                                       │
│  └─ [Y/n] Next.js 15 + shadcn/ui                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### LLM Configuration

**WICHTIG:** Führe `/llm-evaluate [projekt-beschreibung]` aus um aktuelle Preise zu holen und das optimale Modell zu empfehlen.

```
┌─────────────────────────────────────────────────────────────────┐
│  LLM KONFIGURATION                                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PRIMARY MODEL (Hauptmodell):                                    │
│  ├─ [1] Claude Sonnet 4    - Best coding, balanced ($3/$15)      │
│  ├─ [2] Claude Haiku 3.5   - Fast, cheap ($0.25/$1.25)           │
│  ├─ [3] Claude Opus 4.5    - Best reasoning ($15/$75)            │
│  ├─ [4] GPT-4o             - Multimodal ($5/$15)                 │
│  ├─ [5] Gemini 2.0 Flash   - Ultra cheap ($0.10/$0.40)           │
│  ├─ [6] DeepSeek V3        - Budget ($0.27/$1.10)                │
│  └─ [7] Custom             - Manuell konfigurieren               │
│                                                                  │
│  FALLBACK MODEL (wenn Primary down):                             │
│  ├─ [1] GPT-4o-mini        - Budget fallback                     │
│  ├─ [2] Gemini Flash       - Google fallback                     │
│  ├─ [3] Kein Fallback      - Nur Primary                         │
│  └─ [4] Custom                                                   │
│                                                                  │
│  FAST MODEL (für einfache Tasks):                                │
│  ├─ [1] Claude Haiku 3.5   - Schnell, Anthropic                  │
│  ├─ [2] Gemini Flash 8B    - Ultra cheap                         │
│  ├─ [3] Same as Primary    - Kein separates Fast-Model           │
│  └─ [4] Custom                                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  COMPLIANCE & REGION                                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [y/N] GDPR-Modus    - Nur EU-Provider (Azure, Mistral)          │
│  [y/N] Portkey       - Cost Tracking, Fallbacks, Caching         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**LLM Empfehlung nach Stufe:**

| Stufe | Primary | Fallback | Fast |
|-------|---------|----------|------|
| 1: MVP | Haiku 3.5 | Gemini Flash | - |
| 2: Standard | Sonnet 4 | GPT-4o-mini | Haiku 3.5 |
| 3: Enterprise | Sonnet 4 | GPT-4o | Haiku 3.5 |
| 4: GDPR | Azure GPT-4o | Mistral Large | - |

**Siehe:** `.claude/reference/llm-configuration.md` für Details.

### Optional Components

```
┌─────────────────────────────────────────────────────────────────┐
│  OPTIONAL COMPONENTS                                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [y/N] n8n          - Workflow Automation, Integrations          │
│  [y/N] Python       - PDF Parsing, OCR, Statistics, ML           │
│  [y/N] LangChain    - Complex Chains, LangGraph                  │
│  [y/N] Terraform    - Infrastructure as Code                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Project Management

```
┌─────────────────────────────────────────────────────────────────┐
│  PROJECT MANAGEMENT                                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Name:    [project-name]                                         │
│  GitHub:  [YES] lucidlabs-hq/[project-name]                     │
│  Linear:  [YES] [Domain] Project Name                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Deployment Target

```
┌─────────────────────────────────────────────────────────────────┐
│  DEPLOYMENT TARGET                                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Wo soll das Projekt deployt werden?                             │
│                                                                  │
│  [1] LUCIDLABS-HQ (Recommended)                                  │
│      → [project].lucidlabs.app                                   │
│      → Shared Elestio, schneller Setup                           │
│      → GitHub Actions deployt automatisch                        │
│                                                                  │
│  [2] DEDICATED                                                   │
│      → Eigener Elestio Server via Terraform                      │
│      → Für Kunden mit Compliance/Isolation                       │
│      → Höhere Kosten, volle Kontrolle                            │
│                                                                  │
│  [3] LOCAL-ONLY                                                  │
│      → Kein Cloud-Deployment (Prototyp/Demo)                     │
│      → Später konfigurierbar                                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Siehe:** `.claude/reference/deployment-targets.md` für Details.

### Entscheidungshilfe (Quick Reference)

| Was brauchst du? | AI Layer | Database | LLM | Optional |
|------------------|----------|----------|-----|----------|
| Chat Prototype | Vercel AI SDK | Convex | Claude | - |
| Production Agent | Mastra | Convex | Claude | - |
| **PDF/Dokument-Analyse** | Mastra | Convex | **Mistral** | - |
| Agent + CRM | Mastra | Convex | Claude | n8n |
| SQL + Pinecone | Mastra | Postgres | Claude | Pinecone |
| Enterprise Multi-Tenant | Mastra | Either | Claude | Portkey, n8n |
| Complex Analysis | Mastra | Either | Claude | Python Workers |
| GDPR/Compliance | Mastra | Postgres | **Azure OpenAI** | - |
| EU-Hosting + Speed | Mastra | Convex | **Mistral** | - |

---

## Step 2: Run the Scaffolding Script

The script automatically creates the project in `../projects/`:

```bash
# Interactive mode (recommended for first-time)
./scripts/create-agent-project.sh --interactive

# Or with project name directly
./scripts/create-agent-project.sh [project-name]
```

**What the script does:**
1. Creates `../projects/[project-name]/`
2. Copies all boilerplate files
3. Customizes package.json and README
4. Creates template PRD
5. Initializes git repository with initial commit
6. Creates GitHub repository (if confirmed)
7. Creates Linear project (if confirmed)

---

## Step 2b: PROJECT-CONTEXT.md erstellen (PFLICHT!)

**KRITISCH:** Nach dem Scaffolding MUSS `PROJECT-CONTEXT.md` erstellt werden.

Erstelle `.claude/PROJECT-CONTEXT.md` im neuen Projekt:

```yaml
# Project Context

> Identifiziert dieses Repository und sein Verhältnis zum Agent Kit.

---

## Repository Type

type: downstream

---

## Upstream Reference

upstream:
  name: lucidlabs-agent-kit
  repo: git@github.com:lucidlabs-hq/lucidlabs-agent-kit.git
  local_path: ../../lucidlabs-agent-kit
  last_sync: [HEUTE]

---

## Active Project

project:
  name: [project-name]
  description: "[Beschreibung aus Step 0.1]"
  client: [Kundenprojekt | Internes Projekt]
  status: Initial
  started: [HEUTE]

---

## Promotion Tracking

Patterns die ins upstream promoted werden sollen:

| Pattern | Status | Description |
|---------|--------|-------------|
| - | - | - |

Nutze `/promote` um Patterns ins upstream zu übernehmen.
```

**Warum das wichtig ist:**
- `/prime` erkennt dadurch, dass dies ein downstream Projekt ist
- `/promote` weiß, wo das upstream liegt
- Der User weiß, an welchem Projekt er arbeitet

---

## Step 2c: Initiales PRD aus Beschreibung erstellen (PFLICHT!)

**KRITISCH:** Die Projekt-Beschreibung aus Step 0.1 wird zum initialen PRD.

Erstelle `.claude/PRD.md` im neuen Projekt:

```markdown
# [project-name] - Product Requirements Document

> **Status:** Initial - Ausspezifizierung mit /create-prd erforderlich

**Version:** 0.1 (Initial)
**Last Updated:** [HEUTE]
**Client:** [Kundenprojekt | Internes Projekt]

---

## Project Description (aus Init-Gespräch)

> "[Exakte Beschreibung die der User in Step 0.1 eingegeben hat]"

---

## Stack (gewählt in Init)

| Component | Choice | Reason |
|-----------|--------|--------|
| AI Layer | [Mastra/Vercel AI SDK] | [Warum gewählt] |
| Database | [Convex/Postgres] | [Warum gewählt] |
| Frontend | Next.js 15 + shadcn/ui | Standard |
| Optional | [n8n, Portkey, etc.] | [Warum gewählt] |

## LLM Konfiguration (gewählt in Init)

| Role | Model | Provider | Cost (Input/Output) |
|------|-------|----------|---------------------|
| Primary | [Model] | [Provider] | $X/$X per 1M tokens |
| Fallback | [Model] | [Provider] | $X/$X per 1M tokens |
| Fast | [Model] | [Provider] | $X/$X per 1M tokens |

**Portkey:** [Ja/Nein] - [Begründung]
**GDPR-Modus:** [Ja/Nein]

---

## Nächste Schritte

**Dieses PRD ist ein Ausgangspunkt.** Es muss mit `/create-prd` ausspezifiziert werden:

1. [ ] Problem & Solution detaillieren
2. [ ] Target Users definieren
3. [ ] MVP Scope festlegen
4. [ ] User Stories schreiben
5. [ ] Domain Model entwerfen
6. [ ] AI Agent Specification
7. [ ] Success Criteria

---

## Kontext aus Init-Gespräch

[Hier wird die Zusammenfassung aus Step 4.1 eingefügt:]

• Projekt-Beschreibung: [...]
• Erkannte Stufe: [1-4]
• Stack-Entscheidungen: [...]
• Offene Fragen: [...]
```

**Warum das wichtig ist:**
- Der User sieht beim nächsten `/prime` sofort den Kontext
- `/create-prd` hat einen Ausgangspunkt
- Nichts aus dem Init-Gespräch geht verloren

---

## Step 2d: DEPLOYMENT-CONFIG.md erstellen (PFLICHT!)

**KRITISCH:** Nach der Deployment-Target Auswahl MUSS die Config erstellt werden.

Erstelle `.claude/DEPLOYMENT-CONFIG.md` im neuen Projekt:

### Bei LUCIDLABS-HQ:

```yaml
# .claude/DEPLOYMENT-CONFIG.md

deployment:
  target: LUCIDLABS-HQ
  configured: [HEUTE]

hq:
  subdomain: [project-name]
  domain: lucidlabs.app
  url: https://[project-name].lucidlabs.app

convex:
  project: [project-name]
  team: lucid-labs

github_actions:
  workflow: deploy-hq.yml
  secrets_required:
    - LUCIDLABS_HQ_HOST (org secret)
    - LUCIDLABS_HQ_SSH_KEY (org secret)
    - CONVEX_DEPLOY_KEY (repo secret)
    - ANTHROPIC_API_KEY (repo secret)
```

### Bei DEDICATED:

```yaml
# .claude/DEPLOYMENT-CONFIG.md

deployment:
  target: DEDICATED
  configured: [HEUTE]

dedicated:
  terraform_env: [customer-name]
  domain: app.[customer].com
  server_name: [customer]-prod

convex:
  project: [project-name]
  team: lucid-labs

github_actions:
  workflow: deploy-dedicated.yml
  secrets_required:
    - DEDICATED_HOST (repo secret)
    - DEDICATED_SSH_KEY (repo secret)
    - CONVEX_DEPLOY_KEY (repo secret)
    - ANTHROPIC_API_KEY (repo secret)
```

### Bei LOCAL-ONLY:

```yaml
# .claude/DEPLOYMENT-CONFIG.md

deployment:
  target: LOCAL-ONLY
  configured: [HEUTE]
  note: "Kein Cloud-Deployment konfiguriert. Später änderbar."

convex:
  project: null
  note: "Lokale Entwicklung mit npx convex dev"
```

---

## Step 2e: GitHub Actions Workflow erstellen (wenn nicht LOCAL-ONLY)

Erstelle `.github/workflows/deploy.yml` basierend auf Deployment Target.

### Für LUCIDLABS-HQ:

```yaml
# .github/workflows/deploy.yml
name: Deploy to Lucid Labs HQ

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: 9
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'pnpm'
          cache-dependency-path: frontend/pnpm-lock.yaml
      - run: cd frontend && pnpm install
      - run: cd frontend && pnpm run lint
      - run: cd frontend && pnpm run type-check

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
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

          rsync -avz --delete \
            --exclude='.git' \
            --exclude='node_modules' \
            --exclude='.next' \
            ./ root@$HQ_HOST:/opt/lucidlabs/projects/$PROJECT_NAME/

          ssh root@$HQ_HOST << EOF
            cd /opt/lucidlabs/projects/$PROJECT_NAME
            docker compose -p $PROJECT_NAME up -d --build
          EOF
```

**Dokumentation:** `.claude/reference/deployment-targets.md`

---

## Step 3: Create Linear Project (if confirmed)

If user confirmed Linear project creation:

```bash
# Use Linear MCP to create project
# Team: lucid-labs-agents
# Name: [Domain] Project Name
```

**Via MCP:**
```
Create Linear project:
- Team: lucid-labs-agents
- Name: "[Domain] [project-name]"
- Description: "AI Agent project for [description]"
```

**Initial Issue:**
Create a "Project Setup" issue in Exploration status:
- Title: "Project Setup & Initial Configuration"
- Work Type: Exploration
- Status: Exploration

---

## Step 3b: n8n Workflow generieren (nur wenn n8n gewählt)

**OPTIONAL:** Dieser Schritt wird nur ausgeführt, wenn n8n im Stack gewählt wurde.

### Wann n8n?

n8n wird typischerweise gewählt wenn:
- Kunde explizit n8n-Lösung erwartet ("Wir wollen das in n8n haben")
- Wir n8n-Expertise demonstrieren wollen
- Externe Integrationen (CRM, ERP, Email) zentral sind
- Kunde selbst n8n-Workflows anpassen können soll

### n8n Workflow Template generieren

Erstelle `n8n/workflows/agent-workflow.json` im neuen Projekt:

```json
{
  "name": "[project-name] Agent Workflow",
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "trigger",
        "options": {}
      },
      "id": "webhook-trigger",
      "name": "Webhook Trigger",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [250, 300],
      "webhookId": "{{$randomUUID}}"
    },
    {
      "parameters": {
        "method": "POST",
        "url": "={{$env.MASTRA_API_URL}}/api/agents/[agent-name]/generate",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth",
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={{ JSON.stringify({ messages: [{ role: 'user', content: $json.body.message }] }) }}",
        "options": {}
      },
      "id": "call-mastra-agent",
      "name": "Call Mastra Agent",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4,
      "position": [500, 300],
      "credentials": {
        "httpHeaderAuth": {
          "id": "mastra-api-key",
          "name": "Mastra API Key"
        }
      }
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { success: true, response: $json.text } }}"
      },
      "id": "respond-webhook",
      "name": "Respond to Webhook",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [750, 300]
    }
  ],
  "connections": {
    "Webhook Trigger": {
      "main": [
        [{ "node": "Call Mastra Agent", "type": "main", "index": 0 }]
      ]
    },
    "Call Mastra Agent": {
      "main": [
        [{ "node": "Respond to Webhook", "type": "main", "index": 0 }]
      ]
    }
  },
  "settings": {
    "executionOrder": "v1"
  },
  "staticData": null,
  "meta": {
    "notes": [
      {
        "id": "note-setup",
        "type": "sticky",
        "content": "## Setup\n\n1. Setze Environment Variable `MASTRA_API_URL`\n2. Erstelle HTTP Header Auth Credential mit API Key\n3. Passe [agent-name] an deinen Mastra Agent an",
        "position": [250, 100],
        "width": 300,
        "height": 150
      },
      {
        "id": "note-endpoints",
        "type": "sticky",
        "content": "## Mastra Endpoints\n\n- `/api/agents/{name}/generate` - Agent ausführen\n- `/api/agents/{name}/stream` - Streaming Response\n- `/api/tools/{name}/execute` - Tool direkt ausführen",
        "position": [550, 100],
        "width": 300,
        "height": 150
      }
    ]
  }
}
```

### Workflow-Varianten

Je nach Projekt-Typ können weitere Workflows generiert werden:

| Projekt-Typ | Zusätzliche Workflows |
|-------------|----------------------|
| **Ticket-Klassifikation** | `ticket-classifier.json` mit Email-Trigger |
| **Document Processing** | `document-pipeline.json` mit File-Trigger |
| **CRM Integration** | `crm-sync.json` mit HubSpot/Salesforce Nodes |
| **Scheduled Tasks** | `scheduled-agent.json` mit Cron-Trigger |

### Frage den User

```
n8n wurde als Stack-Komponente gewählt.

Soll ich einen vorkonfigurierten n8n Workflow generieren?

[1] Ja, Basis-Workflow (Webhook → Agent → Response)
[2] Ja, mit Email-Trigger (für Ticket-Systeme)
[3] Ja, mit Cron-Trigger (für scheduled Tasks)
[4] Nein, ich erstelle Workflows später manuell

Wähle [1-4]:
```

### Nach Generierung

Informiere den User:

```
n8n Workflow erstellt: n8n/workflows/agent-workflow.json

Import in n8n:
1. n8n öffnen → Workflows → Import from File
2. n8n/workflows/agent-workflow.json auswählen
3. Environment Variables setzen (MASTRA_API_URL)
4. Credentials erstellen (Mastra API Key)

Dokumentation: .claude/reference/n8n-workflows.md
```

---

## Step 4: Kontext-Zusammenfassung für PRD

**WICHTIG:** Bevor die Session endet, fasse den gesammelten Kontext zusammen.

Dieser Kontext fließt in die PRD-Erstellung im neuen Projekt ein:

### 4.1 Kontext dokumentieren

Erstelle eine Zusammenfassung mit:

```
KONTEXT FÜR PRD (aus Init-Gespräch):

• Projekt-Beschreibung: [Was der User ursprünglich beschrieben hat]
• Erkannte Stufe: [1-4]
• Stack-Entscheidungen: [Was gewählt wurde und WARUM]
• Architektur-Skizzen: [Falls erstellt]
• Kunden-Anforderungen: [Spezifische Wünsche]
• Offene Fragen: [Was noch geklärt werden muss]
```

### 4.2 Handoff-Nachricht

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                  │
│  ✅ PROJEKT ERSTELLT: [project-name]                                            │
│                                                                                  │
│  Stack: [komponenten]                                                           │
│                                                                                  │
│  ═══════════════════════════════════════════════════════════════════════════   │
│                                                                                  │
│  NÄCHSTER SCHRITT:                                                              │
│                                                                                  │
│    cd ../projects/[project-name] && claude                                      │
│                                                                                  │
│  ═══════════════════════════════════════════════════════════════════════════   │
│                                                                                  │
│  IN DER NEUEN SESSION:                                                          │
│                                                                                  │
│    1. /prime                    ← Projekt-Kontext laden                         │
│    2. /create-prd               ← PRD GEMEINSAM ausspezifizieren                │
│                                                                                  │
│  KONTEXT FÜR PRD:                                                               │
│                                                                                  │
│    [Zusammenfassung aus 4.1 hier einfügen]                                      │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Wichtige Regel

**KEINE Implementierung während /init-project!**

| Erlaubt in Init | NICHT erlaubt in Init |
|-----------------|----------------------|
| Stack-Empfehlung | Code schreiben |
| Architektur-Skizzen | Workflows erstellen |
| Anforderungen sammeln | Components bauen |
| Kontext dokumentieren | Dependencies installieren |

Alles Konkrete passiert NACH dem Handoff, beginnend mit `/create-prd`.

---

## Step 5: In-Session Handoff (OHNE Exit!)

**WICHTIG:** Nach erfolgreicher Projekt-Erstellung wird ein **In-Session Handoff** durchgeführt.
Der User muss NICHT die Session beenden und eine neue starten!

### 5.1 Working Directory wechseln

```bash
cd ../projects/[project-name]
```

### 5.2 Handoff-Bestätigung anzeigen

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  ✓ SESSION HANDOFF COMPLETE                                                 │
│                                                                             │
│  ───────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  Neues Working Directory:                                                   │
│  /Users/.../projects/[project-name]                                         │
│                                                                             │
│  ⚠️  WICHTIG: Ich arbeite ab jetzt NUR in diesem Projekt.                   │
│      Das Upstream Repository (lucidlabs-agent-kit) wird NICHT verändert.    │
│                                                                             │
│  ───────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  GitHub: https://github.com/lucidlabs-hq/[project-name]                     │
│  Deployment: https://[project-name].lucidlabs.app (nach Setup)              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 Context Header für neues Projekt anzeigen

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CONTEXT                                                                    │
│  ───────                                                                    │
│                                                                             │
│  Working Directory: .../projects/[project-name]                             │
│  Repository Type:   DOWNSTREAM                                              │
│  Active Project:    [project-name]                                          │
│  PRD:               .claude/PRD.md                                          │
│  Upstream:          ../../lucidlabs-agent-kit                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.4 Boot Screen für neues Projekt anzeigen

Zeige den vollständigen Agent Kit Boot Screen (wie in `/prime`):
- ASCII Logo
- Welcome Message mit Developer-Name
- Agent Log
- Verfügbare Skills für das Projekt

### 5.5 Projekt-Status und nächste Schritte

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  PROJECT: [project-name]                                                    │
│  ─────────────────────────────                                              │
│                                                                             │
│  Status:    Initial (frisch erstellt)                                       │
│  Template:  [template-name]                                                 │
│  Stack:     [stack-komponenten]                                             │
│                                                                             │
│  ───────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  NÄCHSTE SCHRITTE                                                           │
│  ────────────────                                                           │
│                                                                             │
│  [1] /create-prd         PRD detaillieren (Problem, Users, MVP Scope)       │
│  [2] Dependencies        cd frontend && pnpm install                        │
│  [3] Services starten    docker compose -f docker-compose.dev.yml up        │
│                                                                             │
│  ───────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  Womit möchtest du anfangen?                                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Handoff-Regeln

| Regel | Beschreibung |
|-------|--------------|
| **Kein Session-Neustart** | Alles passiert in der gleichen Claude-Session |
| **Working Directory wechseln** | `cd` ins neue Projekt-Verzeichnis |
| **Explizite Bestätigung** | Handoff wird visuell bestätigt |
| **Upstream-Schutz** | Nach Handoff: KEINE Änderungen am Agent Kit mehr |
| **Projekt-Fokus** | Alle weiteren Aktionen betreffen nur das neue Projekt |

### Kernprinzip: PRD zuerst, gemeinsam

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                  │
│  WORKFLOW NACH HANDOFF                                                           │
│                                                                                  │
│  1. /create-prd         ← PRD GEMEINSAM ausspezifizieren                        │
│        │                                                                         │
│        ├─► Kontext aus Init-Gespräch einarbeiten                                │
│        ├─► Offene Fragen klären                                                 │
│        ├─► Scope definieren                                                     │
│        └─► Erst wenn PRD fertig: Implementierung                                │
│                                                                                  │
│  2. /plan-feature       ← Erst NACH PRD-Approval                                │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Warum In-Session Handoff?

| Alter Workflow (Exit) | Neuer Workflow (In-Session) |
|-----------------------|----------------------------|
| Session beenden | Nahtloser Übergang |
| Neues Terminal öffnen | Gleiche Session |
| Kontext geht verloren | Kontext bleibt erhalten |
| User muss Befehle tippen | Automatischer Wechsel |

**Der PRD ist das Agreement zwischen Developer und Stakeholder.**

---

## Key Principle

**In-Session Handoff:** Nach Projekt-Erstellung wechselt Claude automatisch ins neue Projekt-Verzeichnis und arbeitet dort weiter. Kein Session-Neustart nötig!

Nach dem Handoff:
- Alle Dateizugriffe beziehen sich auf das neue Projekt
- Das Upstream Repository (lucidlabs-agent-kit) wird NICHT mehr verändert
- `/prime` ist nicht nötig - der Kontext wurde bereits geladen

---

## Available Skills in New Project

| Skill | Description |
|-------|-------------|
| `/prime` | Load project context |
| `/create-prd` | Create Product Requirements Document |
| `/plan-feature` | Plan feature implementation |
| `/execute` | Execute an implementation plan |
| `/validate` | Run all validation checks |
| `/commit` | Create formatted commit |
| `/promote` | Promote patterns back to template |
| `/sync` | Sync updates from template |

---

## Stack Reference

Für detaillierte Stack-Dokumentation siehe:
- `.claude/agent-kit-stack-overview.md` - Vollständige Referenz
- `.claude/reference/ai-framework-choice.md` - Mastra vs Vercel AI SDK
- `.claude/reference/mcp-servers.md` - MCP Server Setup

---

## Notes

- Always use `pnpm` for package management (never npm/yarn)
- PRD is the main project-specific file
- Follow patterns in `.claude/reference/` docs
