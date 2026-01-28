#!/usr/bin/env npx tsx
/**
 * Read-Only Protection Proxy
 *
 * A local proxy that intercepts API requests and blocks write operations.
 * Use this when working with production databases to prevent accidental modifications.
 *
 * SECURITY NOTES:
 * - Credentials are passed via CLI arguments or environment variables
 * - Credentials should NEVER be stored in project files
 * - Store credentials in ~/.credentials/ or pass directly in terminal
 *
 * Usage:
 *   Terminal 1 (start proxy):
 *     ./scripts/read-only-proxy.ts \
 *       --api-url https://api.example.com \
 *       --api-key "$(cat ~/.credentials/api-key.txt)" \
 *       --port 3333
 *
 *   Terminal 2 (run scripts):
 *     USE_PROXY=true PROXY_URL=http://localhost:3333 npx tsx scripts/my-script.ts
 */

import http from "http";
import https from "https";
import { URL } from "url";

// Configuration from CLI arguments or environment
interface ProxyConfig {
  apiUrl: string;
  apiKey: string;
  port: number;
  allowedWritePaths: string[];
}

// Parse CLI arguments
const parseArgs = (): ProxyConfig => {
  const args = process.argv.slice(2);
  const config: Partial<ProxyConfig> = {
    port: 3333,
    allowedWritePaths: ["/auth/login", "/auth/refresh", "/authenticate"],
  };

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case "--api-url":
        config.apiUrl = args[++i];
        break;
      case "--api-key":
        config.apiKey = args[++i];
        break;
      case "--port":
        config.port = parseInt(args[++i], 10);
        break;
      case "--allow-write":
        config.allowedWritePaths?.push(args[++i]);
        break;
      case "--help":
        console.log(`
Read-Only Protection Proxy

Usage:
  ./read-only-proxy.ts --api-url <url> --api-key <key> [options]

Options:
  --api-url <url>       Target API URL (required)
  --api-key <key>       API key for authentication (required)
  --port <number>       Local proxy port (default: 3333)
  --allow-write <path>  Additional paths to allow writes (can be repeated)
  --help                Show this help message

Environment Variables (alternative to CLI):
  API_URL               Target API URL
  API_KEY               API key for authentication
  PROXY_PORT            Local proxy port

Security:
  - Pass credentials via CLI or environment variables
  - NEVER store credentials in project files
  - Use: --api-key "$(cat ~/.credentials/my-key.txt)"
        `);
        process.exit(0);
    }
  }

  // Fall back to environment variables
  config.apiUrl = config.apiUrl || process.env.API_URL;
  config.apiKey = config.apiKey || process.env.API_KEY;
  config.port = config.port || parseInt(process.env.PROXY_PORT || "3333", 10);

  if (!config.apiUrl || !config.apiKey) {
    console.error("Error: --api-url and --api-key are required");
    console.error("Run with --help for usage information");
    process.exit(1);
  }

  return config as ProxyConfig;
};

// Check if request should be blocked
const shouldBlock = (
  method: string,
  path: string,
  allowedWritePaths: string[]
): boolean => {
  const writeMethods = ["POST", "PUT", "PATCH", "DELETE"];

  if (!writeMethods.includes(method.toUpperCase())) {
    return false; // GET, HEAD, OPTIONS are always allowed
  }

  // Check if path is in allowed write paths
  for (const allowedPath of allowedWritePaths) {
    if (path.startsWith(allowedPath)) {
      return false; // This write path is explicitly allowed
    }
  }

  return true; // Block all other writes
};

// Format log message
const log = (
  method: string,
  path: string,
  status: number | string,
  blocked = false
): void => {
  const timestamp = new Date().toISOString().replace("T", " ").split(".")[0];
  const statusStr = blocked ? `BLOCKED (${status})` : `${status}`;
  const color = blocked ? "\x1b[31m" : status < 400 ? "\x1b[32m" : "\x1b[33m";
  const reset = "\x1b[0m";
  console.log(`[${timestamp}] ${method} ${path} → ${color}${statusStr}${reset}`);
};

// Create the proxy server
const createProxy = (config: ProxyConfig): http.Server => {
  const targetUrl = new URL(config.apiUrl);
  const isHttps = targetUrl.protocol === "https:";
  const httpModule = isHttps ? https : http;

  return http.createServer((clientReq, clientRes) => {
    const method = clientReq.method || "GET";
    const path = clientReq.url || "/";

    // Health check endpoint
    if (path === "/health") {
      clientRes.writeHead(200, { "Content-Type": "application/json" });
      clientRes.end(JSON.stringify({ status: "ok", mode: "read-only" }));
      log(method, path, 200);
      return;
    }

    // Check if request should be blocked
    if (shouldBlock(method, path, config.allowedWritePaths)) {
      log(method, path, 403, true);
      clientRes.writeHead(403, { "Content-Type": "application/json" });
      clientRes.end(
        JSON.stringify({
          error: "Forbidden",
          message: "Write operations are blocked by read-only proxy",
          method: method,
          path: path,
        })
      );
      return;
    }

    // Forward request to target API
    const options: https.RequestOptions = {
      hostname: targetUrl.hostname,
      port: targetUrl.port || (isHttps ? 443 : 80),
      path: path,
      method: method,
      headers: {
        ...clientReq.headers,
        host: targetUrl.hostname,
        authorization: `Bearer ${config.apiKey}`,
      },
    };

    const proxyReq = httpModule.request(options, (proxyRes) => {
      log(method, path, proxyRes.statusCode || 0);
      clientRes.writeHead(proxyRes.statusCode || 500, proxyRes.headers);
      proxyRes.pipe(clientRes);
    });

    proxyReq.on("error", (err) => {
      log(method, path, "ERROR");
      console.error(`Proxy error: ${err.message}`);
      clientRes.writeHead(502, { "Content-Type": "application/json" });
      clientRes.end(
        JSON.stringify({
          error: "Bad Gateway",
          message: err.message,
        })
      );
    });

    clientReq.pipe(proxyReq);
  });
};

// Main
const main = (): void => {
  const config = parseArgs();

  console.log("\n╔═══════════════════════════════════════════════════════════╗");
  console.log("║           READ-ONLY PROTECTION PROXY                      ║");
  console.log("╚═══════════════════════════════════════════════════════════╝\n");

  console.log(`Target API:     ${config.apiUrl}`);
  console.log(`Local Port:     ${config.port}`);
  console.log(`Proxy URL:      http://localhost:${config.port}`);
  console.log(`\nAllowed write paths:`);
  config.allowedWritePaths.forEach((p) => console.log(`  - ${p}`));

  console.log("\n┌─────────────────────────────────────────────────────────┐");
  console.log("│  All other POST/PUT/PATCH/DELETE requests are BLOCKED  │");
  console.log("└─────────────────────────────────────────────────────────┘\n");

  const server = createProxy(config);

  server.listen(config.port, () => {
    console.log(`Proxy listening on http://localhost:${config.port}`);
    console.log("\nPress Ctrl+C to stop\n");
    console.log("─".repeat(60));
  });

  // Graceful shutdown
  process.on("SIGINT", () => {
    console.log("\n\nShutting down proxy...");
    server.close(() => {
      console.log("Proxy stopped.");
      process.exit(0);
    });
  });
};

main();
