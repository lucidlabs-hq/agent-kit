# Pattern Registry

> **Central catalog of all upstream patterns. Use when discovering patterns, checking staleness, or working with promote/sync.**
> Referenced by: promote.sh, sync-upstream.sh, pattern-list.sh
> Last Updated: February 2026

---

## What It Is

`pattern-registry.json` at the repo root catalogs every reusable pattern in the agent-kit (skills, reference docs, components, utilities, hooks, scripts). It is auto-generated — never edit manually.

---

## Key Scripts

### `scripts/pattern-registry.sh` — Generator

```bash
./scripts/pattern-registry.sh              # Generate/refresh registry
./scripts/pattern-registry.sh --dry-run    # Preview JSON, don't write
./scripts/pattern-registry.sh --quiet      # No progress output
```

When to regenerate:
- After adding/removing/renaming pattern files
- `pattern-list.sh` auto-regenerates if file is missing or >1 hour old
- `promote.sh` auto-regenerates during promotion

### `scripts/pattern-list.sh` — Discovery CLI

```bash
./scripts/pattern-list.sh                           # All patterns
./scripts/pattern-list.sh --category skill           # Filter by category
./scripts/pattern-list.sh --search "auth"            # Search name + description
./scripts/pattern-list.sh --project neola            # Staleness report
./scripts/pattern-list.sh --new-since abc1234        # Changes since commit
./scripts/pattern-list.sh --json                     # JSON output (all modes)
```

---

## Pattern Categories

| Category | Base Path | ID Example |
|----------|-----------|------------|
| skill | `.claude/skills/*/SKILL.md` | `skill/commit` |
| reference | `.claude/reference/*.md` | `reference/code-standards` |
| component | `frontend/components/ui/*.tsx` | `component/button` |
| utility | `frontend/lib/*.ts` | `utility/utils` |
| hook | `frontend/hooks/*.ts` | `hook/use-theme` |
| script | `scripts/*.sh` | `script/promote` |

Pattern ID format: `{category}/{name}` — always lowercase, derived from filename or directory name.

---

## Registry Schema (pattern-registry.json)

```json
{
  "$schema_version": "1.0.0",
  "generated_at": "ISO-8601 UTC timestamp",
  "generated_from_commit": "short SHA",
  "pattern_count": 118,
  "categories": {
    "skill": { "count": 35, "base_path": ".claude/skills" }
  },
  "patterns": [
    {
      "id": "skill/commit",
      "name": "commit",
      "category": "skill",
      "path": ".claude/skills/commit/SKILL.md",
      "description": "extracted from YAML/blockquote/auto",
      "version": "short SHA of last commit touching this file",
      "added_date": "YYYY-MM-DD",
      "last_modified": "YYYY-MM-DD",
      "size_bytes": 4805
    }
  ]
}
```

### Description Extraction

| Category | Source |
|----------|--------|
| skill | YAML frontmatter `description:` field |
| reference | First `> **bold text**` blockquote or first `#` heading |
| others | Fallback: `"{name} {category}"` |

---

## Integration Points

### promote.sh

After copying promoted files to the upstream branch, `promote.sh` calls:
```bash
update_pattern_registry()   # runs pattern-registry.sh --quiet
                             # git adds pattern-registry.json
```

The regenerated registry is included in the promotion commit and PR.

### sync-upstream.sh

Three integration points:

1. **SYNCABLE_PATHS** — `pattern-registry.json` is included, so downstream projects receive it during sync

2. **Enriched display** — The scan list shows pattern descriptions from the registry next to each file path

3. **synced_files population** — After syncing, every copied file is recorded in `.upstream-sync.json`:
   ```json
   "synced_files": {
     ".claude/skills/commit/SKILL.md": "8b71059",
     "scripts/promote.sh": "8b71059"
   }
   ```

4. **Coverage summary** — After the sync summary, shows pattern coverage:
   ```
   Pattern coverage: 85 synced / 3 stale / 30 missing of 118 total
   ```

---

## Staleness Detection

The `--project` flag compares registry versions against `synced_files`:

| State | Condition |
|-------|-----------|
| **Up-to-date** | `synced_files[path] == pattern.version` |
| **Stale** | `path` exists in `synced_files` but version differs |
| **Missing** | `path` not in `synced_files` at all |

Empty `synced_files` (legacy projects) shows everything as "missing". Running `/sync --all` populates the tracking.

---

## Rules for AI Agents

1. **Never edit `pattern-registry.json` manually.** Always use `pattern-registry.sh` to regenerate.
2. **After adding/removing pattern files**, regenerate the registry before committing.
3. **When a user asks "what patterns exist?"**, run `pattern-list.sh` instead of manually listing files.
4. **When a user asks "is my project up to date?"**, run `pattern-list.sh --project <name>`.
5. **The registry is deterministic.** Same filesystem + git state = same output (except timestamp). Safe to regenerate at any time.
6. **During promotion**, the registry update is automatic — no manual step needed.
7. **During sync**, `synced_files` population is automatic — no manual step needed.

---

## See Also

- `docs/pattern-registry.md` — Full human-readable documentation with examples
- `promote-sync.md` — Promote/sync architecture (includes registry section)
