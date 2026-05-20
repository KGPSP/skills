#!/usr/bin/env bash
# run-ui-tests.sh — Faza 2: Playwright UI interactions per kontrakt sprintu
# Usage: scripts/run-ui-tests.sh <sprint-n>
# Generuje testy z templates/ na podstawie kryteriów kontraktu, uruchamia, zbiera evidence.

set -euo pipefail

SPRINT="${1:?Usage: run-ui-tests.sh <sprint-n>}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONTRACT="$BASE_DIR/state/contracts/sprint-${SPRINT}.json"
EVIDENCE_DIR="$BASE_DIR/state/evidence/sprint-${SPRINT}/ui"
mkdir -p "$EVIDENCE_DIR"

LOG="$BASE_DIR/state/evidence/sprint-${SPRINT}/ui-tests.log"
: > "$LOG"

step() { echo "[$(date -u +%H:%M:%S)] $*" | tee -a "$LOG"; }

# 1. Kontrakt
if [[ ! -f "$CONTRACT" ]]; then
  step "[WARN] No contract at $CONTRACT — standalone mode (uruchom wszystkie testy w tests/ui-*.spec.ts)"
  STANDALONE=1
else
  STANDALONE=0
  step "[OK] Contract loaded: $CONTRACT"
fi

# 2. Wyciągnij kryteria functional/layout z kontraktu
if [[ "$STANDALONE" -eq 0 ]]; then
  CRITERIA=$(jq -r '[.criteria // .proposed_criteria // [] | .[] | select(.type == "functional" or .type == "layout")] | .[] | .id' "$CONTRACT")
  CRITERIA_COUNT=$(echo "$CRITERIA" | grep -c . || echo 0)
  step "Criteria do przetestowania: $CRITERIA_COUNT"
fi

# 3. Generuj testy z templates (jeśli kontrakt istnieje)
if [[ "$STANDALONE" -eq 0 ]]; then
  GEN_DIR="$BASE_DIR/tests/generated/sprint-${SPRINT}"
  mkdir -p "$GEN_DIR"

  while IFS= read -r CID; do
    [[ -z "$CID" ]] && continue
    CHECK=$(jq -r ".criteria[] | select(.id == \"$CID\") | .check" "$CONTRACT" 2>/dev/null || \
            jq -r ".proposed_criteria[] | select(.id == \"$CID\") | .check" "$CONTRACT" 2>/dev/null || echo "")
    TYPE=$(jq -r ".criteria[] | select(.id == \"$CID\") | .type" "$CONTRACT" 2>/dev/null || \
           jq -r ".proposed_criteria[] | select(.id == \"$CID\") | .type" "$CONTRACT" 2>/dev/null || echo "functional")

    TEMPLATE_FILE="$SKILL_DIR/templates/ui-interactions.spec.ts.tmpl"
    [[ "$TYPE" == "layout" ]] && TEMPLATE_FILE="$SKILL_DIR/templates/layout.spec.ts.tmpl"

    if [[ -f "$TEMPLATE_FILE" ]]; then
      SPEC_FILE="$GEN_DIR/${CID}.spec.ts"
      sed -e "s|{{CRITERION_ID}}|$CID|g" \
          -e "s|{{CRITERION_CHECK}}|$CHECK|g" \
          -e "s|{{SPRINT}}|$SPRINT|g" \
          -e "s|{{EVIDENCE_DIR}}|$EVIDENCE_DIR/$CID|g" \
          "$TEMPLATE_FILE" > "$SPEC_FILE"
      mkdir -p "$EVIDENCE_DIR/$CID"
      step "Generated: $SPEC_FILE"
    else
      step "[WARN] Template missing: $TEMPLATE_FILE — pomijam $CID"
    fi
  done <<< "$CRITERIA"
fi

# 4. Uruchom Playwright
step "=== Running Playwright ==="

RESULTS_JSON="$EVIDENCE_DIR/playwright-results.json"
TEST_PATTERN=""
[[ "$STANDALONE" -eq 0 ]] && TEST_PATTERN="tests/generated/sprint-${SPRINT}/" || TEST_PATTERN="tests/ui-*.spec.ts"

if npx playwright test "$TEST_PATTERN" \
   --reporter="json:$RESULTS_JSON,html:$EVIDENCE_DIR/html-report" \
   2>&1 | tee -a "$LOG"; then
  step "[OK] All UI tests passed"
  RESULT="passed"
else
  step "[FAIL] Some UI tests failed — check $RESULTS_JSON for details"
  RESULT="failed"
fi

# 5. Per-criterion metadata (jeśli kontrakt)
if [[ "$STANDALONE" -eq 0 ]] && [[ -f "$RESULTS_JSON" ]]; then
  while IFS= read -r CID; do
    [[ -z "$CID" ]] && continue
    PASSED=$(jq -r ".suites[].specs[] | select(.title | contains(\"$CID\")) | .ok" "$RESULTS_JSON" 2>/dev/null | head -1 || echo "false")

    cat > "$EVIDENCE_DIR/$CID/metadata.json" <<EOF
{
  "produced_by": "playwright-runner",
  "phase": "ui",
  "criterion_id": "$CID",
  "sprint": "$SPRINT",
  "ts": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "passed": $PASSED,
  "tool": "playwright",
  "results_path": "$RESULTS_JSON"
}
EOF
  done <<< "$CRITERIA"
fi

# 6. Faza metadata
cat > "$BASE_DIR/state/evidence/sprint-${SPRINT}/ui-tests.metadata.json" <<EOF
{
  "produced_by": "playwright-runner",
  "phase": "ui",
  "sprint": "$SPRINT",
  "ts": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "result": "$RESULT",
  "criteria_count": ${CRITERIA_COUNT:-0},
  "results_json": "$RESULTS_JSON",
  "html_report": "$EVIDENCE_DIR/html-report/index.html"
}
EOF

step ""
step "=== Phase 2 (UI) done: $RESULT ==="
[[ "$RESULT" == "passed" ]] && exit 0 || exit 1
