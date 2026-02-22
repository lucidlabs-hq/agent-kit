#!/usr/bin/env bash
#===============================================================================
# Cross-Project Audit & Sync
#
# Orchestrates bringing ALL downstream projects up to date with upstream.
# Workflow: Pre-flight → Backup → Bootstrap → Promote → Sync → Verify
#
# IMPORTANT: Run this from the upstream agent-kit directory.
#
# Usage:
#   ./scripts/audit-sync.sh [options]
#
# Options:
#   --dry-run              Preview what would happen without changes
#   --project NAME         Process a single project only
#   --backup-dir PATH      Custom backup location (default: ~/.lucidlabs-backups/<timestamp>)
#   --skip-promote         Skip the promote-first phase
#   --skip-bootstrap       Skip bootstrapping broken projects
#   --skip-backup          Skip backup phase (dangerous!)
#   --yes                  Auto-confirm all prompts
#   --help, -h             Show this help
#
# Examples:
#   ./scripts/audit-sync.sh --dry-run               # Preview full audit
#   ./scripts/audit-sync.sh --project neola          # Single project
#   ./scripts/audit-sync.sh --skip-promote --yes     # Sync-only, no prompts
#===============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPSTREAM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECTS_DIR="$UPSTREAM_ROOT/../projects"

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
DRY_RUN=false
SINGLE_PROJECT=""
BACKUP_DIR=""
SKIP_PROMOTE=false
SKIP_BOOTSTRAP=false
SKIP_BACKUP=false
AUTO_YES=false

# Counters
BACKED_UP=0
BOOTSTRAPPED=0
PROMOTED=0
SYNCED=0
VERIFIED=0
ERRORS=0

# Phase tracking
CURRENT_PHASE=""
CURRENT_PROJECT=""

#-------------------------------------------------------------------------------
# Helpers
#-------------------------------------------------------------------------------

print_banner() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                       CROSS-PROJECT AUDIT & SYNC                         ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_phase() {
    local phase_num="$1"
    local phase_name="$2"
    CURRENT_PHASE="$phase_name"
    echo ""
    echo -e "${CYAN}┌─── Phase $phase_num ─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}  ${BOLD}$phase_name${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

print_project() {
    local name="$1"
    local index="$2"
    local total="$3"
    CURRENT_PROJECT="$name"
    echo -e "  ${BLUE}▶${NC} [$index/$total] ${BOLD}$name${NC}"
}

print_success() { echo -e "    ${GREEN}✓${NC} $1"; }
print_warning() { echo -e "    ${YELLOW}⚠${NC} $1"; }
print_error()   { echo -e "    ${RED}✗${NC} $1"; }
print_info()    { echo -e "    ${BLUE}ℹ${NC} $1"; }
print_skip()    { echo -e "    ${DIM}⊘ $1${NC}"; }

confirm() {
    if [[ "$AUTO_YES" == true ]]; then
        return 0
    fi
    local msg="${1:-Proceed?}"
    echo -en "  ${YELLOW}$msg [y/N]:${NC} "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

#-------------------------------------------------------------------------------
# Argument Parsing
#-------------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)      DRY_RUN=true; shift ;;
        --project)      SINGLE_PROJECT="$2"; shift 2 ;;
        --backup-dir)   BACKUP_DIR="$2"; shift 2 ;;
        --skip-promote) SKIP_PROMOTE=true; shift ;;
        --skip-bootstrap) SKIP_BOOTSTRAP=true; shift ;;
        --skip-backup)  SKIP_BACKUP=true; shift ;;
        --yes)          AUTO_YES=true; shift ;;
        --help|-h)      head -30 "$0" | tail -25; exit 0 ;;
        *)              echo "Unknown option: $1"; exit 1 ;;
    esac
done

#-------------------------------------------------------------------------------
# Phase 0: Pre-flight Checks
#-------------------------------------------------------------------------------

preflight() {
    print_phase "0" "PRE-FLIGHT CHECKS"

    # Check we're in upstream
    if [[ ! -f "$UPSTREAM_ROOT/scripts/create-agent-project.sh" ]]; then
        print_error "This script must be run from the upstream agent-kit directory."
        print_info  "Current: $UPSTREAM_ROOT"
        exit 1
    fi
    print_success "Running from upstream agent-kit"

    # Check projects directory
    if [[ ! -d "$PROJECTS_DIR" ]]; then
        print_error "Projects directory not found: $PROJECTS_DIR"
        exit 1
    fi
    print_success "Projects directory found: $PROJECTS_DIR"

    # Check upstream git state
    local upstream_dirty
    upstream_dirty=$(cd "$UPSTREAM_ROOT" && git status --porcelain 2>/dev/null | head -1)
    if [[ -n "$upstream_dirty" ]]; then
        print_warning "Upstream has uncommitted changes"
        print_info  "These won't affect sync, but consider committing first"
    else
        print_success "Upstream working tree is clean"
    fi

    # Get upstream HEAD
    UPSTREAM_HEAD=$(cd "$UPSTREAM_ROOT" && git rev-parse --short HEAD 2>/dev/null)
    UPSTREAM_HEAD_FULL=$(cd "$UPSTREAM_ROOT" && git rev-parse HEAD 2>/dev/null)
    UPSTREAM_HEAD_DATE=$(cd "$UPSTREAM_ROOT" && git log -1 --format=%as HEAD 2>/dev/null)
    UPSTREAM_BRANCH=$(cd "$UPSTREAM_ROOT" && git rev-parse --abbrev-ref HEAD 2>/dev/null)
    print_success "Upstream HEAD: $UPSTREAM_HEAD ($UPSTREAM_HEAD_DATE) on $UPSTREAM_BRANCH"

    # Check tools
    command -v python3 &>/dev/null && print_success "python3 available" || { print_error "python3 required"; exit 1; }
    command -v rsync &>/dev/null && print_success "rsync available" || print_warning "rsync not available, will use cp"
    command -v gh &>/dev/null && print_success "gh CLI available" || print_warning "gh CLI not available (PR creation will be skipped)"

    # Collect project list
    PROJECT_LIST=()
    if [[ -n "$SINGLE_PROJECT" ]]; then
        if [[ -d "$PROJECTS_DIR/$SINGLE_PROJECT" ]]; then
            PROJECT_LIST+=("$SINGLE_PROJECT")
        else
            print_error "Project not found: $SINGLE_PROJECT"
            exit 1
        fi
    else
        for d in "$PROJECTS_DIR"/*/; do
            [[ -d "$d" ]] || continue
            local name
            name=$(basename "$d")
            [[ "$name" == .* ]] && continue
            PROJECT_LIST+=("$name")
        done
    fi

    TOTAL_PROJECTS=${#PROJECT_LIST[@]}
    print_success "Found $TOTAL_PROJECTS projects to process"

    # Run drift detection for overview
    echo ""
    if [[ -f "$SCRIPT_DIR/drift-detect.sh" ]]; then
        bash "$SCRIPT_DIR/drift-detect.sh" --quiet 2>/dev/null || true
    fi

    # Identify broken projects (no .upstream-sync.json)
    BROKEN_PROJECTS=()
    SYNCABLE_PROJECTS=()
    PROMOTABLE_PROJECTS=()

    for name in "${PROJECT_LIST[@]}"; do
        local path="$PROJECTS_DIR/$name"
        if [[ ! -f "$path/.upstream-sync.json" ]] || [[ ! -f "$path/scripts/sync-upstream.sh" ]]; then
            BROKEN_PROJECTS+=("$name")
        else
            SYNCABLE_PROJECTS+=("$name")
        fi
        if [[ -f "$path/.agents/promote-queue.md" ]]; then
            local pcount
            pcount=$(grep -c "^### " "$path/.agents/promote-queue.md" 2>/dev/null || true)
            pcount=${pcount:-0}
            if [[ "$pcount" -gt 0 ]]; then
                PROMOTABLE_PROJECTS+=("$name")
            fi
        fi
    done

    # Show audit plan
    echo ""
    echo -e "  ${BOLD}AUDIT PLAN${NC}"
    echo -e "  ─────────"
    [[ "$SKIP_BACKUP" != true ]]     && echo -e "    1. Backup     $TOTAL_PROJECTS projects"
    [[ "$SKIP_BOOTSTRAP" != true ]]  && echo -e "    2. Bootstrap   ${#BROKEN_PROJECTS[@]} broken projects"
    [[ "$SKIP_PROMOTE" != true ]]    && echo -e "    3. Promote     ${#PROMOTABLE_PROJECTS[@]} projects with pending items"
    echo -e "    4. Sync        $TOTAL_PROJECTS projects to upstream HEAD ($UPSTREAM_HEAD)"
    echo -e "    5. Verify      $TOTAL_PROJECTS projects"
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${YELLOW}DRY RUN — No changes will be made.${NC}"
        echo ""

        if [[ ${#BROKEN_PROJECTS[@]} -gt 0 ]]; then
            echo -e "  ${BOLD}Broken projects (need bootstrap):${NC}"
            for name in "${BROKEN_PROJECTS[@]}"; do
                echo -e "    ${RED}•${NC} $name"
            done
            echo ""
        fi

        if [[ ${#PROMOTABLE_PROJECTS[@]} -gt 0 ]]; then
            echo -e "  ${BOLD}Projects with pending promotions:${NC}"
            for name in "${PROMOTABLE_PROJECTS[@]}"; do
                local pcount
                pcount=$(grep -c "^### " "$PROJECTS_DIR/$name/.agents/promote-queue.md" 2>/dev/null || true)
                echo -e "    ${YELLOW}•${NC} $name ($pcount items)"
            done
            echo ""
        fi

        echo -e "  ${BOLD}All projects will be synced to: ${GREEN}$UPSTREAM_HEAD${NC}"
        exit 0
    fi

    if ! confirm "Proceed with audit?"; then
        echo -e "  ${DIM}Aborted.${NC}"
        exit 0
    fi
}

#-------------------------------------------------------------------------------
# Phase 1: Safe Backups
#-------------------------------------------------------------------------------

backup_projects() {
    if [[ "$SKIP_BACKUP" == true ]]; then
        print_phase "1" "BACKUP (skipped)"
        print_skip "Backup skipped via --skip-backup"
        return
    fi

    print_phase "1" "SAFE BACKUP"

    # Create backup directory
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    if [[ -z "$BACKUP_DIR" ]]; then
        BACKUP_DIR="$HOME/.lucidlabs-backups/audit-$timestamp"
    fi

    mkdir -p "$BACKUP_DIR"
    print_success "Backup directory: $BACKUP_DIR"

    local index=0
    for name in "${PROJECT_LIST[@]}"; do
        ((index++))
        print_project "$name" "$index" "$TOTAL_PROJECTS"

        local src="$PROJECTS_DIR/$name"
        local dest="$BACKUP_DIR/$name"

        # rsync backup (exclude heavy dirs)
        if command -v rsync &>/dev/null; then
            rsync -a \
                --exclude='node_modules' \
                --exclude='.next' \
                --exclude='.pnpm-store' \
                --exclude='dist' \
                --exclude='build' \
                --exclude='coverage' \
                --exclude='.turbo' \
                "$src/" "$dest/" 2>/dev/null
        else
            mkdir -p "$dest"
            cp -R "$src/" "$dest/" 2>/dev/null || true
        fi

        # Git bundle for complete history
        if (cd "$src" && git rev-parse --is-inside-work-tree &>/dev/null); then
            (cd "$src" && git bundle create "$BACKUP_DIR/$name.bundle" --all 2>/dev/null) && \
                print_success "Backed up (rsync + git bundle)" || \
                print_success "Backed up (rsync only, bundle failed)"
        else
            print_success "Backed up (rsync only, not a git repo)"
        fi

        ((BACKED_UP++))
    done

    # Write manifest
    python3 -c "
import json, os, subprocess
from datetime import datetime

manifest = {
    'audit_id': 'audit-$timestamp',
    'created_at': datetime.now().isoformat(),
    'upstream_head': '$UPSTREAM_HEAD',
    'backup_dir': '$BACKUP_DIR',
    'projects': []
}

for name in '${PROJECT_LIST[*]}'.split():
    src = '$PROJECTS_DIR/' + name
    dest = '$BACKUP_DIR/' + name
    
    git_branch = 'unknown'
    git_commit = 'unknown'
    git_dirty = False
    
    try:
        git_branch = subprocess.check_output(['git', '-C', src, 'rev-parse', '--abbrev-ref', 'HEAD'], 
                                              stderr=subprocess.DEVNULL).decode().strip()
        git_commit = subprocess.check_output(['git', '-C', src, 'rev-parse', '--short', 'HEAD'],
                                              stderr=subprocess.DEVNULL).decode().strip()
        git_status = subprocess.check_output(['git', '-C', src, 'status', '--porcelain'],
                                              stderr=subprocess.DEVNULL).decode().strip()
        git_dirty = len(git_status) > 0
    except:
        pass
    
    # Count files in backup
    file_count = 0
    for root, dirs, files in os.walk(dest):
        file_count += len(files)
    
    # Calculate size
    size_bytes = 0
    for root, dirs, files in os.walk(dest):
        for f in files:
            try:
                size_bytes += os.path.getsize(os.path.join(root, f))
            except:
                pass
    
    manifest['projects'].append({
        'name': name,
        'backup_path': dest,
        'bundle_path': '$BACKUP_DIR/' + name + '.bundle',
        'git_branch': git_branch,
        'git_commit': git_commit,
        'git_dirty': git_dirty,
        'file_count': file_count,
        'backup_size_mb': round(size_bytes / 1024 / 1024, 1)
    })

with open('$BACKUP_DIR/manifest.json', 'w') as f:
    json.dump(manifest, f, indent=2)

total_size = sum(p['backup_size_mb'] for p in manifest['projects'])
print(f'Manifest written. Total backup size: {total_size:.1f} MB')
" 2>/dev/null && print_success "Manifest written to $BACKUP_DIR/manifest.json" || \
        print_warning "Manifest generation failed (backups still safe)"

    echo ""
    echo -e "  ${GREEN}✓${NC} Backed up $BACKED_UP/$TOTAL_PROJECTS projects to $BACKUP_DIR"
}

#-------------------------------------------------------------------------------
# Phase 2: Bootstrap Broken Projects
#-------------------------------------------------------------------------------

bootstrap_projects() {
    if [[ "$SKIP_BOOTSTRAP" == true ]]; then
        print_phase "2" "BOOTSTRAP (skipped)"
        print_skip "Bootstrap skipped via --skip-bootstrap"
        return
    fi

    print_phase "2" "BOOTSTRAP BROKEN PROJECTS"

    if [[ ${#BROKEN_PROJECTS[@]} -eq 0 ]]; then
        print_success "No broken projects found — all have sync infrastructure"
        return
    fi

    for name in "${BROKEN_PROJECTS[@]}"; do
        local path="$PROJECTS_DIR/$name"
        print_project "$name" "$((BOOTSTRAPPED + 1))" "${#BROKEN_PROJECTS[@]}"

        # Create scripts directory
        mkdir -p "$path/scripts"

        # Copy sync script
        if [[ ! -f "$path/scripts/sync-upstream.sh" ]]; then
            cp "$UPSTREAM_ROOT/scripts/sync-upstream.sh" "$path/scripts/sync-upstream.sh"
            chmod +x "$path/scripts/sync-upstream.sh"
            print_success "Copied sync-upstream.sh"
        else
            print_skip "sync-upstream.sh already exists"
        fi

        # Copy promote script
        if [[ ! -f "$path/scripts/promote.sh" ]]; then
            cp "$UPSTREAM_ROOT/scripts/promote.sh" "$path/scripts/promote.sh"
            chmod +x "$path/scripts/promote.sh"
            print_success "Copied promote.sh"
        else
            print_skip "promote.sh already exists"
        fi

        # Create .upstream-sync.json
        if [[ ! -f "$path/.upstream-sync.json" ]]; then
            cat > "$path/.upstream-sync.json" << SYNCEOF
{
  "upstream_repo": "lucidlabs-hq/agent-kit",
  "last_sync_commit": "$UPSTREAM_HEAD",
  "last_sync_date": "$(date +%Y-%m-%d)",
  "synced_files": {}
}
SYNCEOF
            print_success "Created .upstream-sync.json"
        else
            print_skip ".upstream-sync.json already exists"
        fi

        # Create promote queue if missing
        if [[ ! -f "$path/.agents/promote-queue.md" ]]; then
            mkdir -p "$path/.agents"
            cat > "$path/.agents/promote-queue.md" << QUEUEEOF
# Promote Queue

Items pending promotion to upstream agent-kit.

## Pending

<!-- Add items here as you discover reusable patterns -->

## Promoted

<!-- Items that have been successfully promoted -->
QUEUEEOF
            print_success "Created promote-queue.md"
        fi

        # Commit bootstrap if in a git repo
        if (cd "$path" && git rev-parse --is-inside-work-tree &>/dev/null); then
            (cd "$path" && git add scripts/sync-upstream.sh scripts/promote.sh .upstream-sync.json .agents/promote-queue.md 2>/dev/null && \
             git commit -m "chore: bootstrap sync infrastructure from upstream" 2>/dev/null) && \
                print_success "Committed bootstrap files" || \
                print_skip "Nothing to commit (files already tracked)"
        fi

        ((BOOTSTRAPPED++))
        # Add to syncable list now
        SYNCABLE_PROJECTS+=("$name")
    done

    echo ""
    echo -e "  ${GREEN}✓${NC} Bootstrapped $BOOTSTRAPPED projects"
}

#-------------------------------------------------------------------------------
# Phase 3: Promote Queue Processing
#-------------------------------------------------------------------------------

promote_queued() {
    if [[ "$SKIP_PROMOTE" == true ]]; then
        print_phase "3" "PROMOTE (skipped)"
        print_skip "Promote skipped via --skip-promote"
        return
    fi

    print_phase "3" "PROMOTE QUEUED PATTERNS"

    if [[ ${#PROMOTABLE_PROJECTS[@]} -eq 0 ]]; then
        print_success "No pending promotions found"
        return
    fi

    echo -e "  ${YELLOW}NOTE:${NC} Promotion creates PRs in the upstream repository."
    echo -e "  ${DIM}Each project's promote queue will be processed via promote.sh${NC}"
    echo ""

    local index=0
    for name in "${PROMOTABLE_PROJECTS[@]}"; do
        ((index++))
        local path="$PROJECTS_DIR/$name"
        local pcount
        pcount=$(grep -c "^### " "$path/.agents/promote-queue.md" 2>/dev/null || true)
        pcount=${pcount:-0}

        print_project "$name ($pcount pending items)" "$index" "${#PROMOTABLE_PROJECTS[@]}"

        # Show queue items
        grep "^### " "$path/.agents/promote-queue.md" 2>/dev/null | while read -r line; do
            echo -e "      ${DIM}${line#\#\#\# }${NC}"
        done

        echo ""
        if confirm "Run promote.sh for $name?"; then
            if [[ -f "$path/scripts/promote.sh" ]]; then
                echo ""
                (cd "$path" && bash scripts/promote.sh --upstream "$UPSTREAM_ROOT" 2>&1) && \
                    { print_success "Promotion completed for $name"; ((PROMOTED++)); } || \
                    { print_error "Promotion failed for $name"; ((ERRORS++)); }
            else
                print_error "promote.sh not found in $path/scripts/"
                ((ERRORS++))
            fi
        else
            print_skip "Skipped promotion for $name"
        fi
        echo ""
    done

    echo -e "  ${GREEN}✓${NC} Processed $PROMOTED promotions (${ERRORS} errors)"

    if [[ $PROMOTED -gt 0 ]]; then
        echo ""
        echo -e "  ${YELLOW}IMPORTANT:${NC} Merge the promotion PRs in GitHub before continuing."
        echo -e "  ${DIM}The sync phase will pull the promoted patterns back into all projects.${NC}"
        echo ""
        if ! confirm "Have the promotion PRs been merged? Continue to sync?"; then
            echo -e "  ${DIM}Paused. Re-run with --skip-promote to continue from sync phase.${NC}"
            exit 0
        fi

        # Refresh upstream HEAD after merges
        (cd "$UPSTREAM_ROOT" && git pull origin main 2>/dev/null) || true
        UPSTREAM_HEAD=$(cd "$UPSTREAM_ROOT" && git rev-parse --short HEAD 2>/dev/null)
        print_success "Upstream HEAD refreshed: $UPSTREAM_HEAD"
    fi
}

#-------------------------------------------------------------------------------
# Phase 4: Sync All Projects
#-------------------------------------------------------------------------------

sync_projects() {
    print_phase "4" "SYNC ALL PROJECTS"

    local index=0
    for name in "${PROJECT_LIST[@]}"; do
        ((index++))
        local path="$PROJECTS_DIR/$name"
        print_project "$name" "$index" "$TOTAL_PROJECTS"

        # Check if sync script exists
        if [[ ! -f "$path/scripts/sync-upstream.sh" ]]; then
            print_error "sync-upstream.sh not found — skipping"
            ((ERRORS++))
            continue
        fi

        # Check for dirty working tree
        if (cd "$path" && git rev-parse --is-inside-work-tree &>/dev/null); then
            local dirty
            dirty=$(cd "$path" && git status --porcelain 2>/dev/null | head -1)
            if [[ -n "$dirty" ]]; then
                print_warning "Working tree is dirty — stashing changes"
                (cd "$path" && git stash -u -m "audit-sync: auto-stash before sync $(date +%Y%m%d)" 2>/dev/null) || true
            fi
        fi

        # Check if already current
        local current_sync
        current_sync=$(python3 -c "
import json
try:
    with open('$path/.upstream-sync.json') as f:
        print(json.load(f).get('last_sync_commit', 'none'))
except:
    print('none')
" 2>/dev/null)

        if [[ "$current_sync" == "$UPSTREAM_HEAD"* ]]; then
            print_skip "Already up to date ($UPSTREAM_HEAD)"
            ((SYNCED++))
            continue
        fi

        # Run sync
        print_info "Syncing from $current_sync → $UPSTREAM_HEAD"
        if (cd "$path" && printf "all\ny\n" | bash scripts/sync-upstream.sh --upstream "$UPSTREAM_ROOT" 2>/dev/null); then
            # Commit sync result
            if (cd "$path" && git rev-parse --is-inside-work-tree &>/dev/null); then
                (cd "$path" && git add -A && \
                 git commit -m "chore: sync upstream agent-kit ($UPSTREAM_HEAD)" 2>/dev/null) && \
                    print_success "Synced and committed" || \
                    print_success "Synced (nothing to commit)"
            else
                print_success "Synced (not a git repo)"
            fi
            ((SYNCED++))
        else
            print_error "Sync failed"
            ((ERRORS++))
        fi
    done

    echo ""
    echo -e "  ${GREEN}✓${NC} Synced $SYNCED/$TOTAL_PROJECTS projects (${ERRORS} errors)"
}

#-------------------------------------------------------------------------------
# Phase 5: Verification
#-------------------------------------------------------------------------------

verify_projects() {
    print_phase "5" "VERIFICATION"

    local index=0
    local pass=0
    local fail=0

    for name in "${PROJECT_LIST[@]}"; do
        ((index++))
        local path="$PROJECTS_DIR/$name"
        print_project "$name" "$index" "$TOTAL_PROJECTS"

        local issues=0

        # Check .upstream-sync.json
        if [[ -f "$path/.upstream-sync.json" ]]; then
            local sync_commit
            sync_commit=$(python3 -c "
import json
try:
    with open('$path/.upstream-sync.json') as f:
        print(json.load(f).get('last_sync_commit', 'none'))
except:
    print('none')
" 2>/dev/null)

            if [[ "$sync_commit" == "$UPSTREAM_HEAD"* ]]; then
                print_success ".upstream-sync.json matches HEAD ($UPSTREAM_HEAD)"
            else
                print_warning ".upstream-sync.json at $sync_commit (expected $UPSTREAM_HEAD)"
                ((issues++))
            fi
        else
            print_error "Missing .upstream-sync.json"
            ((issues++))
        fi

        # Check sync scripts
        [[ -f "$path/scripts/sync-upstream.sh" ]] && \
            print_success "sync-upstream.sh present" || \
            { print_error "Missing sync-upstream.sh"; ((issues++)); }

        [[ -f "$path/scripts/promote.sh" ]] && \
            print_success "promote.sh present" || \
            { print_error "Missing promote.sh"; ((issues++)); }

        # Check CLAUDE.md zone marker
        if [[ -f "$path/CLAUDE.md" ]]; then
            if grep -q "UPSTREAM-SYNC-END" "$path/CLAUDE.md" 2>/dev/null; then
                print_success "CLAUDE.md has zone marker"
            else
                print_warning "CLAUDE.md missing zone marker"
                ((issues++))
            fi
        else
            print_warning "No CLAUDE.md"
            ((issues++))
        fi

        # Check promote queue
        if [[ -f "$path/.agents/promote-queue.md" ]]; then
            print_success "promote-queue.md present"
        else
            print_warning "Missing promote-queue.md"
        fi

        # Verdict
        if [[ $issues -eq 0 ]]; then
            ((pass++))
        else
            ((fail++))
        fi
    done

    VERIFIED=$pass
    echo ""
    echo -e "  ${GREEN}✓${NC} Verified: $pass passed, $fail with issues"
}

#-------------------------------------------------------------------------------
# Phase 6: Final Report
#-------------------------------------------------------------------------------

final_report() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                           AUDIT COMPLETE                                 ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "  ${BOLD}RESULTS${NC}"
    echo -e "  ───────"
    [[ "$SKIP_BACKUP" != true ]]    && echo -e "    Backed up:     ${GREEN}$BACKED_UP${NC}/$TOTAL_PROJECTS projects"
    [[ "$SKIP_BOOTSTRAP" != true ]] && echo -e "    Bootstrapped:  ${GREEN}$BOOTSTRAPPED${NC} projects"
    [[ "$SKIP_PROMOTE" != true ]]   && echo -e "    Promoted:      ${GREEN}$PROMOTED${NC} projects"
    echo -e "    Synced:        ${GREEN}$SYNCED${NC}/$TOTAL_PROJECTS projects"
    echo -e "    Verified:      ${GREEN}$VERIFIED${NC}/$TOTAL_PROJECTS passed"
    [[ $ERRORS -gt 0 ]] && echo -e "    Errors:        ${RED}$ERRORS${NC}"
    echo ""

    if [[ -n "$BACKUP_DIR" ]] && [[ -d "$BACKUP_DIR" ]]; then
        local backup_size
        backup_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
        echo -e "  ${BOLD}BACKUP${NC}"
        echo -e "  ──────"
        echo -e "    Location: $BACKUP_DIR"
        echo -e "    Size:     $backup_size"
        echo -e "    Manifest: $BACKUP_DIR/manifest.json"
        echo ""
    fi

    # Run drift detection to show final state
    echo -e "  ${BOLD}FINAL STATE${NC}"
    echo -e "  ───────────"
    if [[ -f "$SCRIPT_DIR/drift-detect.sh" ]]; then
        bash "$SCRIPT_DIR/drift-detect.sh" --quiet 2>/dev/null || true
    fi

    echo ""
    if [[ $ERRORS -gt 0 ]]; then
        echo -e "  ${YELLOW}Some projects had errors. Review above and re-run for failed projects:${NC}"
        echo -e "  ${DIM}./scripts/audit-sync.sh --project <name> --skip-backup${NC}"
    else
        echo -e "  ${GREEN}All projects are up to date with upstream $UPSTREAM_HEAD.${NC}"
    fi
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

main() {
    print_banner

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${YELLOW}▶ DRY RUN MODE — No changes will be made${NC}"
        echo ""
    fi

    preflight
    backup_projects
    bootstrap_projects
    promote_queued
    sync_projects
    verify_projects
    final_report
}

main
