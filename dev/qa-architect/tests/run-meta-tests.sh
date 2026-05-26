#!/bin/sh
# run-meta-tests.sh — meta-tests for qa-architect scripts.
# Beyoncé Rule: każdy walidator ma fixtures + assert.
#
# Tests:
#   detect-stack.sh             on GOOD/nextjs-detect, GOOD/python-detect, GOOD/go-detect, BAD/unknown-stack
#   check-blueprint-complete.sh on GOOD/complete-blueprint, BAD/incomplete-blueprint
#   verify-postgres-strategy.sh on GOOD/complete-blueprint, BAD/postgres-mocked
#
# Usage: sh tests/run-meta-tests.sh
#
# NOTE: `set -u` (bez `-e`) celowe — assert_exit testuje też non-zero exit codes
# (np. exit 1 dla BAD fixtures, exit 2 dla unknown-stack). `set -e` przerywałby
# skrypt przy każdym oczekiwanym niepowodzeniu komendy w command substitution
# `actual_out=$("$@" 2>&1)`. Bezpieczeństwo: każda komenda jest opakowana w
# assert_exit/assert_contains, więc fail jest jawnie zliczany w $failed.

set -u

dir="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$dir/.." && pwd)"

passed=0
failed=0

# helper: run cmd, compare exit code, log result
assert_exit() {
    label="$1"; expected="$2"; shift 2
    actual_out=$("$@" 2>&1)
    actual_rc=$?
    if [ "$actual_rc" -eq "$expected" ]; then
        echo "[PASS] $label (exit=$actual_rc as expected)"
        passed=$((passed + 1))
    else
        echo "[FAIL] $label (expected exit=$expected, got=$actual_rc)"
        echo "       cmd: $*"
        echo "       output:"
        echo "$actual_out" | sed 's/^/         /'
        failed=$((failed + 1))
    fi
}

# helper: run cmd, check stdout contains substring
assert_contains() {
    label="$1"; needle="$2"; shift 2
    out=$("$@" 2>&1 || true)
    if printf '%s' "$out" | grep -q -F "$needle"; then
        echo "[PASS] $label (output contains '$needle')"
        passed=$((passed + 1))
    else
        echo "[FAIL] $label (output missing '$needle')"
        echo "       cmd: $*"
        echo "       output:"
        echo "$out" | sed 's/^/         /'
        failed=$((failed + 1))
    fi
}

echo "=== detect-stack.sh ==="
assert_exit "detect-stack on GOOD/nextjs-detect (exit 0)" 0 \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/GOOD/nextjs-detect"
assert_contains "detect-stack on GOOD/nextjs-detect says stack=nextjs" '"stack":"nextjs"' \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/GOOD/nextjs-detect"
assert_contains "detect-stack on GOOD/nextjs-detect says db_driver=pg" '"db_driver":"pg"' \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/GOOD/nextjs-detect"

assert_exit "detect-stack on GOOD/python-detect (exit 0)" 0 \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/GOOD/python-detect"
assert_contains "detect-stack on GOOD/python-detect says stack=python" '"stack":"python"' \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/GOOD/python-detect"
assert_contains "detect-stack on GOOD/python-detect says db_driver=asyncpg" '"db_driver":"asyncpg"' \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/GOOD/python-detect"

assert_exit "detect-stack on GOOD/go-detect (exit 0)" 0 \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/GOOD/go-detect"
assert_contains "detect-stack on GOOD/go-detect says stack=go" '"stack":"go"' \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/GOOD/go-detect"
assert_contains "detect-stack on GOOD/go-detect says db_driver=pgx" '"db_driver":"pgx"' \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/GOOD/go-detect"

assert_exit "detect-stack on BAD/unknown-stack (exit 2 = stack unknown)" 2 \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/BAD/unknown-stack"

assert_exit "detect-stack on BAD/monorepo-detect (exit 3 = monorepo)" 3 \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/BAD/monorepo-detect"
assert_contains "detect-stack on BAD/monorepo-detect says stack=monorepo" '"stack":"monorepo"' \
    sh "$root/scripts/detect-stack.sh" "$dir/fixtures/BAD/monorepo-detect"

echo ""
echo "=== check-blueprint-complete.sh ==="
assert_exit "check-blueprint on GOOD/complete-blueprint (exit 0)" 0 \
    sh "$root/scripts/check-blueprint-complete.sh" "$dir/fixtures/GOOD/complete-blueprint/qa-blueprint"
assert_exit "check-blueprint on BAD/incomplete-blueprint (exit 1)" 1 \
    sh "$root/scripts/check-blueprint-complete.sh" "$dir/fixtures/BAD/incomplete-blueprint/qa-blueprint"
assert_contains "check-blueprint on BAD reports MISSING" "MISSING" \
    sh "$root/scripts/check-blueprint-complete.sh" "$dir/fixtures/BAD/incomplete-blueprint/qa-blueprint"

echo ""
echo "=== verify-postgres-strategy.sh ==="
assert_exit "verify-pg on GOOD/complete-blueprint (exit 0 — CLEAN)" 0 \
    sh "$root/scripts/verify-postgres-strategy.sh" "$dir/fixtures/GOOD/complete-blueprint/qa-blueprint"
assert_exit "verify-pg on BAD/postgres-mocked (exit 1 — violation)" 1 \
    sh "$root/scripts/verify-postgres-strategy.sh" "$dir/fixtures/BAD/postgres-mocked/qa-blueprint"
assert_contains "verify-pg on BAD reports VIOLATION" "VIOLATION" \
    sh "$root/scripts/verify-postgres-strategy.sh" "$dir/fixtures/BAD/postgres-mocked/qa-blueprint"

echo ""
echo "================================"
total=$((passed + failed))
echo "Result: $passed/$total passed, $failed failed"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
