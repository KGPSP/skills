#!/bin/sh
# check-analysis-report.sh — Phase 1 gate. Verifies the Analysis Report exists, is
# non-empty, contains core sections (Stack, Architektura, Analog/PRIMARY TEMPLATE),
# and that "Open questions" carries no unresolved bullets (hard rule analysis-protocol.md).
#
# Usage:
#   sh check-analysis-report.sh --file analysis/<plan-id>.md
#
# Exit codes:
#   0 — report present + core sections + no open questions (status=ok)
#   1 — missing report/sections OR unresolved open questions (status=fail)

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
    printf '{"status":"fail","message":"analysis report not found or empty","file":"%s"}\n' "$file" >&2
    exit 1
fi

missing=""
# Stack section
grep -iqE '^#+ .*stack' "$file" || missing="${missing}Stack,"
# Architecture section
grep -iqE '^#+ .*architekt' "$file" || missing="${missing}Architektura,"
# Analog / PRIMARY TEMPLATE
if ! grep -iqE '(analog|primary template)' "$file"; then
    missing="${missing}Analog/PRIMARY-TEMPLATE,"
fi
missing=$(echo "$missing" | sed 's/,$//')

if [ -n "$missing" ]; then
    printf '{"status":"fail","message":"missing core sections","missing":"%s","file":"%s"}\n' "$missing" "$file" >&2
    exit 1
fi

# Open questions must be resolved: count "- " bullets in the Open questions section.
open_q=$(awk '
    /^#+ .*[Oo]pen [Qq]uestions/ {flag=1; next}
    /^#+ / && flag {flag=0}
    flag && /^- / {c++}
    END {print c+0}
' "$file")

if [ "$open_q" -gt 0 ]; then
    printf '{"status":"fail","message":"unresolved open questions block Phase 2","open_questions":%d,"file":"%s"}\n' "$open_q" "$file" >&2
    exit 1
fi

if ! grep -iqE 'effort[-_ ]?level[[:space:]]*[:=]' "$file"; then
    printf '{"status":"fail","message":"missing effort-level declaration (Phase 1 standard v3.6.0)","file":"%s"}\n' "$file" >&2
    exit 1
fi

printf '{"status":"ok","message":"analysis report complete, open questions resolved, effort declared","file":"%s"}\n' "$file"
exit 0
