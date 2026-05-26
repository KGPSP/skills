# Changelog — qa-architect

All notable changes to this skill will be documented here. Format inspired by Keep a Changelog.

## [v1.0.1] — 2026-05-26

### Fixed (z code review)

- **`templates/configs/nextjs/jest.config.ts.tmpl:9`** — `setupFilesAfterEach` (pole nie istniejące w Jest Config) → **`setupFilesAfterEnv`** (poprawna nazwa per Jest docs). Bug krytyczny: każdy wygenerowany jest.config silently ignorował setup file, `@testing-library/jest-dom` matchers nie były rejestrowane, asercje typu `toBeInTheDocument()` rzucały `TypeError`.
- **`scripts/detect-stack.sh`** — `stack="monorepo"` zwracał exit 0, agent czytający tylko exit code nie wykrywał wymaganej eskalacji. Dodano **exit 3** dla monorepo + zaktualizowano `SKILL.md` Phase 0 hard-stop (exit 2 = unknown, exit 3 = monorepo, oba STOP).
- **`SKILL.md` Phase 5 + `references/dod-evidence-protocol.md` §1** — usunięto wymaganie `qa-blueprint/05-execution-log.md` jako osobnego pliku (nie był w 24-file count CHANGELOG'a ani sprawdzany przez `check-blueprint-complete.sh` — gap powodował false-positive DoD). Execution log agregowany w `qa-strategy.md` sekcja Execution log podczas Phase 6 consolidation.
- **`templates/ci/pr.yml:78`** — `if: matrix.pm == 'npm' || env.PM == 'npm' || true` (warunek zawsze true przez `|| true`) — przemianowano krok na "Dependency audit" (stack-agnostic) i usunięto martwy `if:`. Audit działa dla wszystkich PMs via `{{PACKAGE_MANAGER}} audit`.
- **`prompts/config-builder.md`** — dodano krok 5 + exit criterion: generuj `setup-vitest.ts`/`setup-jest.ts` razem z config'ami runnera (templates referencują te pliki przez `setupFiles`/`setupFilesAfterEnv` — bez nich runner failuje na starcie).
- **`references/ci-cd-protocol.md` §8** — usunięto referencje do nieistniejących templates `pr-python.yml` + `pr-go.yml`. Udokumentowano że `pr.yml` jest stack-agnostic via `{{PACKAGE_MANAGER}}` + `setup-{node|python|go}` conditional steps.
- **`scripts/extract-raw-log.sh:11`** — dopisano komentarz wyjaśniający dlaczego `set -u` (a nie `set -eu`) jest celowe (skrypt świadomie kontroluje exit code wrapped command via `set +e`/`set -e`).
- **`tests/run-meta-tests.sh:12`** — dopisano analogiczny komentarz dla `set -u` (assert_exit testuje też non-zero exit codes — `set -e` przerywałby skrypt przy każdym oczekiwanym fail w `actual_out=$("$@")`).
- **`CHANGELOG.md` (skill-level) + repo-root** — naprawiono sloppy wording „5 sub-agentów wymienione: 6 nazw" → spójnie „1 Manager + 5 workers = 6 sub-agentów".
- **`templates/configs/nextjs/playwright.config.ts.tmpl:34`** — `command: 'npm run dev'` → `command: '{{PACKAGE_MANAGER}} run dev'` (działa dla pnpm/yarn/bun).
- **`scripts/detect-stack.sh`** — initial `db="none-postgres"` → `db="none"` (jednoznaczny brak driver'a; `"none-postgres"` brzmiało jak „znaleziono nie-Postgres"). Zaktualizowano `references/stack-detection.md` §4 + GOOD fixture przewidziane wartości.

### Added

- **`tests/run-meta-tests.sh`** — dodano 2 testy dla nowego exit 3 monorepo case (GOOD fixture `monorepo-detect/` z `package.json` + `pyproject.toml`).
- **`SKILL.md` Phase 0** — rozszerzony hard-stop block obejmujący monorepo case z konkretną instrukcją eskalacji.

### Code review evidence

- Reviewer agent (`feature-dev:code-reviewer`) zaplątał się w pętlę przy nazwie pola Jest — werdykt zweryfikowany niezależnie via `WebFetch https://jestjs.io/docs/configuration` (`setupFilesAfterEnv`, NIE `setupFilesAfterEach` ani `setupFilesAfterFramework`).
- Po fixes: `sh tests/run-meta-tests.sh` → **18/18 passed** (16 oryginalne + 2 nowe monorepo case).
- `sh -n` na wszystkich skryptach → OK.

## [v1.0.0] — 2026-05-26

### Added

- Initial release.
- 8-fazowy orchestrator (Phase 0–8) z 2 bramkami approval (APPROVAL #1 swarm plan, APPROVAL #2 handoff/patch).
- 1 Manager (`qa-manager`) + 5 workers (`tooling-decisor`, `config-builder`, `test-author`, `ci-author`, `reviewer`) = 6 sub-agentów wywoływanych przez Agent tool.
- Multi-stack support: Next.js + React, Node generic, Python, Go (4 profile w `references/stack-profiles/`).
- 10 referencji w `references/` z `source:` traceability do DOC/{material_skill,since_skill,QA-swarm,INSTRUKCJA-BUDOWANIA-SKILLI,agent-teams-generator-ewaluator}.md.
- 4 POSIX skrypty w `scripts/` (`#!/bin/sh`, `set -eu`, exec bit 100755):
  - `detect-stack.sh` — deterministyczna detekcja stacku (Phase 0)
  - `check-blueprint-complete.sh` — DoD gate kompletności 24 plików (Phase 7)
  - `verify-postgres-strategy.sh` — anti-mock gate dla warstwy SQL (Phase 7)
  - `extract-raw-log.sh` — helper Phase 7 (timestamp + exit code)
- 11 templates w `templates/`:
  - master: `qa-strategy.md`, `claude-md-patch.md`, `agents-md.md`, `verify-tests-skill.md`, `pilot-4-weeks.md`
  - configs per stack: `nextjs/{vitest,jest,playwright,tsconfig,package.json-scripts,docker-compose}` + 4 samples
  - configs `node-generic/{vitest,tsconfig,package.json-scripts,docker-compose}`
  - configs `python/{pyproject-test-deps,conftest,pytest.ini,docker-compose}`
  - configs `go/{go-test-deps,testcontainers-postgres,docker-compose}`
  - CI: `pr.yml`, `nightly.yml`, `prerelease.yml`
- Beyoncé Rule: `tests/fixtures/GOOD/` (4 fixtures) + `tests/fixtures/BAD/` (3 fixtures) + `tests/run-meta-tests.sh` z 16/16 passing assertions.

### Source citations

- `DOC/QA-swarm.md` §2 (paradygmat swarm), §3–4 (krytyczna rewizja + piramida), §6.3 (kontrakt projektowy), §7 (dobór narzędzi), §8 (wzorce), §10–11 (struktura + CI), §12.3 (pilotaż 4-tyg), §12.5 (checklisty)
- `DOC/material_skill.md` §3 (Anti-Rationalization), §5 (Beyoncé + DAMP), §8 (5 Non-negotiables)
- `DOC/since_skill.md` §1 (Token budget), §4 (Negative Triggers), §5 (Prove-It), §6 (Anti-Laziness), §7 (Plan-Validate-Execute)
- `DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md` §3 (5 filarów), §9 (checklista), §10 (`source:` traceability)
- `DOC/agent-teams-generator-ewaluator.md` §2 (Manager + workers), §4 (rubryka)

### Pozycjonowanie vs istniejące skille dev/

- **`qa-architect` (ten skill):** setup-time, generator blueprintu QA, multi-stack
- `playwright-test-suite`: runtime E2E executor (Playwright + axe + Chrome DevTools MCP)
- `audited-feature-workflow` Phase 7: per-feature 7-warstwowy test gate
- `swarm-orchestrator`: long-running tmux 4 agenci (>2h zadania)

### DoD evidence

- `sh tests/run-meta-tests.sh` → 16/16 passed
- `sh -n scripts/*.sh && sh -n tests/*.sh` → wszystkie OK
- `sh scripts/detect-stack.sh /tmp/fixtures/{nextjs,python,go,empty}` → exit 0/0/0/2 zgodnie z spec
