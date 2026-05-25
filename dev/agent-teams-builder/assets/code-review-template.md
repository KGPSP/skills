# CR-sprint-{N}-{slug} — Five-Axis Code Review

> Pisany przez **Evaluator** (lub delegacja do audited-feature-workflow Reviewer jeśli skill zainstalowany).
> Format Five-Axis Review przejęty z `dev/audited-feature-workflow/references/five-axis-review.md`.
> Wykonywany **po** `sprint_passed`, **przed** fazą 7 (ship).

---

## Metadata

- **Sprint:** {N} — <slug>
- **Reviewer:** evaluator (lub reviewer)
- **Date:** <YYYY-MM-DD>
- **Commits reviewed:** <hash_start>..<hash_end>
- **Diff stats:** `git diff --stat <hash_start>..<hash_end>` → <files changed>, <insertions>, <deletions>

---

## Change sizing

| Metric | Value | Threshold | Status |
|---|---|---|---|
| Linie zmienione (total) | <N> | ≤300 | ✅/⚠️/❌ |
| Pliki dotknięte | <N> | ≤15 | ✅/⚠️/❌ |
| Commits | <N> | każdy ≤100 linii | ✅/⚠️/❌ |
| Largest commit | <N> linii | ≤300 | ✅/⚠️/❌ |

**Verdict change sizing:** ✅ Acceptable / ⚠️ Large (uzasadnij) / ❌ Block (split required).

---

## Five-Axis findings

### Oś 1: Correctness

> Off-by-one, null safety, race conditions, boundary conditions, AC matching, error paths.

**Findings:**

| ID | Severity | File:line | Issue | Suggested fix |
|---|---|---|---|---|
| F-01 | Critical | src/editor/Canvas.tsx:42 | `array.length - 1` może zwrócić -1 dla pustej listy | Dodaj `if (array.length === 0) return null` |
| F-02 | Optional | src/editor/store.ts:88 | `useEffect` bez cleanup może leak'ować event listener | Dodaj `return () => element.removeEventListener(...)` |

**Score:** <N critical / N optional / N nit / N FYI>

### Oś 2: Readability & Simplicity

> Naming, function length <50 linii, brak przedwczesnych abstrakcji, brak "sprytnych" jednolinijkowców.

**Findings:**

| ID | Severity | File:line | Issue | Suggested fix |
|---|---|---|---|---|
| F-03 | Nit | src/editor/Canvas.tsx:120 | Funkcja `handleEvent` ma 78 linii (próg 50) | Wyekstrahuj 2-3 helpery |

### Oś 3: Architecture

> Duplikacje, cykliczne zależności, naruszenia granic modułów, layer leak, shared state.

**Findings:**

| ID | Severity | File:line | Issue | Suggested fix |
|---|---|---|---|---|
| F-04 | Optional | src/editor/store.ts ↔ src/playmode/store.ts | Duplikacja logiki `serialize()` (60% overlap) | Wyekstrahuj `src/lib/serialize.ts` |

### Oś 4: Security

> Input validation (Zod/Pydantic), SQL injection, XSS, CSRF, secrets, authZ, OWASP Top 10, CVE.

**Findings:**

| ID | Severity | File:line | Issue | Suggested fix |
|---|---|---|---|---|
| F-05 | Critical | src/editor/import.ts:15 | `JSON.parse(userInput)` bez try/catch — DoS przez malformed input | Wrap w try/catch + Zod schema validation |

### Oś 5: Performance

> N+1 queries, pętle bez base case, async I/O, cache-busting, memory leaks, bundle size.

**Findings:**

| ID | Severity | File:line | Issue | Suggested fix |
|---|---|---|---|---|
| F-06 | FYI | src/editor/Canvas.tsx:200 | Re-render każdej operacji drag (CLS=0.05 z perf report) | Rozważyć `React.memo` w v0.2 — nie blocking |

---

## Summary

| Severity | Count | Status |
|---|---|---|
| **Critical** | <N> | <N>=0 → ✅ / ≥1 → ❌ BLOCK |
| **Optional** | <N> | <N>≤5 → ✅ / ≥6 → ⚠️ |
| **Nit** | <N> | informacyjne |
| **FYI** | <N> | informacyjne |

**Total findings:** <N>

---

## Multi-Model Review (opcjonalne, dla L-size sprintów)

Jeśli sprint > 500 linii diff — uruchom dodatkowy review przez inny model (np. Sonnet) i porównaj.

- **Reviewer A (Opus):** <N critical / N optional / ...>
- **Reviewer B (Sonnet):** <N critical / N optional / ...>
- **Agreement rate:** <%>
- **Critical discrepancies:** <lista findings gdzie A i B się różnią>

---

## Verdict

> Wybierz JEDEN:

- [ ] ✅ **Approve** — 0 critical, ≤5 optional, code can ship.
- [ ] ⚠️ **Request changes** — critical/serious findings muszą być naprawione przed ship.
- [ ] ❌ **Block** — fundamental issues, pivot rozważyć.

**Reasoning:** <1-2 zdania uzasadnienia verdictu>

---

## Hyrum Impact summary

- **Publiczne API zmienione w tym sprincie:** <lista LUB "brak (greenfield)">
- **Klasyfikacja:** Breaking / Additive / Internal
- **Consumers wymagający migracji:** <lista LUB "brak">
- **Powiązane ADRs:** <linki do ADR-NNNN>

---

## Beyoncé Rule check

```bash
# Heurystyka: każdy nowy/zmieniony plik src/ ma odpowiadający test
git diff --name-only <hash_start>..<hash_end> | grep -E "^src/.*\.(ts|tsx|js)$" | while read f; do
  base=$(basename "$f" | sed 's/\.[^.]*$//')
  find tests/ -name "${base}.spec.ts" -o -name "${base}.test.ts" 2>/dev/null | head -1 || echo "MISSING: $f"
done
```

**Result:** <output skryptu>

---

## Links

- PRD: `state/prd/sprint-{N}.md`
- Contract: `state/contracts/sprint-{N}.json`
- QA Report: `state/qa-reports/sprint-{N}.md`
- Retrospective: `state/retrospectives/sprint-{N}.md`
- Commits: `git log --oneline <hash_start>..<hash_end>`
- ADRs created in sprint: <linki>
