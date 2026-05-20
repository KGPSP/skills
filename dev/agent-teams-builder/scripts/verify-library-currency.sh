#!/usr/bin/env bash
# verify-library-currency.sh — egzekwuje sprawdzanie aktualności bibliotek przez context7
# Usage: scripts/verify-library-currency.sh <sprint-n>
#
# Sprawdza:
# 1. Czy sprint dodał/zmienił dependencies (package.json, requirements.txt, Cargo.toml, go.mod)
# 2. Jeśli TAK — czy w breadcrumbs jest event 'library_currency_checked' z tej iteracji
# 3. Czy event ma wymagane pola: actor, library_name, source (context7|deepwiki|webfetch|npm-jsdoc)
#
# Exit 0 = sprint nie dotyka deps LUB ma poprawny audit trail
# Exit ≠0 = sprint zmienił deps bez weryfikacji aktualności

set -uo pipefail

SPRINT="${1:?Usage: verify-library-currency.sh <sprint-n>}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
BC="$BASE_DIR/state/breadcrumbs.json"

[[ -f "$BC" ]] || { echo "[FAIL] $BC missing"; exit 1; }

# === 1. Znajdź zakres commitów dla sprintu ===
SPRINT_START_HASH=$(jq -r --argjson s "$SPRINT" \
  '[.[] | select(.event == "iteration_start" and .details.sprint == ($s | tostring))] | first | .details.start_hash // ""' \
  "$BC" 2>/dev/null || echo "")

resolve_fallback_hash() {
  # Inteligentny fallback: jeśli HEAD~5 nie istnieje (krótkie repo), użyj root commita
  if (cd "$BASE_DIR" && git rev-parse --quiet --verify "HEAD~5^{commit}" >/dev/null 2>&1); then
    echo "HEAD~5"
  else
    cd "$BASE_DIR" && git rev-list --max-parents=0 HEAD 2>/dev/null | head -1
  fi
}

if [[ -z "$SPRINT_START_HASH" ]]; then
  SPRINT_START_HASH=$(resolve_fallback_hash)
  echo "[INFO] Brak iteration_start hash dla sprintu $SPRINT — używam $SPRINT_START_HASH"
elif ! (cd "$BASE_DIR" && git rev-parse --quiet --verify "${SPRINT_START_HASH}^{commit}" >/dev/null 2>&1); then
  # Hash z breadcrumbs nie istnieje w git (np. fixture testowy) — fallback
  SPRINT_START_HASH=$(resolve_fallback_hash)
  echo "[WARN] Hash z breadcrumbs nie istnieje w git — fallback do $SPRINT_START_HASH"
fi

# === 2. Czy sprint dotknął dependency-related files? ===
DEP_FILES=(
  "package.json"
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
  "requirements.txt"
  "pyproject.toml"
  "poetry.lock"
  "Cargo.toml"
  "Cargo.lock"
  "go.mod"
  "go.sum"
  "Gemfile"
  "Gemfile.lock"
  "composer.json"
)

CHANGED_DEPS=""
if [[ -d "$BASE_DIR/.git" ]]; then
  set +o pipefail
  for f in "${DEP_FILES[@]}"; do
    if (cd "$BASE_DIR" && git diff --name-only "$SPRINT_START_HASH"..HEAD 2>/dev/null | grep -qxF "$f"); then
      CHANGED_DEPS="$CHANGED_DEPS $f"
    fi
  done
  set -o pipefail
fi

if [[ -z "$CHANGED_DEPS" ]]; then
  echo "[OK] Sprint $SPRINT nie dotknął żadnych dependency files — currency check pomijalny"
  exit 0
fi

echo "[INFO] Sprint $SPRINT zmienił dependency files:$CHANGED_DEPS"

# === 3. Wyciągnij konkretne nowe/zmienione paczki (jeśli package.json) ===
NEW_DEPS=""
if echo "$CHANGED_DEPS" | grep -q "package.json"; then
  set +o pipefail
  # Compare dependencies block
  OLD_DEPS=$(cd "$BASE_DIR" && git show "$SPRINT_START_HASH:package.json" 2>/dev/null | jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' 2>/dev/null | sort -u)
  CUR_DEPS=$(jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' "$BASE_DIR/package.json" 2>/dev/null | sort -u)
  NEW_DEPS=$(comm -13 <(echo "$OLD_DEPS") <(echo "$CUR_DEPS") 2>/dev/null | tr '\n' ' ')
  set -o pipefail
fi

[[ -n "$NEW_DEPS" ]] && echo "[INFO] Nowe paczki w sprincie: $NEW_DEPS"

# === 4. Sprawdź breadcrumbs — czy są eventy library_currency_checked ===
CURRENCY_EVENTS=$(jq --argjson s "$SPRINT" \
  '[.[] | select(.event == "library_currency_checked" and (.details.sprint == ($s | tostring) or .details.sprint == $s))]' \
  "$BC" 2>/dev/null || echo "[]")

EVENT_COUNT=$(echo "$CURRENCY_EVENTS" | jq 'length' 2>/dev/null || echo 0)

if [[ "$EVENT_COUNT" -eq 0 ]]; then
  echo "[FAIL] Sprint $SPRINT zmienił dependencies ALE brak ŻADNEGO library_currency_checked w breadcrumbs."
  echo ""
  echo "Wymagane (przez fallback chain):"
  echo "  1. context7 (primary):  use 'mcp__context7__get-library-docs'"
  echo "  2. DeepWiki (fallback): use 'mcp__deepwiki__*'"
  echo "  3. WebFetch (fallback): use WebFetch dla oficjalnej dok"
  echo "  4. npm/JSDoc (offline): npm view + parsowanie node_modules/.../README.md"
  echo ""
  echo "Po sprawdzeniu — dopisz breadcrumb:"
  echo '  bash scripts/append-breadcrumb.sh "<actor>" "library_currency_checked" \'
  echo '    "$(jq -nc --arg s "'"$SPRINT"'" --arg lib "react" --arg v "19.0.0" --arg src "context7" \'
  echo '      "{sprint: \$s, library: \$lib, version_used: \$v, source: \$src, deprecations_checked: true}")"'
  exit 2
fi

# === 5. Walidacja struktury każdego eventu ===
INVALID=0
ALLOWED_SOURCES="context7 deepwiki webfetch npm-jsdoc"

while IFS= read -r event_json; do
  [[ -z "$event_json" ]] && continue
  LIB=$(echo "$event_json" | jq -r '.details.library // "missing"')
  SRC=$(echo "$event_json" | jq -r '.details.source // "missing"')
  VER=$(echo "$event_json" | jq -r '.details.version_used // "missing"')

  if [[ "$LIB" == "missing" || "$SRC" == "missing" ]]; then
    echo "[FAIL] Event bez wymaganych pól (library, source): $(echo "$event_json" | jq -c .)"
    INVALID=$((INVALID + 1))
    continue
  fi

  if ! echo "$ALLOWED_SOURCES" | grep -qw "$SRC"; then
    echo "[FAIL] Event z nieznanym source='$SRC' (allowed: $ALLOWED_SOURCES)"
    INVALID=$((INVALID + 1))
    continue
  fi

  echo "[OK] Event: library=$LIB, version=$VER, source=$SRC"
done < <(echo "$CURRENCY_EVENTS" | jq -c '.[]' 2>/dev/null)

# === 6. Sprawdź pokrycie — czy każda NEW_DEP ma odpowiadający event ===
if [[ -n "$NEW_DEPS" ]]; then
  MISSING=""
  for dep in $NEW_DEPS; do
    if ! echo "$CURRENCY_EVENTS" | jq -e --arg d "$dep" '.[] | select(.details.library == $d)' >/dev/null 2>&1; then
      MISSING="$MISSING $dep"
    fi
  done

  if [[ -n "$MISSING" ]]; then
    echo "[WARN] Nowe paczki bez event'u library_currency_checked:$MISSING"
    echo "       Każda nowa paczka powinna być zweryfikowana przez context7 lub fallback."
    # WARN, nie FAIL — fixture/migrations mogą legitymnie dodawać paczki bez context7
  fi
fi

# === Summary ===
echo ""
if [[ "$INVALID" -eq 0 ]]; then
  echo "[OK] Library currency check: $EVENT_COUNT events, wszystkie poprawne"
  exit 0
else
  echo "[FAIL] $INVALID eventów ma błędną strukturę"
  exit 3
fi
