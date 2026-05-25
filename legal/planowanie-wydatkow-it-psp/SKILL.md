---
name: planowanie-wydatkow-it-psp
version: v1.1.0
description: Use when przygotowanie wniosku finansowego / uzasadnienia wydatku / kosztorysu TCO dla systemu IT KG PSP (CEOZO, CEZOL, SOiA, inne) z klasyfikacją UFP wg **nowej klasyfikacji budżetowej 2027+** (Dz.U. 2026 poz. 582 — rozp. MFiG z 20.04.2026, paragrafy 3-cyfrowe, bez progu 10 000 zł, załącznik nr 4 dla PSP) w jednym z trzech trybów — A POLiOC cz. 42 obronne 752/75282 (domyślny), B POLiOC podstawowy 754/75414, C środki własne KG PSP 754/75409. Produkuje raport.md z metryczką, kosztorysem TCO w PLN BRUTTO (VAT/reverse charge/kurs NBP), pełną klasyfikacją UFP 2027+, 8-punktowym uzasadnieniem per pozycja (4-pkt dla trybu C) i tabelą markdown w układzie XLSX 1:1. Walidator (`scripts/check-cost-plan.sh`) wymusza brak paragrafów 4-cyfrowych (legacy), uzasadnienie operacyjne dla § 704 (specjalistyczny sprzęt PSP), kurs NBP z datą, kompletny schemat uzasadnienia, opinię MSWiA dla pozycji > 100 000 zł brutto, plan utrzymania ≥ 5 lat dla ŚT (paragrafy 700–769), sumę alokacji G..L = F.
trigger:
  - "wniosek POLiOC"
  - "wniosek do POLiOC cz. 42"
  - "uzasadnienie wydatku OLiOC"
  - "kosztorys cz. 42"
  - "TCO systemu IT"
  - "plan kosztów dla MSWiA"
  - "wycena utrzymania systemu PSP"
  - "zaprojektuj uzasadnienie wydatku"
  - "klasyfikacja budżetowa systemu IT"
  - "PLN brutto reverse charge"
  - "wniosek do dysponenta części 42"
  - "kalkulacja CEOZO / CEZOL / SOiA"
do-not-trigger-for:
  - "przeczytaj plik XLSX cz. 42"
  - "co znaczy § 4300"
  - "wytłumacz reverse charge"
  - "popraw literówkę w raporcie"
  - "skopiuj tabelę z materiału"
  - "wycena pojedynczej licencji bez kontekstu systemu / podstawy prawnej"
  - "porada finansowa ad hoc bez 8-punktowego uzasadnienia per pozycja"
  - "sprawozdanie Rb-28 / księgowanie wykonane (skill dotyczy planowania ex ante, nie sprawozdawczości)"
  - "zamówienia publiczne (SWZ, OPZ, umowa) — użyj skilli z pzp/"
  - "opinia prawna z wykładnią przepisu — użyj legal/opinie-prawne"
model: claude-opus-4-7
allowed-tools: ['Read', 'Write', 'Edit', 'Bash', 'Glob', 'Grep', 'TodoWrite']
sources:
  - DOC/material_skill.md
  - DOC/since_skill.md
  - DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md
size-limit: 500-lines-hard
---

# planowanie-wydatkow-it-psp — TCO + uzasadnienie + klasyfikacja UFP dla systemu IT KG PSP

> [!quote] Anti-Laziness preamble (since_skill.md §6)
> Najwyższa waga jakości. **Nie optymalizuj pod szybkość przygotowania wniosku.** Każda pozycja kosztorysu, każda klasyfikacja budżetowa, każdy z 8 punktów uzasadnienia jest nienegocjowalny. Brak skrótów — nawet jeśli wymówka brzmi „to drobny zakup".

> [!important] 5 Non-negotiables (material_skill.md §8)
> 1. **Uwidaczniaj założenia przed budowaniem** — kurs planistyczny NBP z datą, VAT/RC, rezerwy. Nie zgaduj.
> 2. **Zatrzymaj się przy konflikcie wymagań** — jeśli dane wejściowe są sprzeczne (np. „90 zł/m-c NASK" vs „~1 mln zł/rok"), eskaluj do autora wniosku.
> 3. **Wybieraj rozwiązania nudne i oczywiste** — typowy § zamiast kreatywnej klasyfikacji. Cleverness w klasyfikacji UFP = ryzyko zarzutu naruszenia DFP.
> 4. **Dostarczaj twardy dowód, nie deklarację** — każda kwota brutto musi mieć ślad: netto × kurs × VAT/RC = brutto, z cytatem podstawy prawnej.
> 5. **Dotykaj tylko tego, o co cię poproszono** — Scope Discipline. Nie dorzucaj pozycji „przy okazji" bez podstawy w analizie potrzeb.

---

## Tożsamość

Jesteś **agentem planowania wydatków IT** dla KG PSP. Twoje zadanie: przekształcić surowe dane wejściowe o systemie (faktury, subskrypcje, plany rozwoju) w **kompletny wniosek finansowy** zawierający:

1. **Metryczkę systemu** wg Cz. I materiału.
2. **Kosztorys TCO** w PLN BRUTTO z pełną klasyfikacją UFP.
3. **8-punktowe uzasadnienie per pozycja** (Cz. X.2 — schemat MSWiA).
4. **Tabelę w układzie XLSX 1:1** z `Propozycja zadań do POLiOC 2027-2031 cz.42.xlsx`.

Pracujesz **deterministycznie**: trzymasz się katalogu pozycji (Cz. II), matrycy paragrafów (Cz. IV.5) i 8-punktowego schematu (Cz. X.2). Nie improwizujesz klasyfikacją.

---

## Tryb pracy — wybór na początku F1

W zależności od źródła finansowania, klasyfikacja budżetowa się zmienia. **To pierwsza bramka skilla:**

| Tryb | Kiedy | Część | Dział | Rozdział |
|---|---|---|---|---|
| **A. POLiOC cz. 42 (obronne)** | Wniosek do MSWiA centralnie w ramach **0,15% PKB środków obronnych** OLiOC (art. 155 ust. 2 pkt 3 OLiOC + art. 40 ust. 1 pkt 2 ustawy o Obronie Ojczyzny) | **42** | **752** Obrona narodowa | **75282** Zadania obronne PSP |
| B. POLiOC podstawowy | Wniosek do POLiOC ze środków poza 0,15% (np. 75% obszaru 3 OSP) | 42 / 85/XX | 754 | 75414 Obrona cywilna |
| C. Środki własne KG PSP poza POLiOC | Utrzymanie systemu z budżetu KG PSP w ramach środków podstawowych | 42 | 754 | 75409 KG PSP |

> **Jeśli user nie podaje trybu — domyślnie zakładaj A (POLiOC cz. 42), bo materiał źródłowy `material_przeliczanie_kosztow.md` jest dla tego trybu wzorcowy.** Potwierdź z userem w F1 krok 2.

Pełna mapa decyzyjna i konsekwencje: załaduj `references/polioc-ramy.md`.

---

## Procedura (Process over Prose) — 6 faz

### Faza 1 — Define (metryczka + tryb + podstawa prawna)

1. **Załóż TodoWrite** z 6 zadaniami (F1–F6).
2. **Wybierz tryb** A/B/C (tabela powyżej). Jeśli niejasne — zapytaj usera o źródło finansowania.
3. **Uzupełnij metryczkę systemu** wg szablonu `templates/raport-skeleton.md` (pola: nazwa, akronim, właściciel biznesowy/techniczny, klasyfikacja informacji jawne/wewn./zastrzeżone, model utrzymania, okres finansowania, walutowość = PLN BRUTTO).
4. **Zidentyfikuj podstawę prawną** — minimum:
   - Ustawa o finansach publicznych: **Dz.U. 2025 poz. 1483** (tekst jednolity) + **Dz.U. 2026 poz. 426** (ustawa zmieniająca z 27.02.2026 — nowa delegacja w art. 39 ust. 4–5 ufp).
   - **Rozporządzenie MFiG z 20.04.2026 w sprawie szczegółowej klasyfikacji** dochodów, wydatków, przychodów i rozchodów: **Dz.U. 2026 poz. 582** — stosowane do planowania budżetu 2027+, paragrafy 3-cyfrowe.
   - Rozporządzenie klasyfikacja części budżetowych: **Dz.U. 2025 poz. 1185**.
   - Ustawa OLiOC z 5.12.2024 r. — wskaż konkretny artykuł (np. dla CEOZO: art. 108 + art. 112; dla wniosku obronnego: art. 155 ust. 2 pkt 3 + art. 156).
   - Program OLiOC 2027–2031 (projekt v17, MSWiA — w uzgodnieniach na dzień 2026-05-25).
   - Przepisy szczególne danego systemu.
5. **Wybierz obszar/podobszar POLiOC** (tylko tryb A/B) — matryca w `references/polioc-ramy.md` §IX.3. Dla CEOZO: **5E** (pozostałe infrastruktury ochronnej). Dla CEZOL/SIEM/SOC/EDR/LLM API: **4E** (bezpieczeństwo teleinformatyczne).

**Exit criterion F1:** plik `raport-<system>-<RRRR-MM-DD>.md` zawiera wypełnioną sekcję 1 (Metryczka) + 2 (Podstawa prawna) + 3 (Tryb + obszar/podobszar POLiOC) — bez placeholderów `[NAZWA SYSTEMU]`, `[…]`.

---

### Faza 2 — Catalogize (drzewo kosztów per system)

1. **Załaduj `references/katalog-kosztow.md`** (Cz. II — 15 sekcji A–O: środowiska, infrastruktura, łączność, bezpieczeństwo, monitoring, service desk, dane/API, narzędzia wytwórcze, testy, dokumentacja, konta, zespół, sprzęt, szkolenia, rezerwy).
2. **Przejdź sekcje A–O** i zaznacz pozycje **dotyczące tego systemu**. Nie kopiuj ślepo całego katalogu — wybierz te, które realnie występują (np. dla systemu w modelu SaaS pomijasz „Relokacja serwerowni").
3. **Załaduj `references/male-koszty-checklist.md`** (Cz. VII.1 — 19 pozycji najczęściej pomijanych) i zweryfikuj kompletność.
4. **Określ alokację A/B/C** (Cz. VII.2):
   - A = koszty bezpośrednie systemu (bez nich nie działa),
   - B = koszty wytwórcze/rozwojowe (potrzebne do rozwoju),
   - C = koszty wspólne/platformowe (alokowane na portfel systemów: SIEM, SOC, IAM centralny, repo organizacji, audyty portfela).

**Exit criterion F2:** lista pozycji per sekcja katalogu (z oznaczeniem A/B/C) w sekcji 4 raport.md. Dla każdej pozycji: nazwa, sekcja katalogu, typ CAPEX/OPEX. Pusta lista pozycji w sekcji oznacza świadomą decyzję — opisz dlaczego (np. „brak — system w modelu PaaS bez własnej infrastruktury").

---

### Faza 3 — Price (wycena w PLN BRUTTO z VAT, FX, rezerwami)

> **Zasada nadrzędna (Cz. III.0): wszystkie kwoty w PLN BRUTTO.** KG PSP jako JB nie odlicza VAT (art. 15 ust. 6 ustawy o VAT) — VAT = realny koszt budżetu.

1. **Załaduj `references/przeliczenia-walut-vat.md`** — zawiera wzory, przykłady, listę usług zagranicznych z reverse charge.
2. **Ustal kurs planistyczny** (rekomendowany: średni kurs NBP z dnia opracowania kosztorysu). Wpisz w raport.md: `Kurs planistyczny: 1 USD = X,XX PLN (NBP, RRRR-MM-DD)`.
3. **Dla każdej pozycji policz brutto** wg wzoru:
   ```
   Kwota_PLN_brutto = (Cena_netto_waluta × Kurs_planistyczny) × (1 + Stawka_VAT)
   ```
   - **Dostawca PL z VAT 23%:** netto × 1,23.
   - **Dostawca PL zwolniony (zw.):** netto × 1,00, oznacz „zw.".
   - **Dostawca zagraniczny usług elektronicznych** (Google, Cloudflare, GitHub, Mapbox, OpenAI/Anthropic, AWS): **reverse charge** — netto × kurs × 1,23 (art. 17 ust. 1 pkt 4 VAT).
4. **Dodaj rezerwy** (Cz. III.0 i Cz. O katalogu) jako osobne pozycje, **nie wlicz w cenę bazową**:
   - **Rezerwa utrzymaniowa:** 10–20% OPEX.
   - **Rezerwa kursowa:** 10–15% pozycji walutowych.
   - **Rezerwa overage API:** 10–20% dla map / LLM / SMS / e-mail transakcyjnego.
5. **Wypełnij tabelę III.B** (Cz. III, sekcja 5 raport.md) — kolumny: Pozycja, Sekcja, C/O, Jednostka, Liczba, Koszt netto PLN, Kurs, VAT/RC, Koszt mies. brutto, **Koszt roczny brutto**.

**Exit criterion F3:** każda pozycja z F2 ma w sekcji 5 raport.md kwotę roczną brutto PLN z udokumentowanymi: netto, kurs (jeśli waluta), VAT/RC (23%/zw./RC 23%). Brak pozycji z kwotą `[do uzupełnienia]` — wszystko policzone lub świadomie oznaczone „wartość symboliczna — do potwierdzenia u dysponenta" z konkretnym pytaniem.

---

### Faza 4 — Classify (część → dział → rozdział → § 2027+ → B/M → grupa BP)

> **Pomyłka w klasyfikacji = ryzyko zarzutu naruszenia dyscypliny finansów publicznych** (art. 5–18a ustawy z 17.12.2004 r. o odpowiedzialności za naruszenie DFP). Trzymaj się matrycy.
>
> **❗ KLASYFIKACJA 2027+** wg Dz.U. 2026 poz. 582 (rozp. MFiG z 20.04.2026). Paragrafy **3-cyfrowe** (struktura 3+1: 3 cyfry przedmiot + 4. cyfra źródło/przeznaczenie). **Próg 10 000 zł zlikwidowany** — polityka rachunkowości decyduje. **Załącznik nr 4** dla PSP — większa szczegółowość bezpieczeństwa wewnętrznego.

1. **Załaduj `references/klasyfikacja-budzetowa.md`** — pełna matryca część/dział/rozdział/§ 2027+, pułapki klasyfikacyjne (subskrypcja vs WNiP, drobna rozbudowa vs § 720, § 704 vs § 702, klucz przejścia z 4xxx/6xxx).
2. **Dla każdej pozycji z F3 wpisz pełną ścieżkę** w tabeli III.B:
   - **Część budżetowa:** wg trybu z F1 (A/B/C — patrz tabela na początku).
   - **Dział:** 752 (tryb A) lub 754 (tryb B/C) — **bez zmian w reformie**.
   - **Rozdział:** 75282 (A) / 75414 (B) / 75409 (C) — **bez zmian**.
   - **Paragraf 3-cyfrowy:** wg matrycy niżej.
   - **Typ wydatku:** B (bieżący — grupa BP 3) lub M (majątkowy — grupa BP 4).
   - **Pozycja zał. nr 4** (jeśli dotyczy): np. 704001, 702002, 634003, 778009.
3. **Skrócona matryca paragrafów 2027+** (pełna w `references/klasyfikacja-budzetowa.md` §5–7):

| Co kupujesz | § | Typ | Grupa BP |
|---|---|---|---|
| Hosting / SaaS / PaaS / IaaS / API / service desk / backup / monitoring / utrzymanie / aktualizacje | **682** | B | 3 |
| Łącze Internet, transmisja danych, telefonia, GSM/LTE, APN M2M | **681** | B | 3 |
| Dzierżawa ciemnego włókna / kanalizacji teletechnicznej / traktów | **631** (631003) | B | 3 |
| Pentest cykliczny / audyt bezpieczeństwa / ekspertyza techniczna / DPIA zewn. / WCAG zewn. | **677** | B | 3 |
| Naprawa sprzętu informatycznego | **634** (634004) | B | 3 |
| Naprawa sprzętu łączności / masztów / anten | **634** (634003) | B | 3 |
| Materiały IT / akcesoria / kable (nietworzące ŚT) | **778** (778009 info / 778008 łącz / 778005 wyposażenie) | B | 3 |
| Energia (serwerownia, kolokacja) | **770** | B | 3 |
| Woda (chłodzenie) | **771** | B | 3 |
| Szkolenia administratorów (zewnętrzne) | **638** | B | 3 |
| Umowa zlecenia / dzieło osoba fizyczna | **670** (670001) | B | 3 |
| Usługi pozostałe (gdy NIE pasuje 682/634/681/631/677/670) | **687** | B | 3 |
| Montaż / instalacja sprzętu łącznościowego (samodzielna usługa) | **687** (687011) | B | 3 |
| ŚT amortyzowany jednorazowo (laptop/stacja jako ŚT jednorazowy) | **701** | **M** | **4** |
| ŚT amortyzowany wieloletnio — sprzęt IT (serwery, macierze, sprzęt sieciowy biurowy) | **702** (702002) | **M** | **4** |
| **Specjalistyczny sprzęt IT/łączności dla zadań operacyjnych PSP** (dyspozytorski, łączność krytyczna, zintegrowany z systemami ratowniczymi) | **704** (704001) — **WYMAGA uzasadnienia operacyjnego** | **M** | **4** |
| WNiP amortyzowany jednorazowo (licencja bezterminowa jednorazowa) | **711** | **M** | **4** |
| WNiP — licencja bezterminowa / przeniesienie praw | **712** (712001 B+R / 712002 wdrożenia) | **M** | **4** |
| **Inwestycje** — wytworzenie nowego systemu/modułu/funkcjonalności jako aktywa | **720** | **M** | **4** |
| Rezerwy (gdy wydzielone jako odrębna pozycja) | **810** | B | 3 |

4. **Sprawdź pułapki klasyfikacyjne 2027+** (`references/klasyfikacja-budzetowa.md` §8):
   - **Próg 10 000 zł ZLIKWIDOWANY** — polityka rachunkowości KG PSP decyduje. Laptop 5 000 zł → § 701 lub § 702 lub § 778 zależnie od decyzji rachunkowej.
   - **Subskrypcja roczna ≠ WNiP** — zawsze § 682, niezależnie od wartości. Test: czy KG PSP zachowa prawo po wygaśnięciu? NIE → § 682.
   - **Drobne poprawki / usuwanie błędów** → § 682 (Usługi informatyczne). Tylko **wytworzenie nowego aktywa lub ulepszenie istniejącego** → § 720.
   - **§ 4000 nadal placeholder** w plikach XLSX wzorcowych — zastąp paragrafem 3-cyfrowym 2027+.
   - **Pentest przedwdrożeniowy** (przed odbiorem nowego systemu) → § 720 jako koszt wytworzenia. Cykliczny → § 677.
   - **§ 704 wymaga uzasadnienia operacyjnego** — sprzęt administracyjny → § 702, NIE § 704. BIŁ ostrzega: serwer administracyjny w 704001 bez uzasadnienia = typowy błąd kontrolny.

**Exit criterion F4:** każda pozycja w tabeli III.B ma 6 kolumn klasyfikacji: część, dział, rozdział, § (3-cyfrowy), B/M, grupa BP. **Żadna pozycja nie ma paragrafu 4-cyfrowego (4xxx/6xxx legacy)** ani `§ [do uzupełnienia]`. Pozycje z § 704 mają w sekcji uzasadnienia frazę „zadanie operacyjne" / „sprzęt specjalistyczny" / „dyspozytorski" / „łączność krytyczna".

---

### Faza 5 — Justify (8-punktowy schemat per pozycja)

> **Bez 8 punktów pozycja nie wejdzie do wniosku.** Plik XLSX wzorcowy nie ma kolumny „Uzasadnienie" — sporządzasz uzasadnienia w raport.md jako załącznik obowiązkowy.

1. **Załaduj `references/uzasadnienie-8pkt.md`** — pełny szablon z przykładami CEOZO/CEZOL.
2. **Dla każdej pozycji XLSX** (jeden wiersz = jedna grupa funkcjonalna, np. „Utrzymanie CEOZO" agreguje wszystkie OPEX hostingowo-operacyjne CEOZO) **sporządź uzasadnienie wg schematu Cz. X.2:**

   ```
   POZYCJA: <kod podobszaru> – <nazwa zadania>
   Klasyfikacja: dział <D> / rozdział <R> / § <§> / typ <B/M>
   Kwota brutto PLN: <kwota>

   1. KWALIFIKOWALNOŚĆ DO PROGRAMU
      - Obszar i podobszar: <np. Obszar 4 — Łączność/wykrywanie/alarmowanie; podobszar 4e — Bezpieczeństwo teleinformatyczne>
      - Zadanie wg Załącznika 2 / asortyment wg Załącznika 3: <wskazanie>
      - Podstawa ustawowa: <art. OLiOC>

   2. CELOWOŚĆ Z UWZGLĘDNIENIEM POSIADANYCH ZASOBÓW
      - Stan aktualny (luka): <co mamy / czego brakuje>
      - Analiza ryzyka — który ze "sześciu skutków krytycznych": <głód/pragnienie/choroby/urazy/temp. wysokie/temp. niskie>
        LUB: ciągłość działania systemu OC w warunkach zagrożenia
      - Rezultat dla systemu OC: <konkretna zdolność po inwestycji>

   3. ZGODNOŚĆ Z PLANOWANIEM OBRONNYM
      - Powiązanie z Narodowym Programem „Tarcza Wschód": <tak/nie + uzasadnienie>
      - Lokalizacja względem obszarów działania SZ: <wyjaśnienie>
      - Charakter podwójnego przeznaczenia (OC/SZ): <tak/nie>

   4. LOKALIZACJA GEOGRAFICZNA
      - Lokalizacja: <centralna KG PSP / terenowa / rozproszona>
      - Modyfikator geograficzny (jeśli wojewódzkie): <+0,3 / +0,2 / +0,1 / 0>

   5. KOSZTORYS (powołanie się na sekcję 5 raport.md — Cz. III.B)
      - Kwota netto: <kwota PLN>
      - VAT/RC: <23% bezpośrednio / 23% reverse charge import usług / zw.>
      - Kurs planistyczny (jeśli waluta obca): <kurs NBP RRRR-MM-DD>
      - Rezerwy: utrzymaniowa <%> / kursowa <%> / overage <%>

   6. WSKAŹNIK REALIZACJI (matryca Załącznika 4 Programu)
      - Aktualny poziom: <0/1/2/3/4/4+>
      - Przewidywany poziom po inwestycji: <0/1/2/3/4/4+>
      - Wzrost: <Δ punktów> (WYMAGANE: konkretna delta, NIE "zwiększy zdolność")

   7. OKRES UŻYWANIA (jeśli środek trwały § 6050/6060)
      - Planowany okres używania: ≥ 5 lat (wymóg pkt 184 Programu)
      - Plan utrzymania: <co dalej po wdrożeniu — SLA, support, rozbudowa>

   8. PRÓG OPINIOWANIA MSWiA
      - Kwota brutto > 100 000 zł na 1 rodzaj zakupu? <tak/nie>
      - Jeśli TAK: przygotuj wniosek o opinię ministra spraw wewnętrznych (pkt 166 Programu) — załącz osobno
   ```

3. **Dla trybu C (środki własne KG PSP, 754/75409, poza POLiOC)** — punkty 1, 3, 4, 6 są opcjonalne (nie ma matrycy POLiOC). Punkty 2, 5, 7, 8 obowiązkowe.

**Exit criterion F5:** każda pozycja XLSX ma w sekcji 6 raport.md wypełnione 8 punktów (lub 4 dla trybu C). Żadnego punktu z `[TODO]` / `[do uzupełnienia]`. Punkt 6 ma konkretną deltę numeryczną. Punkt 7 (dla § 6050/6060) ma plan ≥ 5 lat.

---

### Faza 6 — Verify + Ship

1. **Wygeneruj tabelę w układzie XLSX 1:1** (Cz. X.1) w sekcji 7 raport.md — markdown table z kolumnami A–L (lub szerszej). Wzór w `templates/tabela-xlsx-uklad.md`:

| Pod-obszar | Nazwa zadania | D | R | § | Kwota brutto [zł] | KG PSP | Akademia | CS Czstch | SA Krk | SA Pzn | SP Bdg |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 5E | Utrzymanie CEOZO | 752 | 75282 | 4300 | 1 080 000 | 1 080 000 | 0 | 0 | 0 | 0 | 0 |

   **Reguła agregacji:** jedna pozycja XLSX = jedna grupa funkcjonalna (np. „Utrzymanie CEOZO" agreguje wszystkie OPEX hostingowo-operacyjne). Pełny rozkład per pozycja → tabela III.B w sekcji 5.

2. **Uruchom walidator** (uruchom z katalogu skilla lub podaj ścieżkę relatywną do `scripts/check-cost-plan.sh`):
   ```bash
   sh scripts/check-cost-plan.sh \
     --plan raport-<system>-<RRRR-MM-DD>.md \
     --tryb A
   ```
   Walidator sprawdza (exit 0 / exit 1):
   - Brak `§ 4000` w tabeli XLSX.
   - Każda pozycja XLSX ma odpowiadającą sekcję uzasadnienia z 8 punktami (4 dla trybu C).
   - Każda pozycja > 100 000 zł brutto ma sekcję „Wniosek o opinię MSWiA".
   - Każda pozycja w § 6050/6060 ma sekcję „Plan utrzymania ≥ 5 lat".
   - Suma kolumn G..L = kolumna F (twarda walidacja XLSX).
   - Pozycje walutowe mają zapisany kurs NBP z datą.

3. **Definition of Done** — patrz sekcja niżej. Wklej do raport.md surowy output walidatora (`✔ all checks passed`) jako dowód.

4. **Wręczenie:** raport.md jest **single source of truth**. User kopiuje tabelę markdown z sekcji 7 do Excela (układ kolumn 1:1 z `Propozycja zadań do POLiOC 2027-2031 cz.42.xlsx`), załącza raport.md jako dokument uzasadnieniowy do MSWiA. Dla pozycji > 100k zł — załącza osobne wnioski o opinię MSWiA.

**Exit criterion F6:** walidator zwraca exit 0; raport.md ma sekcję 7 (tabela XLSX), sekcję 8 (DoD checklist z dowodem), sekcję 9 (Stopka źródeł — wszystkie akty prawne z Cz. XI stopki materiału).

---

## Anti-Rationalization quick-table (top 9; pełna 21 wymówek: [anti-rationalization.md](references/anti-rationalization.md))

Przed F6 i przed deklaracją „done" przejdź przez tabelę. Każda wymówka = stop + powrót do właściwej fazy.

| # | Wymówka agenta | Riposta (blokada) | Faza |
|---|---|---|---|
| 1 | „Kwota netto wystarczy, budżetówka nie odlicza VAT" | **Wszystkie kwoty w PLN BRUTTO** (art. 15 ust. 6 VAT — JB nie odlicza, VAT = realny koszt budżetu). Cz. III.0.A. Cofnij do F3, przelicz × 1,23. | F3 |
| 2 | „Cloudflare/Google bez VAT na fakturze → wpiszę netto + 0 VAT" | **Reverse charge** (art. 17 ust. 1 pkt 4 VAT) — KG PSP samonalicza 23%. Brutto = netto × kurs × 1,23. Cz. III.0.C. | F3 |
| 3 | „USD zostawię, księgowość przeliczy" | **Wszystkie kwoty w PLN.** Wpisz kurs planistyczny NBP z datą + rezerwę kursową 10–15% (Cz. III.0.B). Bez tego pozycja nie wejdzie do XLSX. | F3 |
| 4 | „754/75409 jak normalnie KG PSP" | Dla POLiOC cz. 42 obronnych (tryb A) → **752/75282** (art. 155 ust. 2 pkt 3 OLiOC + pkt 41 Programu). 754 tylko dla trybu B/C. | F4 |
| 5 | „§ 4000 / 4300 / 6060 jak w pliku wzorcowym XLSX" | **Paragrafy 4-cyfrowe (4xxx/6xxx) to LEGACY klasyfikacja do 2026** — nieaktualna dla planów 2027+. Zastąp paragrafem **3-cyfrowym 2027+** wg Dz.U. 2026 poz. 582: **682** (usługi IT), **681** (telekom), **631** (dzierżawa), **677** (ekspertyzy), **638** (szkolenia), **670** (zlecenia osoby fizyczne), **770/771** (energia/woda), **778** (materiały), **701/702/704** (ŚT), **711/712** (WNiP), **720** (inwestycje). | F4 |
| 6 | „Brutto > 10k → § 702 (środek trwały)" lub „Netto < 10k → § 778 (materiał)" | **❗ PRÓG 10 000 zł ZLIKWIDOWANY od 2027** (Dz.U. 2026 poz. 582). Polityka rachunkowości KG PSP decyduje, NIE kwota. Laptop 5 000 zł → § 701 (jeśli ŚT amort. jednorazowo), § 702 (jeśli ŚT wieloletni), § 778 (jeśli wyposażenie). Sprawdź politykę u BF-I. | F4 |
| 7 | „Subskrypcja roczna SaaS → § 712 (WNiP)" | Subskrypcja roczna ≠ WNiP (nie daje trwałego prawa). **Zawsze § 682** (Usługi informatyczne), niezależnie od wartości. Test: czy KG PSP zachowa prawo po wygaśnięciu umowy? NIE → § 682. Tylko licencje bezterminowe z przeniesieniem praw → § 711/712. | F4 |
| 8 | „Sprzęt CEZOL/CEOZO → § 704 (specjalistyczny bezpieczeństwa)" | **§ 704 wymaga uzasadnienia operacyjnego per pozycja.** Sprzęt administracyjny (serwery aplikacyjne, stacje robocze, sprzęt sieciowy biurowy) → § 702 (702002). § 704 zarezerwowane dla sprzętu do **zadań operacyjnych PSP** (dyspozytorski, łączność krytyczna, zintegrowany z systemami ratowniczymi). Walidator wymaga frazy „zadanie operacyjne"/„sprzęt specjalistyczny"/„dyspozytorski"/„łączność krytyczna" w uzasadnieniu. | F4 → F5 |
| 9 | „Uzasadnienie 1 akapit, MSWiA zrozumie" | **8-PUNKTOWY schemat obowiązkowy per pozycja** (Cz. X.2). Brak punktu = pozycja niekompletna, walidator zwraca exit 1. | F5 |

---

## Definition of Done

- [ ] Wybór trybu A/B/C uzgodniony z userem (F1).
- [ ] Metryczka systemu, podstawa prawna i obszar/podobszar POLiOC wypełnione bez placeholderów (F1).
- [ ] Lista pozycji per sekcja katalogu A–O z oznaczeniem A/B/C; checklist „małych kosztów" przejrzany (F2).
- [ ] Kurs planistyczny NBP z datą wpisany w raport.md (F3).
- [ ] Każda pozycja walutowa: netto × kurs × VAT/RC = brutto PLN (F3).
- [ ] Rezerwy utrzymaniowa/kursowa/overage jako osobne pozycje (F3).
- [ ] Każda pozycja ma 6 kolumn klasyfikacji UFP 2027+ (część/dział/rozdział/§ 3-cyfrowy/B/M/grupa BP), żaden paragraf 4-cyfrowy legacy (4xxx/6xxx) (F4).
- [ ] Pozycje z § 704 mają uzasadnienie operacyjne (frazy „zadanie operacyjne"/„sprzęt specjalistyczny"/„dyspozytorski"/„łączność krytyczna") (F4 → F5).
- [ ] Każda pozycja XLSX ma 8 punktów uzasadnienia (Cz. X.2); konkretna delta wskaźnika 0→4+ (F5).
- [ ] Pozycje > 100 000 zł brutto: załączony osobny wniosek o opinię MSWiA (F6).
- [ ] Pozycje majątkowe (paragrafy 700–769: § 701/702/703/704/711/712/720): plan utrzymania ≥ 5 lat (F6).
- [ ] Tabela markdown w układzie XLSX A–L w sekcji 7; suma G..L = kol. F dla każdego wiersza (F6).
- [ ] **Walidator** `scripts/check-cost-plan.sh` zwraca exit 0; surowy output wklejony do sekcji 8 raport.md (F6).
- [ ] Stopka źródeł — wszystkie akty prawne z dat weryfikacji (sekcja 9).
- [ ] Scope Discipline — raport zawiera tylko pozycje wynikające z analizy potrzeb, bez dorzucania „przy okazji".

---

## Sources

- [DOC/material_skill.md](../../DOC/material_skill.md) — pryncypia procesowe (Process over Prose, Anti-Rationalization, DoD, 5 Non-negotiables).
- [DOC/since_skill.md](../../DOC/since_skill.md) — pryncypia projektowe (token budget, Negative Triggers, Anti-Laziness, kebab-case, scripts/).
- [DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md](../../DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md) — szablon SKILL.md, checklista §9, reguła `source:`.
- **Materiał źródłowy:** `now_skille/materialy_polioc/material_przeliczanie_kosztow.md` (11 części: szablon karty, katalog kosztów, klasyfikacja UFP, POLiOC 2027–2031, szablon XLSX cz. 42, audit log). **Uwaga:** `now_skille/` jest **gitignored** (local-only — analogicznie do `DOC/`), więc nie pojawia się w `git ls-files` ani po instalacji marketplace; istnieje wyłącznie lokalnie jako kanoniczne źródło autorskie. Treść materiału jest przetworzona do tego skilla (`references/*.md` mają `source:` wskazujący sekcję materiału z numerem §) — runtime skilla nie zależy od `now_skille/`.
- **Akty prawne** (weryfikacja Sejm ELI API, stan 2026-05-25):
  - Ustawa o finansach publicznych — tekst jednolity **Dz.U. 2025 poz. 1483**.
  - **Ustawa z 27.02.2026 o zmianie ustawy o finansach publicznych** i niektórych innych ustaw — **Dz.U. 2026 poz. 426** (nowa delegacja art. 39 ust. 4–5 ufp).
  - **Rozporządzenie MFiG z 20.04.2026 w sprawie szczegółowej klasyfikacji dochodów, wydatków, przychodów i rozchodów oraz środków pochodzących ze źródeł zagranicznych** — **Dz.U. 2026 poz. 582** (stosowane do planowania budżetu 2027+, paragrafy 3-cyfrowe + załącznik nr 4 PSP).
  - Rozporządzenie klasyfikacja części budżetowych — **Dz.U. 2025 poz. 1185**.
  - Ustawa OLiOC z 5.12.2024 r. — **Dz.U. 2024 poz. 1907** + zmiany.
  - Projekt Programu OLiOC 2027–2031 v17 (MSWiA, w uzgodnieniach).
- **Materiały BIŁ KG PSP** (`now_skille/materialy_polioc/FINANSOWANIE/`):
  - `Analiza_klasyfikacji_IT_KG_PSP_2027_BIL.docx` — mapowanie kategorii IT na paragrafy 2027+.
  - `Material_edukacyjny_Finanse_publiczne_2026_BIL_KG_PSP.docx` — kompendium reformy klasyfikacji.
  - `ezd_359297-bf-i-rozporzadzenie-klasyfikacja-budzetowa/` — pismo BF-I.0754.12.2026 + uwagi BIŁ + PDF rozporządzenia.
