---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa>>"
wykonawca: <<nazwa>>
wykonawca_slug: <<slug-wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
typ_dokumentu: tabela-kontrolna
status: <<draft | final>>
tags:
  - pzp/raport
  - pzp/tabela-kontrolna
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
---

# Tabela kontrolna — weryfikacja wymagań wobec oferty <<wykonawca>>

> [!info] Zasady wypełnienia
> - **Źródło wymagania:** zawsze `[DOC: plik] [Rozdz. N] [ust. N] [pkt N] [lit. l] [str. N]`
> - **Kategoria:** `wraz` / `na wezwanie` / `fakultatywny`
> - **Prawidłowy:** ✅ tak / ⚠️ z zastrzeżeniami / ❌ nie / ⬜ nie dotyczy
> - **Kategoria F:** F1–F6 wg `references/verification-prompt.md`
> - Przy każdym „⚠️" lub „❌" — callout w [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>]]

## A. Wymagania formalne oferty

| # | Wymaganie | Źródło wymagania | Wymagane wraz z ofertą | Złożone (plik:str.) | Prawidłowe | Uwagi | F |
|---|-----------|------------------|------------------------|---------------------|------------|-------|---|
| A.1 | Formularz oferty | <<src>> | ✅ | <<plik>> | ✅ | <<...>> | — |
| A.2 | Cena brutto/netto/VAT + arytmetyka | <<src>> | ✅ | <<plik>> | <<...>> | <<...>> | <<...>> |
| A.3 | Okres gwarancji w przedziale | <<src>> | ✅ | <<plik>> | <<...>> | <<...>> | <<...>> |
| A.4 | Termin wykonania | <<src>> | ✅ | <<plik>> | <<...>> | <<...>> | <<...>> |
| A.5 | Kwalifikowany podpis elektroniczny | <<src>> | ✅ | <<plik>> | <<...>> | <<...>> | <<...>> |
| A.6 | Forma dokumentów (PDF/DOCX/XML) | <<src>> | ✅ | <<plik>> | <<...>> | <<...>> | <<...>> |
| A.7 | Termin związania ofertą (TZO) | <<src>> | ✅ | <<plik>> | <<...>> | <<...>> | <<...>> |
| A.8 | Spójność wewnętrzna oferty | <<src>> | ✅ | <<plik>> | <<...>> | <<...>> | <<...>> |

## B. Dokumenty składane WRAZ Z OFERTĄ

| # | Dokument | Źródło wymagania | Kategoria | Złożony (plik:str.) | Prawidłowy | Treść potwierdza wymóg | F | Uwagi |
|---|----------|------------------|-----------|---------------------|------------|------------------------|---|-------|
| B.1 | Formularz oferty (Zał. 3) | <<src>> | wraz | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |
| B.2 | JEDZ wykonawcy | <<src>> | wraz | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |
| B.3 | JEDZ podmiotu 3. | <<src>> | wraz (jeśli dot.) | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |
| B.4 | OPZ wypełniony (Zał. 1) | <<src>> | wraz | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |
| B.5 | Karty katalogowe producenta | <<src>> | wraz | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |
| B.6 | Przedmiotowe środki dowodowe | <<src>> | wraz | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |
| B.7 | Zobowiązanie pod. 3 (Zał. 6) | <<src>> | wraz (jeśli dot.) | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |
| B.8 | Oświadczenie sankcyjne wykonawca (Zał. 9) | <<src>> | wraz | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |
| B.9 | Oświadczenie sankcyjne podmiot 3 (Zał. 10) | <<src>> | wraz (jeśli dot.) | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |
| B.10 | Wadium | <<src>> | wraz | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |
| B.11 | Pełnomocnictwo | <<src>> | fakult. | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |
| B.12 | Uzasadnienie tajemnicy przedsiębiorstwa | <<src>> | fakult. | <<plik>> | <<...>> | <<...>> | <<...>> | <<...>> |

## C. Dokumenty składane NA WEZWANIE

> [!info] Uwaga
> Brak tych dokumentów w ofercie ≠ błąd. Oceniamy tylko czy wymóg istnieje i czy będzie można je wezwać.

| # | Dokument | Źródło | Podstawa wezwania (Pzp) | Komentarz |
|---|----------|--------|-------------------------|-----------|
| C.1 | Wykaz dostaw (Zał. 4 — wersja po zmianie) | <<src>> | art. 126 | <<...>> |
| C.2 | Wykaz osób (Zał. 5) | <<src>> | art. 126 | <<...>> |
| C.3 | Oświadczenie grupa kapitałowa (Zał. 7) | <<src>> | art. 108 ust. 1 pkt 5 Pzp | <<...>> |
| C.4 | Oświadczenie o aktualności (Zał. 8) | <<src>> | § 3 rozp. MRPiT z 23.12.2020 r. (Dz.U. 2020 poz. 2415); wezwanie art. 126/274 Pzp | <<...>> |
| C.5 | Zaświadczenie ZUS | <<src>> | art. 126 | <<...>> |
| C.6 | Zaświadczenie US | <<src>> | art. 126 | <<...>> |
| C.7 | Informacja z KRK | <<src>> | art. 126 | <<...>> |

## D. Zgodność merytoryczna z OPZ

> Pełna tabela parametrów: rozbić per część A/B/C (jak w OPZ)

### Część A — <<nazwa części>>

| Pkt OPZ | Wymaganie minimalne | Źródło | Oferowane | Plik potwierdzający | Zgodność | F | Uwagi |
|---------|---------------------|--------|-----------|---------------------|----------|---|-------|
| A.1 | <<param>> | <<src>> | <<wartość>> | <<plik:str>> | <<...>> | <<...>> | <<...>> |
| A.2 | <<param>> | <<src>> | <<wartość>> | <<plik:str>> | <<...>> | <<...>> | <<...>> |
| ... | ... | ... | ... | ... | ... | ... | ... |

### Część B — <<nazwa>>

| Pkt OPZ | Wymaganie | Źródło | Oferowane | Plik | Zgodność | F | Uwagi |
|---------|-----------|--------|-----------|------|----------|---|-------|
| B.1 | <<...>> | <<src>> | <<...>> | <<...>> | <<...>> | <<...>> | <<...>> |

### Część C — <<nazwa>>

| Pkt OPZ | Wymaganie | Źródło | Oferowane | Plik | Zgodność | F | Uwagi |
|---------|-----------|--------|-----------|------|----------|---|-------|
| C.1 | <<...>> | <<src>> | <<...>> | <<...>> | <<...>> | <<...>> | <<...>> |

## E. Uwzględnienie modyfikacji SWZ

| Data pisma | Zakres zmiany | Czy oferta uwzględnia | Dowód w ofercie | Uwagi |
|------------|---------------|----------------------|------------------|-------|
| <<data>> | <<zakres>> | ✅/⚠️/❌ | <<plik:str>> | <<...>> |
| <<data>> | <<zakres>> | ✅/⚠️/❌ | <<plik:str>> | <<...>> |

## F. Kryteria oceny ofert

| Kryterium | Waga | Oferta wykonawcy | Punkty (wg wzoru SWZ) |
|-----------|------|-------------------|------------------------|
| <<cena>> | <<N pkt>> | <<wartość>> | <<N/M>> |
| <<gwarancja>> | <<N pkt>> | <<wartość>> | <<N/M>> |
| **SUMA** | 100 | — | <<N>> |

## Zestawienie finalne

| Kategoria | Liczba wymagań | ✅ Spełnione | ⚠️ Z zastrzeżeniem | ❌ Niespełnione | ⬜ Nie dotyczy |
|-----------|----------------|--------------|---------------------|-----------------|----------------|
| A. Formalne | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| B. Wraz z ofertą | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| C. Na wezwanie | <<N>> | — | — | — | <<N>> |
| D. Merytoryczne OPZ | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| E. Modyfikacje | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |

## Powiązania

- [[01-raport-glowny-<<slug-wykonawcy>>]]
- [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>]]
- [[06-cytaty-i-zrodla-<<slug-wykonawcy>>]]
