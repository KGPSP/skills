---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa postępowania>>"
zamawiajacy: <<nazwa zamawiającego>>
wykonawca: <<nazwa wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email autora>>
typ_dokumentu: podsumowanie-wykonawcze
status: <<draft | final>>
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/podsumowanie-wykonawcze
---

# Podsumowanie wykonawcze — weryfikacja projektu umowy

**Sygnatura:** <<sygnatura>>
**Postępowanie:** <<nazwa>>
**Zamawiający:** <<Komenda Główna Państwowej Straży Pożarnej>>
**Wykonawca:** <<nazwa>>
**Projekt umowy:** <<plik.docx / data wersji>>
**Data analizy:** <<yyyy-mm-dd>>
**Autor analizy:** <<email>>

## 1. Rekomendacja końcowa

<!-- Agent wybiera typ callout wg wyniku analizy:
     [!success] = TAK — gotowa do podpisu
     [!warning] = WARUNKOWO — wymaga poprawek R2
     [!danger]  = NIE — wymaga poprawek R1 / przebudowy -->
> [!warning] Rekomendacja
> <<Jedno zdanie: tak / nie / tak po poprawkach (z liczbą poprawek R1 + R2).>>

**Czy projekt umowy może zostać podpisany w obecnym brzmieniu?** <<TAK / NIE / WARUNKOWO>>

<<1-2 zdania uzasadnienia.>>

## 2. Ocena ogólna (A)

| Aspekt | Ocena | Uzasadnienie w skrócie |
|--------|-------|--------------------------|
| **Ogólna jakość projektu umowy** | <<bardzo dobra / dobra / dostateczna / niedostateczna>> | <<...>> |
| **Zgodność formalna** | <<...>> | <<...>> |
| **Zgodność z dokumentacją postępowania** (SWZ, OPZ, oferta, modyfikacje) | <<...>> | <<...>> |
| **Spójność wewnętrzna** | <<...>> | <<...>> |
| **Zgodność z Pzp** (art. 433, 436, 439, 454–455) | <<...>> | <<...>> |
| **Gotowość do podpisania** | <<gotowa / gotowa po drobnych poprawkach / wymaga istotnych korekt / nieakceptowalna>> | <<...>> |

## 3. Statystyki znalezisk

| Poziom ryzyka | Liczba znalezisk | Kluczowy obszar |
|---------------|------------------|-----------------|
| R1 — Krytyczne | <<N>> | <<np. art. 439 brak waloryzacji, klauzule abuzywne>> |
| R2 — Istotne | <<N>> | <<np. kary umowne nieproporcjonalne>> |
| R3 — Umiarkowane | <<N>> | <<np. redakcja „zmian umowy">> |
| R4 — Drobne | <<N>> | <<np. literówki w nazwie>> |
| **RAZEM** | <<N>> | — |

## 4. Top 3-5 krytycznych znalezisk (R1/R2)

> [!danger] R1 — <<Krótka nazwa>>
> **Jednostka:** <<§ N ust. M>>
> **Problem:** <<1-2 zdania>>
> **Rekomendacja:** [[05-proponowane-poprawki-<<slug>>#P-XXX]]

> [!danger] R1 — <<Krótka nazwa>>
> **Jednostka:** <<§ N ust. M>>
> **Problem:** <<...>>
> **Rekomendacja:** [[05-proponowane-poprawki-<<slug>>#P-XXX]]

> [!warning] R2 — <<Krótka nazwa>>
> **Jednostka:** <<§ N ust. M>>
> **Problem:** <<...>>
> **Rekomendacja:** [[05-proponowane-poprawki-<<slug>>#P-XXX]]

## 5. Obszary wymagające priorytetowej uwagi

1. **<<np. Waloryzacja (art. 439 Pzp)>>** — <<krótki opis, poziom, rekomendacja>>
2. **<<np. Kary umowne — klauzule abuzywne (art. 433 Pzp)>>** — <<...>>
3. **<<np. Spójność terminów z ofertą>>** — <<...>>

## 6. Następne kroki

- [ ] **Wdrożenie poprawek R1 — obligatoryjne przed podpisaniem** (lista: P-XXX, …)
- [ ] Wdrożenie poprawek R2 — silnie rekomendowane (lista: P-XXX, …)
- [ ] Uzgodnienie z wykonawcą akceptacji proponowanych poprawek (patrz [[drafting-pzp-letters]] jeśli potrzeba formalnego pisma)
- [ ] Weryfikacja prawna pogłębiona dla pozycji oznaczonych `[!abstract]` (jeśli są)
- [ ] Ponowne uruchomienie `weryfikacja-umow-pzp` po wprowadzeniu poprawek (opcjonalnie)

## 7. Zastrzeżenia analityczne

<<Jeżeli nie otrzymano kluczowych dokumentów (np. brakuje pism z modyfikacjami SWZ, brakuje harmonogramu, brakuje oferty), wskaż tu zastrzeżenia. W takim wypadku analiza ma ograniczenia, które należy odnotować.>>

> [!info] Zakres analizy
> Dokumenty wykorzystane: <<lista>>
> Dokumenty niedostarczone lub niedostępne: <<lista>>
> Wpływ na wnioski: <<...>>

## Powiązania

- [[01-raport-glowny-<<slug-sygnatury>>]]
- [[02-tabela-ustalen-krytycznych-<<slug-sygnatury>>]]
- [[03-analiza-szczegolowa-<<slug-sygnatury>>]]
- [[04-macierz-korelacji-<<slug-sygnatury>>]]
- [[05-proponowane-poprawki-<<slug-sygnatury>>]]
- [[06-ocena-ryzyk-<<slug-sygnatury>>]]
- [[07-wnioski-koncowe-<<slug-sygnatury>>]]
