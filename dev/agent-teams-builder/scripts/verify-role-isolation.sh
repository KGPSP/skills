#!/usr/bin/env bash
# verify-role-isolation.sh — egzekwuje izolację narzędzi między rolami
# Usage: scripts/verify-role-isolation.sh
# Sprawdza: Generator NIE ma Playwright/Chrome/Computer; Evaluator NIE ma Edit; evidence produced_by == evaluator

set -euo pipefail

BASE_DIR="${BASE_DIR:-$(pwd)}"

# Szukamy definicji sub-agentów w 2 lokalizacjach (kompatybilność):
# 1. .claude/agents/ (Claude Code standard)
# 2. prompts/ (legacy)
if [[ -d "$BASE_DIR/.claude/agents" ]]; then
  AGENTS_DIR="$BASE_DIR/.claude/agents"
elif [[ -d "$BASE_DIR/prompts" ]]; then
  AGENTS_DIR="$BASE_DIR/prompts"
else
  echo "[FAIL] Brak .claude/agents/ ani prompts/. Skopiuj definicje z skill-dir/agents/."
  exit 10
fi

echo "=== Role isolation check ($AGENTS_DIR) ==="
ERRORS=0

# 1. Generator — NIE może mieć Playwright/Chrome/Computer
GEN_FILE=""
for candidate in "$AGENTS_DIR/generator.md" "$AGENTS_DIR/generator.yaml"; do
  [[ -f "$candidate" ]] && GEN_FILE="$candidate" && break
done

if [[ -n "$GEN_FILE" ]]; then
  # Wyciągnij linię tools: z frontmatter
  TOOLS_LINE=$(awk '/^---/{c++;next} c==1 && /^tools:/{print;exit}' "$GEN_FILE")
  if echo "$TOOLS_LINE" | grep -qiE "(playwright|chrome-devtools|computer-use)"; then
    echo "[FAIL] $GEN_FILE: tools zawiera Playwright/Chrome/Computer — łamie izolację"
    ERRORS=$((ERRORS + 1))
  else
    echo "[OK]   Generator: brak UI testing tools w tools"
  fi

  # Sprawdź czy w body jest jawny ZAKAZ (defense in depth)
  if grep -qiE "(zakaz|nie uruchamiaj).*(playwright|chrome|computer)" "$GEN_FILE"; then
    echo "[OK]   Generator: jawny ZAKAZ w body"
  else
    echo "[WARN] Generator: brak jawnego ZAKAZU w body (frontmatter wystarczy, ale defense in depth lepsze)"
  fi
else
  echo "[FAIL] Brak agents/generator.md"
  ERRORS=$((ERRORS + 1))
fi

# 2. Evaluator — NIE może mieć Edit
EVAL_FILE=""
for candidate in "$AGENTS_DIR/evaluator.md" "$AGENTS_DIR/evaluator.yaml"; do
  [[ -f "$candidate" ]] && EVAL_FILE="$candidate" && break
done

if [[ -n "$EVAL_FILE" ]]; then
  TOOLS_LINE=$(awk '/^---/{c++;next} c==1 && /^tools:/{print;exit}' "$EVAL_FILE")
  if echo "$TOOLS_LINE" | grep -qwE "Edit"; then
    echo "[FAIL] $EVAL_FILE: tools zawiera Edit — Evaluator musi być read-only na kodzie"
    ERRORS=$((ERRORS + 1))
  else
    echo "[OK]   Evaluator: brak Edit w tools"
  fi

  if grep -qiE "(nie modyfikuj|read-only|zakaz.*edit)" "$EVAL_FILE"; then
    echo "[OK]   Evaluator: jawne ograniczenie do read-only w body"
  else
    echo "[WARN] Evaluator: brak jawnego ograniczenia w body"
  fi
else
  echo "[FAIL] Brak agents/evaluator.md"
  ERRORS=$((ERRORS + 1))
fi

# 3. Planner — NIE powinien mieć Edit (tylko Write raz dla plan.md)
PLAN_FILE=""
for candidate in "$AGENTS_DIR/planner.md" "$AGENTS_DIR/planner.yaml"; do
  [[ -f "$candidate" ]] && PLAN_FILE="$candidate" && break
done

if [[ -n "$PLAN_FILE" ]]; then
  TOOLS_LINE=$(awk '/^---/{c++;next} c==1 && /^tools:/{print;exit}' "$PLAN_FILE")
  if echo "$TOOLS_LINE" | grep -qwE "Edit"; then
    echo "[WARN] $PLAN_FILE: tools zawiera Edit — Planner zwykle nie potrzebuje (tylko Write plan.md raz)"
  else
    echo "[OK]   Planner: brak Edit (zgodnie z konwencją)"
  fi
fi

# 4. Evidence produced_by — wszystkie evidence files muszą być produced_by == evaluator
EVIDENCE_DIR="$BASE_DIR/state/evidence"
if [[ -d "$EVIDENCE_DIR" ]]; then
  WRONG=0
  while IFS= read -r md; do
    [[ -z "$md" ]] && continue
    PRODUCER=$(jq -r '.produced_by // "missing"' "$md" 2>/dev/null || echo "missing")
    if [[ "$PRODUCER" != "evaluator" && "$PRODUCER" != "smoke-test-runner" ]]; then
      echo "[FAIL] $md: produced_by=$PRODUCER (oczekiwano: evaluator lub smoke-test-runner)"
      WRONG=$((WRONG + 1))
    fi
  done < <(find "$EVIDENCE_DIR" -name "*.metadata.json" 2>/dev/null)

  if [[ "$WRONG" -eq 0 ]]; then
    echo "[OK]   Wszystkie evidence files produced_by == evaluator|smoke-test-runner"
  else
    ERRORS=$((ERRORS + WRONG))
  fi
fi

# 5. Breadcrumbs — actor zgodny z event semantyką
BC="$BASE_DIR/state/breadcrumbs.json"
if [[ -f "$BC" ]]; then
  WRONG_ACTOR=$(jq '[.[] | select(.event == "iteration_verdict") | select(.actor != "evaluator")] | length' "$BC")
  if [[ "$WRONG_ACTOR" -gt 0 ]]; then
    echo "[FAIL] $WRONG_ACTOR iteration_verdict events z actor != evaluator"
    ERRORS=$((ERRORS + 1))
  else
    echo "[OK]   iteration_verdict events: wszystkie od evaluator"
  fi

  WRONG_GEN=$(jq '[.[] | select(.event == "commit") | select(.actor != "generator")] | length' "$BC")
  if [[ "$WRONG_GEN" -gt 0 ]]; then
    echo "[FAIL] $WRONG_GEN commit events z actor != generator"
    ERRORS=$((ERRORS + 1))
  fi
fi

echo ""
if [[ "$ERRORS" -eq 0 ]]; then
  echo "[OK] Role isolation zachowana."
  exit 0
else
  echo "[FAIL] $ERRORS naruszeń izolacji ról."
  exit "$ERRORS"
fi
