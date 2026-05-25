# CHANGELOG — feature-planner-v3

> Wersje przed wprowadzeniem semver zrekonstruowane z historii git (backfill).
> Major `v3` to generacja wariantu (senior-grade) — koegzystuje z `feature-planner` (v2).

## [v3.2.0] — 2026-05-25 — Test Discipline (mapa unit/integration/regression dla skryptów v3)

### Added

- **`references/testing-map.md`** — mapa meta-testów (**unit / integration / regression**) per skrypt v3 (`scripts/*.sh` × 7). Rozróżnia dwa piętra testowania:
  - **`testing-protocol.md`** (istniejący) → testy aplikacji wytwarzanej przez skill (Phase 7: 7 scopes × S/M/L, AC↔Test, raw log).
  - **`testing-map.md`** (nowy) → meta-testy **samego skilla** (czy `check-pr-size.sh` poprawnie klasyfikuje diff, czy `api-impact-scan.sh` nie myli breaking ↔ additive, etc.).
- **Wykryty rozjazd:** 0 / 7 skryptów v3 ma meta-testy. Fixtures `complete-plan.md` / `incomplete-plan.md` istnieją w `tests/fixtures/` (commit `7947066`) ale są **martwe** — żaden skrypt v3 ich nie wywołuje. Mapa zawiera **TODO retrofitting** z kolejnością priorytetową (1: utworzyć `tests/run-meta-tests.sh` wzorcem a-t-b → 2: `check-pr-size.sh` retrofit → 3: `check-ac-coverage.sh` retrofit → reszta).
- **2 wiersze Anti-Rationalization quick-table** (#12, #13) — wymówki specyficzne dla meta-testów skryptów v3:
  - #12: „Skrypt v3 jest deterministyczny, meta-test zbędny" → Beyoncé Rule dla samego skilla.
  - #13: „Bug w skrypcie v3 — fix, regresji nie dorabiam" → Prove-It Pattern dla skryptu (analog Phase 6.5 ale dla walidatora).
- **1 checkbox w DoD Phase 7** — „Meta-testy skryptów v3 (Beyoncé Rule dla samego skilla)".
- **1 wpis w Indeks referencji** — `testing-map.md` z regułą ładowania.

### Why

User feedback: „jak coś wytwarzasz to tworzysz testy". v3 miał już rygor TDD w Phase 6 (failing test PRZED implementacją) + Phase 6.5 Prove-It dla bugów aplikacji, ALE brakowało analogu dla samego skilla (skryptów-bramek). Bramka Phase 6 (`check-pr-size`) lub Phase 7 (`verify-build-clean`) może milcząco regresować przy refaktorze, jeśli sam skrypt nie ma testu.

### Sources

- DOC/material_skill.md §4 (DoD = dowód), §5 (Beyoncé Rule, DAMP, piramida 80/15/5)
- DOC/since_skill.md §5 (TDD RED-GREEN-REFACTOR + Prove-It Pattern = test regresji)
- DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §9, §10

---

## [v3.1.0] — 2026-05-13 — `/goal` mode

### Added

- **Tryb `/goal`** — autonomiczna pętla weryfikacji AC z mierzalnym stopem:
  - **Phase 5.8** + **Gate #1.5** (Goal Mode decision) + **6-Goal sub-route** w Phase 6.
  - `scripts/derive-goal-from-ac.sh` — parsowanie tabeli AC → goal-statement + goal-prompt.
  - `scripts/run-goal-loop.sh` — driver pętli weryfikacyjnej (dry-run + hand-off).
  - `references/goal-mode-protocol.md` (10 sekcji) + Anti-Rat #11.
  - Fixtures: `complete-plan.md` + `incomplete-plan.md`.
- `/goal` wyłączny z `/ralph` i `/teams`; fragile zone → hard stop.

### Fixed

- Hardening po Five-Axis Review: cytowanie ścieżek w wygenerowanych komendach, dup check tylko dla valid AC-ID, usunięty martwy STRICT, rule 7 / constraints-count / status emitter.

---

## [v3.0.0] — 2026-05-12 — initial release (senior-grade)

### Added

- Senior-grade skill z deterministyczną uprzężą inżynieryjną (18 plików, ~4200 linii): SKILL.md (≤500 hard limit), 12 referencji, 5 skryptów POSIX.
- 15-wpisowa Anti-Rationalization Table, twardy DoD z surowymi artefaktami, PR Sizing (100/300/1000), Hyrum's Law, Chesterton's Fence, Beyoncé Rule 1:1 AC↔Test, DAMP over DRY, Five-Axis Review, Plan-Validate-Execute, Thin Vertical Slices, Prove-It Pattern.
