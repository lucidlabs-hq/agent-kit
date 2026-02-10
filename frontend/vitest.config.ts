/**
 * Vitest Configuration
 *
 * Unit testing setup for Next.js application.
 * Unit tests = 60% of testing pyramid.
 *
 * Key choices:
 * - vite-tsconfig-paths: resolves @ alias from tsconfig (recommended by Next.js docs)
 * - restoreMocks: auto-restores mocks between tests (prevents state leakage)
 * - jsdom: browser-like environment for React component tests
 */

import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [tsconfigPaths(), react()],
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: ["./src/test/setup.ts"],
    include: ["src/**/*.test.{ts,tsx}", "lib/**/*.test.{ts,tsx}"],
    restoreMocks: true,
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
      exclude: ["node_modules", "src/test", "e2e"],
    },
  },
});
