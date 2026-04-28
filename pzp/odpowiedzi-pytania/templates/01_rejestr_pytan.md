---
sygnatura_postepowania: <<sygnatura>>
postepowanie: "<<krótka nazwa>>"
zamawiajacy: <<np. Komenda Główna Państwowej Straży Pożarnej>>
data_wyjasnien: <<RRRR-MM-DD>>
typ_dokumentu: rejestr-pytan
status: draft
autor: claude@kg.straz.gov.pl
liczba_pytan: <<N>>
liczba_pytan_z_decyzja_zamawiajacego: <<N>>
liczba_pytan_z_konsultacja_techniczna: <<N>>
liczba_pytan_z_konsultacja_prawna: <<N>>
tags:
  - pzp/wyjasnienia
  - pzp/sygnatura/<<sygnatura w slug>>
  - pzp/etap/rejestr-pytan
---

> [!info] Rejestr pytań wykonawców
> Roboczy rejestr pytań w postępowaniu `<<sygnatura>>` z bieżącej tury wyjaśnień. Dokument **wewnętrzny** (zawiera nazwy wykonawców). Powiązane: [[00_indeks_dokumentow]], [[02_analiza_hipotez]], [[03_odpowiedzi_dla_wykonawcow]].

# Rejestr pytań — `<<sygnatura>>`

**Tura wyjaśnień:** <<numer tury, np. tura 2>>
**Data przygotowania:** <<RRRR-MM-DD>>
**Liczba pytań:** <<N>>

## Tabela pytań

| Nr | Wykonawca | Plik źródłowy | Obszar | Dokument | Wymaga zmiany? | Status |
| --- | --- | --- | --- | --- | --- | --- |
| Q01 | <<nazwa | „nieujawniony">> | `<<plik źródłowy>>` | <<kod obszaru>> | <<TAK \| NIE \| ZALEŻY>> | <<status>> |
| Q02 | … | … | … | … | … | … |

### Kody obszarów (słownik kontrolowany)

`OPZ-parametr` · `OPZ-rownowaznosc` · `SWZ-tresc` · `SWZ-formalne` · `umowa-PPU` · `kryteria-oceny` · `warunki-udzialu` · `przedmiotowe-sd` · `podmiotowe-sd` · `wykluczenie` · `termin-skladania` · `termin-realizacji` · `odbiory-SLA` · `licencje` · `integracja` · `cyber-KSC` · `inne`

### Statusy

- `odpowiedź przygotowana` — gotowe do akceptacji
- `wymaga decyzji Zamawiającego` — komisja przetargowa / kierownik
- `wymaga konsultacji technicznej` — ekspert techniczny
- `wymaga konsultacji prawnej` — radca prawny / Biuro Prawne

## Statystyki bieżącej tury

| Metryka | Wartość |
| --- | --- |
| Liczba pytań ogółem | <<N>> |
| Liczba pytań z dokumentacją do zmiany | <<N>> |
| Liczba pytań wymagających decyzji Zamawiającego | <<N>> |
| Liczba pytań wymagających konsultacji technicznej | <<N>> |
| Liczba pytań wymagających konsultacji prawnej | <<N>> |
| Pytania o termin składania ofert | <<N>> |
| Pytania o termin realizacji | <<N>> |
| Pytania o równoważność | <<N>> |
| Pytania o umowę | <<N>> |
| Pytania o warunki udziału | <<N>> |

## Pytania zgrupowane wg obszaru

### OPZ-parametr (<<N>>)
- Q01, Q02, …

### OPZ-rownowaznosc (<<N>>)
- Q03, Q07, …

### umowa-PPU (<<N>>)
- Q12, Q13, Q14, …

<!-- itd. dla każdego obszaru -->

## Anonimizacja w wersji publikowanej

> [!important] Pole „Wykonawca" w tym pliku służy **wyłącznie do celów wewnętrznych** (komisja przetargowa, kierownik). W `03_odpowiedzi_dla_wykonawcow.md` (wersja publikowana) **nigdy nie ujawniaj** wykonawcy. Stosuj wyłącznie numerację: „Pytanie nr Q01" lub „Pytanie nr 1".

## Zgodność z wcześniejszymi turami

| Pytanie | Powiązanie z wcześniejszą odpowiedzią | Wymaga sprostowania? |
| --- | --- | --- |
| Q07 | „Odpowiedź na pytanie 18 z dnia 14.04.2026 dot. ofert częściowych" | <<TAK \| NIE — uzasadnienie>> |

## Pytania, na które Zamawiający nie ma obowiązku odpowiedzieć

> [!info] Zgodnie z art. 135 ust. 5 / art. 284 ust. 4 Pzp Zamawiający nie ma obowiązku udzielać wyjaśnień ani przedłużać terminu, gdy wniosek wpłynął po terminie z odpowiednio art. 135 ust. 2 / art. 284 ust. 2. Mimo to — zaleca się odpowiedź dla zachowania zasady równego traktowania wykonawców (art. 16 pkt 1 Pzp).

| Pytanie | Data wpływu | Termin ustawowy | Decyzja Zamawiającego |
| --- | --- | --- | --- |
| <<np. Q23>> | <<RRRR-MM-DD>> | <<RRRR-MM-DD>> | <<odpowiada \| nie odpowiada — uzasadnienie>> |
