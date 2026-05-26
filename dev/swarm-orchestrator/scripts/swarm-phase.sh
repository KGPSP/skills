#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SWARM_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
. "$SWARM_ROOT/scripts/lib/paths.sh"
. "$SWARM_ROOT/scripts/lib/prompt.sh"
. "$SWARM_ROOT/scripts/lib/tmux.sh"

usage() {
  printf 'Usage: swarm-phase.sh --run <run-id> --phase plan|contract|generate|evaluate|report [--sprint N]\n' >&2
  exit 2
}

run_id=
phase=
sprint=1
while [ "$#" -gt 0 ]; do
  case "$1" in
    --run) [ "$#" -ge 2 ] || usage; run_id="$2"; shift 2 ;;
    --phase) [ "$#" -ge 2 ] || usage; phase="$2"; shift 2 ;;
    --sprint) [ "$#" -ge 2 ] || usage; sprint="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

[ -n "$run_id" ] || usage
[ -n "$phase" ] || usage

load_run_env "$run_id"

template="$SWARM_ROOT/prompts/phase-$phase.md"
[ -f "$template" ] || die "unknown phase '$phase'"

send_phase_to_role() {
  send_role="$1"
  pane=$(role_pane_var "$send_role")
  out="$RUN_DIR/prompts/phase-$phase-$send_role.md"
  render_prompt "$template" "$out" "$send_role" "$phase" "$sprint"
  tmux_send_file "$pane" "$out"
  printf 'sent phase=%s role=%s pane=%s\n' "$phase" "$send_role" "$pane"
}

case "$phase" in
  plan)
    send_phase_to_role planner
    ;;
  contract)
    send_phase_to_role generator
    send_phase_to_role evaluator
    ;;
  generate)
    send_phase_to_role generator
    ;;
  evaluate)
    send_phase_to_role evaluator
    ;;
  report)
    send_phase_to_role parent
    send_phase_to_role evaluator
    ;;
  *)
    die "unknown phase '$phase'"
    ;;
esac
