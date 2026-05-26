---
name: prd-input-schema
type: reference
parent: swarm-orchestrator
sources:
  - dev/audited-feature-workflow/references/goal-mode-protocol.md §3 (10 reguł walidacji)
---

# Schemat PRD/plan na wejściu

## Lokacja

User wskazuje plik przez `--prd <path>` lub `--goal <inline>`:
- `--prd path/to/PRD.md` — plik zostanie skopiowany do `state/plan.md` (planner zwykle go rozszerzy)
- `--goal "tekst inline"` — zapisany do `goal.md`, planner pisze plan.md od zera

Default discovery: jeśli ani `--prd` ani `--goal` — szuka `{workspace}/PRD.md` lub `{workspace}/plans/*.md`.

## Format PRD (obowiązkowy dla YOLO)

```markdown
---
title: "Feature X"
slug: feature-x
sprint-count: 3
paths-in-scope:
  - src/feature-x/
  - tests/feature-x/
out-of-scope:
  - "Refactoring sąsiednich modułów"
  - "Migracja DB"
fragile-paths-detected: false
---

# Co i dlaczego

<1-2 paragrafy: kontekst, problem, motywacja>

# Acceptance Criteria

| AC-ID | Typ | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | Endpoint `/api/x` zwraca 200 + JSON {id,name} | T-1 | tests/feature-x/api.spec.ts | npm test -- tests/feature-x/api.spec.ts |
| AC-2 | F | UI button "X" disabled gdy field empty | T-2 | tests/feature-x/ui.spec.ts | npm test -- tests/feature-x/ui.spec.ts |
| AC-3 | NF | Build zero warnings | T-3 | (build) | npm run build |

# Definition of Done

- Wszystkie AC w tabeli → komenda exit 0
- Build clean (`npm run build` → 0 warnings)
- Lint clean (`npm run lint` → 0 errors)
- Coverage ≥ 80% dla zmienionych plików
- Code review zero Critical

# Out of scope

- Refactoring modułu `legacy/` (osobny sprint)
- Migracja schematu DB (Fragile zone, wymaga osobnego PR)

# Sprints

## Sprint 1
AC-1, AC-3 — backend endpoint + build

## Sprint 2
AC-2 — UI integration

## Sprint 3
Polish + edge cases
```

## Walidacja (swarm-derive-goal.sh)

10 reguł (z `goal-mode-protocol.md §3`):

1. **Frontmatter zawiera `paths-in-scope:`** (lista YAML, niepusta) — exit 1 z "missing paths-in-scope".
2. **Sekcja `# Acceptance Criteria` istnieje** — exit 1.
3. **Tabela AC ma 6 kolumn:** AC-ID / Typ / Opis / Test ID / Plik testu / Komenda — exit 1 jeśli mniej.
4. **Każda AC ma niepustą `Komenda`** — exit 1 z listą pustych AC.
5. **`Komenda` jest single command:** brak `&&`, `||`, `;`, `|`, `$()`, backticks — exit 1 z listą problematycznych.
6. **`Komenda` non-interactive:** brak `read`, `vi`, `nano`, `htop` etc. — warning (nie blocker).
7. **`Plik testu` istnieje** w `paths-in-scope` jako relatywna ścieżka — exit 1 z listą missing.
8. **Sekcja `# Out of scope` ma ≥1 bullet** — exit 1.
9. **AC nie jest subiektywne:** opis nie zawiera „ładnie", „szybciej" bez progu — exit 1 z listą subjective AC.
10. **`paths-in-scope` nie zawiera Fragile zone** (chyba że `--force-fragile`) — exit 5.

## Fragile zones (egzekwowane w YOLO)

Lista (rozszerzalna przez env `FRAGILE_PATHS`):
- `migrations/` — zmiany schemy DB
- `terraform/` — IaC
- `k8s/` — Kubernetes manifesty
- `auth/` — autentykacja/autoryzacja
- `.github/workflows/` — CI/CD
- `Dockerfile`, `docker-compose.yml`
- `prod*` — produkcyjne konfigi

`swarm-derive-goal.sh` skanuje `paths-in-scope` przed wygenerowaniem `goal-statement.md`. Match (case-insensitive, prefix) → exit 5 z listą wykrytych.

Override: `--force-fragile` → dopisuje breadcrumb `fragile_override {"paths":[...],"reason":"<user-provided>"}` + kontynuuje. Operator wziął odpowiedzialność.

## Inline goal (alternative dla `--goal`)

Dla quick experiments (manual/hybrid mode, NIE yolo):

```sh
scripts/swarm-start.sh --workspace . --goal "Endpoint /api/health zwraca 200 z body {status:ok}. Test: curl -fs http://localhost:3000/api/health | jq -e '.status == \"ok\"'"
```

Tekst trafi do `goal.md`. Planner musi rozbudować do pełnego `state/plan.md` z AC table w fazie 3. Inline goal **nie nadaje się** dla YOLO bo brak frontmatter + AC table — `swarm-derive-goal.sh` odmówi.

## Konwersja inline → PRD (helper, opcjonalnie)

V1.0.0 nie ma `scripts/inline-to-prd.sh` — manualny krok:
1. `swarm-start --goal "..."`  
2. Czekaj na planner output `state/plan.md`
3. Manualnie dopisz frontmatter + AC table
4. Re-run `swarm-derive-goal.sh --plan state/plan.md`

V1.1.0 może dodać auto-konwersję jeśli use case popularny.
