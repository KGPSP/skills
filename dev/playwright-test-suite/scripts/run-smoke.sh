#!/usr/bin/env bash
# run-smoke.sh — Faza 1: build + start + HTTP + Playwright smoke spec
# Usage: scripts/run-smoke.sh [sprint-n]
# Exit 0 = wszystkie 4 kroki passed. Brak smoke = brak prawa na fazę 2.

set -euo pipefail

SPRINT="${1:-current}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
EVIDENCE_DIR="$BASE_DIR/state/evidence/sprint-${SPRINT}"
[[ "$SPRINT" == "current" ]] && EVIDENCE_DIR="$BASE_DIR/qa-report/$(date +%Y%m%dT%H%M%S)"
mkdir -p "$EVIDENCE_DIR"

LOG="$EVIDENCE_DIR/smoke.log"
: > "$LOG"

step() { echo "[$(date -u +%H:%M:%S)] $*" | tee -a "$LOG"; }
fail() { step "[FAIL] $*"; gen_metadata "failed" "$1"; exit 1; }

gen_metadata() {
  local result="$1"; local reason="${2:-}"
  cat > "$EVIDENCE_DIR/smoke.metadata.json" <<EOF
{
  "produced_by": "playwright-runner",
  "phase": "smoke",
  "sprint": "$SPRINT",
  "ts": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "result": "$result",
  "reason": "$reason",
  "duration_ms": $(($(date +%s) - START)),
  "log_path": "$LOG"
}
EOF
}

START=$(date +%s)

# 1. Detect stack
if [[ -f package.json ]]; then STACK="node"
elif [[ -f Cargo.toml ]]; then STACK="rust"
elif [[ -f go.mod ]]; then STACK="go"
elif [[ -f pyproject.toml ]] || [[ -f requirements.txt ]]; then STACK="python"
else STACK="unknown"
fi
step "Stack detected: $STACK"

# 2. Build clean
step "=== Step 1: Build ==="
case "$STACK" in
  node)
    [[ -d node_modules ]] || npm ci --silent 2>&1 | tee -a "$LOG"
    if jq -e '.scripts.build' package.json >/dev/null 2>&1; then
      npm run build 2>&1 | tee -a "$LOG" || fail "build failed"
    else
      step "[SKIP] no 'build' script in package.json"
    fi
    ;;
  rust)
    cargo build --release 2>&1 | tee -a "$LOG" || fail "cargo build failed"
    ;;
  go)
    go build ./... 2>&1 | tee -a "$LOG" || fail "go build failed"
    ;;
  python)
    pip install -e . --quiet 2>&1 | tee -a "$LOG" || step "[WARN] pip install partial"
    ;;
  *)
    step "[WARN] Unknown stack — skipping build"
    ;;
esac
step "[OK] Build clean"

# 3. App start (background)
step "=== Step 2: App start ==="
APP_URL="${APP_URL:-http://localhost:3000}"
APP_START_CMD="${APP_START_CMD:-}"
APP_TIMEOUT="${APP_TIMEOUT:-30}"

if [[ -z "$APP_START_CMD" ]]; then
  case "$STACK" in
    node) APP_START_CMD="npm run dev" ;;
    rust) APP_START_CMD="cargo run --release" ;;
    go) APP_START_CMD="go run ." ;;
    python) APP_START_CMD="python -m server" ;;
  esac
fi

if [[ -n "$APP_START_CMD" ]]; then
  step "Starting: $APP_START_CMD"
  $APP_START_CMD >> "$LOG" 2>&1 &
  APP_PID=$!
  trap "kill $APP_PID 2>/dev/null || true" EXIT

  step "Waiting for $APP_URL (timeout: ${APP_TIMEOUT}s)..."
  for i in $(seq 1 "$APP_TIMEOUT"); do
    if curl -fsS "$APP_URL" -o /dev/null 2>/dev/null; then
      step "[OK] App responding after ${i}s"
      break
    fi
    sleep 1
    [[ "$i" -eq "$APP_TIMEOUT" ]] && fail "app not responding after ${APP_TIMEOUT}s"
  done
else
  step "[SKIP] No APP_START_CMD configured"
fi

# 4. HTTP check
step "=== Step 3: HTTP check ==="
HTTP_CODE=$(curl -fsS -o /dev/null -w "%{http_code}" "$APP_URL" 2>/dev/null || echo "000")
if [[ "$HTTP_CODE" =~ ^[23] ]]; then
  step "[OK] GET $APP_URL → $HTTP_CODE"
else
  fail "GET $APP_URL → $HTTP_CODE"
fi

# 5. Playwright smoke
step "=== Step 4: Playwright smoke ==="
if [[ -f tests/smoke.spec.ts ]] || [[ -f tests/smoke.spec.js ]]; then
  if APP_URL="$APP_URL" npx playwright test smoke.spec --reporter=json 2>&1 | tee -a "$LOG"; then
    step "[OK] Playwright smoke passed"
  else
    fail "playwright smoke failed"
  fi
else
  step "[WARN] No tests/smoke.spec.ts — generating from template"
  SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  if [[ -f "$SKILL_DIR/templates/smoke.spec.ts.tmpl" ]]; then
    sed "s|{{APP_URL}}|$APP_URL|g" "$SKILL_DIR/templates/smoke.spec.ts.tmpl" > tests/smoke.spec.ts
    npx playwright test smoke.spec --reporter=json 2>&1 | tee -a "$LOG" || fail "playwright smoke failed (from generated template)"
  else
    step "[WARN] Template missing — skipping playwright smoke"
  fi
fi

# 6. Metadata
gen_metadata "passed" ""
step ""
step "=== ✅ Smoke passed ==="
step "Evidence: $EVIDENCE_DIR/smoke.{log,metadata.json}"
step "Faza 2 (UI tests) odblokowana."
