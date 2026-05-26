---
name: stack-detection
type: reference
parent: qa-architect
sources:
  - DOC/QA-swarm.md §10.1 (struktura katalogów), §3.2 (założenia robocze)
  - DOC/since_skill.md §6 (Anti-Laziness — nie zgaduj stacku)
description: Protokół Phase 0 — deterministyczna detekcja stacku aplikacji (nextjs|node-generic|python|go|unknown). Reguły rozstrzygania konfliktów (np. monorepo z wieloma stackami). Wymaga uruchomienia scripts/detect-stack.sh i wklejenia raw output.
---

# Stack detection protocol

> [!important] Zasada nadrzędna
> Stack detekcja jest **deterministyczna** — uruchamiana przez `scripts/detect-stack.sh`, nie przez LLM patrzący na pliki. Output JSON wklejany dosłownie do `qa-blueprint/00-environment.md`. LLM **tylko interpretuje** wynik i pyta usera przy niejednoznaczności.

## 1. Markery per stack

| Stack | Markery (kolejność priorytetu) | Wykluczenia |
|---|---|---|
| **nextjs** | `next` w `package.json:dependencies` LUB `next.config.{js,ts,mjs}` istnieje | — |
| **node-generic** | `package.json` istnieje + brak `next` w deps | jeśli `react` lub `vite` + brak `next` → wciąż node-generic z flagą `frontend: <framework>` |
| **python** | `pyproject.toml` LUB `setup.py` LUB `requirements.txt` | — |
| **go** | `go.mod` istnieje | — |
| **unknown** | brak któregokolwiek z powyższych | — |

## 2. Reguły rozstrzygania konfliktów

| Sytuacja | Rozwiązanie |
|---|---|
| `package.json` + `pyproject.toml` (monorepo) | Output `stack: monorepo`, `components: [nextjs, python]`. Phase 0 STOP, eskaluj: „dla którego komponentu generuję blueprint? Czy jednym blueprintem dla obu (zaawansowane)?". |
| `package.json` bez `dependencies.next`, ale `next` w `devDependencies` | Traktuj jako `nextjs` (devDep next = test toolingu Next, też wymaga next/jest). |
| `package.json` z `react` + `vite` (czysty Vite, nie Next) | `stack: node-generic`, `frontend: react+vite`. Profile: użyj `node-generic` z dopiskiem „vite-based" w Phase 2. |
| `go.mod` + `package.json` (Go backend + JS frontend) | Monorepo case — eskaluj j.w. |
| Brak markerów | `stack: unknown` → Phase 0 STOP, eskaluj. |

## 3. Detekcja package manager

| PM | Marker |
|---|---|
| **npm** | `package-lock.json` |
| **yarn** | `yarn.lock` |
| **pnpm** | `pnpm-lock.yaml` |
| **bun** | `bun.lockb` |
| **pip** | `requirements.txt` + brak `pyproject.toml` |
| **uv** | `uv.lock` |
| **poetry** | `poetry.lock` |
| **pdm** | `pdm.lock` |
| **go modules** | `go.sum` |

Brak lockfile → flag `package_manager: unknown`, eskaluj (PM ma znaczenie dla CI workflow — `npm ci` vs `pnpm install --frozen-lockfile` vs `uv sync --frozen` itp.).

## 4. Detekcja DB driver

| Driver | Marker |
|---|---|
| **pg** (Node) | `pg` w dependencies |
| **postgres** (Node) | `postgres` w dependencies (Postgres.js) |
| **prisma** (Node) | `@prisma/client` w dependencies + `prisma/schema.prisma` |
| **drizzle** (Node) | `drizzle-orm` w dependencies |
| **typeorm** (Node) | `typeorm` w dependencies |
| **psycopg** (Python) | `psycopg` lub `psycopg2` w deps |
| **asyncpg** (Python) | `asyncpg` w deps |
| **sqlalchemy** (Python) | `sqlalchemy` w deps |
| **pgx** (Go) | `github.com/jackc/pgx` w `go.mod` |
| **database/sql + lib/pq** (Go) | `github.com/lib/pq` w `go.mod` |

Brak Postgres → flag `db_driver: none-postgres`, w Phase 3 layer strategy **integracyjna bazodanowa = N/A** (oznacz wprost).

## 5. Wymagany output JSON (z `detect-stack.sh`)

```json
{
  "stack": "nextjs|node-generic|python|go|monorepo|unknown",
  "components": ["nextjs", "python"],
  "package_manager": "npm|yarn|pnpm|bun|pip|uv|poetry|pdm|go|unknown",
  "db_driver": "pg|prisma|psycopg|asyncpg|pgx|...|none-postgres",
  "has_existing_tests": true,
  "has_existing_ci": false,
  "project_size_files": 312,
  "project_size_class": "S|M|L",
  "fragile_paths": [".github/workflows/", "CLAUDE.md"]
}
```

## 6. Decision flow dla LLM po uruchomieniu detect-stack.sh

```
1. Wklej raw JSON do `qa-blueprint/00-environment.md`.
2. Jeśli `stack == unknown` → STOP, eskaluj user'owi z pełnym JSON-em.
3. Jeśli `stack == monorepo` → STOP, eskaluj wyborem komponentu.
4. Jeśli `package_manager == unknown` → eskaluj („który PM używasz?").
5. Jeśli `db_driver == none-postgres` → flag w 00-environment, layer-db = N/A.
6. Załaduj odpowiedni `references/stack-profiles/<stack>.md`.
```

## 7. Anti-pattern detection

W Phase 1 (Discovery) sprawdź też te wzorce — to nie zmienia detekcji stacku, ale ląduje w Gap matrix:

| Wzorzec | Status |
|---|---|
| `jest.mock('pg')` w testach Node | **Critical anti-pattern** (paper §4.2, §8.5) |
| `vi.mock('pg')` | Critical |
| Użycie `pg-mem`, `pg-memory`, `pg-ish` | Critical |
| `monkeypatch.setattr('psycopg2.connect', ...)` | Critical (Python) |
| `sqlmock` w Go bez Testcontainers | Critical |
| Brak `Playwright` + brak `Cypress` w stacku z `react`/`next`/`vue` | High (brak e2e) |
| Brak `MSW`/`nock`/`fetch-mock` w testach UI z `fetch`/`axios` | Medium |

Wpisz wszystkie znaleziska do `01-discovery.md` sekcja `Anti-patterns detected`.
