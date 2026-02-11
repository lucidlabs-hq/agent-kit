#!/bin/bash

#===============================================================================
# Agent Kit - Unlock Upstream (macOS chflags)
#
# Removes the user immutable flag (nouchg) from all tracked files in the
# upstream repository. Use this before making legitimate changes.
#
# Usage:
#   ./scripts/unlock-upstream.sh            # Unlock all tracked files
#
# Lock after changes:
#   ./scripts/lock-upstream.sh              # Re-lock all tracked files
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
    echo -e "${YELLOW}chflags is macOS-only. Skipping filesystem unlock.${NC}"
    exit 0
fi

echo -e "${CYAN}Unlocking upstream agent-kit files...${NC}"
echo ""

count=0

while IFS= read -r file; do
    if [[ -f "$REPO_ROOT/$file" ]]; then
        chflags nouchg "$REPO_ROOT/$file" 2>/dev/null || true
        ((count++))
    fi
done < <(cd "$REPO_ROOT" && git ls-files)

echo -e "${GREEN}Unlocked $count tracked files (chflags nouchg).${NC}"
echo -e "${YELLOW}Remember to re-lock after changes: ./scripts/lock-upstream.sh${NC}"
