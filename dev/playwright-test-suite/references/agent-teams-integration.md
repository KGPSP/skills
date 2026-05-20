---
title: Integracja z agent-teams-builder — Evaluator deleguje do playwright-runner
load-when: "Skill wywoływany z agent-teams-builder LUB Evaluator z agent-teams-builder potrzebuje runtime QA"
source:
  - dev/agent-teams-builder/agents/evaluator.md
  - dev/agent-teams-builder/references/evaluator-rubric.md
---

# Integracja z agent-teams-builder

> Cel: jasny kontrakt jak `playwright-runner` (z tego skilla) komunikuje się z `evaluator` (z agent-teams-builder). Bez tego — duplicate work LUB Evaluator próbuje sam uruchamiać testy bez wyspecjalizowanego sub-agenta.

## 1. Architektura

```
parent agent (główne okno)
   │
   ├── Task(subagent_type: "planner") → state/plan.md
   ├── Task(subagent_type: "generator") → kod w src/
   └── Task(subagent_type: "evaluator") → werdykt
              │
              └── Task(subagent_type: "playwright-runner")  ← TEN skill
                     │
                     ├── Faza 1-5 QA
                     └── state/evidence/sprint-{n}/qa-summary.json
```

`evaluator` deleguje **całą część QA** do `playwright-runner`, sam tylko:
- Czyta `qa-summary.json`.
- Mapuje na kryteria kontraktu.
- Wystawia werdykt JSON do kontraktu (`criteria_results`, `verdict`).

## 2. Protokół wywołania

W `evaluator.md` (workflow per iteracja):

```
1. Czytaj state/contracts/sprint-{n}.json
2. Wywołaj playwright-runner:
   Task(
     description: "Run QA suite for sprint {n}",
     subagent_type: "playwright-runner",
     prompt: "Uruchom 5 faz testowych dla sprintu {n} wg kontraktu state/contracts/sprint-{n}.json. Evidence do state/evidence/sprint-{n}/. Po skończeniu zwróć JSON z qa-summary.json."
   )
3. Czekaj na return — playwright-runner zwraca:
   {
     "overall_pass": <bool>,
     "blocking_failures": [...],
     "evidence_dir": "state/evidence/sprint-{n}/",
     "report_url": "..."
   }
4. Czytaj qa-summary.json + mapuj phases na criteria_results.
5. Wpisz do kontraktu (jak w evaluator.md workflow):
   {
     "criteria_results": [
       {"id": "C-01", "passed": true,  "evidence_path": "state/evidence/sprint-{n}/ui/C-01/after.png"},
       {"id": "C-15", "passed": false, "evidence_path": "state/evidence/sprint-{n}/perf/vitals.json", "observation": "LCP=3200ms > threshold 2500ms"}
     ],
     "verdict": "iterate",
     "feedback_for_generator": "LCP zbyt wysoki dla home page. Zoptymalizuj critical rendering path."
   }
```

## 3. Mapowanie kryteriów na fazy playwright-runner

| Kryterium kontraktu | Faza w playwright-runner | Evidence path |
|---|---|---|
| `type: "functional"` | Faza 2 (UI) lub 3 (jeśli API) | `state/evidence/sprint-{n}/ui/{C-XX}/` |
| `type: "layout"` | Faza 2 (boundingBox checks) | `state/evidence/sprint-{n}/ui/{C-XX}/` |
| `type: "design"` | Faza 5 (visual regression) + manualny check rubric | `state/evidence/sprint-{n}/visual/{view}/` |
| `type: "performance"` | Faza 3 (Chrome DevTools) | `state/evidence/sprint-{n}/perf/vitals.json` |
| `type: "craft"` | NIE w playwright-runner — Evaluator robi sam (lint, tsc, grep no-stubs) | n/a |
| `type: "a11y"` (jeśli kontrakt ma) | Faza 4 (axe-core) | `state/evidence/sprint-{n}/a11y/violations.json` |

## 4. Cykl iteracji

```
1. Generator commit
2. evaluator → Task("playwright-runner")
3. playwright-runner uruchamia smoke → ui → perf → a11y → visual
4. playwright-runner zwraca qa-summary.json
5. evaluator czyta + mapuje na kontrakt
6. evaluator wystawia verdict
7. JEŚLI verdict == "iterate": generator widzi feedback_for_generator (CO nie działa, NIE jak naprawić)
8. JEŚLI verdict == "passed": sprint zamknięty
9. JEŚLI verdict == "pivot_requested": Evaluator pisze pivot_plan.md
```

## 5. Izolacja kontekstów

| Co widzi playwright-runner | Co widzi evaluator |
|---|---|
| Kontrakt sprintu (read) | Kontrakt sprintu (read+write własnych sekcji) |
| Kod aplikacji (read-only przez Read) | NIE — tylko evidence i qa-summary.json |
| state/evidence/ (write) | state/evidence/ (read) |
| Output Playwright (raw) | qa-summary.json (zaggregowany) |

**Nie wycieka:** wewnętrzne rozumowanie playwright-runner. Evaluator dostaje **tylko** strukturę JSON.

## 6. Co Evaluator NIE deleguje do playwright-runner

- Ocena kryteriów `type: "craft"` (linting, typecheck, brak stubów) — to deterministyczne checks, Evaluator robi `bash scripts/...` z agent-teams-builder.
- Decyzja o pivot/passed — to Evaluator wystawia werdykt, nie playwright-runner.
- Modyfikacja kontraktu — playwright-runner read-only na kontrakcie.
- Pisanie do `state/contracts/` — tylko Evaluator.

## 7. Fallback gdy playwright-runner unavailable

Jeśli skill `playwright-test-suite` nie jest zainstalowany w projekcie:

1. Evaluator wykrywa brak `agents/playwright-runner.md` w `.claude/agents/`.
2. Wraca do trybu inline — używa `Bash` tool bezpośrednio do `npx playwright test` (jak w v1.0 evaluator.md).
3. Jakość gorsza (brak dedykowanego workflow), ale działa.

Patrz `dev/agent-teams-builder/agents/evaluator.md §fallback`.

## 8. Setup integracji w projekcie

```bash
# W katalogu projektu który używa agent-teams-builder:
mkdir -p .claude/agents

# Skopiuj sub-agenty agent-teams-builder
cp ~/Documents/GitHub/skills/dev/agent-teams-builder/agents/*.md .claude/agents/

# Skopiuj sub-agent playwright-runner (z playwright-test-suite)
cp ~/Documents/GitHub/skills/dev/playwright-test-suite/agents/playwright-runner.md .claude/agents/

# Walidacja
bash ~/Documents/GitHub/skills/dev/agent-teams-builder/scripts/verify-role-isolation.sh
# Powinno wykryć 4 role (planner, generator, evaluator, playwright-runner) i potwierdzić izolację.
```

Walidator może wymagać aktualizacji żeby uznawał playwright-runner — patrz commit do `agent-teams-builder/scripts/verify-role-isolation.sh`.
