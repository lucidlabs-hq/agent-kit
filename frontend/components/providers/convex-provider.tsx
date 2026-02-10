/**
 * Convex Client Provider
 *
 * Provides Convex client context to the application.
 * Uses environment variable for deployment URL.
 *
 * If NEXT_PUBLIC_CONVEX_URL is not set, provides a context that
 * indicates Convex is not configured.
 */

"use client";

import { ConvexProvider, ConvexReactClient } from "convex/react";
import { ReactNode, useMemo, createContext, useContext } from "react";

interface ConvexConfigContextValue {
  isConfigured: boolean;
}

const ConvexConfigContext = createContext<ConvexConfigContextValue>({
  isConfigured: false,
});

export function useConvexConfig() {
  return useContext(ConvexConfigContext);
}

interface ConvexClientProviderProps {
  children: ReactNode;
}

export function ConvexClientProvider({ children }: ConvexClientProviderProps) {
  const convexUrl = process.env.NEXT_PUBLIC_CONVEX_URL;

  const convex = useMemo(() => {
    if (!convexUrl) return null;
    return new ConvexReactClient(convexUrl);
  }, [convexUrl]);

  if (!convex) {
    // Provide context indicating Convex is not configured
    return (
      <ConvexConfigContext.Provider value={{ isConfigured: false }}>
        {children}
      </ConvexConfigContext.Provider>
    );
  }

  return (
    <ConvexConfigContext.Provider value={{ isConfigured: true }}>
      <ConvexProvider client={convex}>{children}</ConvexProvider>
    </ConvexConfigContext.Provider>
  );
}
