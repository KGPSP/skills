#!/usr/bin/env bash
# run-meta-tests.sh — meta-tests for audited-feature-workflow gate scripts.
# GOOD fixtures/cases must exit 0. BAD fixtures/cases must exit != 0.
# Some scripts classify in stdout (not exit code) — checked via assert_stdout_contains.
# Usage: bash tests/run-meta-tests.sh
# Exit 0 = every case matched expectation.
#
# Beyoncé Rule for the skill itself: every scripts/*.sh has >=1 GOOD + >=1 BAD case here.

set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$SKILL_DIR/scripts"
FIXTURES="$SKILL_DIR/tests/fixtures"

PASS=0
FAIL=0
FAILED_TESTS=()

# mktemp under /tmp so derive-goal-from-ac.sh OUT_DIR guard (allows /tmp, /private/tmp,
# or repo root) is satisfied on macOS (where bare mktemp -> /var/folders).
mk() { mktemp -d "/tmp/aftw-meta.XXXXXX"; }

assert_exit() {
  local desc="$1"; local expected="$2"; shift 2
  local actual=0
  "$@" >/dev/null 2>&1 || actual=$?
  if [[ "$expected" == "0" && "$actual" == "0" ]]; then
    echo "  [PASS] $desc (exit 0)"; PASS=$((PASS + 1))
  elif [[ "$expected" == "nonzero" && "$actual" != "0" ]]; then
    echo "  [PASS] $desc (exit $actual != 0)"; PASS=$((PASS + 1))
  elif [[ "$expected" =~ ^[0-9]+$ && "$actual" == "$expected" ]]; then
    echo "  [PASS] $desc (exit $actual)"; PASS=$((PASS + 1))
  else
    echo "  [FAIL] $desc (expected $expected, got $actual)"; FAIL=$((FAIL + 1)); FAILED_TESTS+=("$desc")
  fi
}

assert_stdout_contains() {
  local desc="$1"; local needle="$2"; shift 2
  local out
  out="$("$@" 2>/dev/null)" || true
  if printf '%s' "$out" | grep -qF "$needle"; then
    echo "  [PASS] $desc (stdout contains '$needle')"; PASS=$((PASS + 1))
  else
    echo "  [FAIL] $desc (stdout missing '$needle')"; FAIL=$((FAIL + 1)); FAILED_TESTS+=("$desc")
  fi
}

# Build a temp git repo: main baseline commit, then a feature branch checked out as HEAD
# with `added_lines` extra lines in feature.txt. Echoes repo path.
setup_git_diff() {
  local added_lines="$1"
  local TMP; TMP=$(mk)
  (
    cd "$TMP" || exit 1
    git init -q
    git config user.email t@local; git config user.name T
    git checkout -q -b main
    echo "base" > base.txt
    git add base.txt; git commit -q -m base
    git checkout -q -b feature
    seq 1 "$added_lines" > feature.txt
    git add feature.txt; git commit -q -m feat
  )
  echo "$TMP"
}

echo "========================================"
echo "  Meta-tests: audited-feature-workflow"
echo "========================================"
echo ""

# ============ [1] check-pr-size.sh ============
echo "[1] check-pr-size.sh"
T=$(setup_git_diff 10)
assert_exit "pr-size under-100 -> exit 0" "0" \
  bash -c "cd '$T' && bash '$SCRIPTS/check-pr-size.sh' --base main"
rm -rf "$T"

T=$(setup_git_diff 400)
assert_exit "pr-size 301-1000 without --justified -> exit 1" "1" \
  bash -c "cd '$T' && bash '$SCRIPTS/check-pr-size.sh' --base main"
rm -rf "$T"

T=$(setup_git_diff 400)
assert_exit "pr-size 301-1000 with --justified -> exit 0" "0" \
  bash -c "cd '$T' && bash '$SCRIPTS/check-pr-size.sh' --base main --justified"
rm -rf "$T"

T=$(setup_git_diff 1200)
assert_exit "pr-size >1000 -> exit 2 (hard stop)" "2" \
  bash -c "cd '$T' && bash '$SCRIPTS/check-pr-size.sh' --base main"
rm -rf "$T"

# ============ [2] verify-build-clean.sh ============
echo "[2] verify-build-clean.sh"
assert_exit "build clean (--cmd 'echo ok') -> exit 0" "0" \
  bash "$SCRIPTS/verify-build-clean.sh" --cmd "echo build ok"
assert_exit "build with warning -> exit 1" "nonzero" \
  bash "$SCRIPTS/verify-build-clean.sh" --cmd "echo 'warning: deprecated api'"
assert_exit "build failing (--cmd false) -> exit 1" "nonzero" \
  bash "$SCRIPTS/verify-build-clean.sh" --cmd "false"

# ============ [3] check-ac-coverage.sh ============
echo "[3] check-ac-coverage.sh"
# Kanoniczna 6-kolumnowa macierz (ac-protocol.md / SKILL.md Phase 4): Test ID=col5, Plik testu=col6.
# Fixture pokrywa regresję format-drift: regex AC-[FNTC] (AC-F-01/AC-N-02), strip sufiksu :LINE, grep Test ID w pliku.
assert_exit "ac-coverage 6-col complete (AC-F-01/AC-N-02 + :LINE strip + id grep) -> exit 0" "0" \
  bash -c "cd '$SKILL_DIR' && bash '$SCRIPTS/check-ac-coverage.sh' --plan '$FIXTURES/ac-coverage-phase4.md'"

T=$(mk)
cat > "$T/plan.md" <<'EOF'
## Acceptance Criteria

| AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-F-01 | F | returns 200 | T-1 | nonexistent.test.ts | npm test |
EOF
assert_exit "ac-coverage 6-col missing test file -> exit 1" "nonzero" \
  bash -c "cd '$T' && bash '$SCRIPTS/check-ac-coverage.sh' --plan plan.md"
rm -rf "$T"

# ============ [4] extract-raw-log.sh ============
echo "[4] extract-raw-log.sh"
assert_exit "extract-raw-log success (--cmd true) -> exit 0" "0" \
  bash "$SCRIPTS/extract-raw-log.sh" --cmd "true"
assert_exit "extract-raw-log failure (--cmd false) -> exit nonzero" "nonzero" \
  bash "$SCRIPTS/extract-raw-log.sh" --cmd "false"

# ============ [5] api-impact-scan.sh ============
echo "[5] api-impact-scan.sh"
T=$(mk)
(
  cd "$T" || exit 1
  git init -q; git config user.email t@local; git config user.name T
  git checkout -q -b main
  printf 'export function alpha() {}\n' > api.ts
  git add api.ts; git commit -q -m base
  git checkout -q -b feature
  printf 'export function alpha() {}\nexport function beta() {}\n' > api.ts
  git add api.ts; git commit -q -m feat
)
assert_stdout_contains "api-impact additive export -> classifies additive" '"type":"additive"' \
  bash -c "cd '$T' && bash '$SCRIPTS/api-impact-scan.sh' --base main"
assert_stdout_contains "api-impact emits hyrum_risk" 'hyrum_risk' \
  bash -c "cd '$T' && bash '$SCRIPTS/api-impact-scan.sh' --base main"
rm -rf "$T"

# ============ [6] derive-goal-from-ac.sh ============
echo "[6] derive-goal-from-ac.sh"
T=$(mk)
cp "$FIXTURES/goal-plan-complete.md" "$T/plan.md"
assert_exit "derive-goal complete plan -> exit 0" "0" \
  bash "$SCRIPTS/derive-goal-from-ac.sh" --plan "$T/plan.md"
rm -rf "$T"

T=$(mk)
cp "$FIXTURES/goal-plan-missing-oos.md" "$T/plan.md"
assert_exit "derive-goal missing Out-of-scope -> exit 1" "nonzero" \
  bash "$SCRIPTS/derive-goal-from-ac.sh" --plan "$T/plan.md"
rm -rf "$T"

# ============ [7] run-goal-loop.sh ============
echo "[7] run-goal-loop.sh"
T=$(mk)
cp "$FIXTURES/goal-statement-valid.md" "$T/x-goal-statement.md"
echo "plan" > "$T/plan.md"
assert_exit "run-goal-loop dry-run valid -> exit 0" "0" \
  bash "$SCRIPTS/run-goal-loop.sh" --goal "$T/x-goal-statement.md" --plan "$T/plan.md" --dry-run
rm -rf "$T"

T=$(mk)
cp "$FIXTURES/goal-statement-no-weryfikacja.md" "$T/x-goal-statement.md"
echo "plan" > "$T/plan.md"
assert_exit "run-goal-loop missing Weryfikacja -> exit 1" "nonzero" \
  bash "$SCRIPTS/run-goal-loop.sh" --goal "$T/x-goal-statement.md" --plan "$T/plan.md" --dry-run
rm -rf "$T"

T=$(mk)
cp "$FIXTURES/goal-statement-chaining.md" "$T/x-goal-statement.md"
echo "plan" > "$T/plan.md"
assert_exit "run-goal-loop chaining in Komenda -> exit 2 (scope-violation)" "2" \
  bash "$SCRIPTS/run-goal-loop.sh" --goal "$T/x-goal-statement.md" --plan "$T/plan.md"
rm -rf "$T"

T=$(mk)
cp "$FIXTURES/goal-statement-valid.md" "$T/x-goal-statement.md"
echo "plan" > "$T/plan.md"
printf 'iter=99\nstart_epoch=1\n' > "$T/x-goal-iter-state"
assert_exit "run-goal-loop iter cap exceeded -> exit 2 (iter-cap-hit)" "2" \
  bash "$SCRIPTS/run-goal-loop.sh" --goal "$T/x-goal-statement.md" --plan "$T/plan.md" --max-iter 20
rm -rf "$T"

T=$(mk)
cp "$FIXTURES/goal-statement-valid.md" "$T/x-goal-statement.md"
echo "plan" > "$T/plan.md"
printf 'iter=1\nstart_epoch=1\n' > "$T/x-goal-iter-state"
assert_exit "run-goal-loop time cap exceeded -> exit 2 (time-cap-hit)" "2" \
  bash "$SCRIPTS/run-goal-loop.sh" --goal "$T/x-goal-statement.md" --plan "$T/plan.md" --max-time 1
rm -rf "$T"

T=$(mk)
cp "$FIXTURES/goal-statement-valid.md" "$T/x-goal-statement.md"
echo "plan" > "$T/plan.md"
printf 'iter=notanumber\nstart_epoch=notanumber\n' > "$T/x-goal-iter-state"
assert_exit "run-goal-loop corrupt iter-state -> no crash (regression C-1)" "0" \
  bash "$SCRIPTS/run-goal-loop.sh" --goal "$T/x-goal-statement.md" --plan "$T/plan.md" --max-iter 20
rm -rf "$T"

# ============ [8] check-env-detection.sh (Phase 0) ============
echo "[8] check-env-detection.sh"
assert_exit "env-detection complete (5 fields) -> exit 0" "0" \
  bash "$SCRIPTS/check-env-detection.sh" --file "$FIXTURES/env-detection-complete.md"
assert_exit "env-detection missing fields -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-env-detection.sh" --file "$FIXTURES/env-detection-missing-fields.md"

# ============ [9] check-analysis-report.sh (Phase 1) ============
echo "[9] check-analysis-report.sh"
assert_exit "analysis complete + open-questions resolved -> exit 0" "0" \
  bash "$SCRIPTS/check-analysis-report.sh" --file "$FIXTURES/analysis-complete.md"
assert_exit "analysis with unresolved open questions -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-analysis-report.sh" --file "$FIXTURES/analysis-open-questions.md"
assert_exit "analysis without effort-level -> exit 1 (v3.6.1 standard)" "nonzero" \
  bash "$SCRIPTS/check-analysis-report.sh" --file "$FIXTURES/analysis-no-effort.md"

# ============ [10] check-hypotheses.sh (Phase 2+3) ============
echo "[10] check-hypotheses.sh"
assert_exit "hypotheses 3 + recommendation -> exit 0" "0" \
  bash "$SCRIPTS/check-hypotheses.sh" --file "$FIXTURES/hypotheses-complete.md"
assert_exit "hypotheses missing Ambitious -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-hypotheses.sh" --file "$FIXTURES/hypotheses-missing-ambitious.md"

# ============ [11] check-screenshots.sh (Phase 7.8) ============
echo "[11] check-screenshots.sh"
T=$(mk); mkdir -p "$T/shots"
: > "$T/shots/42-AC-F1-chromium.png"
: > "$T/shots/42-AC-F2-chromium.png"
assert_exit "screenshots all AC-F present -> exit 0" "0" \
  bash "$SCRIPTS/check-screenshots.sh" --plan "$FIXTURES/screenshots-plan.md" --dir "$T/shots"
rm -rf "$T"

T=$(mk); mkdir -p "$T/shots"
: > "$T/shots/42-AC-F1-chromium.png"
assert_exit "screenshots missing AC-F2 -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-screenshots.sh" --plan "$FIXTURES/screenshots-plan.md" --dir "$T/shots"
rm -rf "$T"

# ============ [12] check-adr.sh (Phase 9) ============
echo "[12] check-adr.sh"
assert_exit "adr complete (mandatory sections) -> exit 0" "0" \
  bash "$SCRIPTS/check-adr.sh" --file "$FIXTURES/adr-complete.md"
assert_exit "adr missing Consequences -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-adr.sh" --file "$FIXTURES/adr-missing-consequences.md"

# ============ [13] check-plan.sh ============
echo "[13] check-plan.sh"
assert_exit "plan complete (10 sekcji) -> exit 0" "0" \
  bash "$SCRIPTS/check-plan.sh" --plan "$FIXTURES/plan-complete-10.md"
assert_exit "plan missing sections -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-plan.sh" --plan "$FIXTURES/plan-missing-sections.md"

# ============ [14] check-tdd-red.sh ============
echo "[14] check-tdd-red.sh"
assert_exit "tdd RED log (FAILED) -> exit 0" "0" \
  bash "$SCRIPTS/check-tdd-red.sh" --red-log "$FIXTURES/red-log-failed.md"
assert_exit "tdd log PASSED (brak RED) -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-tdd-red.sh" --red-log "$FIXTURES/red-log-passed.md"

# ============ [15] check-anti-rat.sh ============
echo "[15] check-anti-rat.sh"
assert_exit "anti-rat decisions present -> exit 0" "0" \
  bash "$SCRIPTS/check-anti-rat.sh" --file "$FIXTURES/anti-rat-complete.md"
assert_exit "anti-rat section empty -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-anti-rat.sh" --file "$FIXTURES/anti-rat-empty.md"

# ============ [16] check-test-scopes.sh ============
echo "[16] check-test-scopes.sh"
assert_exit "test scopes M complete -> exit 0" "0" \
  bash "$SCRIPTS/check-test-scopes.sh" --evidence "$FIXTURES/test-scopes-M-complete.md" --size M
assert_exit "test scopes M missing integration -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-test-scopes.sh" --evidence "$FIXTURES/test-scopes-M-missing.md" --size M

# ============ [17] check-five-axis.sh ============
echo "[17] check-five-axis.sh"
assert_exit "five-axis complete (5 osi + verdict) -> exit 0" "0" \
  bash "$SCRIPTS/check-five-axis.sh" --file "$FIXTURES/five-axis-complete.md"
assert_exit "five-axis missing Security -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-five-axis.sh" --file "$FIXTURES/five-axis-missing.md"

# ============ [18] check-chesterton.sh ============
echo "[18] check-chesterton.sh"
assert_exit "chesterton deletion + justification -> exit 0" "0" \
  bash "$SCRIPTS/check-chesterton.sh" --diff "$FIXTURES/chesterton-del.diff" --pr "$FIXTURES/chesterton-pr-good.md"
assert_exit "chesterton deletion without justification -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-chesterton.sh" --diff "$FIXTURES/chesterton-del.diff" --pr "$FIXTURES/chesterton-pr-bad.md"

# ============ [19] check-research-log.sh (Phase 1.0) ============
echo "[19] check-research-log.sh"
assert_exit "research-log complete (context7 entry) -> exit 0" "0" \
  bash "$SCRIPTS/check-research-log.sh" --file "$FIXTURES/research-used-complete.md"
assert_exit "research-log skip 'none -- powod' -> exit 0" "0" \
  bash "$SCRIPTS/check-research-log.sh" --file "$FIXTURES/research-used-none-justified.md"
assert_exit "research-log missing section -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-research-log.sh" --file "$FIXTURES/research-used-missing.md"
assert_exit "research-log bare 'none' bez uzasadnienia -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-research-log.sh" --file "$FIXTURES/research-used-none-bare.md"
assert_exit "research-log bez mechanizmu -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-research-log.sh" --file "$FIXTURES/research-used-no-mechanism.md"
assert_exit "research-log Explore-only (bez flagi) -> exit 0" "0" \
  bash "$SCRIPTS/check-research-log.sh" --file "$FIXTURES/research-used-explore-only.md"
assert_exit "research-log complete + --require-context7 -> exit 0" "0" \
  bash "$SCRIPTS/check-research-log.sh" --file "$FIXTURES/research-used-complete.md" --require-context7
assert_exit "research-log Explore-only + --require-context7 -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-research-log.sh" --file "$FIXTURES/research-used-explore-only.md" --require-context7

# ============ [20] check-orchestration-decl.sh (Phase 1) ============
echo "[20] check-orchestration-decl.sh"
assert_exit "orchestration M/L declared (ultracode+fallback) -> exit 0" "0" \
  bash "$SCRIPTS/check-orchestration-decl.sh" --file "$FIXTURES/orchestration-decl-ml-plan.md" --size L
assert_exit "orchestration workflow/ultracode + --goal -> exit 2 (self-consistency hard-stop)" "2" \
  bash "$SCRIPTS/check-orchestration-decl.sh" --file "$FIXTURES/orchestration-decl-ml-plan.md" --size L --goal
assert_exit "orchestration 'none -- powod' (M) -> exit 0" "0" \
  bash "$SCRIPTS/check-orchestration-decl.sh" --file "$FIXTURES/orchestration-decl-ml-none-justified.md" --size M
assert_exit "orchestration S absent -> exit 0 (declare-not-prescribe)" "0" \
  bash "$SCRIPTS/check-orchestration-decl.sh" --file "$FIXTURES/orchestration-decl-s-absent.md" --size S
assert_exit "orchestration M/L missing field -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-orchestration-decl.sh" --file "$FIXTURES/orchestration-decl-ml-missing.md" --size M
assert_exit "orchestration bare 'none' bez uzasadnienia -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-orchestration-decl.sh" --file "$FIXTURES/orchestration-decl-none-bare.md" --size L
assert_exit "orchestration ultracode bez fallbacku /effort -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-orchestration-decl.sh" --file "$FIXTURES/orchestration-decl-ml-ultracode-nofallback.md" --size L

# ============ [21] check-workflow-scripts.sh (Phase 1/6/8) ============
echo "[21] check-workflow-scripts.sh"
assert_exit "workflow GOOD template -> exit 0" "0" \
  bash "$SCRIPTS/check-workflow-scripts.sh" --file "$FIXTURES/workflow-phase1-good.js"
assert_exit "workflow syntax error -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-workflow-scripts.sh" --file "$FIXTURES/workflow-syntax-bad.js"
assert_exit "workflow disallowed token (paralel) -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-workflow-scripts.sh" --file "$FIXTURES/workflow-bad-token.js"
assert_exit "workflow missing DOC-CONSTRAINTS header -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-workflow-scripts.sh" --file "$FIXTURES/workflow-no-header.js"
assert_exit "workflow gate inside (APPROVAL) -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-workflow-scripts.sh" --file "$FIXTURES/workflow-gate-inside.js"
assert_exit "workflow lead-IO (process.) -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-workflow-scripts.sh" --file "$FIXTURES/workflow-lead-io.js"
assert_exit "workflow concurrency > 16 -> exit 1" "nonzero" \
  bash "$SCRIPTS/check-workflow-scripts.sh" --file "$FIXTURES/workflow-overconc.js"

# ============ Summary ============
echo ""
echo "========================================"
TOTAL=$((PASS + FAIL))
echo "  Result: $PASS/$TOTAL passed"
if [[ $FAIL -gt 0 ]]; then
  echo "  FAILED:"
  for t in "${FAILED_TESTS[@]}"; do echo "    - $t"; done
  echo "========================================"
  exit 1
fi
echo "========================================"
exit 0
