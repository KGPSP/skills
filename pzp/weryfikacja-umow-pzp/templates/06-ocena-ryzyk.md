---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa postępowania>>"
zamawiajacy: <<nazwa zamawiającego>>
wykonawca: <<nazwa wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email autora>>
typ_dokumentu: ocena-ryzyk
status: <<draft | final>>
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/ocena-ryzyk
---

# Ocena ryzyk kontraktowych — <<sygnatura>>

> [!info] Struktura
> Ryzyka grupowane wg **8 kategorii** z sekcji V promptu weryfikacyjnego. Dla każdego ryzyka: źródło + dotknięty zapis + możliwy skutek + poziom istotności + rekomendacja.

---

## 1. Ryzyka dla zamawiającego

### 1.1. <<Nazwa ryzyka>>

- **Źródło:** <<brak klauzuli kontroli / niejasna procedura odbioru / …>>
- **Dotknięty zapis:** <<§ N ust. M / brak odpowiedniego zapisu>>
- **Możliwy skutek:** <<konkret — „strata finansowa do X zł", „konieczność przyjęcia nienależytego wykonania", „zarzut KIO", „unieważnienie umowy — art. 457 Pzp">>
- **Poziom istotności:** R<<1/2/3/4>>
- **Rekomendacja:** [[05-proponowane-poprawki-<<slug>>#P-XXX]] — <<krótki opis>>

### 1.2. <<Ryzyko>>

<<analogicznie>>

---

## 2. Ryzyka dla wykonawcy

> [!info] Uwaga
> Nadmierne ryzyko dla wykonawcy = potencjalna klauzula abuzywna (art. 433 Pzp) = ryzyko dla zamawiającego, ponieważ abuzywne postanowienie jest nieważne, a umowa musi być wykonywana bez tego postanowienia (art. 58 § 3 k.c. w zw. z art. 8 Pzp).

### 2.1. <<Nazwa ryzyka>>

- **Źródło:** <<rażąca dysproporcja kar / ograniczenie wynagrodzenia / arbitralne zasady płatności>>
- **Dotknięty zapis:** <<§>>
- **Skutek:** <<spór sądowy / zarzut KIO / nieważność postanowienia>>
- **Poziom:** R<<...>>
- **Rekomendacja:** [[05-proponowane-poprawki-<<slug>>#P-XXX]]

---

## 3. Ryzyka dla realizacji projektu

### 3.1. <<Nazwa ryzyka>>

- **Źródło:** <<brak mechanizmu rozwiązywania problemów / niepełna procedura zmian / brak klauzuli siły wyższej>>
- **Dotknięty zapis:** <<§>>
- **Skutek:** <<opóźnienie realizacji / wymuszenie aneksu / spór o zakres>>
- **Poziom:** R<<...>>
- **Rekomendacja:** [[05-proponowane-poprawki-<<slug>>#P-XXX]]

---

## 4. Ryzyka dla odbioru

### 4.1. <<Nazwa ryzyka>>

- **Źródło:** <<niejasne kryteria akceptacji / brak procedury odmowy odbioru / niejasny termin odbioru>>
- **Dotknięty zapis:** <<§>>
- **Skutek:** <<niemożność odmowy odbioru mimo wad / wymuszenie akceptacji / milczące uznanie odbioru>>
- **Poziom:** R<<...>>
- **Rekomendacja:** [[05-proponowane-poprawki-<<slug>>#P-XXX]]

---

## 5. Ryzyka dla rozliczenia

### 5.1. <<Nazwa ryzyka>>

- **Źródło:** <<niejasne zasady fakturowania / brak potrącenia kar z wynagrodzenia / brak precyzji terminu płatności>>
- **Dotknięty zapis:** <<§>>
- **Skutek:** <<konieczność dodatkowego postępowania windykacyjnego o kary umowne / opóźnienie rozliczenia / spór o prawidłowość faktury>>
- **Poziom:** R<<...>>
- **Rekomendacja:** [[05-proponowane-poprawki-<<slug>>#P-XXX]]

---

## 6. Ryzyka dla dochodzenia roszczeń

### 6.1. <<Nazwa ryzyka>>

- **Źródło:** <<brak klauzuli odszkodowawczej / brak zasady kumulacji kar i odszkodowań / brak forum właściwego>>
- **Dotknięty zapis:** <<§>>
- **Skutek:** <<niemożność dochodzenia odszkodowania ponad karę umowną / niejasny sąd właściwy / koszt sporu>>
- **Poziom:** R<<...>>
- **Rekomendacja:** [[05-proponowane-poprawki-<<slug>>#P-XXX]]

---

## 7. Ryzyka dla kontroli / audytu

### 7.1. <<Nazwa ryzyka>>

- **Źródło:** <<brak klauzul kontroli (NIK, UZP, CBA) / brak dostępu do dokumentacji wykonawcy / brak logów audytowych (dla IT)>>
- **Dotknięty zapis:** <<§>>
- **Skutek:** <<niemożność przeprowadzenia kontroli / brak dowodów w razie sporu / zarzut naruszenia finansów publicznych>>
- **Poziom:** R<<...>>
- **Rekomendacja:** [[05-proponowane-poprawki-<<slug>>#P-XXX]]

---

## 8. Ryzyka dla zgodności z zasadami zamówień publicznych

> [!danger] Ryzyka strukturalne
> Ryzyko uznania umowy za zawartą z naruszeniem Pzp → unieważnienie (art. 457), konsekwencje administracyjne.

### 8.1. <<Nazwa ryzyka>>

- **Źródło:** <<klauzula abuzywna / zmiana poza art. 455 / obejście zasady równego traktowania>>
- **Dotknięty zapis:** <<§>>
- **Skutek:** <<art. 457 Pzp — nieważność / art. 458 Pzp — roszczenia / postępowanie kontrolne UZP / KIO>>
- **Poziom:** R<<...>>
- **Rekomendacja:** [[05-proponowane-poprawki-<<slug>>#P-XXX]]

---

## Macierz ryzyk — podsumowanie

| Kategoria | Liczba ryzyk R1 | Liczba ryzyk R2 | Liczba ryzyk R3 | Liczba ryzyk R4 | RAZEM |
|-----------|------------------|-------------------|-------------------|-------------------|-------|
| 1. Dla zamawiającego | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 2. Dla wykonawcy | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 3. Dla realizacji | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 4. Dla odbioru | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 5. Dla rozliczenia | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 6. Dla dochodzenia roszczeń | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 7. Dla kontroli / audytu | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| 8. Dla zgodności z PZP | <<N>> | <<N>> | <<N>> | <<N>> | <<N>> |
| **RAZEM** | **<<N>>** | **<<N>>** | **<<N>>** | **<<N>>** | **<<N>>** |

## Top 5 ryzyk wymagających priorytetowej mitygacji

> Uszeregowane wg istotności (nie tylko poziomu R, ale kombinacji poziom × prawdopodobieństwo × skutek)

1. **<<Nazwa ryzyka>>** (R<<X>>) — <<opis>> → [[05-proponowane-poprawki-<<slug>>#P-XXX]]
2. **<<...>>** (R<<X>>) — <<...>> → [[05-proponowane-poprawki-<<slug>>#P-XXX]]
3. **<<...>>** → <<...>>
4. **<<...>>** → <<...>>
5. **<<...>>** → <<...>>

## Ryzyka pozostałe po wdrożeniu wszystkich rekomendowanych poprawek

> [!info] Ryzyka rezydualne
> Nawet po wdrożeniu wszystkich poprawek pewne ryzyka pozostają — wynika to z natury zamówienia, zmienności rynku, ograniczeń ustawowych. Wskaż, jakich zagrożeń nie da się wyeliminować redakcyjnie.

1. **<<np. Ryzyko znaczącej zmiany wskaźnika waloryzacji powyżej założonego cap-u>>** — <<opis + mitygacja operacyjna>>
2. **<<np. Ryzyko niedostępności rynkowej zasobów po stronie wykonawcy>>** — <<...>>
3. **<<...>>** — <<...>>

## Powiązania

- [[01-raport-glowny-<<slug-sygnatury>>]]
- [[02-tabela-ustalen-krytycznych-<<slug-sygnatury>>]]
- [[05-proponowane-poprawki-<<slug-sygnatury>>]]
- [[07-wnioski-koncowe-<<slug-sygnatury>>]]
