#!/bin/sh
# check-blueprint-complete.sh — DoD gate dla qa-architect Phase 7.
# Sprawdza obecność wszystkich wymaganych plików w qa-blueprint/.
# Exit 0 = wszystkie obecne, 1 = brak któregokolwiek (lista wypisana).
#
# Usage:
#   sh check-blueprint-complete.sh [blueprintDir]
#   blueprintDir default: ./qa-blueprint

set -eu

blueprint_dir="${1:-./qa-blueprint}"

if [ ! -d "$blueprint_dir" ]; then
    echo "ERROR: blueprintDir not a directory: $blueprint_dir" >&2
    exit 1
fi

# Required files — markdowns + minimum samples + configs + ci
required_md="00-environment.md
01-discovery.md
02-tooling.md
03-layer-strategy.md
04-swarm-plan.md
qa-strategy.md
CLAUDE.md.patch
AGENTS.md
checklists.md
pilot-4-weeks.md
07-verification.md
07-review.md
HANDOFF.md"

# verify-tests skill (nested path)
required_skills=".claude/skills/verify-tests/SKILL.md"

# Configs — at least one of these per stack (we don't know stack here, so check 'any')
optional_configs="configs/vitest.config.ts
configs/jest.config.ts
configs/playwright.config.ts
configs/pytest.ini
configs/conftest.py
configs/docker-compose.test.yml"

# Samples — at least one of these
optional_samples="samples/unit.test.tsx
samples/unit.test.ts
samples/unit_test.py
samples/unit_test.go
samples/integration-http.test.ts
samples/integration_http_test.py
samples/integration_http_test.go
samples/integration-db.int.test.ts
samples/integration_db_test.py
samples/integration_db_test.go
samples/e2e.spec.ts
samples/e2e_test.py"

# CI — all 3 required
required_ci="ci/pr.yml
ci/nightly.yml
ci/prerelease.yml"

missing=0
present=0
total=0

check_file() {
    total=$((total + 1))
    if [ -f "$blueprint_dir/$1" ]; then
        echo "[OK] $1"
        present=$((present + 1))
    else
        echo "[MISSING] $1"
        missing=$((missing + 1))
    fi
}

check_any_of() {
    # $1 = description, $2..N = candidates
    desc="$1"
    shift
    total=$((total + 1))
    found=0
    for f in "$@"; do
        if [ -f "$blueprint_dir/$f" ]; then
            echo "[OK] $f (matches $desc)"
            present=$((present + 1))
            found=1
            break
        fi
    done
    if [ "$found" -eq 0 ]; then
        echo "[MISSING] none of: $* ($desc)"
        missing=$((missing + 1))
    fi
}

echo "=== Required markdown documents ==="
for f in $required_md; do
    check_file "$f"
done

echo ""
echo "=== Required skills ==="
for f in $required_skills; do
    check_file "$f"
done

echo ""
echo "=== Required CI workflows ==="
for f in $required_ci; do
    check_file "$f"
done

echo ""
echo "=== At least one config per category ==="
check_any_of "unit/component config" \
    configs/vitest.config.ts configs/jest.config.ts \
    configs/pytest.ini configs/conftest.py \
    configs/go-test-deps.txt
check_any_of "docker-compose.test.yml" configs/docker-compose.test.yml

echo ""
echo "=== At least one sample per warstwa ==="
check_any_of "sample unit" \
    samples/unit.test.tsx samples/unit.test.ts \
    samples/unit_test.py samples/unit_test.go
check_any_of "sample integration-http" \
    samples/integration-http.test.ts samples/integration-http.test.tsx \
    samples/integration_http_test.py samples/integration_http_test.go
check_any_of "sample integration-db" \
    samples/integration-db.int.test.ts samples/integration-db.test.ts \
    samples/integration_db_test.py samples/integration_db_test.go
check_any_of "sample e2e (optional — N/A dla backend-only)" \
    samples/e2e.spec.ts samples/e2e_test.py samples/e2e_test.go

echo ""
echo "Result: $present/$total files present, $missing missing"

if [ "$missing" -gt 0 ]; then
    exit 1
fi
exit 0
