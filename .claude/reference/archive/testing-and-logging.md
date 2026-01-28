# Testing & Logging Best Practices Reference

Best practices for testing and observability in Neola AI projects.

---

## Table of Contents

1. [Testing Strategy](#1-testing-strategy)
2. [Unit Testing](#2-unit-testing)
3. [Integration Testing](#3-integration-testing)
4. [E2E Testing](#4-e2e-testing)
5. [Logging](#5-logging)
6. [Monitoring](#6-monitoring)

---

## 1. Testing Strategy

### Testing Pyramid

```
        ┌───────────┐
        │    E2E    │  10% - Critical flows
        │    (10)   │
        ├───────────┤
        │ Integration│  30% - API, DB
        │    (30)    │
        ├───────────┤
        │   Unit     │  60% - Logic, Utils
        │   (60)     │
        └───────────┘
```

### What to Test

| Layer | What | Tools |
|-------|------|-------|
| Unit | Business logic, utilities, formatters | Vitest |
| Integration | API endpoints, DB operations, Agent tools | Vitest + Supertest |
| E2E | User journeys, critical paths | Playwright |

### Test Organization

```
frontend/
├── src/
│   ├── lib/
│   │   ├── utils.ts
│   │   └── __tests__/
│   │       └── utils.test.ts
│   └── components/
│       └── Dashboard/
│           └── __tests__/
│               └── TicketCard.test.tsx

backend/
├── src/
│   ├── tools/
│   │   └── __tests__/
│   │       └── classifyTicket.test.ts
│   └── api/
│       └── __tests__/
│           └── tickets.integration.test.ts

e2e/
└── specs/
    └── ticket-triage.spec.ts
```

---

## 2. Unit Testing

### Setup (Vitest)

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    include: ['src/**/*.test.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules', 'src/test'],
    },
  },
});
```

```typescript
// src/test/setup.ts
import '@testing-library/jest-dom';
import { vi } from 'vitest';

// Mock matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
  })),
});
```

### Testing Utilities

```typescript
// lib/__tests__/utils.test.ts
import { describe, it, expect } from 'vitest';
import { formatDate, isHavarieTrigger, calculatePriority } from '../utils';

describe('formatDate', () => {
  it('formats ISO date to German format', () => {
    expect(formatDate('2025-01-13')).toBe('13.01.2025');
  });

  it('handles invalid date gracefully', () => {
    expect(formatDate('invalid')).toBe('Ungültiges Datum');
  });
});

describe('isHavarieTrigger', () => {
  it('returns true for heating failure keywords', () => {
    expect(isHavarieTrigger('Totalausfall der Heizung')).toBe(true);
    expect(isHavarieTrigger('Heizung komplett ausgefallen')).toBe(true);
  });

  it('returns false for standard issues', () => {
    expect(isHavarieTrigger('Heizung macht Geräusche')).toBe(false);
  });
});

describe('calculatePriority', () => {
  it('returns havarie for critical conditions', () => {
    const result = calculatePriority({
      isHavarieTrigger: true,
      isHeatingPeriod: true,
      temperatureBelow5: true,
      multipleUnitsAffected: false,
    });
    expect(result).toBe('havarie');
  });

  it('returns standard when no triggers', () => {
    const result = calculatePriority({
      isHavarieTrigger: false,
      isHeatingPeriod: true,
      temperatureBelow5: true,
      multipleUnitsAffected: false,
    });
    expect(result).toBe('standard');
  });
});
```

### Testing React Components

```typescript
// components/Dashboard/__tests__/TicketCard.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { TicketCard } from '../TicketCard';

const mockTicket = {
  id: 'tkt-001',
  title: 'Heizung ausgefallen',
  category: 'heating_failure',
  priority: 'havarie',
  status: 'new',
  createdAt: new Date('2025-01-13'),
};

describe('TicketCard', () => {
  it('renders ticket title', () => {
    render(<TicketCard ticket={mockTicket} />);
    expect(screen.getByText('Heizung ausgefallen')).toBeInTheDocument();
  });

  it('displays havarie badge for havarie priority', () => {
    render(<TicketCard ticket={mockTicket} />);
    expect(screen.getByText('HAVARIE')).toBeInTheDocument();
  });

  it('calls onClick when card is clicked', () => {
    const onClick = vi.fn();
    render(<TicketCard ticket={mockTicket} onClick={onClick} />);
    
    fireEvent.click(screen.getByRole('article'));
    expect(onClick).toHaveBeenCalledWith(mockTicket.id);
  });

  it('applies correct styling for priority', () => {
    render(<TicketCard ticket={mockTicket} />);
    const card = screen.getByRole('article');
    expect(card).toHaveClass('border-red-500');
  });
});
```

### Testing Hooks

```typescript
// hooks/__tests__/useTickets.test.ts
import { describe, it, expect, vi } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useTickets } from '../useTickets';

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return ({ children }) => (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
};

describe('useTickets', () => {
  it('fetches tickets successfully', async () => {
    vi.spyOn(global, 'fetch').mockResolvedValueOnce({
      ok: true,
      json: async () => ({ tickets: [mockTicket] }),
    });

    const { result } = renderHook(() => useTickets(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(result.current.isSuccess).toBe(true);
    });

    expect(result.current.data).toHaveLength(1);
  });
});
```

---

## 3. Integration Testing

### API Testing

```typescript
// api/__tests__/tickets.integration.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { testDb, resetTestDb } from '@/test/db-setup';
import app from '../routes';

describe('Tickets API', () => {
  beforeEach(async () => {
    await resetTestDb();
  });

  describe('GET /api/tickets', () => {
    it('returns empty array when no tickets', async () => {
      const res = await app.request('/api/tickets');
      const data = await res.json();

      expect(res.status).toBe(200);
      expect(data.tickets).toEqual([]);
    });

    it('returns tickets with relations', async () => {
      // Seed test data
      await testDb.insert(properties).values({ id: 'prop-1', address: 'Test' });
      await testDb.insert(tickets).values({
        id: 'tkt-1',
        title: 'Test',
        description: 'Test',
        category: 'heating_failure',
        propertyId: 'prop-1',
      });

      const res = await app.request('/api/tickets');
      const data = await res.json();

      expect(data.tickets).toHaveLength(1);
      expect(data.tickets[0].property).toBeDefined();
    });

    it('filters by category', async () => {
      await testDb.insert(tickets).values([
        { title: 'Heating', category: 'heating_failure' },
        { title: 'Water', category: 'water_damage' },
      ]);

      const res = await app.request('/api/tickets?category=heating_failure');
      const data = await res.json();

      expect(data.tickets).toHaveLength(1);
      expect(data.tickets[0].category).toBe('heating_failure');
    });
  });

  describe('POST /api/tickets', () => {
    it('creates ticket with valid data', async () => {
      const res = await app.request('/api/tickets', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: 'New Ticket',
          description: 'Description',
          category: 'heating_failure',
        }),
      });

      expect(res.status).toBe(201);
      const data = await res.json();
      expect(data.ticket.id).toBeDefined();
    });

    it('returns 400 for invalid data', async () => {
      const res = await app.request('/api/tickets', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: '' }), // Missing required fields
      });

      expect(res.status).toBe(400);
    });
  });
});
```

### Agent Tool Testing

```typescript
// tools/__tests__/classifyTicket.integration.test.ts
import { describe, it, expect } from 'vitest';
import { classifyTicket } from '../classify/classifyTicket';

describe('classifyTicket Integration', () => {
  it('classifies heating failure correctly', async () => {
    const result = await classifyTicket.execute({
      context: {
        title: 'Heizung komplett ausgefallen',
        description: 'Seit heute Morgen keine Heizung mehr, alle 4 Parteien betroffen',
      },
    });

    expect(result.category).toBe('heating_failure');
    expect(result.isHavarie).toBe(true);
    expect(result.triggers).toContain('Mehrere Parteien betroffen');
  });
});
```

---

## 4. E2E Testing

### Playwright Setup

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e/specs',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile', use: { ...devices['iPhone 13'] } },
  ],
  webServer: {
    command: 'pnpm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Page Objects

```typescript
// e2e/pages/DashboardPage.ts
import { Page, Locator } from '@playwright/test';

export class DashboardPage {
  readonly page: Page;
  readonly ticketList: Locator;
  readonly urgentCarousel: Locator;
  readonly filterButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.ticketList = page.getByTestId('ticket-list');
    this.urgentCarousel = page.getByTestId('urgent-carousel');
    this.filterButton = page.getByRole('button', { name: 'Filter' });
  }

  async goto() {
    await this.page.goto('/controlboard');
  }

  async getTicketCount() {
    return this.ticketList.getByRole('article').count();
  }

  async clickTicket(index: number) {
    await this.ticketList.getByRole('article').nth(index).click();
  }

  async filterByCategory(category: string) {
    await this.filterButton.click();
    await this.page.getByRole('option', { name: category }).click();
  }
}
```

### E2E Test Specs

```typescript
// e2e/specs/ticket-triage.spec.ts
import { test, expect } from '@playwright/test';
import { DashboardPage } from '../pages/DashboardPage';
import { TicketDetailPage } from '../pages/TicketDetailPage';

test.describe('Ticket Triage Flow', () => {
  test('user can view and approve a draft', async ({ page }) => {
    const dashboard = new DashboardPage(page);
    await dashboard.goto();

    // Verify dashboard loads
    await expect(dashboard.ticketList).toBeVisible();
    expect(await dashboard.getTicketCount()).toBeGreaterThan(0);

    // Click first ticket
    await dashboard.clickTicket(0);

    // Verify detail page
    const detail = new TicketDetailPage(page);
    await expect(detail.approveButton).toBeVisible();

    // Approve draft
    await detail.approveDraft();
    await expect(detail.successMessage).toBeVisible();
  });

  test('havarie tickets appear in urgent carousel', async ({ page }) => {
    const dashboard = new DashboardPage(page);
    await dashboard.goto();

    await expect(dashboard.urgentCarousel).toBeVisible();
    const urgentCards = dashboard.urgentCarousel.getByRole('article');
    expect(await urgentCards.count()).toBeGreaterThan(0);
  });

  test('filter reduces visible tickets', async ({ page }) => {
    const dashboard = new DashboardPage(page);
    await dashboard.goto();

    const initialCount = await dashboard.getTicketCount();
    await dashboard.filterByCategory('Heizung');
    const filteredCount = await dashboard.getTicketCount();

    expect(filteredCount).toBeLessThanOrEqual(initialCount);
  });
});
```

### Mobile E2E Tests

```typescript
// e2e/specs/mobile.spec.ts
import { test, expect, devices } from '@playwright/test';

test.describe('Mobile Experience', () => {
  test.use(devices['iPhone 13']);

  test('navigation works on mobile', async ({ page }) => {
    await page.goto('/');
    
    // Open mobile menu
    await page.getByRole('button', { name: 'Menu' }).click();
    await page.getByRole('link', { name: 'Controlboard' }).click();
    
    await expect(page).toHaveURL('/controlboard');
  });

  test('swipe gestures work in check-in', async ({ page }) => {
    await page.goto('/check-in');
    
    const card = page.getByTestId('draft-card');
    await card.swipe('left');
    
    // Next card should appear
    await expect(card).toHaveAttribute('data-index', '1');
  });
});
```

---

## 5. Logging

### Structured Logging Setup

```typescript
// lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: () => `,"time":"${new Date().toISOString()}"`,
  ...(process.env.NODE_ENV === 'development' && {
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
      },
    },
  }),
});

// Create child logger with context
export function createLogger(context: Record<string, unknown>) {
  return logger.child(context);
}
```

### Usage Patterns

```typescript
import { createLogger } from '@/lib/logger';

// In API route
const log = createLogger({ module: 'api', route: '/tickets' });

export async function POST(request: Request) {
  const requestId = crypto.randomUUID();
  const reqLog = log.child({ requestId });

  reqLog.info('Creating ticket');

  try {
    const data = await request.json();
    reqLog.debug({ data }, 'Request body parsed');

    const ticket = await createTicket(data);
    reqLog.info({ ticketId: ticket.id }, 'Ticket created successfully');

    return Response.json({ ticket }, { status: 201 });
  } catch (error) {
    reqLog.error({ error }, 'Failed to create ticket');
    return Response.json({ error: 'Failed' }, { status: 500 });
  }
}
```

### Agent Logging

```typescript
// In Mastra tools
import { createLogger } from '@/lib/logger';

const log = createLogger({ module: 'agent', tool: 'classifyTicket' });

export const classifyTicket = createTool({
  id: 'classify-ticket',
  execute: async ({ context }) => {
    const startTime = Date.now();
    log.info({ ticketTitle: context.title }, 'Starting classification');

    try {
      const result = await doClassification(context);
      
      log.info({
        duration: Date.now() - startTime,
        category: result.category,
        isHavarie: result.isHavarie,
        confidence: result.confidence,
      }, 'Classification complete');

      return result;
    } catch (error) {
      log.error({ error }, 'Classification failed');
      throw error;
    }
  },
});
```

---

## 6. Monitoring

### Error Tracking (Sentry)

```typescript
// lib/sentry.ts
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
});

// Usage
export function captureError(error: Error, context?: Record<string, unknown>) {
  Sentry.captureException(error, {
    extra: context,
  });
}
```

### Metrics

```typescript
// lib/metrics.ts
interface Metric {
  name: string;
  value: number;
  tags?: Record<string, string>;
  timestamp: Date;
}

const metrics: Metric[] = [];

export function recordMetric(
  name: string,
  value: number,
  tags?: Record<string, string>
) {
  metrics.push({
    name,
    value,
    tags,
    timestamp: new Date(),
  });

  // In production, send to metrics service
  if (process.env.NODE_ENV === 'production') {
    sendToMetricsService({ name, value, tags });
  }
}

// Usage
recordMetric('ticket.classification.duration', 1234, {
  category: 'heating_failure',
  isHavarie: 'true',
});

recordMetric('ticket.created', 1, {
  source: 'casavi',
});
```

---

## Commands

```bash
# Run all tests
pnpm run test

# Run with coverage
pnpm run test:coverage

# Run unit tests only
pnpm run test:unit

# Run integration tests
pnpm run test:integration

# Run E2E tests
pnpm run test:e2e

# Run E2E with UI
pnpm run test:e2e:ui

# Watch mode
pnpm run test:watch
```

---

## Resources

- [Vitest](https://vitest.dev)
- [Testing Library](https://testing-library.com)
- [Playwright](https://playwright.dev)
- [Pino Logger](https://getpino.io)
- [Sentry](https://docs.sentry.io)
