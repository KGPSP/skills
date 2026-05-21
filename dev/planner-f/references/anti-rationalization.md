---
name: anti-rationalization
type: reference
parent: planner-f
source: DOC/material_skill.md §3
description: Tabela wymówek agenta AI — wersja planistyczna (planner-f). Tylko wpisy dotyczące analizy, AC, scope, Hyrum/Chesterton i dokumentacji. Wpisy wykonawcze (TDD order, build clean, raw logs, PR sizing przy commitach, Five-Axis) należą do skilla wykonawczego.
---

# Anti-Rationalization Tables (planner-f)

> [!quote] material_skill.md §3
> LLM są mistrzami racjonalizacji. Potrafią wygenerować logicznie brzmiący esej o tym, dlaczego *akurat w tym zadaniu* można pominąć analizę albo nie zapisać AC. Tabela anty-racjonalizacji to **deterministyczny hamulec** — predefiniowane riposty nadrzędne wobec własnych „dobrych powodów".

> [!important] Zakres
> Ta wersja dotyczy **planowania i dokumentacji**. Wymówki wykonawcze („testy dopiszę później", „build clean wystarcza", „PR 800 linii ale spójny") egzekwuje skill wykonawczy — w planner-f nie ma kodu do których by się odnosiły.

## Sekcja 1 — Tabela master (planistyczna)

| # | Wymówka agenta | Riposta (blokada) | Egzekwuj w fazie |
|---|---|---|---|
| 1 | „Zmiana jest mała, pomijam Phase 1 analizę" | Phase 1 nienegocjowalna. Analog + architecture walk + 5 linii kontekstu = minimum, 0 = STOP. | Phase 0→1 |
| 2 | „AC jest oczywiste, opiszę słownie" | Każdy AC-F/N/C wymaga wiersza w matrycy z `Test ID` + `Komenda`. Brak = blokada Phase 6 gate. | Phase 4, 6 |
| 3 | „Wystarczy happy path w AC" | Beyoncé Rule. Każdy edge case / failure / non-regression → osobny AC z własnym (planowanym) testem. | Phase 4 |
| 4 | „Test napiszę w fazie wykonania, teraz pole puste" | Matryca AC powstaje w Phase 4. Pusty `Test ID` = STOP. Jeśli nie wiesz, jakim testem zweryfikujesz AC — AC jest źle zdefiniowany. | Phase 4, 6 |
| 5 | „API change jest bezpieczne, nie ma userów" | Hyrum's Law. Każda zmiana sygnatury → `api-impact.md` z listą callerów. „Brak userów" sprawdź `git grep`. | Phase 1.5, 3 |
| 6 | „Zaplanuję usunięcie martwego kodu" | Chesterton's Fence. Bez sekcji `Why this existed:` (git blame) — kod ZOSTAJE w planie. | Phase 1 |
| 7 | „Refactor sąsiada zmieści się w tym planie" | Scope Discipline. Rozszerzenie → wpis w `out-of-scope.md`, nie do listy zadań planu. | Phase 1.5, 4 |
| 8 | „Plan gotowy, pomijam ADR — to formalność" | Decyzja z realnym tradeoffem (Phase 2/3) wymaga ADR. Implementacja prosto z analoga = jawne „N/A". | Phase 5, 6 |
| 9 | „Hipoteza Ambitious najlepsza, jedna wystarczy" | Wymagane ≥3 hipotezy (Minimal/Idiomatic/Ambitious). Idiomatic preferowana; Ambitious wymaga uzasadnienia. | Phase 2, 3 |
| 10 | „Założenie oczywiste, nie zapisuję" | Każde ciche założenie → sekcja `Assumptions`. Brak = bramka blokuje (Non-negotiable #1). | Phase 1, 4 |
| 11 | „Anti-rationalization quick-table to formalność" | **Ta tabela to też wymówka.** Przejdź ją explicite, nie deklaratywnie. | każda faza |

---

## Sekcja 2 — Per-faza redirects

Zamiast czytać całą tabelę za każdym razem, sprawdzaj konkretne wpisy:

| Faza | Wpisy do sprawdzenia |
|---|---|
| **Phase 0 → 1** | #1 (skip analizy) |
| **Phase 1** | #6 (Chesterton), #10 (assumptions) |
| **Phase 1.5** | #5 (API risk), #7 (scope) |
| **Phase 2-3** | #9 (≥3 hipotezy, boring preferred) |
| **Phase 4 (plan writing)** | #2, #3, #4 (AC matrix), #7 (scope), #10 (assumptions) |
| **Phase 5 (ADR)** | #8 (ADR pominięty?) |
| **Phase 6 (approval gate)** | #2, #4, #8 — kompletność pakietu + #11 (formalność) |

---

## Sekcja 3 — Wzorzec dialogu (gdy agent próbuje pójść na skróty)

> [!example] Wzorzec
> **Agent:** „Ten endpoint jest prosty, AC opiszę jednym zdaniem zamiast tabeli."
>
> **Anti-rationalization response:** „Wpis #2. Każdy AC wymaga wiersza w matrycy z `Test ID` + `Komenda`. Bez tego wykonawca nie wie, czym potwierdzić AC. Wypełnij matrycę. Bez wyjątku."

Format internalizowany:

```
1. Identyfikuj numer wpisu (#X).
2. Cytuj ripostę dosłownie.
3. Wykonaj wymagane działanie (bez modyfikacji).
4. Loguj w ADR: "Anti-rationalization #X applied at Phase Y."
```

---

## Sekcja 4 — Anti-pattern: parafraza wymówki

LLM czasem parafrazuje wymówkę sprytniej. Wzorce do wyłapania:

| Parafraza | Standardowa wymówka, którą maskuje |
|---|---|
| „API jest internal, scope ograniczony" | #5 |
| „Ten kod i tak nikt nie używa" | #6 |
| „Plan jest oczywisty, analog zbędny" | #1 |
| „AC-N jest jakościowy, nie da się go zmierzyć" | #2 lub #4 |
| „Dodam to do planu, bo i tak dotykam modułu" | #7 |

Reguła: **gdy wątpisz, traktuj parafrazę jak standardową wymówkę** i egzekwuj ripostę.

---

## Sekcja 5 — Integracja z fazami

- **Phase 0**: Załaduj ten plik do kontekstu (lazy, tylko gdy planner-f trigger match).
- **Phase 4**: Plan MUSI zawierać inline link do tej tabeli. Quick-check przed zapisaniem planu.
- **Phase 5**: ADR zawiera sekcję `Anti-rationalization decisions` — które wymówki agent odrzucił.
- **Phase 6**: Pełny pass przed bramką akceptacji (wpisy #2, #4, #8, #11 szczególnie).
