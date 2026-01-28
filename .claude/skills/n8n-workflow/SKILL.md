---
name: n8n-workflow
description: Generate and manage n8n workflows for AI agents. Creates automation workflows that complement Mastra agents.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, WebFetch
argument-hint: [create|list|sync]
---

# n8n Workflow Skill

Generiere n8n Workflows passend zu deinen Mastra Agents.

## Konzept

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AGENT + WORKFLOW ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   MASTRA AGENT                    N8N WORKFLOW                       │
│   ────────────                    ────────────                       │
│   • AI Reasoning                  • Scheduled Triggers               │
│   • Tool Execution                • Webhook Endpoints                │
│   • Context Management            • Data Transformations             │
│   • Decision Making               • External Integrations            │
│                                                                      │
│   ┌─────────────┐                ┌─────────────┐                    │
│   │             │   triggers     │             │                    │
│   │   Agent     │◄──────────────►│  Workflow   │                    │
│   │             │   calls        │             │                    │
│   └─────────────┘                └─────────────┘                    │
│                                                                      │
│   WHEN TO USE WHAT:                                                  │
│   • Agent: Complex reasoning, multi-step decisions                   │
│   • Workflow: Scheduled tasks, webhooks, integrations                │
│   • Both: Agent decides → Workflow executes                          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## MCP Integration

### n8n als MCP Server (empfohlen)

n8n hat native MCP-Unterstützung via **MCP Server Trigger** Node:

```bash
# In n8n: MCP Server Trigger Node hinzufügen
# Workflow als Tool für Claude/Agents exponieren
```

**Vorteile:**
- Workflows werden zu Tools für Claude
- Bidirektional: n8n → Agent, Agent → n8n
- Keine extra Infrastruktur

### n8n MCP Client für Claude

```bash
# Community MCP Server für n8n Workflows
claude mcp add n8n-server -- npx @anthropic-ai/mcp-server-n8n
```

Oder mit dem populären czlonkowski/n8n-mcp:

```json
{
  "mcpServers": {
    "n8n": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-n8n"],
      "env": {
        "N8N_HOST": "https://n8n.example.com",
        "N8N_API_KEY": "your-api-key"
      }
    }
  }
}
```

---

## Commands

### `/n8n-workflow create [agent-name]`

Generiere n8n Workflow Template für einen Mastra Agent.

**Workflow:**

1. Analysiere Agent Definition (Mastra)
2. Identifiziere benötigte Integrationen
3. Generiere n8n Workflow JSON
4. Speichere in `n8n/workflows/`

**Output:**

```json
{
  "name": "Customer Support Agent Triggers",
  "nodes": [
    {
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "position": [240, 300],
      "parameters": {
        "httpMethod": "POST",
        "path": "agent-trigger"
      }
    },
    {
      "name": "Process Request",
      "type": "n8n-nodes-base.code",
      "position": [460, 300],
      "parameters": {
        "jsCode": "// Process and route to agent"
      }
    }
  ]
}
```

### `/n8n-workflow list`

Liste alle Workflows in `n8n/workflows/`.

### `/n8n-workflow sync`

Synchronisiere Workflows mit n8n Instance.

---

## Workflow Patterns

### Pattern 1: Agent Trigger

Workflow startet Agent-Ausführung.

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Schedule │ ─► │ Prepare  │ ─► │ Call     │ ─► │ Process  │
│ Trigger  │    │ Context  │    │ Mastra   │    │ Result   │
└──────────┘    └──────────┘    │ Agent    │    └──────────┘
                                └──────────┘
```

**Use Cases:**
- Täglicher Report-Agent
- Periodische Datenanalyse
- Scheduled Cleanup

### Pattern 2: Agent → Workflow

Agent delegiert Aufgabe an Workflow.

```
┌──────────┐    ┌──────────┐    ┌──────────┐
│ Mastra   │ ─► │ n8n      │ ─► │ External │
│ Agent    │    │ Workflow │    │ Systems  │
└──────────┘    └──────────┘    └──────────┘
```

**Use Cases:**
- CRM Update nach Agent-Entscheidung
- Email versenden
- Slack Notification

### Pattern 3: Webhook → Agent → Response

End-to-end Request Processing.

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Webhook  │ ─► │ Mastra   │ ─► │ n8n      │ ─► │ Response │
│ Request  │    │ Agent    │    │ Actions  │    │ Webhook  │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
```

**Use Cases:**
- Chatbot mit externen Aktionen
- Support-Ticket Routing + Actions
- Approval Workflows

---

## Workflow Templates

### Template: Daily Report Agent

```json
{
  "name": "Daily Report Agent",
  "nodes": [
    {
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.scheduleTrigger",
      "parameters": {
        "rule": { "interval": [{ "field": "hours", "hoursInterval": 24 }] }
      }
    },
    {
      "name": "Fetch Data",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "={{$env.API_URL}}/metrics"
      }
    },
    {
      "name": "Call Agent",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "POST",
        "url": "={{$env.MASTRA_URL}}/agents/report-generator/run",
        "body": "={{ JSON.stringify($json) }}"
      }
    },
    {
      "name": "Send Report",
      "type": "n8n-nodes-base.slack",
      "parameters": {
        "channel": "#reports",
        "text": "={{ $json.report }}"
      }
    }
  ]
}
```

### Template: Webhook → Agent Router

```json
{
  "name": "Agent Router",
  "nodes": [
    {
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "httpMethod": "POST",
        "path": "agent-router"
      }
    },
    {
      "name": "Route Decision",
      "type": "n8n-nodes-base.switch",
      "parameters": {
        "rules": {
          "rules": [
            { "value": "support", "output": 0 },
            { "value": "sales", "output": 1 }
          ]
        }
      }
    },
    {
      "name": "Support Agent",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "POST",
        "url": "={{$env.MASTRA_URL}}/agents/support/run"
      }
    },
    {
      "name": "Sales Agent",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "POST",
        "url": "={{$env.MASTRA_URL}}/agents/sales/run"
      }
    }
  ]
}
```

---

## File Structure

```
n8n/
├── workflows/
│   ├── templates/               # Wiederverwendbare Templates
│   │   ├── daily-report.json
│   │   ├── webhook-router.json
│   │   └── notification.json
│   │
│   └── agents/                  # Agent-spezifische Workflows
│       ├── support-agent.json
│       └── sales-agent.json
│
└── README.md
```

---

## Best Practices

### 1. Agent für Reasoning, Workflow für Actions

```
❌ Agent macht HTTP Calls direkt
✅ Agent entscheidet → Workflow führt aus
```

### 2. Idempotente Workflows

```
❌ Workflow verändert State ohne Check
✅ Workflow prüft vor Aktion
```

### 3. Error Handling

```json
{
  "name": "Error Handler",
  "type": "n8n-nodes-base.errorTrigger"
}
```

### 4. Credentials in n8n

```
❌ API Keys in Workflow JSON
✅ n8n Credentials verwenden
```

---

## Environment Variables

```env
# n8n Instance
N8N_HOST=https://n8n.example.com
N8N_API_KEY=your-api-key

# Mastra (für Callbacks)
MASTRA_URL=https://app.example.com/api/mastra
```

---

## Referenzen

- [n8n Documentation](https://docs.n8n.io/)
- [n8n MCP Server Trigger](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-langchain.mcptrigger/)
- [czlonkowski/n8n-mcp](https://github.com/czlonkowski/n8n-mcp)
- [Mastra Integration](../reference/mastra-best-practices.md)
