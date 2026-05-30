#!/bin/sh
# check-five-axis.sh — Phase 8 gate. Weryfikuje, ze CR report pokrywa 5 osi + werdykt.
# Usage: sh check-five-axis.sh --file CR.md ; exit 0/1
set -eu
file=""
while [ $# -gt 0 ]; do case "$1" in --file) file="$2"; shift 2 ;; -h|--help) sed -n '2,3p' "$0"; exit 0 ;; *) echo "unknown argument: $1" >&2; exit 64 ;; esac; done
if [ -z "$file" ] || [ ! -f "$file" ]; then printf '{"status":"fail","message":"CR file not found","file":"%s"}\n' "$file" >&2; exit 1; fi
missing=""
for ax in Correctness Readability Architecture Security Performance; do grep -iqw "$ax" "$file" || missing="${missing}${ax} "; done
grep -iqE 'verdict|werdykt|approve|request changes|proceed|fix-first' "$file" || missing="${missing}Verdict "
if [ -n "$missing" ]; then printf '{"status":"fail","message":"missing axes/verdict","missing":"%s","file":"%s"}\n' "$missing" "$file" >&2; exit 1; fi
printf '{"status":"ok","message":"Five-Axis review kompletny (5 osi + werdykt)","file":"%s"}\n' "$file"; exit 0
