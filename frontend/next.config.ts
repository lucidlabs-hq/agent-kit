import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  // Standalone output for optimized Docker builds
  output: 'standalone',

  // Empty turbopack config to allow coexistence with webpack config
  turbopack: {},

  // Webpack config for path aliases
  webpack: (config) => {
    config.resolve.alias = {
      ...config.resolve.alias,
      '@convex': path.resolve(__dirname, './convex'),
    };
    return config;
  },
};

export default nextConfig;
