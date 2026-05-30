#!/bin/sh
# check-test-scopes.sh — Phase 7 gate. Weryfikuje, że dowód testow pokrywa wymagane
# scope'y wg rozmiaru S/M/L. Usage: sh check-test-scopes.sh --evidence EV.md --size S|M|L
set -eu
ev=""; size=""
while [ $# -gt 0 ]; do case "$1" in --evidence) ev="$2"; shift 2 ;; --size) size="$2"; shift 2 ;; -h|--help) sed -n '2,3p' "$0"; exit 0 ;; *) echo "unknown argument: $1" >&2; exit 64 ;; esac; done
if [ -z "$ev" ] || [ ! -f "$ev" ]; then printf '{"status":"fail","message":"evidence not found","file":"%s"}\n' "$ev" >&2; exit 1; fi
case "$size" in
    S) req="unit" ;;
    M) req="unit integration acceptance regression" ;;
    L) req="unit integration system acceptance e2e regression perf security" ;;
    *) printf '{"status":"fail","message":"--size must be S|M|L"}\n' >&2; exit 64 ;;
esac
missing=""
for s in $req; do grep -iqw "$s" "$ev" || missing="${missing}${s} "; done
if [ -n "$missing" ]; then printf '{"status":"fail","message":"missing test scopes for size %s","missing":"%s","file":"%s"}\n' "$size" "$missing" "$ev" >&2; exit 1; fi
printf '{"status":"ok","message":"test scopes pokryte dla size %s","file":"%s"}\n' "$size" "$ev"; exit 0
