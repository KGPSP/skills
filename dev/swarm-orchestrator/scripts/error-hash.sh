#!/bin/sh
# error-hash.sh — md5 sygnatury błędu z raw log
# Użyty do no-progress detection (3× ten sam hash = pętla).
# Usage: error-hash.sh <raw_log_path>
# Output: 8-char md5 (np. "a3f7b2c8") lub "no-errors" gdy brak linii błędu.

set -eu

LOG="${1:-}"
[ -n "$LOG" ] || { echo "ERR: usage: $0 <raw_log_path>" >&2; exit 2; }
[ -f "$LOG" ] || { echo "ERR: file not found: $LOG" >&2; exit 1; }

# Wyciąga linie zaczynające się od Error/FAIL/ERROR/Exception/AssertionError, sortuje unique,
# liczy md5 (8 znaków). Stabilne dla powtarzających się stack traces.
SIGNATURE=$(grep -E '^[[:space:]]*(Error|FAIL|FAILED|ERROR|Exception|AssertionError|TypeError|ReferenceError|SyntaxError|ValueError)[: ]' "$LOG" 2>/dev/null | sort -u || true)

if [ -z "$SIGNATURE" ]; then
  echo "no-errors"
  exit 0
fi

# md5sum (Linux) / md5 (BSD/macOS) — prefer md5sum.
if command -v md5sum >/dev/null 2>&1; then
  HASH=$(printf '%s' "$SIGNATURE" | md5sum | cut -c1-8)
elif command -v md5 >/dev/null 2>&1; then
  HASH=$(printf '%s' "$SIGNATURE" | md5 -q | cut -c1-8)
else
  echo "ERR: neither md5sum nor md5 available" >&2
  exit 3
fi

echo "$HASH"
