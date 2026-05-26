#!/bin/sh
# verify-postgres-strategy.sh — anti-mock gate dla warstwy SQL.
# Skanuje qa-blueprint/{samples,configs}/ pod kątem wzorców mockowania Postgres.
# Exit 0 = czyste (no anti-pattern), 1 = znaleziono anti-pattern.
#
# Usage:
#   sh verify-postgres-strategy.sh [blueprintDir]

set -eu

blueprint_dir="${1:-./qa-blueprint}"

if [ ! -d "$blueprint_dir" ]; then
    echo "ERROR: blueprintDir not a directory: $blueprint_dir" >&2
    exit 1
fi

scan_dirs=""
[ -d "$blueprint_dir/samples" ] && scan_dirs="$scan_dirs $blueprint_dir/samples"
[ -d "$blueprint_dir/configs" ] && scan_dirs="$scan_dirs $blueprint_dir/configs"

if [ -z "$scan_dirs" ]; then
    echo "WARN: no samples/ or configs/ to scan in $blueprint_dir"
    exit 0
fi

echo "Scanning for Postgres mocking anti-patterns:"
echo "  Node:    jest.mock\\(.*pg, vi.mock\\(.*pg, vi.mock\\(.*postgres"
echo "  Node:    pg-mem, pg-memory, pg-ish"
echo "  Python:  monkeypatch.setattr.*psycopg, mock.patch.*psycopg, mock.patch.*asyncpg"
echo "  Go:      DATA-DOG/go-sqlmock without testcontainers in same file"
echo "  Generic: in-memory-pg, mock-postgres"
echo ""

# Collect files
files=$(find $scan_dirs -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" \) 2>/dev/null)
file_count=$(echo "$files" | grep -c . || true)

echo "Files scanned: $file_count"
echo ""

violations=0

scan_pattern() {
    pattern="$1"
    label="$2"
    matches=$(echo "$files" | xargs -I {} grep -l -E "$pattern" {} 2>/dev/null || true)
    if [ -n "$matches" ]; then
        echo "[VIOLATION] $label"
        echo "$matches" | sed 's/^/  - /'
        violations=$((violations + 1))
    fi
}

# Node
scan_pattern "jest\.mock\(['\"]pg['\"]" "jest.mock('pg') — Node anti-pattern"
scan_pattern "vi\.mock\(['\"]pg['\"]" "vi.mock('pg') — Node anti-pattern"
scan_pattern "vi\.mock\(['\"]postgres['\"]" "vi.mock('postgres') — Node anti-pattern"
scan_pattern "from ['\"]pg-mem['\"]" "import from pg-mem — Node anti-pattern"
scan_pattern "require\(['\"]pg-mem['\"]\)" "require('pg-mem') — Node anti-pattern"
scan_pattern "pg-memory" "pg-memory mention"

# Python
scan_pattern "monkeypatch\.setattr.*psycopg" "monkeypatch.setattr psycopg — Python anti-pattern"
scan_pattern "mock\.patch.*psycopg" "mock.patch psycopg — Python anti-pattern"
scan_pattern "mock\.patch.*asyncpg" "mock.patch asyncpg — Python anti-pattern"

# Go (sqlmock w pliku który nie ma testcontainers)
sqlmock_files=$(echo "$files" | xargs -I {} grep -l "DATA-DOG/go-sqlmock\|github.com/DATA-DOG/go-sqlmock" {} 2>/dev/null || true)
if [ -n "$sqlmock_files" ]; then
    for f in $sqlmock_files; do
        if ! grep -q "testcontainers" "$f" 2>/dev/null; then
            echo "[VIOLATION] go-sqlmock without testcontainers in: $f"
            violations=$((violations + 1))
        fi
    done
fi

# Generic
scan_pattern "in-memory-pg" "in-memory-pg mention"
scan_pattern "mock-postgres" "mock-postgres mention"

echo ""
if [ "$violations" -eq 0 ]; then
    echo "[CLEAN] No Postgres mocking anti-patterns found ($file_count files scanned)"
    exit 0
else
    echo "[FAIL] $violations anti-pattern violations found"
    echo "See references/layer-strategy.md §3 — Modyfikacja 2 (Testcontainers obowiązkowy dla SQL)"
    exit 1
fi
