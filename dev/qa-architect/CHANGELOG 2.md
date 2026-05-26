# Changelog — qa-architect

All notable changes to this skill will be documented here. Format inspired by Keep a Changelog.

## [v1.0.0] — 2026-05-26

### Added

- Initial release.
- 8-fazowy orchestrator (Phase 0–8) z 2 bramkami approval (APPROVAL #1 swarm plan, APPROVAL #2 handoff/patch).
- 5 sub-agentów wywoływanych przez Agent tool: `qa-manager`, `tooling-decisor`, `config-builder`, `test-author`, `ci-author`, `reviewer`.
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
