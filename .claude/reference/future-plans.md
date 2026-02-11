# Future Plans: Agent Kit Roadmap

> **Structured feature roadmap for the Lucid Labs Agent Kit.**
> Referenced by `/prime` (shows next 10 open items) and `/future`.
> Last Updated: February 2026

---

## Session Tracking & Time Management

- [x] Basic session recording (`/session-end` saves to JSON)
- [x] Developer profile (`~/.claude-time/developer.json`)
- [x] Session Dashboard in `/prime` (activity grid, statistics)
- [x] Crash-safe heartbeat (background process, stale recovery)
- [x] Cross-project `/time-report` skill
- [ ] Productive.io time sync (`/time-sync`)
- [ ] Auto-sync at `/session-end` (opt-in)
- [ ] Budget warnings when contingent threshold reached
- [ ] Monthly aggregated reports
- [ ] Team aggregation (multi-developer)

## CI/CD & Deployment

- [x] PR-based workflow (`ci.yml` + `deploy-hq.yml`)
- [x] SHA-pinned GitHub Actions
- [x] Branch protection on `main`
- [x] Greptile PR review integration (documented in CLAUDE.md, install GitHub App)
- [ ] Staging environment (preview deploys)
- [ ] Rollback automation (one-click revert)
- [ ] Deploy notifications (Slack/email)

## AI & Agent Framework

- [x] Mastra agent layer
- [x] Portkey LLM Gateway (documented)
- [x] Vercel AI SDK for prototypes
- [ ] PromptFoo evaluation pipeline in CI
- [ ] Langfuse observability (when multi-step debugging needed)
- [ ] Agent performance benchmarks
- [ ] Cost tracking per customer via Portkey

## Authentication & RBAC

- [x] BetterAuth with Magic Links
- [x] Role detection via server proxy
- [x] RBAC loading gate
- [ ] Cross-subdomain SSO
- [ ] Admin panel for user management
- [ ] Audit logging for auth events

## Developer Experience

- [x] `/prime` boot screen with context detection
- [x] Linear integration (`/linear`)
- [x] Skill system (v2.1.3+)
- [x] `/clone-skill` and `/publish-skill`
- [ ] `/todo` skill (local task management)
- [ ] Improvement Analyzer trend tracking
- [ ] Session replay (what was done in past sessions)
- [ ] PRD-based complexity estimation

## Infrastructure

- [x] Docker Compose deployment
- [x] Convex self-hosted
- [x] MinIO S3-compatible storage
- [ ] Watchtower auto-updates (documented, not deployed)
- [ ] OpenTelemetry distributed tracing
- [ ] Health check dashboard
- [ ] Centralized log aggregation

## Customer-Facing

- [x] Service Dashboard (basic)
- [x] Productive.io integration (documented)
- [ ] Customer contingent portal
- [ ] Automated monthly service reports
- [ ] SLA tracking and reporting
- [ ] Customer notification system

---

*Maintained in Git. Update via `/promote` to upstream.*
