# Vercel AI SDK

> Quick prototyping with streaming chat UIs.
> Use Mastra for production agents with tools/workflows.

---

## When to Use

| Use Case | Tool |
|----------|------|
| Chat-UI, Streaming | Vercel AI SDK |
| Complex Agents, Tools | Mastra |
| Quick Prototypes | Vercel AI SDK |
| Production Workflows | Mastra |

## Installation

```bash
pnpm add ai @ai-sdk/anthropic
```

## Chat Route Example

```typescript
// app/api/chat/route.ts
import { anthropic } from "@ai-sdk/anthropic";
import { streamText } from "ai";

export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: anthropic("claude-sonnet-4-20250514"),
    messages,
  });

  return result.toDataStreamResponse();
}
```

## useChat Hook Example

```typescript
// components/Chat.tsx
"use client";
import { useChat } from "ai/react";

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit } = useChat();

  return (
    <form onSubmit={handleSubmit}>
      {messages.map((m) => (
        <div key={m.id}>{m.content}</div>
      ))}
      <input value={input} onChange={handleInputChange} />
    </form>
  );
}
```

## Vercel Deployment (Prototypes)

```bash
pnpm add -g vercel
vercel              # Deploy
vercel --prod       # Production
```

### vercel.json (optional)

```json
{
  "framework": "nextjs",
  "buildCommand": "pnpm run build",
  "installCommand": "pnpm install"
}
```

### Environment Variables

```bash
vercel env add ANTHROPIC_API_KEY
```

---

*See also: `.claude/reference/ai-framework-choice.md` for Mastra vs Vercel AI SDK decision guide.*
