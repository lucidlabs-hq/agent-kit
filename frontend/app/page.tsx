/**
 * Home Page
 *
 * Landing page for the Agent Kit template.
 * Replace with your application's main content.
 */

import { AppShell } from "@/components/Layout/app-shell";
import { AppHeader } from "@/components/Layout/app-header";
import { Card } from "@/components/ui/card";
import { Bot, Workflow, Database, Zap } from "lucide-react";

export default function HomePage() {
  return (
    <AppShell>
      <div className="flex flex-col">
        <AppHeader
          title="Agent Kit"
          subtitle="AI Agent Starter Kit by Lucid Labs GmbH"
        />

        <div className="px-8 pb-8">
          {/* Hero Section */}
          <Card className="mb-6 border-indigo-100 bg-gradient-to-br from-indigo-50 to-white p-6">
            <div className="flex items-start gap-4">
              <div className="rounded-lg bg-indigo-100 p-3">
                <Bot className="size-8 text-indigo-600" />
              </div>
              <div>
                <h2 className="text-lg font-semibold text-slate-900">
                  Welcome to Agent Kit
                </h2>
                <p className="mt-1 text-sm text-slate-600">
                  Your foundation for building AI-powered applications with
                  Next.js, Mastra, Convex, and n8n.
                </p>
              </div>
            </div>
          </Card>

          {/* Features Grid */}
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            <FeatureCard
              icon={<Bot className="size-5" />}
              title="AI Agents"
              description="Build intelligent agents with Mastra framework and Claude models."
            />
            <FeatureCard
              icon={<Database className="size-5" />}
              title="Realtime Database"
              description="Convex provides reactive data sync and vector search."
            />
            <FeatureCard
              icon={<Workflow className="size-5" />}
              title="Workflows"
              description="n8n integration for complex automation workflows."
            />
            <FeatureCard
              icon={<Zap className="size-5" />}
              title="Fast Development"
              description="Bun runtime for dev, Node.js for production stability."
            />
          </div>

          {/* Getting Started */}
          <Card className="mt-6 p-6">
            <h3 className="text-base font-semibold text-slate-900">
              Getting Started
            </h3>
            <div className="mt-4 space-y-3 text-sm text-slate-600">
              <Step number={1} text="Update .claude/PRD.md with your project requirements" />
              <Step number={2} text="Run /plan-feature to create an implementation plan" />
              <Step number={3} text="Execute with /execute and validate with /validate" />
              <Step number={4} text="Commit changes with /commit" />
            </div>
          </Card>
        </div>
      </div>
    </AppShell>
  );
}

function FeatureCard({
  icon,
  title,
  description,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
}) {
  return (
    <Card className="p-4">
      <div className="flex items-start gap-3">
        <div className="rounded-md bg-slate-100 p-2 text-slate-600">
          {icon}
        </div>
        <div>
          <h4 className="font-medium text-slate-900">{title}</h4>
          <p className="mt-1 text-sm text-slate-500">{description}</p>
        </div>
      </div>
    </Card>
  );
}

function Step({ number, text }: { number: number; text: string }) {
  return (
    <div className="flex items-start gap-3">
      <span className="flex size-6 shrink-0 items-center justify-center rounded-full bg-indigo-100 text-xs font-medium text-indigo-600">
        {number}
      </span>
      <span>{text}</span>
    </div>
  );
}
