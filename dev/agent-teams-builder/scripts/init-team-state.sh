#!/usr/bin/env bash
# init-team-state.sh — inicjalizuje strukturę state/ dla nowej sesji Agent Teams
# Usage: scripts/init-team-state.sh <project-name>
# Idempotent: jeśli state/ istnieje — STOP, każe użyć recovery (memory-filesystem.md §7).

set -euo pipefail

PROJECT_NAME="${1:?Usage: init-team-state.sh <project-name>}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
STATE_DIR="$BASE_DIR/state"

if [[ -d "$STATE_DIR" ]]; then
  echo "[STOP] state/ already exists. Use recovery procedure (references/memory-filesystem.md §7)."
  echo "       Last breadcrumb:"
  jq '.[-1]' "$STATE_DIR/breadcrumbs.json" 2>/dev/null || echo "       (breadcrumbs.json unreadable)"
  exit 1
fi

# Create directory tree
mkdir -p "$STATE_DIR/contracts" "$STATE_DIR/rubric" "$STATE_DIR/evidence" "$STATE_DIR/archives"

# Init JSON files (append-only)
echo '[]' > "$STATE_DIR/breadcrumbs.json"
cat > "$STATE_DIR/feature_list.json" <<EOF
{
  "version": 1,
  "project": "$PROJECT_NAME",
  "features": []
}
EOF

# Init plan.md skeleton
cat > "$STATE_DIR/plan.md" <<'EOF'
# Plan — <project name>

## Goal (business)
<wypełni Planner w fazie 1>

## Sprints
<3-15 sprintów z mierzalnym celem biznesowym>

## Dependencies
<biblioteki, API, dane>

## Open Questions
<niewiadome do eskalacji — Non-negotiable #1>
EOF

# Init blockers.md (puste)
echo "# Blockers — eskalacje do human" > "$STATE_DIR/blockers.md"

# Git init jeśli brak
if [[ ! -d "$BASE_DIR/.git" ]]; then
  (cd "$BASE_DIR" && git init -q)
fi

# First commit
(cd "$BASE_DIR" && \
  git add state/ && \
  git commit -q --allow-empty -m "init agent-teams session: $PROJECT_NAME")

INIT_HASH=$(cd "$BASE_DIR" && git rev-parse HEAD)
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# First breadcrumb
TMP=$(mktemp)
jq --arg ts "$TS" --arg p "$PROJECT_NAME" --arg h "$INIT_HASH" \
  '. + [{"ts": $ts, "actor": "bootstrap", "event": "init", "details": {"project": $p, "git_init_hash": $h}}]' \
  "$STATE_DIR/breadcrumbs.json" > "$TMP"
mv "$TMP" "$STATE_DIR/breadcrumbs.json"

echo "[OK] state/ initialized for project: $PROJECT_NAME"
echo "[OK] git initial commit: $INIT_HASH"
echo "[OK] Faza 0 (bootstrap) zamknięta. Przejdź do fazy 1 (Planner)."
ls -la "$STATE_DIR"
