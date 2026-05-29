#!/bin/sh
# check-hypotheses.sh — Phase 2 + Phase 3 gate. Verifies the artifact declares at least
# three hypotheses (Minimal, Idiomatic, Ambitious) and a Recommendation section.
#
# Usage:
#   sh check-hypotheses.sh --file <plan-or-hypotheses.md>
#
# Exit codes:
#   0 — 3 hypotheses + recommendation present (status=ok)
#   1 — missing any hypothesis label or recommendation (status=fail)

set -eu

file=""

while [ $# -gt 0 ]; do
    case "$1" in
        --file) file="$2"; shift 2 ;;
        -h|--help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

if [ -z "$file" ] || [ ! -f "$file" ] || [ ! -s "$file" ]; then
    printf '{"status":"fail","message":"hypotheses artifact not found or empty","file":"%s"}\n' "$file" >&2
    exit 1
fi

missing=""
grep -iqE 'minimal' "$file" || missing="${missing}Minimal,"
grep -iqE 'idiomatic' "$file" || missing="${missing}Idiomatic,"
grep -iqE 'ambitious' "$file" || missing="${missing}Ambitious,"
if ! grep -iqE '(recommendation|rekomendacja)' "$file"; then
    missing="${missing}Recommendation,"
fi
missing=$(echo "$missing" | sed 's/,$//')

if [ -n "$missing" ]; then
    printf '{"status":"fail","message":"missing hypotheses/recommendation","missing":"%s","file":"%s"}\n' "$missing" "$file" >&2
    exit 1
fi

printf '{"status":"ok","message":"3 hypotheses + recommendation present","file":"%s"}\n' "$file"
exit 0
