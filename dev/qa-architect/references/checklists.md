---
name: checklists
type: reference
parent: qa-architect
sources:
  - DOC/QA-swarm.md §12.5 (Checklisty kontrolne — PR + testy)
description: Checklisty PR i testów z paper'a §12.5. Trafiają do qa-blueprint/checklists.md jako reference dla user'a + agentów (verify-tests skill). Format: pytania kontrolne + kryteria akceptacji.
---

# Checklists — PR + testy (paper §12.5)

## 1. Checklist PR (review gate)

| Pytanie kontrolne | Kryterium akceptacji |
|---|---|
| Czy zmiana ma test na właściwej warstwie? | unit dla logiki, integration dla API/DB, e2e dla flow użytkownika |
| Czy test weryfikuje zachowanie, a nie implementation details? | semantyczne query (`getByRole`/`getByLabelText`), brak asercji na klasy CSS lub prywatny stan |
| Czy nowe zależności przeszły security gate? | `dependency-review-action` i `npm audit`/`pip-audit`/`govulncheck` nie blokują merge |
| Czy błędy z CI mają artefakty? | coverage, trace, screenshot lub raport JSON/JUnit są zapisane (upload-artifact `if: always()`) |
| Czy instrukcje dla Claude Code są aktualne? | `CLAUDE.md` / skill `verify-tests` pokrywają nową procedurę, jeśli powtarzalna |
| Czy PR diff ≤ 300 linii (lub uzasadnione >300)? | Paper §6.2 — PR Sizing |
| Czy Chesterton check dla usuniętego kodu? | Każda deleted line ma uzasadnienie „why this existed" w PR body |
| Czy Hyrum impact dla zmian API? | Każda zmiana sygnatury publicznej ma listę callerów / dowód braku breaking change |

## 2. Checklist testów (test author / reviewer)

| Pytanie kontrolne | Kryterium akceptacji |
|---|---|
| Czy selektory są semantyczne? | `getByRole` / `getByLabelText` przed `data-testid` |
| Czy mocki są na właściwej granicy? | MSW dla HTTP, test doubles dla modułów lokalnych, **realny Postgres** dla SQL |
| Czy test jest izolowany? | brak współdzielonego stanu; rollback lub czysta instancja DB |
| Czy retry nie maskuje defektu? | test flaky **raportowany**, a nie tylko „naprawiany retry" |
| Czy czasy wykonania są proporcjonalne do wartości testu? | unit szybkie (<1s/plik), integration umiarkowane (<5s), e2e ograniczone do krytycznych flow |
| Czy DAMP over DRY? | Test czyta się jak spec; brak magicznych helperów ukrywających stan |
| Czy AC mapping? | Każdy test odpowiada konkretnemu AC (lub explicite jest „regression test for bug #X") |
| Czy edge cases pokryte? | Beyoncé Rule — happy path + error path + boundary |
| Czy async Server Components NIE w unit? | Dla Next.js — RSC async w e2e Playwright, nie w Jest/Vitest |
| Czy Testcontainers per-suite lifecycle poprawny? | beforeAll = start, afterAll = stop, beforeEach = BEGIN, afterEach = ROLLBACK |

## 3. Checklist deployment (handoff do release)

| Pytanie | Kryterium |
|---|---|
| Czy nightly suite zielony przez ostatnie 7 dni? | Github Actions dashboard PASS rate ≥ 95% |
| Czy ZAP baseline nie ma nowych High/Critical? | porównanie z previous run |
| Czy k6 smoke trzyma SLA (p95 latency)? | progi z `qa-strategy.md` |
| Czy dependency audit czysty? | `npm audit --audit-level=high` exit 0 |
| Czy artefakty CI dostępne dla ostatnich 30 dni? | retention policy actions/upload-artifact ≥ 30 days |
| Czy CLAUDE.md / verify-tests skill aktualne? | last-modified w ciągu sprintu |

## 4. Checklist Phase 0 (qa-architect self-check)

| Pytanie | Kryterium |
|---|---|
| Stack wykryty? | `detect-stack.sh` exit 0, JSON ma `stack != unknown` |
| Package manager wykryty? | `package_manager != unknown` |
| DB driver wykryty? | `db_driver` ma wartość (konkretny driver: `pg`/`prisma`/`asyncpg`/`pgx`/... lub `none` gdy brak Postgres) |
| Rozmiar projektu sklasyfikowany? | `project_size_class ∈ {S, M, L}` |
| Fragile paths zidentyfikowane? | `fragile_paths` lista (może być pusta) |
| Negative triggers nie odpalają? | Frontmatter `do-not-trigger-for` sprawdzony |

## 5. Checklist sub-agenta (per worker w Phase 5)

| Pytanie | Kryterium |
|---|---|
| Czytam wyłącznie pliki w `Inputs:` z promptu? | Glob/Read tylko z listy |
| Modyfikuję wyłącznie pliki w `Scope (file ownership)`? | Diff per agent w wybranym katalogu |
| Output ma format wymagany w `Exit criterion`? | Plik istnieje + składnia OK + wymagane sekcje |
| Anti-rationalization przeszło? | Wpis w `## Anti-rationalization log:` w output |
| Brak modyfikacji prod-code? | `git diff --name-only` poza `qa-blueprint/` = 0 |

## 6. Checklist reviewer (Phase 7)

| Oś review | Pytanie kontrolne |
|---|---|
| Correctness | Czy configi mają poprawną składnię? Czy paths/imports się rozwiązują? |
| Readability | Czy nazwy plików kebab-case? Czy komenty wyjaśniają WHY a nie WHAT? |
| Architecture | Czy CLAUDE.md.patch importuje AGENTS.md? Czy verify-tests skill ma poprawny frontmatter? |
| Security | Czy CI workflow ma `permissions:` explicite? Czy brak hardcoded secrets? |
| Performance | Czy Playwright workers = sensible (4 dla CI, default lokalnie)? Czy coverage threshold nie blokuje incremental builds? |
| Anti-pattern | Czy żaden sample test nie mockuje `pg`/`psycopg`/`pgx`? |
| Completeness | Czy wszystkie 24 pliki blueprintu istnieją? |

Verdict format:
- **PASS** — 0 Critical, max 5 Optional, dowolnie Nit/FYI
- **FAIL** — ≥1 Critical → Phase 7 STOP, eskaluj do usera z listą Critical

## 7. Hard rule

**Każda checklist trafia do `qa-blueprint/checklists.md` w całości**, nie wybiórczo. User decyduje które pytania włącza do team conventions — to jego sprawa, qa-architect dostarcza pełny zestaw.
