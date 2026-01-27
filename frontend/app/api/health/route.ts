/**
 * Health Check API Route
 *
 * Provides health status for container orchestration.
 * - Used by Docker HEALTHCHECK
 * - Used by Elestio monitoring
 */

import { NextResponse } from "next/server";

interface HealthStatus {
  status: "ok" | "degraded" | "unhealthy";
  timestamp: string;
  services: {
    frontend: "ok" | "error";
  };
}

export async function GET(): Promise<NextResponse<HealthStatus>> {
  const status: HealthStatus = {
    status: "ok",
    timestamp: new Date().toISOString(),
    services: {
      frontend: "ok",
    },
  };

  return NextResponse.json(status, { status: 200 });
}
