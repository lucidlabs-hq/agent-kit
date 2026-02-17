# Agent Browser Setup

> Visual testing tool for automated UI verification.
> Repository: https://github.com/vercel-labs/agent-browser

---

## Installation

- **Package:** `frontend/package.json` (devDependencies)
- **Binary:** `frontend/node_modules/.bin/agent-browser`
- **Chromium:** Downloaded via `pnpm exec agent-browser install`

```bash
cd frontend
pnpm add -D agent-browser
pnpm exec agent-browser install    # Download Chromium (required once)
```

## Usage

```bash
cd frontend
pnpm exec agent-browser

# Available commands in session:
# - goto <url>         Navigate to URL
# - screenshot         Take screenshot
# - click <id>         Click element by accessibility ID
# - type <id> <text>   Type text into element
# - snapshot           Get accessibility tree snapshot
```

## Visual Verification Workflow

1. Start dev server: `pnpm run dev`
2. In another terminal: `pnpm exec agent-browser`
3. Navigate: `goto http://localhost:3000/<page>`
4. Take screenshot: `screenshot`
5. Verify UI matches specification

## Important Notes

- **Dev dependency only** - Not included in production builds
- **Requires Chromium** - Run `agent-browser install` after fresh clone
- **Local only** - For development verification, not CI/CD
- **Ask before taking screenshots** - Only on user request
