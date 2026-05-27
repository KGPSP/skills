---
title: "Podwaliny: autonomiczne agenty długodystansowe w Claude Code (Agent Teams)"
type: methodology
status: kanoniczny
version: v1
audience: autorzy skilli orkiestrujących zespoły sub-agentów
tags: [agent-teams, generator-evaluator, claude-code, orchestration, pivot]
sources:
  - "Prelekcja inżynierów Anthropic — budowanie agentów długodystansowych"
updated: 2026-05-22
---

# Podwaliny: Autonomiczne agenty długodystansowe w Claude Code (Agent Teams)

> **Typ:** methodology (wzorzec orkiestracji) · **Status:** kanoniczny · **Aktualizacja:** 2026-05-22
> **Rola w korpusie `DOC/`:** baza wzorca Generator–Ewaluator — cytowana jako `source:` przez skille orkiestrujące (m.in. `agent-teams-builder`).

## Streszczenie

Opisuje wzorzec **Generator–Ewaluator** (inspirowany GAN) do prowadzenia złożonych zadań programistycznych przez wiele godzin: dwa niezależne agenty w osobnych kontekstach, presja rywalizacyjna, rubryka ewaluatora, mechanizm pivota oraz system plików jako trwały stan. Stanowi metodyczną podstawę realizacji w trybie Agent Teams w Claude Code.

**Słowa kluczowe:** Generator–Ewaluator · presja adwersarzowa · rubryka ewaluatora · pivot · breadcrumbs · git worktrees · Agent Teams · długodystansowa autonomia.

## Spis treści

1. Idea: wzorzec Generator–Ewaluator
2. Role w zespole
3. Pętla działania (workflow)
4. Rubryka ewaluatora
5. Pamięć: system plików jako trwały stan
6. Realizacja w Claude Code z Agent Teams
7. Mechanizm pivota w Agent Teams (krok po kroku)
8. Optymalizacja i utrzymanie
9. Checklist startowy (Agent Teams w Claude Code)
10. Kontekst kosztowy

---

> Notatki na podstawie prelekcji inżynierów Anthropic o budowaniu agentów AI zdolnych do samodzielnej pracy nad złożonymi projektami programistycznymi przez wiele godzin. Wersja przeniesiona ze ścieżki "Agent SDK" na ścieżkę **Agent Teams** dostępną bezpośrednio w Claude Code.

---

## 1. Idea: wzorzec Generator–Ewaluator

Klasyczny pojedynczy agent w pętli ma dwa problemy: jest "sędzią we własnej sprawie" (zbyt łagodnie ocenia własną pracę) i wpada w pułapkę bez końca łatania tego samego wadliwego kodu. Wzorzec generator–ewaluator (inspirowany GAN) rozwiązuje to przez **presję rywalizacyjną** między dwoma niezależnymi agentami pracującymi w **osobnych oknach kontekstowych**.

**Co to daje:**

- **Obiektywna, surowa ocena** — łatwiej zapromptować niezależnego agenta na bezlitosnego krytyka niż zmusić twórcę kodu do samokrytyki. Wykorzystujemy lukę między zdolnością modelu do krytykowania a generowania.
- **Możliwość pivota** — jeśli generator utknie, system potrafi wyrzucić całą dotychczasową pracę i zacząć od zera, zamiast łatać zepsuty fundament.
- **Precyzyjne wymagania przez negocjacje** — przed napisaniem pierwszej linijki kodu agenci uzgadniają granularny "kontrakt" (np. 27 konkretnych kryteriów dla jednej funkcji), na podstawie którego później oceniana jest praca.
- **Aktywne testowanie na żywo** — ewaluator nie czyta diffów, tylko otwiera aplikację w przeglądarce, klika, robi zrzuty ekranu i wyłapuje błędy, które przeszłyby przez CI (nakładający się tekst, zła kolejność wywołań API, niedziałające klawisze).
- **Czystość kontekstów** — generator nie widzi wewnętrznego rozumowania ewaluatora, dostaje wyłącznie suchą krytykę i sam szuka rozwiązania.
- **Ocena "dobrego smaku" i designu** — możliwa, jeśli ewaluator dostanie szczegółową rubrykę i przykłady kalibracyjne (patrz sekcja 4).

**Efekt jakościowy:** w testach pojedynczy agent poproszony o "kreator gier retro" zbudował ładny, ale niefunkcjonalny interfejs (nie działały klawisze). Ten sam model w schemacie z ewaluatorem zbudował pełnoprawny program z paletami kolorów, sprawnym trybem gry, systemem debugowania i asystentami AI.

---

## 2. Role w zespole

Każda rola = osobny agent z własnym oknem kontekstowym.

### Rdzeń: 3 agenty (minimalna sprawdzona konfiguracja)

**Planista (Planner / Initializer)**
- **Zadanie:** zamienia krótki prompt użytkownika (np. "zbuduj kreator gier retro") w wysokopoziomową specyfikację podzieloną na sprinty / user stories. Inicjuje trwałe artefakty (repozytorium, `feature_list.json`).
- **Ograniczenia:** celowo unika szczegółów technicznych i granularnej architektury — błąd na tym etapie wywołałby kaskadę błędów przez kolejne godziny pracy.
- **Wykorzystanie:** jego specyfikacja jest regularnie **wstrzykiwana** do sesji generatora i ewaluatora jako punkt odniesienia, żeby agenci nie zgubili głównego celu.

**Generator (Builder)**
- **Zadanie:** proponuje rozwiązania, pisze kod, modyfikuje go na podstawie feedbacku ewaluatora.
- **Wejście:** kontrakt wynegocjowany z ewaluatorem + suchy feedback z iteracji.
- **Co dostaje:** **wyłącznie krytykę** ("tu jest błąd"), bez podpowiedzi jak konkretnie napisać kod — sam musi znaleźć i wdrożyć rozwiązanie.

**Ewaluator (Critic / QA)**
- **Zadanie:** weryfikuje działanie kodu zachowując się jak prawdziwy użytkownik — otwiera aplikację, nawiguje, klika, robi zrzuty ekranu.
- **Prompt systemowy:** rygorystyczny, ze szczegółową rubryką (patrz sekcja 4).
- **Narzędzia:** Playwright MCP / Chrome DevTools MCP do aplikacji web; Computer Use do aplikacji desktopowych.
- **Co ocenia:** kontrakt wynegocjowany z generatorem (nie wysokopoziomowy plan Planisty).

### Rozbudowa: zaawansowane potoki (do 7+ agentów)

Przy bardziej złożonych projektach zespół skaluje się wg **żelaznej reguły**: każdy agent generujący cokolwiek musi mieć dedykowanego ewaluatora.

Typowe specjalizacje sub-agentów:

| Sub-agent | Rola |
|---|---|
| **Front-end Builder** | Wyłącznie warstwa UI. |
| **Back-end Builder** | Wyłącznie logika serwerowa. |
| **Integrator (wiring-up)** | Spaja wyniki etapów (baza + API + UI), przygotowuje do wdrożenia. |
| **Generator danych syntetycznych** | Buduje zestawy testowe dla aplikacji w fazie startowej. |
| **Dedykowani QA** | Po jednym ewaluatorze na każdego z powyższych — presja rywalizacyjna na każdym etapie, nie tylko końcowym. |

Pełna konfiguracja w cytowanym projekcie: **7 agentów** (Planista + 3 specjalistów + 3 ewaluatorów).

**Potok kaskadowy:** generator danych → QA danych → integrator → finalny QA. Każdy etap pod presją własnego krytyka.

---

## 3. Pętla działania (workflow)

### Krok 1 — Negocjacja kontraktu

Przed napisaniem jakiegokolwiek kodu Generator i Ewaluator uzgadniają definicję "ukończenia". Komunikacja przez wymianę plików na dysku (Markdown).

1. **Propozycja Generatora:** "Zbuduję funkcję X, a ty zweryfikuj ją testując Y".
2. **Odrzucenie/modyfikacja Ewaluatora:** zakres zbyt szeroki, testy zbyt słabe, pominięte przypadki brzegowe.
3. **Iteracyjna wymiana** przez pliki, aż obaj agenci dojdą do porozumienia. Specyfikację Planisty wstrzykuje się regularnie, żeby agenci nie zgubili głównego celu.
4. **Granularność** — w przykładowym projekcie kontrakt rozbito na 27 konkretnych kryteriów dla jednej funkcji. Rozmyte kryteria → rozmyta krytyka → generator ignoruje.
5. **Kontrakt utrwala się** jako `contracts/sprint-{n}.json` (lub Markdown) — od tego momentu ewaluator ocenia **wyłącznie wg kontraktu**, ignorując wysokopoziomowy plan Planisty.

### Krok 2 — Uruchomienie i ocena

- Generator pisze kod zgodnie z kontraktem.
- Ewaluator ocenia wyłącznie wg wynegocjowanego kontraktu i rubryk.
- Wyłapuje błędy układu, logiki, zachowania (złe przyciski, nakładający się tekst, zerwana kolejność API).

### Krok 3 — Poprawki lub pivot

- Krytyka idzie do generatora **bez wskazywania rozwiązania**.
- **Mechanizm pivota:** jeśli po kilku iteracjach generator nie potrafi przejść rubryki, Ewaluator wysyła komunikat "podejście nie działa, usuń wszystko, zacznijmy od nowa". Nowsze modele (4.6+) są zaskakująco chętne do akceptacji takiej krytyki i resetu całej pracy nad daną funkcją. Patrz sekcja 7 — szczegóły wdrożenia.

---

## 4. Rubryka ewaluatora

Sekret skuteczności Ewaluatora siedzi w jakości jego rubryki, nie w samym modelu.

### Cztery filary oceny

Design • Oryginalność • Rzemiosło (craft) • Funkcjonalność.

**Wagi dostosowuj do modelu.** Np. Opus 4.6 dobrze radzi sobie z funkcjonalnością, więc rubryka dla niego ma kłaść większy nacisk na **oryginalność i design**. Możesz tworzyć osobne rubryki dla warstw (API design, code quality), które ładujesz progresywnie.

### Cztery zasady budowy

1. **Ekstremalna granularność** — w testowym projekcie pojedyncza funkcja miała 27 punktów kontraktu. Rozmyte kryteria są ignorowane.
2. **Kodyfikacja "dobrego smaku"** — estetyka da się ocenić przez AI, **pod warunkiem** że masz sprecyzowaną wizję i opiszesz ją sztywnymi zasadami tekstowymi.
3. **Kalibracja przykładami (few-shot)** — wklej do rubryki "to jest dobry design" vs "to jest AI slop". Bez tego model produkuje sztampę.
4. **Twarde progi binarne, nie skale 1–10** — modele osiadają na "7/10" i przepuszczają niestabilny kod. Stawiaj progi typu "zero błędów TypeScript", "zero stubów w finalnym module".

### Konkretne przykłady kryteriów

**Estetyka i oryginalność:**
- Zakaz "AI slop" (nadużywanie fioletowych gradientów, sztampowy układ).
- Few-shot examples — referencyjne obrazy dobrego designu vs słabego.

**Architektura i jakość kodu:**
- Osobne kryteria projektowania API.
- Osobne kryteria czystości kodu.

**Funkcjonalność (granularna, sprawdzalna):**
- **Kolejność ścieżek FastAPI** — przechodzi CI, łamie produkcję; ewaluator weryfikuje porządek endpointów.
- **Fizyczne testy klawiatury** — wciśnięcie spacji / Delete / strzałek faktycznie wywołuje akcję (np. ruch postaci).
- **Wizualne błędy layoutu** — nakładający się tekst (wykrywane przez Playwright/Chrome).
- **Błędy logiki boole'owskiej** i ukryte przypadki brzegowe, których generator próbował uniknąć.

Praca z rubryką to **hill climbing** — ewaluator wywiera ciągłą presję, generator iteruje, aż osiągnie próg.

---

## 5. Pamięć: system plików jako trwały stan

Zamiast polegać na oknie kontekstowym (które ulega **context rot** w długich sesjach), agenci współdzielą stan przez zwykły system plików.

### JSON do statusu i list zadań

Modele używające Markdownu często **nadpisują cały plik** niszcząc poprzednie wpisy. Format JSON jest ustrukturyzowany — model częściej **dopisuje** do struktury zamiast zastępować. Dlatego `feature_list.json` (status 200 funkcji, lista wypróbowanych poprawek) trzymaj w JSON, nie MD.

### Markdown do kontraktów i negocjacji

Czytelny format na specyfikacje testów, kryteria ukończenia, dialog generator–ewaluator.

### Breadcrumbs (okruszki chleba)

Pliki JSON ze znacznikami czasu, w których agent zapisuje: jakiego ewaluatora użyto, jaki błąd znaleziono, jaką poprawkę wdrożono, czy zadziałała. Chronologiczny log dla kolejnych agentów i ludzi przejmujących projekt.

### Promptowanie pod stan

Wpleć w pętlę uprzęży drobne instrukcje: *"dopisuj wnioski/błędy/poprawki do JSON jako kolejne wpisy, nie zastępuj istniejących"*.

### Git worktrees dla pracy równoległej

Gdy zespół agentów buduje wiele funkcji jednocześnie, **`git worktree`** izoluje sesje i zapobiega konfliktom w systemie plików (jednoczesna praca nad różnymi funkcjami bez wzajemnego nadpisywania).

### Git jako część uprzęży

Uprząż automatycznie tworzy repozytorium, a po pozytywnym przejściu rubryki przez funkcję wykonuje `git commit`.

---

## 6. Realizacja w Claude Code z Agent Teams

Funkcja **Agent Teams** w Claude Code to nowy, oficjalny sposób na odtworzenie wzorca generator–ewaluator **bez pisania własnej uprzęży w Agent SDK**. Inżynierowie Anthropic potwierdzili podczas Q&A, że Agent Teams to "doskonały framework" do tego celu i traktują podział generator/ewaluator jako podzbiór filozofii Agent Teams.

### Co rozwiązuje Agent Teams

- **Izolacja wątków** — główny agent (np. Generator) powołuje wyspecjalizowanego sub-agenta (Ewaluatora) z własnym, rygorystycznym promptem systemowym i własnym oknem kontekstowym. Alternatywnie obie role są osobnymi sub-agentami.
- **Komunikacja peer-to-peer** — sub-agenci wymieniają się informacjami bezpośrednio między sobą, raportując do nadrzędnego interfejsu tylko wtedy, gdy to potrzebne. Okna kontekstowe pozostają czyste.
- **Brak konieczności pisania orkiestratora** — pętla decyzyjna "kto pyta, kogo, kiedy" jest obsługiwana przez framework.

### Mapowanie ról na Agent Teams

| Rola wzorca | Realizacja w Agent Teams |
|---|---|
| Planista | Główny agent lub sub-agent uruchamiany raz na początku; jego output (specyfikacja sprintów) trafia na dysk i jest cyklicznie wstrzykiwany. |
| Generator | Sub-agent z dostępem do edytora, terminala, git. Otrzymuje kontrakt + feedback. |
| Ewaluator | Sub-agent z bardzo surowym promptem systemowym, dostępem do Playwright/Chrome MCP, **bez dostępu do edytora kodu** — może tylko czytać kod i testować aplikację. |
| Sub-specjaliści (FE/BE/Integrator) + ich QA | Dodatkowi sub-agenci powoływani dynamicznie z parami generator-krytyk. |

### Pozostałe komponenty potrzebne do Agent Teams

- **Playwright MCP / Chrome DevTools MCP** — żeby ewaluator mógł otwierać aplikację, klikać, robić zrzuty. Dla natywnych aplikacji desktopowych: **Computer Use**.
- **Skills** — do **wplatania rubryk oceny** w przepływ bez zaśmiecania głównego okna kontekstowego (progresywne ujawnianie: na starcie ładuje się tylko opis umiejętności, ciało dopiero w momencie użycia).
- **System plików + Git + worktrees** — trwała pamięć i kontrola wersji (patrz sekcja 5).
- **Skrypty inicjalizacyjne (init / smoke tests)** — uruchamiają zbudowany kod lokalnie i przeprowadzają wstępne testy, zanim ewaluator zacznie korzystać z Playwright.

### Ograniczenia Agent Teams w Claude Code

**Rozwiązuje:** rozdzielenie ról, czyste konteksty, orkiestracja, negocjacja.

**Nie rozwiązuje:**
- **Środowisko uruchomieniowe** — Claude Code działa lokalnie w terminalu użytkownika. Wielogodzinna sesja jest podatna na uśpienie maszyny, awarię terminala, błędy środowiska. Agent SDK rozwiązuje to przez sandbox chmurowy — Agent Teams w Claude Code nie.
- **Wniosek praktyczny:** Agent Teams to **idealny "poligon doświadczalny"** do projektowania i kalibracji ról generator/ewaluator lokalnie. Dopiero gdy zachowania są dopracowane i potrzebujesz pracy 6–12 h non-stop, sensowne jest przeniesienie tej samej architektury na Agent SDK w chmurze.

---

## 7. Mechanizm pivota w Agent Teams (krok po kroku)

Pivot = autonomiczna decyzja Ewaluatora o wyrzuceniu całej pracy nad funkcją i starcie od zera.

1. **Wyodrębnione role z prawem do komunikacji peer-to-peer** — Generator i Ewaluator jako osobni sub-agenci. Negocjują bezpośrednio, raportują wyżej dopiero po zakończeniu zadania. Separacja okien jest niezbędna dla obiektywnej oceny.
2. **Surowy prompt + uprawnienie do resetu** — Ewaluator dostaje rygorystyczny prompt z rubryką **plus jasną instrukcję**, że nie musi godzić się na nieustanne łatanie. Gdy generator utknie i nie robi postępów na rubryce ("nie wspina się"), Ewaluator ma wymusić reset.
3. **Pivot w praktyce** — Ewaluator wysyła do Generatora komunikat: *"podejście, które przyjąłeś, ewidentnie nie działa, usuń wszystko i zacznijmy od nowa"*. Nowsze modele (4.6+) są zaskakująco chętne do akceptacji takiej krytyki i odrzucenia pracy z wielu iteracji.
4. **Opcjonalny hook człowieka** — jeśli wolisz nie oddawać całej kontroli, podpnij **Claude Code hook**, który przy żądaniu pivota zatrzymuje proces i prosi człowieka o decyzję, zanim maszyna faktycznie skasuje pracę.

---

## 8. Optymalizacja i utrzymanie

### Jeden ciągły kontekst (dla nowych modeli)
Modele z dużym oknem kontekstowym (Opus 4.6+ z milionem tokenów) eliminują potrzebę sztucznego dzielenia pracy na małe sprinty i ciągłego resetowania okna (technika "Ralph loop"). Polega się na jednej ciągłej sesji z **kompakcją po stronie serwera**. Efekt: prostsza uprząż, **~50% niższe koszty** operacyjne, brak "niepokoju końca kontekstu".

### Czytanie śladów (traces) — sekretny sos
Kalibracji uprzęży **nie da się zautomatyzować**. Klucz to żmudne, ręczne czytanie surowych logów konwersacji agentów linijka po linijce. Tylko tak dostrzeżesz, w którym momencie osąd modelu rozminął się z ludzkim (np. ewaluator za wcześnie zaakceptował brzydki projekt) i odpowiednio doprecyzujesz prompt systemowy lub rubrykę. Inżynierowie Anthropic nazywają to "wyrabianiem empatii do modelu" — wchodzeniem w jego buty, żeby zrozumieć tok rozumowania.

### Filozofia: pełna autonomia zamiast "człowieka w pętli"
Zamiast modelu Scrum, gdzie inżynier przegląda wyniki co kilka godzin i nakierowuje agenta, Anthropic obrał drogę maksymalnej automatyzacji ("AGI-pilled"). Gdy system się zapętli, **nie ratuje się go ręcznie** — analizuje się porażkę i poprawia bazowy prompt uprzęży. System docelowo sam zarządza pomyłkami.

---

## 9. Checklist startowy (Agent Teams w Claude Code)

Minimalny zestaw do uruchomienia własnej uprzęży generator–ewaluator:

- [ ] Skonfigurowane Agent Teams z trzema sub-agentami: Planner, Generator, Evaluator.
- [ ] Osobny, surowy prompt systemowy dla Ewaluatora + rubryka 4-filarowa (design, oryginalność, rzemiosło, funkcjonalność).
- [ ] Skill z pakietem rubryk podpinany do sesji Ewaluatora (progresywne ujawnianie).
- [ ] Few-shot examples w rubryce (referencyjny dobry design vs AI slop).
- [ ] Twarde progi binarne zamiast skal 1–10.
- [ ] Playwright MCP lub Chrome DevTools MCP podłączony **tylko** do Ewaluatora.
- [ ] Generator **bez** dostępu do Playwright/Chrome (żeby nie testował własnego kodu).
- [ ] Schemat plików stanu: `plan.md` (Planner), `contract.md` lub `contracts/sprint-{n}.json` (negocjacje), `feature_list.json` (status), `breadcrumbs.json` (log iteracji).
- [ ] Instrukcja w promptach: "dopisuj do JSON, nie nadpisuj".
- [ ] Mechanizm pivota: Ewaluator ma uprawnienie do resetu po N nieudanych iteracjach.
- [ ] Opcjonalny hook człowieka przy pivocie (jeśli chcesz bramkę).
- [ ] Git inicjalizowany automatycznie + auto-commit po pozytywnej weryfikacji.
- [ ] `git worktree` jeśli wiele funkcji buduje się równolegle.
- [ ] Smoke test (init script) uruchamiający aplikację lokalnie przed wejściem Ewaluatora.
- [ ] Plan na **czytanie traces** — bez tego kalibracja stoi.

---

## 10. Kontekst kosztowy

W cytowanym eksperymencie Anthropic w pełni autonomiczna uprząż budująca przez **6 godzin** zaawansowany kreator gier retro (RetroForge) wygenerowała koszt **~200 USD** w trybie API. Rozkład budżetu rozłożył się następująco: faza planowania ~0,5 USD w 5 minut, główna pętla generator–ewaluator ~71 USD przez ~2 h, poprawki w mniejszych blokach.

To punkt odniesienia dla wyceny własnych eksperymentów — w Claude Code z subskrypcją (Max 200 USD/mies.) limit i sposób rozliczenia są inne; kalkulacja per-sesja nie przekłada się 1:1.
