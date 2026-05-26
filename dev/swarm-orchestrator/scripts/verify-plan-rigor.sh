#!/usr/bin/env bash
# verify-plan-rigor.sh — egzekwuje 11 sekcji planu (dziedziczone z audited-feature-workflow)
# Usage: scripts/verify-plan-rigor.sh
# Exit 0 = plan akceptowalny. Exit ≠0 = sekcja brakuje LUB nie spełnia minimum.

set -uo pipefail

BASE_DIR="${BASE_DIR:-$(pwd)}"
PLAN="$BASE_DIR/state/plan.md"

[[ -f "$PLAN" ]] || { echo "[FAIL] $PLAN missing"; exit 1; }

ERRORS=0
WARNINGS=0

err() { echo "[FAIL] $*"; ERRORS=$((ERRORS + 1)); }
warn() { echo "[WARN] $*"; WARNINGS=$((WARNINGS + 1)); }
ok() { echo "[OK]   $*"; }

# === Sekcja 1: Goal (business) ===
if grep -qE "^## [0-9]+\. Goal" "$PLAN" || grep -qE "^## Goal" "$PLAN"; then
  ok "Sekcja 1: Goal (business)"
else
  err "Sekcja 1 (Goal) missing"
fi

# === Sekcja 2: Sprints + 3 hipotezy per sprint ===
if grep -qE "^## .*Sprints" "$PLAN"; then
  ok "Sekcja 2: Sprints"
  # Liczymy heading'i sprintów
  SPRINT_COUNT=$(grep -cE "^### Sprint [0-9]+" "$PLAN")
  if [[ "$SPRINT_COUNT" -lt 1 ]]; then
    err "Brak sub-sekcji ### Sprint N"
  else
    ok "  Znalezione sprinty: $SPRINT_COUNT"
    # Per sprint sprawdź czy są 3 hipotezy (heurystyka: tabela z H1/H2/H3)
    MISSING_HIPOTEZ=0
    for n in $(seq 1 "$SPRINT_COUNT"); do
      next_n=$((n + 1))
      # Awk range z wykluczeniem self-match: szukamy heading N, kończymy na N+1 LUB top-level ##
      SPRINT_BLOCK=$(awk -v n="$n" -v nx="$next_n" '
        $0 ~ "^### Sprint "n"( |$|—)" {capture=1; nxln=0; next}
        capture && ($0 ~ "^### Sprint "nx"( |$|—)" || $0 ~ "^## [0-9]") {capture=0}
        capture {print}
      ' "$PLAN")
      H_COUNT=$(echo "$SPRINT_BLOCK" | grep -cE "^\| H[0-9]+ \|" | tr -d ' \n')
      H_COUNT="${H_COUNT:-0}"
      if [[ "$H_COUNT" -lt 3 ]]; then
        warn "  Sprint $n: tylko $H_COUNT hipotez (wymagane >=3 Minimal/Idiomatic/Ambitious)"
        MISSING_HIPOTEZ=$((MISSING_HIPOTEZ + 1))
      fi
    done
    if [[ "$MISSING_HIPOTEZ" -gt 0 ]]; then
      err "  $MISSING_HIPOTEZ/$SPRINT_COUNT sprintów ma <3 hipotez"
    else
      ok "  Wszystkie sprinty mają >=3 hipotez (Minimal/Idiomatic/Ambitious)"
    fi
  fi
else
  err "Sekcja 2 (Sprints) missing"
fi

# === Sekcja 3: Dependencies ===
if grep -qE "^## .*Dependencies" "$PLAN"; then
  ok "Sekcja 3: Dependencies"
else
  err "Sekcja 3 (Dependencies) missing"
fi

# === Sekcja 4: Open Questions ===
if grep -qE "^## .*Open Questions" "$PLAN"; then
  OQ_BLOCK=$(awk '
    /^## .*Open Questions/ {capture=1; next}
    capture && /^## / {capture=0}
    capture {print}
  ' "$PLAN")
  OQ_ITEMS=$(echo "$OQ_BLOCK" | grep -cE "^- \[" | tr -d ' \n')
  OQ_ITEMS="${OQ_ITEMS:-0}"
  if [[ "$OQ_ITEMS" -ge 1 ]] || echo "$OQ_BLOCK" | grep -qiE "no open questions|brak open|świadomie pusta"; then
    ok "Sekcja 4: Open Questions ($OQ_ITEMS items lub świadoma deklaracja)"
  else
    err "Sekcja 4: Open Questions pusta bez deklaracji 'no open questions'"
  fi
else
  err "Sekcja 4 (Open Questions) missing"
fi

# === Sekcja 5: Out of scope ===
if grep -qE "^## .*Out of scope" "$PLAN"; then
  ok "Sekcja 5: Out of scope"
else
  err "Sekcja 5 (Out of scope) missing"
fi

# === Sekcja 6: Success metric ===
if grep -qE "^## .*Success metric" "$PLAN"; then
  ok "Sekcja 6: Success metric"
else
  err "Sekcja 6 (Success metric) missing"
fi

# === Sekcja 7: Ryzyka (skalowane H/M/L) ===
if grep -qE "^## .*Ryzyka|^## .*Risks" "$PLAN"; then
  RISK_BLOCK=$(awk '
    /^## .*(Ryzyka|Risks)/ {capture=1; next}
    capture && /^## / {capture=0}
    capture {print}
  ' "$PLAN")
  if echo "$RISK_BLOCK" | grep -qiE "(high|medium|low|severity)"; then
    ok "Sekcja 7: Ryzyka (skalowanie H/M/L obecne)"
  else
    warn "Sekcja 7: Ryzyka istnieje, ale brak skalowania H/M/L"
  fi
else
  err "Sekcja 7 (Ryzyka) missing"
fi

# === Sekcja 8: Recommendation summary (NOWE v1.5) ===
if grep -qE "^## .*Recommendation" "$PLAN"; then
  ok "Sekcja 8: Recommendation summary"
else
  err "Sekcja 8 (Recommendation summary) missing — NOWA w v1.5"
fi

# === Sekcja 9: Hyrum Impact (NOWE v1.5) ===
if grep -qE "^## .*Hyrum" "$PLAN"; then
  HYRUM_BLOCK=$(awk '
    /^## .*Hyrum/ {capture=1; next}
    capture && /^## / {capture=0}
    capture {print}
  ' "$PLAN")
  if echo "$HYRUM_BLOCK" | grep -qiE "(breaking|additive|internal|no public API|n/a)"; then
    ok "Sekcja 9: Hyrum Impact (klasyfikacja obecna)"
  else
    warn "Sekcja 9: Hyrum Impact istnieje, ale brak klasyfikacji breaking/additive/internal"
  fi
else
  err "Sekcja 9 (Hyrum Impact) missing — NOWA w v1.5"
fi

# === Sekcja 10: Rollback plan (NOWE v1.5) ===
if grep -qE "^## .*Rollback" "$PLAN"; then
  ok "Sekcja 10: Rollback plan"
else
  err "Sekcja 10 (Rollback plan) missing — NOWA w v1.5"
fi

# === Sekcja 11: Alternatives considered (NOWE v1.5) ===
if grep -qE "^## .*Alternatives considered" "$PLAN"; then
  ALT_BLOCK=$(awk '
    /^## .*Alternatives considered/ {capture=1; next}
    capture && /^## / {capture=0}
    capture {print}
  ' "$PLAN")
  ALT_ROWS=$(echo "$ALT_BLOCK" | grep -cE "^\| .* \| .* \|" | tr -d ' \n')
  ALT_ROWS="${ALT_ROWS:-0}"
  ALT_COUNT=$((ALT_ROWS > 1 ? ALT_ROWS - 2 : 0))  # minus header + separator
  if [[ "$ALT_COUNT" -ge 2 ]]; then
    ok "Sekcja 11: Alternatives considered ($ALT_COUNT alternatyw)"
  else
    err "Sekcja 11: Alternatives considered ma tylko $ALT_COUNT alternatyw (min. 2)"
  fi
else
  err "Sekcja 11 (Alternatives considered) missing — NOWA w v1.5"
fi

# === Summary ===
echo ""
TOTAL_SECTIONS=11
PRESENT=$((TOTAL_SECTIONS - ERRORS))
echo "=== Plan rigor: $PRESENT/$TOTAL_SECTIONS sekcji OK, $WARNINGS warnings ==="

if [[ "$ERRORS" -eq 0 ]]; then
  echo "[OK] Plan akceptowalny. Faza 1 zamknięta."
  exit 0
else
  echo "[FAIL] $ERRORS sekcji brakuje lub niespełnia minimum. Planner musi uzupełnić."
  exit 1
fi
