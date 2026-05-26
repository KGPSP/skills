---
name: dod-evidence-protocol
type: reference
parent: qa-architect
sources:
  - DOC/material_skill.md §4 (Definition of Done), §8 (#4 — twardy dowód)
  - DOC/since_skill.md §5 (Prove-It Pattern), §6 (raw log requirement)
  - DOC/QA-swarm.md §12.5 (checklisty)
description: Format twardych dowodów dla blueprintu qa-architect. Każda faza wymaga konkretnego artefaktu z mierzalnym exit criterion. Bez raw artifacts → DoD niespełnione → blokada następnej fazy.
---

# Definition of Done — qa-architect

> [!important] Zasada nadrzędna
> **Deklaracja „done" bez artefaktu = błąd systemu, nie zakończenie fazy.** Każda faza ma exit criterion sprawdzalny skryptem lub treścią pliku. Wkleić raw output, nie parafrazować.

## 1. Per-faza DoD

| Faza | Artefakt | Wymagany raw output | Skrypt weryfikacyjny |
|---|---|---|---|
| **0** | `qa-blueprint/00-environment.md` | Raw JSON z `scripts/detect-stack.sh` | `sh scripts/detect-stack.sh` exit 0 |
| **1** | `qa-blueprint/01-discovery.md` | Gap matrix + lista istniejących configów/testów/CI z `Read`/`Glob` | brak — manualnie verified w Phase 7 |
| **2** | `qa-blueprint/02-tooling.md` | 9 sekcji decyzji + Anti-rationalization decisions | Phase 7 reviewer sprawdzi obecność sekcji |
| **3** | `qa-blueprint/03-layer-strategy.md` | Piramida + 2 modyfikacje + macierz + exclusions | reviewer Phase 7 |
| **4** | `qa-blueprint/04-swarm-plan.md` | Tabela zadań z exit_criterion per task + APPROVAL #1 log | manualnie + reviewer |
| **5** | Pliki w `configs/`, `samples/`, `ci/` | Output każdego sub-agenta agregowany przez Managera do `qa-strategy.md` Phase 6 (sekcja Execution log) | reviewer Phase 7 |
| **6** | `qa-strategy.md`, `CLAUDE.md.patch`, `AGENTS.md`, `verify-tests/SKILL.md`, `checklists.md`, `pilot-4-weeks.md` | wszystkie pliki istnieją | `scripts/check-blueprint-complete.sh` |
| **7** | `07-verification.md` + `07-review.md` | Raw output 2 skryptów (exit 0) + reviewer 5-axis (0 Critical) | `check-blueprint-complete.sh` + `verify-postgres-strategy.sh` |
| **8** | `HANDOFF.md` + opcjonalny patch CLAUDE.md | APPROVAL #2 log + diff (jeśli patchowany) | git diff jeśli patch zastosowany |

## 2. Format raw output

### Stack detection

```log
$ sh scripts/detect-stack.sh ./
{
  "stack": "nextjs",
  "components": ["nextjs"],
  "package_manager": "pnpm",
  "db_driver": "pg",
  "has_existing_tests": false,
  "has_existing_ci": false,
  "project_size_files": 47,
  "project_size_class": "S",
  "fragile_paths": ["CLAUDE.md", ".github/workflows/"]
}
$ echo $?
0
```

### Blueprint completeness

```log
$ sh scripts/check-blueprint-complete.sh ./qa-blueprint
[OK] 00-environment.md
[OK] 01-discovery.md
[OK] 02-tooling.md
[OK] 03-layer-strategy.md
[OK] 04-swarm-plan.md
[OK] configs/vitest.config.ts
[OK] configs/playwright.config.ts
[OK] configs/docker-compose.test.yml
[OK] samples/unit.test.tsx
[OK] samples/integration-http.test.ts
[OK] samples/integration-db.int.test.ts
[OK] samples/e2e.spec.ts
[OK] ci/pr.yml
[OK] ci/nightly.yml
[OK] ci/prerelease.yml
[OK] qa-strategy.md
[OK] CLAUDE.md.patch
[OK] AGENTS.md
[OK] .claude/skills/verify-tests/SKILL.md
[OK] checklists.md
[OK] pilot-4-weeks.md
[OK] HANDOFF.md
[OK] 07-verification.md
[OK] 07-review.md
Result: 24/24 files present
$ echo $?
0
```

### Anti-mock check

```log
$ sh scripts/verify-postgres-strategy.sh ./qa-blueprint
Scanning for anti-patterns: jest.mock\\(.*pg, vi.mock\\(.*postgres, pg-mem, pg-memory, monkeypatch.*psycopg, sqlmock
Files scanned: 4 sample files + 3 configs
[CLEAN] No Postgres mocking anti-patterns found
$ echo $?
0
```

### Reviewer verdict (Five-Axis)

W `07-review.md`:

```markdown
# Five-Axis Review — qa-blueprint

## Verdict: PASS

Critical findings: 0
Optional findings: 2
Nit findings: 5
FYI findings: 3

## Findings

### Correctness
- [Nit] samples/integration-db.int.test.ts używa BEGIN/ROLLBACK bez SAVEPOINT — dla nested transaction tests wymaga SAVEPOINT.

### Readability & Simplicity
- [Optional] vitest.config.ts ma 73 linie — można uprościć przez wynesienie coverage config do `vitest.config.coverage.ts`.

### Architecture
- [Optional] CLAUDE.md.patch importuje AGENTS.md przez `@AGENTS.md` — OK, paper §3.2.

### Security
- [FYI] ci/pr.yml uruchamia `npm audit --audit-level=high` — OK dla S/M, dla L rozważ `moderate`.

### Performance
- [Nit] playwright.config.ts ma 8 workers — domyślnie 4 dla CI runner.
```

## 3. Akceptowalne typy dowodów

| Typ | Format | Przykład |
|---|---|---|
| Stack detection | Raw JSON exit 0 | §2 |
| Plik istnieje | `[OK] <path>` per plik + `Result: N/N files present` | §2 |
| Składnia config OK | `sh -n` / `tsc --noEmit` / `yamllint` exit 0 | — |
| Brak anti-pattern | `[CLEAN] No <pattern> found` exit 0 | §2 |
| Review pass | `## Verdict: PASS` + `Critical findings: 0` | §2 |
| APPROVAL log | `> User accepted at <ISO timestamp>: <verbatim quote>` | — |

## 4. Anti-patterns w DoD

| Anti-pattern | Dlaczego źle | Co zamiast |
|---|---|---|
| „Blueprint kompletny, sprawdziłem ręcznie" | LLM judgment ≠ deterministyczny sprawdź | Uruchom `check-blueprint-complete.sh` |
| „Skrypt by przeszedł, nie warto uruchamiać" | Brak weryfikacji = halucynacja | Uruchom + wklej output |
| „Reviewer pokazał Optional, łapię to" | Brak zapisu = brak audit trail | Zapisz w `07-review.md` |
| „APPROVAL ustnie, nie loguję" | Brak audit trail = niespójność z DoD #4 | Wklej cytat usera + timestamp |
| Parafraza output (np. „wszystko OK") | Subiektywne | Raw log dosłowny |

## 5. Final DoD checklist (master)

Przed deklaracją Phase 8 done — przejdź **wszystkie**:

- [ ] `00-environment.md` ma raw JSON z detect-stack.sh
- [ ] `01-discovery.md` ma Gap matrix
- [ ] `02-tooling.md` ma 9 decyzji + Anti-rationalization
- [ ] `03-layer-strategy.md` ma piramidę + 2 modyfikacje + exclusions
- [ ] `04-swarm-plan.md` ma tabelę zadań + APPROVAL #1 log
- [ ] `configs/` ma kompletne pliki per stack
- [ ] `samples/` ma 1 plik per wymagana warstwa
- [ ] `ci/` ma 3 workflowy (pr/nightly/prerelease)
- [ ] `qa-strategy.md` scala wszystko, linki działają
- [ ] `CLAUDE.md.patch` + `AGENTS.md` + `verify-tests/SKILL.md`
- [ ] `checklists.md` + `pilot-4-weeks.md`
- [ ] `07-verification.md` ma raw outputs 2 skryptów (oba exit 0)
- [ ] `07-review.md` ma `Verdict: PASS` + 0 Critical
- [ ] `HANDOFF.md` ma APPROVAL #2 log

Brak czegokolwiek = Phase 8 STOP, doflesh artefakt, dopiero potem deklaruj done.
