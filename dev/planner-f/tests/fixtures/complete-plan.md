# Plan 3 — health endpoint

## Co i dlaczego
Dodajemy `GET /health` aby load balancer wiedział, że instancja żyje. Cel: zero-downtime deploy.

## Acceptance Criteria
| AC-ID | Typ (F/N/C) | Priorytet | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|---|
| AC-F-01 | F | MUST | `GET /health` zwraca 200 + `{status:"ok"}` | health 200 | tests/health.test.ts | `pnpm test health` |
| AC-F-02 | F | MUST | `GET /health` zwraca 503 gdy DB down | health 503 | tests/health.test.ts | `pnpm test health` |
| AC-N-01 | N | SHOULD | p95 < 100ms @ 100rps | health perf | perf/health.spec.ts | `pnpm test:perf` |
| AC-C-01 | C | MUST | tsc strict bez błędów | tsc strict | tsconfig.json | `pnpm tsc --noEmit` |

## Definition of Done (specyfikacja dowodu)
| AC-ID | Komenda dowodu | Próg sukcesu | Lokalizacja artefaktu |
|---|---|---|---|
| AC-F-01 | `pnpm test health` | `2 passed, 0 failed` | plans/3-evidence/AC-F-01.log |
| AC-N-01 | `pnpm test:perf` | `p(95) < 100ms` | plans/3-evidence/AC-N-01.log |

## Assumptions
- DB health sprawdzamy istniejącym `db.ping()`.

## Out of scope
- Metryki Prometheus — osobny plan.
- Health dla zależności zewnętrznych (Redis) — follow-up.

## Thin Vertical Slices
### Slice 1 — endpoint + test (PR target ~60 linii)
Route handler `GET /health` + integration test 200/503.

## Rollback plan
Endpoint additive, brak migracji. `git revert` cofa całość.

## Target diff size
~60 linii (1 slice).

## Hyrum Risk
Brak — nowy eksport additive, zero callerów do zmiany.

## Relevant gotchas
- Soft-delete via deleted_at — nie dotyczy health.
