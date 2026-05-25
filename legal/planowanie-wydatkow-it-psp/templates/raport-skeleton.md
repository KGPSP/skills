# Raport finansowy — [NAZWA SYSTEMU] — RRRR-MM-DD

> **Tryb:** [A — POLiOC cz. 42 (obronne 752/75282) / B — POLiOC podstawowy (754/75414) / C — środki własne KG PSP (754/75409)]
> **Status:** [draft / do review / do złożenia]
> **Autor:** [imię nazwisko, komórka KG PSP]
> **Data sporządzenia:** RRRR-MM-DD

---

## 1. Metryczka systemu

| Pole | Wartość |
|---|---|
| Nazwa systemu | [pełna nazwa] |
| Akronim | [np. CEOZO, CEZOL] |
| Właściciel biznesowy | Komendant Główny PSP / [komórka KG PSP] |
| Właściciel techniczny | Biuro Informatyki i Łączności KG PSP / [inna komórka] |
| Charakter systemu | [centralny / resortowy / ogólnokrajowy / wspierający JST / wspierający PSP] |
| Klasyfikacja informacji | [jawne / wewnętrzne / zastrzeżone / wydzielona część niejawna] |
| Model utrzymania | [infrastruktura własna / PaaS / SaaS / hosting NASK / SKR-Z / chmura publiczna / model hybrydowy] |
| Okres finansowania | [rok budżetowy / okres programu / okres umowy] |
| **Źródło finansowania** | **Część 42 MSWiA** (lub 85/XX); **Dział [752 / 754]**; **Rozdział [75282 / 75414 / 75409]** |
| Walutowość | **PLN BRUTTO** (waluty obce przeliczone wg kursu planistycznego) |
| Kurs planistyczny | 1 USD = X,XX PLN (NBP, RRRR-MM-DD) |

## 2. Podstawa prawna

1. **Ustawa o finansach publicznych** — tekst jednolity **Dz.U. 2025 poz. 1483**.
2. **Rozporządzenie klasyfikacja dochodów/wydatków** — **Dz.U. 2026 poz. 582**.
3. **Rozporządzenie klasyfikacja części budżetowych** — **Dz.U. 2025 poz. 1185**.
4. **Ustawa OLiOC z 5.12.2024 r.** — **Dz.U. 2024 poz. 1907** (z 2025 r. poz. 1705), art. [108 / 112 / 155 ust. 2 pkt 3 / 156 / 156a — wskaż konkretny].
5. **Projekt Programu OLiOC 2027–2031** wersja 17 (MSWiA, status: w uzgodnieniach na RRRR-MM-DD).
6. **Ustawa o Obronie Ojczyzny** — art. 40 ust. 1 pkt 2 (tryb A: środki obronne 0,15% PKB).
7. **Ustawa o VAT** — art. 15 ust. 6 (JB nie odlicza), art. 17 ust. 1 pkt 4 (reverse charge / import usług).
8. Przepisy szczególne danego systemu: [wymień].

## 3. Tryb finansowania + obszar/podobszar POLiOC

- **Tryb:** [A / B / C]
- **Część budżetowa:** 42 MSWiA (lub 85/XX wojewoda)
- **Dział:** [752 / 754]
- **Rozdział:** [75282 / 75414 / 75409]
- **Obszar POLiOC (tryb A/B):** [4 Łączność/wykrywanie/alarmowanie / 5 Infrastruktura ochronna / 6 Edukacja / ...]
- **Podobszar POLiOC:** [4e Bezpieczeństwo teleinformatyczne / 5e Pozostałe infrastruktury ochronnej / ...]

## 4. Lista pozycji per sekcja katalogu (z alokacją A/B/C)

| Pozycja | Sekcja katalogu | A/B/C | Typ (CAPEX/OPEX) | § | Uwagi |
|---|---|---|---|---|---|
| [np. Hosting niejawny NASK] | B | A | OPEX | 4300 | warstwa niejawna |
| [np. Cloudflare WAF/CDN] | D | C | OPEX | 4300 | platformowy — klucz alokacji: ruch |
| [np. Pentest cykliczny] | I/D | A | OPEX | 4390 | rocznie |
| ... | ... | ... | ... | ... | ... |

**Małe koszty — checklist** (`references/male-koszty-checklist.md` §1): przejrzane, status każdej z 19 pozycji [TAK/NIE/N/D].

## 5. Tabela kosztorysu szczegółowa III.B (PLN BRUTTO)

| Pozycja (z Cz. II) | Sekcja | C/O | Jednostka | Liczba | Koszt netto PLN | Kurs | VAT/RC | Koszt mies. brutto | **Koszt roczny brutto** | Część | Dział | Rozdz. | § | B/M | Uwagi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| [np. Hosting niejawny NASK] | B | O | mies. | 1 | [wartość] | — | 23% | [obl.] | **[obl.]** | 42 | 752 | 75282 | 4300 | B | [komentarz] |
| [np. Google Maps] | G | O | rok | 1 | [waluta] | 4,00 NBP RRRR-MM-DD | RC 23% | — | **[obl.]** | 42 | 752 | 75282 | 4300 | B | usługa zagraniczna |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

## 6. Uzasadnienia 8-punktowe per pozycja

> Jedna sekcja per wiersz tabeli XLSX (sekcja 7). Pełny szablon w `references/uzasadnienie-8pkt.md`.

### Pozycja: [kod podobszaru] – [nazwa zadania 1]

**Klasyfikacja:** część 42 / dział [752/754] / rozdział [75282/75414/75409] / § [§] / typ [B/M]
**Kwota brutto PLN:** [kwota] zł
**Alokacja:** KG PSP [kwota], Akademia 0, CS Czstch 0, SA Krk 0, SA Pzn 0, SP Bdg 0
**Charakter:** [OPEX bieżący / CAPEX majątkowy]

#### 1. KWALIFIKOWALNOŚĆ DO PROGRAMU
- Obszar: [...]
- Podobszar: [...]
- Zadanie wg Załącznika 2 / asortyment wg Załącznika 3: [...]
- Podstawa ustawowa: [art. OLiOC]

#### 2. CELOWOŚĆ Z UWZGLĘDNIENIEM POSIADANYCH ZASOBÓW
- Stan aktualny: [...]
- Luka: [...]
- Analiza ryzyka — który ze „sześciu skutków krytycznych": [głód/pragnienie/choroby/urazy/temp. wysokie/temp. niskie] LUB „ciągłość działania systemu OC w warunkach zagrożenia"
- Rezultat dla systemu OC: [...]

#### 3. ZGODNOŚĆ Z PLANOWANIEM OBRONNYM
- Powiązanie z Narodowym Programem „Tarcza Wschód": [tak/nie + uzasadnienie]
- Lokalizacja względem obszarów działania SZ: [...]
- Podwójne przeznaczenie (OC/SZ): [tak/nie]

#### 4. LOKALIZACJA GEOGRAFICZNA
- Lokalizacja: [centralna KG PSP / terenowa / rozproszona]
- Modyfikator geograficzny: [+0,3 / +0,2 / +0,1 / 0 / nie dotyczy]

#### 5. KOSZTORYS (sekcja 5 raport.md)
- Kwota netto: [...]
- VAT/RC: [...]
- Kurs planistyczny: [...]
- Rezerwy: utrzymaniowa [%], kursowa [%], overage [%]
- Kwota brutto razem: [...]

#### 6. WSKAŹNIK REALIZACJI
- Aktualny poziom: [0/1/2/3/4/4+]
- Przewidywany poziom po inwestycji: [0/1/2/3/4/4+]
- Wzrost: +[N] punktów

#### 7. OKRES UŻYWANIA (tylko § 6050/6060)
- Planowany okres używania: ≥ 5 lat (pkt 184 Programu)
- Plan utrzymania: [...]

#### 8. PRÓG OPINIOWANIA MSWiA
- Kwota brutto > 100 000 zł: [tak/nie]
- Jeśli tak: załącz wniosek o opinię MSWiA (`wniosek-opinii-[system]-[pozycja]-RRRR-MM-DD.md`)

---

### Pozycja: [kod podobszaru] – [nazwa zadania 2]

[powtórz schemat...]

---

## 7. Tabela w układzie XLSX (do kopiowania do `Propozycja zadań do POLiOC 2027-2031 cz.42.xlsx`)

> Reguła agregacji: jedna pozycja XLSX = jedna grupa funkcjonalna z sekcji 6. Suma kolumn G..L (alokacja per jednostka) **musi się równać** kolumnie F (Kwota brutto).

| Podobszar | Nazwa zadania | Dział | Rozdział | § | Kwota brutto [zł] | KG PSP | Akademia | CS Czstch | SA Krk | SA Pzn | SP Bdg |
|---|---|---|---|---|---|---|---|---|---|---|---|
| [5E] | [np. Utrzymanie CEOZO] | 752 | 75282 | 4300 | 1 080 000 | 1 080 000 | 0 | 0 | 0 | 0 | 0 |
| [5E] | [np. Budowa CEOZO] | 752 | 75282 | 6060 | 1 500 000 | 1 500 000 | 0 | 0 | 0 | 0 | 0 |

**Suma F razem:** [suma w zł]
**Walidacja:** sum(G..L) = F dla każdego wiersza? [TAK/NIE]

## 8. Definition of Done — wynik walidatora

```bash
# Uruchom z katalogu skilla `legal/planowanie-wydatkow-it-psp/`
sh scripts/check-cost-plan.sh \
  --plan raport-[system]-RRRR-MM-DD.md \
  --tryb [A/B/C]
```

**Output:**

```
[tu wklej surowy output walidatora]
```

DoD checklist (zaznacz ✔):
- [ ] F1: Metryczka + tryb + podstawa prawna + obszar/podobszar POLiOC — bez placeholderów.
- [ ] F2: Lista pozycji z A/B/C + checklist małych kosztów.
- [ ] F3: Kurs NBP z datą + każda pozycja brutto + rezerwy jako osobne pozycje.
- [ ] F4: Pełna klasyfikacja UFP per pozycja; żadnego § 4000.
- [ ] F5: 8 punktów uzasadnienia per pozycja (lub 4 dla trybu C); delta wskaźnika numeryczna.
- [ ] F6: Tabela XLSX w sekcji 7; sum(G..L) = F; walidator exit 0.

## 9. Stopka źródeł

| Akt | ELI / Cytowanie | Status |
|---|---|---|
| Ustawa o finansach publicznych — tekst jednolity | DU/2025/1483 | obowiązujący |
| Rozporządzenie klasyfikacja dochodów/wydatków | DU/2026/582 | obowiązujący (IN_FORCE od 29.04.2026) |
| Rozporządzenie klasyfikacja części budżetowych | DU/2025/1185 | obowiązujący |
| Ustawa OLiOC | DU/2024/1907 + DU/2025/1705 | obowiązujący od 1.01.2025 |
| Projekt Programu OLiOC 2027–2031 v17 | MSWiA, w uzgodnieniach (RRRR-MM-DD) | projekt |
| Ustawa o Obronie Ojczyzny | art. 40 ust. 1 pkt 2 | obowiązujący |
| Ustawa o VAT | art. 15 ust. 6 + art. 17 ust. 1 pkt 4 | obowiązujący |

**Weryfikacja przez Sejm ELI API:** sprawdzono `RRRR-MM-DD` przez skill `legal/sejm-eli-api`.
