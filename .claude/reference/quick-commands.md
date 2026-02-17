# Quick Commands Reference

> All commands via `pnpm run` - unified interface.

---

## Dev Server Start Rule (MANDATORY)

**ALWAYS** before starting a dev server:

1. Check what's running: `lsof -i:3000`
2. Show the user what's currently running
3. Kill existing process if needed: `lsof -ti:3000 | xargs kill -9`
4. Start server and show port

## Frontend

```bash
cd frontend
pnpm install                     # Dependencies (once)
pnpm run dev                     # Dev Server (port 3000)
pnpm run lint                    # ESLint
pnpm run type-check              # TypeScript
pnpm run validate                # Lint + Type-check
pnpm run self-audit              # Full compliance check
pnpm run build                   # Production Build
pnpm run start                   # Production Server
```

## Backend

```bash
cd backend
pnpm install                     # Dependencies (once)
pnpm run dev                     # Dev Server (port 4000)

# Convex
npx convex dev                   # Start Convex dev server
npx convex deploy                # Deploy to cloud
```

## Mastra

```bash
cd mastra
pnpm install                     # Dependencies (once)
pnpm run dev                     # Dev Server (port 4000)
pnpm run build                   # Production build
```

## Testing

```bash
cd frontend
pnpm run test                    # E2E tests (Playwright)
pnpm run test:ui                 # E2E with UI
pnpm run test:headed             # E2E with visible browser
```

## Service URLs Display Format

```
+------------------+------+-----------------------+
|     Service      | Port |         Link          |
+------------------+------+-----------------------+
| Frontend         | 8080 | http://localhost:8080 |
| Mastra API       | 8081 | http://localhost:8081 |
| Convex Backend   | 8082 | http://localhost:8082 |
| Convex Dashboard | 8083 | http://localhost:8083 |
+------------------+------+-----------------------+
```
