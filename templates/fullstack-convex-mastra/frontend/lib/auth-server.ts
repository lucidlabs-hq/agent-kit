/**
 * Auth Server
 *
 * Server-side authentication utilities for Next.js.
 *
 * Created: 29. Januar 2026
 */

import { convexBetterAuthNextJs } from "@convex-dev/better-auth/nextjs";

const convexUrl = process.env.NEXT_PUBLIC_CONVEX_URL!;
const convexSiteUrl = process.env.NEXT_PUBLIC_CONVEX_SITE_URL!;

/**
 * Server-side auth utilities
 *
 * @example
 * ```tsx
 * // In a server component
 * import { isAuthenticated, getToken } from '@/lib/auth-server';
 *
 * export default async function ProtectedPage() {
 *   const authenticated = await isAuthenticated();
 *   if (!authenticated) redirect('/login');
 *   return <div>Protected content</div>;
 * }
 * ```
 */
export const { handler, preloadAuthQuery, isAuthenticated, getToken } =
  convexBetterAuthNextJs({
    convexUrl,
    convexSiteUrl,
  });
