#!/usr/bin/env bash
#===============================================================================
# Cross-Project Drift Detection
#
# Detect how far behind each downstream project is relative to upstream HEAD.
# Can be run from the upstream agent-kit OR from any downstream project.
#
# Usage:
#   ./scripts/drift-detect.sh [options]
#
# Options:
#   --project NAME        Report for a single project only
#   --projects-dir PATH   Path to projects directory (default: auto-detect)
#   --json                Output machine-readable JSON
#   --quiet               Summary only (for /prime integration)
#   --help, -h            Show this help
#
# Examples:
#   ./scripts/drift-detect.sh                       # Full drift report
#   ./scripts/drift-detect.sh --project neola        # Single project
#   ./scripts/drift-detect.sh --json                 # Machine-readable
#   ./scripts/drift-detect.sh --quiet                # For /prime embed
#===============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Options
SINGLE_PROJECT=""
PROJECTS_DIR=""
JSON_OUTPUT=false
QUIET=false

#-------------------------------------------------------------------------------
# Argument Parsing
#-------------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project)
            SINGLE_PROJECT="$2"
            shift 2
            ;;
        --projects-dir)
            PROJECTS_DIR="$2"
            shift 2
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --quiet)
            QUIET=true
            shift
            ;;
        --help|-h)
            head -25 "$0" | tail -20
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

#-------------------------------------------------------------------------------
# Context Detection
#-------------------------------------------------------------------------------

detect_context() {
    # Check if we're in a downstream project or the upstream agent-kit
    if [[ -f "$SCRIPT_DIR/../.upstream-sync.json" ]] && [[ ! -f "$SCRIPT_DIR/../scripts/create-agent-project.sh" ]]; then
        # We're in a downstream project
        CONTEXT="downstream"
        DOWNSTREAM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
        
        # Try to find upstream
        if [[ -z "$UPSTREAM_PATH" ]]; then
            local candidate="$DOWNSTREAM_ROOT/../../lucidlabs-agent-kit"
            if [[ -d "$candidate" ]] && [[ -f "$candidate/CLAUDE.md" ]]; then
                UPSTREAM_PATH="$(cd "$candidate" && pwd)"
            else
                echo -e "${RED}ERROR:${NC} Cannot find upstream agent-kit at $candidate"
                echo "  Use --upstream PATH to specify"
                exit 1
            fi
        fi
        
        if [[ -z "$PROJECTS_DIR" ]]; then
            PROJECTS_DIR="$(cd "$DOWNSTREAM_ROOT/.." && pwd)"
        fi
    else
        # We're in the upstream agent-kit
        CONTEXT="upstream"
        UPSTREAM_PATH="$(cd "$SCRIPT_DIR/.." && pwd)"
        
        if [[ -z "$PROJECTS_DIR" ]]; then
            PROJECTS_DIR="$(cd "$UPSTREAM_PATH/../projects" 2>/dev/null && pwd)" || {
                echo -e "${RED}ERROR:${NC} Cannot find projects directory at $UPSTREAM_PATH/../projects"
                echo "  Use --projects-dir PATH to specify"
                exit 1
            }
        fi
    fi
}

UPSTREAM_PATH=""
detect_context

#-------------------------------------------------------------------------------
# Upstream State
#-------------------------------------------------------------------------------

UPSTREAM_HEAD=$(cd "$UPSTREAM_PATH" && git rev-parse --short HEAD 2>/dev/null)
UPSTREAM_HEAD_FULL=$(cd "$UPSTREAM_PATH" && git rev-parse HEAD 2>/dev/null)
UPSTREAM_HEAD_DATE=$(cd "$UPSTREAM_PATH" && git log -1 --format=%as HEAD 2>/dev/null)
UPSTREAM_BRANCH=$(cd "$UPSTREAM_PATH" && git rev-parse --abbrev-ref HEAD 2>/dev/null)

#-------------------------------------------------------------------------------
# Per-Project Drift Calculation
#-------------------------------------------------------------------------------

# Result arrays (parallel indexed)
declare -a P_NAMES=()
declare -a P_STATUS=()
declare -a P_SYNC_COMMIT=()
declare -a P_SYNC_DATE=()
declare -a P_COMMITS_BEHIND=()
declare -a P_DAYS_BEHIND=()
declare -a P_FILES_CHANGED=()
declare -a P_SCORES=()
declare -a P_PROMOTE_COUNT=()

calculate_drift() {
    local project_path="$1"
    local project_name
    project_name=$(basename "$project_path")
    
    P_NAMES+=("$project_name")
    
    # Check for .upstream-sync.json
    local sync_file="$project_path/.upstream-sync.json"
    if [[ ! -f "$sync_file" ]]; then
        P_STATUS+=("BROKEN")
        P_SYNC_COMMIT+=("---")
        P_SYNC_DATE+=("---")
        P_COMMITS_BEHIND+=("---")
        P_DAYS_BEHIND+=("---")
        P_FILES_CHANGED+=("---")
        calculate_score "$project_path"
        count_promote_queue "$project_path"
        return
    fi
    
    # Read last sync commit
    local last_sync_commit
    last_sync_commit=$(python3 -c "
import json, sys
try:
    with open('$sync_file') as f:
        data = json.load(f)
    print(data.get('last_sync_commit', 'none'))
except:
    print('none')
" 2>/dev/null)
    
    local last_sync_date
    last_sync_date=$(python3 -c "
import json, sys
try:
    with open('$sync_file') as f:
        data = json.load(f)
    print(data.get('last_sync_date', 'unknown'))
except:
    print('unknown')
" 2>/dev/null)
    
    P_SYNC_COMMIT+=("${last_sync_commit:0:7}")
    P_SYNC_DATE+=("$last_sync_date")
    
    if [[ "$last_sync_commit" == "none" ]] || [[ "$last_sync_commit" == "" ]]; then
        P_STATUS+=("BROKEN")
        P_COMMITS_BEHIND+=("---")
        P_DAYS_BEHIND+=("---")
        P_FILES_CHANGED+=("---")
        calculate_score "$project_path"
        count_promote_queue "$project_path"
        return
    fi
    
    # Calculate commits behind
    local commits_behind
    commits_behind=$(cd "$UPSTREAM_PATH" && git rev-list --count "${last_sync_commit}..HEAD" 2>/dev/null || echo "?")
    P_COMMITS_BEHIND+=("$commits_behind")
    
    # Calculate days behind
    if [[ "$last_sync_date" != "unknown" ]] && [[ "$last_sync_date" != "" ]]; then
        local sync_epoch
        local now_epoch
        sync_epoch=$(date -j -f "%Y-%m-%d" "$last_sync_date" "+%s" 2>/dev/null || date -d "$last_sync_date" "+%s" 2>/dev/null || echo "0")
        now_epoch=$(date "+%s")
        if [[ "$sync_epoch" -gt 0 ]]; then
            local days=$(( (now_epoch - sync_epoch) / 86400 ))
            P_DAYS_BEHIND+=("$days")
        else
            P_DAYS_BEHIND+=("?")
        fi
    else
        P_DAYS_BEHIND+=("?")
    fi
    
    # Count files changed in upstream since last sync
    local files_changed
    files_changed=$(cd "$UPSTREAM_PATH" && git diff --name-only "${last_sync_commit}..HEAD" 2>/dev/null | wc -l | tr -d ' ')
    P_FILES_CHANGED+=("$files_changed")
    
    # Determine status
    if [[ "$commits_behind" == "0" ]]; then
        P_STATUS+=("CURRENT")
    elif [[ "$commits_behind" -le 3 ]] 2>/dev/null; then
        P_STATUS+=("RECENT")
    else
        P_STATUS+=("STALE")
    fi
    
    calculate_score "$project_path"
    count_promote_queue "$project_path"
}

calculate_score() {
    local project_path="$1"
    local score=0
    local max=9
    
    [[ -f "$project_path/.upstream-sync.json" ]] && ((score++))
    [[ -f "$project_path/.claude/PROJECT-CONTEXT.md" ]] && ((score++))
    [[ -f "$project_path/scripts/sync-upstream.sh" ]] && ((score++))
    [[ -f "$project_path/scripts/promote.sh" ]] && ((score++))
    [[ -f "$project_path/.agents/promote-queue.md" ]] && ((score++))
    [[ -f "$project_path/CLAUDE.md" ]] && ((score++))
    [[ -d "$project_path/.claude/reference" ]] && ((score++))
    [[ -d "$project_path/.claude/skills" ]] && ((score++))
    [[ -f "$project_path/.gitignore" ]] && ((score++))
    
    P_SCORES+=("$score/$max")
}

count_promote_queue() {
    local project_path="$1"
    local queue_file="$project_path/.agents/promote-queue.md"
    
    if [[ -f "$queue_file" ]]; then
        local count
        count=$(grep -c "^### " "$queue_file" 2>/dev/null || true)
        count=${count:-0}
        count=$(echo "$count" | tr -d '[:space:]')
        # Subtract promoted items (those under ## Promoted section)
        local promoted_start
        promoted_start=$(grep -n "^## Promoted" "$queue_file" 2>/dev/null | head -1 | cut -d: -f1 || true)
        if [[ -n "${promoted_start:-}" ]]; then
            local promoted_count
            promoted_count=$(tail -n +"$promoted_start" "$queue_file" | grep -c "^### " 2>/dev/null || true)
            promoted_count=${promoted_count:-0}
            promoted_count=$(echo "$promoted_count" | tr -d '[:space:]')
            count=$((count - promoted_count))
            [[ $count -lt 0 ]] && count=0
        fi
        P_PROMOTE_COUNT+=("$count")
    else
        P_PROMOTE_COUNT+=("0")
    fi
}

#-------------------------------------------------------------------------------
# Scan All Projects
#-------------------------------------------------------------------------------

scan_projects() {
    if [[ -n "$SINGLE_PROJECT" ]]; then
        local path="$PROJECTS_DIR/$SINGLE_PROJECT"
        if [[ -d "$path" ]]; then
            calculate_drift "$path"
        else
            echo -e "${RED}ERROR:${NC} Project not found: $path"
            exit 1
        fi
    else
        for project_dir in "$PROJECTS_DIR"/*/; do
            [[ -d "$project_dir" ]] || continue
            local name
            name=$(basename "$project_dir")
            [[ "$name" == "." ]] || [[ "$name" == ".." ]] && continue
            # Skip hidden directories
            [[ "$name" == .* ]] && continue
            calculate_drift "$project_dir"
        done
    fi
}

scan_projects

#-------------------------------------------------------------------------------
# Summary Counters
#-------------------------------------------------------------------------------

TOTAL=${#P_NAMES[@]}
COUNT_CURRENT=0
COUNT_RECENT=0
COUNT_STALE=0
COUNT_BROKEN=0
TOTAL_PROMOTE=0

for i in "${!P_NAMES[@]}"; do
    case "${P_STATUS[$i]}" in
        CURRENT) ((COUNT_CURRENT++)) ;;
        RECENT)  ((COUNT_RECENT++)) ;;
        STALE)   ((COUNT_STALE++)) ;;
        BROKEN)  ((COUNT_BROKEN++)) ;;
    esac
    if [[ "${P_PROMOTE_COUNT[$i]:-0}" =~ ^[0-9]+$ ]]; then
        TOTAL_PROMOTE=$((TOTAL_PROMOTE + ${P_PROMOTE_COUNT[$i]:-0}))
    fi
done

#-------------------------------------------------------------------------------
# JSON Output
#-------------------------------------------------------------------------------

if [[ "$JSON_OUTPUT" == true ]]; then
    echo "{"
    echo "  \"generated_at\": \"$(date -Iseconds)\","
    echo "  \"upstream\": {"
    echo "    \"path\": \"$UPSTREAM_PATH\","
    echo "    \"head_commit\": \"$UPSTREAM_HEAD\","
    echo "    \"head_date\": \"$UPSTREAM_HEAD_DATE\","
    echo "    \"branch\": \"$UPSTREAM_BRANCH\""
    echo "  },"
    echo "  \"summary\": {"
    echo "    \"total_projects\": $TOTAL,"
    echo "    \"current\": $COUNT_CURRENT,"
    echo "    \"recent\": $COUNT_RECENT,"
    echo "    \"stale\": $COUNT_STALE,"
    echo "    \"broken\": $COUNT_BROKEN,"
    echo "    \"total_promote_items\": $TOTAL_PROMOTE"
    echo "  },"
    echo "  \"projects\": ["
    
    for i in "${!P_NAMES[@]}"; do
        [[ $i -gt 0 ]] && echo ","
        echo -n "    {"
        echo -n "\"name\":\"${P_NAMES[$i]}\","
        echo -n "\"status\":\"${P_STATUS[$i]}\","
        echo -n "\"sync_commit\":\"${P_SYNC_COMMIT[$i]}\","
        echo -n "\"sync_date\":\"${P_SYNC_DATE[$i]}\","
        echo -n "\"commits_behind\":\"${P_COMMITS_BEHIND[$i]}\","
        echo -n "\"days_behind\":\"${P_DAYS_BEHIND[$i]}\","
        echo -n "\"files_changed\":\"${P_FILES_CHANGED[$i]}\","
        echo -n "\"score\":\"${P_SCORES[$i]}\","
        echo -n "\"promote_queue\":${P_PROMOTE_COUNT[$i]}"
        echo -n "}"
    done
    
    echo ""
    echo "  ]"
    echo "}"
    exit 0
fi

#-------------------------------------------------------------------------------
# Table Output
#-------------------------------------------------------------------------------

if [[ "$QUIET" != true ]]; then
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                         DRIFT DETECTION REPORT                           ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Upstream: ${BOLD}$UPSTREAM_HEAD${NC} ($UPSTREAM_HEAD_DATE) on ${BOLD}$UPSTREAM_BRANCH${NC}"
    echo -e "  Context:  ${DIM}$CONTEXT${NC}"
    echo ""
fi

# Header
printf "  ${BOLD}%-32s %-10s %7s %5s %6s %6s %7s${NC}\n" \
    "PROJECT" "SYNC AT" "BEHIND" "DAYS" "FILES" "SCORE" "PROMOTE"
echo -e "  ${DIM}────────────────────────────────  ─────────  ───────  ─────  ──────  ──────  ───────${NC}"

for i in "${!P_NAMES[@]}"; do
    local_name="${P_NAMES[$i]}"
    local_status="${P_STATUS[$i]}"
    local_sync="${P_SYNC_COMMIT[$i]}"
    local_commits="${P_COMMITS_BEHIND[$i]}"
    local_days="${P_DAYS_BEHIND[$i]}"
    local_files="${P_FILES_CHANGED[$i]}"
    local_score="${P_SCORES[$i]}"
    local_promote="${P_PROMOTE_COUNT[$i]}"
    
    # Color based on status
    case "$local_status" in
        CURRENT)
            color="$GREEN"
            ;;
        RECENT)
            color="$YELLOW"
            ;;
        STALE)
            color="$RED"
            ;;
        BROKEN)
            color="$RED"
            local_sync="BROKEN"
            ;;
    esac
    
    # Promote indicator
    promote_display="$local_promote"
    if [[ "$local_promote" -gt 0 ]] 2>/dev/null; then
        promote_display="$local_promote"
    fi
    
    printf "  ${color}%-32s${NC} %-10s %7s %5s %6s %6s %7s\n" \
        "$local_name" "$local_sync" "$local_commits" "$local_days" "$local_files" "$local_score" "$promote_display"
done

echo ""

# Summary
if [[ "$QUIET" != true ]]; then
    echo -e "  ${DIM}───────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${BOLD}SUMMARY${NC}"
    
    [[ $COUNT_CURRENT -gt 0 ]] && echo -e "    ${GREEN}Current:${NC}  $COUNT_CURRENT/$TOTAL"
    [[ $COUNT_RECENT -gt 0 ]]  && echo -e "    ${YELLOW}Recent:${NC}   $COUNT_RECENT/$TOTAL"
    [[ $COUNT_STALE -gt 0 ]]   && echo -e "    ${RED}Stale:${NC}    $COUNT_STALE/$TOTAL"
    [[ $COUNT_BROKEN -gt 0 ]]  && echo -e "    ${RED}Broken:${NC}   $COUNT_BROKEN/$TOTAL"
    
    if [[ $TOTAL_PROMOTE -gt 0 ]]; then
        echo ""
        echo -e "  ${BOLD}PROMOTE QUEUE:${NC} $TOTAL_PROMOTE items across projects"
        for i in "${!P_NAMES[@]}"; do
            if [[ "${P_PROMOTE_COUNT[$i]:-0}" -gt 0 ]] 2>/dev/null; then
                printf "    %-32s %s items\n" "${P_NAMES[$i]}" "${P_PROMOTE_COUNT[$i]}"
            fi
        done
    fi
    
    echo ""
    
    if [[ $COUNT_STALE -gt 0 ]] || [[ $COUNT_BROKEN -gt 0 ]]; then
        echo -e "  ${YELLOW}Run:${NC} ./scripts/audit-sync.sh --dry-run    to preview fleet update"
        echo -e "  ${YELLOW}Run:${NC} ./scripts/audit-sync.sh              to bring all projects up to date"
    else
        echo -e "  ${GREEN}All projects are up to date.${NC}"
    fi
fi
