---
sygnatura_postepowania: <<np. BL-V.2371.3.2026>>
postepowanie: <<pełna nazwa postępowania z ogłoszenia>>
zamawiajacy: <<pełna nazwa zamawiającego>>
wykonawca: <<pełna nazwa wykonawcy z oferty>>
wykonawca_slug: <<slug-wykonawcy>>
adres_wykonawcy: <<ulica, kod pocztowy, miasto>>
typ_pisma: wezwanie-uzupelnienie-podmiotowe
kod_pisma: W01
podstawa_prawna:
  - "art. 128 ust. 1 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
znaleziska_powiazane:
  - <<np. K2.1>>
termin_odpowiedzi: "5 dni od doręczenia"
sygnatura_pisma: <<np. BL-V.2371.3.2026.W01>>
data_pisma: <<YYYY-MM-DD>>
miejscowosc: Warszawa
autor: <<email autora analizy>>
signatory_stanowisko: <<np. Dyrektor Biura Informatyki i Łączności KG PSP>>
signatory_tytul: <<np. mł. bryg. mgr inż.>>
signatory_imie_nazwisko: <<np. Michał Kłosiński>>
signatory_zrodlo: <<memory | explicit>>
status: draft
poziom_pewnosci: <<wysoki | średni | niski>>
zweryfikowano_art_128_ust_3: true  # PRZED W01 upewnij się, że uzupełnienie nie służy kryteriom selekcji
tags:
  - pzp/pismo/wezwanie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
  - pzp/kod/W01
---

# W01 — Wezwanie do złożenia, poprawienia lub uzupełnienia oświadczenia art. 125 ust. 1 Pzp lub podmiotowych środków dowodowych

**Dane do szablonu DOCX:**

| Pole szablonu | Wartość |
|---------------|---------|
| `ezdSprawaZnak` / `$sygnatura pisma` | `<<sygnatura_pisma>>` |
| `ezdDataPodpisu` / `$DataPodpisu` | `<<data_pisma>>` |
| `[adresat]` | **<<pełna nazwa wykonawcy>>**, <<adres>> |
| `ezdPracownikAtrybut1` | `<<signatory_stanowisko>>` |
| `ezdPracownikAtrybut2` | `<<signatory_tytul>>` |
| `ezdPracownikNazwa` | `<<signatory_imie_nazwisko>>` |

---

## Treść pisma

**Dotyczy:** postępowania o udzielenie zamówienia publicznego pn. „<<postepowanie>>", znak sprawy: **<<sygnatura_postepowania>>**.

### Wstęp

Działając na podstawie art. 128 ust. 1 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.), zwanej dalej „ustawą Pzp", w toku badania i oceny oferty złożonej przez Wykonawcę — <<pełna nazwa wykonawcy>> — w postępowaniu wskazanym powyżej, Zamawiający niniejszym **wzywa Wykonawcę do złożenia, poprawienia lub uzupełnienia** wskazanych niżej oświadczeń i podmiotowych środków dowodowych.

Zgodnie z art. 128 ust. 1 ustawy Pzp, jeżeli wykonawca nie złożył oświadczenia, o którym mowa w art. 125 ust. 1 ustawy Pzp, podmiotowych środków dowodowych, innych dokumentów lub oświadczeń składanych w postępowaniu, lub są one niekompletne lub zawierają błędy, Zamawiający wzywa Wykonawcę odpowiednio do ich złożenia, poprawienia lub uzupełnienia w wyznaczonym terminie.

### Stan faktyczny — dokumenty wymagające uzupełnienia / poprawienia / złożenia

<!-- Dla każdego znaleziska F2 z analizy: cytat wymogu + cytat stanu faktycznego + wskazanie konkretnego działania (złożenie/poprawienie/uzupełnienie) -->

#### 1. <<Nazwa dokumentu — np. Jednolity Europejski Dokument Zamówienia (JEDZ), Część II sekcja D>>

**Wymóg Zamawiającego:**

> [!quote]
> <<Cytat z SWZ/JEDZ wzór lub właściwy przepis wymagający złożenia dokumentu w określonej treści>>
> `[DOC: <<plik>>] [pkt <<Y>>] [str. <<N>>]`

**Stan faktyczny oferty:**

> [!quote]
> <<Cytat z oferty — np. „W JEDZ WASKO w Części II sekcja D zaznaczono odpowiedź «Nie» na pytanie o zamiar powierzenia podwykonawstwa, podczas gdy w Załączniku nr 6 — zobowiązaniu podmiotu trzeciego — wskazano stosunek prawny oparty na umowie podwykonawczej.">>
> `[DOC: <<plik>>] [str. <<N>>]`

**Charakter braku / błędu:** <<„niekompletność" / „błąd treści" / „brak dokumentu" — wskaż jednoznacznie. Np.: „Błąd treści — odpowiedź niezgodna ze stanem faktycznym wynikającym z innych dokumentów oferty.">>

#### 2. <<Kolejny dokument>>

<!-- Ta sama struktura -->

### Żądanie

Mając na uwadze powyższe, Zamawiający **wzywa Wykonawcę** do:

1. <<Konkretne żądanie — np.: „poprawienia Jednolitego Europejskiego Dokumentu Zamówienia (JEDZ) w Części II sekcja D poprzez zmianę odpowiedzi z «Nie» na «Tak» wraz ze wskazaniem podmiotu, któremu Wykonawca zamierza powierzyć wykonanie części zamówienia w charakterze podwykonawcy (tj. <<nazwa podmiotu>>), z określeniem zakresu powierzonych części zamówienia;">>
2. <<Kolejne żądanie>>
3. <<...>>

Oświadczenia i dokumenty uzupełniane lub składane w odpowiedzi na niniejsze wezwanie winny być aktualne na dzień ich złożenia (art. 128 ust. 3 zdanie pierwsze ustawy Pzp) oraz spełniać wymagania formalne określone w dokumentach zamówienia, w szczególności w zakresie formy elektronicznej (art. 63 ustawy Pzp) oraz wykorzystania wzorów załączników do SWZ.

### Termin

> [!important] Termin złożenia uzupełnień
> Żądane oświadczenia lub dokumenty należy złożyć w terminie **<<5 dni>> od dnia doręczenia niniejszego wezwania**, za pośrednictwem platformy zakupowej Zamawiającego — <<URL platformy>>.

### Pouczenie o skutkach

> [!warning] Skutki prawne
> Niezłożenie w wyznaczonym terminie żądanych oświadczeń lub dokumentów, złożenie ich w niekompletnej formie lub zawierających błędy, skutkować będzie **odrzuceniem oferty na podstawie art. 226 ust. 1 pkt 2 lit. c ustawy Pzp** (brak złożenia po wezwaniu wymaganych oświadczeń i środków dowodowych).
>
> Zamawiający przypomina, że zgodnie z art. 128 ust. 3 zdanie drugie ustawy Pzp **uzupełnienie, złożenie lub poprawienie oświadczenia, o którym mowa w art. 125 ust. 1, lub podmiotowych środków dowodowych nie może służyć potwierdzeniu spełniania kryteriów selekcji.** Zamawiający ocenił, że niniejsze wezwanie tego ograniczenia nie narusza.

### Zakończenie

<<Krótka formuła zakończeniowa.>>

---

## Załączniki

<<np. „nie dotyczy">>

## Otrzymują

1. <<pełna nazwa wykonawcy>>, <<adres>> — za pośrednictwem platformy zakupowej
2. a/a
