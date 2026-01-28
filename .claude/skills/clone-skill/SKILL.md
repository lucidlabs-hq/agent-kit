---
name: clone-skill
description: Clone skills from central repository or import from clipboard. Use to add proven patterns to your project.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, AskUserQuestion
argument-hint: [skill-name] or --list or --import
---

# Clone Skill

Clone skills from the central Lucid Labs skills repository or import from clipboard.

---

## Usage

```bash
/clone-skill [skill-name]           # Clone specific skill from central repo
/clone-skill --list                 # List all available skills
/clone-skill --import               # Import skill from clipboard (Cloud export)
/clone-skill [name] --from [repo]   # Clone from custom repository
```

---

## Option A: Clone from GitHub (Recommended)

### List Available Skills

```bash
/clone-skill --list
```

**Output:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  AVAILABLE SKILLS                                        lucidlabs-hq/agent-kit │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  CORE                                                                            │
│  ────                                                                            │
│  prime              Load project context, start session                          │
│  session-end        End session, update Linear, clean state                      │
│  commit             Create formatted git commit                                  │
│                                                                                  │
│  PLANNING                                                                        │
│  ────────                                                                        │
│  create-prd         Create Product Requirements Document                         │
│  plan-feature       Plan feature implementation                                  │
│  init-project       Initialize new project from template                         │
│                                                                                  │
│  IMPLEMENTATION                                                                  │
│  ──────────────                                                                  │
│  execute            Execute implementation plan                                  │
│  n8n-workflow       Generate n8n workflows for agents                           │
│                                                                                  │
│  VALIDATION                                                                      │
│  ──────────                                                                      │
│  visual-verify      UI verification via agent-browser                           │
│  pre-production     Security & Quality Check before deploy                       │
│                                                                                  │
│  INTEGRATION                                                                     │
│  ───────────                                                                     │
│  linear             Linear project management                                    │
│  productizer        Bridge Linear to Productive.io                              │
│  notion-publish     Publish markdown to Notion                                   │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Clone: /clone-skill [name]                                                      │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Clone Specific Skill

```bash
/clone-skill pdf-analyzer
```

**Process:**

1. Fetch skill from `lucidlabs-hq/agent-kit` (or configured repo)
2. Check if skill already exists locally
3. Copy to `.claude/skills/[skill-name]/`
4. Confirm success

**Implementation:**

```bash
# Default source repository
SKILLS_REPO="lucidlabs-hq/agent-kit"
SKILLS_PATH=".claude/skills"

# Clone skill
SKILL_NAME="$1"
TARGET_DIR=".claude/skills/$SKILL_NAME"

# Check if exists
if [ -d "$TARGET_DIR" ]; then
  echo "Skill '$SKILL_NAME' already exists. Overwrite? [y/N]"
  # Handle response
fi

# Fetch from GitHub
gh api repos/$SKILLS_REPO/contents/$SKILLS_PATH/$SKILL_NAME/SKILL.md \
  --jq '.content' | base64 -d > "$TARGET_DIR/SKILL.md"
```

**Output:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  SKILL CLONED                                                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  Skill:     pdf-analyzer                                                         │
│  Source:    lucidlabs-hq/agent-kit                                              │
│  Location:  .claude/skills/pdf-analyzer/SKILL.md                                │
│                                                                                  │
│  Usage:     /pdf-analyzer [file.pdf]                                            │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Clone from Custom Repository

```bash
/clone-skill email-parser --from lucidlabs-hq/customer-skills
```

---

## Option B: Import from Clipboard (Cloud Export)

For skills stored in Claude.ai Cloud Projects that don't have API access.

### Export from Claude.ai

1. Open Claude.ai → Projects → Your Project
2. Find the skill/instruction
3. Copy the content

### Import Locally

```bash
/clone-skill --import
```

**Process:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  IMPORT SKILL FROM CLIPBOARD                                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  Skill Name: _                                                                   │
│                                                                                  │
│  (Enter a kebab-case name like 'pdf-analyzer')                                  │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

After entering name:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  PASTE SKILL CONTENT                                                             │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  Paste the skill content from Claude.ai Cloud.                                  │
│                                                                                  │
│  The content should include:                                                     │
│  - YAML frontmatter (---)                                                        │
│  - Skill instructions                                                            │
│                                                                                  │
│  Press Enter twice when done.                                                    │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Validation:**

- Check for valid YAML frontmatter
- Ensure `name` and `description` exist
- Create directory structure
- Save as SKILL.md

**Output:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  SKILL IMPORTED                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  Skill:     meeting-notes                                                        │
│  Location:  .claude/skills/meeting-notes/SKILL.md                               │
│  Source:    Clipboard (Cloud Export)                                            │
│                                                                                  │
│  Tip: Use /publish-skill to share with the team                                 │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Configuration

### Set Default Repository

Skills are cloned from `lucidlabs-hq/agent-kit` by default.

To use a different default:

```bash
# In project root, create .skills-config
echo "SKILLS_REPO=lucidlabs-hq/custom-skills" > .skills-config
```

### Repository Structure

The source repository must have this structure:

```
.claude/
└── skills/
    ├── skill-name-1/
    │   └── SKILL.md
    ├── skill-name-2/
    │   └── SKILL.md
    └── ...
```

---

## Error Handling

| Error | Solution |
|-------|----------|
| "Skill not found" | Check spelling, use `--list` to see available |
| "Already exists" | Use `--force` to overwrite or rename |
| "Auth failed" | Run `gh auth login` for GitHub access |
| "Invalid format" | Ensure SKILL.md has valid YAML frontmatter |

---

## Examples

```bash
# List all available skills
/clone-skill --list

# Clone a skill
/clone-skill visual-verify

# Clone from custom repo
/clone-skill crm-sync --from myorg/my-skills

# Import from Claude.ai Cloud
/clone-skill --import

# Force overwrite existing
/clone-skill linear --force
```

---

## Related

- `/publish-skill` - Share your skills with the team
- `/sync` - Sync all updates from upstream
- `/promote` - Promote patterns to upstream
