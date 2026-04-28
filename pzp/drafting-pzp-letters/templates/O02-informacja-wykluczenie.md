---
sygnatura_postepowania: <<np. BL-V.2371.3.2026>>
postepowanie: <<pełna nazwa postępowania z ogłoszenia>>
zamawiajacy: <<pełna nazwa zamawiającego>>
wykonawca: <<pełna nazwa wykonawcy z oferty>>
wykonawca_slug: <<slug-wykonawcy>>
adres_wykonawcy: <<ulica, kod pocztowy, miasto>>
typ_pisma: informacja-wykluczenie
kod_pisma: O02
podstawa_prawna:
  - "art. <<108 ust. 1 pkt X | 109 ust. 1 pkt X | 5k rozp. 833/2014 | 7 ust. 1 pkt X ustawy antyrosyjskiej>> oraz art. 226 ust. 1 pkt 2 lit. a ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
  - "art. 253 ust. 1 pkt 2 oraz ust. 2 ustawy Pzp (obowiązek informacyjny)"
znaleziska_powiazane:
  - <<np. Kx.y>>
podstawa_wykluczenia_art: "<<np. art. 108 ust. 1 pkt 1 lit. a Pzp>>"
self_cleaning_zweryfikowany: true  # OBOWIĄZKOWE sprawdzenie przed O02
self_cleaning_wynik: <<nie złożono | złożono — niewystarczający | złożono — wystarczający (w tym ostatnim przypadku: NIE generuj O02!)>>
sygnatura_pisma: <<np. BL-V.2371.3.2026.O02>>
data_pisma: <<YYYY-MM-DD>>
miejscowosc: Warszawa
autor: <<email autora analizy>>
signatory_stanowisko: <<np. Dyrektor Biura Informatyki i Łączności KG PSP>>
signatory_tytul: <<np. mł. bryg. mgr inż.>>
signatory_imie_nazwisko: <<np. Michał Kłosiński>>
signatory_zrodlo: <<memory | explicit>>
status: draft
poziom_pewnosci: <<wysoki | średni | niski>>
termin_odwolania_dni: <<10 dla procedury unijnej | 5 dla trybu podstawowego>>
tags:
  - pzp/pismo/wykluczenie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
  - pzp/kod/O02
---

# O02 — Informacja o wykluczeniu Wykonawcy i odrzuceniu oferty

> [!danger] Precondition check — PRZED WYSŁANIEM
> 1. **Self-cleaning (art. 110 Pzp) zweryfikowany obowiązkowo!** Self-cleaning dotyczy TYLKO: art. 108 ust. 1 pkt 1, 2, 5 oraz art. 109 ust. 1 pkt 2-5, 7-10. NIE dotyczy: art. 108 ust. 1 pkt 3, 4, 6, ust. 2 oraz art. 109 ust. 1 pkt 1, 6.
> 2. Jeśli Wykonawca przedstawił self-cleaning dla przesłanki objętej art. 110 — **eskalacja do F6, konsultacja prawnika, NIE generuj O02 automatycznie**.
> 3. Sprawdź okres wykluczenia (art. 111 Pzp) — czy podstawa wykluczenia jeszcze obowiązuje czasowo.
> 4. Dla sankcji międzynarodowych (art. 5k rozp. 833/2014, art. 7 ust. 1 ustawy antyrosyjskiej) — zweryfikuj aktualne listy sankcyjne (CRBR, Dziennik Urzędowy UE, polska lista MSWiA).

**Dane do szablonu DOCX:**

| Pole szablonu | Wartość |
|---------------|---------|
| `ezdSprawaZnak` | `<<sygnatura_pisma>>` |
| `ezdDataPodpisu` | `<<data_pisma>>` |
| `[adresat]` | **<<pełna nazwa wykonawcy>>**, <<adres>> |
| `ezdPracownikAtrybut1` | `<<signatory_stanowisko>>` |
| `ezdPracownikAtrybut2` | `<<signatory_tytul>>` |
| `ezdPracownikNazwa` | `<<signatory_imie_nazwisko>>` |

---

## Treść pisma

**Dotyczy:** postępowania o udzielenie zamówienia publicznego pn. „<<postepowanie>>", znak sprawy: **<<sygnatura_postepowania>>**.

### Wstęp

Działając na podstawie art. 253 ust. 1 pkt 2 oraz ust. 2 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.), zwanej dalej „ustawą Pzp", Zamawiający niniejszym **informuje Wykonawcę — <<pełna nazwa wykonawcy>> — o wykluczeniu z postępowania i odrzuceniu oferty** wraz z uzasadnieniem faktycznym i prawnym.

### Rozstrzygnięcie

Wykonawca **podlega wykluczeniu z postępowania** na podstawie <<art. 108 ust. 1 pkt X | art. 109 ust. 1 pkt X | art. 5k rozp. (UE) 833/2014 | art. 7 ust. 1 pkt X ustawy antyrosyjskiej z 13 kwietnia 2022 r.>>, a w konsekwencji oferta Wykonawcy **podlega odrzuceniu na podstawie art. 226 ust. 1 pkt 2 lit. a ustawy Pzp**.

### Uzasadnienie faktyczne

#### 1. Stan faktyczny uzasadniający wykluczenie

**Dokumenty i okoliczności:**

> [!quote]
> <<Literalny cytat z dokumentu potwierdzającego podstawę wykluczenia — np. wypisu z KRK, zaświadczenia z ZUS/US, decyzji administracyjnej, listy sankcyjnej, orzeczenia sądowego>>
> `[DOC: <<plik>>] [str. <<N>>]`

**Opis:** <<np.: „Z informacji z Krajowego Rejestru Karnego z dnia <<data>> wynika, że urzędujący członek organu zarządzającego Wykonawcy — <<imię, nazwisko, funkcja>> — został prawomocnie skazany za przestępstwo stypizowane w art. <<X k.k.>>, co odpowiada przesłance art. 108 ust. 1 pkt 2 ustawy Pzp.">>

#### 2. Self-cleaning (art. 110 Pzp)

<!-- Ten rozdział OBOWIĄZKOWY w O02, nawet gdy wykonawca nie skorzystał -->

<<OPCJA A — Wykonawca nie skorzystał z self-cleaning>>

W toku postępowania Wykonawca **nie przedstawił dowodów**, o których mowa w art. 110 ust. 2 ustawy Pzp, potwierdzających:
1) naprawienie lub zobowiązanie do naprawienia szkody wyrządzonej przestępstwem lub wykroczeniem,
2) wyczerpujące wyjaśnienie faktów i okoliczności związanych z przestępstwem lub wykroczeniem,
3) podjęcie konkretnych środków technicznych, organizacyjnych i kadrowych, zapobiegających dalszym przestępstwom lub wykroczeniom.

W konsekwencji Wykonawca nie wykazał przesłanki niepodlegania wykluczeniu na podstawie art. 110 ust. 2 ustawy Pzp. Wskazana w pkt 1 przesłanka wykluczenia obowiązuje bez ograniczeń.

<<OPCJA B — Wykonawca przedstawił self-cleaning niewystarczający>>

Wykonawca, w dokumencie z dnia <<data>>, przedstawił dowody, o których mowa w art. 110 ust. 2 ustawy Pzp. Zamawiający ocenił te dowody w kontekście wagi i szczególnych okoliczności czynu Wykonawcy (art. 110 ust. 3 ustawy Pzp) i uznał je za niewystarczające z następujących powodów:

1. <<Argument pierwszy — np.: „Wykonawca nie przedstawił dowodu naprawienia szkody poszkodowanemu (art. 110 ust. 2 pkt 1 ustawy Pzp)">>
2. <<Argument drugi>>

W konsekwencji Zamawiający uznał, że dowody przedstawione przez Wykonawcę nie wykazują niepodlegania wykluczeniu.

#### 3. Ocena czasowa przesłanki (art. 111 Pzp)

Zamawiający zweryfikował, że okres wykluczenia dla zastosowanej przesłanki (<<podstawa_wykluczenia_art>>) **jeszcze obowiązuje**: <<np.: „Prawomocne skazanie członka organu nastąpiło <<data>>; zgodnie z art. 111 pkt 1 ustawy Pzp okres wykluczenia wynosi 5 lat od dnia uprawomocnienia wyroku i upływa dnia <<data końca>>; w dniu niniejszej decyzji przesłanka obowiązuje.">>

### Uzasadnienie prawne

Zgodnie z <<art. 108 ust. 1 pkt X | art. 109 ust. 1 pkt X | inne>> ustawy Pzp:

> [!quote]
> <<Literalny cytat właściwego przepisu>>

<!-- Jeśli F5w na podstawie art. 7 ust. 1 ustawy antyrosyjskiej — dodaj: -->

Zgodnie z art. 7 ust. 1 pkt <<X>> ustawy z dnia 13 kwietnia 2022 r. o szczególnych rozwiązaniach w zakresie przeciwdziałania wspieraniu agresji na Ukrainę oraz służących ochronie bezpieczeństwa narodowego (Dz.U. poz. 835, ze zm.):

> [!quote]
> <<Literalny cytat>>

**Wnioskowanie:** Stan faktyczny dotyczący Wykonawcy odpowiada przesłance <<podstawa_wykluczenia_art>>. Wykonawca nie wykazał niepodlegania wykluczeniu w trybie art. 110 ust. 2 ustawy Pzp (w zakresie, w jakim art. 110 Pzp znajduje zastosowanie do danej przesłanki). Wykluczenie obliguje do odrzucenia oferty na podstawie art. 226 ust. 1 pkt 2 lit. a ustawy Pzp.

### Środki ochrony prawnej

> [!important] Pouczenie o środkach ochrony prawnej
> Na podstawie art. 513 i nast. ustawy Pzp Wykonawcy, którego interes w uzyskaniu zamówienia doznał lub może doznać uszczerbku w wyniku niniejszej czynności Zamawiającego, przysługuje **odwołanie do Prezesa Krajowej Izby Odwoławczej** w terminie **<<10 | 5>> dni od dnia przekazania informacji o czynności Zamawiającego**, zgodnie z <<art. 515 ust. 1 pkt 1 lit. a Pzp — procedura unijna | art. 515 ust. 2 Pzp — tryb podstawowy>>.
>
> Odwołanie wnosi się w formie pisemnej albo w formie elektronicznej opatrzone kwalifikowanym podpisem elektronicznym, za pośrednictwem elektronicznej skrzynki podawczej Urzędu Zamówień Publicznych.
>
> **Adres KIO:**
> Krajowa Izba Odwoławcza
> ul. Postępu 17a
> 02-676 Warszawa
> ePUAP: /KIO/SkrytkaESP

### Zakończenie

Niniejsza informacja jest jednocześnie przekazywana wszystkim wykonawcom, którzy złożyli oferty w postępowaniu, zgodnie z art. 253 ust. 1 pkt 2 ustawy Pzp.

---

## Załączniki

<<np. „nie dotyczy" lub lista, np.:
1. Informacja z KRK Wykonawcy z dnia <<data>>;
2. Informacja Wykonawcy w przedmiocie self-cleaning z dnia <<data>>;
3. Ocena self-cleaning sporządzona przez Zamawiającego.>>

## Otrzymują

1. <<pełna nazwa wykonawcy>>, <<adres>> — za pośrednictwem platformy zakupowej
2. Pozostali wykonawcy, którzy złożyli oferty w postępowaniu — do informacji
3. a/a
