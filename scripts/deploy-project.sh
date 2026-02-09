#!/bin/bash
# =============================================================================
# LUCIDLABS-HQ - Deploy Project (Local Orchestration)
#
# Full end-to-end deployment from developer machine to LUCIDLABS-HQ.
# Handles GitHub repo, server provisioning, code sync, Convex functions,
# initial data seed, and health checks.
#
# Usage:
#   ./scripts/deploy-project.sh \
#     --name "my-project" \
#     --abbreviation "mp" \
#     --subdomain "myproject" \
#     [--has-convex] \
#     [--has-mastra] \
#     [--skip-github] \
#     [--skip-provision] \
#     [--skip-data] \
#     [--dry-run]
#
# Prerequisites:
#   - SSH access to lucidlabs-hq (via ~/.ssh/config)
#   - gh CLI authenticated
#   - Project code in current directory
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
SSH_HOST="lucidlabs-hq"
SSH_PORT=2222
REMOTE_BASE="/opt/lucidlabs"
REMOTE_SCRIPTS="$REMOTE_BASE/scripts"
GITHUB_ORG="lucidlabs-hq"
LOCAL_INFRA_SCRIPTS="$(dirname "$0")/../infrastructure/lucidlabs-hq/scripts"

# Resolve to absolute path
LOCAL_INFRA_SCRIPTS=$(cd "$LOCAL_INFRA_SCRIPTS" 2>/dev/null && pwd || echo "$LOCAL_INFRA_SCRIPTS")

# Track timing
DEPLOY_START=$(date +%s)

# Store admin key for summary
ADMIN_KEY=""

# Track step results for final report
STEPS_PASSED=0
STEPS_SKIPPED=0
STEPS_FAILED=0

# -----------------------------------------------------------------------------
# Parse arguments
# -----------------------------------------------------------------------------
PROJECT_NAME=""
ABBREVIATION=""
SUBDOMAIN=""
HAS_CONVEX=false
HAS_MASTRA=false
SKIP_GITHUB=false
SKIP_PROVISION=false
SKIP_DATA=false
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
        --skip-github)
            SKIP_GITHUB=true
            shift
            ;;
        --skip-provision)
            SKIP_PROVISION=true
            shift
            ;;
        --skip-data)
            SKIP_DATA=true
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
    echo "Usage: ./scripts/deploy-project.sh --name <name> --abbreviation <abbr> --subdomain <sub> [options]"
    echo ""
    echo "Options:"
    echo "  --has-convex       Include Convex database"
    echo "  --has-mastra       Include Mastra AI agent layer"
    echo "  --skip-github      Skip GitHub repo creation/setup"
    echo "  --skip-provision   Skip server provisioning (add-project.sh)"
    echo "  --skip-data        Skip local data export/import to production"
    echo "  --dry-run          Show what would happen without making changes"
    echo ""
    echo "Example:"
    echo "  ./scripts/deploy-project.sh --name client-service-reporting --abbreviation csr --subdomain reporting --has-convex"
    exit 1
fi

# -----------------------------------------------------------------------------
# Logging & Progress
# -----------------------------------------------------------------------------
TOTAL_STEPS=12
STEP=0

# Colors (if terminal supports it)
if [ -t 1 ]; then
    C_RESET="\033[0m"
    C_BOLD="\033[1m"
    C_DIM="\033[2m"
    C_GREEN="\033[32m"
    C_YELLOW="\033[33m"
    C_RED="\033[31m"
    C_CYAN="\033[36m"
    C_BLUE="\033[34m"
    C_MAGENTA="\033[35m"
else
    C_RESET="" C_BOLD="" C_DIM="" C_GREEN="" C_YELLOW="" C_RED="" C_CYAN="" C_BLUE="" C_MAGENTA=""
fi

step() {
    STEP=$((STEP + 1))
    echo ""
    echo -e "${C_CYAN}${C_BOLD}[$STEP/$TOTAL_STEPS]${C_RESET} ${C_BOLD}$1${C_RESET}"
    echo -e "${C_DIM}$(printf '%.0s-' {1..60})${C_RESET}"
}

log_ok() {
    STEPS_PASSED=$((STEPS_PASSED + 1))
    echo -e "  ${C_GREEN}[OK]${C_RESET}    $1"
}

log_skip() {
    STEPS_SKIPPED=$((STEPS_SKIPPED + 1))
    echo -e "  ${C_YELLOW}[SKIP]${C_RESET}  $1"
}

log_err() {
    STEPS_FAILED=$((STEPS_FAILED + 1))
    echo -e "  ${C_RED}[ERR]${C_RESET}   $1"
}

log_info() {
    echo -e "  ${C_BLUE}[....]${C_RESET}  $1"
}

log_dry() {
    echo -e "  ${C_MAGENTA}[DRY]${C_RESET}   $1"
}

log_detail() {
    echo -e "  ${C_DIM}        $1${C_RESET}"
}

# -----------------------------------------------------------------------------
# Header
# -----------------------------------------------------------------------------
echo ""
echo -e "${C_BOLD}=============================================================================${C_RESET}"
echo -e "${C_BOLD}  LUCIDLABS-HQ  |  Project Deployment${C_RESET}"
echo -e "${C_BOLD}=============================================================================${C_RESET}"
echo ""
echo -e "  Project:      ${C_BOLD}$PROJECT_NAME${C_RESET}"
echo -e "  Abbreviation: ${C_BOLD}$ABBREVIATION${C_RESET}"
echo -e "  Domain:       ${C_CYAN}https://$SUBDOMAIN.lucidlabs.de${C_RESET}"
[ "$HAS_CONVEX" = true ] && echo -e "  Convex:       ${C_GREEN}Enabled${C_RESET}  (https://${ABBREVIATION}-convex.lucidlabs.de)"
[ "$HAS_CONVEX" = false ] && echo -e "  Convex:       ${C_DIM}No${C_RESET}"
[ "$HAS_MASTRA" = true ] && echo -e "  Mastra:       ${C_GREEN}Enabled${C_RESET}"
[ "$HAS_MASTRA" = false ] && echo -e "  Mastra:       ${C_DIM}No${C_RESET}"
[ "$DRY_RUN" = true ] && echo -e "  Mode:         ${C_MAGENTA}DRY RUN (no changes)${C_RESET}"
echo ""
echo -e "${C_DIM}  Started at $(date '+%H:%M:%S on %Y-%m-%d')${C_RESET}"
echo -e "${C_BOLD}=============================================================================${C_RESET}"

# =============================================================================
# PHASE 1: PREFLIGHT
# =============================================================================
echo ""
echo -e "${C_BOLD}${C_BLUE}--- Phase 1: Preflight Checks ---${C_RESET}"

# -----------------------------------------------------------------------------
# Step 1: Verify SSH access
# -----------------------------------------------------------------------------
step "Verify SSH Access"

if [ "$DRY_RUN" = true ]; then
    log_dry "Would verify SSH to $SSH_HOST"
else
    log_info "Connecting to $SSH_HOST (port $SSH_PORT)..."
    if ssh -p "$SSH_PORT" "$SSH_HOST" "echo ok" 2>/dev/null | grep -q "ok"; then
        log_ok "SSH connection to $SSH_HOST verified"
    else
        log_err "Cannot connect to $SSH_HOST via SSH (port $SSH_PORT)"
        echo ""
        echo "  Ensure your ~/.ssh/config has:"
        echo "    Host lucidlabs-hq"
        echo "      HostName <server-ip>"
        echo "      User nightwing"
        echo "      Port 2222"
        echo "      IdentityFile ~/.ssh/lucidlabs-hq"
        exit 1
    fi
fi

# -----------------------------------------------------------------------------
# Step 2: Verify gh CLI
# -----------------------------------------------------------------------------
step "Verify GitHub CLI"

if [ "$SKIP_GITHUB" = true ]; then
    log_skip "GitHub steps skipped (--skip-github)"
else
    if ! command -v gh &> /dev/null; then
        log_err "gh CLI not installed. Install with: brew install gh"
        exit 1
    fi

    if [ "$DRY_RUN" = true ]; then
        log_dry "Would verify gh auth status"
    else
        if gh auth status &> /dev/null; then
            log_ok "gh CLI authenticated"
        else
            log_err "gh CLI not authenticated. Run: gh auth login"
            exit 1
        fi
    fi
fi

# =============================================================================
# PHASE 2: GITHUB
# =============================================================================
if [ "$SKIP_GITHUB" = false ]; then
    echo ""
    echo -e "${C_BOLD}${C_BLUE}--- Phase 2: GitHub Setup ---${C_RESET}"

    # -------------------------------------------------------------------------
    # Step 3: Create GitHub repo
    # -------------------------------------------------------------------------
    step "GitHub Repository"

    REPO_FULL="${GITHUB_ORG}/${PROJECT_NAME}"

    if [ "$DRY_RUN" = true ]; then
        log_dry "Would create repo $REPO_FULL (if not exists)"
    else
        if gh repo view "$REPO_FULL" &> /dev/null; then
            log_skip "Repository $REPO_FULL already exists"
        else
            log_info "Creating private repository..."
            gh repo create "$REPO_FULL" --private --description "Lucid Labs - ${PROJECT_NAME}"
            log_ok "Created repository: $REPO_FULL"
        fi
    fi

    # -------------------------------------------------------------------------
    # Step 4: Set GitHub secrets
    # -------------------------------------------------------------------------
    step "GitHub Secrets"

    CONVEX_URL=""
    if [ "$HAS_CONVEX" = true ]; then
        CONVEX_URL="https://${ABBREVIATION}-convex.lucidlabs.de"
    fi

    if [ "$DRY_RUN" = true ]; then
        log_dry "Would set secrets: LUCIDLABS_HQ_HOST, LUCIDLABS_HQ_SSH_KEY"
        [ -n "$CONVEX_URL" ] && log_dry "Would set secret: NEXT_PUBLIC_CONVEX_URL=$CONVEX_URL"
    else
        log_info "Organization secrets (HQ_HOST, SSH_KEY) are inherited"
        log_info "Set project-specific secrets manually if needed:"
        log_detail "gh secret set NEXT_PUBLIC_CONVEX_URL -R $REPO_FULL"
        log_detail "gh secret set LINEAR_API_KEY -R $REPO_FULL"
        log_ok "Secrets configuration noted"
    fi

    # -------------------------------------------------------------------------
    # Step 5: Push code
    # -------------------------------------------------------------------------
    step "Push Code to GitHub"

    if [ "$DRY_RUN" = true ]; then
        log_dry "Would add remote 'origin' and push to $REPO_FULL"
    else
        CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
        EXPECTED_URL="git@github.com:${REPO_FULL}.git"

        if [ -z "$CURRENT_REMOTE" ]; then
            git remote add origin "$EXPECTED_URL"
            log_ok "Added remote: $EXPECTED_URL"
        elif [ "$CURRENT_REMOTE" != "$EXPECTED_URL" ]; then
            log_info "Remote 'origin' points to: $CURRENT_REMOTE"
            log_detail "Expected: $EXPECTED_URL"
            log_skip "Keeping existing remote (may be intentional)"
        else
            log_skip "Remote already configured"
        fi

        log_info "Pushing to origin/main..."
        if git push -u origin main 2>/dev/null; then
            log_ok "Pushed to origin/main"
        else
            log_info "Push may require manual intervention"
        fi
    fi
else
    # Count the 3 skipped GitHub steps
    STEP=$((STEP + 3))
fi

# =============================================================================
# PHASE 3: SERVER PROVISIONING
# =============================================================================
echo ""
echo -e "${C_BOLD}${C_BLUE}--- Phase 3: Server Provisioning ---${C_RESET}"

# -----------------------------------------------------------------------------
# Step 6: Sync add-project.sh to server
# -----------------------------------------------------------------------------
step "Sync Server Scripts"

if [ "$DRY_RUN" = true ]; then
    log_dry "Would rsync add-project.sh to $SSH_HOST:$REMOTE_SCRIPTS/"
else
    log_info "Uploading add-project.sh to server..."
    rsync -avz --quiet -e "ssh -p $SSH_PORT" \
        "$LOCAL_INFRA_SCRIPTS/add-project.sh" \
        "$SSH_HOST:/tmp/add-project.sh"

    log_info "Installing script to /opt/lucidlabs/scripts/..."
    ssh -p "$SSH_PORT" "$SSH_HOST" "sudo docker run --rm \
        -v /opt/lucidlabs:/opt/lucidlabs \
        -v /tmp:/tmp \
        alpine sh -c 'mkdir -p /opt/lucidlabs/scripts && \
            cp /tmp/add-project.sh /opt/lucidlabs/scripts/add-project.sh && \
            chmod +x /opt/lucidlabs/scripts/add-project.sh && \
            chown root:root /opt/lucidlabs/scripts/add-project.sh'" 2>/dev/null

    log_ok "Server scripts updated"
fi

# -----------------------------------------------------------------------------
# Step 7: Run add-project.sh on server
# -----------------------------------------------------------------------------
REMOTE_PROJECT="$REMOTE_BASE/projects/$PROJECT_NAME"

if [ "$SKIP_PROVISION" = false ]; then
    step "Provision Project on Server"

    ADD_ARGS="--name $PROJECT_NAME --abbreviation $ABBREVIATION --subdomain $SUBDOMAIN"
    [ "$HAS_CONVEX" = true ] && ADD_ARGS="$ADD_ARGS --has-convex"
    [ "$HAS_MASTRA" = true ] && ADD_ARGS="$ADD_ARGS --has-mastra"

    if [ "$DRY_RUN" = true ]; then
        log_dry "Would run: sudo $REMOTE_SCRIPTS/add-project.sh $ADD_ARGS"
    else
        log_info "Running server provisioning (ports, Caddyfile, registry)..."
        ssh -p "$SSH_PORT" "$SSH_HOST" "sudo $REMOTE_SCRIPTS/add-project.sh $ADD_ARGS"
        log_ok "Server provisioning complete"
    fi
else
    step "Provision Project on Server"
    log_skip "Server provisioning skipped (--skip-provision)"
fi

# =============================================================================
# PHASE 4: CODE DEPLOYMENT
# =============================================================================
echo ""
echo -e "${C_BOLD}${C_BLUE}--- Phase 4: Code Deployment ---${C_RESET}"

# -----------------------------------------------------------------------------
# Step 8: Rsync project code
# -----------------------------------------------------------------------------
step "Sync Project Code"

if [ "$DRY_RUN" = true ]; then
    log_dry "Would rsync project code to $SSH_HOST:$REMOTE_PROJECT/"
else
    STAGING="/tmp/deploy-${PROJECT_NAME}"

    log_info "Uploading project files to staging area..."
    rsync -avz --quiet -e "ssh -p $SSH_PORT" \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='.next' \
        --exclude='.env.local' \
        --exclude='frontend/.next' \
        --exclude='frontend/node_modules' \
        --exclude='mastra/node_modules' \
        --exclude='convex/node_modules' \
        --delete \
        ./ "$SSH_HOST:$STAGING/"

    log_info "Moving files to project directory..."
    ssh -p "$SSH_PORT" "$SSH_HOST" "sudo docker run --rm \
        -v /opt/lucidlabs:/opt/lucidlabs \
        -v /tmp:/tmp \
        alpine sh -c 'cp -a /tmp/deploy-${PROJECT_NAME}/. /opt/lucidlabs/projects/${PROJECT_NAME}/ && \
            rm -rf /tmp/deploy-${PROJECT_NAME}'" 2>/dev/null

    log_ok "Project code deployed to $REMOTE_PROJECT"
fi

# =============================================================================
# PHASE 5: SERVICES
# =============================================================================
echo ""
echo -e "${C_BOLD}${C_BLUE}--- Phase 5: Start Services ---${C_RESET}"

# -----------------------------------------------------------------------------
# Step 9: Start services
# -----------------------------------------------------------------------------
step "Start Docker Containers"

if [ "$DRY_RUN" = true ]; then
    [ "$HAS_CONVEX" = true ] && log_dry "Would start Convex instance"
    log_dry "Would build and start frontend"
else
    # Start Convex if needed
    if [ "$HAS_CONVEX" = true ]; then
        log_info "Starting Convex database..."
        EXISTING_CONVEX=$(ssh -p "$SSH_PORT" "$SSH_HOST" "sudo docker ps -a --filter 'name=${ABBREVIATION}-convex-backend' --format '{{.Names}}'" 2>/dev/null)

        if [ -n "$EXISTING_CONVEX" ]; then
            log_info "Convex containers exist, restarting..."
            ssh -p "$SSH_PORT" "$SSH_HOST" "sudo docker restart ${ABBREVIATION}-convex-backend ${ABBREVIATION}-convex-dashboard" 2>/dev/null || true
        else
            log_info "Creating new Convex containers..."
            ssh -p "$SSH_PORT" "$SSH_HOST" "cd $REMOTE_PROJECT && sudo docker compose -f docker-compose.convex.yml -p $PROJECT_NAME up -d" 2>/dev/null
        fi
        log_ok "Convex database running"

        log_info "Waiting for Convex to initialize (15s)..."
        sleep 15
    fi

    log_info "Building and starting frontend container..."
    ssh -p "$SSH_PORT" "$SSH_HOST" "cd $REMOTE_PROJECT && sudo docker compose -p $PROJECT_NAME up -d --build" 2>&1 | grep -E "^(#|Building| |Created|Started|Running)" | tail -5
    log_ok "Frontend container running"
fi

# =============================================================================
# PHASE 6: CONVEX DEPLOYMENT
# =============================================================================
if [ "$HAS_CONVEX" = true ]; then
    echo ""
    echo -e "${C_BOLD}${C_BLUE}--- Phase 6: Convex Functions & Data ---${C_RESET}"

    # -------------------------------------------------------------------------
    # Step 10: Deploy Convex Functions
    # -------------------------------------------------------------------------
    step "Deploy Convex Functions"

    CONVEX_PROD_URL="https://${ABBREVIATION}-convex.lucidlabs.de"

    if [ "$DRY_RUN" = true ]; then
        log_dry "Would generate admin key and deploy Convex functions to $CONVEX_PROD_URL"
    else
        log_info "Generating Convex admin key..."
        ADMIN_KEY=$(ssh -p "$SSH_PORT" "$SSH_HOST" "sudo docker exec ${ABBREVIATION}-convex-backend /convex/generate_admin_key.sh 2>/dev/null" | tail -1)

        if [ -z "$ADMIN_KEY" ]; then
            log_err "Failed to generate admin key"
            log_info "Try manually: ssh $SSH_HOST 'sudo docker exec ${ABBREVIATION}-convex-backend /convex/generate_admin_key.sh'"
        else
            log_ok "Admin key generated"

            log_info "Pushing schema, queries, and mutations to production..."
            if npx convex deploy --url "$CONVEX_PROD_URL" --admin-key "$ADMIN_KEY" --yes 2>&1; then
                log_ok "Convex functions deployed to production"
            else
                log_err "Convex function deployment failed"
                log_info "Try manually: npx convex deploy --url $CONVEX_PROD_URL --admin-key <key>"
            fi
        fi
    fi

    # -------------------------------------------------------------------------
    # Step 11: Initial Data Seed (first deploy only)
    # -------------------------------------------------------------------------
    step "Initial Data Seed"

    if [ "$SKIP_DATA" = true ]; then
        log_skip "Data seed skipped (--skip-data)"
    elif [ "$DRY_RUN" = true ]; then
        log_dry "Would check if production needs initial data seed"
    else
        # Check if production database already has data
        PROD_HAS_DATA=false
        if [ -n "${ADMIN_KEY:-}" ]; then
            DOC_CHECK=$(curl -s "${CONVEX_PROD_URL}/api/list_snapshot" \
                -H "Authorization: Convex ${ADMIN_KEY}" 2>/dev/null || echo "")
            if echo "$DOC_CHECK" | grep -q '"tables"' 2>/dev/null; then
                HAS_TABLES=$(echo "$DOC_CHECK" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tables = data.get('tables', [])
    has_data = any(t.get('numDocuments', 0) > 0 for t in tables if not t['name'].startswith('_'))
    print('true' if has_data else 'false')
except:
    print('false')
" 2>/dev/null || echo "false")
                if [ "$HAS_TABLES" = "true" ]; then
                    PROD_HAS_DATA=true
                fi
            fi
        fi

        if [ "$PROD_HAS_DATA" = true ]; then
            log_skip "Production database already has data"
            log_detail "Functions updated, but data stays independent (Production != Development)"
        else
            EXPORT_DIR="/tmp/convex-export-${PROJECT_NAME}"
            EXPORT_PATH="${EXPORT_DIR}/snapshot.zip"
            mkdir -p "$EXPORT_DIR"

            log_info "First deploy detected - seeding production from local data..."
            if npx convex export --path "$EXPORT_PATH" --include-file-storage 2>&1; then
                log_ok "Local data exported"

                if [ -z "${ADMIN_KEY:-}" ]; then
                    ADMIN_KEY=$(ssh -p "$SSH_PORT" "$SSH_HOST" "sudo docker exec ${ABBREVIATION}-convex-backend /convex/generate_admin_key.sh 2>/dev/null" | tail -1)
                fi

                log_info "Importing data to production..."
                if npx convex import "$EXPORT_PATH" --url "$CONVEX_PROD_URL" --admin-key "$ADMIN_KEY" --replace-all --yes 2>&1; then
                    log_ok "Production database seeded from local data"
                else
                    log_err "Data import failed"
                    log_detail "npx convex import $EXPORT_PATH --url $CONVEX_PROD_URL --admin-key <key> --replace-all --yes"
                fi
                rm -rf "$EXPORT_DIR"
            else
                log_info "No local Convex data to export (dev server not running)"
                log_detail "Production starts with empty database. Seed manually if needed."
            fi
        fi
    fi
else
    # Skip Convex steps in counter
    STEP=$((STEP + 2))
fi

# =============================================================================
# PHASE 7: VERIFICATION
# =============================================================================
echo ""
echo -e "${C_BOLD}${C_BLUE}--- Phase 7: Verification ---${C_RESET}"

# -----------------------------------------------------------------------------
# Step 12: Health check
# -----------------------------------------------------------------------------
step "Health Check"

FRONTEND_URL="https://${SUBDOMAIN}.lucidlabs.de"
HEALTH_FRONTEND="PENDING"
HEALTH_CONVEX="PENDING"

if [ "$DRY_RUN" = true ]; then
    log_dry "Would check: $FRONTEND_URL"
    HEALTH_FRONTEND="DRY_RUN"
    HEALTH_CONVEX="DRY_RUN"
else
    log_info "Waiting for services to start (20s)..."
    sleep 20

    # Check frontend
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" 2>/dev/null || echo "000")

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "307" ] || [ "$HTTP_CODE" = "308" ]; then
        log_ok "Frontend: $FRONTEND_URL (HTTP $HTTP_CODE)"
        HEALTH_FRONTEND="LIVE"
    else
        log_err "Frontend: $FRONTEND_URL (HTTP $HTTP_CODE)"
        log_detail "Check logs: ssh $SSH_HOST 'sudo docker logs ${ABBREVIATION}-frontend --tail 20'"
        HEALTH_FRONTEND="DOWN"
    fi

    # Check Convex
    if [ "$HAS_CONVEX" = true ]; then
        CONVEX_URL="https://${ABBREVIATION}-convex.lucidlabs.de"
        CONVEX_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${CONVEX_URL}/version" 2>/dev/null || echo "000")

        if [ "$CONVEX_CODE" = "200" ]; then
            log_ok "Convex API: $CONVEX_URL (HTTP $CONVEX_CODE)"
            HEALTH_CONVEX="LIVE"
        else
            log_err "Convex API: $CONVEX_URL (HTTP $CONVEX_CODE)"
            log_detail "Check logs: ssh $SSH_HOST 'sudo docker logs ${ABBREVIATION}-convex-backend --tail 20'"
            HEALTH_CONVEX="DOWN"
        fi
    fi
fi

# =============================================================================
# DEPLOYMENT SUMMARY
# =============================================================================
DEPLOY_END=$(date +%s)
DEPLOY_DURATION=$((DEPLOY_END - DEPLOY_START))
DEPLOY_MINS=$((DEPLOY_DURATION / 60))
DEPLOY_SECS=$((DEPLOY_DURATION % 60))

echo ""
echo ""

if [ "$HEALTH_FRONTEND" = "LIVE" ] || [ "$DRY_RUN" = true ]; then
    # Success!
    echo -e "${C_GREEN}${C_BOLD}"
    echo "    ==========================================================="
    echo ""
    echo "      Deployment successful!"
    echo ""
    echo "      $PROJECT_NAME is now live."
    echo ""
    echo "    ==========================================================="
    echo -e "${C_RESET}"
else
    echo -e "${C_YELLOW}${C_BOLD}"
    echo "    ==========================================================="
    echo ""
    echo "      Deployment completed with warnings."
    echo "      Check the details below."
    echo ""
    echo "    ==========================================================="
    echo -e "${C_RESET}"
fi

# URLs section
echo -e "${C_BOLD}  Your Project URLs${C_RESET}"
echo -e "  ${C_DIM}$(printf '%.0s-' {1..55})${C_RESET}"
echo ""
echo -e "  Frontend:           ${C_CYAN}${C_BOLD}https://${SUBDOMAIN}.lucidlabs.de${C_RESET}"
if [ "$HAS_CONVEX" = true ]; then
    echo -e "  Convex API:         ${C_CYAN}https://${ABBREVIATION}-convex.lucidlabs.de${C_RESET}"
fi
if [ "$SKIP_GITHUB" = false ]; then
    echo -e "  GitHub:             ${C_CYAN}https://github.com/${GITHUB_ORG}/${PROJECT_NAME}${C_RESET}"
fi
echo ""

# Convex access section
if [ "$HAS_CONVEX" = true ] && [ -n "${ADMIN_KEY:-}" ] && [ "$DRY_RUN" = false ]; then
    echo -e "${C_BOLD}  Convex Access (Terminal)${C_RESET}"
    echo -e "  ${C_DIM}$(printf '%.0s-' {1..55})${C_RESET}"
    echo ""
    echo -e "  Production URL:     ${C_CYAN}https://${ABBREVIATION}-convex.lucidlabs.de${C_RESET}"
    echo -e "  Admin Key:          ${C_YELLOW}${ADMIN_KEY}${C_RESET}"
    echo ""
    echo -e "  ${C_DIM}Deploy functions:${C_RESET}"
    echo -e "  ${C_DIM}  npx convex deploy --url https://${ABBREVIATION}-convex.lucidlabs.de --admin-key ${ADMIN_KEY}${C_RESET}"
    echo ""
    echo -e "  ${C_DIM}Open Convex dashboard:${C_RESET}"
    echo -e "  ${C_DIM}  ssh $SSH_HOST 'sudo docker logs ${ABBREVIATION}-convex-dashboard --tail 5'${C_RESET}"
    echo ""
    echo -e "  ${C_DIM}Export production data:${C_RESET}"
    echo -e "  ${C_DIM}  npx convex export --path backup.zip --url https://${ABBREVIATION}-convex.lucidlabs.de --admin-key ${ADMIN_KEY}${C_RESET}"
    echo ""
    echo -e "  ${C_DIM}Import data to production:${C_RESET}"
    echo -e "  ${C_DIM}  npx convex import data.zip --url https://${ABBREVIATION}-convex.lucidlabs.de --admin-key ${ADMIN_KEY} --replace-all --yes${C_RESET}"
    echo ""
fi

# Container status
echo -e "${C_BOLD}  Container Status${C_RESET}"
echo -e "  ${C_DIM}$(printf '%.0s-' {1..55})${C_RESET}"
echo ""
if [ "$HEALTH_FRONTEND" = "LIVE" ]; then
    echo -e "  ${ABBREVIATION}-frontend           ${C_GREEN}LIVE${C_RESET}   https://${SUBDOMAIN}.lucidlabs.de"
elif [ "$HEALTH_FRONTEND" = "DRY_RUN" ]; then
    echo -e "  ${ABBREVIATION}-frontend           ${C_MAGENTA}DRY RUN${C_RESET}"
else
    echo -e "  ${ABBREVIATION}-frontend           ${C_RED}DOWN${C_RESET}   Check logs above"
fi

if [ "$HAS_CONVEX" = true ]; then
    if [ "$HEALTH_CONVEX" = "LIVE" ]; then
        echo -e "  ${ABBREVIATION}-convex-backend     ${C_GREEN}LIVE${C_RESET}   https://${ABBREVIATION}-convex.lucidlabs.de"
        echo -e "  ${ABBREVIATION}-convex-dashboard   ${C_GREEN}LIVE${C_RESET}"
    elif [ "$HEALTH_CONVEX" = "DRY_RUN" ]; then
        echo -e "  ${ABBREVIATION}-convex-backend     ${C_MAGENTA}DRY RUN${C_RESET}"
    else
        echo -e "  ${ABBREVIATION}-convex-backend     ${C_RED}DOWN${C_RESET}   Check logs above"
    fi
fi
echo ""

# Deployment info
echo -e "${C_BOLD}  Deployment Info${C_RESET}"
echo -e "  ${C_DIM}$(printf '%.0s-' {1..55})${C_RESET}"
echo ""
echo -e "  Duration:           ${DEPLOY_MINS}m ${DEPLOY_SECS}s"
echo -e "  Server:             LUCIDLABS-HQ (Elestio/Hetzner)"
echo -e "  Directory:          $REMOTE_PROJECT"
echo -e "  Deployed at:        $(date '+%Y-%m-%d %H:%M:%S')"
if [ "$DRY_RUN" = true ]; then
    echo ""
    echo -e "  ${C_MAGENTA}(DRY RUN - no changes were made)${C_RESET}"
fi
echo ""

# Quick reference
echo -e "${C_BOLD}  Quick Reference${C_RESET}"
echo -e "  ${C_DIM}$(printf '%.0s-' {1..55})${C_RESET}"
echo ""
echo -e "  ${C_DIM}View logs:${C_RESET}    ssh $SSH_HOST 'sudo docker logs ${ABBREVIATION}-frontend --tail 50'"
echo -e "  ${C_DIM}Restart:${C_RESET}      ssh $SSH_HOST 'sudo docker restart ${ABBREVIATION}-frontend'"
echo -e "  ${C_DIM}Rebuild:${C_RESET}      ssh $SSH_HOST 'cd $REMOTE_PROJECT && sudo docker compose -p $PROJECT_NAME up -d --build'"
echo -e "  ${C_DIM}SSH in:${C_RESET}       ssh $SSH_HOST"
echo ""
echo -e "${C_BOLD}=============================================================================${C_RESET}"
echo ""
