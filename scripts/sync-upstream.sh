#!/usr/bin/env bash
# sync-upstream.sh - Sync updates from upstream agent-kit to downstream project
#
# Usage:
#   ./scripts/sync-upstream.sh [options]
#
# Options:
#   --upstream PATH   Path to upstream agent-kit (default: ../../lucidlabs-agent-kit)
#   --dry-run         Preview changes without applying
#   --all             Sync all without selection
#   --help            Show this help message

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Default values
UPSTREAM_PATH="../../lucidlabs-agent-kit"
DRY_RUN=false
SYNC_ALL=false

# Syncable paths (files/directories that can be synced from upstream)
SYNCABLE_PATHS=(
    ".claude/skills"
    ".claude/reference"
    "frontend/components/ui"
    "frontend/lib/utils.ts"
    "frontend/lib/hooks"
    "scripts/promote.sh"
    "scripts/sync-upstream.sh"
    "CLAUDE.md"
    "AGENTS.md"
    "WORKFLOW.md"
)

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
            SYNC_ALL=true
            shift
            ;;
        --help)
            echo "Usage: ./scripts/sync-upstream.sh [options]"
            echo ""
            echo "Options:"
            echo "  --upstream PATH   Path to upstream agent-kit (default: ../../lucidlabs-agent-kit)"
            echo "  --dry-run         Preview changes without applying"
            echo "  --all             Sync all without selection"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Print header
echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                      UPSTREAM SYNC                                ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate upstream path
if [[ ! -d "$UPSTREAM_PATH" ]]; then
    echo -e "${RED}Error: Upstream path not found: $UPSTREAM_PATH${NC}"
    echo ""
    echo "Expected folder structure:"
    echo "  lucidlabs/"
    echo "  ├── lucidlabs-agent-kit/    ← Upstream template"
    echo "  └── projects/"
    echo "      └── [this-project]/     ← You are here"
    echo ""
    echo "Use --upstream to specify a different path."
    exit 1
fi

# Check if upstream has required files
if [[ ! -f "$UPSTREAM_PATH/CLAUDE.md" ]]; then
    echo -e "${RED}Error: $UPSTREAM_PATH doesn't look like an agent-kit repository${NC}"
    exit 1
fi

DOWNSTREAM_PATH=$(pwd)
UPSTREAM_PATH=$(cd "$UPSTREAM_PATH" && pwd)

echo -e "${BLUE}ℹ${NC} Downstream: ${BOLD}$DOWNSTREAM_PATH${NC}"
echo -e "${BLUE}ℹ${NC} Upstream:   ${BOLD}$UPSTREAM_PATH${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}▶ DRY RUN MODE - No changes will be made${NC}"
    echo ""
fi

# Find syncable changes
echo -e "${BLUE}▶${NC} Scanning for syncable updates..."
echo ""

declare -a SYNC_ITEMS
declare -a SYNC_TYPES
INDEX=1

for path in "${SYNCABLE_PATHS[@]}"; do
    UPSTREAM_FILE="$UPSTREAM_PATH/$path"
    DOWNSTREAM_FILE="$DOWNSTREAM_PATH/$path"

    if [[ -e "$UPSTREAM_FILE" ]]; then
        if [[ ! -e "$DOWNSTREAM_FILE" ]]; then
            # New file/directory in upstream
            SYNC_ITEMS+=("$path")
            SYNC_TYPES+=("NEW")
            echo -e "  ${GREEN}[$INDEX]${NC} $path ${GREEN}(NEW)${NC}"
            ((INDEX++))
        elif [[ -f "$UPSTREAM_FILE" ]]; then
            # File exists in both - check if different
            if ! diff -q "$UPSTREAM_FILE" "$DOWNSTREAM_FILE" > /dev/null 2>&1; then
                SYNC_ITEMS+=("$path")
                SYNC_TYPES+=("MODIFIED")
                echo -e "  ${YELLOW}[$INDEX]${NC} $path ${YELLOW}(MODIFIED)${NC}"
                ((INDEX++))
            fi
        elif [[ -d "$UPSTREAM_FILE" ]]; then
            # Directory - check for new/modified files
            while IFS= read -r -d '' file; do
                rel_path="${file#$UPSTREAM_PATH/}"
                downstream_file="$DOWNSTREAM_PATH/$rel_path"

                if [[ ! -e "$downstream_file" ]]; then
                    SYNC_ITEMS+=("$rel_path")
                    SYNC_TYPES+=("NEW")
                    echo -e "  ${GREEN}[$INDEX]${NC} $rel_path ${GREEN}(NEW)${NC}"
                    ((INDEX++))
                elif ! diff -q "$file" "$downstream_file" > /dev/null 2>&1; then
                    SYNC_ITEMS+=("$rel_path")
                    SYNC_TYPES+=("MODIFIED")
                    echo -e "  ${YELLOW}[$INDEX]${NC} $rel_path ${YELLOW}(MODIFIED)${NC}"
                    ((INDEX++))
                fi
            done < <(find "$UPSTREAM_FILE" -type f -print0 2>/dev/null)
        fi
    fi
done

echo ""

if [[ ${#SYNC_ITEMS[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓${NC} Already up to date with upstream!"
    exit 0
fi

# Get user selection
if [[ "$SYNC_ALL" == true ]]; then
    SELECTED_INDICES=$(seq 1 ${#SYNC_ITEMS[@]} | tr '\n' ' ')
else
    echo -e "${BOLD}Enter numbers to sync (e.g., 1,2,3 or 'all' or 'q' to quit):${NC}"
    read -r SELECTION

    if [[ "$SELECTION" == "q" || "$SELECTION" == "quit" ]]; then
        echo "Cancelled."
        exit 0
    fi

    if [[ "$SELECTION" == "all" ]]; then
        SELECTED_INDICES=$(seq 1 ${#SYNC_ITEMS[@]} | tr '\n' ' ')
    else
        SELECTED_INDICES=$(echo "$SELECTION" | tr ',' ' ')
    fi
fi

echo ""

# Show diff for selected files
echo -e "${BLUE}▶${NC} Preview of changes:"
echo ""

for idx in $SELECTED_INDICES; do
    idx=$((idx - 1))
    if [[ $idx -ge 0 && $idx -lt ${#SYNC_ITEMS[@]} ]]; then
        path="${SYNC_ITEMS[$idx]}"
        type="${SYNC_TYPES[$idx]}"

        echo -e "${CYAN}--- $path ($type) ---${NC}"

        if [[ "$type" == "NEW" ]]; then
            echo -e "${GREEN}+ New file from upstream${NC}"
        else
            # Show diff
            diff -u "$DOWNSTREAM_PATH/$path" "$UPSTREAM_PATH/$path" 2>/dev/null | head -20 || true
        fi
        echo ""
    fi
done

# Confirm sync
if [[ "$DRY_RUN" == false ]]; then
    echo -e "${BOLD}Apply these changes? [y/N]:${NC}"
    read -r CONFIRM

    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "Cancelled."
        exit 0
    fi

    echo ""
    echo -e "${BLUE}▶${NC} Syncing files..."

    SYNCED_COUNT=0

    for idx in $SELECTED_INDICES; do
        idx=$((idx - 1))
        if [[ $idx -ge 0 && $idx -lt ${#SYNC_ITEMS[@]} ]]; then
            path="${SYNC_ITEMS[$idx]}"

            # Create directory if needed
            dir=$(dirname "$DOWNSTREAM_PATH/$path")
            mkdir -p "$dir"

            # Copy file
            cp "$UPSTREAM_PATH/$path" "$DOWNSTREAM_PATH/$path"
            echo -e "${GREEN}✓${NC} Synced: $path"
            ((SYNCED_COUNT++))
        fi
    done

    echo ""
    echo -e "${GREEN}✓${NC} Synced $SYNCED_COUNT file(s) from upstream"
    echo ""

    # Suggest commit
    echo -e "${BLUE}Suggested commit:${NC}"
    echo ""
    echo "  git add ."
    echo "  git commit -m \"chore: sync updates from upstream agent-kit\""
    echo ""
else
    echo -e "${YELLOW}DRY RUN complete. No changes made.${NC}"
    echo "Run without --dry-run to apply changes."
fi
