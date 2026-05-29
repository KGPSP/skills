#!/bin/sh
# check-adr.sh — Phase 9 gate. Verifies the ADR exists, is non-empty, and contains the
# mandatory sections: Context, Decision, Anti-rationalization decisions, Consequences.
# (Hyrum/Chesterton decisions recommended; warned but not blocking.)
#
# Usage:
#   sh check-adr.sh --file ADR.md
#
# Exit codes:
#   0 — ADR present + mandatory sections (status=ok)
#   1 — missing ADR or mandatory sections (status=fail)

set -eu

file=""

while [ $# -gt 0 ]; do
    case "$1" in
        --file) file="$2"; shift 2 ;;
        -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

if [ -z "$file" ] || [ ! -f "$file" ] || [ ! -s "$file" ]; then
    printf '{"status":"fail","message":"ADR not found or empty","file":"%s"}\n' "$file" >&2
    exit 1
fi

missing=""
grep -iqE '^#+ .*(context|kontekst)' "$file" || missing="${missing}Context,"
grep -iqE '^#+ .*(decision|decyzja)' "$file" || missing="${missing}Decision,"
grep -iqE 'anti-rationalization' "$file" || missing="${missing}Anti-rationalization,"
grep -iqE '^#+ .*(consequences|konsekwencje)' "$file" || missing="${missing}Consequences,"
missing=$(echo "$missing" | sed 's/,$//')

if [ -n "$missing" ]; then
    printf '{"status":"fail","message":"missing mandatory ADR sections","missing":"%s","file":"%s"}\n' "$missing" "$file" >&2
    exit 1
fi

printf '{"status":"ok","message":"ADR complete (mandatory sections present)","file":"%s"}\n' "$file"
exit 0
