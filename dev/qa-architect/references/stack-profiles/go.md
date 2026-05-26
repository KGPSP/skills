---
name: go
type: reference
parent: qa-architect
sources:
  - DOC/QA-swarm.md §7 (dobór narzędzi — adaptacja Go)
description: Profile dla Go (net/http, Gin, Echo, Fiber + PostgreSQL). Loaded when detect-stack.sh returns stack=go.
---

# Profile: Go (net/http, Gin/Echo/Fiber + PostgreSQL)

## 1. Stack assumptions

- **Framework:** net/http (stdlib) lub Gin, Echo, Fiber.
- **DB:** PostgreSQL via `pgx` (preferowany) lub `database/sql` + `lib/pq`.
- **Language:** Go ≥ 1.22.
- **PM:** Go modules.

## 2. Tooling per warstwa

| Warstwa | Tool | Powód |
|---|---|---|
| Unit | **`testing`** (stdlib) + `testify/assert` (opcjonalnie) | Standard Go |
| Integration HTTP | `testing` + **`httptest.NewServer`** + `http.Client` | stdlib pattern |
| Integration DB | **`testcontainers-go`** + `postgres` module | Realny Postgres |
| E2E (gdy frontend) | **Playwright** (CLI) lub `chromedp` (Go-native) | Playwright dla parity ze stackami JS |
| Mocking HTTP outbound | `httptest.Server` jako fake upstream | Nie potrzeba zewnętrznej biblioteki |
| Mocking lokalne | Interface substitution (DI) | Idiomatyczny Go |
| Perf | k6 | — |
| Security | `govulncheck` + Dependency Review + ZAP baseline | — |

## 3. Wykluczenia / anti-patterns

| Co | Status | Powód |
|---|---|---|
| `sqlmock` zamiast Testcontainers | Anti-pattern dla logiki query | sqlmock OK dla testów error handling, NIE dla query correctness |
| `gomock` / `mockery` dla DB | Anti-pattern | Interface substitution + Testcontainers wystarczy |
| Globalne stany testów | Anti-pattern | t.Cleanup() + per-test isolation |

## 4. Struktura katalogów (idiomatic Go)

```
my-app/
├── go.mod
├── cmd/
│   └── server/main.go
├── internal/
│   ├── api/
│   │   ├── handlers.go
│   │   └── handlers_test.go   # _test.go kolokowane
│   ├── service/
│   │   ├── user.go
│   │   └── user_test.go
│   └── db/
│       ├── repo.go
│       └── repo_int_test.go   # //go:build integration
├── tests/
│   └── e2e/                   # Playwright (osobny projekt JS)
└── docker-compose.test.yml
```

## 5. Wzorzec test integration HTTP (httptest)

```go
func TestGetUser(t *testing.T) {
    h := http.HandlerFunc(getUserHandler)
    srv := httptest.NewServer(h)
    defer srv.Close()

    resp, err := http.Get(srv.URL + "/users/1")
    require.NoError(t, err)
    require.Equal(t, 200, resp.StatusCode)
}
```

## 6. Wzorzec integration DB (testcontainers-go)

```go
//go:build integration

func TestRepo(t *testing.T) {
    ctx := context.Background()
    pgContainer, err := postgres.RunContainer(ctx,
        testcontainers.WithImage("postgres:16-alpine"),
        postgres.WithDatabase("app_test"),
        postgres.WithUsername("app"),
        postgres.WithPassword("app"),
        testcontainers.WithWaitStrategy(wait.ForLog("database system is ready to accept connections").WithOccurrence(2)),
    )
    require.NoError(t, err)
    t.Cleanup(func() { pgContainer.Terminate(ctx) })

    connStr, err := pgContainer.ConnectionString(ctx)
    require.NoError(t, err)

    pool, err := pgxpool.New(ctx, connStr)
    require.NoError(t, err)
    t.Cleanup(func() { pool.Close() })

    // ... use pool in transaction with t.Cleanup rollback
}
```

## 7. Build tags dla separacji

```go
//go:build integration
// +build integration
```

Run:
- Unit only: `go test ./...`
- Integration: `go test -tags=integration ./...`
- All: `go test -tags=integration ./...`

## 8. Wymagane dependencies (`go.mod`)

```
require (
    github.com/jackc/pgx/v5 latest
    github.com/testcontainers/testcontainers-go latest
    github.com/testcontainers/testcontainers-go/modules/postgres latest
    github.com/stretchr/testify latest  // opcjonalnie
)
```

## 9. Templates

`templates/configs/go/`:
- `go-test-deps.txt` (lista require)
- `testcontainers-postgres.go.tmpl`
- `docker-compose.test.yml.tmpl`

## 10. Open questions

- Framework: stdlib net/http / Gin / Echo / Fiber? — wpływ na handler signature i test pattern.
- ORM: pgx (raw) / sqlc (codegen) / GORM / ent? — wpływ na test repo.
- Czy aplikacja ma frontend? — jeśli tak, Playwright osobny projekt JS w `tests/e2e/`.
- `govulncheck` w CI: `go install golang.org/x/vuln/cmd/govulncheck@latest && govulncheck ./...`.
