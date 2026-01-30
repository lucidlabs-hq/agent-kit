# Convex Self-Hosted Setup

> Best Practices für Convex mit selbst-gehostetem Backend

---

## Übersicht

Convex kann sowohl in der Cloud als auch self-hosted betrieben werden. Für Datenschutz und Kontrolle nutzen wir self-hosted Docker Container.

**Problem:** Das Convex CLI braucht Cloud-Login für Codegen, auch bei self-hosted.

**Lösung:** Einmalig Cloud-Login, dann lokales Backend nutzen.

---

## ⚠️ Project Isolation (MANDATORY)

**KRITISCH: Jedes Projekt MUSS seine eigene Convex-Instanz haben!**

### Warum Isolation?

- **Schema-Konflikte:** Verschiedene Projekte haben unterschiedliche Tabellen-Definitionen
- **Daten-Überschreibung:** Shared Instance führt zu unerwarteten Daten-Kollisionen
- **Migrations-Probleme:** Schema-Änderungen eines Projekts brechen andere Projekte
- **Debugging-Chaos:** Unklar welche Daten zu welchem Projekt gehören

### Regel

```
1 Projekt = 1 Convex Backend = 1 Convex Dashboard = Eigene Ports
```

### Lokale Entwicklung

Jedes Projekt braucht eigene Container in `docker-compose.dev.yml`:

```yaml
# RICHTIG: Projekt-spezifische Container
services:
  cotinga-convex-backend:
    image: ghcr.io/get-convex/convex-backend:latest
    container_name: cotinga-convex-backend
    ports:
      - "3214:3210"  # Eigener Port!
    # ...

  cotinga-convex-dashboard:
    image: ghcr.io/get-convex/convex-dashboard:latest
    container_name: cotinga-convex-dashboard
    ports:
      - "6794:6791"  # Eigener Port!
    # ...
```

```yaml
# FALSCH: Shared Container für mehrere Projekte
services:
  convex-backend:  # Generischer Name = Konflikt-Risiko!
    ports:
      - "3210:3210"  # Standard-Port = Kollision!
```

### Production (LUCIDLABS-HQ)

Auf dem Server braucht jedes Projekt seinen eigenen Convex-Container:

| Projekt | Container | Backend Port | Dashboard Port | URL |
|---------|-----------|--------------|----------------|-----|
| Shared (VERALTET) | lucidlabs-convex | 3210 | - | convex.lucidlabs.de |
| cotinga-test-suite | cotinga-convex | 3214 | 6794 | cotinga-convex.lucidlabs.de |
| invoice-assistant | invoice-convex | 3216 | 6796 | invoice-convex.lucidlabs.de |

### Port-Allokation

```
Projekt-Ports = Base + (Projekt-Index * 2)

Backend:   3210, 3214, 3216, 3218, ...
Dashboard: 6791, 6794, 6796, 6798, ...
```

### Checkliste für neue Projekte

- [ ] Eigene Container-Namen mit Projekt-Prefix
- [ ] Eigene Ports (keine Kollision mit anderen Projekten)
- [ ] Eigene `.env.local` mit projekt-spezifischer `NEXT_PUBLIC_CONVEX_URL`
- [ ] Eigener Caddy-Eintrag für Production
- [ ] NIEMALS `lucidlabs-convex` für Projekt-Daten nutzen

---

## Setup-Workflow

### 1. Docker Container starten

```bash
# Projekt-spezifische Container (siehe docker-conventions.md)
docker compose -f docker-compose.dev.yml up -d
```

Container:
- `{prefix}-convex-backend` - Backend API
- `{prefix}-convex-dashboard` - Admin Dashboard

### 2. Convex CLI Login (einmalig)

```bash
npx convex login
```

Öffnet Browser für Authentifizierung. Nach Login:

```bash
npx convex dev --once
```

Dies generiert:
```
convex/_generated/
├── api.ts          # Type-safe API
├── server.ts       # Server helpers
└── dataModel.ts    # Schema types
```

### 3. Auf Self-Hosted umstellen

In `.env.local`:
```env
NEXT_PUBLIC_CONVEX_URL=http://localhost:3212
```

Die generierten Types funktionieren mit jedem Backend.

---

## Projekt-Struktur

```
project/
├── convex/
│   ├── schema.ts           # Tabellen-Definitionen
│   ├── tsconfig.json       # Convex TypeScript Config
│   ├── functions/          # Queries & Mutations
│   │   ├── clients.ts
│   │   ├── tickets.ts
│   │   └── ...
│   └── _generated/         # Auto-generiert (nicht editieren!)
│       ├── api.ts
│       ├── server.ts
│       └── dataModel.ts
├── frontend/
│   ├── .env.local          # NEXT_PUBLIC_CONVEX_URL
│   └── components/
│       └── providers/
│           └── ConvexClientProvider.tsx
└── docker-compose.dev.yml  # Convex Container
```

---

## Schema Definition

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  clients: defineTable({
    name: v.string(),
    slug: v.string(),
    isActive: v.boolean(),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_slug", ["slug"])
    .index("by_active", ["isActive"]),
});
```

---

## Queries & Mutations

```typescript
// convex/functions/clients.ts
import { mutation, query } from "../_generated/server";
import { v } from "convex/values";

export const getAll = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db
      .query("clients")
      .withIndex("by_active", (q) => q.eq("isActive", true))
      .collect();
  },
});

export const create = mutation({
  args: {
    name: v.string(),
    slug: v.string(),
  },
  handler: async (ctx, args) => {
    const now = Date.now();
    return await ctx.db.insert("clients", {
      ...args,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    });
  },
});
```

---

## Frontend Integration

### ConvexClientProvider

```typescript
// components/providers/ConvexClientProvider.tsx
"use client";

import { ConvexProvider, ConvexReactClient } from "convex/react";
import { ReactNode } from "react";

const convexUrl = process.env.NEXT_PUBLIC_CONVEX_URL!;
const convex = new ConvexReactClient(convexUrl);

export function ConvexClientProvider({ children }: { children: ReactNode }) {
  return <ConvexProvider client={convex}>{children}</ConvexProvider>;
}
```

### Layout einbinden

```typescript
// app/layout.tsx
import { ConvexClientProvider } from "@/components/providers/ConvexClientProvider";

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <ConvexClientProvider>{children}</ConvexClientProvider>
      </body>
    </html>
  );
}
```

### Queries nutzen

```typescript
// app/dashboard/page.tsx
"use client";

import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export default function Dashboard() {
  const clients = useQuery(api.functions.clients.getAll);

  if (clients === undefined) return <div>Loading...</div>;

  return (
    <ul>
      {clients.map((client) => (
        <li key={client._id}>{client.name}</li>
      ))}
    </ul>
  );
}
```

---

## tsconfig.json (Convex)

Die Convex CLI generiert diese Config:

```json
{
  "compilerOptions": {
    "allowJs": true,
    "strict": true,
    "moduleResolution": "Bundler",
    "jsx": "react-jsx",
    "skipLibCheck": true,
    "allowSyntheticDefaultImports": true,
    "target": "ESNext",
    "lib": ["ES2021", "dom"],
    "forceConsistentCasingInFileNames": true,
    "module": "ESNext",
    "isolatedModules": true,
    "noEmit": true
  },
  "include": ["./**/*"],
  "exclude": ["./_generated"]
}
```

**NICHT manuell ändern** - Convex überschreibt diese Datei.

---

## Commands

| Command | Zweck |
|---------|-------|
| `npx convex login` | Cloud-Login für Codegen |
| `npx convex dev` | Watch mode + Codegen |
| `npx convex dev --once` | Einmalig generieren |
| `npx convex deploy` | Production deployment |

---

## Troubleshooting

### "Cannot prompt for input in non-interactive terminals"

Lösung: Im echten Terminal ausführen, nicht in Claude/AI.

```bash
npx convex login
```

### "_generated nicht gefunden"

```bash
npx convex dev --once
```

### "CONVEX_DEPLOYMENT not set"

Nach Login:
```bash
npx convex dev --once
```

### Schema-Änderungen nicht sichtbar

```bash
# Neu generieren
npx convex dev --once

# Falls nötig: Container neustarten
docker compose -f docker-compose.dev.yml restart
```

---

## Port-Zuordnung (siehe docker-conventions.md)

| Projekt | Backend | Dashboard |
|---------|---------|-----------|
| Base | 3210 | 6791 |
| client-service-reporting | 3212 | 6793 |
| satellite | 3220 | 6792 |

---

## Checkliste für neue Projekte

- [ ] `docker-compose.dev.yml` mit projekt-spezifischen Ports
- [ ] `convex/schema.ts` erstellen
- [ ] `convex/functions/` mit Queries/Mutations
- [ ] `npx convex login` (einmalig)
- [ ] `npx convex dev --once` (generiert _generated)
- [ ] `.env.local` mit `NEXT_PUBLIC_CONVEX_URL`
- [ ] `ConvexClientProvider` im Layout

---

**Last Updated:** 2026-01-30
