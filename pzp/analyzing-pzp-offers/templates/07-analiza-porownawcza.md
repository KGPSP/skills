---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa>>"
zamawiajacy: <<zamawiajacy>>
data_analizy: <<yyyy-mm-dd>>
typ_dokumentu: analiza-porownawcza
status: <<draft | final>>
liczba_wykonawcow: <<N>>
wykonawcy:
  - <<wykonawca 1>>
  - <<wykonawca 2>>
  - <<wykonawca N>>
tags:
  - pzp/raport
  - pzp/porownanie
  - pzp/sygnatura/<<slug-sygnatury>>
---

# Analiza porównawcza ofert — Postępowanie <<sygnatura>>

> [!info] Zakres dokumentu
> Porównanie wszystkich złożonych ofert: punktacja kryteriów, braki, ryzyka, ranking wstępny (przed wezwaniami) oraz ranking warunkowy (po ewentualnych uzupełnieniach). Wskazanie oferty najkorzystniejszej.

## Sekcja 1. Zestawienie ogólne

| Parametr | <<Wykonawca 1>> | <<Wykonawca 2>> | <<Wykonawca N>> |
|----------|-----------------|-----------------|-----------------|
| NIP | <<...>> | <<...>> | <<...>> |
| Status MŚP | <<...>> | <<...>> | <<...>> |
| Cena brutto | <<kwota>> | <<kwota>> | <<kwota>> |
| Cena netto | <<...>> | <<...>> | <<...>> |
| Okres gwarancji (mies.) | <<N>> | <<N>> | <<N>> |
| Termin realizacji | <<data>> | <<data>> | <<data>> |
| Wadium | <<forma/kwota>> | <<...>> | <<...>> |
| Podmiot trzeci | <<nazwa / n/d>> | <<...>> | <<...>> |
| Data złożenia | <<data>> | <<...>> | <<...>> |
| Tajemnica przedsiębiorstwa | <<tak/nie>> | <<...>> | <<...>> |

## Sekcja 2. Punktacja kryteriów oceny

> Podstawa: SWZ Rozdział <<N>> — kryteria oceny ofert (wzór punktacji).

### Kryterium 1 — Cena (waga <<N>> pkt)

**Wzór:** <<wzór z SWZ, np. `Pc = (C_min / C_i) × 80`>>
**C_min:** <<najniższa cena brutto>> zł
**C_max:** <<najwyższa cena>> zł

| Wykonawca | Cena brutto | Punkty |
|-----------|-------------|--------|
| <<W1>> | <<...>> | <<...>> |
| <<W2>> | <<...>> | <<...>> |

### Kryterium 2 — Okres gwarancji (waga <<N>> pkt)

**Wzór:** <<np. `Pg = ((G_i − 36) / (60 − 36)) × 20`>>

| Wykonawca | Gwarancja (mies.) | Punkty |
|-----------|---------------------|--------|
| <<W1>> | <<N>> | <<...>> |
| <<W2>> | <<N>> | <<...>> |

### Suma punktów

| Wykonawca | Cena | Gwarancja | Suma | Pozycja |
|-----------|------|-----------|------|---------|
| <<W1>> | <<N>> | <<N>> | <<N>> | 1 |
| <<W2>> | <<N>> | <<N>> | <<N>> | 2 |
| <<W3>> | <<N>> | <<N>> | <<N>> | 3 |

## Sekcja 3. Porównanie kompletności i formalności

| Wymóg | <<W1>> | <<W2>> | <<W3>> |
|-------|--------|--------|--------|
| Formularz oferty | ✅/⚠️/❌ | ✅/⚠️/❌ | ✅/⚠️/❌ |
| JEDZ wykonawcy | ✅/⚠️/❌ | ✅/⚠️/❌ | ✅/⚠️/❌ |
| OPZ wypełniony | ✅/⚠️/❌ | ✅/⚠️/❌ | ✅/⚠️/❌ |
| Karty katalogowe | ✅/⚠️/❌ | ✅/⚠️/❌ | ✅/⚠️/❌ |
| Wadium | ✅/⚠️/❌ | ✅/⚠️/❌ | ✅/⚠️/❌ |
| Zał. 9 (sankcje wyk.) | ✅/⚠️/❌ | ✅/⚠️/❌ | ✅/⚠️/❌ |
| Zał. 10 (sankcje pod.3) | ✅/⚠️/❌/⬜ | ✅/⚠️/❌/⬜ | ✅/⚠️/❌/⬜ |
| Pełnomocnictwo | ✅/⚠️/❌/⬜ | ✅/⚠️/❌/⬜ | ✅/⚠️/❌/⬜ |
| Tajemnica przeds. — skut. zastrzeż. | ✅/⚠️/❌/⬜ | ✅/⚠️/❌/⬜ | ✅/⚠️/❌/⬜ |

## Sekcja 4. Porównanie parametrów technicznych OPZ

### Część A — <<nazwa>>

| Pkt OPZ | Wymaganie min. | <<W1>> | <<W2>> | <<W3>> |
|---------|------------------|--------|--------|--------|
| A.1 | <<param>> | <<...>> | <<...>> | <<...>> |
| A.2 | <<param>> | <<...>> | <<...>> | <<...>> |
| ... | ... | ... | ... | ... |

### Część B — <<nazwa>>

| Pkt OPZ | Wymaganie | <<W1>> | <<W2>> | <<W3>> |
|---------|-----------|--------|--------|--------|
| B.1 | <<...>> | <<...>> | <<...>> | <<...>> |

### Część C — <<nazwa>>

| Pkt OPZ | Wymaganie | <<W1>> | <<W2>> | <<W3>> |
|---------|-----------|--------|--------|--------|
| C.1 | <<...>> | <<...>> | <<...>> | <<...>> |

## Sekcja 5. Porównanie ryzyk

| Kategoria F | <<W1>> | <<W2>> | <<W3>> |
|-------------|--------|--------|--------|
| F1 | <<N>> | <<N>> | <<N>> |
| F2 | <<N>> | <<N>> | <<N>> |
| F3 | <<N>> | <<N>> | <<N>> |
| F4 | <<N>> | <<N>> | <<N>> |
| F5 | <<N>> | <<N>> | <<N>> |
| F6 | <<N>> | <<N>> | <<N>> |
| **Łączne ryzyko** | 🟢/🟡/🔴 | 🟢/🟡/🔴 | 🟢/🟡/🔴 |

## Sekcja 6. Ranking wstępny (przed wezwaniami)

| Poz. | Wykonawca | Punkty | Status |
|------|-----------|--------|--------|
| 1 | <<...>> | <<N>> | <<kompletna / wymaga wezwań / ryzyko odrzucenia>> |
| 2 | <<...>> | <<N>> | <<...>> |
| 3 | <<...>> | <<N>> | <<...>> |

## Sekcja 7. Ranking warunkowy (po ewentualnych uzupełnieniach)

> Zakłada pomyślne uzupełnienia w trybach art. 107 ust. 2 / 128 ust. 1 / 223 / 224 Pzp.

| Poz. | Wykonawca | Punkty (niezm.) | Wymagane wezwania | Prawdopodobieństwo uzupełnienia |
|------|-----------|------------------|-------------------|--------------------------------|
| 1 | <<...>> | <<N>> | <<lista>> | <<wysokie / średnie / niskie>> |
| 2 | <<...>> | <<N>> | <<lista>> | <<...>> |
| 3 | <<...>> | <<N>> | <<lista>> | <<...>> |

## Sekcja 8. Oferta najkorzystniejsza

> [!<<success|warning|failure>>] Rekomendacja
>
> **Oferta najkorzystniejsza (wstępnie):** <<nazwa wykonawcy>>
> **Uzasadnienie:** <<...>>
>
> **Ryzyka wyboru tej oferty:**
> - <<ryzyko 1>>
> - <<ryzyko 2>>
>
> **Wymagane wezwania przed wyborem:**
> - <<...>>

## Sekcja 9. „Odwrócona" kolejność oceny (art. 139 Pzp)

<<Jeśli postępowanie prowadzone w trybie „odwróconym": kolejność badania ofert, kiedy badać podmiotowe środki dowodowe.>>

## Sekcja 10. Kwestie wymagające wspólnego rozstrzygnięcia

<<Jeśli w kilku ofertach występują te same problemy interpretacyjne dokumentacji zamawiającego — opisać.>>

## Powiązania — raporty indywidualne

- [[01-raport-glowny-<<W1-slug>>]]
- [[01-raport-glowny-<<W2-slug>>]]
- [[01-raport-glowny-<<W3-slug>>]]
- [[00-podsumowanie-wykonawcze-<<W1-slug>>]]
- [[00-podsumowanie-wykonawcze-<<W2-slug>>]]
- [[00-podsumowanie-wykonawcze-<<W3-slug>>]]
- [[index-ogloszenie]]
