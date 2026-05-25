---
name: testing-map
type: reference
parent: agent-teams-builder
sources:
  - DOC/material_skill.md §4 — Definition of Done (dowód zamiast deklaracji)
  - DOC/material_skill.md §5 — Beyoncé Rule, DAMP over DRY, piramida 80/15/5
  - DOC/since_skill.md §5 — Incremental Implementation + TDD RED-GREEN-REFACTOR + Prove-It Pattern (regresja)
  - DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §9 — Checklist gotowości (Beyoncé)
description: Mapa testów (unit / integration / regression) dla każdego walidatora i funkcjonalności skilla agent-teams-builder. Egzekwuje regułę „wytwarzasz funkcjonalność → wytwarzasz test" przy każdej modyfikacji skilla.
---

# Test Discipline — agent-teams-builder

> **Zakres:** meta-testy walidatorów i skryptów **samego skilla** (`scripts/` + procedura `SKILL.md`).
> **NIE w zakresie:** testy aplikacji, którą zespół agentów buduje (te zapewnia sub-agent `playwright-runner` + `references/library-currency-protocol.md`).

## Pryncypium (source: DOC/material_skill.md §5, DOC/since_skill.md §5)

> **Beyoncé Rule** — *„If you liked it, you should have put a test on it"*. Każdy walidator, każda faza, każdy breadcrumb-emitter MA test w `tests/run-meta-tests.sh`.
> **Piramida 80/15/5** — 80% unit (per walidator), 15% integration (cross-validator scenariusze na wspólnym `state/`), 5% E2E (workflow LLM nie jest deterministycznie testowalny → brak).
> **TDD RED-GREEN-REFACTOR** — failing fixture + `assert_exit` PRZED implementacją walidatora.
> **Prove-It Pattern (= test regresji)** — każdy bug walidatora → `tests/fixtures/regression-<short-desc>.<ext>` + `assert_exit` w runnerze, PRZED fixem.
> **DAMP over DRY** — nazwa fixture = scenariusz (`contract-broken-scales.json`, nie `bad-1.json`). Test czytelny jak specyfikacja.
> **DoD = dowód** — `bash tests/run-meta-tests.sh | tail -3` → surowy `X/X passed` wklejony do PR description.

## Definicje (w kontekście agent-teams-builder)

| Typ | Definicja | Lokalizacja | Konwencja nazwy |
|---|---|---|---|
| **Unit** | Jeden walidator vs jedna fixture, exit code check. `assert_exit` z GOOD (exit 0) lub BAD (exit ≠0). | `tests/run-meta-tests.sh` + `tests/fixtures/<komponent>-<scenariusz>.<json\|md>` | `<komponent>-<scenariusz>` (np. `contract-broken-scales.json`) |
| **Integration** | ≥2 walidatorów na wspólnym `state/` przez `setup_*` helper. Testuje współdziałanie (np. breadcrumbs + verify-approval-gates). | `tests/run-meta-tests.sh` — sceny z `setup_temp_state` / `setup_breadcrumbs` / `setup_plan` przed `assert_exit` | Opis scenariusza w `assert_exit "desc..."` |
| **Regression** | Fixture odtwarzająca historyczny bug walidatora. Każdy bug → nowa fixture + assert_exit. | `tests/fixtures/regression-<short-desc>.<ext>` | `regression-<short-desc>` (np. `regression-empty-breadcrumb-array.json`) |

## Mapa walidatorów → testy

| Walidator (`scripts/`) | Funkcjonalność | Unit (fixtures) | Integration (sceny) | Regression | Status |
|---|---|---|---|---|---|
| `check-contract-coverage.sh` | Kontrakt sprintu: ≥15 binarnych kryteriów, brak skal 1-10 | `contract-complete.json`, `contract-broken-scales.json`, `contract-broken-too-few.json` | — | — | ✅ |
| `verify-evaluator-rubric.sh` | Few-shot examples + `status: passed` + binarne kryteria | (via `setup_temp_state`) | rubric + contract scena | — | ✅ |
| `verify-plan-rigor.sh` | 11 sekcji planu + 3 hipotezy/sprint + Hyrum Impact + Rollback | `plan-rigorous.md`, `plan-shallow.md`, `plan-empty-open-questions.md`, `plan-complete.md` | — | — | ✅ |
| `check-breadcrumbs-append-only.sh` | Schema breadcrumbs + immutability (append-only) | `breadcrumbs-valid.json`, `breadcrumbs-broken-schema.json`, `breadcrumbs-tampered.json` | git-diff scena | — | ✅ |
| `verify-library-currency.sh` | Każda paczka w `package.json` ma breadcrumb `library_currency_checked` | `breadcrumbs-with-currency-check.json`, `breadcrumbs-missing-currency.json` | — | — | ✅ |
| `verify-documentation.sh` | PRD + retrospective + Five-Axis CR + ADR + TODO + QA per passed sprint | `feature_list-with-docs.json`, `feature_list-passed-no-docs.json` | — | — | ✅ |
| `verify-approval-gates.sh` | 6 bramek HITL domknięte (#1-#6) + prawidłowa kolejność | — | Group 9 (3 cases): "GATE #1 + GATE #3 → exit 0", "spawn bez #1 + sprint passed bez #3 → exit ≠0", "YOLO auto-approved (actor=yolo) → exit 0" | — | ✅ |
| `verify-role-isolation.sh` | Per-rola `.claude/agents/*.md`, brak Edit dla Evaluatora, brak Playwright dla Generatora | — | Group 5 (2 cases): `agents/` good + sztuczne złamanie izolacji (Playwright dodany do Generatora) | — | ✅ |
| `verify-non-negotiables.sh` | 5 zasad: assumptions, brak open blockerów, evidence per passed, scope, plan-review | `plan-complete.md` (Open Questions wypełnione) | Group 4 (2 cases, via `setup_plan` na plan + breadcrumbs): plan-complete → exit 0, plan-empty-open-questions → exit ≠0 | — | ✅ |
| `init-docs-structure.sh` | Bootstrap `state/prd/` + `docs/adr/` (tworzy strukturę audit-trail) | exit 0 + post-check że katalogi powstały | (część DOCUMENTATION group, 1 case) | — | ✅ |
| `check-evidence-completeness.sh` | Każdy passed sprint ma plik dowodowy w `state/evidence/` | — | (TODO retrofit) | — | ⏳ |
| `check-scope-discipline.sh` | Diff per sprint zawiera tylko pliki ze sprint scope | — | (TODO retrofit) | — | ⏳ |
| `append-breadcrumb.sh`, `append-session-log.sh` | Bezpieczny append + schema validation | — | (wywoływane pośrednio przez `setup_breadcrumbs` w innych grupach — brak osobnego case) | — | ⏳ |
| `init-team-state.sh`, `setup-context7.sh` | Bootstrap state/ + MCP context7 | — | — | — | ⏳ (test = `mkdir` + grep produced) |
| `smoke-test-runner.sh`, `pivot-trigger.sh`, `run-goal-loop.sh` | Drivery (nie pure validatory) | — | — | — | ⏳ (test = exit codes per arg combination) |

**Stan ogółem (2026-05-25 snapshot, po code review fakt-checku):**
- **10 / 19 walidatorów ma unit testy** (53%) — `check-contract-coverage`, `verify-evaluator-rubric`, `verify-plan-rigor`, `check-breadcrumbs-append-only`, `verify-library-currency`, `verify-documentation`, `verify-approval-gates`, `verify-role-isolation`, `verify-non-negotiables`, `init-docs-structure`.
- **3 walidatory mają integration tests** — `verify-approval-gates` (Group 9, sceny z `setup_breadcrumbs`), `verify-non-negotiables` (Group 4, scena z `setup_plan` łącząca plan + breadcrumbs), `verify-documentation` (Group 8 + init-docs-structure dla bootstrap structures).
- **22 / 22 test cases passed** w runnerze (DoD evidence: `bash tests/run-meta-tests.sh | tail -3`).
- **0 regression fixtures** (zero historycznych bugów walidatorów uchwyconych jako fixtures w `tests/fixtures/regression-*`).
- **9 walidatorów TODO retrofit** — kolejność priorytetowa: `check-evidence-completeness` → `check-scope-discipline` → `append-breadcrumb` → `append-session-log` → drivers (`run-goal-loop`, `smoke-test-runner`, `pivot-trigger`) → bootstrap (`init-team-state`, `setup-context7`).

## Procedura: dodawanie nowego walidatora lub funkcjonalności

> Egzekwowane przez Beyoncé Rule + Anti-Rat „pominę test runnerowy".

1. **Spec** — opisz funkcjonalność w SKILL.md (faza N) / PRD: co waliduje, exit codes, struktura input.
2. **RED** — utwórz `tests/fixtures/<komponent>-good.<ext>` (GOOD scenario) + `<komponent>-bad-<typ>.<ext>` (≥1 BAD scenario per typ błędu, ≥2 dla walidatorów z >1 wariantem failu). Dodaj w `tests/run-meta-tests.sh`:
   ```sh
   assert_exit "<komponent>: good → exit 0" "0" \
     bash "$SCRIPTS/<walidator>.sh" "$FIXTURES/<komponent>-good.<ext>"
   assert_exit "<komponent>: <typ błędu> → exit ≠0" "nonzero" \
     bash "$SCRIPTS/<walidator>.sh" "$FIXTURES/<komponent>-bad-<typ>.<ext>"
   ```
3. **Uruchom runner** — `bash tests/run-meta-tests.sh`. Nowe cases MUSZĄ failować (RED — implementacja jeszcze nie istnieje).
4. **Implementacja** — minimalny kod walidatora.
5. **GREEN** — `bash tests/run-meta-tests.sh` → wszystkie cases zielone (`(X+N)/(X+N) passed`).
6. **Integration test** — jeśli walidator współpracuje z innymi (czyta `state/`, breadcrumbs, gates): dodaj scenę z `setup_*` przed `assert_exit`.
7. **Update** `references/testing-map.md` — wiersz w tabeli z ścieżką do fixtures + Status ✅.
8. **Update** `CHANGELOG.md` skilla — `+N test cases, walidator: <nazwa>`.

**Exit criterion:** wklejony surowy output `bash tests/run-meta-tests.sh | tail -3` do PR description pokazuje `X/X passed`.

## Procedura: fix buga w walidatorze (Prove-It = test regresji, source: DOC/since_skill.md §5)

1. **Reprodukcja** — utwórz `tests/fixtures/regression-<short-desc>.<ext>` odtwarzającą buga (input który walidator nieprawidłowo obsługuje).
2. **RED — failing reproducer w runnerze** — dodaj:
   ```sh
   assert_exit "regression: <short-desc> → <expected behavior>" "<0|nonzero>" \
     bash "$SCRIPTS/<walidator>.sh" "$FIXTURES/regression-<short-desc>.<ext>"
   ```
   Uruchom runner — ten case MUSI failować (potwierdza istnienie buga).
3. **Fix** — minimalny kod w walidatorze. Bez zmian w innych walidatorach (Scope Discipline).
4. **GREEN** — runner → nowy case zielony + wszystkie pozostałe cases nadal zielone (`(X+1)/(X+1) passed`, zero regresji).
5. **Update** `testing-map.md` — kolumna Regression dla walidatora oznaczona z linkiem do fixture.
6. **Update** `CHANGELOG.md` — `### Fixed — <bug desc>. Regression test: tests/fixtures/regression-<short-desc>.<ext>`.

**Exit criterion:** runner przechodzi z dodanym regression case. Hashed evidence: `git log -1 --format=%H tests/fixtures/regression-<short-desc>.<ext>` + line z passed runner.

## Anti-Rationalization (testowanie meta-testów)

| Wymówka | Riposta (blokada) | Źródło |
|---|---|---|
| „Walidator jest 5-liniowy, test = ceremonia" | Odrzucono. **Beyoncé Rule.** 5 linii też zasługuje na test. Bez `assert_exit` walidator nie ma DoD evidence i może milcząco regresować. | DOC/material_skill.md §5 |
| „Dodaję walidator bez fixture — uruchomię ręcznie i potwierdzę" | Odrzucono. **DoD = dowód, nie deklaracja.** Bez fixture w `tests/fixtures/` + `assert_exit` w runnerze nie ma reproducibility. Ręczne uruchomienie ≠ regresja przy następnej zmianie. | DOC/material_skill.md §4 |
| „Bug fix bez regression fixture — naprawione, lecę" | Odrzucono. **Prove-It Pattern.** Bez `regression-*.<ext>` + failing assert_exit PRZED fixem ten sam bug wróci za 6 miesięcy bez ostrzeżenia. Test regresji jest nienegocjowalny dla każdego fixa walidatora. | DOC/since_skill.md §5 |
| „Walidator nie współpracuje z innymi, integration test zbędny" | Sprawdź ponownie. Czyta `state/`? Pisze breadcrumbs? Reaguje na gate? Wtedy MA cross-validator dependencies → integration scena z `setup_*`. 15% piramidy = minimum, nie maximum. | DOC/since_skill.md §5 |
| „Helper `setup_temp_state` jest spaghetti, refaktoryzuję DRY" | Odrzucono. **DAMP over DRY w testach.** Każda fixture czytelna jak spec. Cofnij abstrakcję jeśli ukrywa input testu. | DOC/material_skill.md §5 |
| „Skopiuję istniejącą fixture pod nowy walidator — szybciej" | Sprawdź czy nazwa odpowiada scenariuszowi. Nazwa = scenariusz (DAMP). `contract-broken-scales.json` ≠ `contract-good.json` ≠ generic `bad.json`. | DOC/material_skill.md §5 |

## DoD per zmiana (egzekwowane w `## Definition of Done` SKILL.md)

- [ ] Nowa funkcjonalność lub walidator: ≥1 unit test (GOOD + ≥1 BAD fixture).
- [ ] Walidator z cross-validator zależnościami: ≥1 integration scena w runnerze.
- [ ] Fix buga: regression fixture `tests/fixtures/regression-*.<ext>` + assert_exit case.
- [ ] `bash tests/run-meta-tests.sh` → `X/X passed` z wzrostem X o liczbę dodanych cases (DoD evidence wklejony do PR description).
- [ ] `references/testing-map.md` zaktualizowana — wiersz funkcjonalności + Status.
- [ ] `CHANGELOG.md` skilla: `+N test cases` lub `regression test: <name>`.

## Reguła ładowania (Progressive Disclosure)

> Załaduj `references/testing-map.md` zawsze gdy:
> - dodajesz/modyfikujesz walidator w `scripts/` (Phase 6 Verify, Phase 7 Ship)
> - dodajesz/modyfikujesz fazę w `SKILL.md` (Phase 0-7)
> - fix buga w walidatorze (Phase 5 Pivot lub bug-fix sprint)
> - audyt DoD przed bramką (#6 Ship — `verify-approval-gates.sh` exit 0 nie wystarczy; spójrz na pokrycie testowe w mapie)
> - retrospective sprintu — czy walidatory dotknięte w sprincie mają zaktualizowane testy?
