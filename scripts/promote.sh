#!/bin/bash

#===============================================================================
# Agent Kit - Pattern Promotion Script
#
# Promotes generic patterns from downstream projects back to the upstream
# agent-kit template repository.
#
# Usage:
#   ./scripts/promote.sh --upstream <path-to-agent-kit>
#   ./scripts/promote.sh --upstream ~/templates/agent-kit --dry-run
#
# Options:
#   --upstream PATH    Path to the upstream agent-kit repository (required)
#   --dry-run          Preview changes without executing
#   --all              Promote all detected changes without selection
#   --help, -h         Show this help
#===============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
UPSTREAM_PATH=""
DRY_RUN=false
PROMOTE_ALL=false
DOWNSTREAM_PATH="$(pwd)"
PROJECT_NAME="$(basename "$DOWNSTREAM_PATH")"

# Whitelist: Paths that can be promoted
WHITELIST_PATTERNS=(
    ".claude/skills/"
    ".claude/reference/"
    "frontend/components/ui/"
    "frontend/lib/utils.ts"
    "frontend/lib/hooks/"
    "scripts/"
)

# Blacklist: Paths that should never be promoted
BLACKLIST_PATTERNS=(
    ".claude/PRD.md"
    "frontend/app/"
    "mastra/src/agents/"
    "convex/schema.ts"
    "convex/functions/"
    ".env"
    "node_modules"
    ".next"
    ".git"
)

# Domain keywords that indicate non-generic code
DOMAIN_KEYWORDS=(
    "ticket"
    "customer"
    "invoice"
    "order"
    "product"
    "user"
    "account"
    "payment"
    "booking"
    "reservation"
)

#-------------------------------------------------------------------------------
# Helper Functions
#-------------------------------------------------------------------------------

print_banner() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}              ${BOLD}PATTERN PROMOTION${NC}                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}      ${BLUE}Promote generic patterns to upstream agent-kit${NC}          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✖${NC} $1"
}

print_success() {
    echo -e "${GREEN}✔${NC} $1"
}

confirm() {
    local prompt="$1"
    local default="${2:-y}"

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    read -p "$prompt" response
    response=${response:-$default}

    [[ "$response" =~ ^[Yy]$ ]]
}

show_help() {
    cat << 'EOF'
Usage: ./scripts/promote.sh --upstream <path> [options]

Promotes generic patterns from a downstream project back to the upstream
agent-kit template repository.

Options:
  --upstream PATH    Path to the upstream agent-kit repository (required)
  --dry-run          Preview changes without executing
  --all              Promote all detected changes without interactive selection
  --help, -h         Show this help

Examples:
  # Interactive promotion
  ./scripts/promote.sh --upstream ~/templates/agent-kit

  # Preview only (no changes)
  ./scripts/promote.sh --upstream ~/templates/agent-kit --dry-run

  # Promote all changes without prompts
  ./scripts/promote.sh --upstream ~/templates/agent-kit --all

Promotable paths:
  - .claude/skills/          Claude Code skills
  - .claude/reference/       Best practice documentation
  - frontend/components/ui/  Generic UI components
  - frontend/lib/utils.ts    Utility functions
  - frontend/lib/hooks/      Generic React hooks
  - scripts/                 Utility scripts

Non-promotable (blacklisted):
  - .claude/PRD.md           Project-specific requirements
  - frontend/app/            Project-specific pages
  - mastra/src/agents/       Domain-specific agents
  - convex/                  Project-specific database

EOF
}

#-------------------------------------------------------------------------------
# Validation Functions
#-------------------------------------------------------------------------------

validate_environment() {
    # Check if we're in a project directory
    if [[ ! -f "CLAUDE.md" ]] && [[ ! -d ".claude" ]]; then
        echo ""
        print_error "[BLOCKED] Not in a valid project directory"
        echo ""
        echo "  Why:  No CLAUDE.md or .claude/ directory found in $(pwd)."
        echo "        This script must be run from a downstream project root."
        echo ""
        echo "  Fix:  cd into your project directory first:"
        echo "          cd ../projects/my-project"
        echo "          ./scripts/promote.sh --upstream ../../lucidlabs-agent-kit"
        echo ""
        exit 1
    fi

    # Check if upstream path is provided
    if [[ -z "$UPSTREAM_PATH" ]]; then
        echo ""
        print_error "[BLOCKED] Upstream path is required"
        echo ""
        echo "  Why:  The --upstream flag was not provided."
        echo ""
        echo "  Fix:  Specify the path to the agent-kit repository:"
        echo "          ./scripts/promote.sh --upstream ../../lucidlabs-agent-kit"
        echo ""
        exit 1
    fi

    # Check if upstream path exists
    if [[ ! -d "$UPSTREAM_PATH" ]]; then
        echo ""
        print_error "[BLOCKED] Upstream path does not exist: $UPSTREAM_PATH"
        echo ""
        echo "  Why:  The specified directory does not exist."
        echo ""
        echo "  Fix:  Verify folder structure:"
        echo "          lucidlabs/"
        echo "          ├── lucidlabs-agent-kit/    <-- Upstream"
        echo "          └── projects/"
        echo "              └── [this-project]/     <-- You are here"
        echo ""
        exit 1
    fi

    # Check if upstream is a valid agent-kit
    if [[ ! -f "$UPSTREAM_PATH/CLAUDE.md" ]]; then
        echo ""
        print_error "[BLOCKED] Not a valid agent-kit: $UPSTREAM_PATH"
        echo ""
        echo "  Why:  The directory has no CLAUDE.md file."
        echo "        This doesn't look like the agent-kit template."
        echo ""
        echo "  Fix:  Check the path is correct:"
        echo "          ls $UPSTREAM_PATH/CLAUDE.md"
        echo ""
        exit 1
    fi

    # Check if gh CLI is installed (for PR creation)
    if ! command -v gh &> /dev/null; then
        print_warning "GitHub CLI (gh) not installed - PR creation will be skipped"
        print_info "Install with: brew install gh"
    fi
}

#-------------------------------------------------------------------------------
# Detection Functions
#-------------------------------------------------------------------------------

is_whitelisted() {
    local path="$1"

    for pattern in "${WHITELIST_PATTERNS[@]}"; do
        if [[ "$path" == "$pattern"* ]]; then
            return 0
        fi
    done

    return 1
}

is_blacklisted() {
    local path="$1"

    for pattern in "${BLACKLIST_PATTERNS[@]}"; do
        if [[ "$path" == "$pattern"* ]] || [[ "$path" == *"$pattern"* ]]; then
            return 0
        fi
    done

    return 1
}

check_domain_keywords() {
    local file="$1"
    local found_keywords=()

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    for keyword in "${DOMAIN_KEYWORDS[@]}"; do
        if grep -qi "$keyword" "$file" 2>/dev/null; then
            found_keywords+=("$keyword")
        fi
    done

    if [[ ${#found_keywords[@]} -gt 0 ]]; then
        echo "${found_keywords[*]}"
        return 1
    fi

    return 0
}

detect_promotable_changes() {
    local changes=()

    print_step "Scanning for promotable changes..." >&2
    echo "" >&2

    # Find all files in whitelisted paths
    for pattern in "${WHITELIST_PATTERNS[@]}"; do
        if [[ -e "$DOWNSTREAM_PATH/$pattern" ]]; then
            # Handle both files and directories
            if [[ -d "$DOWNSTREAM_PATH/$pattern" ]]; then
                while IFS= read -r -d '' file; do
                    local rel_path="${file#$DOWNSTREAM_PATH/}"

                    # Skip if blacklisted
                    if is_blacklisted "$rel_path"; then
                        continue
                    fi

                    # Check if file exists in upstream
                    local status="NEW"
                    if [[ -f "$UPSTREAM_PATH/$rel_path" ]]; then
                        # Check if different
                        if ! diff -q "$file" "$UPSTREAM_PATH/$rel_path" > /dev/null 2>&1; then
                            status="MODIFIED"
                        else
                            continue  # Same file, skip
                        fi
                    fi

                    changes+=("$rel_path|$status")
                done < <(find "$DOWNSTREAM_PATH/$pattern" -type f -print0 2>/dev/null)
            elif [[ -f "$DOWNSTREAM_PATH/$pattern" ]]; then
                local rel_path="$pattern"

                if is_blacklisted "$rel_path"; then
                    continue
                fi

                local status="NEW"
                if [[ -f "$UPSTREAM_PATH/$rel_path" ]]; then
                    if ! diff -q "$DOWNSTREAM_PATH/$rel_path" "$UPSTREAM_PATH/$rel_path" > /dev/null 2>&1; then
                        status="MODIFIED"
                    else
                        continue
                    fi
                fi

                changes+=("$rel_path|$status")
            fi
        fi
    done

    # Return changes
    printf '%s\n' "${changes[@]}"
}

#-------------------------------------------------------------------------------
# Selection Functions
#-------------------------------------------------------------------------------

select_changes() {
    local -a changes=("$@")
    local -a selected=()

    if [[ ${#changes[@]} -eq 0 ]]; then
        print_info "No promotable changes found." >&2
        return
    fi

    echo -e "${BOLD}Promotable changes found:${NC}" >&2
    echo "" >&2

    local i=1
    for change in "${changes[@]}"; do
        local path="${change%|*}"
        local status="${change#*|}"
        local status_color="${GREEN}"
        [[ "$status" == "MODIFIED" ]] && status_color="${YELLOW}"

        # Check for domain keywords
        local warning=""
        local keywords
        if keywords=$(check_domain_keywords "$DOWNSTREAM_PATH/$path"); then
            : # No keywords found
        else
            warning=" ${YELLOW}⚠ domain keywords: $keywords${NC}"
        fi

        echo -e "  [${CYAN}$i${NC}] $path (${status_color}$status${NC})$warning" >&2
        ((i++))
    done

    echo "" >&2

    if [[ "$PROMOTE_ALL" == true ]]; then
        selected=("${changes[@]}")
    else
        read -p "Enter numbers to promote (e.g., 1,3,5 or 'all' or 'q' to quit): " selection

        if [[ "$selection" == "q" ]] || [[ "$selection" == "quit" ]]; then
            print_info "Cancelled." >&2
            exit 0
        fi

        if [[ "$selection" == "all" ]]; then
            selected=("${changes[@]}")
        else
            IFS=',' read -ra nums <<< "$selection"
            for num in "${nums[@]}"; do
                num=$(echo "$num" | tr -d ' ')
                if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#changes[@]} ]]; then
                    selected+=("${changes[$((num-1))]}")
                fi
            done
        fi
    fi

    # Return selected (to stdout for capture)
    printf '%s\n' "${selected[@]}"
}

#-------------------------------------------------------------------------------
# Review Functions
#-------------------------------------------------------------------------------

review_changes() {
    local -a changes=("$@")

    echo ""
    echo -e "${BOLD}Review selected changes:${NC}"
    echo ""

    for change in "${changes[@]}"; do
        local path="${change%|*}"
        local status="${change#*|}"

        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}$path${NC} ($status)"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

        if [[ "$status" == "NEW" ]]; then
            echo -e "${GREEN}+ New file will be added${NC}"
            head -20 "$DOWNSTREAM_PATH/$path" 2>/dev/null || true
            echo "..."
        else
            echo -e "${YELLOW}~ File will be updated${NC}"
            diff --color=always -u "$UPSTREAM_PATH/$path" "$DOWNSTREAM_PATH/$path" 2>/dev/null | head -30 || true
        fi

        echo ""
    done

    if [[ "$DRY_RUN" == true ]]; then
        print_info "DRY RUN - No changes will be made"
        return 1
    fi

    if ! confirm "Proceed with promotion?"; then
        print_info "Cancelled."
        return 1
    fi

    return 0
}

#-------------------------------------------------------------------------------
# Pattern Registry Update
#-------------------------------------------------------------------------------

update_pattern_registry() {
    local registry_script="$UPSTREAM_PATH/scripts/pattern-registry.sh"
    if [[ -f "$registry_script" ]]; then
        print_step "Updating pattern registry..."
        bash "$registry_script" --quiet 2>/dev/null
        if [[ -f "$UPSTREAM_PATH/pattern-registry.json" ]]; then
            git add "pattern-registry.json"
            print_success "Pattern registry updated"
        fi
    fi
}

#-------------------------------------------------------------------------------
# Promotion Execution
#-------------------------------------------------------------------------------

execute_promotion() {
    local -a changes=("$@")
    local branch="promote/$(date +%Y%m%d)-from-${PROJECT_NAME}"

    print_step "Starting promotion..."
    echo ""

    # Switch to upstream directory
    cd "$UPSTREAM_PATH"

    # Unlock upstream files if lock script exists (macOS chflags)
    if [[ -f "$UPSTREAM_PATH/scripts/unlock-upstream.sh" ]]; then
        print_step "Unlocking upstream files..."
        "$UPSTREAM_PATH/scripts/unlock-upstream.sh"
    fi

    # Check for uncommitted changes
    if [[ -n "$(git status --porcelain)" ]]; then
        print_error "Upstream has uncommitted changes. Please commit or stash them first."
        # Re-lock before exit
        if [[ -f "$UPSTREAM_PATH/scripts/lock-upstream.sh" ]]; then
            "$UPSTREAM_PATH/scripts/lock-upstream.sh" 2>/dev/null || true
        fi
        exit 1
    fi

    # Pull latest
    print_step "Pulling latest upstream..."
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true

    # Create branch
    print_step "Creating branch: $branch"
    git checkout -b "$branch"

    # Copy files
    local copied=0
    for change in "${changes[@]}"; do
        local path="${change%|*}"
        local dir=$(dirname "$path")

        # Create directory if needed
        mkdir -p "$dir"

        # Copy file
        cp "$DOWNSTREAM_PATH/$path" "$path"
        print_success "Copied: $path"
        ((copied++))
    done

    # Update pattern registry (auto-regenerate after new files copied)
    update_pattern_registry

    # Stage changes
    git add .

    # Create commit (ALLOW_UPSTREAM_COMMIT bypasses the pre-commit hook)
    local commit_msg="feat: promote patterns from $PROJECT_NAME

Promoted files:
$(printf '- %s\n' "${changes[@]}" | sed 's/|/ (/' | sed 's/$/)/')"

    print_step "Creating commit..."
    ALLOW_UPSTREAM_COMMIT=1 git commit -m "$commit_msg"

    print_success "Committed $copied files"
    echo ""

    # Offer to create PR
    if command -v gh &> /dev/null; then
        if confirm "Create GitHub PR?"; then
            print_step "Creating PR..."

            # Push branch
            git push -u origin "$branch"

            # Create PR
            gh pr create \
                --title "Promote patterns from $PROJECT_NAME" \
                --body "## Pattern Promotion

Promoted from downstream project: \`$PROJECT_NAME\`

### Files:
$(printf '- %s\n' "${changes[@]}" | sed 's/|/ (/' | sed 's/$/)/')

### Pattern Registry
- [x] Auto-updated \`pattern-registry.json\`

### Checklist:
- [ ] Reviewed for domain-specific content
- [ ] Tested in isolation
- [ ] Documentation updated if needed
"
            print_success "PR created!"
        else
            print_info "Branch pushed. Create PR manually when ready:"
            echo "  git push -u origin $branch"
            echo "  gh pr create"
        fi
    else
        print_info "Push branch and create PR manually:"
        echo "  git push -u origin $branch"
    fi

    # Re-lock upstream files
    if [[ -f "$UPSTREAM_PATH/scripts/lock-upstream.sh" ]]; then
        print_step "Re-locking upstream files..."
        "$UPSTREAM_PATH/scripts/lock-upstream.sh"
    fi

    # Switch back
    cd "$DOWNSTREAM_PATH"

    echo ""
    print_success "Promotion complete!"
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --upstream)
                UPSTREAM_PATH="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --all)
                PROMOTE_ALL=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Expand path
    UPSTREAM_PATH=$(eval echo "$UPSTREAM_PATH")

    print_banner
    validate_environment

    print_info "Downstream: $DOWNSTREAM_PATH"
    print_info "Upstream:   $UPSTREAM_PATH"
    echo ""

    # ─────────────────────────────────────────────────────────────────────
    # Enforce upstream check: block if upstream has new commits
    # ─────────────────────────────────────────────────────────────────────
    print_step "Checking upstream is up-to-date..."

    pushd "$UPSTREAM_PATH" > /dev/null
    git fetch origin 2>/dev/null || true
    BEHIND_COUNT=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
    if [[ "$BEHIND_COUNT" -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║  [BLOCKED] Upstream has new commits since last pull            ║${NC}"
        echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "  Why:  The upstream agent-kit has commits that are not in your"
        echo "        local copy. Promoting now could cause merge conflicts"
        echo "        or overwrite recent upstream changes."
        echo ""
        echo "  New commits:"
        git log HEAD..origin/main --oneline 2>/dev/null || git log HEAD..origin/master --oneline 2>/dev/null || true
        echo ""
        echo "  Fix:  1. Pull upstream first:"
        echo "            cd $UPSTREAM_PATH && git pull origin main"
        echo "        2. Run /sync in your downstream project"
        echo "        3. Then retry /promote"
        echo ""
        popd > /dev/null
        exit 1
    fi

    print_success "Upstream is up-to-date ($(git rev-parse --short HEAD 2>/dev/null))"
    popd > /dev/null
    echo ""

    # Detect changes (bash 3 compatible - no mapfile)
    all_changes=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && all_changes+=("$line")
    done < <(detect_promotable_changes)

    if [[ ${#all_changes[@]} -eq 0 ]]; then
        print_info "No promotable changes found."
        exit 0
    fi

    # Select changes (bash 3 compatible - no mapfile)
    selected_changes=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && selected_changes+=("$line")
    done < <(select_changes "${all_changes[@]}")

    if [[ ${#selected_changes[@]} -eq 0 ]]; then
        print_info "No changes selected."
        exit 0
    fi

    # Review and confirm
    if ! review_changes "${selected_changes[@]}"; then
        exit 0
    fi

    # Execute promotion
    execute_promotion "${selected_changes[@]}"
}

main "$@"
