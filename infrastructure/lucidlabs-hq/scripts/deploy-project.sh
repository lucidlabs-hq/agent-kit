#!/bin/bash
# =============================================================================
# LUCIDLABS-HQ - Deploy Project
#
# Deploys or updates a project on the HQ server.
# Called by GitHub Actions or manually.
#
# Usage:
#   ./deploy-project.sh <project-name>
#
# Environment:
#   PROJECT_DIR - Override project directory (default: /opt/lucidlabs/projects/<name>)
# =============================================================================

set -e

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: ./deploy-project.sh <project-name>"
    exit 1
fi

PROJECT_DIR="${PROJECT_DIR:-/opt/lucidlabs/projects/$PROJECT_NAME}"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              DEPLOYING: $PROJECT_NAME"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# -----------------------------------------------------------------------------
# Verify project exists
# -----------------------------------------------------------------------------
if [ ! -d "$PROJECT_DIR" ]; then
    echo "✗ Project directory not found: $PROJECT_DIR"
    echo "  Run add-project.sh first"
    exit 1
fi

if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo "✗ .env file not found: $PROJECT_DIR/.env"
    exit 1
fi

if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    echo "✗ docker-compose.yml not found: $PROJECT_DIR/docker-compose.yml"
    exit 1
fi

# -----------------------------------------------------------------------------
# Deploy
# -----------------------------------------------------------------------------
cd "$PROJECT_DIR"

echo "▶ Pulling latest changes..."
if [ -d ".git" ]; then
    git pull origin main
fi

echo ""
echo "▶ Building and starting containers..."
docker compose -p "$PROJECT_NAME" up -d --build

echo ""
echo "▶ Cleaning up old images..."
docker image prune -f

echo ""
echo "▶ Container status:"
docker compose -p "$PROJECT_NAME" ps

# -----------------------------------------------------------------------------
# Health check
# -----------------------------------------------------------------------------
echo ""
echo "▶ Waiting for health checks..."
sleep 10

FRONTEND_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' "${PROJECT_NAME}-frontend" 2>/dev/null || echo "unknown")
MASTRA_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' "${PROJECT_NAME}-mastra" 2>/dev/null || echo "unknown")

echo "  Frontend: $FRONTEND_HEALTH"
echo "  Mastra:   $MASTRA_HEALTH"

# -----------------------------------------------------------------------------
# Update registry
# -----------------------------------------------------------------------------
REGISTRY_FILE="/opt/lucidlabs/registry.json"
if [ -f "$REGISTRY_FILE" ]; then
    # Update lastUpdate timestamp using jq
    if command -v jq &> /dev/null; then
        TIMESTAMP=$(date -Iseconds)
        jq --arg name "$PROJECT_NAME" --arg ts "$TIMESTAMP" \
           '(.projects[] | select(.name == $name) | .lastUpdate) = $ts | (.projects[] | select(.name == $name) | .status) = "active"' \
           "$REGISTRY_FILE" > "$REGISTRY_FILE.tmp" && mv "$REGISTRY_FILE.tmp" "$REGISTRY_FILE"
        echo ""
        echo "✔ Registry updated"
    fi
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✓ DEPLOYMENT COMPLETE                                         ║"
echo "║                                                                 ║"
echo "║  Project: $PROJECT_NAME"
echo "║  Status:  Running                                               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
