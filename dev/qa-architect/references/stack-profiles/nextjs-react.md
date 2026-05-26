---
name: nextjs-react
type: reference
parent: qa-architect
sources:
  - DOC/QA-swarm.md §3.2 (założenia), §4.2 (macierz), §8 (wzorce), §10.2 (konwencje), §10.3 (configi)
description: Profile stacku Next.js (App Router) + React + Node + PostgreSQL. Loaded when detect-stack.sh returns stack=nextjs. Definuje konkretne narzędzia, wykluczenia (async Server Components), strukturę plików, konfiguracje referencyjne.
---

# Profile: Next.js + React + Node + PostgreSQL

## 1. Stack assumptions

- **Framework:** Next.js App Router (wersjozależne — czytaj `node_modules/next/dist/docs/` przy zmianach, paper §3.2).
- **UI:** React + Testing Library (semantyczne query).
- **API:** Route handlers (`app/api/.../route.ts`) — cienka warstwa HTTP, logika w `services/`.
- **DB:** PostgreSQL via `pg` / `postgres` / Prisma / Drizzle.
- **Language:** TypeScript strict (`noUncheckedIndexedAccess: true`).

## 2. Tooling per warstwa

| Warstwa | Tool | Komenda |
|---|---|---|
| Unit/Component | **Jest + `next/jest`** (default dla `apps/web`) lub Vitest dla pakietów bibliotecznych | `npm test` / `npm run test:unit` |
| Integration HTTP | Vitest/Jest + Route handler test pattern | `npm run test:integration` |
| Integration DB | **Testcontainers** `@testcontainers/postgresql` + Vitest/Jest | `npm run test:api` |
| E2E | **Playwright** (multi-browser) | `npm run test:e2e` |
| Mocking HTTP | **MSW** (`msw/node` + `msw/browser`) | — |
| Perf | k6 | `k6 run scripts/smoke.js` |
| Security | npm audit + Dependency Review + ZAP baseline | CI workflow |

## 3. Wykluczenia obowiązkowe (paper §4.2)

| Co | Status | Powód |
|---|---|---|
| Async Server Components | **N/A dla Jest/Vitest** | Next.js Testing Guide explicite: nie wspierane oficjalnie. Pokrycie → Playwright e2e. |
| Synchronous Server Components | OK w Jest/Vitest + RTL | Renderowane w jsdom. |
| Client Components (`'use client'`) | OK w Jest/Vitest + RTL | Default. |
| Route Handlers | Integration (Vitest/Jest + mock service via vi.mock) | Cienka warstwa HTTP, logika osobno. |
| Middleware | E2E Playwright | Trudno mockować w isolation. |

## 4. Struktura katalogów (paper §10.1)

```
apps/web/
├── app/                    # App Router
├── src/
│   ├── components/         # *.test.tsx kolokowane
│   ├── lib/                # *.test.ts kolokowane
│   ├── server/             # route handler logic, *.test.ts kolokowane
│   └── test/
│       ├── msw/handlers.ts
│       ├── setup-vitest.ts (lub setup-jest.ts)
│       └── fixtures/
├── tests/
│   ├── integration/        # *.int.test.ts
│   └── e2e/                # *.spec.ts (Playwright)
├── playwright.config.ts
├── vitest.config.ts        # LUB jest.config.ts
└── next.config.ts
```

## 5. Konwencje nazewnicze

- `*.test.ts(x)` — unit/component (kolokowane lub w `__tests__/`)
- `*.int.test.ts` — integration
- `*.spec.ts` lub `*.e2e.spec.ts` — Playwright

## 6. Wymagane scripts w `package.json`

```json
{
  "scripts": {
    "lint": "eslint .",
    "typecheck": "tsc --noEmit",
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage.enabled",
    "test:unit": "vitest run src --exclude tests/**",
    "test:integration": "vitest run tests/integration",
    "test:e2e": "playwright test",
    "test:api": "vitest run src/server tests/integration",
    "db:test:up": "docker compose -f docker-compose.test.yml up -d postgres",
    "db:test:down": "docker compose -f docker-compose.test.yml down -v"
  }
}
```

## 7. Headers security (next.config.ts)

```ts
headers: [
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' }
]
```

## 8. Templates pliku konfiguracyjnego

Patrz `templates/configs/nextjs/`:
- `vitest.config.ts.tmpl`
- `jest.config.ts.tmpl`
- `playwright.config.ts.tmpl`
- `tsconfig.json.tmpl`
- `package.json-scripts.json` — sekcja scripts do mergeania
- `docker-compose.test.yml.tmpl`

## 9. Wzorzec testu per warstwa

| Warstwa | Wzorzec | Anti-pattern |
|---|---|---|
| Component | `render() + userEvent.setup() + screen.getByRole({name})` | `getByTestId` jako default, asercje na CSS class |
| Route handler | `vi.mock('@/server/<svc>') + import { GET, POST } + response.json()` | Stawianie pełnej Next app w jsdom |
| Integration HTTP | Supertest na `buildApp()` Express-like helper (dla Node services), `vi.mock` dla Next route handlers | Ręczne zarządzanie portami |
| Integration DB | `beforeAll: start container + run migrations`, `beforeEach: BEGIN, afterEach: ROLLBACK` | Cleanup przez `TRUNCATE`, brak rollback |
| E2E | `await page.getByRole('button', {name: 'Zaloguj'}).click()` | sztywne `page.waitForTimeout(1000)` |

## 10. Open questions (eskaluj jeśli niejasne)

- Vitest czy Jest dla `apps/web`? (default Jest+next/jest, Vitest dla bibliotek monorepo)
- ORM: czy Prisma migrations czy raw SQL migrations?
- Hosting: Vercel czy self-hosted (Node server)? — wpływ na headers i caching.
- Czy istnieje OpenAPI/GraphQL spec? — jeśli tak, dodaj Schemathesis/Pact w prerelease.
