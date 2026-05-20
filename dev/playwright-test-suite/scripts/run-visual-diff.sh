#!/usr/bin/env bash
# run-visual-diff.sh — Faza 5: Visual regression (pixel-diff vs baseline)
# Usage: scripts/run-visual-diff.sh <sprint-n> [baseline-branch]
# NIE robi --update-snapshots automatycznie — diff zostaje do code review.

set -euo pipefail

SPRINT="${1:?Usage: run-visual-diff.sh <sprint-n> [baseline-branch]}"
BASELINE_BRANCH="${2:-main}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VISUAL_DIR="$BASE_DIR/state/evidence/sprint-${SPRINT}/visual"
mkdir -p "$VISUAL_DIR"

LOG="$VISUAL_DIR/visual.log"
: > "$LOG"

step() { echo "[$(date -u +%H:%M:%S)] $*" | tee -a "$LOG"; }

# 1. Generuj visual spec
VISUAL_SPEC="$BASE_DIR/tests/generated/sprint-${SPRINT}/visual.spec.ts"
mkdir -p "$(dirname "$VISUAL_SPEC")"

if [[ -f "$SKILL_DIR/templates/visual.spec.ts.tmpl" ]]; then
  sed -e "s|{{SPRINT}}|$SPRINT|g" \
      -e "s|{{VISUAL_DIR}}|$VISUAL_DIR|g" \
      "$SKILL_DIR/templates/visual.spec.ts.tmpl" > "$VISUAL_SPEC"
  step "[OK] Generated visual spec"
fi

# 2. Sprawdź czy są baseline screenshots
if [[ ! -d "$BASE_DIR/tests/snapshots" ]] || [[ -z "$(find "$BASE_DIR/tests/snapshots" -name '*.png' 2>/dev/null)" ]]; then
  step "[WARN] Brak baseline screenshots w tests/snapshots/"
  step "       Pierwsze uruchomienie? Wygeneruj baseline: npx playwright test $VISUAL_SPEC --update-snapshots"
  step "       Potem code review baseline i commit do git."

  cat > "$VISUAL_DIR/metadata.json" <<EOF
{
  "produced_by": "playwright-runner",
  "phase": "visual",
  "sprint": "$SPRINT",
  "ts": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "result": "no_baseline",
  "message": "Brak baseline — wygeneruj przez --update-snapshots (po Plan-Validate-Execute)"
}
EOF
  exit 2
fi

# 3. Run Playwright with screenshot compare (NIE --update-snapshots)
step "=== Running visual regression ==="
if npx playwright test "$VISUAL_SPEC" \
   --reporter="json:$VISUAL_DIR/playwright-results.json" \
   2>&1 | tee -a "$LOG"; then
  RESULT="passed"
  step "[OK] All views match baseline"
else
  RESULT="failed"
  step "[FAIL] Visual diff detected — review evidence in $VISUAL_DIR"
fi

# 4. Liczenie views_passed / views_failed
VIEWS_TOTAL=0
VIEWS_PASSED=0
VIEWS_FAILED=0

if [[ -f "$VISUAL_DIR/playwright-results.json" ]]; then
  VIEWS_TOTAL=$(jq '[.suites[].specs[]] | length' "$VISUAL_DIR/playwright-results.json" 2>/dev/null || echo 0)
  VIEWS_PASSED=$(jq '[.suites[].specs[] | select(.ok == true)] | length' "$VISUAL_DIR/playwright-results.json" 2>/dev/null || echo 0)
  VIEWS_FAILED=$((VIEWS_TOTAL - VIEWS_PASSED))
fi

step "Views: $VIEWS_PASSED/$VIEWS_TOTAL passed"

# 5. Metadata
cat > "$VISUAL_DIR/metadata.json" <<EOF
{
  "produced_by": "playwright-runner",
  "phase": "visual",
  "sprint": "$SPRINT",
  "ts": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "result": "$RESULT",
  "views_total": $VIEWS_TOTAL,
  "views_passed": $VIEWS_PASSED,
  "views_failed": $VIEWS_FAILED,
  "baseline_branch": "$BASELINE_BRANCH",
  "regenerate_command_if_intentional": "npx playwright test $VISUAL_SPEC --update-snapshots (PO Plan-Validate-Execute z human review)"
}
EOF

step ""
step "=== Phase 5 (visual) done: $RESULT ==="
[[ "$RESULT" == "passed" ]] && exit 0 || exit 1
