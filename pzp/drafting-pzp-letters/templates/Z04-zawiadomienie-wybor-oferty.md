---
sygnatura_postepowania: <<np. BL-V.2371.3.2026>>
postepowanie: <<pełna nazwa postępowania z ogłoszenia>>
zamawiajacy: <<pełna nazwa zamawiającego>>
# Pole `wykonawca` wskazuje konkretnego adresata tego egzemplarza pisma
# (Z04 kieruje się RÓWNOCZEŚNIE do wszystkich wykonawców — każdy egzemplarz
# ma tego samego wykonawcę jako adresata). Dla kolejnych adresatów generuj
# osobne pliki .md/.docx różniące się wyłącznie polem `wykonawca` i
# `adres_wykonawcy`; część merytoryczna (rozstrzygnięcie, punktacja, pouczenie)
# pozostaje identyczna.
wykonawca: <<pełna nazwa wykonawcy — adresata tego egzemplarza>>
wykonawca_slug: <<slug-wykonawcy>>
adres_wykonawcy: <<ulica, kod pocztowy, miasto>>
wykonawca_wybrany: <<pełna nazwa wykonawcy, którego oferta została wybrana>>
wykonawcy_pozostali:
  - <<nazwa>>
  - <<...>>
typ_pisma: zawiadomienie-wybor-oferty
kod_pisma: Z04
podstawa_prawna:
  - "art. 253 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
  - "art. 308 ust. 2 Pzp (tryb podstawowy) lub art. 264 ust. 1 Pzp (procedura unijna) — zawieszenie zawarcia umowy"
sygnatura_pisma: <<np. BL-V.2371.3.2026.Z04>>
data_pisma: <<YYYY-MM-DD>>
miejscowosc: Warszawa
autor: <<email autora analizy>>
signatory_stanowisko: <<np. Dyrektor Biura Informatyki i Łączności KG PSP>>
signatory_tytul: <<np. mł. bryg. mgr inż.>>
signatory_imie_nazwisko: <<np. Michał Kłosiński>>
signatory_zrodlo: <<memory | explicit>>
status: draft
poziom_pewnosci: wysoki
termin_odwolania_dni: <<10 dla procedury unijnej | 5 dla trybu podstawowego>>
standstill_dni: <<10 dla procedury unijnej | 5 dla trybu podstawowego>>
tags:
  - pzp/pismo/zawiadomienie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/kod/Z04
---

# Z04 — Zawiadomienie o wyborze najkorzystniejszej oferty (SZKIELET)

> [!info] Adresaci
> Zawiadomienie kieruje się **równocześnie** do wszystkich wykonawców, którzy złożyli oferty. Każdy egzemplarz adresowany na konkretnego wykonawcę, ale treść merytoryczna — identyczna.

**Dane do szablonu DOCX:** analogicznie do W01 (ale adresat = konkretny wykonawca).

---

## Treść pisma

**Dotyczy:** postępowania o udzielenie zamówienia publicznego pn. „<<postepowanie>>", znak sprawy: **<<sygnatura_postepowania>>**.

### Wstęp

Działając na podstawie art. 253 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.), zwanej dalej „ustawą Pzp", Zamawiający niniejszym **informuje o wyborze najkorzystniejszej oferty** w postępowaniu wskazanym powyżej.

### Rozstrzygnięcie

Jako najkorzystniejsza wybrana została oferta złożona przez Wykonawcę:

**<<Pełna nazwa wykonawcy wybranego>>**
<<Siedziba / miejsce zamieszkania / miejsce wykonywania działalności>>

z ceną oferty brutto **<<XX XXX XXX,XX zł>>** — z łączną punktacją **<<XX,XX pkt>>**.

### Punktacja wszystkich ofert

<!-- TODO: Tabela punktacji — wszystkie oferty, każde kryterium oceny + łączna -->

| # | Wykonawca | Cena brutto | Pkt za cenę (waga X%) | Pkt za kryterium 2 (waga Y%) | **Łącznie** |
|---|-----------|-------------|-----------------------|------------------------------|-------------|
| 1 | <<Wykonawca 1>> | <<kwota>> | <<pkt>> | <<pkt>> | **<<pkt>>** |
| 2 | <<Wykonawca 2>> | <<kwota>> | <<pkt>> | <<pkt>> | **<<pkt>>** |

### Wykonawcy, których oferty zostały odrzucone

<!-- TODO: Jeżeli były odrzucenia — wymień wykonawców + podstawa prawna i krótkie uzasadnienie. Zgodnie z art. 253 ust. 1 pkt 2 Pzp zawiadomienie MUSI zawierać uzasadnienie faktyczne i prawne. -->

**<<Nazwa wykonawcy odrzuconego>>**
- Podstawa prawna: art. 226 ust. 1 pkt <<X>> Pzp
- Uzasadnienie: <<krótki opis>>
- Szczegóły: patrz informacja o odrzuceniu z dnia <<data>>, znak: <<sygnatura>>

### Wykonawcy wykluczeni

<!-- TODO: Jeżeli byli wykluczeni — analogicznie -->

### Termin zawarcia umowy (standstill)

> [!important] Termin zawarcia umowy
> Zgodnie z <<art. 264 ust. 1 Pzp — procedura unijna | art. 308 ust. 2 Pzp — tryb podstawowy>>, umowa w sprawie zamówienia publicznego zostanie zawarta **w terminie nie krótszym niż <<10 | 5>> dni od dnia przesłania zawiadomienia o wyborze najkorzystniejszej oferty**, jeżeli zawiadomienie to zostało przesłane przy użyciu środków komunikacji elektronicznej, albo 15 dni — jeżeli zostało przesłane w inny sposób.

### Środki ochrony prawnej

> [!important] Pouczenie
> Wykonawcom, których interes w uzyskaniu zamówienia doznał lub może doznać uszczerbku w wyniku niniejszej czynności Zamawiającego, przysługuje **odwołanie do Prezesa Krajowej Izby Odwoławczej** w terminie **<<10 | 5>> dni** od dnia przekazania zawiadomienia (art. 515 ust. <<1 pkt 1 lit. a | 2>> Pzp).
>
> **Krajowa Izba Odwoławcza**, ul. Postępu 17a, 02-676 Warszawa, ePUAP: /KIO/SkrytkaESP.

### Publikacja

Zgodnie z art. 253 ust. 2 ustawy Pzp zawiadomienie podlega niezwłocznemu udostępnieniu na stronie internetowej prowadzonego postępowania.

### Zakończenie

<<Formuła zakończeniowa.>>

---

## Załączniki

<<nie dotyczy | tabela punktacji szczegółowej>>

## Otrzymują

1. Wszyscy wykonawcy, którzy złożyli oferty w postępowaniu — równocześnie, za pośrednictwem platformy zakupowej
2. a/a
