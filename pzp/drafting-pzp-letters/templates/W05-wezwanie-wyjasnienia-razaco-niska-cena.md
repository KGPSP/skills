---
sygnatura_postepowania: <<np. BL-V.2371.3.2026>>
postepowanie: <<pełna nazwa postępowania z ogłoszenia>>
zamawiajacy: <<pełna nazwa zamawiającego>>
wykonawca: <<pełna nazwa wykonawcy z oferty>>
wykonawca_slug: <<slug-wykonawcy>>
adres_wykonawcy: <<ulica, kod pocztowy, miasto>>
typ_pisma: wezwanie-wyjasnienia-razaco-niska-cena
kod_pisma: W05
podstawa_prawna:
  - "art. 224 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
termin_odpowiedzi: "5 dni od doręczenia"
sygnatura_pisma: <<np. BL-V.2371.3.2026.W05>>
data_pisma: <<YYYY-MM-DD>>
miejscowosc: Warszawa
autor: <<email autora analizy>>
signatory_stanowisko: <<np. Dyrektor Biura Informatyki i Łączności KG PSP>>
signatory_tytul: <<np. mł. bryg. mgr inż.>>
signatory_imie_nazwisko: <<np. Michał Kłosiński>>
signatory_zrodlo: <<memory | explicit>>
cena_oferty_brutto: <<XX XXX XXX,XX zł>>
wartosc_szacunkowa_brutto: <<XX XXX XXX,XX zł>>  # wartość zamówienia + VAT (art. 224 ust. 2 pkt 1)
srednia_cen_ofert: <<XX XXX XXX,XX zł>>  # średnia arytmetyczna cen ofert niepodlegających odrzuceniu (art. 224 ust. 2 pkt 2)
odchylenie_procentowe: <<XX%>>  # minimum 30% — próg uruchomienia art. 224 ust. 2
status: draft
poziom_pewnosci: <<wysoki | średni | niski>>
tags:
  - pzp/pismo/wezwanie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
  - pzp/kod/W05
---

# W05 — Wezwanie do złożenia wyjaśnień w zakresie ceny oferty (art. 224 Pzp)

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

Działając na podstawie art. 224 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.), zwanej dalej „ustawą Pzp", w toku badania i oceny oferty złożonej przez Wykonawcę — <<pełna nazwa wykonawcy>> — w postępowaniu wskazanym powyżej, Zamawiający powziął uzasadnione wątpliwości co do możliwości wykonania przedmiotu zamówienia zgodnie z wymaganiami określonymi w dokumentach zamówienia za zaoferowaną cenę. W związku z powyższym Zamawiający niniejszym **żąda od Wykonawcy wyjaśnień, w tym złożenia dowodów, w zakresie wyliczenia ceny oferty oraz jej istotnych części składowych.**

### Okoliczności uzasadniające wezwanie

Cena oferty złożonej przez Wykonawcę wynosi **<<cena_oferty_brutto>>** brutto.

<!-- Wybierz jedną z dwóch podstaw uruchomienia art. 224 ust. 2: -->

<!-- OPCJA A — odchylenie od wartości zamówienia + VAT -->

Zamawiający przeznaczył na sfinansowanie zamówienia kwotę stanowiącą wartość zamówienia powiększoną o należny podatek od towarów i usług w wysokości **<<wartosc_szacunkowa_brutto>>**. Zaoferowana cena jest niższa od tej kwoty o **<<odchylenie_procentowe>>**, co przekracza próg 30% wskazany w art. 224 ust. 2 pkt 1 ustawy Pzp.

<!-- OPCJA B — odchylenie od średniej -->

Średnia arytmetyczna cen wszystkich ofert niepodlegających odrzuceniu na podstawie art. 226 ust. 1 pkt 1, 5a oraz 10 ustawy Pzp w niniejszym postępowaniu wynosi **<<srednia_cen_ofert>>**. Zaoferowana cena jest niższa od tej średniej o **<<odchylenie_procentowe>>**, co przekracza próg 30% wskazany w art. 224 ust. 2 pkt 2 ustawy Pzp.

### Żądanie

Zamawiający **wzywa Wykonawcę do złożenia wyjaśnień**, w tym dowodów w zakresie wyliczenia ceny lub jej istotnych części składowych, z uwzględnieniem w szczególności poniższych okoliczności (art. 224 ust. 3 pkt 1–8 ustawy Pzp):

1. **zarządzania procesem produkcji, świadczonych usług lub metody budowy**,
2. **wybranych rozwiązań technicznych, wyjątkowo korzystnych warunków dostaw, usług albo związanych z realizacją robót budowlanych**,
3. **oryginalności dostaw, usług lub robót budowlanych oferowanych przez wykonawcę**,
4. **zgodności z przepisami dotyczącymi kosztów pracy, których wartość przyjęta do ustalenia ceny nie może być niższa od minimalnego wynagrodzenia za pracę albo minimalnej stawki godzinowej** (ustalonych na podstawie ustawy z dnia 10 października 2002 r. o minimalnym wynagrodzeniu za pracę lub przepisów odrębnych właściwych dla spraw, z którymi związane jest realizowane zamówienie),
5. **zgodności z prawem w rozumieniu przepisów o postępowaniu w sprawach dotyczących pomocy publicznej**,
6. **zgodności z przepisami z zakresu prawa pracy i zabezpieczenia społecznego, obowiązującymi w miejscu, w którym realizowane jest zamówienie**,
7. **zgodności z przepisami z zakresu ochrony środowiska**,
8. **wypełniania obowiązków związanych z powierzeniem wykonania części zamówienia podwykonawcy**.

> [!warning] Obligatoryjny zakres dla RB/usług (art. 224 ust. 4 Pzp)
> W przypadku zamówień na **roboty budowlane lub usługi** Zamawiający jest **obowiązany** żądać wyjaśnień co najmniej w zakresie pkt 4 i 6 (koszty pracy + prawo pracy/ubezpieczenia społeczne).

Wyjaśnienia winny zawierać w szczególności:

- kalkulację ceny oferty z wyodrębnieniem kosztów bezpośrednich, pośrednich, marży i rezerw,
- podział ceny na istotne części składowe (np. dostawa sprzętu, instalacja, uruchomienie, szkolenie, wsparcie techniczne, gwarancja, licencje, koszty transportu i instalacji) — w rozbiciu umożliwiającym weryfikację,
- dowody potwierdzające wskazane przez Wykonawcę okoliczności uzasadniające możliwość wykonania zamówienia za zaoferowaną cenę (oferty dostawców / producentów, porozumienia handlowe, wyliczenia kosztów osobowych, zaświadczenia, kalkulacje).

### Ciężar dowodu

> [!warning] Obowiązek wykonawcy
> Zgodnie z art. 224 ust. 5 ustawy Pzp **obowiązek wykazania, że oferta nie zawiera rażąco niskiej ceny lub kosztu, spoczywa na Wykonawcy**. Wyjaśnienia ogólnikowe, nieprzedstawiające konkretnej kalkulacji lub nieodnoszące się do elementów wskazanych w art. 224 ust. 3 ustawy Pzp, nie będą uznane za wystarczające.

### Termin

> [!important] Termin złożenia wyjaśnień
> Wyjaśnienia wraz z dowodami należy złożyć w terminie **5 dni od dnia doręczenia niniejszego wezwania**, za pośrednictwem platformy zakupowej Zamawiającego — <<URL platformy>>.

### Pouczenie o skutkach

> [!warning] Skutki prawne
> Zgodnie z art. 224 ust. 6 ustawy Pzp: „Odrzuceniu, jako oferta z rażąco niską ceną lub kosztem, podlega oferta wykonawcy, który nie udzielił wyjaśnień w wyznaczonym terminie lub jeżeli złożone wyjaśnienia wraz z dowodami nie uzasadniają podanej w ofercie ceny lub kosztu."
>
> W przypadku niezłożenia wyjaśnień lub złożenia wyjaśnień niewystarczających dla potwierdzenia, że oferta nie zawiera rażąco niskiej ceny lub kosztu, **oferta Wykonawcy podlega odrzuceniu na podstawie art. 226 ust. 1 pkt 8 ustawy Pzp**.

### Zakończenie

<<Krótka formuła zakończeniowa.>>

---

## Załączniki

<<np. „nie dotyczy">>

## Otrzymują

1. <<pełna nazwa wykonawcy>>, <<adres>> — za pośrednictwem platformy zakupowej
2. a/a
