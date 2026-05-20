#!/usr/bin/env bash
# pivot-trigger.sh — uruchamia operację pivota wg pivot-protocol.md §2 (Plan-Validate-Execute)
# Usage: scripts/pivot-trigger.sh <sprint-n>
# Wymaga: state/pivot_plan.md (od Evaluatora), wpis "pivot_accepted" w breadcrumbs (od Generatora).

set -euo pipefail

SPRINT="${1:?Usage: pivot-trigger.sh <sprint-n>}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
PIVOT_PLAN="$BASE_DIR/state/pivot_plan.md"
BC="$BASE_DIR/state/breadcrumbs.json"

# Preflight checks
echo "=== Pivot preflight (sprint-${SPRINT}) ==="

[[ -f "$PIVOT_PLAN" ]] || { echo "[ABORT] $PIVOT_PLAN missing — Evaluator must write plan first"; exit 1; }

ACCEPTED=$(jq -r --arg s "sprint-${SPRINT}" \
  '[.[] | select(.event == "pivot_accepted") | select(.details.sprint == $s)] | length' "$BC")
if [[ "$ACCEPTED" -lt 1 ]]; then
  echo "[ABORT] no pivot_accepted breadcrumb for sprint-${SPRINT}. Generator must accept first."
  exit 2
fi

# Human hook (jeśli włączony)
if [[ "${PIVOT_REQUIRES_HUMAN:-1}" == "1" ]]; then
  echo "[HUMAN HOOK] pivot wymaga akceptacji człowieka."
  echo "--- pivot_plan.md ---"
  cat "$PIVOT_PLAN"
  echo "--- end plan ---"
  read -r -p "Approve pivot? [y/N] " ANS
  if [[ "${ANS,,}" != "y" ]]; then
    echo "[ABORT] aborted by human"
    bash "$BASE_DIR/scripts/append-breadcrumb.sh" "human" "pivot_aborted" \
      "$(jq -nc --arg s "sprint-${SPRINT}" '{sprint: $s}')"
    exit 3
  fi
fi

# Archiwizacja branchu
TS=$(date -u +"%Y-%m-%dT%H-%M")
ARCHIVE_BRANCH="archive/sprint-${SPRINT}-pivot-${TS}"
HASH_BEFORE=$(cd "$BASE_DIR" && git rev-parse HEAD)

(cd "$BASE_DIR" && \
  git checkout -b "$ARCHIVE_BRANCH" -q && \
  git checkout - -q)

echo "[OK] archived to branch: $ARCHIVE_BRANCH (from $HASH_BEFORE)"

# Wyczytaj what_to_discard z pivot_plan.md
DISCARD_PATHS=$(awk '/^## Co usuwamy/,/^## /{if(/^- /) print $2}' "$PIVOT_PLAN" | grep -v "^## " || true)

if [[ -z "$DISCARD_PATHS" ]]; then
  echo "[ABORT] pivot_plan.md nie zawiera 'Co usuwamy' z listą paths"
  exit 4
fi

# Bezpieczeństwo: blokuj jeśli ścieżka zawiera state/contracts/ lub state/plan.md
if echo "$DISCARD_PATHS" | grep -qE "(state/contracts|state/plan\.md|state/breadcrumbs)"; then
  echo "[ABORT] discard paths nie mogą zawierać state/contracts/ ani state/plan.md ani state/breadcrumbs"
  echo "Kontrakt i plan są niezmiennikami sprintu."
  exit 5
fi

# Execute
echo "Discarding:"
echo "$DISCARD_PATHS"
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  if [[ -e "$BASE_DIR/$path" ]]; then
    rm -rf "$BASE_DIR/$path"
    echo "[RM] $path"
  fi
done <<< "$DISCARD_PATHS"

# Commit
(cd "$BASE_DIR" && \
  git add -A && \
  git commit -q -m "pivot(sprint-${SPRINT}): discard implementation, restart from contract")

HASH_AFTER=$(cd "$BASE_DIR" && git rev-parse HEAD)

# Breadcrumb
bash "$BASE_DIR/scripts/append-breadcrumb.sh" "pivot-trigger" "pivot_executed" \
  "$(jq -nc --arg s "sprint-${SPRINT}" --arg hb "$HASH_BEFORE" --arg ha "$HASH_AFTER" --arg ab "$ARCHIVE_BRANCH" \
    '{sprint: $s, hash_before: $hb, hash_after: $ha, archived_branch: $ab}')"

# Move pivot_plan.md to evidence
mkdir -p "$BASE_DIR/state/evidence/pivots/sprint-${SPRINT}-pivot-${TS}"
mv "$PIVOT_PLAN" "$BASE_DIR/state/evidence/pivots/sprint-${SPRINT}-pivot-${TS}/pivot_plan.md"
echo "$HASH_BEFORE" > "$BASE_DIR/state/evidence/pivots/sprint-${SPRINT}-pivot-${TS}/before-hash.txt"
echo "$ARCHIVE_BRANCH" > "$BASE_DIR/state/evidence/pivots/sprint-${SPRINT}-pivot-${TS}/archive-branch.txt"

echo "[OK] Pivot zakończony. Wracaj do fazy 3 (renegocjacja kontraktu)."
