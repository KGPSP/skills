#!/bin/sh

die() {
  printf 'ERR: %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

abs_dir() {
  [ -d "$1" ] || return 1
  CDPATH= cd -- "$1" && pwd -P
}

sanitize_slug() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9_-]/-/g; s/--*/-/g; s/^-//; s/-$//' \
    | cut -c 1-48
}

require_swarm_root() {
  [ -n "${SWARM_ROOT:-}" ] || die "SWARM_ROOT is not set by the caller"
  [ -d "$SWARM_ROOT/scripts" ] || die "invalid SWARM_ROOT: $SWARM_ROOT"
}

run_index_dir() {
  require_swarm_root
  printf '%s/.runs\n' "$SWARM_ROOT"
}

run_index_file() {
  [ -n "${1:-}" ] || die "run id is required"
  printf '%s/%s.env\n' "$(run_index_dir)" "$1"
}

load_run_env() {
  [ -n "${1:-}" ] || die "--run is required"
  env_file=$(run_index_file "$1")
  [ -f "$env_file" ] || die "unknown run id '$1' (missing $env_file)"
  # shellcheck disable=SC1090
  . "$env_file"
  [ -n "${RUN_ENV:-}" ] || die "run index is missing RUN_ENV"
  [ -f "$RUN_ENV" ] || die "run env no longer exists: $RUN_ENV"
  # shellcheck disable=SC1090
  . "$RUN_ENV"
}

role_pane_var() {
  case "$1" in
    parent) printf '%s\n' "$PARENT_PANE" ;;
    planner) printf '%s\n' "$PLANNER_PANE" ;;
    generator) printf '%s\n' "$GENERATOR_PANE" ;;
    evaluator) printf '%s\n' "$EVALUATOR_PANE" ;;
    *) die "unknown role '$1'; expected parent, planner, generator, or evaluator" ;;
  esac
}
