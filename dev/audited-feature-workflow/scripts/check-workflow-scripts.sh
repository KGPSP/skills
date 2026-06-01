#!/bin/sh
# check-workflow-scripts.sh — Phase 1/6/8 gate (Dynamic Workflow exemplar templates).
# Waliduje SKLADNIE + strukture szablonu .js — NIE runnability wzgledem runtime CC
# (prymitywy agent/parallel/... sa globalami wstrzykiwanymi przez runtime; to gate
# skladniowo-strukturalny, nie dowod uruchomienia). Sprawdza:
#   1. skladnie — wrapper AsyncFunction (runtime opakowuje cialo, wiec top-level
#      await/return + "export const meta" sa legalne; node --check by je odrzucil),
#   2. closed-world lint tokenow wywolan — typo "paralel(" leci,
#   3. naglowek "// DOC-CONSTRAINTS:" + "// source: DOC/" (audytowalnosc),
#   4. brak bramki wewnatrz — APPROVAL/Gate w kodzie (gates-outside, DOC §6),
#   5. brak lead-IO — import/require/process./fs./child_process (DOC §9),
#   6. brak concurrency>16 — slice(0,N>16) lub concurrency=N>16 (DOC §9).
#
# Usage:
#   sh check-workflow-scripts.sh --file <workflow.js> [--require-node]
#
# Exit codes:
#   0 — szablon parsuje + struktura zgodna (status=ok)
#   1 — blad skladni / niedozwolony token / brak naglowka / bramka wewnatrz /
#       lead-IO / concurrency>16 / --require-node bez node (status=fail)
#  64 — nieznany argument

set -eu

file=""
require_node=0

while [ $# -gt 0 ]; do
    case "$1" in
        --file) file="$2"; shift 2 ;;
        --require-node) require_node=1; shift ;;
        -h|--help) sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

fail() {
    printf '{"status":"fail","message":"%s","file":"%s"}\n' "$1" "$file" >&2
    exit 1
}

if [ -z "$file" ] || [ ! -f "$file" ] || [ ! -s "$file" ]; then
    fail "workflow script not found or empty"
fi

# --- 1. Skladnia (wrapper AsyncFunction; runtime opakowuje cialo skryptu) ---
if command -v node >/dev/null 2>&1; then
    if ! node -e 'const fs=require("fs");
        const src=fs.readFileSync(process.argv[1],"utf8").replace(/^export\s+/gm,"");
        const AF=Object.getPrototypeOf(async function(){}).constructor;
        new AF("args","agent","parallel","pipeline","phase","log","budget","StructuredOutput", src);' "$file" 2>/dev/null; then
        fail "syntax error (AsyncFunction-wrapped parse failed)"
    fi
elif [ "$require_node" -eq 1 ]; then
    fail "--require-node ustawione ale node niedostepny"
fi

# Cialo bez linii komentarzy (// ...) — naglowek dokumentujacy gates-outside nie moze
# falszywie wyzwalac kontroli "bramka wewnatrz".
code=$(grep -vE '^[[:space:]]*//' "$file" || true)

# --- 3. Naglowek audytowalnosci ---
if ! grep -qE '^//[[:space:]]*DOC-CONSTRAINTS:' "$file"; then
    fail "brak naglowka // DOC-CONSTRAINTS:"
fi
if ! grep -qE '^//[[:space:]]*source:[[:space:]]*DOC/' "$file"; then
    fail "brak naglowka // source: DOC/..."
fi

# --- 2. Closed-world lint tokenow wywolan ---
ALLOW=" agent parallel pipeline phase log budget StructuredOutput
 if for while switch catch function return typeof await
 map filter slice reduce forEach find some every concat flat flatMap
 join split includes indexOf push keys values entries from isArray
 stringify parse Boolean Number String Math max min floor round abs "
tokens=$(printf '%s\n' "$code" | grep -oE '[A-Za-z_][A-Za-z0-9_]*\(' | sed 's/($//;s/(//' | sort -u || true)
bad=""
for tok in $tokens; do
    case "$ALLOW" in
        *" $tok "*) : ;;
        *) bad="$bad $tok" ;;
    esac
done
if [ -n "$bad" ]; then
    fail "niedozwolony token wywolania (closed-world lint):$bad"
fi

# --- 4. Gates-outside: zadnej bramki HITL wewnatrz workflow (kod, nie komentarz) ---
if printf '%s\n' "$code" | grep -qE 'APPROVAL|Gate[[:space:]]*#|mid-run'; then
    fail "bramka HITL wewnatrz workflow (APPROVAL/Gate/mid-run) — musi zostac POZA (DOC §6)"
fi

# --- 5. Lead-IO zabronione (delegacja do subagentow; DOC §9) ---
if printf '%s\n' "$code" | grep -qE '(^|[^A-Za-z])import |require\(|process\.|fs\.|child_process'; then
    fail "lead-IO zabronione (import/require/process/fs/child_process) — DOC §9"
fi

# --- 6. Concurrency <= 16 (slice(0,N) lub concurrency=N) ---
nums=$(printf '%s\n' "$code" | grep -oE 'slice\([[:space:]]*0[[:space:]]*,[[:space:]]*[0-9]+|concurrency[[:space:]]*[:=][[:space:]]*[0-9]+' | grep -oE '[0-9]+$' || true)
for n in $nums; do
    if [ "$n" -gt 16 ]; then
        fail "concurrency literal > 16 ($n) — limit DOC §9"
    fi
done

printf '{"status":"ok","message":"workflow template parses + struktura zgodna","file":"%s"}\n' "$file"
exit 0
