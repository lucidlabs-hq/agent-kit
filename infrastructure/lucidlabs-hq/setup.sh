#!/bin/bash
# =============================================================================
# LUCIDLABS-HQ - Initial Server Setup
#
# Run this script once after provisioning the Elestio server.
#
# Usage:
#   chmod +x setup.sh
#   ./setup.sh
# =============================================================================

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              LUCIDLABS-HQ SERVER SETUP                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# -----------------------------------------------------------------------------
# 1. Create directory structure
# -----------------------------------------------------------------------------
echo "▶ Creating directory structure..."

mkdir -p /opt/lucidlabs/caddy
mkdir -p /opt/lucidlabs/projects
mkdir -p /opt/lucidlabs/logs
mkdir -p /opt/lucidlabs/backups

echo "  ✔ /opt/lucidlabs/caddy"
echo "  ✔ /opt/lucidlabs/projects"
echo "  ✔ /opt/lucidlabs/logs"
echo "  ✔ /opt/lucidlabs/backups"
echo ""

# -----------------------------------------------------------------------------
# 2. Copy base configuration
# -----------------------------------------------------------------------------
echo "▶ Copying configuration files..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp "$SCRIPT_DIR/docker-compose.yml" /opt/lucidlabs/caddy/
cp "$SCRIPT_DIR/Caddyfile" /opt/lucidlabs/caddy/
cp "$SCRIPT_DIR/registry.json" /opt/lucidlabs/

echo "  ✔ docker-compose.yml"
echo "  ✔ Caddyfile"
echo "  ✔ registry.json"
echo ""

# -----------------------------------------------------------------------------
# 3. Create .env file template
# -----------------------------------------------------------------------------
echo "▶ Creating environment template..."

cat > /opt/lucidlabs/caddy/.env << 'EOF'
# LUCIDLABS-HQ Environment Variables
# Copy to .env and fill in values

# Monitoring (optional)
# UPTIME_KUMA_ENABLED=true
EOF

echo "  ✔ .env template created"
echo ""

# -----------------------------------------------------------------------------
# 4. Set permissions
# -----------------------------------------------------------------------------
echo "▶ Setting permissions..."

chmod -R 755 /opt/lucidlabs
chmod 600 /opt/lucidlabs/caddy/.env 2>/dev/null || true

echo "  ✔ Permissions set"
echo ""

# -----------------------------------------------------------------------------
# 5. Start Caddy
# -----------------------------------------------------------------------------
echo "▶ Starting Caddy reverse proxy..."

cd /opt/lucidlabs/caddy
docker compose up -d

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✓ SETUP COMPLETE                                              ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║                                                                 ║"
echo "║  Directory structure:                                           ║"
echo "║  /opt/lucidlabs/                                                ║"
echo "║  ├── caddy/          (Reverse proxy)                           ║"
echo "║  ├── projects/       (Project deployments)                     ║"
echo "║  ├── logs/           (Centralized logs)                        ║"
echo "║  └── registry.json   (Project registry)                        ║"
echo "║                                                                 ║"
echo "║  Next steps:                                                    ║"
echo "║  1. Configure DNS: *.lucidlabs.app → Server IP                 ║"
echo "║  2. Deploy first project to /opt/lucidlabs/projects/           ║"
echo "║  3. Update Caddyfile with project routing                      ║"
echo "║                                                                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
