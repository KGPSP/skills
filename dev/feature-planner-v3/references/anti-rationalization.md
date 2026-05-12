---
name: anti-rationalization
type: reference
parent: feature-planner-v3
source: DOC/material_skill.md §3
description: Pełna tabela wymówek agenta AI z gotowymi ripostami. Egzekwowana w Phase 6 (przed commit), Phase 7 (przed deklaracją done), Phase 8 (final pass), oraz w każdej iteracji ralph-loop.
---

# Anti-Rationalization Tables

> [!quote] material_skill.md §3
> LLM są mistrzami racjonalizacji. Potrafią wygenerować logicznie brzmiący esej o tym, dlaczego *akurat w tym zadaniu* można pominąć testy. Tabela anty-racjonalizacji to **deterministyczny hamulec** — predefiniowane riposty, które agent musi uznać za nadrzędne wobec własnych „dobrych powodów".

## Sekcja 1 — Tabela master

| # | Wymówka agenta | Riposta (blokada) | Egzekwuj w fazie |
|---|---|---|---|
| 1 | „Zmiana jest mała, pomijam Phase 1 analizę" | Phase 1 nienegocjowalna. 5 linii kontekstu architektonicznego = minimum, 0 = STOP. | Phase 0→1 |
| 2 | „Testy dopiszę w Phase 7" | TDD: failing test PRZED implementacją w Phase 6. Bez RED → brak GREEN. | Phase 6 |
| 3 | „AC jest oczywiste, pomijam zapis" | Każdy AC-F/N/C wymaga zapisu w planie. Brak AC = blokada Phase 5 gate. | Phase 4, 5 |
| 4 | „Kod się buduje, można mergować" | Build clean ≠ DoD. Wymagane: log testu, runtime trace, screenshot UI. | Phase 7 |
| 5 | „Refaktoryzowałem sąsiedni plik przy okazji" | Scope Discipline. Cofnij zmiany spoza zakresu, zgłoś jako osobny task w `out-of-scope.md`. | Phase 6, 8 |
| 6 | „PR ma 800 linii ale jest spójny" | Próg >300 linii wymaga uzasadnienia w PR description. >1000 = automatyczny split. | Phase 6, 8 |
| 7 | „API change jest bezpieczne, nie ma userów" | Hyrum's Law. Każda zmiana sygnatury wymaga `api-impact.md` z listą callerów. | Phase 1.5, 3 |
| 8 | „Usunąłem martwy kod, oszczędność LoC" | Chesterton's Fence. Bez sekcji `Why this existed:` w PR description — przywróć. | Phase 1, 8 |
| 9 | „Test pokrywa happy path, wystarczy" | Beyoncé Rule. Każdy edge case z AC-N wymaga osobnego testu. | Phase 4, 7 |
| 10 | „DRY-uję testy w helper `createValidUser()`" | DAMP over DRY. Test musi być czytelny jak spec, bez magicznych helperów ukrywających stan. | Phase 7 |
| 11 | „Trace runtime to overkill dla prostego endpointu" | Każdy AC-F wymaga dowodu wykonania w środowisku uruchomieniowym. Bez trace = brak DoD. | Phase 7 |
| 12 | „Plan-Validate-Execute spowalnia fragile op" | Fragile zone = obowiązkowy reżim PVE. Brak shortcut'u, nawet jeśli operacja „prosta". | Phase 5, 6 |
| 13 | „Five-Axis Review zbyteczne dla małego PR" | Każdy PR przechodzi przez 5 osi. Severity FYI/Nit nie blokują, ale audyt obowiązkowy. | Phase 8 |
| 14 | „Build warning to false positive, pomijam" | Warnings as errors. Każdy warning to potencjalny incydent — eskaluj lub fix. | Phase 7 |
| 15 | „Anti-rationalization quick-table to formalność" | **Ta tabela to też wymówka.** Przejdź ją explicite, nie deklaratywnie. | każda faza |

---

## Sekcja 2 — Per-faza redirects

Zamiast czytać całą tabelę za każdym razem, w danej fazie sprawdzaj konkretne wpisy:

| Faza | Wpisy do sprawdzenia |
|---|---|
| **Phase 0 → 1** | #1 (skip analizy) |
| **Phase 1.5** | #7 (API risk) |
| **Phase 4 (plan writing)** | #3 (AC zapis), #9 (edge cases) |
| **Phase 5 (approval gate)** | #3, #9, #11 (DoD evidence format) |
| **Phase 6 (per commit)** | #2 (TDD order), #5 (scope), #6 (PR size), #14 (warnings) |
| **Phase 6 (fragile)** | #12 (PVE shortcut) |
| **Phase 7 (test gate)** | #4 (build vs DoD), #9 (happy path), #10 (DAMP), #11 (trace), #14 (warnings) |
| **Phase 8 (final review)** | #5, #6, #7, #8 (Chesterton), #13 (5-axis), #15 (formalność) |
| **Phase 9 (ADR)** | wszystkie — sekcja `Anti-rationalization decisions` w ADR |

---

## Sekcja 3 — Wymówki spotykane w ralph-loop (autonomous mode)

Ralph-loop iteruje bez user interruption. Bez disciplины model akumuluje skróty z iteracji na iterację. Te wymówki pojawiają się w autonomous mode częściej:

| # | Wymówka ralph-loop | Riposta |
|---|---|---|
| R1 | „Już to widziałem w poprzedniej iteracji, pomijam check" | Każda iteracja przechodzi przez quick-table na nowo. Cache anty-pattern. |
| R2 | „Test flaky, restart powtórzy" | Flaky test to bug. Stop, debug, fix — nie restart. |
| R3 | „Build wolniejszy, użyję `--no-warnings`" | Zakaz wyłączania warningów dla speedu. Iteracja staje się bezwartościowa. |
| R4 | „Diff rośnie, ale w kolejnej iteracji posprzątam" | „Później" nie istnieje (material_skill.md §3). PR sizing per iteracja. |
| R5 | „Tabela anty-racjonalizacji to tylko dla pierwszej iteracji" | Tabela egzekwowana KAŻDĄ iterację. Brak wyjątku „już znam". |

---

## Sekcja 4 — Wzorzec dialogu (gdy agent próbuje pójść na skróty)

> [!example] Wzorzec
> **Agent:** „Test integracyjny dla tego endpointu byłby przesadą — unit test wystarczy."
>
> **Anti-rationalization response:** „Wpis #9 (Beyoncé Rule). Każdy AC-F wymaga testu na poziomie deklarowanym w planie. Plan deklaruje AC-F-03 jako integration test. Pisz test integracyjny. Bez wyjątku."

Format internalizowany przez agenta:

```
1. Identyfikuj numer wpisu (#X).
2. Cytuj ripostę dosłownie.
3. Wykonaj wymagane działanie (bez modyfikacji).
4. Loguj w PR description: "Anti-rationalization #X applied at Phase Y."
```

---

## Sekcja 5 — Anti-pattern: parafraza wymówki

Czasem LLM zamiast cytować standardową wymówkę, parafrazuje ją sprytniej. Wzorce do wyłapania:

| Parafraza | Standardowa wymówka, którą maskuje |
|---|---|
| „Test jest niedeterministyczny w izolacji" | #2 lub #9 |
| „API jest internal, scope ograniczony" | #7 |
| „Refactor zmieścił się w diff, brak overhead" | #5 lub #6 |
| „Linter false positive, znany problem" | #14 |
| „W tej iteracji TDD nieoptymalne czasowo" | R4 lub #2 |

Reguła: **gdy wątpisz, traktuj parafrazę jak standardową wymówkę** i egzekwuj ripostę.

---

## Sekcja 6 — Integracja z fazami

- **Phase 0**: Załaduj ten plik do kontekstu (lazy, tylko gdy v3 trigger match).
- **Phase 4**: Plan MUSI zawierać inline link do tej tabeli.
- **Phase 6**: Quick-check przed każdym `git commit`. Lista wpisów per faza (sekcja 2).
- **Phase 7**: Final pass na #4, #9, #10, #11, #14.
- **Phase 8**: Pełny audyt wszystkich wpisów. Sekcja `Anti-rationalization decisions` w PR description.
- **Phase 9**: ADR zawiera listę zastosowanych ripost (które wymówki agent odrzucił).
- **Ralph-loop**: Sekcja 3 obowiązkowo każdą iterację.
