#!/bin/sh
# check-screenshots.sh — Phase 7.8 gate. For each AC-F in the plan, verifies a matching
# screenshot file exists in the screenshots directory (name contains the AC-F id).
#
# Usage:
#   sh check-screenshots.sh --plan PLAN_FILE --dir SCREENSHOT_DIR
#
# AC-F id forms accepted in plan: AC-F1, AC-F-01, AC-F-1 ...
# A screenshot matches if its filename contains the normalized id (e.g. AC-F-01 or AC-F1).
#
# Exit codes:
#   0 — every AC-F has a screenshot (status=ok)
#   1 — plan/dir missing OR at least one AC-F lacks a screenshot (status=missing)

set -eu

plan=""
dir=""

while [ $# -gt 0 ]; do
    case "$1" in
        --plan) plan="$2"; shift 2 ;;
        --dir) dir="$2"; shift 2 ;;
        -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

if [ -z "$plan" ] || [ ! -f "$plan" ]; then
    printf '{"status":"missing","message":"plan file not found","plan":"%s"}\n' "$plan" >&2
    exit 1
fi
if [ -z "$dir" ] || [ ! -d "$dir" ]; then
    printf '{"status":"missing","message":"screenshot dir not found","dir":"%s"}\n' "$dir" >&2
    exit 1
fi

# Extract unique AC-F ids (normalize by removing internal dash: AC-F-01 -> AC-F01).
ids=$(grep -oiE 'AC-F-?[0-9]+' "$plan" | tr 'a-z' 'A-Z' | sort -u || true)
if [ -z "$ids" ]; then
    printf '{"status":"ok","message":"no AC-F in plan; no screenshots required","plan":"%s"}\n' "$plan"
    exit 0
fi

missing=""
for id in $ids; do
    norm=$(echo "$id" | tr -d '-')          # AC-F-01 -> ACF01
    found=0
    for f in "$dir"/*; do
        [ -e "$f" ] || continue
        base=$(basename "$f" | tr 'a-z' 'A-Z' | tr -d '-')
        case "$base" in
            *"$norm"*) found=1; break ;;
        esac
    done
    [ "$found" -eq 0 ] && missing="${missing}${id},"
done
missing=$(echo "$missing" | sed 's/,$//')

if [ -n "$missing" ]; then
    printf '{"status":"missing","message":"AC-F without screenshot","missing":"%s","dir":"%s"}\n' "$missing" "$dir" >&2
    exit 1
fi

printf '{"status":"ok","message":"every AC-F has a screenshot","dir":"%s"}\n' "$dir"
exit 0
