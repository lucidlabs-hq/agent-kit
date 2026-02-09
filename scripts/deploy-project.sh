#!/bin/bash
# =============================================================================
# LUCIDLABS-HQ - Deploy Project (Local Orchestration)
#
# Full end-to-end deployment from developer machine to LUCIDLABS-HQ.
# Handles GitHub repo, server provisioning, code sync, and health checks.
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
    echo "  --dry-run          Show what would happen without making changes"
    echo ""
    echo "Example:"
    echo "  ./scripts/deploy-project.sh --name client-service-reporting --abbreviation csr --subdomain reporting --has-convex"
    exit 1
fi

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
STEP=0
step() {
    STEP=$((STEP + 1))
    echo ""
    echo "=== Step $STEP: $1 ==="
    echo ""
}

log_ok()   { echo "  [OK]   $1"; }
log_skip() { echo "  [SKIP] $1"; }
log_err()  { echo "  [ERR]  $1"; }
log_info() { echo "  [INFO] $1"; }
log_dry()  { echo "  [DRY]  $1"; }

run_or_dry() {
    if [ "$DRY_RUN" = true ]; then
        log_dry "Would run: $*"
    else
        "$@"
    fi
}

# -----------------------------------------------------------------------------
# Header
# -----------------------------------------------------------------------------
echo ""
echo "============================================================================="
echo "  LUCIDLABS-HQ: DEPLOY PROJECT"
echo "============================================================================="
echo ""
echo "  Project:      $PROJECT_NAME"
echo "  Abbreviation: $ABBREVIATION"
echo "  Subdomain:    $SUBDOMAIN.lucidlabs.de"
echo "  Convex:       $HAS_CONVEX"
echo "  Mastra:       $HAS_MASTRA"
echo "  Dry Run:      $DRY_RUN"
echo ""
echo "============================================================================="

# -----------------------------------------------------------------------------
# Step 1: Verify SSH access
# -----------------------------------------------------------------------------
step "Verify SSH Access"

if [ "$DRY_RUN" = true ]; then
    log_dry "Would verify SSH to $SSH_HOST"
else
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

# -----------------------------------------------------------------------------
# Step 3: Create GitHub repo
# -----------------------------------------------------------------------------
if [ "$SKIP_GITHUB" = false ]; then
    step "GitHub Repository"

    REPO_FULL="${GITHUB_ORG}/${PROJECT_NAME}"

    if [ "$DRY_RUN" = true ]; then
        log_dry "Would create repo $REPO_FULL (if not exists)"
    else
        if gh repo view "$REPO_FULL" &> /dev/null; then
            log_skip "Repository $REPO_FULL already exists"
        else
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
        # Check if secrets already set (we can check if repo has them)
        log_info "Setting repository secrets..."
        log_info "Note: Organization secrets (HQ_HOST, SSH_KEY) are inherited."
        log_info "Set project-specific secrets manually if needed:"
        log_info "  gh secret set NEXT_PUBLIC_CONVEX_URL -R $REPO_FULL"
        log_info "  gh secret set LINEAR_API_KEY -R $REPO_FULL"
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
            log_info "Expected: $EXPECTED_URL"
            log_info "Skipping remote update (may be intentional)"
        else
            log_skip "Remote already configured: $EXPECTED_URL"
        fi

        if git push -u origin main 2>/dev/null; then
            log_ok "Pushed to origin/main"
        else
            log_info "Push may require manual intervention (branch protection, etc.)"
        fi
    fi
fi

# -----------------------------------------------------------------------------
# Step 6: Sync add-project.sh to server
# -----------------------------------------------------------------------------
step "Sync Server Scripts"

if [ "$DRY_RUN" = true ]; then
    log_dry "Would rsync add-project.sh to $SSH_HOST:$REMOTE_SCRIPTS/"
else
    ssh -p "$SSH_PORT" "$SSH_HOST" "sudo mkdir -p $REMOTE_SCRIPTS"

    rsync -avz -e "ssh -p $SSH_PORT" \
        "$LOCAL_INFRA_SCRIPTS/add-project.sh" \
        "$SSH_HOST:/tmp/add-project.sh"

    ssh -p "$SSH_PORT" "$SSH_HOST" "sudo mv /tmp/add-project.sh $REMOTE_SCRIPTS/add-project.sh && sudo chmod +x $REMOTE_SCRIPTS/add-project.sh && sudo chown root:root $REMOTE_SCRIPTS/add-project.sh"

    log_ok "Synced add-project.sh to server"
fi

# -----------------------------------------------------------------------------
# Step 7: Run add-project.sh on server
# -----------------------------------------------------------------------------
if [ "$SKIP_PROVISION" = false ]; then
    step "Provision Project on Server"

    ADD_ARGS="--name $PROJECT_NAME --abbreviation $ABBREVIATION --subdomain $SUBDOMAIN"
    [ "$HAS_CONVEX" = true ] && ADD_ARGS="$ADD_ARGS --has-convex"
    [ "$HAS_MASTRA" = true ] && ADD_ARGS="$ADD_ARGS --has-mastra"

    if [ "$DRY_RUN" = true ]; then
        log_dry "Would run: sudo $REMOTE_SCRIPTS/add-project.sh $ADD_ARGS"
    else
        ssh -p "$SSH_PORT" "$SSH_HOST" "sudo $REMOTE_SCRIPTS/add-project.sh $ADD_ARGS"
        log_ok "Server provisioning complete"
    fi
else
    log_skip "Server provisioning skipped (--skip-provision)"
fi

# -----------------------------------------------------------------------------
# Step 8: Rsync project code
# -----------------------------------------------------------------------------
step "Sync Project Code"

REMOTE_PROJECT="$REMOTE_BASE/projects/$PROJECT_NAME"

if [ "$DRY_RUN" = true ]; then
    log_dry "Would rsync project code to $SSH_HOST:$REMOTE_PROJECT/"
else
    rsync -avz -e "ssh -p $SSH_PORT" \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='.next' \
        --exclude='.env.local' \
        --exclude='frontend/.next' \
        --exclude='frontend/node_modules' \
        --exclude='mastra/node_modules' \
        --exclude='convex/node_modules' \
        ./ "$SSH_HOST:$REMOTE_PROJECT/"

    log_ok "Project code synced to server"
fi

# -----------------------------------------------------------------------------
# Step 9: Start services
# -----------------------------------------------------------------------------
step "Start Services"

if [ "$DRY_RUN" = true ]; then
    [ "$HAS_CONVEX" = true ] && log_dry "Would start Convex instance"
    log_dry "Would build and start frontend"
else
    # Start Convex if needed
    if [ "$HAS_CONVEX" = true ]; then
        log_info "Starting Convex instance..."
        ssh -p "$SSH_PORT" "$SSH_HOST" "cd $REMOTE_PROJECT && sudo docker compose -f docker-compose.convex.yml -p ${ABBREVIATION}-convex up -d"
        log_ok "Convex instance started"

        # Wait for Convex to be ready
        log_info "Waiting for Convex to initialize (15s)..."
        sleep 15
    fi

    # Build and start frontend
    log_info "Building and starting frontend..."
    ssh -p "$SSH_PORT" "$SSH_HOST" "cd $REMOTE_PROJECT && sudo docker compose -p $PROJECT_NAME up -d --build"
    log_ok "Frontend started"
fi

# -----------------------------------------------------------------------------
# Step 10: Health check
# -----------------------------------------------------------------------------
step "Health Check"

FRONTEND_URL="https://${SUBDOMAIN}.lucidlabs.de"

if [ "$DRY_RUN" = true ]; then
    log_dry "Would check: $FRONTEND_URL"
else
    log_info "Waiting for services to start (20s)..."
    sleep 20

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" 2>/dev/null || echo "000")

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "307" ] || [ "$HTTP_CODE" = "308" ]; then
        log_ok "Frontend responding: $FRONTEND_URL (HTTP $HTTP_CODE)"
    else
        log_err "Frontend not responding: $FRONTEND_URL (HTTP $HTTP_CODE)"
        log_info "Check container logs: ssh $SSH_HOST 'docker logs ${ABBREVIATION}-frontend'"
    fi

    if [ "$HAS_CONVEX" = true ]; then
        CONVEX_URL="https://${ABBREVIATION}-convex.lucidlabs.de"
        CONVEX_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${CONVEX_URL}/version" 2>/dev/null || echo "000")

        if [ "$CONVEX_CODE" = "200" ]; then
            log_ok "Convex responding: $CONVEX_URL (HTTP $CONVEX_CODE)"
        else
            log_err "Convex not responding: $CONVEX_URL (HTTP $CONVEX_CODE)"
            log_info "Check container logs: ssh $SSH_HOST 'docker logs ${ABBREVIATION}-convex-backend'"
        fi
    fi
fi

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "============================================================================="
echo "  DEPLOYMENT COMPLETE"
echo "============================================================================="
echo ""
echo "  Frontend:         $FRONTEND_URL"
[ "$HAS_CONVEX" = true ] && echo "  Convex API:       https://${ABBREVIATION}-convex.lucidlabs.de"
[ "$SKIP_GITHUB" = false ] && echo "  GitHub:           https://github.com/${GITHUB_ORG}/${PROJECT_NAME}"
echo ""
if [ "$DRY_RUN" = true ]; then
    echo "  (DRY RUN - no changes were made)"
    echo ""
fi
echo "============================================================================="
