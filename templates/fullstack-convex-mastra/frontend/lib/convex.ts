/**
 * Convex Client Configuration
 *
 * Provides ConvexProvider for React and client utilities.
 * Uses local backend in development, self-hosted on HQ in production.
 */

import { ConvexProvider, ConvexReactClient } from 'convex/react';

const convexUrl = process.env.NEXT_PUBLIC_CONVEX_URL!;

if (!convexUrl) {
  throw new Error(
    'NEXT_PUBLIC_CONVEX_URL is not set. ' +
      'For local dev: run `npx convex dev` and set NEXT_PUBLIC_CONVEX_URL=http://localhost:3210'
  );
}

export const convex = new ConvexReactClient(convexUrl);

export { ConvexProvider };
