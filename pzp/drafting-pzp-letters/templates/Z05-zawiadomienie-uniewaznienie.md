---
sygnatura_postepowania: <<np. BL-V.2371.3.2026>>
postepowanie: <<pełna nazwa postępowania z ogłoszenia>>
zamawiajacy: <<pełna nazwa zamawiającego>>
# Pole `wykonawca` wskazuje konkretnego adresata tego egzemplarza pisma.
# Z05 kieruje się RÓWNOCZEŚNIE do wszystkich wykonawców — generuj osobne
# pliki .md/.docx dla każdego adresata różniące się polami `wykonawca` i
# `adres_wykonawcy`; pozostała treść jest identyczna.
wykonawca: <<pełna nazwa wykonawcy — adresata tego egzemplarza>>
wykonawca_slug: <<slug-wykonawcy>>
adres_wykonawcy: <<ulica, kod pocztowy, miasto>>
wykonawcy_odbiorcy:
  - <<nazwa wykonawcy, który złożył ofertę 1>>
  - <<...>>
typ_pisma: zawiadomienie-uniewaznienie
kod_pisma: Z05
podstawa_prawna:
  - "<<art. 255 pkt X | art. 256 | art. 257 | art. 258>> ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
  - "art. 260 ust. 1 Pzp (obowiązek zawiadomienia)"
podstawa_uniewaznienia_artykul: "<<np. art. 255 pkt 3 | art. 257>>"
podstawa_uniewaznienia_pkt: "<<pkt 1 | pkt 2 | pkt 3 | pkt 4 | pkt 5 | pkt 6 | pkt 7 | pkt 8>> (tylko dla art. 255; max pkt 8 — art. 255 ma 8 punktów, nie 9)"
sygnatura_pisma: <<np. BL-V.2371.3.2026.Z05>>
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
  - pzp/pismo/zawiadomienie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/kod/Z05
---

# Z05 — Zawiadomienie o unieważnieniu postępowania (SZKIELET)

**Dane do szablonu DOCX:** analogicznie do W01 (adresat = konkretny wykonawca; pismo do wszystkich, którzy złożyli oferty).

---

## Treść pisma

**Dotyczy:** postępowania o udzielenie zamówienia publicznego pn. „<<postepowanie>>", znak sprawy: **<<sygnatura_postepowania>>**.

### Wstęp

Działając na podstawie art. 260 ust. 1 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.), zwanej dalej „ustawą Pzp", Zamawiający niniejszym **zawiadamia o unieważnieniu postępowania** o udzielenie zamówienia publicznego wskazanego powyżej.

### Rozstrzygnięcie

Postępowanie zostaje unieważnione na podstawie **art. 255 pkt <<X>> ustawy Pzp**.

### Uzasadnienie faktyczne

<!-- TODO: Opis stanu faktycznego + cytaty dokumentów. Dostosuj do wybranego punktu art. 255 (8 pkt — literalne brzmienie ustawy Dz.U. 2024 poz. 1320):

- pkt 1: "nie złożono żadnego wniosku o dopuszczenie do udziału w postępowaniu albo żadnej oferty"
- pkt 2: "wszystkie złożone wnioski o dopuszczenie do udziału w postępowaniu albo oferty podlegały odrzuceniu"
- pkt 3: "cena lub koszt najkorzystniejszej oferty lub oferta z najniższą ceną przewyższa kwotę, którą zamawiający zamierza przeznaczyć na sfinansowanie zamówienia, chyba że zamawiający może zwiększyć tę kwotę do ceny lub kosztu najkorzystniejszej oferty"
- pkt 4: "w przypadkach, o których mowa w art. 248 ust. 3, art. 249 i art. 250 ust. 2, zostały złożone oferty dodatkowe o takiej samej cenie lub koszcie"
- pkt 5: "wystąpiła istotna zmiana okoliczności powodująca, że prowadzenie postępowania lub wykonanie zamówienia nie leży w interesie publicznym, czego nie można było wcześniej przewidzieć"
- pkt 6: "postępowanie obarczone jest niemożliwą do usunięcia wadą uniemożliwiającą zawarcie niepodlegającej unieważnieniu umowy w sprawie zamówienia publicznego"
- pkt 7: "wykonawca nie wniósł wymaganego zabezpieczenia należytego wykonania umowy lub uchylił się od zawarcia umowy w sprawie zamówienia publicznego, z uwzględnieniem art. 263"
- pkt 8: "w trybie zamówienia z wolnej ręki negocjacje nie doprowadziły do zawarcia umowy w sprawie zamówienia publicznego"

Osobne podstawy (nie pkt art. 255):
- **art. 257** — nieprzyznanie środków publicznych (zamówienie „z zastrzeżeniem") — wymaga przewidzenia w ogłoszeniu/zaproszeniu
- **art. 258** — niewystarczająca liczba wykonawców
-->

> [!danger] UWAGA
> Art. 255 ma **tylko 8 punktów** — NIE ma „pkt 9". Nie wymyślać nieistniejących przesłanek. Jeśli podstawą unieważnienia są środki publiczne — art. 257 Pzp (osobna podstawa). Rażąco niska cena NIE jest samodzielną przesłanką z art. 255; jeśli dotyczy — stosuje się pkt 2 („wszystkie oferty podlegały odrzuceniu z art. 226 ust. 1 pkt 8").

<<Szczegółowy opis stanu faktycznego uzasadniającego unieważnienie.>>

### Uzasadnienie prawne

Zgodnie z art. 255 pkt <<X>> ustawy Pzp:

> [!quote]
> <<Literalny cytat właściwego punktu>>

Stan faktyczny opisany w pkt „Uzasadnienie faktyczne" odpowiada przesłance art. 255 pkt <<X>> Pzp, co obliguje Zamawiającego do unieważnienia postępowania.

### Skutki unieważnienia

- **Wadium** zostanie zwrócone wykonawcom zgodnie z art. 98 ust. 1 pkt 1 ustawy Pzp.
- **Dalsze czynności w postępowaniu** nie będą prowadzone.
- <<Dodatkowe skutki, jeżeli dotyczą — np. informacja o planach wszczęcia nowego postępowania.>>

### Środki ochrony prawnej

> [!important] Pouczenie
> Wykonawcom, których interes w uzyskaniu zamówienia doznał lub może doznać uszczerbku w wyniku niniejszej czynności Zamawiającego, przysługuje **odwołanie do Prezesa Krajowej Izby Odwoławczej** w terminie **<<10 | 5>> dni** od dnia przekazania zawiadomienia (art. 515 ust. <<1 pkt 1 lit. a | 2>> Pzp).
>
> **Krajowa Izba Odwoławcza**, ul. Postępu 17a, 02-676 Warszawa, ePUAP: /KIO/SkrytkaESP.

### Publikacja

Zgodnie z art. 260 ust. 2 ustawy Pzp zawiadomienie podlega niezwłocznemu udostępnieniu na stronie internetowej prowadzonego postępowania.

### Zakończenie

<<Formuła zakończeniowa.>>

---

## Załączniki

<<nie dotyczy>>

## Otrzymują

1. Wszyscy wykonawcy, którzy złożyli oferty w postępowaniu — równocześnie, za pośrednictwem platformy zakupowej
2. a/a
