#!/usr/bin/env bash
# setup-context7.sh — instaluje context7 MCP + opcjonalnie DeepWiki
# Usage: scripts/setup-context7.sh [--user|--project] [--api-key KEY]
# --user (default)    — claude mcp add --scope user  (globalnie dla wszystkich projektów)
# --project           — tworzy .mcp.json w katalogu projektu (per-repo)
#
# Env:
#   CONTEXT7_API_KEY  — token z context7.com/dashboard (opcjonalny, podnosi rate limit)
#
# Idempotent — jeśli context7 już skonfigurowany, NIE nadpisuje.

set -euo pipefail

SCOPE="user"
API_KEY="${CONTEXT7_API_KEY:-}"
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) SCOPE="user"; shift ;;
    --project) SCOPE="project"; shift ;;
    --api-key) API_KEY="$2"; shift 2 ;;
    *) echo "[FAIL] Unknown arg: $1"; exit 1 ;;
  esac
done

echo "=== Setup context7 MCP (scope: $SCOPE) ==="
echo ""

# === Preflight ===
NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1 || echo "0")
if [[ "$NODE_VERSION" -lt 18 ]]; then
  echo "[FAIL] Node.js ≥18 required (have: $(node --version 2>/dev/null || echo 'none'))"
  exit 2
fi
echo "[OK] Node $(node --version)"

if ! command -v npx >/dev/null 2>&1; then
  echo "[FAIL] npx not in PATH"
  exit 3
fi
echo "[OK] npx available"

# === Smoke test context7 — czy npm package jest dostępny ===
echo "[step] Verifying @upstash/context7-mcp on npm..."
if ! npm view @upstash/context7-mcp version >/dev/null 2>&1; then
  echo "[FAIL] Cannot reach npm registry or package missing"
  exit 4
fi
C7_VERSION=$(npm view @upstash/context7-mcp version 2>/dev/null)
echo "[OK] @upstash/context7-mcp@$C7_VERSION available on npm"

# === Setup wg scope ===
case "$SCOPE" in
  user)
    if ! command -v claude >/dev/null 2>&1; then
      echo "[FAIL] 'claude' CLI not found. Zainstaluj Claude Code lub użyj --project mode."
      exit 5
    fi

    # Sprawdź czy już skonfigurowane
    if claude mcp list 2>/dev/null | grep -qE "^context7\s"; then
      echo "[SKIP] context7 already configured in user scope — NIE nadpisuję"
      echo "       Aby zaktualizować: claude mcp remove context7 --scope user && reruning."
    else
      echo "[step] Adding context7 to Claude Code user scope..."
      if [[ -n "$API_KEY" ]]; then
        claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp --api-key "$API_KEY"
      else
        echo "[WARN] No CONTEXT7_API_KEY — rate limit będzie niższy. Get key: https://context7.com/dashboard"
        claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp
      fi
      echo "[OK] context7 added to user scope"
    fi
    ;;

  project)
    MCP_CONFIG="$PROJECT_DIR/.mcp.json"
    SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    TEMPLATE="$SKILL_DIR/assets/mcp-config-template.json"

    if [[ -f "$MCP_CONFIG" ]]; then
      # Sprawdź czy context7 już jest
      if jq -e '.mcpServers.context7' "$MCP_CONFIG" >/dev/null 2>&1; then
        echo "[SKIP] context7 already in $MCP_CONFIG — NIE nadpisuję"
      else
        # Merge — dodaj context7 do istniejącego
        TMP=$(mktemp)
        jq '.mcpServers.context7 = {
          "command": "npx",
          "args": ["-y", "@upstash/context7-mcp"]
        }' "$MCP_CONFIG" > "$TMP" && mv "$TMP" "$MCP_CONFIG"
        echo "[OK] context7 added to existing $MCP_CONFIG"
      fi
    elif [[ -f "$TEMPLATE" ]]; then
      cp "$TEMPLATE" "$MCP_CONFIG"
      # Substytucja API key jeśli podany
      if [[ -n "$API_KEY" ]]; then
        TMP=$(mktemp)
        jq --arg key "$API_KEY" '.mcpServers.context7.args += ["--api-key", $key]' "$MCP_CONFIG" > "$TMP"
        mv "$TMP" "$MCP_CONFIG"
      fi
      echo "[OK] $MCP_CONFIG created from template"
    else
      # Inline minimum
      cat > "$MCP_CONFIG" <<EOF
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"$([ -n "$API_KEY" ] && echo ", \"--api-key\", \"$API_KEY\"")]
    }
  }
}
EOF
      echo "[OK] $MCP_CONFIG created (minimal)"
    fi

    # .gitignore — jeśli API key inline, ostrzeż
    if [[ -n "$API_KEY" ]] && [[ -f "$PROJECT_DIR/.gitignore" ]]; then
      if ! grep -q "^\.mcp\.json$" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
        echo ""
        echo "[WARN] API key osadzony w .mcp.json. Rozważ:"
        echo "       1. Dodać .mcp.json do .gitignore (jeśli secrets)"
        echo "       2. LUB użyć env var \$CONTEXT7_API_KEY i template bez klucza"
      fi
    fi
    ;;
esac

# === Smoke test context7 (jeśli claude CLI dostępny) ===
echo ""
echo "[step] Smoke test — czy MCP server odpowiada..."
if command -v claude >/dev/null 2>&1; then
  if claude mcp list 2>/dev/null | grep -q "context7"; then
    echo "[OK] context7 widoczny w claude mcp list"
  else
    echo "[WARN] context7 NIE widoczny w claude mcp list — restart Claude Code może być potrzebny"
  fi
fi

# === Summary + next steps ===
echo ""
echo "=== ✅ Setup done ==="
echo ""
echo "Aktywacja:"
echo "  - W prompcie: dodaj 'use context7' aby agent wywołał aktualne docs"
echo "  - Auto-invoke: dodaj regułę do CLAUDE.md (patrz assets/claude-md-template.md)"
echo ""
echo "Test:"
echo "  W Claude Code napisz: 'Pokaż mi najnowszy sposób użycia React 19 useTransition. use context7'"
echo "  Powinieneś zobaczyć tool calls: resolve-library-id + get-library-docs"
echo ""
echo "Walidator (w pętli agent-teams-builder):"
echo "  bash scripts/verify-library-currency.sh {sprint-n}"
echo ""
echo "Source: https://github.com/upstash/context7 · API keys: https://context7.com/dashboard"
