#!/usr/bin/env bash
# bootstrap-sync.sh - Bootstrap sync infrastructure into all downstream projects
#
# Copies promote.sh, sync-upstream.sh, and creates .upstream-sync.json
# in all projects under ../projects/
#
# Usage:
#   ./scripts/bootstrap-sync.sh [options]
#
# Options:
#   --projects-dir PATH   Path to projects directory (default: ../projects)
#   --dry-run             Preview changes without applying
#   --help                Show this help message

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Defaults
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UPSTREAM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECTS_DIR="$UPSTREAM_ROOT/../projects"
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --projects-dir)
            PROJECTS_DIR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: ./scripts/bootstrap-sync.sh [options]"
            echo ""
            echo "Bootstraps sync infrastructure into all downstream projects."
            echo ""
            echo "Options:"
            echo "  --projects-dir PATH   Path to projects directory (default: ../projects)"
            echo "  --dry-run             Preview changes without applying"
            echo "  --help                Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Header
echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                   SYNC BOOTSTRAP                                  ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate
if [[ ! -d "$PROJECTS_DIR" ]]; then
    echo -e "${RED}Error: Projects directory not found: $PROJECTS_DIR${NC}"
    exit 1
fi

if [[ ! -f "$UPSTREAM_ROOT/CLAUDE.md" ]]; then
    echo -e "${RED}Error: Not in an agent-kit repository${NC}"
    exit 1
fi

# Get upstream HEAD commit
UPSTREAM_HEAD=$(cd "$UPSTREAM_ROOT" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
UPSTREAM_DATE=$(date +%Y-%m-%d)

echo -e "${BLUE}ℹ${NC} Upstream:     ${BOLD}$UPSTREAM_ROOT${NC}"
echo -e "${BLUE}ℹ${NC} Projects dir: ${BOLD}$PROJECTS_DIR${NC}"
echo -e "${BLUE}ℹ${NC} Upstream HEAD: ${BOLD}$UPSTREAM_HEAD${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}▶ DRY RUN MODE - No changes will be made${NC}"
    echo ""
fi

# Find downstream projects
BOOTSTRAPPED=0
SKIPPED=0

for project_dir in "$PROJECTS_DIR"/*/; do
    project_name=$(basename "$project_dir")

    # Skip if not a git repo or doesn't have CLAUDE.md
    if [[ ! -d "$project_dir/.git" ]] && [[ ! -f "$project_dir/CLAUDE.md" ]]; then
        continue
    fi

    echo -e "${BLUE}▶${NC} Processing: ${BOLD}$project_name${NC}"

    # Check what needs to be done
    needs_sync_script=false
    needs_promote_script=false
    needs_tracking_file=false

    [[ ! -f "$project_dir/scripts/sync-upstream.sh" ]] && needs_sync_script=true
    [[ ! -f "$project_dir/scripts/promote.sh" ]] && needs_promote_script=true
    [[ ! -f "$project_dir/.upstream-sync.json" ]] && needs_tracking_file=true

    if [[ "$needs_sync_script" == false ]] && [[ "$needs_promote_script" == false ]] && [[ "$needs_tracking_file" == false ]]; then
        echo -e "  ${GREEN}✓${NC} Already bootstrapped"
        ((SKIPPED++))
        echo ""
        continue
    fi

    if [[ "$DRY_RUN" == true ]]; then
        [[ "$needs_sync_script" == true ]] && echo -e "  ${YELLOW}→${NC} Would copy sync-upstream.sh"
        [[ "$needs_promote_script" == true ]] && echo -e "  ${YELLOW}→${NC} Would copy promote.sh"
        [[ "$needs_tracking_file" == true ]] && echo -e "  ${YELLOW}→${NC} Would create .upstream-sync.json"
        echo ""
        continue
    fi

    # Create scripts directory
    mkdir -p "$project_dir/scripts"

    # Copy sync-upstream.sh
    if [[ "$needs_sync_script" == true ]]; then
        cp "$UPSTREAM_ROOT/scripts/sync-upstream.sh" "$project_dir/scripts/sync-upstream.sh"
        chmod +x "$project_dir/scripts/sync-upstream.sh"
        echo -e "  ${GREEN}✓${NC} Copied sync-upstream.sh"
    fi

    # Copy promote.sh
    if [[ "$needs_promote_script" == true ]]; then
        cp "$UPSTREAM_ROOT/scripts/promote.sh" "$project_dir/scripts/promote.sh"
        chmod +x "$project_dir/scripts/promote.sh"
        echo -e "  ${GREEN}✓${NC} Copied promote.sh"
    fi

    # Create .upstream-sync.json
    if [[ "$needs_tracking_file" == true ]]; then
        cat > "$project_dir/.upstream-sync.json" << EOF
{
  "upstream_repo": "lucidlabs-hq/agent-kit",
  "last_sync_commit": "$UPSTREAM_HEAD",
  "last_sync_date": "$UPSTREAM_DATE",
  "synced_files": {}
}
EOF
        echo -e "  ${GREEN}✓${NC} Created .upstream-sync.json"
    fi

    ((BOOTSTRAPPED++))
    echo ""
done

# Summary
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}DRY RUN complete. No changes made.${NC}"
else
    echo -e "${GREEN}✓${NC} Bootstrapped: $BOOTSTRAPPED project(s)"
    echo -e "${BLUE}ℹ${NC} Skipped (already done): $SKIPPED project(s)"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  In each bootstrapped project, commit the new files:"
    echo "  git add scripts/sync-upstream.sh scripts/promote.sh .upstream-sync.json"
    echo "  git commit -m \"chore: bootstrap sync infrastructure from upstream\""
fi
echo ""
