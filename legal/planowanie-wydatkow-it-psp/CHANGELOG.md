# Changelog — planowanie-wydatkow-it-psp

Wszystkie istotne zmiany w tym skillu są dokumentowane w tym pliku.

Format wzorowany na [Keep a Changelog](https://keepachangelog.com/pl/1.1.0/).

## [v1.1.0] — 2026-05-25 — **MIGRACJA NA KLASYFIKACJĘ 2027+**

### Changed (BREAKING — pełna migracja klasyfikacji UFP)

- **Klasyfikacja UFP — pełna migracja na stan 2027+** wg rozporządzenia MFiG z 20.04.2026 (Dz.U. 2026 poz. 582) i ustawy z 27.02.2026 (Dz.U. 2026 poz. 426).
- **Paragrafy 3-cyfrowe** (struktura 3+1: 3 cyfry przedmiot + 4. cyfra źródło/przeznaczenie) zamiast 4-cyfrowych legacy (4xxx/6xxx). Migracja zgodnie z analizą BIŁ KG PSP (`Analiza_klasyfikacji_IT_KG_PSP_2027_BIL.docx`).
- **Próg 10 000 zł ZLIKWIDOWANY** dla wydatków majątkowych. O kwalifikacji decyduje **polityka rachunkowości jednostki**, nie kwota. Pułapka 4 w `references/klasyfikacja-budzetowa.md` całkowicie przebudowana.
- **Załącznik nr 4** (większa szczegółowość bezpieczeństwa wewnętrznego PSP) — dodano pozycje 631003, 634003/4, 670001, 687011, 702001/2, 704001, 712001/2, 778005/8/9.
- **5 grup wydatków BP** (art. 124 ufp po zmianie) zamiast 7 — grupa 3 (bieżące, paragrafy 600–699/770–799) i grupa 4 (majątkowe, paragrafy 700–769) dla IT.
- Pełny rewrite `references/klasyfikacja-budzetowa.md` (208 → ~250 linii): nowe matryce paragrafów (§5/§6), załącznik nr 4 (§7), 9 pułapek klasyfikacyjnych (§8), klucz przejścia stara→nowa (§10), cheatsheet BIŁ (§12).
- Aktualizacja `references/katalog-kosztow.md`: kolumna `§` we wszystkich 15 sekcjach A–O zmigrowana na paragrafy 2027+ (np. hosting 4300 → 682, ŚT 6060 → 702/701/704/711/712, wytworzenie 6050 → 720, materiały 4210 → 778, telekom 4350/4360 → 681/631003, ekspertyzy 4390 → 677, szkolenia 4700 → 638, zlecenia 4170 → 670).
- Aktualizacja `references/przeliczenia-walut-vat.md`: przykłady stacji roboczych z trzema scenariuszami (§ 701/702/778 zależnie od polityki rachunkowości), rezerwy w § 682/810.
- Aktualizacja `references/uzasadnienie-8pkt.md`: przykłady CEOZO (§ 682 utrzymanie, § 720 budowa), punkt 7 (okres używania) rozszerzony z § 6050/6060 na paragrafy 700–769.
- Aktualizacja `references/anti-rationalization.md`: wymówki #5/6/7/8 zmigrowane na 2027+, **nowa wymówka #21** „Sprzęt CEZOL/CEOZO → § 704 (specjalistyczny) bez uzasadnienia operacyjnego" (BIŁ ostrzega: serwer administracyjny w 704001 bez uzasadnienia = błąd kontrolny). Tabela 6 (spirit vs letter) przebudowana — 5 sytuacji z nową klasyfikacją.
- Aktualizacja `references/polioc-ramy.md`: adnotacja o stosowaniu nowej klasyfikacji do POLiOC 2027–2031, § 4000 nadal placeholder w XLSX (do zastąpienia 3-cyfrowym).
- Aktualizacja `SKILL.md`: F4 (Classify) — nowa skrócona matryca paragrafów 2027+ (16 wierszy: 682/681/631/677/634/778/770/771/638/670/687 bieżące + 701/702/704/711/712/720 majątkowe), Anti-Rationalization quick-table — wymówki #5/6/7/8/9 zaktualizowane, DoD checklist — 6 kolumn klasyfikacji (część/dział/rozdział/§ 3-cyfrowy/B/M/grupa BP), nowa pozycja DoD dla § 704 (uzasadnienie operacyjne).
- Aktualizacja `templates/raport-skeleton.md` + `templates/tabela-xlsx-uklad.md`: przykłady z paragrafami 2027+ (682, 702, 720), kolumna „§" w tabeli III.B opisana jako 3-cyfrowa, nowa kolumna „Grupa BP" (3/4).

### Added

- **`scripts/check-cost-plan.sh` (sprawdzenie 9 — nowe)** — egzekwowanie uzasadnienia operacyjnego dla pozycji w § 704 (specjalistyczny sprzęt bezpieczeństwa publicznego). Wymagane frazy w raport.md: „zadanie operacyjne" / „sprzęt specjalistyczny" / „dyspozytorski" / „łączność krytyczna" / „system ratowniczy" / „operacyjne PSP". Realizuje decyzję z code review: „walidator wymaga uzasadnienia per pozycja".
- **`scripts/check-cost-plan.sh` (sprawdzenie 1 — rozszerzone)** — detekcja paragrafów 4-cyfrowych legacy (4xxx/6xxx) zamiast tylko § 4000. Regex `§[[:space:]]*[46][0-9]{3}\b` + awk per kolumna tabeli. Każdy paragraf 4-cyfrowy = błąd legacy, plan musi używać 3-cyfrowego 2027+.
- **`scripts/check-cost-plan.sh` (sprawdzenie 5 — rozszerzone)** — plan utrzymania ≥ 5 lat dla pozycji w paragrafach majątkowych 2027+ (700–729: 701/702/703/704/711/712/720) zamiast tylko § 6050/6060.
- Aktualizacja wszystkich 3 fixtures na klasyfikację 2027+:
  - `good-plan.md` (tryb A, CEOZO) → exit 0, 8 ✔
  - `good-plan-tryb-c.md` (tryb C, Service Desk) → exit 0, 6 ✔
  - `bad-plan.md` (tryb A) → exit 1, 12 błędów (4 nowe vs v1.0.1: legacy 4-cyfrowy, brak uzasadnienia operacyjnego § 704, plus zachowane stare błędy)
- Adnotacja w `references/polioc-ramy.md` o reformie klasyfikacji oraz w `SKILL.md` o materiałach BIŁ KG PSP (`now_skille/materialy_polioc/FINANSOWANIE/`).

### Why

Rozporządzenie MFiG z 20.04.2026 (Dz.U. 2026 poz. 582) **stosuje się po raz pierwszy do planowania ustawy budżetowej na 2027 r. i lata kolejne**. POLiOC 2027–2031 obejmuje cały okres nowej klasyfikacji — wszystkie wnioski składane w skillu muszą używać paragrafów 3-cyfrowych. Skill v1.0.1 używał starej klasyfikacji (4xxx/6xxx z art. 16d CIT, próg 10 000 zł) — był nieaktualny dla okresu planowania, do którego jest przeznaczony.

### Decisions (z dialogu z user)

- **Stara klasyfikacja usunięta całkowicie** (decyzja: „Usuń całkowicie" — Q1 dialogu) — skill obsługuje wyłącznie 2027+. Klucz przejścia 4xxx/6xxx → 3-cyfrowy zachowany jako pomoc referencyjna w `klasyfikacja-budzetowa.md` §10 dla interpretacji danych historycznych, ale matryca skilla = wyłącznie 2027+.
- **Walidator egzekwuje uzasadnienie operacyjne dla § 704** (decyzja: „Decyzja per pozycja — walidator wymaga uzasadnienia 704" — Q2 dialogu) — sprawdzenie 9 w `check-cost-plan.sh`.

### Materiał źródłowy

`now_skille/materialy_polioc/FINANSOWANIE/` (gitignored, local-only):
- `Analiza_klasyfikacji_IT_KG_PSP_2027_BIL.docx` — analiza dziedzinowa BIŁ KG PSP (stan 21.05.2026, wersja 1.0): mapowanie kategorii IT na paragrafy 2027+, schematy decyzyjne dla usług developerskich/subskrypcji/sprzętu 702 vs 704, 9 reguł szybkich decyzyjnych.
- `Material_edukacyjny_Finanse_publiczne_2026_BIL_KG_PSP.docx` — materiał edukacyjny BIŁ KG PSP (stan 21.05.2026, wersja 1.0): kompletne kompendium reformy ustawowej + rozporządzeniowej, 5 grup wydatków BP, klucze przejścia, checklista wdrożeniowa, mini-test.
- `ezd_359297-bf-i-rozporzadzenie-klasyfikacja-budzetowa/`: pismo BF-I.0754.12.2026 z 13.05.2026 (Zastępca KG PSP nadbryg. Paweł Frysztak) + uwagi BIŁ KG PSP do klasyfikacji 2027 + PDF rozporządzenia.

## [v1.0.1] — 2026-05-25

### Fixed (z code review)

- **Walidator `scripts/check-cost-plan.sh` (sprawdzenie 8 — dodane)** — egzekwowanie sumy alokacji `G..L = F` w tabeli XLSX (deklarowane w SKILL.md F6 jako „twarda walidacja XLSX", ale wcześniej nie zaimplementowane). Parser awk: 12 kolumn A..L, pomija nagłówek i separator, sumuje `KG PSP + Akademia + CS Czstch + SA Krk + SA Pzn + SP Bdg` i porównuje z kwotą brutto. `tests/fixtures/bad-plan.md` BŁĄD 7 (suma 1 000 000 ≠ F 1 225 000) teraz **wykrywany**.
- **Walidator `scripts/check-cost-plan.sh` (sprawdzenie 4 — bug naprawiony)** — heurystyka detekcji kwot > 100 000 zł brutto **nigdy nie działała w v1.0.0**: `tr -d ' '` nie usuwało markdownowych `**` wokół etykiety „**Kwota brutto PLN:**", więc regex `KwotabruttoPLN:[0-9]{6,}` nigdy nie matchował (wszystkie fixtures pokazywały 0/0). Naprawiono na `tr -d ' *'`. Po naprawie: GOOD plan A wykrywa 2 pozycje > 100k z ✔, BAD plan A wykrywa 1 pozycję z ✘ (brak odniesienia do MSWiA), GOOD plan C wykrywa 1 pozycję z ✔.
- **`SKILL.md:237`** — odwołanie do `templates/tabela-xlsx-uklad.md` wskazywało na nieistniejący plik. Utworzono `templates/tabela-xlsx-uklad.md` (układ A–L, mapa skrótów jednostek PSP, konwencje formatu, przykłady kompletnego wypełnienia).
- **`SKILL.md:247` + `templates/raport-skeleton.md:140`** — usunięto absolutne ścieżki `/Users/sq13pl/...` przy wywołaniu walidatora (anty-wzorzec wg DOC `since_skill.md` §6: ścieżki muszą być relatywne, bo po instalacji marketplace skill kopiuje się do `~/.claude/plugins/...`). Zastąpiono `sh scripts/check-cost-plan.sh ...` z komentarzem o uruchamianiu z katalogu skilla.
- **`SKILL.md` frontmatter `description`** — skondensowano z 1149 znaków (jedno megazdanie duplikujące 11 trigger phrases) do 789 znaków (skupione na CO + KIEDY + bramki walidatora). Trigger phrases pozostają jedynie w `trigger:` (zgodnie z DOC §2 szablonem).
- **`references/anti-rationalization.md` frontmatter** — naprawiono niespójność „16 wymówek" w `description` → 20 wymówek (zgodne z faktyczną liczbą wierszy i wzmiankami w README/CHANGELOG/SKILL.md).

### Added (testy + dokumentacja)

- **`tests/fixtures/good-plan-tryb-c.md`** — fixture trybu C (środki własne KG PSP poza POLiOC, 754/75409). Pokrywa gałąź `--tryb C` walidatora (4-pkt schemat uzasadnienia: 2/5/7/8 zamiast 8-pkt). Walidator zwraca exit 0 z 6 ✔. Realizuje Beyoncé Rule (gałąź funkcjonalności = własny test).
- **`tests/fixtures/bad-plan.md`** — uściślono komentarze diagnostyczne BŁĄD 3 i BŁĄD 6 tak, by nie zawierały trigger phrases walidatora („reverse charge", „opinii MSWiA"). Po poprawce walidator wykrywa 10 fizycznych błędów (poprzednio 8) — wszystkie 8 zaprojektowanych logicznych błędów + 5 brakujących sekcji uzasadnienia liczonych osobno.
- **`SKILL.md` sekcja `## Sources`** — dopisano adnotację, że `now_skille/` jest gitignored (analogicznie do `DOC/`), runtime skilla nie zależy od tego katalogu (treść materiału jest przetworzona do `references/*.md` z `source:` per sekcja).
- **`references/klasyfikacja-budzetowa.md` §6 nagłówek** — adnotacja o spójności: skrócona matryca w SKILL.md F4 jest derywatem §6–8, w razie rozbieżności pełna matryca w tym pliku jest źródłem prawdy.

### Notes

- Skrypt nadal POSIX-compliant (`sh -n` OK), bez bashizmów. Awk: POSIX subset (FS, NF, gsub, printf, END).
- Wszystkie 3 fixtures przechodzą walidator zgodnie z oczekiwaniem: GOOD A → exit 0 (8 ✔), GOOD C → exit 0 (6 ✔), BAD A → exit 1 (10 błędów).

## [v1.0.0] — 2026-05-25

### Added

- Pierwsza wersja skilla wspierającego krok-po-kroku przygotowanie wniosku finansowego / uzasadnienia wydatku / kosztorysu TCO dla systemu IT KG PSP.
- `SKILL.md` (313 linii) — procedura 6 faz: F1 Define → F2 Catalogize → F3 Price → F4 Classify → F5 Justify → F6 Verify+Ship; każda faza z exit criterion.
- Trzy tryby finansowania: **A** (POLiOC cz. 42 obronne 752/75282 — domyślny), **B** (POLiOC podstawowy 754/75414), **C** (środki własne KG PSP poza POLiOC 754/75409).
- `references/katalog-kosztow.md` — atomowy katalog 15 sekcji A–O (Cz. II materiału): środowiska / hosting / łączność / bezpieczeństwo / monitoring / service desk / dane i API / narzędzia wytwórcze / testy / dokumentacja / konta / zespół / sprzęt / szkolenia / rezerwy.
- `references/klasyfikacja-budzetowa.md` — pełna klasyfikacja UFP (część/dział/rozdział/§/B/M) + 7 pułapek klasyfikacyjnych (próg netto vs brutto, subskrypcja vs WNiP, drobna rozbudowa vs § 6050, § 4000 placeholder).
- `references/przeliczenia-walut-vat.md` — kurs NBP, VAT 23%, reverse charge dla 18 znanych dostawców zagranicznych (Google, Cloudflare, AWS, Azure, OpenAI, Anthropic, GitHub i in.), rezerwy utrzymaniowa/kursowa/overage, 5 przykładów end-to-end.
- `references/uzasadnienie-8pkt.md` — szablon 8-punktowy per pozycja (Cz. X.2 materiału): kwalifikowalność / celowość / zgodność obronna / lokalizacja / kosztorys / wskaźnik 0–4+ / okres używania ≥ 5 lat / próg MSWiA 100k. Przykłady wypełnienia CEOZO OPEX i CAPEX.
- `references/polioc-ramy.md` — ramy Programu OLiOC 2027–2031: finansowanie 0,3% PKB (z czego 0,15% obronne 752), 7 obszarów Programu z matrycą decyzyjną dla systemów IT KG PSP (CEOZO→5E, CEZOL→4E), trzy kryteria kwalifikowalności, dyslokacja geograficzna z modyfikatorami wschodnimi, wskaźniki 0–4+, inwestycje wieloletnie (art. 156a OLiOC).
- `references/male-koszty-checklist.md` — 19 pozycji najczęściej pomijanych (egress, retencja logów, overage API, koszty wyjścia, rezerwa kursowa itd.) + alokacja A/B/C (bezpośrednie / wytwórcze / wspólne platformowe).
- `references/anti-rationalization.md` — pełna tabela **20 wymówek** agenta z ripostami i wskazaniem fazy powrotu. Pokrywa: wycenę (5 wymówek), klasyfikację UFP (7), uzasadnienie (4), walidację (4). Plus stop-list i tabela „spirit vs letter".
- `scripts/check-cost-plan.sh` — POSIX-compliant walidator (`#!/bin/sh`, `set -eu`) sprawdzający 7 wymagań: § 4000, kurs NBP z datą, 8 punktów uzasadnienia (lub 4 dla trybu C), opinię MSWiA > 100k, plan utrzymania ≥ 5 lat dla § 6050/6060, reverse charge dla pozycji walutowych, klasyfikację 752/75282 dla trybu A. Tryb wywołania: `--plan <ścieżka> --tryb A|B|C`.
- `templates/raport-skeleton.md` — szkielet raport.md (sekcje 1–9: metryczka / podstawa prawna / tryb / lista pozycji / tabela III.B / 8-pkt uzasadnienie / tabela XLSX A-L / DoD / stopka źródeł).
- `tests/fixtures/good-plan.md` + `tests/fixtures/bad-plan.md` — fixture GOOD (kompletny, walidator exit 0) i BAD (8 zaprojektowanych błędów, walidator wykrywa 7, exit 1).

### Notes

- Materiał źródłowy: `now_skille/materialy_polioc/material_przeliczanie_kosztow.md` (11 części, ~1200 linii) + `Projekt-Programu-OLiOC-2027-2031-v17.DOCX` + `Propozycja zadań do POLiOC 2027-2031 cz.42.xlsx`.
- Pryncypia: `DOC/material_skill.md` (Process over Prose, Anti-Rationalization, DoD), `DOC/since_skill.md` (token budget, Negative Triggers, kebab-case, POSIX scripts), `DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md` (szablon, checklist §9, reguła `source:`).
- Weryfikacja aktów prawnych: Sejm ELI API przez skill `legal/sejm-eli-api`, stan 2026-05-25 — Dz.U. 2025 poz. 1483 (UFP tekst jednolity), Dz.U. 2026 poz. 582 (klasyfikacja dochodów/wydatków), Dz.U. 2025 poz. 1185 (klasyfikacja części budżetowych), ustawa OLiOC z 5.12.2024 r.
