---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa>>"
wykonawca: <<nazwa>>
wykonawca_slug: <<slug-wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
typ_dokumentu: ocena-ryzyka
status: <<draft | final>>
poziom_ryzyka_ogolny: <<niski | sredni | wysoki | krytyczny>>
tags:
  - pzp/raport
  - pzp/ryzyko
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
---

# Ocena ryzyka — Oferta <<wykonawca>>

> [!info] Ogólna ocena ryzyka
> **Poziom:** <<niski | średni | wysoki | krytyczny>>
> **Uzasadnienie:** <<1–2 zdania>>

## Macierz ryzyka

| Kategoria F | Liczba | Ważność | Odwracalne | Kumulacja |
|-------------|--------|---------|------------|-----------|
| F1 — Brak nieistotny | <<N>> | Niska | ✅ | Nie |
| F2 — Wada uzupełnialna | <<N>> | Średnia | ✅ (po wezwaniu) | Nie |
| F3 — Wymagające wyjaśnień | <<N>> | Średnia | ✅ (po wezwaniu) | Nie |
| F4 — Niezgodność treści | <<N>> | Wysoka | ❌ | Tak — może prowadzić do F5 |
| F5 — Podstawa odrzucenia | <<N>> | Krytyczna | ❌ | — |
| F6 — Do analizy prawnej | <<N>> | Nieokreślona | ? | ? |

## Ryzyka per obszar

### Ryzyko R.1 — <<Tytuł>>

> [!danger] Krytyczne
> **Obszar:** <<formalny / merytoryczny / proceduralny>>
> **Kategoria F:** F<<N>>
> **Prawdopodobieństwo wystąpienia skutku:** <<niskie / średnie / wysokie>>
> **Skutek:** <<odrzucenie / wykluczenie / wezwanie / wyjaśnienie / brak skutku>>
> **Znalezisko źródłowe:** [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>#^find-XXX]]
> **Podstawa prawna:** art. <<N>> Pzp
> **Mitygacja:**
> 1. <<działanie zamawiającego>>
> 2. <<...>>

### Ryzyko R.2 — <<Tytuł>>

> [!warning] Średnie
> <<...>>

### Ryzyko R.N — <<Tytuł>>

<<...>>

---

## Scenariusze decyzyjne

### Scenariusz S.1 — Wezwanie do uzupełnienia i wyjaśnień

**Zakres wezwania:**
- art. 107 ust. 2 Pzp — przedmiotowe środki dowodowe: <<lista>>
- art. 128 ust. 1 Pzp — podmiotowe środki dowodowe: <<lista>>
- art. 223 ust. 1 Pzp — wyjaśnienia treści: <<lista>>
- art. 224 Pzp — wyjaśnienia ceny: <<lista, jeśli dotyczy>>

**Oczekiwany rezultat:** <<...>>
**Prawdopodobieństwo uzupełnienia:** <<wysokie / średnie / niskie>>

### Scenariusz S.2 — Odrzucenie oferty

**Podstawy:** art. 226 ust. 1 pkt <<...>> Pzp
**Uzasadnienie:** <<...>>
**Ryzyko odwoławcze (KIO):** <<niskie / średnie / wysokie>> — <<argumenty pro/contra>>

### Scenariusz S.3 — Wybór oferty (po ewentualnych uzupełnieniach)

**Warunki:** <<...>>
**Ryzyka pozostające:**
- <<ryzyko>>: <<mitygacja>>

### Scenariusz S.4 — Unieważnienie postępowania (jeśli wszystkie oferty obarczone wadami)

**Podstawa:** art. 255 Pzp
**Prawdopodobieństwo:** <<niskie / średnie / wysokie>>

---

## Ryzyka dla zamawiającego (wybór tej oferty)

### Ryzyko prawne

<<Np. ryzyko unieważnienia umowy, ryzyko odwołania do KIO, ryzyko kary za naruszenie dyscypliny finansów publicznych.>>

### Ryzyko realizacyjne

<<Ryzyko nieterminowego wykonania, ryzyko odstąpienia od umowy przez wykonawcę, ryzyko jakości.>>

### Ryzyko reputacyjne

<<Jeśli wykonawca lub jego dostawcy są powiązani z podmiotami objętymi sankcjami.>>

### Ryzyko finansowe

<<Cena rażąco niska → dopłaty na etapie realizacji; cena wysoka → ryzyko zarzutu nadmiernej ceny.>>

---

## Mapa cieplna ryzyk (risk heatmap)

| Obszar | Prawdopodobieństwo | Skutek | Poziom | Mitygacja |
|--------|--------------------|--------|--------|-----------|
| Formalny | <<...>> | <<...>> | 🟢/🟡/🔴 | <<...>> |
| Merytoryczny OPZ | <<...>> | <<...>> | 🟢/🟡/🔴 | <<...>> |
| Podmiotowy (JEDZ, sankcje) | <<...>> | <<...>> | 🟢/🟡/🔴 | <<...>> |
| Wadium | <<...>> | <<...>> | 🟢/🟡/🔴 | <<...>> |
| Tajemnica przedsiębiorstwa | <<...>> | <<...>> | 🟢/🟡/🔴 | <<...>> |
| Modyfikacje SWZ | <<...>> | <<...>> | 🟢/🟡/🔴 | <<...>> |

## Priorytetyzacja działań zamawiającego

| Pr. | Działanie | Podstawa | Termin | Znaleziska objęte |
|-----|-----------|----------|--------|-------------------|
| 1 | <<...>> | art. <<...>> | <<N dni>> | F-0NN, F-0NN |
| 2 | <<...>> | art. <<...>> | <<N dni>> | F-0NN |
| 3 | <<...>> | art. <<...>> | <<N dni>> | F-0NN |

## Powiązania

- [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>]]
- [[04-analiza-szczegolowa-<<slug-wykonawcy>>]]
- [[01-raport-glowny-<<slug-wykonawcy>>]]
