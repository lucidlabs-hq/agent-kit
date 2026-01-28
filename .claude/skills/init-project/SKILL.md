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
