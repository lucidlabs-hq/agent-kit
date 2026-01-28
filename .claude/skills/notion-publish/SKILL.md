---
name: notion-publish
description: Publish markdown documents to Notion as private pages. Use for sharing specs, docs, or session outputs.
disable-model-invocation: true
allowed-tools: Read, Bash, Write
argument-hint: [file.md]
---

# Notion Publish: Push Markdown to Notion

Publish markdown documents directly to Notion as private pages.

---

## IMPORTANT: Formatting Rules

When publishing to Notion:

- NO EMOJIS anywhere in the document
- Clean, clear headings (H1, H2, H3)
- No decorative elements
- Professional, technical formatting only
- Tables and code blocks are allowed
- Lists should be simple (no emoji bullets)

---

## Usage

```
/notion-publish [file.md]              # Publish specific file
/notion-publish                        # Publish from clipboard/selection
```

---

## Setup (einmalig)

### 1. Notion Integration erstellen

1. Gehe zu https://www.notion.so/my-integrations
2. "New integration" klicken
3. Name: "Agent Kit Publisher"
4. Capabilities: Read/Write content
5. Token kopieren (beginnt mit `secret_`)

### 2. Token speichern

```bash
# In ~/.claude-time/integrations.json
{
  "notion": {
    "token": "secret_xxx...",
    "default_parent_page_id": "abc123..."
  }
}
```

### 3. Parent Page freigeben

1. In Notion eine Page öffnen (z.B. "Agent Kit Docs")
2. "Share" → "Invite" → Integration "Agent Kit Publisher" hinzufügen
3. Page ID aus URL kopieren: `notion.so/Page-Name-<PAGE_ID>`

---

## Process

### 1. Datei lesen

```bash
# Lies die Markdown-Datei
CONTENT=$(cat "$FILE_PATH")
TITLE=$(head -1 "$FILE_PATH" | sed 's/^#\s*//')
```

### 2. Markdown zu Notion Blocks konvertieren

**Mapping:**

| Markdown | Notion Block Type |
|----------|-------------------|
| `# Heading` | `heading_1` |
| `## Heading` | `heading_2` |
| `### Heading` | `heading_3` |
| Paragraph | `paragraph` |
| `- item` | `bulleted_list_item` |
| `1. item` | `numbered_list_item` |
| ``` code ``` | `code` |
| `> quote` | `quote` |
| `---` | `divider` |
| `| table |` | `table` |

### 3. Notion API Call

```bash
NOTION_TOKEN=$(cat ~/.claude-time/integrations.json | jq -r '.notion.token')
PARENT_PAGE=$(cat ~/.claude-time/integrations.json | jq -r '.notion.default_parent_page_id')

curl -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{
    "parent": { "page_id": "'"$PARENT_PAGE"'" },
    "properties": {
      "title": [{ "text": { "content": "'"$TITLE"'" } }]
    },
    "children": [
      // ... converted blocks
    ]
  }'
```

---

## Output

Nach erfolgreichem Publish:

```
Published to Notion:
───────────────────────────────────────────────────────────────────────────────

Title:    Session Boot Screen Spec
URL:      https://notion.so/Session-Boot-Screen-Spec-abc123
Parent:   Agent Kit Docs
Created:  2026-01-28 18:30

───────────────────────────────────────────────────────────────────────────────
```

---

## Formatting Enforcement

Vor dem Publish wird das Dokument automatisch bereinigt:

```
CLEANUP RULES:
1. Remove all emoji characters (Unicode ranges)
2. Remove emoji shortcodes (:emoji:)
3. Replace emoji bullets with plain dashes
4. Ensure H1 is plain text (no icons)
5. Remove decorative Unicode symbols
```

**Beispiel:**

```
VORHER:
# 🚀 Session Boot Screen

## ✅ Features
- 📋 Feature 1

NACHHER:
# Session Boot Screen

## Features
- Feature 1
```

---

## Advanced Options

```
/notion-publish [file.md] --parent [page-id]    # Specific parent page
/notion-publish [file.md] --title "Custom"      # Override title
/notion-publish [file.md] --public              # Make page public (later)
```

---

## Error Handling

| Error | Solution |
|-------|----------|
| "Invalid token" | Token in integrations.json prüfen |
| "Page not found" | Parent Page mit Integration geteilt? |
| "Rate limited" | Warten, dann erneut versuchen |
| "Invalid blocks" | Markdown-Format prüfen |

---

## Security

- Token wird lokal in `~/.claude-time/integrations.json` gespeichert
- Nicht in Git committen
- Pages sind standardmäßig private
- Nur mit explizit geteilten Parent Pages nutzbar

---

## Examples

```bash
# Publish current spec
/notion-publish .claude/reference/session-boot-spec.md

# Publish session summary
/notion-publish ~/.claude-time/reports/project-2026-01-28.md

# Publish with custom title
/notion-publish WORKFLOW.md --title "Agent Kit Workflow Guide"
```
