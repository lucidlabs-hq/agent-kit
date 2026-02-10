---
name: browser
description: Interactive browser automation with agent-browser. Open pages, click elements, fill forms, take screenshots. Use for testing UI, automating tasks, or debugging visual issues.
allowed-tools: Bash, Read
argument-hint: <url> [action]
---

# Browser Automation

Interactive browser control using agent-browser (Playwright-based).

## Quick Reference

```bash
# Open page
pnpm exec agent-browser open <url>

# Take screenshot
pnpm exec agent-browser screenshot [path]
pnpm exec agent-browser screenshot --full [path]

# Get interactive elements
pnpm exec agent-browser snapshot -i

# Interact
pnpm exec agent-browser click @e1
pnpm exec agent-browser fill @e2 "text"
pnpm exec agent-browser hover @e3
pnpm exec agent-browser press Enter

# Viewport
pnpm exec agent-browser viewport 375 812    # Mobile
pnpm exec agent-browser viewport 1920 1080  # Desktop
```

## Setup (First Time)

```bash
cd frontend
pnpm add -D agent-browser
pnpm exec agent-browser install
```

## Workflow

### 1. Open a Page

```bash
pnpm exec agent-browser open http://localhost:8080
# or any URL
pnpm exec agent-browser open https://example.com
```

### 2. See What's Interactive

```bash
pnpm exec agent-browser snapshot -i
# Output: list of elements with refs like @e1, @e2, etc.
```

### 3. Interact

```bash
# Click by ref
pnpm exec agent-browser click @e1

# Fill text input
pnpm exec agent-browser fill @e2 "Hello World"

# Hover for tooltips/dropdowns
pnpm exec agent-browser hover @e3

# Keyboard
pnpm exec agent-browser press Enter
pnpm exec agent-browser press Escape
```

### 4. Screenshot

```bash
# Current viewport
pnpm exec agent-browser screenshot

# Save to specific path
pnpm exec agent-browser screenshot ./my-screenshot.png

# Full page
pnpm exec agent-browser screenshot --full ./full-page.png
```

### 5. Responsive Testing

```bash
# Set viewport before screenshot
pnpm exec agent-browser viewport 375 812    # iPhone
pnpm exec agent-browser viewport 768 1024   # iPad
pnpm exec agent-browser viewport 1920 1080  # Desktop

pnpm exec agent-browser screenshot ./mobile.png
```

## Sessions

Isolate tests in separate browser sessions:

```bash
# Session 1: Login flow
pnpm exec agent-browser --session login open http://localhost:8080/login
pnpm exec agent-browser --session login fill @e1 "user@test.com"
pnpm exec agent-browser --session login click @e2

# Session 2: Different test
pnpm exec agent-browser --session dashboard open http://localhost:8080/dashboard
```

## Wait for Elements

```bash
# Wait for element to appear
pnpm exec agent-browser wait visible "[role='dialog']"

# Then screenshot
pnpm exec agent-browser screenshot ./modal.png
```

## Common Patterns

### Test a Form

```bash
pnpm exec agent-browser open http://localhost:8080/form
pnpm exec agent-browser snapshot -i
pnpm exec agent-browser fill @e1 "John"
pnpm exec agent-browser fill @e2 "john@example.com"
pnpm exec agent-browser click @e3  # Submit
pnpm exec agent-browser snapshot -i  # Check result
pnpm exec agent-browser screenshot ./form-submitted.png
```

### Test a Modal

```bash
pnpm exec agent-browser click @e1  # Open trigger
pnpm exec agent-browser wait visible "[role='dialog']"
pnpm exec agent-browser screenshot ./modal-open.png
pnpm exec agent-browser press Escape
pnpm exec agent-browser screenshot ./modal-closed.png
```

### Responsive Screenshots

```bash
# Desktop
pnpm exec agent-browser viewport 1920 1080
pnpm exec agent-browser screenshot ./desktop.png

# Tablet
pnpm exec agent-browser viewport 768 1024
pnpm exec agent-browser screenshot ./tablet.png

# Mobile
pnpm exec agent-browser viewport 375 812
pnpm exec agent-browser screenshot ./mobile.png
```

## Troubleshooting

### Browser not installed

```bash
pnpm exec agent-browser install
```

### Page not loading

Check if dev server is running:
```bash
lsof -i:8080  # or your port
```

### Element not found

Use `snapshot -i` to see current elements:
```bash
pnpm exec agent-browser snapshot -i
```

## Reference

- [agent-browser GitHub](https://github.com/vercel-labs/agent-browser)
