# Document Maintenance Guide

> Guidelines for maintaining documentation: update frequency, version control, and contributing.

---

## Table of Contents

1. [Document Structure](#1-document-structure)
2. [Update Frequency](#2-update-frequency)
3. [Version Control](#3-version-control)
4. [Contributing](#4-contributing)
5. [Review Process](#5-review-process)

---

## 1. Document Structure

### Documentation Hierarchy

```
CLAUDE.md                           # Main boilerplate (read first)
.cursorrules                        # Cursor IDE rules (auto-loaded)
.claude/
├── settings.md                     # Claude Code detailed settings
├── PRD.md                          # Product Requirements (project-specific)
├── commands/                       # Slash commands (project-specific)
└── reference/                      # Technical references
    ├── architecture.md             # System overview
    ├── data-model.md               # Database schema
    ├── design-system.md            # UI/UX guidelines
    ├── mastra-best-practices.md    # AI agents
    ├── error-handling.md           # Error patterns
    ├── database-strategy.md        # PostgreSQL-first
    ├── auth-setup.md               # BetterAuth
    ├── cursor-patterns.md          # AI dev guidelines
    ├── testing-and-logging.md      # Tests & logging
    ├── deployment-best-practices.md # Docker & Elestio
    ├── scaling.md                  # Scaling patterns
    └── document-maintenance.md     # This file
```

### Document Purpose

| Document | Purpose | Audience |
|----------|---------|----------|
| `CLAUDE.md` | Tech stack, code standards, quick reference | All developers |
| `PRD.md` | Product requirements, features, domain | Product & Dev |
| `.cursorrules` | IDE auto-rules | Cursor users |
| `.claude/settings.md` | Detailed AI guidelines | Claude Code |
| `reference/*.md` | Deep technical guides | Developers |

---

## 2. Update Frequency

### Recommended Schedule

| Document | Update Frequency | Trigger |
|----------|------------------|---------|
| **PRD.md** | When requirements change | New features, scope changes |
| **CLAUDE.md** | Monthly | Tech stack updates, new patterns |
| **design-system.md** | When components added | New UI patterns |
| **data-model.md** | When schema changes | DB migrations |
| **deployment-best-practices.md** | Quarterly | Infrastructure changes |
| **Other references** | As needed | Pattern changes, new learnings |

### Update Triggers

**Immediate Update Required:**
- New feature introduces new pattern
- Bug caused by outdated documentation
- Security-related changes
- Breaking API changes

**Regular Review (Monthly):**
- Check for outdated information
- Verify code examples still work
- Update version numbers
- Remove deprecated content

---

## 3. Version Control

### Version Numbering

Use semantic versioning for documents:

```
Major.Minor (e.g., 2.0, 2.1, 2.2)

Major: Breaking changes, major restructuring
Minor: New sections, significant updates
```

### Document Header Template

Every document should include:

```markdown
# Document Title

> Brief description of the document

**Version:** 2.1
**Last Updated:** January 2026
**Maintainer:** KI-Schmiede

---
```

### Change Tracking

**Option 1: Inline Changelog**

```markdown
## Changelog

### v2.1 (January 2026)
- Added scaling patterns section
- Updated Docker examples

### v2.0 (December 2025)
- Major restructure for neutral boilerplate
- Removed project-specific content
```

**Option 2: Git Commit Messages**

Use descriptive commit messages:

```bash
docs: update design-system.md with new component patterns
docs: add scaling.md reference
docs(PRD): update MVP scope for phase 2
```

### Breaking Changes

Document breaking changes clearly:

```markdown
## Breaking Changes

### v2.0 (December 2025)

**BREAKING:** Renamed `AGENTS.md` to `CLAUDE.md`
- Update all references in your workflow
- Claude Code now uses `CLAUDE.md` as default

**BREAKING:** Moved technical details to reference/
- Architecture details now in `reference/architecture.md`
- Data model details now in `reference/data-model.md`
```

---

## 4. Contributing

### When to Update Documentation

**Always update docs when:**
- New feature is implemented
- Design pattern changes
- Bug is caused by missing documentation
- Requirements evolve
- Tech stack is updated

### How to Update

1. **Edit the relevant document**
2. **Update version number** (if significant change)
3. **Add "Last Updated" date**
4. **Update changelog** (if using inline changelog)
5. **Update cross-references** (if structure changes)
6. **Update CLAUDE.md** (if new reference added)

### Document Quality Checklist

- [ ] Clear and concise?
- [ ] Code examples work?
- [ ] Links are valid?
- [ ] No outdated information?
- [ ] Follows document structure?
- [ ] Version updated?
- [ ] Cross-references updated?

### Writing Guidelines

**DO:**
- Use clear, simple language
- Include working code examples
- Use tables for comparison
- Keep sections focused
- Link to related documents

**DON'T:**
- Duplicate information (link instead)
- Include project-specific details in boilerplate
- Use jargon without explanation
- Leave TODO comments in final docs

---

## 5. Review Process

### Self-Review Checklist

Before committing documentation changes:

- [ ] Accurate information?
- [ ] Code examples tested?
- [ ] No typos or grammar errors?
- [ ] Consistent formatting?
- [ ] Version number updated?
- [ ] Last Updated date set?
- [ ] Cross-references valid?

### Peer Review

For significant changes:

1. Create PR with documentation changes
2. Request review from team member
3. Address feedback
4. Merge after approval

### Annual Audit

**Once per year:**
- Review all documents for relevance
- Remove deprecated content
- Update outdated examples
- Consolidate duplicate information
- Archive obsolete documents

---

## Questions?

If you have questions about documentation:

1. **Check the relevant document first**
2. **Review CLAUDE.md** for overview
3. **Check reference/** for technical details
4. **Ask the team** for clarification

---

**Version:** 1.0
**Last Updated:** January 2026
**Maintainer:** KI-Schmiede
