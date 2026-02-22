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
DIM='\033[2m'

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
    "pattern-registry.json"
)

# Zone marker for CLAUDE.md
ZONE_MARKER="<!-- UPSTREAM-SYNC-END -->"

# Key dependencies to track across projects
TRACKED_DEPS=("next" "react" "react-dom" "tailwindcss" "convex" "zod")

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

#-------------------------------------------------------------------------------
# Dependency version check function
#-------------------------------------------------------------------------------
get_dep_version() {
    local pkg_file="$1"
    local dep_name="$2"
    python3 -c "
import json
with open('$pkg_file') as f:
    d = json.load(f)
deps = d.get('dependencies', {})
dev = d.get('devDependencies', {})
v = deps.get('$dep_name', dev.get('$dep_name', ''))
print(v)
" 2>/dev/null || echo ""
}

strip_version_prefix() {
    echo "$1" | sed 's/^[\^~]//'
}

check_dependency_versions() {
    local upstream_pkg="$UPSTREAM_PATH/frontend/package.json"
    local downstream_pkg="$DOWNSTREAM_PATH/frontend/package.json"

    if [[ ! -f "$upstream_pkg" ]] || [[ ! -f "$downstream_pkg" ]]; then
        return 0
    fi

    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  DEPENDENCY VERSION CHECK                         ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    local has_diff=false
    local -a diff_deps=()
    local -a diff_upstream=()
    local -a diff_downstream=()

    for dep in "${TRACKED_DEPS[@]}"; do
        local up_ver
        up_ver=$(get_dep_version "$upstream_pkg" "$dep")
        local down_ver
        down_ver=$(get_dep_version "$downstream_pkg" "$dep")

        # Skip if neither has this dependency
        [[ -z "$up_ver" && -z "$down_ver" ]] && continue

        local up_clean
        up_clean=$(strip_version_prefix "$up_ver")
        local down_clean
        down_clean=$(strip_version_prefix "$down_ver")

        if [[ "$up_clean" != "$down_clean" && -n "$up_ver" && -n "$down_ver" ]]; then
            has_diff=true
            diff_deps+=("$dep")
            diff_upstream+=("$up_ver")
            diff_downstream+=("$down_ver")
        fi
    done

    if [[ "$has_diff" == false ]]; then
        echo -e "  ${GREEN}✓${NC} All tracked dependencies are in sync."
        echo ""
        return 0
    fi

    # Load existing version decisions
    local sync_file="$DOWNSTREAM_PATH/.upstream-sync.json"
    local decisions_json="{}"
    if [[ -f "$sync_file" ]]; then
        decisions_json=$(python3 -c "
import json
with open('$sync_file') as f:
    d = json.load(f)
print(json.dumps(d.get('version_decisions', {})))
" 2>/dev/null || echo "{}")
    fi

    echo -e "  ${YELLOW}Version differences found:${NC}"
    echo ""
    printf "  %-20s %-16s %-16s %s\n" "DEPENDENCY" "UPSTREAM" "DOWNSTREAM" "STATUS"
    printf "  %-20s %-16s %-16s %s\n" "──────────" "────────" "──────────" "──────"

    for i in "${!diff_deps[@]}"; do
        local dep="${diff_deps[$i]}"
        local up="${diff_upstream[$i]}"
        local down="${diff_downstream[$i]}"

        # Check if there's a previous decision to skip
        local prev_decision
        prev_decision=$(python3 -c "
import json
d = json.loads('$decisions_json')
entry = d.get('$dep', {})
if entry.get('skipped_version') == '$up':
    print(entry.get('reason', 'no reason given'))
else:
    print('')
" 2>/dev/null || echo "")

        local status="${YELLOW}UPDATE AVAILABLE${NC}"
        if [[ -n "$prev_decision" ]]; then
            status="${BLUE}SKIPPED: $prev_decision${NC}"
        fi

        printf "  %-20s %-16s %-16s " "$dep" "$up" "$down"
        echo -e "$status"
    done

    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${YELLOW}DRY RUN - No dependency changes will be made${NC}"
        return 0
    fi

    # Ask about each dependency that hasn't been previously skipped
    local updated_count=0
    local skipped_count=0
    local new_decisions=""

    for i in "${!diff_deps[@]}"; do
        local dep="${diff_deps[$i]}"
        local up="${diff_upstream[$i]}"
        local down="${diff_downstream[$i]}"

        # Check previous decision
        local prev_decision
        prev_decision=$(python3 -c "
import json
d = json.loads('$(echo "$decisions_json" | sed "s/'/\\\\'/g")')
entry = d.get('$dep', {})
if entry.get('skipped_version') == '$up':
    print('skip')
else:
    print('')
" 2>/dev/null || echo "")

        if [[ "$prev_decision" == "skip" ]]; then
            continue
        fi

        echo -e "  ${BOLD}$dep${NC}: $down → $up"
        echo -n "  Update? [y/N/s(kip with reason)] "
        read -r answer

        case "$answer" in
            y|Y)
                # Update the version in downstream package.json
                python3 -c "
import json
with open('$downstream_pkg') as f:
    d = json.load(f)
if '$dep' in d.get('dependencies', {}):
    d['dependencies']['$dep'] = '$up'
elif '$dep' in d.get('devDependencies', {}):
    d['devDependencies']['$dep'] = '$up'
with open('$downstream_pkg', 'w') as f:
    json.dump(d, f, indent=2)
    f.write('\n')
" 2>/dev/null
                echo -e "  ${GREEN}✓${NC} Updated $dep to $up"
                ((updated_count++))
                ;;
            s|S)
                echo -n "  Reason for skipping: "
                read -r reason
                [[ -z "$reason" ]] && reason="no reason given"
                new_decisions="$new_decisions|$dep|$up|$reason"
                echo -e "  ${BLUE}⏭${NC} Skipped $dep (reason recorded)"
                ((skipped_count++))
                ;;
            *)
                echo -e "  ${YELLOW}─${NC} Skipped $dep (no record)"
                ;;
        esac
    done

    # Save skip decisions to .upstream-sync.json
    if [[ -n "$new_decisions" && -f "$sync_file" ]]; then
        python3 -c "
import json

with open('$sync_file') as f:
    data = json.load(f)

decisions = data.get('version_decisions', {})

entries = '''$new_decisions'''.strip().split('|')
# entries format: empty|dep|ver|reason|dep|ver|reason...
i = 1
while i < len(entries) - 2:
    dep = entries[i]
    ver = entries[i+1]
    reason = entries[i+2]
    decisions[dep] = {
        'skipped_version': ver,
        'reason': reason,
        'current_downstream': '$(get_dep_version "$downstream_pkg" "placeholder")'
    }
    i += 3

data['version_decisions'] = decisions

with open('$sync_file', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" 2>/dev/null
    fi

    echo ""
    if [[ $updated_count -gt 0 ]]; then
        echo -e "  ${GREEN}Updated $updated_count dependency/dependencies.${NC}"
        echo -e "  ${YELLOW}Run 'pnpm install' in frontend/ to apply changes.${NC}"
    fi
    if [[ $skipped_count -gt 0 ]]; then
        echo -e "  ${BLUE}Skipped $skipped_count dependency/dependencies (decisions saved to .upstream-sync.json).${NC}"
    fi
    echo ""
}

# Load pattern registry for enriched display (if available)
REGISTRY_FILE="$UPSTREAM_PATH/pattern-registry.json"
REGISTRY_LOOKUP=""
if [[ -f "$REGISTRY_FILE" ]]; then
    REGISTRY_LOOKUP=$(python3 -c "
import json
with open('$REGISTRY_FILE') as f:
    reg = json.load(f)
for p in reg.get('patterns', []):
    # TSV: path \t name \t description (first 60 chars)
    desc = p.get('description', '')[:60]
    print(f\"{p['path']}\t{p['name']}\t{desc}\")
" 2>/dev/null || echo "")
fi

get_pattern_info() {
    local path="$1"
    if [[ -n "$REGISTRY_LOOKUP" ]]; then
        echo "$REGISTRY_LOOKUP" | grep "^${path}	" 2>/dev/null | head -1 || echo ""
    fi
}

# Find syncable changes
echo -e "${BLUE}▶${NC} Scanning for syncable updates..."
echo ""

declare -a SYNC_ITEMS
declare -a SYNC_TYPES
INDEX=1

print_sync_entry() {
    local idx="$1"
    local rel_path="$2"
    local status="$3"
    local color="${GREEN}"
    [[ "$status" == "MODIFIED" ]] && color="${YELLOW}"

    local info
    info=$(get_pattern_info "$rel_path")
    local suffix=""
    if [[ -n "$info" ]]; then
        local desc
        desc=$(echo "$info" | cut -f3)
        [[ -n "$desc" ]] && suffix=" ${DIM}— ${desc}${NC}"
    fi

    echo -e "  ${color}[$idx]${NC} $rel_path ${color}($status)${NC}${suffix}"
}

for path in "${SYNCABLE_PATHS[@]}"; do
    UPSTREAM_FILE="$UPSTREAM_PATH/$path"
    DOWNSTREAM_FILE="$DOWNSTREAM_PATH/$path"

    if [[ -e "$UPSTREAM_FILE" ]]; then
        if [[ ! -e "$DOWNSTREAM_FILE" ]]; then
            # New file/directory in upstream
            if [[ -f "$UPSTREAM_FILE" ]]; then
                SYNC_ITEMS+=("$path")
                SYNC_TYPES+=("NEW")
                print_sync_entry "$INDEX" "$path" "NEW"
                ((INDEX++))
            elif [[ -d "$UPSTREAM_FILE" ]]; then
                while IFS= read -r -d '' file; do
                    rel_path="${file#$UPSTREAM_PATH/}"
                    SYNC_ITEMS+=("$rel_path")
                    SYNC_TYPES+=("NEW")
                    print_sync_entry "$INDEX" "$rel_path" "NEW"
                    ((INDEX++))
                done < <(find "$UPSTREAM_FILE" -type f -not -name ".DS_Store" -not -name "Thumbs.db" -not -name "*.swp" -not -name "*~" -print0 2>/dev/null)
            fi
        elif [[ -f "$UPSTREAM_FILE" ]]; then
            # File exists in both - check if different
            if ! diff -q "$UPSTREAM_FILE" "$DOWNSTREAM_FILE" > /dev/null 2>&1; then
                SYNC_ITEMS+=("$path")
                SYNC_TYPES+=("MODIFIED")
                print_sync_entry "$INDEX" "$path" "MODIFIED"
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
                    print_sync_entry "$INDEX" "$rel_path" "NEW"
                    ((INDEX++))
                elif ! diff -q "$file" "$downstream_file" > /dev/null 2>&1; then
                    SYNC_ITEMS+=("$rel_path")
                    SYNC_TYPES+=("MODIFIED")
                    print_sync_entry "$INDEX" "$rel_path" "MODIFIED"
                    ((INDEX++))
                fi
            done < <(find "$UPSTREAM_FILE" -type f -not -name ".DS_Store" -not -name "Thumbs.db" -not -name "*.swp" -not -name "*~" -print0 2>/dev/null)
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
        # Build list of synced file paths for synced_files population
        SYNCED_PATHS_LIST=""
        for f in "${SYNCED_FILES_NEW[@]}" "${SYNCED_FILES_UPDATED[@]}"; do
            SYNCED_PATHS_LIST="${SYNCED_PATHS_LIST}${f}"$'\n'
        done

        python3 -c "
import json
from datetime import date

with open('$DOWNSTREAM_PATH/.upstream-sync.json') as f:
    data = json.load(f)

data['last_sync_commit'] = '$UPSTREAM_HEAD'
data['last_sync_date'] = str(date.today())

# Populate synced_files for per-file tracking
synced = data.get('synced_files', {})
paths_text = '''$SYNCED_PATHS_LIST'''.strip()
if paths_text:
    for path in paths_text.split('\n'):
        path = path.strip()
        if path:
            synced[path] = '$UPSTREAM_HEAD'
data['synced_files'] = synced

with open('$DOWNSTREAM_PATH/.upstream-sync.json', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" 2>/dev/null && echo -e "${GREEN}✓${NC} Updated .upstream-sync.json (${PREV_SYNC_COMMIT} → ${UPSTREAM_HEAD}, ${SYNCED_COUNT} files tracked)"
    fi

    # ─────────────────────────────────────────────────────────────────────
    # Dependency Version Check
    # ─────────────────────────────────────────────────────────────────────
    check_dependency_versions

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

    # ─────────────────────────────────────────────────────────────────────
    # Pattern Coverage Summary (if registry available)
    # ─────────────────────────────────────────────────────────────────────
    if [[ -f "$REGISTRY_FILE" && -f "$DOWNSTREAM_PATH/.upstream-sync.json" ]]; then
        python3 -c "
import json
import sys

with open('$REGISTRY_FILE') as f:
    reg = json.load(f)
with open('$DOWNSTREAM_PATH/.upstream-sync.json') as f:
    sync = json.load(f)

synced = sync.get('synced_files', {})
total = reg.get('pattern_count', 0)
if total == 0:
    sys.exit(0)

up = sum(1 for p in reg['patterns'] if synced.get(p['path']) == p['version'])
stale = sum(1 for p in reg['patterns'] if p['path'] in synced and synced[p['path']] != p['version'])
missing = total - up - stale

print(f'  \033[2mPattern coverage: \033[0;32m{up} synced\033[0m\033[2m / \033[1;33m{stale} stale\033[0m\033[2m / \033[0;31m{missing} missing\033[0m\033[2m of {total} total\033[0m')
if stale > 0 or missing > 20:
    proj = '$DOWNSTREAM_PATH'.rstrip('/').split('/')[-1]
    print(f'  \033[2mRun: ./scripts/pattern-list.sh --project {proj}  for details\033[0m')
" 2>/dev/null || true
        echo ""
    fi

    echo -e "${BLUE}Suggested commit:${NC}"
    echo ""
    echo "  git add ."
    echo "  git commit -m \"chore: sync upstream agent-kit ($UPSTREAM_HEAD)\""
    echo ""
else
    echo -e "${YELLOW}DRY RUN complete. No changes made.${NC}"
    echo "Run without --dry-run to apply changes."
fi
