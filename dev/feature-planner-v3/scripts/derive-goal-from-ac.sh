#!/usr/bin/env bash
# derive-goal-from-ac.sh — parser AC + generator goal-statement.md/goal-prompt.txt
# Hard-stopuje na brakach (zgodne ze spec §5.1).
# Usage: derive-goal-from-ac.sh --plan <path> [--out-dir <dir>]

set -euo pipefail

SCRIPT_VERSION="0.1.0"
PLAN=""
OUT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan) PLAN="$2"; shift 2 ;;
    --out-dir) OUT_DIR="$2"; shift 2 ;;
    -h|--help) echo "Usage: $0 --plan <path> [--out-dir <dir>]"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

[[ -z "$PLAN" ]] && { echo "ERR: --plan required" >&2; exit 2; }
[[ ! -f "$PLAN" ]] && { echo "ERR: plan file not found: $PLAN" >&2; exit 1; }
[[ ! -s "$PLAN" ]] && { echo "ERR: plan file empty: $PLAN" >&2; exit 1; }

OUT_DIR="${OUT_DIR:-$(dirname "$PLAN")}"
mkdir -p "$OUT_DIR"

BASENAME=$(basename "$PLAN" .md)
GOAL_MD="$OUT_DIR/${BASENAME}-goal-statement.md"
GOAL_TXT="$OUT_DIR/${BASENAME}-goal-prompt.txt"

# Strip optional carriage returns for cross-platform input.
PLAN_CONTENT=$(tr -d '\r' < "$PLAN")

# --- Validation rule 2: ## Acceptance Criteria exists ---
if ! grep -q "^## Acceptance Criteria" <<<"$PLAN_CONTENT"; then
  echo "ERR: missing section '## Acceptance Criteria' in $PLAN" >&2
  exit 1
fi

# --- Extract AC table ---
AC_TABLE=$(awk '
  /^## Acceptance Criteria/ {flag=1; next}
  /^## / && flag {flag=0}
  flag && /^\| AC-[0-9]/ {print}
' <<<"$PLAN_CONTENT")

if [[ -z "$AC_TABLE" ]]; then
  echo "ERR: AC table empty or malformed in $PLAN" >&2
  exit 1
fi

# --- Validate each AC row (6 columns, all non-empty) ---
ERRORS=()
LINE_NUM=0
SEEN_AC_IDS=""
while IFS= read -r row; do
  LINE_NUM=$((LINE_NUM + 1))
  # Split by | (skip leading/trailing empty fields).
  IFS='|' read -ra CELLS <<<"$row"
  # CELLS[0] is empty (before first |), CELLS[1..6] are the 6 columns, CELLS[7] is empty.
  if [[ ${#CELLS[@]} -lt 7 ]]; then
    ERRORS+=("AC row $LINE_NUM: less than 6 columns")
    continue
  fi
  AC_ID=$(echo "${CELLS[1]}" | xargs)
  TYP=$(echo "${CELLS[2]}" | xargs)
  OPIS=$(echo "${CELLS[3]}" | xargs)
  TEST_ID=$(echo "${CELLS[4]}" | xargs)
  TEST_FILE=$(echo "${CELLS[5]}" | xargs)
  KOMENDA=$(echo "${CELLS[6]}" | xargs)

  for pair in "AC-ID:$AC_ID" "Typ:$TYP" "Opis:$OPIS" "Test ID:$TEST_ID" "Plik testu:$TEST_FILE" "Komenda:$KOMENDA"; do
    name="${pair%%:*}"
    val="${pair#*:}"
    if [[ -z "$val" || "$val" == "-" || "$val" == "TBD" || "$val" == "TODO" ]]; then
      ERRORS+=("$AC_ID: kolumna '$name' pusta lub placeholder ($PLAN row $LINE_NUM)")
    fi
  done

  if ! [[ "$AC_ID" =~ ^AC-[0-9]+$ ]]; then
    ERRORS+=("$AC_ID: niepoprawny format AC-ID (oczekiwane AC-<digits>)")
  else
    if [[ ",$SEEN_AC_IDS," == *",$AC_ID,"* ]]; then
      ERRORS+=("$AC_ID: duplikat AC-ID")
    fi
    SEEN_AC_IDS="$SEEN_AC_IDS,$AC_ID"
  fi

  case "$TYP" in
    F|N|C) ;;
    *) ERRORS+=("$AC_ID: Typ='$TYP', dozwolone {F, N, C}") ;;
  esac

  case "$KOMENDA" in
    \`npm*|\`pnpm*|\`yarn*|\`pytest*|\`cargo*|\`go*|\`make*|\`sh*|\`bash*|\`node*) ;;
    npm*|pnpm*|yarn*|pytest*|cargo*|go*|make*|sh*|bash*|node*) ;;
    *) ERRORS+=("$AC_ID: Komenda prefix nie jest dozwolony (oczekiwane: npm|pnpm|yarn|pytest|cargo|go|make|sh|bash|node), dostała: $KOMENDA") ;;
  esac
done <<<"$AC_TABLE"

# --- Validate Out of scope ---
if ! grep -q "^## Out of scope" <<<"$PLAN_CONTENT"; then
  ERRORS+=("missing section '## Out of scope'")
else
  OOS_BULLETS=$(awk '/^## Out of scope/{flag=1; next} /^## /{flag=0} flag && /^- /' <<<"$PLAN_CONTENT" | wc -l | xargs)
  if [[ "$OOS_BULLETS" -lt 1 ]]; then
    ERRORS+=("'## Out of scope' has zero bullets")
  fi
fi

# --- Validate Definition of Done ---
if ! grep -q "^## Definition of Done" <<<"$PLAN_CONTENT"; then
  ERRORS+=("missing section '## Definition of Done'")
fi

if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "ERR: validation failed (${#ERRORS[@]} issues):" >&2
  for e in "${ERRORS[@]}"; do echo "  - $e" >&2; done
  exit 1
fi

# --- Generate goal-statement.md ---
AC_COUNT=$(wc -l <<<"$AC_TABLE" | xargs)
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

{
  echo "---"
  echo "plan-id: ${BASENAME}"
  echo "plan-file: ${PLAN}"
  echo "generated-at: ${NOW}"
  echo "generated-by: scripts/derive-goal-from-ac.sh v${SCRIPT_VERSION}"
  echo "ac-count: ${AC_COUNT}"
  echo "verification-commands: $((AC_COUNT + 2))"
  echo "---"
  echo ""
  echo "# Goal Statement — ${BASENAME}"
  echo ""
  echo "> [!info] Źródło"
  echo "> Auto-derived z \`${PLAN}\` (sekcje \`## Acceptance Criteria\`, \`## Out of scope\`, \`## Definition of Done\`)."
  echo ""
  echo "## Stan końcowy"
  echo ""
  while IFS= read -r row; do
    IFS='|' read -ra CELLS <<<"$row"
    AC_ID=$(echo "${CELLS[1]}" | xargs)
    TYP=$(echo "${CELLS[2]}" | xargs)
    OPIS=$(echo "${CELLS[3]}" | xargs)
    echo "- **${AC_ID}** (${TYP}): ${OPIS}"
  done <<<"$AC_TABLE"
  echo ""
  echo "## Weryfikacja"
  echo ""
  while IFS= read -r row; do
    IFS='|' read -ra CELLS <<<"$row"
    AC_ID=$(echo "${CELLS[1]}" | xargs)
    TEST_ID=$(echo "${CELLS[4]}" | xargs)
    TEST_FILE=$(echo "${CELLS[5]}" | xargs)
    KOMENDA=$(echo "${CELLS[6]}" | xargs)
    echo "### ${AC_ID} — ${TEST_ID}"
    echo "- **Plik testu**: \`${TEST_FILE}\`"
    echo "- **Komenda**: ${KOMENDA}"
    echo "- **Próg sukcesu**: exit 0."
    echo ""
  done <<<"$AC_TABLE"
  echo "### BUILD — clean"
  echo "- **Komenda**: \`sh dev/feature-planner-v3/scripts/verify-build-clean.sh\`"
  echo "- **Próg**: exit 0, zero warnings."
  echo ""
  echo "### AC-COVERAGE — 1:1"
  echo "- **Komenda**: \`sh dev/feature-planner-v3/scripts/check-ac-coverage.sh --plan \"${PLAN}\"\`"
  echo "- **Próg**: 100%."
  echo ""
  echo "## Ograniczenia"
  echo ""
  echo "- **Out of scope** (z planu):"
  awk '/^## Out of scope/{flag=1; next} /^## /{flag=0} flag && /^- /' <<<"$PLAN_CONTENT" | sed 's/^/  /'
  echo "- **Scope Discipline**: nie modyfikuj plików spoza files-touched."
  echo "- **PR Sizing**: >1000 linii diff = hard stop."
  echo "- **Anti-Rationalization quick-table**: przed każdym commitem."
  echo "- **Fragile zone**: migrations/, terraform/, k8s/, auth/, .github/workflows/, Dockerfile → STOP."
  echo "- **Iteration cap**: max 20."
  echo "- **Time cap**: max 480 min."
  echo ""
  echo "## Definition of Done (agregat)"
  echo ""
  echo "- [ ] Wszystkie cmd z \`## Weryfikacja\` exit 0."
  echo "- [ ] Build clean."
  echo "- [ ] AC coverage 100%."
  echo "- [ ] PR size ≤ target."
  echo "- [ ] Brak zmian w Fragile zone."
  echo ""
  echo "## Goal-prompt"
  echo ""
  echo "> Patrz \`${BASENAME}-goal-prompt.txt\`."
} > "$GOAL_MD"

# --- Generate goal-prompt.txt (single block, plain text) ---
{
  printf "/goal "
  while IFS= read -r row; do
    IFS='|' read -ra CELLS <<<"$row"
    OPIS=$(echo "${CELLS[3]}" | xargs)
    printf "%s. " "$OPIS"
  done <<<"$AC_TABLE"
  printf "Weryfikacja: "
  while IFS= read -r row; do
    IFS='|' read -ra CELLS <<<"$row"
    KOMENDA=$(echo "${CELLS[6]}" | tr -d '`' | xargs)
    printf "%s; " "$KOMENDA"
  done <<<"$AC_TABLE"
  printf "wszystkie exit 0. Ograniczenia: zgodne z Out of scope w %s, scope discipline, PR<=1000, brak Fragile zone, max 20 iter, max 480 min.\n" "$PLAN"
} > "$GOAL_TXT"

CONSTRAINTS_COUNT=$(awk '/^## Ograniczenia/{flag=1; next} /^## /{flag=0} flag && /^- /' "$GOAL_MD" | wc -l | xargs)

echo "OK: AC=${AC_COUNT}, Verification=$((AC_COUNT + 2)), Constraints=${CONSTRAINTS_COUNT}"
echo "Generated: ${GOAL_MD}"
echo "Generated: ${GOAL_TXT}"
exit 0
