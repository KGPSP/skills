---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa postępowania>>"
zamawiajacy: <<nazwa zamawiającego>>
wykonawca: <<nazwa wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email autora>>
typ_dokumentu: index-umowa
status: <<draft | final>>
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/index/umowa
---

# Index projektu umowy — <<sygnatura>>

> [!info] Zasady wypełnienia
> - Każdy paragraf projektu umowy MUSI mieć wpis z tytułem + jednozdaniowym streszczeniem
> - Dla każdego załącznika: czy wymieniony w treści umowy + czy fizycznie dołączony do przekazanego materiału
> - Odnotuj liczby paragrafów, ustępów, punktów — porównaj z numeracją (luki / duplikaty to P1)

## Metryka pliku projektu umowy

| Pole | Wartość |
|------|---------|
| **Nazwa pliku** | <<plik.docx>> |
| **Wersja dokumentu** | <<data utworzenia z właściwości / wersja z nagłówka>> |
| **Liczba stron** | <<N>> |
| **Liczba paragrafów** | <<N>> |
| **Liczba załączników** | <<N>> |
| **Data podana w treści umowy** | <<data lub „___________ r." jeśli pusta>> |
| **Miejscowość podana w treści umowy** | <<...>> |
| **Sygnatura podana w treści** | <<...>> |
| **Forma (pisemna / elektroniczna)** | <<...>> |

## Rozkład paragrafów

| § | Tytuł paragrafu | Streszczenie (1-2 zdania) | Odesłania zewnętrzne (do SWZ/OPZ/oferty/załączników) | Obserwacje wstępne |
|---|-----------------|---------------------------|-------------------------------------------------------|---------------------|
| § 1 | <<np. „Definicje">> | <<streszczenie>> | <<SWZ, Zał. X>> | <<ewentualne red flag-i>> |
| § 2 | <<np. „Przedmiot umowy">> | <<...>> | <<OPZ, oferta>> | <<...>> |
| § 3 | <<...>> | <<...>> | <<...>> | <<...>> |
| … | … | … | … | … |

## Wykaz załączników do umowy (wg treści umowy)

| Nr | Nazwa załącznika (wg umowy) | Gdzie w umowie wskazany (§ / ust.) | Czy fizycznie obecny w przekazanym materiale | Nazwa pliku załącznika | Uwagi |
|----|------------------------------|-------------------------------------|-----------------------------------------------|-------------------------|-------|
| 1 | <<np. „OPZ">> | <<§ 2 ust. 1>> | <<tak / nie / częściowo>> | <<Zał-1-OPZ.pdf>> | <<...>> |
| 2 | <<np. „Formularz ofertowy">> | <<§ 1 pkt 3>> | <<...>> | <<...>> | <<...>> |
| 3 | <<np. „Harmonogram">> | <<§ 4 ust. 2>> | <<...>> | <<...>> | <<...>> |
| … | … | … | … | … | … |

> [!warning] Red flag — brakujące załączniki
> Jeśli w kolumnie „Czy fizycznie obecny" pojawia się `nie` albo `częściowo` — **zapytaj usera PRZED Phase 2**. Nie zakładaj, że „pewnie są". To kandydat na P1/P7 + R1/R2 w raporcie.

## Spójność numeracji

| Sprawdzenie | Wynik |
|-------------|-------|
| Paragrafy numerowane ciągle (§ 1, § 2, …) bez luk | <<tak / nie — opisać>> |
| Ustępy w każdym paragrafie numerowane od 1 | <<...>> |
| Punkty w ustępach numerowane od 1 | <<...>> |
| Litery w punktach (a, b, c) bez luk | <<...>> |
| Odesłania wewnętrzne (np. „zgodnie z § 5 ust. 2") — sprawdzenie istnienia celu | <<wszystkie działają / X odesłań do nieistniejących pozycji>> |
| Numeracja załączników w treści ↔ wykaz | <<zgodne / rozbieżne: …>> |

## Tabele / specyfikacje wewnątrz umowy

Jeśli umowa zawiera tabele ze stawkami, terminami, parametrami:

| Tabela | Lokalizacja (§) | Zawartość | Spójność z ofertą/OPZ |
|--------|-----------------|-----------|------------------------|
| <<np. „Tabela stawek">> | <<§ 6 ust. 3>> | <<streszczenie>> | <<zgodne / rozbieżne (szczegóły)>> |

## Kluczowe parametry umowy — szybki ekstrakt

| Parametr | Wartość w umowie | Źródło (§) | Wartość w ofercie / SWZ | Zgodność |
|----------|------------------|------------|--------------------------|----------|
| Wynagrodzenie (brutto) | <<X zł>> | <<§>> | <<X zł>> | ✅/⚠️/❌ |
| Wynagrodzenie (netto) | <<X zł>> | <<§>> | <<X zł>> | ✅/⚠️/❌ |
| Stawka VAT | <<X%>> | <<§>> | <<X%>> | ✅/⚠️/❌ |
| Termin wykonania | <<data / okres>> | <<§>> | <<data / okres>> | ✅/⚠️/❌ |
| Okres gwarancji | <<N miesięcy>> | <<§>> | <<N miesięcy>> | ✅/⚠️/❌ |
| Okres rękojmi | <<N miesięcy>> | <<§>> | <<N miesięcy>> | ✅/⚠️/❌ |
| Zabezpieczenie NWU | <<X% / X zł>> | <<§>> | <<X% / X zł>> | ✅/⚠️/❌ |
| Czas reakcji SLA | <<X godz.>> | <<§>> | <<X godz.>> | ✅/⚠️/❌ |
| Cap kar umownych | <<X% / X zł>> | <<§>> | — | <<obecne / brak>> |
| Waloryzacja (art. 439 Pzp) | <<obecna / brak>> | <<§>> | — | <<zgodnie / brak — wymagana dla > 6 m-cy>> |

## Początkowa checklista formalna

- [ ] Zamawiający: poprawna nazwa, adres, NIP, REGON, osoba reprezentująca, podstawa umocowania
- [ ] Wykonawca: poprawna nazwa, adres, NIP, REGON, KRS, osoba reprezentująca, podstawa umocowania (z KRS / pełnomocnictwa z oferty)
- [ ] Preambuła / zawiadomienie — wskazanie art. Pzp, numeru postępowania, daty publikacji ogłoszenia
- [ ] Definicje — obecność rozdziału / paragrafu
- [ ] Przedmiot umowy — wskazanie OPZ jako integralnej części
- [ ] Termin wykonania — obecność (art. 436 pkt 2 Pzp)
- [ ] Warunki zmiany umowy — obecność (art. 436 pkt 3 + art. 454–455 Pzp)
- [ ] Warunki płatności — obecność (art. 436 pkt 4 Pzp)
- [ ] Zabezpieczenie NWU — obecność, jeśli SWZ przewiduje (art. 449–453 Pzp — rozdz. 2)
- [ ] Klauzula waloryzacji — obecność dla umów > 6 m-cy (art. 436 pkt 6, art. 439 Pzp)
- [ ] Odstąpienie — obecność katalogu zgodnego z art. 456 Pzp
- [ ] Poufność / RODO — obecność, jeśli dotyczy
- [ ] Prawa autorskie / licencje — obecność, jeśli dotyczy (IT / projekty)
- [ ] Podpisy stron — wskazanie miejsca na podpisy obu stron
- [ ] Egzemplarze — wskazanie liczby egzemplarzy (2 / w formie elektronicznej)
- [ ] Data i miejscowość — obecność (może być do uzupełnienia)
- [ ] Wykaz załączników — obecność i zgodność z odwołaniami w treści

## Powiązania

- [[index-dokumentacja-postepowania]]
- [[01-raport-glowny-<<slug-sygnatury>>]]
- [[05-proponowane-poprawki-<<slug-sygnatury>>]]
