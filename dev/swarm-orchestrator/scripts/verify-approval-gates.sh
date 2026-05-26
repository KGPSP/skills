#!/usr/bin/env bash
# verify-approval-gates.sh — egzekwuje 6 bramek akceptacji człowieka (human-in-the-loop)
# Usage: scripts/verify-approval-gates.sh
# Exit 0 = wszystkie bramki domknięte zgodą. Exit ≠0 = brakująca/wisząca zgoda → blokada Fazy 7.
# Protokół: references/approval-gates-protocol.md

set -uo pipefail

BASE_DIR="${BASE_DIR:-$(pwd)}"
BC="$BASE_DIR/state/breadcrumbs.json"
FL="$BASE_DIR/state/feature_list.json"

ERRORS=0
WARNINGS=0

err()  { echo "[FAIL] $*"; ERRORS=$((ERRORS + 1)); }
warn() { echo "[WARN] $*"; WARNINGS=$((WARNINGS + 1)); }
ok()   { echo "[OK]   $*"; }

[[ -f "$BC" ]] || { echo "[ERROR] $BC not found. Run init-team-state.sh first."; exit 1; }

# Helper: czy istnieje gate_approved dla danego numeru bramki (i opcjonalnie sprintu)
approved_for_gate() {
  local gate="$1"
  jq -e --argjson g "$gate" \
    'any(.[]; .event == "gate_approved" and .details.gate == $g)' "$BC" >/dev/null 2>&1
}
approved_for_sprint_gate() {
  local gate="$1" sprint="$2"
  jq -e --argjson g "$gate" --arg s "$sprint" \
    'any(.[]; .event == "gate_approved" and .details.gate == $g and ((.details.sprint|tostring) == $s))' \
    "$BC" >/dev/null 2>&1
}

echo "=== Approval Gates ==="

# --- GATE #1: plan zatwierdzony PRZED pierwszym role_spawned ---
FIRST_SPAWN_IDX=$(jq '[.[] | .event] | index("role_spawned")' "$BC" 2>/dev/null || echo "null")
GATE1_IDX=$(jq 'first(range(0; length) as $i | select(.[$i].event == "gate_approved" and .[$i].details.gate == 1) | $i) // null' "$BC" 2>/dev/null || echo "null")

if [[ "$FIRST_SPAWN_IDX" == "null" ]]; then
  if approved_for_gate 1; then
    ok "GATE #1 (plan): zatwierdzony (jeszcze brak spawnu)"
  else
    warn "GATE #1 (plan): brak gate_approved — OK tylko jeśli faza 1 jeszcze trwa"
  fi
else
  if [[ "$GATE1_IDX" != "null" ]] && [[ "$GATE1_IDX" -lt "$FIRST_SPAWN_IDX" ]]; then
    ok "GATE #1 (plan): zatwierdzony PRZED spawnem ról"
  else
    err "GATE #1 (plan): role_spawned wystąpił bez wcześniejszego gate_approved gate:1"
  fi
fi

# --- GATE #2: kontrakty zatwierdzone (jeśli istnieją kontrakty) ---
if ls "$BASE_DIR"/state/contracts/sprint-*.json >/dev/null 2>&1; then
  if approved_for_gate 2; then
    ok "GATE #2 (kontrakty): zatwierdzone"
  else
    err "GATE #2 (kontrakty): istnieją kontrakty, brak gate_approved gate:2"
  fi
fi

# --- GATE #3: per passed/shipped sprint ---
if [[ -f "$FL" ]]; then
  PASSED_SPRINTS=$(jq -r '[.features[]? | select(.status == "passed" or .status == "shipped") | .sprint] | unique | .[]' "$FL" 2>/dev/null || echo "")
  for SPRINT in $PASSED_SPRINTS; do
    if approved_for_sprint_gate 3 "$SPRINT"; then
      ok "GATE #3 (sprint $SPRINT): zatwierdzony"
    else
      err "GATE #3 (sprint $SPRINT): status passed/shipped, brak gate_approved gate:3 dla tego sprintu"
    fi
  done
fi

# --- GATE #6: ship (jeśli final-report istnieje) ---
if [[ -f "$BASE_DIR/state/final-report.md" ]]; then
  if approved_for_gate 6; then
    ok "GATE #6 (ship): zatwierdzony"
  else
    err "GATE #6 (ship): final-report.md istnieje, brak gate_approved gate:6"
  fi
fi

# --- Wiszące bramki: każdy gate_pending ma approved LUB rejected ---
PENDING_COUNT=$(jq '[.[] | select(.event == "gate_pending")] | length' "$BC" 2>/dev/null || echo 0)
RESOLVED_COUNT=$(jq '[.[] | select(.event == "gate_approved" or .event == "gate_rejected")] | length' "$BC" 2>/dev/null || echo 0)
if [[ "$PENDING_COUNT" -gt "$RESOLVED_COUNT" ]]; then
  err "Wiszące bramki: $PENDING_COUNT gate_pending vs $RESOLVED_COUNT rozstrzygniętych (approved/rejected)"
else
  ok "Brak wiszących bramek ($PENDING_COUNT pending / $RESOLVED_COUNT resolved)"
fi

# --- Audit: bramki zatwierdzone autonomicznie (YOLO) ---
YOLO_COUNT=$(jq '[.[] | select(.event == "gate_approved" and (.actor == "yolo" or .details.auto_approved == true))] | length' "$BC" 2>/dev/null || echo 0)
if [[ "$YOLO_COUNT" -gt 0 ]]; then
  warn "YOLO: $YOLO_COUNT bramka(i) zatwierdzona autonomicznie (actor=yolo / auto_approved). Brak przeglądu człowieka — sprawdź audit trail."
fi

# === Summary ===
echo ""
echo "=== RESULT ==="
echo "Errors: $ERRORS, Warnings: $WARNINGS"

if [[ "$ERRORS" -eq 0 ]]; then
  echo "[OK] Wszystkie bramki domknięte zgodą człowieka. Faza 7 (ship) odblokowana."
  exit 0
else
  echo "[FAIL] $ERRORS bramka(i) bez zgody. Blokada Fazy 7."
  exit 1
fi
