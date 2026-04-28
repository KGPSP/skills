---
sygnatura_postepowania: <<np. BL-V.2371.3.2026>>
postepowanie: <<pełna nazwa postępowania z ogłoszenia>>
zamawiajacy: <<pełna nazwa zamawiającego>>
wykonawca: <<pełna nazwa wykonawcy z oferty>>
wykonawca_slug: <<slug-wykonawcy>>
adres_wykonawcy: <<ulica, kod pocztowy, miasto>>
typ_pisma: informacja-odrzucenie
kod_pisma: O01
podstawa_prawna:
  - "art. 226 ust. 1 pkt <<X>> ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
  - "art. 253 ust. 1 pkt 2 oraz ust. 2 ustawy Pzp (obowiązek informacyjny)"
znaleziska_powiazane:
  - <<np. Kx.y>>
podstawa_odrzucenia_pkt: "<<np. pkt 5>>"  # numer punktu art. 226 ust. 1
sygnatura_pisma: <<np. BL-V.2371.3.2026.O01>>
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
  - pzp/pismo/odrzucenie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
  - pzp/kod/O01
---

# O01 — Informacja o odrzuceniu oferty

> [!danger] Precondition check — PRZED WYSŁANIEM
> 1. **Czy dla znaleziska F4 (niezgodność z warunkami zamówienia) wykonano najpierw wezwanie do wyjaśnień W03 (art. 223 ust. 1 Pzp)?** Jeśli NIE — NIE wysyłaj O01 zanim Wykonawca otrzyma możliwość wyjaśnień.
> 2. **Czy ocena wyjaśnień jest udokumentowana?** Jeśli tak — załącz ją lub odwołaj się do dokumentu zawierającego ocenę.
> 3. **Czy wskazana przesłanka art. 226 ust. 1 jest dopasowana do stanu faktycznego?** Sprawdź dokładnie pkt 1–19.
> 4. **Czy oferta nie powinna być odrzucona z innej, dalej idącej przesłanki?** (Np. jednocześnie pkt 2 i pkt 5 — pierwsza rozstrzyga).

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

Działając na podstawie art. 253 ust. 1 pkt 2 oraz ust. 2 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.), zwanej dalej „ustawą Pzp", Zamawiający niniejszym **informuje Wykonawcę — <<pełna nazwa wykonawcy>> — o odrzuceniu oferty złożonej w postępowaniu wskazanym powyżej** wraz z uzasadnieniem faktycznym i prawnym.

### Rozstrzygnięcie

Oferta Wykonawcy **podlega odrzuceniu na podstawie art. 226 ust. 1 <<pkt X>> ustawy Pzp**.

### Uzasadnienie faktyczne

<!-- Opis stanu faktycznego z cytatami wymogu + oferty + ew. wyjaśnieniami wykonawcy i oceną tych wyjaśnień. Bez ozdobników. -->

#### 1. Stan faktyczny oferty w zakresie objętym odrzuceniem

<!-- Per każda niezgodność, która prowadzi do odrzucenia -->

**Wymóg Zamawiającego:**

> [!quote]
> <<Dosłowny cytat z SWZ/OPZ/odpowiedzi>>
> `[DOC: <<plik>>] [Rozdz./Część <<X>>] [pkt <<Y>>] [str. <<N>>]`

**Stan faktyczny oferty:**

> [!quote]
> <<Dosłowny cytat z oferty>>
> `[DOC: <<plik oferty>>] [str. <<N>>]`

**Niezgodność:** <<Opis niezgodności — np.: „Oferowany parametr klasy środowiskowej ASHRAE A2 jest niezgodny z wymogiem klasy ASHRAE A1 lub lepszej, podtrzymanym przez Zamawiającego w odpowiedzi na zapytanie nr 4 z dnia ...">>

#### 2. Przebieg postępowania wyjaśniającego (jeżeli przeprowadzono W03)

Zamawiający pismem z dnia <<data W03>>, znak: <<sygnatura W03>>, **wezwał Wykonawcę do wyjaśnienia treści oferty** w zakresie wskazanym w pkt 1, na podstawie art. 223 ust. 1 ustawy Pzp.

Wykonawca złożył wyjaśnienia pismem z dnia <<data>>, w których <<krótki opis treści wyjaśnień — np. „potwierdził zgodność z klasą ASHRAE A2, nie przedstawił dowodów na kwalifikację klasy A1 przy zawężeniu parametrów eksploatacji.">>.

**Ocena wyjaśnień:** <<Merytoryczna ocena — np.: „Wyjaśnienia Wykonawcy nie uzasadniają zgodności oferowanego produktu z wymogiem OPZ. Wykonawca nie przedstawił dowodu, że oferowane serwery obliczeniowe spełniają wymagania klasy ASHRAE A1 lub lepszej, a karta katalogowa producenta potwierdza wyłącznie zgodność z klasą ASHRAE A2.">>

#### 3. Okoliczności dodatkowe

<<Jeśli dotyczą — np. wykluczenie próby poprawy omyłki z art. 223 ust. 2, niezmożność zastosowania art. 107 ust. 2 (gdyby szło o przedmiotowe ś.d.) ze względu na art. 107 ust. 3 itp.>>

### Uzasadnienie prawne

Zgodnie z art. 226 ust. 1 <<pkt X>> ustawy Pzp:

> [!quote]
> <<Literalny cytat właściwego punktu, np. dla pkt 5: „Zamawiający odrzuca ofertę, jeżeli: (...) jej treść jest niezgodna z warunkami zamówienia">>

<!-- Jeśli pkt = 5 — dodaj wyjaśnienie pojęcia -->

W świetle art. 226 ust. 1 pkt 5 ustawy Pzp, treść oferty jest niezgodna z warunkami zamówienia, jeżeli nie odpowiada wymaganiom określonym przez zamawiającego w ogłoszeniu o zamówieniu, SWZ lub OPZ, w tym w zakresie parametrów technicznych, funkcjonalnych, terminów, gwarancji albo innych wymagań wiążących wykonawcę. Takie niezgodności zostały stwierdzone w stanie faktycznym wskazanym powyżej.

**Wnioskowanie:** Stan faktyczny oferty Wykonawcy spełnia przesłankę zastosowania art. 226 ust. 1 <<pkt X>> ustawy Pzp, co obliguje Zamawiającego do odrzucenia oferty. Niniejsze rozstrzygnięcie pozostaje w zgodzie z art. 16 ust. 1 ustawy Pzp (zasada równego traktowania wykonawców) oraz art. 17 ustawy Pzp (zasada przejrzystości postępowania).

### Środki ochrony prawnej

> [!important] Pouczenie o środkach ochrony prawnej
> Na podstawie art. 513 i nast. ustawy Pzp Wykonawcy, którego interes w uzyskaniu zamówienia doznał lub może doznać uszczerbku w wyniku niniejszej czynności Zamawiającego, przysługuje **odwołanie do Prezesa Krajowej Izby Odwoławczej** w terminie **<<10 | 5>> dni od dnia przekazania informacji o czynności Zamawiającego stanowiącej podstawę jego wniesienia**, zgodnie z <<art. 515 ust. 1 pkt 1 lit. a Pzp — dla procedury unijnej | art. 515 ust. 2 Pzp — dla trybu podstawowego>>.
>
> Odwołanie wnosi się w formie pisemnej albo w formie elektronicznej opatrzone kwalifikowanym podpisem elektronicznym, za pośrednictwem elektronicznej skrzynki podawczej Urzędu Zamówień Publicznych.
>
> **Adres KIO:**
> Krajowa Izba Odwoławcza
> ul. Postępu 17a
> 02-676 Warszawa
> ePUAP: /KIO/SkrytkaESP
>
> Szczegółowe wymagania co do treści i formy odwołania określa art. 516 ustawy Pzp. Wniesienie odwołania podlega opłacie, której wysokość i zasady wnoszenia określa rozporządzenie Prezesa Rady Ministrów z dnia 30 grudnia 2020 r. w sprawie szczegółowych rodzajów kosztów postępowania odwoławczego, ich rozliczania oraz wysokości i sposobu pobierania wpisu od odwołania (Dz.U. 2020 poz. 2437).

### Zakończenie

Zgodnie z art. 253 ust. 1 pkt 2 ustawy Pzp, równocześnie z przekazaniem niniejszej informacji, Zamawiający informuje o odrzuceniu oferty Wykonawcy pozostałych wykonawców, którzy złożyli oferty w postępowaniu — w odrębnych pismach (lub w zbiorczym zawiadomieniu o wyborze oferty najkorzystniejszej, o którym mowa w art. 253 ust. 1 pkt 1 Pzp).

---

## Załączniki

<<np. „nie dotyczy" lub lista, np.:
1. Kopia pisma z dnia <<data W03>>, znak: <<sygnatura W03>> — wezwanie do wyjaśnień;
2. Ocena wyjaśnień Wykonawcy z dnia <<data>>.>>

## Otrzymują

1. <<pełna nazwa wykonawcy>>, <<adres>> — za pośrednictwem platformy zakupowej
2. a/a
