#!/bin/sh
# check-research-log.sh — Phase 1.0 gate (Deep Research Probe).
# Weryfikuje, ze Analysis Report deklaruje sekcje "## Research used", ze skip jest
# uzasadniony, ze zadeklarowany research nazywa konkretny mechanizm, oraz — z flaga
# --require-context7 — ze context7 zostal uzyty (obligatoryjny przy zewn. bibliotece).
#
# Usage:
#   sh check-research-log.sh --file <analysis-report.md> [--require-context7]
#
# Exit codes:
#   0 — research log obecny i poprawny (status=ok)
#   1 — sekcja brak/pusta, skip bez uzasadnienia, brak mechanizmu, lub brak context7 (status=fail)

set -eu

file=""
require_context7=0

while [ $# -gt 0 ]; do
    case "$1" in
        --file) file="$2"; shift 2 ;;
        --require-context7) require_context7=1; shift ;;
        -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

if [ -z "$file" ] || [ ! -f "$file" ] || [ ! -s "$file" ]; then
    printf '{"status":"fail","message":"analysis report not found or empty","file":"%s"}\n' "$file" >&2
    exit 1
fi

if ! grep -qiE '^##[[:space:]]+Research used[[:space:]]*$' "$file"; then
    printf '{"status":"fail","message":"missing \\"## Research used\\" section","file":"%s"}\n' "$file" >&2
    exit 1
fi

# Wytnij cialo sekcji "## Research used" (do nastepnego naglowka "## ").
section=$(awk '
    /^##[[:space:]]+Research used[[:space:]]*$/ { grab=1; next }
    grab && /^##[[:space:]]/ { grab=0 }
    grab { print }
' "$file")

# Usun puste linie — zostaja tylko linie tresci.
body=$(printf '%s\n' "$section" | sed '/^[[:space:]]*$/d')

if [ -z "$body" ]; then
    printf '{"status":"fail","message":"\\"## Research used\\" section is empty","file":"%s"}\n' "$file" >&2
    exit 1
fi

# Case A: skip zadeklarowany jako "none" — musi miec uzasadnienie ("none — <powod>").
if printf '%s\n' "$body" | grep -qiE '\bnone\b'; then
    rest=$(printf '%s\n' "$body" | grep -i 'none' | head -1 | sed -E 's/^.*[Nn][Oo][Nn][Ee]//')
    if ! printf '%s' "$rest" | grep -qiE '[a-z]{2,}'; then
        printf '{"status":"fail","message":"skip bez uzasadnienia — uzyj \\"none — <powod>\\"","file":"%s"}\n' "$file" >&2
        exit 1
    fi
    if [ "$require_context7" -eq 1 ]; then
        printf '{"status":"fail","message":"zewn. biblioteka wykryta ale research=none; context7 obligatoryjny","file":"%s"}\n' "$file" >&2
        exit 1
    fi
    printf '{"status":"ok","message":"research skip uzasadniony","file":"%s"}\n' "$file"
    exit 0
fi

# Case B: research zadeklarowany — musi nazwac min. jeden konkretny mechanizm.
if ! printf '%s\n' "$body" | grep -qiE '(context7|Explore|defuddle|WebSearch|WebFetch|codex)[[:space:]]*:'; then
    printf '{"status":"fail","message":"research bez mechanizmu (context7/Explore/defuddle/WebSearch/WebFetch/codex)","file":"%s"}\n' "$file" >&2
    exit 1
fi

# context7 obligatoryjny gdy ruszasz zewn. biblioteke (flaga z Phase 1.1 stack detection).
if [ "$require_context7" -eq 1 ]; then
    if ! printf '%s\n' "$body" | grep -qiE 'context7[[:space:]]*:'; then
        printf '{"status":"fail","message":"context7 obligatoryjny przy zewn. bibliotece — brak wpisu context7:","file":"%s"}\n' "$file" >&2
        exit 1
    fi
fi

printf '{"status":"ok","message":"research log kompletny","file":"%s"}\n' "$file"
exit 0
