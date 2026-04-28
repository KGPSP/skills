---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa>>"
zamawiajacy: <<zamawiajacy>>
wykonawca: <<nazwa>>
wykonawca_slug: <<slug-wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email>>
typ_dokumentu: raport-glowny
status: <<draft | final>>
wersja: 1.0
tags:
  - pzp/raport
  - pzp/raport-glowny
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
---

# Raport główny z analizy oferty — <<nazwa wykonawcy>>

> [!info] Metryka raportu
> - **Postępowanie:** <<nazwa>>
> - **Nr sprawy:** <<sygnatura>>
> - **Zamawiający:** <<zamawiajacy>>
> - **Wykonawca:** <<nazwa>> (NIP <<nip>>, KRS <<krs>>)
> - **Przedmiot analizy:** Kompletność, prawidłowość i zgodność oferty z dokumentacją postępowania
> - **Podstawy prawne:** ustawa z 11.09.2019 r. — Prawo zamówień publicznych (dalej: Pzp) wraz z aktami wykonawczymi
> - **Autor analizy:** <<email>>
> - **Data:** <<yyyy-mm-dd>>
> - **Wersja:** 1.0

## Spis treści

1. [[#I. Podsumowanie końcowe]]
2. [[#II. Tabela kontrolna]]
3. [[#III. Stwierdzone braki, błędy i niezgodności]]
4. [[#IV. Analiza szczegółowa]]
5. [[#V. Wnioski końcowe i rekomendacja]]
6. [[#VI. Załączniki i dokumenty pochodne]]

---

## I. Podsumowanie końcowe

<<Patrz: [[00-podsumowanie-wykonawcze-<<slug-wykonawcy>>]] — poniżej powtórzenie w skróconej wersji.>>

### Kompletność oferty

<<Ocena + uzasadnienie z cytatem.>>

### Prawidłowość formalna

<<Ocena + uzasadnienie.>>

### Zgodność merytoryczna z SWZ, OPZ i modyfikacjami

<<Ocena + uzasadnienie.>>

### Stwierdzone ryzyka

<<Ocena + uzasadnienie.>>

### Rekomendacja ogólna (forma nr X z V)

<<Jedna z 5 form wniosku końcowego.>>

---

## II. Tabela kontrolna

> Pełna tabela kontrolna: [[02-tabela-kontrolna-<<slug-wykonawcy>>]]
> Poniżej skrócona wersja z kluczowymi wymaganiami.

| # | Wymaganie | Źródło | Kategoria | Dokument złożony | Prawidłowy | Kategoria F | Uwagi |
|---|-----------|--------|-----------|------------------|------------|-------------|-------|
| 1 | Formularz oferty | `[DOC: SWZ] [Rozdz. XIV]` | Wraz z ofertą | <<plik>> | ✅/⚠️/❌ | F1 | <<...>> |
| 2 | JEDZ | `[DOC: SWZ] [Rozdz. IX]` | Wraz z ofertą | <<plik>> | ✅/⚠️/❌ | F1 | <<...>> |
| 3 | OPZ wypełniony | `[DOC: SWZ] [Rozdz. V]` | Wraz z ofertą | <<plik>> | ✅/⚠️/❌ | — | <<...>> |
| 4 | Wadium | `[DOC: SWZ] [Rozdz. XVII]` | Wraz z ofertą | <<plik>> | ✅/⚠️/❌ | — | <<...>> |
| 5 | Pełnomocnictwo | `[DOC: SWZ] [Rozdz. XIV]` | Jeśli dotyczy | <<plik / n/d>> | ✅/⚠️/❌ | — | <<...>> |
| ... | ... | ... | ... | ... | ... | ... | ... |

---

## III. Stwierdzone braki, błędy i niezgodności

> Pełna lista: [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>]]

### 3.1. Braki formalne

<<Lista z callout per znalezisko>>

> [!warning] <<Tytuł>>
> **Wymóg:** `[DOC] [Rozdz.] [pkt] [str.]` — „<<cytat>>"
> **Stan oferty:** `[DOC] [str.]` — <<opis>>
> **Kategoria F:** F<<N>> — <<nazwa>>
> **Podstawa prawna:** art. <<N>> ust. <<N>> Pzp
> **Sugerowane działanie:** <<...>>

### 3.2. Braki uzupełnialne

<<...>>

### 3.3. Braki nieuzupełnialne

<<...>>

### 3.4. Niezgodności techniczne

<<...>>

### 3.5. Niespójności dokumentów

<<...>>

### 3.6. Ryzyka odrzucenia

<<...>>

### 3.7. Kwestie wymagające wyjaśnienia

<<...>>

---

## IV. Analiza szczegółowa

> Pełna analiza per sekcja: [[04-analiza-szczegolowa-<<slug-wykonawcy>>]]

### A. Weryfikacja formalna oferty

<<Podsumowanie 2–3 akapity, linki do szczegółów.>>

### B. Kompletność dokumentów składanych wraz z ofertą

<<...>>

### C. Dokumenty składane na wezwanie

<<...>>

### D. Zgodność merytoryczna z OPZ i SWZ

<<...>>

### E. Elementy szczególnie istotne

<<Cena, gwarancja, termin, przedmiotowe środki dowodowe, JEDZ, oświadczenia sankcyjne, poleganie na zasobach, tajemnica przedsiębiorstwa.>>

### F. Ocena pod kątem ryzyka odrzucenia lub wezwania

<<Tabelka F1–F6 z liczbą znalezisk; link do [[05-ocena-ryzyka-<<slug-wykonawcy>>]].>>

### G. Spójność z ogłoszeniem i modyfikacjami SWZ

<<Czy wykonawca uwzględnił wszystkie modyfikacje, czy zastosował aktualne wzory załączników.>>

---

## V. Wnioski końcowe i rekomendacja

> [!<<success|warning|failure|danger|quote>>] Wniosek (forma nr X z V)
>
> **<<treść wniosku>>**

### Rekomendowane działania zamawiającego

1. **<<działanie>>** — podstawa prawna: art. <<N>> Pzp — uzasadnienie: <<...>>
2. **<<działanie>>** — <<...>>

### Ryzyka dla zamawiającego przy ewentualnym wyborze tej oferty

- <<ryzyko 1 + mitygacja>>
- <<ryzyko 2 + mitygacja>>

### Terminy krytyczne

| Termin | Data | Uwaga |
|--------|------|-------|
| Termin związania ofertą (TZO) | <<data>> | <<...>> |
| Termin wezwania do uzupełnienia (po otwarciu) | <<data>> | <<...>> |
| Planowana data wyboru oferty | <<data>> | <<...>> |

---

## VI. Załączniki i dokumenty pochodne

| Nr | Dokument | Opis |
|----|----------|------|
| 00 | [[00-podsumowanie-wykonawcze-<<slug-wykonawcy>>]] | Podsumowanie wykonawcze |
| 02 | [[02-tabela-kontrolna-<<slug-wykonawcy>>]] | Pełna tabela kontrolna |
| 03 | [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>]] | Wszystkie znaleziska |
| 04 | [[04-analiza-szczegolowa-<<slug-wykonawcy>>]] | Analiza per sekcja A–G |
| 05 | [[05-ocena-ryzyka-<<slug-wykonawcy>>]] | Klasyfikacja ryzyk |
| 06 | [[06-cytaty-i-zrodla-<<slug-wykonawcy>>]] | Register cytatów |
| 07 | [[07-analiza-porownawcza]] | Porównanie ofert (gdy >1) |
| I1 | [[index-ogloszenie]] | Indeks dokumentacji postępowania |
| I2 | [[index-<<slug-wykonawcy>>]] | Indeks oferty |

## Podpis i data

**Analizę sporządził:** <<autor>>
**Data:** <<yyyy-mm-dd>>
**Wersja raportu:** 1.0
**Status:** <<draft | final>>
