#!/usr/bin/env bash
# run-e2e.sh — end-to-end test CALEGO workflow audited-feature-workflow.
# Przepuszcza jedna fikcyjna feature przez WSZYSTKIE bramki faz 0->9 (positive),
# a nastepnie wstrzykuje defekty i sprawdza, ze lancuch je BLOKUJE (negative).
# Usage: bash tests/run-e2e.sh
# Exit 0 = positive: wszystkie bramki GREEN  ORAZ  negative: wszystkie defekty zablokowane.
#
# Roznica vs run-meta-tests.sh: meta-testy sprawdzaja bramki w IZOLACJI;
# ten plik sprawdza CALY przebieg workflow na spojnym artefaktowym przykladzie.

set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
S="$SKILL_DIR/scripts"

POS_PASS=0; POS_FAIL=0
NEG_BLOCK=0; NEG_LEAK=0

g(){ # positive: oczekiwany exit 0
  local desc="$1"; shift
  "$@" >/dev/null 2>&1; local rc=$?
  if [ "$rc" -eq 0 ]; then printf '  [GREEN] %s\n' "$desc"; POS_PASS=$((POS_PASS+1));
  else printf '  [RED]   %s (exit %s)\n' "$desc" "$rc"; POS_FAIL=$((POS_FAIL+1)); fi
}
chk(){ # negative: oczekiwany exit != 0 (zablokowane)
  local desc="$1"; shift
  "$@" >/dev/null 2>&1; local rc=$?
  if [ "$rc" -ne 0 ]; then printf '  [BLOCKED] %s (exit %s)\n' "$desc" "$rc"; NEG_BLOCK=$((NEG_BLOCK+1));
  else printf '  [LEAK!]   %s przepuszczone (exit 0)\n' "$desc"; NEG_LEAK=$((NEG_LEAK+1)); fi
}

# =====================================================================
echo "########## E2E POSITIVE: feature 070 (health endpoint) przez fazy 0->9 ##########"
WD=$(mktemp -d /tmp/aftw-e2e.XXXXXX)
(
  cd "$WD" || exit 1
  git init -q; git config user.email e2e@local; git config user.name E2E
  git checkout -q -b main
  printf 'export function existing() { return 1 }\n' > src.ts
  git add src.ts; git commit -q -m base
  git checkout -q -b feature
  { echo 'export function existing() { return 1 }'; echo 'export function getHealth() { return { status: "ok" } }'; for i in $(seq 1 15); do echo "// linia $i"; done; } > src.ts
  git add src.ts; git commit -q -m "feat: health endpoint"

  cat > env-detection.md <<'F'
# env-detection
- stack: Next.js 14 + Vitest
- size: M
- fragile: false
- teams: false
- plan-number: 70
F
  cat > analysis-070.md <<'F'
# Analysis Report — plan #70 — health endpoint
- effort-level: max
- orchestration: workflow — fan-out Phase 1 czytelnikow per podsystem
## Stack
Next.js 14 + Vitest.
## Architektura
route -> service -> DB.
## Analog featuru (PRIMARY TEMPLATE)
src/features/status/
## Research used
- context7: next@14 — route handlers
## Open questions
F
  cat > hypotheses.md <<'F'
## Hipoteza Minimal
jeden endpoint.
## Hipoteza Idiomatic
service + zod.
## Hipoteza Ambitious
generyczny health-registry.
## Recommendation
Idiomatic.
F
  cat > plan-070.md <<'F'
# Plan 070 — health endpoint
## Co i dlaczego
Endpoint /health dla monitoringu.
## Acceptance Criteria
| AC-ID | Typ | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | GET /health zwraca 200 | returns 200 | tests/health.test.ts | npm test |
## Definition of Done
- AC-1: npm test -> 1 passed.
## Assumptions
Node 20+.
## Out of scope
- metryki Prometheus.
## Thin Vertical Slices
1. route + test.
## Rollback plan
git revert.
## Target diff size
~30 linii.
## Hyrum Risk
brak zmian publicznych breaking.
## Anti-rationalization quick-table
link do anti-rationalization.md.
F
  printf 'test("returns 200", () => {})\n' > health.test.ts
  cat > ac-coverage.md <<'F'
## Acceptance Criteria
| AC-ID | Typ | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-F-01 | F | returns 200 | returns 200 | health.test.ts | npm test |
F
  printf 'FAIL tests/health.test.ts\n  x returns 200\nTests: 1 failed\nStatus: FAILED\n' > red.log
  cat > pr.md <<'F'
# PR — plan 070
## Anti-rationalization decisions
- #4 build clean != DoD — dolaczono raw log.
- #9 happy path — dodano test edge case.
## Why this existed (Chesterton check)
- legacyPing wprowadzony w INC-12 jako tymczasowy health-check; 0 callerow od 2025-02.
F
  cat > test-evidence.md <<'F'
# Test evidence — size M
## unit
3 passed.
## integration
route<->service: 2 passed.
## acceptance
AC-1 mapping: passed.
## regression
istniejace zielone.
F
  mkdir -p screenshots; : > screenshots/070-AC-F1.png; : > screenshots/070-AC-F2.png
  cat > ui-plan.md <<'F'
## Acceptance Criteria
| AC-ID | Opis |
| AC-F1 | widget health |
| AC-F2 | lista statusow |
F
  cat > cr.md <<'F'
# CR-070 — Five-Axis
## Correctness
ok. ## Readability
ok. ## Architecture
ok. ## Security
OWASP clean. ## Performance
no N+1.
## Verdict
PROCEED — 0 Critical.
F
  cat > chesterton.diff <<'F'
--- a/src/legacy.ts
+++ b/src/legacy.ts
-function legacyPing() {
-  return true
-}
F
  cat > adr-070.md <<'F'
# ADR-070
## Context
health endpoint.
## Decision
Idiomatic; alternatywy Minimal/Ambitious.
## Anti-rationalization decisions
odrzucono #4, #9.
## Consequences
nowy endpoint, brak wplywu.
F

  echo "[Phase 0]";   g "check-env-detection"            sh "$S/check-env-detection.sh" --file env-detection.md
  echo "[Phase 1.0]"; g "check-research-log (+context7)" sh "$S/check-research-log.sh" --file analysis-070.md --require-context7
  echo "[Phase 1]";   g "check-analysis-report (+effort)" sh "$S/check-analysis-report.sh" --file analysis-070.md
                      g "check-orchestration-decl (M)"   sh "$S/check-orchestration-decl.sh" --file analysis-070.md --size M
                      g "check-workflow-scripts (phase1)" sh "$S/check-workflow-scripts.sh" --file "$SKILL_DIR/workflows/phase1-fanout-analysis.js"
  echo "[Phase 1.5]"; g "api-impact-scan"                bash "$S/api-impact-scan.sh" --base main
  echo "[Phase 2+3]"; g "check-hypotheses"               sh "$S/check-hypotheses.sh" --file hypotheses.md
  echo "[Phase 4]";   g "check-plan (10 sekcji)"         sh "$S/check-plan.sh" --plan plan-070.md
  echo "[Phase 5.8]"; g "derive-goal-from-ac"            bash "$S/derive-goal-from-ac.sh" --plan plan-070.md
  echo "[Phase 6-G]"; g "run-goal-loop --dry-run"        bash "$S/run-goal-loop.sh" --goal "$WD/plan-070-goal-statement.md" --plan plan-070.md --dry-run
  echo "[Phase 6]";   g "check-tdd-red (RED)"            sh "$S/check-tdd-red.sh" --red-log red.log
                      g "verify-build-clean"             bash "$S/verify-build-clean.sh" --cmd "echo build ok"
                      g "check-pr-size"                  bash "$S/check-pr-size.sh" --base main
                      g "check-anti-rat"                 sh "$S/check-anti-rat.sh" --file pr.md
  echo "[Phase 6.5]"; g "extract-raw-log"                bash "$S/extract-raw-log.sh" --cmd "true"
  echo "[Phase 7]";   g "check-ac-coverage (1:1)"        sh "$S/check-ac-coverage.sh" --plan ac-coverage.md
                      g "check-test-scopes (M)"          sh "$S/check-test-scopes.sh" --evidence test-evidence.md --size M
  echo "[Phase 7.8]"; g "check-screenshots (per AC-F)"   sh "$S/check-screenshots.sh" --plan ui-plan.md --dir screenshots
  echo "[Phase 8]";   g "check-pr-size (gate)"           bash "$S/check-pr-size.sh" --base main
                      g "check-five-axis (5 osi)"        sh "$S/check-five-axis.sh" --file cr.md
                      g "check-chesterton"               sh "$S/check-chesterton.sh" --diff chesterton.diff --pr pr.md
  echo "[Phase 9]";   g "check-adr"                      sh "$S/check-adr.sh" --file adr-070.md

  # eksport licznikow z subshell przez plik
  echo "$POS_PASS $POS_FAIL" > "$WD/.pos"
)
read -r POS_PASS POS_FAIL < "$WD/.pos" 2>/dev/null || { POS_PASS=0; POS_FAIL=99; }
rm -rf "$WD"
POS_TOTAL=$((POS_PASS+POS_FAIL))
echo "  -> POSITIVE: $POS_PASS/$POS_TOTAL bramek GREEN"
echo ""

# =====================================================================
echo "########## E2E NEGATIVE: zepsuta feature MUSI byc zablokowana ##########"
ND=$(mktemp -d /tmp/aftw-e2eneg.XXXXXX)
(
  cd "$ND" || exit 1
  printf '# Plan\n## Co i dlaczego\nx\n## Acceptance Criteria\ny\n## Out of scope\n- z\n' > bad-plan.md
  chk "Phase 4: plan z brakami sekcji"        sh "$S/check-plan.sh" --plan bad-plan.md
  printf '# Analysis\n## Stack\nx\n## Architektura\ny\n## Analog featuru\nz\n## Open questions\n' > bad-analysis.md
  chk "Phase 1: analiza bez effort-level"     sh "$S/check-analysis-report.sh" --file bad-analysis.md
  printf -- '--- a/x.ts\n-function gone() {\n-  return 1\n-}\n' > d.diff
  printf '# PR\nusunalem martwy kod\n' > bad-pr.md
  chk "Phase 8: usuniecie funkcji bez Chesterton" sh "$S/check-chesterton.sh" --diff d.diff --pr bad-pr.md
  printf '## unit\nok\n## acceptance\nok\n## regression\nok\n' > bad-ev.md
  chk "Phase 7: brak scope integration (M)"   sh "$S/check-test-scopes.sh" --evidence bad-ev.md --size M
  printf 'Tests: 1 passed\nStatus: PASSED\n' > bad-red.log
  chk "Phase 6: brak failing testu (RED)"     sh "$S/check-tdd-red.sh" --red-log bad-red.log
  printf '# Analysis\n## Research used\n- none\n## Open questions\n' > bad-research.md
  chk "Phase 1.0: research=none bez uzasadnienia" sh "$S/check-research-log.sh" --file bad-research.md
  printf '# Analysis\n## Stack\nx\n- effort-level: high\n## Open questions\n' > bad-orch.md
  chk "Phase 1: rozmiar M bez orchestration decl"  sh "$S/check-orchestration-decl.sh" --file bad-orch.md --size M
  echo "$NEG_BLOCK $NEG_LEAK" > "$ND/.neg"
)
read -r NEG_BLOCK NEG_LEAK < "$ND/.neg" 2>/dev/null || { NEG_BLOCK=0; NEG_LEAK=99; }
rm -rf "$ND"
NEG_TOTAL=$((NEG_BLOCK+NEG_LEAK))
echo "  -> NEGATIVE: $NEG_BLOCK/$NEG_TOTAL defektow zablokowanych ($NEG_LEAK leak)"
echo ""

# =====================================================================
echo "========================================================"
if [ "$POS_FAIL" -eq 0 ] && [ "$POS_PASS" -ge 20 ] && [ "$NEG_LEAK" -eq 0 ] && [ "$NEG_BLOCK" -ge 1 ]; then
  echo "  E2E RESULT: PASS — positive $POS_PASS/$POS_TOTAL GREEN, negative $NEG_BLOCK/$NEG_TOTAL BLOCKED"
  echo "========================================================"
  exit 0
fi
echo "  E2E RESULT: FAIL — positive_fail=$POS_FAIL negative_leak=$NEG_LEAK"
echo "========================================================"
exit 1
