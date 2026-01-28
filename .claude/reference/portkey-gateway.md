# Portkey AI Gateway

> **Purpose:** Zentrale AI Gateway für alle Projekte - Cost Tracking, Fallbacks, Caching.

---

## Was ist Portkey?

Portkey ist ein AI Gateway/Proxy, der zwischen deinen Anwendungen und LLM-APIs sitzt:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Project   │ ──▶ │   Portkey   │ ──▶ │  Anthropic  │
│   (Mastra)  │     │   Gateway   │     │   OpenAI    │
└─────────────┘     └─────────────┘     │   Azure     │
                           │            └─────────────┘
                           ▼
                    ┌─────────────┐
                    │   Logging   │
                    │   Costs     │
                    │   Metrics   │
                    └─────────────┘
```

---

## Vorteile

| Feature | Beschreibung |
|---------|--------------|
| **Cost Tracking** | Kosten pro Projekt/Request sehen |
| **Fallbacks** | Automatisch zu anderem Provider wechseln |
| **Caching** | Gleiche Requests cachen (günstiger) |
| **Rate Limiting** | Schutz vor API-Überlastung |
| **Logging** | Alle Requests protokolliert |
| **Single API Key** | Projekte brauchen nur Portkey-Key |

---

## LUCIDLABS-HQ Setup

Portkey läuft als shared Service auf dem HQ Server:

```yaml
# docker-compose.yml (HQ)
portkey:
  image: portkeyai/gateway:latest
  container_name: lucidlabs-portkey
  environment:
    - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    - OPENAI_API_KEY=${OPENAI_API_KEY}
```

**Interner Zugriff:** `http://lucidlabs-portkey:8787`

---

## In Projekten nutzen

### Mastra Konfiguration

```typescript
// mastra/src/index.ts
import { Mastra } from '@mastra/core';

const mastra = new Mastra({
  llm: {
    provider: 'anthropic',
    baseUrl: 'http://lucidlabs-portkey:8787/v1', // Portkey Gateway
    apiKey: process.env.PORTKEY_API_KEY,
  },
});
```

### Vercel AI SDK

```typescript
import { createAnthropic } from '@ai-sdk/anthropic';

const anthropic = createAnthropic({
  baseURL: 'http://lucidlabs-portkey:8787/v1',
  apiKey: process.env.PORTKEY_API_KEY,
});
```

### Direkte API Calls

```bash
curl http://lucidlabs-portkey:8787/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "x-portkey-api-key: $PORTKEY_API_KEY" \
  -H "x-portkey-provider: anthropic" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

---

## Environment Variables

### HQ Server (.env)

```bash
# Echte API Keys (nur auf HQ Server)
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
```

### Projekt (.env)

```bash
# Projekte nutzen nur Portkey
PORTKEY_API_KEY=pk-...  # Optional, für Tracking
PORTKEY_BASE_URL=http://lucidlabs-portkey:8787
```

---

## Cost Tracking

### Portkey Dashboard

Falls externes Dashboard gewünscht:
1. Account auf https://portkey.ai erstellen
2. API Key holen
3. In HQ .env eintragen: `PORTKEY_API_KEY=pk-...`

### Lokales Logging

Logs in Docker:
```bash
docker logs lucidlabs-portkey
```

---

## Fallback Konfiguration

```typescript
// Automatisch zu OpenAI wechseln wenn Anthropic down
const config = {
  strategy: {
    mode: 'fallback',
  },
  targets: [
    { provider: 'anthropic', model: 'claude-sonnet-4-20250514' },
    { provider: 'openai', model: 'gpt-4o' },
  ],
};
```

---

## Projekte aktualisieren

Statt direkter API Keys:

```yaml
# ALT (direkte Keys)
environment:
  - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}

# NEU (via Portkey)
environment:
  - LLM_BASE_URL=http://lucidlabs-portkey:8787/v1
  - LLM_PROVIDER=anthropic
```

---

## Referenzen

- [Portkey Documentation](https://docs.portkey.ai/)
- [Portkey Gateway GitHub](https://github.com/Portkey-AI/gateway)
- [Self-Hosted Setup](https://docs.portkey.ai/docs/self-hosting)

---

**Version:** 1.0
**Last Updated:** January 2026
