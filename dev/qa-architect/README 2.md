# qa-architect — multi-stack QA blueprint orchestrator

> **Tryb:** setup-time generator strategii QA i konfiguracji testów
> **Stack:** Next.js + React + Node, Node generic (Express/Fastify), Python (FastAPI/Django), Go
> **Orkiestracja:** Manager + 5 sub-agentów (tooling-decisor, config-builder, test-author, ci-author, reviewer)
> **Wersja:** v1.0.0
> **Źródła:** [DOC/QA-swarm.md](../../DOC/QA-swarm.md), [DOC/material_skill.md](../../DOC/material_skill.md), [DOC/since_skill.md](../../DOC/since_skill.md)

## Co robi

Dla projektu webowego (Next.js / Node / Python / Go z PostgreSQL) generuje audytowalny **qa-blueprint/** zawierający:

| Plik | Co tam siedzi |
|---|---|
| `qa-strategy.md` | Master doc — decyzje narzędziowe + warstwy + pilotaż |
| `configs/{vitest,jest,playwright,pytest,go-test,docker-compose.test}.{ext}` | Kompletne konfiguracje runnerów per stack |
| `samples/{unit,integration-http,integration-db,e2e}.{ext}` | Po 1 sample test per warstwa (Beyoncé Rule) |
| `ci/{pr,nightly,prerelease}.yml` | 3 workflowy GitHub Actions z `permissions:` + artefaktami |
| `CLAUDE.md.patch` + `AGENTS.md` + `.claude/skills/verify-tests/SKILL.md` | Kontrakt projektowy dla agentów AI |
| `checklists.md` + `pilot-4-weeks.md` | PR/test checklisty + harmonogram pilotażu |
| `07-verification.md` + `07-review.md` | Raw outputs walidatorów + Five-Axis Review |
| `HANDOFF.md` | Co user musi zrobić ręcznie po blueprint |

## Czego skill **nie robi** (granice)

| Tryb | Skill |
|---|---|
| **Setup QA blueprint** | `qa-architect` ← jesteś tu |
| Runtime E2E (Playwright + axe + Chrome DevTools MCP) | `playwright-test-suite` |
| Per-feature 7-warstwowy test gate | `audited-feature-workflow` Phase 7 |
| Tmux orkiestracja 4 agentów (>2h) | `swarm-orchestrator` |
| TDD implementation z bramkami | `audited-feature-workflow` |

`qa-architect` **nie modyfikuje** kodu aplikacji — wszystko trafia do osobnego `qa-blueprint/`. Patch `CLAUDE.md` jest pliku patch'em, nie auto-merge (APPROVAL #2 wymagany).

## Trigger

```
/qa-architect
zaprojektuj strategię testów
qa blueprint
setup qa
setup testów
dobierz narzędzia testowe
```

Nie aktywuje się dla: „uruchom testy", „napisz test jednostkowy", „popraw failing test", eksploracja repo bez intencji setup.

## Architektura — 8 faz + 2 bramki

| Faza | Cel | Sub-agent | Bramka |
|---|---|---|---|
| 0 | Detect stack (`scripts/detect-stack.sh`) | — | — |
| 1 | Discovery (gap matrix) | — | — |
| 2 | Tooling decisions | tooling-decisor | — |
| 3 | Layer strategy (piramida 80/15/5 + 2 mod.) | — | — |
| 4 | Swarm decomposition | qa-manager | **APPROVAL #1** |
| 5 | Parallel execution (configs + samples + CI) | config-builder, test-author, ci-author | — |
| 6 | Consolidation (qa-strategy + patches) | — | — |
| 7 | Verification (skrypty + Five-Axis Review) | reviewer | — |
| 8 | Handoff (pilotaż 4-tyg) | — | **APPROVAL #2** |

## Struktura skilla

```
dev/qa-architect/
├── SKILL.md                              ~290 linii (limit 500)
├── README.md                             ← jesteś tu
├── CHANGELOG.md
├── references/
│   ├── non-negotiables.md                5 zasad + Fragile Ops
│   ├── anti-rationalization.md           15 wymówek + S-series swarm
│   ├── stack-detection.md                protokół Phase 0
│   ├── tooling-decision-matrix.md        macierz Vitest/Jest/Playwright/Cypress/...
│   ├── layer-strategy.md                 piramida + 2 modyfikacje + per-stack
│   ├── swarm-protocol.md                 Manager + 5 workers
│   ├── dod-evidence-protocol.md          raw artifacts format
│   ├── ci-cd-protocol.md                 GitHub Actions PR/nightly/release
│   ├── checklists.md                     PR + testy + deployment
│   └── stack-profiles/{nextjs-react,node-generic,python,go}.md
├── prompts/                              prompty Agent tool dla sub-agentów
│   └── {qa-manager,tooling-decisor,config-builder,test-author,ci-author,reviewer}.md
├── scripts/                              POSIX, exec bit 100755
│   ├── detect-stack.sh                   deterministyczna detekcja
│   ├── check-blueprint-complete.sh       DoD gate
│   ├── verify-postgres-strategy.sh       anti-mock SQL gate
│   └── extract-raw-log.sh                helper z timestampem + exit code
├── templates/
│   ├── qa-strategy.md
│   ├── claude-md-patch.md
│   ├── agents-md.md
│   ├── verify-tests-skill.md
│   ├── pilot-4-weeks.md
│   ├── configs/{nextjs,node-generic,python,go}/*.tmpl
│   └── ci/{pr,nightly,prerelease}.yml
└── tests/
    ├── fixtures/GOOD/{nextjs,python,go,complete-blueprint}/
    ├── fixtures/BAD/{unknown-stack,postgres-mocked,incomplete-blueprint}/
    └── run-meta-tests.sh                 16/16 PASS
```

## Walidacja

```bash
# meta-testy skryptów (16/16)
sh tests/run-meta-tests.sh

# składnia każdego skryptu
for f in scripts/*.sh tests/*.sh; do sh -n "$f"; done

# smoke detect-stack
sh scripts/detect-stack.sh .
```

## Instalacja

Skill jest w marketplace `kgpsp-skills` plugin `dev-tools`:

```
/plugin marketplace add KGPSP/skills
/plugin install dev-tools@kgpsp-skills
```

Lokalne testowanie:

```
claude plugin marketplace add /Users/sq13pl/Documents/GitHub/skills
claude plugin install dev-tools@kgpsp-skills
claude plugin details dev-tools     # potwierdza Skills (7)
```

## Decision tree dev/

```
Setup QA dla nowego projektu              → qa-architect (you are here)
Implementacja feature'a z TDD             → audited-feature-workflow
Quick feature plan (v2)                   → replit-style-workflow
Planning-only (kończ na planie + ADR)     → feature-spec-planner
Runtime E2E + a11y + visual               → playwright-test-suite
Orkiestracja zespołu sub-agentów          → agent-teams-builder
Tmux 4 agentów Claude w panes (>2h)       → swarm-orchestrator
```

## Pryncypia

Skill opiera się na 5 filarach z `DOC/` (Process over Prose, Anti-Rationalization Tables, Non-negotiable Verification, Progressive Disclosure, Scope Discipline) + 2 metodologicznych wnioskach z `DOC/QA-swarm.md`:

1. Testy weryfikują zachowanie użytkownika, nie detale implementacyjne.
2. Warstwa SQL **wyłącznie** na realnym PostgreSQL (Testcontainers obowiązkowy).
3. Async Server Components Next.js → Playwright e2e, nie Jest/Vitest.
4. Claude Code = **rama egzekucyjna**, nie magiczny generator testów.
