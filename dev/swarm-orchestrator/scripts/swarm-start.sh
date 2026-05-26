#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SWARM_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
. "$SWARM_ROOT/scripts/lib/paths.sh"
. "$SWARM_ROOT/scripts/lib/state.sh"
. "$SWARM_ROOT/scripts/lib/prompt.sh"
. "$SWARM_ROOT/scripts/lib/tmux.sh"

usage() {
  cat >&2 <<'USAGE'
Usage: swarm-start.sh --workspace <repo> --goal <text|file> [--name <slug>] [--allow-dirty]
USAGE
  exit 2
}

workspace_arg=
goal_arg=
name_arg=
allow_dirty=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --workspace) [ "$#" -ge 2 ] || usage; workspace_arg="$2"; shift 2 ;;
    --goal) [ "$#" -ge 2 ] || usage; goal_arg="$2"; shift 2 ;;
    --name) [ "$#" -ge 2 ] || usage; name_arg="$2"; shift 2 ;;
    --allow-dirty) allow_dirty=1; shift ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

[ -n "$workspace_arg" ] || usage
[ -n "$goal_arg" ] || usage

command_exists tmux || die "tmux is required"
command_exists claude || die "claude is required"
command_exists git || die "git is required"

WORKSPACE=$(abs_dir "$workspace_arg") || die "workspace does not exist: $workspace_arg"
git -C "$WORKSPACE" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "workspace is not a git repo: $WORKSPACE"

if [ "$allow_dirty" -ne 1 ]; then
  dirty=$(git -C "$WORKSPACE" status --short --untracked-files=all)
  [ -z "$dirty" ] || die "workspace has uncommitted changes; pass --allow-dirty to continue"
fi

if [ -n "$name_arg" ]; then
  slug=$(sanitize_slug "$name_arg")
else
  base=$(basename "$WORKSPACE")
  slug=$(sanitize_slug "$base")
fi
[ -n "$slug" ] || slug=swarm

RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$$"
SESSION_NAME="swarm-$slug-$RUN_ID"
RUN_DIR="$WORKSPACE/.agents-swarm/runs/$RUN_ID"
RUN_ENV="$RUN_DIR/run.env"
STATE_DIR="$RUN_DIR/state"
LOG_DIR="$RUN_DIR/logs"
GOAL_FILE="$RUN_DIR/goal.md"

ensure_git_excludes "$WORKSPACE"
init_run_state
install_project_agents

if [ -f "$goal_arg" ]; then
  cp "$goal_arg" "$GOAL_FILE"
else
  printf '%s\n' "$goal_arg" > "$GOAL_FILE"
fi

tmux_start_swarm
write_run_env_file
write_run_index_file
render_boot_prompts
tmux_send_boot_prompts

printf 'RUN_ID=%s\n' "$RUN_ID"
printf 'SESSION_NAME=%s\n' "$SESSION_NAME"
printf 'RUN_DIR=%s\n' "$RUN_DIR"
printf 'ATTACH=tmux -CC attach -t %s\n' "$SESSION_NAME"
