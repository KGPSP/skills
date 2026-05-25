---
name: non-negotiables
type: reference
parent: feature-spec-planner
source: DOC/material_skill.md §8
description: Pięć zasad nienegocjowalnych dla feature-spec-planner — wersja planistyczna. Każda zasada egzekwowana w konkretnych fazach analizy/planu/ADR. Wersja wykonawcza (raw artifacts, build clean) należy do skilla wykonawczego.
---

# 5 Non-negotiables (wersja planistyczna)

> [!important] Zasada nadrzędna
> Te 5 punktów to **imperatyw** dla każdego uruchomienia feature-spec-planner. Naruszenie któregokolwiek = STOP, eskalacja do użytkownika, nie continue. feature-spec-planner egzekwuje je na poziomie **planu i dokumentacji** — nie na poziomie kodu (tego nie produkuje).

---

## #1 — Uwidaczniaj założenia przed planowaniem

> [!quote] material_skill.md §8
> Każde ciche założenie musi być zgłoszone. Praca przy niejasnych wymaganiach jest zabroniona.

**Jak egzekwowane:**

- Phase 1 (analysis): sekcja `Open questions` w Analysis Report — niepusta = STOP.
- Phase 4 (plan): sekcja `Assumptions` obowiązkowa, jawnie wymienia wszystkie założenia.
- Phase 6 (gate): brak `Assumptions` w planie = bramka blokuje.

**Anti-pattern:** „Zakładam że <X> bo to standardowe" — żadne założenie nie jest „standardowe" bez explicit deklaracji w planie.

---

## #2 — Zatrzymaj się przy konflikcie wymagań

> [!quote] material_skill.md §8
> Zakaz zgadywania intencji. Konflikt to sygnał do przerwania pracy i eskalacji do człowieka.

**Jak egzekwowane:**

- Phase 1: konflikt między PRIMARY TEMPLATE a wymaganiem usera → STOP.
- Phase 2 (hipotezy): jeśli żadna hipoteza nie pokrywa wszystkich wymagań bez konfliktu → STOP, zapytaj.
- Phase 3 (recommendation): konflikt między AC a ograniczeniem repo → eskaluj, nie wybieraj „rozsądnej" interpretacji.

**Anti-pattern:** „Wybiorę interpretację najbardziej sensowną" — improwizacja w planie = bug w produkcji u wykonawcy.

---

## #3 — Planuj rozwiązania nudne i oczywiste

> [!quote] material_skill.md §8 — Cleverness is expensive
> Kod ma być czytelny dla najsłabszego ogniwa w zespole. Plan też.

**Jak egzekwowane:**

- Phase 2 (hipotezy): hipoteza **Idiomatic** preferowana domyślnie nad **Ambitious**.
- Phase 3 (recommendation): wybór **Ambitious** wymaga uzasadnienia + Hyrum Risk + (zwykle) ADR.
- ADR (Phase 5): jeśli plan świadomie odchodzi od konwencji repo — uzasadnij koszt.

**Anti-pattern:** Generic types z 4 parametrami, abstrakcyjne fabryki, „przygotowane na przyszłość" rozwiązania bez konkretnego use case — zaplanowane = wciąż dług.

---

## #4 — Każdy AC ma być weryfikowalny dowodem (specyfikacja)

> [!quote] material_skill.md §8 — Verification is non-negotiable
> Każdy status „done" musi być podparty logiem, wynikiem testu lub zrzutem ekranu.

**Jak egzekwowane w feature-spec-planner:**

- Phase 4: matryca AC — każdy AC ma `Test ID` + `Komenda` + `Plik testu` (Beyoncé 1:1, [ac-protocol.md](ac-protocol.md)).
- Phase 4: DoD — każdy AC ma komendę dowodu + próg sukcesu + lokalizację artefaktu ([dod-evidence-protocol.md](dod-evidence-protocol.md)).
- Phase 6 (gate): pusty `Test ID`/`Komenda` = specyfikacja niekompletna = bramka blokuje.

> [!note] Różnica wobec wykonawcy
> feature-spec-planner **specyfikuje**, czym AC zostanie udowodniony. **Zebranie** surowego dowodu (raw log, screenshot, trace) i werdykt PASS/FAIL należą do skilla wykonawczego. „Plan deklaruje dowód" ≠ „dowód istnieje".

**Anti-pattern:** AC bez przypisanego testu („sprawdzi się ręcznie") — albo planowany test, albo spisana procedura manualna z artefaktem.

---

## #5 — Planuj tylko to, o co cię poproszono

> [!quote] material_skill.md §8 — Scope Discipline
> Jedyny gwarant mergowalnych Pull Requestów. Zaczyna się od planu.

**Jak egzekwowane:**

- Phase 4: sekcja `Out of scope` obowiązkowa i niepusta.
- Phase 1.5: zależności poza zakresem → `Out of scope` lub jawne pytanie, nie ciche dodanie do planu.
- Każdy „przy okazji refaktor" wykryty w analizie → wpis w `out-of-scope.md`, nie do listy zadań.

**Anti-pattern:** „Przy okazji zaplanuję też sprzątanie sąsiedniego modułu" — to nie ten plan.

---

## Anti-Laziness w bramce (feature-spec-planner)

> [!quote] since_skill.md §6
> Najwyższa waga jakości. **Nie optymalizuj pod szybkość oddania planu.**

- Bramka akceptacji (Phase 6) wymaga **explicit** zgody usera, nie auto-proceed.
- Brak skrótu „analiza oczywista, pomijam Phase 1".
- Anti-rationalization quick-table ([anti-rationalization.md](anti-rationalization.md)) przechodzona **explicite** przed zapisaniem planu i przed bramką.

---

## Egzekwowanie globalne

| Faza | Non-negotiables aktywne |
|---|---|
| **Phase 0** | #2 (detekcja konfliktu scope) |
| **Phase 1** | #2 (konflikt PRIMARY TEMPLATE), #5 (scope analizy) |
| **Phase 2-3** | #1 (assumptions), #2 (konflikt hipotez), #3 (boring preferred) |
| **Phase 4** | #1, #4 (AC + DoD spec), #5 (out of scope) |
| **Phase 5 (ADR)** | #3 (uzasadnienie odejścia od konwencji) |
| **Phase 6 (gate)** | #1, #4, Anti-Laziness (explicit approval) |

---

## Wzorzec eskalacji (gdy non-negotiable narusza)

```
1. STOP — nie kontynuuj fazy.
2. Identyfikuj naruszone #X.
3. Cytuj zasadę w output fazy.
4. Eskaluj do użytkownika z propozycją 2-3 rozwiązań.
5. Czekaj na decyzję — żadna improwizacja.
```

Brak akceptacji → rollback fazy, restart od ostatniego zatwierdzonego checkpointu.
