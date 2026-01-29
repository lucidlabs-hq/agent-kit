# Project Templates

Pre-configured project templates for rapid development.

## Available Templates

| Template | Description | Stack |
|----------|-------------|-------|
| **fullstack-convex-mastra** | AI-powered full-stack app | Next.js + Convex + Mastra + Better Auth |

## Usage

### Via `/init-project` Skill

```bash
/init-project
# Select: fullstack-convex-mastra
```

### Manual Setup

```bash
cd templates/fullstack-convex-mastra
./setup.sh my-project ~/projects
```

## Template Structure

Each template contains:

```
template-name/
├── README.md           # Template documentation
├── template.json       # Configuration & metadata
├── setup.sh            # Setup script
├── frontend/           # Frontend source files
├── mastra/             # Mastra source files
└── .claude/            # Claude Code skills
```

## Creating New Templates

1. Create directory: `templates/my-template/`
2. Add `template.json` with metadata
3. Add `README.md` with documentation
4. Add `setup.sh` for automated setup
5. Include source files

### template.json Schema

```json
{
  "name": "template-name",
  "displayName": "Display Name",
  "description": "Template description",
  "version": "1.0.0",
  "stack": {
    "frontend": { ... },
    "backend": { ... }
  },
  "services": {
    "service-name": {
      "docker": "image:tag",
      "port": 3000
    }
  },
  "features": [ ... ]
}
```

---

**Maintainer:** Lucid Labs GmbH
**Updated:** January 2026
