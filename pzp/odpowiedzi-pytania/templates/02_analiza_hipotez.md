---
sygnatura_postepowania: <<sygnatura>>
postepowanie: "<<krótka nazwa>>"
zamawiajacy: <<np. Komenda Główna Państwowej Straży Pożarnej>>
data_wyjasnien: <<RRRR-MM-DD>>
typ_dokumentu: analiza-hipotez
status: draft
autor: claude@kg.straz.gov.pl
liczba_pytan_analizowanych: <<N>>
prog_unijny: <<tak | nie>>
podstawa_prawna_terminu:
  - "art. <<135 | 284>> ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
tags:
  - pzp/wyjasnienia
  - pzp/sygnatura/<<sygnatura w slug>>
  - pzp/etap/analiza-hipotez
---

> [!info] Analiza w modelu trzech hipotez
> Roboczy dokument analityczny **dla komisji przetargowej**. Per pytanie: trzy hipotezy odpowiedzi (negatywna / pozytywna / kompromisowa) z oceną skutków prawnych, dla konkurencyjności, dla spójności dokumentacji, ryzyka odwoławczego, wpływu na termin składania ofert + rekomendacja Zamawiającego. Powiązane: [[01_rejestr_pytan]], [[03_odpowiedzi_dla_wykonawcow]], [[04_zmiany_dokumentacji]].

# Analiza w modelu 3 hipotez — `<<sygnatura>>`

**Tura wyjaśnień:** <<numer>>
**Liczba pytań:** <<N>>

> [!important] Metodyka analizy 3 hipotez per obszar pytania — zob. `references/workflow-3-hipotez.md` w skillu `odpowiedzi-pytania`. Przed analizą pytań niestandardowych przeczytaj odpowiednią sekcję.

---

## Pytanie nr Q01

**Wykonawca:** <<nazwa | „nieujawniony">>
**Plik źródłowy:** `<<plik>>`
**Obszar:** <<kod obszaru>>
**Dokument(y), których dotyczy:** <<np. OPZ pkt A.1, projekt umowy § 5>>
**Powiązanie z wcześniejszymi turami:** <<np. „brak" | „spójne z odp. nr 18 z 14.04.2026" | „rozbieżne — wymaga sprostowania">>

### Treść pytania

> <<pełna, dosłowna treść pytania wykonawcy z bloku cytatu>>

### Cytaty referencyjne

**SWZ / OPZ / Umowa (cytat dosłowny + lokalizacja):**

> „<<cytat>>" `[DOC: <<plik>>] [<<lokalizacja>>] [str. <<N>>]`

**Podstawa prawna w ustawie Pzp (artykuł + krótkie streszczenie):**

> art. <<N>> ust. <<N>> ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.) — <<co stanowi>>.

### Hipoteza 1 — odpowiedź negatywna, bez zmiany dokumentacji

| Kryterium | Ocena |
| --- | --- |
| Skutki prawne | <<analiza>> |
| Skutki dla konkurencyjności | <<analiza>> |
| Skutki dla spójności dokumentacji | <<analiza>> |
| Ryzyko odwoławcze | <<niskie \| średnie \| wysokie>> — <<uzasadnienie>> |
| Wpływ na termin składania ofert | <<brak \| wymaga przedłużenia>> |
| Wymaga zmiany dokumentacji | <<NIE>> |

### Hipoteza 2 — odpowiedź pozytywna, ze zmianą dokumentacji

| Kryterium | Ocena |
| --- | --- |
| Skutki prawne | <<analiza>> |
| Skutki dla konkurencyjności | <<analiza>> |
| Skutki dla spójności dokumentacji | <<analiza>> |
| Ryzyko odwoławcze | <<niskie \| średnie \| wysokie>> |
| Wpływ na termin składania ofert | <<brak \| wymaga obligatoryjnego przedłużenia o czas niezbędny (art. 137 ust. 6 / art. 286 ust. 3) — w praktyce 6–14 dni>> |
| Wymaga zmiany dokumentacji | <<TAK — SWZ \| OPZ \| umowa \| ogłoszenie>> |

### Hipoteza 3 — odpowiedź kompromisowa (warunkowo / przez doprecyzowanie)

| Kryterium | Ocena |
| --- | --- |
| Skutki prawne | <<analiza>> |
| Skutki dla konkurencyjności | <<analiza>> |
| Skutki dla spójności dokumentacji | <<analiza>> |
| Ryzyko odwoławcze | <<niskie \| średnie \| wysokie>> |
| Wpływ na termin składania ofert | <<brak \| wymaga przedłużenia>> |
| Wymaga zmiany dokumentacji | <<TAK — doprecyzowanie OPZ pkt […]>> |

### Rekomendowane stanowisko

**Wybór:** <<H1 | H2 | H3>>

**Uzasadnienie (3–5 zdań):**

<<dlaczego ten wariant zabezpiecza interes Zamawiającego, utrzymuje konkurencyjność, zachowuje istotne wymagania jakościowe/bezpieczeństwa/funkcjonalne, jest spójny z dotychczasową dokumentacją, minimalizuje ryzyko skutecznego odwołania, nie powoduje niekontrolowanej zmiany charakteru zamówienia>>

**Status w rejestrze:** <<odpowiedź przygotowana | wymaga decyzji Zamawiającego | wymaga konsultacji technicznej | wymaga konsultacji prawnej>>

### Projekt odpowiedzi (do `03_odpowiedzi_dla_wykonawcow.md`)

> Zamawiający <<informuje | wyjaśnia | wskazuje | dopuszcza | nie dopuszcza | dokonuje zmiany | podtrzymuje zapisy>>, że <<treść odpowiedzi>>.

### Zakres zmian dokumentacji (jeżeli H2 lub H3)

→ przeniesione do `04_zmiany_dokumentacji.md` jako Zmiana #<<N>>.

---

## Pytanie nr Q02

<!-- powtórz strukturę dla każdego pytania -->

---

## Podsumowanie analiz

| Q | Obszar | Rekomendacja | Status | Zmiana dokumentacji |
| --- | --- | --- | --- | --- |
| Q01 | <<kod>> | <<H1 \| H2 \| H3>> | <<status>> | <<TAK/NIE — co>> |
| Q02 | … | … | … | … |

## Eskalacje

### Wymaga decyzji Zamawiającego (kierownik / komisja)

- Q<<N>> — <<krótki opis decyzji>>

### Wymaga konsultacji technicznej

- Q<<N>> — <<obszar wymagający opinii>>

### Wymaga konsultacji prawnej

- Q<<N>> — <<obszar prawny>>
