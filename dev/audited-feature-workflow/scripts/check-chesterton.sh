#!/bin/sh
# check-chesterton.sh — Phase 8 gate. Jesli diff usuwa definicje (function/def/class/...),
# PR musi zawierac uzasadnienie "Why this existed".
# Usage: sh check-chesterton.sh --diff DIFF.patch [--pr PR.md] ; exit 0/1
set -eu
diff=""; pr=""
while [ $# -gt 0 ]; do case "$1" in --diff) diff="$2"; shift 2 ;; --pr) pr="$2"; shift 2 ;; -h|--help) sed -n '2,4p' "$0"; exit 0 ;; *) echo "unknown argument: $1" >&2; exit 64 ;; esac; done
if [ -z "$diff" ] || [ ! -f "$diff" ]; then printf '{"status":"fail","message":"diff not found","file":"%s"}\n' "$diff" >&2; exit 1; fi
dels=$(grep -E '^-' "$diff" | grep -vE '^---' | grep -cE '(function |def |class |pub fn |func )' 2>/dev/null || true)
dels=${dels:-0}
if [ "$dels" -eq 0 ]; then printf '{"status":"ok","message":"brak usuniec definicji — Chesterton n/d"}\n'; exit 0; fi
if [ -z "$pr" ] || [ ! -f "$pr" ]; then printf '{"status":"fail","message":"usunieto %s definicji, brak --pr z uzasadnieniem","deletions":%s}\n' "$dels" "$dels" >&2; exit 1; fi
if grep -iqE 'why this existed|dlaczego.*istnia|chesterton' "$pr"; then
    printf '{"status":"ok","message":"usuniecia uzasadnione (Why this existed), %s def","deletions":%s}\n' "$dels" "$dels"; exit 0; fi
printf '{"status":"fail","message":"usunieto %s definicji bez sekcji Why this existed (Chesterton)","deletions":%s}\n' "$dels" "$dels" >&2; exit 1
