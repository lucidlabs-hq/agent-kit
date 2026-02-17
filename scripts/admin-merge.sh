#!/usr/bin/env bash
#===============================================================================
# Admin Merge - Bypass required reviews for solo maintainer PRs
#
# Why this exists:
#   Branch protection requires 1 approving review to prevent downstream
#   projects from pushing directly to upstream. But as the sole maintainer,
#   you cannot approve your own PRs. This script provides an intentional,
#   auditable bypass.
#
# Usage:
#   ./scripts/admin-merge.sh <PR_NUMBER>
#   ./scripts/admin-merge.sh 7
#   ./scripts/admin-merge.sh 12 --merge    # merge commit instead of squash
#
# What it does:
#   1. Validates PR is open and all review conversations are resolved
#   2. Temporarily sets required_approving_review_count to 0
#   3. Squash-merges the PR and deletes the branch
#   4. Restores required_approving_review_count to 1
#   5. Logs the action to .admin-merge.log
#
# Safety:
#   - Only works when run from the upstream agent-kit repository
#   - Requires gh CLI with admin permissions
#   - Protection is restored even if merge fails (trap)
#===============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
REPO=""
PR_NUMBER=""
MERGE_METHOD="squash"
REQUIRED_REVIEWS=1
PROTECTION_LOWERED=false

#-------------------------------------------------------------------------------
# Helpers
#-------------------------------------------------------------------------------

die() {
    echo -e "${RED}  [BLOCKED] $1${NC}" >&2
    echo "" >&2
    [[ -n "${2:-}" ]] && echo "  Why:  $2" >&2 && echo "" >&2
    [[ -n "${3:-}" ]] && echo "  Fix:  $3" >&2 && echo "" >&2
    exit 1
}

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
step() { echo -e "${GREEN}▶${NC} $1"; }

#-------------------------------------------------------------------------------
# Cleanup trap - ALWAYS restore protection
#-------------------------------------------------------------------------------

restore_protection() {
    if [[ "$PROTECTION_LOWERED" == true ]]; then
        echo ""
        step "Restoring branch protection (required_approving_review_count → $REQUIRED_REVIEWS)..."
        gh api "repos/$REPO/branches/main/protection/required_pull_request_reviews" \
            --method PATCH \
            --field "required_approving_review_count=$REQUIRED_REVIEWS" \
            --field dismiss_stale_reviews=true \
            --field require_code_owner_reviews=true \
            --silent 2>/dev/null && success "Branch protection restored." || \
            echo -e "${RED}  CRITICAL: Failed to restore protection! Run manually:${NC}
  gh api repos/$REPO/branches/main/protection/required_pull_request_reviews \\
    --method PATCH --field required_approving_review_count=$REQUIRED_REVIEWS"
    fi
}

trap restore_protection EXIT

#-------------------------------------------------------------------------------
# Parse arguments
#-------------------------------------------------------------------------------

if [[ $# -lt 1 ]]; then
    echo ""
    echo "Usage: ./scripts/admin-merge.sh <PR_NUMBER> [--merge|--squash|--rebase]"
    echo ""
    echo "Examples:"
    echo "  ./scripts/admin-merge.sh 7           # squash merge (default)"
    echo "  ./scripts/admin-merge.sh 12 --merge  # merge commit"
    echo ""
    exit 1
fi

PR_NUMBER="$1"
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        --merge)  MERGE_METHOD="merge"; shift ;;
        --squash) MERGE_METHOD="squash"; shift ;;
        --rebase) MERGE_METHOD="rebase"; shift ;;
        *) die "Unknown option: $1" "" "Valid options: --merge, --squash, --rebase" ;;
    esac
done

#-------------------------------------------------------------------------------
# Validation
#-------------------------------------------------------------------------------

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                      ADMIN MERGE                                  ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Must be in a git repo
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null) || \
    die "Not in a GitHub repository" "Could not determine repo from current directory." "Run from the agent-kit root."

info "Repository: ${BOLD}$REPO${NC}"
info "PR: ${BOLD}#$PR_NUMBER${NC}"
info "Method: ${BOLD}$MERGE_METHOD${NC}"
echo ""

# Check gh auth
gh auth status &>/dev/null || \
    die "Not authenticated with GitHub CLI" "" "Run: gh auth login"

# Validate PR exists and is open
PR_STATE=$(gh pr view "$PR_NUMBER" --json state --jq '.state' 2>/dev/null) || \
    die "PR #$PR_NUMBER not found" "The PR does not exist or you don't have access." ""

if [[ "$PR_STATE" != "OPEN" ]]; then
    die "PR #$PR_NUMBER is $PR_STATE" "Only open PRs can be merged." ""
fi

# Get PR details
PR_TITLE=$(gh pr view "$PR_NUMBER" --json title --jq '.title')
PR_AUTHOR=$(gh pr view "$PR_NUMBER" --json author --jq '.author.login')
PR_BRANCH=$(gh pr view "$PR_NUMBER" --json headRefName --jq '.headRefName')

info "Title: ${BOLD}$PR_TITLE${NC}"
info "Author: $PR_AUTHOR"
info "Branch: $PR_BRANCH"
echo ""

#-------------------------------------------------------------------------------
# Check unresolved review threads
#-------------------------------------------------------------------------------

step "Checking review conversations..."

UNRESOLVED=$(gh api "repos/$REPO/pulls/$PR_NUMBER/comments" \
    --jq '[.[] | select(.in_reply_to_id == null)] | length' 2>/dev/null || echo "0")

# Use GraphQL for accurate thread resolution status
UNRESOLVED_THREADS=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            isResolved
            comments(first: 1) {
              nodes { body }
            }
          }
        }
      }
    }
  }
' -f owner="${REPO%/*}" -f repo="${REPO#*/}" -F pr="$PR_NUMBER" \
    --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)] | length' 2>/dev/null || echo "0")

if [[ "$UNRESOLVED_THREADS" -gt 0 ]]; then
    warn "${BOLD}$UNRESOLVED_THREADS unresolved review thread(s)${NC}"
    echo ""
    echo -e "  ${YELLOW}Unresolved threads should be resolved before merging.${NC}"
    echo ""
    read -p "  Continue anyway? [y/N] " -r CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "  Cancelled."
        exit 0
    fi
    echo ""
else
    success "All review conversations resolved."
fi

#-------------------------------------------------------------------------------
# Check CI status
#-------------------------------------------------------------------------------

step "Checking CI status..."

CI_STATE=$(gh pr checks "$PR_NUMBER" --json state --jq '.[].state' 2>/dev/null | sort -u)

if echo "$CI_STATE" | grep -q "FAILURE"; then
    warn "Some CI checks have failed."
    read -p "  Continue anyway? [y/N] " -r CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "  Cancelled."
        exit 0
    fi
elif echo "$CI_STATE" | grep -q "PENDING"; then
    warn "Some CI checks are still pending."
    read -p "  Continue anyway? [y/N] " -r CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "  Cancelled."
        exit 0
    fi
else
    success "CI checks passed."
fi

echo ""

#-------------------------------------------------------------------------------
# Confirm merge
#-------------------------------------------------------------------------------

echo -e "${BOLD}  Ready to merge PR #$PR_NUMBER ($MERGE_METHOD):${NC}"
echo -e "  ${CYAN}$PR_TITLE${NC}"
echo ""
read -p "  Proceed? [y/N] " -r CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "  Cancelled."
    exit 0
fi

echo ""

#-------------------------------------------------------------------------------
# Get current protection level
#-------------------------------------------------------------------------------

step "Reading current branch protection..."

REQUIRED_REVIEWS=$(gh api "repos/$REPO/branches/main/protection/required_pull_request_reviews" \
    --jq '.required_approving_review_count' 2>/dev/null || echo "1")

info "Current required reviews: $REQUIRED_REVIEWS"

if [[ "$REQUIRED_REVIEWS" -eq 0 ]]; then
    info "No review bypass needed."
else
    #---------------------------------------------------------------------------
    # Temporarily lower protection
    #---------------------------------------------------------------------------
    step "Temporarily setting required reviews → 0..."

    gh api "repos/$REPO/branches/main/protection/required_pull_request_reviews" \
        --method PATCH \
        --field required_approving_review_count=0 \
        --field dismiss_stale_reviews=true \
        --field require_code_owner_reviews=true \
        --silent 2>/dev/null || die "Failed to update branch protection" "You may not have admin access." ""

    PROTECTION_LOWERED=true
    success "Review requirement temporarily disabled."
fi

#-------------------------------------------------------------------------------
# Merge
#-------------------------------------------------------------------------------

step "Merging PR #$PR_NUMBER (--$MERGE_METHOD --delete-branch)..."

gh pr merge "$PR_NUMBER" "--$MERGE_METHOD" --delete-branch 2>&1 || {
    echo ""
    echo -e "${RED}  Merge failed. Branch protection will be restored.${NC}"
    exit 1
}

success "PR #$PR_NUMBER merged successfully!"

#-------------------------------------------------------------------------------
# Log the action
#-------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../.admin-merge.log"

{
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | PR #$PR_NUMBER | $MERGE_METHOD | $PR_TITLE | by $(gh api user --jq '.login' 2>/dev/null || echo 'unknown')"
} >> "$LOG_FILE"

info "Logged to .admin-merge.log"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Done. PR #$PR_NUMBER merged. Protection restored.                     ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""
