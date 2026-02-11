#!/bin/bash

#===============================================================================
# Agent Kit - Lock Upstream (macOS chflags)
#
# Sets the user immutable flag (uchg) on all tracked files in the upstream
# repository. This makes files read-only at the filesystem level, preventing
# accidental modifications from any process.
#
# Usage:
#   ./scripts/lock-upstream.sh              # Lock all tracked files
#   ./scripts/lock-upstream.sh --status     # Show lock status
#
# Unlock:
#   ./scripts/unlock-upstream.sh            # Remove immutable flags
#
# Requires macOS (uses chflags).
#===============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Check if on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${YELLOW}chflags is macOS-only. Skipping filesystem lock.${NC}"
    exit 0
fi

show_status() {
    echo -e "${BOLD}Lock status for upstream agent-kit:${NC}"
    echo ""

    local locked=0
    local unlocked=0

    while IFS= read -r file; do
        if [[ -f "$REPO_ROOT/$file" ]]; then
            local flags
            flags=$(ls -lO "$REPO_ROOT/$file" 2>/dev/null | awk '{print $5}')
            if [[ "$flags" == *"uchg"* ]]; then
                ((locked++))
            else
                ((unlocked++))
            fi
        fi
    done < <(cd "$REPO_ROOT" && git ls-files)

    echo -e "  Locked (uchg):   ${GREEN}$locked${NC}"
    echo -e "  Unlocked:        ${YELLOW}$unlocked${NC}"
    echo ""

    if [[ $unlocked -eq 0 ]] && [[ $locked -gt 0 ]]; then
        echo -e "  ${GREEN}All tracked files are locked.${NC}"
    elif [[ $locked -eq 0 ]]; then
        echo -e "  ${YELLOW}No files are locked.${NC}"
    else
        echo -e "  ${YELLOW}Some files are unlocked.${NC}"
    fi
}

lock_files() {
    echo -e "${CYAN}Locking upstream agent-kit files...${NC}"
    echo ""

    local count=0

    while IFS= read -r file; do
        if [[ -f "$REPO_ROOT/$file" ]]; then
            chflags uchg "$REPO_ROOT/$file" 2>/dev/null || true
            ((count++))
        fi
    done < <(cd "$REPO_ROOT" && git ls-files)

    echo -e "${GREEN}Locked $count tracked files with chflags uchg.${NC}"
    echo -e "${CYAN}To unlock: ./scripts/unlock-upstream.sh${NC}"
}

# Parse arguments
case "${1:-}" in
    --status|-s)
        show_status
        ;;
    --help|-h)
        echo "Usage: ./scripts/lock-upstream.sh [--status|--help]"
        echo ""
        echo "Sets macOS immutable flag (uchg) on all git-tracked files."
        echo "This prevents any process from modifying the files."
        echo ""
        echo "Options:"
        echo "  --status    Show current lock status"
        echo "  --help      Show this help"
        ;;
    *)
        lock_files
        ;;
esac
