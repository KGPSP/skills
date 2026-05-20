#!/usr/bin/env bash
# verify-evaluator-rubric.sh — sprawdza czy rubryka spełnia 4 zasady (granularność, kodyfikacja, few-shot, binarne progi)
# Usage: scripts/verify-evaluator-rubric.sh <path-to-contract-or-rubric.json|md>
# Exit 0 = rubryka gotowa. Exit ≠0 = popraw przed wejściem w fazę 4.

set -euo pipefail

TARGET="${1:?Usage: verify-evaluator-rubric.sh <file>}"
[[ -f "$TARGET" ]] || { echo "[FAIL] $TARGET not found"; exit 1; }

BASE_DIR="${BASE_DIR:-$(pwd)}"
ERRORS=0

echo "=== Rubric verification: $TARGET ==="

# 1. Granularność — liczba kryteriów ≥15
case "$TARGET" in
  *.json)
    COUNT=$(jq '[.criteria // .proposed_criteria // [] | .[]] | length' "$TARGET")
    ;;
  *.md)
    COUNT=$(grep -cE "^\s*-\s+\*\*C-[0-9]+" "$TARGET" || true)
    ;;
esac

if [[ "$COUNT" -lt 15 ]]; then
  echo "[FAIL] §2.1 Granulacja: tylko $COUNT kryteriów (wymagane ≥15)"
  ERRORS=$((ERRORS + 1))
else
  echo "[OK]   §2.1 Granulacja: $COUNT kryteriów"
fi

# 2. Binarne progi — zero skal
SCALE_HITS=0
case "$TARGET" in
  *.json)
    SCALE_HITS=$(jq -r '.. | strings? // empty' "$TARGET" \
      | grep -ciE "(scale|skala|/10|out of 10|rating|grade [a-f])" || true)
    ;;
  *.md)
    SCALE_HITS=$(grep -ciE "(scale|skala|/10|out of 10|rating|grade [a-f])" "$TARGET" || true)
    ;;
esac

if [[ "$SCALE_HITS" -gt 0 ]]; then
  echo "[FAIL] §2.4 Binarne progi: znaleziono $SCALE_HITS wystąpień skali/grade"
  ERRORS=$((ERRORS + 1))
else
  echo "[OK]   §2.4 Binarne progi: brak skal"
fi

# 3. Few-shot examples — sekcja examples/ z min. 2 good i 2 bad
EXAMPLES_DIR="$BASE_DIR/state/rubric/examples"
if [[ -d "$EXAMPLES_DIR" ]]; then
  GOOD=$(find "$EXAMPLES_DIR" -name "good-*" 2>/dev/null | wc -l)
  BAD=$(find "$EXAMPLES_DIR" -name "bad-*" -o -name "*slop*" 2>/dev/null | wc -l)
  if [[ "$GOOD" -ge 2 && "$BAD" -ge 2 ]]; then
    echo "[OK]   §2.3 Few-shot: $GOOD good + $BAD bad examples"
  else
    echo "[FAIL] §2.3 Few-shot: tylko $GOOD good i $BAD bad (wymagane ≥2 i ≥2)"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "[FAIL] §2.3 Few-shot: brak katalogu $EXAMPLES_DIR"
  ERRORS=$((ERRORS + 1))
fi

# 4. Kodyfikacja dobrego smaku — sprawdź czy kryteria design mają sztywne reguły
case "$TARGET" in
  *.json)
    DESIGN_CRITERIA=$(jq -r '[.criteria // .proposed_criteria // [] | .[] | select(.type == "design") | .check // ""] | join("\n")' "$TARGET")
    ;;
  *.md)
    DESIGN_CRITERIA=$(grep -iE "design|estetyka|kolor|paleta|typograf" "$TARGET" || true)
    ;;
esac

if [[ -n "$DESIGN_CRITERIA" ]]; then
  # Sprawdź czy w design jest hex / px / nazwa czcionki (twarda spec)
  HARD_SPECS=$(echo "$DESIGN_CRITERIA" | grep -ciE "#[0-9a-f]{3,6}|[0-9]+px|font-family|locator|boundingBox" || true)
  if [[ "$HARD_SPECS" -lt 1 ]]; then
    echo "[FAIL] §2.2 Kodyfikacja smaku: kryteria design bez twardych specs (hex, px, font-family)"
    ERRORS=$((ERRORS + 1))
  else
    echo "[OK]   §2.2 Kodyfikacja smaku: $HARD_SPECS twardych specs w design"
  fi
fi

echo ""
if [[ "$ERRORS" -eq 0 ]]; then
  echo "[OK] Wszystkie 4 zasady rubryki spełnione."
  exit 0
else
  echo "[FAIL] $ERRORS zasad złamanych. Wracaj do fazy 3."
  exit "$ERRORS"
fi
