#!/bin/sh

tmux_require_session_absent() {
  if tmux has-session -t "$1" >/dev/null 2>&1; then
    die "tmux session already exists: $1"
  fi
}

tmux_start_swarm() {
  tmux_require_session_absent "$SESSION_NAME"

  PARENT_PANE=$(tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE" -n swarm -P -F '#{pane_id}' env "PATH=$PATH" "FAKE_CLAUDE_LOG=${FAKE_CLAUDE_LOG-}" claude)
  PLANNER_PANE=$(tmux split-window -d -v -t "$PARENT_PANE" -c "$WORKSPACE" -P -F '#{pane_id}' env "PATH=$PATH" "FAKE_CLAUDE_LOG=${FAKE_CLAUDE_LOG-}" claude)
  GENERATOR_PANE=$(tmux split-window -d -h -t "$PARENT_PANE" -c "$WORKSPACE" -P -F '#{pane_id}' env "PATH=$PATH" "FAKE_CLAUDE_LOG=${FAKE_CLAUDE_LOG-}" claude)
  EVALUATOR_PANE=$(tmux split-window -d -v -t "$GENERATOR_PANE" -c "$WORKSPACE" -P -F '#{pane_id}' env "PATH=$PATH" "FAKE_CLAUDE_LOG=${FAKE_CLAUDE_LOG-}" claude)

  tmux select-pane -t "$PARENT_PANE" -T parent >/dev/null 2>&1 || true
  tmux select-pane -t "$PLANNER_PANE" -T planner >/dev/null 2>&1 || true
  tmux select-pane -t "$GENERATOR_PANE" -T generator >/dev/null 2>&1 || true
  tmux select-pane -t "$EVALUATOR_PANE" -T evaluator >/dev/null 2>&1 || true
  tmux select-layout -t "$SESSION_NAME" tiled >/dev/null 2>&1 || true
}

tmux_send_file() {
  pane="$1"
  file="$2"
  [ -f "$file" ] || die "prompt file does not exist: $file"
  buffer="agents-swarm-$$-$(date +%s)"
  tmux load-buffer -b "$buffer" "$file"
  tmux paste-buffer -d -b "$buffer" -t "$pane"
  tmux send-keys -t "$pane" Enter
}

tmux_send_boot_prompts() {
  tmux_send_file "$PARENT_PANE" "$RUN_DIR/prompts/parent.md"
  tmux_send_file "$PLANNER_PANE" "$RUN_DIR/prompts/planner.md"
  tmux_send_file "$GENERATOR_PANE" "$RUN_DIR/prompts/generator.md"
  tmux_send_file "$EVALUATOR_PANE" "$RUN_DIR/prompts/evaluator.md"
}
