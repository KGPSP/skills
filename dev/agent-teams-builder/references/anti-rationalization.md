---
title: Tabela anty-racjonalizacji — pełna, z wymówkami domenowymi Agent Teams
load-when: "Generator/Evaluator próbuje uzasadnić pominięcie kroku, którego SKILL.md nie pokrywa"
source:
  - DOC/material_skill.md §3 (Tabela Anty-racjonalizacji)
  - DOC/since_skill.md §2 (Filar 2: Anti-Rationalization Tables)
  - DOC/agent-teams-generator-ewaluator.md §4 + §7
---

# Anti-Rationalization — pełna tabela

> LLM są mistrzami racjonalizacji. Generują logicznie brzmiący esej, dlaczego *akurat w tym zadaniu* można pominąć krok. Każda riposta = **blokada deterministyczna**, nie sugestia.

---

## 1. Ogólne wymówki (z material_skill.md §3)

| Wymówka | Riposta (blokada) |
|---|---|
| „Zmiana za mała na specyfikację" | 5 linii minimum, 0 to dług. Kontrakt obowiązuje nawet dla one-linera. |
| „Testy później" | „Później" nie istnieje. Failing test PRZED implementacją (RED → GREEN → REFACTOR). |
| „Kod działa lokalnie" | Działający kod ≠ dowód. Wklej log runtime, build clean, screenshot z Evaluatora. |
| „Refaktoryzowałem przy okazji" | Scope Discipline. Cofnij, zgłoś osobny sprint, zaktualizuj plan. |
| „Wydaje się działać" | Halucynacja statusu. Bez artefaktu w `state/evidence/` zadanie nie istnieje. |
| „Mamy monitoring" | Monitoring informuje o pożarze, nie zapobiega. Brak testu = brak zmiany. |

---

## 2. Wymówki specyficzne dla Agent Teams

### 2.1 Wymówki Generatora

| Wymówka | Riposta |
|---|---|
| „Przeczytałem rozumowanie Evaluatora w breadcrumbs i się dostosuję" | **Odrzucono. Izolacja kontekstów.** Generator widzi tylko `feedback_for_generator`, nie wewnętrzne rozumowanie. Wycofaj zmianę, której powodem jest cudza myśl, nie kontrakt. |
| „Sam sobie zrobię screenshot, Evaluator nie potrzebny" | **Odrzucono. Sędzia we własnej sprawie.** Evidence generuje WYŁĄCZNIE Evaluator. Brak alternatyw. |
| „Kryterium C-07 jest źle sformułowane, pominę" | **Odrzucono.** Kryterium kwestionuj w fazie 3 (negocjacja kontraktu). Po `accepted: true` nie ma renegocjacji. Eskalacja przez `blockers.md`. |
| „Mogę zrobić commit przed Evaluatorem dla bezpieczeństwa" | **Dozwolone**, ale commit z prefiksem `WIP:`, NIE z message implikującym ukończenie. Beyoncé Rule nadal obowiązuje. |
| „Implementacja monolityczna jest szybsza niż Composition" | **Sprawdź `passed` na rubryce.** Jeśli `craft` filar < 100%, monolit przegrywa. Decyzja architektoniczna należy do kontraktu, nie do Generatora ad hoc. |
| „Test integracyjny pokrywa unit, oszczędzę czas" | **Odrzucono. Piramida 80/15/5.** Brak unitu na publiczny export = blokada. |
| „Dodam `eslint-disable` — Evaluator nie sprawdza lintera" | **Odrzucono.** `craft` filar zawsze ma kryterium `0 warnings`. Heurystyka w fazie 6: `grep -rE 'eslint-disable\|ts-ignore\|@ts-nocheck' src/` zwraca 0. |
| „Czas mi się kończy, oddam bez ostatniego kryterium" | **Odrzucono. Wszystko-albo-nic per sprint.** 14/15 nie jest passed. Pivot lub eskalacja. |
| „W trakcie pivota wezmę kawałek starego kodu" | **Odrzucono. Pivot = czysty start.** `pivot_plan.md → what_to_keep` to **wyłącznie kontrakt i plan**, NIE implementacja. |

### 2.2 Wymówki Evaluatora

| Wymówka | Riposta |
|---|---|
| „Generator to się napracował, oceniam łagodniej" | **Odrzucono.** Praca Generatora nie wpływa na rubrykę. Każde kryterium → `passed: true|false` wg twardej weryfikacji. Empatia ≠ obniżanie progu. |
| „Kryterium C-05 jest trudne do zweryfikowania, dam passed" | **Odrzucono.** Brak evidence = automatic `passed: false`. Jeśli kryterium nie da się zweryfikować — to wada kontraktu (faza 3), nie powód do pochopnego passed. |
| „Dam feedback z rozwiązaniem, Generator szybciej naprawi" | **Odrzucono.** Feedback opisuje CO nie działa, NIE jak naprawić. Generator sam szuka. Łamanie reguły = sędzia we własnej sprawie. |
| „Zmodyfikuję rubrykę retroaktywnie" | **Odrzucono.** Kontrakt po `accepted: true` jest niezmiennikiem sprintu. Modyfikacja = wymaga renegocjacji + nowy hash + breadcrumb. |
| „4/5 iteracji minęło, dam mu jeszcze 3" | **Odrzucono.** `MAX_ITERATIONS` to twardy próg. Brak progresu → pivot. Pobłażanie pogłębia patologię. |
| „Pivot to porażka, unikajmy" | **Odrzucono.** Pivot to mechanizm wyjścia, nie porażka. Łatanie zepsutego fundamentu kosztuje 10× więcej niż reset. |
| „Nie uruchomię smoke testu, kod się skompilował" | **Odrzucono.** Build clean ≠ runtime. Smoke test PRZED Playwright jest obowiązkowy. |
| „Subiektywnie design jest OK, przepuszczam" | **Odrzucono.** Subiektywność = brak few-shot examples. Wymuś sekcję `examples/` w rubryce. Brak referencji = brak prawa do oceny design. |

### 2.3 Wymówki Plannera

| Wymówka | Riposta |
|---|---|
| „Sprint-1 jest oczywisty, pomijam specyfikację" | **Odrzucono.** Każdy sprint ma mierzalny cel biznesowy. „Oczywisty" = niezapisany = stracony w trakcie 6h sesji. |
| „Wybiorę bibliotekę, Generator później to docyzelizuje" | **Odrzucono.** Planner NIE projektuje technicznie. Wybór biblioteki to decyzja Generatora pod feedbackiem Evaluatora. |
| „Sprintów może być 50, projekt jest duży" | **Odrzucono.** >15 sprintów = mikromanagement, agenci się gubią. Rozbij na fazy projektu, każda faza = oddzielne `state/`. |
| „Niewiadome dopisze w trakcie" | **Odrzucono.** Open Questions ujawnia się PRZED kodem. Non-negotiable #1. |

---

## 3. Wymówki strukturalne (stan plików)

| Wymówka | Riposta |
|---|---|
| „Markdown wystarczy dla breadcrumbs" | **Odrzucono.** Markdown nadpisywany. JSON dla append-only data. Walidator skryptowy zatrzyma sesję. |
| „Pominę `state/blockers.md`, dam radę" | **Odrzucono.** Brak eskalacji = halucynacja autonomii. Konflikt wymagań → STOP → blockers.md. |
| „Nadpiszę `state/contracts/sprint-1.json`, kontrakt się zmienił" | **Odrzucono.** Nadpisanie kontraktu = utrata audit trail. Dopisz sekcję `amendments: [...]`. |
| „Pliki evidence zajmują dużo miejsca, kasuję stare" | **Odrzucono.** Evidence = dowód dla audytu. Kasowanie = utrata podstawy DoD. Archiwizuj zip do `state/archives/`, NIE kasuj. |
| „Nie dopiszę breadcrumbs, śpieszy się" | **Odrzucono.** Breadcrumbs = jedyny sposób recovery sesji. Brak = `session_resumed` nie zadziała. |

---

## 4. Wymówki wokół pivota

| Wymówka | Riposta |
|---|---|
| „Pivot bez archiwizacji branchu, czyścimy historię" | **Odrzucono.** `archive/sprint-N-pivot-{ts}` to obowiązek. Bez tego brak rollbacku przy regresji. |
| „Pivot 3. raz na tym samym sprincie" | **Odrzucono.** Po 2. pivocie → eskalacja human + rewizja `state/plan.md`. Pivot łańcuchowy = problem w planie, nie w kodzie. |
| „Pivot subiektywny — Evaluator nie lubi estetyki" | **Odrzucono.** Pivot wyłącznie z `passed[N] == passed[N-1] == passed[N-2]` (stagnacja). „Smak" nie jest podstawą. |
| „Wyrzucę kontrakt razem z kodem, zaczniemy świeżo" | **Odrzucono.** Kontrakt to niezmiennik sprintu. Pivot wyrzuca **implementację**, nie kontrakt. |

---

## 5. Google DNA — wymówki obejmujące Hyrum/Chesterton/Beyoncé/DAMP

> Cztery zasady z *Software Engineering at Google* (material_skill.md §5). Każda z konkretnymi wymówkami i ripostami.

| Wymówka | Riposta (Google DNA) |
|---|---|
| **Hyrum:** „Pomijam test kolejności API — to nieudokumentowane zachowanie" | **Odrzucono. Prawo Hyruma.** Każde obserwowalne zachowanie API (nawet nieudokumentowane) staje się zależnością przy dostatecznej liczbie użytkowników. Test C-XX kolejności endpointów obowiązkowy. |
| **Hyrum:** „Zmieniam sygnaturę funkcji helpera — nikt z niej nie korzysta poza modułem" | **Odrzucono.** `grep -rn 'helperName(' .` zwraca >0 → ktoś korzysta. Bez `git log -S` i analizy wpływu — zmiana zablokowana. |
| **Chesterton:** „Usuwam ten kod, wygląda na martwy" | **Odrzucono. Płot Chestertona.** Przed usunięciem przedstaw pisemny dowód zrozumienia *dlaczego* ten kod tu jest. Sprawdź `git log -p {file}`, `git blame {linia}`, issue tracker. Brak wyjaśnienia = obowiązek pozostawienia kodu nietkniętego. |
| **Chesterton:** „Wyłączam ten test, jest dziwny" | **Odrzucono.** `git log` na pliku testowym + analiza incydentu z commit message. Dziwny test często = ślad realnego buga. Wyłączenie wymaga ADR w `docs/adr/`. |
| **Beyoncé:** „Zmiana mała, pominę test" | **Odrzucono. Zasada Beyoncé** — *"If you liked it, you should have put a test on it."* Zmiana bez testu = dług technologiczny. Heurystyka walidacji: `git diff --name-only HEAD` z `src/` → odpowiadające testy w `tests/`. |
| **DAMP:** „Wyodrębniłem helper testowy z 5 testów — DRY" | **Odrzucono w testach.** DAMP > DRY — *Descriptive And Meaningful Phrases*. Test musi się czytać jak specyfikacja. Nadmiernie abstrakcyjny test = niemożliwy do zdiagnozowania przy awarii. Cofnij abstrakcję. |

---

## 6. Anty-wzorce w prompcie systemowym (jeśli sam piszesz prompty)

| Anty-wzorzec | Co źle | Zamiast |
|---|---|---|
| „Bądź ekspertem" | Esej do zignorowania | „Czytaj `state/contracts/sprint-{n}.json` i implementuj WSZYSTKIE kryteria binarne." |
| „Dbaj o jakość" | Inspiracja, nie egzekucja | „Po każdym commicie uruchom `npm test` + `npm run lint`. Exit 0 obowiązkowy." |
| „Pisz dobre testy" | Niemierzalne | „Każdy publiczny export ma test. Beyoncé Rule. Heurystyka: dla każdego pliku w `git diff --name-only` z `src/` istnieje plik testowy w `tests/` z sufiksem `.spec.*` lub `.test.*`." |
| „Zachowaj profesjonalizm" | Marketing | (nie wpisuj — nieoperacyjne) |

---

## 7. Procedura aktualizacji tabeli

Po każdej rzeczywistej sesji `/goal`:

1. Przeczytaj `state/breadcrumbs.json` i znajdź momenty, gdzie agent się rozjechał z osądem.
2. Wyodrębnij konkretną wymówkę (cytat z myśli agenta lub feedback'u).
3. Dopisz wiersz w tej tabeli z konkretną ripostą.
4. Wpisz do CHANGELOG repo.

**Anti-pattern:** dodawanie generycznych instrukcji w nadziei, że „trafią". Działają tylko punktowe poprawki na zaobserwowane porażki. Patrz `traces-reading.md`.
