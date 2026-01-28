#!/bin/bash
# =============================================================================
# LUCIDLABS-HQ - Add New Project
#
# Adds a new project to the HQ server.
#
# Usage:
#   ./add-project.sh <project-name> <subdomain>
#
# Example:
#   ./add-project.sh invoice-accounting-assistant invoice
# =============================================================================

set -e

PROJECT_NAME=$1
SUBDOMAIN=$2

if [ -z "$PROJECT_NAME" ] || [ -z "$SUBDOMAIN" ]; then
    echo "Usage: ./add-project.sh <project-name> <subdomain>"
    echo "Example: ./add-project.sh invoice-accounting-assistant invoice"
    exit 1
fi

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              ADD PROJECT: $PROJECT_NAME"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# -----------------------------------------------------------------------------
# 1. Create project directory
# -----------------------------------------------------------------------------
PROJECT_DIR="/opt/lucidlabs/projects/$PROJECT_NAME"

if [ -d "$PROJECT_DIR" ]; then
    echo "⚠ Project directory already exists: $PROJECT_DIR"
else
    mkdir -p "$PROJECT_DIR"
    echo "✔ Created: $PROJECT_DIR"
fi

# -----------------------------------------------------------------------------
# 2. Create .env template
# -----------------------------------------------------------------------------
if [ ! -f "$PROJECT_DIR/.env" ]; then
    cat > "$PROJECT_DIR/.env" << EOF
# $PROJECT_NAME Environment Variables
# Fill in the values below

# Convex
CONVEX_URL=https://your-project.convex.cloud

# AI Keys
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...

# N8N (if enabled)
# N8N_USER=admin
# N8N_PASSWORD=changeme
EOF
    chmod 600 "$PROJECT_DIR/.env"
    echo "✔ Created: .env template (fill in values!)"
else
    echo "⚠ .env already exists"
fi

# -----------------------------------------------------------------------------
# 3. Add to Caddyfile
# -----------------------------------------------------------------------------
CADDY_ENTRY="
# === $PROJECT_NAME ===
$SUBDOMAIN.lucidlabs.de {
    reverse_proxy $PROJECT_NAME-frontend:3000

    handle /api/agent/* {
        reverse_proxy $PROJECT_NAME-mastra:4000
    }

    log {
        output file /data/logs/$SUBDOMAIN.log {
            roll_size 10mb
            roll_keep 5
        }
    }
}"

echo ""
echo "▶ Add this to /opt/lucidlabs/caddy/Caddyfile:"
echo "────────────────────────────────────────────────────────────────"
echo "$CADDY_ENTRY"
echo "────────────────────────────────────────────────────────────────"
echo ""

# -----------------------------------------------------------------------------
# 4. Update registry
# -----------------------------------------------------------------------------
echo "▶ Update /opt/lucidlabs/registry.json with:"
echo "────────────────────────────────────────────────────────────────"
cat << EOF
{
  "name": "$PROJECT_NAME",
  "subdomain": "$SUBDOMAIN",
  "url": "https://$SUBDOMAIN.lucidlabs.de",
  "repo": "lucidlabs-hq/$PROJECT_NAME",
  "status": "pending",
  "services": {
    "frontend": {
      "container": "$PROJECT_NAME-frontend",
      "port": 3000
    },
    "mastra": {
      "container": "$PROJECT_NAME-mastra",
      "port": 4000
    }
  }
}
EOF
echo "────────────────────────────────────────────────────────────────"
echo ""

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✓ PROJECT PREPARED                                            ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║                                                                 ║"
echo "║  Next steps:                                                    ║"
echo "║  1. Fill in $PROJECT_DIR/.env                                  ║"
echo "║  2. Copy docker-compose.yml to $PROJECT_DIR                    ║"
echo "║  3. Add Caddy entry (shown above)                              ║"
echo "║  4. docker compose restart caddy                               ║"
echo "║  5. Deploy project code                                        ║"
echo "║                                                                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
