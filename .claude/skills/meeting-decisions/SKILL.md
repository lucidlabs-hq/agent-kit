---
name: meeting-decisions
description: Extract AIDD decisions from tldv.io meeting transcripts and notes. Analyzes transcripts to propose proceed/pivot/drop/iterate decisions.
disable-model-invocation: true
allowed-tools: Read, Write, Glob
argument-hint: [folder-path]
---

# Meeting Decisions Skill

Extrahiere AIDD-Entscheidungen aus Meeting-Transkripten (tldv.io).

## Konzept

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DECISION EXTRACTION WORKFLOW                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   MEETING                  EXTRACTION              OUTPUT            │
│   ───────                  ──────────              ──────            │
│                                                                      │
│   ┌───────────┐           ┌───────────┐          ┌───────────┐      │
│   │  tldv.io  │           │  Claude   │          │ Decision  │      │
│   │ Transcript│──────────►│  Analysis │─────────►│ Proposals │      │
│   │           │           │           │          │           │      │
│   │  + Notes  │           │           │          │ + Linear  │      │
│   └───────────┘           └───────────┘          │   Updates │      │
│                                                   └───────────┘      │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Usage

### `/meeting-decisions [folder-path]`

Analysiere Transkripte und Notizen in einem Ordner.

**Beispiel:**
```bash
/meeting-decisions .meetings/2026-01-28
```

**Erwartete Ordnerstruktur:**
```
.meetings/2026-01-28/
├── transcript.txt       # tldv.io Export
├── notes.md            # Eigene Notizen (optional)
└── context.md          # Zusätzlicher Kontext (optional)
```

---

## Input Format

### transcript.txt (tldv.io Export)

```
Meeting: Weekly Board Review
Date: 2026-01-28
Participants: Adam, Sarah, Max

[00:02:15] Adam: Okay, let's go through the board. First item is the
Customer Support Agent for ACME Corp.

[00:03:42] Sarah: We finished the exploration. The RAG approach works
well, response quality is 85% in our tests.

[00:04:18] Adam: Great. So we can move forward with delivery?

[00:04:25] Sarah: Yes, I'd recommend we proceed. Estimated 2 weeks
to production.

[00:05:10] Adam: Agreed. Let's set the deadline to February 12th.
...
```

### notes.md (Optional)

```markdown
# Meeting Notes 2026-01-28

## ACME Corp - Support Agent
- RAG approach validated
- Decision: Proceed to Delivery
- Deadline: 12. Februar 2026

## Beta GmbH - CRM Integration
- Technical blocker discovered
- Decision: Pivot to webhook approach
- Need another week of exploration
```

---

## Output

### Decision Proposals

```markdown
# Extracted Decisions - 2026-01-28

## 1. ACME Corp - Customer Support Agent

**Decision:** PROCEED ✅
**Confidence:** High (explicit agreement in transcript)

**Summary:**
- Exploration complete, RAG approach validated
- 85% response quality in tests
- Team consensus to move forward

**Proposed Action:**
- Move Linear issue to "Delivery"
- Set deadline: 12. Februar 2026
- Estimated: 2 weeks

**Transcript Reference:**
> [00:04:18] "So we can move forward with delivery?"
> [00:04:25] "Yes, I'd recommend we proceed."

---

## 2. Beta GmbH - CRM Integration

**Decision:** PIVOT 🔄
**Confidence:** Medium (implied from blocker discussion)

**Summary:**
- Technical blocker with direct API approach
- Webhook alternative proposed
- Additional exploration needed

**Proposed Action:**
- Keep Linear issue in "Exploration"
- Add label: "pivot"
- Update description with new direction

**Transcript Reference:**
> [00:12:45] "The direct API has rate limits..."
> [00:13:20] "Let's try webhooks instead"

---

## Next Steps

- [ ] Review these proposals
- [ ] Confirm or adjust decisions
- [ ] Update Linear board
- [ ] Sync with Productive.io (/productizer sync)
```

---

## Decision Types

| Type | Indicator in Transcript | Action |
|------|------------------------|--------|
| **PROCEED** | "move forward", "let's do it", "approved" | → Delivery |
| **PIVOT** | "try different approach", "doesn't work" | → New Exploration |
| **DROP** | "not worth it", "cancel", "deprioritize" | → Archive |
| **ITERATE** | "need more info", "investigate further" | → Continue Exploration |

---

## Analysis Approach

### 1. Scan for Decision Signals

```
Proceed signals:
- "let's proceed"
- "move to delivery"
- "approved"
- "green light"
- deadline discussions

Pivot signals:
- "doesn't work"
- "try different"
- "alternative approach"
- blocker discussions

Drop signals:
- "not viable"
- "deprioritize"
- "cancel"
- "not worth"

Iterate signals:
- "need more info"
- "investigate"
- "not sure yet"
- "explore further"
```

### 2. Extract Context

- Which project/Delivery Unit?
- What was explored?
- What was decided?
- Who made the decision?
- Any deadlines mentioned?

### 3. Generate Proposals

- One proposal per identified decision
- Include confidence level
- Include transcript references
- Suggest Linear actions

---

## Integration with Workflow

```
Weekly Meeting          After Meeting           Board Update
───────────────         ─────────────           ────────────
tldv.io records         /meeting-decisions      Review proposals
Board review            Extract decisions       Update Linear
Discuss issues          Generate proposals      /productizer sync
```

---

## Best Practices

### 1. Strukturierte Meetings

Nutze ein klares Format für Entscheidungs-Meetings:
```
1. Board durchgehen (Linear)
2. Pro Issue: Status → Diskussion → Entscheidung
3. Explizit aussprechen: "Entscheidung: Proceed/Pivot/Drop"
4. Deadlines explizit nennen
```

### 2. Klare Sprache

```
❌ "Sieht gut aus"
✅ "Entscheidung: Proceed, Deadline 15. Februar"

❌ "Müssen wir nochmal schauen"
✅ "Entscheidung: Iterate, eine weitere Woche Exploration"
```

### 3. Review vor Commit

Immer die extrahierten Entscheidungen reviewen bevor sie ins System übernommen werden.

---

## Folder Structure

```
.meetings/
├── 2026-01-28/
│   ├── transcript.txt
│   ├── notes.md
│   └── decisions.md      # Generated output
├── 2026-01-21/
│   └── ...
└── templates/
    └── meeting-notes.md  # Template for notes
```

---

## Template: Meeting Notes

```markdown
# Meeting Notes [DATE]

## Agenda
1. Board Review
2. [Topic]
3. [Topic]

## Decisions

### [Project/Issue Name]
- **Status vor Meeting:** [Exploration/Decision/Delivery]
- **Diskussion:** [Key points]
- **Entscheidung:** [Proceed/Pivot/Drop/Iterate]
- **Deadline:** [If applicable]
- **Nächste Schritte:** [Action items]

### [Next Project]
...

## Action Items
- [ ] [Person]: [Task]
- [ ] [Person]: [Task]

## Notes
[Additional notes]
```

---

## Referenzen

- [tldv.io](https://tldv.io/app/meetings) - Meeting Recording & Transcripts
- [AIDD Methodology](./../reference/aidd-methodology.md)
- [Linear Integration](./../skills/linear/SKILL.md)
