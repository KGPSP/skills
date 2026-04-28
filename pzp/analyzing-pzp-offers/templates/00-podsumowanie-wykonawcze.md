---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa>>"
zamawiajacy: <<zamawiajacy>>
wykonawca: <<nazwa>>
wykonawca_slug: <<slug-wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email>>
typ_dokumentu: podsumowanie-wykonawcze
status: <<draft | final>>
rekomendacja: <<kompletna_prawidlowa | do_wyjasnien | istotne_niezgodnosci | ryzyko_odrzucenia | niepelny_material>>
poziom_ryzyka_ogolny: <<niski | sredni | wysoki | krytyczny>>
liczba_F1: <<N>>
liczba_F2: <<N>>
liczba_F3: <<N>>
liczba_F4: <<N>>
liczba_F5: <<N>>
liczba_F6: <<N>>
tags:
  - pzp/raport
  - pzp/podsumowanie
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
---

# Podsumowanie wykonawcze — Oferta <<nazwa wykonawcy>>

> [!info] Kontekst
> - **Postępowanie:** <<nazwa>>
> - **Nr sprawy:** <<sygnatura>>
> - **Zamawiający:** <<zamawiajacy>>
> - **Wykonawca:** <<nazwa>>
> - **Cena brutto:** ==<<kwota>>==
> - **Okres gwarancji:** <<N>> miesięcy
> - **Data analizy:** <<yyyy-mm-dd>>

## Jednozdaniowa ocena

<<Jedno zdanie: np. „Oferta Galaxy Systemy Informatyczne Sp. z o.o. jest zasadniczo kompletna, ale wymaga wyjaśnień w zakresie kart katalogowych dla pkt A.3 OPZ.">>

## Kluczowe ustalenia

### Kompletność
<<✅ / ⚠️ / ❌>> <<Zdanie-uzasadnienie z cytatem kluczowym.>>

### Zgodność formalna
<<✅ / ⚠️ / ❌>> <<Zdanie-uzasadnienie.>>

### Zgodność merytoryczna z OPZ
<<✅ / ⚠️ / ❌>> <<Zdanie-uzasadnienie.>>

### Uwzględnienie modyfikacji SWZ
<<✅ / ⚠️ / ❌>> <<Zdanie-uzasadnienie.>>

## Statystyka znalezisk

| Kategoria F | Liczba | Skutek |
|-------------|--------|--------|
| F1 — Braki nieistotne | <<N>> | Informacyjnie |
| F2 — Wady uzupełnialne | <<N>> | Wezwanie do uzupełnienia |
| F3 — Wymagające wyjaśnień | <<N>> | Wezwanie do wyjaśnień |
| F4 — Niezgodności treści | <<N>> | Ryzyko odrzucenia |
| F5 — Podstawy odrzucenia | <<N>> | Odrzucenie / wykluczenie |
| F6 — Do analizy prawnej | <<N>> | Pogłębiona ocena |

## Rekomendacja końcowa

> [!<<success|warning|failure|danger|quote>>] Rekomendacja
> **<<jedna z 5 form:>>**
> 1. Oferta kompletna i prawidłowa
> 2. Oferta zasadniczo kompletna, ale wymaga wyjaśnień/uzupełnień
> 3. Oferta zawiera istotne niezgodności
> 4. Oferta obarczona jest ryzykiem odrzucenia
> 5. Brak możliwości jednoznacznej oceny z uwagi na niepełny materiał
>
> **Sugerowane działania zamawiającego:**
> - <<działanie 1 z podstawą prawną>>
> - <<działanie 2>>

## Ograniczenia analizy

> [!abstract] Materiał
> <<Jeśli brakuje dokumentów postępowania lub oferty — wymień konkretnie, czego brak i jakie to ma skutki dla analizy.>>

## Powiązania

- [[01-raport-glowny-<<slug-wykonawcy>>]] — pełny raport
- [[02-tabela-kontrolna-<<slug-wykonawcy>>]] — macierz wymagań
- [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>]] — wszystkie znaleziska
- [[04-analiza-szczegolowa-<<slug-wykonawcy>>]] — analiza sekcje A–G
- [[05-ocena-ryzyka-<<slug-wykonawcy>>]] — klasyfikacja ryzyk
- [[06-cytaty-i-zrodla-<<slug-wykonawcy>>]] — register cytatów
- [[07-analiza-porownawcza]] — <<jeśli >1 wykonawca>>
