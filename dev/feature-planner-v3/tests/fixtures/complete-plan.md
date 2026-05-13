# Plan 999-fixture-complete

## Co i dlaczego

Fixture do testów `derive-goal-from-ac.sh` happy-path. Symuluje kompletny plan Phase 4.

## Acceptance Criteria

| AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | Funkcja `add(a,b)` zwraca sumę | T-1 | tests/add.test.js | `npm test -- tests/add.test.js` |
| AC-2 | F | Funkcja `sub(a,b)` zwraca różnicę | T-2 | tests/sub.test.js | `npm test -- tests/sub.test.js` |
| AC-3 | N | Suma 10000 wywołań <100ms | T-3 | tests/perf.test.js | `npm test -- tests/perf.test.js` |
| AC-4 | C | Brak zewnętrznych deps | T-4 | tests/deps.test.js | `npm run check-deps` |

## Definition of Done

- AC-1: stdout zawiera `PASS T-1`, exit 0.
- AC-2: stdout zawiera `PASS T-2`, exit 0.
- AC-3: stdout zawiera `duration < 100ms`, exit 0.
- AC-4: stdout zawiera `no external deps`, exit 0.

## Assumptions

- Node 20+ dostępny.
- npm test runner skonfigurowany.

## Out of scope

- Dzielenie i mnożenie (osobny plan).
- UI dla kalkulatora.

## Thin Vertical Slices

1. add + test.
2. sub + test.
3. perf check.
4. deps lint.

## Rollback plan

`git revert HEAD`.

## Target diff size

~80 linii.

## files-touched

- src/math.js
- tests/add.test.js
- tests/sub.test.js
- tests/perf.test.js
- tests/deps.test.js
