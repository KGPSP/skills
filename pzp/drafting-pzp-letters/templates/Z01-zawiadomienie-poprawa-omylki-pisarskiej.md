---
sygnatura_postepowania: <<np. BL-V.2371.3.2026>>
postepowanie: <<pełna nazwa postępowania z ogłoszenia>>
zamawiajacy: <<pełna nazwa zamawiającego>>
wykonawca: <<pełna nazwa wykonawcy z oferty>>
wykonawca_slug: <<slug-wykonawcy>>
adres_wykonawcy: <<ulica, kod pocztowy, miasto>>
typ_pisma: zawiadomienie-poprawa-omylki-pisarskiej
kod_pisma: Z01
podstawa_prawna:
  - "art. 223 ust. 2 pkt 1 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
znaleziska_powiazane:
  - <<np. K1.F1.2>>
sygnatura_pisma: <<np. BL-V.2371.3.2026.Z01>>
data_pisma: <<YYYY-MM-DD>>
miejscowosc: Warszawa
autor: <<email autora analizy>>
signatory_stanowisko: <<np. Dyrektor Biura Informatyki i Łączności KG PSP>>
signatory_tytul: <<np. mł. bryg. mgr inż.>>
signatory_imie_nazwisko: <<np. Michał Kłosiński>>
signatory_zrodlo: <<memory | explicit>>
status: draft
poziom_pewnosci: wysoki
tags:
  - pzp/pismo/zawiadomienie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
  - pzp/kod/Z01
---

# Z01 — Zawiadomienie o poprawieniu oczywistej omyłki pisarskiej

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

Działając na podstawie art. 223 ust. 2 pkt 1 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.), zwanej dalej „ustawą Pzp", Zamawiający niniejszym **zawiadamia Wykonawcę — <<pełna nazwa wykonawcy>> — o poprawieniu oczywistej omyłki pisarskiej** stwierdzonej w treści oferty złożonej w postępowaniu wskazanym powyżej.

Zgodnie z art. 223 ust. 2 pkt 1 ustawy Pzp: „Zamawiający poprawia w ofercie oczywiste omyłki pisarskie (...), niezwłocznie zawiadamiając o tym wykonawcę, którego oferta została poprawiona."

### Stan faktyczny — stwierdzone omyłki i ich poprawienie

<!-- Per każda omyłka pisarska: lokalizacja w ofercie + pierwotna treść + treść po poprawie -->

#### 1. <<Opis omyłki — np. Literówka w adresie internetowym Wykonawcy w JEDZ>>

**Lokalizacja:** `[DOC: <<plik>>] [sekcja <<X>>] [str. <<N>>]`

**Pierwotna treść oferty:**

> [!quote]
> <<Dosłowny cytat zawierający omyłkę — np. „Adres internetowy Wykonawcy: www.wsko.pl">>

**Treść po poprawieniu:**

> [!quote]
> <<Poprawiona treść — np. „Adres internetowy Wykonawcy: www.wasko.pl">>

**Charakter omyłki:** <<np. „Oczywista omyłka pisarska — literówka polegająca na pominięciu jednej litery w nazwie domeny internetowej Wykonawcy. Poprawka polegająca na wstawieniu brakującej litery «a» jest jednoznaczna i nie budzi wątpliwości co do prawidłowej treści deklaracji Wykonawcy.">>

#### 2. <<Kolejna omyłka>>

<!-- Ta sama struktura -->

### Zakres i skutek poprawienia

Zamawiający poprawił wyżej opisane omyłki pisarskie **z urzędu**, działając w granicach art. 223 ust. 2 pkt 1 ustawy Pzp. Poprawki nie prowadzą do zmiany treści oferty w rozumieniu merytorycznym — w każdym przypadku właściwa treść oferty była jednoznacznie możliwa do odtworzenia na podstawie całokształtu dokumentów złożonych w postępowaniu.

### Pouczenie

> [!info] Brak procedury sprzeciwu — omyłka pisarska
> Niniejsze zawiadomienie ma charakter informacyjny. Zgodnie z art. 223 ust. 2 pkt 1 ustawy Pzp poprawienie oczywistych omyłek pisarskich nie wymaga uprzedniej zgody Wykonawcy ani nie podlega procedurze sprzeciwu określonej w art. 223 ust. 3 ustawy Pzp (która dotyczy wyłącznie poprawek, o których mowa w art. 223 ust. 2 pkt 3 ustawy Pzp — innych omyłek polegających na niezgodności oferty z dokumentami zamówienia, niepowodujących istotnych zmian w treści oferty).
>
> Wykonawca, który kwestionuje zakwalifikowanie danej niezgodności jako „oczywistej omyłki pisarskiej" lub zakres dokonanej poprawki, może wnieść odwołanie do Prezesa Krajowej Izby Odwoławczej zgodnie z art. 513 i nast. ustawy Pzp — w terminach określonych w art. 515 ustawy Pzp (10 dni — procedura unijna, art. 515 ust. 1 pkt 1 lit. a Pzp; 5 dni — tryb podstawowy, art. 515 ust. 2 Pzp). Zarzut może zostać także podniesiony w odwołaniu od innej czynności Zamawiającego, w szczególności od wyboru oferty najkorzystniejszej lub unieważnienia postępowania.

### Zakończenie

<<Krótka formuła zakończeniowa, np.: „Niniejsze zawiadomienie włącza się do dokumentacji postępowania. Oferta Wykonawcy po poprawieniu omyłek pisarskich podlega dalszemu badaniu i ocenie.">>

---

## Załączniki

<<np. „nie dotyczy">>

## Otrzymują

1. <<pełna nazwa wykonawcy>>, <<adres>> — za pośrednictwem platformy zakupowej
2. a/a
