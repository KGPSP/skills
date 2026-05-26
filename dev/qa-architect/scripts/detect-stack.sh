#!/bin/sh
# detect-stack.sh — deterministyczna detekcja stacku dla qa-architect Phase 0.
# Output: pojedynczy JSON na stdout.
# Exit 0 = sukces (pojedynczy stack wykryty)
# Exit 1 = błąd argumentów
# Exit 2 = brak markerów (stack=unknown — wymaga eskalacji do usera)
# Exit 3 = monorepo (>1 stack — wymaga eskalacji: który komponent?)
#
# Usage:
#   sh detect-stack.sh [projectDir]
#   projectDir default: .
#
# Output schema (JSON):
#   { stack, components[], package_manager, db_driver, has_existing_tests,
#     has_existing_ci, project_size_files, project_size_class, fragile_paths[] }

set -eu

project_dir="${1:-.}"

if [ ! -d "$project_dir" ]; then
    echo '{"error":"projectDir not a directory","stack":"unknown"}' >&2
    exit 1
fi

# helpers
has_file() { [ -f "$project_dir/$1" ]; }
has_glob() { find "$project_dir" -maxdepth 3 -name "$1" -type f 2>/dev/null | head -n 1 | grep -q .; }

# === stack detection ===
stack="unknown"
components=""

# Next.js: next w deps OR next.config.{js,ts,mjs}
if has_file "package.json"; then
    if grep -q '"next"[[:space:]]*:' "$project_dir/package.json" 2>/dev/null \
       || has_file "next.config.js" || has_file "next.config.ts" || has_file "next.config.mjs"; then
        stack="nextjs"
        components="nextjs"
    else
        stack="node-generic"
        components="node-generic"
    fi
fi

# Python
if has_file "pyproject.toml" || has_file "setup.py" || has_file "requirements.txt"; then
    if [ "$stack" = "unknown" ]; then
        stack="python"
        components="python"
    else
        stack="monorepo"
        components="${components},python"
    fi
fi

# Go
if has_file "go.mod"; then
    if [ "$stack" = "unknown" ]; then
        stack="go"
        components="go"
    else
        stack="monorepo"
        components="${components},go"
    fi
fi

# === package manager ===
pm="unknown"
case "$stack" in
    nextjs|node-generic|monorepo)
        if has_file "pnpm-lock.yaml"; then pm="pnpm"
        elif has_file "yarn.lock"; then pm="yarn"
        elif has_file "bun.lockb"; then pm="bun"
        elif has_file "package-lock.json"; then pm="npm"
        fi
        ;;
esac

if [ "$pm" = "unknown" ] && (has_file "pyproject.toml" || has_file "requirements.txt"); then
    if has_file "uv.lock"; then pm="uv"
    elif has_file "poetry.lock"; then pm="poetry"
    elif has_file "pdm.lock"; then pm="pdm"
    elif has_file "requirements.txt"; then pm="pip"
    fi
fi

if [ "$pm" = "unknown" ] && has_file "go.mod"; then
    pm="go"
fi

# === db driver ===
db="none"
if has_file "package.json"; then
    if grep -q '"@prisma/client"' "$project_dir/package.json" 2>/dev/null; then db="prisma"
    elif grep -q '"drizzle-orm"' "$project_dir/package.json" 2>/dev/null; then db="drizzle"
    elif grep -q '"typeorm"' "$project_dir/package.json" 2>/dev/null; then db="typeorm"
    elif grep -qE '"pg"[[:space:]]*:' "$project_dir/package.json" 2>/dev/null; then db="pg"
    elif grep -qE '"postgres"[[:space:]]*:' "$project_dir/package.json" 2>/dev/null; then db="postgres-js"
    fi
fi

if [ "$db" = "none" ] && has_file "pyproject.toml"; then
    if grep -qE 'asyncpg' "$project_dir/pyproject.toml" 2>/dev/null; then db="asyncpg"
    elif grep -qE 'psycopg' "$project_dir/pyproject.toml" 2>/dev/null; then db="psycopg"
    elif grep -qE 'sqlalchemy' "$project_dir/pyproject.toml" 2>/dev/null; then db="sqlalchemy"
    fi
fi

if [ "$db" = "none" ] && has_file "requirements.txt"; then
    if grep -qE 'asyncpg' "$project_dir/requirements.txt" 2>/dev/null; then db="asyncpg"
    elif grep -qE 'psycopg' "$project_dir/requirements.txt" 2>/dev/null; then db="psycopg"
    elif grep -qE 'sqlalchemy' "$project_dir/requirements.txt" 2>/dev/null; then db="sqlalchemy"
    fi
fi

if [ "$db" = "none" ] && has_file "go.mod"; then
    if grep -qE 'jackc/pgx' "$project_dir/go.mod" 2>/dev/null; then db="pgx"
    elif grep -qE 'lib/pq' "$project_dir/go.mod" 2>/dev/null; then db="lib-pq"
    fi
fi

# === existing tests / ci ===
has_tests=false
if find "$project_dir" -maxdepth 4 \( -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.test.js" -o -name "*_test.go" -o -name "test_*.py" -o -name "*_test.py" \) -type f 2>/dev/null | head -n 1 | grep -q .; then
    has_tests=true
fi

has_ci=false
if [ -d "$project_dir/.github/workflows" ] && find "$project_dir/.github/workflows" -name "*.yml" -o -name "*.yaml" 2>/dev/null | head -n 1 | grep -q .; then
    has_ci=true
fi

# === project size ===
size_files=$(find "$project_dir" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" \) \
    -not -path "*/node_modules/*" -not -path "*/.next/*" -not -path "*/dist/*" -not -path "*/build/*" \
    -not -path "*/__pycache__/*" -not -path "*/.venv/*" -not -path "*/venv/*" -not -path "*/vendor/*" \
    2>/dev/null | wc -l | tr -d ' ')

if [ "$size_files" -lt 50 ]; then size_class="S"
elif [ "$size_files" -lt 500 ]; then size_class="M"
else size_class="L"
fi

# === fragile paths ===
fragile=""
[ -f "$project_dir/CLAUDE.md" ] && fragile="\"CLAUDE.md\""
[ -d "$project_dir/.github/workflows" ] && fragile="${fragile:+$fragile,}\".github/workflows/\""
[ -d "$project_dir/migrations" ] && fragile="${fragile:+$fragile,}\"migrations/\""
[ -d "$project_dir/db/migrations" ] && fragile="${fragile:+$fragile,}\"db/migrations/\""
[ -d "$project_dir/terraform" ] && fragile="${fragile:+$fragile,}\"terraform/\""
[ -d "$project_dir/k8s" ] && fragile="${fragile:+$fragile,}\"k8s/\""

# === build components JSON array ===
comp_json=""
old_ifs=$IFS
IFS=,
for c in $components; do
    [ -z "$c" ] && continue
    comp_json="${comp_json:+$comp_json,}\"$c\""
done
IFS=$old_ifs

# === emit JSON ===
cat <<EOF
{"stack":"$stack","components":[$comp_json],"package_manager":"$pm","db_driver":"$db","has_existing_tests":$has_tests,"has_existing_ci":$has_ci,"project_size_files":$size_files,"project_size_class":"$size_class","fragile_paths":[$fragile]}
EOF

if [ "$stack" = "unknown" ]; then
    exit 2
fi
if [ "$stack" = "monorepo" ]; then
    exit 3
fi
exit 0
