#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SWARM_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
. "$SWARM_ROOT/scripts/lib/paths.sh"

usage() {
  printf 'Usage: swarm-status.sh --run <run-id>\n' >&2
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

printf 'RUN_ID=%s\n' "$RUN_ID"
printf 'WORKSPACE=%s\n' "$WORKSPACE"
printf 'RUN_DIR=%s\n' "$RUN_DIR"
printf 'SESSION_NAME=%s\n' "$SESSION_NAME"
printf 'ROLE_PANES=parent:%s planner:%s generator:%s evaluator:%s\n' "$PARENT_PANE" "$PLANNER_PANE" "$GENERATOR_PANE" "$EVALUATOR_PANE"

if tmux has-session -t "$SESSION_NAME" >/dev/null 2>&1; then
  printf 'TMUX_STATUS=running\n'
  tmux list-panes -t "$SESSION_NAME" -F 'PANE=#{pane_id} TITLE=#{pane_title} ACTIVE=#{pane_active} DEAD=#{pane_dead}'
else
  printf 'TMUX_STATUS=stopped\n'
fi
