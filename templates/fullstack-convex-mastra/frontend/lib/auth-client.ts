/**
 * Auth Client
 *
 * Client-side authentication utilities using Better Auth.
 *
 * Created: 29. Januar 2026
 */

import { convexClient } from "@convex-dev/better-auth/client/plugins";
import { createAuthClient } from "better-auth/react";

/**
 * Auth client for use in React components
 *
 * @example
 * ```tsx
 * import { authClient } from '@/lib/auth-client';
 *
 * // Sign in
 * await authClient.signIn.email({ email, password });
 *
 * // Sign out
 * await authClient.signOut();
 *
 * // Get session
 * const session = authClient.useSession();
 * ```
 */
export const authClient = createAuthClient({
  plugins: [convexClient()],
});

// Export commonly used hooks and methods
export const { useSession, signIn, signOut, signUp } = authClient;
