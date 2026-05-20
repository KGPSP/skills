#!/usr/bin/env bash
# run-meta-tests.sh — uruchamia walidatory skilla na fixtures i sprawdza exit codes.
# GOOD fixtures muszą dawać exit 0. BAD fixtures muszą dawać exit ≠ 0.
# Usage: tests/run-meta-tests.sh
# Exit 0 = wszystkie testy zgodne z oczekiwaniem.

set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURES="$SKILL_DIR/tests/fixtures"
SCRIPTS="$SKILL_DIR/scripts"

PASS=0
FAIL=0
FAILED_TESTS=()

assert_exit() {
  local desc="$1"; local expected="$2"; shift 2
  local actual=0
  "$@" >/dev/null 2>&1 || actual=$?

  if [[ "$expected" == "0" && "$actual" == "0" ]]; then
    echo "  [PASS] $desc (exit 0 as expected)"
    PASS=$((PASS + 1))
  elif [[ "$expected" == "nonzero" && "$actual" != "0" ]]; then
    echo "  [PASS] $desc (exit $actual ≠ 0 as expected)"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] $desc (expected $expected, got $actual)"
    FAIL=$((FAIL + 1))
    FAILED_TESTS+=("$desc")
  fi
}

setup_temp_state() {
  local fixture="$1"
  local TMP=$(mktemp -d)
  mkdir -p "$TMP/state/contracts" "$TMP/state/rubric/examples"
  cp "$FIXTURES/$fixture" "$TMP/state/contracts/sprint-1.json"
  # Few-shot examples (wymagane przez verify-evaluator-rubric.sh)
  touch "$TMP/state/rubric/examples/good-a.md" "$TMP/state/rubric/examples/good-b.md"
  touch "$TMP/state/rubric/examples/bad-a.md" "$TMP/state/rubric/examples/bad-b.md"
  echo "$TMP"
}

setup_breadcrumbs() {
  local fixture="$1"
  local TMP=$(mktemp -d)
  mkdir -p "$TMP/state"
  cp "$FIXTURES/$fixture" "$TMP/state/breadcrumbs.json"
  # Init mini git repo (dla diff-based check)
  (cd "$TMP" && git -c user.email=test@local -c user.name=Test init -q && git add state/ && git -c user.email=test@local -c user.name=Test commit -q -m "init")
  echo "$TMP"
}

setup_plan() {
  local fixture="$1"
  local TMP=$(mktemp -d)
  mkdir -p "$TMP/state"
  cp "$FIXTURES/$fixture" "$TMP/state/plan.md"
  echo '[]' > "$TMP/state/breadcrumbs.json"
  echo "# Blockers" > "$TMP/state/blockers.md"
  echo "$TMP"
}

echo "========================================"
echo "  Meta-tests: agent-teams-builder"
echo "========================================"
echo ""

# ============ CONTRACT FIXTURES ============
echo "[Group 1] check-contract-coverage.sh"

TMP=$(setup_temp_state "contract-complete.json")
assert_exit "contract-complete.json → exit 0 (15 binary criteria, accepted)" "0" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/check-contract-coverage.sh' 1"
rm -rf "$TMP"

TMP=$(setup_temp_state "contract-broken-scales.json")
assert_exit "contract-broken-scales.json → exit ≠0 (skale 1-10)" "nonzero" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/check-contract-coverage.sh' 1"
rm -rf "$TMP"

TMP=$(setup_temp_state "contract-broken-too-few.json")
assert_exit "contract-broken-too-few.json → exit ≠0 (8 < 15 kryteriów)" "nonzero" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/check-contract-coverage.sh' 1"
rm -rf "$TMP"

# ============ RUBRIC FIXTURES ============
echo ""
echo "[Group 2] verify-evaluator-rubric.sh"

TMP=$(setup_temp_state "contract-complete.json")
assert_exit "contract-complete.json rubric → exit 0" "0" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/verify-evaluator-rubric.sh' '$TMP/state/contracts/sprint-1.json'"
rm -rf "$TMP"

TMP=$(setup_temp_state "contract-broken-scales.json")
assert_exit "contract-broken-scales.json rubric → exit ≠0" "nonzero" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/verify-evaluator-rubric.sh' '$TMP/state/contracts/sprint-1.json'"
rm -rf "$TMP"

# ============ BREADCRUMBS FIXTURES ============
echo ""
echo "[Group 3] check-breadcrumbs-append-only.sh"

TMP=$(setup_breadcrumbs "breadcrumbs-valid.json")
assert_exit "breadcrumbs-valid.json → exit 0 (zgodny schema + chronologia)" "0" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/check-breadcrumbs-append-only.sh'"
rm -rf "$TMP"

TMP=$(setup_breadcrumbs "breadcrumbs-broken-schema.json")
assert_exit "breadcrumbs-broken-schema.json → exit ≠0 (brakuje pól)" "nonzero" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/check-breadcrumbs-append-only.sh'"
rm -rf "$TMP"

# ============ NON-NEGOTIABLES FIXTURES ============
echo ""
echo "[Group 4] verify-non-negotiables.sh (na plan + breadcrumbs)"

TMP=$(setup_plan "plan-complete.md")
assert_exit "plan-complete.md → exit 0 (Open Questions wypełnione)" "0" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/verify-non-negotiables.sh'"
rm -rf "$TMP"

TMP=$(setup_plan "plan-empty-open-questions.md")
assert_exit "plan-empty-open-questions.md → exit ≠0 (Non-negotiable #1)" "nonzero" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/verify-non-negotiables.sh'"
rm -rf "$TMP"

# ============ ROLE ISOLATION FIXTURE ============
echo ""
echo "[Group 5] verify-role-isolation.sh (na agents/)"

TMP=$(mktemp -d)
mkdir -p "$TMP/.claude/agents"
cp "$SKILL_DIR/agents/"*.md "$TMP/.claude/agents/"
assert_exit "agents/ (good — Generator bez Playwright, Evaluator bez Edit) → exit 0" "0" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/verify-role-isolation.sh'"
rm -rf "$TMP"

# Negative: Generator z Playwright (sztuczna modyfikacja)
TMP=$(mktemp -d)
mkdir -p "$TMP/.claude/agents"
cp "$SKILL_DIR/agents/"*.md "$TMP/.claude/agents/"
# Złam izolację: dodaj Playwright do Generatora
sed -i.bak 's/^tools:.*/tools: Read, Write, Edit, Bash, Grep, Glob, mcp__playwright/' "$TMP/.claude/agents/generator.md"
assert_exit "Generator z mcp__playwright w tools → exit ≠0 (izolacja złamana)" "nonzero" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/verify-role-isolation.sh'"
rm -rf "$TMP"

# ============ LIBRARY CURRENCY FIXTURES ============
echo ""
echo "[Group 6] verify-library-currency.sh"

setup_currency() {
  local fixture="$1"; local add_package="$2"
  local TMP=$(mktemp -d)
  mkdir -p "$TMP/state"
  cp "$FIXTURES/$fixture" "$TMP/state/breadcrumbs.json"
  # Init git + create initial package.json bez deps
  (cd "$TMP" && \
    git -c user.email=t@t -c user.name=t init -q && \
    echo '{"name":"test","version":"1.0.0"}' > package.json && \
    git add . && \
    git -c user.email=t@t -c user.name=t commit -q -m "init")
  # Symuluj dodanie biblioteki w sprincie (jeśli żądane)
  if [[ "$add_package" == "1" ]]; then
    (cd "$TMP" && \
      echo '{"name":"test","version":"1.0.0","dependencies":{"react":"19.0.0"}}' > package.json && \
      git add . && \
      git -c user.email=t@t -c user.name=t commit -q -m "add react")
  fi
  echo "$TMP"
}

TMP=$(setup_currency "breadcrumbs-with-currency-check.json" "1")
assert_exit "sprint dodał react + ma library_currency_checked → exit 0" "0" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/verify-library-currency.sh' 1"
rm -rf "$TMP"

TMP=$(setup_currency "breadcrumbs-missing-currency.json" "1")
assert_exit "sprint dodał react ale BRAK currency event → exit ≠0" "nonzero" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/verify-library-currency.sh' 1"
rm -rf "$TMP"

TMP=$(setup_currency "breadcrumbs-missing-currency.json" "0")
assert_exit "sprint NIE dotyka deps → exit 0 (currency check pomijalny)" "0" \
  bash -c "cd '$TMP' && BASE_DIR='$TMP' bash '$SCRIPTS/verify-library-currency.sh' 1"
rm -rf "$TMP"

# ============ SUMMARY ============
TOTAL=$((PASS + FAIL))
echo ""
echo "========================================"
echo "  RESULT: $PASS/$TOTAL passed, $FAIL failed"
echo "========================================"

if [[ "$FAIL" -gt 0 ]]; then
  echo ""
  echo "Failed tests:"
  printf '  - %s\n' "${FAILED_TESTS[@]}"
  exit 1
fi

echo "[OK] Wszystkie walidatory zachowują się zgodnie z oczekiwaniem na fixtures."
exit 0
