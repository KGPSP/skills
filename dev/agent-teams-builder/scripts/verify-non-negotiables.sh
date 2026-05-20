#!/usr/bin/env bash
# verify-non-negotiables.sh — sprawdza 5 zasad niepodlegających negocjacjom
# Usage: scripts/verify-non-negotiables.sh
# Exit code = numer złamanej zasady (0 = wszystkie OK)

set -euo pipefail

BASE_DIR="${BASE_DIR:-$(pwd)}"
STATE="$BASE_DIR/state"

ERRORS=()

# #1 Założenia uwidocznione — plan.md ma sekcję Open Questions niepustą
if [[ ! -f "$STATE/plan.md" ]]; then
  ERRORS+=("#1: brak state/plan.md (Planner nie wykonał fazy 1)")
else
  OQ=$(awk '/^## Open Questions/,/^## /' "$STATE/plan.md" | grep -cE "^[-*]" || true)
  if [[ "$OQ" -lt 1 ]]; then
    # Pusta sekcja Open Questions może być OK jeśli Planner świadomie napisał "brak"
    if ! grep -qE "(brak|none|no open questions)" "$STATE/plan.md"; then
      ERRORS+=("#1: state/plan.md Open Questions puste bez świadomej deklaracji 'brak'")
    fi
  fi
fi

# #2 Konflikty zatrzymują pracę — sprawdź blockers.md czy nie ma open blockerów
# Liczymy tylko nagłówki "# Blocker — <data>" (z myślnikiem), pomijając nagłówek pliku
if [[ -f "$STATE/blockers.md" ]]; then
  OPEN_BLOCKERS=$(grep -cE "^# Blocker —" "$STATE/blockers.md" || true)
  RESOLVED=$(grep -cE "^## Resolution" "$STATE/blockers.md" || true)
  OPEN_BLOCKERS="${OPEN_BLOCKERS:-0}"
  RESOLVED="${RESOLVED:-0}"
  if [[ "$OPEN_BLOCKERS" -gt "$RESOLVED" ]]; then
    ERRORS+=("#2: $((OPEN_BLOCKERS - RESOLVED)) nierozwiązanych blockerów w state/blockers.md")
  fi
fi

# #3 Nudne rozwiązania — heurystyka: zlicz pliki z 3+ generic parameters
GENERIC_HITS=0
if command -v grep >/dev/null; then
  GENERIC_HITS=$(grep -rE "<[A-Z][a-zA-Z]+\s*,\s*[A-Z][a-zA-Z]+\s*,\s*[A-Z][a-zA-Z]+\s*,\s*[A-Z]" "$BASE_DIR" \
    --include="*.ts" --include="*.tsx" --include="*.py" 2>/dev/null | wc -l || true)
fi
if [[ "$GENERIC_HITS" -gt 5 ]]; then
  ERRORS+=("#3: $GENERIC_HITS plików z 4+ generic params (heurystyka 'sprytności')")
fi

# #4 Twardy dowód — wszystkie passed criteria mają evidence
if [[ -d "$STATE/contracts" ]]; then
  MISSING_EVIDENCE=0
  for contract in "$STATE/contracts"/sprint-*.json; do
    [[ -f "$contract" ]] || continue
    [[ "$contract" == *.draft.json ]] && continue

    sprint=$(basename "$contract" .json | sed 's/sprint-//')
    PASSED_IDS=$(jq -r '
      [.criteria_results // [] | .[] | select(.passed == true) | .id] +
      [.evaluator_review // {} | .iterations // [] | .[].criteria_results // [] | .[] | select(.passed == true) | .id]
      | unique | .[]
    ' "$contract" 2>/dev/null || true)

    while IFS= read -r cid; do
      [[ -z "$cid" ]] && continue
      if ! ls "$STATE/evidence/sprint-${sprint}/${cid}".* 2>/dev/null | head -1 >/dev/null; then
        MISSING_EVIDENCE=$((MISSING_EVIDENCE + 1))
      fi
    done <<< "$PASSED_IDS"
  done

  if [[ "$MISSING_EVIDENCE" -gt 0 ]]; then
    ERRORS+=("#4: $MISSING_EVIDENCE passed criteria bez pliku evidence")
  fi
fi

# #5 Scope discipline — sprawdź per sprint (jeśli kontrakty istnieją)
SCOPE_VIOLATIONS=0
if [[ -d "$STATE/contracts" ]]; then
  for contract in "$STATE/contracts"/sprint-*.json; do
    [[ -f "$contract" ]] || continue
    [[ "$contract" == *.draft.json ]] && continue
    sprint=$(basename "$contract" .json | sed 's/sprint-//')
    if ! bash "$BASE_DIR/scripts/check-scope-discipline.sh" "$sprint" 2>/dev/null; then
      SCOPE_VIOLATIONS=$((SCOPE_VIOLATIONS + 1))
    fi
  done
fi
if [[ "$SCOPE_VIOLATIONS" -gt 0 ]]; then
  ERRORS+=("#5: $SCOPE_VIOLATIONS sprintów z plikami spoza scope")
fi

# Raport
echo "=== Non-negotiables verification ==="
if [[ "${#ERRORS[@]}" -eq 0 ]]; then
  echo "[OK] Wszystkie 5 zasad zachowane."
  exit 0
else
  echo "[FAIL] Złamano ${#ERRORS[@]} zasad:"
  printf '  - %s\n' "${ERRORS[@]}"
  echo ""
  echo "Sesja pauzowana. Patrz references/non-negotiables.md."
  exit "${#ERRORS[@]}"
fi
