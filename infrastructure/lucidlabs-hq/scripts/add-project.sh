#!/bin/bash
# =============================================================================
# LUCIDLABS-HQ - Add New Project (Automated)
#
# Fully automated server-side provisioning for a new project.
# Creates folder, allocates ports, updates Caddyfile, generates Convex
# docker-compose, and updates registry.json.
#
# Usage:
#   sudo ./add-project.sh \
#     --name "my-project" \
#     --abbreviation "mp" \
#     --subdomain "myproject" \
#     [--has-convex] \
#     [--has-mastra] \
#     [--dry-run]
#
# Runs on LUCIDLABS-HQ with sudo. Idempotent (safe to re-run).
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
BASE_DIR="/opt/lucidlabs"
PROJECTS_DIR="$BASE_DIR/projects"
CADDY_DIR="$BASE_DIR/caddy"
CADDYFILE="$CADDY_DIR/Caddyfile"
REGISTRY="$BASE_DIR/registry.json"
DOMAIN="lucidlabs.de"

# Port ranges
FRONTEND_MIN=3050
FRONTEND_MAX=3099
FRONTEND_STEP=10

CONVEX_BACKEND_MIN=3210
CONVEX_BACKEND_MAX=3299
CONVEX_BACKEND_STEP=2

CONVEX_DASHBOARD_MIN=6790
CONVEX_DASHBOARD_MAX=6899
CONVEX_DASHBOARD_STEP=2

MASTRA_MIN=4050
MASTRA_MAX=4099
MASTRA_STEP=10

# -----------------------------------------------------------------------------
# Parse arguments
# -----------------------------------------------------------------------------
PROJECT_NAME=""
ABBREVIATION=""
SUBDOMAIN=""
HAS_CONVEX=false
HAS_MASTRA=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --abbreviation)
            ABBREVIATION="$2"
            shift 2
            ;;
        --subdomain)
            SUBDOMAIN="$2"
            shift 2
            ;;
        --has-convex)
            HAS_CONVEX=true
            shift
            ;;
        --has-mastra)
            HAS_MASTRA=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$PROJECT_NAME" ] || [ -z "$ABBREVIATION" ] || [ -z "$SUBDOMAIN" ]; then
    echo "Usage: sudo ./add-project.sh --name <name> --abbreviation <abbr> --subdomain <sub> [--has-convex] [--has-mastra] [--dry-run]"
    echo ""
    echo "Example:"
    echo "  sudo ./add-project.sh --name client-service-reporting --abbreviation csr --subdomain reporting --has-convex"
    exit 1
fi

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
log_info()  { echo "  [INFO]  $1"; }
log_ok()    { echo "  [OK]    $1"; }
log_skip()  { echo "  [SKIP]  $1"; }
log_warn()  { echo "  [WARN]  $1"; }
log_err()   { echo "  [ERR]   $1"; }
log_dry()   { echo "  [DRY]   $1"; }

action() {
    if [ "$DRY_RUN" = true ]; then
        log_dry "$1"
    else
        log_info "$1"
    fi
}

# -----------------------------------------------------------------------------
# Preflight checks
# -----------------------------------------------------------------------------
echo ""
echo "============================================================================="
echo "  LUCIDLABS-HQ: ADD PROJECT"
echo "============================================================================="
echo ""
echo "  Project:      $PROJECT_NAME"
echo "  Abbreviation: $ABBREVIATION"
echo "  Subdomain:    $SUBDOMAIN.$DOMAIN"
echo "  Convex:       $HAS_CONVEX"
echo "  Mastra:       $HAS_MASTRA"
echo "  Dry Run:      $DRY_RUN"
echo ""
echo "============================================================================="
echo ""

# Check python3 is available (used for JSON operations)
if ! command -v python3 &> /dev/null; then
    log_err "python3 is required but not installed."
    exit 1
fi

# JSON helper: query registry with python3 (jq replacement)
# Usage: reg_query '<python expression using data>'
reg_query() {
    python3 -c "
import json, sys
with open('$REGISTRY') as f:
    data = json.load(f)
$1
" 2>/dev/null
}

# JSON helper: get max port from registry, handling both old and new schema
# Old schema: services.frontend.port, services.convex.backendPort
# New schema: ports.frontend, ports.convexBackend
reg_max_port() {
    local field=$1
    python3 -c "
import json
with open('$REGISTRY') as f:
    data = json.load(f)
ports = []
for p in data.get('projects', []):
    # New schema: ports.frontend, ports.convexBackend, etc.
    if 'ports' in p and isinstance(p['ports'], dict):
        ports.append(p['ports'].get('$field', 0) or 0)
    # Old schema fallback
    elif '$field' == 'frontend' and 'services' in p:
        svc = p['services']
        if isinstance(svc.get('frontend'), dict):
            ports.append(svc['frontend'].get('port', 0) or 0)
    elif '$field' == 'convexBackend' and 'services' in p:
        svc = p['services']
        if isinstance(svc.get('convex'), dict):
            ports.append(svc['convex'].get('backendPort', 0) or 0)
    elif '$field' == 'convexDashboard' and 'services' in p:
        svc = p['services']
        if isinstance(svc.get('convex'), dict):
            ports.append(svc['convex'].get('dashboardPort', 0) or 0)
    elif '$field' == 'mastra' and 'services' in p:
        ports.append(0)
print(max(ports) if ports else 0)
" 2>/dev/null
}

# JSON helper: check if project exists in registry
reg_project_exists() {
    python3 -c "
import json
with open('$REGISTRY') as f:
    data = json.load(f)
for p in data.get('projects', []):
    if p['name'] == '$1':
        print(p['name'])
        break
" 2>/dev/null
}

# JSON helper: get port for existing project (handles both schemas)
reg_project_port() {
    local project_name=$1
    local field=$2
    python3 -c "
import json
with open('$REGISTRY') as f:
    data = json.load(f)
for p in data.get('projects', []):
    if p['name'] != '$project_name':
        continue
    # New schema
    if 'ports' in p and isinstance(p['ports'], dict):
        print(p['ports'].get('$field', 0) or 0)
        break
    # Old schema fallback
    elif '$field' == 'frontend' and 'services' in p:
        svc = p['services']
        if isinstance(svc.get('frontend'), dict):
            print(svc['frontend'].get('port', 0) or 0)
            break
    elif '$field' == 'convexBackend' and 'services' in p:
        svc = p['services']
        if isinstance(svc.get('convex'), dict):
            print(svc['convex'].get('backendPort', 0) or 0)
            break
    elif '$field' == 'convexDashboard' and 'services' in p:
        svc = p['services']
        if isinstance(svc.get('convex'), dict):
            print(svc['convex'].get('dashboardPort', 0) or 0)
            break
    else:
        print(0)
        break
" 2>/dev/null
}

# JSON helper: update registry with python3
reg_update() {
    python3 -c "
import json
with open('$REGISTRY') as f:
    data = json.load(f)
$1
with open('$REGISTRY', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" 2>/dev/null
}

# Check registry exists
if [ ! -f "$REGISTRY" ]; then
    log_err "Registry not found: $REGISTRY"
    exit 1
fi

# Check Caddyfile exists
if [ ! -f "$CADDYFILE" ]; then
    log_err "Caddyfile not found: $CADDYFILE"
    exit 1
fi

# Check project not already in registry (unless re-running)
EXISTING=$(reg_project_exists "$PROJECT_NAME")

# -----------------------------------------------------------------------------
# Step 1: Port Allocation
# -----------------------------------------------------------------------------
echo "--- Step 1: Port Allocation ---"
echo ""

allocate_port() {
    local range_min=$1
    local range_max=$2
    local step=$3
    local port_field=$4

    # Get highest allocated port in this range from registry (handles both schemas)
    local highest
    highest=$(reg_max_port "$port_field")

    if [ -z "$highest" ] || [ "$highest" = "null" ] || [ "$highest" = "0" ] || [ "$highest" -lt "$range_min" ]; then
        echo "$range_min"
        return
    fi

    local next=$((highest + step))
    if [ "$next" -gt "$range_max" ]; then
        log_err "Port range exhausted for $port_field ($range_min-$range_max)"
        exit 1
    fi

    echo "$next"
}

PORT_FRONTEND=$(allocate_port $FRONTEND_MIN $FRONTEND_MAX $FRONTEND_STEP "frontend")

PORT_CONVEX_BACKEND=0
PORT_CONVEX_DASHBOARD=0
if [ "$HAS_CONVEX" = true ]; then
    PORT_CONVEX_BACKEND=$(allocate_port $CONVEX_BACKEND_MIN $CONVEX_BACKEND_MAX $CONVEX_BACKEND_STEP "convexBackend")
    PORT_CONVEX_DASHBOARD=$(allocate_port $CONVEX_DASHBOARD_MIN $CONVEX_DASHBOARD_MAX $CONVEX_DASHBOARD_STEP "convexDashboard")
fi

PORT_MASTRA=0
if [ "$HAS_MASTRA" = true ]; then
    PORT_MASTRA=$(allocate_port $MASTRA_MIN $MASTRA_MAX $MASTRA_STEP "mastra")
fi

# If project already exists, use existing ports
if [ -n "$EXISTING" ]; then
    log_warn "Project already in registry, using existing port allocation"
    PORT_FRONTEND=$(reg_project_port "$PROJECT_NAME" "frontend")
    if [ "$HAS_CONVEX" = true ]; then
        PORT_CONVEX_BACKEND=$(reg_project_port "$PROJECT_NAME" "convexBackend")
        PORT_CONVEX_DASHBOARD=$(reg_project_port "$PROJECT_NAME" "convexDashboard")
    fi
    if [ "$HAS_MASTRA" = true ]; then
        PORT_MASTRA=$(reg_project_port "$PROJECT_NAME" "mastra")
    fi
fi

# Verify no port conflicts with running services
verify_port() {
    local port=$1
    local label=$2
    if [ "$port" -eq 0 ]; then return; fi
    if ss -tlnp 2>/dev/null | grep -q ":${port} " && [ -z "$EXISTING" ]; then
        log_warn "Port $port ($label) is already in use!"
    fi
}

verify_port "$PORT_FRONTEND" "frontend"
verify_port "$PORT_CONVEX_BACKEND" "convex-backend"
verify_port "$PORT_CONVEX_DASHBOARD" "convex-dashboard"
verify_port "$PORT_MASTRA" "mastra"

log_ok "Frontend:         port $PORT_FRONTEND"
[ "$HAS_CONVEX" = true ] && log_ok "Convex Backend:   port $PORT_CONVEX_BACKEND"
[ "$HAS_CONVEX" = true ] && log_ok "Convex Dashboard: port $PORT_CONVEX_DASHBOARD"
[ "$HAS_MASTRA" = true ] && log_ok "Mastra:           port $PORT_MASTRA"
echo ""

# -----------------------------------------------------------------------------
# Step 2: Create Project Directory
# -----------------------------------------------------------------------------
echo "--- Step 2: Project Directory ---"
echo ""

PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"

if [ -d "$PROJECT_DIR" ]; then
    log_skip "Directory already exists: $PROJECT_DIR"
else
    action "Creating $PROJECT_DIR"
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$PROJECT_DIR"
        log_ok "Created: $PROJECT_DIR"
    fi
fi
echo ""

# -----------------------------------------------------------------------------
# Step 3: Generate .env
# -----------------------------------------------------------------------------
echo "--- Step 3: Environment File ---"
echo ""

CONVEX_URL=""
if [ "$HAS_CONVEX" = true ]; then
    CONVEX_URL="https://${ABBREVIATION}-convex.${DOMAIN}"
fi

if [ -f "$PROJECT_DIR/.env" ]; then
    log_skip ".env already exists"
else
    action "Generating .env"
    if [ "$DRY_RUN" = false ]; then
        cat > "$PROJECT_DIR/.env" << ENVEOF
# $PROJECT_NAME - Environment Variables
# Generated by add-project.sh on $(date -Iseconds)

# Convex
NEXT_PUBLIC_CONVEX_URL=$CONVEX_URL

# AI Keys (fill in)
# ANTHROPIC_API_KEY=sk-ant-...
# OPENAI_API_KEY=sk-...

# Linear (fill in)
# LINEAR_API_KEY=
# LINEAR_TEAM_KEY=
ENVEOF
        chmod 600 "$PROJECT_DIR/.env"
        log_ok "Created .env"
    fi
fi
echo ""

# -----------------------------------------------------------------------------
# Step 4: Backup and Update Caddyfile
# -----------------------------------------------------------------------------
echo "--- Step 4: Caddyfile ---"
echo ""

# Check if entry already exists
if grep -q "${SUBDOMAIN}.${DOMAIN}" "$CADDYFILE" 2>/dev/null; then
    log_skip "Caddyfile entry for ${SUBDOMAIN}.${DOMAIN} already exists"
else
    action "Adding Caddyfile entry for ${SUBDOMAIN}.${DOMAIN}"

    if [ "$DRY_RUN" = false ]; then
        # Backup
        BACKUP="$CADDYFILE.bak.$(date +%Y%m%d%H%M%S)"
        cp "$CADDYFILE" "$BACKUP"
        log_ok "Backup: $BACKUP"

        # Build Caddy block for frontend
        CADDY_BLOCK=""
        CADDY_BLOCK+=$'\n'"# === ${PROJECT_NAME} ==="
        CADDY_BLOCK+=$'\n'"${SUBDOMAIN}.${DOMAIN} {"
        CADDY_BLOCK+=$'\n'"	reverse_proxy ${ABBREVIATION}-frontend:3000"

        if [ "$HAS_MASTRA" = true ]; then
            CADDY_BLOCK+=$'\n'""
            CADDY_BLOCK+=$'\n'"	handle /api/agent/* {"
            CADDY_BLOCK+=$'\n'"		reverse_proxy ${ABBREVIATION}-mastra:4000"
            CADDY_BLOCK+=$'\n'"	}"
        fi

        CADDY_BLOCK+=$'\n'""
        CADDY_BLOCK+=$'\n'"	log {"
        CADDY_BLOCK+=$'\n'"		output file /data/logs/${SUBDOMAIN}.log {"
        CADDY_BLOCK+=$'\n'"			roll_size 10mb"
        CADDY_BLOCK+=$'\n'"			roll_keep 5"
        CADDY_BLOCK+=$'\n'"		}"
        CADDY_BLOCK+=$'\n'"	}"
        CADDY_BLOCK+=$'\n'"}"

        # Add Convex routing if needed
        if [ "$HAS_CONVEX" = true ]; then
            CADDY_BLOCK+=$'\n'""
            CADDY_BLOCK+=$'\n'"# === ${PROJECT_NAME} Convex ==="
            CADDY_BLOCK+=$'\n'"${ABBREVIATION}-convex.${DOMAIN} {"
            CADDY_BLOCK+=$'\n'"	reverse_proxy ${ABBREVIATION}-convex-backend:3210"
            CADDY_BLOCK+=$'\n'""
            CADDY_BLOCK+=$'\n'"	log {"
            CADDY_BLOCK+=$'\n'"		output file /data/logs/${ABBREVIATION}-convex.log {"
            CADDY_BLOCK+=$'\n'"			roll_size 10mb"
            CADDY_BLOCK+=$'\n'"			roll_keep 5"
            CADDY_BLOCK+=$'\n'"		}"
            CADDY_BLOCK+=$'\n'"	}"
            CADDY_BLOCK+=$'\n'"}"
        fi

        # Append to Caddyfile
        echo "$CADDY_BLOCK" >> "$CADDYFILE"
        log_ok "Appended Caddyfile entries"

        # Validate Caddyfile
        if docker exec lucidlabs-caddy caddy validate --config /etc/caddy/Caddyfile 2>/dev/null; then
            log_ok "Caddyfile validation passed"
        else
            log_warn "Caddy container validation unavailable, checking syntax with caddy fmt"
            # If caddy is available locally
            if command -v caddy &> /dev/null; then
                if caddy validate --config "$CADDYFILE" 2>/dev/null; then
                    log_ok "Caddyfile validation passed (local caddy)"
                else
                    log_err "Caddyfile validation FAILED! Rolling back..."
                    cp "$BACKUP" "$CADDYFILE"
                    log_ok "Rolled back to: $BACKUP"
                    exit 1
                fi
            else
                log_warn "Cannot validate Caddyfile (no caddy binary). Proceeding with caution."
            fi
        fi
    fi
fi
echo ""

# -----------------------------------------------------------------------------
# Step 5: Reload Caddy
# -----------------------------------------------------------------------------
echo "--- Step 5: Reload Caddy ---"
echo ""

if [ "$DRY_RUN" = false ]; then
    if docker exec lucidlabs-caddy caddy reload --config /etc/caddy/Caddyfile 2>/dev/null; then
        log_ok "Caddy reloaded (SSL will be auto-provisioned)"
    else
        log_warn "Could not reload Caddy. You may need to restart manually:"
        log_warn "  cd /opt/lucidlabs/caddy && docker compose restart caddy"
    fi
else
    log_dry "Would reload Caddy"
fi
echo ""

# -----------------------------------------------------------------------------
# Step 6: Generate Convex docker-compose
# -----------------------------------------------------------------------------
if [ "$HAS_CONVEX" = true ]; then
    echo "--- Step 6: Convex Docker Compose ---"
    echo ""

    CONVEX_FILE="$PROJECT_DIR/docker-compose.convex.yml"

    if [ -f "$CONVEX_FILE" ]; then
        log_skip "docker-compose.convex.yml already exists"
    else
        action "Generating docker-compose.convex.yml"
        if [ "$DRY_RUN" = false ]; then
            cat > "$CONVEX_FILE" << CONVEXEOF
# =============================================================================
# ${PROJECT_NAME} - Convex Instance
#
# Separate Convex backend for project isolation
# Port Block: ${PORT_CONVEX_BACKEND} (backend), ${PORT_CONVEX_DASHBOARD} (dashboard)
#
# Usage:
#   docker compose -f docker-compose.convex.yml -p ${ABBREVIATION}-convex up -d
# =============================================================================

services:
  convex-backend:
    image: ghcr.io/get-convex/convex-backend:latest
    container_name: ${ABBREVIATION}-convex-backend
    ports:
      - "${PORT_CONVEX_BACKEND}:3210"
      - "$((PORT_CONVEX_BACKEND + 1)):3211"
    volumes:
      - ${ABBREVIATION}-convex-data:/convex/data
    environment:
      - CONVEX_SITE_URL=https://${ABBREVIATION}-convex.${DOMAIN}
    networks:
      - lucidlabs-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3210/version"]
      interval: 30s
      timeout: 10s
      retries: 3

  convex-dashboard:
    image: ghcr.io/get-convex/convex-dashboard:latest
    container_name: ${ABBREVIATION}-convex-dashboard
    ports:
      - "${PORT_CONVEX_DASHBOARD}:6791"
    environment:
      - CONVEX_BACKEND_URL=http://convex-backend:3210
    depends_on:
      - convex-backend
    networks:
      - lucidlabs-network
    restart: unless-stopped

volumes:
  ${ABBREVIATION}-convex-data:

networks:
  lucidlabs-network:
    external: true
CONVEXEOF
            log_ok "Created docker-compose.convex.yml"
        fi
    fi
    echo ""
fi

# -----------------------------------------------------------------------------
# Step 7: Update registry.json
# -----------------------------------------------------------------------------
echo "--- Step 7: Registry ---"
echo ""

TIMESTAMP=$(date -Iseconds)

if [ -n "$EXISTING" ]; then
    log_skip "Project already in registry (updating status)"
    if [ "$DRY_RUN" = false ]; then
        reg_update "
for p in data.get('projects', []):
    if p['name'] == '$PROJECT_NAME':
        p['status'] = 'provisioned'
        p['lastUpdate'] = '$TIMESTAMP'
        break
"
        log_ok "Registry updated (status: provisioned)"
    fi
else
    action "Adding project to registry"
    if [ "$DRY_RUN" = false ]; then
        CONVEX_URL_VAL=""
        if [ "$HAS_CONVEX" = true ]; then
            CONVEX_URL_VAL="https://${ABBREVIATION}-convex.${DOMAIN}"
        fi

        HAS_CONVEX_PY="False"
        HAS_MASTRA_PY="False"
        [ "$HAS_CONVEX" = true ] && HAS_CONVEX_PY="True"
        [ "$HAS_MASTRA" = true ] && HAS_MASTRA_PY="True"

        reg_update "
new_project = {
    'name': '$PROJECT_NAME',
    'abbreviation': '$ABBREVIATION',
    'subdomain': '$SUBDOMAIN',
    'url': 'https://${SUBDOMAIN}.${DOMAIN}',
    'convexUrl': '$CONVEX_URL_VAL' if $HAS_CONVEX_PY else None,
    'ports': {
        'frontend': $PORT_FRONTEND,
        'convexBackend': $PORT_CONVEX_BACKEND,
        'convexDashboard': $PORT_CONVEX_DASHBOARD,
        'mastra': $PORT_MASTRA
    },
    'repo': 'lucidlabs-hq/$PROJECT_NAME',
    'status': 'provisioned',
    'services': {
        'frontend': True,
        'convex': $HAS_CONVEX_PY,
        'mastra': $HAS_MASTRA_PY
    },
    'deployed': None,
    'lastUpdate': '$TIMESTAMP'
}
data.setdefault('projects', []).append(new_project)
"
        log_ok "Added to registry"
    fi
fi
echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "============================================================================="
echo "  PROJECT PROVISIONED"
echo "============================================================================="
echo ""
echo "  Project:            $PROJECT_NAME"
echo "  Abbreviation:       $ABBREVIATION"
echo "  Directory:          $PROJECT_DIR"
echo ""
echo "  URLs:"
echo "    Frontend:         https://${SUBDOMAIN}.${DOMAIN}"
[ "$HAS_CONVEX" = true ] && echo "    Convex API:       https://${ABBREVIATION}-convex.${DOMAIN}"
[ "$HAS_CONVEX" = true ] && echo "    Convex Dashboard: http://<server-ip>:${PORT_CONVEX_DASHBOARD}"
echo ""
echo "  Ports:"
echo "    Frontend:         $PORT_FRONTEND"
[ "$HAS_CONVEX" = true ] && echo "    Convex Backend:   $PORT_CONVEX_BACKEND"
[ "$HAS_CONVEX" = true ] && echo "    Convex Dashboard: $PORT_CONVEX_DASHBOARD"
[ "$HAS_MASTRA" = true ] && echo "    Mastra:           $PORT_MASTRA"
echo ""
if [ "$DRY_RUN" = true ]; then
    echo "  (DRY RUN - no changes were made)"
    echo ""
fi
echo "  Next steps:"
echo "    1. Fill in $PROJECT_DIR/.env with actual secrets"
echo "    2. Rsync project code to $PROJECT_DIR"
[ "$HAS_CONVEX" = true ] && echo "    3. Start Convex: cd $PROJECT_DIR && docker compose -f docker-compose.convex.yml -p ${ABBREVIATION}-convex up -d"
echo "    4. Build frontend: cd $PROJECT_DIR && docker compose -p $PROJECT_NAME up -d --build"
echo ""
echo "============================================================================="
