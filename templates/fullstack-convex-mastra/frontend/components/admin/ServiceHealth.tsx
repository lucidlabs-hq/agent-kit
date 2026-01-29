/**
 * Service Health Component
 *
 * Displays health status of all services.
 *
 * Created: 29. Januar 2026
 */

"use client";

import { useEffect, useState } from "react";

interface ServiceStatus {
  name: string;
  url: string;
  status: "checking" | "healthy" | "unhealthy";
  latency?: number;
  details?: string;
}

const services: Omit<ServiceStatus, "status" | "latency" | "details">[] = [
  { name: "Frontend", url: "/" },
  { name: "Convex Backend", url: "http://localhost:3210" },
  { name: "Convex Dashboard", url: "http://localhost:6791" },
  { name: "Mastra API", url: "http://localhost:4000/health" },
  { name: "Mastra Studio", url: "http://localhost:4111" },
];

export function ServiceHealth() {
  const [statuses, setStatuses] = useState<ServiceStatus[]>(
    services.map((s) => ({ ...s, status: "checking" }))
  );

  useEffect(() => {
    async function checkServices() {
      const results = await Promise.all(
        services.map(async (service) => {
          const start = Date.now();
          try {
            const res = await fetch(service.url, {
              method: "GET",
              signal: AbortSignal.timeout(5000),
            });
            const latency = Date.now() - start;

            if (res.ok) {
              let details = "OK";
              if (service.name === "Mastra") {
                const data = await res.json();
                details = `Agents: ${data.agents?.length || 0}, Workflows: ${data.workflows?.length || 0}`;
              }
              return { ...service, status: "healthy" as const, latency, details };
            }
            return { ...service, status: "unhealthy" as const, details: `HTTP ${res.status}` };
          } catch (error) {
            return {
              ...service,
              status: "unhealthy" as const,
              details: error instanceof Error ? error.message : "Connection failed",
            };
          }
        })
      );
      setStatuses(results);
    }

    checkServices();
    const interval = setInterval(checkServices, 30000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="rounded-lg border border-zinc-800 bg-zinc-900 p-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold">Service Health</h2>
          <p className="mt-1 text-sm text-zinc-500">
            Real-time status of all services
          </p>
        </div>
        <button
          onClick={() => window.location.reload()}
          className="rounded-md border border-zinc-700 px-3 py-1.5 text-sm hover:bg-zinc-800"
        >
          Refresh
        </button>
      </div>

      <div className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
        {statuses.map((service) => (
          <div
            key={service.name}
            className="rounded-lg border border-zinc-800 bg-zinc-950 p-4"
          >
            <div className="flex items-center gap-3">
              <StatusIndicator status={service.status} />
              <div>
                <h3 className="font-medium">{service.name}</h3>
                <p className="text-xs text-zinc-500">{service.url}</p>
              </div>
            </div>

            <div className="mt-3 flex items-center justify-between text-sm">
              <span className="text-zinc-500">
                {service.status === "checking"
                  ? "Checking..."
                  : service.details}
              </span>
              {service.latency && (
                <span className="text-zinc-500">{service.latency}ms</span>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function StatusIndicator({ status }: { status: ServiceStatus["status"] }) {
  const colors = {
    checking: "bg-zinc-500 animate-pulse",
    healthy: "bg-emerald-500",
    unhealthy: "bg-red-500",
  };

  return (
    <span className={`inline-block h-3 w-3 rounded-full ${colors[status]}`} />
  );
}
