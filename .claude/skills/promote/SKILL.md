---
name: promote
description: Promote generic patterns from this project back to the upstream agent-kit. Use when you have reusable patterns to share.
disable-model-invocation: true
allowed-tools: Bash, Read
argument-hint: [--dry-run]
---

# Promote Patterns to Upstream

Promote generic, reusable patterns from this downstream project back to the upstream agent-kit template.

## Expected Folder Structure

```
lucidlabs/
├── lucidlabs-agent-kit/        # Upstream template
└── projects/
    └── [this-project]/         # You are here (downstream)
```

## Quick Start

```bash
# Run promotion script (default path: ../../lucidlabs-agent-kit)
./scripts/promote.sh --upstream ../../lucidlabs-agent-kit

# Preview only (dry run)
./scripts/promote.sh --upstream ../../lucidlabs-agent-kit --dry-run

# Custom upstream path (if different structure)
./scripts/promote.sh --upstream /path/to/agent-kit
```

## What Gets Promoted

| Promotable | Description |
|------------|-------------|
| `.claude/skills/*` | Claude Code skills |
| `.claude/reference/*` | Best practice documentation |
| `frontend/components/ui/*` | Generic UI components |
| `frontend/lib/utils.ts` | Utility functions |
| `frontend/lib/hooks/*` | Generic React hooks |
| `scripts/*` | Utility scripts |

## What Does NOT Get Promoted

| Blacklisted | Reason |
|-------------|--------|
| `.claude/PRD.md` | Project-specific requirements |
| `frontend/app/*` | Project-specific pages |
| `mastra/src/agents/*` | Domain-specific agents |
| `convex/*` | Project-specific database |

## Promotion Flow

**WICHTIG: Promotions gehen IMMER über Pull Requests, NIE direkt auf main!**

**WICHTIG: VOR jeder Promotion MUSS ein Abgleich mit Upstream erfolgen!**

```
1. FETCH     → Upstream holen: git fetch origin (PFLICHT!)
2. DIFF      → Änderungen prüfen: Hat sich upstream was geändert? (PFLICHT!)
3. SYNC      → Falls Änderungen: Erst downstream syncen
4. DETECT    → Promotable Änderungen finden
5. SELECT    → Auswählen was promoted wird
6. BRANCH    → Feature Branch im Upstream erstellen
7. COPY      → Dateien übertragen
8. PR        → Pull Request erstellen (PFLICHT!)
9. REVIEW    → Code Review durch Team
10. MERGE    → Nach Approval mergen
```

### Step 1-3: Upstream-Abgleich (PFLICHT vor jeder Promotion!)

```bash
# Im Upstream Repo
cd /path/to/lucidlabs-agent-kit

# 1. FETCH - Aktuellen Stand holen
git fetch origin

# 2. DIFF - Prüfen ob Änderungen seit letztem Sync
git log HEAD..origin/main --oneline

# Wenn Ausgabe NICHT leer:
# → Es gibt neue Commits im Upstream!
# → ERST syncen, DANN promoten
```

**Wenn Upstream-Änderungen existieren:**

```
╔════════════════════════════════════════════════════════════════╗
║  ⚠️  UPSTREAM HAT NEUE ÄNDERUNGEN                              ║
╠════════════════════════════════════════════════════════════════╣
║                                                                 ║
║  Seit deinem letzten Sync wurden 3 Commits gemacht:            ║
║                                                                 ║
║  abc1234 feat: add new skill                                   ║
║  def5678 docs: update readme                                   ║
║  ghi9012 fix: typo in reference                                ║
║                                                                 ║
║  AKTION ERFORDERLICH:                                          ║
║  1. Führe /sync aus um Downstream zu aktualisieren             ║
║  2. Teste ob alles funktioniert                                ║
║  3. Dann erst /promote ausführen                               ║
║                                                                 ║
╚════════════════════════════════════════════════════════════════╝
```

**Wenn keine Änderungen:**

```
✓ Upstream ist aktuell. Promotion kann fortfahren.
```

### Warum kein direkter Push?

| Direkter Push | Pull Request |
|---------------|--------------|
| ❌ Keine Review | ✅ Code wird geprüft |
| ❌ Konflikte möglich | ✅ Konflikte vor Merge sichtbar |
| ❌ Fehler gehen direkt live | ✅ CI/CD Tests laufen |
| ❌ Keine Dokumentation | ✅ PR dokumentiert Änderung |

## Domain Keyword Warning

The script warns if files contain domain-specific keywords like:
- `ticket`, `customer`, `invoice`, `order`
- `product`, `user`, `account`, `payment`

These indicate the code may not be generic enough for the template.

## Options

| Option | Description |
|--------|-------------|
| `--upstream PATH` | Path to agent-kit (required) |
| `--dry-run` | Preview without changes |
| `--all` | Promote all without selection |
| `--help` | Show help |

## Example Session

```
╔════════════════════════════════════════════════════════════════╗
║              PATTERN PROMOTION                                 ║
╚════════════════════════════════════════════════════════════════╝

ℹ Downstream: ~/coding/repos/lucidlabs/projects/customer-portal
ℹ Upstream:   ~/coding/repos/lucidlabs/lucidlabs-agent-kit

▶ Step 1: Scanning for promotable changes...

Promotable changes found:

  [1] .claude/skills/code-review/SKILL.md (NEW)
  [2] .claude/reference/api-patterns.md (NEW)
  [3] frontend/components/ui/data-table.tsx (MODIFIED)

Enter numbers to promote (e.g., 1,2 or 'all'): 1,2

▶ Step 2: Checking upstream main status...

  Last commit: abc1234 "docs: update readme" (2 hours ago)
  Your local:  In sync ✓

▶ Step 3: Creating promotion branch...

  Branch: promote/20260128-code-review-api-patterns

▶ Step 4: Copying files to upstream...

  ✔ Copied: .claude/skills/code-review/SKILL.md
  ✔ Copied: .claude/reference/api-patterns.md

▶ Step 5: Creating Pull Request...

  ✔ Branch pushed: promote/20260128-code-review-api-patterns
  ✔ PR created: https://github.com/lucidlabs-hq/agent-kit/pull/42

╔════════════════════════════════════════════════════════════════╗
║  ✓ PROMOTION COMPLETE                                          ║
║                                                                 ║
║  PR: https://github.com/lucidlabs-hq/agent-kit/pull/42         ║
║                                                                 ║
║  Next steps:                                                    ║
║  1. Review the PR                                               ║
║  2. Request team review if needed                               ║
║  3. Merge after approval                                        ║
╚════════════════════════════════════════════════════════════════╝
```

## Manuelle Promotion (Schritt für Schritt)

Falls das Script nicht verfügbar ist:

```bash
# 1. Upstream aktualisieren
cd /path/to/lucidlabs-agent-kit
git fetch origin
git checkout main
git pull origin main

# 2. Promotion Branch erstellen
git checkout -b promote/$(date +%Y%m%d)-pattern-name

# 3. Dateien kopieren
cp /path/to/downstream/.claude/skills/my-skill/SKILL.md .claude/skills/my-skill/

# 4. Committen
git add .
git commit -m "feat: promote [pattern] from [project]"

# 5. Branch pushen
git push -u origin promote/$(date +%Y%m%d)-pattern-name

# 6. PR erstellen (PFLICHT!)
gh pr create --title "Promote: [Pattern Name]" --body "..."
```

**⚠️ NIEMALS `git push origin main` im Upstream!**

## When to Promote

Promote patterns when:
- You created a reusable skill that could help other projects
- You built a generic UI component with no domain logic
- You documented a best practice others should follow
- You wrote utility functions that are project-agnostic

Do NOT promote:
- Project-specific configurations
- Domain logic or business rules
- Database schemas
- App pages or routes

## Related Commands

| Direction | Command | Description |
|-----------|---------|-------------|
| Downstream → Upstream | `/promote` | This skill |
| Upstream → Downstream | `./scripts/sync-upstream.sh` | Pull updates from template |

## Best Practices

1. **Review before promoting** - Ensure code is truly generic
2. **Remove domain references** - Clean up project-specific names
3. **Test in isolation** - Verify patterns work without project context
4. **Document changes** - Add comments explaining the pattern
5. **Small promotions** - Promote one pattern at a time for easier review
6. **IMMER PRs verwenden** - Nie direkt auf main pushen

---

## Schutz vor direktem Push

### GitHub Branch Protection (empfohlen)

Aktiviere Branch Protection für `main` im Agent Kit:

```bash
# Via GitHub CLI
gh repo edit lucidlabs-hq/agent-kit --enable-branch-protection

# Oder via GitHub UI:
# Settings → Branches → Add rule → main
# ✓ Require pull request before merging
# ✓ Require approvals (1)
```

### Claude Verhalten

**Bei Promotions prüft Claude automatisch:**

1. Ist dies das Upstream-Repo?
2. Bin ich auf `main`?
3. → Wenn ja: Branch erstellen, NICHT direkt pushen

```
IF upstream AND on_main THEN
  → create branch
  → commit to branch
  → create PR
  → NEVER push to main directly
```

### Fehlermeldung bei direktem Push-Versuch

Wenn jemand versucht direkt zu pushen (und Branch Protection aktiv):

```
remote: error: GH006: Protected branch update failed
remote: At least 1 approving review is required
```

---

## Checkliste vor Promotion

```markdown
## Pre-Promotion Checklist

- [ ] Ist das Pattern wirklich generisch?
- [ ] Keine Domain-Keywords (invoice, customer, etc.)?
- [ ] Upstream main ist aktuell (`git fetch && git status`)?
- [ ] Feature Branch erstellt (nicht auf main)?
- [ ] PR wird erstellt (nicht direkter Push)?
- [ ] PR Description erklärt das Pattern?
```
