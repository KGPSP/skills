#!/bin/sh
# api-impact-scan.sh — Phase 1.5 Hyrum risk scan.
# Finds public exports in changed files vs BASE, classifies breaking/additive/internal,
# and locates callers (excluding tests). Emits JSON for the agent's impact analysis.
#
# Usage:
#   sh api-impact-scan.sh [--base BRANCH] [--lang ts|js|py|rs|go|auto]

set -eu

base="main"
lang="auto"

while [ $# -gt 0 ]; do
    case "$1" in
        --base) base="$2"; shift 2 ;;
        --lang) lang="$2"; shift 2 ;;
        -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

if ! git rev-parse --verify "$base" >/dev/null 2>&1; then
    echo "{\"changes\":[],\"hyrum_risk\":\"unknown\",\"error\":\"base '$base' not found\"}" >&2
    exit 1
fi

changed=$(git diff --name-only "$base"...HEAD || true)
[ -z "$changed" ] && { echo '{"changes":[],"hyrum_risk":"low","message":"no changed files"}'; exit 0; }

scan_file() {
    f="$1"
    ext="${f##*.}"
    case "$ext" in
        ts|tsx|js|jsx) pattern='^export (function|class|const|interface|type|enum) +[A-Za-z_][A-Za-z0-9_]*' ;;
        rs) pattern='^pub (fn|struct|enum|trait|const|type) +[A-Za-z_][A-Za-z0-9_]*' ;;
        go) pattern='^func +[A-Z][A-Za-z0-9_]*' ;;
        py) pattern='^def +[a-z][A-Za-z0-9_]*' ;;
        *) return 0 ;;
    esac
    [ "$lang" != "auto" ] && case "$lang:$ext" in
        ts:ts|ts:tsx|js:js|js:jsx|py:py|rs:rs|go:go) : ;;
        *) return 0 ;;
    esac

    new_syms=$(grep -E "$pattern" "$f" 2>/dev/null | awk '{print $1" "$2" "$3}' || true)
    old_syms=$(git show "$base:$f" 2>/dev/null | grep -E "$pattern" | awk '{print $1" "$2" "$3}' || true)

    echo "$new_syms" | while IFS= read -r sym; do
        [ -z "$sym" ] && continue
        name=$(echo "$sym" | awk '{print $NF}')
        if echo "$old_syms" | grep -qF "$sym"; then
            type="internal"
        elif echo "$old_syms" | grep -qE "[ ]$name(\$| |\()"; then
            type="breaking"
        else
            type="additive"
        fi
        callers=$(git grep -l -F "$name" -- ':!*test*' ':!*spec*' 2>/dev/null | grep -vF "$f" | head -n 5 | tr '\n' ',' | sed 's/,$//')
        printf '{"file":"%s","symbol":"%s","type":"%s","callers":"%s"},' "$f" "$name" "$type" "$callers"
    done
}

results=""
for f in $changed; do
    [ -f "$f" ] || continue
    chunk=$(scan_file "$f")
    [ -n "$chunk" ] && results="${results}${chunk}"
done

results=$(echo "$results" | sed 's/,$//')

if echo "$results" | grep -q '"type":"breaking"'; then
    risk="high"
elif echo "$results" | grep -q '"type":"additive"'; then
    risk="medium"
else
    risk="low"
fi

printf '{"changes":[%s],"hyrum_risk":"%s"}\n' "$results" "$risk"
