---
name: anti-rationalization
type: reference
parent: swarm-orchestrator
sources:
  - DOC/material_skill.md §3 (Anti-Rationalization principle)
  - DOC/agent-teams-generator-ewaluator.md §3 (presja rywalizacyjna)
  - dev/agent-teams-builder/SKILL.md (Anti-Rat tabela base)
---

# Anti-Rationalization — pełna tabela 12+ wymówek

Format: **wymówka → riposta z konsekwencją + akcja zamiast**.

Skrót 8 wierszy jest w SKILL.md; ta pełna tabela ładuje się gdy agent wpadnie w wymówkę spoza skrótu.

## Orkiestracja (tmux, role separation)

| # | Wymówka | Riposta |
|---|---|---|
| 1 | „Wystarczy 1 agent, szybciej i mniej koordynacji" | Single-agent w >2h = gwarantowany context rot (DOC/agents_swarm.md §3.2). Generator nie widzi swoich błędów, je powtarza. **Spawnuj 4 panes** nawet dla pozornie prostego zadania. |
| 2 | „Tmux to overhead, użyję Task tool zawsze" | Task tool zwraca jeden message i kończy kontekst sub-agenta — tracisz widzialność iteracji w czasie rzeczywistym. Tmux pane = persistent proces + audit. **Task tool jest fallback tylko gdy `swarm-doctor` zgłasza brak tmux.** |
| 3 | „Brakuje iTerm2, użyję zwykłego terminala — tmux -CC działa wszędzie" | W innym terminalu tmux -CC daje fallback do tmux UI w jednym oknie — działa, ale operator musi przełączać pane'y Ctrl+B + ←→↑↓. **Mniej wygodne**, ale akceptowalne. iTerm2 jest preferowane dla wielu okien natywnie. |
| 4 | „Pomijam role separation, planner też napisze trochę kodu" | Łamie izolację kontekstu. Plan + impl w tym samym pane = planner widzi swój własny kod i racjonalizuje plan ex post. **`verify-role-isolation.sh` zablokuje** gdy planner ma `Edit` w tools. |

## Contract i kryteria

| # | Wymówka | Riposta |
|---|---|---|
| 5 | „Pomijam contract phase, wiem co robić, generator zacznie od razu" | Rozmyte kryteria = rozmyta krytyka ewaluatora = patologiczna pętla (agent-teams-builder §Anti-Rat). **≥15 binarnych kryteriów wymagane** nawet dla 5-liniowej funkcji. `check-contract-coverage.sh` zablokuje. |
| 6 | „15 kryteriów to przegięcie dla małej funkcji" | Stwierdzenie poziomu wymagań **nie skaluje się** w dół — granularność kryteriów = granularność dyskusji w iteracji. Małe funkcje też mają edge cases. Lepiej 15 prostych niż 3 mgliste. |
| 7 | „Mogę ocenić w skali 1-10 zamiast binarnie" | Skale są subiektywne i nie kończą iteracji. „7/10 jakości" nie odpowiada na pytanie „done?" `check-contract-coverage.sh` ma walidator: grep "1-10|skala|score" → exit 1. **Tylko pass/fail.** |

## Evidence i weryfikacja

| # | Wymówka | Riposta |
|---|---|---|
| 8 | „Generator może sam ocenić swój kod, ma evidence z testów" | Sędzia we własnej sprawie. Werdykt + screenshot generuje **inny agent niż autor** (DOC/agent-teams-generator-ewaluator.md §4). `verify-role-isolation.sh` sprawdza breadcrumb `iteration_verdict actor` — musi być `evaluator`, nie `generator`. |
| 9 | „Pomijam evidence — git history wystarczy" | Git diff pokazuje statyczne zmiany, NIE runtime trace. „Test passed" w git log nie jest dowodem — dowodem jest plik `.log` z exit code, screenshot z UI, raw output endpointu. `check-evidence-completeness.sh` szuka per `passed:true` plik w `state/evidence/sprint-N/`. |
| 10 | „Evidence to overhead, zaufaj że uruchomiłem testy" | DoD = dowód, nie deklaracja (DOC/material_skill.md §4). Bez artefaktu uznaj że nie zrobione. „Wydaje się działać" = halucynacja statusu. |

## YOLO i autonomia

| # | Wymówka | Riposta |
|---|---|---|
| 11 | „W YOLO mogę pominąć smoke test, leci autonomicznie" | YOLO znosi **bramki przeglądu**, NIE walidatory. Smoke fail przed wejściem ewaluatora = generator pisze do śmietnika (agent-teams-builder Faza 4). W YOLO smoke fail → STOP + `state/blockers.md`. |
| 12 | „Mogę `git push` w YOLO, walidatory zielone" | YOLO znosi human-in-the-loop dla przeglądu, **nie** twarde zabezpieczenia destrukcyjne. `git push`, `npm publish`, `gh pr create`, `gh release`, `DROP`, `rm` poza paths_in_scope — zawsze human gate. Driver blokuje (whitelist) → exit 7. |
| 13 | „STOP po 3× ten sam error_hash to za wcześnie, jestem blisko" | `error_hash` powtarza się = generator powtarza ten sam błąd, nie eksploruje przestrzeni rozwiązań. „Jestem blisko" to halucynacja postępu. **Pivot wcześniej = mniej spalonych iteracji + niższy time-cap.** |
| 14 | „Modify Fragile zone (migrations/, k8s/...) jest OK bo wiem co robię" | Fragile zone = nieodwracalne konsekwencje (data loss, deployment failure). W YOLO blokowane (exit 5). Override przez `--force-fragile` + explicit `fragile_override` w breadcrumbs — operator widzi i bierze odpowiedzialność. Bez tego — Plan-Validate-Execute manualnie. |

## Pivot i no-progress

| # | Wymówka | Riposta |
|---|---|---|
| 15 | „Pivot to przyznanie się do porażki" | Pivot to świadoma decyzja że obecne podejście jest droższe niż restart. Zachowujesz wiedzę (plan + contract), tracisz tylko zły kod. Lepiej pivotować po 3 iter niż po 15. |
| 16 | „Mogę zmienić contract zamiast pivotować, łatwiej" | Można, ale to wymaga renegotiation phase + akceptacji gate:2 ponownie. Jeśli **implementation** jest zła a contract OK → pivot jest właściwą drogą. Jeśli **contract** był źle skonstruowany → renegotiation. Distinct cases. |

## Scope discipline

| # | Wymówka | Riposta |
|---|---|---|
| 17 | „Generator może też poprawić sąsiedni moduł, mała zmiana" | Scope creep blokuje atomic commit. **Każdy zmieniony plik musi być w `paths_in_scope` contract.** `check-scope-discipline.sh` exit 1 jeśli wykryje out-of-scope. Stwórz osobne zadanie w `state/blockers.md`. |
| 18 | „PR z 500+ linii to OK dla complex feature" | `check-pr-size.sh` warning na 300, fail hard na 1000. **Atomic commits per slice** (1 AC per commit) wymuszają mniejsze PRy. Jeśli naprawdę >1000 wymagane → `--justified` flag + uzasadnienie w commit message. |

---

**Ogólna zasada (DOC/material_skill.md §3):** wymówki zaczynające się od „wystarczy", „pomijam", „chyba", „mogę pominąć", „za wcześnie" są **sygnałami racjonalizacji**. Zatrzymaj się, sprawdź konsekwencję, wykonaj akcję zamiast.
