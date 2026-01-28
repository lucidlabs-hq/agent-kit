---
name: publish-skill
description: Publish local skills to central repository for team sharing. Use when you've developed a useful pattern others should have.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, AskUserQuestion
argument-hint: [skill-name]
---

# Publish Skill

Share your locally developed skills with the team by publishing to the central repository.

---

## Usage

```bash
/publish-skill [skill-name]         # Publish specific skill
/publish-skill --list-local         # List local skills not in central repo
/publish-skill [skill-name] --to [repo]  # Publish to custom repository
```

---

## When to Publish

Publish a skill when:
- You've developed something useful that others could use
- The skill is **generic** (not project-specific)
- It's tested and documented
- It follows the SKILL.md format

**DO NOT publish:**
- Project-specific skills (customer logic, domain code)
- Incomplete or untested skills
- Skills with hardcoded credentials or paths

---

## Process

### Step 1: List Publishable Skills

```bash
/publish-skill --list-local
```

**Output:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  LOCAL SKILLS (not in central repo)                                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  [1] pdf-analyzer        Analyze PDF documents with AI                          │
│  [2] email-classifier    Classify incoming emails by intent                     │
│  [3] meeting-notes       Extract action items from meeting transcripts          │
│                                                                                  │
│  Already in central repo:                                                        │
│  - prime, session-end, commit, execute, linear, ...                             │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Publish: /publish-skill [name]                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Step 2: Publish Skill

```bash
/publish-skill pdf-analyzer
```

**Validation Checklist:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  PUBLISH SKILL: pdf-analyzer                                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  PRE-PUBLISH CHECKLIST                                                           │
│  ─────────────────────                                                           │
│                                                                                  │
│  [x] Has valid YAML frontmatter                                                 │
│  [x] Has name and description                                                   │
│  [x] Has usage examples                                                         │
│  [x] No hardcoded paths or credentials                                          │
│  [x] No project-specific logic                                                  │
│  [ ] Has been tested                                                            │
│                                                                                  │
│  ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                  │
│  Confirm: Has this skill been tested? [Y/n]                                     │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Step 3: Create Pull Request

After confirmation, the skill creates a PR:

```bash
# Fork/clone central repo if needed
# Create branch
git checkout -b skill/pdf-analyzer

# Copy skill
cp -r .claude/skills/pdf-analyzer ../agent-kit/.claude/skills/

# Commit and push
git add .
git commit -m "feat(skills): add pdf-analyzer skill"
git push origin skill/pdf-analyzer

# Create PR
gh pr create --title "feat(skills): add pdf-analyzer skill" \
  --body "## New Skill: pdf-analyzer

### Description
Analyze PDF documents with AI

### Usage
\`\`\`
/pdf-analyzer [file.pdf]
\`\`\`

### Checklist
- [x] Tested locally
- [x] Generic (not project-specific)
- [x] Documented
"
```

**Output:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  SKILL PUBLISHED                                                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  Skill:     pdf-analyzer                                                         │
│  Target:    lucidlabs-hq/agent-kit                                              │
│  Branch:    skill/pdf-analyzer                                                   │
│  PR:        https://github.com/lucidlabs-hq/agent-kit/pull/42                   │
│                                                                                  │
│  Status:    Awaiting Review                                                      │
│                                                                                  │
│  ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                  │
│  Next Steps:                                                                     │
│  1. Team reviews the PR                                                          │
│  2. After merge, skill is available via /clone-skill                            │
│  3. All projects can now use it!                                                │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Skill Quality Guidelines

### Required

| Element | Description |
|---------|-------------|
| **Frontmatter** | Valid YAML with name, description |
| **Description** | Clear explanation of what the skill does |
| **Usage** | Examples showing how to invoke |
| **Process** | Step-by-step instructions |

### Recommended

| Element | Description |
|---------|-------------|
| **Error Handling** | Common errors and solutions |
| **Examples** | Multiple use case examples |
| **Output** | Sample output format |
| **Related** | Links to related skills |

### Forbidden

| Element | Reason |
|---------|--------|
| Hardcoded paths | Won't work on other machines |
| API keys/secrets | Security risk |
| Customer names | Privacy |
| Project-specific logic | Not reusable |

---

## Publish to Custom Repository

```bash
/publish-skill crm-sync --to myorg/internal-skills
```

Useful for:
- Team-internal skills not for public sharing
- Customer-specific skill collections
- Experimental skills

---

## The Skill Sharing Cycle

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          SKILL SHARING CYCLE                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│                        CENTRAL REPOSITORY                                        │
│                     lucidlabs-hq/agent-kit                                      │
│                              │                                                   │
│              ┌───────────────┼───────────────┐                                  │
│              │               │               │                                  │
│              ▼               ▼               ▼                                  │
│         ┌─────────┐    ┌─────────┐    ┌─────────┐                              │
│         │Project A│    │Project B│    │Project C│                              │
│         └────┬────┘    └────┬────┘    └────┬────┘                              │
│              │              │              │                                    │
│              │         Developer          │                                    │
│              │         creates            │                                    │
│              │         cool skill         │                                    │
│              │              │              │                                    │
│              │              ▼              │                                    │
│              │     /publish-skill         │                                    │
│              │              │              │                                    │
│              │              ▼              │                                    │
│              │         PR + Review        │                                    │
│              │              │              │                                    │
│              │              ▼              │                                    │
│              │      Merged to Central     │                                    │
│              │              │              │                                    │
│              ▼              ▼              ▼                                    │
│         /clone-skill   Available!    /clone-skill                              │
│                                                                                  │
│  ─────────────────────────────────────────────────────────────────────────────  │
│                                                                                  │
│  RESULT: One developer's good idea benefits ALL projects!                       │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Error Handling

| Error | Solution |
|-------|----------|
| "Skill not found" | Check skill exists in `.claude/skills/` |
| "Already in central" | Skill already published, use `/sync` instead |
| "Auth failed" | Run `gh auth login` |
| "PR creation failed" | Check GitHub permissions |

---

## Examples

```bash
# List local skills not yet published
/publish-skill --list-local

# Publish a skill
/publish-skill pdf-analyzer

# Publish to internal repo
/publish-skill secret-handler --to lucidlabs-hq/internal-skills

# Force republish (update existing)
/publish-skill linear --force
```

---

## Related

- `/clone-skill` - Get skills from central repository
- `/promote` - Promote other patterns (not just skills)
- `/sync` - Sync all updates from upstream
