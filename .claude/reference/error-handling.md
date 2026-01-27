# Error Handling Patterns

> Comprehensive error handling guidelines for API routes and frontend components.

---

## Table of Contents

1. [API Routes](#1-api-routes)
2. [Frontend Error Handling](#2-frontend-error-handling)
3. [Structured Logging](#3-structured-logging)
4. [Graceful Degradation](#4-graceful-degradation)
5. [Best Practices](#5-best-practices)

---

## 1. API Routes

### Basic Pattern

```typescript
// app/api/[resource]/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const resource = await fetchResource(params.id)

    if (!resource) {
      return NextResponse.json(
        { error: 'Resource not found' },
        { status: 404 }
      )
    }

    return NextResponse.json(resource)
  } catch (error) {
    console.error('[Resource API Error]', {
      resourceId: params.id,
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined
    })

    return NextResponse.json(
      { error: 'Failed to fetch resource. Please try again.' },
      { status: 500 }
    )
  }
}
```

### User-Friendly Messages

**Good:**
```typescript
return NextResponse.json(
  { error: 'Resource not found. Please check the ID and try again.' },
  { status: 404 }
)
```

**Bad:**
```typescript
return NextResponse.json(
  { error: 'Error: ENOENT: no such file or directory' },
  { status: 500 }
)
```

### Agent Error Handling

```typescript
// app/api/agents/[name]/route.ts
import { agent } from '@/agents/[name]'

export async function POST(req: Request) {
  try {
    const { input, conversationId } = await req.json()

    if (!input) {
      return Response.json(
        { error: 'Input is required' },
        { status: 400 }
      )
    }

    const stream = await agent.stream({
      input,
      conversationId
    })

    return stream
  } catch (error) {
    console.error('[Agent Error]', {
      input: req.body?.input,
      conversationId: req.body?.conversationId,
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined
    })

    return Response.json(
      { error: 'Processing failed. Please try again.' },
      { status: 500 }
    )
  }
}
```

---

## 2. Frontend Error Handling

### Error Boundaries

```typescript
// components/ErrorBoundary.tsx
'use client'

import { Component, ErrorInfo, ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false
  }

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('[Error Boundary]', {
      error: error.message,
      componentStack: errorInfo.componentStack,
      stack: error.stack
    })

    // Log to Sentry in production
    if (process.env.NODE_ENV === 'production') {
      // Sentry.captureException(error, { contexts: { react: errorInfo } })
    }
  }

  public render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="p-8 text-center">
          <h2 className="text-xl font-semibold text-slate-800 mb-4">
            Something went wrong
          </h2>
          <p className="text-slate-600 mb-4">
            We're sorry, but something unexpected happened.
          </p>
          <button
            onClick={() => this.setState({ hasError: false })}
            className="px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700"
          >
            Try again
          </button>
        </div>
      )
    }

    return this.props.children
  }
}
```

### Usage

```typescript
// app/[feature]/page.tsx
import { ErrorBoundary } from '@/components/ErrorBoundary'
import { FeatureComponent } from '@/components/Feature/FeatureComponent'

export default function FeaturePage() {
  return (
    <ErrorBoundary>
      <FeatureComponent />
    </ErrorBoundary>
  )
}
```

### Toast Notifications

```typescript
// hooks/useToast.ts
'use client'

import { useState, useCallback } from 'react'

interface Toast {
  id: string
  message: string
  type: 'success' | 'error' | 'info'
}

export function useToast() {
  const [toasts, setToasts] = useState<Toast[]>([])

  const showToast = useCallback((message: string, type: Toast['type'] = 'info') => {
    const id = Math.random().toString(36).substr(2, 9)
    setToasts(prev => [...prev, { id, message, type }])

    setTimeout(() => {
      setToasts(prev => prev.filter(t => t.id !== id))
    }, 5000)
  }, [])

  return { toasts, showToast }
}
```

### API Call Error Handling

```typescript
// lib/api/resources.ts
export async function fetchResource(resourceId: string): Promise<Resource> {
  try {
    const response = await fetch(`/api/resources/${resourceId}`)

    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.error || 'Failed to fetch resource')
    }

    return await response.json()
  } catch (error) {
    console.error('[Fetch Resource Error]', {
      resourceId,
      error: error instanceof Error ? error.message : 'Unknown error'
    })
    throw error
  }
}
```

### Component Error Handling

```typescript
// components/Feature/FeatureDetail.tsx
'use client'

import { useState, useEffect } from 'react'
import { fetchResource } from '@/lib/api/resources'
import { useToast } from '@/hooks/useToast'

export function FeatureDetail({ resourceId }: { resourceId: string }) {
  const [resource, setResource] = useState<Resource | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const { showToast } = useToast()

  useEffect(() => {
    async function loadResource() {
      try {
        setIsLoading(true)
        setError(null)
        const data = await fetchResource(resourceId)
        setResource(data)
      } catch (err) {
        const message = err instanceof Error ? err.message : 'Failed to load resource'
        setError(message)
        showToast(message, 'error')
      } finally {
        setIsLoading(false)
      }
    }

    loadResource()
  }, [resourceId, showToast])

  if (isLoading) {
    return <div>Loading...</div>
  }

  if (error) {
    return (
      <div className="p-4 bg-slate-50 border border-slate-200 rounded">
        <p className="text-slate-800">Error: {error}</p>
        <button
          onClick={() => window.location.reload()}
          className="mt-2 px-4 py-2 bg-indigo-600 text-white rounded"
        >
          Retry
        </button>
      </div>
    )
  }

  if (!resource) {
    return <div>Resource not found</div>
  }

  return <div>{/* Resource details */}</div>
}
```

---

## 3. Structured Logging

### Format: `[Component] Message`

```typescript
// API Routes
console.error('[Resource API] Failed to fetch resource', { resourceId, error })
console.info('[Agent API] Processing request', { input, conversationId })

// Components
console.error('[FeatureDetail] Failed to load resource', { resourceId, error })
console.warn('[FeatureList] Empty state', { filters })

// Utilities
console.error('[Date Utils] Invalid date format', { input, expectedFormat })
```

### JSON Format for Production

```typescript
// For production logging (Elestio captures stdout)
console.log(JSON.stringify({
  level: 'error',
  component: 'Resource API',
  message: 'Failed to fetch resource',
  resourceId: params.id,
  userId: req.headers.get('user-id'),
  timestamp: new Date().toISOString(),
  error: {
    message: error.message,
    stack: error.stack
  }
}))
```

---

## 4. Graceful Degradation

### Network Failures

```typescript
// components/Feature/FeatureList.tsx
'use client'

export function FeatureList() {
  const [resources, setResources] = useState<Resource[]>([])
  const [isOffline, setIsOffline] = useState(false)

  useEffect(() => {
    const handleOnline = () => setIsOffline(false)
    const handleOffline = () => setIsOffline(true)

    window.addEventListener('online', handleOnline)
    window.addEventListener('offline', handleOffline)

    return () => {
      window.removeEventListener('online', handleOnline)
      window.removeEventListener('offline', handleOffline)
    }
  }, [])

  if (isOffline) {
    return (
      <div className="p-4 bg-slate-50 border border-slate-200 rounded">
        <p className="text-slate-800">
          You're currently offline. Please check your connection.
        </p>
      </div>
    )
  }

  // ... rest of component
}
```

### Partial Data Loading

```typescript
// Load critical data first, non-critical data can fail
const [criticalData, setCriticalData] = useState<CriticalData | null>(null)
const [optionalData, setOptionalData] = useState<OptionalData | null>(null)

useEffect(() => {
  // Critical data - show error if fails
  fetchCriticalData()
    .then(setCriticalData)
    .catch(error => {
      console.error('[Critical] Failed to load', error)
      showToast('Failed to load essential data', 'error')
    })

  // Optional data - fail silently
  fetchOptionalData()
    .then(setOptionalData)
    .catch(error => {
      console.warn('[Optional] Failed to load', error)
      // Don't show error to user
    })
}, [])
```

---

## 5. Best Practices

1. **Always use try-catch** in API routes
2. **Structured logging** - `[Component] Message` format
3. **User-friendly messages** - No technical jargon
4. **Error Boundaries** - Catch React component errors
5. **Toast notifications** - For user-facing errors
6. **Graceful degradation** - Handle network failures
7. **Log full context** - Include relevant data for debugging
8. **Separate critical/optional** - Critical errors shown, optional fail silently

---

## Related References

- `mastra-best-practices.md` - Agent error handling
- `deployment.md` - Production logging
- `cursor-patterns.md` - Code structure
