#!/usr/bin/env bash
# smoke-test-runner.sh — uruchamia smoke test PRZED wejściem Evaluatora
# Usage: scripts/smoke-test-runner.sh [<sprint-n>]
# Wyłapuje: kompilację, start aplikacji, podstawową dostępność endpoint/UI.

set -euo pipefail

SPRINT="${1:-current}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
EVIDENCE_DIR="$BASE_DIR/state/evidence/sprint-${SPRINT}"
mkdir -p "$EVIDENCE_DIR"

LOG="$EVIDENCE_DIR/smoke.log"
: > "$LOG"

run_step() {
  local name="$1"; shift
  echo "[$(date -u +%H:%M:%S)] $name" | tee -a "$LOG"
  if "$@" >> "$LOG" 2>&1; then
    echo "[OK] $name" | tee -a "$LOG"
  else
    echo "[FAIL] $name (exit $?)" | tee -a "$LOG"
    return 1
  fi
}

# 1. Detect project type
if [[ -f "$BASE_DIR/package.json" ]]; then
  PROJECT_TYPE="node"
elif [[ -f "$BASE_DIR/pyproject.toml" ]] || [[ -f "$BASE_DIR/requirements.txt" ]]; then
  PROJECT_TYPE="python"
elif [[ -f "$BASE_DIR/Cargo.toml" ]]; then
  PROJECT_TYPE="rust"
elif [[ -f "$BASE_DIR/go.mod" ]]; then
  PROJECT_TYPE="go"
else
  PROJECT_TYPE="unknown"
fi

echo "Project type: $PROJECT_TYPE" | tee -a "$LOG"

# 2. Build / install / typecheck
case "$PROJECT_TYPE" in
  node)
    [[ -d "$BASE_DIR/node_modules" ]] || run_step "install" npm ci --silent
    if jq -e '.scripts.typecheck' "$BASE_DIR/package.json" >/dev/null 2>&1; then
      run_step "typecheck" npm run typecheck
    fi
    if jq -e '.scripts.build' "$BASE_DIR/package.json" >/dev/null 2>&1; then
      run_step "build" npm run build
    fi
    if jq -e '.scripts.lint' "$BASE_DIR/package.json" >/dev/null 2>&1; then
      run_step "lint" npm run lint
    fi
    ;;
  python)
    run_step "install" pip install -e . --quiet || true
    command -v mypy >/dev/null && run_step "typecheck" mypy . || true
    command -v ruff >/dev/null && run_step "lint" ruff check . || true
    ;;
  rust)
    run_step "build" cargo build --release
    run_step "clippy" cargo clippy -- -D warnings
    ;;
  go)
    run_step "build" go build ./...
    run_step "vet" go vet ./...
    ;;
  *)
    echo "[WARN] Nieznany typ projektu, pomijam build/lint" | tee -a "$LOG"
    ;;
esac

# 3. Start app (jeśli skonfigurowane)
APP_URL="${APP_URL:-http://localhost:3000}"
APP_START_CMD="${APP_START_CMD:-}"
APP_TIMEOUT="${APP_TIMEOUT:-30}"

if [[ -n "$APP_START_CMD" ]]; then
  echo "Starting app: $APP_START_CMD" | tee -a "$LOG"
  $APP_START_CMD >> "$LOG" 2>&1 &
  APP_PID=$!
  trap "kill $APP_PID 2>/dev/null || true" EXIT

  # Wait for app to be up
  for i in $(seq 1 "$APP_TIMEOUT"); do
    if curl -fsS "$APP_URL" -o /dev/null 2>/dev/null; then
      echo "[OK] App responding on $APP_URL after ${i}s" | tee -a "$LOG"
      break
    fi
    sleep 1
    if [[ "$i" -eq "$APP_TIMEOUT" ]]; then
      echo "[FAIL] App nie odpowiada po ${APP_TIMEOUT}s" | tee -a "$LOG"
      exit 10
    fi
  done

  # Basic GET
  HTTP_CODE=$(curl -fsS -o /dev/null -w "%{http_code}" "$APP_URL" || echo "000")
  if [[ "$HTTP_CODE" =~ ^[23] ]]; then
    echo "[OK] GET $APP_URL → $HTTP_CODE" | tee -a "$LOG"
  else
    echo "[FAIL] GET $APP_URL → $HTTP_CODE" | tee -a "$LOG"
    exit 11
  fi
else
  echo "[SKIP] APP_START_CMD nieustawione, pomijam runtime smoke" | tee -a "$LOG"
fi

# 4. Tests (jeśli istnieją)
case "$PROJECT_TYPE" in
  node)
    jq -e '.scripts.test' "$BASE_DIR/package.json" >/dev/null 2>&1 && run_step "unit-tests" npm test -- --watchAll=false
    ;;
  python)
    command -v pytest >/dev/null && run_step "unit-tests" pytest -x --tb=short
    ;;
  rust)
    run_step "unit-tests" cargo test
    ;;
  go)
    run_step "unit-tests" go test ./...
    ;;
esac

echo "[OK] Smoke test passed. Evaluator może wchodzić." | tee -a "$LOG"

# Metadata
cat > "$EVIDENCE_DIR/smoke.metadata.json" <<EOF
{
  "produced_by": "smoke-test-runner",
  "sprint": "$SPRINT",
  "ts": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project_type": "$PROJECT_TYPE",
  "app_url": "$APP_URL",
  "result": "passed"
}
EOF
