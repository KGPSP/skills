#!/usr/bin/env bash
# aggregate-evidence.sh — agreguje metadata wszystkich faz w qa-summary.json
# Usage: scripts/aggregate-evidence.sh <sprint-n>
# Output: state/evidence/sprint-{n}/qa-summary.json

set -euo pipefail

SPRINT="${1:?Usage: aggregate-evidence.sh <sprint-n>}"
BASE_DIR="${BASE_DIR:-$(pwd)}"
EVIDENCE="$BASE_DIR/state/evidence/sprint-${SPRINT}"

[[ -d "$EVIDENCE" ]] || { echo "[FAIL] $EVIDENCE not found"; exit 1; }

read_phase() {
  local file="$1"; local default="$2"
  if [[ -f "$file" ]]; then
    jq "$default" "$file" 2>/dev/null || echo "$default"
  else
    echo "{ \"passed\": null, \"missing\": true }"
  fi
}

SMOKE=$(read_phase "$EVIDENCE/smoke.metadata.json"        '{passed: (.result == "passed"), duration_ms: .duration_ms, evidence: [.log_path]}')
UI=$(read_phase "$EVIDENCE/ui-tests.metadata.json"       '{passed: (.result == "passed"), criteria_count: .criteria_count, evidence: [.results_json, .html_report]}')
PERF=$(read_phase "$EVIDENCE/perf/metadata.json"          '{passed: (.result == "passed"), vitals: .vitals, thresholds: .thresholds, blocking_failures: .blocking_failures}')
A11Y=$(read_phase "$EVIDENCE/a11y/metadata.json"          '{passed: (.result == "passed"), violations_by_impact: .violations_by_impact, blocking_failures: .blocking_failures}')
VISUAL=$(read_phase "$EVIDENCE/visual/metadata.json"      '{passed: (.result == "passed"), views_total: .views_total, views_passed: .views_passed, views_failed: .views_failed}')

# Determine overall
OVERALL_PASS="true"
BLOCKING=()

for phase_name in smoke ui perf a11y visual; do
  phase_var=$(echo "$phase_name" | tr 'a-z' 'A-Z')
  phase_data=$(eval echo "\${$phase_var}")
  passed=$(echo "$phase_data" | jq -r '.passed // false')

  if [[ "$passed" == "false" ]]; then
    OVERALL_PASS="false"
    BLOCKING+=("phase_${phase_name}_failed")
  fi
done

# Build qa-summary.json
cat > "$EVIDENCE/qa-summary.json" <<EOF
{
  "produced_by": "playwright-runner",
  "ts": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "sprint": "$SPRINT",
  "phases": {
    "smoke":  $SMOKE,
    "ui":     $UI,
    "perf":   $PERF,
    "a11y":   $A11Y,
    "visual": $VISUAL
  },
  "overall_pass": $OVERALL_PASS,
  "blocking_failures": $(printf '%s\n' "${BLOCKING[@]:-}" | jq -R . | jq -s . 2>/dev/null || echo '[]'),
  "evidence_dir": "$EVIDENCE"
}
EOF

echo "[OK] qa-summary.json:"
jq '.' "$EVIDENCE/qa-summary.json"
echo ""
echo "Overall: $OVERALL_PASS"
[[ "$OVERALL_PASS" == "true" ]] && exit 0 || exit 1
