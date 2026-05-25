# Raport finansowy — CEOZO — 2026-05-25

> Tryb A — POLiOC cz. 42 obronne 752/75282
>
> **Kurs planistyczny: 1 USD = 4,00 PLN (NBP, 2026-05-25)**

## 1. Metryczka systemu

| Pole | Wartość |
|---|---|
| Nazwa systemu | Centralna Ewidencja Obiektów Zbiorowej Ochrony |
| Akronim | CEOZO |
| Walutowość | PLN BRUTTO |
| Kurs planistyczny | 1 USD = 4,00 PLN (NBP, 2026-05-25) |

## 5. Tabela III.B

| Pozycja | § | Koszt roczny brutto | Część | Dział | Rozdział | B/M |
|---|---|---|---|---|---|---|
| Hosting niejawny NASK | 4300 | 1 328 | 42 | 752 | 75282 | B |
| API LLM (reverse charge 23%) | 4300 | 59 040 | 42 | 752 | 75282 | B |
| Google Maps (RC 23%, USD) | 4300 | 7 380 | 42 | 752 | 75282 | B |
| Budowa modułu IAM | 6060 | 1 500 000 | 42 | 752 | 75282 | M |

## 6. Uzasadnienia 8-punktowe per pozycja

## Pozycja: 5E – Utrzymanie i eksploatacja CEOZO

**Klasyfikacja:** część 42 / dział 752 / rozdział 75282 / § 4300 / typ B
**Kwota brutto PLN:** 1 080 000 zł

### 1. KWALIFIKOWALNOŚĆ DO PROGRAMU
- Obszar 5 Infrastruktura ochronna, podobszar 5E.
- Podstawa: art. 108 OLiOC + art. 155 ust. 2 pkt 3 OLiOC.

### 2. CELOWOŚĆ
- Stan: system działa w modelu hybrydowym; brak rezerwy na ciągłość 2027+.
- Ryzyko: ciągłość działania systemu OC w warunkach zagrożenia.
- Rezultat: utrzymanie dostępności ≥ 99,5%.

### 3. ZGODNOŚĆ Z PLANOWANIEM OBRONNYM
- Tarcza Wschód: pośrednie.
- Podwójne przeznaczenie: tak.

### 4. LOKALIZACJA GEOGRAFICZNA
- Lokalizacja: centralna KG PSP.
- Modyfikator: nie dotyczy.

### 5. KOSZTORYS
- Kwota netto: 870 000 zł.
- VAT: mix 23% + RC 23% (Google Maps, Mapbox, Cloudflare, LLM API).
- Kurs planistyczny: NBP 2026-05-25.
- Rezerwy: utrzymaniowa 15%, kursowa 15%, overage 20%.

### 6. WSKAŹNIK REALIZACJI
- Aktualny poziom: 3 (podstawowy).
- Przewidywany poziom: 4 (pełny).
- Wzrost: +1 punkt.

### 7. OKRES UŻYWANIA
- Nie dotyczy — § 4300.

### 8. PRÓG OPINIOWANIA MSWiA
- Kwota brutto > 100 000 zł: tak.
- Załączony osobny wniosek o opinię MSWiA: `wniosek-opinii-CEOZO-utrzymanie-2026-05-25.md`.

---

## Pozycja: 5E – Budowa, rozbudowa i rozwój CEOZO

**Klasyfikacja:** część 42 / dział 752 / rozdział 75282 / § 6060 / typ M
**Kwota brutto PLN:** 1 500 000 zł

### 1. KWALIFIKOWALNOŚĆ DO PROGRAMU
- Obszar 5, podobszar 5E. Art. 108 OLiOC + art. 156a OLiOC (inwestycje wieloletnie).

### 2. CELOWOŚĆ
- Luka: brak modułów IAM, raportowego, integracji z CEZOL.
- Rezultat: rozbudowa funkcjonalna CEOZO.

### 3. ZGODNOŚĆ Z PLANOWANIEM OBRONNYM
- Powiązanie: pośrednie. Podwójne przeznaczenie: tak.

### 4. LOKALIZACJA GEOGRAFICZNA
- Centralna KG PSP. Modyfikator: nie dotyczy.

### 5. KOSZTORYS
- Kwota netto: 1 219 512 zł. VAT: 23%. Rezerwy: rozwojowa 10%.

### 6. WSKAŹNIK REALIZACJI
- Aktualny: 3. Przewidywany: 4. Wzrost: +1 punkt.

### 7. OKRES UŻYWANIA
- Planowany okres używania: ≥ 5 lat (pkt 184 Programu).
- Plan utrzymania: w ramach umowy serwisowej (objęte § 4300).

### 8. PRÓG OPINIOWANIA MSWiA
- Kwota brutto > 100 000 zł: tak.
- Załączony wniosek o opinię MSWiA: `wniosek-opinii-CEOZO-rozbudowa-2026-05-25.md`.
- Inwestycja wieloletnia (art. 156a OLiOC): wykaz z podziałem 2027–2031 załączony.

## 7. Tabela XLSX

| Podobszar | Nazwa zadania | Dział | Rozdział | § | Kwota brutto [zł] | KG PSP | Akademia | CS Czstch | SA Krk | SA Pzn | SP Bdg |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 5E | Utrzymanie CEOZO | 752 | 75282 | 4300 | 1 080 000 | 1 080 000 | 0 | 0 | 0 | 0 | 0 |
| 5E | Budowa CEOZO | 752 | 75282 | 6060 | 1 500 000 | 1 500 000 | 0 | 0 | 0 | 0 | 0 |
