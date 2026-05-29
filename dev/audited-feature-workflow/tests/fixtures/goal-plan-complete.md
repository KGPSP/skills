# Plan — sample feature (derive-goal source)

## Acceptance Criteria

| AC-ID | Typ | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | Endpoint zwraca 200 | returns 200 | tests/health.test.ts | npm test |
| AC-2 | C | tsc strict bez błędów | tsc strict | tests/types.test.ts | npm run tsc |

## Out of scope
- UI admin nie objęte tym planem.

## Definition of Done
- AC-1: npm test → 1 passed.
- AC-2: npm run tsc → exit 0.
