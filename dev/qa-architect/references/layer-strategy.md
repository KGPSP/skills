---
name: layer-strategy
type: reference
parent: qa-architect
sources:
  - DOC/QA-swarm.md §4.1 (piramida z 2 modyfikacjami), §4.2 (macierz odpowiedzialności), §13.1 (wnioski metodologiczne)
  - DOC/material_skill.md §5 (Beyoncé Rule + DAMP over DRY)
description: Strategia warstw testów dla qa-architect Phase 3. Piramida 80/15/5 z dwiema obowiązkowymi modyfikacjami (komponentowa Testing Library + integracyjna PostgreSQL Testcontainers). Macierz odpowiedzialności + per-stack exclusions. Wynikiem jest qa-blueprint/03-layer-strategy.md.
---

# Layer strategy — piramida + 2 modyfikacje

> [!quote] QA-swarm.md §13.1 (wniosek nadrzędny)
> Testy mają weryfikować **zachowanie widoczne dla użytkownika**, nie detale implementacyjne. Dla logiki SQL nie wolno polegać wyłącznie na mockach. Async Server Components nie są dziś kandydatem do unit tests w Jest/Vitest — powinny być pokrywane testami e2e.

## 1. Piramida bazowa 80/15/5

| Poziom | % suite | Speed | Cel |
|---|---|---|---|
| **Unit** (80%) | szybkie | < 30s całość | Helpery, walidatory, reducery, business rules, czyste funkcje |
| **Integration** (15%) | umiarkowane | < 5 min | Moduł ↔ moduł, route ↔ service, route ↔ DB, contract HTTP |
| **E2E** (5%) | wolne | < 15 min | Krytyczne ścieżki biznesowe, autoryzacja, routing, cross-browser smoke |

**Skala dostosowuje się do rozmiaru projektu (S/M/L wykryty w Phase 0):**

| Rozmiar | Unit | Integration HTTP | Integration DB | E2E | Perf | Security |
|---|---|---|---|---|---|---|
| **S** (<50 plików) | ✅ wymagane | ✅ wymagane | ✅ (jeśli SQL) | smoke (1 golden) | skip | npm audit |
| **M** (50–500) | ✅ | ✅ | ✅ | smoke + 1 edge | nightly k6 smoke | + Dep Review + ZAP baseline |
| **L** (>500) | ✅ | ✅ | ✅ | golden + 2–3 edge + failure path | k6 smoke+average+stress | + Dep Review + ZAP baseline + nightly ZAP API scan |

## 2. Modyfikacja 1 — Komponentowa (Testing Library)

> [!warning] Egzekwowane dla każdego stacku z UI (React/Vue/Svelte/htmx)
> Warstwa „komponentowa" frontendu **nie jest czysto jednostkowa**. Komponenty renderowane w DOM (jsdom/happy-dom), obsługiwane semantycznie zgodnie z Testing Library Guiding Principles.

**Reguły:**

1. **Query priority:** `getByRole({ name })` > `getByLabelText` > `getByPlaceholderText` > `getByText` > `data-testid` (escape hatch wyłącznie gdy semantyka niewystarczająca).
2. **Brak testowania detali implementacyjnych:** żadnych asercji na klasy CSS, prywatny state, internal hooks.
3. **`userEvent` nad `fireEvent`:** rzeczywiste interakcje użytkownika (`@testing-library/user-event`).
4. **`await screen.findBy*` nad `screen.getBy*` + sztywne timeouts:** Testing Library czeka wewnętrznie.

**Pliki:** `*.test.tsx` współlokowane z komponentem.

## 3. Modyfikacja 2 — Integracyjna bazodanowa (Testcontainers + Postgres)

> [!warning] Egzekwowane dla każdego stacku z PostgreSQL (`db_driver != none` z Phase 0)
> Zapytania SQL, migracje, constraints, transakcje, współbieżność krytyczna **muszą być testowane na realnym PostgreSQL**. Mockowanie tej warstwy = wzorzec anty (paper §4.2, §8.5).

**Reguły:**

1. **Per-suite lifecycle:** `beforeAll` → `start container`, `afterAll` → `stop`. Pool połączeń współdzielony.
2. **Per-test isolation:** `beforeEach` → `BEGIN`, `afterEach` → `ROLLBACK`. Brak state leakage.
3. **Same-client transaction:** `node-postgres` wymaga `pool.connect()` → użycia tego samego klienta w obrębie transakcji. Anti-pattern: różne klienty per query w transakcji.
4. **Migracje testowe:** uruchamiane raz w `beforeAll` po starcie containera, z plików w `db/migrations/`.
5. **Fixtures w `db/fixtures/`:** loadowane per test z `LOAD DATA` lub `INSERT`. NIE zostawiane w bazie między testami.

**Pliki:** `*.int.test.{ts,py,go}` w `tests/integration/` lub `services/<svc>/tests/`.

## 4. Per-stack exclusions

### Next.js / React

| Co | Status | Powód |
|---|---|---|
| Async Server Components | **N/A dla Jest/Vitest** → e2e Playwright | Paper §4.2 — Next.js Testing Guide explicite: nie wspierane |
| Synchronous Server Components | OK w Jest/Vitest | Komponent jak każdy inny renderowany w jsdom |
| Client Components (`'use client'`) | OK w Jest/Vitest + RTL | Default ścieżka |
| Route Handlers (`app/api/.../route.ts`) | Integration test (cienka warstwa, logika w service) | Paper §8.2 |
| Middleware | E2E w Playwright (testowanie efektu w przeglądarce) | Trudno mockować w isolation |

### Node generic (Express/Fastify/Koa)

| Co | Status | Powód |
|---|---|---|
| Route handlers | **Supertest** integration | Bez ręcznego zarządzania portami (paper §8.3) |
| Middleware Express | Unit (gdy czysta funkcja) lub integration via Supertest | — |
| Background jobs | Integration z prawdziwym Redis/queue via Testcontainers | Mock Redis = anti-pattern j.w. |

### Python (Django/FastAPI/Flask)

| Co | Status | Powód |
|---|---|---|
| Endpoints FastAPI | `httpx.AsyncClient` + ASGI | Standard FastAPI testing |
| Endpoints Django | `pytest-django` + Django test client | Standard |
| ORM queries (SQLAlchemy/Django ORM) | Testcontainers Postgres, **nie SQLite in-memory** | Niezgodność dialektów |
| Celery tasks | `pytest-celery` lub eager mode + integration | — |

### Go

| Co | Status | Powód |
|---|---|---|
| HTTP handlers | `httptest.NewServer` + `http.Client` | stdlib pattern |
| DB queries (`database/sql`, `pgx`) | `testcontainers-go` + `postgres` module | — |
| gRPC | `bufconn` listener + integration | Standard |

## 5. Macierz odpowiedzialności (paper §4.2)

| Warstwa | Główny cel | Domyślne narzędzia | Kiedy uruchamiać |
|---|---|---|---|
| Jednostkowa | logika domenowa, helpery, walidatory, hooks, komponenty synchroniczne | Vitest/Jest/pytest/go test + RTL/DOM TL | lokalnie, pre-commit, każdy PR |
| Integracyjna aplikacyjna | route handlers, API, serwisy, repozytoria, cache, config | + Supertest/httpx/httptest, MSW/respx, Testcontainers | każdy PR |
| Integracyjna bazodanowa | SQL queries, migracje, constraints, transakcje | Testcontainers, Docker Compose, PostgreSQL | każdy PR (dla pakietów backend/db); pełen zestaw nightly |
| E2E | krytyczne ścieżki biznesowe, autoryzacja, routing, rendering | Playwright (Cypress dla legacy) | smoke na PR, pełen zestaw przed release |
| Regresyjna | utrzymanie zachowania po zmianach | wszystkie warstwy + retry/trace/reporting | każdy PR i release |
| Wydajnościowa | czasy odpowiedzi, degradacja pod obciążeniem | k6 | nightly, pre-release |
| Bezpieczeństwa | supply chain, nagłówki, autz/autn, skany pasywne | npm audit, Dep Review, ZAP, Playwright security smoke | każdy PR + nightly/staging |

## 6. Output Phase 3 → `03-layer-strategy.md`

Minimum sekcje:

1. **Piramida dostosowana do rozmiaru S/M/L** (z §1).
2. **Modyfikacja 1 obowiązkowa** (jeśli stack ma UI) — zasady semantycznych query.
3. **Modyfikacja 2 obowiązkowa** (jeśli `db_driver != none`) — protokół Testcontainers.
4. **Per-stack exclusions** (z §4).
5. **Macierz odpowiedzialności** (kopia §5 dostosowana do stacku).
6. **Open questions** — co wymaga decyzji usera.

Brak którejkolwiek = Critical finding w Phase 7 review.
