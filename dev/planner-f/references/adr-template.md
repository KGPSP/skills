---
name: adr-template
type: reference
parent: planner-f
sources:
  - dev/feature-planner v2 baseline (kopia bez zmian)
description: Phase 5 (planner-f) ADR template — kontekst, decyzja, alternatywy. SKILL.md Phase 5 wymusza dodatkowe sekcje (Anti-rationalization decisions, Hyrum/Chesterton decisions). Wzór dziedziczony z feature-planner-v3 (tam Phase 9).
---

# references/adr-template.md

Protokół dla Phase 5 (planner-f) — **ADR (Architecture Decision Record)**. Cel: utrwalić decyzję tak,
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
Wskaż AC-MUST z matrycy AC (Phase 4) lub *Definition of Done* z planu, jeśli to one wymusiły wybór.]

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

## Weryfikacja (planowana)
- Test (planowany): `tests/integration/shelters.test.ts::"filters by powiat code"` — czym decyzja zostanie potwierdzona przez wykonawcę
- AC kluczowe: AC-F-2 [MUST], AC-N-1 [SHOULD] (z planu — dowód zbiera skill wykonawczy)
- Plan: `plans/PLAN_NUM-*.md`

## Follow-ups
- [opcjonalne — co jeszcze warto zrobić, ale nie blokuje tej decyzji]
- [np. „Dodać index na shelters(powiat_code, dostepnosc) — backlog ticket #123"]
```

> [!note] planner-f — brak sekcji wykonawczych
> Sekcje `## Parallelization` (6-Teams) i `## Ralph-iterations` (6-Ralph) z feature-planner-v3 nie należą do planner-f — dotyczą trybu wykonania. ADR planner-f kończy się na decyzji + planowanej weryfikacji.

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
