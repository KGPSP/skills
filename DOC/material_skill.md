---
title: "Inżynieria Agent Skills: Od stochastycznego juniora do Senior Developera AI"
type: explanation
status: kanoniczny
version: v1
audience: inżynierowie oprogramowania pracujący z agentami AI (Claude Code, Cursor, Copilot)
tags: [agent-skills, ai-engineering, sdlc, claude-code, google-dna]
sources:
  - "Addy Osmani — Senior Staff Engineer, Google"
  - "Software Engineering at Google (O'Reilly)"
  - "Anthropic Agent Skills documentation"
updated: 2026-05-27
---

# Inżynieria Agent Skills: Od stochastycznego juniora do Senior Developera AI

> **Typ:** explanation (pryncypia procesowe) · **Status:** kanoniczny · **Aktualizacja:** 2026-05-27
> **Rola w korpusie `DOC/`:** zwarta esencja pryncypiów procesowych — cytowana jako `source:` (§1–§10) przez ~53 plików skilli. Pełen raport → [`since_skill.md`](since_skill.md).

> [!abstract] TL;DR
> Domyślny agent AI to **stochastyczny junior**: optymalizuje pod sygnał „zadanie ukończone”, pomija specyfikację, testy i weryfikację. Skuteczna praca z AI to **inżynieria procesów**, a nie prompt engineering. Rozwiązaniem jest **Agent Skills** — deterministyczna uprząż (harness) w formie plików Markdown, która wymusza dyscyplinę senioralną poprzez procedury, tabele anty-racjonalizacji i dowodową definicję ukończenia.

---

**Słowa kluczowe:** Process over Prose · Anti-Rationalization · Definition of Done · Prawo Hyruma · Płot Chestertona · Zasada Beyoncé · DAMP over DRY · Progressive Disclosure · 5 Non-negotiables · SDLC.

## Spis treści

1. Problem: dlaczego agent AI domyślnie zachowuje się jak niecierpliwy junior
2. Fundament: Proces zamiast Prozy
3. Tabela Anty-racjonalizacji: blokady na drogi-na-skróty
4. Definition of Done: dowód zamiast deklaracji
5. Google DNA: zaawansowane reguły inżynieryjne
6. Architektura operacyjna: Progressive Disclosure i Meta-Skill Router
7. Mapowanie na SDLC: komendy slash jako bramki faz
8. Pięć Zasad Niepodlegających Negocjacjom
9. Quick Start: pierwszy Skill w 3 krokach
10. Podsumowanie: programista jako architekt procesu
- Źródła

---

## 1. Problem: Dlaczego agent AI domyślnie zachowuje się jak niecierpliwy junior

W inżynierii Google mawia się, że praca Seniora to w **80% to, czego nie widać w diffie**: specyfikacje, testy, code review, dyscyplina zakresu. Agent AI w trybie domyślnym ignoruje tę „niewidoczną pracę”, ponieważ optymalizuje pod sygnał *task complete*, a nie pod stabilność systemu.

Brak rygoru prowadzi do trzech klas awarii:

1. **Latent Dependencies** — agent polega na nieudokumentowanych zachowaniach API (Prawo Hyruma); system pęka przy pierwszej aktualizacji bibliotek.
2. **Brak audytowalności** — deklaracja „Gotowe” bez logów, trace'ów i screenshotów jest niemożliwa do zweryfikowania w systemach rozproszonych.
3. **Paraliż Code Review** — PR-y na 700 linii (gdzie 30 to fix, a 670 to „przy okazji refactor”) są nie do sprawdzenia przez człowieka, co maskuje krytyczne błędy.

### Porównanie: AI vs. Senior Developer

| Kategoria | Domyślne podejście AI | Podejście Senior Developera |
|---|---|---|
| **Specyfikacja** | Generuje kod natychmiast na podstawie promptu | Definiuje kryteria akceptacji, ujawnia ukryte założenia |
| **Testowanie** | Pomija testy lub pisze pod „szczęśliwą ścieżkę” | Beyoncé Rule + DAMP over DRY w testach |
| **Zakres zmian** | Refaktor „przy okazji” sąsiednich plików | PR Sizing: atomowe zmiany ~100 linii |
| **Weryfikacja** | „Wydaje się działać” | Dowód: logi, zielone testy, screenshot |
| **Założenia** | Zgaduje intencje | Eskaluje konflikt wymagań do człowieka |

---

## 2. Fundament: Proces zamiast Prozy

Większość porażek w pracy z AI wynika z **pisania esejów** w stylu „bądź ekspertem”, „dbaj o jakość”. Modele zignorują ścianę tekstu nawołującą do profesjonalizmu — wybiorą najkrótszą drogę i wygenerują logicznie brzmiącą wymówkę.

> [!important] Zasada nadrzędna
> **AI potrzebuje runbooka, nie inspiracji.** Workflow z punktami kontrolnymi (checkpointami) jest niemożliwy do zracjonalizowania; esej o jakości — owszem.

| | Opis (Junior) | Procedura (Senior) |
|---|---|---|
| **Forma** | „Pisz dobre testy i dbaj o jakość kodu” | Workflow z numerowanymi krokami i bramkami |
| **Mechanizm** | Inspiracja do naśladowania | Egzekucja krok-po-kroku przez Code Execution Tool |
| **Weryfikacja** | Deklaratywna („napisałem kod”) | Dowodowa (log, zielony test, screenshot) |
| **Wpływ na kontekst** | Szum, „zatruwanie studni” | Precyzyjne ładowanie tylko potrzebnych narzędzi |

### Wzorcowy workflow TDD dla agenta

```
1. Napisz test jednostkowy, który MUSI zawieść (failing test).
2. Uruchom test → wklej wyjście konsoli pokazujące błąd (dowód porażki).
3. Zaimplementuj minimalny kod przechodzący test.
4. Uruchom test ponownie → wklej czysty wynik (dowód sukcesu).
5. Refaktoryzuj WYŁĄCZNIE pod warunkiem utrzymania zielonych testów.
```

---

## 3. Tabela Anty-racjonalizacji: Blokady na drogi-na-skróty

LLM są mistrzami racjonalizacji. Potrafią wygenerować logicznie brzmiący esej o tym, dlaczego *akurat w tym zadaniu* można pominąć testy. Tabela anty-racjonalizacji to **deterministyczny hamulec** — predefiniowane riposty, które agent musi uznać za nadrzędne wobec własnych „dobrych powodów”.

| Wymówka agenta | Inżynieryjna riposta (blokada) |
|---|---|
| „Zmiana jest za mała na specyfikację” | Nawet 1-liniowy fix wymaga kryteriów akceptacji. **5 linii to minimum, 0 to dług technologiczny.** |
| „Testy dopiszę później” | **„Później” nie istnieje w tym SDLC.** Najpierw failing test, potem implementacja. |
| „Kod działa lokalnie, można kończyć” | Działający kod ≠ dowód. Wklej logi runtime, build output bez warningów i runtime trace. |
| „To bezpieczna zmiana, mamy monitoring” | Monitoring informuje o pożarze, nie zapobiega mu. Brak testu = brak zmiany. |
| „Refaktoryzowałem sąsiedni plik przy okazji” | **Scope Discipline.** Cofnij zmiany spoza zakresu i zgłoś osobny task. |
| „Wydaje się działać” | Halucynacja statusu. Bez artefaktu (log/test/screenshot) zadanie nie istnieje. |

---

## 4. Definition of Done: Dowód zamiast Deklaracji

> [!warning] Verification is non-negotiable
> Status „Gotowe” bez artefaktu jest traktowany jako **błąd systemu**, a nie zakończenie zadania.

### Checklista DoD dla każdego zadania

- [ ] **Clean build** — kompilacja bez ostrzeżeń (`warnings as errors`), bez błędów lintera.
- [ ] **Beyoncé Rule** — każda nowa funkcjonalność i każdy fix ma odpowiadający test (*„If you liked it, you should have put a test on it”*).
- [ ] **Runtime evidence** — log z runtime'u, screenshot lub wynik endpointu potwierdzający działanie.
- [ ] **PR Sizing** — zmiana mieści się w ~100 liniach i jest czytelna dla człowieka.
- [ ] **Scope Discipline** — diff zawiera wyłącznie pliki ze zgłoszonego zakresu.
- [ ] **Plan Review** — implementacja ruszyła dopiero po akceptacji wyniku `/plan`.

Akceptowalne dowody (w kolejności preferencji):

1. Surowy output `Tests: X passed` z konsoli.
2. Czysty build output (bez warningów).
3. Trace runtime na ścieżce krytycznej.
4. Screenshot zachowania widocznego dla użytkownika.
5. Zatwierdzone code review od człowieka.

---

## 5. Google DNA: Zaawansowane reguły inżynieryjne

Cztery zasady z *Software Engineering at Google*, które agent musi stosować **deterministycznie**, a nie uznaniowo.

### Prawo Hyruma

> *„Przy odpowiedniej liczbie użytkowników API, nie ma znaczenia, co obiecałeś w dokumentacji: wszystkie zauważalne zachowania twojego systemu zostaną przez kogoś wykorzystane.”*

**Implementacja w skillu:** Zakaz modyfikowania istniejących sygnatur i zachowań API (nawet nieudokumentowanych) bez analizy wpływu na systemy zależne. Każda zmiana interfejsu wymaga uzasadnienia technicznego i dowodu na brak regresji.

### Płot Chestertona

> *„Nie usuwaj ogrodzenia, dopóki nie zrozumiesz i nie opiszesz dokładnie, dlaczego zostało ono postawione.”*

**Implementacja w skillu:** Zanim agent usunie pozornie zbędny kod, musi przedstawić pisemny dowód zrozumienia jego pierwotnej funkcji. Brak wyjaśnienia = obowiązek pozostawienia kodu nietkniętego.

### Zasada Beyoncé

> *„If you liked it, you should have put a test on it.”*

**Implementacja w skillu:** Zmiana bez testu jest długiem technologicznym. Piramida testów 80/15/5 (unit / integration / UI). Infrastruktura nie wyłapuje bugów — robią to wyłącznie testy.

### DAMP over DRY (w testach)

**DAMP** = *Descriptive And Meaningful Phrases*. W testach przedkładamy **czytelność** nad unikanie powtórzeń. Nadmiernie abstrakcyjne, „sprytne” testy generowane przez AI są niemożliwe do zdiagnozowania w przypadku awarii. Test musi czytać się jak specyfikacja.

---

## 6. Architektura operacyjna: Progressive Disclosure i Meta-Skill Router

Ładowanie 20 skilli na raz to **kontekstowe samobójstwo** — model wybiera zasady losowo, a okno kontekstowe degraduje się (*context window degradation*). Rozwiązaniem jest **Progressive Disclosure**.

> [!tip] Architektura
> System operuje na plikach Markdown z frontmatterem YAML (Skills). Zarządza nimi **Meta-Skill Router** (np. `using-agent-skills`), który dynamicznie wstrzykuje wyłącznie procedury niezbędne dla bieżącej fazy zadania. Pozwala to zmieścić bibliotekę 60+ skilli w wąskim oknie kontekstowym (~5K tokenów).

Anatomia pojedynczego Skilla:

```
my-skill/
├── SKILL.md          # frontmatter + procedura krok-po-kroku
├── scripts/          # deterministyczne narzędzia (Code Execution)
└── resources/        # tabele, checklisty, przykłady
```

Reguła aktywacji: *„Ten skill służy wyłącznie do [X]. Nie ładuj go podczas [Y].”*

---

## 7. Mapowanie na SDLC: Komendy slash jako bramki faz

Agent Skills mapują się 1:1 na fazy cyklu życia oprogramowania. Każda komenda to bramka, której nie można pominąć.

| Faza SDLC | Komenda | Domyślne (błędne) zachowanie AI | Wymuszone zachowanie Seniora |
|---|---|---|---|
| **Define** | `/spec` | Skok bezpośrednio do kodu | Specyfikacja + kryteria akceptacji |
| **Plan** | `/plan` | Chaos w commitach | Rozbicie na atomowe kroki recenzowalne |
| **Build** | `/build` | Kodowanie bez planu | Implementacja w oparciu o zatwierdzony plan |
| **Verify** | `/test` | „Wydaje się działać” | Zielone testy przed jakimkolwiek mergem |
| **Review** | `/review` | Ignorowanie standardów | Readability review zgodne z normami |
| **Ship** | `/ship` | Push niezweryfikowanego kodu | Wydanie po spełnieniu Exit Criteria |

---

## 8. Pięć Zasad Niepodlegających Negocjacjom

Imperatyw dla każdego agenta AI działającego w infrastrukturze:

1. **Uwidaczniaj założenia przed budowaniem.** Każde ciche założenie musi być zgłoszone. Praca przy niejasnych wymaganiach jest zabroniona.
2. **Zatrzymaj się przy konflikcie wymagań.** Zakaz zgadywania intencji — konflikt to sygnał do eskalacji.
3. **Wybieraj rozwiązania nudne i oczywiste.** *Cleverness is expensive.* Kod ma być czytelny dla najsłabszego ogniwa zespołu.
4. **Dostarczaj twardy dowód, nie deklarację.** Każdy status „done” musi być podparty logiem, testem lub screenshotem.
5. **Dotykaj tylko tego, o co cię poproszono.** Scope Discipline — jedyny gwarant mergowalnych Pull Requestów.

---

## 9. Quick Start: Twój pierwszy Skill w 3 krokach

> [!example] Minimalna wersja produkcyjna
> Zacznij od jednego skilla dla jednego, powtarzalnego zadania (np. naprawa endpointów API).

1. **Stwórz plik `SKILL.md`** z frontmatterem YAML i twardą, numerowaną procedurą (nie esejem).
2. **Wstaw Tabelę Anty-racjonalizacji** — wymień 4–6 dróg na skróty typowych dla tego zadania i podaj blokujące riposty.
3. **Wymuś dowody** — zakończ instrukcję zdaniem: *„Nie uznawaj zadania za zakończone, dopóki nie wkleisz surowego logu z sukcesem testu X.”*

### Szkielet pliku SKILL.md

```markdown
---
name: api-fix
description: Procedura naprawy regresji w endpointach REST API
trigger: gdy użytkownik raportuje 5xx z konkretnego endpointu
---

## Procedura
1. Powtórz błąd lokalnie (curl + dokładny request).
2. Napisz failing test odtwarzający regresję.
3. Uruchom test → wklej output.
4. Zaimplementuj minimalny fix.
5. Uruchom test ponownie → wklej zielony output.
6. Diff: `git diff --stat` ≤ 100 linii.

## Anti-rationalization
| Wymówka | Riposta |
|---|---|
| „Naprawiłem przy okazji walidację” | Cofnij. Scope Discipline. |
| „Test jest oczywisty, pomijam” | Failing test PRZED implementacją, bez wyjątków. |

## Definition of Done
- [ ] Failing test pokazał regresję
- [ ] Zielony test po fixie (output wklejony)
- [ ] Build clean, zero warningów
- [ ] Diff ≤ 100 linii, tylko pliki w zakresie
```

---

## 10. Podsumowanie: Programista jako Architekt Procesu

Inżynieria w dobie AI to nie walka o najciekawszy prompt, lecz **walka o rygor**. Agent Skills nie są magicznym rozwiązaniem — są **deterministyczną uprzężą**, która pozwala wykryć błędy stochastyczne.

> [!quote] Finalna myśl
> W erze AI to „niewidoczne” aspekty pracy inżyniera — **specyfikacja, weryfikacja i narzucanie rygoru** — stają się jego największą wartością. Kod jest produktem ubocznym; **Twoim głównym produktem jest proces**, który gwarantuje, że ten kod jest bezpieczny.

Jeśli dasz agentowi wolną rękę — zbuduje dług.
Jeśli dasz mu proces — zbuduje system.

---

## Źródła

1. Addy Osmani — *Beyond Vibe Coding: Agent Skills as Engineering Scaffolding* (addyosmani.com)
2. Winters, Manshreck, Wright — *Software Engineering at Google* (O'Reilly, 2020)
3. Anthropic — *Claude Code: Agent Skills documentation*
