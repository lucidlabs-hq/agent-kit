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
    ".claude/settings.json"
    "frontend/components/ui"
    "frontend/lib/utils.ts"
    "frontend/lib/hooks"
    "scripts/promote.sh"
    "scripts/sync-upstream.sh"
    "CLAUDE.md"
    "AGENTS.md"
    "WORKFLOW.md"
)

# Zone marker for CLAUDE.md
ZONE_MARKER="<!-- UPSTREAM-SYNC-END -->"

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
            echo "Sync updates from upstream agent-kit to this downstream project."
            echo ""
            echo "Options:"
            echo "  --upstream PATH   Path to upstream agent-kit (default: ../../lucidlabs-agent-kit)"
            echo "  --dry-run         Preview changes without applying"
            echo "  --all             Sync all without selection"
            echo "  --help            Show this help message"
            echo ""
            echo "Features:"
            echo "  - Zone-aware CLAUDE.md sync (preserves content after UPSTREAM-SYNC-END marker)"
            echo "  - Auto-updates .upstream-sync.json tracking file"
            echo "  - Shows sync-diff summary report after completion"
            exit 0
            ;;
        *)
            echo ""
            echo -e "${RED}  [BLOCKED] Unknown option: $1${NC}"
            echo ""
            echo "  Why:  '$1' is not a recognized option."
            echo ""
            echo "  Fix:  Run with --help to see available options:"
            echo "          ./scripts/sync-upstream.sh --help"
            echo ""
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
    echo ""
    echo -e "${RED}  [BLOCKED] Upstream path not found: $UPSTREAM_PATH${NC}"
    echo ""
    echo "  Why:  The upstream agent-kit repository is not where expected."
    echo "        The default location is ../../lucidlabs-agent-kit"
    echo ""
    echo "  Fix:  Ensure your folder structure looks like this:"
    echo "          lucidlabs/"
    echo "          ├── lucidlabs-agent-kit/    <-- Upstream template"
    echo "          └── projects/"
    echo "              └── [this-project]/     <-- You are here"
    echo ""
    echo "        Or specify a custom path:"
    echo "          ./scripts/sync-upstream.sh --upstream /path/to/agent-kit"
    echo ""
    exit 1
fi

# Check if upstream has required files
if [[ ! -f "$UPSTREAM_PATH/CLAUDE.md" ]]; then
    echo ""
    echo -e "${RED}  [BLOCKED] Not a valid agent-kit repository: $UPSTREAM_PATH${NC}"
    echo ""
    echo "  Why:  The directory exists but has no CLAUDE.md file."
    echo "        This doesn't look like the agent-kit template."
    echo ""
    echo "  Fix:  Verify the path points to the correct repository:"
    echo "          ls $UPSTREAM_PATH/CLAUDE.md"
    echo ""
    exit 1
fi

DOWNSTREAM_PATH=$(pwd)
UPSTREAM_PATH=$(cd "$UPSTREAM_PATH" && pwd)

# Get upstream commit info
UPSTREAM_HEAD=$(cd "$UPSTREAM_PATH" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Get previous sync commit (if tracking file exists)
PREV_SYNC_COMMIT="none"
if [[ -f "$DOWNSTREAM_PATH/.upstream-sync.json" ]]; then
    PREV_SYNC_COMMIT=$(python3 -c "
import json
with open('$DOWNSTREAM_PATH/.upstream-sync.json') as f:
    data = json.load(f)
print(data.get('last_sync_commit', 'none'))
" 2>/dev/null || echo "none")
fi

echo -e "${BLUE}ℹ${NC} Downstream: ${BOLD}$DOWNSTREAM_PATH${NC}"
echo -e "${BLUE}ℹ${NC} Upstream:   ${BOLD}$UPSTREAM_PATH${NC}"
echo -e "${BLUE}ℹ${NC} Upstream HEAD: ${BOLD}$UPSTREAM_HEAD${NC}"
if [[ "$PREV_SYNC_COMMIT" != "none" ]]; then
    echo -e "${BLUE}ℹ${NC} Last sync:  ${BOLD}$PREV_SYNC_COMMIT${NC}"
fi
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}▶ DRY RUN MODE - No changes will be made${NC}"
    echo ""
fi

#-------------------------------------------------------------------------------
# Zone-aware CLAUDE.md sync function
#-------------------------------------------------------------------------------
sync_claude_md() {
    local upstream_file="$1"
    local downstream_file="$2"

    # Check if downstream has the zone marker
    if ! grep -q "$ZONE_MARKER" "$downstream_file" 2>/dev/null; then
        echo ""
        echo -e "${YELLOW}  [WARNING] CLAUDE.md has no zone marker: $ZONE_MARKER${NC}"
        echo ""
        echo "  Why:  The downstream CLAUDE.md is missing the zone marker."
        echo "        Without it, sync cannot distinguish upstream from project-specific content."
        echo ""
        echo "  Fix:  Add this line to CLAUDE.md where upstream content ends:"
        echo "          $ZONE_MARKER"
        echo ""
        echo "  Skipping CLAUDE.md sync to avoid overwriting project-specific content."
        return 1
    fi

    # Check if upstream has the zone marker
    if ! grep -q "$ZONE_MARKER" "$upstream_file" 2>/dev/null; then
        echo -e "${YELLOW}  [WARNING] Upstream CLAUDE.md has no zone marker. Copying full file.${NC}"
        cp "$upstream_file" "$downstream_file"
        return 0
    fi

    # Extract downstream content from the marker onward (including marker line)
    local downstream_tail
    downstream_tail=$(sed -n "/$ZONE_MARKER/,\$p" "$downstream_file")

    # Combine: upstream before marker + downstream from marker onward
    # The marker line is included in both, so we take upstream up to (but not including)
    # the marker, then append the downstream from the marker onward.
    local upstream_before_marker
    upstream_before_marker=$(sed -n "1,/$ZONE_MARKER/{/$ZONE_MARKER/!p;}" "$upstream_file")

    # Write combined file
    {
        printf '%s\n' "$upstream_before_marker"
        printf '%s\n' "$downstream_tail"
    } > "$downstream_file"

    return 0
}

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
            if [[ -f "$UPSTREAM_FILE" ]]; then
                SYNC_ITEMS+=("$path")
                SYNC_TYPES+=("NEW")
                echo -e "  ${GREEN}[$INDEX]${NC} $path ${GREEN}(NEW)${NC}"
                ((INDEX++))
            elif [[ -d "$UPSTREAM_FILE" ]]; then
                while IFS= read -r -d '' file; do
                    rel_path="${file#$UPSTREAM_PATH/}"
                    SYNC_ITEMS+=("$rel_path")
                    SYNC_TYPES+=("NEW")
                    echo -e "  ${GREEN}[$INDEX]${NC} $rel_path ${GREEN}(NEW)${NC}"
                    ((INDEX++))
                done < <(find "$UPSTREAM_FILE" -type f -print0 2>/dev/null)
            fi
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
        elif [[ "$path" == "CLAUDE.md" ]]; then
            echo -e "${BLUE}Zone-aware sync: only content before $ZONE_MARKER will be updated${NC}"
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
    NEW_COUNT=0
    UPDATED_COUNT=0
    declare -a SYNCED_FILES_NEW
    declare -a SYNCED_FILES_UPDATED

    for idx in $SELECTED_INDICES; do
        idx=$((idx - 1))
        if [[ $idx -ge 0 && $idx -lt ${#SYNC_ITEMS[@]} ]]; then
            path="${SYNC_ITEMS[$idx]}"
            type="${SYNC_TYPES[$idx]}"

            # Create directory if needed
            dir=$(dirname "$DOWNSTREAM_PATH/$path")
            mkdir -p "$dir"

            # Special handling for CLAUDE.md (zone-aware sync)
            if [[ "$path" == "CLAUDE.md" ]]; then
                if sync_claude_md "$UPSTREAM_PATH/$path" "$DOWNSTREAM_PATH/$path"; then
                    echo -e "${GREEN}✓${NC} Synced: $path (zone-aware)"
                    ((SYNCED_COUNT++))
                    if [[ "$type" == "NEW" ]]; then
                        SYNCED_FILES_NEW+=("$path")
                        ((NEW_COUNT++))
                    else
                        SYNCED_FILES_UPDATED+=("$path")
                        ((UPDATED_COUNT++))
                    fi
                else
                    echo -e "${YELLOW}⚠${NC} Skipped: $path (no zone marker)"
                fi
            else
                # Regular file copy
                cp "$UPSTREAM_PATH/$path" "$DOWNSTREAM_PATH/$path"
                echo -e "${GREEN}✓${NC} Synced: $path"
                ((SYNCED_COUNT++))
                if [[ "$type" == "NEW" ]]; then
                    SYNCED_FILES_NEW+=("$path")
                    ((NEW_COUNT++))
                else
                    SYNCED_FILES_UPDATED+=("$path")
                    ((UPDATED_COUNT++))
                fi
            fi
        fi
    done

    echo ""

    # ─────────────────────────────────────────────────────────────────────
    # Auto-update .upstream-sync.json
    # ─────────────────────────────────────────────────────────────────────
    if [[ -f "$DOWNSTREAM_PATH/.upstream-sync.json" ]]; then
        python3 -c "
import json
from datetime import date

with open('$DOWNSTREAM_PATH/.upstream-sync.json') as f:
    data = json.load(f)

data['last_sync_commit'] = '$UPSTREAM_HEAD'
data['last_sync_date'] = str(date.today())

with open('$DOWNSTREAM_PATH/.upstream-sync.json', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" 2>/dev/null && echo -e "${GREEN}✓${NC} Updated .upstream-sync.json (${PREV_SYNC_COMMIT} → ${UPSTREAM_HEAD})"
    fi

    # ─────────────────────────────────────────────────────────────────────
    # Sync-Diff Summary Report
    # ─────────────────────────────────────────────────────────────────────
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                      SYNC SUMMARY                                 ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Synced:   ${BOLD}$SYNCED_COUNT${NC} files"
    echo -e "  New:      ${GREEN}$NEW_COUNT${NC}"
    echo -e "  Updated:  ${YELLOW}$UPDATED_COUNT${NC}"
    echo ""

    if [[ ${#SYNCED_FILES_NEW[@]} -gt 0 ]]; then
        echo -e "  ${GREEN}New files:${NC}"
        for f in "${SYNCED_FILES_NEW[@]}"; do
            echo -e "    + $f"
        done
        echo ""
    fi

    if [[ ${#SYNCED_FILES_UPDATED[@]} -gt 0 ]]; then
        echo -e "  ${YELLOW}Updated files:${NC}"
        for f in "${SYNCED_FILES_UPDATED[@]}"; do
            echo -e "    ~ $f"
        done
        echo ""
    fi

    echo -e "  Upstream: ${BOLD}${PREV_SYNC_COMMIT}${NC} → ${BOLD}${UPSTREAM_HEAD}${NC}"
    echo ""
    echo -e "${BLUE}Suggested commit:${NC}"
    echo ""
    echo "  git add ."
    echo "  git commit -m \"chore: sync upstream agent-kit ($UPSTREAM_HEAD)\""
    echo ""
else
    echo -e "${YELLOW}DRY RUN complete. No changes made.${NC}"
    echo "Run without --dry-run to apply changes."
fi
