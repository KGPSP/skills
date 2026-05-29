#!/bin/sh
# check-env-detection.sh — Phase 0 gate. Verifies env-detection.md exists, non-empty,
# and declares all required fields: stack, size, fragile, ralph, teams, plan-number.
# Field may appear as "key:" or "**key**" (case-insensitive).
#
# Usage:
#   sh check-env-detection.sh --file env-detection.md
#
# Exit codes:
#   0 — file present + all fields declared (status=ok)
#   1 — file missing/empty or fields missing (status=missing)

set -eu

file=""

while [ $# -gt 0 ]; do
    case "$1" in
        --file) file="$2"; shift 2 ;;
        -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

if [ -z "$file" ] || [ ! -f "$file" ]; then
    printf '{"status":"missing","message":"env-detection.md not found or --file not given","file":"%s"}\n' "$file" >&2
    exit 1
fi
if [ ! -s "$file" ]; then
    printf '{"status":"missing","message":"env-detection.md is empty","file":"%s"}\n' "$file" >&2
    exit 1
fi

missing=""
for key in stack size fragile ralph teams plan-number; do
    if ! grep -iqE "(^|[*| ])${key}[*]*[[:space:]]*[:=]" "$file"; then
        missing="${missing}${key},"
    fi
done
missing=$(echo "$missing" | sed 's/,$//')

if [ -n "$missing" ]; then
    printf '{"status":"missing","message":"missing fields","missing":"%s","file":"%s"}\n' "$missing" "$file" >&2
    exit 1
fi

printf '{"status":"ok","message":"env-detection complete (6/6 fields)","file":"%s"}\n' "$file"
exit 0
