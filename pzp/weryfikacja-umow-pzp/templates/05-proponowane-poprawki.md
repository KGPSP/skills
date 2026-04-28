---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa postępowania>>"
zamawiajacy: <<nazwa zamawiającego>>
wykonawca: <<nazwa wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email autora>>
typ_dokumentu: proponowane-poprawki
status: <<draft | final>>
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/proponowane-poprawki
---

# Proponowane poprawki do projektu umowy — <<sygnatura>>

> [!important] Kluczowy produkt weryfikacji
> Dla każdej zidentyfikowanej wady projektu umowy: **cytat obecnego brzmienia** + **cytat proponowanego nowego brzmienia** + **uzasadnienie**.
> Proponowane brzmienia są **pełnym tekstem gotowym do wklejenia** do projektu umowy.

## Legenda

### Kategorie problemów

- `P1` — Formalny (struktura, numeracja, dane stron, odesłania)
- `P2` — Prawny (sprzeczny z k.c. / RODO / pr.aut. / KSC)
- `P3` — Pzp (art. 433 niedopuszczalne, 436 obligatoryjne, 437 podwyk. RB, 439 waloryzacja, 442 zaliczki, 443/447 płatności częściowe, 449–453 zabezpieczenie, 454–455 zmiany, 456 odstąpienie, 462–465 podwykonawstwo)
- `P4` — Redakcyjny (literówki, dwuznaczność, błędna odmiana)
- `P5` — Logiczny (spójność wewnętrzna)
- `P6` — Operacyjny (wykonalność, procedura egzekwowania)
- `P7` — Brak korelacji (z SWZ / OPZ / ofertą / pismami)

### Poziomy ryzyka

- `R1` — Krytyczne (uniemożliwia podpisanie / nieważność / sprzeczność z ustawą)
- `R2` — Istotne (silne ryzyko sporu / korekta silnie rekomendowana)
- `R3` — Umiarkowane (ryzyko interpretacyjne / korekta zalecana)
- `R4` — Drobne (redakcyjne, do rozważenia)

---

## Poprawki R1 — obligatoryjne przed podpisaniem

### P-001 — <<Krótka nazwa poprawki>>

**Kategoria:** <<P3>> | **Poziom ryzyka:** R1

**Jednostka redakcyjna:** <<§ N ust. M pkt K lit. L umowy>>

**Obecne brzmienie:**
> [!quote] Cytat z projektu umowy (<<§ N ust. M>>)
> „<<DOKŁADNY literalny cytat obecnego brzmienia. Skopiuj dosłownie, z zachowaniem interpunkcji i ewentualnych błędów. Cytuj całe zdanie / ustęp, z kontekstem.>>"

**Problem:**
<<Opis: co konkretnie jest niewłaściwe. Odróżnij: sprzeczność z ustawą / sprzeczność z SWZ / sprzeczność wewnętrzna / ryzyko interpretacyjne / błąd redakcyjny. Użyj 2-4 zdań, bez powtarzania cytatu.>>

**Proponowane brzmienie:**
> [!success] Propozycja nowego brzmienia (<<§ N ust. M>>)
> „<<PEŁNY tekst proponowany do wstawienia w miejsce obecnego brzmienia. Gotowy do wklejenia do projektu umowy. Nie pisz „należy dodać" — pisz całą klauzulę, zachowując styl redakcyjny (polski urzędowy, terminologia z ustawy Pzp + OPZ).>>"

**Uzasadnienie:**

- **Prawne:** <<konkretny artykuł — np. „art. 433 pkt 1 Pzp zakazuje obciążania wykonawcy odpowiedzialnością za okoliczności, za które nie ponosi winy". Obowiązkowo wskaż Dz.U. aktualnego tekstu jednolitego.>>
- **Dokumentacja postępowania:** <<np. „SWZ Rozdz. XII pkt 3 wskazuje okres waloryzacji co 12 miesięcy — nie 24 jak w projekcie umowy". Cytuj: `[DOC: SWZ.pdf] [Rozdz. XII] [str. 34]` — „<<cytat>>".>>
- **Operacyjne:** <<np. „obecne brzmienie nakazuje zamawiającemu naliczać karę za każdy dzień niezależnie od winy wykonawcy — w praktyce oznacza to ryzyko KIO w razie pierwszego sporu o termin">>
- **Alternatywa (opcjonalnie):** <<druga możliwa redakcja, jeśli istnieje kilka interpretacji równolegle bezpiecznych>>

**Powiązania:**
- [[02-tabela-ustalen-krytycznych-<<slug>>]] — ustalenie #<<X>>
- [[03-analiza-szczegolowa-<<slug>>]] — obszar <<numer>>
- [[04-macierz-korelacji-<<slug>>]] — relacja <<nr>>
- [[06-ocena-ryzyk-<<slug>>]] — ryzyko <<nr>>

^P-001

---

### P-002 — <<Krótka nazwa>>

**Kategoria:** <<P>> | **Poziom ryzyka:** R1

**Jednostka redakcyjna:** <<§ N ust. M>>

**Obecne brzmienie:**
> [!quote] Cytat z projektu umowy (<<§ N ust. M>>)
> „<<cytat>>"

**Problem:**
<<...>>

**Proponowane brzmienie:**
> [!success] Propozycja nowego brzmienia (<<§ N ust. M>>)
> „<<pełny tekst>>"

**Uzasadnienie:**
- **Prawne:** <<...>>
- **Dokumentacja postępowania:** <<...>>
- **Operacyjne:** <<...>>

**Powiązania:**
- [[03-analiza-szczegolowa-<<slug>>]] — <<...>>

^P-002

---

## Poprawki R2 — silnie rekomendowane

<!-- Każda poprawka MUSI mieć unikalny block ID ^P-NNN (kolejne numery: P-003, P-004, ...). Obsidian wymaga unikalności w obrębie pliku — duplikaty łamią wikilinki [[...#^P-NNN]]. -->

### P-003 — <<Krótka nazwa (przykład R2)>>

**Kategoria:** <<P>> | **Poziom ryzyka:** R2

**Jednostka redakcyjna:** <<§ N>>

**Obecne brzmienie:**
> [!quote] Cytat z projektu umowy (<<§ N>>)
> „<<cytat>>"

**Problem:**
<<...>>

**Proponowane brzmienie:**
> [!success] Propozycja nowego brzmienia (<<§ N>>)
> „<<pełny tekst>>"

**Uzasadnienie:**
- **Prawne:** <<...>>
- **Operacyjne:** <<...>>

^P-003

---

## Poprawki R3 — zalecane

### P-004 — <<Krótka nazwa (przykład R3)>>

**Kategoria:** <<P>> | **Poziom ryzyka:** R3

**Jednostka redakcyjna:** <<§ N>>

**Obecne brzmienie:**
> [!quote] Cytat z projektu umowy
> „<<cytat>>"

**Problem:** <<...>>

**Proponowane brzmienie:**
> [!success] Propozycja
> „<<pełny tekst>>"

**Uzasadnienie:** <<...>>

^P-004

---

## Poprawki R4 — do rozważenia

### P-005 — <<Krótka nazwa (przykład R4)>>

**Kategoria:** <<P1 / P4>> | **Poziom ryzyka:** R4

**Jednostka redakcyjna:** <<§ N>>

**Obecne brzmienie:**
> [!quote] Cytat
> „<<cytat>>"

**Problem:** <<literówka / sformułowanie / drobne>>

**Proponowane brzmienie:**
> [!success] Propozycja
> „<<pełny tekst>>"

**Uzasadnienie:** <<drobne, głównie redakcyjne>>

^P-005

---

## Zestawienie poprawek

| # | Nazwa | Jednostka | P | R | Status wdrożenia |
|---|-------|-----------|---|---|-------------------|
| P-001 | <<...>> | <<§>> | <<...>> | R1 | <<do wdrożenia / uzgodnione / wdrożone>> |
| P-002 | <<...>> | <<§>> | <<...>> | R1 | <<...>> |
| P-003 | <<...>> | <<§>> | <<...>> | R2 | <<...>> |
| P-004 | <<...>> | <<§>> | <<...>> | R2 | <<...>> |
| … | … | … | … | … | … |

## Plan wdrożenia

> [!warning] Rekomendowana kolejność wprowadzenia poprawek

1. **Krok 1 — wszystkie R1** (obligatoryjne przed podpisem):
   - P-001, P-002, … <<lista>>
2. **Krok 2 — wszystkie R2** (silnie rekomendowane):
   - P-XXX, P-XXX, … <<lista>>
3. **Krok 3 — R3 i R4** (do rozważenia / akceptacji zamawiającego):
   - P-XXX, P-XXX, … <<lista>>

## Uzgodnienie z wykonawcą

> [!info] Proces uzgodnienia

Poprawki poniższego katalogu wymagają:

1. **Samodzielnego wprowadzenia przez zamawiającego** (formalnie — redakcja projektu umowy przed przekazaniem do podpisu):
   - Poprawki wynikające z obowiązku prawnego (art. 439, art. 436, art. 454–455 Pzp, art. 28 RODO)
   - Poprawki wynikające z niezgodności umowy z SWZ (umowa MUSI odzwierciedlać SWZ + modyfikacje)
   - Poprawki wynikające z błędów formalnych i redakcyjnych
2. **Uzgodnienia z wykonawcą** (jeśli zmienia istotnie obowiązki wykonawcy poza SWZ):
   - W takim wypadku — przygotuj pismo do wykonawcy (skill: [[drafting-pzp-letters]])
   - Weryfikuj, czy zmiana nie narusza zasady równego traktowania (art. 16 Pzp) — nie można zmienić umowy w zakresie, który SWZ nie przewidywał, bo to byłaby zmiana na korzyść jednego wykonawcy po wyborze

**Lista poprawek wymagających uzgodnienia:**
- P-XXX — <<nazwa>> (powód: <<...>>)
- P-XXX — <<nazwa>> (powód: <<...>>)

## Powiązania

- [[00-podsumowanie-wykonawcze-<<slug-sygnatury>>]]
- [[01-raport-glowny-<<slug-sygnatury>>]]
- [[02-tabela-ustalen-krytycznych-<<slug-sygnatury>>]]
- [[03-analiza-szczegolowa-<<slug-sygnatury>>]]
- [[04-macierz-korelacji-<<slug-sygnatury>>]]
- [[06-ocena-ryzyk-<<slug-sygnatury>>]]
- [[07-wnioski-koncowe-<<slug-sygnatury>>]]
- [[08-cytaty-i-zrodla-<<slug-sygnatury>>]]
