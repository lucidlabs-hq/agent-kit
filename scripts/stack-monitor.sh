#!/usr/bin/env bash
#===============================================================================
# Stack Monitor - Check for new versions of key dependencies
#
# Called by /prime at session start. Checks npm registry for updates
# to tracked dependencies and shows actionable report.
#
# Usage:
#   ./scripts/stack-monitor.sh [--pkg-dir PATH] [--json]
#
# Options:
#   --pkg-dir PATH   Directory containing package.json (default: frontend/)
#   --json           Output as JSON instead of formatted table
#   --quiet          Only show if updates are available
#
# Decisions are stored in .stack-monitor.json per project.
#===============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Configuration
PKG_DIR="frontend"
JSON_OUTPUT=false
QUIET=false
MONITOR_FILE=".stack-monitor.json"

# Key dependencies to track (core architecture stack)
TRACKED_DEPS=(
    "next"
    "react"
    "react-dom"
    "tailwindcss"
    "convex"
    "zod"
    "better-auth"
    "mastra"
    "@hono/node-server"
    "lucide-react"
)

#-------------------------------------------------------------------------------
# Parse arguments
#-------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case $1 in
        --pkg-dir)  PKG_DIR="$2"; shift 2 ;;
        --json)     JSON_OUTPUT=true; shift ;;
        --quiet)    QUIET=true; shift ;;
        --help|-h)
            echo "Usage: ./scripts/stack-monitor.sh [--pkg-dir PATH] [--json] [--quiet]"
            exit 0
            ;;
        *) shift ;;
    esac
done

#-------------------------------------------------------------------------------
# Helpers
#-------------------------------------------------------------------------------

get_installed_version() {
    local dep="$1"
    local pkg_file="$PKG_DIR/package.json"
    [[ ! -f "$pkg_file" ]] && echo "" && return

    python3 -c "
import json
with open('$pkg_file') as f:
    d = json.load(f)
deps = d.get('dependencies', {})
dev = d.get('devDependencies', {})
v = deps.get('$dep', dev.get('$dep', ''))
# Strip ^ ~ >= etc.
import re
print(re.sub(r'^[\^~>=<]+', '', v))
" 2>/dev/null || echo ""
}

get_latest_version() {
    local dep="$1"
    # URL-encode @ for scoped packages
    local encoded
    encoded=$(echo "$dep" | sed 's/@/%40/g; s|/|%2F|g')
    curl -s --max-time 5 "https://registry.npmjs.org/$encoded/latest" 2>/dev/null | \
        python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('version',''))" 2>/dev/null || echo ""
}

compare_versions() {
    local current="$1"
    local latest="$2"

    [[ -z "$current" || -z "$latest" ]] && echo "unknown" && return
    [[ "$current" == "$latest" ]] && echo "current" && return

    local cur_major cur_minor cur_patch
    local lat_major lat_minor lat_patch

    IFS='.' read -r cur_major cur_minor cur_patch <<< "$current"
    IFS='.' read -r lat_major lat_minor lat_patch <<< "$latest"

    # Strip any pre-release suffixes for comparison
    cur_major="${cur_major%%[-+]*}"
    lat_major="${lat_major%%[-+]*}"

    if [[ "$lat_major" -gt "$cur_major" ]] 2>/dev/null; then
        echo "major"
    elif [[ "$lat_minor" -gt "$cur_minor" ]] 2>/dev/null; then
        echo "minor"
    else
        echo "patch"
    fi
}

get_decision() {
    local dep="$1"
    local version="$2"

    [[ ! -f "$MONITOR_FILE" ]] && echo "" && return

    python3 -c "
import json
with open('$MONITOR_FILE') as f:
    d = json.load(f)
decisions = d.get('decisions', {})
entry = decisions.get('$dep', {})
if entry.get('parked_version') == '$version':
    action = entry.get('action', 'parked')
    reason = entry.get('reason', '')
    print(f'{action}|{reason}')
else:
    print('')
" 2>/dev/null || echo ""
}

save_decision() {
    local dep="$1"
    local version="$2"
    local action="$3"
    local reason="$4"

    # Initialize file if not exists
    if [[ ! -f "$MONITOR_FILE" ]]; then
        echo '{"decisions": {}, "last_check": ""}' > "$MONITOR_FILE"
    fi

    python3 -c "
import json
from datetime import datetime

with open('$MONITOR_FILE') as f:
    d = json.load(f)

decisions = d.get('decisions', {})
decisions['$dep'] = {
    'parked_version': '$version',
    'action': '$action',
    'reason': '''$reason''',
    'decided_at': datetime.now().isoformat()
}
d['decisions'] = decisions
d['last_check'] = datetime.now().isoformat()

with open('$MONITOR_FILE', 'w') as f:
    json.dump(d, f, indent=2)
    f.write('\n')
" 2>/dev/null
}

#-------------------------------------------------------------------------------
# Main check
#-------------------------------------------------------------------------------

# Verify package.json exists
if [[ ! -f "$PKG_DIR/package.json" ]]; then
    [[ "$QUIET" == false ]] && echo -e "${DIM}  No $PKG_DIR/package.json found, skipping stack monitor.${NC}"
    exit 0
fi

# Check if we should skip (checked within last 24h)
if [[ -f "$MONITOR_FILE" ]]; then
    LAST_CHECK=$(python3 -c "
import json
from datetime import datetime, timedelta
with open('$MONITOR_FILE') as f:
    d = json.load(f)
lc = d.get('last_check', '')
if lc:
    last = datetime.fromisoformat(lc)
    if datetime.now() - last < timedelta(hours=24):
        print('skip')
    else:
        print('check')
else:
    print('check')
" 2>/dev/null || echo "check")

    if [[ "$LAST_CHECK" == "skip" && "$QUIET" == true ]]; then
        exit 0
    fi
fi

# Collect version data
declare -a UPDATE_DEPS=()
declare -a UPDATE_CURRENT=()
declare -a UPDATE_LATEST=()
declare -a UPDATE_TYPE=()
declare -a UPDATE_DECISION=()

for dep in "${TRACKED_DEPS[@]}"; do
    installed=$(get_installed_version "$dep")

    # Skip if not installed in this project
    [[ -z "$installed" ]] && continue

    latest=$(get_latest_version "$dep")
    [[ -z "$latest" ]] && continue

    change_type=$(compare_versions "$installed" "$latest")

    if [[ "$change_type" != "current" && "$change_type" != "unknown" ]]; then
        decision=$(get_decision "$dep" "$latest")

        UPDATE_DEPS+=("$dep")
        UPDATE_CURRENT+=("$installed")
        UPDATE_LATEST+=("$latest")
        UPDATE_TYPE+=("$change_type")
        UPDATE_DECISION+=("$decision")
    fi
done

# Update last_check timestamp
if [[ -f "$MONITOR_FILE" ]]; then
    python3 -c "
import json
from datetime import datetime
with open('$MONITOR_FILE') as f:
    d = json.load(f)
d['last_check'] = datetime.now().isoformat()
with open('$MONITOR_FILE', 'w') as f:
    json.dump(d, f, indent=2)
    f.write('\n')
" 2>/dev/null
elif [[ ${#UPDATE_DEPS[@]} -gt 0 ]]; then
    echo "{\"decisions\": {}, \"last_check\": \"$(date -Iseconds)\"}" > "$MONITOR_FILE"
fi

# Output
if [[ ${#UPDATE_DEPS[@]} -eq 0 ]]; then
    if [[ "$QUIET" == false ]]; then
        echo -e "  ${GREEN}✓${NC} All tracked dependencies are up to date."
    fi
    exit 0
fi

# Count by type
MAJOR_COUNT=0
MINOR_COUNT=0
PATCH_COUNT=0
NEW_COUNT=0

for i in "${!UPDATE_TYPE[@]}"; do
    case "${UPDATE_TYPE[$i]}" in
        major) ((MAJOR_COUNT++)) ;;
        minor) ((MINOR_COUNT++)) ;;
        patch) ((PATCH_COUNT++)) ;;
    esac
    [[ -z "${UPDATE_DECISION[$i]}" ]] && ((NEW_COUNT++))
done

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                     STACK VERSION MONITOR                         ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ $MAJOR_COUNT -gt 0 ]]; then
    echo -e "  ${RED}${BOLD}$MAJOR_COUNT major${NC}, ${YELLOW}$MINOR_COUNT minor${NC}, ${DIM}$PATCH_COUNT patch${NC} update(s) available"
else
    echo -e "  ${YELLOW}$MINOR_COUNT minor${NC}, ${DIM}$PATCH_COUNT patch${NC} update(s) available"
fi

if [[ $NEW_COUNT -gt 0 ]]; then
    echo -e "  ${GREEN}$NEW_COUNT new${NC} (not yet reviewed)"
fi
echo ""

printf "  %-24s %-14s %-14s %-8s %s\n" "DEPENDENCY" "INSTALLED" "LATEST" "TYPE" "STATUS"
printf "  %-24s %-14s %-14s %-8s %s\n" "────────────────────────" "──────────────" "──────────────" "────────" "──────"

for i in "${!UPDATE_DEPS[@]}"; do
    dep="${UPDATE_DEPS[$i]}"
    current="${UPDATE_CURRENT[$i]}"
    latest="${UPDATE_LATEST[$i]}"
    type="${UPDATE_TYPE[$i]}"
    decision="${UPDATE_DECISION[$i]}"

    # Color based on type
    case "$type" in
        major) type_color="${RED}MAJOR${NC}" ;;
        minor) type_color="${YELLOW}minor${NC}" ;;
        patch) type_color="${DIM}patch${NC}" ;;
    esac

    # Status
    if [[ -z "$decision" ]]; then
        status="${GREEN}NEW${NC}"
    else
        action="${decision%%|*}"
        reason="${decision#*|}"
        if [[ "$action" == "parked" ]]; then
            status="${BLUE}PARKED${NC}"
        elif [[ "$action" == "skipped" ]]; then
            status="${DIM}SKIPPED: ${reason}${NC}"
        fi
    fi

    printf "  %-24s %-14s %-14s " "$dep" "$current" "$latest"
    echo -ne "$type_color"
    printf "   "
    echo -e "$status"
done

echo ""

# Interactive mode (only if running in terminal and not --json/--quiet)
if [[ "$JSON_OUTPUT" == false && "$QUIET" == false && -t 0 ]]; then
    # Filter for new (un-reviewed) updates only
    has_new=false
    for i in "${!UPDATE_DEPS[@]}"; do
        [[ -z "${UPDATE_DECISION[$i]}" ]] && has_new=true && break
    done

    if [[ "$has_new" == true ]]; then
        echo -e "  ${BOLD}Review new updates?${NC}"
        echo -n "  [y/N] "
        read -r review_answer

        if [[ "$review_answer" == "y" || "$review_answer" == "Y" ]]; then
            echo ""
            for i in "${!UPDATE_DEPS[@]}"; do
                [[ -n "${UPDATE_DECISION[$i]}" ]] && continue

                dep="${UPDATE_DEPS[$i]}"
                current="${UPDATE_CURRENT[$i]}"
                latest="${UPDATE_LATEST[$i]}"
                type="${UPDATE_TYPE[$i]}"

                echo -e "  ${BOLD}$dep${NC} $current → $latest (${type})"

                if [[ "$type" == "major" ]]; then
                    echo -e "  ${RED}Major update — check release notes before updating.${NC}"
                    echo -e "  ${DIM}https://github.com/$(echo "$dep" | tr '@' '' | tr '/' '-')/releases${NC}"
                fi

                echo -n "  Action? [u]pdate / [p]ark / [s]kip with reason / [enter] skip: "
                read -r action

                case "$action" in
                    u|U)
                        echo -e "  ${GREEN}→ Marked for update.${NC} Run 'pnpm update $dep' in $PKG_DIR/"
                        save_decision "$dep" "$latest" "update" ""
                        ;;
                    p|P)
                        echo -e "  ${BLUE}→ Parked. Will remind you next session.${NC}"
                        save_decision "$dep" "$latest" "parked" ""
                        ;;
                    s|S)
                        echo -n "  Reason: "
                        read -r skip_reason
                        [[ -z "$skip_reason" ]] && skip_reason="no reason given"
                        save_decision "$dep" "$latest" "skipped" "$skip_reason"
                        echo -e "  ${DIM}→ Skipped (reason saved).${NC}"
                        ;;
                    *)
                        echo -e "  ${DIM}→ Skipped for now (no record).${NC}"
                        ;;
                esac
                echo ""
            done
        fi
    fi
fi

echo -e "  ${DIM}Decisions saved to $MONITOR_FILE${NC}"
echo -e "  ${DIM}Next check in ~24h (or run scripts/stack-monitor.sh manually)${NC}"
echo ""
