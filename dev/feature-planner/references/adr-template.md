# references/adr-template.md

Protokół dla Phase 9 — **ADR (Architecture Decision Record)**. Cel: utrwalić decyzję tak,
żeby ktoś wracający do tego kodu za 6 miesięcy zrozumiał *dlaczego* tak zostało zrobione,
a nie tylko *co*.

> **Zasada nadrzędna:** ADR to **decyzja**, nie raport implementacyjny. Krótko (≤ 1 strona),
> z jasnym kontekstem i alternatywami. Nie kopiuj kodu — od tego jest commit history.

---

## Kiedy pisać ADR

ADR ma sens, gdy plan wprowadził jeden z poniższych:

- Wybór technologii / biblioteki / wzorca, który będzie kosztowny do zmiany (DB schema, auth,
  state management, format wymiany danych z systemami zewnętrznymi PSP).
- Decyzję sprzeczną z analogiem z Analysis Report (świadome odejście od konwencji repo).
- Decyzję regulacyjną / proceduralną (RODO, WCAG, PZP, KRI ABW) z konsekwencjami operacyjnymi.
- Wybór jednej z hipotez, gdy kompromisy były niebanalne (Phase 2/3 miały realny tradeoff).

**Nie pisz ADR dla:**
- Bug fix bez decyzji architektonicznej.
- Refaktor wewnętrzny (rename, extract function) bez impact na innych.
- Implementacja prosto z analogu bez tradeoffów (Analysis Report 1.3 to PRIMARY TEMPLATE).

---

## Lokalizacja i naming

```
docs/adr/ADR-PLAN_NUM-[kebab-name].md
```

Przykład: `docs/adr/ADR-042-shelter-filter-by-powiat.md` (PLAN_NUM = 042 z Phase 0.1).

---

## Template

```markdown
# ADR-PLAN_NUM — [Nazwa decyzji]

## Status
Accepted | Proposed | Superseded by [ADR-NNN]

## Kontekst
[2–4 zdania: jaki problem, jakie ograniczenia, jakie siły doprowadziły do decyzji.
Wskaż AC-MUST z Phase 8.1 lub *Definition of Done* z planu, jeśli to one wymusiły wybór.]

## Decyzja
[Wybrane podejście w jednym akapicie, w trybie oznajmującym.
„Filtrujemy schronyu po powiat_code zamiast nazwie tekstowej, używając enum z TERYT."]

## Konsekwencje
**Pozytywne:**
- [konkret 1 — np. „validacja na poziomie typu, brak runtime SQL injection risk"]
- [konkret 2]

**Negatywne / koszty:**
- [konkret 1 — np. „dodanie nowego powiatu wymaga migracji enum, nie tylko seed"]
- [konkret 2]

**Operacyjne:**
- [wpływ na deploy, monitoring, oncall — jeśli jest]

## Alternatywy rozważane
- **[Hipoteza H1 z Phase 2]** — [dlaczego nie wybrana, 1 zdanie]
- **[Hipoteza H2 z Phase 2]** — [dlaczego nie wybrana, 1 zdanie]
- **[Status quo / nie robić nic]** — [dlaczego nie wystarczyło, 1 zdanie]

## Weryfikacja
- Test: `tests/integration/shelters.test.ts::"filters by powiat code"` — dowód że decyzja działa
- AC verdict z `docs/code-reviews/CR-PLAN_NUM-*.md`: AC-F-2 PASS, AC-N-1 PARTIAL
- Plan: `docs/plany/PLAN_NUM-*.md`

## Follow-ups
- [opcjonalne — co jeszcze warto zrobić, ale nie blokuje tej decyzji]
- [np. „Dodać index na shelters(powiat_code, dostepnosc) — backlog ticket #123"]
```

---

## Sekcja `## Parallelization` — TYLKO dla planów wykonanych w 6-Teams

Gdy Phase 6-Teams (parallel implementation) była użyta, **dodaj** sekcję poniżej:

```markdown
## Parallelization (6-Teams)

**Liczba teammates:** 3 (auto-sized z Phase 6T.1)

**Podział ownership:**
| Teammate       | Parallel-groups        | Owned files              | Tasks    |
|----------------|------------------------|--------------------------|----------|
| backend-dev    | backend, db-migrations | server/**, prisma/**     | 1, 3, 5  |
| frontend-dev   | frontend, ui           | app/**, components/**    | 2, 4     |
| tester-prep    | tests-scaffolding      | tests/**                 | 6        |

**Co działało:**
- [konkret — np. „brak konfliktów plików, każdy teammate kończył przed barrierą"]

**Co wymagało koordynacji od leada:**
- [konkret — np. „API DTO shape — lead zdecydował i broadcastował obu po Zadaniu 1"]

**Lessons learned dla przyszłych planów:**
- [konkret — np. „migracje DB faktycznie warto zostawić 1 teammate; próba splitu w innym planie skończyła się konfliktem schema"]
```

Ta sekcja nie jest opcjonalna dla 6-Teams — daje przyszłym planom dane do auto-sizing'u
i identyfikuje wzorce koordynacji, które się sprawdziły.

---

## Sekcja `## Ralph-iterations` — TYLKO dla planów wykonanych w 6-Ralph

Gdy Phase 6-Ralph (autonomous self-correcting loop) była użyta, **dodaj** sekcję poniżej.
Źródłem danych jest state file `.claude/plan-${PLAN_NUM}.state` + `.claude/ralph-loop.local.md`:

```markdown
## Ralph-iterations (6-Ralph)

**Max iterations (5.7.4 auto-compute):** 22 (tasks=4 × 2 + scopes=7 × 2)
**Faktyczna liczba iteracji:** 9
**Completion-promise:** `FEATURE_DONE` (wystawiony w iteracji 9)
**Completion timestamp:** 2026-05-08T14:32:11Z (z `.claude/plan-${PLAN_NUM}.state`)

**Gdzie loop "stutterował"** (iteracje gdzie nie było progresu = ten sam task w toku):
- Iteracje 4-6: task 3 (migracja Prisma) — pierwsza próba zawiodła z "schema drift",
  loop sam wycofał i poprawił `prisma/schema.prisma` przed re-runem `migrate dev`.

**Co loop zrobił dobrze (samo-korekta):**
- [konkret — np. „lint fail w iteracji 7 → fix → re-run zielony bez interwencji operatora"]
- [konkret — np. „test E2E timeout w 8 → loop dodał `await page.waitFor` i przeszedł"]

**Gdzie operator interweniował:**
- [konkret — np. „iteracja 5 wisiała na migracji > 5 min — operator `/cancel-ralph`,
  potem manualny rollback i restart loop'a od iteracji 4"] **lub** „brak interwencji"

**Lessons learned dla przyszłych planów:**
- [konkret — np. „dla planów dotykających Prisma migrations max-iterations=15 było ciasne;
  podbij default do 25 dla L-size z DB schema changes"]
```

Ta sekcja nie jest opcjonalna dla 6-Ralph — daje przyszłym planom dane do auto-compute'u
RALPH_MAX_ITER (Phase 5.7.4) oraz identyfikuje wzorce gdzie loop sobie radzi vs gdzie
trzeba człowieka.

---

## Anty-wzorce

❌ **ADR jako changelog**: „Dodano endpoint GET /api/shelters" — to nie decyzja, to commit message.

❌ **ADR bez alternatyw**: „Zdecydowaliśmy użyć Prisma" bez wskazania, czemu nie Drizzle / raw SQL.
Jeśli alternatywy nie były rozważane, ADR nie ma sensu — to nie była decyzja.

❌ **ADR z kodem**: long code blocks z implementacją. Code → commit. ADR → *dlaczego*.

❌ **ADR „na zaś"**: bez konkretnego planu, „bo może kiedyś będzie się przydać". ADR rodzi się
z planu, nie odwrotnie.

❌ **ADR superseded bez linku**: stary ADR oznaczony `Superseded` musi mieć link do nowego —
inaczej tracisz historię decyzji.

---

## Długość

Cel: **≤ 1 strona A4** w Marked / Obsidian Reading view (~250–400 słów).

Jeśli ADR rośnie do 2 stron — najprawdopodobniej:
- Mieszasz decyzję z implementacją (przenieś implementację do planu).
- Decyzja jest złożona z kilku — rozbij na ADR-NNN-a, ADR-NNN-b z linkami.
- Wlewasz kontekst, który należy do Analysis Report — link, nie kopiuj.

ADR jest dokumentem **decyzji**. Gdy ktoś go czyta za rok — w 2 minuty rozumie,
*co* zostało wybrane, *dlaczego*, i *co byłoby kosztem* gdybyśmy chcieli odwrócić.
