#!/usr/bin/env bash
# check-scope-discipline.sh — git diff ⊆ paths_in_scope z kontraktu sprintu
# Usage: scripts/check-scope-discipline.sh <sprint-n>
# Exit 0 = wszystkie zmiany w scope. Exit ≠0 = pliki spoza scope (Non-negotiable #5).

set -euo pipefail

SPRINT="${1:?Usage: check-scope-discipline.sh <sprint-n>}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
CONTRACT="$BASE_DIR/state/contracts/sprint-${SPRINT}.json"

[[ -f "$CONTRACT" ]] || { echo "[FAIL] $CONTRACT not found"; exit 1; }

# Get paths_in_scope and out_of_scope
IN_SCOPE=$(jq -r '.paths_in_scope[]? // empty' "$CONTRACT")
OUT_SCOPE=$(jq -r '.out_of_scope[]? // empty' "$CONTRACT")

if [[ -z "$IN_SCOPE" ]]; then
  echo "[WARN] Kontrakt nie ma paths_in_scope. Skipping scope check."
  echo "[HINT] Dodaj paths_in_scope: [\"src/feature-x/\"] do kontraktu."
  exit 0
fi

# Get changed files since sprint start
SPRINT_START_HASH=$(jq -r --arg s "$SPRINT" \
  '[.[] | select(.event == "iteration_start") | select(.details.sprint == ($s | tonumber))] | first | .details.start_hash // ""' \
  "$BASE_DIR/state/breadcrumbs.json" 2>/dev/null || echo "")

if [[ -z "$SPRINT_START_HASH" ]]; then
  echo "[WARN] Brak iteration_start z hashem. Używam HEAD~5."
  SPRINT_START_HASH="HEAD~5"
fi

CHANGED=$(cd "$BASE_DIR" && git diff --name-only "$SPRINT_START_HASH"..HEAD 2>/dev/null || git diff --name-only HEAD)

OUT_OF_SCOPE_FILES=()
ALLOWED_ALWAYS=("state/breadcrumbs.json" "state/feature_list.json" "state/contracts/")

while IFS= read -r changed_file; do
  [[ -z "$changed_file" ]] && continue

  # Zawsze dozwolone (state files)
  is_allowed=0
  for allowed in "${ALLOWED_ALWAYS[@]}"; do
    if [[ "$changed_file" == "$allowed"* ]]; then
      is_allowed=1
      break
    fi
  done
  [[ "$is_allowed" -eq 1 ]] && continue

  # Sprawdź w paths_in_scope
  in_scope=0
  while IFS= read -r scope_path; do
    [[ -z "$scope_path" ]] && continue
    if [[ "$changed_file" == "$scope_path"* ]] || [[ "$changed_file" == $scope_path ]]; then
      in_scope=1
      break
    fi
  done <<< "$IN_SCOPE"

  if [[ "$in_scope" -eq 0 ]]; then
    OUT_OF_SCOPE_FILES+=("$changed_file")
  fi
done <<< "$CHANGED"

if [[ "${#OUT_OF_SCOPE_FILES[@]}" -gt 0 ]]; then
  echo "[FAIL] ${#OUT_OF_SCOPE_FILES[@]} plików spoza scope:"
  printf '  - %s\n' "${OUT_OF_SCOPE_FILES[@]}"
  echo ""
  echo "paths_in_scope było:"
  echo "$IN_SCOPE" | sed 's/^/  - /'
  echo ""
  echo "Cofnij zmiany w plikach spoza scope LUB renegocjuj kontrakt (faza 3)."
  exit 2
fi

echo "[OK] Wszystkie zmiany w scope (paths_in_scope)."
exit 0
