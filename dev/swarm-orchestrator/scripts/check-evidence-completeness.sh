#!/usr/bin/env bash
# check-evidence-completeness.sh — każde criterion.passed=true ma plik evidence
# Usage: scripts/check-evidence-completeness.sh <sprint-n> | --all-sprints
# Exit 0 = każde passed ma evidence. Exit ≠0 = braki dowodów.

set -euo pipefail

BASE_DIR="${BASE_DIR:-$(pwd)}"
ARG="${1:?Usage: check-evidence-completeness.sh <sprint-n>|--all-sprints}"

check_sprint() {
  local sprint="$1"
  local contract="$BASE_DIR/state/contracts/sprint-${sprint}.json"
  local evidence_dir="$BASE_DIR/state/evidence/sprint-${sprint}"
  local errors=0

  [[ -f "$contract" ]] || { echo "[SKIP] sprint-${sprint}: no contract"; return 0; }

  # Get all passed criterion IDs
  PASSED_IDS=$(jq -r '
    [.criteria_results // [] | .[] | select(.passed == true) | .id] +
    [.evaluator_review // {} | .iterations // [] | .[].criteria_results // [] | .[] | select(.passed == true) | .id]
    | unique | .[]
  ' "$contract" 2>/dev/null || true)

  if [[ -z "$PASSED_IDS" ]]; then
    echo "[WARN] sprint-${sprint}: 0 passed criteria w kontrakcie"
    return 0
  fi

  while IFS= read -r cid; do
    [[ -z "$cid" ]] && continue
    # Sprawdź czy istnieje co najmniej 1 plik evidence dla tego criterion
    if ls "$evidence_dir/${cid}".* 2>/dev/null | head -1 >/dev/null; then
      # Sprawdź czy ma metadata
      if [[ -f "$evidence_dir/${cid}.metadata.json" ]]; then
        echo "[OK]   sprint-${sprint}/${cid}: evidence + metadata"
      else
        echo "[WARN] sprint-${sprint}/${cid}: evidence bez metadata.json"
      fi
    else
      echo "[FAIL] sprint-${sprint}/${cid}: passed=true, brak pliku evidence"
      errors=$((errors + 1))
    fi
  done <<< "$PASSED_IDS"

  return "$errors"
}

TOTAL_ERRORS=0

if [[ "$ARG" == "--all-sprints" ]]; then
  for contract in "$BASE_DIR"/state/contracts/sprint-*.json; do
    [[ -f "$contract" ]] || continue
    # Skip drafts
    [[ "$contract" == *.draft.json ]] && continue
    sprint=$(basename "$contract" .json | sed 's/sprint-//')
    check_sprint "$sprint" || TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
  done
else
  check_sprint "$ARG" || TOTAL_ERRORS=$?
fi

echo ""
if [[ "$TOTAL_ERRORS" -eq 0 ]]; then
  echo "[OK] Wszystkie passed criteria mają evidence."
  exit 0
else
  echo "[FAIL] $TOTAL_ERRORS braków dowodów."
  exit 1
fi
