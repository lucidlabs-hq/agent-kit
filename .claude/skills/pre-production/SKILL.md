---
name: pre-production
description: Pre-Production Security & Quality Check with Strix AI. Use BEFORE deploying to production to catch vulnerabilities and issues.
allowed-tools: Bash, Read
argument-hint: [mvp|production]
---

# Pre-Production Check

Führe Security- und Quality-Checks durch **bevor** Code in Production geht.

## Wann welchen Check?

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   MVP / Staging                   PRODUCTION DELIVERY           │
│   ─────────────                   ───────────────────           │
│   /pre-production mvp             /pre-production production    │
│                                                                 │
│   ✅ Quick Security Scan          ✅ Full Security Audit        │
│   ✅ Basic Vulnerability Check    ✅ Deep Vulnerability Scan    │
│   ✅ Essential E2E Tests          ✅ Full E2E Test Suite        │
│   ✅ Build Verification           ✅ Performance Check          │
│                                                                 │
│   Dauer: ~5 Minuten               Dauer: ~15-30 Minuten         │
│                                                                 │
│   Für: Interne Demos,             Für: Echte User,              │
│        Beta Testing,                   Paid Customers,          │
│        Staging Deploy                  Final Release            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Voraussetzungen

### Strix Installation

```bash
# Via curl
curl -sSL https://strix.ai/install | bash

# Oder via pipx
pipx install strix-agent

# Environment Variables
export STRIX_LLM="anthropic/claude-sonnet-4-20250514"
export LLM_API_KEY="your-api-key"
```

## MVP Check (`/pre-production mvp`)

Schneller Check für interne Demos und Staging:

### 1. Build Verification

```bash
cd frontend && pnpm run build
```

### 2. Type & Lint Check

```bash
cd frontend && pnpm run validate
```

### 3. Quick Security Scan

```bash
# Lokaler Code-Scan
strix --target ./frontend --scan-mode quick -n

# Oder gegen Staging URL
strix --target https://staging.your-app.com --scan-mode quick -n
```

### 4. Essential E2E Tests

```bash
cd frontend && pnpm run test:e2e -- --grep "@critical"
```

### MVP Checklist

- [ ] Build erfolgreich?
- [ ] TypeScript/ESLint Fehler?
- [ ] Kritische Security Issues?
- [ ] Login/Logout funktioniert?
- [ ] Hauptfunktion nutzbar?

---

## Production Check (`/pre-production production`)

Vollständiger Check vor echtem Production Deploy:

### 1. Full Build & Validation

```bash
cd frontend && pnpm run build
cd frontend && pnpm run validate
cd frontend && pnpm run test
```

### 2. Full Security Audit mit Strix

```bash
# Vollständiger Scan gegen Production-ähnliche Umgebung
strix --target https://staging.your-app.com \
  --instruction-file .strix/production-check.md \
  -n
```

### 3. Vulnerability Scan

```bash
# Mit spezifischen Anweisungen
strix --target https://staging.your-app.com \
  --instruction "Focus on: authentication bypass, injection attacks, access control, XSS, SSRF"
```

### 4. Full E2E Suite

```bash
cd frontend && pnpm run test:e2e
```

### 5. Performance Check (Optional)

```bash
# Lighthouse via agent-browser
agent-browser open https://staging.your-app.com
agent-browser evaluate "JSON.stringify(window.performance.timing)"
```

### Production Checklist

- [ ] Build erfolgreich?
- [ ] Alle Tests bestanden?
- [ ] **Keine kritischen Security Issues?**
- [ ] **Keine Injection Vulnerabilities?**
- [ ] **Keine Access Control Flaws?**
- [ ] **Keine XSS Vulnerabilities?**
- [ ] Login/Logout/Auth Flow sicher?
- [ ] Sensitive Daten geschützt?
- [ ] Error Handling korrekt?
- [ ] Performance akzeptabel?

---

## Strix Instruction File

Erstelle `.strix/production-check.md` für konsistente Checks:

```markdown
# Production Security Check

## Target Information
- Next.js 15 Application
- Convex Database
- Better Auth Authentication

## Focus Areas

### Authentication
- Test login/logout flows
- Check session handling
- Verify JWT/token security
- Test password reset flow

### Authorization
- Test role-based access
- Verify API endpoint protection
- Check for IDOR vulnerabilities

### Injection
- Test all input fields
- Check API parameters
- Verify SQL/NoSQL injection protection

### Client-Side
- Check for XSS in user inputs
- Verify CSP headers
- Test for open redirects

### API Security
- Check rate limiting
- Verify CORS configuration
- Test for SSRF

## Exclude
- /api/health (public)
- Static assets
```

---

## Workflow Integration

```
Development          Staging              Production
───────────          ───────              ──────────
/visual-verify   →   /pre-production  →   /pre-production
                     mvp                  production

Schnell              Quick Check          Full Audit
UI Focus             Security Basics      Complete Security
```

### Vor MVP/Staging Deploy

```bash
/pre-production mvp
```

### Vor Production Deploy

```bash
/pre-production production
```

---

## Security Issue Response

### Kritisch (BLOCKER)

| Issue | Aktion |
|-------|--------|
| SQL/NoSQL Injection | **STOP** - Sofort fixen |
| Auth Bypass | **STOP** - Sofort fixen |
| RCE Vulnerability | **STOP** - Sofort fixen |

### Hoch

| Issue | Aktion |
|-------|--------|
| XSS (Stored) | Fix vor Production |
| IDOR | Fix vor Production |
| SSRF | Fix vor Production |

### Mittel

| Issue | Aktion |
|-------|--------|
| XSS (Reflected) | Dokumentieren, zeitnah fixen |
| Missing Rate Limit | Dokumentieren, zeitnah fixen |

### Niedrig

| Issue | Aktion |
|-------|--------|
| Information Disclosure | Backlog |
| Missing Headers | Backlog |

---

## Referenzen

- [Strix GitHub](https://github.com/usestrix/strix)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
