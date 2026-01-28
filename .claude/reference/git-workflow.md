# Git Workflow Best Practices

> **Purpose:** Definiert den Git-Workflow für Solo-Entwicklung und Team-Arbeit.

---

## Workflow-Modi

### Solo-Entwicklung (1 Person)

```
Direkt auf main arbeiten ist OK
├── Schneller
├── Weniger Overhead
└── Aber: Disziplin bei Commits nötig
```

### Team-Entwicklung (2+ Personen)

```
NIEMALS direkt auf main pushen!
├── Feature Branches verwenden
├── Pull Requests für alle Änderungen
├── Code Review vor Merge
└── Main ist immer deployable
```

---

## Team-Workflow (Branch + PR)

### 1. Neuen Branch erstellen

```bash
# Aktuellen Stand holen
git fetch origin
git checkout main
git pull origin main

# Feature Branch erstellen
git checkout -b feat/feature-name
# oder
git checkout -b fix/bug-description
```

**Branch-Naming:**
| Prefix | Use Case |
|--------|----------|
| `feat/` | Neue Features |
| `fix/` | Bug Fixes |
| `docs/` | Dokumentation |
| `refactor/` | Code Refactoring |
| `chore/` | Maintenance, Dependencies |

### 2. Änderungen committen

```bash
# Änderungen staged
git add [files]

# Commit mit Message
git commit -m "feat(scope): description"
```

### 3. Branch pushen

```bash
# Ersten Push mit Upstream
git push -u origin feat/feature-name

# Weitere Pushes
git push
```

### 4. Pull Request erstellen

```bash
# Via GitHub CLI
gh pr create --title "feat: Add feature X" --body "## Summary
- What changed
- Why

## Test Plan
- How to test"
```

**Oder via GitHub UI:**
1. GitHub Repo öffnen
2. "Compare & pull request" klicken
3. Title + Description ausfüllen
4. Reviewer zuweisen

### 5. Review & Merge

```bash
# PR Status checken
gh pr status

# PR mergen (nach Approval)
gh pr merge --squash
```

---

## Main Branch Protection

Für Team-Arbeit sollte der `main` Branch geschützt werden:

```bash
# Via GitHub CLI
gh repo edit --enable-branch-protection main

# Oder via GitHub UI:
# Settings → Branches → Add rule → main
```

**Empfohlene Regeln:**
- [ ] Require pull request before merging
- [ ] Require approvals (1+)
- [ ] Require status checks to pass
- [ ] Require branch to be up to date

---

## Vor dem PR: Main-Stand prüfen

**WICHTIG:** Vor einem PR immer den aktuellen Main-Stand einbeziehen!

```bash
# Option 1: Rebase (sauberer History)
git fetch origin
git rebase origin/main

# Option 2: Merge (einfacher)
git fetch origin
git merge origin/main

# Konflikte lösen falls nötig
# Dann pushen
git push
```

---

## Workflow für /promote (Upstream)

Beim Promoten von Downstream → Upstream:

### 1. Upstream Stand prüfen

```bash
cd upstream-repo
git fetch origin
git log origin/main -5 --oneline
```

### 2. Promotion Branch erstellen

```bash
git checkout main
git pull origin main
git checkout -b promote/pattern-name-$(date +%Y%m%d)
```

### 3. Änderungen übertragen

```bash
# Dateien kopieren von downstream
cp ../downstream/path/to/file ./path/to/file

# Committen
git add .
git commit -m "feat: promote [pattern] from [project]"
```

### 4. PR erstellen

```bash
gh pr create \
  --title "Promote: [Pattern Name]" \
  --body "## Promoted from
- Project: [project-name]
- Reason: [why this should be in upstream]

## Changes
- [list of changes]

## Testing
- Verified in [project-name]"
```

---

## Claude Code Verhalten

### Bei Solo-Entwicklung (default)

Claude pusht direkt zu main:
```bash
git add . && git commit -m "..." && git push
```

### Bei Team-Entwicklung

Claude erstellt Branches und PRs:
```bash
git checkout -b feat/...
git add . && git commit -m "..."
git push -u origin feat/...
gh pr create ...
```

### Umschalten

In `PROJECT-CONTEXT.md`:

```yaml
git_workflow:
  mode: team  # solo | team
  require_pr: true
  branch_protection: true
```

---

## Konflikt-Vermeidung

### Regelmäßig Main einbeziehen

```bash
# Mindestens täglich
git fetch origin
git rebase origin/main
# oder
git merge origin/main
```

### Kleine, fokussierte PRs

- Ein PR = Ein Feature/Fix
- Nicht mehrere unabhängige Änderungen mischen
- Schneller zu reviewen = weniger Konflikte

### Kommunikation

- Vor größeren Refactorings: Team informieren
- Parallel-Arbeit an gleichen Files vermeiden
- Bei Konflikten: Absprechen, nicht blind mergen

---

## Quick Reference

```bash
# Neues Feature starten
git checkout main && git pull
git checkout -b feat/my-feature

# Arbeit committen
git add . && git commit -m "feat: description"

# PR erstellen
git push -u origin feat/my-feature
gh pr create

# Main-Stand einbeziehen
git fetch origin && git rebase origin/main

# PR mergen (nach Approval)
gh pr merge --squash

# Aufräumen
git checkout main && git pull
git branch -d feat/my-feature
```

---

**Version:** 1.0
**Last Updated:** January 2026
