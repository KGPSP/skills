#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SWARM_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
. "$SWARM_ROOT/scripts/lib/paths.sh"
. "$SWARM_ROOT/scripts/lib/tmux.sh"

usage() {
  printf 'Usage: swarm-send.sh --run <run-id> --to parent|planner|generator|evaluator --file <prompt.md>\n' >&2
  exit 2
}

run_id=
role=
prompt_file=
while [ "$#" -gt 0 ]; do
  case "$1" in
    --run) [ "$#" -ge 2 ] || usage; run_id="$2"; shift 2 ;;
    --to) [ "$#" -ge 2 ] || usage; role="$2"; shift 2 ;;
    --file) [ "$#" -ge 2 ] || usage; prompt_file="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

[ -n "$run_id" ] || usage
[ -n "$role" ] || usage
[ -n "$prompt_file" ] || usage

load_run_env "$run_id"
pane=$(role_pane_var "$role")
tmux_send_file "$pane" "$prompt_file"
printf 'sent role=%s pane=%s file=%s\n' "$role" "$pane" "$prompt_file"
