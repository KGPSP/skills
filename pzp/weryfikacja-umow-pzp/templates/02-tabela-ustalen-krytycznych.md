---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa postępowania>>"
zamawiajacy: <<nazwa zamawiającego>>
wykonawca: <<nazwa wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email autora>>
typ_dokumentu: tabela-ustalen-krytycznych
status: <<draft | final>>
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/tabela-ustalen
---

# Tabela ustaleń krytycznych — <<sygnatura>>

> [!info] Legenda
> **Rodzaj problemu:**
> - `P1` — Formalny (struktura, dane stron, numeracja, odesłania)
> - `P2` — Prawny (sprzeczny z k.c. / RODO / pr.aut. / KSC)
> - `P3` — Pzp (art. 433 niedopuszczalne, art. 436 obligatoryjne, art. 437 podwyk. RB, art. 439 waloryzacja, art. 442 zaliczki, art. 443 płatności częściowe, art. 449–453 zabezpieczenie, art. 454–455 zmiany, art. 456 odstąpienie, art. 462–465 podwykonawstwo)
> - `P4` — Redakcyjny (literówki, błędne odmiany, dwuznaczność)
> - `P5` — Logiczny (spójność wewnętrzna, sprzeczności między paragrafami)
> - `P6` — Operacyjny (wykonalność, procedura egzekwowania)
> - `P7` — Brak korelacji z dokumentacją postępowania
>
> **Poziom ryzyka:**
> - `R1` — Krytyczne (uniemożliwia podpisanie; nieważność; sprzeczność z ustawą)
> - `R2` — Istotne (silne ryzyko sporu / nieskutecznej egzekucji; korekta przed podpisem silnie rekomendowana)
> - `R3` — Umiarkowane (ryzyko interpretacyjne / operacyjne; korekta zalecana)
> - `R4` — Drobne (redakcyjne, bez wpływu na wykonalność; do rozważenia)

## Sortowanie

Tabela posortowana najpierw wg poziomu ryzyka (R1 → R4), następnie wg kolejności paragrafów w projekcie umowy.

## Tabela ustaleń (pełna)

| # | Jednostka redakcyjna / załącznik / dokument | Opis problemu | Rodzaj (P1–P7) | Ryzyko (R1–R4) | Rekomendowana korekta (link do poprawki) |
|---|----------------------------------------------|---------------|----------------|----------------|-------------------------------------------|
| 1 | <<§ N ust. M pkt K>> | <<opis problemu — 1-2 zdania>> | <<P3>> | <<R1>> | [[05-proponowane-poprawki-<<slug>>#P-001]] — <<Krótka nazwa>> |
| 2 | <<§ N ust. M>> | <<...>> | <<P7>> | <<R1>> | [[05-proponowane-poprawki-<<slug>>#P-002]] |
| 3 | <<§ N>> | <<...>> | <<P3>> | <<R2>> | [[05-proponowane-poprawki-<<slug>>#P-003]] |
| 4 | <<załącznik nr 2>> | <<...>> | <<P7>> | <<R2>> | [[05-proponowane-poprawki-<<slug>>#P-004]] |
| 5 | <<§ N ust. M>> | <<...>> | <<P5>> | <<R3>> | [[05-proponowane-poprawki-<<slug>>#P-005]] |
| … | … | … | … | … | … |

## Grupowanie wg obszaru

### R1 — Krytyczne (N znalezisk)

| # | Jednostka | Problem | Rodzaj | Korekta |
|---|-----------|---------|--------|---------|
| 1 | <<§>> | <<...>> | <<P>> | [[05-proponowane-poprawki-<<slug>>#P-001]] |

### R2 — Istotne (N znalezisk)

| # | Jednostka | Problem | Rodzaj | Korekta |
|---|-----------|---------|--------|---------|
| 1 | <<§>> | <<...>> | <<P>> | [[05-proponowane-poprawki-<<slug>>#P-XXX]] |

### R3 — Umiarkowane (N znalezisk)

| # | Jednostka | Problem | Rodzaj | Korekta |
|---|-----------|---------|--------|---------|
| 1 | <<§>> | <<...>> | <<P>> | [[05-proponowane-poprawki-<<slug>>#P-XXX]] |

### R4 — Drobne (N znalezisk)

| # | Jednostka | Problem | Rodzaj | Korekta |
|---|-----------|---------|--------|---------|
| 1 | <<§>> | <<...>> | <<P>> | [[05-proponowane-poprawki-<<slug>>#P-XXX]] |

## Grupowanie wg kategorii problemu

| Kategoria | Liczba | Główne obszary |
|-----------|--------|-----------------|
| P1 — Formalny | <<N>> | <<...>> |
| P2 — Prawny | <<N>> | <<...>> |
| P3 — Pzp | <<N>> | <<art. 433 / art. 439 / art. 454–455 / …>> |
| P4 — Redakcyjny | <<N>> | <<...>> |
| P5 — Logiczny | <<N>> | <<...>> |
| P6 — Operacyjny | <<N>> | <<...>> |
| P7 — Brak korelacji | <<N>> | <<oferta / SWZ / OPZ / pisma>> |

## Statystyki podsumowujące

| Metryka | Wartość |
|---------|---------|
| Łączna liczba znalezisk | <<N>> |
| Liczba poprawek R1 (obligatoryjne przed podpisem) | <<N>> |
| Liczba poprawek R2 (silnie rekomendowane) | <<N>> |
| Liczba poprawek R3 (zalecane) | <<N>> |
| Liczba poprawek R4 (do rozważenia) | <<N>> |
| Liczba znalezisk P3 (Pzp) | <<N>> |
| Liczba znalezisk P7 (brak korelacji) | <<N>> |
| Pozycje wymagające dalszej analizy prawnej (`[!abstract]`) | <<N>> |

## Powiązania

- [[01-raport-glowny-<<slug-sygnatury>>]]
- [[05-proponowane-poprawki-<<slug-sygnatury>>]]
- [[06-ocena-ryzyk-<<slug-sygnatury>>]]
