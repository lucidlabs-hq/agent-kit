# SSR & Hydration Best Practices

Richtlinien zur Vermeidung von Hydration Mismatches in Next.js.

---

## Das Problem

Next.js rendert Seiten zuerst auf dem Server (SSR), dann "hydratiert" React die Seite im Browser. Wenn Server-HTML und Client-HTML nicht übereinstimmen, entsteht ein **Hydration Mismatch Error**.

```
A tree hydrated but some attributes of the server rendered HTML
didn't match the client properties.
```

---

## Häufige Ursachen

### 1. Dynamische Werte auf Modul-Ebene

```typescript
// ❌ FALSCH - Date.now() ist bei jedem Render anders
export const mockData = {
  createdAt: new Date().toISOString(),        // Server: 10:00:00.123
  updatedAt: new Date(Date.now()).toISOString(), // Client: 10:00:00.456
};

// ❌ FALSCH - Math.random() ist nie gleich
export const items = [
  { id: Math.random(), name: "Item" },
];
```

### 2. Browser-APIs im Server-Code

```typescript
// ❌ FALSCH - window existiert nicht auf dem Server
export const isDesktop = window.innerWidth > 1024;

// ❌ FALSCH - localStorage ist Server-seitig nicht verfügbar
export const theme = localStorage.getItem("theme") ?? "light";
```

### 3. Locale-abhängige Formatierung

```typescript
// ❌ RISKANT - Locale kann Server vs Client unterschiedlich sein
export const formattedDate = new Date().toLocaleString();
```

---

## Lösungen

### Lösung 1: Feste Werte für Mock-Daten

```typescript
// ✅ RICHTIG - ISO-Strings sind deterministisch
export const mockData = {
  createdAt: "2026-01-13T10:00:00.000Z",
  updatedAt: "2026-01-13T10:30:00.000Z",
};

// ✅ RICHTIG - Feste IDs
export const items = [
  { id: "item-1", name: "Item 1" },
  { id: "item-2", name: "Item 2" },
];
```

### Lösung 2: Client-Only für dynamische Werte

```typescript
"use client";

import { useState, useEffect } from "react";

export function CurrentTime() {
  const [time, setTime] = useState<string>();

  useEffect(() => {
    // ✅ Läuft nur im Browser
    setTime(new Date().toLocaleTimeString("de-DE"));
  }, []);

  // Während SSR: nichts oder Skeleton anzeigen
  if (!time) return <span>--:--</span>;

  return <span>{time}</span>;
}
```

### Lösung 3: suppressHydrationWarning (sparsam verwenden)

```tsx
// ✅ OK für kleine, unkritische Unterschiede
<time suppressHydrationWarning>
  {new Date().toLocaleString()}
</time>
```

**Hinweis:** Nur für kosmetische Unterschiede verwenden, nicht als generelle Lösung!

### Lösung 4: next/dynamic mit ssr: false

```typescript
import dynamic from "next/dynamic";

// ✅ Komponente wird nur im Browser gerendert
const LiveClock = dynamic(() => import("./LiveClock"), {
  ssr: false,
  loading: () => <span>Lädt...</span>,
});
```

---

## Checkliste für Hydration-sichere Komponenten

| Frage | Aktion |
|-------|--------|
| Verwendet die Komponente `Date.now()`? | → Feste Werte oder useEffect |
| Verwendet die Komponente `Math.random()`? | → UUID v4 oder feste IDs |
| Greift die Komponente auf `window`/`localStorage` zu? | → useEffect oder dynamic import |
| Formatiert die Komponente Daten locale-spezifisch? | → Server-Locale festlegen oder useEffect |

---

## Beispiele aus diesem Projekt

### Mock-Daten (lib/mock-data.ts)

```typescript
// ✅ So machen wir es
export const mockActivities: AgentActivity[] = [
  {
    id: "activity-1",
    message: "Ticket analysiert",
    createdAt: "2026-01-13T10:00:00.000Z", // Fester ISO-String
  },
];
```

### Relative Zeit-Anzeige (Client Component)

```typescript
"use client";

function formatRelativeTime(dateString: string): string {
  // ✅ OK - wird konsistent auf Client berechnet
  const diff = Date.now() - new Date(dateString).getTime();
  const minutes = Math.floor(diff / 60000);

  if (minutes < 1) return "Gerade eben";
  if (minutes < 60) return `Vor ${minutes} Min.`;
  // ...
}
```

---

## Debugging

### Hydration Error im Browser erkennen

1. Console öffnen → Error mit "hydration mismatch" suchen
2. Der Error zeigt die betroffene Komponente und das unterschiedliche Attribut

### Typisches Error-Format

```
-                           style={{visibility:"visible"}}
+                           (keine style prop)
```

Das `-` zeigt Server-HTML, das `+` zeigt Client-HTML.

---

## Zusammenfassung

| Regel | Begründung |
|-------|------------|
| **Keine dynamischen Werte auf Modul-Ebene** | Server und Client evaluieren zu unterschiedlichen Zeiten |
| **Mock-Daten mit festen Timestamps** | Vermeidet Date.now() bei jedem Import |
| **Browser-APIs nur in useEffect** | window/localStorage existieren Server-seitig nicht |
| **Client Components für Live-Daten** | Klare Trennung zwischen SSR und Client-Interaktivität |

---

## Weiterführende Links

- [React Hydration Mismatch Docs](https://react.dev/link/hydration-mismatch)
- [Next.js App Router - Server vs Client](https://nextjs.org/docs/app/building-your-application/rendering)

---

**Zuletzt aktualisiert:** Januar 2026
