#!/bin/sh
# check-anti-rat.sh — Phase 6/8 gate. Wymaga sekcji "Anti-rationalization decisions"
# z >=1 wpisem (jawne przejście tabeli, nie deklaratywne).
# Usage: sh check-anti-rat.sh --file PR_OR_ADR.md ; exit 0/1
set -eu
file=""
while [ $# -gt 0 ]; do case "$1" in --file) file="$2"; shift 2 ;; -h|--help) sed -n '2,4p' "$0"; exit 0 ;; *) echo "unknown argument: $1" >&2; exit 64 ;; esac; done
if [ -z "$file" ] || [ ! -f "$file" ]; then
    printf '{"status":"fail","message":"file not found","file":"%s"}\n' "$file" >&2; exit 1; fi
grep -iqE '^#+ .*anti-rationaliz' "$file" || { printf '{"status":"fail","message":"brak sekcji Anti-rationalization decisions","file":"%s"}\n' "$file" >&2; exit 1; }
n=$(awk 'BEGIN{f=0;c=0} /^#+ .*[Aa]nti-rationaliz/{f=1;next} /^#+ /&&f{f=0} f&&/^- /{c++} END{print c+0}' "$file")
if [ "$n" -ge 1 ]; then
    printf '{"status":"ok","message":"anti-rationalization decisions obecne (%d wpisow)","file":"%s"}\n' "$n" "$file"; exit 0; fi
printf '{"status":"fail","message":"sekcja Anti-rationalization pusta (0 wpisow)","file":"%s"}\n' "$file" >&2; exit 1
