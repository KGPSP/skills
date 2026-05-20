#!/usr/bin/env bash
# append-breadcrumb.sh — bezpiecznie dopisuje wpis do state/breadcrumbs.json
# Usage: scripts/append-breadcrumb.sh <actor> <event> '<details-json>'
# Wymusza append-only — nigdy nie nadpisuje istniejących wpisów.

set -euo pipefail

ACTOR="${1:?Usage: append-breadcrumb.sh <actor> <event> <details-json>}"
EVENT="${2:?event required}"
DETAILS="${3:-}"
[[ -z "$DETAILS" ]] && DETAILS='{}'
BASE_DIR="${BASE_DIR:-$(pwd)}"
BC="$BASE_DIR/state/breadcrumbs.json"

[[ -f "$BC" ]] || { echo "[ERROR] $BC not found. Run init-team-state.sh first."; exit 1; }

# Validate DETAILS is valid JSON
if ! echo "$DETAILS" | jq empty 2>/dev/null; then
  echo "[ERROR] details is not valid JSON: $DETAILS"
  exit 2
fi

TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LEN_BEFORE=$(jq 'length' "$BC")

TMP=$(mktemp)
jq --arg ts "$TS" --arg a "$ACTOR" --arg e "$EVENT" --argjson d "$DETAILS" \
  '. + [{"ts": $ts, "actor": $a, "event": $e, "details": $d}]' \
  "$BC" > "$TMP"

# Sanity check: length must grow by exactly 1
LEN_AFTER=$(jq 'length' "$TMP")
if [[ "$LEN_AFTER" -ne $((LEN_BEFORE + 1)) ]]; then
  echo "[ABORT] breadcrumb length did not grow by 1 (before=$LEN_BEFORE, after=$LEN_AFTER)"
  rm "$TMP"
  exit 3
fi

mv "$TMP" "$BC"
echo "[OK] breadcrumb +1 ($ACTOR/$EVENT @ $TS)"
