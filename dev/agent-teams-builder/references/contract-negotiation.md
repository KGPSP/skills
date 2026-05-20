---
title: Protokół negocjacji kontraktu Generator ↔ Evaluator
load-when: "Faza 3 SKILL.md — przed napisaniem pierwszej linii kodu sprintu"
source:
  - DOC/agent-teams-generator-ewaluator.md §3.1 (Negocjacja kontraktu)
  - DOC/agent-teams-generator-ewaluator.md §4 (Rubryka ewaluatora)
  - DOC/material_skill.md §3 (Tabela Anty-racjonalizacji)
---

# Protokół negocjacji kontraktu

> Cel: przed napisaniem jakiegokolwiek kodu Generator i Evaluator uzgadniają granularną, mierzalną definicję "ukończenia". Komunikacja przez wymianę plików JSON/MD na dysku — bez kanału side-channel w jednym oknie kontekstowym.

---

## 1. Twarde wymagania kontraktu

Każdy kontrakt sprintu (`state/contracts/sprint-{n}.json`) MUSI zawierać:

1. **≥15 kryteriów binarnych** (referencja: w cytowanym projekcie Anthropic — 27 dla pojedynczej funkcji).
2. **Zero skal 1-10.** Każde kryterium: `passed: true|false`. Patrz `evaluator-rubric.md`.
3. **Sekcję `acceptance_evidence`** — czym Evaluator udowodni weryfikację (screenshot, log, output endpointu, hash gita).
4. **Sekcję `out_of_scope`** — co jawnie pomijamy (Scope Discipline).
5. **Wskaźnik `max_iterations`** — domyślnie 5. Po przekroczeniu wchodzi `pivot-protocol.md`.

---

## 2. Workflow negocjacji (krok po kroku)

### Krok 1 — Propozycja Generatora

Generator zapisuje `state/contracts/sprint-{n}.draft.json`:

```json
{
  "sprint": "n",
  "goal": "Zbuduj komponent X realizujący Y",
  "proposed_criteria": [
    { "id": "C-01", "type": "functional", "check": "...", "binary": true },
    { "id": "C-02", "type": "design", "check": "...", "binary": true }
  ],
  "acceptance_evidence": ["playwright-screenshot", "npm-test-output"],
  "out_of_scope": ["zmiany w module Z", "refaktor API auth"],
  "status": "draft-by-generator"
}
```

### Krok 2 — Krytyka Evaluatora

Evaluator dopisuje (NIE nadpisuje) sekcję `evaluator_review`:

```json
{
  ...,
  "evaluator_review": {
    "ts": "2026-05-19T16:00:00Z",
    "verdict": "rejected",
    "missing_criteria": [
      "brak testu klawiatury (spacja, strzałki)",
      "brak weryfikacji kolejności wywołań API (Hyrum)",
      "brak few-shot referencji 'dobry design' vs 'AI slop'"
    ],
    "weak_criteria": ["C-03 jest skalą — przerób na binarne"],
    "edge_cases_missing": ["pusty input", "100k rekordów", "utracony token sesji"]
  },
  "status": "iteration-1-rejected"
}
```

### Krok 3 — Iteracja

Generator dopisuje nowe propozycje + akceptacje. Plik puchnie sekcjami `evaluator_review_2`, `generator_response_2`, itd.

**Wstrzykiwanie planu:** co 3-4 wymiany do każdego agenta wkleja się fragment `state/plan.md` z fragmentem dotyczącym tego sprintu (przeciwdziałanie utracie celu — sekcja 2 dokumentu źródłowego).

### Krok 4 — Konwergencja

Gdy obaj agenci wpisali `status: "accepted"`:

1. Plik rename: `sprint-{n}.draft.json` → `sprint-{n}.json`.
2. Hash gita w `state/breadcrumbs.json` jako artefakt.
3. Walidacja: `scripts/check-contract-coverage.sh {n}` MUSI zwrócić exit 0.

---

## 3. Anty-wzorce w negocjacji

| Anty-wzorzec | Co go zdradza | Riposta |
|---|---|---|
| **Generator akceptuje wszystko** | Brak kontrkrytyki, kontrakt zatwierdzony w 1 iteracji | Wymuś min. 3 iteracje. Generator MUSI odrzucić co najmniej jedno kryterium Evaluatora jako zbyt restrykcyjne LUB zaakceptować i uzasadnić. |
| **Evaluator pisze szczegółową rubrykę alone** | Brak `generator_response` w iteracjach | Negocjacja = dialog. Generator musi proponować, nie tylko reagować. |
| **Kryteria typu "kod jest czytelny"** | Brak `binary: true`, opisowy `check` | Odrzuć przed konwergencją. Każde kryterium musi być sprawdzalne skryptem LUB binarnym screenshotem (jest X na ekranie / nie ma). |
| **Pominięcie `out_of_scope`** | Pusta lista | Wymuś min. 3 wpisy. Scope Discipline jest jawne, nie domyślne. |
| **`max_iterations = 50`** | Generator próbuje uciec od pivota | Hard cap = 7. Wyższe wymaga eskalacji do human. |

---

## 4. Granularność — przykład dla "kreator gier retro" (z dokumentu źródłowego)

Pojedynczy sprint "edytor poziomu" miał 27 kryteriów. Wybrane z 4 kategorii:

**Funkcjonalność (binarna):**
- C-01: wciśnięcie strzałki w prawo przesuwa kursor o 1 kafel → `playwright.keyboard.press('ArrowRight')` + screenshot pre/post
- C-02: zapis poziomu generuje plik `levels/{name}.json` w 200ms → `fs.existsSync` + `performance.now`
- C-03: kolejność wywołań API: POST /save → GET /verify → 200 OK (nie odwrotnie — Prawo Hyruma)

**Layout (binarna):**
- C-10: brak nakładającego się tekstu — `playwright.locator('.title').boundingBox()` nie przecina `.subtitle.boundingBox()`
- C-11: paleta widoczna na ekranie 1920x1080 bez scrollowania

**Design (binarna z few-shot):**
- C-20: brak fioletowych gradientów (AI slop) — heurystyka: `getComputedStyle` na 5 losowych elementach, brak `linear-gradient.*purple|violet`
- C-21: czcionka headerów — `font-family` zawiera "Press Start 2P" lub "VT323" (retro vibe, nie sans-serif)

**Architektura (binarna):**
- C-30: zero stubów w finalnym module — `grep -r "TODO\|FIXME\|throw new Error('not implemented')" src/editor/` zwraca 0 linii
- C-31: zero `any` w TypeScript — `tsc --noImplicitAny` exit 0

---

## 5. Co Evaluator ocenia, a czego NIE ocenia

**Ocenia:** wyłącznie kontrakt wynegocjowany w fazie 3. NIE wysokopoziomowy plan Plannera.

**Nie ocenia:**
- Wewnętrznego rozumowania Generatora (kontekst Generatora nie wycieka do Evaluatora).
- "Pięknych" wyborów technicznych nie zapisanych w kontrakcie.
- Refaktoryzacji "przy okazji" — to leci pod Scope Discipline w fazie 6.

**Powód:** Evaluator z dostępem do rozumowania Generatora przestaje być niezależnym krytykiem — staje się collaboratorem. Patrz `references/role-mapping.md §isolation`.

---

## 6. Exit criterion fazy 3

```bash
scripts/check-contract-coverage.sh {n}
# musi zwrócić:
#   exit 0
#   "Contract sprint-{n}: 17 binary criteria, 5 edge cases, 3 out-of-scope items."
#   "All criteria machine-checkable: yes"
```

Brak exit 0 = brak prawa wejścia w fazę 4.
