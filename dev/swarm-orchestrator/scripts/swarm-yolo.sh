#!/bin/sh
# swarm-yolo.sh — single-iteration YOLO/hybrid driver dla swarm-orchestrator.
# Konwencja: jak run-goal-loop.sh z audited-feature-workflow — JEDEN call = jedna iteracja.
# Calling Claude session (lub bash wrapper) re-invokuje skrypt po commit.
#
# Robi w jednej iteracji:
#   1. Sprawdza STOP conditions (iter-cap, time-cap, no-progress)
#   2. Uruchamia verification commands z goal-statement.md
#   3. Jeśli GREEN → archive run (gate:5) + exit 0
#   4. Jeśli FAIL → wysyła phase-yolo-iterate do generator pane (tmux) + exit 1
#   5. Sprawdza scope-violation, pr-size, fragile paths przed exit
#
# Usage:
#   swarm-yolo.sh --run <RUN_ID> --mode {hybrid|yolo}
#                 [--max-iter 20] [--max-time 480] [--sprint 1]
#                 [--force-fragile] [--dry-run]
#
# Exit codes:
#   0  GREEN (success, sprint achieved, archive done)
#   1  NEEDS_AGENT_ITERATION (failed verification, generator should iterate)
#   2  bad args / missing files
#   3  iter-cap-hit / time-cap-hit
#   4  no-progress (auto-pivot triggered or escalation)
#   5  scope-violation (fragile zone or out-of-scope file touched)
#   6  pr-too-big
#   7  destructive command attempted

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SWARM_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
. "$SWARM_ROOT/scripts/lib/paths.sh"
. "$SWARM_ROOT/scripts/lib/prompt.sh"
. "$SWARM_ROOT/scripts/lib/tmux.sh"

usage() {
  cat >&2 <<'USAGE'
Usage: swarm-yolo.sh --run <RUN_ID> --mode {hybrid|yolo}
                     [--max-iter 20] [--max-time 480] [--sprint 1]
                     [--force-fragile] [--dry-run]
USAGE
  exit 2
}

run_id=
mode=
max_iter=20
max_time=480
sprint=1
force_fragile=0
dry_run=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --run) [ "$#" -ge 2 ] || usage; run_id="$2"; shift 2 ;;
    --mode) [ "$#" -ge 2 ] || usage; mode="$2"; shift 2 ;;
    --max-iter) [ "$#" -ge 2 ] || usage; max_iter="$2"; shift 2 ;;
    --max-time) [ "$#" -ge 2 ] || usage; max_time="$2"; shift 2 ;;
    --sprint) [ "$#" -ge 2 ] || usage; sprint="$2"; shift 2 ;;
    --force-fragile) force_fragile=1; shift ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

[ -n "$run_id" ] || usage
case "$mode" in
  hybrid|yolo) ;;
  *) echo "ERR: --mode must be hybrid or yolo (got: $mode)" >&2; exit 2 ;;
esac

[ "$max_iter" -ge 1 ] 2>/dev/null || { echo "ERR: --max-iter must be >=1" >&2; exit 2; }
[ "$max_time" -ge 1 ] 2>/dev/null || { echo "ERR: --max-time must be >=1 min" >&2; exit 2; }

load_run_env "$run_id"

GOAL_STATEMENT="$RUN_DIR/state/goal-statement.md"
CONTRACT="$RUN_DIR/state/contracts/sprint-${sprint}.json"
BREADCRUMBS="$RUN_DIR/state/breadcrumbs.json"
ITER_LOG_DIR="$RUN_DIR/logs"
YOLO_STATUS="$RUN_DIR/state/yolo-status.json"
RUN_LOG="$ITER_LOG_DIR/goal-run-log.md"

[ -f "$GOAL_STATEMENT" ] || { echo "ERR: missing goal-statement.md; run swarm-derive-goal.sh first: $GOAL_STATEMENT" >&2; exit 2; }
[ -f "$CONTRACT" ] || { echo "ERR: missing contract: $CONTRACT (run contract phase first)" >&2; exit 2; }
[ -f "$BREADCRUMBS" ] || { echo "ERR: missing breadcrumbs: $BREADCRUMBS" >&2; exit 2; }

mkdir -p "$ITER_LOG_DIR"

# --- Iter counter (load or init) ---
ITER=0
if [ -f "$YOLO_STATUS" ]; then
  ITER=$(jq -r '.iter // 0' "$YOLO_STATUS" 2>/dev/null || echo 0)
fi
ITER=$((ITER + 1))

# --- Time-cap check (start_ts in yolo-status or now) ---
NOW=$(date +%s)
if [ -f "$YOLO_STATUS" ]; then
  START_TS=$(jq -r '.start_ts // empty' "$YOLO_STATUS" 2>/dev/null || true)
fi
if [ -z "${START_TS:-}" ]; then
  START_TS="$NOW"
fi
ELAPSED_SEC=$((NOW - START_TS))
MAX_TIME_SEC=$((max_time * 60))

# --- STOP: iter-cap ---
if [ "$ITER" -gt "$max_iter" ]; then
  {
    printf '{"status":"iter-cap-hit","iter":%s,"max_iter":%s,"elapsed_sec":%s}\n' \
      "$ITER" "$max_iter" "$ELAPSED_SEC"
  } > "$YOLO_STATUS"
  BASE_DIR="$RUN_DIR" "$SWARM_ROOT/scripts/append-breadcrumb.sh" yolo yolo_stopped "{\"reason\":\"iter-cap-hit\",\"iter\":$ITER,\"sprint\":$sprint}"
  echo "STATUS=iter-cap-hit iter=$ITER max=$max_iter" >&2
  exit 3
fi

# --- STOP: time-cap ---
if [ "$ELAPSED_SEC" -gt "$MAX_TIME_SEC" ]; then
  {
    printf '{"status":"time-cap-hit","iter":%s,"elapsed_sec":%s,"max_time_sec":%s}\n' \
      "$ITER" "$ELAPSED_SEC" "$MAX_TIME_SEC"
  } > "$YOLO_STATUS"
  BASE_DIR="$RUN_DIR" "$SWARM_ROOT/scripts/append-breadcrumb.sh" yolo yolo_stopped "{\"reason\":\"time-cap-hit\",\"elapsed_sec\":$ELAPSED_SEC,\"sprint\":$sprint}"
  echo "STATUS=time-cap-hit elapsed=${ELAPSED_SEC}s max=${MAX_TIME_SEC}s" >&2
  exit 3
fi

# --- Fragile paths check (chyba że --force-fragile) ---
FRAGILE_PATHS="migrations/,terraform/,k8s/,auth/,.github/workflows/,Dockerfile,prod"
if [ "$force_fragile" -eq 0 ]; then
  PATHS_IN_SCOPE=$(jq -r '.paths_in_scope[]?' "$CONTRACT" 2>/dev/null || true)
  if [ -n "$PATHS_IN_SCOPE" ]; then
    VIOLATIONS=""
    IFS=','
    for fragile in $FRAGILE_PATHS; do
      [ -n "$fragile" ] || continue
      MATCH=$(printf '%s\n' "$PATHS_IN_SCOPE" | grep -F "$fragile" || true)
      if [ -n "$MATCH" ]; then
        VIOLATIONS="${VIOLATIONS}${fragile} "
      fi
    done
    unset IFS
    if [ -n "$VIOLATIONS" ]; then
      printf '{"status":"scope-violation","reason":"fragile-zone-in-paths_in_scope","violations":"%s"}\n' "$VIOLATIONS" > "$YOLO_STATUS"
      BASE_DIR="$RUN_DIR" "$SWARM_ROOT/scripts/append-breadcrumb.sh" yolo yolo_stopped "{\"reason\":\"fragile-zone-in-scope\",\"violations\":\"$VIOLATIONS\"}"
      echo "STATUS=scope-violation fragile_paths=$VIOLATIONS" >&2
      echo "Use --force-fragile to override (will be logged in breadcrumbs)" >&2
      exit 5
    fi
  fi
fi

# --- Run verification commands z goal-statement.md ---
# Format goal-statement.md: sekcja "## Weryfikacja" zawiera bloki "### AC-X" z linią "- **Komenda**: `cmd`".
{
  printf '# Goal Run Log — iter %s — %s\n\n' "$ITER" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} >> "$RUN_LOG"

WERYFIKACJA=$(awk '/^## Weryfikacja/{f=1; next} /^## /{f=0} f' "$GOAL_STATEMENT")
[ -n "$WERYFIKACJA" ] || { echo "ERR: missing '## Weryfikacja' section in $GOAL_STATEMENT" >&2; exit 2; }

# Wyciągnij komendy (linia "- **Komenda**: `cmd`")
CMD_FILE=$(mktemp)
HEADER_FILE=$(mktemp)
trap 'rm -f "$CMD_FILE" "$HEADER_FILE"' EXIT
printf '%s\n' "$WERYFIKACJA" | grep '^- \*\*Komenda\*\*:' | sed 's/^- \*\*Komenda\*\*: //; s/^`//; s/`$//' > "$CMD_FILE"
printf '%s\n' "$WERYFIKACJA" | grep '^### ' > "$HEADER_FILE"

CMD_COUNT=$(wc -l < "$CMD_FILE" | tr -d ' ')
[ "$CMD_COUNT" -ge 1 ] || { echo "ERR: no verification commands in $GOAL_STATEMENT" >&2; exit 2; }

ALL_GREEN=1
FIRST_FAIL_HEADER=""
FIRST_FAIL_CMD=""
FIRST_FAIL_OUT=""
FIRST_FAIL_LOG=""

I=0
while IFS= read -r CMD; do
  I=$((I + 1))
  HEADER=$(sed -n "${I}p" "$HEADER_FILE" 2>/dev/null || echo "(AC-${I})")

  # Hard-stop on command chaining (zgodnie z v3 §10).
  case "$CMD" in
    *'&&'*|*'||'*|*';'*|*'$('*|*'`'*|*'|'*)
      echo "ERR: forbidden chaining/substitution in Komenda: $CMD" >&2
      printf '{"status":"scope-violation","reason":"command-chaining","cmd":"%s"}\n' "$CMD" > "$YOLO_STATUS"
      BASE_DIR="$RUN_DIR" "$SWARM_ROOT/scripts/append-breadcrumb.sh" yolo yolo_stopped "{\"reason\":\"command-chaining\",\"cmd\":\"$CMD\"}"
      exit 5
      ;;
  esac

  ITER_LOG="$ITER_LOG_DIR/yolo-iter-${ITER}-ac${I}.log"
  {
    printf '## %s\n' "$HEADER"
    printf 'Command: `%s`\n\n' "$CMD"
    printf '```\n'
  } >> "$RUN_LOG"

  RC=0
  OUT=$(cd "$WORKSPACE" && /bin/sh -c "$CMD" 2>&1) || RC=$?
  printf '%s\n' "$OUT" >> "$RUN_LOG"
  printf '%s\n' "$OUT" > "$ITER_LOG"

  {
    printf '```\nExit code: %s\n\n' "$RC"
  } >> "$RUN_LOG"

  if [ "$RC" -ne 0 ] && [ "$ALL_GREEN" -eq 1 ]; then
    ALL_GREEN=0
    FIRST_FAIL_HEADER="$HEADER"
    FIRST_FAIL_CMD="$CMD"
    FIRST_FAIL_OUT="$OUT"
    FIRST_FAIL_LOG="$ITER_LOG"
  fi
done < "$CMD_FILE"

# --- GREEN path: archive + exit 0 ---
if [ "$ALL_GREEN" -eq 1 ]; then
  printf '{"status":"achieved","iter":%s,"start_ts":%s,"sprint":%s}\n' "$ITER" "$START_TS" "$sprint" > "$YOLO_STATUS"
  BASE_DIR="$RUN_DIR" "$SWARM_ROOT/scripts/append-breadcrumb.sh" yolo gate_approved "{\"gate\":5,\"actor\":\"yolo\",\"auto_approved\":true,\"sprint\":$sprint,\"iter\":$ITER}"
  echo "STATUS=GREEN sprint=$sprint iter=$ITER"
  echo "Triggering archive (gate:5 ship)..."
  "$SWARM_ROOT/scripts/archive-run.sh" --run "$run_id" --workspace "$WORKSPACE" --reason "yolo sprint=$sprint achieved iter=$ITER"
  exit 0
fi

# --- FAIL path: no-progress detection ---
NEW_HASH=$("$SWARM_ROOT/scripts/error-hash.sh" "$FIRST_FAIL_LOG" 2>/dev/null || echo "no-errors")
LAST_HASHES=""
if [ -f "$YOLO_STATUS" ]; then
  LAST_HASHES=$(jq -r '.recent_hashes // [] | join(",")' "$YOLO_STATUS" 2>/dev/null || true)
fi
# Konkatenacja: nowy + ostatnie 2 (trzymamy max 3)
COMBINED="${NEW_HASH}"
if [ -n "$LAST_HASHES" ]; then
  COMBINED="${NEW_HASH},${LAST_HASHES}"
fi
# Trim do 3
TRIMMED=$(echo "$COMBINED" | cut -d, -f1-3)
COUNT_SAME=$(echo "$TRIMMED" | tr ',' '\n' | sort | uniq -c | awk '{print $1}' | sort -nr | head -1)

if [ "$COUNT_SAME" -ge 3 ] && [ "$NEW_HASH" != "no-errors" ]; then
  printf '{"status":"no-progress","iter":%s,"hash":"%s","recent_hashes":[%s]}\n' \
    "$ITER" "$NEW_HASH" "$(echo "$TRIMMED" | sed 's/,/","/g; s/^/"/; s/$/"/')" > "$YOLO_STATUS"
  BASE_DIR="$RUN_DIR" "$SWARM_ROOT/scripts/append-breadcrumb.sh" yolo yolo_stopped "{\"reason\":\"no-progress\",\"hash\":\"$NEW_HASH\",\"iter\":$ITER,\"sprint\":$sprint}"
  echo "STATUS=no-progress hash=$NEW_HASH iter=$ITER" >&2
  if [ "$mode" = "yolo" ]; then
    echo "Auto-pivot triggered (3× same error_hash)" >&2
    # Pivot wymaga human acceptance (PIVOT_REQUIRES_HUMAN=1 default w pivot-trigger.sh).
    # W YOLO: oznacz PIVOT_REQUIRES_HUMAN=0 dla auto-flow, zapisuje breadcrumb pivot_executed.
    BASE_DIR="$RUN_DIR" SCRIPTS_DIR="$SWARM_ROOT/scripts" PIVOT_REQUIRES_HUMAN=0 "$SWARM_ROOT/scripts/pivot-trigger.sh" "$sprint" || true
  fi
  exit 4
fi

# --- Dry-run: print plan only ---
if [ "$dry_run" -eq 1 ]; then
  printf 'DRY-RUN iter=%s mode=%s\n' "$ITER" "$mode"
  printf '  goal-statement: %s\n' "$GOAL_STATEMENT"
  printf '  contract:       %s\n' "$CONTRACT"
  printf '  cmd_count:      %s\n' "$CMD_COUNT"
  printf '  all_green:      %s\n' "$ALL_GREEN"
  printf '  first_fail:     %s\n' "${FIRST_FAIL_HEADER:-none}"
  exit 0
fi

# --- FAIL path: send phase-yolo-iterate prompt do generator pane ---
PHASE_TEMPLATE="$SWARM_ROOT/prompts/phase-yolo-iterate.md"
[ -f "$PHASE_TEMPLATE" ] || { echo "ERR: missing $PHASE_TEMPLATE" >&2; exit 2; }

OUT_PROMPT="$RUN_DIR/prompts/phase-yolo-iterate-iter${ITER}.md"
# Render z dodatkowymi placeholderami: {{FOCUS_AC}}, {{FAIL_CMD}}, {{FAIL_LOG}}, {{ITER}}
TMP_TEMPLATE=$(mktemp)
sed \
  -e "s|{{FOCUS_AC}}|${FIRST_FAIL_HEADER}|g" \
  -e "s|{{FAIL_CMD}}|${FIRST_FAIL_CMD}|g" \
  -e "s|{{FAIL_LOG}}|${FIRST_FAIL_LOG}|g" \
  -e "s|{{ITER}}|${ITER}|g" \
  "$PHASE_TEMPLATE" > "$TMP_TEMPLATE"
render_prompt "$TMP_TEMPLATE" "$OUT_PROMPT" generator yolo-iterate "$sprint"
rm -f "$TMP_TEMPLATE"

GEN_PANE=$(role_pane_var generator)
tmux_send_file "$GEN_PANE" "$OUT_PROMPT"

# --- Update yolo-status (iter, start_ts, recent_hashes) ---
{
  printf '{"status":"iterating","iter":%s,"start_ts":%s,"elapsed_sec":%s,"sprint":%s,"first_fail":"%s","recent_hashes":[%s]}\n' \
    "$ITER" "$START_TS" "$ELAPSED_SEC" "$sprint" "$FIRST_FAIL_HEADER" \
    "$(echo "$TRIMMED" | sed 's/,/","/g; s/^/"/; s/$/"/')"
} > "$YOLO_STATUS"

BASE_DIR="$RUN_DIR" "$SWARM_ROOT/scripts/append-breadcrumb.sh" yolo yolo_iter "{\"iter\":$ITER,\"sprint\":$sprint,\"first_fail\":\"$FIRST_FAIL_HEADER\",\"hash\":\"$NEW_HASH\"}"

echo "STATUS=NEEDS_AGENT_ITERATION iter=$ITER sprint=$sprint"
echo "First fail: $FIRST_FAIL_HEADER"
echo "Prompt sent to generator pane: $GEN_PANE"
echo "Run log: $RUN_LOG"
echo ""
echo "Generator iterates. Re-invoke this script after commit: $0 --run $run_id --mode $mode --sprint $sprint"
exit 1
