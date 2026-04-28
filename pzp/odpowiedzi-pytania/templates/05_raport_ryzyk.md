---
sygnatura_postepowania: <<sygnatura>>
postepowanie: "<<krótka nazwa>>"
zamawiajacy: <<np. Komenda Główna Państwowej Straży Pożarnej>>
data_wyjasnien: <<RRRR-MM-DD>>
typ_dokumentu: raport-ryzyk
status: draft
autor: claude@kg.straz.gov.pl
poziom_ryzyka_ogolny: <<niskie | średnie | wysokie>>
liczba_ryzyk_wysokich: <<N>>
liczba_ryzyk_srednich: <<N>>
liczba_ryzyk_niskich: <<N>>
tags:
  - pzp/wyjasnienia
  - pzp/sygnatura/<<sygnatura w slug>>
  - pzp/etap/raport-ryzyk
---

> [!info] Raport ryzyk
> Identyfikacja ryzyk prawnych, proceduralnych, technicznych i odwoławczych wynikających z odpowiedzi na pytania wykonawców + sposób ograniczenia. Dokument **wewnętrzny** — dla kierownika zamawiającego, komisji przetargowej, radcy prawnego. Powiązane: [[02_analiza_hipotez]], [[03_odpowiedzi_dla_wykonawcow]], [[04_zmiany_dokumentacji]], [[06_wersja_do_akceptacji]].

# Raport ryzyk — `<<sygnatura>>`

**Tura wyjaśnień:** <<N>>
**Data:** <<RRRR-MM-DD>>
**Poziom ryzyka ogólny:** <<niskie | średnie | wysokie>>

## Macierz ryzyk

| # | Kategoria | Pytanie | Opis ryzyka | Prawdopodobieństwo | Skutek | Poziom | Sposób ograniczenia |
| --- | --- | --- | --- | --- | --- | --- | --- |
| R1 | <<prawne \| proceduralne \| techniczne \| odwoławcze>> | Q<<N>> | <<opis>> | <<niskie \| średnie \| wysokie>> | <<niski \| średni \| wysoki>> | <<wynik macierzy>> | <<działanie>> |

### Kategorie ryzyk

- **Prawne:** sprzeczność z ustawą Pzp, regulaminem KG PSP, sankcjami międzynarodowymi.
- **Proceduralne:** niedotrzymanie terminu z art. 135/284, błąd publikacji, naruszenie pisemności (art. 20).
- **Techniczne:** wątpliwa wykonalność, niezgodność z architekturą SOiA / EZD / KSC, niemożliwość integracji.
- **Odwoławcze:** ryzyko skutecznego odwołania do KIO + skutek dla harmonogramu postępowania.

---

## R1 — <<krótka nazwa, np. „Sprzeczność z wcześniejszą turą Q&A">>

**Kategoria:** <<prawne / proceduralne / techniczne / odwoławcze>>
**Pytanie:** Q<<N>> — <<obszar>>
**Prawdopodobieństwo:** <<niskie | średnie | wysokie>>
**Skutek:** <<niski | średni | wysoki>> (np. unieważnienie postępowania, odwołanie KIO, konieczność powtórzenia czynności)
**Poziom ryzyka:** <<wynik macierzy>>

### Opis

<<2–4 zdania opisu ryzyka z odesłaniem do faktów: która odpowiedź / która zmiana / dlaczego problematyczne>>

### Sposób ograniczenia

1. <<działanie 1 — np. „weryfikacja przez radcę prawnego przed publikacją">>
2. <<działanie 2 — np. „dodanie sprostowania w `03_odpowiedzi_dla_wykonawcow.md`">>
3. <<działanie 3 — np. „przedłużenie terminu składania ofert o 7 dni">>

### Decyzja Zamawiającego (do akceptacji)

- [ ] Akceptacja sposobu ograniczenia (kierownik zamawiającego)
- [ ] Wykonanie czynności (komisja przetargowa)
- [ ] Weryfikacja prawna (Biuro Prawne)

---

## R2 — <<…>>

<!-- powtórz dla każdego ryzyka -->

---

## Ryzyka systemowe (niezwiązane z konkretnym pytaniem)

### S1 — Niezgodność opisów technicznych z OPZ

<<jeżeli wykryto>>

### S2 — Niespójność terminologii

<<jeżeli wykryto — np. różne nazwy systemu w SWZ / OPZ / umowie>>

### S3 — Brak klauzuli waloryzacyjnej (art. 439 Pzp)

<<jeżeli umowa > 6 m-cy a klauzuli brak>>

### S4 — Niedopuszczenie równoważności (art. 99 ust. 5–6 Pzp)

<<jeżeli OPZ powołuje znak towarowy bez „lub równoważne">>

### S5 — Termin zapłaty przekraczający 30 dni (art. 433 pkt 1 Pzp)

<<jeżeli umowa przewiduje termin > 30 dni>>

### S6 — Nieproporcjonalne kary umowne (art. 433 pkt 2 Pzp)

<<jeżeli kara > 10–15% wartości>>

### S7 — Nieproporcjonalne warunki udziału (art. 112 ust. 1 Pzp)

<<jeżeli warunki istotnie ograniczają konkurencję>>

---

## Spójność z wcześniejszymi turami Q&A

| Sprzeczność | Wcześniejsza odpowiedź | Bieżąca odpowiedź | Sposób rozwiązania |
| --- | --- | --- | --- |
| <<opis>> | <<plik + numer pytania>> | <<plik + numer pytania>> | <<sprostowanie / ujednolicenie / podtrzymanie>> |

## Eskalacje wymagane

### Do kierownika zamawiającego

- [ ] R<<N>> — <<krótki opis decyzji>>

### Do radcy prawnego

- [ ] R<<N>> — <<obszar wymagający opinii>>

### Do eksperta technicznego

- [ ] R<<N>> — <<obszar wymagający opinii>>

## Plan działań naprawczych

| # | Działanie | Termin | Odpowiedzialny | Status |
| --- | --- | --- | --- | --- |
| 1 | <<np. „Weryfikacja prawna odpowiedzi nr Q07">> | <<RRRR-MM-DD>> | <<np. radca prawny>> | <<otwarte | w toku | zamknięte>> |

## Rekomendacja końcowa Zamawiającego

> [!important] **Rekomendacja:** <<publikować bez zmian | publikować po wprowadzeniu poprawek z R1, R3 | wstrzymać publikację do akceptacji kierownika | wstrzymać do opinii radcy prawnego>>

**Uzasadnienie:**

<<3–5 zdań — synteza ryzyk i zalecanego działania>>
