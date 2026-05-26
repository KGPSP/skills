#!/bin/sh

render_prompt() {
  template="$1"
  output="$2"
  role="${3:-}"
  phase="${4:-}"
  sprint="${5:-1}"

  [ -f "$template" ] || die "missing prompt template: $template"

  awk \
    -v workspace="$WORKSPACE" \
    -v run_id="$RUN_ID" \
    -v run_dir="$RUN_DIR" \
    -v state_dir="$STATE_DIR" \
    -v goal_file="$GOAL_FILE" \
    -v role="$role" \
    -v phase="$phase" \
    -v sprint="$sprint" '
    function esc(s) {
      gsub(/\\/, "\\\\", s)
      gsub(/&/, "\\&", s)
      return s
    }
    BEGIN {
      workspace = esc(workspace)
      run_id = esc(run_id)
      run_dir = esc(run_dir)
      state_dir = esc(state_dir)
      goal_file = esc(goal_file)
      role = esc(role)
      phase = esc(phase)
      sprint = esc(sprint)
    }
    {
      gsub(/\{\{WORKSPACE\}\}/, workspace)
      gsub(/\{\{RUN_ID\}\}/, run_id)
      gsub(/\{\{RUN_DIR\}\}/, run_dir)
      gsub(/\{\{STATE_DIR\}\}/, state_dir)
      gsub(/\{\{GOAL_FILE\}\}/, goal_file)
      gsub(/\{\{ROLE\}\}/, role)
      gsub(/\{\{PHASE\}\}/, phase)
      gsub(/\{\{SPRINT\}\}/, sprint)
      print
    }
  ' "$template" > "$output"
}

render_boot_prompts() {
  render_prompt "$SWARM_ROOT/prompts/boot-parent.md" "$RUN_DIR/prompts/parent.md" parent boot 1
  render_prompt "$SWARM_ROOT/prompts/boot-planner.md" "$RUN_DIR/prompts/planner.md" planner boot 1
  render_prompt "$SWARM_ROOT/prompts/boot-generator.md" "$RUN_DIR/prompts/generator.md" generator boot 1
  render_prompt "$SWARM_ROOT/prompts/boot-evaluator.md" "$RUN_DIR/prompts/evaluator.md" evaluator boot 1
}
