#!/usr/bin/env bash
# run-devtools-trace.sh — Faza 3: Chrome DevTools (perf, network, console)
# Usage: scripts/run-devtools-trace.sh <sprint-n>
# Uruchamia Playwright z tracing on + analizuje HAR/console/vitals.

set -euo pipefail

SPRINT="${1:?Usage: run-devtools-trace.sh <sprint-n>}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONTRACT="$BASE_DIR/state/contracts/sprint-${SPRINT}.json"
PERF_DIR="$BASE_DIR/state/evidence/sprint-${SPRINT}/perf"
mkdir -p "$PERF_DIR"

LOG="$PERF_DIR/devtools.log"
: > "$LOG"

step() { echo "[$(date -u +%H:%M:%S)] $*" | tee -a "$LOG"; }

# 1. Progi (default lub z kontraktu)
LCP_THRESHOLD=2500
FCP_THRESHOLD=1800
CLS_THRESHOLD=0.1
INP_THRESHOLD=200
TTFB_THRESHOLD=800

if [[ -f "$CONTRACT" ]]; then
  LCP_THRESHOLD=$(jq -r '.performance_thresholds.LCP_ms // 2500' "$CONTRACT")
  FCP_THRESHOLD=$(jq -r '.performance_thresholds.FCP_ms // 1800' "$CONTRACT")
  CLS_THRESHOLD=$(jq -r '.performance_thresholds.CLS // 0.1' "$CONTRACT")
fi
step "Thresholds: LCP<$LCP_THRESHOLD, FCP<$FCP_THRESHOLD, CLS<$CLS_THRESHOLD"

# 2. Generuj/uruchom perf spec
PERF_SPEC="$BASE_DIR/tests/generated/sprint-${SPRINT}/perf.spec.ts"
mkdir -p "$(dirname "$PERF_SPEC")"

if [[ -f "$SKILL_DIR/templates/perf.spec.ts.tmpl" ]]; then
  sed -e "s|{{SPRINT}}|$SPRINT|g" \
      -e "s|{{PERF_DIR}}|$PERF_DIR|g" \
      -e "s|{{LCP_THRESHOLD}}|$LCP_THRESHOLD|g" \
      -e "s|{{FCP_THRESHOLD}}|$FCP_THRESHOLD|g" \
      -e "s|{{CLS_THRESHOLD}}|$CLS_THRESHOLD|g" \
      "$SKILL_DIR/templates/perf.spec.ts.tmpl" > "$PERF_SPEC"
  step "Generated perf spec: $PERF_SPEC"
fi

# 3. Run with full tracing
APP_URL="${APP_URL:-http://localhost:3000}"
step "=== Running Playwright with full trace ==="

if APP_URL="$APP_URL" npx playwright test "$PERF_SPEC" \
   --trace=on \
   --reporter="json:$PERF_DIR/playwright-results.json" \
   2>&1 | tee -a "$LOG"; then
  step "[OK] Perf tests passed"
  TESTS_RESULT="passed"
else
  step "[FAIL] Perf tests failed"
  TESTS_RESULT="failed"
fi

# 4. Sprawdź evidence — vitals.json
VITALS="$PERF_DIR/vitals.json"
if [[ -f "$VITALS" ]]; then
  step "[OK] vitals.json exists"

  # Parse i sprawdź progi
  LCP=$(jq -r '.LCP // 0' "$VITALS")
  FCP=$(jq -r '.FCP // 0' "$VITALS")
  CLS=$(jq -r '.CLS // 0' "$VITALS")

  BLOCKING=()

  awk_check() { awk -v v="$1" -v t="$2" 'BEGIN{exit !(v < t)}'; }

  awk_check "$LCP" "$LCP_THRESHOLD" || BLOCKING+=("LCP=${LCP}ms > threshold ${LCP_THRESHOLD}")
  awk_check "$FCP" "$FCP_THRESHOLD" || BLOCKING+=("FCP=${FCP}ms > threshold ${FCP_THRESHOLD}")
  awk_check "$CLS" "$CLS_THRESHOLD" || BLOCKING+=("CLS=${CLS} > threshold ${CLS_THRESHOLD}")

  if [[ ${#BLOCKING[@]} -eq 0 ]]; then
    step "[OK] All Core Web Vitals within thresholds"
    PERF_RESULT="passed"
  else
    step "[FAIL] Web Vitals failures:"
    for b in "${BLOCKING[@]}"; do step "  - $b"; done
    PERF_RESULT="failed"
  fi
else
  step "[WARN] vitals.json missing — test prawdopodobnie nie nagrał metryk"
  PERF_RESULT="incomplete"
fi

# 5. Console errors check
CONSOLE_LOG="$PERF_DIR/console.log"
if [[ -f "$CONSOLE_LOG" ]]; then
  CONSOLE_ERRORS=$(grep -cE "\[error\]" "$CONSOLE_LOG" 2>/dev/null || echo 0)
  step "Console errors: $CONSOLE_ERRORS"
  [[ "$CONSOLE_ERRORS" -gt 0 ]] && PERF_RESULT="failed"
fi

# 6. Metadata
cat > "$PERF_DIR/metadata.json" <<EOF
{
  "produced_by": "playwright-runner",
  "phase": "devtools",
  "sprint": "$SPRINT",
  "ts": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "result": "$PERF_RESULT",
  "tests_result": "$TESTS_RESULT",
  "vitals": {
    "LCP_ms": ${LCP:-0},
    "FCP_ms": ${FCP:-0},
    "CLS": ${CLS:-0}
  },
  "thresholds": {
    "LCP_ms": $LCP_THRESHOLD,
    "FCP_ms": $FCP_THRESHOLD,
    "CLS": $CLS_THRESHOLD
  },
  "console_errors": ${CONSOLE_ERRORS:-0},
  "blocking_failures": $(printf '%s\n' "${BLOCKING[@]:-}" | jq -R . | jq -s . 2>/dev/null || echo '[]')
}
EOF

step ""
step "=== Phase 3 (devtools) done: $PERF_RESULT ==="
[[ "$PERF_RESULT" == "passed" ]] && exit 0 || exit 1
