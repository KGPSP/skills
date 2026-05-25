# Plan 999-fixture-incomplete

## Co i dlaczego

Fixture do testów `derive-goal-from-ac.sh` fail-path. Brak `Komenda` w AC-2.

## Acceptance Criteria

| AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | Funkcja `add(a,b)` zwraca sumę | T-1 | tests/add.test.js | `npm test -- tests/add.test.js` |
| AC-2 | F | Funkcja `sub(a,b)` zwraca różnicę | T-2 | tests/sub.test.js |  |
| AC-3 | N | Suma 10000 wywołań <100ms | T-3 | tests/perf.test.js | `npm test -- tests/perf.test.js` |

## Definition of Done

- AC-1: stdout zawiera `PASS T-1`, exit 0.

## Out of scope

- Dzielenie i mnożenie.
