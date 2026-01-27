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
NC='\033[0m' # No Color

# Default values
PROJECT_NAME=""
INCLUDE_FRONTEND=true
INCLUDE_MASTRA=true
INCLUDE_CONVEX=true
INCLUDE_N8N=false
INCLUDE_TERRAFORM=false
NPM_SCOPE="@lucidlabs"
AI_MODEL="anthropic"  # anthropic, openai, both
INTERACTIVE=false

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
    echo -e "${CYAN}Which components do you need?${NC}"
    echo ""

    # Frontend
    if confirm "Include Frontend (Next.js 15 + shadcn/ui)?"; then
        INCLUDE_FRONTEND=true
    else
        INCLUDE_FRONTEND=false
    fi

    # Mastra
    if confirm "Include Mastra (AI Agents)?"; then
        INCLUDE_MASTRA=true
    else
        INCLUDE_MASTRA=false
    fi

    # Convex
    if confirm "Include Convex (Realtime Database)?"; then
        INCLUDE_CONVEX=true
    else
        INCLUDE_CONVEX=false
    fi

    # n8n
    if confirm "Include n8n (Workflow Automation)?" "n"; then
        INCLUDE_N8N=true
    else
        INCLUDE_N8N=false
    fi

    # Terraform
    if confirm "Include Terraform (Infrastructure as Code)?" "n"; then
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
    echo "AI Model preference:"
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

    echo ""
    echo -e "${CYAN}Configuration Summary:${NC}"
    echo "──────────────────────────────────────"
    echo "  Project:    $PROJECT_NAME"
    echo "  Scope:      $NPM_SCOPE"
    echo "  Frontend:   $([ "$INCLUDE_FRONTEND" = true ] && echo "Yes" || echo "No")"
    echo "  Mastra:     $([ "$INCLUDE_MASTRA" = true ] && echo "Yes" || echo "No")"
    echo "  Convex:     $([ "$INCLUDE_CONVEX" = true ] && echo "Yes" || echo "No")"
    echo "  n8n:        $([ "$INCLUDE_N8N" = true ] && echo "Yes" || echo "No")"
    echo "  Terraform:  $([ "$INCLUDE_TERRAFORM" = true ] && echo "Yes" || echo "No")"
    echo "  AI Model:   $AI_MODEL"
    echo "──────────────────────────────────────"
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
    local project_dir="$PWD/$PROJECT_NAME"

    print_step "Creating project directory: $project_dir"

    if [[ -d "$project_dir" ]]; then
        print_error "Directory already exists: $project_dir"
        exit 1
    fi

    mkdir -p "$project_dir"
    cd "$project_dir"

    # Copy template files
    local template_dir
    template_dir="$(dirname "$0")/.."

    # Core files (always included)
    print_step "Copying core configuration..."
    cp "$template_dir/CLAUDE.md" . 2>/dev/null || true
    cp "$template_dir/AGENTS.md" . 2>/dev/null || true
    cp "$template_dir/.gitignore" . 2>/dev/null || true

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
            cp -r "$template_dir/frontend" .
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

# Database (Convex)
NEXT_PUBLIC_CONVEX_URL=https://your-project.convex.cloud
# Or for self-hosted:
# NEXT_PUBLIC_CONVEX_URL=http://localhost:3210

# AI Models
ANTHROPIC_API_KEY=sk-ant-...
EOF

    if [[ "$AI_MODEL" == "openai" ]] || [[ "$AI_MODEL" == "both" ]]; then
        cat >> ".env.example" << EOF
OPENAI_API_KEY=sk-...
EOF
    fi

    if [[ "$INCLUDE_N8N" = true ]]; then
        cat >> ".env.example" << EOF

# n8n
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme
EOF
    fi

    cat >> ".env.example" << EOF

# Application
NODE_ENV=development
PORT=3000
EOF

    # Initialize Git
    print_step "Initializing Git repository..."
    git init -q
    git add .
    git commit -q -m "Initial commit from Agent Kit template"

    print_success "Project created successfully!"
}

#-------------------------------------------------------------------------------
# Post-Creation Instructions
#-------------------------------------------------------------------------------

print_next_steps() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    Project Created Successfully!               ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}📁 Project Location:${NC} $PWD/$PROJECT_NAME"
    echo ""
    echo -e "${CYAN}📋 Next Steps:${NC}"
    echo ""
    echo "  1. Navigate to project:"
    echo -e "     ${YELLOW}cd $PROJECT_NAME${NC}"
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
    echo -e "${CYAN}📖 Workflow:${NC}"
    echo ""
    echo "  PRD-First Development:"
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │  1. Edit .claude/PRD.md with your requirements         │"
    echo "  │  2. Run /plan-feature to create implementation plan    │"
    echo "  │  3. Run /execute to implement the plan                 │"
    echo "  │  4. Run /validate to verify compliance                 │"
    echo "  │  5. Run /commit to commit changes                      │"
    echo "  └─────────────────────────────────────────────────────────┘"
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
