# Convex Backend

Convex is a reactive backend-as-a-service that provides:
- Real-time database with automatic sync
- TypeScript-first API
- Built-in vector search for RAG
- Serverless functions (queries, mutations, actions)

## Setup

### Cloud (Recommended for Production)

1. Create a Convex account at [convex.dev](https://convex.dev)
2. Initialize the project:

```bash
npx convex init
```

3. Deploy:

```bash
npx convex deploy
```

### Self-Hosted (Development/Privacy)

For self-hosted deployments, use the Convex Local Backend:

```bash
# Using Docker
docker run -p 3210:3210 convex/convex-local-backend:latest

# Set environment variable
export CONVEX_URL=http://localhost:3210
```

## Project Structure

```
convex/
├── schema.ts           # Database schema definition
├── functions/
│   ├── queries.ts      # Read-only operations (reactive)
│   ├── mutations.ts    # Write operations
│   └── actions.ts      # External API calls
├── convex.json         # Configuration
└── _generated/         # Auto-generated types (don't edit)
```

## Usage in Frontend

```typescript
// Install Convex client
// pnpm add convex

// In your Next.js app
import { ConvexProvider, ConvexReactClient } from "convex/react";

const convex = new ConvexReactClient(process.env.NEXT_PUBLIC_CONVEX_URL!);

// In layout.tsx
<ConvexProvider client={convex}>
  {children}
</ConvexProvider>

// In components - queries are reactive!
import { useQuery, useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

function TaskList() {
  const tasks = useQuery(api.functions.queries.listTasks);
  const createTask = useMutation(api.functions.mutations.createTask);

  return (
    <div>
      {tasks?.map(task => <TaskCard key={task._id} task={task} />)}
      <button onClick={() => createTask({ title: "New Task" })}>
        Add Task
      </button>
    </div>
  );
}
```

## Key Concepts

### Queries (Reactive Reads)

- Automatically re-run when underlying data changes
- Used with `useQuery` hook in React
- Must be pure functions (no side effects)

### Mutations (Writes)

- Modify database state
- Transactional and consistent
- Used with `useMutation` hook

### Actions (External Calls)

- Can call external APIs
- Not reactive
- Used for AI models, webhooks, etc.

## Vector Search (RAG)

Convex has built-in vector search for retrieval-augmented generation:

```typescript
// In schema.ts
documents: defineTable({
  content: v.string(),
  embedding: v.array(v.float64()),
}).vectorIndex("by_embedding", {
  vectorField: "embedding",
  dimensions: 1536,
});

// In actions.ts
const results = await ctx.vectorSearch("documents", "by_embedding", {
  vector: queryEmbedding,
  limit: 10,
});
```

## Environment Variables

```env
# Cloud Convex
NEXT_PUBLIC_CONVEX_URL=https://your-project.convex.cloud

# Self-hosted
NEXT_PUBLIC_CONVEX_URL=http://localhost:3210
CONVEX_DEPLOY_KEY=your-deploy-key
```

## Documentation

- [Convex Docs](https://docs.convex.dev/)
- [Convex + Next.js Guide](https://docs.convex.dev/client/react/nextjs)
- [Vector Search](https://docs.convex.dev/vector-search)
