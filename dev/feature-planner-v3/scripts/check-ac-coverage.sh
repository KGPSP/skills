#!/bin/sh
# check-ac-coverage.sh — Phase 7 Beyoncé Rule: 1:1 AC -> test mapping.
# Parses plan file with table:
#   | AC-ID | Type | Test ID | Test File | Command |
# Verifies each test file exists and test id is grep'able in it.
#
# Usage:
#   sh check-ac-coverage.sh --plan PLAN_FILE

set -eu

plan=""

while [ $# -gt 0 ]; do
    case "$1" in
        --plan) plan="$2"; shift 2 ;;
        -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

if [ -z "$plan" ] || [ ! -f "$plan" ]; then
    printf '{"total_ac":0,"covered":0,"missing":[],"status":"missing","message":"plan file not found or --plan not given"}\n' >&2
    exit 1
fi

rows=$(grep -E '^\| *AC-[FNC]' "$plan" || true)
if [ -z "$rows" ]; then
    printf '{"total_ac":0,"covered":0,"missing":[],"status":"missing","message":"no AC rows found in plan (expected | AC-F1 | ... | path | grep_id | cmd |)"}\n' >&2
    exit 1
fi

total=0
covered=0
missing=""

OLDIFS=$IFS
IFS='
'
for row in $rows; do
    total=$((total + 1))
    ac_id=$(echo "$row" | awk -F'|' '{gsub(/^ +| +$/,"",$2); print $2}')
    test_id=$(echo "$row" | awk -F'|' '{gsub(/^ +| +$/,"",$4); print $4}')
    test_file=$(echo "$row" | awk -F'|' '{gsub(/^ +| +$/,"",$5); print $5}')

    if [ -z "$test_file" ] || [ ! -f "$test_file" ]; then
        missing="${missing}{\"ac\":\"$ac_id\",\"reason\":\"file_missing\",\"file\":\"$test_file\"},"
        continue
    fi
    if [ -n "$test_id" ] && ! grep -qF "$test_id" "$test_file"; then
        missing="${missing}{\"ac\":\"$ac_id\",\"reason\":\"test_id_not_found\",\"id\":\"$test_id\",\"file\":\"$test_file\"},"
        continue
    fi
    covered=$((covered + 1))
done
IFS=$OLDIFS

missing=$(echo "$missing" | sed 's/,$//')

if [ "$covered" -eq "$total" ]; then
    printf '{"total_ac":%d,"covered":%d,"missing":[],"status":"ok","message":"AC COVERAGE 100%% (%d/%d)"}\n' "$total" "$covered" "$covered" "$total"
    exit 0
fi

printf '{"total_ac":%d,"covered":%d,"missing":[%s],"status":"missing"}\n' "$total" "$covered" "$missing" >&2
exit 1
