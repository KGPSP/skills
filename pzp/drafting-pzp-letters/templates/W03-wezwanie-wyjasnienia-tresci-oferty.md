---
sygnatura_postepowania: <<np. BL-V.2371.3.2026>>
postepowanie: <<pełna nazwa postępowania z ogłoszenia>>
zamawiajacy: <<pełna nazwa zamawiającego>>
wykonawca: <<pełna nazwa wykonawcy z oferty>>
wykonawca_slug: <<slug-wykonawcy>>
adres_wykonawcy: <<ulica, kod pocztowy, miasto>>
typ_pisma: wezwanie-wyjasnienia-tresci-oferty
kod_pisma: W03
podstawa_prawna:
  - "art. 223 ust. 1 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
znaleziska_powiazane:
  - <<np. K5.1>>
  - <<np. K5.2>>
termin_odpowiedzi: "5 dni od doręczenia"
sygnatura_pisma: <<np. BL-V.2371.3.2026.W03>>
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
  - pzp/pismo/wezwanie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
  - pzp/kod/W03
---

# W03 — Wezwanie do wyjaśnień treści oferty

**Dane do szablonu DOCX (wypełniane w `wzor_pismo_przewodnie.docx`):**

| Pole szablonu | Wartość |
|---------------|---------|
| `ezdSprawaZnak` / `$sygnatura pisma` | `<<sygnatura_pisma>>` |
| `ezdDataPodpisu` / `$DataPodpisu` | `<<data_pisma w formacie: 22 kwietnia 2026>>` |
| `[adresat]` | **<<pełna nazwa wykonawcy>>**, <<adres wykonawcy>> |
| `ezdPracownikAtrybut1` / `$stanowisko` | `<<signatory_stanowisko>>` |
| `ezdPracownikAtrybut2` / `$tytuł` | `<<signatory_tytul>>` |
| `ezdPracownikNazwa` / `$imię i nazwisko` | `<<signatory_imie_nazwisko>>` |

---

## Treść pisma (wstaw do body szablonu DOCX)

> [!info] Uwaga redakcyjna
> Tekst poniżej jest gotową treścią merytoryczną do wstawienia w szablon DOCX w miejscu akapitów „Wstęp do pisma..." i „Rozwinięcie i zasadnicza treść pisma...". Nagłówek, sygnatura, data, adresat i podpis są wypełniane osobno przez zakładki EZD / placeholdery `$...`.

**Dotyczy:** postępowania o udzielenie zamówienia publicznego pn. „<<postepowanie>>", znak sprawy: **<<sygnatura_postepowania>>**.

### Wstęp

Działając na podstawie art. 223 ust. 1 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.), zwanej dalej „ustawą Pzp", w toku badania i oceny oferty złożonej przez Wykonawcę — <<pełna nazwa wykonawcy>> — w postępowaniu wskazanym powyżej, Zamawiający niniejszym **wzywa Wykonawcę do złożenia wyjaśnień dotyczących treści oferty** w zakresie wskazanym poniżej.

Zamawiający przypomina, że zgodnie z art. 223 ust. 1 zdanie drugie ustawy Pzp **niedopuszczalne jest prowadzenie między zamawiającym a wykonawcą negocjacji dotyczących złożonej oferty oraz, z zastrzeżeniem art. 223 ust. 2 i art. 187 ustawy Pzp, dokonywanie jakiejkolwiek zmiany w jej treści.** Wyjaśnienia mają służyć wyłącznie doprecyzowaniu treści, które JUŻ znajdują się w ofercie; nie mogą one uzupełniać brakujących elementów oferty ani zmieniać jej treści.

### Stan faktyczny — elementy oferty wymagające wyjaśnienia

<!-- Dla każdego znaleziska F3/F4 powiąż cytat wymogu SWZ/OPZ z cytatem z oferty wykonawcy. Bezwzględnie używaj formatu [DOC: plik] [str. N]. Nie pomijaj lokalizacji. -->

#### 1. <<Temat znaleziska nr 1 — np. Parametr środowiskowy klasy ASHRAE w Części A.1 OPZ>>

**Wymóg Zamawiającego:**

> [!quote]
> <<Dosłowny cytat wymogu z SWZ/OPZ/odpowiedzi na pytania>>
> `[DOC: <<plik>>] [Rozdz./Część <<X>>] [pkt <<Y>>] [str. <<N>>]`

**Stan faktyczny oferty:**

> [!quote]
> <<Dosłowny cytat z oferty wykonawcy>>
> `[DOC: <<plik oferty>>] [str. <<N>>]`

**Zagadnienie wymagające wyjaśnienia:** <<Opis niespójności / niejasności treści oferty — 2-3 zdania wyjaśniające, w czym konkretnie jest problem. Bez ozdobników, formalnie, rzeczowo.>>

#### 2. <<Temat znaleziska nr 2>>

<!-- Ta sama struktura: Wymóg Zamawiającego + Stan faktyczny oferty + Zagadnienie -->

#### <<...>>

<!-- Kontynuuj dla każdego F3/F4 z 03-braki-i-niezgodnosci-<slug>.md, które zostało zgrupowane do pisma W03 -->

### Żądanie

Mając na uwadze powyższe, Zamawiający **wzywa Wykonawcę do złożenia wyjaśnień** dotyczących treści oferty w następującym zakresie:

1. <<Żądanie dotyczące znaleziska nr 1 — w imperatywie normatywnym, precyzyjnie. Np.: „wyjaśnienie, czy oferowane serwery obliczeniowe z procesorami NVIDIA HGX B300 spełniają wymóg klasy ASHRAE A1 lub lepszej, o którym mowa w Części A.1 OPZ, w tym — w razie potrzeby — wskazanie warunków eksploatacji (np. zawężenie temperatury wlotowej), przy których parametr ten jest dotrzymany;">>
2. <<Żądanie dotyczące znaleziska nr 2>>
3. <<...>>

Do każdego z żądanych wyjaśnień Wykonawca może załączyć dowody (karty katalogowe, noty techniczne producenta, oświadczenia producenta, inne dokumenty), które potwierdzają lub dokumentują treść wyjaśnień, w zakresie, w jakim nie prowadzą one do zmiany treści oferty.

### Termin

> [!important] Termin złożenia wyjaśnień
> Wyjaśnienia wraz z ewentualnymi dowodami należy złożyć w terminie **<<5 dni>> od dnia doręczenia niniejszego wezwania**, za pośrednictwem platformy zakupowej Zamawiającego — <<URL platformy, np. https://platformazakupowa.pl/...>>.

### Pouczenie o skutkach

> [!warning] Skutki prawne
> Niezłożenie wyjaśnień w wyznaczonym terminie, złożenie wyjaśnień w niepełnym zakresie lub złożenie wyjaśnień, które nie uzasadniają zgodności treści oferty z wymaganiami dokumentów zamówienia, może skutkować **odrzuceniem oferty na podstawie art. 226 ust. 1 pkt 5 ustawy Pzp** (niezgodność treści oferty z warunkami zamówienia) lub art. 226 ust. 1 pkt 2 lit. c ustawy Pzp, jeżeli wyjaśnienia nie zostaną złożone.
>
> Ponadto Zamawiający przypomina, że wyjaśnienia nie mogą prowadzić do zmiany treści oferty ani do negocjacji jej warunków; nieuprawnione wyjaśnienia skutkujące zmianą treści oferty będą traktowane jako niedopuszczalne w świetle art. 223 ust. 1 zdanie drugie ustawy Pzp.

### Zakończenie

<<Krótka formuła zakończeniowa, np.: „Jednocześnie Zamawiający informuje, że wynik niniejszego wezwania wpłynie na dalszą ocenę oferty w postępowaniu.">>

---

## Załączniki

<!-- Wypełnij tylko gdy są załączniki. W przypadku wezwania do wyjaśnień treści oferty — zazwyczaj brak załączników. -->

<<np. „nie dotyczy" lub lista, np.:
1. Kopia formularza oferty z oznaczonymi miejscami wymagającymi wyjaśnień.>>

## Otrzymują

1. <<pełna nazwa wykonawcy>>, <<adres>> — za pośrednictwem platformy zakupowej
2. a/a
