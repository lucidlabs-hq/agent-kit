#!/bin/bash

#===============================================================================
# Agent Kit - Project Scaffolding Script
#
# Creates a new AI agent project from the Agent Kit template.
# Supports modular component selection.
#
# Usage:
#   ./scripts/create-agent-project.sh [project-name]
#   ./scripts/create-agent-project.sh --interactive
#
# Components:
#   - Frontend (Next.js 15)
#   - Mastra (AI Agents)
#   - Convex (Realtime Database)
#   - n8n (Workflows)
#   - Terraform (Infrastructure)
#===============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Default values
PROJECT_NAME=""
INCLUDE_FRONTEND=true
INCLUDE_MASTRA=true
INCLUDE_CONVEX=true
INCLUDE_POSTGRES=false
INCLUDE_N8N=false
INCLUDE_TERRAFORM=false
INCLUDE_PORTKEY=false
INCLUDE_LANGCHAIN=false
INCLUDE_PYTHON_WORKERS=false
NPM_SCOPE="@lucidlabs"
AI_MODEL="anthropic"  # anthropic, openai, both
AI_LAYER="mastra"     # mastra, vercel-ai-sdk
INTERACTIVE=false
GITHUB_REPO_URL=""
CREATE_LINEAR_PROJECT=true
LINEAR_DOMAIN=""
LINEAR_PROJECT_NAME=""

# Get the script's directory (agent-kit root)
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECTS_DIR="$SCRIPT_DIR/../projects"

#-------------------------------------------------------------------------------
# Helper Functions
#-------------------------------------------------------------------------------

print_banner() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║${NC}     ${BLUE}█████╗  ██████╗ ███████╗███╗   ██╗████████╗${NC}                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${BLUE}██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝${NC}                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${BLUE}███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${BLUE}██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${BLUE}██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${BLUE}╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝${NC}   ${GREEN}KIT${NC}           ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║${NC}       ${YELLOW}AI Agent Starter Kit by Lucid Labs GmbH${NC}              ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✖${NC} $1"
}

print_success() {
    echo -e "${GREEN}✔${NC} $1"
}

confirm() {
    local prompt="$1"
    local default="${2:-y}"

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    read -p "$prompt" response
    response=${response:-$default}

    [[ "$response" =~ ^[Yy]$ ]]
}

select_option() {
    local prompt="$1"
    shift
    local options=("$@")

    echo "$prompt"
    for i in "${!options[@]}"; do
        echo "  $((i+1))) ${options[$i]}"
    done

    local selection
    read -p "Select (1-${#options[@]}): " selection

    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#options[@]}" ]; then
        echo "$((selection-1))"
    else
        echo "0"
    fi
}

#-------------------------------------------------------------------------------
# Interactive Mode
#-------------------------------------------------------------------------------

run_interactive() {
    print_banner

    echo -e "${CYAN}Let's set up your new AI agent project!${NC}"
    echo ""

    # Project name
    read -p "Project name (e.g., my-agent): " PROJECT_NAME
    if [[ -z "$PROJECT_NAME" ]]; then
        print_error "Project name is required"
        exit 1
    fi

    # Validate project name
    if [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
        print_error "Project name must be lowercase, start with a letter, and contain only letters, numbers, and hyphens"
        exit 1
    fi

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                      STACK CONFIGURATION                       ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # ─────────────────────────────────────────────────────────────────
    # AI LAYER (Choose one)
    # ─────────────────────────────────────────────────────────────────
    echo -e "${YELLOW}AI Layer (wähle eins):${NC}"
    echo ""
    echo "  1) Mastra (Production Agents, Tools, Workflows)"
    echo "     → Für: Full Agents, Decision Layer, Structured Outputs"
    echo ""
    echo "  2) Vercel AI SDK (Schnelle Prototypen, Chat UI)"
    echo "     → Für: Chat Interfaces, Streaming, Simple Prompts"
    echo ""
    read -p "Select (1-2, default: 1): " ai_layer_choice
    case $ai_layer_choice in
        2)
            AI_LAYER="vercel-ai-sdk"
            INCLUDE_MASTRA=false
            ;;
        *)
            AI_LAYER="mastra"
            INCLUDE_MASTRA=true
            ;;
    esac

    # ─────────────────────────────────────────────────────────────────
    # DATABASE (Choose one)
    # ─────────────────────────────────────────────────────────────────
    echo ""
    echo -e "${YELLOW}Database (wähle eins):${NC}"
    echo ""
    echo "  1) Convex (Realtime, Simple Setup, Built-in Vector)"
    echo "     → Für: Realtime Apps, schnelles Setup, Type-safe"
    echo ""
    echo "  2) Postgres (SQL Standard, Pinecone-kompatibel)"
    echo "     → Für: SQL, Pinecone Vectors, maximale Kontrolle"
    echo ""
    read -p "Select (1-2, default: 1): " db_choice
    case $db_choice in
        2)
            INCLUDE_POSTGRES=true
            INCLUDE_CONVEX=false
            ;;
        *)
            INCLUDE_POSTGRES=false
            INCLUDE_CONVEX=true
            ;;
    esac

    # ─────────────────────────────────────────────────────────────────
    # FRONTEND
    # ─────────────────────────────────────────────────────────────────
    echo ""
    echo -e "${YELLOW}Frontend:${NC}"
    if confirm "Include Frontend (Next.js 15 + shadcn/ui)?"; then
        INCLUDE_FRONTEND=true
    else
        INCLUDE_FRONTEND=false
    fi

    # ─────────────────────────────────────────────────────────────────
    # OPTIONAL COMPONENTS
    # ─────────────────────────────────────────────────────────────────
    echo ""
    echo -e "${YELLOW}Optionale Komponenten:${NC}"
    echo ""

    # Portkey (LLM Gateway)
    echo -e "  ${CYAN}Portkey${NC} - LLM Gateway mit Cost Tracking, Multi-Model, Guardrails"
    if confirm "  Include Portkey (LLM Gateway)?" "n"; then
        INCLUDE_PORTKEY=true
    else
        INCLUDE_PORTKEY=false
    fi

    # n8n
    echo ""
    echo -e "  ${CYAN}n8n${NC} - Workflow Automation, Integrations, Scheduling"
    if confirm "  Include n8n (Workflow Automation)?" "n"; then
        INCLUDE_N8N=true
    else
        INCLUDE_N8N=false
    fi

    # Python Workers
    echo ""
    echo -e "  ${CYAN}Python Workers${NC} - PDF Parsing, OCR, Statistics, ML"
    if confirm "  Include Python Workers (Compute Layer)?" "n"; then
        INCLUDE_PYTHON_WORKERS=true
    else
        INCLUDE_PYTHON_WORKERS=false
    fi

    # LangChain
    echo ""
    echo -e "  ${CYAN}LangChain${NC} - Complex Chains, LangGraph, erweiterte Agents"
    if confirm "  Include LangChain/LangGraph?" "n"; then
        INCLUDE_LANGCHAIN=true
    else
        INCLUDE_LANGCHAIN=false
    fi

    # Terraform
    echo ""
    echo -e "  ${CYAN}Terraform${NC} - Infrastructure as Code für Deployment"
    if confirm "  Include Terraform (IaC)?" "n"; then
        INCLUDE_TERRAFORM=true
    else
        INCLUDE_TERRAFORM=false
    fi

    echo ""

    # NPM Scope
    read -p "NPM scope (default: @lucidlabs): " input_scope
    NPM_SCOPE=${input_scope:-"@lucidlabs"}

    # AI Model preference
    echo ""
    echo -e "${YELLOW}LLM Provider:${NC}"
    echo "  1) Anthropic Claude (Recommended)"
    echo "  2) OpenAI GPT"
    echo "  3) Both"
    read -p "Select (1-3): " model_choice
    case $model_choice in
        1) AI_MODEL="anthropic" ;;
        2) AI_MODEL="openai" ;;
        3) AI_MODEL="both" ;;
        *) AI_MODEL="anthropic" ;;
    esac

    # Linear Project
    echo ""
    echo -e "${CYAN}Project Management:${NC}"
    echo ""
    if confirm "Linear Projekt erstellen? (lucid-labs-agents workspace)"; then
        CREATE_LINEAR_PROJECT=true
        echo ""
        echo "Project Domain (für Naming Convention):"
        echo "  1) Agents    - AI Agent Projekte"
        echo "  2) AI        - Allgemeine AI Features"
        echo "  3) Platform  - Infrastructure & Ops"
        echo "  4) Integration - Externe Integrationen"
        echo "  5) Other     - Eigene Domain"
        read -p "Select (1-5): " domain_choice
        case $domain_choice in
            1) LINEAR_DOMAIN="Agents" ;;
            2) LINEAR_DOMAIN="AI" ;;
            3) LINEAR_DOMAIN="Platform" ;;
            4) LINEAR_DOMAIN="Integration" ;;
            5)
                read -p "Domain Name: " LINEAR_DOMAIN
                ;;
            *) LINEAR_DOMAIN="Agents" ;;
        esac

        # Generate Linear project name
        # Convert kebab-case to Title Case
        TITLE_CASE_NAME=$(echo "$PROJECT_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
        LINEAR_PROJECT_NAME="[$LINEAR_DOMAIN] $TITLE_CASE_NAME"

        echo ""
        echo -e "Linear Project Name: ${YELLOW}$LINEAR_PROJECT_NAME${NC}"
        read -p "Anpassen? (Enter für Standard): " custom_name
        if [[ -n "$custom_name" ]]; then
            LINEAR_PROJECT_NAME="[$LINEAR_DOMAIN] $custom_name"
        fi
    else
        CREATE_LINEAR_PROJECT=false
    fi

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    CONFIGURATION SUMMARY                       ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "  Project:         $PROJECT_NAME"
    echo "  Scope:           $NPM_SCOPE"
    echo ""
    echo -e "  ${YELLOW}Core Stack:${NC}"
    echo "  ├─ AI Layer:     $([ "$AI_LAYER" = "mastra" ] && echo "Mastra (Production)" || echo "Vercel AI SDK (Prototype)")"
    echo "  ├─ Database:     $([ "$INCLUDE_CONVEX" = true ] && echo "Convex (Realtime)" || echo "Postgres (SQL)")"
    echo "  ├─ Frontend:     $([ "$INCLUDE_FRONTEND" = true ] && echo "Yes (Next.js 15)" || echo "No")"
    echo "  └─ LLM Provider: $AI_MODEL"
    echo ""
    echo -e "  ${YELLOW}Optional:${NC}"
    echo "  ├─ Portkey:      $([ "$INCLUDE_PORTKEY" = true ] && echo "Yes (LLM Gateway)" || echo "No")"
    echo "  ├─ n8n:          $([ "$INCLUDE_N8N" = true ] && echo "Yes (Automation)" || echo "No")"
    echo "  ├─ Python:       $([ "$INCLUDE_PYTHON_WORKERS" = true ] && echo "Yes (Compute)" || echo "No")"
    echo "  ├─ LangChain:    $([ "$INCLUDE_LANGCHAIN" = true ] && echo "Yes" || echo "No")"
    echo "  └─ Terraform:    $([ "$INCLUDE_TERRAFORM" = true ] && echo "Yes (IaC)" || echo "No")"
    echo ""
    echo -e "  ${YELLOW}Project Management:${NC}"
    echo "  └─ Linear:       $([ "$CREATE_LINEAR_PROJECT" = true ] && echo "$LINEAR_PROJECT_NAME" || echo "No")"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    if ! confirm "Create project with these settings?"; then
        print_info "Cancelled."
        exit 0
    fi
}

#-------------------------------------------------------------------------------
# Project Creation
#-------------------------------------------------------------------------------

create_project() {
    # Ensure projects directory exists
    if [[ ! -d "$PROJECTS_DIR" ]]; then
        print_step "Creating projects directory: $PROJECTS_DIR"
        mkdir -p "$PROJECTS_DIR"
    fi

    local project_dir="$PROJECTS_DIR/$PROJECT_NAME"

    print_step "Creating project directory: $project_dir"

    if [[ -d "$project_dir" ]]; then
        print_error "Directory already exists: $project_dir"
        exit 1
    fi

    mkdir -p "$project_dir"
    cd "$project_dir"

    # Template directory is the agent-kit root
    local template_dir="$SCRIPT_DIR"

    # Core files (always included)
    print_step "Copying core configuration..."
    cp "$template_dir/CLAUDE.md" . 2>/dev/null || true
    cp "$template_dir/AGENTS.md" . 2>/dev/null || true
    cp "$template_dir/.gitignore" . 2>/dev/null || true

    # Add Welcome Section to CLAUDE.md for project-specific greeting
    print_step "Adding project welcome section..."
    cat >> "CLAUDE.md" << 'WELCOME_EOF'

---

## Session Start: Welcome

**WICHTIG:** Wenn dies der erste Kontakt in einer neuen Session ist, begrüße den Benutzer mit dem folgenden Format:

```
╔═══════════════════════════════════════════════════════════════════╗
║  Willkommen bei [PROJECT_NAME]!                                   ║
╚═══════════════════════════════════════════════════════════════════╝

Projekt: [PROJECT_NAME]
Status:  [Lies PROJECT-STATUS.md falls vorhanden]

Was möchtest du tun?

┌─────────────────────────────────────────────────────────────────┐
│  [1] 🔍 Prime      - Projekt verstehen, Kontext laden           │
│  [2] 📋 Create PRD - Product Requirements erstellen             │
│  [3] 📝 Plan       - Feature planen                             │
│  [4] ⚡ Execute    - Plan ausführen                              │
│  [5] ✅ Commit     - Änderungen committen                        │
│  [6] 🔄 Sync       - Updates vom Template holen                  │
│  [7] 📤 Promote    - Pattern zum Template befördern              │
└─────────────────────────────────────────────────────────────────┘

Antworte mit einer Zahl oder beschreibe, was du machen möchtest.
```

Nach der Begrüßung:
- Bei [1]: Führe `/prime` aus
- Bei [2]: Führe `/create-prd` aus
- Bei [3]: Frage nach dem Feature-Namen, dann `/plan-feature [name]`
- Bei [4]: Frage nach dem Plan, dann `/execute [plan]`
- Bei [5]: Führe `/commit` aus
- Bei [6]: Führe `/sync` aus
- Bei [7]: Führe `/promote` aus

WELCOME_EOF
    sed -i '' "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" "CLAUDE.md" 2>/dev/null || \
    sed -i "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" "CLAUDE.md" 2>/dev/null || true

    # .claude directory
    if [[ -d "$template_dir/.claude" ]]; then
        cp -r "$template_dir/.claude" .
        # Replace PRD with template
        if [[ -f ".claude/PRD.md" ]]; then
            cat > ".claude/PRD.md" << 'EOF'
# [PROJECT_NAME] - Product Requirements Document

## 1. Overview

**Project:** [PROJECT_NAME]
**Description:** [Brief description of what your project does]
**Target Users:** [Who will use this?]

## 2. Problem Statement

[What problem does this solve?]

## 3. Core Features

### Feature 1: [Name]
- Description: [What it does]
- User Story: As a [user], I want to [action] so that [benefit]
- Acceptance Criteria:
  - [ ] Criterion 1
  - [ ] Criterion 2

### Feature 2: [Name]
[...]

## 4. Data Model

[Describe your main entities and their relationships]

```
Entity1
├── field1: type
├── field2: type
└── relationships

Entity2
├── field1: type
└── relationships
```

## 5. AI Agents

### Agent: [Name]
- **Purpose:** [What does this agent do?]
- **Triggers:** [When is it invoked?]
- **Tools:** [What tools does it use?]
- **Output:** [What does it produce?]

## 6. Workflows

### Workflow: [Name]
1. Step 1: [Description]
2. Step 2: [Description]
3. Step 3: [Description]

## 7. User Interface

[Describe key screens/views]

## 8. Non-Functional Requirements

- **Performance:** [Response times, throughput]
- **Security:** [Authentication, authorization]
- **Scalability:** [Expected load]

## 9. Success Metrics

- [ ] Metric 1: [Target]
- [ ] Metric 2: [Target]
EOF
            sed -i '' "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" ".claude/PRD.md" 2>/dev/null || \
            sed -i "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" ".claude/PRD.md" 2>/dev/null || true
        fi
    fi

    # Frontend
    if [[ "$INCLUDE_FRONTEND" = true ]]; then
        print_step "Setting up Frontend (Next.js)..."
        if [[ -d "$template_dir/frontend" ]]; then
            # Use rsync to exclude build artifacts, or fallback to manual copy
            if command -v rsync &> /dev/null; then
                rsync -a --exclude='node_modules' --exclude='.next' --exclude='playwright-report' --exclude='test-results' --exclude='.dev-screenshots' "$template_dir/frontend/" frontend/
            else
                mkdir -p frontend
                # Manual copy excluding problematic directories
                for item in "$template_dir/frontend"/*; do
                    base=$(basename "$item")
                    if [[ "$base" != "node_modules" && "$base" != ".next" && "$base" != "playwright-report" && "$base" != "test-results" && "$base" != ".dev-screenshots" ]]; then
                        cp -r "$item" frontend/ 2>/dev/null || true
                    fi
                done
                # Copy hidden files except .next
                for item in "$template_dir/frontend"/.[!.]*; do
                    base=$(basename "$item")
                    if [[ "$base" != ".next" && "$base" != ".dev-screenshots" && -e "$item" ]]; then
                        cp -r "$item" frontend/ 2>/dev/null || true
                    fi
                done
            fi
            # Update package.json
            sed -i '' "s/@lucidlabs\/agent-kit-frontend/${NPM_SCOPE}\/${PROJECT_NAME}-frontend/g" frontend/package.json 2>/dev/null || \
            sed -i "s/@lucidlabs\/agent-kit-frontend/${NPM_SCOPE}\/${PROJECT_NAME}-frontend/g" frontend/package.json 2>/dev/null || true
        fi
    fi

    # Mastra
    if [[ "$INCLUDE_MASTRA" = true ]]; then
        print_step "Setting up Mastra (AI Agents)..."
        if [[ -d "$template_dir/mastra" ]]; then
            cp -r "$template_dir/mastra" .
            # Update package.json
            sed -i '' "s/@lucidlabs\/agent-kit-mastra/${NPM_SCOPE}\/${PROJECT_NAME}-mastra/g" mastra/package.json 2>/dev/null || \
            sed -i "s/@lucidlabs\/agent-kit-mastra/${NPM_SCOPE}\/${PROJECT_NAME}-mastra/g" mastra/package.json 2>/dev/null || true
        fi
    fi

    # Convex
    if [[ "$INCLUDE_CONVEX" = true ]]; then
        print_step "Setting up Convex (Database)..."
        if [[ -d "$template_dir/convex" ]]; then
            cp -r "$template_dir/convex" .
        fi
    fi

    # n8n
    if [[ "$INCLUDE_N8N" = true ]]; then
        print_step "Setting up n8n (Workflows)..."
        if [[ -d "$template_dir/n8n" ]]; then
            cp -r "$template_dir/n8n" .
        fi
    fi

    # Terraform
    if [[ "$INCLUDE_TERRAFORM" = true ]]; then
        print_step "Setting up Terraform (Infrastructure)..."
        if [[ -d "$template_dir/terraform" ]]; then
            cp -r "$template_dir/terraform" .
        fi
    fi

    # Docker files
    print_step "Setting up Docker configuration..."
    if [[ -f "$template_dir/docker-compose.yml" ]]; then
        cp "$template_dir/docker-compose.yml" .
    fi

    # Create .env.example
    print_step "Creating environment template..."
    cat > ".env.example" << EOF
# =============================================================================
# $PROJECT_NAME - Environment Variables
# =============================================================================
# Stack: AI Layer: $AI_LAYER | Database: $([ "$INCLUDE_CONVEX" = true ] && echo "Convex" || echo "Postgres")
# =============================================================================

EOF

    # Database section
    if [[ "$INCLUDE_CONVEX" = true ]]; then
        cat >> ".env.example" << EOF
# Database (Convex)
NEXT_PUBLIC_CONVEX_URL=https://your-project.convex.cloud
# Or for self-hosted:
# NEXT_PUBLIC_CONVEX_URL=http://localhost:3210

EOF
    fi

    if [[ "$INCLUDE_POSTGRES" = true ]]; then
        cat >> ".env.example" << EOF
# Database (Postgres)
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
# For Prisma:
# DIRECT_URL=postgresql://user:password@localhost:5432/dbname

# Vector Database (Optional - wenn Pinecone genutzt wird)
# PINECONE_API_KEY=your-pinecone-key
# PINECONE_ENVIRONMENT=us-east-1

EOF
    fi

    # AI Models section
    cat >> ".env.example" << EOF
# AI Models
ANTHROPIC_API_KEY=sk-ant-...
EOF

    if [[ "$AI_MODEL" == "openai" ]] || [[ "$AI_MODEL" == "both" ]]; then
        cat >> ".env.example" << EOF
OPENAI_API_KEY=sk-...
EOF
    fi

    # Portkey section
    if [[ "$INCLUDE_PORTKEY" = true ]]; then
        cat >> ".env.example" << EOF

# Portkey (LLM Gateway)
# Self-hosted: http://localhost:8787
# Cloud: https://api.portkey.ai
PORTKEY_API_KEY=your-portkey-key
PORTKEY_BASE_URL=https://api.portkey.ai/v1
EOF
    fi

    # n8n section
    if [[ "$INCLUDE_N8N" = true ]]; then
        cat >> ".env.example" << EOF

# n8n (Workflow Automation)
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme
EOF
    fi

    # Python Workers section
    if [[ "$INCLUDE_PYTHON_WORKERS" = true ]]; then
        cat >> ".env.example" << EOF

# Python Workers (Compute Layer)
PYTHON_WORKER_URL=http://localhost:8000
EOF
    fi

    # Application section
    cat >> ".env.example" << EOF

# Application
NODE_ENV=development
PORT=3000
EOF

    # Sync Infrastructure
    print_step "Setting up sync infrastructure..."
    mkdir -p scripts
    if [[ -f "$SCRIPT_DIR/scripts/sync-upstream.sh" ]]; then
        cp "$SCRIPT_DIR/scripts/sync-upstream.sh" scripts/sync-upstream.sh
        chmod +x scripts/sync-upstream.sh
        print_success "Copied sync-upstream.sh"
    fi
    if [[ -f "$SCRIPT_DIR/scripts/promote.sh" ]]; then
        cp "$SCRIPT_DIR/scripts/promote.sh" scripts/promote.sh
        chmod +x scripts/promote.sh
        print_success "Copied promote.sh"
    fi

    # Create .upstream-sync.json with current upstream HEAD
    local upstream_head
    upstream_head=$(cd "$SCRIPT_DIR" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    cat > ".upstream-sync.json" << EOF
{
  "upstream_repo": "lucidlabs-hq/agent-kit",
  "last_sync_commit": "$upstream_head",
  "last_sync_date": "$(date +%Y-%m-%d)",
  "synced_files": {}
}
EOF
    print_success "Created .upstream-sync.json"

    # Generate CI/CD Workflows
    print_step "Generating CI/CD workflows..."
    mkdir -p .github/workflows

    # Copy CI workflow (no changes needed)
    if [[ -f "$template_dir/.github/workflow-templates/ci.yml" ]]; then
        cp "$template_dir/.github/workflow-templates/ci.yml" .github/workflows/ci.yml
        print_success "Generated .github/workflows/ci.yml"
    fi

    # Generate deploy-hq.yml with project values filled in
    if [[ -f "$template_dir/.github/workflow-templates/deploy-hq.yml" ]]; then
        # Derive abbreviation from project name (first letters of each word)
        local abbr
        abbr=$(echo "$PROJECT_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) printf substr($i,1,1)}')

        # Derive subdomain (project name without hyphens)
        local subdomain
        subdomain=$(echo "$PROJECT_NAME" | tr -d '-')

        local has_convex_val="true"
        [[ "$INCLUDE_CONVEX" != true ]] && has_convex_val="false"

        local has_mastra_val="false"
        [[ "$INCLUDE_MASTRA" = true ]] && has_mastra_val="true"

        sed \
            -e "s/PROJECT_NAME: \"my-project\"/PROJECT_NAME: \"$PROJECT_NAME\"/" \
            -e "s/ABBREVIATION: \"mp\"/ABBREVIATION: \"$abbr\"/" \
            -e "s/SUBDOMAIN: \"myproject\"/SUBDOMAIN: \"$subdomain\"/" \
            -e "s/HAS_CONVEX: \"true\"/HAS_CONVEX: \"$has_convex_val\"/" \
            -e "s/HAS_MASTRA: \"false\"/HAS_MASTRA: \"$has_mastra_val\"/" \
            "$template_dir/.github/workflow-templates/deploy-hq.yml" > .github/workflows/deploy-hq.yml

        print_success "Generated .github/workflows/deploy-hq.yml (values filled in)"
    fi

    # Copy provisioning workflow
    if [[ -f "$template_dir/.github/workflow-templates/deploy-provision.yml" ]]; then
        cp "$template_dir/.github/workflow-templates/deploy-provision.yml" .github/workflows/deploy-provision.yml
        print_success "Generated .github/workflows/deploy-provision.yml"
    fi

    # Initialize Git
    print_step "Initializing Git repository..."
    git init -q
    git add .
    git commit -q -m "Initial commit from Agent Kit template"

    # GitHub Repository Creation
    if command -v gh &> /dev/null; then
        echo ""
        if confirm "GitHub Repository erstellen?" "y"; then
            echo ""
            read -p "GitHub Organization/User (default: lucidlabs-hq): " gh_org
            gh_org=${gh_org:-"lucidlabs-hq"}

            local visibility="private"
            if confirm "Repository öffentlich machen?" "n"; then
                visibility="public"
            fi

            print_step "Creating GitHub repository: $gh_org/$PROJECT_NAME ($visibility)..."

            if gh repo create "$gh_org/$PROJECT_NAME" --"$visibility" --source=. --push 2>/dev/null; then
                print_success "GitHub repository created and pushed!"
                GITHUB_REPO_URL="https://github.com/$gh_org/$PROJECT_NAME"
            else
                print_warning "Could not create GitHub repo. You can do it later with:"
                echo "  gh repo create $gh_org/$PROJECT_NAME --private --source=. --push"
            fi
        fi
    else
        print_info "GitHub CLI (gh) not installed. Skipping repo creation."
        print_info "Install with: brew install gh"
    fi

    # Linear Project Creation Instructions
    if [[ "$CREATE_LINEAR_PROJECT" = true ]]; then
        echo ""
        print_step "Linear Project Setup"
        echo ""
        echo -e "  ${YELLOW}Linear Projekt muss über MCP erstellt werden:${NC}"
        echo ""
        echo "  1. Starte Claude in deinem neuen Projekt:"
        echo -e "     ${CYAN}cd $project_dir && claude${NC}"
        echo ""
        echo "  2. Erstelle das Linear Projekt:"
        echo -e "     ${CYAN}/linear create-project${NC}"
        echo ""
        echo "  Projekt Details:"
        echo "    - Workspace: lucid-labs-agents"
        echo "    - Name: $LINEAR_PROJECT_NAME"
        echo ""

        # Save Linear config for later
        cat > "$project_dir/.linear-config" << EOF
LINEAR_PROJECT_NAME="$LINEAR_PROJECT_NAME"
LINEAR_DOMAIN="$LINEAR_DOMAIN"
LINEAR_WORKSPACE="lucid-labs-agents"
EOF
        print_info "Linear config saved to .linear-config"
    fi

    print_success "Project created successfully!"
}

#-------------------------------------------------------------------------------
# Post-Creation Instructions
#-------------------------------------------------------------------------------

print_next_steps() {
    local project_path="$PROJECTS_DIR/$PROJECT_NAME"
    local relative_path="../projects/$PROJECT_NAME"

    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    Project Created Successfully!               ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}📁 Project Location:${NC} $project_path"

    if [[ -n "$GITHUB_REPO_URL" ]]; then
        echo -e "${CYAN}🔗 GitHub Repository:${NC} $GITHUB_REPO_URL"
    fi

    echo ""
    echo -e "${CYAN}🚀 Jetzt starten:${NC}"
    echo ""
    echo -e "  ${BOLD}Starte eine neue Claude Session im Projekt:${NC}"
    echo -e "     ${YELLOW}cd $relative_path && claude${NC}"
    echo ""
    echo -e "  Claude wird dich dann begrüßen und fragen, was du tun möchtest!"
    echo ""
    echo -e "${CYAN}📋 Alternativ manuell:${NC}"
    echo ""
    echo "  1. Navigate to project:"
    echo -e "     ${YELLOW}cd $relative_path${NC}"
    echo ""

    if [[ "$INCLUDE_FRONTEND" = true ]]; then
        echo "  2. Install frontend dependencies:"
        echo -e "     ${YELLOW}cd frontend && pnpm install${NC}"
        echo ""
    fi

    if [[ "$INCLUDE_MASTRA" = true ]]; then
        echo "  3. Install mastra dependencies:"
        echo -e "     ${YELLOW}cd mastra && pnpm install${NC}"
        echo ""
    fi

    if [[ "$INCLUDE_CONVEX" = true ]]; then
        echo "  4. Initialize Convex:"
        echo -e "     ${YELLOW}npx convex init${NC}"
        echo ""
    fi

    echo "  5. Copy environment variables:"
    echo -e "     ${YELLOW}cp .env.example .env.local${NC}"
    echo ""
    echo "  6. Start developing:"
    echo -e "     ${YELLOW}pnpm run dev${NC}"
    echo ""
    echo -e "${CYAN}📖 Workflow (Discovery-Driven Development):${NC}"
    echo ""
    echo "  Linear-First Development:"
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │  1. /linear create - Create Linear issue               │"
    echo "  │  2. /plan-feature  - Plan implementation               │"
    echo "  │  3. /execute       - Implement the plan                │"
    echo "  │  4. /validate      - Verify compliance                 │"
    echo "  │  5. /commit        - Commit changes                    │"
    echo "  │  6. /session-end   - Update Linear, clean state        │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  Status Flow: Backlog → Exploration → Decision → Delivery → Review → Done"
    echo ""
    echo -e "${CYAN}📚 Documentation:${NC}"
    echo "  - CLAUDE.md      - Project conventions and rules"
    echo "  - .claude/PRD.md - Product requirements (edit this first!)"
    echo "  - README.md      - Project overview"
    echo ""
    echo -e "${GREEN}Happy building! 🚀${NC}"
    echo ""
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --interactive|-i)
                INTERACTIVE=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [project-name] [options]"
                echo ""
                echo "Options:"
                echo "  --interactive, -i    Run in interactive mode"
                echo "  --no-frontend        Exclude frontend"
                echo "  --no-mastra          Exclude Mastra agents"
                echo "  --no-convex          Exclude Convex database"
                echo "  --with-n8n           Include n8n workflows"
                echo "  --with-terraform     Include Terraform"
                echo "  --scope SCOPE        NPM scope (default: @lucidlabs)"
                echo "  --help, -h           Show this help"
                exit 0
                ;;
            --no-frontend)
                INCLUDE_FRONTEND=false
                shift
                ;;
            --no-mastra)
                INCLUDE_MASTRA=false
                shift
                ;;
            --no-convex)
                INCLUDE_CONVEX=false
                shift
                ;;
            --with-n8n)
                INCLUDE_N8N=true
                shift
                ;;
            --with-terraform)
                INCLUDE_TERRAFORM=true
                shift
                ;;
            --scope)
                NPM_SCOPE="$2"
                shift 2
                ;;
            -*)
                print_error "Unknown option: $1"
                exit 1
                ;;
            *)
                PROJECT_NAME="$1"
                shift
                ;;
        esac
    done

    # Run interactive mode if requested or no project name given
    if [[ "$INTERACTIVE" = true ]] || [[ -z "$PROJECT_NAME" ]]; then
        run_interactive
    fi

    # Create the project
    create_project

    # Print next steps
    print_next_steps
}

main "$@"
