/**
 * Convex Client Provider
 *
 * Wraps the application with ConvexProvider and Better Auth.
 * Supports development mode without authentication.
 *
 * Created: 29. Januar 2026
 */

"use client";

import { ReactNode } from "react";
import { ConvexReactClient } from "convex/react";
import { ConvexBetterAuthProvider } from "@convex-dev/better-auth/react";
import { ConvexProvider } from "convex/react";
import { authClient } from "@/lib/auth-client";

const convexUrl = process.env.NEXT_PUBLIC_CONVEX_URL!;
const convex = new ConvexReactClient(convexUrl);

// Check if auth is enabled (disabled in offline/dev mode)
const AUTH_ENABLED = process.env.NEXT_PUBLIC_AUTH_ENABLED === "true";

interface ConvexClientProviderProps {
  children: ReactNode;
  initialToken?: string;
}

/**
 * ConvexClientProvider
 *
 * In development mode (AUTH_ENABLED=false):
 * - Uses simple ConvexProvider without auth
 * - Allows offline development
 *
 * In production mode (AUTH_ENABLED=true):
 * - Uses ConvexBetterAuthProvider with full auth
 * - Requires Convex backend to be running
 */
export function ConvexClientProvider({
  children,
  initialToken,
}: ConvexClientProviderProps) {
  // Development mode: No auth required
  if (!AUTH_ENABLED) {
    return <ConvexProvider client={convex}>{children}</ConvexProvider>;
  }

  // Production mode: Full auth
  return (
    <ConvexBetterAuthProvider
      client={convex}
      authClient={authClient}
      initialToken={initialToken}
    >
      {children}
    </ConvexBetterAuthProvider>
  );
}

/**
 * Development user for testing
 *
 * When AUTH_ENABLED=false, use these credentials:
 * - Email: dev@lucidlabs.de
 * - Password: dev123
 *
 * These are only valid in development mode.
 */
export const DEV_USER = {
  email: "dev@lucidlabs.de",
  name: "Dev User",
  role: "admin",
};
