# CHANGELOG — agent-teams-builder

## [v1.7.1] — 2026-05-20 — Planning = effort max (ultrathink)

### Changed

- **Faza 1 (Planner) pracuje z maksymalnym budżetem rozumowania.** Planowanie to faza o najwyższej dźwigni — błąd kaskaduje przez godziny pracy N agentów, więc nie wolno optymalizować jej pod szybkość.
  - `SKILL.md` Faza 1 — nowy callout „Planning = effort max (ultrathink)" + prompt spawnu Plannera zaczyna się od `ultrathink`. Przykład `Task()` w Fazie 2 prependuje `ultrathink`.
  - `agents/planner.md` — nowa reguła na starcie roli: praca z maksymalnym budżetem rozumowania, głęboka analiza przed każdą hipotezą / klasyfikacją Hyrum / wyborem architektury.

## [v1.7.0] — 2026-05-20 — Approval Gates Protocol (6 bramek human-in-the-loop, transfer z feature-planner-v3)

### Added

Pełny mechanizm **6 bramek akceptacji człowieka** (human-in-the-loop) przeniesiony z `feature-planner-v3`. Proces ZATRZYMUJE się na każdej bramce i czeka na jawną frazę akceptującą — **także w trybie `/goal`** (decyzja projektowa: wszystkie bramki aktywne, `/goal` je respektuje).

**6 bramek mapowanych na fazy:**
- **GATE #1 — Plan** (po Fazie 1, przed spawnem) — `state/plan.md` + PRD.
- **GATE #2 — Kontrakty** (po Fazie 3, przed pętlą) — `state/contracts/sprint-{n}.json`.
- **GATE #3 — Sprint** (po każdym sprincie w Fazie 4) — `state/sprint-reports/sprint-{n}.md`.
- **GATE #4 — QA/Runtime** (po QA playwright) — `state/qa-reports/sprint-{n}.md` + screenshoty per AC-F.
- **GATE #5 — Code Review** (Faza 6) — `docs/code-reviews/CR-sprint-{n}-*.md`, zero Critical.
- **GATE #6 — Ship** (Faza 7, przed `git tag`) — `state/final-report.md`.

### New files

- **`references/approval-gates-protocol.md`** — pełny protokół: mapa bramek, protokół STOP, checklisty per bramka, whitelist fraz akceptujących, interakcja z `/goal`, anti-rationalization, red flags.
- **`assets/sprint-report-template.md`** — raport o **wykonaniu sprintu** prezentowany na GATE #3 (executive summary + wynik kryteriów + evidence + rekomendacja Evaluatora). Odrębny od retrospektywy.
- **`scripts/verify-approval-gates.sh`** — egzekwuje breadcrumby `gate_approved`: GATE #1 przed pierwszym `role_spawned`, GATE #3 per passed sprint, GATE #2/#6 jeśli artefakty istnieją, brak wiszących `gate_pending`.

### Changed

- **`SKILL.md`** — preambuła „Strefa pracy" przeredagowana na tryb nadzorowany + callout „6 APPROVAL GATES". Bramki wstawione jako STOP w fazy 1→2, 3→4, 4 (per sprint), 6, 7. Nowy plik stanu `state/sprint-reports/`. Nowy DoD item (`verify-approval-gates.sh` exit 0). 4 nowe wymówki anti-rat (plan bez GATE #1, sprint bez akceptacji, /goal vs bramki, „spoko" jako zgoda). Wiersz progresywnego ładowania + wiersz kalibracji „Human-in-the-loop". Faza 6 verify krok 7 = `verify-approval-gates.sh`. (337 linii, <500 limit).
- **`references/goal-mode-protocol.md`** — `/goal` przeredagowany z „pełnej autonomii bez nadzoru" na „pętlę nadzorowaną z bramkami". Workflow Krok 4 oznaczony STOP-ami per bramka. Sekcja 6 „Bezpieczniki" ostrzega że praca nocna „odpal i zostaw" nie zadziała.

## [v1.6.0] — 2026-05-20 — Documentation Protocol (PRD + ADR + retrospectives + code reviews + QA reports)

### Added

Pełen audit trail wszystkich dokumentów pracy zespołu agentów. **10 typów dokumentów** w dwóch warstwach:

**Ephemeral (state/):**
- `state/plan.md` (istniejące)
- `state/prd/sprint-{n}.md` — **PRD per sprint** (8 sekcji: User story / Problem / Personas / FR / NFR / Out of scope / Success metrics / Open questions)
- `state/todo.md` — TODO snapshot z TodoWrite (persistowany per iteracja)
- `state/retrospectives/sprint-{n}.md` — **Sprint retrospective** (8 sekcji: summary / went well / didn't / lessons per agent / pivot history / cost / action items)
- `state/sessions/{YYYY-MM-DD}.md` — auto-generated daily log
- `state/decision-log.md` — lekkie decyzje (append-only)
- `state/qa-reports/sprint-{n}.md` — czytelna agregacja `qa-summary.json` od playwright-runner
- `state/final-report.md` — executive summary po fazie 7

**Committable (docs/):**
- `docs/adr/ADR-{NNNN}-{slug}.md` — **Architecture Decision Records** sekwencyjne, per decyzja architektoniczna (template przejęty z feature-planner-v3)
- `docs/code-reviews/CR-sprint-{n}-{slug}.md` — **Five-Axis Code Review** per sprint passed (Correctness/Readability/Architecture/Security/Performance × Critical/Optional/Nit/FYI)
- `docs/reports/final-{slug}.md` — kopia state/final-report.md (committable)

### New files

- **`references/documentation-protocol.md`** (~280 linii) — pełen protokół: 10 typów dokumentów × kto/kiedy/format/walidator.
- **`assets/prd-template.md`** + **`adr-template.md`** + **`retrospective-template.md`** + **`code-review-template.md`** + **`session-log-template.md`** (5 templates).
- **`scripts/init-docs-structure.sh`** — idempotent, tworzy state/{prd,retrospectives,sessions,qa-reports} + docs/{adr,code-reviews,reports} + sensible `.gitignore`.
- **`scripts/verify-documentation.sh`** — egzekwuje completeness per passed sprint: PRD (8 sekcji), retrospective, code review, QA report (jeśli evidence istnieje), ADR jeśli sprint dotknął architektury.
- **`scripts/append-session-log.sh`** — auto-generuje daily session log z breadcrumbs + git log + feature_list.
- **`tests/fixtures/feature_list-with-docs.json`** + **`feature_list-passed-no-docs.json`** + Group 8 meta-tests.

### Changed

- **`agents/planner.md`** — workflow rozszerzony: krok 3 (init docs structure), krok 6 (PRD per sprint), krok 7 (final report skeleton).
- **`agents/generator.md`** — workflow krok 5 (ADR per decyzja architektoniczna LUB decision-log.md dla lekkich), krok 9 (TODO snapshot per iteracja).
- **`agents/evaluator.md`** — nowa sekcja "Dokumenty po sprincie": retrospective + Five-Axis code review + QA report agregacja po `sprint_passed`.
- **`playwright-test-suite/agents/playwright-runner.md`** — po fazie 5 pisze `state/qa-reports/sprint-{n}.md`.
- **`SKILL.md`** — sekcja "Konwencja zapisu stanu" rozszerzona z 5 plików do **15** (5 ephemeral istniejących + 5 nowych ephemeral + 3 committable). 5 nowych wymówek anti-rat ("PRD overhead", "ADR później", "TODO w głowie", "retrospective ceremoniał", "code review w werdykcie"). Nowy DoD item: `verify-documentation.sh` exit 0. Tabela progresywnego ładowania rozszerzona o `documentation-protocol.md`.

### Why

User chce **wiedzieć co dzieje** w trakcie pracy zespołu agentów. Do tej pory:
- Stan był rozproszony: kontrakty (JSON), breadcrumbs (JSON), evidence files (heterogenne).
- Brakowało **czytelnych dokumentów** do code review, audit compliance, knowledge handoff.
- ADRs i Five-Axis reviews były tylko w `feature-planner-v3` (1 feature) — nie w orkiestracji zespołu.

Po v1.6: każda decyzja udokumentowana, każdy sprint ma retrospektywę, code review ze Five-Axis, ADR w `docs/adr/` (committable). Po sesji `/goal` można prześledzić KAŻDĄ decyzję bez czytania surowych breadcrumbs.

### Test results

- `bash tests/run-meta-tests.sh` → **19/19 passed** (z 16 → 19, Group 8 dodana).

---

## [v1.5.0] — 2026-05-20 — Planning Rigor (dziedziczone z feature-planner-v3)

### Added

- **`references/planning-rigor.md`** — pełen protokół planowania przejęty z `feature-planner-v3`:
  - 3 hipotezy per sprint (Minimal/Idiomatic/Ambitious) + wybór + uzasadnienie wg 5 Non-negotiables.
  - 11 obowiązkowych sekcji planu (z 6 do 11 — 5 nowych).
  - Hyrum Impact analysis (klasyfikacja breaking/additive/internal per sprint dotykający API).
  - Rollback plan per sprint (feature flag / migration `down()` / `git revert` strategy).
  - Alternatives considered top-level (min. 2 odrzucone architektury).
  - AC priorities MUST/SHOULD/COULD (przejęte z `ac-protocol.md`).
- **`scripts/verify-plan-rigor.sh`** — walidator wszystkich 11 sekcji + 3 hipotez per sprint + min. 2 alternatives. Inteligentne awk z wykluczeniem self-match.
- **`tests/fixtures/plan-rigorous.md`** (GOOD — wszystkie sekcje + 3 hipotezy/sprint + 4 alternatives) + **`plan-shallow.md`** (BAD — tylko 7 sekcji bez nowych v1.5).
- **`tests/run-meta-tests.sh`** — 2 nowe testy w Group 7 (verify-plan-rigor).
- **`assets/plan-template.md`** — rozszerzony z 6 do 11 sekcji z konkretnymi przykładami.

### Changed

- **`agents/planner.md`** — frontmatter `description` zaktualizowane (wymienia hipotezy/Hyrum/rollback/alternatives). Sekcja "Output" zaktualizowana z 7 do 11 obowiązkowych sekcji. Nowa reguła: minimum 3 hipotezy per sprint + min. 2 alternatives top-level + Hyrum Impact gdy dotyka API.
- **`SKILL.md`** — 3 nowe wymówki w anti-rationalization (1 hipoteza/sprint, Hyrum później, rollback później). Nowy DoD item: `verify-plan-rigor.sh` exit 0. Tabela "Progresywne ładowanie" rozszerzona o `planning-rigor.md`.

### Why

Planowanie w v1.4 było płaskie: Planner produkował listę sprintów z mierzalnymi celami, ale **bez audytu wyborów architektonicznych**. Generator dostawał plan w którym nie było widać DLACZEGO wybrano X zamiast Y. Konsekwencja: w fazie 3 (negocjacja kontraktu) Evaluator nie miał punktu odniesienia do oceny czy proposed implementation realizuje cel biznesowy najlepszą dostępną metodą. Dziedzicząc rygor z `feature-planner-v3` (1 feature, sprawdzony) wprowadzamy ten sam standard do orkiestracji wielu sprintów.

### Test results

- `bash tests/run-meta-tests.sh` → **16/16 passed** (z 14 → 16).

---

## [v1.4.0] — 2026-05-20 — context7 MCP + library currency protocol

### Added

- **`scripts/setup-context7.sh`** — instaluje context7 MCP (per-user via `claude mcp add` LUB per-project via `.mcp.json`). Idempotent. Wspiera ENV `CONTEXT7_API_KEY`.
- **`scripts/verify-library-currency.sh`** — walidator: sprint dotykający `package.json`/`requirements.txt`/`Cargo.toml`/`go.mod` MUSI mieć breadcrumb `library_currency_checked` z `source ∈ {context7, deepwiki, webfetch, npm-jsdoc}`. Heurystyczne wykrywanie nowych paczek + walidacja struktury eventów.
- **`references/library-currency-protocol.md`** — pełen protokół: 4-poziomowy fallback chain (context7 → DeepWiki → WebFetch → npm/JSDoc), format breadcrumb event, mapowanie per agent (planner/generator/evaluator/playwright-runner), anti-rationalization.
- **`assets/mcp-config-template.json`** — `.mcp.json` template dla projektu (context7 primary + DeepWiki fallback).
- **`assets/claude-md-template.md`** — `CLAUDE.md` template z **auto-invoke regułą** (Claude automatycznie woła context7 bez czekania na "use context7" w prompcie).
- **`tests/fixtures/breadcrumbs-with-currency-check.json`** + **`breadcrumbs-missing-currency.json`** — GOOD/BAD fixtures.
- **`tests/run-meta-tests.sh`** — 3 nowe testy w Group 6 (verify-library-currency).

### Changed

- **`agents/planner.md`** — frontmatter `tools` rozszerzone o `mcp__context7__*`. Workflow Step 3: library currency check dla bibliotek wskazanych w prompcie usera.
- **`agents/generator.md`** — `tools` + workflow Step 2: **OBOWIĄZKOWO** context7 PRZED każdym nowym `import { X } from 'lib'`. Zakaz halucynacji API.
- **`agents/evaluator.md`** — `tools` + workflow Step 3: deprecation scan w runtime traces (console.log → context7 lookup → breadcrumb).
- **`SKILL.md`** — 3 nowe wymówki w tabeli anty-racjonalizacji (halucynacja API / "lib jest stabilna" / "context7 zajmuje czas dla małych libów"). Nowy DoD item: `verify-library-currency.sh` exit 0. Tabela "Progresywne ładowanie" rozszerzona o `library-currency-protocol.md`.

### Why

Halucynacja API (LLM cutoff date) to **pierwsza przyczyna zerwanej pętli generator-ewaluator**: Generator pisze kod używający nieaktualnego/nieistniejącego API → Evaluator widzi runtime error → feedback → Generator próbuje naprawić kolejną halucynacją → 5 iteracji bez progresu → pivot. Context7 + walidator currency eliminuje ten patologiczny wzorzec u źródła.

### Test results

- `bash tests/run-meta-tests.sh` → **14/14 passed** (z 11 → 14).

---

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
