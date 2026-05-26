---
name: approval-gates-protocol
type: reference
parent: swarm-orchestrator
sources:
  - dev/agent-teams-builder/SKILL.md (6 bramek base)
  - DOC/material_skill.md §8 (5 Non-negotiables — Hard Stop)
---

# 5 bramek aprobacji (approval gates)

Bramki to **wymuszone STOP-checki** — bez zaakceptowanego breadcrumb dla danej bramki kolejna faza nie startuje.

## Mapowanie bramek na fazy

| Gate # | Faza | Co zatwierdza |
|---|---|---|
| 1 | 3.5 | Plan accepted (`state/plan.md` jest gotowy do contract negotiation) |
| 1.5 | 4.5 | Goal statement accepted (TYLKO yolo; `goal-statement.md` jest stabilny) |
| 2 | 5.5 | Contract accepted (`state/contracts/sprint-N.json` ma ≥15 binarnych) |
| 3 | 6.5 | Sprint review (per sprint; sprint-report.md zaakceptowany) |
| 4 | 7.5 | Code review (zero Critical findings) |
| 5 | 8 | Ship (final-report.md + opcjonalny git tag) |

## Format breadcrumb gate_approved

```json
{
  "ts": "2026-05-24T18:42:00Z",
  "actor": "human" | "yolo",
  "event": "gate_approved",
  "details": {
    "gate": 1 | 1.5 | 2 | 3 | 4 | 5,
    "sprint": 1,           // tylko dla gate 3
    "auto_approved": true, // tylko dla actor=yolo
    "reason": "..."        // opcjonalne uzasadnienie human
  }
}
```

## Tryby per bramka

| Tryb | gate:1 | gate:1.5 | gate:2 | gate:3 | gate:4 | gate:5 |
|---|---|---|---|---|---|---|
| manual | human | n/a | human | human | human | human |
| hybrid | human | human | human | human | human | human |
| yolo | yolo (auto) | yolo (auto) | yolo (auto) | yolo (auto) | n/a (skipped) | yolo (auto) |

**YOLO note:** gate:4 (code review) jest **skipowane w trybie yolo** — code review wymaga człowieka. Walidatory automatyczne (`verify-approval-gates.sh`, `check-evidence-completeness.sh` itp.) zastępują manualny code review w YOLO. Operator może zrobić code review post-archive z plików w tar.gz.

## Egzekwowanie

`verify-approval-gates.sh` (uruchamiany w Fazie 7):

```sh
EXPECTED_GATES="1 2 3 5"   # YOLO mode: skip 1.5/4
[ "$mode" = "yolo" ] || EXPECTED_GATES="1 1.5 2 3 4 5"

for g in $EXPECTED_GATES; do
  approved=$(jq --arg g "$g" '[.[] | select(.event == "gate_approved" and .details.gate == ($g | tonumber))] | length' state/breadcrumbs.json)
  if [ "$approved" -lt 1 ]; then
    echo "[FAIL] gate $g not approved"
    exit 1
  fi
done
```

## Akceptacja przez operatora (hybrid/manual)

Operator pisze bezpośrednio w **parent pane** (lub ręcznie z CLI):

```sh
BASE_DIR="$RUN_DIR" scripts/append-breadcrumb.sh human gate_approved '{"gate":1,"reason":"plan covers all 5 ACs"}'
```

Bez explicite breadcrumb, `swarm-yolo.sh --mode hybrid` zatrzymuje się na bramce — polling przez `verify-approval-gates.sh --gate N` (exit 0 gdy approved).

## Akceptacja przez YOLO (auto)

Driver dopisuje breadcrumb automatycznie po każdej fazie:

```sh
BASE_DIR="$RUN_DIR" scripts/append-breadcrumb.sh yolo gate_approved \
  '{"gate":1,"actor":"yolo","auto_approved":true,"validators_passed":["verify-plan-rigor"]}'
```

Gate:5 jest auto-approved **tylko** po:
- wszystkie verification cmds exit 0 (GREEN)
- check-evidence-completeness exit 0
- check-scope-discipline exit 0
- check-pr-size exit 0

Brak któregokolwiek → driver nie zatwierdza gate:5, exit z odpowiednim STOP code.

## Decyzja: bramki = STOP, nie suggestion

Bramki **nigdy nie są ostrzeżeniem** — są hard stop. Operator nie może przeklikać "approve all" hurtowo; każda bramka wymaga **świadomej** decyzji (lub automatycznej z YOLO + walidatorów). To wynika z `DOC/material_skill.md §8` Non-negotiable #5 (Hard Stop at Confict).
