#!/usr/bin/env bash
# run-goal-loop.sh — autonomous goal-driven loop driver (6-Goal route).
# Pure validator/driver — calling Claude session woła model, nie ten skrypt.
# Usage: run-goal-loop.sh --goal <path> --plan <path>
#                       [--max-iter N] [--max-time MIN]
#                       [--worktree PATH] [--files-touched CSV]
#                       [--fragile-paths CSV] [--dry-run]
#
# Note: --max-iter, --max-time, --worktree, --files-touched are accepted and
# echoed in dry-run for caller visibility, but NOT enforced by this script.
# The calling Claude session is responsible for counting iterations, timing
# out, and verifying scope/worktree boundaries before re-invoking this script.
# Each invocation runs verification commands once and exits.

set -euo pipefail

GOAL=""
PLAN=""
MAX_ITER=20
MAX_TIME=480
WORKTREE=""
FILES_TOUCHED=""
FRAGILE_PATHS="migrations/,terraform/,k8s/,auth/,.github/workflows/,Dockerfile"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --goal) GOAL="$2"; shift 2 ;;
    --plan) PLAN="$2"; shift 2 ;;
    --max-iter) MAX_ITER="$2"; shift 2 ;;
    --max-time) MAX_TIME="$2"; shift 2 ;;
    --worktree) WORKTREE="$2"; shift 2 ;;
    --files-touched) FILES_TOUCHED="$2"; shift 2 ;;
    --fragile-paths) FRAGILE_PATHS="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) echo "Usage: $0 --goal <path> --plan <path> [--dry-run] [--max-iter N] [--max-time MIN]"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

[[ -z "$GOAL" ]] && { echo "ERR: --goal required" >&2; exit 2; }
[[ -z "$PLAN" ]] && { echo "ERR: --plan required" >&2; exit 2; }
[[ ! -f "$GOAL" ]] && { echo "ERR: goal file not found: $GOAL" >&2; exit 1; }
[[ ! -f "$PLAN" ]] && { echo "ERR: plan file not found: $PLAN" >&2; exit 1; }

GOAL_CONTENT=$(tr -d '\r' < "$GOAL")

# --- Parse verification commands ---
# Each "### AC-X — T-Y" block has a "Komenda" line.
# Use bash 3.2-compatible array population (no mapfile).
CMD_LINES=()
while IFS= read -r line; do
  CMD_LINES+=("$line")
done < <(grep "^- \*\*Komenda\*\*:" <<<"$GOAL_CONTENT")

AC_HEADERS=()
while IFS= read -r line; do
  AC_HEADERS+=("$line")
done < <(grep "^### " <<<"$GOAL_CONTENT")

if [[ ${#CMD_LINES[@]} -eq 0 ]]; then
  echo "ERR: no verification commands found in $GOAL" >&2
  exit 1
fi

if [[ ${#CMD_LINES[@]} -ne ${#AC_HEADERS[@]} ]]; then
  echo "WARN: ${#AC_HEADERS[@]} AC headers vs ${#CMD_LINES[@]} commands — count mismatch" >&2
fi

# --- Dry-run: print plan and exit ---
if [[ $DRY_RUN -eq 1 ]]; then
  echo "DRY-RUN: would execute goal loop with these parameters:"
  echo "  goal:            \"$GOAL\""
  echo "  plan:            \"$PLAN\""
  echo "  max-iter:        $MAX_ITER"
  echo "  max-time (min):  $MAX_TIME"
  echo "  worktree:        \"${WORKTREE:-<none>}\""
  echo "  files-touched:   \"${FILES_TOUCHED:-<all>}\""
  echo "  fragile-paths:   \"$FRAGILE_PATHS\""
  echo ""
  echo "Verification commands (${#CMD_LINES[@]}):"
  for i in "${!CMD_LINES[@]}"; do
    HEADER="${AC_HEADERS[$i]:-(no header)}"
    CMD=$(echo "${CMD_LINES[$i]}" | sed 's/^- \*\*Komenda\*\*: //')
    echo "  [$((i+1))] ${HEADER} → ${CMD}"
  done
  echo ""
  echo "DRY-RUN: no execution, no commits."
  exit 0
fi

# --- Live mode: run verification commands once, aggregate, hand off ---
LOG_DIR=$(dirname "$GOAL")
RUN_LOG="${LOG_DIR}/$(basename "$GOAL" -goal-statement.md)-goal-run-log.md"
RESULT="${LOG_DIR}/$(basename "$GOAL" -goal-statement.md)-goal-result.md"

START_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "# Goal Run Log — $(basename "$GOAL")" > "$RUN_LOG"
echo "" >> "$RUN_LOG"
echo "Started: $START_TS" >> "$RUN_LOG"
echo "" >> "$RUN_LOG"

ALL_GREEN=1
FIRST_FAIL_HEADER=""
FIRST_FAIL_CMD=""
FIRST_FAIL_OUT=""

for i in "${!CMD_LINES[@]}"; do
  HEADER="${AC_HEADERS[$i]:-(no header)}"
  CMD=$(echo "${CMD_LINES[$i]}" | sed 's/^- \*\*Komenda\*\*: //' | sed 's/^`//; s/`$//')
  echo "## ${HEADER}" >> "$RUN_LOG"
  echo "Command: \`${CMD}\`" >> "$RUN_LOG"
  echo "" >> "$RUN_LOG"
  echo '```' >> "$RUN_LOG"
  OUT=$(bash -c "$CMD" 2>&1) || true
  RC=$?
  echo "$OUT" >> "$RUN_LOG"
  echo '```' >> "$RUN_LOG"
  echo "Exit code: $RC" >> "$RUN_LOG"
  echo "" >> "$RUN_LOG"

  if [[ $RC -ne 0 && $ALL_GREEN -eq 1 ]]; then
    ALL_GREEN=0
    FIRST_FAIL_HEADER="$HEADER"
    FIRST_FAIL_CMD="$CMD"
    FIRST_FAIL_OUT="$OUT"
  fi
done

END_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [[ $ALL_GREEN -eq 1 ]]; then
  STATUS="GREEN"
else
  STATUS="NEEDS_AGENT_ITERATION"
fi

{
  echo "# Goal Result"
  echo ""
  echo "- **status**: ${STATUS}"
  echo "- **started**: ${START_TS}"
  echo "- **ended**: ${END_TS}"
  echo "- **commands**: ${#CMD_LINES[@]}"
  echo "- **log**: ${RUN_LOG}"
} > "$RESULT"

if [[ $ALL_GREEN -eq 1 ]]; then
  echo "STATUS=GREEN"
  echo "Result: $RESULT"
  exit 0
fi

# --- Hand-off context to calling Claude session ---
echo "STATUS=NEEDS_AGENT_ITERATION"
echo "Result: $RESULT"
echo "Log:    $RUN_LOG"
echo ""
echo "=== HAND-OFF CONTEXT (for calling Claude session) ==="
echo "Focus AC: ${FIRST_FAIL_HEADER}"
echo "Failed command: ${FIRST_FAIL_CMD}"
echo ""
echo "--- Raw output ---"
printf '%s\n' "$FIRST_FAIL_OUT"
echo "--- End raw output ---"
echo ""
echo "Action required:"
echo "  1. Read failed command + raw output above."
echo "  2. Implement minimal change in code to fix it."
echo "  3. Run Anti-Rationalization quick-check (11 wierszy) before commit."
echo "  4. Verify no Fragile-path or out-of-scope file touched."
echo "  5. git commit atomic."
echo "  6. Re-invoke: bash $0 --goal \"\$GOAL\" --plan \"\$PLAN\""
exit 1
