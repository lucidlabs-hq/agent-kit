# n8n Workflow Templates

n8n is a workflow automation platform for connecting services and APIs.

## Overview

This directory contains pre-built workflow templates:
- `agent-trigger.json` - Webhook to trigger Mastra agent
- `scheduled-job.json` - Scheduled task processing

## Setup

### Self-Hosted (Recommended)

n8n runs as a Docker container:

```bash
# Using Docker Compose (see root docker-compose.yml)
docker-compose up n8n

# Or standalone
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  n8nio/n8n:latest
```

### Cloud

For quick prototyping, use [n8n.cloud](https://n8n.cloud).

## Importing Workflows

1. Open n8n at `http://localhost:5678`
2. Go to Workflows > Import from File
3. Select a workflow JSON from `workflows/`
4. Configure credentials and environment variables

## Environment Variables

Set these in n8n:

```env
# Mastra Agent Server
MASTRA_URL=http://mastra:4000

# Convex Backend
CONVEX_URL=https://your-project.convex.cloud

# Or for self-hosted Convex
CONVEX_URL=http://convex:3210
```

## Workflow Templates

### Agent Trigger (agent-trigger.json)

```
Webhook → Mastra Agent → Store in Convex → Respond
```

**Use case:** Trigger AI agent processing from external systems.

**Webhook endpoint:** `POST /webhook/agent-trigger`

**Payload:**
```json
{
  "message": "User input to process",
  "context": {
    "userId": "user-123",
    "taskId": "task-456"
  }
}
```

### Scheduled Job (scheduled-job.json)

```
Schedule → Fetch Tasks → Process Each → Update Status
```

**Use case:** Periodic processing of pending tasks.

**Default:** Runs every hour.

## Creating Custom Workflows

### 1. Basic Structure

```json
{
  "name": "My Workflow",
  "nodes": [...],
  "connections": {...},
  "settings": {
    "executionOrder": "v1"
  }
}
```

### 2. Common Nodes

| Node | Purpose |
|------|---------|
| `webhook` | HTTP trigger |
| `scheduleTrigger` | Cron/interval trigger |
| `httpRequest` | Call external APIs |
| `code` | Custom JavaScript |
| `if` | Conditional branching |
| `splitInBatches` | Process items one by one |

### 3. Connecting to Mastra

```json
{
  "parameters": {
    "method": "POST",
    "url": "={{ $env.MASTRA_URL }}/api/agents/{{ $json.agentId }}/execute",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ input: $json.message }) }}"
  },
  "type": "n8n-nodes-base.httpRequest"
}
```

### 4. Connecting to Convex

**Query:**
```json
{
  "url": "={{ $env.CONVEX_URL }}/api/query",
  "queryParameters": {
    "path": "functions/queries:listTasks",
    "args": "{\"status\":\"pending\"}"
  }
}
```

**Mutation:**
```json
{
  "url": "={{ $env.CONVEX_URL }}/api/mutation",
  "body": {
    "path": "functions/mutations:createTask",
    "args": { "title": "New Task" }
  }
}
```

## Read-Only Access for Clients

To give clients view-only access:

1. Create a separate user role in n8n
2. Use Caddy/nginx to block mutation endpoints
3. Share workflow visualizations only

Example Caddy config:
```caddyfile
@readonly {
  path /rest/workflows*
  not method GET HEAD OPTIONS
}
respond @readonly 403
```

## Best Practices

1. **Use environment variables** for URLs and credentials
2. **Add error handling** with try/catch nodes
3. **Log important steps** for debugging
4. **Test with small batches** before full execution
5. **Set execution timeout** for long-running workflows

## Documentation

- [n8n Docs](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [Workflow Examples](https://n8n.io/workflows/)
