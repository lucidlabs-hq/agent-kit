/**
 * Quick Actions Component
 *
 * Common actions and links for development.
 *
 * Created: 29. Januar 2026
 */

"use client";

import { useState } from "react";

interface Action {
  name: string;
  description: string;
  command?: string;
  href?: string;
  category: "dev" | "test" | "docs";
}

const actions: Action[] = [
  // Development
  {
    name: "Start All Services",
    description: "Docker + Frontend + Mastra",
    command: "# Terminal 1: docker run -d --name convex-local -p 3210:3210 ghcr.io/get-convex/convex-backend:latest\n# Terminal 2: cd frontend && pnpm run dev\n# Terminal 3: cd mastra && pnpm run dev",
    category: "dev",
  },
  {
    name: "Stop Convex",
    description: "Stop and remove Convex container",
    command: "docker stop convex-local && docker rm convex-local",
    category: "dev",
  },
  {
    name: "Restart Mastra",
    description: "Kill and restart Mastra server",
    command: "pkill -f 'bun run' && cd mastra && pnpm run dev",
    category: "dev",
  },

  // Testing
  {
    name: "Run Demo Workflow",
    description: "Test invoice processing",
    command: "cd mastra && pnpm run demo:workflow",
    category: "test",
  },
  {
    name: "Health Check",
    description: "Check Mastra health",
    command: "cd mastra && pnpm run health",
    category: "test",
  },
  {
    name: "Run Tests",
    description: "Execute test suite",
    command: "cd frontend && pnpm run test",
    category: "test",
  },

  // Documentation
  {
    name: "Project README",
    description: "Main documentation",
    href: "https://github.com/lucidlabs-hq/invoice-accounting-assistant",
    category: "docs",
  },
  {
    name: "Mastra Docs",
    description: "AI framework documentation",
    href: "https://mastra.ai/docs",
    category: "docs",
  },
  {
    name: "Convex Docs",
    description: "Database documentation",
    href: "https://docs.convex.dev",
    category: "docs",
  },
];

export function QuickActions() {
  const [copiedCommand, setCopiedCommand] = useState<string | null>(null);

  const copyCommand = async (command: string, name: string) => {
    await navigator.clipboard.writeText(command);
    setCopiedCommand(name);
    setTimeout(() => setCopiedCommand(null), 2000);
  };

  const categories = {
    dev: { label: "Development", icon: "⚙️" },
    test: { label: "Testing", icon: "🧪" },
    docs: { label: "Documentation", icon: "📚" },
  };

  return (
    <div className="rounded-lg border border-zinc-800 bg-zinc-900 p-6">
      <h2 className="text-lg font-semibold">Quick Actions</h2>
      <p className="mt-1 text-sm text-zinc-500">
        Common commands and links
      </p>

      <div className="mt-6 grid gap-6 md:grid-cols-3">
        {Object.entries(categories).map(([key, category]) => (
          <div key={key} className="space-y-3">
            <h3 className="text-sm font-medium text-zinc-400">
              {category.icon} {category.label}
            </h3>
            <div className="space-y-2">
              {actions
                .filter((a) => a.category === key)
                .map((action) => (
                  <ActionCard
                    key={action.name}
                    action={action}
                    copied={copiedCommand === action.name}
                    onCopy={copyCommand}
                  />
                ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function ActionCard({
  action,
  copied,
  onCopy,
}: {
  action: Action;
  copied: boolean;
  onCopy: (command: string, name: string) => void;
}) {
  if (action.href) {
    return (
      <a
        href={action.href}
        target="_blank"
        rel="noopener noreferrer"
        className="block rounded-md border border-zinc-800 bg-zinc-950 p-3 transition-colors hover:border-zinc-700"
      >
        <div className="flex items-center justify-between">
          <span className="font-medium">{action.name}</span>
          <span className="text-xs text-zinc-500">↗</span>
        </div>
        <p className="mt-1 text-xs text-zinc-500">{action.description}</p>
      </a>
    );
  }

  return (
    <button
      onClick={() => action.command && onCopy(action.command, action.name)}
      className="block w-full cursor-pointer rounded-md border border-zinc-800 bg-zinc-950 p-3 text-left transition-colors hover:border-zinc-700"
    >
      <div className="flex items-center justify-between">
        <span className="font-medium">{action.name}</span>
        <span className="text-xs text-zinc-500">
          {copied ? "✓ Copied" : "Copy"}
        </span>
      </div>
      <p className="mt-1 text-xs text-zinc-500">{action.description}</p>
    </button>
  );
}
