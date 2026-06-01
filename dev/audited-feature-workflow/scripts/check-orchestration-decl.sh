#!/bin/sh
# check-orchestration-decl.sh — Phase 1 gate (orchestration declaration).
# Weryfikuje deklaracje "orchestration:" w Analysis Report (declare-not-prescribe,
# lustro effort-level): dla rozmiaru M/L pole jest wymagane; skip "none" musi byc
# uzasadniony ("none — <powod>"); tryb ultracode/ultrathink musi podac fallback
# "/effort"; a z flaga --goal deklaracja workflow/ultracode NIE wspolistnieje z /goal
# (Dynamic Workflows nie wspieraja mid-run input wymaganego przez Gate #1.5).
# Gate skladniowy NIE obserwuje, czy workflow faktycznie ruszyl — sprawdza deklaracje.
#
# Usage:
#   sh check-orchestration-decl.sh --file <analysis-report.md> [--size S|M|L] [--goal]
#
# Exit codes:
#   0 — deklaracja obecna/uzasadniona, lub rozmiar S bez pola (status=ok)
#   1 — M/L bez pola, "none" bez uzasadnienia, lub ultracode bez /effort (status=fail)
#   2 — --goal + deklaracja workflow/ultracode (status=goal-conflict, hard-stop)
#  64 — nieznany argument

set -eu

file=""
size="S"
goal=0

while [ $# -gt 0 ]; do
    case "$1" in
        --file) file="$2"; shift 2 ;;
        --size) size="$2"; shift 2 ;;
        --goal) goal=1; shift ;;
        -h|--help) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

ok()       { printf '{"status":"ok","message":"%s","file":"%s"}\n' "$1" "$file"; exit 0; }
fail()     { printf '{"status":"fail","message":"%s","file":"%s"}\n' "$1" "$file" >&2; exit 1; }
goalfail() { printf '{"status":"goal-conflict","message":"%s","file":"%s"}\n' "$1" "$file" >&2; exit 2; }

if [ -z "$file" ] || [ ! -f "$file" ] || [ ! -s "$file" ]; then
    fail "analysis report not found or empty"
fi

ml=0
case "$size" in
    M|m|L|l) ml=1 ;;
esac

# Wykrycie linii "orchestration:" — bez kotwicy (spojnie z effort-level w check-analysis-report.sh),
# wiec "- orchestration: workflow" i "orchestration = none" lapie tak samo.
orch_line=$(grep -iE 'orchestration[[:space:]]*[:=]' "$file" | head -1 || true)

if [ -z "$orch_line" ]; then
    if [ "$ml" -eq 1 ]; then
        fail "rozmiar M/L wymaga deklaracji 'orchestration:' (workflow|teams|sequential|none — powod)"
    fi
    ok "rozmiar S bez 'orchestration:' — dozwolone (declare-not-prescribe)"
fi

# Wartosc po pierwszym : lub =
value=$(printf '%s' "$orch_line" | sed -E 's/^[^:=]*[:=][[:space:]]*//')
first=$(printf '%s' "$value" | awk '{print tolower($1)}')

# Skip "none" — wymaga uzasadnienia "none — <powod>".
if [ "$first" = "none" ]; then
    rest=$(printf '%s' "$value" | sed -E 's/^[[:space:]]*[Nn][Oo][Nn][Ee]//')
    if printf '%s' "$rest" | grep -qiE '[a-z]{2,}'; then
        ok "orchestration=none uzasadnione"
    fi
    fail "orchestration=none bez uzasadnienia — uzyj 'none — <powod>'"
fi

# ultracode/ultrathink: zawsze z fallbackiem /effort (Anti-Rationalization, nigdy jedyna sciezka).
if printf '%s' "$value" | grep -qiE 'ultracode|ultrathink'; then
    if ! grep -qF '/effort' "$file"; then
        fail "ultracode/ultrathink bez fallbacku /effort — podaj '/effort xhigh|max' (Anti-Rationalization)"
    fi
fi

# Self-consistency: workflow/ultracode wzajemnie wykluczajace z /goal (Gate #1.5 mid-run input).
if [ "$goal" -eq 1 ]; then
    if printf '%s' "$value" | grep -qiE 'workflow|ultracode'; then
        goalfail "deklaracja workflow/ultracode + /goal — DW nie wspiera mid-run input (Gate #1.5); hard-stop"
    fi
fi

ok "orchestration zadeklarowana ($first)"
