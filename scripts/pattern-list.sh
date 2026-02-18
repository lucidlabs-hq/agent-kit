#!/usr/bin/env bash
#===============================================================================
# Pattern Discovery CLI
#
# Query the pattern registry and check staleness against downstream projects.
#
# Usage:
#   ./scripts/pattern-list.sh [options]
#
# Options:
#   --category CATEGORY   Filter by category (skill|reference|component|utility|hook|script)
#   --search TERM         Search by name or description (case-insensitive)
#   --project NAME        Staleness report for a downstream project
#   --new-since COMMIT    Patterns added/modified since a commit SHA
#   --json                Output as JSON
#   --help, -h            Show this help
#
# Examples:
#   ./scripts/pattern-list.sh                           # List all patterns
#   ./scripts/pattern-list.sh --category skill          # List all skills
#   ./scripts/pattern-list.sh --search "auth"           # Search for auth-related
#   ./scripts/pattern-list.sh --project neola           # Staleness report for neola
#   ./scripts/pattern-list.sh --new-since abc1234       # What changed since abc1234
#===============================================================================

set -euo pipefail

# Navigate to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

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
CATEGORY=""
SEARCH=""
PROJECT=""
NEW_SINCE=""
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --category)   CATEGORY="$2"; shift 2 ;;
        --search)     SEARCH="$2"; shift 2 ;;
        --project)    PROJECT="$2"; shift 2 ;;
        --new-since)  NEW_SINCE="$2"; shift 2 ;;
        --json)       JSON_OUTPUT=true; shift ;;
        --help|-h)
            sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

REGISTRY="$REPO_ROOT/pattern-registry.json"

# Auto-generate registry if missing or stale (older than 1 hour)
if [[ ! -f "$REGISTRY" ]]; then
    echo -e "${YELLOW}Registry not found. Generating...${NC}" >&2
    bash "$REPO_ROOT/scripts/pattern-registry.sh" --quiet
elif [[ "$(uname)" == "Darwin" ]]; then
    # macOS: check if file is older than 1 hour
    age=$(( $(date +%s) - $(stat -f %m "$REGISTRY") ))
    if [[ $age -gt 3600 ]]; then
        echo -e "${DIM}Registry is stale ($(( age / 60 ))m old). Regenerating...${NC}" >&2
        bash "$REPO_ROOT/scripts/pattern-registry.sh" --quiet
    fi
else
    # Linux: check if file is older than 1 hour
    age=$(( $(date +%s) - $(stat -c %Y "$REGISTRY") ))
    if [[ $age -gt 3600 ]]; then
        echo -e "${DIM}Registry is stale ($(( age / 60 ))m old). Regenerating...${NC}" >&2
        bash "$REPO_ROOT/scripts/pattern-registry.sh" --quiet
    fi
fi

if [[ ! -f "$REGISTRY" ]]; then
    echo "ERROR: Could not find or generate pattern-registry.json" >&2
    exit 1
fi

#-------------------------------------------------------------------------------
# Project staleness report
#-------------------------------------------------------------------------------
if [[ -n "$PROJECT" ]]; then
    # Find the downstream project
    PROJECT_PATH=""
    for candidate in "../projects/$PROJECT" "../../projects/$PROJECT" "../$PROJECT"; do
        if [[ -d "$candidate" && -f "$candidate/.upstream-sync.json" ]]; then
            PROJECT_PATH="$(cd "$candidate" && pwd)"
            break
        fi
    done

    if [[ -z "$PROJECT_PATH" ]]; then
        echo ""
        echo -e "${RED}  [BLOCKED] Project not found: $PROJECT${NC}"
        echo ""
        echo "  Searched in:"
        echo "    ../projects/$PROJECT"
        echo "    ../../projects/$PROJECT"
        echo "    ../$PROJECT"
        echo ""
        echo "  Make sure the project has an .upstream-sync.json file."
        echo ""
        exit 1
    fi

    SYNC_FILE="$PROJECT_PATH/.upstream-sync.json"

    python3 << PYEOF
import json
import sys

with open("$REGISTRY") as f:
    registry = json.load(f)

with open("$SYNC_FILE") as f:
    sync_data = json.load(f)

synced_files = sync_data.get("synced_files", {})
last_sync_commit = sync_data.get("last_sync_commit", "none")
last_sync_date = sync_data.get("last_sync_date", "unknown")

json_output = $( [[ "$JSON_OUTPUT" == true ]] && echo "True" || echo "False" )

up_to_date = []
stale = []
missing = []

for pattern in registry["patterns"]:
    path = pattern["path"]
    if path in synced_files:
        synced_ver = synced_files[path]
        if synced_ver == pattern["version"]:
            up_to_date.append(pattern)
        else:
            stale.append({"pattern": pattern, "synced_version": synced_ver})
    else:
        missing.append(pattern)

if json_output:
    result = {
        "project": "$PROJECT",
        "project_path": "$PROJECT_PATH",
        "last_sync_commit": last_sync_commit,
        "last_sync_date": last_sync_date,
        "registry_commit": registry["generated_from_commit"],
        "summary": {
            "total_patterns": registry["pattern_count"],
            "up_to_date": len(up_to_date),
            "stale": len(stale),
            "missing": len(missing),
        },
        "stale_patterns": [{"id": s["pattern"]["id"], "current": s["synced_version"], "latest": s["pattern"]["version"]} for s in stale],
        "missing_patterns": [p["id"] for p in missing],
    }
    print(json.dumps(result, indent=2))
else:
    total = registry["pattern_count"]
    print()
    print(f"\033[0;36m╔═══════════════════════════════════════════════════════════════════╗\033[0m")
    print(f"\033[0;36m║              PATTERN STALENESS REPORT                             ║\033[0m")
    print(f"\033[0;36m╚═══════════════════════════════════════════════════════════════════╝\033[0m")
    print()
    print(f"  Project:     \033[1m$PROJECT\033[0m")
    print(f"  Last sync:   \033[1m{last_sync_commit}\033[0m ({last_sync_date})")
    print(f"  Registry:    \033[1m{registry['generated_from_commit']}\033[0m ({registry['pattern_count']} patterns)")
    print()

    # Summary bar
    up_pct = (len(up_to_date) / total * 100) if total > 0 else 0
    stale_pct = (len(stale) / total * 100) if total > 0 else 0
    miss_pct = (len(missing) / total * 100) if total > 0 else 0

    print(f"  \033[0;32m✓ Up-to-date: {len(up_to_date):>3}\033[0m  ({up_pct:.0f}%)")
    print(f"  \033[1;33m⚠ Stale:      {len(stale):>3}\033[0m  ({stale_pct:.0f}%)")
    print(f"  \033[0;31m✖ Missing:    {len(missing):>3}\033[0m  ({miss_pct:.0f}%)")
    print()

    if stale:
        print(f"  \033[1;33mStale patterns:\033[0m")
        for s in stale:
            p = s["pattern"]
            print(f"    ~ {p['id']:<40} {s['synced_version']} → {p['version']}")
        print()

    if missing and len(missing) <= 30:
        print(f"  \033[0;31mMissing patterns:\033[0m (never synced)")
        # Group by category
        by_cat = {}
        for p in missing:
            by_cat.setdefault(p["category"], []).append(p)
        for cat in sorted(by_cat):
            print(f"    {cat} ({len(by_cat[cat])}):")
            for p in by_cat[cat][:10]:
                print(f"      - {p['name']}")
            if len(by_cat[cat]) > 10:
                print(f"      ... and {len(by_cat[cat]) - 10} more")
        print()
    elif missing:
        print(f"  \033[0;31mMissing patterns:\033[0m {len(missing)} (run sync to populate)")
        print()

    print(f"  \033[2mRun: ./scripts/sync-upstream.sh --all  to sync all patterns\033[0m")
    print()
PYEOF
    exit 0
fi

#-------------------------------------------------------------------------------
# New-since report
#-------------------------------------------------------------------------------
if [[ -n "$NEW_SINCE" ]]; then
    # Get all files changed since the given commit
    CHANGED_FILES=$(git diff --name-only "$NEW_SINCE"..HEAD 2>/dev/null || echo "")

    if [[ -z "$CHANGED_FILES" ]]; then
        echo "No changes found since $NEW_SINCE" >&2
        exit 0
    fi

    python3 << PYEOF
import json
import sys

with open("$REGISTRY") as f:
    registry = json.load(f)

changed_files = set("""$CHANGED_FILES""".strip().split("\n"))
json_output = $( [[ "$JSON_OUTPUT" == true ]] && echo "True" || echo "False" )

matched = []
for pattern in registry["patterns"]:
    if pattern["path"] in changed_files:
        matched.append(pattern)

if json_output:
    print(json.dumps({"since": "$NEW_SINCE", "count": len(matched), "patterns": matched}, indent=2))
else:
    if not matched:
        print(f"  No registry patterns changed since $NEW_SINCE")
    else:
        print()
        print(f"\033[1mPatterns changed since $NEW_SINCE:\033[0m ({len(matched)} patterns)")
        print()
        for p in matched:
            print(f"  {p['id']:<40} {p['version']}  {p['last_modified']}")
        print()
PYEOF
    exit 0
fi

#-------------------------------------------------------------------------------
# General listing (with optional --category and --search filters)
#-------------------------------------------------------------------------------
python3 << PYEOF
import json
import sys

with open("$REGISTRY") as f:
    registry = json.load(f)

category_filter = "$CATEGORY".lower().strip()
search_filter = "$SEARCH".lower().strip()
json_output = $( [[ "$JSON_OUTPUT" == true ]] && echo "True" || echo "False" )

patterns = registry["patterns"]

# Apply filters
if category_filter:
    patterns = [p for p in patterns if p["category"] == category_filter]

if search_filter:
    patterns = [p for p in patterns if search_filter in p["name"].lower() or search_filter in p["description"].lower()]

if json_output:
    result = {
        "filters": {},
        "count": len(patterns),
        "patterns": patterns,
    }
    if category_filter:
        result["filters"]["category"] = category_filter
    if search_filter:
        result["filters"]["search"] = search_filter
    print(json.dumps(result, indent=2))
else:
    if not patterns:
        print("  No patterns found matching your criteria.")
        sys.exit(0)

    print()
    print(f"\033[0;36m╔═══════════════════════════════════════════════════════════════════╗\033[0m")
    print(f"\033[0;36m║                     PATTERN REGISTRY                              ║\033[0m")
    print(f"\033[0;36m╚═══════════════════════════════════════════════════════════════════╝\033[0m")
    print()

    title = "All patterns"
    if category_filter:
        title = f"Category: {category_filter}"
    if search_filter:
        title = f"Search: '{search_filter}'"
    if category_filter and search_filter:
        title = f"Category: {category_filter}, Search: '{search_filter}'"

    print(f"  {title} ({len(patterns)} results)")
    print()

    # Header
    print(f"  {'ID':<40} {'VERSION':<10} {'MODIFIED':<12} {'DESCRIPTION'}")
    print(f"  {'─' * 40} {'─' * 10} {'─' * 12} {'─' * 40}")

    current_category = ""
    for p in patterns:
        if p["category"] != current_category:
            current_category = p["category"]
            if current_category != patterns[0]["category"]:
                print()  # Separator between categories

        desc = p["description"][:50] + "..." if len(p["description"]) > 50 else p["description"]
        print(f"  {p['id']:<40} {p['version']:<10} {p['last_modified']:<12} {desc}")

    print()
    print(f"  \033[2mGenerated from commit {registry['generated_from_commit']} at {registry['generated_at']}\033[0m")
    print()

    # Category summary
    cats = registry["categories"]
    summary_parts = []
    for cat_name in ["skill", "reference", "component", "utility", "hook", "script"]:
        c = cats.get(cat_name, {}).get("count", 0)
        if c > 0:
            summary_parts.append(f"{cat_name}: {c}")
    print(f"  \033[2mCategories: {', '.join(summary_parts)}\033[0m")
    print()
PYEOF
