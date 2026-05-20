#!/usr/bin/env bash
# run-a11y.sh — Faza 4: Accessibility audit (axe-core WCAG 2.1 AA)
# Usage: scripts/run-a11y.sh <sprint-n>

set -euo pipefail

SPRINT="${1:?Usage: run-a11y.sh <sprint-n>}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

A11Y_DIR="$BASE_DIR/state/evidence/sprint-${SPRINT}/a11y"
mkdir -p "$A11Y_DIR"

LOG="$A11Y_DIR/a11y.log"
: > "$LOG"

step() { echo "[$(date -u +%H:%M:%S)] $*" | tee -a "$LOG"; }

# 1. Generuj a11y spec z template
A11Y_SPEC="$BASE_DIR/tests/generated/sprint-${SPRINT}/a11y.spec.ts"
mkdir -p "$(dirname "$A11Y_SPEC")"

if [[ -f "$SKILL_DIR/templates/a11y.spec.ts.tmpl" ]]; then
  sed -e "s|{{SPRINT}}|$SPRINT|g" \
      -e "s|{{A11Y_DIR}}|$A11Y_DIR|g" \
      "$SKILL_DIR/templates/a11y.spec.ts.tmpl" > "$A11Y_SPEC"
  step "[OK] Generated a11y spec"
else
  step "[FAIL] Template a11y.spec.ts.tmpl missing"
  exit 1
fi

# 2. Verify @axe-core/playwright installed
if ! [[ -d node_modules/@axe-core/playwright ]]; then
  step "[FAIL] @axe-core/playwright not installed. Run scripts/init-playwright.sh first."
  exit 2
fi

# 3. Run axe-core tests
step "=== Running axe-core ==="
if npx playwright test "$A11Y_SPEC" \
   --reporter="json:$A11Y_DIR/playwright-results.json" \
   2>&1 | tee -a "$LOG"; then
  TESTS_RESULT="passed"
else
  TESTS_RESULT="failed"
fi

# 4. Parse violations.json (test spec powinien zapisać do A11Y_DIR/violations.json)
VIOLATIONS_FILE="$A11Y_DIR/violations.json"

if [[ -f "$VIOLATIONS_FILE" ]]; then
  CRITICAL=$(jq '[.violations[] | select(.impact == "critical")] | length' "$VIOLATIONS_FILE" 2>/dev/null || echo 0)
  SERIOUS=$(jq '[.violations[] | select(.impact == "serious")] | length' "$VIOLATIONS_FILE" 2>/dev/null || echo 0)
  MODERATE=$(jq '[.violations[] | select(.impact == "moderate")] | length' "$VIOLATIONS_FILE" 2>/dev/null || echo 0)
  MINOR=$(jq '[.violations[] | select(.impact == "minor")] | length' "$VIOLATIONS_FILE" 2>/dev/null || echo 0)
else
  step "[WARN] violations.json missing — test spec może nie eksportować poprawnie"
  CRITICAL=0; SERIOUS=0; MODERATE=0; MINOR=0
fi

step "Violations: critical=$CRITICAL, serious=$SERIOUS, moderate=$MODERATE, minor=$MINOR"

# 5. Werdykt
BLOCKING=()
[[ "$CRITICAL" -gt 0 ]] && BLOCKING+=("critical_violations=$CRITICAL")
[[ "$SERIOUS" -gt 0 ]] && BLOCKING+=("serious_violations=$SERIOUS")

if [[ ${#BLOCKING[@]} -eq 0 ]]; then
  RESULT="passed"
  step "[OK] Zero critical/serious violations"
else
  RESULT="failed"
  step "[FAIL] HARD violations:"
  for b in "${BLOCKING[@]}"; do step "  - $b"; done
fi

# Warning thresholds
[[ "$MODERATE" -gt 3 ]] && step "[WARN] moderate violations exceed soft threshold (3): $MODERATE"
[[ "$MINOR" -gt 10 ]] && step "[WARN] minor violations exceed soft threshold (10): $MINOR"

# 6. Generuj violations-grouped.md (czytelnie dla human review)
if [[ -f "$VIOLATIONS_FILE" ]]; then
  cat > "$A11Y_DIR/violations-grouped.md" <<EOF
# A11y Violations — sprint-${SPRINT}

Audit: axe-core, WCAG 2.1 AA + best-practice
Date: $(date -u +%Y-%m-%d)

## Summary

| Impact | Count | Threshold | Status |
|---|---|---|---|
| critical | $CRITICAL | 0 (HARD) | $([[ $CRITICAL -eq 0 ]] && echo "✅" || echo "❌") |
| serious | $SERIOUS | 0 (HARD) | $([[ $SERIOUS -eq 0 ]] && echo "✅" || echo "❌") |
| moderate | $MODERATE | ≤3 (WARN) | $([[ $MODERATE -le 3 ]] && echo "✅" || echo "⚠️") |
| minor | $MINOR | ≤10 (WARN) | $([[ $MINOR -le 10 ]] && echo "✅" || echo "⚠️") |

## Critical violations

$(jq -r '.violations[] | select(.impact == "critical") | "- **\(.id)** (\(.helpUrl)): \(.description)\n  Affected: \(.nodes | length) elements"' "$VIOLATIONS_FILE" 2>/dev/null || echo "(none)")

## Serious violations

$(jq -r '.violations[] | select(.impact == "serious") | "- **\(.id)**: \(.description)"' "$VIOLATIONS_FILE" 2>/dev/null || echo "(none)")
EOF
  step "[OK] violations-grouped.md generated"
fi

# 7. Metadata
cat > "$A11Y_DIR/metadata.json" <<EOF
{
  "produced_by": "playwright-runner",
  "phase": "a11y",
  "sprint": "$SPRINT",
  "ts": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "result": "$RESULT",
  "violations_by_impact": {
    "critical": $CRITICAL,
    "serious": $SERIOUS,
    "moderate": $MODERATE,
    "minor": $MINOR
  },
  "blocking_failures": $(printf '%s\n' "${BLOCKING[@]:-}" | jq -R . | jq -s . 2>/dev/null || echo '[]'),
  "wcag_tags": ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "best-practice"]
}
EOF

step ""
step "=== Phase 4 (a11y) done: $RESULT ==="
[[ "$RESULT" == "passed" ]] && exit 0 || exit 1
