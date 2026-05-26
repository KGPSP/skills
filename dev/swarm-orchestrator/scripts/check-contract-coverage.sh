#!/usr/bin/env bash
# check-contract-coverage.sh — weryfikuje kontrakt sprintu wg wymagań fazy 3
# Usage: scripts/check-contract-coverage.sh <sprint-n>
# Exit 0 = kontrakt gotowy do fazy 4. Exit ≠0 = wracaj do negocjacji.

set -euo pipefail

SPRINT="${1:?Usage: check-contract-coverage.sh <sprint-n>}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
CONTRACT="$BASE_DIR/state/contracts/sprint-${SPRINT}.json"

[[ -f "$CONTRACT" ]] || { echo "[FAIL] $CONTRACT not found"; exit 1; }

MIN_CRITERIA="${MIN_CRITERIA:-15}"

# 1. Liczba kryteriów ≥ MIN_CRITERIA
TOTAL=$(jq '[.criteria // .proposed_criteria // [] | .[]] | length' "$CONTRACT")
if [[ "$TOTAL" -lt "$MIN_CRITERIA" ]]; then
  echo "[FAIL] only $TOTAL criteria, need ≥$MIN_CRITERIA"
  exit 2
fi

# 2. 100% kryteriów ma binary: true
NON_BINARY=$(jq '[.criteria // .proposed_criteria // [] | .[] | select(.binary != true)] | length' "$CONTRACT")
if [[ "$NON_BINARY" -gt 0 ]]; then
  echo "[FAIL] $NON_BINARY criteria nie mają binary: true"
  jq '[.criteria // .proposed_criteria // [] | .[] | select(.binary != true) | .id]' "$CONTRACT"
  exit 3
fi

# 3. Brak skal 1-10 (heurystyka na słowa kluczowe w check)
SCALE_HITS=$(jq -r '[.criteria // .proposed_criteria // [] | .[] | .check // ""] | join("\n")' "$CONTRACT" \
  | grep -iE "(scale|skala|/10|out of 10|grade [a-f]|rating)" | wc -l || true)
if [[ "$SCALE_HITS" -gt 0 ]]; then
  echo "[FAIL] wykryto skalę/grade w check field ($SCALE_HITS hit). Tylko binary."
  exit 4
fi

# 4. out_of_scope ma ≥1 wpis
OOS=$(jq '.out_of_scope // [] | length' "$CONTRACT")
if [[ "$OOS" -lt 1 ]]; then
  echo "[FAIL] out_of_scope musi mieć ≥1 wpis (Scope Discipline)"
  exit 5
fi

# 5. acceptance_evidence określone
EV=$(jq '.acceptance_evidence // [] | length' "$CONTRACT")
if [[ "$EV" -lt 1 ]]; then
  echo "[FAIL] acceptance_evidence puste"
  exit 6
fi

# 6. status accepted
STATUS=$(jq -r '.status // "missing"' "$CONTRACT")
if [[ "$STATUS" != "accepted" ]]; then
  echo "[FAIL] status=$STATUS (oczekiwano: accepted)"
  exit 7
fi

# 7. max_iterations w sensownym zakresie
MAX_ITER=$(jq -r '.max_iterations // 5' "$CONTRACT")
if [[ "$MAX_ITER" -lt 3 || "$MAX_ITER" -gt 7 ]]; then
  echo "[FAIL] max_iterations=$MAX_ITER poza zakresem 3-7"
  exit 8
fi

echo "[OK] Contract sprint-${SPRINT}: $TOTAL binary criteria, $OOS out-of-scope items, $EV evidence types."
echo "[OK] All criteria machine-checkable: yes"
echo "[OK] Faza 3 zamknięta. Wchodź w fazę 4."
exit 0
