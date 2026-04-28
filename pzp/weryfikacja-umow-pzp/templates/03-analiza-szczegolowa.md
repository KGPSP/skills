---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa postępowania>>"
zamawiajacy: <<nazwa zamawiającego>>
wykonawca: <<nazwa wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email autora>>
typ_dokumentu: analiza-szczegolowa
status: <<draft | final>>
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/analiza-szczegolowa
---

# Analiza szczegółowa projektu umowy — <<sygnatura>>

> [!info] Struktura
> Dokument omawia kolejno **15 obszarów** zgodnie z promptem weryfikacyjnym (sekcja C formatu odpowiedzi). Dla każdego obszaru: podsumowanie stanu + lista ustaleń + znaleziska z referencjami do [[05-proponowane-poprawki-<<slug-sygnatury>>]].

---

## 1. Strony i reprezentacja

### 1.1. Zamawiający

- **Nazwa:** <<literalny cytat z umowy>>
- **Adres:** <<...>>
- **NIP / REGON:** <<...>>
- **Osoba reprezentująca:** <<...>>
- **Podstawa umocowania:** <<np. „na podstawie upoważnienia Komendanta Głównego PSP nr ___ z dn. ___">>

**Ocena:** ✅ / ⚠️ / ❌

**Cytaty kluczowe:**
- `[§ 1 umowy / preambuła]` — „<<cytat>>"

**Znaleziska:** <<lista lub „brak">>

### 1.2. Wykonawca

- **Nazwa:** <<cytat>>
- **Adres:** <<...>>
- **NIP / REGON / KRS:** <<...>>
- **Osoba reprezentująca:** <<...>>
- **Podstawa umocowania:** <<KRS / pełnomocnictwo z oferty>>

**Porównanie z ofertą:**
- Dane w ofercie (formularz ofertowy): `[DOC: <<plik>>] [str. <<N>>]` — „<<cytat>>"
- Zgodność: ✅ / ⚠️ / ❌

**Ocena:** ✅ / ⚠️ / ❌

**Znaleziska:** <<lista>>

### 1.3. Preambuła i podstawa działania

- Wskazanie trybu postępowania: <<jest / brak / niepełne>>
- Wskazanie sygnatury sprawy: <<jest / brak>>
- Wskazanie dokumentów stanowiących integralną część umowy (SWZ, OPZ, oferta): <<...>>
- Wskazanie podstawy prawnej (Pzp): <<...>>

---

## 2. Definicje

### 2.1. Obecność i kompletność

- Paragraf „Definicje": <<§ N / brak>>
- Liczba zdefiniowanych terminów: <<N>>
- Terminy, które powinny być zdefiniowane, ale nie są: <<lista>>
- Terminy zdefiniowane, ale nieużywane dalej: <<lista>>

### 2.2. Konsekwencja stosowania

| Termin zdefiniowany | Użycie w dalszych postanowieniach | Zgodność |
|---------------------|-----------------------------------|----------|
| <<np. „Protokół odbioru">> | <<§ 5, § 8, § 11 — zgodne>> | ✅ |
| <<np. „Wada istotna">> | <<§ 8 ust. 3 — brak definicji, ale używane>> | ❌ |

**Ocena:** ✅ / ⚠️ / ❌

**Znaleziska:** [[05-proponowane-poprawki-<<slug>>#P-XXX]] — <<opis>>

---

## 3. Przedmiot umowy

### 3.1. Zakres rzeczowy

- **Zapis w umowie:** `[§ N ust. M]` — „<<cytat>>"
- **Zapis w OPZ:** `[DOC: OPZ.pdf] [Rozdz. N] [str. M]` — „<<cytat>>"
- **Porównanie:** ✅ / ⚠️ / ❌ <<komentarz: czy zakres umowy odpowiada OPZ; czy coś zostało dodane / pominięte>>

### 3.2. Zgodność z ofertą

- Oferta deklaruje: <<cytat>>
- Umowa stanowi: <<cytat>>
- Zgodność: ✅ / ⚠️ / ❌

### 3.3. Obligatoryjny wskaźnik integralności OPZ

- Czy umowa wskazuje OPZ jako integralną część?
- Czy są odesłania do OPZ w miejscach, gdzie powinny być (np. „zgodnie z OPZ")?

**Ocena:** ✅ / ⚠️ / ❌

**Znaleziska:** <<lista>>

---

## 4. Obowiązki stron

### 4.1. Obowiązki wykonawcy

Lista obowiązków z umowy (§):

1. <<§ N — cytat skrócony>>
2. <<...>>
3. <<...>>

**Ocena kompletności:** <<czy wszystkie obowiązki z SWZ/OPZ są odzwierciedlone; czy nic nie zostało dodane ponad dokumentację>>

**Ocena wykonalności / egzekwowalności:** <<czy każdy obowiązek ma: (a) termin, (b) miarę spełnienia, (c) konsekwencję braku spełnienia>>

### 4.2. Obowiązki zamawiającego

Lista obowiązków z umowy (§):

1. <<§ N — cytat>>
2. <<...>>

**Ocena koordynacji z obowiązkami wykonawcy:** <<np. obowiązek zamawiającego do akceptacji harmonogramu w terminie 7 dni → obowiązek wykonawcy do przedłożenia harmonogramu>>

### 4.3. Wzajemna koordynacja

| Obowiązek wykonawcy | Odpowiadający obowiązek / działanie zamawiającego | Koordynacja |
|---------------------|----------------------------------------------------|-------------|
| Przedłożenie harmonogramu w 14 dni | Akceptacja w 7 dni (?) | ✅/⚠️/❌ |
| Przedstawienie wyników testów | Zwolnienie płatności | ✅/⚠️/❌ |
| <<...>> | <<...>> | <<...>> |

**Znaleziska:** <<lista>>

---

## 5. Terminy i harmonogram

### 5.1. Termin wykonania

- **Zapis w umowie:** `[§ N]` — „<<cytat>>"
- **Zapis w ofercie:** `[DOC: Oferta.pdf] [str. N]` — „<<cytat>>"
- **Zapis w SWZ:** `[DOC: SWZ.pdf] [Rozdz. N]` — „<<cytat>>"
- **Zapis w harmonogramie:** `[DOC: Harmonogram.xlsx]` — „<<cytat>>"
- **Zgodność:** ✅ / ⚠️ / ❌

### 5.2. Etapy / kamienie milowe

| Etap | Zakres | Termin | Źródło w umowie | Zgodność z harmonogramem |
|------|--------|--------|-------------------|----------------------------|
| Etap 1 | <<...>> | <<...>> | <<§ N>> | <<...>> |
| Etap 2 | <<...>> | <<...>> | <<§ N>> | <<...>> |

### 5.3. Termin umowy vs. art. 434–435 Pzp

- Umowa na <<okres>> miesięcy: <<≤ 4 lat / > 4 lat>>
- Uzasadnienie (jeśli > 4 lat): <<...>>
- Ocena: ✅ / ⚠️ / ❌

### 5.4. Dzień wejścia w życie / dzień zawarcia

- Zapis: `[§ N]` — „<<cytat>>"
- Jasność i jednoznaczność: <<...>>

**Znaleziska:** <<lista>>

---

## 6. Odbiory

### 6.1. Rodzaje odbiorów

- **Odbiór częściowy:** <<§ N, jeśli występuje>>
- **Odbiór końcowy:** <<§ N>>
- **Odbiór gwarancyjny / pogwarancyjny:** <<§ N, jeśli występuje>>

### 6.2. Procedura odbioru

- **Zgłoszenie gotowości:** <<...>>
- **Termin na wyznaczenie odbioru:** <<...>>
- **Komisja odbiorowa:** <<skład, procedura>>
- **Dokumenty wymagane do odbioru:** <<lista z umowy>>
- **Protokół odbioru:** <<zapis dot. treści, podpisywania, przechowywania>>

### 6.3. Odmowa odbioru / odbiór warunkowy / odbiór z zastrzeżeniami

- **Zapis:** `[§ N ust. M]` — „<<cytat>>"
- **Kryteria odmowy:** <<...>>
- **Procedura usuwania wad:** <<terminy, ponowny odbiór>>
- **Spójność:** czy nie ma sprzeczności między „odmową" a „odbiorem z zastrzeżeniami"?

### 6.4. Spójność z procedurami w załącznikach

| Dokument | Procedura odbioru | Spójność z umową |
|----------|-------------------|------------------|
| OPZ | <<cytat>> | ✅/⚠️/❌ |
| Załącznik odbiorowy | <<cytat>> | ✅/⚠️/❌ |

**Znaleziska:** <<lista>>

---

## 7. Wynagrodzenie i płatności

### 7.1. Wysokość wynagrodzenia

- **Brutto (umowa):** <<kwota>>
- **Netto (umowa):** <<kwota>>
- **VAT (umowa):** <<kwota>>
- **Arytmetyka:** <<zgodna / rozbieżność X zł>>
- **Zgodność z ofertą:** ✅ / ⚠️ / ❌

### 7.2. Model rozliczeń

- **Ryczałt / obmiar / jednostkowy / mieszany:** <<...>>
- **Zgodność z modelem z SWZ / oferty:** <<...>>

### 7.3. Płatności częściowe

- **Obecność:** <<tak / nie>>
- **Zgodność z art. 443 Pzp (dla dostaw/usług > 12 m-cy):** <<obligatoryjne / nie dotyczy>> — wynagrodzenie w częściach LUB zaliczka; ostatnia część ≤ 50% wynagrodzenia (ust. 2); zaliczka ≥ 5% wynagrodzenia (ust. 3)
- **Zgodność z art. 447 Pzp (dla robót budowlanych > 12 m-cy):** <<obligatoryjne / nie dotyczy>> — dodatkowo: warunkiem zapłaty drugiej i następnych części jest przedstawienie dowodów zapłaty podwykonawcom (art. 464 ust. 1)
- **Procent płatności częściowych z całości wynagrodzenia:** <<np. 4 x 25% + 1 x retencja 5%>>
- **Powiązanie z etapami / kamieniami milowymi:** <<...>>

### 7.4. Termin zapłaty

- **Zapis:** `[§ N]` — „<<cytat, np. „30 dni od dnia otrzymania prawidłowo wystawionej faktury">>"
- **Zgodność z ustawą o terminach zapłaty (art. 8 ust. 2):** ✅ / ⚠️ / ❌
- **Precyzyjność zasad płatności (podstawa: art. 353¹ k.c. + art. 8 ust. 2 ustawy z 08.03.2013 r. o przeciwdziałaniu nadmiernym opóźnieniom w transakcjach handlowych — Dz.U. 2023 poz. 711):** czy terminy są precyzyjne (liczbowo, nie „niezwłocznie"), jasne podstawy wystawienia faktury, dokumenty wymagane, osoby akceptujące ✅ / ⚠️ / ❌ — *uwaga: nie jest to naruszenie art. 433 pkt 4, który dotyczy ograniczenia zakresu zamówienia bez wskazania minimum*

### 7.5. Faktura VAT

- **Procedura wystawiania:** <<...>>
- **Adresat:** <<...>>
- **E-faktura / faktura papierowa:** <<...>>
- **Podstawa wystawienia** (np. „po podpisaniu protokołu odbioru końcowego"): <<...>>

### 7.6. Waloryzacja (art. 439 Pzp)

<!-- Agent wybiera callout: [!success] gdy waloryzacja obecna i prawidłowa; [!warning] gdy niekompletna; [!danger] gdy brak dla umowy > 6 m-cy -->
> [!warning] Waloryzacja — obligatoryjna dla umów > 6 m-cy (art. 439 Pzp)
> Art. 439 ust. 1 Pzp: „Umowa, której przedmiotem są roboty budowlane, dostawy lub usługi, zawarta na okres dłuższy niż 6 miesięcy, zawiera postanowienia dotyczące zasad wprowadzania zmian wysokości wynagrodzenia należnego wykonawcy w przypadku zmiany ceny materiałów lub kosztów związanych z realizacją zamówienia."

- **Czy umowa > 6 m-cy?:** <<tak / nie>>
- **Czy klauzula waloryzacyjna obecna?:** <<tak / nie>>
- **Wskaźnik waloryzacji:** <<np. GUS wskaźnik cen produkcji budowlano-montażowej>>
- **Częstotliwość:** <<raz na N m-cy>>
- **Cap (górna granica zmiany):** <<X% wynagrodzenia>>
- **Ocena:** ✅ / ⚠️ / ❌ <<komentarz>>

### 7.7. Zaliczki (jeśli dotyczą)

- <<obecne / nie dotyczy>>

### 7.8. Zabezpieczenie NWU (art. 449–453 Pzp — rozdział 2)

- **Wysokość:** <<X% / X zł>>
- **Limit (art. 452 ust. 2):** <<≤ 5% ceny całkowitej z oferty / wyjątkowo ≤ 10% — art. 452 ust. 3, z uzasadnieniem w SWZ>>: ✅ / ⚠️ / ❌
- **Forma (art. 450 ust. 1 — wybór wykonawcy):** <<pieniądz / poręczenie bankowe lub SKOK / gwarancja bankowa / gwarancja ubezp. / poręczenie PARP>> (+ art. 450 ust. 2 za zgodą zamawiającego: weksel z poręczeniem, zastaw na p.w. SP/JST, zastaw rejestrowy)
- **Moment wniesienia (art. 449 ust. 3):** <<przed zawarciem umowy / inny termin określony w SWZ>>
- **Zasady zwrotu (art. 453):** <<70% w terminie 30 dni od uznania za należycie wykonane (ust. 1); ≤ 30% pozostawione na rękojmię/gwarancję (ust. 2); zwrot tej kwoty nie później niż 15. dzień po upływie rękojmi/gwarancji (ust. 3)>>
- **Potrącenia z należności (art. 452 ust. 4-7, dla umów > 1 rok):** <<stosowane / nie dotyczy>>
- **Zgodność z SWZ:** ✅ / ⚠️ / ❌

**Znaleziska:** <<lista>>

---

## 8. Kary umowne i odpowiedzialność

### 8.1. Katalog kar umownych

| # | Zdarzenie wyzwalające | Stawka | Cap pojedynczej kary | Uwagi |
|---|------------------------|--------|-----------------------|-------|
| 1 | <<...>> | <<X% / X zł>> | <<X%>> | <<...>> |
| 2 | <<...>> | <<...>> | <<...>> | <<...>> |

### 8.2. Łączny cap kar umownych

- **Obecny:** <<X% wynagrodzenia brutto / X zł / brak>>
- **Rekomendowany:** <<np. 20-30% wynagrodzenia brutto>>
- **Ocena:** ✅ / ⚠️ / ❌

### 8.3. Analiza pod kątem klauzul niedopuszczalnych (art. 433 Pzp — 4 pkt)

> [!warning] Obligatoryjna weryfikacja
> Literalne brzmienie: „Projektowane postanowienia umowy nie mogą przewidywać" (art. 433 Pzp).

- **Art. 433 pkt 1 (odpowiedzialność wykonawcy za opóźnienie — z warunkiem „chyba że jest to uzasadnione okolicznościami lub zakresem zamówienia"):** <<czy kary za opóźnienie mają obiektywne uzasadnienie; czy wyłączają: siłę wyższą, działania/zaniechania zamawiającego, błędy w dokumentacji zamawiającego>>
- **Art. 433 pkt 2 (kary umowne za zachowanie niezwiązane bezpośrednio lub pośrednio z przedmiotem umowy/prawidłowym wykonaniem):** <<czy kary obejmują wyłącznie naruszenia zobowiązań kontraktowych, nie naruszenia polityk wewnętrznych zamawiającego spoza umowy>>
- **Art. 433 pkt 3 (odpowiedzialność wykonawcy za okoliczności, za które wyłączną odpowiedzialność ponosi zamawiający):** <<czy umowa nie przerzuca na wykonawcę ryzyka: błędów w dokumentacji zamawiającego, opóźnień w akceptacji ze strony zamawiającego, zmian w wymaganiach zamawiającego>>
- **Art. 433 pkt 4 (ograniczenie zakresu zamówienia bez wskazania minimum):** <<czy nie ma klauzul „zamawiający zastrzega prawo rezygnacji z części" lub „zmniejszenie zakresu do …% bez odszkodowania" bez wskazania gwarantowanego minimum>>

**Oddzielnie (nie art. 433):**
- **Rażąca dysproporcja kar umownych** — podstawa: art. 484 § 2 k.c. (miarkowanie); art. 58 § 2 k.c. (zasady współżycia społecznego); art. 353¹ k.c.
- **Niejasne terminy płatności** — podstawa: art. 353¹ k.c. + art. 8 ust. 2 ustawy z 08.03.2013 r. o przeciwdziałaniu nadmiernym opóźnieniom w transakcjach handlowych (Dz.U. 2023 poz. 711)

**Wnioski:** <<...>>

### 8.4. Zasada naliczania i potrącania

- **Sposób naliczania:** <<...>>
- **Potrącenie z wynagrodzenia:** <<zapis obecny / brak>>
- **Podstawa wezwania do zapłaty:** <<...>>
- **Procedura:** <<...>>

### 8.5. Relacja kara umowna — odszkodowanie

- **Zapis:** <<„kary nie wyczerpują roszczeń" / „kary wyczerpują roszczenia" / brak>>
- **Zgodność z art. 484 § 1 k.c.:** ✅ / ⚠️ / ❌

### 8.6. Odpowiedzialność wykonawcy vs. zamawiającego

- **Symetryczność:** <<tak / nie>>
- **Odsetki ustawowe za zwłokę w płatności:** <<klauzula obecna / brak — jeśli brak to stosuje się ustawa z 08.03.2013 r. bez potrzeby zapisu w umowie, ale warto>>

**Znaleziska:** <<lista>>

---

## 9. Gwarancja / rękojmia / SLA / serwis

### 9.1. Gwarancja

- **Okres:** <<N m-cy>>
- **Zgodność z ofertą:** ✅ / ⚠️ / ❌
- **Zakres:** <<...>>
- **Procedura zgłaszania wad:** <<...>>
- **Termin usunięcia wady:** <<...>>
- **Przedłużenie gwarancji w razie usunięcia wady:** <<klauzula obecna / brak>>

### 9.2. Rękojmia (art. 559–563 k.c.)

- **Okres:** <<standardowo 2 lata / wydłużony>>
- **Relacja do gwarancji:** <<...>>
- **Wyłączenia:** <<...>>

### 9.3. SLA (Service Level Agreement) — dla umów serwisowych / utrzymaniowych

- **Czasy reakcji:** <<...>>
- **Czasy naprawy:** <<...>>
- **Kary za naruszenie SLA:** <<...>>
- **Dostępność (%):** <<...>>
- **Zgodność z ofertą / OPZ:** ✅ / ⚠️ / ❌

### 9.4. Serwis / wsparcie

- **Zakres:** <<...>>
- **Sposób zgłaszania:** <<...>>
- **Godziny dostępności:** <<...>>

**Znaleziska:** <<lista>>

---

## 10. Poufność / RODO / bezpieczeństwo

### 10.1. Poufność / tajemnica przedsiębiorstwa

- **Zakres:** <<...>>
- **Okres obowiązywania:** <<...>>
- **Wyjątki:** <<...>>

### 10.2. RODO — umowa powierzenia (art. 28 RODO)

<!-- Agent wybiera callout: [!success] gdy umowa powierzenia obecna i kompletna; [!warning] gdy niekompletna; [!danger] gdy dotyczy i brakuje -->
> [!warning] RODO — umowa powierzenia art. 28
> Jeżeli umowa wiąże się z przetwarzaniem danych osobowych — umowa powierzenia art. 28 RODO jest OBLIGATORYJNA.

- **Czy dotyczy:** <<tak / nie>>
- **Jeśli dotyczy — czy umowa powierzenia jest załącznikiem / integralną częścią:** <<...>>
- **Elementy art. 28 ust. 3 RODO — weryfikacja:**
  - [ ] przedmiot, czas, charakter i cel przetwarzania
  - [ ] rodzaj danych i kategorie osób
  - [ ] prawa i obowiązki administratora
  - [ ] subpowierzenie za zgodą
  - [ ] TOM (art. 32 RODO)
  - [ ] wsparcie przy wnioskach osób (art. 12–22 RODO)
  - [ ] zwrot / usunięcie danych
  - [ ] audyty

### 10.3. Cyberbezpieczeństwo (KSC) — dla zamówień ICT

- **Czy dotyczy:** <<tak / nie>>
- **Art. 33 ust. 4 KSC (rekomendacje):** <<...>>
- **Art. 67b KSC (dostawcy wysokiego ryzyka):** <<...>>
- **TOM:** <<...>>
- **Obowiązek zgłaszania incydentów:** <<...>>
- **Prawo audytu zamawiającego:** <<...>>

**Znaleziska:** <<lista>>

---

## 11. Prawa autorskie / licencje (jeśli dotyczy)

### 11.1. Charakter umowy

- **IT / projektowa / badawcza / dostawy sprzętu bez oprogramowania:** <<...>>
- **Czy dotyczą prawa autorskie:** <<tak / nie>>

### 11.2. Przeniesienie / licencja (art. 41 pr.aut.)

- **Model:** <<przeniesienie / licencja wyłączna / licencja niewyłączna>>
- **Moment przejścia praw:** <<np. „z chwilą odbioru i zapłaty">>

### 11.3. Pola eksploatacji (art. 50 pr.aut.)

- **Lista pól eksploatacji:** <<...>>
- **Kompletność (wszystkie potrzebne):** ✅ / ⚠️ / ❌
- **Precyzyjność (nie „wszystkie możliwe"):** ✅ / ⚠️ / ❌

### 11.4. Programy komputerowe (art. 74 pr.aut.)

- **Specyfika:** <<...>>

### 11.5. Utwory zależne / prawa zezwalania

- **Zapis:** <<...>>

### 11.6. Sublicencja

- **Czy zamawiający może udzielać sublicencji (np. jednostkom PSP):** <<...>>

**Znaleziska:** <<lista>>

---

## 12. Zmiany umowy

### 12.1. Podstawa prawna katalogu zmian

- **Zapis w umowie:** `[§ N]` — „<<cytat>>"
- **Zgodność z art. 454–455 Pzp:** ✅ / ⚠️ / ❌

### 12.2. Katalog dopuszczalnych zmian

| Przesłanka | Podstawa (art. 455 Pzp) | Zapis w umowie | Zgodność |
|------------|--------------------------|----------------|----------|
| Zmiany przewidziane w SWZ | ust. 1 pkt 1 | <<cytat>> | ✅/⚠️/❌ |
| Dodatkowe dostawy/usługi/roboty | ust. 1 pkt 2 | <<cytat>> | ✅/⚠️/❌ |
| Okoliczności, których zam. nie mógł przewidzieć | ust. 1 pkt 3 | <<cytat>> | ✅/⚠️/❌ |
| Zmiana wykonawcy z obiektywnej przyczyny | ust. 1 pkt 4 | <<cytat>> | ✅/⚠️/❌ |
| Łączna wartość zmian ≤ 10%/15% | ust. 2 | <<cytat>> | ✅/⚠️/❌ |

### 12.3. Klauzule rozszerzające ponad katalog

- **Obecność niedozwolonych przesłanek:** <<np. „zmiana z ważnych powodów" bez konkretyzacji — NIEDOPUSZCZALNE>>

### 12.4. Waloryzacja (art. 439 Pzp) — jako osobna kategoria

- Odrębna od katalogu zmian; nie wchodzi w limity 10/15%
- Zapis: <<...>>

### 12.5. Procedura zmiany

- Forma (pisemna pod rygorem nieważności): ✅ / ⚠️ / ❌
- Wniosek (kto składa, treść, termin rozpatrzenia): <<...>>
- Aneks: <<...>>

**Znaleziska:** <<lista>>

---

## 13. Odstąpienie / rozwiązanie / wypowiedzenie

### 13.1. Odstąpienie ustawowe (art. 456 Pzp)

> [!important] Literalne brzmienie
> Art. 456 ust. 1 Pzp (tekst jednolity Dz.U. 2024 poz. 1320) — zamawiający może odstąpić od umowy TYLKO w przesłankach wymienionych poniżej. **Upadłość / likwidacja wykonawcy NIE jest ustawową przesłanką** z art. 456 Pzp (może być tylko umowną przesłanką odstąpienia, o ile umowa to przewiduje).

| Przesłanka | Art. 456 Pzp | Zapis w umowie |
|------------|--------------|----------------|
| Istotna zmiana okoliczności, której nie można było przewidzieć — wykonanie umowy nie leży w interesie publicznym lub zagraża bezpieczeństwu państwa/publicznemu (termin 30 dni od powzięcia wiadomości) | **ust. 1 pkt 1** | <<cytat>> |
| Zmiana umowy dokonana z naruszeniem art. 454 i art. 455 | **ust. 1 pkt 2 lit. a** | <<cytat>> |
| Wykonawca w chwili zawarcia umowy podlegał wykluczeniu na podstawie art. 108 | **ust. 1 pkt 2 lit. b** | <<cytat>> |
| TSUE stwierdził, że RP uchybiła zobowiązaniom z Traktatów UE / dyrektyw 2014/24/UE, 2014/25/UE, 2009/81/WE | **ust. 1 pkt 2 lit. c** | <<cytat>> |

**Rozliczenie — art. 456 ust. 3:** „wykonawca może żądać wyłącznie wynagrodzenia należnego z tytułu wykonania części umowy".

### 13.2. Odstąpienie umowne (dodatkowe)

- Lista przesłanek umownych: <<...>>
- Czy nie obchodzą zasad zamówień publicznych: <<...>>

### 13.3. Termin na złożenie oświadczenia

- **Zapis:** `[§ N]` — „<<cytat>>"
- **Zgodność z art. 456 ust. 2 Pzp:** ✅ / ⚠️ / ❌

### 13.4. Skutki odstąpienia

- Rozliczenie wykonanej pracy
- Zwrot zabezpieczenia
- Kary umowne za odstąpienie

### 13.5. Wypowiedzenie

- Czy obecne: <<tak / nie>>
- Przesłanki: <<...>>

**Znaleziska:** <<lista>>

---

## 14. Załączniki

### 14.1. Lista załączników w umowie

| Nr | Nazwa w umowie | Fizycznie obecny w materiale | Plik | Zgodność nazw |
|----|----------------|------------------------------|------|----------------|
| 1 | <<...>> | <<tak/nie>> | <<...>> | ✅/⚠️/❌ |
| 2 | <<...>> | <<...>> | <<...>> | <<...>> |

### 14.2. Załączniki wskazane w treści umowy (grep)

- Wszystkie odesłania do „Załącznik nr X" zgodne z wykazem: <<tak / rozbieżności>>
- Załączniki wymagane przez SWZ, ale nieobecne w umowie: <<...>>

### 14.3. Kluczowe załączniki

- **OPZ:** <<obecny / brak>>
- **Formularz ofertowy (oferta):** <<obecny / brak>>
- **Harmonogram:** <<obecny / brak / przewidziany do uzgodnienia po zawarciu>>
- **Umowa powierzenia (RODO):** <<...>>
- **Wykaz podwykonawców:** <<...>>
- **Wzory protokołów odbioru:** <<...>>

**Znaleziska:** <<lista>>

---

## 15. Zgodność z SWZ, OPZ, ofertą i innymi dokumentami postępowania

> Pełna analiza korelacji: [[04-macierz-korelacji-<<slug-sygnatury>>]]

### 15.1. Zgodność z PPU (Wzór umowy — Załącznik do SWZ)

- **Wersja wiążąca PPU:** <<po wszystkich modyfikacjach SWZ>>
- **Rozbieżności vs. projekt umowy:** <<...>>
- **Ocena:** <<zgodne / rozbieżne w X paragrafach — wymaga uzasadnienia>>

### 15.2. Zgodność z SWZ (pozostałe rozdziały)

- **Rozdział „Zabezpieczenie":** ✅ / ⚠️ / ❌
- **Rozdział „Zmiany umowy":** ✅ / ⚠️ / ❌
- **Rozdział „Warunki realizacji":** ✅ / ⚠️ / ❌

### 15.3. Zgodność z OPZ

- **Zakres rzeczowy:** ✅ / ⚠️ / ❌
- **Parametry techniczne:** ✅ / ⚠️ / ❌
- **Procedury odbioru:** ✅ / ⚠️ / ❌

### 15.4. Zgodność z ofertą

| Element | Oferta | Umowa | Zgodność |
|---------|--------|-------|----------|
| Cena brutto | <<...>> | <<...>> | ✅/⚠️/❌ |
| Okres gwarancji | <<...>> | <<...>> | ✅/⚠️/❌ |
| Termin wykonania | <<...>> | <<...>> | ✅/⚠️/❌ |
| Podwykonawcy | <<...>> | <<...>> | ✅/⚠️/❌ |
| Parametry punktowane | <<...>> | <<...>> | ✅/⚠️/❌ |

### 15.5. Zgodność z odpowiedziami na pytania wykonawców

| Pismo | Zakres modyfikacji | Uwzględnienie w projekcie umowy | Dowód |
|-------|---------------------|-----------------------------------|-------|
| <<...>> | <<...>> | ✅/⚠️/❌ | <<§ umowy>> |

### 15.6. Zgodność z harmonogramem

- Daty etapów: <<...>>

**Znaleziska:** <<lista>>

---

## Podsumowanie analizy szczegółowej

<!-- Agent wybiera callout: [!success]/[!warning]/[!danger] -->
> [!warning] Wniosek z analizy szczegółowej
> <<Zwięzłe podsumowanie: ile obszarów z 15 ocenionych jako ✅, ⚠️, ❌; gdzie główne ryzyka; czy projekt umowy jest gotowy do podpisu.>>

| Obszar | Ocena | Główne znaleziska |
|--------|-------|--------------------|
| 1. Strony i reprezentacja | ✅/⚠️/❌ | <<...>> |
| 2. Definicje | ✅/⚠️/❌ | <<...>> |
| 3. Przedmiot umowy | ✅/⚠️/❌ | <<...>> |
| 4. Obowiązki stron | ✅/⚠️/❌ | <<...>> |
| 5. Terminy i harmonogram | ✅/⚠️/❌ | <<...>> |
| 6. Odbiory | ✅/⚠️/❌ | <<...>> |
| 7. Wynagrodzenie i płatności | ✅/⚠️/❌ | <<...>> |
| 8. Kary umowne i odpowiedzialność | ✅/⚠️/❌ | <<...>> |
| 9. Gwarancja / rękojmia / SLA | ✅/⚠️/❌ | <<...>> |
| 10. Poufność / RODO / bezpieczeństwo | ✅/⚠️/❌ | <<...>> |
| 11. Prawa autorskie / licencje | ✅/⚠️/❌/⬜ | <<...>> |
| 12. Zmiany umowy | ✅/⚠️/❌ | <<...>> |
| 13. Odstąpienie | ✅/⚠️/❌ | <<...>> |
| 14. Załączniki | ✅/⚠️/❌ | <<...>> |
| 15. Zgodność z dok. post. | ✅/⚠️/❌ | <<...>> |

## Powiązania

- [[01-raport-glowny-<<slug-sygnatury>>]]
- [[02-tabela-ustalen-krytycznych-<<slug-sygnatury>>]]
- [[04-macierz-korelacji-<<slug-sygnatury>>]]
- [[05-proponowane-poprawki-<<slug-sygnatury>>]]
- [[06-ocena-ryzyk-<<slug-sygnatury>>]]
