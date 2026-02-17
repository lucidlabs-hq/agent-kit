# shadcn/ui Setup

> Pre-configured with New York style, RSC support, CSS variables.
> Components in `components/ui/`. Modify freely.

---

## Configuration

Already configured in `components.json`:

```json
{
  "style": "new-york",
  "rsc": true,
  "tailwind": { "cssVariables": true },
  "aliases": {
    "ui": "@/components/ui",
    "utils": "@/lib/utils"
  }
}
```

## Adding Components

```bash
npx shadcn@latest add button
npx shadcn@latest add card dialog tabs
```

## Available Components

| Component | Path | Server/Client |
|-----------|------|---------------|
| `Button` | `components/ui/button.tsx` | Server |
| `Badge` | `components/ui/badge.tsx` | Server |
| `Card` | `components/ui/card.tsx` | Server |
| `Avatar` | `components/ui/avatar.tsx` | Server |
| `Separator` | `components/ui/separator.tsx` | Server |

## Rules

- **Server Components preferred** - shadcn configured with `rsc: true`
- **Radix UI only when needed** - For complex interaction (Dialog, Dropdown)
- **Customization allowed** - shadcn components can be modified
- **Flat Design** - No shadows, only borders
