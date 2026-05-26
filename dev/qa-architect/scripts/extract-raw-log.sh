#!/bin/sh
# extract-raw-log.sh — helper Phase 7. Uruchamia komendę testową i wkleja raw output
# do pliku evidence z timestampem + exit code. Wzorzec z audited-feature-workflow.
#
# Usage:
#   sh extract-raw-log.sh --label LABEL --out FILE -- CMD [ARGS...]
#
# Example:
#   sh extract-raw-log.sh --label "blueprint-complete" --out 07-verification.md -- sh scripts/check-blueprint-complete.sh

set -u

label=""
out=""

while [ $# -gt 0 ]; do
    case "$1" in
        --label) label="$2"; shift 2 ;;
        --out) out="$2"; shift 2 ;;
        --) shift; break ;;
        -h|--help)
            sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

if [ -z "$label" ] || [ -z "$out" ] || [ $# -eq 0 ]; then
    echo "usage: extract-raw-log.sh --label LABEL --out FILE -- CMD [ARGS...]" >&2
    exit 64
fi

ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

{
    printf "\n## %s (raw log)\n\n" "$label"
    printf "**Timestamp (UTC):** %s\n" "$ts"
    printf "**Command:** \`%s\`\n\n" "$*"
    printf '```log\n'
} >> "$out"

set +e
"$@" >> "$out" 2>&1
rc=$?
set -e

{
    printf '```\n\n'
    printf "**Exit code:** %d\n" "$rc"
} >> "$out"

exit "$rc"
