---
name: python
type: reference
parent: qa-architect
sources:
  - DOC/QA-swarm.md §7 (dobór narzędzi — adaptacja Python)
description: Profile dla Python (FastAPI/Django/Flask + PostgreSQL). Loaded when detect-stack.sh returns stack=python.
---

# Profile: Python (FastAPI/Django/Flask + PostgreSQL)

## 1. Stack assumptions

- **Framework:** FastAPI (preferowany dla nowych projektów), Django, Flask.
- **API:** REST (FastAPI/Flask), Django REST framework.
- **DB:** PostgreSQL via `psycopg`/`asyncpg`/SQLAlchemy/Django ORM.
- **Language:** Python ≥ 3.11, type hints obowiązkowe (`mypy --strict`).
- **PM:** pip / uv / poetry / pdm.

## 2. Tooling per warstwa

| Warstwa | Tool | Powód |
|---|---|---|
| Unit | **pytest** | Standard, parametrize, fixtures |
| Integration HTTP (FastAPI) | **pytest + httpx.AsyncClient + ASGITransport** | Standard FastAPI testing |
| Integration HTTP (Django) | **pytest-django + Django test client** | Standard Django |
| Integration DB | **testcontainers-python** + `testcontainers[postgres]` | Realny Postgres |
| E2E | **pytest-playwright** (Playwright via pytest) | Spójność z Node stackiem |
| Mocking HTTP | **respx** (dla httpx) lub `pytest-httpx` | Single source of truth |
| Mocking lokalne | `unittest.mock` / `pytest-mock` | stdlib |
| Perf | k6 lub locust | k6 dla spójności, locust dla Python ergonomics |
| Security | `pip-audit` + Dependency Review + ZAP baseline | OWASP baseline |

## 3. Wykluczenia / specyfika

| Co | Status | Powód |
|---|---|---|
| SQLite in-memory dla testów ORM | **Anti-pattern** | Niezgodność dialektów. Użyj Testcontainers Postgres. |
| `MagicMock` dla DB | Anti-pattern | Brak walidacji query/transakcji. |
| Django `TestCase` z transactional rollback | OK ale wolne dla wielu suite | Preferuj `pytest-django` + Testcontainers per session |

## 4. Struktura katalogów

```
my_app/
├── pyproject.toml
├── src/my_app/
│   ├── api/
│   ├── services/
│   └── db/
├── tests/
│   ├── unit/test_*.py
│   ├── integration/test_*_int.py
│   └── e2e/test_*_e2e.py
├── conftest.py
└── pytest.ini
```

## 5. Wzorzec test integration HTTP (FastAPI + httpx)

```python
import pytest
from httpx import AsyncClient, ASGITransport
from my_app.api import app

@pytest.mark.asyncio
async def test_post_users():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/users", json={"email": "a@b.c"})
    assert response.status_code == 201
```

## 6. Wzorzec integration DB (testcontainers-python + asyncpg)

```python
import pytest
import asyncpg
from testcontainers.postgres import PostgresContainer

@pytest.fixture(scope="session")
def postgres_container():
    with PostgresContainer("postgres:16-alpine") as pg:
        yield pg

@pytest.fixture(scope="function")
async def db_conn(postgres_container):
    conn = await asyncpg.connect(postgres_container.get_connection_url().replace("postgresql+psycopg2", "postgresql"))
    tr = conn.transaction()
    await tr.start()
    try:
        yield conn
    finally:
        await tr.rollback()
        await conn.close()
```

## 7. Wymagane sekcje w `pyproject.toml`

```toml
[project.optional-dependencies]
test = [
  "pytest>=8",
  "pytest-asyncio",
  "pytest-cov",
  "pytest-playwright",
  "pytest-django",          # jeśli Django
  "testcontainers[postgres]",
  "httpx",
  "respx",
  "asyncpg",                # lub psycopg
  "pip-audit",
]

[tool.pytest.ini_options]
asyncio_mode = "auto"
addopts = "-ra --strict-markers --cov=src --cov-report=xml --junitxml=reports/junit.xml"
```

## 8. Templates

`templates/configs/python/`:
- `pyproject-test-deps.toml.tmpl`
- `conftest.py.tmpl`
- `pytest.ini.tmpl`
- `docker-compose.test.yml.tmpl`

## 9. Open questions

- Framework: FastAPI / Django / Flask? — wpływ na test client.
- ORM: SQLAlchemy 2.0 / Django ORM / raw asyncpg? — wpływ na migrations testowe.
- async vs sync? — FastAPI = async-first, Flask = sync. `pytest-asyncio` mode = `auto` lub `strict`.
- PM: pip / uv / poetry / pdm? — wpływ na CI install command.
