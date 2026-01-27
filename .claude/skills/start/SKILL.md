---
name: start
description: Entry point for Agent Kit. Use this when starting a session in the template repository to create or open a project.
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Edit
---

# Start: Agent Kit Entry Point

This skill is the entry point when working with the Agent Kit template. It guides you to create a new project or open an existing one.

## When This Skill Runs

You are in the **upstream template** (`lucidlabs-agent-kit/`). This is NOT where development happens. You need to either:
1. Create a new downstream project
2. Open an existing downstream project

## Expected Folder Structure

```
lucidlabs/
├── lucidlabs-agent-kit/        ← You are here (upstream template)
└── projects/                    ← Downstream projects go here
    ├── customer-portal/
    ├── internal-dashboard/
    └── ...
```

## Step 1: Check for Existing Projects

First, check what projects exist:

```bash
# List existing projects
ls -la ../projects 2>/dev/null || echo "No projects directory yet"
```

## Step 2: Ask the User

Present the options to the user:

**Question:** "Was möchtest du tun?"

**Options:**
1. **Neues Projekt erstellen** → Run `/init-project [name]`
2. **Bestehendes Projekt öffnen** → Navigate to `../projects/[name]`
3. **Projekt von GitHub klonen** → Run `/checkout-project [repo-url]`
4. **Am Template arbeiten** → Only for template improvements

## Workflow: New Project

If user wants to create a new project:

1. Ask for project name (kebab-case, e.g., `customer-portal`)
2. Run the scaffolding script:
   ```bash
   ./scripts/create-agent-project.sh [project-name]
   ```
3. The script creates the project in `../projects/[project-name]/`
4. **IMPORTANT:** Tell the user to start a new Claude session:
   ```
   Project created at: ../projects/[project-name]/

   To continue working:
   1. Open a new terminal
   2. Run: cd ../projects/[project-name] && claude

   Or if using VS Code with Claude extension:
   1. Open the project folder in VS Code
   2. Start Claude from there
   ```

## Workflow: Open Existing Project

If user wants to open an existing project:

1. List available projects:
   ```bash
   ls ../projects/
   ```
2. Let user choose which project
3. **IMPORTANT:** Tell the user to start a new Claude session:
   ```
   To work on [project-name]:

   1. Open a new terminal
   2. Run: cd ../projects/[project-name] && claude
   ```

## Workflow: Clone from GitHub

If user wants to clone a project:

1. Ask for repository URL
2. Ask for project name (or derive from repo)
3. Clone into projects folder:
   ```bash
   mkdir -p ../projects
   git clone [repo-url] ../projects/[project-name]
   ```
4. **IMPORTANT:** Tell the user to start a new Claude session:
   ```
   Project cloned to: ../projects/[project-name]/

   To continue working:
   1. Open a new terminal
   2. Run: cd ../projects/[project-name] && claude
   ```

## Workflow: Template Work

If user wants to work on the template itself:

1. Confirm this is intentional:
   ```
   Du möchtest am Agent-Kit Template selbst arbeiten?
   Das ist nur für:
   - Neue Skills hinzufügen
   - Boilerplate verbessern
   - Dokumentation aktualisieren

   Domain-spezifische Arbeit gehört in downstream Projekte.
   ```
2. If confirmed, run `/prime` to load template context

## Key Principle

**Claude sessions are directory-bound.** A session started in `lucidlabs-agent-kit/` works on the template. To work on a project, the user must start a new Claude session in that project's directory.

## Output Template

After determining what the user wants, provide clear instructions:

```markdown
## Nächste Schritte

**Projekt:** [project-name]
**Pfad:** ../projects/[project-name]/

### Für neues Terminal:
\`\`\`bash
cd ../projects/[project-name] && claude
\`\`\`

### Für VS Code:
1. Öffne den Ordner `../projects/[project-name]/` in VS Code
2. Starte Claude über die Command Palette

---

Sobald du im Projekt bist, nutze `/prime` um den Kontext zu laden.
```
