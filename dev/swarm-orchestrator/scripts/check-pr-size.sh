#!/bin/sh
# check-pr-size.sh — PR size gate for audited-feature-workflow (Phase 6 / Phase 8).
# Counts insertions+deletions between BASE and HEAD. Exits with structured JSON.
#
# Usage:
#   sh check-pr-size.sh [--base BRANCH] [--justified] [--threshold N]
#
# Exit codes:
#   0 — total <= threshold (status=ok) OR over threshold with --justified (status=warning)
#   1 — total > threshold without --justified (status=fail)
#   2 — total > 1000 (hard stop, status=hard_stop, even with --justified)

set -eu

base="main"
threshold=300
justified=0

while [ $# -gt 0 ]; do
    case "$1" in
        --base) base="$2"; shift 2 ;;
        --justified) justified=1; shift ;;
        --threshold) threshold="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

if ! git rev-parse --verify "$base" >/dev/null 2>&1; then
    echo "{\"total\":0,\"status\":\"fail\",\"message\":\"base branch '$base' not found\"}" >&2
    exit 1
fi

stats=$(git diff --shortstat "$base"...HEAD 2>/dev/null || echo "")
ins=$(echo "$stats" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)
del=$(echo "$stats" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)
ins=${ins:-0}
del=${del:-0}
total=$((ins + del))

if [ "$total" -gt 1000 ]; then
    printf '{"total":%d,"status":"hard_stop","message":"diff >1000 lines: split required (vertical slicing or stacked PRs)"}\n' "$total"
    exit 2
fi

if [ "$total" -le "$threshold" ]; then
    printf '{"total":%d,"status":"ok","message":"diff within budget (<=%d)"}\n' "$total" "$threshold"
    exit 0
fi

if [ "$justified" -eq 1 ]; then
    printf '{"total":%d,"status":"warning","message":"diff >%d lines but --justified; document rationale in plan"}\n' "$total" "$threshold" >&2
    exit 0
fi

printf '{"total":%d,"status":"fail","message":"diff >%d lines without --justified; split into ~100-line slices"}\n' "$total" "$threshold"
exit 1
