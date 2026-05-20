#!/usr/bin/env bash
# check-breadcrumbs-append-only.sh — wymusza zasadę append-only dla breadcrumbs.json
# Usage: scripts/check-breadcrumbs-append-only.sh
# Exit 0 = nie wykryto usuniętych wpisów. Exit ≠0 = sesja przerywana.

set -euo pipefail

BASE_DIR="${BASE_DIR:-$(pwd)}"
BC="$BASE_DIR/state/breadcrumbs.json"

[[ -f "$BC" ]] || { echo "[FAIL] $BC missing"; exit 1; }

# git diff --unified=0 — sprawdź usunięte linie w tablicy
if [[ -d "$BASE_DIR/.git" ]]; then
  DELETED_LINES=$(cd "$BASE_DIR" && git diff --unified=0 state/breadcrumbs.json 2>/dev/null \
    | grep -E "^-" | grep -vE "^---" | grep -E '"ts"|"actor"|"event"' | wc -l | tr -d ' \n')
  DELETED_LINES="${DELETED_LINES:-0}"

  if [[ "$DELETED_LINES" -gt 0 ]]; then
    echo "[FAIL] Wykryto $DELETED_LINES usuniętych wpisów w breadcrumbs.json"
    echo "Append-only rule złamane. Sesja przerywana."
    cd "$BASE_DIR" && git diff state/breadcrumbs.json | head -40
    exit 2
  fi
fi

# Walidacja JSON
if ! jq empty "$BC" 2>/dev/null; then
  echo "[FAIL] breadcrumbs.json niepoprawny JSON"
  exit 3
fi

# Walidacja struktury: każdy wpis ma ts, actor, event
INVALID=$(jq '[.[] | select(.ts == null or .actor == null or .event == null)] | length' "$BC")
if [[ "$INVALID" -gt 0 ]]; then
  echo "[FAIL] $INVALID wpisów bez wymaganych pól (ts, actor, event)"
  exit 4
fi

# Walidacja chronologii: timestamps rosnące
NOT_MONOTONIC=$(jq -r '
  [.[].ts] as $ts |
  reduce range(0; ($ts | length) - 1) as $i (0;
    if $ts[$i] > $ts[$i+1] then . + 1 else . end
  )
' "$BC")

if [[ "$NOT_MONOTONIC" -gt 0 ]]; then
  echo "[WARN] $NOT_MONOTONIC nieuporządkowanych timestamps (powinno być monotonicznie rosnące)"
fi

LEN=$(jq 'length' "$BC")
echo "[OK] breadcrumbs.json: $LEN wpisów, append-only zachowane"
exit 0
