---
name: tooling-decision-matrix
type: reference
parent: qa-architect
sources:
  - DOC/QA-swarm.md §7.1 (Vitest vs Jest), §7.2 (Playwright vs Cypress), §7.3 (security/perf), §7.4 (macierz porównawcza)
  - DOC/material_skill.md §8 (#3 — boring preferred)
description: Macierz decyzji narzędziowych per warstwa testów × stack. Każda decyzja ma format Wybór | Uzasadnienie | Alternatywa odrzucona | Powód odrzucenia. Używana przez sub-agenta tooling-decisor w Phase 2.
---

# Tooling decision matrix

> [!important] Reguła
> **Jedna decyzja per warstwa per stack**, nie dwie równorzędne opcje. Mieszanie runnerów (Jest + Vitest w tym samym pakiecie) wymaga **explicite uzasadnienia w 02-tooling.md** lub jest odrzucone (paper §7.1 — anti-pattern „mieszanie Jest i Vitest").

## 1. Macierz: warstwa × stack → tool

| Warstwa | Next.js + React | Node generic (Vite/Express) | Python | Go |
|---|---|---|---|---|
| **Unit/Component** | Jest + `next/jest` *(default greenfield: Vitest dla bibliotek)* | Vitest | pytest | `testing` (stdlib) |
| **DOM/UI** | React Testing Library + DOM TL | React Testing Library (gdy React); brak (gdy CLI/server-only) | — (Python = backend) | — (Go = backend) |
| **Integration HTTP** | Vitest/Jest + Next route handler test pattern | Vitest + Supertest | pytest + httpx.AsyncClient + ASGI/WSGI client | `testing` + `httptest` |
| **Integration DB (Postgres)** | Testcontainers `@testcontainers/postgresql` | Testcontainers `@testcontainers/postgresql` | `testcontainers-python` + `testcontainers[postgres]` | `testcontainers-go` + `postgres` module |
| **E2E (browser)** | Playwright *(Cypress dopuszczone dla legacy)* | Playwright | Playwright (wywoływany z pytest przez `pytest-playwright`) | Playwright (gdy aplikacja ma frontend); inaczej N/A |
| **API contract** | Supertest / Pact / Schemathesis | Supertest / Pact | Schemathesis / Pact-python | `httptest` + golden files |
| **Mocking HTTP boundary** | MSW (`msw/node` + `msw/browser`) | MSW | `respx` | `httptest.Server` (no external mock lib needed) |
| **Mocking lokalne moduły** | `vi.fn()` / `vi.spyOn()` (Vitest) lub `jest.fn()` (Jest) | `vi.fn()` | `unittest.mock` / `pytest-mock` | interface substitution (no mock lib) |
| **Perf/load** | k6 | k6 | k6 lub locust | k6 |
| **Security baseline** | npm audit + GitHub Dependency Review + ZAP baseline | npm audit + Dependency Review + ZAP baseline | `pip-audit` + Dependency Review + ZAP baseline | `govulncheck` + Dependency Review + ZAP baseline |

## 2. Format decyzji w `02-tooling.md`

Każdy wpis musi mieć tę strukturę:

```markdown
### Decyzja: <Warstwa>

| Pole | Wartość |
|---|---|
| **Wybór** | <konkretne narzędzie + wersja major, np. Vitest ^2> |
| **Uzasadnienie** | <cytat z paper'a §X.Y, max 2 zdania> |
| **Alternatywa odrzucona** | <konkretne narzędzie>, <wersja> |
| **Powód odrzucenia** | <techniczny, nie subiektywny> |
| **Anti-rationalization decisions** | #X applied (jeśli wymówka była rozważana) |
```

## 3. Decyzje per kontekst (override defaultów)

### Vitest vs Jest dla TypeScript

| Kontekst | Wybór | Powód |
|---|---|---|
| Greenfield, pakiet biblioteczny w monorepo | **Vitest** | Vite ecosystem, szybkie watch, modern ESM (paper §7.1) |
| Greenfield, `apps/web` Next.js | **Jest + `next/jest`** | Automatic config dla Next/SWC, mocki assetów, .env loading (paper §7.1) |
| Legacy z istniejącym Jest | **Jest** (nie migruj na siłę) | Migracja Jest → Vitest = osobny PR, nie scope qa-architect |
| Mieszanka w jednym pakiecie | **STOP — eskaluj** | Anti-pattern (paper §7.1) |

### Playwright vs Cypress dla E2E

| Kontekst | Wybór | Powód |
|---|---|---|
| Greenfield | **Playwright** | Multi-browser (Chromium+Firefox+WebKit), trace viewer, parallelism, browser contexts (paper §7.2) |
| Legacy z istniejącym Cypress + duża suite | **Cypress** + Playwright dla nowych e2e | Migracja całej suite poza scope qa-architect; Playwright dla nowych testów dodaje multi-browser |
| Komponent-testing potrzebny w Cypress component runner | **Cypress component testing** | Playwright nie ma component runnera (paper §7.2) |

### Testcontainers vs Docker Compose dla DB testów

| Kontekst | Wybór | Powód |
|---|---|---|
| Per-suite/per-test izolacja | **Testcontainers** | Ephemeral instance per suite, zero state leakage (paper §8.5) |
| Wspólne środowisko dev + CI baseline | **Docker Compose** (`docker-compose.test.yml`) | Deklaratywny standard, healthcheck, wolumeny (paper §8.6) |
| **Optymalne: oba** | Compose dla dev + Testcontainers dla CI per-suite | Paper §8.6 — „uzupełniają się" |

### MSW vs lokalne stuby

| Kontekst | Wybór | Powód |
|---|---|---|
| Zewnętrzne API (auth provider, payment, third-party) | **MSW** (`setupServer` w Node, `setupWorker` w browser) | Single source of truth, runtime `.use()` overrides (paper §8.4) |
| Lokalne moduły aplikacji | **`vi.fn()` / `jest.fn()` / `spyOn()`** | MSW dla lokalnych modułów = overengineering |
| Granica DB | **Testcontainers** (NIE MSW) | MSW jest dla HTTP, nie SQL (anti-pattern #6) |

## 4. Decyzje obowiązkowe (bez wyjątków)

| Decyzja | Wybór wymuszony | Powód |
|---|---|---|
| Realny Postgres w testach SQL | Testcontainers (lub Docker Compose w lokalnym dev) | Transakcje + izolacja `pg` ≠ mock (paper §4.2) |
| Semantyczne query w UI | `getByRole` → `getByLabelText` → `data-testid` | Testing Library Guiding Principles |
| CI workflow PR | GitHub Actions z lint+typecheck+unit+integration+smoke e2e+dep review | Bez tego DoD bramki dla PR nieobecna (paper §11) |
| Security baseline | npm audit (lub equiv) + Dependency Review w każdym PR | OWASP Top 10 baseline (paper §7.3) |

## 5. Output sub-agenta `tooling-decisor`

Plik `qa-blueprint/02-tooling.md` z minimum tymi sekcjami:

1. **Stack-detected:** (z Phase 0)
2. **Decyzja: Unit/Component**
3. **Decyzja: Integration HTTP**
4. **Decyzja: Integration DB**
5. **Decyzja: E2E**
6. **Decyzja: Mocking HTTP**
7. **Decyzja: Mocking lokalne**
8. **Decyzja: Perf**
9. **Decyzja: Security baseline**
10. **Anti-rationalization decisions** — lista wymówek rozważonych i odrzuconych (z #X).
11. **Open questions** — co wymaga decyzji usera (np. „Jest czy Vitest dla apps/web" jeśli niejasne).

Każda decyzja w formacie z §2. Brak którejkolwiek = Critical finding w Phase 7 review.
