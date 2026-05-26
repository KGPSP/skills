#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SWARM_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
. "$SWARM_ROOT/scripts/lib/paths.sh"

usage() {
  printf 'Usage: swarm-attach.sh --run <run-id>\n' >&2
  exit 2
}

run_id=
while [ "$#" -gt 0 ]; do
  case "$1" in
    --run) [ "$#" -ge 2 ] || usage; run_id="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

[ -n "$run_id" ] || usage
load_run_env "$run_id"
exec tmux -CC attach -t "$SESSION_NAME"
