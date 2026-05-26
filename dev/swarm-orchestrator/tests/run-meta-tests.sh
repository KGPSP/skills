#!/bin/sh
# run-meta-tests.sh — uruchamia wszystkie meta-testy walidatorów swarm-orchestrator.
# Wzorzec z dev/agent-teams-builder/tests/run-meta-tests.sh.
#
# Usage:
#   sh tests/run-meta-tests.sh           # wszystkie grupy
#   sh tests/run-meta-tests.sh syntax    # tylko syntax checks
#   sh tests/run-meta-tests.sh fixtures  # tylko fixtures (good/bad PRD)
#
# Exit: 0 wszystkie passed, 1 jakikolwiek FAIL.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SKILL_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
GROUP="${1:-all}"

PASS=0
FAIL=0
FAIL_NAMES=""

run_test() {
  NAME="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    PASS=$((PASS + 1))
    printf '  [PASS] %s\n' "$NAME"
  else
    RC=$?
    FAIL=$((FAIL + 1))
    FAIL_NAMES="$FAIL_NAMES $NAME(rc=$RC)"
    printf '  [FAIL] %s (rc=%s)\n' "$NAME" "$RC"
  fi
}

# --- Group: syntax ---
if [ "$GROUP" = "all" ] || [ "$GROUP" = "syntax" ]; then
  echo "=== Syntax (sh -n / bash -n per shebang) ==="
  for f in "$SKILL_ROOT/scripts/"*.sh "$SKILL_ROOT/scripts/lib/"*.sh; do
    SHEBANG=$(head -1 "$f")
    case "$SHEBANG" in
      *bash*)
        run_test "bash-n: $(basename "$f")" bash -n "$f"
        ;;
      *)
        run_test "sh-n: $(basename "$f")" sh -n "$f"
        ;;
    esac
  done
fi

# --- Group: fixtures (PRD walidacja) ---
if [ "$GROUP" = "all" ] || [ "$GROUP" = "fixtures" ]; then
  echo ""
  echo "=== Fixtures (PRD validation) ==="

  # GOOD: good-prd-minimal.md powinien mieć ≥1 AC z Komenda
  GOOD_AC_COUNT=$(grep -c '^| AC-' "$SCRIPT_DIR/fixtures/good-prd-minimal.md" 2>/dev/null || echo 0)
  if [ "$GOOD_AC_COUNT" -ge 1 ]; then
    PASS=$((PASS + 1))
    printf '  [PASS] good-prd-minimal has %d AC rows\n' "$GOOD_AC_COUNT"
  else
    FAIL=$((FAIL + 1))
    FAIL_NAMES="$FAIL_NAMES good-prd-minimal-ac-count"
    printf '  [FAIL] good-prd-minimal has 0 AC rows (expected >=1)\n'
  fi

  # GOOD: good-prd-minimal frontmatter ma paths-in-scope
  if grep -q '^paths-in-scope:' "$SCRIPT_DIR/fixtures/good-prd-minimal.md"; then
    PASS=$((PASS + 1))
    printf '  [PASS] good-prd-minimal has paths-in-scope frontmatter\n'
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] good-prd-minimal missing paths-in-scope\n'
  fi

  # BAD: bad-prd-no-ac NIE powinien mieć tabeli AC
  if ! grep -q '^| AC-' "$SCRIPT_DIR/fixtures/bad-prd-no-ac.md"; then
    PASS=$((PASS + 1))
    printf '  [PASS] bad-prd-no-ac correctly lacks AC table\n'
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] bad-prd-no-ac unexpectedly has AC table\n'
  fi

  # BAD: bad-prd-subjective ma "ładniej" lub "czystszy" (subjective markers)
  if grep -qE '(ładniej|czystszy|ładny|brzydki)' "$SCRIPT_DIR/fixtures/bad-prd-subjective.md"; then
    PASS=$((PASS + 1))
    printf '  [PASS] bad-prd-subjective has subjective markers\n'
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] bad-prd-subjective missing subjective markers\n'
  fi

  # BAD: bad-prd-fragile ma migrations/ lub terraform/ w paths-in-scope
  if grep -qE '(migrations/|terraform/|k8s/|auth/)' "$SCRIPT_DIR/fixtures/bad-prd-fragile.md"; then
    PASS=$((PASS + 1))
    printf '  [PASS] bad-prd-fragile has Fragile zone in paths-in-scope\n'
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] bad-prd-fragile missing Fragile paths\n'
  fi
fi

# --- Group: structure (skill layout) ---
if [ "$GROUP" = "all" ] || [ "$GROUP" = "structure" ]; then
  echo ""
  echo "=== Structure (skill layout) ==="

  # SKILL.md istnieje + ≤500 linii
  if [ -f "$SKILL_ROOT/SKILL.md" ]; then
    LINES=$(wc -l < "$SKILL_ROOT/SKILL.md" | tr -d ' ')
    if [ "$LINES" -le 500 ]; then
      PASS=$((PASS + 1))
      printf '  [PASS] SKILL.md exists, %d lines (limit 500)\n' "$LINES"
    else
      FAIL=$((FAIL + 1))
      printf '  [FAIL] SKILL.md %d lines (over 500 limit)\n' "$LINES"
    fi
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] SKILL.md missing\n'
  fi

  # 10 references obecne
  REF_COUNT=$(ls -1 "$SKILL_ROOT/references/" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$REF_COUNT" -ge 10 ]; then
    PASS=$((PASS + 1))
    printf '  [PASS] references/ has %d files (expected >=10)\n' "$REF_COUNT"
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] references/ has only %d files (expected >=10)\n' "$REF_COUNT"
  fi

  # 4 agentów swarm-*.md
  AGENT_COUNT=$(ls -1 "$SKILL_ROOT/agents/swarm-"*.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$AGENT_COUNT" -eq 4 ]; then
    PASS=$((PASS + 1))
    printf '  [PASS] agents/ has 4 swarm-*.md\n'
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] agents/ has %d swarm-*.md (expected 4)\n' "$AGENT_COUNT"
  fi

  # 10 promptów (4 boot + 5 phase + 1 yolo-iterate)
  PROMPT_COUNT=$(ls -1 "$SKILL_ROOT/prompts/" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$PROMPT_COUNT" -ge 10 ]; then
    PASS=$((PASS + 1))
    printf '  [PASS] prompts/ has %d files (expected >=10)\n' "$PROMPT_COUNT"
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] prompts/ has only %d files (expected >=10)\n' "$PROMPT_COUNT"
  fi

  # frontmatter SKILL.md ma name, description, trigger, do-not-trigger-for, model, version
  for field in 'name:' 'description:' 'trigger:' 'do-not-trigger-for:' 'model:' 'version:' 'sources:' 'size-limit:'; do
    if grep -q "^$field" "$SKILL_ROOT/SKILL.md"; then
      PASS=$((PASS + 1))
      printf '  [PASS] frontmatter contains %s\n' "$field"
    else
      FAIL=$((FAIL + 1))
      printf '  [FAIL] frontmatter missing %s\n' "$field"
    fi
  done
fi

# --- Group: scripts-exec (executable bit) ---
if [ "$GROUP" = "all" ] || [ "$GROUP" = "scripts-exec" ]; then
  echo ""
  echo "=== Scripts executable bit ==="
  NON_EXEC=$(find "$SKILL_ROOT/scripts" -name '*.sh' ! -perm -u+x 2>/dev/null | wc -l | tr -d ' ')
  if [ "$NON_EXEC" -eq 0 ]; then
    PASS=$((PASS + 1))
    printf '  [PASS] all scripts have +x bit\n'
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] %d scripts lack +x bit\n' "$NON_EXEC"
    find "$SKILL_ROOT/scripts" -name '*.sh' ! -perm -u+x 2>/dev/null
  fi
fi

# --- Group: error-hash ---
if [ "$GROUP" = "all" ] || [ "$GROUP" = "error-hash" ]; then
  echo ""
  echo "=== error-hash.sh logic ==="

  TMP_LOG=$(mktemp)
  trap 'rm -f "$TMP_LOG"' EXIT

  # Bez błędów → "no-errors"
  echo "OK output" > "$TMP_LOG"
  RES=$("$SKILL_ROOT/scripts/error-hash.sh" "$TMP_LOG" 2>/dev/null || echo "ERR")
  if [ "$RES" = "no-errors" ]; then
    PASS=$((PASS + 1))
    printf '  [PASS] no-error log returns "no-errors"\n'
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] no-error log returned: %s (expected "no-errors")\n' "$RES"
  fi

  # Z błędem → 8-char hash
  echo "Error: something failed" > "$TMP_LOG"
  RES=$("$SKILL_ROOT/scripts/error-hash.sh" "$TMP_LOG" 2>/dev/null || echo "ERR")
  if [ "${#RES}" -eq 8 ]; then
    PASS=$((PASS + 1))
    printf '  [PASS] error log returns 8-char hash: %s\n' "$RES"
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] error log returned: %s (expected 8 chars)\n' "$RES"
  fi

  # Ten sam błąd 2× → ten sam hash
  H1=$("$SKILL_ROOT/scripts/error-hash.sh" "$TMP_LOG" 2>/dev/null)
  H2=$("$SKILL_ROOT/scripts/error-hash.sh" "$TMP_LOG" 2>/dev/null)
  if [ "$H1" = "$H2" ]; then
    PASS=$((PASS + 1))
    printf '  [PASS] same error → same hash (idempotent)\n'
  else
    FAIL=$((FAIL + 1))
    printf '  [FAIL] same error → different hash (%s vs %s)\n' "$H1" "$H2"
  fi
fi

# --- Summary ---
echo ""
TOTAL=$((PASS + FAIL))
if [ "$FAIL" -eq 0 ]; then
  printf '✔ %d/%d passed\n' "$PASS" "$TOTAL"
  exit 0
else
  printf '✗ %d/%d passed, %d failed:%s\n' "$PASS" "$TOTAL" "$FAIL" "$FAIL_NAMES"
  exit 1
fi
