---
name: init-project
description: Initialize a new project from Agent Kit boilerplate. Use when creating a new downstream project.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash
argument-hint: [project-name]
---

# Initialize New Project

Create a new downstream project from the Agent Kit template.

## Expected Folder Structure

```
lucidlabs/
├── lucidlabs-agent-kit/            ← You are here (upstream)
└── projects/
    └── [project-name]/             ← Will be created here
```

## Project Details

**Project Name:** $ARGUMENTS

If no argument provided, ask for:
- Project name (kebab-case, e.g., `customer-portal`)
- Project description (one sentence)

## Step 1: Run the Scaffolding Script

The script automatically creates the project in `../projects/`:

```bash
# Interactive mode (recommended for first-time)
./scripts/create-agent-project.sh --interactive

# Or with project name directly
./scripts/create-agent-project.sh [project-name]
```

**What the script does:**
1. Creates `../projects/[project-name]/`
2. Copies all boilerplate files
3. Customizes package.json and README
4. Creates template PRD
5. Initializes git repository with initial commit

## Step 2: Provide Next Steps

After the script completes, tell the user:

```markdown
## Projekt erstellt

**Projekt:** [project-name]
**Pfad:** ../projects/[project-name]/

### WICHTIG: Neue Claude Session starten

Claude Sessions sind verzeichnisgebunden. Um im neuen Projekt zu arbeiten:

**Terminal:**
\`\`\`bash
cd ../projects/[project-name] && claude
\`\`\`

**VS Code:**
1. Öffne den Ordner `../projects/[project-name]/` in VS Code
2. Starte Claude über die Command Palette

### Nach dem Start der neuen Session:

1. Dependencies installieren:
   \`\`\`bash
   cd frontend && pnpm install
   \`\`\`

2. Kontext laden:
   \`\`\`
   /prime
   \`\`\`

3. PRD erstellen:
   \`\`\`
   /create-prd
   \`\`\`

4. Erste Feature planen:
   \`\`\`
   /plan-feature [feature-name]
   \`\`\`
```

## Key Principle

**Claude arbeitet immer im aktuellen Verzeichnis.** Eine Session die in `lucidlabs-agent-kit/` gestartet wurde, arbeitet am Template. Für Projekt-Arbeit muss eine neue Session im Projekt-Verzeichnis gestartet werden.

## Available Skills in New Project

| Skill | Description |
|-------|-------------|
| `/prime` | Load project context |
| `/create-prd` | Create Product Requirements Document |
| `/plan-feature` | Plan feature implementation |
| `/execute` | Execute an implementation plan |
| `/validate` | Run all validation checks |
| `/commit` | Create formatted commit |
| `/promote` | Promote patterns back to template |
| `/sync` | Sync updates from template |

## Notes

- Always use `pnpm` for package management (never npm/yarn)
- PRD is the main project-specific file
- Follow patterns in `.claude/reference/` docs
