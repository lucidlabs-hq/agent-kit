---
name: checkout-project
description: Clone an existing project from GitHub into the projects folder. Use when starting work on an existing downstream project.
disable-model-invocation: true
allowed-tools: Bash, Read
argument-hint: [repo-url-or-name]
---

# Checkout Project: Clone from GitHub

Clone an existing downstream project from GitHub into the correct folder structure.

## Arguments

**$ARGUMENTS** can be:
- Full GitHub URL: `https://github.com/lucidlabs-hq/customer-portal`
- Short form: `lucidlabs-hq/customer-portal`
- Just the project name (if repo follows naming convention): `customer-portal`

## Expected Folder Structure

After checkout:

```
lucidlabs/
├── lucidlabs-agent-kit/        ← You are here
└── projects/
    └── [project-name]/         ← Project will be cloned here
```

## Process

### Step 1: Parse Repository URL

```bash
# If full URL
REPO_URL="$ARGUMENTS"

# If short form (org/repo)
REPO_URL="git@github.com:$ARGUMENTS.git"

# Derive project name from URL
PROJECT_NAME=$(basename "$REPO_URL" .git)
```

### Step 2: Ensure Projects Directory Exists

```bash
mkdir -p ../projects
```

### Step 3: Check if Project Already Exists

```bash
if [ -d "../projects/$PROJECT_NAME" ]; then
    echo "Project already exists at ../projects/$PROJECT_NAME"
    echo "To update, navigate there and run: git pull"
    exit 1
fi
```

### Step 4: Clone the Repository

```bash
git clone "$REPO_URL" "../projects/$PROJECT_NAME"
```

### Step 5: Verify Clone Success

```bash
ls -la "../projects/$PROJECT_NAME"
```

## Output

After successful clone, provide these instructions:

```markdown
## Projekt geklont

**Projekt:** [project-name]
**Pfad:** ../projects/[project-name]/

### Nächste Schritte

1. **Neues Terminal öffnen und dort arbeiten:**
   \`\`\`bash
   cd ../projects/[project-name] && claude
   \`\`\`

2. **Dependencies installieren:**
   \`\`\`bash
   cd frontend && pnpm install
   \`\`\`

3. **Kontext laden:**
   \`\`\`
   /prime
   \`\`\`

---

**Hinweis:** Claude Sessions sind verzeichnisgebunden.
Starte eine neue Session im Projektordner, um dort zu arbeiten.
```

## Error Handling

### Repository Not Found

```
Fehler: Repository nicht gefunden.

Überprüfe:
1. Ist die URL korrekt?
2. Hast du Zugriff auf das Repository?
3. SSH-Key konfiguriert? (für git@github.com URLs)

Versuche:
- Mit HTTPS: git clone https://github.com/org/repo.git
- SSH prüfen: ssh -T git@github.com
```

### Permission Denied

```
Fehler: Zugriff verweigert.

Das Repository existiert, aber du hast keinen Zugriff.
Kontaktiere den Repository-Owner für Zugang.
```

## Quick Reference

| Input | Interpreted As |
|-------|----------------|
| `customer-portal` | `git@github.com:lucidlabs-hq/customer-portal.git` |
| `lucidlabs-hq/my-project` | `git@github.com:lucidlabs-hq/my-project.git` |
| `https://github.com/org/repo` | `https://github.com/org/repo.git` |
| `git@github.com:org/repo.git` | Used as-is |
