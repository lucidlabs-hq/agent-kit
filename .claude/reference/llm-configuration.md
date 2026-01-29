# LLM Configuration Guide

> **Purpose:** Zentrale Referenz für LLM-Auswahl, Kosten, und Best Practices.

---

## Quick Decision Matrix

| Use Case | Empfohlenes Modell | Kosten/1M Token | Latenz |
|----------|-------------------|-----------------|--------|
| **Complex Reasoning** | Claude Opus 4.5 | ~$75 | Langsam |
| **General/Coding** | Claude Sonnet 4 | ~$15 | Mittel |
| **Fast/High-Volume** | Claude Haiku 3.5 | ~$1 | Schnell |
| **EU/GDPR Compliant** | Azure GPT-4o | ~$30 | Mittel |
| **Budget/Open Source** | DeepSeek V3 | ~$0.50 | Schnell |
| **Realtime/xAI** | Grok 2 | ~$10 | Schnell |

---

## Alle Modelle im Überblick

### Tier 1: Premium (Complex Reasoning)

| Provider | Modell | Input/1M | Output/1M | Context | Stärken |
|----------|--------|----------|-----------|---------|---------|
| **Anthropic** | Claude Opus 4.5 | $15 | $75 | 200K | Best reasoning, research |
| **OpenAI** | GPT-4o | $5 | $15 | 128K | Multimodal, vision |
| **OpenAI** | o1 | $15 | $60 | 200K | Deep reasoning, math |
| **Google** | Gemini 2.0 Pro | $7 | $21 | 1M | Long context |

### Tier 2: Standard (Production)

| Provider | Modell | Input/1M | Output/1M | Context | Stärken |
|----------|--------|----------|-----------|---------|---------|
| **Anthropic** | Claude Sonnet 4 | $3 | $15 | 200K | Best coding, balanced |
| **OpenAI** | GPT-4o-mini | $0.15 | $0.60 | 128K | Good value |
| **Google** | Gemini 2.0 Flash | $0.10 | $0.40 | 1M | Very fast, cheap |
| **xAI** | Grok 2 | $2 | $10 | 128K | Realtime, Twitter data |

### Tier 3: Fast/Budget (High Volume)

| Provider | Modell | Input/1M | Output/1M | Context | Stärken |
|----------|--------|----------|-----------|---------|---------|
| **Anthropic** | Claude Haiku 3.5 | $0.25 | $1.25 | 200K | Fast, cheap |
| **Google** | Gemini Flash 8B | $0.04 | $0.15 | 1M | Ultra cheap |
| **DeepSeek** | DeepSeek V3 | $0.27 | $1.10 | 64K | Open-weight, cheap |
| **DeepSeek** | DeepSeek R1 | $0.55 | $2.19 | 64K | Reasoning, cheap |

### Tier 4: Specialized

| Provider | Modell | Input/1M | Output/1M | Context | Stärken |
|----------|--------|----------|-----------|---------|---------|
| **Mistral** | Mistral Large | $2 | $6 | 128K | EU-hosted, GDPR |
| **Mistral** | Codestral | $0.30 | $0.90 | 256K | Code-spezialisiert |
| **Azure** | GPT-4o (EU) | $5 | $15 | 128K | GDPR, EU Data Residency |
| **xAI** | Grok 2 Vision | $2 | $10 | 32K | Image understanding |

---

## Empfehlungen nach Projekt-Typ

### MVP/Prototype (Stufe 1)
```
Primary:   Claude Haiku 3.5      (günstig, schnell)
Fallback:  Gemini Flash          (noch günstiger)
```

### Standard Projekt (Stufe 2)
```
Primary:   Claude Sonnet 4       (beste Balance)
Fallback:  GPT-4o-mini           (wenn Anthropic down)
Fast:      Claude Haiku 3.5      (für einfache Tasks)
```

### Enterprise (Stufe 3)
```
Complex:   Claude Opus 4.5       (für schwierige Aufgaben)
Primary:   Claude Sonnet 4       (Hauptmodell)
Fast:      Claude Haiku 3.5      (High-Volume)
Fallback:  GPT-4o                (wenn Anthropic down)
```

### GDPR/Compliance (Stufe 4)
```
Primary:   Azure GPT-4o (EU)     (GDPR-konform)
Fallback:  Mistral Large (EU)    (EU-hosted)
```

### Budget-Optimiert
```
Primary:   DeepSeek V3           (sehr günstig)
Reasoning: DeepSeek R1           (günstig + smart)
Fallback:  Gemini Flash          (Google backup)
```

---

## Portkey Gateway Konfiguration

### Multi-Provider Setup

```yaml
# HQ .env
PORTKEY_API_KEY=pk-...

# Provider Keys
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
GOOGLE_API_KEY=...
XAI_API_KEY=xai-...
DEEPSEEK_API_KEY=sk-...

# Optional: Azure (GDPR)
AZURE_OPENAI_API_KEY=...
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
```

### Fallback Konfiguration

```typescript
// Portkey Config für automatische Fallbacks
const config = {
  strategy: {
    mode: 'fallback',
  },
  targets: [
    { provider: 'anthropic', model: 'claude-sonnet-4-20250514' },
    { provider: 'openai', model: 'gpt-4o' },
    { provider: 'google', model: 'gemini-2.0-flash' },
  ],
};
```

### Load Balancing

```typescript
// Für High-Volume: Load Balancing über mehrere Provider
const config = {
  strategy: {
    mode: 'loadbalance',
  },
  targets: [
    { provider: 'anthropic', model: 'claude-haiku-3-5', weight: 50 },
    { provider: 'google', model: 'gemini-flash', weight: 30 },
    { provider: 'deepseek', model: 'deepseek-chat', weight: 20 },
  ],
};
```

---

## Kosten-Optimierung

### Strategie 1: Model Routing

```typescript
// Einfache Anfragen → günstiges Modell
// Komplexe Anfragen → teures Modell
function selectModel(complexity: 'simple' | 'medium' | 'complex') {
  switch (complexity) {
    case 'simple': return 'claude-haiku-3-5';
    case 'medium': return 'claude-sonnet-4';
    case 'complex': return 'claude-opus-4-5';
  }
}
```

### Strategie 2: Caching

```typescript
// Portkey Caching für wiederholte Anfragen
const config = {
  cache: {
    mode: 'semantic',  // Ähnliche Anfragen cachen
    ttl: 3600,         // 1 Stunde
  },
};
```

### Strategie 3: Prompt Optimization

- Kürzere Prompts = weniger Input-Tokens
- Strukturierte Outputs = weniger Output-Tokens
- System Prompts wiederverwenden

---

## Provider-Vergleich

### Anthropic (Claude)
- **Pro:** Beste Code-Qualität, längster Context, sicherste Outputs
- **Con:** Teurer als Alternativen
- **Best for:** Coding, komplexe Reasoning, Safety-kritische Apps

### OpenAI (GPT)
- **Pro:** Multimodal, schnell, gute Vision
- **Con:** Weniger konsistent bei langen Aufgaben
- **Best for:** Vision, Multimodal, Chat

### Google (Gemini)
- **Pro:** Sehr günstig, 1M Context, schnell
- **Con:** Weniger "smart" bei Reasoning
- **Best for:** Budget-Projekte, lange Dokumente

### DeepSeek
- **Pro:** Extrem günstig, Open-Weight, gute Qualität
- **Con:** China-based, möglicherweise Compliance-Issues
- **Best for:** Budget-Projekte ohne Compliance-Anforderungen

### xAI (Grok)
- **Pro:** Realtime-Daten, Twitter-Integration
- **Con:** Kleiner Context, weniger getestet
- **Best for:** Social Media, Realtime-Analyse

### Mistral
- **Pro:** EU-hosted, GDPR-konform, günstig
- **Con:** Weniger Capabilities als Claude/GPT
- **Best for:** EU-Projekte, GDPR-Compliance

### Azure OpenAI
- **Pro:** EU Data Residency, Enterprise Support
- **Con:** Gleiche Kosten wie OpenAI, Setup komplexer
- **Best for:** Enterprise, GDPR, Compliance

---

## Preisänderungen

**WICHTIG:** LLM-Preise ändern sich häufig (wöchentlich bis monatlich).

Nutze `/llm-evaluate` um aktuelle Preise zu checken:
- Holt aktuelle Preise von Provider-Websites
- Berechnet Cost/Performance Ratio
- Empfiehlt optimales Modell für Use Case

---

## Referenzen

- [Anthropic Pricing](https://www.anthropic.com/pricing)
- [OpenAI Pricing](https://openai.com/api/pricing/)
- [Google AI Pricing](https://ai.google.dev/pricing)
- [DeepSeek Pricing](https://platform.deepseek.com/api-docs/pricing)
- [xAI Pricing](https://x.ai/api)
- [Mistral Pricing](https://mistral.ai/technology/#pricing)
- [Azure OpenAI Pricing](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/openai-service/)

---

**Version:** 1.0
**Last Updated:** January 2026
