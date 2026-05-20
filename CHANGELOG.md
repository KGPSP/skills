# Changelog

Historia zmian na poziomie repozytorium. Per-skill detale → commit history poszczególnych folderów.

## [2026-05-20] audit(dev): Google DNA compliance — agent-teams-builder v1.3.0 + playwright-test-suite v1.0.1

Audit pryncypiów wg `material_skill.md` §5 (Google DNA) + §8 (5 Non-negotiables) + `since_skill.md` §2 (5 filarów) wykrył luki w pokryciu 4 zasad inżynieryjnych Google. Naprawione w obu skillach.

### Changed

- **`dev/agent-teams-builder/`** → **v1.3.0**
  - `SKILL.md` — 4 nowe wymówki anty-racjonalizacyjne (Chesterton's Fence / Hyrum's Law / Beyoncé Rule / DAMP > DRY).
  - `references/anti-rationalization.md §5` — nowa sekcja "Google DNA" z 6 wymówkami i ripostami (przed: **brak Chesterton's Fence**).
- **`dev/playwright-test-suite/`** → **v1.0.1**
  - `SKILL.md` — nowa sekcja "Google DNA" + 4 nowe wymówki + DoD rozszerzony o Beyoncé/DAMP/Chesterton checks + explicit `(Non-negotiable #N)` labels + token budget L2 ≤5000.
  - `references/playwright-ui-protocol.md §5` — nowa sekcja "Google DNA w testach" z przykładami ✅/❌.

### Audit summary (po fixach)

| Zasada | agent-teams-builder | playwright-test-suite |
|---|---|---|
| Hyrum's Law | 8+ wzmianek ✅ | (w obu) ✅ |
| Chesterton's Fence | 5+ (było **0**) ✅ | ✅ |
| Beyoncé Rule | 15+ ✅ | 6+ ✅ |
| DAMP > DRY | 5+ ✅ | 7+ ✅ |

### Sanity tests

- `agent-teams-builder/tests/run-meta-tests.sh` → **11/11 passed** ✅
- `verify-role-isolation.sh` z 4 sub-agentami → ✅

---

## [2026-05-20] playwright-test-suite v1.0.0 + agent-teams-builder integration

### Added

- **`dev/playwright-test-suite/`** — dedykowany skill QA dla aplikacji webowych. 5-fazowa procedura (smoke → UI → DevTools → a11y → visual) przez Playwright CLI + `@axe-core/playwright` + pixelmatch. Pełna struktura:
  - SKILL.md (~250 linii)
  - **agents/playwright-runner.md** — dedykowany sub-agent Claude Code
  - references/ (7 protokołów)
  - scripts/ (7 orchestratorów)
  - templates/ (7 Playwright .ts.tmpl)

### Changed

- **`dev/agent-teams-builder/agents/evaluator.md`** — sekcja "Delegacja do playwright-runner" z gotowym wzorcem `Task(subagent_type: "playwright-runner")`. Evaluator deleguje pełne QA do dedykowanego sub-agenta zamiast wywoływać Playwright/Chrome inline.
- **`dev/agent-teams-builder/scripts/verify-role-isolation.sh`** — uznaje `playwright-runner` jako allowed producer evidence files + dodaje walidację jego izolacji (read-only na kodzie).

### Architecture (po tym sprincie)

```
parent agent (główne okno)
   ├── Task(planner)    → state/plan.md
   ├── Task(generator)  → kod w src/
   └── Task(evaluator)  → werdykt
              └── Task(playwright-runner)  ← NOWY skill
                     ├── 5 faz QA
                     └── state/evidence/sprint-{n}/qa-summary.json
```

---

## [2026-05-20] agent-teams-builder v1.2.0 — meta-tests

### Added

- **`dev/agent-teams-builder/tests/`** — 7 fixtures testowych (GOOD/BAD przykłady dla każdego walidatora) + `run-meta-tests.sh` (11 testów w 5 grupach, sprawdza że walidatory zachowują się zgodnie z oczekiwaniem).

### Fixed

- `scripts/check-breadcrumbs-append-only.sh` — bug `set -e -o pipefail` aborts skrypt gdy `grep` nie znajduje matchu w pipe. Naprawione przez lokalne `set +o pipefail`.

### Test results

- `bash tests/run-meta-tests.sh` → **11/11 passed**.

---

## [2026-05-20] agent-teams-builder v1.1.0

### Added

- **`dev/agent-teams-builder/`** — orkiestracja zespołu sub-agentów (Planner + Generator + Evaluator + opcjonalni specjaliści) wg wzorca Generator-Ewaluator do realizacji złożonych zadań programistycznych.
  - **SKILL.md** (~270 linii, limit ≤500) — 7-fazowa procedura (bootstrap → ship) z exit criteria per faza.
  - **`agents/`** (3 pliki) — gotowe definicje sub-agentów Claude Code (`planner.md`, `generator.md`, `evaluator.md`) z izolowanymi tools (Generator BEZ Playwright, Evaluator BEZ Edit).
  - **`references/`** (10 protokołów, ~2200 linii) — progresywne ładowanie: `contract-negotiation`, `evaluator-rubric`, `pivot-protocol`, `memory-filesystem`, `role-mapping`, `goal-mode-protocol`, `anti-rationalization`, `non-negotiables`, `dod-evidence-protocol`, `traces-reading`.
  - **`scripts/`** (12 skryptów bash, ~1000 linii) — `init-team-state`, `append-breadcrumb`, `check-contract-coverage`, `verify-evaluator-rubric`, `pivot-trigger`, `smoke-test-runner`, `check-breadcrumbs-append-only`, `verify-role-isolation`, `check-evidence-completeness`, `run-goal-loop`, `check-scope-discipline`, `verify-non-negotiables`.
  - **`assets/`** (6 plików) — szablon kontraktu z 15 binarnymi kryteriami, few-shot rubryki "good design vs AI slop", JSON schemy dla feature_list i breadcrumbs, plan template, prompt-templates.
  - **Tryb `/goal`** — autonomiczna pętla AC z auto-pivotem po MAX_ITERATIONS.
  - **Mechanizm pivota** — Plan-Validate-Execute dla operacji destruktywnych, archiwizacja branchu przed `rm -rf`, opcjonalny human hook (`PIVOT_REQUIRES_HUMAN=1`).

### Source

- `DOC/agent-teams-generator-ewaluator.md` (wzorzec Generator-Ewaluator, sekcje 1-10)
- `DOC/material_skill.md` §8 (5 Non-negotiables)
- `DOC/since_skill.md` §2 (5 filarów: Process / Anti-Rat / Verification / Progressive / Scope)
- `DOC/goal_mode.md` (przykłady `/goal` z mierzalną weryfikacją)

### Pozycjonowanie vs feature-planner-v3

- **feature-planner-v3** — pojedynczy feature, 1 sesja, 1 agent. Optymalny dla 100-300 linii diff.
- **agent-teams-builder** (ten skill) — projekty wielosprintowe, zespół sub-agentów z presją rywalizacyjną, dla pracy >2h. Optymalny dla "zbuduj aplikację od zera".

---

## [2026-05-12] feature-planner-v3 + dokumentacja repo

### Added

- **`dev/feature-planner-v3/`** — nowy senior-grade skill (18 plików, 4200 linii):
  - SKILL.md (344 linii, hard limit ≤500)
  - 12 referencji (`anti-rationalization`, `non-negotiables`, `dod-evidence-protocol`, `fragile-operations-protocol`, `incremental-implementation`, `five-axis-review`, `gotchas` + 4 rozszerzone z v2 + `adr-template`)
  - 5 deterministycznych skryptów POSIX (`check-pr-size`, `verify-build-clean`, `check-ac-coverage`, `extract-raw-log`, `api-impact-scan`)
- **`dev/README.md`** — decision tree + porównanie v2 vs v3 + struktura plików v3
- **`pzp/README.md`** — indeks 4 skilli PZP z mapowaniem na fazy postępowania
- **`CHANGELOG.md`** — niniejszy plik
- **`.gitignore`** — wyłączenia (`DOC/`, macOS artefakty, IDE, `node_modules`, Python cache, secrets, tmp logs)

### Changed

- **`README.md`** (top-level) — dodano `feature-planner-v3` do tabeli `dev/`, sekcja "Wybór dev/feature-planner (skrót)", sekcja "Pryncypia projektowania skilli (od v3)"

### Reżim koegzystencji

`feature-planner` (v2) i `feature-planner-v3` koegzystują — żadnych zmian w plikach v2. Wybór świadomy przez trigger (`v3` w prompcie → v3, inaczej → v2).

---

## [Wcześniej]

Pojedyncze commity feature-by-feature na branchu `main`. Główne kamienie milowe (z git history):

- `0fd51c0` — feature-planner: TodoWrite usage + harden Ralph-loop
- `3efab06` — Add Ralph-loop autonomous workflow
- `7dcf821` — Add worktree decision (Phase 5.5) and live preview (Phase 7.8)
- `0bb6456` — Add 7-scope testing matrix and Playwright fallback
- `0ba33ae` — init: KGPSP skills catalog (pzp, legal, dev)

Pełna historia: `git log --oneline`.
