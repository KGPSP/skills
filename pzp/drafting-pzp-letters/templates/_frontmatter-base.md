# Frontmatter base — wspólny szablon YAML dla pism `.md`

Ten plik jest **nie-templatem** — dokumentuje pola frontmatter używane we wszystkich pismach tworzonych przez skill `drafting-pzp-letters`. Nie kopiujemy go bezpośrednio; każdy template pisma ma własny frontmatter dostosowany do typu pisma.

## Pola obligatoryjne (muszą być wypełnione w każdym piśmie)

```yaml
sygnatura_postepowania: BL-V.2371.3.2026
postepowanie: "B10: HPC/AI dla SOiA"
zamawiajacy: Komenda Główna Państwowej Straży Pożarnej
wykonawca: WASKO S.A.
wykonawca_slug: wasko
typ_pisma: wezwanie-wyjasnienia-tresci-oferty
kod_pisma: W03
podstawa_prawna:
  - "art. 223 ust. 1 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
data_pisma: 2026-04-22
miejscowosc: Warszawa
autor: claude@kg.straz.gov.pl
signatory_stanowisko: "Dyrektor Biura Informatyki i Łączności KG PSP"
signatory_tytul: "mł. bryg. mgr inż."
signatory_imie_nazwisko: "Michał Kłosiński"
signatory_zrodlo: memory  # memory | explicit
status: draft  # draft | review | final
tags:
  - pzp/pismo/<typ>  # wezwanie | zawiadomienie | odrzucenie | wykluczenie
  - pzp/sygnatura/<slug-sygnatury>
  - pzp/wykonawca/<slug-wykonawcy>
```

## Pola opcjonalne (wypełniaj, gdy dotyczą)

```yaml
# Adres fizyczny wykonawcy (do polowy "Adresat"; jeśli nieznany — zostaw puste i dodaj adnotację w metryce)
adres_wykonawcy: "ul. Berbeckiego 6, 44-100 Gliwice"

# Wykaz znalezisk z 03-braki-i-niezgodnosci-<slug>.md — block IDs lub kody K*
znaleziska_powiazane:
  - K5.1
  - K5.2
  - K7.2

# Tylko dla wezwań (W01-W11) i Z03
termin_odpowiedzi: "5 dni od doręczenia"
termin_szczegolowy: "do dnia 2026-04-30 do godz. 23:59"  # opcjonalnie, konkretna data

# Sygnatura pisma zamawiającego (generowana z sygnatury postępowania + kodu pisma)
sygnatura_pisma: "BL-V.2371.3.2026.W03"

# Poziom pewności oceny prawnej (wysoki = pełne wsparcie w dokumentach, niski = wymaga analizy prawnika)
poziom_pewnosci: wysoki  # wysoki | średni | niski

# Wskaźniki ryzyka prawnego (tylko gdy relevant)
ryzyko_odrzucenia_po_W03: średnie  # dla F4 eskalowanych przez W03
wymaga_weryfikacji_self_cleaning: true  # tylko O02
wymaga_weryfikacji_SWZ_art_107_ust_2: true  # tylko W02

# Tylko dla O01 i O02
podstawa_odrzucenia_pkt: "pkt 5"  # O01 — numer punktu art. 226 ust. 1
podstawa_wykluczenia_art: "art. 108 ust. 1 pkt 1 lit. a Pzp"  # O02
self_cleaning_zweryfikowany: true  # O02 — czy sprawdzono art. 110

# Odwołanie do KIO (dla O01, O02, Z05)
termin_odwolania_dni: 10  # 10 dla procedury unijnej, 5 dla trybu podstawowego
```

## Pola computed (generowane przez skill, nie wpisywane ręcznie)

```yaml
data_utworzenia: 2026-04-22T15:30:00+02:00
liczba_znalezisk: 3
liczba_zadan: 7
liczba_zalacznikow: 0
```

## Konwencje wartości enum

**`typ_pisma`:**
- `wezwanie-uzupelnienie-podmiotowe` (W01)
- `wezwanie-uzupelnienie-przedmiotowe` (W02)
- `wezwanie-wyjasnienia-tresci-oferty` (W03)
- `wezwanie-wyjasnienia-podmiotowe` (W04)
- `wezwanie-wyjasnienia-razaco-niska-cena` (W05)
- `wezwanie-wyjasnienia-tajemnica` (W06)
- `wezwanie-zlozenie-sd-najwyzej-oceniona` (W07)
- `wezwanie-przedluzenie-tzo` (W08)
- `wezwanie-przedluzenie-wadium` (W09)
- `wezwanie-wymiana-podmiotu-trzeciego` (W10)
- `wezwanie-wyjasnienia-certyfikat` (W11)
- `zawiadomienie-poprawa-omylki-pisarskiej` (Z01)
- `zawiadomienie-poprawa-omylki-rachunkowej` (Z02)
- `zawiadomienie-poprawa-omylki-innej` (Z03)
- `zawiadomienie-wybor-oferty` (Z04)
- `zawiadomienie-uniewaznienie` (Z05)
- `informacja-odrzucenie` (O01)
- `informacja-wykluczenie` (O02)

**`kod_pisma`:** jedna z 18 wartości W01-W11, Z01-Z05, O01-O02.

**`signatory_zrodlo`:**
- `memory` — wartość wzięta z auto-memory użytkownika (domyślnie: Michał Kłosiński dla KG PSP). **Obligatoryjna adnotacja w metryce**: „Signatory domyślny z memory. Zweryfikuj przed podpisem."
- `explicit` — wartość podana wprost przez użytkownika w parametrze `<signatory>`.

**`status`:**
- `draft` — projekt; niegotowy do podpisu.
- `review` — projekt do weryfikacji (przez prawnika, zamawiającego).
- `final` — gotowy do podpisu; zgodny z wszystkimi regułami skilla.

**`poziom_pewnosci`:**
- `wysoki` — wszystkie znaleziska potwierdzone cytatami z dokumentów, jednoznaczna podstawa prawna, brak luk w materiale.
- `średni` — 1-2 znaleziska wymagają dodatkowej weryfikacji (np. orzecznictwo KIO, interpretacja SWZ); podstawa prawna jednoznaczna.
- `niski` — materiał niekompletny, interpretacja dyskusyjna, zalecana konsultacja prawnika przed wysłaniem pisma.

## Tagi Obsidian — konwencja

Każde pismo ma co najmniej 3 tagi:

```yaml
tags:
  - pzp/pismo/wezwanie  # lub: pzp/pismo/zawiadomienie / pzp/pismo/odrzucenie / pzp/pismo/wykluczenie
  - pzp/sygnatura/BL-V-2371-3-2026  # slug sygnatury (myślniki zamiast kropek)
  - pzp/wykonawca/wasko  # slug wykonawcy
```

Dodatkowe tagi (opcjonalne):

```yaml
  - pzp/kod/W03  # kod pisma dla szybkiego filtrowania
  - pzp/priorytet/wysoki  # gdy znaleziska F4/F5
  - pzp/status/draft
```

## Przykład kompletnego frontmatter (pismo W03 dla WASKO)

```yaml
---
sygnatura_postepowania: BL-V.2371.3.2026
postepowanie: "B10: HPC/AI dla SOiA"
zamawiajacy: Komenda Główna Państwowej Straży Pożarnej
wykonawca: WASKO S.A.
wykonawca_slug: wasko
adres_wykonawcy: "ul. Berbeckiego 6, 44-100 Gliwice"
typ_pisma: wezwanie-wyjasnienia-tresci-oferty
kod_pisma: W03
podstawa_prawna:
  - "art. 223 ust. 1 ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
znaleziska_powiazane:
  - K5.1
  - K5.2
  - K5.3
  - K6.1
  - K7.1
  - K7.2
  - K7.3
  - K7.4
  - K7.5
  - K7.6
  - K4.1
  - K4.2
termin_odpowiedzi: "5 dni od doręczenia"
sygnatura_pisma: "BL-V.2371.3.2026.W03"
data_pisma: 2026-04-22
miejscowosc: Warszawa
autor: claude@kg.straz.gov.pl
signatory_stanowisko: "Dyrektor Biura Informatyki i Łączności KG PSP"
signatory_tytul: "mł. bryg. mgr inż."
signatory_imie_nazwisko: "Michał Kłosiński"
signatory_zrodlo: memory
status: draft
poziom_pewnosci: wysoki
tags:
  - pzp/pismo/wezwanie
  - pzp/sygnatura/BL-V-2371-3-2026
  - pzp/wykonawca/wasko
  - pzp/kod/W03
---
```
