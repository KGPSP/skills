---
sygnatura_postepowania: <<sygnatura>>
postepowanie: "<<krótka nazwa>>"
zamawiajacy: <<np. Komenda Główna Państwowej Straży Pożarnej>>
data_wyjasnien: <<RRRR-MM-DD>>
typ_dokumentu: akceptacja
status: do-akceptacji
autor: claude@kg.straz.gov.pl
przygotowal: <<imię i nazwisko opracowującego — komisja przetargowa>>
do_akceptacji: <<imię i nazwisko kierownika zamawiającego>>
liczba_pytan: <<N>>
liczba_odpowiedzi_pozytywnych: <<N>>
liczba_odpowiedzi_negatywnych: <<N>>
liczba_odpowiedzi_kompromisowych: <<N>>
liczba_zmian_dokumentacji: <<N>>
wymaga_przedluzenia_terminu: <<tak | nie>>
nowy_termin_skladania: <<RRRR-MM-DD HH:MM | brak zmiany>>
poziom_ryzyka_ogolny: <<niskie | średnie | wysokie>>
tags:
  - pzp/wyjasnienia
  - pzp/sygnatura/<<sygnatura w slug>>
  - pzp/etap/akceptacja
---

> [!warning] Wersja do akceptacji
> Zbiorczy dokument decyzyjny dla **kierownika zamawiającego** / **komisji przetargowej**. Po akceptacji — `03_odpowiedzi_dla_wykonawcow.md` może zostać opublikowany na platformie zakupowej. Powiązane: [[01_rejestr_pytan]], [[02_analiza_hipotez]], [[03_odpowiedzi_dla_wykonawcow]], [[04_zmiany_dokumentacji]], [[05_raport_ryzyk]].

# Wersja do akceptacji — `<<sygnatura>>`

**Postępowanie:** <<krótka nazwa>>
**Sygnatura:** <<sygnatura>>
**Tura wyjaśnień:** <<N>>
**Data przygotowania:** <<RRRR-MM-DD>>
**Termin składania ofert:** <<RRRR-MM-DD HH:MM>>

## Streszczenie wykonawcze

| Metryka | Wartość |
| --- | --- |
| Liczba pytań w bieżącej turze | <<N>> |
| Liczba odpowiedzi przygotowanych | <<N>> |
| — w tym odpowiedzi pozytywnych (Zamawiający dopuszcza / dokonuje zmiany) | <<N>> |
| — w tym odpowiedzi negatywnych (Zamawiający nie dopuszcza / podtrzymuje zapisy) | <<N>> |
| — w tym odpowiedzi kompromisowych (warunkowo / przez doprecyzowanie) | <<N>> |
| Liczba odpowiedzi wymagających zmiany dokumentacji | <<N>> |
| Liczba zmian dokumentacji | <<N>> |
| — w SWZ | <<N>> |
| — w OPZ | <<N>> |
| — w projekcie umowy | <<N>> |
| — w ogłoszeniu | <<N>> |
| Wymaga przedłużenia terminu składania ofert | <<TAK | NIE>> |
| Nowy termin składania ofert (jeżeli zmiana) | <<RRRR-MM-DD HH:MM | brak zmiany>> |
| Wymaga zmiany ogłoszenia w BZP/TED | <<TAK | NIE>> |
| Poziom ryzyka ogólny | <<niskie | średnie | wysokie>> |

## Lista decyzji wymagających zatwierdzenia

> [!important] Każda pozycja na tej liście wymaga **wyraźnej akceptacji** kierownika zamawiającego przed publikacją wyjaśnień.

### D1 — <<krótka nazwa decyzji>>

**Pytanie:** Q<<N>> — <<obszar>>
**Decyzja do podjęcia:** <<np. „Czy Zamawiający dopuszcza zaoferowanie procesora Intel Xeon Gold 6442Y przy spełnieniu kryteriów równoważności (lista w pkt A.1.1 OPZ)?">>

**Rekomendacja zespołu przygotowującego:** <<TAK | NIE>>

**Uzasadnienie:** <<3–5 zdań>>

**Skutek dla dokumentacji:** <<np. „zmiana OPZ pkt A.1; dodanie pkt A.1.1 z kryteriami równoważności; przedłużenie terminu składania ofert o 6 dni">>

**Decyzja kierownika:**
- [ ] Akceptuję rekomendację
- [ ] Nie akceptuję — uzasadnienie: __________________________________
- [ ] Skieruj do dodatkowej opinii: <<radca prawny | ekspert techniczny | inny>>

---

### D2 — <<…>>

<!-- powtórz dla każdej decyzji -->

---

## Lista pytań eskalowanych

### Wymaga decyzji Zamawiającego (kierownik / komisja)

| Pytanie | Obszar | Decyzja do podjęcia |
| --- | --- | --- |
| Q<<N>> | <<obszar>> | <<krótki opis>> |

### Wymaga konsultacji prawnej

| Pytanie | Obszar | Powód eskalacji | Termin opinii |
| --- | --- | --- | --- |
| Q<<N>> | <<obszar>> | <<np. sankcje międzynarodowe — art. 5k rozp. 833/2014>> | <<RRRR-MM-DD>> |

### Wymaga konsultacji technicznej

| Pytanie | Obszar | Powód eskalacji | Termin opinii |
| --- | --- | --- | --- |
| Q<<N>> | <<obszar>> | <<np. integracja z EZD>> | <<RRRR-MM-DD>> |

## Termin składania ofert — rekomendacja

> [!warning] **Rekomendacja:** <<TAK — przedłużenie do <<RRRR-MM-DD>> | NIE — bez zmian>>

**Uzasadnienie:**

<<3–5 zdań — np. „Zmiana OPZ pkt A.1 (dopuszczenie równoważności procesora) poszerza krąg potencjalnych wykonawców i wymaga umożliwienia im przygotowania ofert na nowych warunkach. Zgodnie z art. 137 ust. 6 ustawy Pzp Zamawiający przedłuża termin składania ofert o czas niezbędny na zapoznanie się ze zmianą i przygotowanie oferty. Rekomendowana nowa data: 2026-05-15 godz. 12:00.">>

**Podstawa prawna:** <<art. 137 ust. <<N>> | art. 286 ust. <<N>> ustawy Pzp>>

**Decyzja kierownika:**
- [ ] Akceptuję przedłużenie do <<RRRR-MM-DD>> godz. <<HH:MM>>
- [ ] Nie akceptuję — utrzymanie pierwotnego terminu (<<RRRR-MM-DD>> godz. <<HH:MM>>)
- [ ] Inna data: <<RRRR-MM-DD>> godz. <<HH:MM>>

## Plik do publikacji

> [!info] Po akceptacji — następujący dokument zostaje opublikowany:

- **`03_odpowiedzi_dla_wykonawcow.md`** → docelowo `Wyjasnienia_SWZ_<<sygnatura>>_<<RRRR-MM-DD>>.docx` (do publikacji na platformie zakupowej)

Dodatkowo (jeżeli zmiana SWZ):

- **`Zmiana_SWZ_<<sygnatura>>_<<RRRR-MM-DD>>.docx`** — pełna treść zmiany z naniesionymi zmianami w SWZ
- **Komunikat o zmianie ogłoszenia** w BZP/TED (jeżeli dotyczy)

## Pliki załączone (robocze, do archiwum)

- [[00_indeks_dokumentow]] — indeks dokumentów postępowania
- [[01_rejestr_pytan]] — rejestr pytań (z ujawnioną nazwą wykonawców — wyłącznie dla potrzeb wewnętrznych)
- [[02_analiza_hipotez]] — analiza w modelu 3 hipotez
- [[03_odpowiedzi_dla_wykonawcow]] — finalne odpowiedzi (do publikacji)
- [[04_zmiany_dokumentacji]] — wykaz zmian
- [[05_raport_ryzyk]] — raport ryzyk

## Akceptacja

**Przygotował:**
<<imię i nazwisko, stanowisko>>
Data: <<RRRR-MM-DD>>
Podpis: ____________________________

**Zatwierdza komisja przetargowa:**
<<imię i nazwisko, funkcja w komisji>>
Data: <<RRRR-MM-DD>>
Podpis: ____________________________

**Akceptuje kierownik zamawiającego:**
<<imię i nazwisko, stanowisko>>
Data: <<RRRR-MM-DD>>
Podpis: ____________________________

---

## Klauzula audytowa

Dokumentacja postępowania zgodnie z art. 71–82 ustawy Pzp. Niniejsza wersja podlega archiwizacji w protokole postępowania na okres min. 4 lat od zakończenia postępowania (art. 78 ustawy Pzp).

Plik zachowywany w EZD KG PSP zgodnie z Regulaminem KG PSP (rozdz. 10–11).
