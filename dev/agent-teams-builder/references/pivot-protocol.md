---
title: Mechanizm pivota — autonomiczna decyzja Evaluatora o restarcie
load-when: "Faza 5 SKILL.md — pętla zacina się ≥MAX_ITERATIONS bez progresu na rubryce"
source:
  - DOC/agent-teams-generator-ewaluator.md §3.3 (Poprawki lub pivot)
  - DOC/agent-teams-generator-ewaluator.md §7 (Mechanizm pivota krok po kroku)
  - DOC/since_skill.md §6 (Calibration — Plan-Validate-Execute dla destruktywnych)
---

# Pivot — wyrzucenie pracy i restart sprintu

> Pivot = autonomiczna decyzja Evaluatora o wyrzuceniu **całej dotychczasowej pracy nad sprintem** i starcie od zera. To NIE jest porażka — to mechanizm wyjścia z patologicznej pętli łatania zepsutego fundamentu.

---

## 1. Kiedy pivot, kiedy nie

### Pivot — sygnały

- `MAX_ITERATIONS` (domyślnie 5) osiągnięte bez `passed == total`.
- **Stagnacja na rubryce:** `passed` w 2 iteracjach z rzędu się nie zmienia.
- **Spadek na rubryce:** `passed[N+1] < passed[N]` — fix generatora zepsuł co innego (regresja).
- **Wzorzec łatania:** Generator zmienia ten sam plik >5 razy bez progresu globalnego.

### NIE pivot — sygnały

- `passed` rośnie monotonicznie — daj Generatorowi jeszcze 1-2 iteracje.
- Failujące kryterium ma zależność zewnętrzną (np. czekamy na fix biblioteki) → otwórz `state/blockers.md`, nie wyrzucaj pracy.
- Generator jawnie zgłosił **konflikt wymagań** (Non-negotiable #2) → eskalacja do human, nie pivot.

---

## 2. Workflow pivota (Plan-Validate-Execute)

Pivot to operacja destruktywna (`rm -rf`, force branch reset). **Tryb Fragile Operations** + Plan-Validate-Execute są obowiązkowe.

### Krok 1 — Sygnał Evaluatora

Evaluator zapisuje w kontrakcie:

```json
{
  "iteration": 5,
  "verdict": "pivot_requested",
  "reason": "passed[3]=11, passed[4]=11, passed[5]=11 — stagnacja",
  "pivot_recommended": true,
  "what_to_discard": ["src/editor/", "tests/editor/"],
  "what_to_keep": ["state/contracts/sprint-2.json", "state/plan.md"],
  "alternative_approach": "Zamiast komponentu monolitycznego — Composition Pattern z 3 sub-komponentami: Toolbar, Canvas, Inspector."
}
```

### Krok 2 — Plan (Evaluator wypisuje)

Evaluator dopisuje `pivot_plan.md` w `state/`:

```markdown
# Pivot Plan — sprint-2

## Co usuwamy (paths)
- src/editor/Editor.tsx (350 linii, monolit)
- src/editor/EditorStore.ts (singleton, trudny do testów)
- tests/editor/*.spec.ts (testy do martwego kodu)

## Co zachowujemy
- state/contracts/sprint-2.json (kontrakt nadal aktualny)
- state/plan.md (cel biznesowy bez zmian)
- assets/editor-mockup.png (referencja designu)

## Nowy startowy szkielet
- src/editor/components/Toolbar.tsx (skeleton)
- src/editor/components/Canvas.tsx (skeleton)
- src/editor/components/Inspector.tsx (skeleton)
- Pattern: Composition (każdy ma własny test + storybook)

## Hash przed pivotem
- git rev-parse HEAD: a3f9b21

## Branch archiwizacyjny
- archive/sprint-2-pivot-2026-05-19T18-00
```

### Krok 3 — Validate (Generator akceptuje pisemnie)

Generator czyta `pivot_plan.md`, weryfikuje z:

- `state/plan.md` — czy alternative_approach faktycznie realizuje cel biznesowy.
- `state/contracts/sprint-2.json` — czy kontrakt nadal pokrywa nową architekturę.

Generator dopisuje w `state/breadcrumbs.json`:

```json
{
  "ts": "2026-05-19T18:05:00Z",
  "actor": "generator",
  "event": "pivot_accepted",
  "pivot_plan_hash": "...",
  "reasoning": "Composition Pattern realizuje kontrakt C-01..C-15 + redukuje złożoność cyklomatyczną. Akceptuję."
}
```

**Bez akceptacji Generatora pivot nie wchodzi.** Jeśli Generator odrzuca → eskalacja do human.

### Krok 4 — Execute (skrypt)

```bash
scripts/pivot-trigger.sh sprint-2
```

Skrypt:

1. `git checkout -b archive/sprint-2-pivot-$(date +%Y-%m-%dT%H-%M)` — archiwizuje branch.
2. `git push origin archive/...` (jeśli remote skonfigurowany).
3. `git checkout main` (lub feature branch).
4. `rm -rf` na ścieżkach z `pivot_plan.md → what_to_discard`.
5. `git commit -m "pivot(sprint-2): discard {paths}"`.
6. Tworzy szkielety z `what_to_keep` i `alternative_approach`.
7. Wpis w `breadcrumbs.json`: `event: "pivot_executed"`, `hash_before`, `hash_after`, `archived_branch`.

### Krok 5 — Restart fazy 3

Po pivocie WRACAMY do fazy 3 (negocjacja kontraktu) z istniejącym `sprint-2.json` jako bazą. Generator i Evaluator dopisują sekcję `post_pivot_amendments`.

---

## 3. Opcjonalny human hook

Jeśli `PIVOT_REQUIRES_HUMAN=1` w env:

```bash
# scripts/pivot-trigger.sh
if [[ "${PIVOT_REQUIRES_HUMAN:-0}" == "1" ]]; then
  echo "[PIVOT BLOCKED] Human approval required."
  echo "Plan: $(cat state/pivot_plan.md)"
  read -p "Approve pivot? [y/N] " ans
  [[ "$ans" != "y" ]] && { echo "Aborted by human."; exit 1; }
fi
```

**Kiedy włączyć human hook:**

- Pierwsze 3 sprinty (zanim skalibrujesz traces).
- Sprint z >500 liniami zmian.
- Pivot drugi raz na tym samym sprincie (ryzyko zapętlenia samego pivota).

**Kiedy NIE włączać:** kalibrowane uprzęże z 10+ udanymi pivotami w breadcrumbs (full autonomy).

---

## 4. Patologie pivota — czego unikać

| Patologia | Co ją zdradza | Riposta |
|---|---|---|
| **Pivot kosmetyczny** | Evaluator wyrzuca pracę po 1 iteracji "bo styl mi się nie podoba" | `MAX_ITERATIONS` ≥3 obowiązkowe przed prawem do pivota |
| **Pivot łańcuchowy** | Pivot 2, 3, 4 na tym samym sprincie | Po 2. pivocie obowiązkowo eskalacja human + rewizja `state/plan.md` |
| **Pivot bez archiwizacji** | `git branch -a` nie pokazuje `archive/...` | Skrypt zatrzymany w preflight check |
| **Pivot na podstawie subiektywnego "smaku" Evaluatora** | `reason` zawiera frazy "nie podoba mi się", "lepiej by było" | Odrzuć — pivot wyłącznie z `passed` w 2 iteracjach z rzędu |
| **Wyrzucenie kontraktu razem z kodem** | `what_to_discard` zawiera `state/contracts/` | Kontrakt jest niezmiennikiem sprintu. Wyrzucamy implementację, nie kontrakt. |

---

## 5. Co mówią nowe modele (4.6+) o pivocie

Według dokumentu źródłowego (§7): "Nowsze modele (4.6+) są zaskakująco chętne do akceptacji takiej krytyki i resetu całej pracy nad daną funkcją."

**Implikacja praktyczna:**

- Dla Opus 4.7+ pivot można uruchamiać autonomicznie.
- Dla Haiku/starszych — wymuś human hook (model bywa zbyt zachowawczy LUB zbyt skłonny do pivota bez przesłanek).

---

## 6. Exit criterion fazy 5

```bash
# Po pivocie:
git branch | grep "archive/sprint-${N}-pivot-"   # branch zarchiwizowany
jq '.[] | select(.event == "pivot_executed")' state/breadcrumbs.json  # wpis istnieje
ls src/feature/                                  # szkielety nowej architektury istnieją
test -f state/pivot_plan.md                      # plan zachowany do audytu
```

Wszystkie 4 zielone → wracaj do fazy 3. Czerwone → przerwij i eskaluj do human.
