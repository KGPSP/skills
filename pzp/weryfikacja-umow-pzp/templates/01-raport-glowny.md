---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa postępowania>>"
zamawiajacy: <<nazwa zamawiającego>>
wykonawca: <<nazwa wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email autora>>
typ_dokumentu: raport-glowny
status: <<draft | final>>
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/raport-glowny
---

# Raport główny — weryfikacja projektu umowy

**Sygnatura postępowania:** <<sygnatura>>
**Postępowanie:** <<pełna nazwa>>
**Zamawiający:** <<Komenda Główna Państwowej Straży Pożarnej>>
**Wykonawca:** <<nazwa>>
**Projekt umowy — plik źródłowy:** <<plik>>
**Data analizy:** <<yyyy-mm-dd>>
**Autor analizy:** <<email>>
**Podstawa prawna analizy:** ustawa z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.); Kodeks cywilny; RODO; ustawa o krajowym systemie cyberbezpieczeństwa; ustawa o prawie autorskim i prawach pokrewnych.

---

## Wprowadzenie

Niniejszy raport stanowi wynik pogłębionej analizy formalnej, prawnej, redakcyjnej i operacyjnej projektu umowy przygotowanego na potrzeby postępowania o udzielenie zamówienia publicznego prowadzonego w trybie <<tryb>>. Analiza została przeprowadzona z perspektywy zamawiającego publicznego, w oparciu o dokumentację postępowania (SWZ, OPZ, PPU, oferta wykonawcy, pisma z odpowiedziami i zmianami SWZ) oraz ustawę Pzp wraz z aktami powiązanymi.

**Struktura raportu odpowiada wymaganemu formatowi odpowiedzi A–F:**
- **A. Ocena ogólna** (poniżej) + [[00-podsumowanie-wykonawcze-<<slug-sygnatury>>]]
- **B. Tabela ustaleń krytycznych:** [[02-tabela-ustalen-krytycznych-<<slug-sygnatury>>]]
- **C. Analiza szczegółowa (15 obszarów):** [[03-analiza-szczegolowa-<<slug-sygnatury>>]]
- **D. Macierz korelacji dokumentów:** [[04-macierz-korelacji-<<slug-sygnatury>>]]
- **E. Proponowane poprawki (cytat → cytat):** [[05-proponowane-poprawki-<<slug-sygnatury>>]]
- **F. Wnioski końcowe:** [[07-wnioski-koncowe-<<slug-sygnatury>>]]

Dodatkowe dokumenty pomocnicze:
- Indeks projektu umowy: [[index-umowa]]
- Indeks dokumentacji postępowania: [[index-dokumentacja-postepowania]]
- Ocena ryzyk kontraktowych: [[06-ocena-ryzyk-<<slug-sygnatury>>]]
- Register cytatów i źródeł: [[08-cytaty-i-zrodla-<<slug-sygnatury>>]]

---

## A. Ocena ogólna

### A.1. Ocena jakości projektu umowy

<<2-3 akapity — jakość redakcyjna, konstrukcja, stopień skomplikowania, podejście do zabezpieczenia interesu zamawiającego. Przykłady: „projekt umowy wykazuje dobrą strukturę, konsekwentnie stosuje terminologię z ustawy Pzp, ale…">>

### A.2. Ocena formalna

- **Struktura dokumentu:** <<poprawna / z błędami — opis>>
- **Numeracja:** <<ciągła / z lukami / z duplikatami>>
- **Odesłania wewnętrzne:** <<wszystkie poprawne / X błędnych>>
- **Spójność terminologii:** <<...>>
- **Kompletność definicji:** <<...>>
- **Dane formalne stron:** <<poprawne / z błędami>>
- **Wykaz załączników ↔ ich fizyczne istnienie:** <<...>>

### A.3. Ocena zgodności z dokumentacją postępowania

- **Projekt umowy ↔ PPU (Załącznik do SWZ po modyfikacjach):** <<zgodne / rozbieżne — X pozycji>>
- **Projekt umowy ↔ SWZ (rozdział o umowie):** <<...>>
- **Projekt umowy ↔ OPZ:** <<...>>
- **Projekt umowy ↔ oferta wykonawcy:** <<zgodne z deklarowanym terminem / ceną / gwarancją>>
- **Projekt umowy ↔ odpowiedzi na pytania i modyfikacje SWZ:** <<wszystkie uwzględnione / X nieuwzględnionych>>

Szczegóły: [[04-macierz-korelacji-<<slug-sygnatury>>]].

### A.4. Ocena spójności wewnętrznej

- **Definicje ↔ użycie:** <<...>>
- **Przedmiot ↔ obowiązki:** <<...>>
- **Terminy ↔ harmonogram ↔ odbiory ↔ płatności:** <<...>>
- **Kary ↔ obowiązki ↔ zdarzenia:** <<...>>
- **Gwarancja / rękojmia / SLA ↔ zakres świadczenia:** <<...>>

### A.5. Ocena zgodności z Pzp

| Zagadnienie | Podstawa prawna | Ocena |
|-------------|-----------------|-------|
| Klauzule abuzywne | art. 433 Pzp | <<brak naruszeń / wykryto — lista P-XXX>> |
| Obligatoryjne postanowienia umowy | art. 436 Pzp | <<wszystkie obecne / brak: …>> |
| Termin umowy | art. 434–435 Pzp | <<w granicach 4 lat / przekroczenie — analiza>> |
| Waloryzacja (umowy > 6 m-cy) | art. 439 Pzp | <<obecna / brak — R1>> |
| Zabezpieczenie NWU | art. 449–453 Pzp (rozdział 2; cap 5% = art. 452 ust. 2) | <<...>> |
| Katalog zmian umowy | art. 454–455 Pzp | <<...>> |
| Odstąpienie ustawowe (4 przesłanki) | art. 456 Pzp | <<...>> |
| Podwykonawstwo (ogólne) | art. 462–465 Pzp + art. 647¹ § 5 k.c. | <<...>> |
| Podwykonawstwo (obligatoryjne postanowienia dla RB) | art. 437 Pzp | <<7 pkt>> |
| Zaliczki | art. 442 Pzp | <<...>> |
| Płatności częściowe (umowy > 12 m-cy) | art. 443 Pzp (dostawy/usługi); art. 447 Pzp (RB) | <<...>> |

### A.6. Ocena zgodności z pozostałymi aktami

- **K.c. (art. 353¹, 483–484, 647–658):** <<...>>
- **RODO (art. 28, 32):** <<umowa powierzenia obecna / brak / niekompletna>>
- **Ustawa o prawie autorskim (art. 41, 50, 74):** <<dotyczy: tak/nie; ocena>>
- **KSC (art. 33 ust. 4, art. 67b):** <<dotyczy: tak/nie; ocena>>
- **Sankcje międzynarodowe:** <<obecność klauzuli odstąpienia, powiadomienia>>

### A.7. Ocena gotowości do podpisania

<!-- Agent wybiera callout wg wyniku: [!success]=TAK, [!warning]=WARUNKOWO, [!danger]=NIE -->
> [!warning] Rekomendacja
> <<TAK w obecnym brzmieniu / TAK po poprawkach R1 (lista) / NIE — wymaga przebudowy.>>

<<Uzasadnienie końcowe — dlaczego.>>

---

## B. Tabela ustaleń krytycznych (skrót)

Pełna tabela: [[02-tabela-ustalen-krytycznych-<<slug-sygnatury>>]].

W raporcie głównym cytujemy tylko R1 i R2:

| # | Jednostka | Opis problemu | Rodzaj | Ryzyko | Korekta |
|---|-----------|---------------|--------|--------|---------|
| 1 | <<§>> | <<...>> | <<P3>> | <<R1>> | [[05-proponowane-poprawki-<<slug>>#P-001]] |
| 2 | <<§>> | <<...>> | <<P7>> | <<R1>> | [[05-proponowane-poprawki-<<slug>>#P-002]] |
| … | … | … | … | … | … |

---

## C. Analiza szczegółowa — wprowadzenie

Pełna analiza 15 obszarów: [[03-analiza-szczegolowa-<<slug-sygnatury>>]].

Obszary analizowane kolejno:

1. Strony i reprezentacja
2. Definicje
3. Przedmiot umowy
4. Obowiązki stron
5. Terminy i harmonogram
6. Odbiory
7. Wynagrodzenie i płatności
8. Kary umowne i odpowiedzialność
9. Gwarancja / rękojmia / SLA / serwis
10. Poufność / RODO / bezpieczeństwo
11. Prawa autorskie / licencje (jeśli dotyczy)
12. Zmiany umowy
13. Odstąpienie / rozwiązanie / wypowiedzenie
14. Załączniki
15. Zgodność z dokumentami postępowania

---

## D. Macierz korelacji — wprowadzenie

Pełna macierz: [[04-macierz-korelacji-<<slug-sygnatury>>]].

Pokrywa zestawienia:

- Projekt umowy ↔ SWZ
- Projekt umowy ↔ OPZ
- Projekt umowy ↔ PPU (wersja po modyfikacjach)
- Projekt umowy ↔ oferta wykonawcy (cena / termin / gwarancja / parametry / podwykonawcy)
- Projekt umowy ↔ odpowiedzi na pytania i zmiany SWZ
- Projekt umowy ↔ harmonogram
- Projekt umowy ↔ załączniki techniczne / odbiorowe

---

## E. Proponowane poprawki — wprowadzenie

Lista: [[05-proponowane-poprawki-<<slug-sygnatury>>]].

Konwencja:

- Plik `05-proponowane-poprawki` jest **grupowany sekcjami wg poziomu ryzyka** (R1 → R2 → R3 → R4)
- Wewnątrz każdej grupy R-* poprawki są uszeregowane **wg kolejności paragrafów umowy** (§ 1 → § 15 → załączniki)
- Numeracja P-001, P-002, … jest **ciągła przez cały plik** (nie restartowana w sekcjach R)
- Każda poprawka: kategoria (P1–P7), poziom (R1–R4), cytat oryginału, cytat propozycji, uzasadnienie
- Proponowane brzmienie jest pełne i gotowe do wklejenia do umowy

---

## V. Ocena ryzyk kontraktowych — wprowadzenie

Pełna ocena: [[06-ocena-ryzyk-<<slug-sygnatury>>]].

Ryzyka grupowane wg kategorii:

1. Dla zamawiającego
2. Dla wykonawcy
3. Dla realizacji projektu
4. Dla odbioru
5. Dla rozliczenia
6. Dla dochodzenia roszczeń
7. Dla kontroli / audytu
8. Dla zgodności z zasadami zamówień publicznych

---

## F. Wnioski końcowe — wprowadzenie

Pełne odpowiedzi: [[07-wnioski-koncowe-<<slug-sygnatury>>]].

Pięć pytań:

1. Czy projekt umowy może zostać podpisany w obecnym brzmieniu?
2. Jakie poprawki są bezwzględnie konieczne przed podpisaniem?
3. Jakie poprawki są rekomendowane dla zwiększenia bezpieczeństwa zamawiającego?
4. Jakie ryzyka pozostaną nawet po korekcie?
5. Czy istnieją elementy wymagające pilnego ujednolicenia z dokumentacją postępowania?

---

## Podsumowanie raportu głównego

<!-- Agent wybiera callout wg konkluzji: [!success]/[!warning]/[!danger] -->
> [!warning] Wniosek końcowy raportu głównego
> <<Zwięzłe podsumowanie: ile poprawek R1 (obligatoryjne), ile R2 (silnie zalecane), jakie są główne obszary problemowe, czy umowa po wdrożeniu rekomendowanych poprawek będzie gotowa do podpisania.>>

## Powiązania

- [[index-umowa]]
- [[index-dokumentacja-postepowania]]
- [[00-podsumowanie-wykonawcze-<<slug-sygnatury>>]]
- [[02-tabela-ustalen-krytycznych-<<slug-sygnatury>>]]
- [[03-analiza-szczegolowa-<<slug-sygnatury>>]]
- [[04-macierz-korelacji-<<slug-sygnatury>>]]
- [[05-proponowane-poprawki-<<slug-sygnatury>>]]
- [[06-ocena-ryzyk-<<slug-sygnatury>>]]
- [[07-wnioski-koncowe-<<slug-sygnatury>>]]
- [[08-cytaty-i-zrodla-<<slug-sygnatury>>]]
