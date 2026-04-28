---
sygnatura_postepowania: <<np. BL-V.2371.3.2026>>
postepowanie: <<pełna nazwa postępowania z ogłoszenia>>
zamawiajacy: <<pełna nazwa zamawiającego>>
wykonawca: <<pełna nazwa wykonawcy z oferty>>
wykonawca_slug: <<slug-wykonawcy>>
adres_wykonawcy: <<ulica, kod pocztowy, miasto>>
typ_pisma: zawiadomienie-poprawa-omylki-innej
kod_pisma: Z03
podstawa_prawna:
  - "art. 223 ust. 2 pkt 3 oraz art. 223 ust. 3 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
znaleziska_powiazane:
  - <<np. Kx.y>>
termin_odpowiedzi: "3 dni od doręczenia (termin sprzeciwu)"
sygnatura_pisma: <<np. BL-V.2371.3.2026.Z03>>
data_pisma: <<YYYY-MM-DD>>
miejscowosc: Warszawa
autor: <<email autora analizy>>
signatory_stanowisko: <<np. Dyrektor Biura Informatyki i Łączności KG PSP>>
signatory_tytul: <<np. mł. bryg. mgr inż.>>
signatory_imie_nazwisko: <<np. Michał Kłosiński>>
signatory_zrodlo: <<memory | explicit>>
status: draft
poziom_pewnosci: <<wysoki | średni | niski>>
tags:
  - pzp/pismo/zawiadomienie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
  - pzp/kod/Z03
---

# Z03 — Zawiadomienie o poprawieniu innej omyłki (niepowodującej istotnych zmian w treści oferty)

> [!warning] Precondition check
> Art. 223 ust. 2 pkt 3 dotyczy omyłek polegających na **niezgodności oferty z dokumentami zamówienia, NIEPOWODUJĄCYCH ISTOTNYCH ZMIAN w treści oferty**. Jeśli poprawka prowadzi do istotnej zmiany treści oferty (np. zmiany parametru technicznego, ceny, zakresu) — poprawka jest niedopuszczalna; oferta podlega odrzuceniu z art. 226 ust. 1 pkt 5 ustawy Pzp.

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

Działając na podstawie art. 223 ust. 2 pkt 3 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.), zwanej dalej „ustawą Pzp", Zamawiający niniejszym **zawiadamia Wykonawcę — <<pełna nazwa wykonawcy>> — o poprawieniu innej omyłki polegającej na niezgodności oferty z dokumentami zamówienia, niepowodującej istotnych zmian w treści oferty**.

Zgodnie z art. 223 ust. 2 pkt 3 ustawy Pzp: „Zamawiający poprawia w ofercie (...) inne omyłki polegające na niezgodności oferty z dokumentami zamówienia, niepowodujące istotnych zmian w treści oferty — niezwłocznie zawiadamiając o tym wykonawcę, którego oferta została poprawiona."

### Stan faktyczny — stwierdzona omyłka i zakres poprawki

**Lokalizacja:** `[DOC: <<plik>>] [str. <<N>>]`

**Pierwotna treść oferty:**

> [!quote]
> <<Dosłowny cytat>>

**Niezgodność z dokumentami zamówienia:**

> [!quote]
> <<Cytat z SWZ/OPZ/odpowiedzi na pytania — wymóg, z którym oferta jest niezgodna>>
> `[DOC: <<plik>>] [Rozdz./pkt <<X>>] [str. <<N>>]`

**Treść po poprawieniu:**

> [!quote]
> <<Treść po poprawce>>

**Charakter omyłki:** <<Opis — np. „Wykonawca wpisał w formularzu ofertowym nieaktualny numer KRS. Poprawka polega na zastąpieniu numeru aktualnym numerem KRS wynikającym z odpisu KRS dołączonego do oferty. Poprawka nie prowadzi do istotnej zmiany treści oferty — nie wpływa na cenę, zakres, parametry techniczne ani warunki realizacji zamówienia.">>

### Uzasadnienie — niepowodowanie istotnych zmian

Zamawiający ocenił, że poprawka nie prowadzi do istotnej zmiany treści oferty w rozumieniu art. 223 ust. 2 pkt 3 ustawy Pzp, z następujących powodów:

1. <<Argument pierwszy — np.: „Poprawka ma charakter wyłącznie formalny (zmiana danych identyfikacyjnych) i nie wpływa na żadne kryterium oceny ofert.">>
2. <<Argument drugi — np.: „Poprawka nie zmienia zakresu przedmiotu zamówienia ani żadnego parametru technicznego wskazanego w ofercie.">>
3. <<Argument trzeci — np.: „Poprawka nie wpływa na cenę oferty ani na warunki jej wykonania.">>

### Procedura sprzeciwu

> [!important] Termin sprzeciwu — 3 dni
> Zgodnie z art. 223 ust. 3 ustawy Pzp, Zamawiający poprawia omyłkę, o której mowa w art. 223 ust. 2 pkt 3 ustawy Pzp, **pod warunkiem, że Wykonawca, w terminie 3 dni od dnia doręczenia niniejszego zawiadomienia, nie wyrazi pisemnego sprzeciwu wobec poprawienia omyłki**.
>
> Ewentualny sprzeciw wobec poprawienia omyłki należy złożyć w terminie **3 dni od dnia doręczenia** niniejszego zawiadomienia, za pośrednictwem platformy zakupowej Zamawiającego — <<URL platformy>>.

### Pouczenie o skutkach

> [!warning] Skutki prawne
> Zgodnie z art. 223 ust. 3 ustawy Pzp — brak odpowiedzi Wykonawcy w terminie 3 dni traktowany jest jak zgoda na poprawienie omyłki (zgoda milcząca). Poprawka wchodzi wówczas w życie automatycznie, bez konieczności dodatkowych czynności.
>
> **Wyrażenie przez Wykonawcę pisemnego sprzeciwu wobec poprawienia omyłki — w terminie 3 dni — skutkuje odrzuceniem oferty na podstawie art. 226 ust. 1 pkt 11 ustawy Pzp.**

### Zakończenie

<<Krótka formuła zakończeniowa.>>

---

## Załączniki

<<np. „nie dotyczy">>

## Otrzymują

1. <<pełna nazwa wykonawcy>>, <<adres>> — za pośrednictwem platformy zakupowej
2. a/a
