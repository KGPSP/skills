---
title: Protokół zbierania dowodów Definition of Done dla zespołu agentów
load-when: "Faza 6 SKILL.md (Verify) LUB zamknięcie sprintu z passed == total"
source:
  - DOC/material_skill.md §4 (Definition of Done)
  - DOC/since_skill.md §2 (Filar 3: Non-negotiable Verification)
  - DOC/agent-teams-generator-ewaluator.md §4 (Rubryka — twarde progi)
---

# Definition of Done — dowodowy audit fazy 6

> Status "Gotowe" bez artefaktu jest **błędem systemu**, nie zakończeniem zadania. Każdy element DoD ma sprawdzalny dowód w `state/evidence/`.

---

## 1. Checklist DoD per sprint

Każdy sprint MUSI mieć ✅ na wszystkich punktach:

| Punkt DoD | Walidator | Lokalizacja dowodu |
|---|---|---|
| **Clean build** | `npm run build 2>&1 \| tee state/evidence/sprint-{n}/build.log; echo $?` | `state/evidence/sprint-{n}/build.log` |
| **Beyoncé Rule** | heurystyka: dla każdego pliku w `git diff --name-only` z `src/` istnieje odpowiadający test w `tests/` | `state/evidence/sprint-{n}/coverage-report.json` |
| **Runtime evidence** | `ls state/evidence/sprint-{n}/*.{png,har,log}` | per kryterium kontraktu |
| **PR Sizing ≤300** | `git diff --stat HEAD~N..HEAD \| tail -1` (linia "X files changed, Y insertions, Z deletions") | `state/evidence/sprint-{n}/diff-stat.txt` |
| **Scope Discipline** | `scripts/check-scope-discipline.sh sprint-{n}` | git diff w breadcrumbs |
| **Contract coverage 100%** | `scripts/check-contract-coverage.sh sprint-{n}` | `state/contracts/sprint-{n}.json` |
| **Rubric — binarne** | `scripts/verify-evaluator-rubric.sh sprint-{n}` | brak skal 1-10 w kontrakcie |
| **Breadcrumbs append-only** | `scripts/check-breadcrumbs-append-only.sh` | git diff `state/breadcrumbs.json` |
| **Role isolation** | `scripts/verify-role-isolation.sh` | `produced_by` w evidence metadata |
| **Non-negotiables** | `scripts/verify-non-negotiables.sh` | exit 0 = wszystkie 5 zachowane |
| **Evidence completeness** | `scripts/check-evidence-completeness.sh sprint-{n}` | każde passed=true ma plik |

**Wszystkie 9 zielone → sprint zamknięty.**

---

## 2. Hierarchia akceptowalnych dowodów

Według preferencji (od najmocniejszego):

### 2.1 Najsilniejsze — automatyczna weryfikacja

1. **Surowy output testu**:
   ```
   Test Suites: 8 passed, 8 total
   Tests:       42 passed, 42 total
   Snapshots:   0 total
   Time:        4.218 s
   ```
   Zapisywane przez `npm test 2>&1 | tee state/evidence/sprint-{n}/tests.log`.

2. **Czysty build output**:
   ```
   webpack 5.89.0 compiled successfully in 8421 ms
   0 errors, 0 warnings
   ```

3. **Hash gita commitu z passem**: `git rev-parse HEAD` w breadcrumbs.

### 2.2 Średnio silne — half-automatic

4. **Playwright trace** — `.zip` z czasem nagrania + screenshoty + DOM snapshots. Reprodukowalne.

5. **Chrome DevTools HAR** — pełny network trace.

6. **curl output + status code**: `curl -i -X POST ... 2>&1 | tee state/evidence/sprint-{n}/api-C-03.log`.

### 2.3 Słabsze — manualna interpretacja

7. **Screenshot** (PNG) — wizualna weryfikacja layoutu. Wymaga `evaluator_observation` w JSON.

8. **Computer Use trace** — log akcji + screenshot. Dla aplikacji desktopowych.

### 2.4 NIE-dowody (odrzucane)

| To NIE jest dowód | Riposta |
|---|---|
| „Wszystko zielone, sprawdziłem" | Wklej output |
| Streszczenie wyników | Tylko surowy output |
| Polecenie referencyjne („`npm test` → ok") | Wklej output polecenia |
| Wewnętrzne rozumowanie agenta | Dowód = artefakt na dysku |
| Commit message z deklaracją | Komunikat nie jest weryfikowalny |

---

## 3. Struktura `state/evidence/`

```
state/evidence/
├── sprint-1/
│   ├── C-01.png                 # screenshot kryterium funkcjonalnego
│   ├── C-01.metadata.json       # {"produced_by": "evaluator", "ts": "...", "tool": "playwright"}
│   ├── C-02.log                 # output npm test
│   ├── C-03.har                 # network trace
│   ├── tests.log                # globalny output tests/
│   ├── build.log                # output build
│   ├── coverage-report.json     # output coverage
│   └── diff-stat.txt            # git diff --stat
├── sprint-2/
│   └── ...
└── pivots/
    └── sprint-2-pivot-2026-05-19T18-00/
        ├── pivot_plan.md
        ├── before-hash.txt
        └── archive-branch.txt
```

---

## 4. Metadata każdego artefaktu

Każdy plik evidence ma `*.metadata.json`:

```json
{
  "produced_by": "evaluator",
  "criterion_id": "C-01",
  "sprint": 2,
  "iteration": 4,
  "ts": "2026-05-19T17:45:23Z",
  "tool": "playwright",
  "tool_version": "1.42.0",
  "commit_hash": "a3f9b21c",
  "passed": true,
  "observation": "Kursor przesuwa się o 32px po wciśnięciu ArrowRight, zgodnie z C-01"
}
```

**Dlaczego metadata:**

1. **Audit:** kto wygenerował dowód (Evaluator, nie Generator — sędzia we własnej sprawie).
2. **Reprodukowalność:** wersja narzędzia + commit hash.
3. **Wyszukiwanie:** `jq` po criterion_id, sprint, passed.

Brak metadata = artefakt nieważny.

---

## 5. Raport końcowy fazy 6

`state/verify-report.md`:

```markdown
# Verify Report — 2026-05-19T20:00

## Sprinty
| Sprint | Status | Kryteria passed/total | Evidence | Pivots | Commits |
|---|---|---|---|---|---|
| 1 | passed | 18/18 | state/evidence/sprint-1/ | 0 | 3 |
| 2 | passed | 17/17 | state/evidence/sprint-2/ | 1 | 5 |
| 3 | passed | 22/22 | state/evidence/sprint-3/ | 0 | 4 |

## Walidatory
- [✅] `npm run build` exit 0 (inline)
- [✅] Beyoncé heuristic — testy obecne dla każdego src file w diff
- [✅] `git diff --stat` — PR size ≤300
- [✅] check-scope-discipline.sh
- [✅] check-contract-coverage.sh (per sprint)
- [✅] verify-evaluator-rubric.sh (per sprint)
- [✅] check-breadcrumbs-append-only.sh
- [✅] check-evidence-completeness.sh
- [✅] verify-role-isolation.sh
- [✅] verify-non-negotiables.sh

## Test pyramid
- Unit: 142 testów (84%)
- Integration: 21 testów (12%)
- E2E: 7 testów (4%)
- Verdict: ✅ zgodne z 80/15/5

## Five-Axis Review (jeśli zainstalowany)
- Correctness: ✅
- Readability: ✅
- Architecture: ✅
- Security: ✅
- Performance: ✅ (4 N+1 fixed in sprint-3)

## Git log
- a3f9b21 sprint-3: editor canvas (4 commits, 287 lines)
- 8c4e1d2 sprint-2: toolbar (5 commits, 412 lines — split into 2 PRs)
- 1f7a93b sprint-1: foundations (3 commits, 198 lines)

## Time spent
- Total: 5h 42min
- Pivots: 1 (sprint-2, 18 min)
- Avg iteration: 6.2 min

## Verdict
✅ Ready to ship (faza 7)
```

---

## 6. Blokady fazy 6

Faza 6 NIE może być zamknięta jeśli:

- Jakikolwiek walidator zwraca exit ≠ 0.
- Jakiekolwiek `passed: true` w kontrakcie nie ma odpowiadającego pliku w `evidence/`.
- Jakikolwiek artefakt nie ma `metadata.json`.
- Hash gita w breadcrumbs nie zgadza się z `git log` (audit tampering).
- Brak `verify-report.md`.

Brak któregokolwiek → eskalacja do human → `state/blockers.md`.

---

## 7. Exit criterion fazy 6

```bash
test -f state/verify-report.md && \
grep -q "✅ Ready to ship" state/verify-report.md && \
scripts/verify-non-negotiables.sh && \
scripts/check-evidence-completeness.sh --all-sprints
```

Wszystkie 4 zielone → faza 7 (ship) odblokowana.
