---
name: testing-map
type: reference
parent: audited-feature-workflow
sources:
  - DOC/material_skill.md §4 — Definition of Done (dowód zamiast deklaracji)
  - DOC/material_skill.md §5 — Beyoncé Rule, DAMP over DRY, piramida 80/15/5
  - DOC/since_skill.md §5 — Incremental Implementation + TDD RED-GREEN-REFACTOR + Prove-It Pattern (regresja)
  - DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §9 — Checklist gotowości (Beyoncé)
description: Mapa testów (unit / integration / regression) dla każdego skryptu i funkcjonalności skilla audited-feature-workflow. Egzekwuje regułę „wytwarzasz funkcjonalność → wytwarzasz test" przy każdej modyfikacji skilla.
---

# Test Discipline — audited-feature-workflow

> **Zakres:** meta-testy skryptów-bramek i exit-criteriów **samego skilla** (`scripts/` + fazy `SKILL.md`).
> **NIE w zakresie:** testy aplikacji, którą skill buduje (Phase 7 — 7 scopes × S/M/L, patrz [`testing-protocol.md`](testing-protocol.md)).
>
> **`testing-protocol.md` vs `testing-map.md`** — dwa różne piętra:
> - `testing-protocol.md` → testy aplikacji wytwarzanej (Phase 7 routes, AC↔Test, raw log).
> - `testing-map.md` (ten plik) → testy skryptów-bramek samego skilla.

## Pryncypium (source: DOC/material_skill.md §5, DOC/since_skill.md §5)

> **Beyoncé Rule** — każdy `scripts/*.sh` MA fixture i `assert_exit` w runnerze.
> **Piramida 80/15/5** — 80% unit (per skrypt), 15% integration (np. derive-goal → run-goal-loop chain), 5% E2E LLM (nieosiągalne deterministycznie → poza scope).
> **TDD RED-GREEN-REFACTOR** — failing fixture + assert_exit PRZED implementacją skryptu.
> **Prove-It Pattern (= test regresji)** — każdy bug skryptu → `tests/fixtures/regression-<short-desc>.<ext>` + failing assert_exit, PRZED fixem.
> **DAMP over DRY** — nazwa fixture = scenariusz (`pr-size-over-1000.diff`, nie `bad-1.diff`).
> **DoD = dowód** — `bash tests/run-meta-tests.sh | tail -3` → surowy `X/X passed`.

## Definicje (w kontekście audited-feature-workflow)

| Typ | Definicja | Lokalizacja | Konwencja nazwy |
|---|---|---|---|
| **Unit** | Jeden skrypt vs jedna fixture, exit code + stdout/JSON check. | `tests/run-meta-tests.sh` (runner istnieje) + `tests/fixtures/<komponent>-<scenariusz>.<ext>` | `<komponent>-<scenariusz>` (np. `ac-coverage-incomplete-mapping.md`) |
| **Integration** | Chain ≥2 skryptów (np. `derive-goal-from-ac.sh` produkuje `goal-statement.md`, który zżywa `run-goal-loop.sh`). | `tests/run-meta-tests.sh` — sceny z pipeline | Opis scenariusza |
| **Regression** | Fixture odtwarzająca historyczny bug skryptu. | `tests/fixtures/regression-<short-desc>.<ext>` | `regression-<short-desc>` |

## Mapa skryptów → testy

| Skrypt (`scripts/`) | Funkcjonalność | Unit (fixtures) | Integration | Regression | Status |
|---|---|---|---|---|---|
| `check-pr-size.sh` | PR sizing gate: ≤100 OK, ≤300 z uzasadnieniem, >1000 hard stop | (TODO) `pr-size-under-100.diff`, `pr-size-200-500.diff`, `pr-size-over-1000.diff` | — | — | ✅ |
| `verify-build-clean.sh` | Auto-detect stack (package.json/Cargo/pyproject/go.mod), exit 0 + zero warnings | (TODO) `build-clean-node.tar`, `build-warning-node.tar`, `build-error-node.tar` | stack auto-detect scena (4 fixtures) | — | ✅ |
| `check-ac-coverage.sh` | 1:1 AC ↔ Test mapping per plan; każdy AC ma test, każdy test ma plik | (TODO) `complete-plan.md` (już istnieje, martwy), `incomplete-plan.md` (już istnieje, martwy), `ac-coverage-missing-test-file.md`, `ac-coverage-orphan-test.md` | — | — | ✅ |
| `extract-raw-log.sh` | Run cmd, capture last N lines + status, emit Markdown code block | (TODO) `cmd-success.sh`, `cmd-fail-with-stderr.sh`, `cmd-timeout.sh` | — | — | ✅ |
| `api-impact-scan.sh` | Hyrum scan: public exports vs BASE → breaking/additive/internal + callerzy | (TODO) `api-impact-breaking.diff`, `api-impact-additive.diff`, `api-impact-internal-only.diff` | git diff scena | — | ✅ |
| `derive-goal-from-ac.sh` | Parser AC + generator `goal-statement.md` + `goal-prompt.txt` | (TODO) `complete-plan.md` (istnieje), `incomplete-plan.md` (istnieje), `ac-malformed-table.md` | derive → run-goal-loop chain | — | ✅ |
| `run-goal-loop.sh` | Pure validator/driver: 1 invocation = 1 iteracja, emit GREEN/NEEDS_AGENT_ITERATION; caps iter/time maszynowe (state file) | `goal-statement-valid.md`, `goal-statement-no-weryfikacja.md`, `goal-statement-chaining.md` | dry-run + caps (iter/time) scenariusze | seed state iter=99 / start_epoch=1 | ✅ |
| `check-env-detection.sh` | Gate Phase 0: env-detection.md kompletny (6 pól) | `env-detection-complete.md`, `env-detection-missing-fields.md` | — | — | ✅ |
| `check-analysis-report.sh` | Gate Phase 1: raport + sekcje core + Open questions rozwiązane | `analysis-complete.md`, `analysis-open-questions.md` | — | — | ✅ |
| `check-hypotheses.sh` | Gate Phase 2+3: ≥3 hipotezy (Minimal/Idiomatic/Ambitious) + Recommendation | `hypotheses-complete.md`, `hypotheses-missing-ambitious.md` | — | — | ✅ |
| `check-screenshots.sh` | Gate Phase 7.8: screenshot per AC-F | `screenshots-plan.md` + dir setup w runnerze | — | — | ✅ |
| `check-adr.sh` | Gate Phase 9: sekcje ADR obowiązkowe (Context/Decision/Anti-rationalization/Consequences) | `adr-complete.md`, `adr-missing-consequences.md` | — | — | ✅ |

**Stan ogółem (2026-05-29 snapshot, v3.4.0):**
- **12 / 12 skryptów ma unit testy** (runner `tests/run-meta-tests.sh` ISTNIEJE — 30 case'ów GOOD/BAD)
- Integration: scenariusze dry-run + caps (iter/time przez state file) dla `run-goal-loop.sh`
- Regression: dodawane wg procedury Prove-It (sekcja niżej) per bug skryptu
- `complete-plan.md`/`incomplete-plan.md` — **ożywione** (wywoływane przez derive-goal fixtures w runnerze)
- DoD: `bash tests/run-meta-tests.sh` → `30/30 passed`, exit 0
- Bramki Phase 0–9 mają deterministyczne walidatory pokryte meta-testami → brak ryzyka cichych regresji

## Retrofitting — ZREALIZOWANE (2026-05-29, v3.4.0)

> Runner `tests/run-meta-tests.sh` istnieje; 12/12 skryptów ma meta-testy (`30/30 passed`).
> 5 nowych skryptów-bramek (Phase 0/1/2/3/7.8/9) + caps maszynowe w `run-goal-loop.sh`.
> Poniższa lista pozostaje jako log historyczny pierwotnej kolejności.

### Pierwotna kolejność (log)

1. **`tests/run-meta-tests.sh`** — skopiuj wzorzec z `dev/agent-teams-builder/tests/run-meta-tests.sh` (POSIX-friendly: `#!/usr/bin/env bash`, `set -uo pipefail`, `assert_exit`, helpers).
2. **`check-pr-size.sh`** — najprostszy do retrofittingu (input: ścieżka diff lub git refs). Daj 3 GOOD/BAD fixtures (under-100, 200-500, over-1000). Priorytet #1.
3. **`check-ac-coverage.sh`** — fixtures `complete-plan.md` / `incomplete-plan.md` już są (commit `7947066`). Dorzuć runner case + 2 nowe fixtures (missing-test-file, orphan-test). Priorytet #2.
4. **`api-impact-scan.sh`** — fixtures jako mini-git-repo z diff per scenariusz. Priorytet #3.
5. Reszta (`verify-build-clean`, `extract-raw-log`, `derive-goal-from-ac`, `run-goal-loop`) — po retrofittingu top 3.

## Procedura: dodawanie nowego skryptu lub funkcjonalności

> Egzekwowane przez Beyoncé Rule + Anti-Rat „skrypt v3 bez testu".

1. **Spec** — w SKILL.md (faza N) lub references/*: co liczy/waliduje, exit codes, input/output.
2. **RED** — utwórz `tests/fixtures/<komponent>-good.<ext>` + `<komponent>-bad-<typ>.<ext>`. Dodaj `assert_exit` w `tests/run-meta-tests.sh` (utwórz runner jeśli nie istnieje, wzorzec: a-t-b).
3. **Implementacja** — minimalny kod skryptu (POSIX shell, `#!/bin/sh`, `set -eu`).
4. **GREEN** — `bash tests/run-meta-tests.sh` → wszystkie cases passed.
5. **Integration** — jeśli skrypt łączy się z innym (np. derive → run-goal-loop): pipeline scena z `setup_*`.
6. **Update** `testing-map.md` + `CHANGELOG.md`.

**Exit criterion:** runner output `X/X passed` wklejony do PR description.

## Procedura: fix buga w skrypcie (Prove-It = test regresji, source: DOC/since_skill.md §5)

1. **Reprodukcja** — `tests/fixtures/regression-<short-desc>.<ext>`.
2. **RED w runnerze** — `assert_exit "regression: <desc> → exit <expected>" "<0|nonzero>" bash "$SCRIPTS/<skrypt>.sh" "$FIXTURES/regression-<short-desc>.<ext>"`. Uruchom — case failuje.
3. **Fix** — minimalny kod w skrypcie.
4. **GREEN** — runner → nowy case zielony + reszta nadal zielona.
5. **Update** `testing-map.md` (kolumna Regression) + `CHANGELOG.md` (`### Fixed — <bug>`).

## Anti-Rationalization (testowanie meta-testów v3)

| Wymówka | Riposta (blokada) | Źródło |
|---|---|---|
| „v3 i tak ma rygorystyczne bramki w SKILL.md, walidator testu nie potrzebuje" | Odrzucono. **Beyoncé Rule.** Bramka opisana w prozie ≠ bramka, której deterministyczność jest udowodniona. Bez meta-testu walidator może milcząco regresować przy refaktorze. | DOC/material_skill.md §5 |
| „Fixtures są — `complete-plan.md` istnieje" | Odrzucono. Fixture bez runnera = martwy plik. Test = (fixture + assert_exit + runner). Wszystkie 3 wymagane. | DOC/material_skill.md §4 |
| „Bug w `check-pr-size.sh` → fix, regression później" | Odrzucono. **Prove-It Pattern.** Bez `regression-<bug>.diff` + failing assert_exit PRZED fixem ten sam bug wróci. Test regresji nienegocjowalny. | DOC/since_skill.md §5 |
| „v3 dziedziczy testy z replit-style-workflow (v2)" | Odrzucono. Wygodny wariant nie ma żadnych meta-testów (`dev/replit-style-workflow/tests/` nie istnieje). Dziedziczenie z pustego = pusta uprząż. | sprawdź `ls dev/replit-style-workflow/` |
| „Skrypty są krótkie, testy ich nie usprawiedliwiają" | Odrzucono. Krótki skrypt z błędną klasyfikacją (np. `api-impact-scan.sh` myli breaking↔additive) kaskaduje przez cały Phase 1.5 → 6 → 9. | DOC/material_skill.md §5 (Hyrum) |

## DoD per zmiana (egzekwowane w `## Definition of Done` SKILL.md)

- [ ] Nowy skrypt lub fix bramki: ≥1 unit test (GOOD + ≥1 BAD fixture w `tests/fixtures/`).
- [ ] Skrypt z chain dependency (np. derive → run-goal-loop): integration scena w runnerze.
- [ ] Fix buga: regression fixture + assert_exit case (Prove-It).
- [ ] `bash tests/run-meta-tests.sh` → `X/X passed` (runner musi istnieć — zacznij od retrofittingu, kroki 1-2 w TODO).
- [ ] `references/testing-map.md` zaktualizowana.
- [ ] `CHANGELOG.md` v3: `+N test cases` lub `regression test: <name>`.

## Reguła ładowania (Progressive Disclosure)

> Załaduj `references/testing-map.md` zawsze gdy:
> - dodajesz/modyfikujesz skrypt w `scripts/` (Phase 1.5, 6, 7, 8)
> - dodajesz/modyfikujesz fazę z bramką (Phase 5 GATE #1, 6 GATE #2, 7 GATE #3, 7.8 GATE #4, 8 GATE #5)
> - fix buga w skrypcie (Phase 6.5 Prove-It Pattern — analogicznie, ale dla samego skryptu, nie testowanej aplikacji)
> - retrospective po sprincie v3 — czy dotknięte skrypty mają zaktualizowane testy?
