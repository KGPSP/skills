#!/usr/bin/env bash
# run-goal-loop.sh — autonomiczna pętla AC dla trybu /goal (faza Goal Mode)
# Usage: scripts/run-goal-loop.sh <path-to-goal-current.json>
# Pętla iteruje aż verification exit 0 LUB MAX_GOAL_ITERATIONS LUB timeout.

set -euo pipefail

GOAL_FILE="${1:?Usage: run-goal-loop.sh <goal-current.json>}"
BASE_DIR="${BASE_DIR:-$(pwd)}"

MAX_ITER="${MAX_GOAL_ITERATIONS:-10}"
TIMEOUT_HOURS="${GOAL_TIMEOUT_HOURS:-6}"
AUTO_PIVOT="${GOAL_AUTO_PIVOT:-0}"

[[ -f "$GOAL_FILE" ]] || { echo "[FAIL] $GOAL_FILE not found"; exit 1; }

# Preflight: czysty git status
if [[ -d "$BASE_DIR/.git" ]]; then
  if [[ -n "$(cd "$BASE_DIR" && git status --porcelain)" ]]; then
    echo "[GOAL BLOCKED] uncommitted changes. Commit or stash first."
    exit 2
  fi
fi

# Wyciągnij parametry
END_STATE=$(jq -r '.end_state' "$GOAL_FILE")
VERIFICATION_CMDS=$(jq -r '.verification[]' "$GOAL_FILE")
CONSTRAINTS=$(jq -r '.constraints[]' "$GOAL_FILE")

echo "=== /goal autonomous loop ==="
echo "End state: $END_STATE"
echo "Max iterations: $MAX_ITER"
echo "Timeout: ${TIMEOUT_HOURS}h"
echo ""

# Mark start in breadcrumbs
TS_START=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
bash "$BASE_DIR/scripts/append-breadcrumb.sh" "goal-loop" "goal_loop_start" \
  "$(jq -nc --arg es "$END_STATE" --arg mi "$MAX_ITER" '{end_state: $es, max_iter: ($mi | tonumber)}')"

START_EPOCH=$(date +%s)
TIMEOUT_SEC=$((TIMEOUT_HOURS * 3600))

iteration=0
while [[ "$iteration" -lt "$MAX_ITER" ]]; do
  iteration=$((iteration + 1))
  NOW=$(date +%s)
  ELAPSED=$((NOW - START_EPOCH))

  if [[ "$ELAPSED" -gt "$TIMEOUT_SEC" ]]; then
    echo "[TIMEOUT] Przekroczono ${TIMEOUT_HOURS}h."
    bash "$BASE_DIR/scripts/append-breadcrumb.sh" "goal-loop" "goal_timeout" \
      "$(jq -nc --argjson i "$iteration" --argjson e "$ELAPSED" '{iteration: $i, elapsed_sec: $e}')"
    exit 3
  fi

  echo "[iter $iteration/$MAX_ITER, +${ELAPSED}s]"

  # Run verification commands
  ALL_PASSED=1
  FAILED_OUTPUT=""
  while IFS= read -r cmd; do
    [[ -z "$cmd" ]] && continue
    echo "  Running: $cmd"
    if ! OUTPUT=$(eval "$cmd" 2>&1); then
      ALL_PASSED=0
      FAILED_OUTPUT="${FAILED_OUTPUT}\n--- $cmd ---\n${OUTPUT}\n"
    fi
  done <<< "$VERIFICATION_CMDS"

  if [[ "$ALL_PASSED" -eq 1 ]]; then
    echo "[ACHIEVED] Wszystkie verification commands exit 0."
    bash "$BASE_DIR/scripts/append-breadcrumb.sh" "goal-loop" "goal_achieved" \
      "$(jq -nc --argjson i "$iteration" --argjson e "$ELAPSED" '{iteration: $i, elapsed_sec: $e}')"

    # Generate goal-report.md
    cat > "$BASE_DIR/state/goal-report.md" <<EOF
# Goal Report

## Status: achieved
- End state: $END_STATE
- Iterations: $iteration / $MAX_ITER
- Duration: $((ELAPSED / 60)) min

## Verification commands (all exit 0)
$(echo "$VERIFICATION_CMDS" | sed 's/^/- /')

## Git log
$(cd "$BASE_DIR" && git log --oneline -10)
EOF
    exit 0
  fi

  # Failed: record iteration
  bash "$BASE_DIR/scripts/append-breadcrumb.sh" "goal-loop" "goal_iteration_failed" \
    "$(jq -nc --argjson i "$iteration" --arg out "$(echo -e "$FAILED_OUTPUT" | head -c 1000)" \
      '{iteration: $i, failed_output_excerpt: $out}')"

  echo "[FAIL iter $iteration] verification commands exit ≠0. Generator should iterate."
  echo -e "Excerpt:\n${FAILED_OUTPUT}" | head -20

  # W tym miejscu w realnej integracji Agent Teams: spawn Generator z feedback
  # Tu w skrypcie tylko logujemy i czekamy na ręczne dopchnięcie generatora w sesji
  # (skrypt jest helperem, NIE zastępuje orkiestracji Agent Teams)

  echo "[INFO] Spawn Generator z tym feedback'em. Po commicie wznów: scripts/run-goal-loop.sh $GOAL_FILE"
  exit 4
done

# Max iterations bez sukcesu
echo "[STAGNATION] $MAX_ITER iteracji bez sukcesu."
if [[ "$AUTO_PIVOT" == "1" ]]; then
  echo "[AUTO_PIVOT] uruchamiam pivot-trigger.sh..."
  bash "$BASE_DIR/scripts/append-breadcrumb.sh" "goal-loop" "goal_auto_pivot_triggered" \
    "$(jq -nc --argjson i "$iteration" '{iteration: $i}')"
  # Pivot wymaga pivot_plan.md — Evaluator musi go napisać
  exit 5
else
  echo "[ESCALATION] AUTO_PIVOT=0 → eskalacja do human. Patrz state/blockers.md"
  bash "$BASE_DIR/scripts/append-breadcrumb.sh" "goal-loop" "goal_escalated" \
    "$(jq -nc --argjson i "$iteration" '{iteration: $i, reason: "max_iterations_reached"}')"
  exit 6
fi
