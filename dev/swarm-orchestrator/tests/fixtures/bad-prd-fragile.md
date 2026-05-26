---
title: "DB migration"
slug: db-migration
sprint-count: 1
paths-in-scope:
  - migrations/
  - terraform/database/
out-of-scope:
  - "Application code"
fragile-paths-detected: true
---

# Co i dlaczego

Dodajemy kolumnę `created_at` do `users` table. Trzeba migration + Terraform apply.

# Acceptance Criteria

| AC-ID | Typ | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | Migration up działa | T-1 | tests/db/migration.spec.sql | psql -f tests/db/migration.spec.sql |
| AC-2 | F | Terraform plan zero changes | T-2 | terraform/database/ | terraform plan -detailed-exitcode |

# Out of scope

- Backend code zmieniający SELECT

# Sprints

## Sprint 1
AC-1, AC-2
