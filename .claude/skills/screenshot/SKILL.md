---
name: screenshot
description: Take visual verification screenshots using agent-browser. Use for UI verification.
disable-model-invocation: true
allowed-tools: Read, Write, Bash
---

# Visual Verification Screenshots

Capture and document UI implementations using agent-browser for visual verification.

## Prerequisites

Ensure agent-browser is installed and dev server is running:

```bash
cd frontend
pnpm exec agent-browser install  # Once after fresh clone
pnpm run dev                     # In separate terminal
```

## Step 1: Navigate to Page

```bash
cd frontend
pnpm exec agent-browser open http://localhost:3000/<page>
```

Common pages:
- `/` - Home page
- `/dashboard` - Dashboard (if exists)
- Custom routes as specified

## Step 2: Get Interactive Elements (Optional)

To find clickable elements:

```bash
pnpm exec agent-browser snapshot --interactive --compact
```

Returns element references like `@e5` for clicking.

## Step 3: Interact (If Needed)

```bash
# Click by reference
pnpm exec agent-browser click @e5

# Click by text
pnpm exec agent-browser click "Button Text"

# Wait for navigation
sleep 1
```

## Step 4: Take Screenshot

```bash
# Standard screenshot
pnpm exec agent-browser screenshot frontend/.dev-screenshots/<name>.png

# Full page screenshot
pnpm exec agent-browser screenshot frontend/.dev-screenshots/<name>.png --full
```

### Naming Convention

| Pattern | Example |
|---------|---------|
| `<feature>-<view>.png` | `inbox-overview.png` |
| `<feature>-<state>.png` | `decision-loading.png` |
| `<date>-<feature>.png` | `2026-01-21-header.png` |

## Step 5: Update Gallery

After taking screenshots, update the HTML gallery:

**File:** `frontend/.dev-screenshots/index.html`

Add new screenshot card:

```html
<article class="screenshot-card">
  <div class="screenshot-header">
    <span class="screenshot-title">N. Feature Name</span>
    <span class="screenshot-date">filename.png</span>
  </div>
  <img src="filename.png" alt="Description" class="screenshot-img" onclick="openLightbox(this.src)">
  <div class="screenshot-footer">
    <ul>
      <li>Verified element 1</li>
      <li>Verified element 2</li>
    </ul>
  </div>
</article>
```

## Step 6: View Gallery

Open in browser:

```
file://[project-path]/frontend/.dev-screenshots/index.html
```

Or use VS Code Live Server.

## Quick Workflow (Copy-Paste)

```bash
# Full workflow for a page
cd frontend
pnpm exec agent-browser open http://localhost:3000/
pnpm exec agent-browser snapshot --interactive --compact
pnpm exec agent-browser screenshot .dev-screenshots/homepage.png --full
```

## Output Report

After capturing screenshots, provide:

```markdown
## Screenshots Captured

**Page:** [URL]
**Screenshots:**
- `filename.png` - [Description]

### Verified Elements
- [ ] Element 1 matches PRD
- [ ] Element 2 matches PRD

### Gallery Link
[file://.../.dev-screenshots/index.html]
```

## Notes

- Screenshots are gitignored (`.dev-screenshots/`)
- Always update gallery HTML after new captures
- Use `--full` flag for full page captures
- Reference PRD for verification checklist
- Link screenshots in chat for user review
- ALWAYS ask user before taking screenshots
