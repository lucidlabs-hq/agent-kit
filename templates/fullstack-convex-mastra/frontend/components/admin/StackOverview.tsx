/**
 * Stack Overview Component
 *
 * Displays the current tech stack configuration.
 *
 * Created: 29. Januar 2026
 */

"use client";

const stackConfig = {
  frontend: {
    name: "Frontend",
    items: [
      { name: "Next.js", version: "16.0", description: "App Router, Server Components" },
      { name: "React", version: "19.2", description: "UI Library" },
      { name: "Tailwind CSS", version: "4.0", description: "Utility-first CSS" },
      { name: "shadcn/ui", version: "latest", description: "Accessible components" },
    ],
  },
  backend: {
    name: "Backend",
    items: [
      { name: "Convex", version: "self-hosted", description: "Realtime database" },
      { name: "Mastra", version: "1.0-beta", description: "AI Agent framework" },
      { name: "Better Auth", version: "1.4", description: "Authentication" },
    ],
  },
  ai: {
    name: "AI / LLM",
    items: [
      { name: "Ollama (dev)", version: "phi3:mini", description: "Offline development" },
      { name: "Portkey (prod)", version: "→ Claude", description: "Production AI" },
    ],
  },
};

export function StackOverview() {
  return (
    <div className="rounded-lg border border-zinc-800 bg-zinc-900 p-6">
      <h2 className="text-lg font-semibold">Stack Overview</h2>
      <p className="mt-1 text-sm text-zinc-500">
        Current technology configuration
      </p>

      <div className="mt-6 grid gap-6 md:grid-cols-3">
        {Object.entries(stackConfig).map(([key, category]) => (
          <div key={key} className="space-y-3">
            <h3 className="text-sm font-medium text-zinc-400">{category.name}</h3>
            <div className="space-y-2">
              {category.items.map((item) => (
                <div
                  key={item.name}
                  className="rounded-md border border-zinc-800 bg-zinc-950 p-3"
                >
                  <div className="flex items-center justify-between">
                    <span className="font-medium">{item.name}</span>
                    <span className="text-xs text-zinc-500">{item.version}</span>
                  </div>
                  <p className="mt-1 text-xs text-zinc-500">{item.description}</p>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
