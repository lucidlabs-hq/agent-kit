---
name: test-setup
description: Initialize testing infrastructure for a project. Syncs Vitest + Playwright configs from upstream.
allowed-tools: Bash, Read, Write, Glob
---

# Test Setup: Initialize Testing Infrastructure

## Objective

Set up Vitest + Playwright testing infrastructure from upstream configs. Run this once per project to enable TDD workflow.

---

## Process

### 1. Check Existing Infrastructure

```bash
cd frontend

# Check if already set up
if [ -f "vitest.config.ts" ]; then
  echo "Test infrastructure already exists."
  echo "  vitest.config.ts: EXISTS"
  echo "  playwright.config.ts: $([ -f playwright.config.ts ] && echo EXISTS || echo MISSING)"
  echo "  src/test/setup.ts: $([ -f src/test/setup.ts ] && echo EXISTS || echo MISSING)"
  echo ""
  echo "Run /test to execute tests."
  exit 0
fi
```

### 2. Locate Upstream Configs

```bash
# Find upstream directory
UPSTREAM=""
if [ -d "../../lucidlabs-agent-kit/frontend" ]; then
  UPSTREAM="../../lucidlabs-agent-kit/frontend"
elif [ -d "../lucidlabs-agent-kit/frontend" ]; then
  UPSTREAM="../lucidlabs-agent-kit/frontend"
fi

if [ -z "$UPSTREAM" ]; then
  echo "Upstream not found. Creating configs from template."
fi
```

### 3. Copy or Create Configs

From upstream (preferred) or from inline templates:

**vitest.config.ts:**
```typescript
/**
 * Vitest Configuration
 *
 * Key choices:
 * - vite-tsconfig-paths: resolves @ alias from tsconfig (recommended by Next.js docs)
 * - restoreMocks: auto-restores mocks between tests (prevents state leakage)
 * - jsdom: browser-like environment for React component tests
 */
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [tsconfigPaths(), react()],
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: ["./src/test/setup.ts"],
    include: ["src/**/*.test.{ts,tsx}", "lib/**/*.test.{ts,tsx}"],
    restoreMocks: true,
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
      exclude: ["node_modules", "src/test", "e2e"],
    },
  },
});
```

> **NOTE:** Do NOT use manual `path.resolve` aliases. Use `vite-tsconfig-paths` instead - it reads the `@` alias from `tsconfig.json` automatically, keeping a single source of truth.

**playwright.config.ts:**
```typescript
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./e2e/specs",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: "html",
  use: {
    baseURL: "http://localhost:3000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "mobile", use: { ...devices["Pixel 5"] } },
  ],
  webServer: {
    command: "pnpm run dev --port 3001",
    url: "http://localhost:3001",
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});
```

**src/test/setup.ts:**
```typescript
import "@testing-library/jest-dom";
import { vi } from "vitest";

Object.defineProperty(window, "matchMedia", {
  writable: true,
  value: vi.fn().mockImplementation((query: string) => ({
    matches: false, media: query, onchange: null,
    addEventListener: vi.fn(), removeEventListener: vi.fn(), dispatchEvent: vi.fn(),
  })),
});

class MockIntersectionObserver {
  observe = vi.fn();
  disconnect = vi.fn();
  unobserve = vi.fn();
}

Object.defineProperty(window, "IntersectionObserver", {
  writable: true,
  value: MockIntersectionObserver,
});
```

### 4. Add Dependencies

Add to `devDependencies` in `package.json`:

```json
{
  "vitest": "^4.0.17",
  "@vitejs/plugin-react": "^5.1.2",
  "@vitest/coverage-v8": "^4.0.17",
  "@testing-library/jest-dom": "^6.9.1",
  "@testing-library/react": "^16.3.1",
  "jsdom": "^27.4.0",
  "vite-tsconfig-paths": "^4.3.2",
  "@playwright/test": "^1.57.0",
  "agent-browser": "^0.6.0"
}
```

Add to `scripts` in `package.json`:

```json
{
  "test": "vitest run",
  "test:watch": "vitest",
  "test:coverage": "vitest run --coverage",
  "test:e2e": "playwright test",
  "test:e2e:ui": "playwright test --ui",
  "test:e2e:headed": "playwright test --headed"
}
```

### 5. Create Directory Structure

```bash
mkdir -p lib/__tests__
mkdir -p e2e/specs
mkdir -p e2e/pages
mkdir -p src/test
```

### 6. Create Canary Test

Create `lib/__tests__/utils.test.ts` as a canary:

```typescript
import { describe, expect, it } from "vitest";
import { cn } from "../utils";

describe("cn", () => {
  it("merges class names correctly", () => {
    expect(cn("foo", "bar")).toBe("foo bar");
  });
});
```

### 7. Install and Verify

```bash
pnpm install
pnpm run test
```

### 8. Output

```
┌─────────────────────────────────────────────────────────────────┐
│  TEST INFRASTRUCTURE READY                                      │
│  ─────────────────────────                                      │
│                                                                 │
│  Created:                                                       │
│    vitest.config.ts                                             │
│    playwright.config.ts                                         │
│    src/test/setup.ts                                            │
│    lib/__tests__/utils.test.ts (canary)                         │
│                                                                 │
│  Directories:                                                   │
│    lib/__tests__/                                               │
│    e2e/specs/                                                   │
│    e2e/pages/                                                   │
│                                                                 │
│  Verification: 1 test passed                                    │
│                                                                 │
│  Next: Run /test to see coverage gaps                           │
│        Run /test:watch for TDD workflow                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```
