---
name: node-generic
type: reference
parent: qa-architect
sources:
  - DOC/QA-swarm.md §7 (dobór narzędzi), §8.3 (Supertest)
description: Profile dla Node.js (Express/Fastify/Koa, Vite SPA, CLI tools) bez Next.js. Loaded when detect-stack.sh returns stack=node-generic.
---

# Profile: Node generic (Express/Fastify/Koa/Vite/CLI)

## 1. Stack assumptions

- **Framework:** Express, Fastify, Koa, NestJS, lub czysty Node HTTP. Może być SPA Vite + React/Vue.
- **API:** HTTP server, optionally gRPC.
- **DB:** PostgreSQL via `pg`/`postgres`/Prisma/Drizzle/TypeORM.
- **Language:** TypeScript (preferowane) lub JavaScript.

## 2. Tooling per warstwa

| Warstwa | Tool | Powód |
|---|---|---|
| Unit/Component | **Vitest** (default dla greenfield) | Modern ESM, szybki watch, dobre coverage |
| Integration HTTP | **Vitest + Supertest** | Bez ręcznego zarządzania portami (paper §8.3) |
| Integration DB | **Testcontainers** `@testcontainers/postgresql` | Realny Postgres |
| E2E (SPA) | **Playwright** | Multi-browser, parallel |
| E2E (CLI) | `execa` + Vitest snapshot | Standard pattern dla CLI |
| Mocking HTTP | MSW (gdy app robi outbound calls) | Single source of truth |
| Perf | k6 | — |
| Security | npm audit + Dependency Review + ZAP baseline | — |

## 3. Struktura katalogów

```
services/api/
├── src/
│   ├── app.ts              # buildApp() factory
│   ├── routes/
│   ├── services/
│   └── db/
├── tests/
│   ├── unit/               # *.test.ts (lub kolokowane)
│   ├── integration/        # *.int.test.ts (Supertest)
│   └── e2e/                # *.spec.ts (gdy ma frontend)
├── vitest.config.ts
└── playwright.config.ts    # gdy ma frontend
```

## 4. Wzorzec test integration HTTP (Supertest)

```ts
import request from 'supertest'
import { buildApp } from '../src/app'

test('POST /users 201', async () => {
  const app = buildApp()
  const response = await request(app)
    .post('/users')
    .send({ email: 'a@b.c' })
  expect(response.status).toBe(201)
})
```

## 5. Wzorzec integration DB (Testcontainers)

```ts
import { PostgreSqlContainer } from '@testcontainers/postgresql'
import { Pool } from 'pg'

beforeAll(async () => {
  container = await new PostgreSqlContainer('postgres:16-alpine').start()
  pool = new Pool({ connectionString: container.getConnectionUri() })
})

afterAll(async () => {
  await pool.end()
  await container.stop()
})

beforeEach(async () => {
  client = await pool.connect()
  await client.query('BEGIN')
})

afterEach(async () => {
  await client.query('ROLLBACK')
  client.release()
})
```

## 6. Wymagane scripts w `package.json`

```json
{
  "scripts": {
    "lint": "eslint .",
    "typecheck": "tsc --noEmit",
    "test": "vitest",
    "test:run": "vitest run",
    "test:unit": "vitest run tests/unit",
    "test:integration": "vitest run tests/integration",
    "test:e2e": "playwright test",
    "db:test:up": "docker compose -f docker-compose.test.yml up -d postgres",
    "db:test:down": "docker compose -f docker-compose.test.yml down -v"
  }
}
```

## 7. Templates

`templates/configs/node-generic/`:
- `vitest.config.ts.tmpl`
- `playwright.config.ts.tmpl` (gdy ma SPA)
- `tsconfig.json.tmpl`
- `package.json-scripts.json`
- `docker-compose.test.yml.tmpl`

## 8. Open questions

- Framework HTTP: Express / Fastify / Koa / Nest? — wpływ na buildApp() factory pattern.
- SPA: Vite + React / Vue / Svelte? — wpływ na Playwright config (baseURL, devServer hooks).
- CLI: czy testujemy snapshot output? — wybór: `vitest` + `execa` + inline snapshots.
