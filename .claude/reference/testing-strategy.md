# Testing Strategy

> Testing pyramid: 60% Unit, 30% Integration, 10% E2E.
> Visual verification with agent-browser for development, E2E only for critical flows.

---

## Testing Pyramid

```
        +----------+
        |   E2E    |  10% - Critical flows only
        |   (10)   |
        +----------+
        |Integration|  30% - API, DB
        |   (30)   |
        +----------+
        |   Unit    |  60% - Logic, Utils
        |   (60)   |
        +----------+
```

## Rules

| Type | When to Write | Tools |
|------|---------------|-------|
| **Unit** | Business logic, utilities | Vitest |
| **Integration** | API endpoints, DB operations | Vitest + Supertest |
| **E2E** | Critical user flows only | Playwright |

## E2E Testing Guidelines

**ONLY write E2E tests for:**
- Critical user journeys (login, main workflows)
- Features that touch multiple systems
- High-risk functionality

**DO NOT write E2E tests for:**
- Simple CRUD operations
- Individual components (use unit tests)
- Edge cases (use integration tests)

## Test Organization

```
frontend/
├── e2e/
│   ├── pages/              # Page Objects
│   │   └── ControlboardPage.ts
│   └── specs/              # Test files
│       └── controlboard.spec.ts
└── src/
    └── lib/
        └── __tests__/      # Unit tests
```

## Page Objects Pattern

```typescript
// e2e/pages/ExamplePage.ts
export class ExamplePage {
  readonly page: Page;
  readonly header: Locator;

  constructor(page: Page) {
    this.page = page;
    this.header = page.locator("h1");
  }

  async goto() {
    await this.page.goto("/example");
  }
}
```

## When Implementing Features

1. Write unit tests for business logic (60%)
2. Write integration tests for API/DB (30%)
3. **UI Changes:** Use `/visual-verify` for quick verification
4. Write E2E tests only for critical production flows (10%)

## Visual Verification vs E2E

| Development (90%) | Production (10%) |
|-------------------|------------------|
| `/visual-verify` | E2E Tests |
| agent-browser | Playwright |
| Seconds | Minutes |
| Every UI change | Login, Checkout, Payment |

**Rule:** `/visual-verify` for development, E2E only for critical flows.
