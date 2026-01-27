# Agent Kit Skills

Skills extend Claude's capabilities in this project. Each skill is a directory with a `SKILL.md` file.

## Available Skills

| Skill | Description | PIV Phase |
|-------|-------------|-----------|
| `/create-prd` | Create Product Requirements Document | Planning |
| `/plan-feature` | Plan feature implementation | Planning |
| `/execute` | Execute implementation plan | Implementation |
| `/commit` | Create formatted git commit | Implementation |
| `/prime` | Load project context | Any |
| `/init-project` | Initialize new project | Planning |
| `/screenshot` | Visual verification screenshots | Validation |
| `/update-readme` | Update README file | Implementation |
| `/promote` | Promote patterns to upstream | Any |

## Skill Format (Claude Code v2.1.3+)

Each skill uses the SKILL.md format with YAML frontmatter:

```yaml
---
name: skill-name
description: What this skill does and when to use it
disable-model-invocation: true
allowed-tools: Read, Write, Bash
argument-hint: [args]
---

# Instructions

[Markdown content with instructions for Claude]
```

## Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Display name (defaults to directory name) |
| `description` | Yes | What the skill does and when to use it |
| `disable-model-invocation` | No | `true` = only user can invoke |
| `allowed-tools` | No | Tools Claude can use without asking |
| `argument-hint` | No | Hint for autocomplete (e.g., `[feature-name]`) |
| `context` | No | `fork` to run in subagent |
| `agent` | No | Subagent type (Explore, Plan, general-purpose) |

## Creating New Skills

1. Create directory: `.claude/skills/my-skill/`
2. Create `SKILL.md` with frontmatter + instructions
3. Optionally add supporting files:
   - `template.md` - Templates for Claude to fill
   - `examples/` - Example outputs
   - `scripts/` - Utility scripts

## Skill vs Mastra Tool

| Concept | What It Is | Location |
|---------|-----------|----------|
| **Claude Code Skill** | Instructions/prompts for Claude | `.claude/skills/` |
| **Mastra Tool** | Executable code for AI agents | `mastra/src/tools/` |

Skills guide Claude's behavior. Mastra tools are actual code implementations.

## Documentation

- [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
- [Agent Skills Standard](https://agentskills.io)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
