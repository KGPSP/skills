#!/bin/sh
# check-plan-complete.sh — feature-spec-planner Phase 6 approval gate.
# Verifies the planning package is complete BEFORE asking the user to approve.
# Checks the plan document for the 10 required sections, AC table completeness
# (no empty Test ID / Komenda), Out-of-scope presence, and slice presence.
# Emits a human-readable report + JSON summary line. Exit 0 = complete, 1 = gaps.
#
# Usage:
#   sh check-plan-complete.sh --plan plans/3-feature.md [--fragile]

set -eu

plan=""
fragile=0

while [ $# -gt 0 ]; do
    case "$1" in
        --plan) plan="$2"; shift 2 ;;
        --fragile) fragile=1; shift ;;
        -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 64 ;;
    esac
done

[ -n "$plan" ] || { echo "ERROR: --plan required" >&2; exit 64; }
[ -f "$plan" ] || { echo "ERROR: plan file not found: $plan" >&2; exit 1; }
[ -s "$plan" ] || { echo "ERROR: plan file is empty: $plan" >&2; exit 1; }

gaps=0
report=""

note() { report="${report}$1\n"; }
fail() { gaps=$((gaps + 1)); note "  ❌ $1"; }
ok()   { note "  ✅ $1"; }

# --- Required sections (heading text fragments, case-insensitive) ---
note "## Sekcje planu"
for needle in \
    "Co i dlaczego" \
    "Acceptance Criteria" \
    "Definition of Done" \
    "Assumptions" \
    "Out of scope" \
    "Thin Vertical Slices" \
    "Target diff" \
    "gotchas"
do
    if grep -iqF "$needle" "$plan"; then
        ok "sekcja obecna: $needle"
    else
        fail "brak sekcji: $needle"
    fi
done

# Hyrum section is conditional — note only.
if grep -iqF "Hyrum" "$plan"; then
    ok "sekcja obecna: Hyrum Risk"
else
    note "  ℹ️  Hyrum Risk nieobecny (OK jeśli brak zmian publicznego API)"
fi

# --- AC table completeness: every AC row must have a non-empty Test ID + Komenda ---
note "## AC ↔ Test mapping (Beyoncé 1:1)"
# Matches data rows AC-F-01 / AC-N-1 / AC-1 / AC-T-2 but NOT the 'AC-ID' header (I excluded).
ac_rows=$(grep -E '^\| *AC-[FNCT0-9]' "$plan" || true)
if [ -z "$ac_rows" ]; then
    fail "brak wierszy AC (oczekiwano '| AC-F-..' itp.)"
else
    ac_total=$(printf '%s\n' "$ac_rows" | grep -c .)
    # A row is "bad" if any pipe-delimited cell is empty/whitespace.
    # Real cells sit between the bordering pipes: fields 2..NF-1.
    ac_bad=$(printf '%s\n' "$ac_rows" | awk -F'|' '{
        bad=0
        for (i=2; i<NF; i++) {
            cell=$i
            gsub(/^[ \t]+|[ \t]+$/, "", cell)
            if (cell == "") bad=1
        }
        if (bad) print
    }' | grep -c . || true)
    if [ "$ac_bad" -eq 0 ]; then
        ok "wszystkie $ac_total wierszy AC mają wypełnione komórki (Test ID + Komenda)"
    else
        fail "$ac_bad z $ac_total wierszy AC ma puste komórki — uzupełnij Test ID / Komenda"
    fi
fi

# --- Out of scope must be non-empty (heading + at least one bullet/line after) ---
note "## Scope discipline"
if awk '/[Oo]ut of scope/{f=1; next} f && /^[#]/{f=0} f && /[A-Za-z]/{print; exit}' "$plan" | grep -q .; then
    ok "Out of scope zawiera treść"
else
    fail "Out of scope puste — wypisz co świadomie pomijasz (lub 'brak — pełny zakres')"
fi

# --- Fragile zone requires Rollback / Plan-Validate-Execute ---
if [ "$fragile" -eq 1 ]; then
    note "## Fragile zone"
    if grep -iqE 'Rollback|Plan-Validate-Execute' "$plan"; then
        ok "sekcja Rollback / Plan-Validate-Execute obecna"
    else
        fail "fragile zone wykryta, ale brak sekcji Rollback / Plan-Validate-Execute"
    fi
fi

# --- Output ---
printf '%b\n' "$report"

if [ "$gaps" -eq 0 ]; then
    printf '{"plan":"%s","status":"complete","gaps":0}\n' "$plan"
    echo "PLAN COMPLETE — gotowy do bramki akceptacji."
    exit 0
else
    printf '{"plan":"%s","status":"incomplete","gaps":%d}\n' "$plan" "$gaps"
    echo "PLAN INCOMPLETE — $gaps brak(ów). Uzupełnij przed bramką akceptacji."
    exit 1
fi
