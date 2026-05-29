# Analysis Report — plan #42 — sample

- effort-level: max

## Stack
Next.js 14 (app router) + Prisma/Postgres + Vitest.

## Architektura
Entry: app/api/*/route.ts → Service: services/*.ts → DB: Prisma.

## Analog featuru (PRIMARY TEMPLATE)
`src/features/shelters/` — list endpoint z filtrem.

## Data model — affected
Tabela Shelter, relacja powiatId.

## Dependency impact radius
Wymagają: src/types/api.ts.

## Test conventions
Fixture buildShelter(), per-test transakcja.

## Patterns catalog
Validation = zod.

## Open questions
