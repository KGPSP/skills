---
sygnatura_postepowania: <<np. BL-V.2371.3.2026>>
postepowanie: <<pełna nazwa postępowania z ogłoszenia>>
zamawiajacy: <<pełna nazwa zamawiającego>>
wykonawca: <<pełna nazwa wykonawcy z oferty>>
wykonawca_slug: <<slug-wykonawcy>>
adres_wykonawcy: <<ulica, kod pocztowy, miasto>>
typ_pisma: wezwanie-uzupelnienie-przedmiotowe
kod_pisma: W02
podstawa_prawna:
  - "art. 107 ust. 2 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
znaleziska_powiazane:
  - <<np. K4.3>>
termin_odpowiedzi: "5 dni od doręczenia"
sygnatura_pisma: <<np. BL-V.2371.3.2026.W02>>
data_pisma: <<YYYY-MM-DD>>
miejscowosc: Warszawa
autor: <<email autora analizy>>
signatory_stanowisko: <<np. Dyrektor Biura Informatyki i Łączności KG PSP>>
signatory_tytul: <<np. mł. bryg. mgr inż.>>
signatory_imie_nazwisko: <<np. Michał Kłosiński>>
signatory_zrodlo: <<memory | explicit>>
status: draft
poziom_pewnosci: <<wysoki | średni | niski>>
zweryfikowano_SWZ_art_107_ust_2: true  # PRZED W02 MUSISZ sprawdzić, czy SWZ/ogłoszenie przewidują uzupełnienie przedmiotowych ś.d.
zweryfikowano_art_107_ust_3: true      # PRZED W02 sprawdź, czy ś.d. nie służy kryteriom oceny ofert
tags:
  - pzp/pismo/wezwanie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
  - pzp/kod/W02
---

# W02 — Wezwanie do złożenia lub uzupełnienia przedmiotowych środków dowodowych

> [!danger] Precondition check — PRZED WYSŁANIEM
> 1. **Czy SWZ lub ogłoszenie o zamówieniu przewiduje możliwość uzupełniania przedmiotowych środków dowodowych (art. 107 ust. 2 zd. 2 Pzp)?** Jeśli NIE → pismo W02 jest NIEDOPUSZCZALNE; rozważyć O01 (odrzucenie z art. 226 ust. 1 pkt 5).
> 2. **Czy przedmiotowy ś.d. NIE służy potwierdzeniu zgodności z kryteriami oceny ofert (art. 107 ust. 3 Pzp)?** Jeśli służy kryteriom oceny → pismo W02 jest NIEDOPUSZCZALNE; rozważyć O01.
> 3. **Czy oferta nie podlega odrzuceniu z innych przyczyn?** Jeśli tak → wezwanie jest bezprzedmiotowe.
>
> Potwierdź powyższe w pliku `04-analiza-szczegolowa-<slug>.md` sekcja B (punkt dot. przedmiotowych ś.d.) i ustaw flagi `zweryfikowano_*` w frontmatterze na `true`. Bez tej weryfikacji — nie wysyłaj pisma.

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

Działając na podstawie art. 107 ust. 2 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.), zwanej dalej „ustawą Pzp", w toku badania i oceny oferty złożonej przez Wykonawcę — <<pełna nazwa wykonawcy>> — w postępowaniu wskazanym powyżej, Zamawiający niniejszym **wzywa Wykonawcę do złożenia lub uzupełnienia przedmiotowych środków dowodowych** w zakresie wskazanym poniżej.

Zamawiający przewidział możliwość wezwania do złożenia lub uzupełnienia przedmiotowych środków dowodowych, o której mowa w art. 107 ust. 2 ustawy Pzp, w: <<cytat z SWZ lub ogłoszenia + lokalizacja, np. `[DOC: SWZ.pdf] [Rozdz. V] [ust. 3] [str. 7]`>>.

### Stan faktyczny

<!-- Dla każdego przedmiotowego ś.d. F2p: cytat wymogu SWZ/OPZ + cytat z oferty (lub stwierdzenie braku) + kwalifikacja (brak/niekompletny) -->

#### 1. <<Nazwa przedmiotowego środka dowodowego — np. Plan i metodyka testów FAT/SAT (Część A pkt A.10 OPZ)>>

**Wymóg Zamawiającego:**

> [!quote]
> <<Cytat z OPZ lub SWZ — pełny zakres wymaganej treści przedmiotowego ś.d.>>
> `[DOC: <<plik>>] [Rozdz./Część <<X>>] [pkt <<Y>>] [str. <<N>>]`

**Stan faktyczny oferty:**

> [!quote]
> <<Cytat z oferty lub stwierdzenie braku — np. „Wykonawca złożył wyłącznie plan testów UPS, Agregatu i ATS; brak metodyki testów HPS, sieci, klastra GPU/CPU oraz LLM Inference SAT Benchmark.">>
> `[DOC: <<plik oferty>>] [str. <<N>>]`

**Charakter braku / niekompletności:** <<„brak dokumentu" / „dokument niekompletny — brak wymaganych elementów" / „dokument nieaktualny" — wskaż jednoznacznie.>>

#### 2. <<Kolejny przedmiotowy ś.d.>>

<!-- Ta sama struktura -->

### Żądanie

Mając na uwadze powyższe, Zamawiający **wzywa Wykonawcę** do:

1. <<Konkretne żądanie, np.: „uzupełnienia Planu i metodyki testów FAT/SAT o metodykę testów: (a) wysokowydajnego systemu pamięci masowej (HPS) — narzędzia i kryteria akceptacji zgodne z Częścią A pkt A.3 OPZ oraz doprecyzowaniami udzielonymi w odpowiedziach na pytania nr 2_5 z dnia 8 kwietnia 2026 r., (b) testów sieci compute fabric — zgodnych z Częścią A pkt A.2 OPZ (NCCL all-reduce itp.), (c) testów klastra GPU/CPU zgodnie z Częścią A pkt A.1 OPZ oraz (d) LLM Inference SAT Benchmark zgodnie z Częścią A pkt A.10.X OPZ.">>
2. <<Kolejne żądanie>>

Uzupełnione przedmiotowe środki dowodowe powinny spełniać wymagania określone w SWZ/OPZ, w tym wymagania co do formy elektronicznej zgodnie z art. 63 ustawy Pzp.

### Termin

> [!important] Termin złożenia uzupełnień
> Żądane przedmiotowe środki dowodowe należy złożyć w terminie **<<5 dni>> od dnia doręczenia niniejszego wezwania**, za pośrednictwem platformy zakupowej Zamawiającego — <<URL platformy>>.

### Pouczenie o skutkach

> [!warning] Skutki prawne
> Niezłożenie żądanych przedmiotowych środków dowodowych w wyznaczonym terminie, ich niekompletność lub niespełnienie wymagań SWZ/OPZ, skutkować będzie odpowiednio:
>
> a) **odrzuceniem oferty na podstawie art. 226 ust. 1 pkt 2 lit. c ustawy Pzp** (brak złożenia po wezwaniu wymaganych środków dowodowych), lub
>
> b) **odrzuceniem oferty na podstawie art. 226 ust. 1 pkt 5 ustawy Pzp** (niezgodność treści oferty z warunkami zamówienia), w razie gdy niezłożenie lub niekompletność środka dowodowego uniemożliwia potwierdzenie zgodności oferty z wymaganiami Zamawiającego.

### Zakończenie

<<Krótka formuła zakończeniowa.>>

---

## Załączniki

<<np. „nie dotyczy">>

## Otrzymują

1. <<pełna nazwa wykonawcy>>, <<adres>> — za pośrednictwem platformy zakupowej
2. a/a
