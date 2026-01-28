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

## Step 0: Intelligente Stack-Empfehlung

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

### Optional Components

```
┌─────────────────────────────────────────────────────────────────┐
│  LLM PROVIDER (zusätzlich zu Claude)                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [y/N] Mistral      - EU-basiert, schnell, günstig, PDF-Analyse  │
│  [y/N] Azure OpenAI - GDPR-konform, EU Data Residency            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  OPTIONAL COMPONENTS                                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [y/N] Portkey      - LLM Gateway, Cost Tracking, Guardrails     │
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

## Step 4: Provide Next Steps

After the script completes, tell the user:

```markdown
## Projekt erstellt

**Projekt:** [project-name]
**Pfad:** ../projects/[project-name]/
**Stack:** [gewählte Komponenten auflisten]

### WICHTIG: Neue Claude Session starten

Claude Sessions sind verzeichnisgebunden. Um im neuen Projekt zu arbeiten:

**Terminal:**
\`\`\`bash
cd ../projects/[project-name] && claude
\`\`\`

**VS Code:**
1. Öffne den Ordner `../projects/[project-name]/` in VS Code
2. Starte Claude über die Command Palette

### Nach dem Start der neuen Session:

1. Dependencies installieren:
   \`\`\`bash
   cd frontend && pnpm install
   \`\`\`

2. Kontext laden:
   \`\`\`
   /prime
   \`\`\`

3. PRD erstellen:
   \`\`\`
   /create-prd
   \`\`\`

4. Erste Feature planen:
   \`\`\`
   /plan-feature [feature-name]
   \`\`\`
```

---

## Step 5: Session beenden und Handoff

**WICHTIG:** Nach erfolgreicher Projekt-Erstellung MUSS die Claude Session beendet werden.

### 5.1 Handoff-Nachricht ausgeben

Führe diesen Bash-Befehl aus, um eine Nachricht zu hinterlassen die NACH dem Claude-Exit sichtbar bleibt:

```bash
echo ""
echo "───────────────────────────────────────────────────────────────────────────────"
echo ""
echo "  PROJEKT ERSTELLT: [project-name]"
echo ""
echo "  Nächster Schritt:"
echo ""
echo "    cd ../projects/[project-name] && claude"
echo ""
echo "  Dann in der neuen Session:"
echo ""
echo "    /prime"
echo ""
echo "───────────────────────────────────────────────────────────────────────────────"
echo ""
```

### 5.2 Session beenden

Nach der Ausgabe der Handoff-Nachricht:

1. Sage dem User: "Projekt erstellt. Beende jetzt diese Session."
2. Verwende `/exit` oder beende die Session
3. Der User landet im Terminal mit der Handoff-Nachricht

### Ablauf

```
Projekt erstellt
     ↓
Handoff-Nachricht (echo)
     ↓
Session beenden (/exit)
     ↓
User sieht im Terminal:
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│  PROJEKT ERSTELLT: customer-portal                                              │
│                                                                                 │
│  Nächster Schritt:                                                              │
│                                                                                 │
│    cd ../projects/customer-portal && claude                                     │
│                                                                                 │
│  Dann in der neuen Session:                                                     │
│                                                                                 │
│    /prime                                                                       │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Key Principle

**Claude arbeitet immer im aktuellen Verzeichnis.** Eine Session die in `lucidlabs-agent-kit/` gestartet wurde, arbeitet am Template. Für Projekt-Arbeit muss eine neue Session im Projekt-Verzeichnis gestartet werden.

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
