#!/bin/sh
set -eu

missing=0

check_cmd() {
  name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    path=$(command -v "$name")
    printf '[OK] %s %s\n' "$name" "$path"
  else
    printf '[MISSING] %s\n' "$name"
    missing=1
  fi
}

check_cmd tmux
check_cmd claude
check_cmd git
check_cmd awk
check_cmd sed
check_cmd tr
check_cmd date

if command -v tmux >/dev/null 2>&1; then
  printf '[INFO] %s\n' "$(tmux -V)"
fi

if [ "$missing" -ne 0 ]; then
  exit 1
fi

printf '[OK] agents_swarm prerequisites satisfied\n'
