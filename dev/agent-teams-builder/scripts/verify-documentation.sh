#!/usr/bin/env bash
# verify-documentation.sh — egzekwuje pełen audit trail dokumentów
# Usage: scripts/verify-documentation.sh [sprint-n | --all-passed]
# Exit 0 = wszystkie dokumenty obecne. Exit ≠0 = brak → blokada fazy 6.

set -uo pipefail

BASE_DIR="${BASE_DIR:-$(pwd)}"
ARG="${1:-}"

ERRORS=0
WARNINGS=0

err() { echo "[FAIL] $*"; ERRORS=$((ERRORS + 1)); }
warn() { echo "[WARN] $*"; WARNINGS=$((WARNINGS + 1)); }
ok() { echo "[OK]   $*"; }

# === Lista sprintów do sprawdzenia ===
SPRINTS_TO_CHECK=""

if [[ "$ARG" == "--all-passed" ]] || [[ -z "$ARG" ]]; then
  # Z feature_list.json: status == passed lub shipped
  if [[ -f "$BASE_DIR/state/feature_list.json" ]]; then
    SPRINTS_TO_CHECK=$(jq -r '[.features[] | select(.status == "passed" or .status == "shipped") | .sprint] | unique | .[]' "$BASE_DIR/state/feature_list.json" 2>/dev/null || echo "")
  fi
elif [[ "$ARG" =~ ^[0-9]+$ ]]; then
  SPRINTS_TO_CHECK="$ARG"
fi

if [[ -z "$SPRINTS_TO_CHECK" ]]; then
  echo "[INFO] Brak passed sprintów do sprawdzenia (state/feature_list.json pusty lub brak)."
  # Sprawdź przynajmniej istnienie struktury
  for dir in state/prd state/retrospectives state/qa-reports docs/adr docs/code-reviews; do
    if [[ -d "$BASE_DIR/$dir" ]]; then
      ok "Struktura: $dir/ istnieje"
    else
      err "Struktura: $dir/ MISSING — uruchom scripts/init-docs-structure.sh"
    fi
  done
  exit "$ERRORS"
fi

# === Per sprint check ===
for SPRINT in $SPRINTS_TO_CHECK; do
  echo ""
  echo "=== Sprint $SPRINT ==="

  # 1. PRD
  if [[ -f "$BASE_DIR/state/prd/sprint-${SPRINT}.md" ]]; then
    PRD_FILE="$BASE_DIR/state/prd/sprint-${SPRINT}.md"
    # 8 sekcji obowiązkowych
    PRD_SECTIONS=0
    for sec in "User story" "Problem statement" "Personas" "Functional requirements" "Non-functional requirements" "Out of scope" "Success metrics" "Open questions"; do
      grep -qE "^## .*${sec}" "$PRD_FILE" 2>/dev/null && PRD_SECTIONS=$((PRD_SECTIONS + 1))
    done
    if [[ "$PRD_SECTIONS" -ge 6 ]]; then
      ok "PRD: state/prd/sprint-${SPRINT}.md ($PRD_SECTIONS/8 sekcji)"
    else
      warn "PRD: tylko $PRD_SECTIONS/8 sekcji w state/prd/sprint-${SPRINT}.md"
    fi
  else
    err "PRD: state/prd/sprint-${SPRINT}.md MISSING"
  fi

  # 2. Retrospective
  if [[ -f "$BASE_DIR/state/retrospectives/sprint-${SPRINT}.md" ]]; then
    ok "Retrospective: state/retrospectives/sprint-${SPRINT}.md"
  else
    err "Retrospective: state/retrospectives/sprint-${SPRINT}.md MISSING"
  fi

  # 3. QA Report (jeśli były QA evidence)
  if [[ -d "$BASE_DIR/state/evidence/sprint-${SPRINT}" ]]; then
    EVIDENCE_FILES=$(find "$BASE_DIR/state/evidence/sprint-${SPRINT}" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$EVIDENCE_FILES" -gt 0 ]]; then
      if [[ -f "$BASE_DIR/state/qa-reports/sprint-${SPRINT}.md" ]]; then
        ok "QA Report: state/qa-reports/sprint-${SPRINT}.md"
      else
        err "QA Report: state/qa-reports/sprint-${SPRINT}.md MISSING (były evidence files)"
      fi
    fi
  fi

  # 4. Code Review (Five-Axis)
  CR_FILES=$(find "$BASE_DIR/docs/code-reviews/" -name "CR-sprint-${SPRINT}-*.md" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$CR_FILES" -ge 1 ]]; then
    ok "Code Review: $CR_FILES plik(ów) w docs/code-reviews/"
  else
    err "Code Review: docs/code-reviews/CR-sprint-${SPRINT}-*.md MISSING"
  fi

  # 5. ADR jeśli sprint dotknął architektury
  # Heurystyka: sprint zmienił package.json deps LUB API
  if [[ -d "$BASE_DIR/.git" ]]; then
    set +o pipefail
    # Wyciągnij hash range sprintu
    SPRINT_HASHES=$(jq -r --argjson s "$SPRINT" \
      '[.[] | select((.event == "iteration_start" or .event == "sprint_passed") and (.details.sprint == ($s | tostring) or .details.sprint == $s))] | .[0].details.start_hash // ""' \
      "$BASE_DIR/state/breadcrumbs.json" 2>/dev/null || echo "")

    ARCH_CHANGED=0
    if [[ -n "$SPRINT_HASHES" ]]; then
      # Sprawdź czy package.json/Cargo.toml/go.mod zmienione
      (cd "$BASE_DIR" && git diff --name-only "$SPRINT_HASHES"..HEAD 2>/dev/null | grep -qE "package\.json|Cargo\.toml|go\.mod|requirements\.txt") && ARCH_CHANGED=1
    fi
    set -o pipefail

    if [[ "$ARCH_CHANGED" -eq 1 ]]; then
      ADR_COUNT=$(find "$BASE_DIR/docs/adr/" -name "ADR-*.md" -newer "$BASE_DIR/state/contracts/sprint-${SPRINT}.json" 2>/dev/null | wc -l | tr -d ' ')
      ADR_COUNT="${ADR_COUNT:-0}"
      if [[ "$ADR_COUNT" -ge 1 ]]; then
        ok "ADR: $ADR_COUNT ADR(ów) powstało w sprincie (architecture changed)"
      else
        warn "ADR: sprint $SPRINT zmienił architekturę (deps), ale brak nowego ADR"
      fi
    fi
  fi
done

# === Globalne checks ===
echo ""
echo "=== Global ==="

# todo.md istnieje + aktualny
if [[ -f "$BASE_DIR/state/todo.md" ]]; then
  ok "TODO snapshot: state/todo.md"
else
  warn "TODO snapshot: state/todo.md MISSING — Generator powinien dopisać po każdej iteracji"
fi

# decision-log.md
if [[ -f "$BASE_DIR/state/decision-log.md" ]]; then
  DEC_COUNT=$(grep -cE "^## [0-9]+" "$BASE_DIR/state/decision-log.md" 2>/dev/null | tr -d ' \n')
  DEC_COUNT="${DEC_COUNT:-0}"
  ok "Decision log: $DEC_COUNT wpisów"
else
  warn "Decision log: state/decision-log.md MISSING"
fi

# === Summary ===
echo ""
echo "=== RESULT ==="
echo "Sprints checked: $(echo "$SPRINTS_TO_CHECK" | wc -w | tr -d ' ')"
echo "Errors: $ERRORS, Warnings: $WARNINGS"

if [[ "$ERRORS" -eq 0 ]]; then
  echo "[OK] Documentation complete. Faza 6 verify może wchodzić."
  exit 0
else
  echo "[FAIL] $ERRORS dokumentów brakuje. Blokada fazy 6."
  exit 1
fi
