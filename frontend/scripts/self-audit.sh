#!/bin/bash
# Self-Audit Script
# Run after implementing features to verify compliance with project standards.
#
# Usage: ./scripts/self-audit.sh [scope]
# Scopes: frontend (default), backend, full

set -e

SCOPE=${1:-frontend}
FRONTEND_DIR="$(dirname "$0")/.."
PROJECT_ROOT="$FRONTEND_DIR/.."

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🔍 SELF-AUDIT                               ║"
echo "║                    Scope: $SCOPE                               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

ERRORS=0
WARNINGS=0

# Helper functions
check_pass() { echo "  ✅ $1"; }
check_fail() { echo "  ❌ $1"; ERRORS=$((ERRORS + 1)); }
check_warn() { echo "  ⚠️  $1"; WARNINGS=$((WARNINGS + 1)); }

# ============================================================================
# LEVEL 1: Syntax & Types
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 LEVEL 1: Syntax & Types"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$FRONTEND_DIR"

# ESLint
if pnpm run lint > /dev/null 2>&1; then
  check_pass "ESLint"
else
  check_fail "ESLint - run 'pnpm run lint' to see errors"
fi

# TypeScript
if pnpm run type-check > /dev/null 2>&1; then
  check_pass "TypeScript"
else
  check_fail "TypeScript - run 'pnpm run type-check' to see errors"
fi

echo ""

# ============================================================================
# LEVEL 2: Build
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 LEVEL 2: Build"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if pnpm run build > /dev/null 2>&1; then
  check_pass "Production build"
else
  check_fail "Production build - run 'pnpm run build' to see errors"
fi

echo ""

# ============================================================================
# LEVEL 3: Pattern Checks
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 LEVEL 3: Pattern Checks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check for 'any' types
if grep -rn ": any\|as any" app components lib --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules > /dev/null; then
  check_fail "Found 'any' types"
  grep -rn ": any\|as any" app components lib --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules | head -5
else
  check_pass "No 'any' types"
fi

# Check for Date.now() in module-level exports (SSR issue)
if grep -rn "^export.*Date\.now\|^export.*new Date()" app components lib --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules > /dev/null; then
  check_fail "Found Date.now()/new Date() in exports (SSR hydration issue)"
  grep -rn "^export.*Date\.now\|^export.*new Date()" app components lib --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules | head -5
else
  check_pass "No Date.now() in module exports"
fi

# Check for Math.random() in module-level exports
if grep -rn "^export.*Math\.random" app components lib --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules > /dev/null; then
  check_fail "Found Math.random() in exports (SSR hydration issue)"
else
  check_pass "No Math.random() in module exports"
fi

# Check for inline styles
if grep -rn "style={{" app components --include="*.tsx" 2>/dev/null > /dev/null; then
  check_fail "Found inline styles (use Tailwind)"
  grep -rn "style={{" app components --include="*.tsx" 2>/dev/null | head -5
else
  check_pass "No inline styles"
fi

# Check for console statements
if grep -rn "console\.\(log\|warn\|error\)" app components lib --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules > /dev/null; then
  check_warn "Found console statements (remove before commit)"
  grep -rn "console\.\(log\|warn\|error\)" app components lib --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules | head -5
else
  check_pass "No console statements"
fi

# Check for barrel exports
if find . -name "index.ts" -not -path "./node_modules/*" -exec grep -l "export \* from\|export {" {} \; 2>/dev/null | grep -v node_modules > /dev/null; then
  check_warn "Found barrel exports (prefer direct imports)"
else
  check_pass "No barrel exports"
fi

# Check for TODO/FIXME comments
if grep -rn "// TODO\|// FIXME\|// HACK" app components lib --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules > /dev/null; then
  check_warn "Found TODO/FIXME comments"
  grep -rn "// TODO\|// FIXME\|// HACK" app components lib --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules | head -5
else
  check_pass "No TODO/FIXME comments"
fi

# Check file sizes
echo ""
echo "  Checking file sizes (max 300 lines)..."
LARGE_FILES=$(find app components lib -name "*.tsx" -o -name "*.ts" 2>/dev/null | while read f; do
  if [ -f "$f" ]; then
    lines=$(wc -l < "$f")
    if [ $lines -gt 300 ]; then
      echo "    $f: $lines lines"
    fi
  fi
done)

if [ -n "$LARGE_FILES" ]; then
  check_warn "Large files found:"
  echo "$LARGE_FILES"
else
  check_pass "All files under 300 lines"
fi

echo ""

# ============================================================================
# LEVEL 4: Design System Compliance
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 LEVEL 4: Design System (Manual Verification Required)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check for semantic colors (red, green, orange, yellow)
if grep -rn "text-red\|bg-red\|text-green\|bg-green\|text-orange\|bg-orange\|text-yellow\|bg-yellow" app components --include="*.tsx" 2>/dev/null | grep -v node_modules > /dev/null; then
  check_warn "Found semantic colors (should use Indigo/Slate only)"
  grep -rn "text-red\|bg-red\|text-green\|bg-green\|text-orange\|bg-orange\|text-yellow\|bg-yellow" app components --include="*.tsx" 2>/dev/null | grep -v node_modules | head -5
else
  check_pass "No semantic colors (only Indigo/Slate)"
fi

# Check for shadows
if grep -rn "shadow-\|shadow " app components --include="*.tsx" 2>/dev/null | grep -v node_modules > /dev/null; then
  check_warn "Found shadows (flat design preferred)"
  grep -rn "shadow-\|shadow " app components --include="*.tsx" 2>/dev/null | grep -v node_modules | head -5
else
  check_pass "No shadows (flat design)"
fi

echo ""
echo "  📖 Manual checks required:"
echo "     □ Verify against design-system.md"
echo "     □ Check PRD.md feature specification"
echo "     □ Test responsive layout in browser"
echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo ""
  echo "  🎉 All checks passed!"
  echo ""
  echo "  Ready for: /commit"
  echo ""
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo ""
  echo "  ⚠️  Passed with $WARNINGS warning(s)"
  echo ""
  echo "  Consider fixing warnings, then: /commit"
  echo ""
  exit 0
else
  echo ""
  echo "  ❌ Failed: $ERRORS error(s), $WARNINGS warning(s)"
  echo ""
  echo "  Fix errors before committing!"
  echo ""
  exit 1
fi
