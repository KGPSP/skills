# Changelog

Historia zmian na poziomie repozytorium. Per-skill detale → commit history poszczególnych folderów.

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
