---
name: test
description: Run tests with coverage report and gap analysis. MANDATORY before /commit and PR creation. Use after implementation or during validation.
allowed-tools: Bash, Read, Glob, Grep
argument-hint: [unit|e2e|coverage|gaps|all]
---

# Test: Run Tests & Coverage

## Objective

Run unit tests, show coverage, identify gaps. This is a **mandatory gate** before any commit or PR.

## IMPORTANT: Test Gate Rule

Tests MUST pass before:
- Any `/commit` execution
- Any PR creation
- Any deployment

If tests fail, DO NOT proceed with commit. Fix the failures first.

---

## Process

### 1. Check Test Infrastructure

```bash
cd frontend

# Check if test script exists
grep -q '"test"' package.json
if [ $? -ne 0 ]; then
  echo "Tests not configured. Run /test-setup first."
  exit 1
fi
```

### 2. Run Tests Based on Argument

**`/test` or `/test all`** - Run all unit tests:
```bash
cd frontend && pnpm run test
```

**`/test unit`** - Run unit tests only:
```bash
cd frontend && pnpm run test
```

**`/test e2e`** - Run E2E tests:
```bash
cd frontend && pnpm run test:e2e
```

**`/test coverage`** - Run with coverage report:
```bash
cd frontend && pnpm run test:coverage
```

**`/test gaps`** - Gap analysis only (no test run):
Skip to step 4.

### 3. Parse and Display Results

Show results in structured format:

```
┌─────────────────────────────────────────────────────────────────┐
│  TEST RESULTS                                                   │
│  ────────────                                                   │
│                                                                 │
│  Status:     PASS / FAIL                                        │
│  Total:      12 tests                                           │
│  Passed:     12                                                 │
│  Failed:     0                                                  │
│  Duration:   1.2s                                               │
│                                                                 │
│  Coverage:   64% lines | 58% branches | 70% functions           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4. Gap Analysis

Identify files without test coverage:

1. Glob all `.ts` and `.tsx` files in `lib/` and `src/` (excluding `__tests__/`, `test/`, `node_modules/`)
2. For each file, check if a corresponding `__tests__/*.test.ts` exists
3. Report uncovered files

```
┌─────────────────────────────────────────────────────────────────┐
│  TEST GAP ANALYSIS                                              │
│  ─────────────────                                              │
│                                                                 │
│  Files with tests:     3/7                                      │
│  Files without tests:  4/7                                      │
│                                                                 │
│  Uncovered:                                                     │
│    lib/notion-data.ts          (complex, high priority)         │
│    lib/auth-client.ts          (auth, medium priority)          │
│    lib/auth-server.ts          (auth, medium priority)          │
│    lib/convex.ts               (config, low priority)           │
│                                                                 │
│  Suggestion: Start with lib/notion-data.ts (most logic)        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5. Commit Gate Check

If this was run as a pre-commit check:

```
┌─────────────────────────────────────────────────────────────────┐
│  COMMIT GATE                                                    │
│  ───────────                                                    │
│                                                                 │
│  Tests:      PASS                                               │
│  Coverage:   64% (threshold: 60%)                               │
│                                                                 │
│  Result:     READY TO COMMIT                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

Or if tests fail:

```
┌─────────────────────────────────────────────────────────────────┐
│  COMMIT GATE                                                    │
│                                                                 │
│  Tests:      FAIL (2 failures)                                  │
│                                                                 │
│  Result:     BLOCKED - Fix tests before commit                  │
│                                                                 │
│  Failures:                                                      │
│    lib/__tests__/utils.test.ts:15                               │
│      Expected: "foo bar"                                        │
│      Received: "bar foo"                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Coverage Thresholds

| Metric | Minimum | Target |
|--------|---------|--------|
| Lines | 60% | 80% |
| Branches | 50% | 70% |
| Functions | 60% | 80% |

---

## AI TDD Best Practices (Mandatory for Test Writing)

When AI writes tests, these anti-patterns MUST be avoided:

### Never Do

| Anti-Pattern | Why It's Bad |
|-------------|-------------|
| Tests without meaningful assertions | `expect(true).toBe(true)` proves nothing |
| Verification instead of validation | Testing current behavior (including bugs) instead of intended behavior |
| Over-mocking | Mocking more than one layer deep creates false security |
| Implementation-coupled tests | Testing private methods/internal state breaks on refactor |
| `getByTestId` as first choice | Use `getByRole`, `getByLabelText`, `getByText` first |
| Test suite flooding | Redundant tests slow CI without improving coverage |

### Always Do

| Practice | Example |
|----------|---------|
| Test behavior, not implementation | Assert on return values and side effects, not internal state |
| Include edge cases | Empty, null, boundary values alongside happy path |
| One assertion per test (when possible) | Clear failure messages, easy to locate issues |
| Descriptive test names | `"returns false when session token is expired"` not `"test case 3"` |
| Extract data-fetching logic | Move async logic out of Server Components into testable utilities |

### Async Server Components

Vitest cannot test async Server Components. For these:
- Extract data-fetching logic into utility functions (unit testable)
- Test the full component via E2E (Playwright)
- Use `/visual-verify` (agent-browser) for layout verification

### Module-Level Environment Variables

When testing code that captures `process.env` at module load time (e.g., `const URL = process.env.AUTH_CONVEX_SITE_URL`), standard `process.env` manipulation in `beforeEach` won't work because the value is already cached.

**Fix:** Use `vi.resetModules()` + dynamic imports:

```typescript
beforeEach(() => {
  vi.resetModules();
});

async function loadModule() {
  const mod = await import("../my-module");
  return mod.myFunction;
}

it("works with custom env", async () => {
  process.env.MY_VAR = "test-value";
  const myFunction = await loadModule();
  // Now myFunction sees the updated env
});
```

This pattern is used in `auth-helpers.test.ts` for testing `validateSession()` with different `AUTH_CONVEX_SITE_URL` values.

---

## Integration with Other Skills

- **`/execute`** runs `/test` automatically after implementation
- **`/commit`** runs `/test` as a mandatory gate before committing
- **`/prime`** shows test health summary at session start
- **`/pre-production`** includes full test suite as quality gate
