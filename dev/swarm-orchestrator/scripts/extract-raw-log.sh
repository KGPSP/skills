#!/bin/sh
# extract-raw-log.sh — Phase 7 DoD evidence helper.
# Runs a test command, captures last N lines + status, emits Markdown code block
# so the agent can paste raw (non-paraphrased) output into PR description.
#
# Usage:
#   sh extract-raw-log.sh --cmd "TEST_COMMAND" [--lines N]

set -eu

cmd=""
lines=30

while [ $# -gt 0 ]; do
    case "$1" in
        --cmd) cmd="$2"; shift 2 ;;
        --lines) lines="$2"; shift 2 ;;
        -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

if [ -z "$cmd" ]; then
    echo "missing --cmd" >&2
    exit 64
fi

tmpout=$(mktemp)
trap 'rm -f "$tmpout"' EXIT

set +e
sh -c "$cmd" >"$tmpout" 2>&1
exit_code=$?
set -e

if [ "$exit_code" -eq 0 ]; then
    status="PASSED"
else
    status="FAILED"
fi

printf '```log\n'
tail -n "$lines" "$tmpout"
printf '```\n'
printf 'Status: %s\n' "$status"
printf 'Command: %s\n' "$cmd"
printf 'Exit: %d\n' "$exit_code"

exit "$exit_code"
