# feature-planner-v3 `/goal` Mode — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `/goal` switch to `feature-planner-v3` skill — deterministically derive goal-statement from Phase 4 Acceptance Criteria table, gate it through new APPROVAL #1.5, then execute autonomous 6-Goal loop driven by AC verification commands.

**Architecture:** Hub-and-spoke. Concise sections in `SKILL.md` (Phase 5.8 + Gate #1.5 + 6-Goal sub-route, ~69 lines total). Full protocol in new `references/goal-mode-protocol.md`. Two POSIX-friendly bash scripts (`derive-goal-from-ac.sh` for AC parsing + goal-statement generation, `run-goal-loop.sh` for verification driver). Test fixtures (complete + incomplete plan) drive script tests. `/goal` is exclusive with `/ralph` and `/teams`; fragile zone forces hard stop.

**Tech Stack:** Bash (POSIX, grep/awk/sed), Markdown.

**Source spec:** `docs/superpowers/specs/2026-05-13-feature-planner-v3-goal-mode-design.md`

---

## File Structure

| Path | Status | Responsibility |
|---|---|---|
| `dev/feature-planner-v3/tests/fixtures/complete-plan.md` | NEW | Wzorcowy plan Phase 4 z poprawną tabelą AC, OOS, DoD. Driver dla happy-path testów. |
| `dev/feature-planner-v3/tests/fixtures/incomplete-plan.md` | NEW | Plan z brakującą `Komenda` w jednym wierszu AC. Driver dla fail-path testów. |
| `dev/feature-planner-v3/scripts/derive-goal-from-ac.sh` | NEW | Parser AC + generator `goal-statement.md` + `goal-prompt.txt`. Hard stop na brakach. |
| `dev/feature-planner-v3/scripts/run-goal-loop.sh` | NEW | Driver 6-Goal: parsuje weryfikacje, uruchamia cmd-y, agreguje exit codes, drukuje hand-off do calling agent. |
| `dev/feature-planner-v3/references/goal-mode-protocol.md` | NEW | Pełny protokół Phase 5.8 + Gate #1.5 + 6-Goal + Anti-Rat variant + telemetry. |
| `dev/feature-planner-v3/SKILL.md` | MODIFY | +~69 linii: frontmatter, architecture table, Anti-Rat #11, Phase 5.7 nota, Phase 5.8, 6-Goal routing, Indeks, Sources. |
| `DOC/goal_mode.md` | MODIFY | +1 linia backlink do `goal-mode-protocol.md`. |

---

## Task 1: Create test fixtures

**Files:**
- Create: `dev/feature-planner-v3/tests/fixtures/complete-plan.md`
- Create: `dev/feature-planner-v3/tests/fixtures/incomplete-plan.md`

- [ ] **Step 1: Create directory**

Run: `mkdir -p dev/feature-planner-v3/tests/fixtures`

- [ ] **Step 2: Write complete-plan.md**

Create `dev/feature-planner-v3/tests/fixtures/complete-plan.md` with full Phase 4 structure:

```markdown
# Plan 999-fixture-complete

## Co i dlaczego

Fixture do testów `derive-goal-from-ac.sh` happy-path. Symuluje kompletny plan Phase 4.

## Acceptance Criteria

| AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | Funkcja `add(a,b)` zwraca sumę | T-1 | tests/add.test.js | `npm test -- tests/add.test.js` |
| AC-2 | F | Funkcja `sub(a,b)` zwraca różnicę | T-2 | tests/sub.test.js | `npm test -- tests/sub.test.js` |
| AC-3 | N | Suma 10000 wywołań <100ms | T-3 | tests/perf.test.js | `npm test -- tests/perf.test.js` |
| AC-4 | C | Brak zewnętrznych deps | T-4 | tests/deps.test.js | `npm run check-deps` |

## Definition of Done

- AC-1: stdout zawiera `PASS T-1`, exit 0.
- AC-2: stdout zawiera `PASS T-2`, exit 0.
- AC-3: stdout zawiera `duration < 100ms`, exit 0.
- AC-4: stdout zawiera `no external deps`, exit 0.

## Assumptions

- Node 20+ dostępny.
- npm test runner skonfigurowany.

## Out of scope

- Dzielenie i mnożenie (osobny plan).
- UI dla kalkulatora.

## Thin Vertical Slices

1. add + test.
2. sub + test.
3. perf check.
4. deps lint.

## Rollback plan

`git revert HEAD`.

## Target diff size

~80 linii.

## files-touched

- src/math.js
- tests/add.test.js
- tests/sub.test.js
- tests/perf.test.js
- tests/deps.test.js
```

- [ ] **Step 3: Write incomplete-plan.md**

Create `dev/feature-planner-v3/tests/fixtures/incomplete-plan.md` — kopia powyższego ale z brakującą `Komenda` w wierszu AC-2:

```markdown
# Plan 999-fixture-incomplete

## Co i dlaczego

Fixture do testów `derive-goal-from-ac.sh` fail-path. Brak `Komenda` w AC-2.

## Acceptance Criteria

| AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | Funkcja `add(a,b)` zwraca sumę | T-1 | tests/add.test.js | `npm test -- tests/add.test.js` |
| AC-2 | F | Funkcja `sub(a,b)` zwraca różnicę | T-2 | tests/sub.test.js |  |
| AC-3 | N | Suma 10000 wywołań <100ms | T-3 | tests/perf.test.js | `npm test -- tests/perf.test.js` |

## Definition of Done

- AC-1: stdout zawiera `PASS T-1`, exit 0.

## Out of scope

- Dzielenie i mnożenie.
```

- [ ] **Step 4: Verify fixtures readable**

Run: `wc -l dev/feature-planner-v3/tests/fixtures/*.md`
Expected: dwie linie outputu, każdy plik >40 linii (complete) i >15 linii (incomplete).

- [ ] **Step 5: Commit**

```bash
git add dev/feature-planner-v3/tests/fixtures/
git commit -m "test(feature-planner-v3): add /goal mode fixtures (complete + incomplete plan)"
```

---

## Task 2: derive-goal-from-ac.sh — minimal script + happy path

**Files:**
- Create: `dev/feature-planner-v3/scripts/derive-goal-from-ac.sh`
- Test fixture: `dev/feature-planner-v3/tests/fixtures/complete-plan.md` (from Task 1)

- [ ] **Step 1: Write failing test as oneliner**

Define expected behavior as test command (saved as comment for now):

```bash
# Test: bash dev/feature-planner-v3/scripts/derive-goal-from-ac.sh \
#         --plan dev/feature-planner-v3/tests/fixtures/complete-plan.md \
#         --out-dir /tmp/goal-test \
#       && test -s /tmp/goal-test/complete-plan-goal-statement.md \
#       && test -s /tmp/goal-test/complete-plan-goal-prompt.txt
```

- [ ] **Step 2: Run test to verify it fails**

Run: `rm -rf /tmp/goal-test && mkdir -p /tmp/goal-test && bash dev/feature-planner-v3/scripts/derive-goal-from-ac.sh --plan dev/feature-planner-v3/tests/fixtures/complete-plan.md --out-dir /tmp/goal-test 2>&1`
Expected: FAIL with "No such file or directory" (script nie istnieje).

- [ ] **Step 3: Write minimal derive-goal-from-ac.sh**

Create `dev/feature-planner-v3/scripts/derive-goal-from-ac.sh`:

```bash
#!/usr/bin/env bash
# derive-goal-from-ac.sh — parser AC + generator goal-statement.md/goal-prompt.txt
# Hard-stopuje na brakach (zgodne ze spec §5.1).
# Usage: derive-goal-from-ac.sh --plan <path> [--out-dir <dir>] [--strict]

set -euo pipefail

SCRIPT_VERSION="0.1.0"
PLAN=""
OUT_DIR=""
STRICT=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan) PLAN="$2"; shift 2 ;;
    --out-dir) OUT_DIR="$2"; shift 2 ;;
    --strict) STRICT=1; shift ;;
    --no-strict) STRICT=0; shift ;;
    -h|--help) echo "Usage: $0 --plan <path> [--out-dir <dir>] [--strict|--no-strict]"; exit 0 ;;
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
  flag && /^\| AC-/ {print}
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
  fi

  if [[ ",$SEEN_AC_IDS," == *",$AC_ID,"* ]]; then
    ERRORS+=("$AC_ID: duplikat AC-ID")
  fi
  SEEN_AC_IDS="$SEEN_AC_IDS,$AC_ID"

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
  echo "- **Komenda**: \`sh dev/feature-planner-v3/scripts/check-ac-coverage.sh --plan ${PLAN}\`"
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
```

- [ ] **Step 4: Make script executable**

Run: `chmod +x dev/feature-planner-v3/scripts/derive-goal-from-ac.sh`

- [ ] **Step 5: Run test to verify happy path works**

Run:
```bash
rm -rf /tmp/goal-test && mkdir -p /tmp/goal-test
bash dev/feature-planner-v3/scripts/derive-goal-from-ac.sh \
  --plan dev/feature-planner-v3/tests/fixtures/complete-plan.md \
  --out-dir /tmp/goal-test
echo "---"
ls -la /tmp/goal-test/
echo "---"
test -s /tmp/goal-test/complete-plan-goal-statement.md && echo "statement OK"
test -s /tmp/goal-test/complete-plan-goal-prompt.txt && echo "prompt OK"
```
Expected: stdout `OK: AC=4, Verification=6, Constraints=...`, dwa pliki obecne i niepuste, `statement OK` + `prompt OK`.

- [ ] **Step 6: Commit**

```bash
git add dev/feature-planner-v3/scripts/derive-goal-from-ac.sh
git commit -m "feat(feature-planner-v3): add derive-goal-from-ac.sh — happy path AC → goal-statement"
```

---

## Task 3: derive-goal-from-ac.sh — fail-path test (hard stop on missing fields)

**Files:**
- Modify: `dev/feature-planner-v3/scripts/derive-goal-from-ac.sh` (validation already implemented in Task 2 — this task verifies it)

- [ ] **Step 1: Run test for incomplete-plan.md**

Run:
```bash
rm -rf /tmp/goal-test-fail && mkdir -p /tmp/goal-test-fail
bash dev/feature-planner-v3/scripts/derive-goal-from-ac.sh \
  --plan dev/feature-planner-v3/tests/fixtures/incomplete-plan.md \
  --out-dir /tmp/goal-test-fail
EXIT=$?
echo "exit code: $EXIT"
[ $EXIT -eq 1 ] && echo "OK: hard stop działa" || echo "FAIL: oczekiwano exit 1"
```
Expected: exit 1, stderr zawiera "AC-2: kolumna 'Komenda' pusta lub placeholder", linia z `OK: hard stop działa`.

- [ ] **Step 2: Verify no output files generated on fail**

Run: `ls /tmp/goal-test-fail/ 2>/dev/null | wc -l`
Expected: `0` (skrypt nie generuje plików gdy walidacja faili).

- [ ] **Step 3: Test missing Out of scope section**

Create transient fixture missing OOS:
```bash
cat > /tmp/no-oos.md <<'EOF'
## Acceptance Criteria
| AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | test | T-1 | tests/x.test.js | `npm test` |
## Definition of Done
- AC-1: exit 0.
EOF
bash dev/feature-planner-v3/scripts/derive-goal-from-ac.sh --plan /tmp/no-oos.md --out-dir /tmp/no-oos-out 2>&1 | grep -q "missing section '## Out of scope'" && echo "OK"
```
Expected: `OK`.

- [ ] **Step 4: Test invalid Typ value**

```bash
cat > /tmp/bad-typ.md <<'EOF'
## Acceptance Criteria
| AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | X | test | T-1 | tests/x.test.js | `npm test` |
## Out of scope
- nic
## Definition of Done
- AC-1: exit 0.
EOF
bash dev/feature-planner-v3/scripts/derive-goal-from-ac.sh --plan /tmp/bad-typ.md --out-dir /tmp/bad-typ-out 2>&1 | grep -q "Typ='X'" && echo "OK"
```
Expected: `OK`.

- [ ] **Step 5: Commit (no-op or chmod-only commit OK)**

If no script changes were needed (validation already correct from Task 2), skip commit. Otherwise:

```bash
git add dev/feature-planner-v3/scripts/derive-goal-from-ac.sh
git commit -m "test(feature-planner-v3): verify derive-goal hard-stop on incomplete AC"
```

---

## Task 4: run-goal-loop.sh — dry-run mode

**Files:**
- Create: `dev/feature-planner-v3/scripts/run-goal-loop.sh`

- [ ] **Step 1: Write failing test command**

```bash
# Test: --dry-run powinno wypisać plan iteracji i zakończyć się exit 0.
# Input: goal-statement.md wygenerowany w Task 2 (/tmp/goal-test/complete-plan-goal-statement.md)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash dev/feature-planner-v3/scripts/run-goal-loop.sh --goal /tmp/goal-test/complete-plan-goal-statement.md --plan dev/feature-planner-v3/tests/fixtures/complete-plan.md --dry-run 2>&1`
Expected: FAIL with "No such file or directory" (skrypt nie istnieje).

- [ ] **Step 3: Write run-goal-loop.sh**

Create `dev/feature-planner-v3/scripts/run-goal-loop.sh`:

```bash
#!/usr/bin/env bash
# run-goal-loop.sh — autonomous goal-driven loop driver (6-Goal route).
# Pure validator/driver — calling Claude session woła model, nie ten skrypt.
# Usage: run-goal-loop.sh --goal <path> --plan <path>
#                       [--max-iter N] [--max-time MIN]
#                       [--worktree PATH] [--files-touched CSV]
#                       [--fragile-paths CSV] [--dry-run]

set -euo pipefail

GOAL=""
PLAN=""
MAX_ITER=20
MAX_TIME=480
WORKTREE=""
FILES_TOUCHED=""
FRAGILE_PATHS="migrations/,terraform/,k8s/,auth/,.github/workflows/,Dockerfile"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --goal) GOAL="$2"; shift 2 ;;
    --plan) PLAN="$2"; shift 2 ;;
    --max-iter) MAX_ITER="$2"; shift 2 ;;
    --max-time) MAX_TIME="$2"; shift 2 ;;
    --worktree) WORKTREE="$2"; shift 2 ;;
    --files-touched) FILES_TOUCHED="$2"; shift 2 ;;
    --fragile-paths) FRAGILE_PATHS="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) echo "Usage: $0 --goal <path> --plan <path> [--dry-run] [--max-iter N] [--max-time MIN]"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

[[ -z "$GOAL" ]] && { echo "ERR: --goal required" >&2; exit 2; }
[[ -z "$PLAN" ]] && { echo "ERR: --plan required" >&2; exit 2; }
[[ ! -f "$GOAL" ]] && { echo "ERR: goal file not found: $GOAL" >&2; exit 1; }
[[ ! -f "$PLAN" ]] && { echo "ERR: plan file not found: $PLAN" >&2; exit 1; }

GOAL_CONTENT=$(tr -d '\r' < "$GOAL")

# --- Parse verification commands ---
# Each "### AC-X — T-Y" block has a "Komenda" line.
mapfile -t CMD_LINES < <(grep "^- \*\*Komenda\*\*:" <<<"$GOAL_CONTENT")
mapfile -t AC_HEADERS < <(grep "^### " <<<"$GOAL_CONTENT")

if [[ ${#CMD_LINES[@]} -eq 0 ]]; then
  echo "ERR: no verification commands found in $GOAL" >&2
  exit 1
fi

if [[ ${#CMD_LINES[@]} -ne ${#AC_HEADERS[@]} ]]; then
  echo "WARN: ${#AC_HEADERS[@]} AC headers vs ${#CMD_LINES[@]} commands — count mismatch" >&2
fi

# --- Dry-run: print plan and exit ---
if [[ $DRY_RUN -eq 1 ]]; then
  echo "DRY-RUN: would execute goal loop with these parameters:"
  echo "  goal:            $GOAL"
  echo "  plan:            $PLAN"
  echo "  max-iter:        $MAX_ITER"
  echo "  max-time (min):  $MAX_TIME"
  echo "  worktree:        ${WORKTREE:-<none>}"
  echo "  files-touched:   ${FILES_TOUCHED:-<all>}"
  echo "  fragile-paths:   $FRAGILE_PATHS"
  echo ""
  echo "Verification commands (${#CMD_LINES[@]}):"
  for i in "${!CMD_LINES[@]}"; do
    HEADER="${AC_HEADERS[$i]:-(no header)}"
    CMD=$(echo "${CMD_LINES[$i]}" | sed 's/^- \*\*Komenda\*\*: //')
    echo "  [$((i+1))] ${HEADER} → ${CMD}"
  done
  echo ""
  echo "DRY-RUN: no execution, no commits."
  exit 0
fi

# --- Live mode: run verification commands once, aggregate, hand off ---
LOG_DIR=$(dirname "$GOAL")
RUN_LOG="${LOG_DIR}/$(basename "$GOAL" -goal-statement.md)-goal-run-log.md"
RESULT="${LOG_DIR}/$(basename "$GOAL" -goal-statement.md)-goal-result.md"

START_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "# Goal Run Log — $(basename "$GOAL")" > "$RUN_LOG"
echo "" >> "$RUN_LOG"
echo "Started: $START_TS" >> "$RUN_LOG"
echo "" >> "$RUN_LOG"

ALL_GREEN=1
FIRST_FAIL_HEADER=""
FIRST_FAIL_CMD=""
FIRST_FAIL_OUT=""

for i in "${!CMD_LINES[@]}"; do
  HEADER="${AC_HEADERS[$i]:-(no header)}"
  CMD=$(echo "${CMD_LINES[$i]}" | sed 's/^- \*\*Komenda\*\*: //' | sed 's/^`//; s/`$//')
  echo "## ${HEADER}" >> "$RUN_LOG"
  echo "Command: \`${CMD}\`" >> "$RUN_LOG"
  echo "" >> "$RUN_LOG"
  echo '```' >> "$RUN_LOG"
  OUT=$(bash -c "$CMD" 2>&1) || true
  RC=$?
  echo "$OUT" >> "$RUN_LOG"
  echo '```' >> "$RUN_LOG"
  echo "Exit code: $RC" >> "$RUN_LOG"
  echo "" >> "$RUN_LOG"

  if [[ $RC -ne 0 && $ALL_GREEN -eq 1 ]]; then
    ALL_GREEN=0
    FIRST_FAIL_HEADER="$HEADER"
    FIRST_FAIL_CMD="$CMD"
    FIRST_FAIL_OUT="$OUT"
  fi
done

END_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [[ $ALL_GREEN -eq 1 ]]; then
  STATUS="GREEN"
else
  STATUS="NEEDS_AGENT_ITERATION"
fi

{
  echo "# Goal Result"
  echo ""
  echo "- **status**: ${STATUS}"
  echo "- **started**: ${START_TS}"
  echo "- **ended**: ${END_TS}"
  echo "- **commands**: ${#CMD_LINES[@]}"
  echo "- **log**: ${RUN_LOG}"
} > "$RESULT"

if [[ $ALL_GREEN -eq 1 ]]; then
  echo "STATUS=GREEN"
  echo "Result: $RESULT"
  exit 0
fi

# --- Hand-off context to calling Claude session ---
echo "STATUS=NEEDS_AGENT_ITERATION"
echo "Result: $RESULT"
echo "Log:    $RUN_LOG"
echo ""
echo "=== HAND-OFF CONTEXT (for calling Claude session) ==="
echo "Focus AC: ${FIRST_FAIL_HEADER}"
echo "Failed command: ${FIRST_FAIL_CMD}"
echo ""
echo "--- Raw output ---"
echo "${FIRST_FAIL_OUT}"
echo "--- End raw output ---"
echo ""
echo "Action required:"
echo "  1. Read failed command + raw output above."
echo "  2. Implement minimal change in code to fix it."
echo "  3. Run Anti-Rationalization quick-check (11 wierszy) before commit."
echo "  4. Verify no Fragile-path or out-of-scope file touched."
echo "  5. git commit atomic."
echo "  6. Re-invoke: bash $0 --goal $GOAL --plan $PLAN"
exit 1
```

- [ ] **Step 4: Make script executable**

Run: `chmod +x dev/feature-planner-v3/scripts/run-goal-loop.sh`

- [ ] **Step 5: Run --dry-run test**

Run:
```bash
bash dev/feature-planner-v3/scripts/run-goal-loop.sh \
  --goal /tmp/goal-test/complete-plan-goal-statement.md \
  --plan dev/feature-planner-v3/tests/fixtures/complete-plan.md \
  --dry-run
```
Expected: exit 0, stdout zawiera `DRY-RUN: would execute goal loop`, lista 6 verification commands (4 AC + BUILD + AC-COVERAGE).

- [ ] **Step 6: Commit**

```bash
git add dev/feature-planner-v3/scripts/run-goal-loop.sh
git commit -m "feat(feature-planner-v3): add run-goal-loop.sh — driver + dry-run + hand-off"
```

---

## Task 5: references/goal-mode-protocol.md

**Files:**
- Create: `dev/feature-planner-v3/references/goal-mode-protocol.md`

- [ ] **Step 1: Write file with 10 sections per spec §6**

Create `dev/feature-planner-v3/references/goal-mode-protocol.md`:

```markdown
# Goal Mode Protocol — feature-planner-v3

> Pełny protokół dla Phase 5.8 + Gate #1.5 + 6-Goal route. Hub-and-spoke: zwięzła wersja w `SKILL.md`, szczegóły tutaj.

## 1. Cel i zakres

`/goal` to autonomiczna pętla wykonawcza driveowana komendami weryfikacyjnymi z tabeli AC Phase 4. Wzorzec: **Stan końcowy + Sposób weryfikacji + Ograniczenia** (źródło: `DOC/goal_mode.md`).

**Używaj gdy:**
- Plan Phase 4 ma kompletną tabelę AC z wykonalną kolumną `Komenda` per wiersz.
- Chcesz overnight run w izolowanym worktree z auto-mode.
- Bramki #2/#3/#4/#5 mają zostać zachowane (Phase 7/8/9 ręczne).

**NIE używaj gdy:**
- AC są subiektywne ("kod jest ładniejszy", "działa szybciej") — bez wymiernego progu.
- Fragile zone aktywna (`migrations/`, `terraform/`, `k8s/`, `auth/`, `.github/workflows/`, `Dockerfile`).
- W tym samym promcie jest `/ralph` lub `/teams` — wybierz jedną strategię.

## 2. Pełna sekwencja Phase 5.8

1. Detekcja triggera (`/goal` lub `goal mode`) w prompcie.
2. Exclusivity guard: `/ralph`, `/teams`, `--fragile` → hard stop z komunikatem.
3. `sh scripts/derive-goal-from-ac.sh --plan "$PLAN_FILE"`.
4. Skrypt waliduje 10 reguł (patrz §3 poniżej). Brak → exit 1 + lista braków.
5. Sukces → 2 outputy: `goal-statement.md` + `goal-prompt.txt`.
6. Przejście do Gate #1.5.

**Recovery:**
- AC brakuje `Komenda` → wróć do Phase 4, uzupełnij, ponów Phase 5.8.
- AC ma interactive REPL w `Komenda` → odrzuć, zamień na non-interactive harness.
- Plan ma `>` zamiast `|` w tabeli → fix syntax, ponów.

## 3. Walidacja AC (10 reguł)

1. Plik planu istnieje i niepusty.
2. Sekcja `## Acceptance Criteria` obecna.
3. Tabela ma nagłówek 6-kolumnowy: `AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda`.
4. Każdy wiersz ma wypełnione 6 kolumn (brak `-`, `TBD`, `TODO`, pusty).
5. AC-ID unikalne, regex `^AC-\d+$`.
6. Typ ∈ {F, N, C}.
7. Plik testu istnieje LUB ma sufiks `.test`/`.spec` (akceptujemy TDD RED).
8. Komenda zaczyna się od `npm|pnpm|yarn|pytest|cargo|go|make|sh|bash|node`.
9. Sekcja `## Out of scope` istnieje, ma ≥1 bullet.
10. Sekcja `## Definition of Done` istnieje z formatem dowodu per AC.

## 4. Format `goal-prompt.txt`

Single block plain text, max 800 znaków:

```
/goal <agregat AC-Opis>. Weryfikacja: <komendy oddzielone średnikiem>; wszystkie exit 0. Ograniczenia: <Out of scope z planu, scope discipline, PR<=1000, brak Fragile zone, max 20 iter, max 480 min>.
```

Przykład 1:1 z `DOC/goal_mode.md`:

```
/goal Wszystkie testy w katalogu tests/auth/ przechodzą. Weryfikacja: npm test -- tests/auth; exit 0. Ograniczenia: nie modyfikuj plików testowych, nie commituj, nie dotykaj plików poza src/auth/.
```

## 5. Gate #1.5 — protokół approval

Po wygenerowaniu `goal-statement.md` skrypt STOP-uje i czeka na jawną zgodę użytkownika.

**Checklist:**
- [ ] `goal-statement.md` niepusty.
- [ ] Trzy sekcje obecne: `## Stan końcowy`, `## Weryfikacja`, `## Ograniczenia`.
- [ ] Każde AC z planu → bullet w `## Stan końcowy` (1:1).
- [ ] Każda `Komenda` z AC → blok w `## Weryfikacja`.
- [ ] `## Out of scope` z planu obecne w `## Ograniczenia`.

**Akceptowane sygnały approval:**
- "zatwierdzam goal" / "proceed goal" / "ok goal" / "approve".
- Ręczna edycja `goal-statement.md` w edytorze + "ok".

**Brak zgody → brak startu 6-Goal.** Eskalacja przy 3 odmowach.

## 6. 6-Goal — kontrakt pętli

Driver: `sh scripts/run-goal-loop.sh`. Skrypt jest walidatorem/orkiestratorem hand-off — calling Claude session woła model.

**Pseudo-kod:**

```
loop:
  1. Uruchom wszystkie cmd z ## Weryfikacja → raw log → append do goal-run-log.md.
  2. Wszystkie exit 0 → STATUS=GREEN, exit 0.
  3. Pierwsze fail (lex po AC-ID) → focus.
  4. No-progress check: error_hash(N) == error_hash(N-1) == error_hash(N-2) → STOP no-progress.
  5. Hand-off do calling Claude (struktura w stdout: focus + cmd + raw output + akcja).
  6. Agent commituje. Pre-commit walidacja:
     - anti-rationalization quick-check (11 wierszy).
     - git diff --name-only HEAD^ ∩ fragile-paths ≠ ∅ → STOP scope-violation.
     - plik ∉ files-touched → STOP scope-violation.
     - check-pr-size.sh > 1000 → STOP pr-too-big.
  7. Inkrementuj iter, sprawdź caps.
```

**Scenariusze stop:**

| Status | Trigger | Działanie |
|---|---|---|
| `GREEN` | wszystkie cmd exit 0 | przejdź do Phase 6.5/7 |
| `iter-cap-hit` | iter > max-iter | raport, brak Phase 7, decyzja user |
| `time-cap-hit` | elapsed > max-time | raport, brak Phase 7, decyzja user |
| `scope-violation` | plik poza files-touched LUB Fragile path | hard stop, eskalacja |
| `no-progress` | 3 iter z tym samym error_hash | hard stop, raport |
| `pr-too-big` | diff > 1000 linii | hard stop, split/justify |

## 7. Anti-Rationalization variant dla goal-mode

Wiersz #11 z głównej tabeli + 3 dodatkowe specyficzne:

| # | Wymówka | Riposta |
|---|---|---|
| 11 | „Goal-statement deryw kompletny, można pominąć Gate #1.5" | Gate #1.5 jest nienegocjowalny. Bez jawnej zgody → brak startu. |
| 12 | „Verification cmd jest flaky, zmień próg" | NIE. Fix flakiness albo stop. Próg pochodzi z DoD, nie z subiektywnej oceny. |
| 13 | „Iter cap blisko, skróć test żeby zmieścić" | NIE. Cap pochodzi z Phase 5.8 approval. Eskalacja, nie skracanie. |
| 14 | „Cap czasu minął ale jestem 1 cmd od zielonego" | NIE. Raport z aktualnym stanem, decyzja user. Brak „jeszcze chwilę". |

## 8. Telemetry kontrakt

**`goal-run-log.md`** (append-only, raw):
- Header: timestamp start, basename goala.
- Per cmd: header (### AC-X — T-Y), `Command:`, fenced raw output, `Exit code:`.

**`goal-result.md`** (final summary):
- `status`: GREEN | iter-cap-hit | time-cap-hit | scope-violation | no-progress | pr-too-big.
- `started`, `ended`.
- `commands`: count.
- `log`: ścieżka do run-log.

**ADR Phase 9 sekcja `Goal-loop telemetry`:**
- status, iter count, czas, no-progress events, scope violations, lista commitów per iter.

## 9. Bezpieczeństwo overnight runs

Pre-flight checklist (Gate #1.5):
- [ ] Worktree aktywny (M+ obligatoryjnie).
- [ ] Auto-mode aktywny (akceptuj narzędzia bez monitów).
- [ ] Brak sekretów w `Komenda` (`grep -E '(password|token|secret|key=)' goal-statement.md` → 0).
- [ ] Brak destruktywnych komend w `## Weryfikacja` (`grep -E '(rm -rf /|drop database|--force)' goal-statement.md` → 0).
- [ ] `files-touched` z planu obecne i nie zawiera Fragile paths.

## 10. Antywzorce

Z `DOC/goal_mode.md`:
- `/goal popraw kod` — niemierzalne.
- `/goal kod jest ładniejszy` — subiektywne.
- `/goal działa szybciej` — bez progu.

Dodatkowe v3:
- Goal-statement bez `## Out of scope` → blokada w Gate #1.5.
- Jeden cmd dla wszystkich AC (np. tylko `npm test` jako globalny harness) → loss of 1:1 mapping AC↔Test. Każdy AC potrzebuje granularnej `Komenda`.
- `--max-iter 0` (unlimited) bez justified flag → ban.
- Verification cmd-y kontaktujące się z siecią/zewnętrznymi API → ban (overnight runs muszą być deterministyczne local-only).
```

- [ ] **Step 2: Verify section count ≥ 10**

Run: `grep -c "^## " dev/feature-planner-v3/references/goal-mode-protocol.md`
Expected: `10` (sekcje 1–10).

- [ ] **Step 3: Commit**

```bash
git add dev/feature-planner-v3/references/goal-mode-protocol.md
git commit -m "docs(feature-planner-v3): add goal-mode-protocol.md (10 sections)"
```

---

## Task 6: SKILL.md — frontmatter (triggers + sources + description)

**Files:**
- Modify: `dev/feature-planner-v3/SKILL.md` (lines 1–26, frontmatter block)

- [ ] **Step 1: Add /goal triggers**

Edit `dev/feature-planner-v3/SKILL.md` — find `trigger:` block (lines 4–10) and add two entries after `"ralph v3"`:

Old:
```yaml
  - "ralph v3"
do-not-trigger-for:
```

New:
```yaml
  - "ralph v3"
  - "/goal"
  - "goal mode"
do-not-trigger-for:
```

- [ ] **Step 2: Add DOC/goal_mode.md to sources**

Edit — find `sources:` block (lines 20–22):

Old:
```yaml
sources:
  - DOC/material_skill.md
  - DOC/since_skill.md
```

New:
```yaml
sources:
  - DOC/material_skill.md
  - DOC/since_skill.md
  - DOC/goal_mode.md
```

- [ ] **Step 3: Extend description**

Edit line 3 (description). Append ` Plus /goal mode auto-derived z AC (Phase 5.8 + 6-Goal route).` na końcu (przed zamykającym cudzysłowem).

- [ ] **Step 4: Verify frontmatter intact**

Run: `head -30 dev/feature-planner-v3/SKILL.md | grep -c "^  - "`
Expected: `>= 13` (6 trigger + 5 do-not-trigger + 3 sources, mniej-więcej).

- [ ] **Step 5: Commit**

```bash
git add dev/feature-planner-v3/SKILL.md
git commit -m "feat(feature-planner-v3): add /goal triggers + DOC/goal_mode.md source"
```

---

## Task 7: SKILL.md — architecture table + Anti-Rationalization #11

**Files:**
- Modify: `dev/feature-planner-v3/SKILL.md` (sekcje „Architektura" i „Anti-Rationalization quick-table")

- [ ] **Step 1: Update architecture table title**

Edit line 61:

Old: `## Architektura: 14 faz + 5 bramek approval`
New: `## Architektura: 15 faz + 6 bramek approval`

- [ ] **Step 2: Insert Phase 5.8 row in architecture table**

Find row `| 5.7 | Ralph-loop decision (opt-in L) | — |` (line ~74). Insert directly after:

```
| 5.8 | Goal Mode decision + auto-derive (tylko /goal) | **APPROVAL #1.5** |
```

- [ ] **Step 3: Insert Anti-Rationalization wiersz #11**

Find Anti-Rationalization table (lines 46–58). After row 10:

```
| 10 | „DRY-uję testy w helper" | DAMP over DRY. Test czytelny jak spec, bez magicznych helperów. |
```

Insert:

```
| 11 | „Goal-statement deryw kompletny, można pominąć Gate #1.5" | Gate #1.5 jest nienegocjowalny w /goal. Bez jawnej zgody → brak startu pętli. |
```

- [ ] **Step 4: Verify changes**

Run: `grep -c "^| 5.8 \|^| 11 " dev/feature-planner-v3/SKILL.md`
Expected: `2`.

- [ ] **Step 5: Commit**

```bash
git add dev/feature-planner-v3/SKILL.md
git commit -m "feat(feature-planner-v3): add Phase 5.8 row + Anti-Rat #11 (goal mode prep)"
```

---

## Task 8: SKILL.md — Phase 5.7 exclusivity note

**Files:**
- Modify: `dev/feature-planner-v3/SKILL.md` (Phase 5.7 section)

- [ ] **Step 1: Find Phase 5.7 section**

Locate sekcję `## Phase 5.7 — Ralph-loop decision` (line ~186).

- [ ] **Step 2: Append exclusivity note**

Po istniejącej regule v3 („Reguła v3: każda iteracja ralph-loop **MUSI**…"), dopisz nowy akapit:

```markdown
> [!warning] Exclusivity z /goal
> `/goal` jest exclusive z `/ralph` i `/teams`. Jeśli w prompcie pojawi się więcej niż jeden z trzech triggerów → Phase 5.8 hard-stopuje. Wybierz jedną strategię pętli.
```

- [ ] **Step 3: Verify**

Run: `grep -A2 "Exclusivity z /goal" dev/feature-planner-v3/SKILL.md`
Expected: bloczek widoczny.

- [ ] **Step 4: Commit**

```bash
git add dev/feature-planner-v3/SKILL.md
git commit -m "feat(feature-planner-v3): note /goal exclusivity in Phase 5.7"
```

---

## Task 9: SKILL.md — Phase 5.8 section

**Files:**
- Modify: `dev/feature-planner-v3/SKILL.md` (insert new section after Phase 5.7, before Phase 6)

- [ ] **Step 1: Locate insertion point**

Find linia tuż przed `## Phase 6 — Implementation + APPROVAL GATE #2` (ok. linia 194).

- [ ] **Step 2: Insert Phase 5.8 section**

Wstaw bezpośrednio przed `## Phase 6 …`:

```markdown
## Phase 5.8 — Goal Mode decision + auto-derive

Aktywuje się **tylko** gdy prompt zawiera `/goal` lub `goal mode`.

**Exclusivity:**
- `/goal` + `/ralph` → hard stop. „Wybierz jedną strategię pętli."
- `/goal` + `/teams` → hard stop. Konflikt modeli wykonawczych.
- `/goal` + `--fragile` (z Phase 0) → hard stop. Fragile zone wymusza Plan-Validate-Execute; autonomia niedozwolona, eskalacja do operatora.

**Goal derivation (deterministyczna):**

1. `sh {baseDir}/dev/feature-planner-v3/scripts/derive-goal-from-ac.sh --plan "$PLAN_FILE"`.
2. Skrypt waliduje 10 reguł (patrz [goal-mode-protocol.md](references/goal-mode-protocol.md) §3).
3. Brak któregokolwiek pola → exit 1 + lista braków + lokalizacje. Faza zatrzymana.
4. Generuje:
   - `plans/<N>-<slug>-goal-statement.md` (markdown, strukturalny).
   - `plans/<N>-<slug>-goal-prompt.txt` (plain text, single block).

> [!warning] Output Phase 5.8
> `goal-statement.md` + `goal-prompt.txt`. Komunikat: „Goal-statement wygenerowany. Czekam na APPROVAL #1.5."

### Gate #1.5 — Goal Approval

> [!important] Approval checklist
> - [ ] `goal-statement.md` niepusty (`test -s`).
> - [ ] Trzy sekcje: `## Stan końcowy`, `## Weryfikacja`, `## Ograniczenia`.
> - [ ] Każde AC z planu → bullet w `## Stan końcowy` (1:1).
> - [ ] Każda `Komenda` z AC → blok w `## Weryfikacja`.
> - [ ] `## Out of scope` z planu obecne w `## Ograniczenia`.
>
> **STOP — czekaj na jawną zgodę użytkownika.** Bez „zatwierdzam goal" / „proceed goal" / ręcznej edycji + „ok" → brak startu 6-Goal.

---
```

- [ ] **Step 3: Verify insertion**

Run: `grep -c "## Phase 5.8 — Goal Mode\|### Gate #1.5 — Goal Approval" dev/feature-planner-v3/SKILL.md`
Expected: `2`.

- [ ] **Step 4: Verify line count under 500**

Run: `wc -l dev/feature-planner-v3/SKILL.md`
Expected: `<= 500`.

- [ ] **Step 5: Commit**

```bash
git add dev/feature-planner-v3/SKILL.md
git commit -m "feat(feature-planner-v3): add Phase 5.8 + Gate #1.5 (Goal Mode decision)"
```

---

## Task 10: SKILL.md — 6-Goal sub-route in Phase 6

**Files:**
- Modify: `dev/feature-planner-v3/SKILL.md` (Phase 6 routing list + new sub-route)

- [ ] **Step 1: Update routing list in Phase 6**

Find linie 196–199:

Old:
```
Routing implementacji:
- **6-Sequential** — domyślnie dla S/M.
- **6-Teams** (2-5 agentów) — dla L gdy parallel safe.
- **6-Ralph** — autonomous L z zielonym test gate.
```

New:
```
Routing implementacji:
- **6-Sequential** — domyślnie dla S/M.
- **6-Teams** (2-5 agentów) — dla L gdy parallel safe.
- **6-Ralph** — autonomous L z zielonym test gate.
- **6-Goal** — autonomous goal-driven loop (tylko gdy `/goal`, exclusive z Ralph/Teams).
```

- [ ] **Step 2: Insert 6-Goal sub-route block**

Tuż przed `> [!danger] Jeśli --fragile` (ok. linia 218), wstaw:

```markdown
### 6-Goal — autonomous goal-driven loop

Pre-flight: APPROVAL #1.5 ✅, `git status` clean, build baseline.

Driver: `sh {baseDir}/dev/feature-planner-v3/scripts/run-goal-loop.sh --goal "$GOAL_FILE" --plan "$PLAN_FILE" --max-iter 20 --max-time 480`.

Per iteracja:

1. Uruchom wszystkie `## Weryfikacja` cmd-y → raw log do `goal-run-log.md`.
2. Wszystkie exit 0 → **GREEN**, exit pętli, Phase 6.5/7.
3. Pierwsze fail (lex po AC-ID) → kontekst do next iter (hand-off do calling agenta).
4. **Anti-Rationalization quick-check** (11 wierszy) przed każdym commitem.
5. **PR Sizing + Fragile guard + Out-of-scope guard** → STOP przy violation.

Stop warunki (poza GREEN):
- `iter > max-iter` → status `iter-cap-hit`.
- `elapsed > max-time` → status `time-cap-hit`.
- Fragile/scope violation → status `scope-violation`.
- 3 iter bez progresu (ten sam error_hash) → status `no-progress`.

Każdy stop ≠ GREEN: raport do użytkownika, **brak Phase 7**, brak merge.

```

- [ ] **Step 3: Verify**

Run: `grep -c "### 6-Goal\|6-Goal — autonomous" dev/feature-planner-v3/SKILL.md`
Expected: `>= 1`.

Run: `wc -l dev/feature-planner-v3/SKILL.md`
Expected: `<= 500`.

- [ ] **Step 4: Commit**

```bash
git add dev/feature-planner-v3/SKILL.md
git commit -m "feat(feature-planner-v3): add 6-Goal sub-route in Phase 6"
```

---

## Task 11: SKILL.md — Indeks referencji + Sources

**Files:**
- Modify: `dev/feature-planner-v3/SKILL.md` (sekcja „Indeks referencji" i „Sources")

- [ ] **Step 1: Add entry in „Protokoły projektowe (warstwa B)"**

Find linia `- [gotchas.md](references/gotchas.md) — auto-populating projektowych anomalii.` (ok. linia 324).

Insert before it (or after, byle w bloku „warstwa B"):

```
- [goal-mode-protocol.md](references/goal-mode-protocol.md) — Phase 5.8 + 6-Goal + Gate #1.5 protokół.
```

- [ ] **Step 2: Add scripts in „Skrypty (warstwa B)"**

Find blok skryptów (ok. linia 328-332). Po `- scripts/api-impact-scan.sh — Hyrum risk scan.` dopisz:

```
- `scripts/derive-goal-from-ac.sh` — AC → goal-statement.md generator.
- `scripts/run-goal-loop.sh` — autonomous goal-driven loop driver.
```

- [ ] **Step 3: Add DOC/goal_mode.md in „Sources"**

Find sekcję `## Sources` (ok. linia 340). Po dwóch istniejących bullet-ach (material_skill.md, since_skill.md, v2 SKILL.md), dopisz:

```
- [DOC/goal_mode.md](../../DOC/goal_mode.md) — pattern „stan końcowy + weryfikacja + ograniczenia", przykłady, antywzorce.
```

- [ ] **Step 4: Final size check**

Run: `wc -l dev/feature-planner-v3/SKILL.md`
Expected: `<= 500` (target ~414).

- [ ] **Step 5: Commit**

```bash
git add dev/feature-planner-v3/SKILL.md
git commit -m "docs(feature-planner-v3): index goal-mode-protocol + scripts + source"
```

---

## Task 12: DOC/goal_mode.md — backlink

**Files:**
- Modify: `DOC/goal_mode.md` (append 1 line at EOF)

- [ ] **Step 1: Append backlink**

Po ostatnim akapicie pliku dopisz 2 linie (pusta + link):

```

> Pełna integracja z feature-planner-v3: [dev/feature-planner-v3/references/goal-mode-protocol.md](../dev/feature-planner-v3/references/goal-mode-protocol.md).
```

- [ ] **Step 2: Verify**

Run: `tail -3 DOC/goal_mode.md`
Expected: blockquote z linkiem widoczny.

- [ ] **Step 3: Commit**

```bash
git add DOC/goal_mode.md
git commit -m "docs(goal-mode): backlink do feature-planner-v3 protocol"
```

---

## Task 13: Final verification — wszystkie 8 spec AC

**Files:** read-only verification, no modifications.

- [ ] **Step 1: AC-1 — Phase 5.8 i Gate #1.5 w SKILL.md**

Run: `grep -c "Phase 5.8\|Gate #1.5" dev/feature-planner-v3/SKILL.md`
Expected: `>= 2`.

- [ ] **Step 2: AC-2 — 500-line hard limit**

Run: `wc -l < dev/feature-planner-v3/SKILL.md`
Expected: `<= 500`.

- [ ] **Step 3: AC-3 — derive-goal hard-stop**

Run:
```bash
bash dev/feature-planner-v3/scripts/derive-goal-from-ac.sh \
  --plan dev/feature-planner-v3/tests/fixtures/incomplete-plan.md \
  --out-dir /tmp/ac3-test 2>/dev/null
echo "exit=$?"
```
Expected: `exit=1`.

- [ ] **Step 4: AC-4 — derive-goal happy path**

Run:
```bash
rm -rf /tmp/ac4 && mkdir -p /tmp/ac4
bash dev/feature-planner-v3/scripts/derive-goal-from-ac.sh \
  --plan dev/feature-planner-v3/tests/fixtures/complete-plan.md \
  --out-dir /tmp/ac4
test -s /tmp/ac4/complete-plan-goal-statement.md && echo OK
```
Expected: `OK`.

- [ ] **Step 5: AC-5 — run-goal-loop dry-run**

Run:
```bash
bash dev/feature-planner-v3/scripts/run-goal-loop.sh \
  --goal /tmp/ac4/complete-plan-goal-statement.md \
  --plan dev/feature-planner-v3/tests/fixtures/complete-plan.md \
  --dry-run | grep -q "DRY-RUN" && echo OK
```
Expected: `OK`.

- [ ] **Step 6: AC-6 — /goal + /ralph hard stop rule w SKILL.md**

Run: `grep -qE "exclusive z /ralph i /teams|/goal.*ralph.*hard stop" dev/feature-planner-v3/SKILL.md && echo OK`
Expected: `OK`.

- [ ] **Step 7: AC-7 — fragile hard stop rule w SKILL.md**

Run: `grep -qE "fragile.*hard stop|--fragile.*niedozwolony" dev/feature-planner-v3/SKILL.md && echo OK`
Expected: `OK`.

- [ ] **Step 8: AC-8 — goal-mode-protocol.md ma >= 10 sekcji**

Run: `[ $(grep -c "^## " dev/feature-planner-v3/references/goal-mode-protocol.md) -ge 10 ] && echo OK`
Expected: `OK`.

- [ ] **Step 9: Aggregate result**

If wszystkie 8 sprawdzeń zwróciły `OK` / oczekiwany exit / oczekiwaną wartość → implementation DONE.

Otherwise: zidentyfikuj failing AC, wróć do odpowiedniego Task, fix, ponów Task 13.

- [ ] **Step 10: Final commit (tag)**

```bash
git tag -a v3.1-goal-mode -m "feature-planner-v3: /goal mode (Phase 5.8 + 6-Goal route + Gate #1.5)"
```

(Tag tylko jeśli wszystkie AC zielone. Brak push do remote — manual.)

---

## Self-Review

**Spec coverage:**
- Frontmatter (spec §3.1) → Task 6 ✅
- Architecture table (§3.2) → Task 7 ✅
- Anti-Rat #11 (§3.3) → Task 7 ✅
- Phase 5.7 nota (§3.4) → Task 8 ✅
- Phase 5.8 + Gate #1.5 (§3.5) → Task 9 ✅
- 6-Goal sub-route (§3.6) → Task 10 ✅
- Indeks + Sources (§3.7) → Task 11 ✅
- `goal-statement.md` format (§4) → Task 2 (script generuje) ✅
- `derive-goal-from-ac.sh` kontrakt (§5.1) → Task 2 + Task 3 ✅
- `run-goal-loop.sh` kontrakt (§5.2) → Task 4 ✅
- `goal-mode-protocol.md` 10 sekcji (§6) → Task 5 ✅
- Composability matrix (§7) → w Task 5 sekcja 1 + w SKILL.md Phase 5.7/5.8 ✅
- Niezmiennice (§8) → nie wymaga osobnej akcji, wynikają z dziedziczenia faz ✅
- Token budget (§9) → Task 9 + Task 10 + Task 13 walidują ✅
- Fixtures (§10) → Task 1 ✅
- Spec AC (§11) → Task 13 ✅
- DOC/goal_mode.md backlink → Task 12 ✅

Brak luk.

**Placeholder scan:**
- Wszystkie kroki mają konkretne ścieżki plików, exact commands, oczekiwane outputy.
- Brak „TBD", „TODO", „fill in details", „add error handling", „similar to Task N".
- Code w bash i markdown — pełne snippety, nie szkice.

**Type consistency:**
- `goal-statement.md` / `goal-prompt.txt` / `goal-run-log.md` / `goal-result.md` używane konsekwentnie.
- `derive-goal-from-ac.sh` / `run-goal-loop.sh` ścieżki konsekwentnie pod `dev/feature-planner-v3/scripts/`.
- Argumenty CLI (`--plan`, `--goal`, `--out-dir`, `--dry-run`) używane spójnie między scriptami i taskami.
- Tabela AC w fixtures ma 6 kolumn — spójna z walidacją w skrypcie i z formatem oczekiwanym przez SKILL.md Phase 4.

Plan kompletny i spójny.

---

## Execution Handoff

**Plan complete and saved to `docs/superpowers/plans/2026-05-13-feature-planner-v3-goal-mode.md`. Two execution options:**

**1. Subagent-Driven (recommended)** — dispatch fresh subagent per task, two-stage review między taskami.

**2. Inline Execution** — execute w bieżącej sesji z `executing-plans`, batch execution z checkpoints.

**Which approach?**
