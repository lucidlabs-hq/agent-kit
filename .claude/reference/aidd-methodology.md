# AIDD: Adaptive AI Discovery & Delivery

> AI-driven, Decision-driven Development Workflow

## Overview

AIDD (Adaptive AI Discovery & Delivery) is a methodology for AI-assisted development that emphasizes **explicit decision points** between exploration and delivery phases. It combines AI capabilities with human decision-making to maximize value and minimize waste.

```
┌──────────────────────────────────────────────────────────────────────┐
│                           AIDD WORKFLOW                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│    EXPLORATION          DECISION           DELIVERY                   │
│    ───────────          ────────           ────────                   │
│    • Research           /decision          • Implement                │
│    • Prototype          • proceed          • Test                     │
│    • Validate           • pivot            • Deploy                   │
│    • Learn              • drop             • Document                 │
│                         • iterate                                     │
│                                                                       │
│    No commitment        Gate               Committed timeline         │
│    Discovery focus      Business choice    Execution focus            │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Core Principles

### 1. Explicit Decisions

Every significant piece of work passes through an **explicit decision point**. No work silently transitions from exploration to delivery.

```
❌ Wrong: Start exploring → Keep working → Suddenly shipping
✅ Right: Explore → /decision proceed → Committed delivery
```

### 2. Discovery Before Commitment

Exploration has **no deadline pressure**. The focus is on learning, not delivering. This allows for honest assessment without sunk cost pressure.

### 3. Decisions Create Accountability

Each decision is documented with:
- What was explored
- Why this decision was made
- What the expected outcome is
- Who made the decision (for customer transparency)

### 4. Customer-Facing Transparency

Decisions are translated into customer-understandable language:

| Internal | Customer Sees |
|----------|---------------|
| "Pivot to RAG approach" | "Optimaler Ansatz nach Analyse gefunden" |
| "Drop feature, not viable" | "Untersuchung abgeschlossen, Empfehlung dokumentiert" |

---

## Status Flow (Discovery-Driven Development)

```
┌─────────┐    ┌─────────────┐    ┌──────────┐    ┌──────────┐    ┌────────┐    ┌──────┐
│ Backlog │ ─► │ Exploration │ ─► │ Decision │ ─► │ Delivery │ ─► │ Review │ ─► │ Done │
└─────────┘    └─────────────┘    └──────────┘    └──────────┘    └────────┘    └──────┘
     │               │                  │               │               │           │
     │               │                  │               │               │           │
 Prioritized    Research &         Explicit        Implementation   Validation  Complete
 not started    prototyping        decision        with deadline
                                   point
```

### Status Definitions

| Status | Purpose | Deadline? |
|--------|---------|-----------|
| **Backlog** | Prioritized, waiting for capacity | No |
| **Exploration** | Active research, prototyping, learning | No |
| **Decision** | Ready for proceed/pivot/drop decision | No |
| **Delivery** | Committed implementation | **YES** |
| **Review** | Validation, testing, feedback | No |
| **Done** | Complete, delivered | No |

### Key Insight: Deadlines Only in Delivery

```
Exploration → No deadline (discovery can't be scheduled)
Decision    → No deadline (quality decisions take time)
Delivery    → YES deadline (commitment enables planning)
```

---

## Decision Types

### `/decision proceed`

Move forward to delivery phase.

```
When: Exploration validated approach, risks understood
Result: Work moves to Delivery with committed timeline
Customer sees: "In Umsetzung, Liefertermin: [Date]"
```

### `/decision pivot`

Change direction based on learnings.

```
When: Better approach discovered during exploration
Result: New exploration cycle with adjusted direction
Customer sees: "Ansatz optimiert basierend auf Erkenntnissen"
```

### `/decision drop`

Stop work, document learnings.

```
When: Not viable, not valuable, or deprioritized
Result: Work archived with documented learnings
Customer sees: "Analyse abgeschlossen, Erkenntnisse dokumentiert"
```

### `/decision iterate`

Continue exploration with focused questions.

```
When: Need more information before deciding
Result: Continue in Exploration with specific goals
Customer sees: "Weitere Untersuchung für optimale Lösung"
```

---

## Work Types

| Type | Description | Typical Flow |
|------|-------------|--------------|
| **Exploration** | New capability, unknown territory | Full AIDD cycle |
| **Delivery** | Known work, clear requirements | Skip to Delivery |
| **Maintenance** | Bug fixes, small improvements | Direct to Delivery |

```
Exploration Work:  Backlog → Exploration → Decision → Delivery → Review → Done
Delivery Work:     Backlog → Delivery → Review → Done
Maintenance Work:  Backlog → Delivery → Done
```

---

## Two-System Architecture

AIDD operates across two systems:

```
┌───────────────────────────────────────────────────────────────────────┐
│                                                                        │
│   LINEAR                    BRIDGE                PRODUCTIVE.IO        │
│   (Execution)               (Productizer)         (Customer Value)     │
│                                                                        │
│   ┌──────────────┐         ┌───────────┐         ┌──────────────┐     │
│   │ Issues       │         │ /decision │         │ Delivery     │     │
│   │ Projects     │◄───────►│ /budget   │◄───────►│ Units        │     │
│   │ Status       │         │ /customer │         │ Time         │     │
│   │ DDD Flow     │         │ /product- │         │ Budgets      │     │
│   │              │         │    izer   │         │              │     │
│   └──────────────┘         └───────────┘         └──────────────┘     │
│                                                                        │
│   INTERNAL                  TRANSLATION           CUSTOMER-FACING      │
│   Technical detail          Layer                 Value focus          │
│   Developer focus                                 Service focus        │
│                                                                        │
└───────────────────────────────────────────────────────────────────────┘
```

### System Responsibilities

| System | Contains | Audience |
|--------|----------|----------|
| **Linear** | Issues, tasks, technical status | Development team |
| **Productive.io** | Delivery Units, time, budgets | Customer reporting |
| **Bridge (Skills)** | Translation, aggregation | Both |

---

## Customer Communication

### What Customers See

| Include | Exclude |
|---------|---------|
| ✅ Service name and type | ❌ Task-level details |
| ✅ Current phase | ❌ Individual tickets |
| ✅ Deadlines (Delivery only) | ❌ Developer names |
| ✅ Business value | ❌ Technical details |
| ✅ Decisions made | ❌ Internal discussions |

### Example Customer Report

```markdown
## KI-Support-Agent

**Typ:** Agent
**Phase:** 🔨 Delivery
**Deadline:** 15. Februar 2026
**Status:** 🟢 On Track

**Letzte Entscheidung:**
> RAG-basierter Ansatz gewählt für bessere Kontrolle und schnellere Anpassung

**Wert:** Automatisiert Support-Anfragen, spart geschätzt 4h/Woche

**Nächste Schritte:**
- Agent-Training mit echten Daten
- Testphase mit Support-Team
```

---

## Implementation in Agent Kit

### Skills Supporting AIDD

| Skill | Purpose | AIDD Phase |
|-------|---------|------------|
| `/linear` | Execution tracking, status flow | All |
| `/decision` | Log decisions for customer reporting | Decision |
| `/budget` | Track kontingent usage | All |
| `/customer` | Customer management | All |
| `/productizer` | Bridge Linear ↔ Productive.io | All |
| `/session-end` | Clean state, update status | All |

### Session Workflow

```
Session Start              During Work                Session End
─────────────              ───────────                ───────────
/prime                     /decision [type]           /session-end
↓                          ↓                          ↓
Check Linear status        Log decisions              Update Linear
Review current phase       Update status              Clean state
Plan work                  Track time                 Summarize work
```

---

## Delivery Unit Types

Services are categorized by type for appropriate reporting:

| Type | Description | Typical Phases |
|------|-------------|----------------|
| **Agent** | AI Agent development | Full AIDD |
| **GPT** | Custom GPT configuration | Exploration → Delivery |
| **Workflow** | n8n automation | Exploration → Delivery |
| **Integration** | System integration | Full AIDD |
| **Workshop** | Training/consulting | Direct Delivery |
| **Advisory** | Strategic consulting | Exploration → Decision |

---

## Best Practices

### 1. Document Decisions Immediately

```bash
# After making a decision, immediately log it
/decision proceed
# Add context while it's fresh
```

### 2. No Silent Transitions

```
❌ "The ticket just moved to Done"
✅ "/decision proceed → Delivery → Review → Done"
```

### 3. Customer-First Language

```
❌ "Refactored auth module, added OAuth2 PKCE flow"
✅ "Sicherer Login-Prozess implementiert"
```

### 4. Deadlines Only When Committed

```
❌ Exploration: "Should be done by Friday"
✅ Delivery: "Liefertermin: 15. Februar 2026"
```

### 5. Focus on Value, Not Activity

```
❌ "8 tickets completed this sprint"
✅ "Automatisiert jetzt 40% der Support-Anfragen"
```

---

## References

- [Linear Integration](./../skills/linear/SKILL.md)
- [Decision Skill](./../skills/decision/SKILL.md)
- [Productizer Skill](./../skills/productizer/SKILL.md)
- [Service Dashboard Audit](./service-dashboard-audit.md)
- [Productive.io Integration](./productive-integration.md)
