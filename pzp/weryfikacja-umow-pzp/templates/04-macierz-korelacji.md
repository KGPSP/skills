---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa postępowania>>"
zamawiajacy: <<nazwa zamawiającego>>
wykonawca: <<nazwa wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email autora>>
typ_dokumentu: macierz-korelacji
status: <<draft | final>>
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/macierz-korelacji
---

# Macierz korelacji dokumentów — <<sygnatura>>

> [!info] Zasady wypełnienia
> - **Zapis umowy:** cytat literalny (skrócony do 1-2 zdań) + lokalizacja `§ N ust. M pkt K`
> - **Dokument powiązany:** nazwa dokumentu i jego rola
> - **Odpowiadający zapis:** cytat literalny z dokumentu powiązanego + lokalizacja `[DOC: plik] [Rozdz./str.]`
> - **Status:** `zgodne` / `częściowo zgodne` / `niezgodne` / `brak regulacji`
> - **Opis rozbieżności:** konkretny opis, jeżeli status ≠ „zgodne"
> - **Rekomendacja:** link do odpowiedniej poprawki w [[05-proponowane-poprawki-<<slug>>]]

## 1. Projekt umowy ↔ PPU (Załącznik „Wzór umowy" do SWZ) — wersja po modyfikacjach

> [!info] PPU (Wzór umowy) to OBOWIĄZUJĄCY wzorzec dla projektu umowy do podpisu. Wszelkie odstępstwa wymagają uzasadnienia prawnego.

| Zapis umowy | Zapis w PPU | Status | Opis rozbieżności | Rekomendacja |
|-------------|-------------|--------|-------------------|---------------|
| § 1 — „Przedmiotem umowy jest…" | `[DOC: Zał-5-Wzór-umowy.pdf] [§ 1]` — „<<cytat>>" | <<...>> | <<...>> | [[05-proponowane-poprawki-<<slug>>#P-XXX]] |
| § 4 — „Termin wykonania…" | `[DOC: Zał-5] [§ 4]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| … | … | … | … | … |

## 2. Projekt umowy ↔ SWZ (rozdziały o umowie i zabezpieczeniu)

| Zapis umowy | Zapis w SWZ | Status | Opis rozbieżności | Rekomendacja |
|-------------|-------------|--------|-------------------|---------------|
| § N — „Zabezpieczenie należytego wykonania…" | `[DOC: SWZ.pdf] [Rozdz. XIII] [str. N]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — „Zmiany umowy…" | `[DOC: SWZ.pdf] [Rozdz. XIV]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — „Warunki realizacji…" | `[DOC: SWZ.pdf] [Rozdz. V]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| … | … | … | … | … |

## 3. Projekt umowy ↔ OPZ

| Zapis umowy | Zapis w OPZ | Status | Opis rozbieżności | Rekomendacja |
|-------------|-------------|--------|-------------------|---------------|
| § N — zakres rzeczowy | `[DOC: OPZ.pdf] [Część A/B/C] [str. N]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — parametry techniczne | `[DOC: OPZ.pdf]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — procedury odbiorowe | `[DOC: OPZ.pdf] [str. N]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — gwarancja / SLA | `[DOC: OPZ.pdf]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| … | … | … | … | … |

## 4. Projekt umowy ↔ Oferta wykonawcy (formularz ofertowy)

| Zapis umowy | Zapis w ofercie | Status | Opis rozbieżności | Rekomendacja |
|-------------|------------------|--------|-------------------|---------------|
| § N — cena brutto | `[DOC: Formularz-ofertowy.pdf] [str. N]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — okres gwarancji | `[DOC: Formularz-ofertowy.pdf]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — termin wykonania | `[DOC: Formularz-ofertowy.pdf]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — podwykonawcy | `[DOC: Formularz-ofertowy.pdf]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — parametry punktowane | `[DOC: Formularz-ofertowy.pdf]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |

## 5. Projekt umowy ↔ Odpowiedzi na pytania wykonawców i zmiany SWZ

> [!danger] Kluczowa weryfikacja
> Każda modyfikacja SWZ / odpowiedź na pytanie zmieniająca PPU MUSI być odzwierciedlona w projekcie umowy. Pominięcie = P7 + R1/R2.

| Pismo | Data | Zakres modyfikacji | Zapis w projekcie umowy | Status odzwierciedlenia | Rekomendacja |
|-------|------|---------------------|---------------------------|--------------------------|---------------|
| `[DOC: Pismo-01-wyjasnienia.pdf]` | <<yyyy-mm-dd>> | <<np. „zmiana terminu realizacji na 12 miesięcy">> | § N — „<<cytat>>" | <<zgodne / brak modyfikacji / niezgodne>> | <<...>> |
| `[DOC: Pismo-02-zmiana-SWZ.pdf]` | <<yyyy-mm-dd>> | <<...>> | <<...>> | <<...>> | <<...>> |
| … | … | … | … | … | … |

## 6. Projekt umowy ↔ Harmonogram

| Zapis umowy | Zapis w harmonogramie | Status | Opis rozbieżności | Rekomendacja |
|-------------|------------------------|--------|-------------------|---------------|
| § N — etap 1 | `[DOC: Harmonogram.xlsx]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — etap 2 | `[DOC: Harmonogram.xlsx]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — data odbioru końcowego | `[DOC: Harmonogram.xlsx]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |

## 7. Projekt umowy ↔ Załączniki techniczne / proceduralne / odbiorowe

| Zapis umowy | Załącznik powiązany | Status | Opis rozbieżności | Rekomendacja |
|-------------|----------------------|--------|-------------------|---------------|
| § N — procedura odbioru | `[DOC: Załącznik-X-Odbiory.pdf]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| § N — wzór protokołu | `[DOC: Załącznik-X-Protokół.docx]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |

## 8. Projekt umowy ↔ Ogłoszenie o zamówieniu

| Zapis umowy | Zapis w ogłoszeniu | Status | Opis rozbieżności | Rekomendacja |
|-------------|---------------------|--------|-------------------|---------------|
| sygnatura postępowania | `[DOC: ogloszenie.pdf]` — „<<cytat>>" | <<...>> | <<...>> | <<...>> |
| zamawiający | `[DOC: ogloszenie.pdf]` | <<...>> | <<...>> | <<...>> |
| tryb | `[DOC: ogloszenie.pdf]` | <<...>> | <<...>> | <<...>> |

## Podsumowanie macierzy

| Relacja | Liczba wierszy | ✅ Zgodne | ⚠️ Częściowo | ❌ Niezgodne | ⬜ Brak regulacji |
|---------|----------------|-----------|---------------|---------------|-------------------|
| 1. Umowa ↔ PPU | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 2. Umowa ↔ SWZ | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 3. Umowa ↔ OPZ | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 4. Umowa ↔ Oferta | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 5. Umowa ↔ Odpowiedzi / zmiany SWZ | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 6. Umowa ↔ Harmonogram | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 7. Umowa ↔ Załączniki techniczne | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 8. Umowa ↔ Ogłoszenie | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| **RAZEM** | **<<N>>** | **<<N>>** | **<<N>>** | **<<N>>** | **<<N>>** |

## Lista najistotniejszych rozbieżności (z linkami)

1. **<<Opis>>** → [[05-proponowane-poprawki-<<slug>>#P-XXX]]
2. **<<Opis>>** → [[05-proponowane-poprawki-<<slug>>#P-XXX]]
3. **<<Opis>>** → [[05-proponowane-poprawki-<<slug>>#P-XXX]]

## Powiązania

- [[01-raport-glowny-<<slug-sygnatury>>]]
- [[03-analiza-szczegolowa-<<slug-sygnatury>>]]
- [[05-proponowane-poprawki-<<slug-sygnatury>>]]
- [[index-dokumentacja-postepowania]]
