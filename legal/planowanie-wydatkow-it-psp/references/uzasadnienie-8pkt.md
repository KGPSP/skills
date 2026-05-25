---
name: uzasadnienie-8pkt
type: reference
parent: planowanie-wydatkow-it-psp
sources:
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §X.2
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §IX.4
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §IX.5
description: 8-punktowy schemat uzasadnienia per pozycja wniosku (wymóg MSWiA do POLiOC cz. 42 — Cz. X.2 materiału). Załącznik obowiązkowy do XLSX, który nie ma kolumny „Uzasadnienie". Pełna struktura + przykłady CEOZO/CEZOL. Ładowany w F5 (Justify).
---

# 8-punktowy schemat uzasadnienia per pozycja

> Plik XLSX wzorcowy `Propozycja zadań do POLiOC 2027-2031 cz.42.xlsx` **nie ma kolumny „Uzasadnienie"**. Sporządzasz uzasadnienia w raport.md jako **załącznik obowiązkowy**. Bez tego wniosek nie przejdzie kontroli formalnej w MSWiA.

## Reguła agregacji

**Jedna pozycja XLSX = jedna grupa funkcjonalna**, np.:

- „Utrzymanie CEOZO" agreguje wszystkie OPEX hostingowo-operacyjne (hosting NASK + PaaS jawny + LLM + mapy + WAF + monitoring + service desk).
- „Budowa, rozbudowa i rozwój CEOZO" agreguje wszystkie CAPEX (nowe moduły, integracje, API, IAM, akredytacja).

Pełny rozkład per pozycja (każda subskrypcja, każdy hosting osobno) zostaje w **tabeli III.B** w sekcji 5 raport.md. Uzasadnienie 8-punktowe dotyczy **agregatu** (jednego wiersza XLSX).

## Pełny szablon 8 punktów

```markdown
## Pozycja: <kod podobszaru> – <nazwa zadania>

**Klasyfikacja:** część 42 / dział <D> / rozdział <R> / § <§> / typ <B/M>
**Kwota brutto PLN:** <kwota> zł
**Alokacja:** KG PSP <kwota>, Akademia <0>, CS Czstch <0>, SA Krk <0>, SA Pzn <0>, SP Bdg <0>
**Charakter:** OPEX bieżący / CAPEX majątkowy

### 1. KWALIFIKOWALNOŚĆ DO PROGRAMU

- **Obszar:** <numer + nazwa> (np. „Obszar 4 — Łączność oraz wykrywanie, ostrzeganie i alarmowanie")
- **Podobszar:** <kod + nazwa> (np. „4e — Bezpieczeństwo teleinformatyczne")
- **Zadanie wg Załącznika 2 Programu / asortyment wg Załącznika 3:** <wskazanie>
- **Podstawa ustawowa:**
  - art. <X> ustawy OLiOC z 5.12.2024 r. (np. dla CEOZO: art. 108 — Centralna Ewidencja OZO prowadzona w systemie teleinformatycznym; art. 112 — rozbudowa, modyfikacje, ochrona przed nieuprawnionym dostępem)
  - art. 155 ust. 2 pkt 3 OLiOC + art. 40 ust. 1 pkt 2 ustawy o Obronie Ojczyzny (tryb A — środki obronne)

### 2. CELOWOŚĆ Z UWZGLĘDNIENIEM POSIADANYCH ZASOBÓW

- **Stan aktualny (luka):**
  - Co mamy: <opis posiadanej infrastruktury / systemu>
  - Czego brakuje: <konkretna luka — funkcjonalna, wydajnościowa, bezpieczeństwa>
- **Analiza ryzyka** — który ze „sześciu skutków krytycznych" (Cz. IX.4): <głód / pragnienie / choroby / urazy / temperatury wysokie / temperatury niskie> **LUB** „ciągłość działania systemu OC w warunkach zagrożenia" (gdy zadanie infrastrukturalne, nie bezpośrednio adresujące skutek krytyczny)
- **Rezultat dla systemu OC po inwestycji:** <konkretna zdolność, która powstanie / zostanie utrzymana>

### 3. ZGODNOŚĆ Z PLANOWANIEM OBRONNYM

- **Powiązanie z Narodowym Programem „Tarcza Wschód":** <tak/nie + jednoz danie uzasadnienia>
- **Lokalizacja względem obszarów działania SZ:** <ogólnokrajowa centralna / poligonowa / wschodnia>
- **Charakter podwójnego przeznaczenia (OC/SZ):** <tak/nie>
- **Opinia wojewódzkiego zespołu zarządzania kryzysowego** (gdy wymagana): <załączyć / nie dotyczy dla zadań centralnych KG PSP>

### 4. LOKALIZACJA GEOGRAFICZNA

- **Lokalizacja inwestycji / zasobu:** <centralna KG PSP / terenowa / rozproszona>
- **Modyfikator geograficzny** (gdy wojewódzkie):
  - +0,3 dla woj. warmińsko-mazurskiego, podlaskiego, lubelskiego
  - +0,2 dla woj. pomorskiego, podkarpackiego
  - +0,1 dla woj. kujawsko-pomorskiego, mazowieckiego, świętokrzyskiego
  - 0 dla pozostałych
  - „nie dotyczy" dla zadań centralnych KG PSP

### 5. KOSZTORYS (powołanie się na sekcję 5 raport.md — Cz. III.B)

- **Kwota netto:** <kwota> zł (jeśli waluta: <kwota waluta> przeliczone po kursie <X,XX PLN/<waluta>>)
- **VAT:** <23% bezpośrednio / 23% reverse charge import usług / zw. / 8% / 5%>
- **Kurs planistyczny (jeśli waluta):** NBP <RRRR-MM-DD>, 1 <waluta> = <X,XX> PLN
- **Rezerwy:**
  - utrzymaniowa <%> = <kwota> zł
  - kursowa <%> = <kwota> zł
  - overage <%> = <kwota> zł
- **Kwota brutto razem:** <kwota> zł

### 6. WSKAŹNIK REALIZACJI (matryca Załącznika 4 Programu)

System 6-stopniowy:

| Poziom | Nazwa | Kolor | Punkty |
|---|---|---|---|
| 0 | brak | czarny | 0 |
| 1 | niewystarczający | czerwony | 1 |
| 2 | minimalny | żółty | 2 |
| 3 | podstawowy | zielony | 3 |
| 4 | pełny | niebieski | 4 |
| 4+ | pełny z redundancją | złoty | 5 |

- **Aktualny poziom:** <0/1/2/3/4/4+>
- **Przewidywany poziom po inwestycji:** <0/1/2/3/4/4+>
- **Wzrost:** <Δ punktów>

> **OBOWIĄZKOWE: konkretna delta numeryczna.** Sformułowania typu „zwiększy zdolność" / „poprawi efektywność" są niewystarczające — wniosek wraca do uzupełnienia.

### 7. OKRES UŻYWANIA (tylko dla pozycji majątkowych — grupa BP 4, paragrafy 700–769: § 701/702/703/704/711/712/720)

- **Planowany okres używania:** ≥ 5 lat (wymóg pkt 184 Projektu Programu OLiOC 2027–2031)
- **Plan utrzymania:**
  - SLA: <opis poziomu utrzymania po wdrożeniu>
  - Support producenta / wykonawcy: <opis warunków>
  - Plan rozbudowy: <opis kolejnych kroków>
  - Plan wymiany / wyjścia: <co po 5+ latach>
- **Zakaz najmu/zbycia komercyjnego:** uwaga — zbycie przed 5 latami wymaga zgody wojewody (lub MSWiA dla zadań centralnych KG PSP).

### 8. PRÓG OPINIOWANIA MSWiA

- **Kwota brutto > 100 000 zł na 1 rodzaj zakupu:** <tak/nie>
- **Jeśli TAK:** załącz wniosek o opinię ministra spraw wewnętrznych (pkt 166 Programu) — osobny dokument zawierający:
  - opis przedmiotu zakupu,
  - uzasadnienie celowości,
  - kosztorys,
  - planowany termin realizacji,
  - klasyfikację budżetową.
- **Konsekwencja braku opinii:** wstrzymanie wydatkowania do uzyskania opinii.
```

## Skrócony schemat dla trybu C (środki własne KG PSP, poza POLiOC)

Dla trybu C (754/75409, finansowanie z budżetu KG PSP, poza POLiOC) **punkty 1, 3, 4, 6 są opcjonalne** (nie ma matrycy POLiOC). Punkty obowiązkowe:

- **2. Celowość** — luka, ryzyko, rezultat (zawsze).
- **5. Kosztorys** — netto/VAT/kurs/rezerwy (zawsze).
- **7. Okres używania** — gdy pozycja majątkowa (§ 701/702/703/704/711/712/720) — zawsze, choć bez wymogu 5-letniego z OLiOC.
- **8. Próg MSWiA** — 100k brutto (zawsze, jeśli z budżetu MSWiA).

## Przykłady wypełnienia

### Przykład 1 — Utrzymanie CEOZO (OPEX, tryb A, klasyfikacja 2027+)

```markdown
## Pozycja: 5E – Utrzymanie i eksploatacja CEOZO

**Klasyfikacja:** część 42 / dział 752 / rozdział 75282 / § 682 / typ B / grupa BP 3
**Kwota brutto PLN:** 1 080 000 zł
**Alokacja:** KG PSP 1 080 000, Akademia 0, CS Czstch 0, SA Krk 0, SA Pzn 0, SP Bdg 0
**Charakter:** OPEX bieżący — usługi informatyczne (Dz.U. 2026 poz. 582)

### 1. KWALIFIKOWALNOŚĆ DO PROGRAMU
- Obszar: 5 — Infrastruktura ochronna
- Podobszar: 5E — Pozostałe zadania związane z infrastrukturą ochronną
- Zadanie wg Załącznika 2 / asortyment wg Załącznika 3: utrzymanie systemu teleinformatycznego CEOZO
- Podstawa ustawowa: art. 108 OLiOC (CEOZO prowadzona przez KG PSP w systemie teleinformatycznym); art. 112 OLiOC (ochrona przed nieuprawnionym dostępem, integralność, rozliczalność, kopie); art. 155 ust. 2 pkt 3 OLiOC

### 2. CELOWOŚĆ Z UWZGLĘDNIENIEM POSIADANYCH ZASOBÓW
- Stan aktualny: system CEOZO wdrożony 2024-2025 w modelu hybrydowym (NASK niejawna + Replit/PaaS jawna „Gdzie się ukryć"); brak rezerwy budżetowej na ciągłość 2027+.
- Luka: brak zabezpieczenia finansowego na utrzymanie hostingu obu warstw, automatyzacji LLM, map (Google + Mapbox), WAF (Cloudflare), monitoringu, service desku w cyklu 5-letnim programu.
- Analiza ryzyka: ciągłość działania systemu OC w warunkach zagrożenia (przerwa działania CEOZO = brak dostępu organów do ewidencji OZO + brak informowania ludności).
- Rezultat: utrzymanie ciągłości CEOZO 2027–2031 z gwarancją dostępności ≥ 99,5%, bezpieczeństwem warstwy niejawnej i informowaniem ludności o OZO.

### 3. ZGODNOŚĆ Z PLANOWANIEM OBRONNYM
- Powiązanie z „Tarczą Wschód": pośrednie — CEOZO jest częścią ogólnopolskiego systemu OC, wspomaga organy na wschodzie.
- Lokalizacja względem SZ: ogólnokrajowa centralna.
- Podwójne przeznaczenie: tak — warstwa niejawna może wspierać operacje SZ w sytuacji kryzysowej.

### 4. LOKALIZACJA GEOGRAFICZNA
- Lokalizacja: centralna KG PSP (warstwa niejawna w NASK; warstwa jawna w chmurze publicznej).
- Modyfikator geograficzny: nie dotyczy (zadanie centralne).

### 5. KOSZTORYS (sekcja 5 raport.md)
- Kwota netto: ~870 000 zł (mix PLN i USD przeliczonych); szczegóły w III.B.
- VAT: mix 23% bezpośrednio (krajowi dostawcy: NASK, polski service desk) + 23% RC (Google Maps, Mapbox, Cloudflare, LLM API).
- Kurs planistyczny: NBP 2026-05-25, 1 USD = 4,00 PLN.
- Rezerwy: utrzymaniowa 15% = ~140 000 zł, kursowa 15% (pozycje walutowe) = ~30 000 zł, overage API 20% = ~40 000 zł.
- Kwota brutto razem: **1 080 000 zł**.

### 6. WSKAŹNIK REALIZACJI
- Aktualny poziom: **3 (podstawowy)** — system działa, ale bez DR i pełnej redundancji.
- Przewidywany poziom po inwestycji: **4 (pełny)** — po dodaniu DR i automatyzacji backupu.
- Wzrost: **+1 punkt** (z 3 do 4).

### 7. OKRES UŻYWANIA
- Nie dotyczy — pozycja OPEX (§ 4300).

### 8. PRÓG OPINIOWANIA MSWiA
- Kwota brutto > 100 000 zł: **tak** (1 080 000 zł).
- Załączony osobny wniosek o opinię MSWiA: `wniosek-opinii-CEOZO-utrzymanie-2026-05-25.md`.
```

### Przykład 2 — Budowa, rozbudowa CEOZO (CAPEX § 720, tryb A, klasyfikacja 2027+)

```markdown
## Pozycja: 5E – Budowa, rozbudowa i rozwój CEOZO

**Klasyfikacja:** część 42 / dział 752 / rozdział 75282 / § 720 / typ M / grupa BP 4
**Kwota brutto PLN:** 1 500 000 zł
**Alokacja:** KG PSP 1 500 000, pozostałe 0
**Charakter:** CAPEX majątkowy — Inwestycje (wytworzenie nowych modułów CEOZO jako WNiP). Gdy część zakresu obejmuje zakup gotowych licencji bezterminowych → wydziel jako § 712 (lub § 711 jeśli amort. jednorazowo).

(...punkty 1–6 jak w Przykładzie 1, dostosowane do CAPEX...)

### 7. OKRES UŻYWANIA (obowiązkowy — § 6060)
- Planowany okres używania: **≥ 5 lat** (wymóg pkt 184 Programu).
- Plan utrzymania:
  - SLA: utrzymanie nowych modułów w ramach umowy serwisowej (objęte § 4300 — pozycja „Utrzymanie CEOZO").
  - Support producenta: 5 lat gwarancji wsparcia od dostawcy.
  - Plan rozbudowy: integracje z systemami sąsiadującymi (CEZOL, SOiA) w latach 3–5.
  - Plan wymiany / wyjścia: ocena po 5 latach — modernizacja lub migracja na nową generację.

### 8. PRÓG OPINIOWANIA MSWiA
- Kwota brutto > 100 000 zł: **tak**.
- Załączony wniosek o opinię: `wniosek-opinii-CEOZO-rozbudowa-2026-05-25.md`.
- **DODATKOWO** (art. 156a OLiOC — inwestycje wieloletnie): przygotowany **wykaz inwestycji wieloletnich** z podziałem na lata 2027–2031 (np. moduł IAM w 2027, moduł raportowy w 2028, integracja CEZOL w 2029).
```
