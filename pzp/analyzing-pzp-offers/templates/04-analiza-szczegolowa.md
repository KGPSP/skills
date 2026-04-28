---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa>>"
wykonawca: <<nazwa>>
wykonawca_slug: <<slug-wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
typ_dokumentu: analiza-szczegolowa
status: <<draft | final>>
tags:
  - pzp/raport
  - pzp/analiza-szczegolowa
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
---

# Analiza szczegółowa — Oferta <<wykonawca>>

> [!info] Struktura
> Dokument prowadzi weryfikację **punkt po punkcie** zgodnie z sekcjami A–G z `verification-prompt.md`. Dla każdej sekcji: podsumowanie, lista ustaleń, lista znalezisk z referencjami do [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>]].

## A. Weryfikacja formalna oferty

### A.1. Formularz oferty

**Stan faktyczny:**
<<Czy formularz został złożony, czy kompletny, kto podpisał, jaki numer dokumentu, data.>>

**Cytaty kluczowe:**
- `[DOC: <<plik>>] [str. <<N>>]` — „<<cytat>>"

**Ocena:** ✅ / ⚠️ / ❌ <<uzasadnienie>>

**Znaleziska:** [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>#^find-XXX]]

### A.2. Cena oferty (brutto, netto, VAT, arytmetyka)

**Deklarowane:**
- Brutto: <<kwota>>
- Netto: <<kwota>>
- VAT: <<kwota>>
- Suma netto + VAT: <<kwota>> (sprawdzenie arytmetyki: <<zgodna / rozbieżność N zł>>)

**Ocena:** <<...>>

**Cena rażąco niska (art. 224 Pzp):** <<analiza vs. wartość szacunkowa, średnia arytm. pozostałych ofert>>

### A.3. Okres gwarancji

**Deklarowany:** <<N>> miesięcy
**Wymagany (zakres):** <<min>>–<<max>> miesięcy (źródło: `[DOC] [Rozdz.] [pkt]`)
**Ocena:** ✅ / ⚠️ / ❌

### A.4. Termin wykonania

**Deklarowany:** <<data>>
**Wymagany:** <<data>>
**Ocena:** <<...>>

### A.5. Podpis elektroniczny

**Forma:** <<kwalifikowany / zaufany / osobisty>>
**Podpisany przez:** <<osoba + funkcja>>
**Podstawa umocowania:** <<pełnomocnictwo / KRS>>
**Ocena:** <<...>>

### A.6. Forma dokumentów

<<PDF / DOCX / XML / XAdES / PAdES — sprawdź zgodność z wymogami SWZ.>>

### A.7. Termin związania ofertą (TZO)

**Deklarowany:** <<...>>
**Wymagany:** <<...>>
**Ocena:** <<...>>

### A.8. Spójność wewnętrzna oferty

<<Czy wszystkie dokumenty wskazują te same: cenę, gwarancję, termin, status, osobę upoważnioną?>>

---

## B. Kompletność dokumentów składanych WRAZ Z OFERTĄ

> Oddzielnie dla KAŻDEGO wymaganego dokumentu: czy został złożony, gdzie, czy prawidłowo.

### B.1. Formularz oferty (Zał. 3)

<<Analiza — źródło wymogu, stan faktyczny, ocena.>>

### B.2. JEDZ

<<Wykonawca + podmiot trzeci (jeśli dot.) — kompletność sekcji II–VI.>>

### B.3. OPZ wypełniony (Zał. 1)

<<Czy obejmuje wszystkie części (A, B, C), czy wskazano oferowane modele/parametry, czy karty katalogowe są dołączone lub zastrzeżone jako tajemnica przedsiębiorstwa.>>

### B.4. Karty katalogowe / dokumentacja techniczna

<<Które elementy OPZ mają obowiązek karty katalogowej; czy karta odnosi się do oferowanego modelu; czy zawiera weryfikowalne parametry.>>

### B.5. Przedmiotowe środki dowodowe

<<Certyfikaty, wyniki testów, benchmarki, dokumentacja równoważności.>>

### B.6. Zobowiązanie podmiotu 3 (Zał. 6)

<<Jeśli wykonawca polega na zasobach innego podmiotu — analiza zobowiązania.>>

### B.7. Oświadczenia sankcyjne

<<Zał. 9 wykonawcy — czy obejmuje wykonawcę, podwykonawcę, dostawcę >10%, podmiot trzeci; Zał. 10 podmiotu trzeciego — jeśli dotyczy.>>

### B.8. Wadium — pełna weryfikacja (art. 97–98 Pzp)

> [!warning] Pogłębiona checklista
> Wadium to jedna z najczęstszych przyczyn odrzuceń (art. 226 ust. 1 pkt 14 Pzp) i odwołań do KIO. Sprawdź **każdy** z 14 punktów poniżej — każdy brak to potencjalne ryzyko odrzucenia lub — przeciwnie — ryzyko KIO przy błędnym odrzuceniu.

#### Parametry formalne (wynikające z SWZ i dokumentacji)

| # | Element | Wymóg SWZ | Stan oferty | Zgodność | Podstawa |
|---|---------|-----------|--------------|----------|----------|
| 1 | **Forma wadium** (art. 97 ust. 7 Pzp) | `[DOC: SWZ] [Rozdz.] [str.]` — <<forma>> | `[DOC: <<plik>>]` — <<forma>> | ✅/⚠️/❌ | art. 97 ust. 7 Pzp: pieniądz / gwarancja bank. / gwarancja ubezp. / poręczenie PARP |
| 2 | **Kwota** | <<wymagana>> (≤ 3% wartości zamówienia — art. 97 ust. 2) | <<oferowana>> | ✅/⚠️/❌ | art. 97 ust. 2 Pzp |
| 3 | **Beneficjent** — nazwa zgodna z SWZ | <<pełna nazwa zamawiającego>> | <<nazwa w gwarancji>> | ✅/⚠️/❌ | błędny beneficjent = nieważna gwarancja |
| 4 | **Sygnatura postępowania w tytule** | <<sygnatura>> | <<w tytule gwarancji/przelewu>> | ✅/⚠️/❌ | identyfikacja do konkretnego postępowania |
| 5 | **Termin ważności** ≥ termin związania ofertą (TZO) | do <<data TZO>> | do <<data>> | ✅/⚠️/❌ | art. 97 ust. 5 Pzp |
| 6 | **Moment wniesienia** (przed upływem terminu składania ofert) | do <<data+godz.>> | <<data+godz. wniesienia>> | ✅/⚠️/❌ | art. 97 ust. 5 Pzp |
| 7 | **Forma składania** — oryginał elektroniczny gwarancji/poręczenia | wg art. 97 ust. 10 | <<PDF z podpisem kwalifikowanym gwaranta>> | ✅/⚠️/❌ | art. 97 ust. 10 Pzp (dla form innych niż pieniądz) |

#### Klauzule gwarancji (dla form innych niż pieniądz)

| # | Klauzula | Wymóg | Stan | Zgodność | Ryzyko jeśli brak |
|---|----------|-------|------|----------|--------------------|
| 8 | **Nieodwołalność** — gwarant nie może odwołać zabezpieczenia | Tak | <<cytat z gwarancji>> | ✅/⚠️/❌ | Odrzucenie — wadium nie zabezpiecza |
| 9 | **Bezwarunkowość** — wypłata bez badania podstaw żądania | Tak | <<cytat>> | ✅/⚠️/❌ | Odrzucenie jeśli warunkowa (np. wymóg przedstawienia wyroku sądu) |
| 10 | **Płatność na pierwsze żądanie** — gwarant wypłaca niezwłocznie | Tak | <<cytat>> | ✅/⚠️/❌ | Odrzucenie jeśli wymaga zgody gwaranta lub innych formalności |
| 11 | **Brak klauzul ograniczających** — UWAGA na: „tylko za zgodą", „pod warunkiem przedłożenia oryginału", „do przekroczenia kwoty", „w terminie X dni od zdarzenia" | Bez klauzul ograniczających | <<cytaty klauzul, jeśli istnieją>> | ✅/⚠️/❌ | **Najczęstsza przyczyna odwołań KIO**: klauzule „rezygnacyjne" skutecznie wyłączają wadium z obiegu |
| 12 | **Zakres przesłanek zatrzymania** — wszystkie z art. 98 ust. 6 Pzp | pkt 1, 2, 3 (wezwanie bezskuteczne, odmowa podpisania umowy, niewniesienie zabezpieczenia, wina uniemożliwiająca zawarcie umowy) | <<treść gwarancji>> | ✅/⚠️/❌ | Jeśli gwarancja pomija którykolwiek punkt art. 98 ust. 6 — brak zabezpieczenia roszczeń zamawiającego |

#### Formalne zgodności

| # | Element | Stan | Zgodność |
|---|---------|------|----------|
| 13 | **Podpis gwaranta** (dla gwarancji elektronicznych — kwalifikowany podpis banku/ubezpieczyciela) | <<informacja o podpisie>> | ✅/⚠️/❌ |
| 14 | **Przekazanie oryginału** (dla form elektronicznych — plik w wymaganym formacie, z kwalifikowanym podpisem gwaranta; dla kopii papierowej — zgodnie z wymogami SWZ) | <<sposób>> | ✅/⚠️/❌ |

#### Ocena końcowa wadium

- **Łączne spełnienie 14/14:** wadium prawidłowe ✅
- **Brak ≥ 1 punktu z 1–12:** potencjalne **odrzucenie (art. 226 ust. 1 pkt 14 Pzp)** — szczegółowa analiza wymagana
- **Brak w pkt 13–14 (formalne):** **możliwa konwalidacja** jeśli treść gwarancji pozostaje prawidłowa (np. ponowne przesłanie prawidłowo podpisanego pliku)

**Ocena tego wykonawcy:** <<...>>

**Cytaty kluczowe:**
- `[DOC: <<gwarancja.pdf>>] [str. <<N>>]` — „<<cytat bezwarunkowości/nieodwołalności/...>>"

**Linkowane znaleziska:** [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>#^find-XXX]]

### B.9. Pełnomocnictwo (jeśli dotyczy)

<<Zakres umocowania, osoba, forma (oryginał elektroniczny / notarialnie poświadczona kopia), podstawa.>>

### B.10. Uzasadnienie tajemnicy przedsiębiorstwa (jeśli dotyczy)

<<Analiza 3 przesłanek (art. 18 ust. 3 Pzp + art. 11 ust. 2 uznk):>>

1. **Charakter informacji + wartość gospodarcza** — <<ocena>>
2. **Niepowszechność** — <<ocena>>
3. **Działania ochronne** — <<ocena>>

**Wniosek:** Zastrzeżenie <<skuteczne / nieskuteczne>> (podstawa: <<art. 18 ust. 3 Pzp, orzecznictwo KIO>>).

---

## C. Dokumenty składane NA WEZWANIE

> [!info] Uwaga
> Brak w ofercie ≠ błąd. Weryfikujemy tylko czy wymóg istnieje i który dokument zamawiający może/powinien wezwać.

### C.1. Wykaz dostaw (Zał. 4)

<<Wymóg z SWZ + modyfikacji (okres, kwota, rodzaj dostaw). Podstawa wezwania: art. 126 Pzp.>>

### C.2. Wykaz osób (Zał. 5)

<<Wymóg z SWZ (role, doświadczenie, kwalifikacje). Podstawa: art. 126 Pzp.>>

### C.3. Oświadczenie grupa kapitałowa (Zał. 7)

<<Podstawa: art. 108 ust. 1 pkt 5 Pzp, termin 3 dni od zamieszczenia informacji z otwarcia.>>

### C.4. Oświadczenie o aktualności (Zał. 8)

<<Podstawa: § 3 rozporządzenia Ministra Rozwoju, Pracy i Technologii z 23.12.2020 r. w sprawie podmiotowych środków dowodowych (Dz.U. 2020 poz. 2415 ze zm.). Wezwanie w trybie art. 126 ust. 1 Pzp (procedura unijna) lub art. 274 ust. 1 Pzp (tryb podstawowy). Uwaga: art. 125 Pzp reguluje wyłącznie JEDZ / oświadczenie wstępne — nie należy go mylić z „oświadczeniem o aktualności" składanym przez wykonawcę najwyżej ocenionego.>>

### C.5. Zaświadczenia ZUS/US, informacja z KRK

<<Podstawa: art. 108 Pzp + rozp. MRiF z 23.12.2020 r.>>

---

## D. Zgodność merytoryczna z OPZ i SWZ

> Weryfikacja parametr po parametrze.

### D.1. Kompletność zakresu zamówienia

<<Czy oferta obejmuje wszystkie części (A + B + C lub inne); czy nie ma oferty częściowej, gdy niedopuszczalna.>>

### D.2. Część A — <<nazwa>>

#### A.1 <<pkt OPZ>>

- **Wymóg:** `[DOC: OPZ] [A.1]` — <<parametr min.>>
- **Oferowane:** <<parametr>>
- **Źródło w ofercie:** `[DOC: <<plik>>] [str.]`
- **Zgodność:** ✅/⚠️/❌ <<komentarz>>

#### A.2 <<pkt OPZ>>

<<...>>

### D.3. Część B — <<nazwa>>

<<Analogicznie>>

### D.4. Część C — <<nazwa>>

<<Analogicznie>>

### D.5. Uwzględnienie modyfikacji SWZ

| Pismo | Zakres zmiany | Status uwzględnienia | Dowód |
|-------|---------------|----------------------|-------|
| <<data>> | <<...>> | ✅/⚠️/❌ | <<plik:str>> |

### D.6. Deklaracje równoważności (art. 99 ust. 5 Pzp)

<<Jeśli wykonawca oferuje rozwiązania równoważne — ocena prawidłowości wykazania równoważności.>>

---

## E. Elementy szczególnie istotne

### E.1. Cena oferty (analiza rażąco niska)

<<Porównanie z wartością szacunkową zamówienia i średnią arytmetyczną pozostałych ofert. Próg z art. 224 Pzp.>>

### E.2. Gwarancja

<<Zgodność z zakresem + podstawa punktacji.>>

### E.3. Termin realizacji

<<Zgodność z SWZ + ew. dostosowanie do modyfikacji.>>

### E.4. Przedmiotowe środki dowodowe

<<Pełna lista + ocena każdego.>>

### E.5. JEDZ

<<Kompletność, format, podpis.>>

### E.6. Sankcje (Zał. 9, Zał. 10)

<<Zakres podmiotowy: wykonawca, podwykonawca, dostawca >10%, podmiot trzeci. Czy pokryto wszystkie.>>

### E.7. Poleganie na zasobach (art. 118 Pzp)

<<Zobowiązanie + JEDZ podmiotu 3 + Zał. 10 — komplementarność.>>

### E.8. Warunki udziału w postępowaniu

<<Doświadczenie, zdolność techniczna, zdolność zawodowa — ocena wstępna na podstawie JEDZ; pełna ocena po wezwaniu do złożenia Zał. 4, 5.>>

### E.9. Sygnatury, nazwy, dane identyfikacyjne

<<Ewentualne błędy w dokumentach zamawiającego vs. dokumenty wykonawcy.>>

### E.10. Tajemnica przedsiębiorstwa

<<Zakres zastrzeżenia + ocena skuteczności.>>

---

## F. Ocena pod kątem ryzyka odrzucenia lub wezwania

> Pełna klasyfikacja: [[05-ocena-ryzyka-<<slug-wykonawcy>>]]

| Kategoria | Liczba znalezisk | Charakter |
|-----------|------------------|-----------|
| F1 — Brak nieistotny | <<N>> | Informacyjnie |
| F2 — Wada uzupełnialna | <<N>> | Wezwanie (art. 107 ust. 2 / 128 ust. 1) |
| F3 — Wymagające wyjaśnień | <<N>> | Wezwanie (art. 223 / 224) |
| F4 — Niezgodność treści | <<N>> | Odrzucenie (art. 226 ust. 1 pkt 5) |
| F5 — Podstawa odrzucenia | <<N>> | Odrzucenie / wykluczenie |
| F6 — Do analizy prawnej | <<N>> | Pogłębiona ocena |

---

## G. Spójność z ogłoszeniem o zamówieniu i modyfikacjami

### G.1. Ogłoszenie o zamówieniu (TED)

<<Czy oferta jest zgodna z ogłoszeniem — kryteria oceny, warunki udziału, CPV, termin.>>

### G.2. Ogłoszenia o zmianie ogłoszenia (sprostowania TED)

<<Chronologicznie — czy wykonawca uwzględnił wszystkie.>>

### G.3. Pisma z wyjaśnieniami i modyfikacjami SWZ

<<Pełna lista pism + status uwzględnienia przez wykonawcę.>>

### G.4. Rozbieżności

<<Jeśli istnieją — wskaż, która wersja jest wiążąca, czy wykonawca zastosował właściwą, jaki jest wpływ.>>

---

## Podsumowanie analizy szczegółowej

> [!<<success|warning|failure|danger|quote>>] Wniosek z analizy szczegółowej
> <<Zwięzłe podsumowanie: ile sekcji A–G spełnionych, gdzie główne ryzyka, czy oferta nadaje się do wyboru / wymaga uzupełnień / wymaga odrzucenia.>>

## Powiązania

- [[01-raport-glowny-<<slug-wykonawcy>>]]
- [[02-tabela-kontrolna-<<slug-wykonawcy>>]]
- [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>]]
- [[05-ocena-ryzyka-<<slug-wykonawcy>>]]
- [[06-cytaty-i-zrodla-<<slug-wykonawcy>>]]
