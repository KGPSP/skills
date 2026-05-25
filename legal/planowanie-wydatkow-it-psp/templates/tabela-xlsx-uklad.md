# Tabela XLSX — układ kolumn 1:1 z `Propozycja zadań do POLiOC 2027-2031 cz.42.xlsx`

> Wklej tę tabelę do sekcji 7 raport.md po wypełnieniu sekcji 6 (8-punktowe uzasadnienia). Markdown → kopia do Excela 1:1 zachowując kolejność kolumn A–L.
>
> **Reguła agregacji:** jedna pozycja XLSX = jedna grupa funkcjonalna (np. „Utrzymanie CEOZO" agreguje wszystkie OPEX hostingowo-operacyjne). Pełny rozkład per subskrypcja/hosting/usługa zostaje w tabeli III.B (sekcja 5).

## Układ kolumn

| Kol. | Nagłówek | Zawartość | Wzór |
|---|---|---|---|
| A | **Pod-obszar** | Kod podobszaru POLiOC (4E / 5E / 6A …) | `5E` |
| B | **Nazwa zadania** | Nazwa funkcjonalna (agregat) | `Utrzymanie CEOZO` |
| C | **Dział** | 752 (tryb A) / 754 (tryb B/C) | `752` |
| D | **Rozdział** | 75282 (A) / 75414 (B) / 75409 (C) | `75282` |
| E | **§** | Paragraf 3-cyfrowy 2027+ (Dz.U. 2026 poz. 582): 631/634/638/670/677/681/682/687/770/771/778 (bieżące, grupa BP 3) lub 701/702/703/704/711/712/720 (majątkowe, grupa BP 4) — **nigdy 4-cyfrowy legacy (4xxx/6xxx)**, **§ 704 wymaga uzasadnienia operacyjnego** | `682` lub `702` lub `720` |
| F | **Kwota brutto [zł]** | Suma roczna w PLN brutto (z VAT/RC, z rezerwami jeśli wliczone) | `1 080 000` |
| G | **KG PSP** | Alokacja KG PSP | `1 080 000` |
| H | **Akademia** | Akademia PSP | `0` |
| I | **CS Czstch** | Centralna Szkoła PSP w Częstochowie | `0` |
| J | **SA Krk** | Szkoła Aspirantów PSP w Krakowie | `0` |
| K | **SA Pzn** | Szkoła Aspirantów PSP w Poznaniu | `0` |
| L | **SP Bdg** | Szkoła Podoficerska PSP w Bydgoszczy | `0` |

**Twardy wymóg:** `G + H + I + J + K + L = F` dla każdego wiersza. Rozbieżność = błąd, do skorygowania przed złożeniem.

## Szablon do kopiowania

```markdown
## 7. Tabela w układzie XLSX (do kopiowania do `Propozycja zadań do POLiOC 2027-2031 cz.42.xlsx`)

| Pod-obszar | Nazwa zadania | Dział | Rozdział | § | Kwota brutto [zł] | KG PSP | Akademia | CS Czstch | SA Krk | SA Pzn | SP Bdg |
|---|---|---|---|---|---|---|---|---|---|---|---|
| <kod> | <nazwa> | <D> | <R> | <§> | <F> | <G> | <H> | <I> | <J> | <K> | <L> |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

**Suma F razem:** <suma w zł>
**Walidacja:** sum(G..L) = F dla każdego wiersza? [TAK/NIE]
```

## Przykład wypełnienia — CEOZO (tryb A, klasyfikacja 2027+)

| Pod-obszar | Nazwa zadania | Dział | Rozdział | § | Kwota brutto [zł] | KG PSP | Akademia | CS Czstch | SA Krk | SA Pzn | SP Bdg |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 5E | Utrzymanie CEOZO | 752 | 75282 | 682 | 1 080 000 | 1 080 000 | 0 | 0 | 0 | 0 | 0 |
| 5E | Budowa, rozbudowa CEOZO (wytworzenie WNiP) | 752 | 75282 | 720 | 1 500 000 | 1 500 000 | 0 | 0 | 0 | 0 | 0 |

**Suma F razem:** 2 580 000 zł
**Walidacja:** sum(G..L) = F dla każdego wiersza? **TAK** (oba wiersze: 1 080 000 = 1 080 000; 1 500 000 = 1 500 000).

## Przykład wypełnienia — alokacja rozproszona (gdy zadanie obejmuje szkoły, 2027+)

| Pod-obszar | Nazwa zadania | Dział | Rozdział | § | Kwota brutto [zł] | KG PSP | Akademia | CS Czstch | SA Krk | SA Pzn | SP Bdg |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 6E | Platforma e-learning portfela PSP | 752 | 75282 | 682 | 600 000 | 200 000 | 100 000 | 100 000 | 100 000 | 50 000 | 50 000 |

**Walidacja:** 200 000 + 100 000 + 100 000 + 100 000 + 50 000 + 50 000 = 600 000 ✔

## Konwencje formatu

- **Separator tysięcy:** spacja (np. `1 080 000`). Nie kropka, nie przecinek (w polskiej notacji przecinek = ułamek dziesiętny).
- **Brak ułamków groszowych** w tabeli XLSX — zaokrąglaj do pełnych złotych (rezerwa kursowa pokrywa zaokrąglenia).
- **`0`** dla jednostek, którym nic nie przypada (nie pomijaj kolumn, nie wpisuj `—`).
- **Kod podobszaru** wielkimi literami: `5E`, `4E`, `4D`, `6A` (zgodnie z Załącznikiem 2 Programu).

## Mapa skróty jednostki → pełna nazwa (referencyjnie)

| Skrót | Pełna nazwa | Lokalizacja |
|---|---|---|
| KG PSP | Komenda Główna Państwowej Straży Pożarnej | Warszawa |
| Akademia | Akademia Pożarnicza | Warszawa |
| CS Czstch | Centralna Szkoła PSP | Częstochowa |
| SA Krk | Szkoła Aspirantów PSP | Kraków |
| SA Pzn | Szkoła Aspirantów PSP | Poznań |
| SP Bdg | Szkoła Podoficerska PSP | Bydgoszcz |
