#!/usr/bin/env bash
#===============================================================================
# Pattern Registry Generator
#
# Scans the agent-kit filesystem and git history to produce a central
# pattern-registry.json cataloging all available patterns.
#
# Usage:
#   ./scripts/pattern-registry.sh [options]
#
# Options:
#   --dry-run   Print JSON to stdout without writing file
#   --quiet     Suppress progress output (still writes file)
#   --json      Print JSON to stdout after writing file
#   --help, -h  Show this help
#
# Categories:
#   skill       .claude/skills/*/SKILL.md
#   reference   .claude/reference/*.md
#   component   frontend/components/ui/*.tsx
#   utility     frontend/lib/*.ts (non-test, non-type)
#   hook        frontend/hooks/*.ts | frontend/lib/hooks/*.ts
#   script      scripts/*.sh
#===============================================================================

set -euo pipefail

# Navigate to repo root (script may be called from anywhere)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Options
DRY_RUN=false
QUIET=false
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)  DRY_RUN=true; shift ;;
        --quiet)    QUIET=true; shift ;;
        --json)     JSON_OUTPUT=true; shift ;;
        --help|-h)
            sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        *) shift ;;
    esac
done

log() {
    if [[ "$QUIET" == false ]]; then
        echo "$@" >&2
    fi
}

OUTPUT_FILE="$REPO_ROOT/pattern-registry.json"
COMMIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

#-------------------------------------------------------------------------------
# Collect pattern data and assemble JSON via python3
#-------------------------------------------------------------------------------

# Build a TSV of all patterns: category\tname\tpath\tsize_bytes
# Then python3 enriches with git history + description extraction

collect_patterns() {
    # Skills: each subdirectory with a SKILL.md
    if [[ -d ".claude/skills" ]]; then
        for skill_dir in .claude/skills/*/; do
            local skill_file="${skill_dir}SKILL.md"
            if [[ -f "$skill_file" ]]; then
                local name
                name=$(basename "$skill_dir")
                local size
                size=$(wc -c < "$skill_file" | tr -d ' ')
                printf "skill\t%s\t%s\t%s\n" "$name" "$skill_file" "$size"
            fi
        done
    fi

    # Reference docs: .md files (exclude .json)
    if [[ -d ".claude/reference" ]]; then
        for ref_file in .claude/reference/*.md; do
            [[ -f "$ref_file" ]] || continue
            local name
            name=$(basename "$ref_file" .md)
            local size
            size=$(wc -c < "$ref_file" | tr -d ' ')
            printf "reference\t%s\t%s\t%s\n" "$name" "$ref_file" "$size"
        done
    fi

    # UI Components: .tsx files
    if [[ -d "frontend/components/ui" ]]; then
        for comp_file in frontend/components/ui/*.tsx; do
            [[ -f "$comp_file" ]] || continue
            local name
            name=$(basename "$comp_file" .tsx)
            local size
            size=$(wc -c < "$comp_file" | tr -d ' ')
            printf "component\t%s\t%s\t%s\n" "$name" "$comp_file" "$size"
        done
    fi

    # Utilities: frontend/lib/*.ts (exclude __tests__, mock, types dirs)
    if [[ -d "frontend/lib" ]]; then
        for util_file in frontend/lib/*.ts; do
            [[ -f "$util_file" ]] || continue
            local name
            name=$(basename "$util_file" .ts)
            local size
            size=$(wc -c < "$util_file" | tr -d ' ')
            printf "utility\t%s\t%s\t%s\n" "$name" "$util_file" "$size"
        done
    fi

    # Hooks: frontend/hooks/*.ts or frontend/lib/hooks/*.ts
    for hook_dir in "frontend/hooks" "frontend/lib/hooks"; do
        if [[ -d "$hook_dir" ]]; then
            for hook_file in "$hook_dir"/*.ts "$hook_dir"/*.tsx; do
                [[ -f "$hook_file" ]] || continue
                local name
                name=$(basename "$hook_file" | sed 's/\.tsx\?$//')
                local size
                size=$(wc -c < "$hook_file" | tr -d ' ')
                printf "hook\t%s\t%s\t%s\n" "$name" "$hook_file" "$size"
            done
        fi
    done

    # Scripts: *.sh files
    if [[ -d "scripts" ]]; then
        for script_file in scripts/*.sh; do
            [[ -f "$script_file" ]] || continue
            local name
            name=$(basename "$script_file" .sh)
            local size
            size=$(wc -c < "$script_file" | tr -d ' ')
            printf "script\t%s\t%s\t%s\n" "$name" "$script_file" "$size"
        done
    fi
}

log "Scanning patterns..."

PATTERN_TSV=$(collect_patterns)
PATTERN_COUNT=$(echo "$PATTERN_TSV" | grep -c '.' || echo "0")

log "Found $PATTERN_COUNT patterns. Enriching with git history..."

# Use python3 to:
# 1. Parse the TSV
# 2. For each pattern, run git log to get version/dates
# 3. Extract descriptions from file content
# 4. Assemble and write JSON

set +e
REGISTRY_JSON=$(PATTERN_TSV="$PATTERN_TSV" COMMIT_SHA="$COMMIT_SHA" REPO_ROOT="$REPO_ROOT" python3 << 'PYEOF'
import json
import subprocess
import os
import re
import sys
from datetime import datetime, timezone

tsv_data = os.environ.get("PATTERN_TSV", "")
commit_sha = os.environ.get("COMMIT_SHA", "unknown")
repo_root = os.environ.get("REPO_ROOT", ".")

patterns = []
category_counts = {
    "skill": 0,
    "reference": 0,
    "component": 0,
    "utility": 0,
    "hook": 0,
    "script": 0,
}

category_base_paths = {
    "skill": ".claude/skills",
    "reference": ".claude/reference",
    "component": "frontend/components/ui",
    "utility": "frontend/lib",
    "hook": "frontend/lib/hooks",
    "script": "scripts",
}

def git_log_field(path, fmt):
    """Run git log -1 and return the output for a given format string."""
    try:
        result = subprocess.run(
            ["git", "log", "-1", "--format=" + fmt, "--", path],
            capture_output=True, text=True, timeout=5, cwd=repo_root
        )
        return result.stdout.strip()
    except Exception:
        return ""

def git_first_commit_date(path):
    """Get the date of the first commit that touched this path."""
    try:
        result = subprocess.run(
            ["git", "log", "--follow", "--diff-filter=A", "--format=%as", "--", path],
            capture_output=True, text=True, timeout=5, cwd=repo_root
        )
        lines = result.stdout.strip().split("\n")
        return lines[-1] if lines and lines[-1] else ""
    except Exception:
        return ""

def extract_description(category, path):
    """Extract a human-readable description from file content."""
    try:
        with open(os.path.join(repo_root, path), "r", encoding="utf-8", errors="replace") as f:
            content = f.read(4096)  # Read first 4KB only
    except Exception:
        return ""

    if category == "skill":
        # YAML frontmatter: extract description field
        fm_match = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
        if fm_match:
            for line in fm_match.group(1).split("\n"):
                if line.startswith("description:"):
                    desc = line[len("description:"):].strip()
                    # Remove surrounding quotes if present
                    if desc.startswith('"') and desc.endswith('"'):
                        desc = desc[1:-1]
                    elif desc.startswith("'") and desc.endswith("'"):
                        desc = desc[1:-1]
                    return desc
        return ""

    elif category == "reference":
        # First blockquote line (> **...**) or first line after # heading
        lines = content.split("\n")
        for line in lines:
            line = line.strip()
            if line.startswith("> **"):
                # Extract text between ** **
                match = re.search(r"\*\*(.+?)\*\*", line)
                if match:
                    return match.group(1).strip()
            elif line.startswith("> "):
                return line[2:].strip()
        # Fallback: first heading
        for line in lines:
            line = line.strip()
            if line.startswith("# "):
                return line[2:].strip()
        return ""

    else:
        # Generic placeholder
        return ""

for line in tsv_data.strip().split("\n"):
    if not line.strip():
        continue

    parts = line.split("\t")
    if len(parts) != 4:
        continue

    category, name, path, size_str = parts

    try:
        size_bytes = int(size_str)
    except ValueError:
        size_bytes = 0

    category_counts[category] = category_counts.get(category, 0) + 1

    # Git metadata
    version = git_log_field(path, "%h")
    last_modified = git_log_field(path, "%as")
    added_date = git_first_commit_date(path)

    # Description
    description = extract_description(category, path)
    if not description:
        description = f"{name} {category}"

    pattern_id = f"{category}/{name}"

    patterns.append({
        "id": pattern_id,
        "name": name,
        "category": category,
        "path": path,
        "description": description,
        "version": version or commit_sha,
        "added_date": added_date or "",
        "last_modified": last_modified or "",
        "size_bytes": size_bytes,
    })

# Sort patterns by category, then name
patterns.sort(key=lambda p: (p["category"], p["name"]))

# Build categories section
categories = {}
for cat, base in category_base_paths.items():
    categories[cat] = {
        "count": category_counts.get(cat, 0),
        "base_path": base,
    }

registry = {
    "$schema_version": "1.0.0",
    "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "generated_from_commit": commit_sha,
    "pattern_count": len(patterns),
    "categories": categories,
    "patterns": patterns,
}

print(json.dumps(registry, indent=2))
PYEOF
)
PYTHON_EXIT=$?
set -e

if [[ $PYTHON_EXIT -ne 0 ]]; then
    echo "ERROR: Failed to generate registry JSON" >&2
    exit 1
fi

# Write or print
if [[ "$DRY_RUN" == true ]]; then
    echo "$REGISTRY_JSON"
    log "Dry run — registry not written."
else
    echo "$REGISTRY_JSON" > "$OUTPUT_FILE"
    log "Wrote $OUTPUT_FILE ($PATTERN_COUNT patterns)"

    if [[ "$JSON_OUTPUT" == true ]]; then
        echo "$REGISTRY_JSON"
    fi
fi

log "Done."
