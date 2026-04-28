---
sygnatura_postepowania: <<np. BL-V.2371.3.2026>>
postepowanie: <<pełna nazwa postępowania z ogłoszenia>>
zamawiajacy: <<pełna nazwa zamawiającego>>
wykonawca: <<pełna nazwa wykonawcy z oferty>>
wykonawca_slug: <<slug-wykonawcy>>
adres_wykonawcy: <<ulica, kod pocztowy, miasto>>
typ_pisma: zawiadomienie-poprawa-omylki-rachunkowej
kod_pisma: Z02
podstawa_prawna:
  - "art. 223 ust. 2 pkt 2 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
znaleziska_powiazane:
  - <<np. Kx.y>>
sygnatura_pisma: <<np. BL-V.2371.3.2026.Z02>>
data_pisma: <<YYYY-MM-DD>>
miejscowosc: Warszawa
autor: <<email autora analizy>>
signatory_stanowisko: <<np. Dyrektor Biura Informatyki i Łączności KG PSP>>
signatory_tytul: <<np. mł. bryg. mgr inż.>>
signatory_imie_nazwisko: <<np. Michał Kłosiński>>
signatory_zrodlo: <<memory | explicit>>
status: draft
poziom_pewnosci: wysoki
cena_przed_poprawka_brutto: <<np. 21 234 567,89 zł>>
cena_po_poprawce_brutto: <<np. 21 234 567,90 zł>>
tags:
  - pzp/pismo/zawiadomienie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
  - pzp/kod/Z02
---

# Z02 — Zawiadomienie o poprawieniu oczywistej omyłki rachunkowej

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

Działając na podstawie art. 223 ust. 2 pkt 2 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.), zwanej dalej „ustawą Pzp", Zamawiający niniejszym **zawiadamia Wykonawcę — <<pełna nazwa wykonawcy>> — o poprawieniu oczywistej omyłki rachunkowej** w treści oferty złożonej w postępowaniu wskazanym powyżej, **z uwzględnieniem konsekwencji rachunkowych dokonanej poprawki**.

Zgodnie z art. 223 ust. 2 pkt 2 ustawy Pzp: „Zamawiający poprawia w ofercie oczywiste omyłki rachunkowe, z uwzględnieniem konsekwencji rachunkowych dokonanych poprawek (...), niezwłocznie zawiadamiając o tym wykonawcę, którego oferta została poprawiona."

### Stan faktyczny — stwierdzona omyłka rachunkowa

**Lokalizacja:** `[DOC: <<plik — formularz oferty lub inny dokument>>] [str. <<N>>]`

**Pierwotna treść oferty:**

> [!quote]
> <<Dosłowny cytat zawierający omyłkę rachunkową — np. „Cena netto: 17 264 480,00 zł. Podatek VAT (23%): 3 970 830,40 zł. Cena brutto: 21 234 567,89 zł.">>

**Charakter omyłki:** <<Opis — np. „Cena brutto wskazana w formularzu (21 234 567,89 zł) nie jest sumą podanej przez Wykonawcę ceny netto (17 264 480,00 zł) i podanego podatku VAT (3 970 830,40 zł). Prawidłowa suma wynosi 21 235 310,40 zł. Omyłka ma charakter oczywisty i możliwy do jednoznacznego wyprostowania na podstawie rachunków arytmetycznych.">>

### Zakres poprawki i jej konsekwencje rachunkowe

Zamawiający dokonał poprawki z uwzględnieniem konsekwencji rachunkowych w sposób następujący:

| Element oferty | Wartość pierwotna | Wartość po poprawieniu |
|----------------|------------------:|------------------------:|
| Cena netto | <<17 264 480,00 zł>> | <<wartość po poprawie — zależna od przyjętej metody>> |
| Podatek VAT (<<23%>>) | <<3 970 830,40 zł>> | <<wartość po poprawie>> |
| **Cena brutto** | **<<21 234 567,89 zł>>** | **<<21 235 310,40 zł>>** |

**Przyjęta metoda poprawki:** <<Opis — np.: „Zamawiający przyjął jako wiarygodną cenę netto podaną w formularzu (17 264 480,00 zł) oraz stawkę podatku VAT 23% wskazaną przez Wykonawcę. Cena brutto została wyliczona przez zsumowanie ceny netto i należnego podatku VAT, co daje 21 235 310,40 zł. Omyłka Wykonawcy polega na błędzie rachunkowym przy sumowaniu.">>

**Wpływ poprawki na ocenę oferty:**

- **Kryterium ceny (<<waga %>>):** po poprawieniu omyłki cena oferty brutto wynosi <<cena_po_poprawce_brutto>>. Liczba punktów w kryterium ceny będzie obliczana w oparciu o tę wartość.
- **Inne kryteria:** bez zmian / wpływ <<opisz>>.

### Pouczenie

> [!info] Brak prawa sprzeciwu — omyłka rachunkowa
> Niniejsze zawiadomienie ma charakter wyłącznie informacyjny. Zgodnie z art. 223 ust. 2 pkt 2 ustawy Pzp poprawienie oczywistych omyłek rachunkowych (z uwzględnieniem konsekwencji rachunkowych) nie wymaga zgody Wykonawcy ani nie podlega procedurze sprzeciwu z art. 223 ust. 3 ustawy Pzp (procedura sprzeciwu dotyczy wyłącznie poprawek z art. 223 ust. 2 pkt 3 ustawy Pzp).
>
> Wykonawca, który kwestionuje zasadność lub zakres poprawki, może podnieść ten zarzut w odwołaniu od innej czynności Zamawiającego, zgodnie z właściwymi terminami określonymi w art. 515 ustawy Pzp.

### Zakończenie

Oferta Wykonawcy po poprawieniu omyłki rachunkowej podlega dalszemu badaniu i ocenie. <<Ew. dodatkowe uwagi — np. „Zamawiający informuje, że cena po poprawieniu omyłki nie przekracza kwoty, którą Zamawiający zamierza przeznaczyć na sfinansowanie zamówienia.">>

---

## Załączniki

<<np. „nie dotyczy">>

## Otrzymują

1. <<pełna nazwa wykonawcy>>, <<adres>> — za pośrednictwem platformy zakupowej
2. a/a
