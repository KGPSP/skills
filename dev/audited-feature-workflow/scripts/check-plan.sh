#!/bin/sh
# check-plan.sh — Phase 4/5 gate. Waliduje, że plan ma 10 wymaganych sekcji.
# Usage: sh check-plan.sh --plan PLAN.md ; exit 0/1
set -eu
plan=""
while [ $# -gt 0 ]; do case "$1" in --plan) plan="$2"; shift 2 ;; -h|--help) sed -n '2,3p' "$0"; exit 0 ;; *) echo "unknown argument: $1" >&2; exit 64 ;; esac; done
if [ -z "$plan" ] || [ ! -f "$plan" ] || [ ! -s "$plan" ]; then
    printf '{"status":"fail","message":"plan not found or empty","file":"%s"}\n' "$plan" >&2; exit 1; fi
missing=""
for sec in "Co i dlaczego" "Acceptance Criteria" "Definition of Done" "Assumptions" "Out of scope" "Thin Vertical Slices" "Rollback" "Target diff size" "Hyrum" "Anti-rationalization"; do
    grep -iqF "$sec" "$plan" || missing="${missing}${sec}; "
done
if [ -n "$missing" ]; then
    printf '{"status":"fail","message":"missing plan sections","missing":"%s","file":"%s"}\n' "$missing" "$plan" >&2; exit 1; fi
printf '{"status":"ok","message":"plan complete (10/10 sekcji)","file":"%s"}\n' "$plan"; exit 0
