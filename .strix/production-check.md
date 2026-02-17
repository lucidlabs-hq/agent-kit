# Production Security Check

> Strix AI instruction file for comprehensive security audits before production deployment.

## Target Information

- **Framework:** Next.js 16+ (App Router)
- **Database:** Convex (Realtime reactive database)
- **Auth:** Better Auth with Convex adapter
- **AI:** Mastra agents with tool execution

## Focus Areas

### Authentication & Sessions

- [ ] Test login/logout flows
- [ ] Check session handling and expiration
- [ ] Verify JWT/token security
- [ ] Test password reset flow
- [ ] Check OAuth callback security
- [ ] Verify session invalidation on logout

### Authorization & Access Control

- [ ] Test role-based access control (RBAC)
- [ ] Verify API endpoint protection
- [ ] Check for IDOR vulnerabilities
- [ ] Test horizontal privilege escalation
- [ ] Test vertical privilege escalation
- [ ] Verify resource ownership checks

### Injection Attacks

- [ ] Test all input fields for XSS
- [ ] Check API parameters for injection
- [ ] Verify NoSQL injection protection (Convex)
- [ ] Test file upload handling
- [ ] Check for command injection in server actions

### Client-Side Security

- [ ] Check for stored XSS in user inputs
- [ ] Verify reflected XSS protection
- [ ] Test for DOM-based XSS
- [ ] Verify CSP headers are set
- [ ] Test for open redirects
- [ ] Check for clickjacking protection

### API Security

- [ ] Check rate limiting implementation
- [ ] Verify CORS configuration
- [ ] Test for SSRF vulnerabilities
- [ ] Check API versioning
- [ ] Verify error messages don't leak info
- [ ] Test for broken function level authorization

### Convex-Specific

- [ ] Verify query/mutation authorization
- [ ] Check action permissions
- [ ] Test file storage access control
- [ ] Verify vector search doesn't leak data
- [ ] Check real-time subscription security

### Mastra/AI-Specific

- [ ] Verify tool execution permissions
- [ ] Check for prompt injection
- [ ] Test agent access boundaries
- [ ] Verify sensitive data handling in AI context

## Exclude from Scan

- `/api/health` - Public health check endpoint
- `/api/cron/*` - Internal cron endpoints (IP-restricted)
- Static assets (`/_next/static/*`)
- Public marketing pages

## Test Credentials

Use these for authenticated testing:

```
Test User: test@example.com
Test Admin: admin@example.com
```

> Note: Create test accounts in staging environment before running scans.

## Severity Classification

| Severity | Response | Timeline |
|----------|----------|----------|
| **Critical** | STOP deployment | Fix immediately |
| **High** | Block deployment | Fix before release |
| **Medium** | Document & track | Fix within sprint |
| **Low** | Backlog | Fix when convenient |

## Post-Scan Actions

1. Review all findings in Strix report
2. Categorize by severity
3. Create tickets for non-blocking issues
4. Re-scan after fixes
5. Document accepted risks (if any)
