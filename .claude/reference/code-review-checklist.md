# Code Review Checklist

> Verify before committing. Automated checks via `pnpm run self-audit`.

---

## Automated (via `pnpm run self-audit`)

- [ ] TypeScript passes
- [ ] ESLint passes
- [ ] Build succeeds
- [ ] No `any` types
- [ ] No Date.now()/Math.random() in SSR
- [ ] No inline styles
- [ ] No console.log statements
- [ ] Files under 300 lines

## Manual (check reference docs)

- [ ] `design-system.md` - Colors, shadows, components
- [ ] `ssr-hydration.md` - SSR safety
- [ ] `PRD.md` - Feature matches specification
- [ ] Test in browser - Responsive, interactions
- [ ] Visual verification via agent-browser (for UI features)

## Code Standards Quick-Check

- [ ] English-only code and comments?
- [ ] TypeScript interfaces for all models?
- [ ] No hardcoded values?
- [ ] File header with summary?
- [ ] File under 300 lines?
- [ ] Named exports (not default)?
- [ ] No barrel exports (direct imports)?
- [ ] Server Components preferred?
- [ ] URL-based state for filters?
- [ ] Error handling implemented?
- [ ] Structured logging `[Component] Message`?
- [ ] Only Tailwind CSS (no inline styles)?
- [ ] No `any` types?
- [ ] No `Date.now()`/`Math.random()` in SSR code?
- [ ] Clickable elements have `cursor-pointer`?
