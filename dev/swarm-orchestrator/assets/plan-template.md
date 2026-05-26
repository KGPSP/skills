---
title: "<Feature title>"
slug: <feature-slug>
sprint-count: <N>
paths-in-scope:
  - <path/in/repo/>
out-of-scope:
  - "<co świadomie nie robimy w tym pościgu>"
fragile-paths-detected: false
---

# Co i dlaczego

<1-2 paragrafy: kontekst, problem, motywacja>

# Acceptance Criteria

| AC-ID | Typ | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | <funkcjonalne kryterium, mierzalne> | T-1 | <path/to/test> | `<single non-interactive cmd>` |
| AC-2 | NF | <niefunkcjonalne, mierzalne, z progiem> | T-2 | (build) | `<cmd>` |

# Definition of Done

- Wszystkie AC → komenda exit 0
- Build clean (zero warnings)
- Lint clean (zero errors)
- Coverage ≥ <X>% dla paths_in_scope
- Code review zero Critical

# Out of scope

- <co świadomie nie robimy — uzasadnienie>

# Sprints

## Sprint 1
<bundle AC, np. "AC-1, AC-3 — backend">

## Sprint 2
<...>

# Hyrum impact (DOC/material_skill.md §5)

- API publiczne zmieniane: <yes/no, lista>
- Backwards-compatible: <yes/no>
- Migration path: <opis lub n/a>

# Chesterton fence (DOC/material_skill.md §5)

- Kod usuwany: <lista lub none>
- Uzasadnienie usunięcia: <dlaczego można>

# Ryzyka

| # | Ryzyko | Mitygacja | Owner |
|---|---|---|---|
| 1 | <opis> | <plan> | <rola> |

# Decyzje architektoniczne

- <jedna decyzja per bullet, z uzasadnieniem>
