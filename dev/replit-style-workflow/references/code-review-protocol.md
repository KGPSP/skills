# references/code-review-protocol.md

Protokół dla Phase 8 — **Code Review**. Cel: zweryfikować, czy implementacja spełnia
*Acceptance Criteria* z Phase 8.1 i nie wprowadza regresji, security gaps ani naruszeń patterns
catalog. Output to **CR report** z werdyktem AC + listą findings posortowanych wg severity.

> **Zasada nadrzędna:** review jest *AC-driven*, nie *style-driven*. Każdy finding poza AC
> ma być realnym defektem (bug, security, regresja, maintainability z konkretnym kosztem),
> nie preferencją stylistyczną.

---

## Postawa review

Priorytetyzuj findings w tej kolejności (Phase 8.4 grupuje wg severity, ale uważność reviewera idzie tak):

1. **Bugi correctness** — kod nie robi tego, co AC mówi.
2. **Bezpieczeństwo i utrata danych** — RODO leak, SQL injection, XSS, brak auth check, TOCTOU.
3. **Regresje behawioralne** — istniejący feature przestał działać.
4. **Brak testów dla zmienionego behavior** — AC bez `test::name` w Trace matrix.
5. **Naruszenia patterns catalog** — niespójność z Analysis Report 1.7 (np. error handling, DTO shape).
6. **Maintainability z konkretnym kosztem** — np. ścieżka, którą musimy zmieniać przy każdej feature flag.

**Anty-priorytety** (nie raportuj jako findings):
- Style code (formatowanie, naming preferencji) — od tego jest linter.
- „Mogłoby być DRY" bez wskazania konkretnego punktu zmiany w przyszłości.
- Sugestie refaktoringu bez impact analysis.

---

## AC verdict — kontrakt z Phase 8.1

Dla **każdego AC** (F/T/N) z Phase 8.1 wystaw werdykt:

| Verdict | Znaczenie | Wymagany dowód |
|---------|-----------|-----------------|
| ✅ **PASS** | AC spełnione | `file:line` lub `test::name` |
| ❌ **FAIL** | AC niespełnione lub naruszone | wskazanie miejsca w kodzie / brakującego testu |
| ⚠️ **PARTIAL** | AC spełnione tylko częściowo | konkretna luka (np. „działa dla powiatu, brak dla województwa") |

**Priorytety AC (z Phase 8.1, MoSCoW):**

- `[MUST]` — `FAIL` blokuje merge. Phase 9 (ADR) niedostępne dopóki nie naprawione.
- `[SHOULD]` — `FAIL` blokuje ADR, ale nie blokuje merge w trybie awaryjnym (decyzja userska, udokumentowana).
- `[COULD]` — `FAIL` → backlog ticket, nie blokuje niczego.

**Anti-pattern:** PASS bez dowodu. Każdy ✅ ma wskazywać `tests/integration/x.test.ts::"name"` albo `src/lib/y.ts:42`.

---

## Severity dla findings poza AC

| Symbol | Poziom | Definicja | Przykład |
|--------|--------|-----------|----------|
| 🔴 | **Critical** | Bug, security, data loss, blokuje merge | Brak auth check na endpoincie zwracającym dane RODO |
| 🟡 | **Major** | Regresja, brak testu na zmienionej ścieżce, naruszenie pattern catalog | Inny error handling niż w analogu |
| 🟢 | **Minor** | Maintainability, dokumentacja, follow-up | Brak komentarza nad nieobvious workaroundem |

**Reguła konwersji:**
- Naruszenie `AC-MUST` → automatycznie 🔴.
- Naruszenie `AC-SHOULD` → 🟡.
- Findings poza AC: oceniasz manualnie wg powyższej tabeli.

---

## Output shape — CR report

Zapisz do `docs/code-reviews/CR-PLAN_NUM-[name].md`:

```markdown
# CR-PLAN_NUM — [feature name]
Backend: `${CR_BACKEND}` | Commits: `${FIRST_COMMIT}..${LAST_COMMIT}` | Diff: ${DIFF_SIZE} linii

## AC verdict
| AC      | Priorytet | Verdict     | Dowód                                           |
|---------|-----------|-------------|-------------------------------------------------|
| AC-F-1  | MUST      | ✅ PASS      | `tests/integration/shelters.test.ts::"filters"` |
| AC-F-2  | MUST      | ❌ FAIL      | brak obsługi pustej listy                       |
| AC-T-1  | SHOULD    | ⚠️ PARTIAL  | error shape OK, brak structured logging        |
| AC-N-1  | SHOULD    | ⚠️ PARTIAL  | p95=620ms (target <500ms)                       |

## 🔴 Critical (blokuje merge)
### [1] src/api/shelters.ts:142 — Brak walidacji powiat code
**AC:** AC-F-2 (MUST)
**Problem:** Endpoint nie waliduje wartości `powiat` przed query — pozwala na dowolny string.
**Failure mode:** SQL injection przez Prisma raw, jeśli kiedyś przepiszemy z findMany na `$queryRaw`.
**Fix:** użyj enum z `prisma/schema.prisma::Powiat` albo zod parser z listy TERYT.

## 🟡 Major (blokuje ADR)
### [2] src/services/shelter-service.ts:67 — Inconsistent error shape
**AC:** AC-T-1 (SHOULD)
**Problem:** Rzucasz `new Error()` zamiast `AppError` (patrz Patterns catalog 1.7 → Error handling).
**Failure mode:** Frontend nie ma `error.code` do mapowania toast'u.
**Fix:** `throw new AppError('SHELTER_NOT_FOUND', { powiat })` zgodnie z analogiem.

## 🟢 Minor (backlog)
### [3] src/lib/teryt.ts:14 — Magic number 16
**AC:** —
**Problem:** Liczba województw zaszyta na sztywno; zmiana administracyjna = silent bug.
**Fix:** Stała `WOJEWODZTW_COUNT` lub odczyt z `Object.keys(TERYT.WOJ).length`.

## Open Questions
- Czy AC-N-1 (p95<500ms) jest twardy, czy pomiar przy `EXPLAIN ANALYZE` pokazał, że brakuje
  indeksu na `shelters(powiat_code, dostepnosc)` — dodać teraz, czy follow-up?

## Podsumowanie
- AC MUST spełnione: 1/2 (AC-F-2 wymaga fix)
- AC SHOULD spełnione: 0/2 (oba PARTIAL)
- Blokery merge: 1 × 🔴 (finding [1])
- Blokery ADR: 1 × 🟡 (finding [2]) + 2 × AC-SHOULD PARTIAL
- Decyzja: **FIX-FIRST** — napraw [1] i [2], przepuść AC-N-1 do follow-up jeśli user akceptuje.

## Tests
Diff testów (12 nowych):
- `unit/validators/shelter.test.ts` — 4 testy (3 happy + 1 boundary)
- `integration/api/shelters.test.ts` — 6 testów (mapowane na AC-F-1, AC-F-3, AC-T-2)
- `e2e/shelter-list.spec.ts` — 2 testy (golden + dropdown)

Brakuje: test dla AC-F-2 (pusta lista) — uzupełnić w fixach.
```

---

## Inline comments (gdy backend wspiera, np. ultrareview / GitHub PR)

Emit jeden directive per finding:

```text
::code-comment{title="🔴 [P1] Brak walidacji powiat code" body="Endpoint nie waliduje powiat przed query. Failure mode: SQL injection po przepisaniu na $queryRaw. Fix: zod parser z listy TERYT albo enum z Prisma schema." file="/abs/path/src/api/shelters.ts" start=140 end=145 priority=1 confidence=0.9}
```

Mapowanie symbolu na priority:
- 🔴 → `priority=1`
- 🟡 → `priority=2`
- 🟢 → `priority=3`

---

## Brak findings — happy path

Gdy review nie znalazł nic blokującego:

```markdown
## Podsumowanie
- AC MUST: 3/3 ✅
- AC SHOULD: 2/2 ✅
- AC COULD: 1/2 (AC-COULD-1 PARTIAL → backlog)
- Blokery merge: brak
- Blokery ADR: brak
- Decyzja: **PROCEED** → Phase 9 (ADR)

Residual risk: pomiar perf na produkcji (AC-N-1 zmierzony na staging, p95=420ms — w budżecie).
```

---

## Post-implementation review checklist

Przed napisaniem CR raportu — review reviewera:

- [ ] Przeczytałem **plan** (`docs/plany/PLAN_NUM-*.md`) i **AC** (`docs/code-reviews/AC-PLAN_NUM-*.md`)
- [ ] Sprawdziłem `git diff ${FIRST_COMMIT}^..${LAST_COMMIT} --stat` — żaden plik poza „Relevant files" w planie
- [ ] Test gate z Phase 7 zielony (Unit/Integration wymagane, E2E wg rozmiaru)
- [ ] Każdy `[MUST]` ma verdict z dowodem (file:line lub test::name)
- [ ] Brak debug logs (`console.log`, `print`, `pdb.set_trace`) w diff
- [ ] Brak temporary artifacts (`*.tmp`, `*.bak`, lockfiles z testów lokalnych)
- [ ] Brak active locks / running sessions (np. `playwright-report/` w stage)
- [ ] Migracje DB: idempotentne, z down migration, name zawiera `plan-PLAN_NUM`

---

## Backend-specific notes

### `CR_BACKEND=superpowers`
Użyj agenta `code-reviewer` (Tools: All). Przekaż AC + plan + commit range. Agent zwróci raport
zgodny z powyższą strukturą — Twoja rola to walidacja i uzupełnienie kontekstu PSP (RODO/PZP).

### `CR_BACKEND=codex`
`codex exec --context plan.md --context AC.md --diff range --format severity-grouped-with-ac-mapping`.
Output do `docs/code-reviews/_raw-CR-PLAN_NUM.txt`, potem ręcznie sformatuj wg powyższego template.

### `CR_BACKEND=inline`
Sam jesteś reviewerem. Bądź krytyczny — łap bugi, edge cases, naruszenia AC. Najtrudniejsza wersja
bo brak drugiego mózgu — kompensuj checklistą powyżej + 2 minutowym refleksem „co user zrobi w ciągu
pierwszych 5 minut, czego ja nie testowałem".
