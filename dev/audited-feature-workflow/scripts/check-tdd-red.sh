#!/bin/sh
# check-tdd-red.sh — Phase 6 gate. Wymaga artefaktu RED-log ze statusem FAILED
# (dowód: failing test uchwycony PRZED implementacją; TDD/Prove-It).
# Usage: sh check-tdd-red.sh --red-log RED.log ; exit 0/1
set -eu
log=""
while [ $# -gt 0 ]; do case "$1" in --red-log) log="$2"; shift 2 ;; -h|--help) sed -n '2,4p' "$0"; exit 0 ;; *) echo "unknown argument: $1" >&2; exit 64 ;; esac; done
if [ -z "$log" ] || [ ! -f "$log" ] || [ ! -s "$log" ]; then
    printf '{"status":"fail","message":"RED log not found or empty","file":"%s"}\n' "$log" >&2; exit 1; fi
if grep -qiE 'Status:[[:space:]]*FAILED|--- FAIL|[1-9][0-9]* (failed|failing)|✗' "$log"; then
    printf '{"status":"ok","message":"RED dowód obecny (failing test)","file":"%s"}\n' "$log"; exit 0; fi
printf '{"status":"fail","message":"brak dowodu RED (Status FAILED) — TDD wymaga failing testu przed implementacją","file":"%s"}\n' "$log" >&2; exit 1
