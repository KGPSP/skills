---
name: code-review-protocol
type: reference
parent: audited-feature-workflow
sources:
  - dev/feature-planner v2 baseline
  - DOC/material_skill.md §1 (PR Sizing ~100/300/1000)
  - DOC/since_skill.md §4 (Five-Axis Review redirect)
description: Phase 8 code review — AC-driven findings, severity matrix. v3 dokleja PR Sizing gate (≤300 linii lub --justified) i przekierowanie do five-axis-review.md.
---

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

---

## PR Sizing Gate

> [!quote] PR Sizing (`material_skill.md` §1, `since_skill.md` §4)
> „PR-y na 700 linii (gdzie 30 to fix, a 670 to »przy okazji refactor«) są nie do sprawdzenia przez człowieka, co maskuje krytyczne błędy." — `>1000 linii` to **rażący defekt metodologiczny**, agent musi przerwać i zastosować stacking lub vertical slicing.

PR Sizing Gate to twardy checkpoint w Phase 8 — uruchamiany **przed** five-axis review. Cel: niemergeowalne PR-y nie marnują uwagi reviewera.

### Progi tolerancji

| Próg (linii) | Zakres | Akcja | Override |
|---|---|---|---|
| ≤100 | Optymalne | ✅ proceed | n/a |
| 101–300 | Tolerowane | ⚠️ wymaga sekcji **„Diff size rationale"** w PR description | jawne uzasadnienie |
| 301–1000 | Wysokie ryzyko | ⚠️ split sugerowany, review **wstrzymany** do akceptacji lead'a | flag `--justified` + odpowiedź lead'a w PR komentarzu |
| >1000 | Hard stop | ⛔ automatyczny split (stacking lub vertical slicing) | **brak override'u** — wymagany rebuild planu |

### Komenda gate'u

```bash
bash {baseDir}/dev/audited-feature-workflow/scripts/check-pr-size.sh <commit-range>
# np.: bash .../check-pr-size.sh origin/main..HEAD
```

Output zawiera:
- liczbę linii dodanych / usuniętych (po wykluczeniu lockfiles, snapshotów, generated/);
- liczbę dotkniętych plików;
- werdykt: `OPTIMAL` / `TOLERATED` / `HIGH_RISK` / `HARD_STOP`;
- listę plików z największym diffem (top 5).

### Override — `--justified`

Dopuszczalny **wyłącznie** gdy:
1. Phase 4 plan **z góry zapowiadał** large diff (np. wymuszony migration script, generated code z OpenAPI).
2. PR description zawiera sekcję `## Diff size rationale` z:
   - powodem nieuniknionego rozmiaru,
   - linkiem do sekcji planu (Phase 4) z zapowiedzią,
   - listą plików, które **nie podlegają** detailed review (np. snapshot DB, regenerated client).

Bez tej sekcji flag `--justified` jest ignorowany — gate pozostaje zamknięty.

### Hard stop — `>1000 linii`

Brak override'u. Procedura:
1. Wróć do Phase 4.
2. Rozbij plan na 2+ niezależnych PR-ów (stacking) lub na vertical slices (każdy E2E sam w sobie).
3. Aktualizuj `docs/plany/PLAN_NUM-*.md` z nową strukturą.
4. Re-aprobata team-lead.

### Anti-rationalization

| Wymówka agenta | Riposta |
|---|---|
| „To tylko refactor, większość linii to czysta zamiana" | Refactor + feature w jednym PR = niemożliwe review. Split obowiązkowy. |
| „Większość diffa to wygenerowane pliki" | Wygenerowane pliki muszą być w `.gitattributes` z `linguist-generated=true` lub w gitignore. Inaczej liczą się do PR size. |
| „Lead już widział wstępny szkic" | Akceptacja szkicu ≠ override sizing gate. Wymagana jawna zgoda w komentarzu PR po komendzie `check-pr-size.sh`. |

---

## Five-Axis Review (przekierowanie)

> [!quote] Five-Axis (`since_skill.md` §4)
> Phase 8 review NIE jest tylko AC-driven — uzupełnia **pięcioosiowy audyt** (Correctness / Readability / Architecture / Security / Performance) zdefiniowany w `references/five-axis-review.md`.

Sam AC verification jest niewystarczający. AC pokrywa „zrobiłem to, co miałem zrobić", a five-axis audit łapie problemy strukturalne, których AC nie zna (czytelność, długi techniczny, security smells).

### Cykl Phase 8 — kolejność operacji

1. **PR Sizing gate** (jak wyżej) — jeśli zamknięty, koniec; nie marnuj uwagi na większe analizy.
2. **Five-axis audit** — uruchom protokół z `references/five-axis-review.md`:
   - Correctness — edge cases, null safety, race conditions, zgodność z AC-F.
   - Readability & Simplicity — kod czyta się jak proza? Brak premature abstractions? *Cleverness is expensive.*
   - Architecture — duplikacje, dependency cycles, naruszenia granic modułów.
   - Security — OWASP Top 10, secret scanning, taint analysis dla user input.
   - Performance — N+1, niekontrolowane pętle, brakujące async I/O.
3. **AC verification (1:1 mapping)** — przejdź matrix z `ac-protocol.md`, dla każdego AC zaznacz PASS / PARTIAL / FAIL z dowodem.
4. **Chesterton check dla deletion** — jeśli diff zawiera `git rm` lub usunięcie funkcji, wymagana sekcja `Why this existed` w PR description (patrz `analysis-protocol.md`).
5. **Severity matrix** — klasyfikuj uwagi:

   | Severity | Definicja | Wpływ na gate |
   |---|---|---|
   | **Critical** | bug, security hole, naruszenie MUST AC, broken contract | ⛔ blokuje merge |
   | **Major** | naruszenie SHOULD AC, czytelność critical-path, brakujący test | ⛔ blokuje ADR (Phase 9) |
   | **Optional** | drobny refactor, lepszy nazewnictwo | nie blokuje |
   | **Nit** | spacja, comment style | nie blokuje |
   | **FYI** | informacyjne, follow-up | nie blokuje |

6. **Decyzja end-of-phase**:
   - 0 Critical + 0 Major → PROCEED do Phase 9 (ADR).
   - ≥1 Critical → STOP, powrót do Phase 6 (fix), powtórka cyklu.
   - ≥1 Major → fix w bieżącym PR lub jawna delegacja do follow-up PR (wpis w `out-of-scope.md`).

### Hard rule

Phase 8 nie wolno skracać do „AC OK → merge". Jeśli nie odbył się pełny cykl (sizing → five-axis → AC → Chesterton → severity), workflow uznaje Phase 8 za niezakończoną.
