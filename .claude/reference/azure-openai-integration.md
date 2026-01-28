# Azure OpenAI Integration (Optional)

> GDPR-konforme LLM-Nutzung über Microsoft Azure

## Übersicht

Azure OpenAI bietet dieselben OpenAI-Modelle, aber gehostet in europäischen Azure-Rechenzentren. Ideal für Projekte mit strengen Datenschutzanforderungen.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AZURE OPENAI ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   [ User / Browser ]                                                 │
│          │                                                           │
│          ▼                                                           │
│   [ Next.js UI ]                                                     │
│          │                                                           │
│          ▼                                                           │
│   [ Convex Realtime Backend ]                                        │
│          │                                                           │
│          │  (Trigger / Action)                                       │
│          ▼                                                           │
│   [ Mastra Agent ]                                                   │
│          │                                                           │
│          ▼                                                           │
│   ┌──────────────────────────────────────────────────────────┐      │
│   │              AZURE OPENAI (EU Region)                     │      │
│   │                                                           │      │
│   │   • GPT-4o, GPT-4 Turbo                                  │      │
│   │   • Embeddings (ada-002)                                 │      │
│   │   • GDPR-konform                                         │      │
│   │   • Data Processing Agreement (DPA)                      │      │
│   │                                                           │      │
│   └──────────────────────────────────────────────────────────┘      │
│          │                                                           │
│          ▼                                                           │
│   [ Agent Result ]                                                   │
│          │                                                           │
│          ▼                                                           │
│   [ Convex Storage + Vector Index ]                                  │
│          │                                                           │
│          ▼                                                           │
│   [ UI Updates in Realtime ]                                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Wann Azure OpenAI nutzen?

| Anforderung | Standard (Anthropic/OpenAI) | Azure OpenAI |
|-------------|----------------------------|--------------|
| GDPR-Konformität | 🟡 US-basiert | ✅ EU Hosting |
| Data Processing Agreement | 🟡 Standard | ✅ Enterprise DPA |
| Datenresidenz EU | ❌ | ✅ West Europe |
| Enterprise Compliance | 🟡 | ✅ ISO 27001, SOC2 |
| Preis | ✅ Günstiger | 🟡 Teurer |
| Modellauswahl | ✅ Claude, GPT | 🟡 Nur GPT |

**Empfehlung:** Azure OpenAI für Projekte mit:
- Personenbezogenen Daten (DSGVO)
- Gesundheitsdaten
- Finanzdaten
- Enterprise-Kunden mit Compliance-Anforderungen

---

## Setup

### 1. Azure Resource erstellen

```bash
# Azure CLI
az cognitiveservices account create \
  --name "lucidlabs-openai" \
  --resource-group "lucidlabs-ai" \
  --kind "OpenAI" \
  --sku "S0" \
  --location "westeurope"
```

### 2. Model Deployment

```bash
# GPT-4o deployen
az cognitiveservices account deployment create \
  --name "lucidlabs-openai" \
  --resource-group "lucidlabs-ai" \
  --deployment-name "gpt-4o" \
  --model-name "gpt-4o" \
  --model-version "2024-05-13" \
  --model-format "OpenAI"
```

### 3. Credentials

```env
# .env
AZURE_OPENAI_API_KEY=your-api-key
AZURE_OPENAI_ENDPOINT=https://lucidlabs-openai.openai.azure.com/
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4o
AZURE_OPENAI_API_VERSION=2024-02-15-preview
```

---

## Integration

### Mastra Agent mit Azure

```typescript
// mastra/src/agents/support-agent.ts
import { Agent } from '@mastra/core';
import { azureOpenai } from '@mastra/azure-openai';

export const supportAgent = new Agent({
  name: 'support-agent',
  instructions: `You are a helpful customer support agent.`,
  model: azureOpenai({
    deploymentName: process.env.AZURE_OPENAI_DEPLOYMENT_NAME!,
    apiKey: process.env.AZURE_OPENAI_API_KEY!,
    endpoint: process.env.AZURE_OPENAI_ENDPOINT!,
    apiVersion: process.env.AZURE_OPENAI_API_VERSION!,
  }),
  tools: [createTicketTool],
});
```

### Vercel AI SDK mit Azure

```typescript
// app/api/chat/route.ts
import { AzureOpenAI } from 'openai';
import { OpenAIStream, StreamingTextResponse } from 'ai';

const client = new AzureOpenAI({
  apiKey: process.env.AZURE_OPENAI_API_KEY,
  endpoint: process.env.AZURE_OPENAI_ENDPOINT,
  apiVersion: process.env.AZURE_OPENAI_API_VERSION,
});

export async function POST(req: Request) {
  const { messages } = await req.json();

  const response = await client.chat.completions.create({
    model: process.env.AZURE_OPENAI_DEPLOYMENT_NAME!,
    messages,
    stream: true,
  });

  const stream = OpenAIStream(response);
  return new StreamingTextResponse(stream);
}
```

### LiteLLM Proxy (Empfohlen für Multi-Provider)

```yaml
# litellm_config.yaml
model_list:
  - model_name: gpt-4o
    litellm_params:
      model: azure/gpt-4o
      api_base: ${AZURE_OPENAI_ENDPOINT}
      api_key: ${AZURE_OPENAI_API_KEY}
      api_version: ${AZURE_OPENAI_API_VERSION}

  - model_name: claude-sonnet
    litellm_params:
      model: anthropic/claude-sonnet-4-20250514
      api_key: ${ANTHROPIC_API_KEY}

# Fallback: Azure → Anthropic
router_settings:
  routing_strategy: simple-shuffle
  fallbacks:
    - gpt-4o: [claude-sonnet]
```

---

## Provider-Auswahl Strategie

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PROVIDER SELECTION STRATEGY                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌───────────────────────────────────────────────────────────┐     │
│   │                    PROJECT REQUIREMENTS                    │     │
│   │                                                            │     │
│   │   GDPR/Compliance?  ──────────► YES ──► Azure OpenAI      │     │
│   │         │                                                  │     │
│   │         NO                                                 │     │
│   │         │                                                  │     │
│   │         ▼                                                  │     │
│   │   Complex Reasoning? ─────────► YES ──► Claude (Anthropic)│     │
│   │         │                                                  │     │
│   │         NO                                                 │     │
│   │         │                                                  │     │
│   │         ▼                                                  │     │
│   │   High Volume/Speed? ─────────► YES ──► GPT-4o / Haiku    │     │
│   │         │                                                  │     │
│   │         NO                                                 │     │
│   │         │                                                  │     │
│   │         ▼                                                  │     │
│   │   Default ────────────────────────────► Claude Sonnet     │     │
│   │                                                            │     │
│   └───────────────────────────────────────────────────────────┘     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Kostenvergleich (Stand Januar 2026)

| Model | Provider | Input (1M tokens) | Output (1M tokens) |
|-------|----------|-------------------|-------------------|
| GPT-4o | OpenAI | $2.50 | $10.00 |
| GPT-4o | Azure | $2.50 | $10.00 |
| Claude Sonnet | Anthropic | $3.00 | $15.00 |
| Claude Haiku | Anthropic | $0.25 | $1.25 |

**Hinweis:** Azure hat oft Enterprise-Rabatte bei höherem Volumen.

---

## Verfügbare Modelle (Azure West Europe)

| Model | Verfügbar | Use Case |
|-------|-----------|----------|
| GPT-4o | ✅ | General purpose, fast |
| GPT-4 Turbo | ✅ | Complex reasoning |
| GPT-4 | ✅ | Legacy compatibility |
| GPT-3.5 Turbo | ✅ | High volume, low cost |
| text-embedding-ada-002 | ✅ | Vector embeddings |
| DALL-E 3 | ✅ | Image generation |
| Whisper | ✅ | Speech-to-text |

---

## Best Practices

### 1. Fallback-Strategie

```typescript
// Bei Azure-Ausfall auf Anthropic fallback
const providers = [
  { name: 'azure', priority: 1 },
  { name: 'anthropic', priority: 2 },
];
```

### 2. Region-spezifische Konfiguration

```typescript
// config/providers.ts
export const getProvider = (region: 'eu' | 'us') => {
  if (region === 'eu') {
    return azureOpenaiProvider;
  }
  return anthropicProvider;
};
```

### 3. Compliance-Logging

```typescript
// Log welcher Provider für welchen Request genutzt wurde
logger.info('LLM Request', {
  provider: 'azure',
  region: 'westeurope',
  model: 'gpt-4o',
  customerId: ctx.customerId,
  dataClassification: 'pii',
});
```

---

## Environment Variables

```env
# Azure OpenAI (Optional - für GDPR-Projekte)
AZURE_OPENAI_API_KEY=your-api-key
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4o
AZURE_OPENAI_API_VERSION=2024-02-15-preview

# Anthropic (Standard)
ANTHROPIC_API_KEY=sk-ant-...

# OpenAI (Optional)
OPENAI_API_KEY=sk-...
```

---

## Referenzen

- [Azure OpenAI Documentation](https://learn.microsoft.com/azure/ai-services/openai/)
- [Azure OpenAI Pricing](https://azure.microsoft.com/pricing/details/cognitive-services/openai-service/)
- [GDPR & Azure](https://azure.microsoft.com/explore/trusted-cloud/privacy/gdpr)
- [Mastra Azure Provider](https://mastra.ai/docs/providers/azure-openai)
