# CHANGELOG — agent-teams-builder

## [v1.3.0] — 2026-05-20 — Google DNA compliance (Chesterton + Hyrum + Beyoncé + DAMP)

### Added (z auditu pryncypiów)

- **SKILL.md** — 4 nowe wymówki w tabeli anty-racjonalizacji obejmujące Google DNA:
  - Chesterton's Fence ("wyrzucam ten test — wygląda na martwy")
  - Hyrum's Law ("zmieniam sygnaturę helpera — nikt nie korzysta")
  - Beyoncé Rule ("pominę test, fix to 5 linii")
  - DAMP > DRY ("wyodrębniłem helper z 3 testów")
- **references/anti-rationalization.md §5** — nowa sekcja "Google DNA" z 6 wymówkami i ripostami obejmującymi 4 zasady inżynieryjne z material_skill.md §5.

### Why

Audit pryncypiów wykrył lukę: SKILL.md odwoływał się do Beyoncé Rule (w DoD) i Hyruma (w referencjach), ale **Chesterton's Fence nie był nigdzie wspomniany**. To 1 z 4 elementów Google DNA z material_skill.md §5 — krytyczne dla skilla orkiestrującego pivot (gdzie kasowanie kodu jest standardową operacją).

---

## [v1.2.0] — 2026-05-20 — meta-tests & fixtures

### Added

- **tests/fixtures/** — 7 fixtures testowych dla walidatorów skilla:
  - `contract-complete.json` (GOOD — 15 binarnych kryteriów, accepted)
  - `contract-broken-scales.json` (BAD — kryteria w skali 1-10)
  - `contract-broken-too-few.json` (BAD — 8 < 15 kryteriów)
  - `breadcrumbs-valid.json` (GOOD — append-only, chronologiczny)
  - `breadcrumbs-broken-schema.json` (BAD — wpisy bez wymaganych pól)
  - `plan-complete.md` (GOOD — Open Questions wypełnione)
  - `plan-empty-open-questions.md` (BAD — Non-negotiable #1 złamane)
- **tests/run-meta-tests.sh** — uruchamia walidatory na fixtures i sprawdza exit codes (GOOD → 0, BAD → ≠0). Test 11 przypadków w 5 grupach: check-contract-coverage, verify-evaluator-rubric, check-breadcrumbs-append-only, verify-non-negotiables, verify-role-isolation.

### Fixed

- **`scripts/check-breadcrumbs-append-only.sh`** — bug `set -e -o pipefail` aborts skrypt gdy `grep -E "^-"` nie znajduje matchu na pustym git diff. Fix: `set +o pipefail` w fragmencie z pipe, `set -o pipefail` po. Wykryto przez nowy `run-meta-tests.sh`.

### Test results

- `bash tests/run-meta-tests.sh` → **11/11 passed**.

---

## [v1.1.0] — 2026-05-19 — code review fixes

### Fixed (z review po v1.0.0)

- **[CRITICAL] Brak integracji z Claude Code Agent Teams API.**
  - Dodano katalog `agents/` z 3 gotowymi definicjami sub-agentów (`planner.md`, `generator.md`, `evaluator.md`) w formacie Claude Code: frontmatter z `name`, `description`, `tools`, `model` + system prompt w body.
  - SKILL.md faza 2 przepisana — konkretna instrukcja `cp` do `.claude/agents/` + wywołanie przez `Task(subagent_type:...)`.
  - `assets/prompt-templates.md` zaktualizowane — przekierowuje do `agents/` zamiast fikcyjnej lokalizacji `prompts/`.
- **[BUG] 8 martwych odwołań do nieistniejących skryptów.** Zastąpione inline-komendami lub odwołaniem do istniejących skryptów:
  - `scripts/verify-build-clean.sh` → inline `npm run build 2>&1 | tee ...`
  - `scripts/check-beyonce.sh` → heurystyka `git diff` + grep tests
  - `scripts/check-pr-size.sh` → inline `git diff --stat`
  - `scripts/check-state-schema.sh` → odwołanie do `verify-non-negotiables.sh` + `jq empty`
  - `scripts/check-goal-spec.sh` + `scripts/derive-goal-from-ac.sh` → inline w parent agencie (parsing prompta)
  - `scripts/check-test-pyramid.sh`, `scripts/append-changelog.sh` → usunięte z procedury (CHANGELOG ręczny, piramidę testów audytuje review)
- **[BUG] Dead link `references/five-axis-review.md`.** Zastąpione delegacją do `feature-planner-v3` (jeśli zainstalowany) — Five-Axis Review nie jest core mechanizmem tego skilla.
- **[BUG] `verify-role-isolation.sh` szukało w `prompts/`.** Naprawione — szuka w `.claude/agents/` (standard Claude Code), fallback do `prompts/` (legacy).

### Tested

- `scripts/verify-role-isolation.sh` testowany na gotowych `agents/*.md` → exit 0 (wszystkie 3 role poprawnie izolowane).

## [v1.0.0] — 2026-05-19

### Added

- Initial release: dev/agent-teams-builder/ — orkiestracja Generator-Ewaluator dla zadań programistycznych.
  - 7-fazowa procedura (bootstrap → ship) z exit criteria.
  - 10 protokołów referencyjnych z progresywnym ładowaniem.
  - 12 skryptów deterministycznych (init, smoke, pivot, walidatory).
  - Tryb /goal z auto-pivotem.
  - Source: DOC/agent-teams-generator-ewaluator.md, DOC/material_skill.md §8, DOC/since_skill.md.
