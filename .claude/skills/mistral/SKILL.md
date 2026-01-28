---
name: mistral
description: Setup Mistral AI integration for a project. Use for EU-friendly, fast, cost-effective LLM access with PDF/document analysis.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
argument-hint: [setup|pdf]
---

# Mistral AI Integration

Setup Mistral AI für schnelle, GDPR-freundliche LLM-Nutzung mit PDF-Analyse.

## Warum Mistral?

| Vorteil | Details |
|---------|---------|
| **EU-Unternehmen** | Paris-basiert, GDPR-freundlich |
| **Schnell** | Niedrige Latenz, hoher Throughput |
| **Günstig** | Gutes Preis-Leistungs-Verhältnis |
| **PDF-Analyse** | Pixtral-Modelle für Vision/Dokumente |

## Argument: $ARGUMENTS

- `setup` - Vollständige Mistral-Integration einrichten
- `pdf` - Nur PDF-Analyse Setup (schnell)
- Kein Argument - Interaktiv fragen

---

## Step 1: API Key Setup

### 1.1 Mistral API Key holen

```
1. Gehe zu: https://console.mistral.ai/
2. Erstelle Account oder Login
3. API Keys → Create new key
4. Key sicher speichern
```

### 1.2 Environment Variable

Füge zu `.env.local` hinzu:

```env
# Mistral AI
MISTRAL_API_KEY=your-mistral-api-key
```

---

## Step 2: Package Installation

### Für Mastra-Projekte:

```bash
cd mastra
pnpm add @ai-sdk/mistral
```

### Für Vercel AI SDK Projekte:

```bash
cd frontend
pnpm add @ai-sdk/mistral
```

---

## Step 3: Mistral Provider Setup

### 3.1 Provider-Datei erstellen

Erstelle `frontend/lib/ai/mistral.ts`:

```typescript
/**
 * Mistral AI Provider Configuration
 * EU-based LLM provider for GDPR-friendly AI applications
 */

import { createMistral } from "@ai-sdk/mistral";

// Initialize Mistral provider
export const mistral = createMistral({
  apiKey: process.env.MISTRAL_API_KEY,
});

// Available models
export const mistralModels = {
  // Text models
  large: mistral("mistral-large-latest"),      // Best quality
  medium: mistral("mistral-medium-latest"),    // Balanced
  small: mistral("mistral-small-latest"),      // Fast & cheap

  // Vision/Document models (PDF analysis)
  pixtralLarge: mistral("pixtral-large-latest"), // Best for documents
  pixtral: mistral("pixtral-12b-2409"),          // Fast vision

  // Code model
  codestral: mistral("codestral-latest"),      // Code generation
} as const;

// Model selection helper
export type MistralModelKey = keyof typeof mistralModels;

export function getMistralModel(key: MistralModelKey = "large") {
  return mistralModels[key];
}
```

---

## Step 4: PDF/Document Analysis

### 4.1 PDF Analysis Utility

Erstelle `frontend/lib/ai/pdf-analyzer.ts`:

```typescript
/**
 * PDF Analysis with Mistral Pixtral
 * Analyzes PDF documents using vision capabilities
 */

import { generateText } from "ai";
import { mistralModels } from "./mistral";

interface PDFAnalysisResult {
  summary: string;
  keyPoints: string[];
  rawResponse: string;
}

interface AnalyzePDFOptions {
  prompt?: string;
  model?: "pixtralLarge" | "pixtral";
}

/**
 * Analyze a PDF document using Mistral Pixtral
 *
 * @param pdfBase64 - Base64 encoded PDF or image
 * @param options - Analysis options
 */
export async function analyzePDF(
  pdfBase64: string,
  options: AnalyzePDFOptions = {}
): Promise<PDFAnalysisResult> {
  const {
    prompt = "Analysiere dieses Dokument. Fasse den Inhalt zusammen und extrahiere die wichtigsten Punkte.",
    model = "pixtralLarge",
  } = options;

  const result = await generateText({
    model: mistralModels[model],
    messages: [
      {
        role: "user",
        content: [
          {
            type: "text",
            text: prompt,
          },
          {
            type: "image",
            image: pdfBase64,
          },
        ],
      },
    ],
  });

  // Parse response for structured output
  const lines = result.text.split("\n").filter(Boolean);

  return {
    summary: result.text,
    keyPoints: lines.slice(0, 5), // First 5 lines as key points
    rawResponse: result.text,
  };
}

/**
 * Analyze multiple pages of a PDF
 */
export async function analyzeMultiPagePDF(
  pages: string[], // Array of base64 encoded pages
  prompt?: string
): Promise<PDFAnalysisResult[]> {
  const results = await Promise.all(
    pages.map((page) => analyzePDF(page, { prompt }))
  );
  return results;
}
```

### 4.2 PDF Upload API Route

Erstelle `frontend/app/api/analyze-pdf/route.ts`:

```typescript
/**
 * PDF Analysis API Route
 * POST /api/analyze-pdf
 */

import { NextRequest, NextResponse } from "next/server";
import { analyzePDF } from "@/lib/ai/pdf-analyzer";

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get("file") as File;
    const prompt = formData.get("prompt") as string | null;

    if (!file) {
      return NextResponse.json(
        { error: "No file provided" },
        { status: 400 }
      );
    }

    // Convert file to base64
    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);
    const base64 = buffer.toString("base64");
    const mimeType = file.type || "application/pdf";
    const dataUrl = `data:${mimeType};base64,${base64}`;

    // Analyze with Mistral Pixtral
    const result = await analyzePDF(dataUrl, {
      prompt: prompt || undefined,
    });

    return NextResponse.json(result);
  } catch (error) {
    console.error("[analyze-pdf] Error:", error);
    return NextResponse.json(
      { error: "Failed to analyze PDF" },
      { status: 500 }
    );
  }
}

export const config = {
  api: {
    bodyParser: false,
  },
};
```

---

## Step 5: Mastra Integration (Optional)

### 5.1 Mistral Tool für Mastra

Erstelle `mastra/src/tools/mistral-pdf.ts`:

```typescript
/**
 * Mistral PDF Analysis Tool for Mastra Agents
 */

import { createTool } from "@mastra/core";
import { z } from "zod";

export const analyzePDFTool = createTool({
  id: "analyze-pdf",
  description: "Analyze a PDF document using Mistral Pixtral vision model",
  inputSchema: z.object({
    documentUrl: z.string().describe("URL or base64 of the PDF/image"),
    question: z.string().optional().describe("Specific question about the document"),
  }),
  outputSchema: z.object({
    analysis: z.string(),
    confidence: z.number(),
  }),
  execute: async ({ context }) => {
    const { documentUrl, question } = context;

    // Call Mistral Pixtral API
    const response = await fetch("https://api.mistral.ai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${process.env.MISTRAL_API_KEY}`,
      },
      body: JSON.stringify({
        model: "pixtral-large-latest",
        messages: [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: question || "Analysiere dieses Dokument detailliert.",
              },
              {
                type: "image_url",
                image_url: { url: documentUrl },
              },
            ],
          },
        ],
      }),
    });

    const data = await response.json();

    return {
      analysis: data.choices[0]?.message?.content || "No analysis available",
      confidence: 0.9,
    };
  },
});
```

---

## Step 6: Usage Examples

### 6.1 Simple Text Generation

```typescript
import { generateText } from "ai";
import { getMistralModel } from "@/lib/ai/mistral";

const result = await generateText({
  model: getMistralModel("large"),
  prompt: "Erkläre mir die DSGVO in einfachen Worten.",
});

console.log(result.text);
```

### 6.2 PDF Analysis

```typescript
import { analyzePDF } from "@/lib/ai/pdf-analyzer";

// From file input
const file = event.target.files[0];
const reader = new FileReader();
reader.onload = async (e) => {
  const base64 = e.target.result as string;
  const analysis = await analyzePDF(base64, {
    prompt: "Was sind die Hauptpunkte dieses Vertrags?",
  });
  console.log(analysis.summary);
};
reader.readAsDataURL(file);
```

### 6.3 Streaming Chat

```typescript
import { streamText } from "ai";
import { getMistralModel } from "@/lib/ai/mistral";

const result = await streamText({
  model: getMistralModel("medium"),
  messages: [
    { role: "user", content: "Schreibe eine Produktbeschreibung für..." },
  ],
});

for await (const chunk of result.textStream) {
  process.stdout.write(chunk);
}
```

---

## Mistral Models Übersicht

| Model | Use Case | Preis | Speed |
|-------|----------|-------|-------|
| `mistral-large-latest` | Complex tasks, reasoning | $$$ | Medium |
| `mistral-medium-latest` | Balanced quality/speed | $$ | Fast |
| `mistral-small-latest` | Simple tasks, high volume | $ | Very Fast |
| `pixtral-large-latest` | **PDF/Document analysis** | $$$ | Medium |
| `pixtral-12b-2409` | Fast vision tasks | $$ | Fast |
| `codestral-latest` | Code generation | $$ | Fast |

---

## Checklist

Nach Abschluss:

- [ ] `MISTRAL_API_KEY` in `.env.local`
- [ ] `@ai-sdk/mistral` installiert
- [ ] Provider-Datei erstellt (`lib/ai/mistral.ts`)
- [ ] PDF-Analyzer erstellt (wenn PDF-Analyse gewünscht)
- [ ] API Route erstellt (wenn Upload gewünscht)
- [ ] Test mit einfachem Prompt

---

## Troubleshooting

| Problem | Lösung |
|---------|--------|
| "Invalid API key" | Key in `.env.local` prüfen, Server neu starten |
| "Model not found" | Model-Namen auf aktuelle Version prüfen |
| PDF-Analyse fehlerhaft | Pixtral-Large für bessere Qualität nutzen |
| Rate Limit | Mistral hat großzügige Limits, aber bei Bedarf throttling einbauen |

---

## Links

- Mistral Console: https://console.mistral.ai/
- API Documentation: https://docs.mistral.ai/
- Pixtral (Vision): https://docs.mistral.ai/capabilities/vision/
- Pricing: https://mistral.ai/technology/#pricing
