#!/usr/bin/env bash
#
# check-greptile.sh — Check for unresolved Greptile review comments on current PR
#
# Usage: ./scripts/check-greptile.sh [--quiet]
#
# Exit codes:
#   0 — No unresolved comments (or no PR found)
#   1 — Unresolved Greptile comments found → STOP and fix
#   2 — Prerequisites missing (gh CLI)
#

set -euo pipefail

QUIET=false
[[ "${1:-}" == "--quiet" ]] && QUIET=true

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

# Prerequisites
if ! command -v gh &>/dev/null; then
    [[ "$QUIET" == false ]] && echo -e "${YELLOW}⚠ gh CLI not installed — skipping Greptile check${NC}"
    exit 0
fi

if ! gh auth status &>/dev/null; then
    [[ "$QUIET" == false ]] && echo -e "${YELLOW}⚠ gh CLI not authenticated — skipping Greptile check${NC}"
    exit 0
fi

# Get current branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [[ -z "$BRANCH" || "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
    exit 0
fi

# Get repo info
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
    exit 0
fi

# Find PR for current branch
PR_NUMBER=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo "")
if [[ -z "$PR_NUMBER" ]]; then
    exit 0
fi

# Get Greptile comments
GREPTILE_COMMENTS=$(gh api "repos/$REPO/pulls/$PR_NUMBER/comments" \
    --jq '[.[] | select(.user.login == "greptile-apps[bot]" or .user.login == "greptile-apps")] | length' \
    2>/dev/null || echo "0")

if [[ "$GREPTILE_COMMENTS" -gt 0 ]]; then
    # Get latest review commit vs current HEAD
    LATEST_REVIEW_COMMIT=$(gh api "repos/$REPO/pulls/$PR_NUMBER/comments" \
        --jq '[.[] | select(.user.login == "greptile-apps[bot]" or .user.login == "greptile-apps")] | sort_by(.created_at) | last | .commit_id' \
        2>/dev/null || echo "")
    
    CURRENT_HEAD=$(git rev-parse HEAD 2>/dev/null || echo "")
    
    # If the review is on the current commit, comments are still relevant
    if [[ "$LATEST_REVIEW_COMMIT" == "$CURRENT_HEAD"* || "$CURRENT_HEAD" == "$LATEST_REVIEW_COMMIT"* ]]; then
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}  ⛔ GREPTILE REVIEW: $GREPTILE_COMMENTS unresolved comment(s) on PR #$PR_NUMBER${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        
        # Show each comment
        gh api "repos/$REPO/pulls/$PR_NUMBER/comments" \
            --jq '.[] | select(.user.login == "greptile-apps[bot]" or .user.login == "greptile-apps") | "  📄 \(.path):\(.line // "general")\n     \(.body | split("\n")[0])\n"' \
            2>/dev/null || true
        
        echo -e "${BOLD}  → Fix these findings before continuing other work.${NC}"
        echo -e "${BOLD}  → Run: gh api repos/$REPO/pulls/$PR_NUMBER/comments${NC}"
        echo ""
        exit 1
    else
        # Review was on an older commit — new push may have fixed things
        if [[ "$QUIET" == false ]]; then
            echo -e "${YELLOW}ℹ Greptile reviewed older commit (${LATEST_REVIEW_COMMIT:0:7}), waiting for re-review on ${CURRENT_HEAD:0:7}${NC}"
        fi
        exit 0
    fi
else
    if [[ "$QUIET" == false ]]; then
        echo -e "${GREEN}✓ No Greptile findings on PR #$PR_NUMBER${NC}"
    fi
    exit 0
fi
