#!/bin/sh

shell_quote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

write_env_var() {
  name="$1"
  value="$2"
  printf '%s=' "$name" >> "$RUN_ENV"
  shell_quote "$value" >> "$RUN_ENV"
  printf '\n' >> "$RUN_ENV"
}

ensure_git_excludes() {
  workspace="$1"
  exclude_file="$workspace/.git/info/exclude"
  [ -f "$exclude_file" ] || : > "$exclude_file"
  for pattern in ".agents-swarm/" ".claude/agents/swarm-*.md"; do
    if ! grep -Fx "$pattern" "$exclude_file" >/dev/null 2>&1; then
      printf '%s\n' "$pattern" >> "$exclude_file"
    fi
  done
}

init_run_state() {
  mkdir -p "$RUN_DIR/prompts" \
    "$STATE_DIR/contracts" \
    "$STATE_DIR/evidence" \
    "$STATE_DIR/messages" \
    "$LOG_DIR"

  : > "$STATE_DIR/plan.md"
  : > "$STATE_DIR/final-report.md"
  cat > "$STATE_DIR/contracts/sprint-1.json" <<'JSON'
{
  "sprint": 1,
  "status": "draft",
  "paths_in_scope": [],
  "criteria": [],
  "ledger": []
}
JSON
}

write_run_env_file() {
  : > "$RUN_ENV"
  write_env_var SWARM_ROOT "$SWARM_ROOT"
  write_env_var WORKSPACE "$WORKSPACE"
  write_env_var RUN_ID "$RUN_ID"
  write_env_var RUN_DIR "$RUN_DIR"
  write_env_var RUN_ENV "$RUN_ENV"
  write_env_var STATE_DIR "$STATE_DIR"
  write_env_var LOG_DIR "$LOG_DIR"
  write_env_var GOAL_FILE "$GOAL_FILE"
  write_env_var SESSION_NAME "$SESSION_NAME"
  write_env_var PARENT_PANE "$PARENT_PANE"
  write_env_var PLANNER_PANE "$PLANNER_PANE"
  write_env_var GENERATOR_PANE "$GENERATOR_PANE"
  write_env_var EVALUATOR_PANE "$EVALUATOR_PANE"
}

write_run_index_file() {
  index_dir=$(run_index_dir)
  mkdir -p "$index_dir"
  index_file=$(run_index_file "$RUN_ID")
  : > "$index_file"
  write_index_var() {
    printf '%s=' "$1" >> "$index_file"
    shell_quote "$2" >> "$index_file"
    printf '\n' >> "$index_file"
  }
  write_index_var RUN_ID "$RUN_ID"
  write_index_var WORKSPACE "$WORKSPACE"
  write_index_var RUN_DIR "$RUN_DIR"
  write_index_var RUN_ENV "$RUN_ENV"
  write_index_var SESSION_NAME "$SESSION_NAME"
}

install_project_agents() {
  mkdir -p "$WORKSPACE/.claude/agents"
  cp "$SWARM_ROOT/agents/swarm-parent.md" "$WORKSPACE/.claude/agents/swarm-parent.md"
  cp "$SWARM_ROOT/agents/swarm-planner.md" "$WORKSPACE/.claude/agents/swarm-planner.md"
  cp "$SWARM_ROOT/agents/swarm-generator.md" "$WORKSPACE/.claude/agents/swarm-generator.md"
  cp "$SWARM_ROOT/agents/swarm-evaluator.md" "$WORKSPACE/.claude/agents/swarm-evaluator.md"
}
