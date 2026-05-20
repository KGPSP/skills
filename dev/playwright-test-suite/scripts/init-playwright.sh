#!/usr/bin/env bash
# init-playwright.sh — bootstrap Playwright + axe-core + pixelmatch w projekcie
# Usage: scripts/init-playwright.sh [project-dir]
# Idempotentny — jeśli pakiety/config już są, nie nadpisuje.

set -euo pipefail

PROJECT="${1:-$(pwd)}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$PROJECT"

echo "=== Init Playwright Test Suite in: $PROJECT ==="

# 1. Node.js check
NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1 || echo "0")
if [[ "$NODE_VERSION" -lt 18 ]]; then
  echo "[FAIL] Node.js ≥18 required (have: $(node --version 2>/dev/null || echo 'none'))"
  exit 1
fi
echo "[OK] Node $(node --version)"

# 2. package.json
if [[ ! -f package.json ]]; then
  echo "[FAIL] package.json not found. Run npm init first."
  exit 2
fi

# 3. Install dependencies (idempotent — npm install nie reinstaluje)
echo "[step] Installing dependencies..."
npm install --save-dev \
  @playwright/test@^1.42.0 \
  @axe-core/playwright@^4.8.5 \
  pixelmatch@^5.3.0 \
  pngjs@^7.0.0 \
  >/dev/null 2>&1 || { echo "[FAIL] npm install failed"; exit 3; }
echo "[OK] Dependencies installed"

# 4. Browser binaries
if ! npx playwright --version >/dev/null 2>&1; then
  echo "[FAIL] playwright CLI not available after install"
  exit 4
fi

echo "[step] Installing browser binaries..."
npx playwright install chromium firefox webkit >/dev/null 2>&1 || \
  { echo "[WARN] playwright install partial — some browsers may be missing"; }

if [[ "${CI:-}" == "true" ]] || [[ "${INSTALL_DEPS:-}" == "1" ]]; then
  echo "[step] Installing system dependencies (--with-deps)..."
  npx playwright install-deps >/dev/null 2>&1 || \
    { echo "[WARN] install-deps failed — may need sudo on Linux"; }
fi
echo "[OK] Browsers ready"

# 5. playwright.config.ts
if [[ -f playwright.config.ts ]]; then
  echo "[SKIP] playwright.config.ts already exists — NIE nadpisuję"
  echo "       Sprawdź ręcznie czy ma sekcje: reporter (json+html), trace, screenshot, projects, webServer"
else
  cp "$SKILL_DIR/templates/playwright.config.ts.tmpl" playwright.config.ts
  echo "[OK] playwright.config.ts created from template"
fi

# 6. tests/ directory
mkdir -p tests tests/snapshots tests/generated
echo "[OK] tests/ directories ready"

# 7. .gitignore additions
if [[ -f .gitignore ]]; then
  for ignore in "test-results/" "playwright-report/" "tests-results.json"; do
    grep -qxF "$ignore" .gitignore || echo "$ignore" >> .gitignore
  done
  echo "[OK] .gitignore updated"
fi

# 8. Sanity check
echo "[step] Sanity: npx playwright test --list..."
if npx playwright test --list >/dev/null 2>&1; then
  echo "[OK] Playwright config parses correctly"
else
  echo "[WARN] playwright test --list failed — check config manually"
fi

# 9. Summary
echo ""
echo "=== ✅ Init done ==="
echo "  Project: $PROJECT"
echo "  Playwright: $(npx playwright --version)"
echo "  Config: $PROJECT/playwright.config.ts"
echo "  Tests dir: $PROJECT/tests/"
echo ""
echo "Next:"
echo "  1. Copy templates: ls $SKILL_DIR/templates/"
echo "  2. Run smoke: bash $SKILL_DIR/scripts/run-smoke.sh"
echo "  3. Generate per-sprint tests: bash $SKILL_DIR/scripts/run-ui-tests.sh {sprint-n}"
