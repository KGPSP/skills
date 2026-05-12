#!/bin/sh
# verify-build-clean.sh — Phase 7 build gate. Exit 0, zero warnings.
# Auto-detects stack: package.json / Cargo.toml / pyproject.toml / go.mod.
#
# Usage:
#   sh verify-build-clean.sh [--cmd "BUILD_CMD"]

set -eu

cmd=""

while [ $# -gt 0 ]; do
    case "$1" in
        --cmd) cmd="$2"; shift 2 ;;
        -h|--help) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

if [ -z "$cmd" ]; then
    if [ -f package.json ]; then
        if command -v pnpm >/dev/null 2>&1; then cmd="pnpm build"
        else cmd="npm run build"; fi
    elif [ -f Cargo.toml ]; then cmd="cargo build --release"
    elif [ -f pyproject.toml ]; then cmd="ruff check ."
    elif [ -f go.mod ]; then cmd="sh -c 'go build ./... && go vet ./...'"
    else
        printf '{"build_cmd":"","exit_code":-1,"warnings":[],"status":"failed","message":"unknown stack; pass --cmd"}\n' >&2
        exit 1
    fi
fi

tmpout=$(mktemp)
trap 'rm -f "$tmpout"' EXIT

set +e
sh -c "$cmd" >"$tmpout" 2>&1
exit_code=$?
set -e

if [ "$exit_code" -ne 0 ]; then
    tail_log=$(tail -n 5 "$tmpout" | tr '\n' ' ' | sed 's/"/\\"/g')
    printf '{"build_cmd":"%s","exit_code":%d,"warnings":[],"status":"failed","tail":"%s"}\n' "$cmd" "$exit_code" "$tail_log" >&2
    exit 1
fi

warns=$(grep -inE 'warning|warn:|deprecated' "$tmpout" || true)

if [ -n "$warns" ]; then
    count=$(echo "$warns" | wc -l | tr -d ' ')
    sample=$(echo "$warns" | head -n 3 | tr '\n' '|' | sed 's/"/\\"/g')
    printf '{"build_cmd":"%s","exit_code":0,"warnings_count":%d,"sample":"%s","status":"warnings"}\n' "$cmd" "$count" "$sample" >&2
    exit 1
fi

printf '{"build_cmd":"%s","exit_code":0,"warnings_count":0,"status":"clean","message":"BUILD CLEAN"}\n' "$cmd"
exit 0
