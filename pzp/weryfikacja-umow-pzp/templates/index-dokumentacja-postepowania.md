---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa postępowania>>"
zamawiajacy: <<nazwa zamawiającego>>
wykonawca: <<nazwa wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email autora>>
typ_dokumentu: index-dokumentacja-postepowania
status: <<draft | final>>
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/index/dokumentacja
---

# Index dokumentacji postępowania — <<sygnatura>>

> [!info] Zasady wypełnienia
> - Każdy plik w `<procurement_dir>` MUSI mieć wpis z co najmniej 2-3 zdaniami opisu
> - Uwzględnij pliki: ogłoszenie, SWZ, OPZ, PPU (Załącznik do SWZ z wzorem umowy), pisma z odpowiedziami i zmianami, oferta wybranego wykonawcy, harmonogram, załączniki techniczne
> - Pomijaj pliki techniczne typu `.XAdES`, `.sig` — odnotuj je osobno jako podpisy zewnętrzne
> - Chronologia pism z odpowiedziami jest **kluczowa** — modyfikacje późniejsze są nadrzędne

## Ogłoszenie o zamówieniu

| Pole | Wartość |
|------|---------|
| **Plik** | <<np. ogloszenie-TED-2026-XX.pdf>> |
| **Numer publikacji (TED / BZP)** | <<...>> |
| **Data publikacji** | <<yyyy-mm-dd>> |
| **Tryb postępowania** | <<przetarg nieograniczony / tryb podstawowy / negocjacje z ogłoszeniem / …>> |
| **Przedmiot zamówienia (tytuł)** | <<pełny tytuł>> |
| **CPV** | <<kody>> |
| **Wartość szacunkowa** | <<kwota netto, jeśli publiczna>> |
| **Liczba stron** | <<N>> |
| **Kluczowe postanowienia dla umowy** | <<np. „sekcja VI.3 — wskazuje na Załącznik nr 5 — PPU">> |

## SWZ (Specyfikacja Warunków Zamówienia)

| Pole | Wartość |
|------|---------|
| **Plik** | <<np. SWZ-v2-po-modyfikacji.pdf>> |
| **Wersja / data** | <<wersja 2 z dn. 15.03.2026>> |
| **Liczba stron** | <<N>> |
| **Liczba rozdziałów** | <<N>> |
| **Liczba załączników** | <<N>> |

### Rozkład rozdziałów SWZ (kluczowych dla umowy)

| Rozdział | Tytuł / zakres | Strony | Relacja do umowy |
|----------|----------------|--------|------------------|
| <<I>> | <<np. „Postanowienia ogólne">> | <<1-3>> | — |
| <<np. III>> | <<„Opis przedmiotu zamówienia">> | <<…>> | bezpośrednio → § „Przedmiot umowy" |
| <<np. V>> | <<„Warunki realizacji">> | <<…>> | bezpośrednio → § „Obowiązki wykonawcy" |
| <<np. XII>> | <<„Projekt umowy / wzór umowy">> | <<…>> | **to jest PPU!** |
| <<np. XIII>> | <<„Zabezpieczenie należytego wykonania">> | <<…>> | → § „Zabezpieczenie" |
| <<np. XIV>> | <<„Zmiany umowy">> | <<…>> | → § „Zmiany umowy" |

### Załączniki do SWZ

| Nr | Nazwa załącznika | Plik | Rola |
|----|------------------|------|------|
| <<1>> | <<np. „Formularz ofertowy">> | <<…>> | wypełniany przez wykonawcę |
| <<2>> | <<np. „OPZ">> | <<…>> | specyfikacja techniczna |
| <<np. 5>> | <<„Projekt umowy" / „Wzór umowy" / „PPU">> | <<…>> | **wersja wzorca umowy — do porównania z projektem umowy!** |
| <<np. 6>> | <<„Harmonogram">> | <<…>> | terminy etapów |
| <<...>> | <<...>> | <<...>> | <<...>> |

## OPZ (Opis Przedmiotu Zamówienia)

| Pole | Wartość |
|------|---------|
| **Plik** | <<OPZ-v2.pdf>> |
| **Wersja / data** | <<...>> |
| **Liczba stron** | <<N>> |
| **Części** | <<A, B, C / nie dzielony na części>> |
| **Kluczowe parametry dla umowy** | <<wymagania techniczne, okres gwarancji, SLA, procedury odbioru, harmonogram, etapy>> |

### Procedury odbiorowe w OPZ

| Dokument | Lokalizacja w OPZ | Powiązanie z umową |
|----------|-------------------|---------------------|
| Protokół odbioru częściowego | <<OPZ str.>> | <<§ umowy>> |
| Protokół odbioru końcowego | <<OPZ str.>> | <<§ umowy>> |
| Dokumentacja powykonawcza | <<OPZ str.>> | <<§ umowy>> |

## PPU (Projektowane Postanowienia Umowy) w wersji z SWZ

> [!info] Kluczowa relacja
> Projekt umowy przekazany do podpisu MUSI być zgodny z PPU z Załącznika do SWZ **w wersji po modyfikacjach** (po wszystkich pismach z odpowiedziami / zmianami SWZ). Wszelkie odstępstwa wymagają uzasadnienia.

| Pole | Wartość |
|------|---------|
| **Plik** | <<Załącznik-5-Wzór-umowy.pdf>> |
| **Wersja / data** | <<...>> |
| **Liczba stron** | <<N>> |
| **Liczba paragrafów** | <<N>> |
| **Kluczowe paragrafy** | <<§ 4 terminy, § 7 kary, § 9 zmiany, § 11 odstąpienie…>> |
| **Różnice vs. projekt umowy przekazany do podpisu** | <<zidentyfikowane w Phase 3>> |

## Pisma z odpowiedziami na pytania wykonawców + zmiany SWZ (chronologicznie)

| Lp. | Data | Plik | Zakres (czego dotyczy) | Czy modyfikuje PPU / umowę | Status odzwierciedlenia w projekcie umowy |
|-----|------|------|-------------------------|------------------------------|--------------------------------------------|
| 1 | <<yyyy-mm-dd>> | <<pismo-01.pdf>> | <<np. „zmiana terminu wykonania na 12 miesięcy">> | **tak** | <<do weryfikacji w Phase 3>> |
| 2 | <<...>> | <<...>> | <<...>> | <<tak/nie>> | <<...>> |
| … | … | … | … | … |

> [!danger] Red flag
> Jeśli **pismo modyfikuje PPU** i dotyczy elementu, który jest w projekcie umowy — sprawdź **literalnie**, czy zapis projektu umowy odzwierciedla wersję po modyfikacji. Typowa P7 + R1/R2.

## Oferta wybranego wykonawcy

| Pole | Wartość |
|------|---------|
| **Plik — formularz ofertowy** | <<Formularz-ofertowy-WASKO.pdf>> |
| **Plik — OPZ wypełniony** | <<...>> |
| **Plik — JEDZ** | <<...>> |
| **Plik — karta oceny parametrów punktowanych** | <<...>> |
| **Data oferty** | <<yyyy-mm-dd>> |
| **Cena oferty (brutto)** | <<X zł>> |
| **Cena oferty (netto)** | <<X zł>> |
| **VAT** | <<X%>> |
| **Okres gwarancji (oferowany)** | <<N miesięcy>> |
| **Termin wykonania (oferowany)** | <<data / liczba miesięcy>> |
| **Podwykonawcy (deklarowani w ofercie)** | <<lista lub „brak">> |

## Harmonogram (jeżeli odrębny załącznik)

| Pole | Wartość |
|------|---------|
| **Plik** | <<Harmonogram-v2.xlsx>> |
| **Wersja** | <<...>> |
| **Etapy** | <<liczba etapów, nazwy>> |
| **Kamienie milowe** | <<daty + opis>> |
| **Relacja do umowy** | <<§ „Etapy realizacji" / § „Terminy">> |

## Inne załączniki proceduralne / odbiorowe / techniczne

| Plik | Rola | Powiązanie z umową | Uwagi |
|------|------|---------------------|-------|
| <<...>> | <<...>> | <<...>> | <<...>> |

## Protokół wyboru oferty (jeśli dostępny)

| Pole | Wartość |
|------|---------|
| **Plik** | <<...>> |
| **Data wyboru** | <<yyyy-mm-dd>> |
| **Wybrany wykonawca** | <<...>> |
| **Punktacja** | <<...>> |

## Inne dokumenty

| Plik | Opis | Rola |
|------|------|------|
| <<.XAdES / .sig / .p7s>> | Podpis zewnętrzny do <<pliku>> | autentyczność |
| <<ZADANIE.md / notatki.md>> | Notatki usera — prompt pomocniczy (NIE źródło prawne) | kontekst analizy |

## Sprawdzenie kompletności

- [ ] Ogłoszenie obecne
- [ ] SWZ w najnowszej wersji (po ew. modyfikacjach)
- [ ] OPZ w najnowszej wersji
- [ ] Wszystkie załączniki do SWZ
- [ ] PPU (Załącznik „Wzór umowy" do SWZ)
- [ ] Wszystkie pisma z odpowiedziami i zmianami SWZ (chronologicznie)
- [ ] Oferta wybranego wykonawcy (formularz ofertowy + OPZ wypełniony + JEDZ)
- [ ] Harmonogram (jeśli odrębny)
- [ ] Protokół wyboru oferty (jeśli dostępny)

> [!warning] Jeśli którekolwiek z powyższych pozycji brak
> **Zapytaj usera** czy materiał pominięto, czy faktycznie nie istnieje. Nie zakładaj automatycznie.

## Powiązania

- [[index-umowa]]
- [[01-raport-glowny-<<slug-sygnatury>>]]
- [[04-macierz-korelacji-<<slug-sygnatury>>]]
