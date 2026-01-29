#!/bin/bash
#
# Template Setup Script
# Copies and configures the fullstack-convex-mastra template
#
# Usage: ./setup.sh <project-name> [target-dir]
#
# Created: 29. Januar 2026

set -e

PROJECT_NAME="${1:-my-project}"
TARGET_DIR="${2:-.}"
TEMPLATE_DIR="$(dirname "$0")"

echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│  Full-Stack Template: Convex + Mastra                            │"
echo "│  Setting up: $PROJECT_NAME"
echo "╰──────────────────────────────────────────────────────────────────╯"
echo ""

# Create project directory
mkdir -p "$TARGET_DIR/$PROJECT_NAME"
cd "$TARGET_DIR/$PROJECT_NAME"

echo "[1/5] Creating directory structure..."
mkdir -p frontend/src/{app,components/{ui,providers},lib}
mkdir -p frontend/convex/betterAuth
mkdir -p mastra/src/{agents,tools,workflows,config}
mkdir -p .claude/skills/deploy

echo "[2/5] Copying template files..."
# Copy from template source (adjust paths as needed)
cp -r "$TEMPLATE_DIR/frontend/" frontend/ 2>/dev/null || true
cp -r "$TEMPLATE_DIR/mastra/" mastra/ 2>/dev/null || true
cp -r "$TEMPLATE_DIR/.claude/" .claude/ 2>/dev/null || true

echo "[3/5] Creating environment files..."
cat > frontend/.env.local << 'EOF'
# Local Development Configuration
NEXT_PUBLIC_CONVEX_URL=http://localhost:3210
NEXT_PUBLIC_MASTRA_URL=http://localhost:4000
NEXT_PUBLIC_AUTH_ENABLED=false

# LLM (Ollama for offline dev)
LLM_BASE_URL=http://localhost:11434/v1
LLM_MODEL=phi3:mini
LLM_PROVIDER=ollama
EOF

echo "[4/5] Installing dependencies..."
cd frontend && pnpm install
cd ../mastra && pnpm install
cd ..

echo "[5/5] Setup complete!"
echo ""
echo "╭──────────────────────────────────────────────────────────────────╮"
echo "│  Next Steps:                                                      │"
echo "├──────────────────────────────────────────────────────────────────┤"
echo "│                                                                   │"
echo "│  1. Start Convex:                                                 │"
echo "│     docker run -d --name convex-local -p 3210:3210 \\             │"
echo "│       ghcr.io/get-convex/convex-backend:latest                   │"
echo "│                                                                   │"
echo "│  2. Start Frontend:                                               │"
echo "│     cd frontend && pnpm run dev                                  │"
echo "│                                                                   │"
echo "│  3. Start Mastra:                                                 │"
echo "│     cd mastra && pnpm run dev                                    │"
echo "│                                                                   │"
echo "│  4. Open: http://localhost:3000                                  │"
echo "│                                                                   │"
echo "╰──────────────────────────────────────────────────────────────────╯"
