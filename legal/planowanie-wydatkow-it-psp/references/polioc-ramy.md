---
name: polioc-ramy
type: reference
parent: planowanie-wydatkow-it-psp
sources:
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §IX
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §XI.3
  - now_skille/materialy_polioc/Projekt-Programu-OLiOC-2027-2031-v17.DOCX
description: Ramy Programu Ochrony Ludności i Obrony Cywilnej 2027–2031 — finansowanie 0,3% PKB (z czego 0,15% obronne w dziale 752), 7 obszarów, kryteria kwalifikowalności, matryca wskaźników 0–4+, dyslokacja geograficzna, próg 100k MSWiA, inwestycje wieloletnie. Ładowany w F1 (wybór obszaru/podobszaru) oraz F5 (uzasadnienie 8-pkt).
---

# Program Ochrony Ludności i Obrony Cywilnej 2027–2031 — ramy

> **Źródło:** Projekt POLiOC 2027–2031 v17 (MSWiA, w uzgodnieniach na 2026-05-25). Plik: `now_skille/materialy_polioc/Projekt-Programu-OLiOC-2027-2031-v17.DOCX`.
>
> **Status:** Projekt w procesie uzgodnieniowym (MON + KW Rządu i ST). Wartości i klasyfikacje wiążące dla danego roku budżetowego; dla kolejnych lat — prognozy.

## 1. Podstawa i mechanizm finansowania

| Element | Wartość |
|---|---|
| Akt podstawowy | Ustawa OLiOC z 5.12.2024 r. — art. 7, 155, 156, 156a |
| Perspektywa | **1.01.2027 – 31.12.2031** (5 lat) |
| Łączny limit środków | **≥ 0,3% PKB rocznie** (art. 155 ust. 1 OLiOC) |
| Z tego: **środki obronne** | **0,15% PKB** ze środków wydatków obronnych (art. 40 ust. 1 pkt 2 ustawy o Obronie Ojczyzny) → **dział 752** |
| Z tego: pozostałe | MSWiA + wojewodowie + RARS + zdrowie/NFZ → **dział 754** lub inne |
| Podział środków obronnych | **≥ 85% wojewodowie + JST** (część 85/XX); **≤ 15% MSWiA centralnie** (część 42) |
| Termin wydatkowania | Do 31.12 danego roku; rozliczenie do 31.01; sprawozdanie do MSWiA do 31.03 |
| Minimalny okres używania ŚT z OLiOC | **5 lat** (przed zbyciem zgoda wojewody; zakaz najmu/zbycia komercyjnego) |
| **Próg zaopiniowania MSWiA** | **inwestycje budowlane + zakupy > 100 000 zł brutto na 1 rodzaj zakupu** (pkt 166 Programu) |

## 2. 7 obszarów Programu — matryca decyzyjna dla systemów IT KG PSP

| Obszar | Nazwa | Podobszary | Co znaczy dla IT KG PSP |
|---|---|---|---|
| **1** | Personel ochrony ludności | 1a–1e | Szkolenia, mobilizacja, korpus OC. IT: rejestry kadr OC |
| **2** | Ciągłość działania i baza magazynowa | 2a–2e | Energia, woda, żywność, magazyny. IT: ewidencje zasobów magazynowych (część CEZOL) |
| **3** | Wyposażenie podmiotów ochrony ludności | 3a–3e | Sprzęt ratowniczy, ewakuacja, pojazdy. **Dla PSP min. 75% obszaru 3** (z czego ≥ 50% dla OSP). IT: ewidencje sprzętu |
| **4** | **Łączność oraz wykrywanie, ostrzeganie i alarmowanie** | 4a SBŁP-T, 4b sprzęt łączności, 4c wykrywanie zagrożeń, 4d SPOA (powiadamianie/syreny), **4e Bezpieczeństwo teleinformatyczne** | **KLUCZOWY dla IT KG PSP** — 4e obejmuje CEZOL, SIEM/SOC, EDR, LLM API, backup |
| **5** | **Infrastruktura ochronna** | 5a budowle ochronne, 5b miejsca doraźne, 5c punkty schronienia, 5d odporna infrastruktura medyczna, **5e Pozostałe** | **5e = CEOZO** (decyzja MSWiA — ewidencja OZO nie jest sama w sobie budowlą/punktem) |
| **6** | Edukacja i szkolenia | 6a–6e | Szkolenia, ćwiczenia, baza poligonowa, badania, dezinformacja. IT: platformy e-learning, narzędzia analityczne |
| **7** | Komponent medyczny Szefa OC | (bez podobszarów) | Wyłącznie centralnie MSWiA, ≥ 0,5% środków centralnych |

### Matryca systemów IT KG PSP → obszar/podobszar (Cz. XI.3)

| System | Obszar | Podobszar | Uzasadnienie |
|---|---|---|---|
| **CEOZO** (Centralna Ewidencja Obiektów Zbiorowej Ochrony) | **5** | **5E** | Decyzja MSWiA: system ewidencjonujący OZO nie jest sam w sobie budowlą/punktem ochronnym → „pozostałe" |
| **CEZOL** (Centralna Ewidencja Zasobów Ochrony Ludności) | **4** | **4E** | Razem z SIEM/SOAR/EDR, LLM API i backupem centralnym = warstwa cyberbezpieczeństwa portfela PSP |
| Bezpieczeństwo teleinf. wspólne (SIEM, SOAR, EDR, PKI, kopie) | **4** | **4E** | Koszt platformowy (alokacja C wg Cz. VII.2) — proporcjonalnie na portfel |
| LLM API + GPU dla analizy zagrożeń | **4** | **4E** | Uwzględnij rezerwę overage 10–20% |
| SOiA (System Ostrzegania i Alarmowania — gdy taki projekt) | **4** | **4D** (SPOA) | Powiadamianie ludności, syreny — operacyjne |
| Platformy e-learning / szkoleniowe | **6** | **6A/6B/6E** | Zależnie od typu — szkolenia/ćwiczenia/dezinformacja |

> **W razie wątpliwości** — sprawdź Załącznik 2 Programu (lista zadań) i Załącznik 3 (asortyment). Konsultuj z dysponentem (MSWiA) przed złożeniem wniosku.

## 3. Klasyfikacja budżetowa w POLiOC — kluczowe rozróżnienie

> **TO ZMIENIA DOMYŚLNE ZAŁOŻENIA Z CZ. IV materiału.** Dla środków OLiOC 0,15% PKB (obronnych) klasyfikacja **NIE jest** w dziale 754, tylko w **752**.

| Wariant finansowania | Część | Dział | Rozdział |
|---|---|---|---|
| **Środki obronne OLiOC** (0,15% PKB) — **dla PSP** | **42** lub 85/XX | **752** Obrona narodowa | **75282** Zadania obronne PSP |
| Środki obronne OLiOC — pozostałe (nie-PSP) | jw. | 752 | 75281 Zadania obronne (ogólne) |
| Środki podstawowe OLiOC (poza 0,15%) | 42 / 85/XX / inne | **754** Bezpieczeństwo publ. i ochrona ppoż. | 75414 Obrona cywilna **lub** 75409 KG PSP |
| Rezerwa celowa Programu | **83** Rezerwy celowe | przepływ do docelowej | — |

## 4. Kryteria kwalifikowalności — trzy łączne

Każda inwestycja musi spełniać **łącznie** trzy kryteria:

### Kryterium 1: Celowość z uwzględnieniem posiadanych zasobów

- Nowe zasoby muszą **realnie wzmocnić zdolności OC**.
- Identyfikacja **luki** wobec analizy ryzyka i potrzeb systemu.
- Konkretny **rezultat dla systemu OC** (nie ogólniki).

### Kryterium 2: Zgodność z planowaniem obronnym

- **Opiniowanie przez wojewódzki zespół zarządzania kryzysowego** przy udziale MON i SZ.
- Uwzględnienie **Narodowego Programu „Tarcza Wschód"**.
- Lokalizacje **obiektów podwójnego przeznaczenia** (OC ↔ SZ).

### Kryterium 3: Prawidłowa dyslokacja geograficzna

- Racjonalne rozmieszczenie zasobów na obszarze kraju.
- Kompensowanie kryterium ludnościowego **współczynnikami wschodnimi**:

| Modyfikator | Województwa |
|---|---|
| **+0,3** | warmińsko-mazurskie, podlaskie, lubelskie |
| **+0,2** | pomorskie, podkarpackie |
| **+0,1** | kujawsko-pomorskie, mazowieckie, świętokrzyskie |
| 0 | pozostałe |

> Dla zadań **centralnych KG PSP** modyfikator nie ma zastosowania (zadanie centralne, nie wojewódzkie). Wpisz „nie dotyczy".

## 5. Sześć skutków krytycznych — do analizy ryzyka

W uzasadnieniu (pkt 2 schematu) wskaż, który ze **sześciu skutków krytycznych** adresuje inwestycja:

1. **Głód**
2. **Pragnienie**
3. **Choroby**
4. **Urazy**
5. **Następstwa zbyt wysokich temperatur**
6. **Następstwa zbyt niskich temperatur**

Dla zadań **infrastrukturalnych IT** (np. CEOZO, CEZOL, SIEM) najczęściej żaden z sześciu skutków nie jest adresowany bezpośrednio — wpisz alternatywę: **„ciągłość działania systemu OC w warunkach zagrożenia"**.

## 6. Wskaźniki realizacji — system 6-stopniowy (Załącznik 4 Programu)

| Poziom | Nazwa | Kolor | Punkty |
|---|---|---|---|
| 0 | brak | czarny | 0 |
| 1 | niewystarczający | czerwony | 1 |
| 2 | minimalny | żółty | 2 |
| 3 | podstawowy | zielony | 3 |
| 4 | pełny | niebieski | 4 |
| 4+ | pełny z redundancją | złoty | 5 |

Wskaźniki przypisane do podobszarów (matryca w Załączniku 4 Programu). We wniosku **organ musi określić przewidywany wzrost wskaźnika po inwestycji** — konkretną deltę numeryczną (z 3 do 4, +1 punkt).

## 7. Inwestycje wieloletnie (art. 156a OLiOC)

Inwestycje budowlane wieloletnie (CEOZO budowa, CEZOL rozbudowa wieloletnia, itp.) wymagają **odrębnego trybu**:

- **Wykaz inwestycji wieloletnich** zatwierdza MSWiA.
- W wykazie: **podział na lata 2027–2031** z limitem wydatków na każdy rok.
- W raport.md (sekcja CAPEX) wskaż:
  - Rok 2027: <kwota brutto>
  - Rok 2028: <kwota brutto>
  - Rok 2029: <kwota brutto>
  - Rok 2030: <kwota brutto>
  - Rok 2031: <kwota brutto>
  - **Razem 2027–2031: <suma>**

## 8. Próg 100 000 zł brutto — opiniowanie MSWiA (pkt 166 Programu)

**Każda pozycja > 100 000 zł brutto na 1 rodzaj zakupu** wymaga opinii ministra spraw wewnętrznych. W praktyce **wszystkie pozycje IT POLiOC** są > 100k (np. utrzymanie CEOZO ~1 mln/rok).

### Załącznik per pozycja > 100k

Plik: `wniosek-opinii-<system>-<pozycja>-<RRRR-MM-DD>.md`

Zawartość:
1. **Przedmiot zakupu** — szczegółowy opis (co konkretnie).
2. **Uzasadnienie celowości** — luka, ryzyko, rezultat.
3. **Kosztorys** — netto/VAT/kurs/brutto, z rezerwami.
4. **Klasyfikacja budżetowa** — pełna ścieżka część/dział/rozdział/§/B/M.
5. **Planowany termin realizacji** — kwartał/miesiąc.
6. **Plan utrzymania (gdy ŚT)** — ≥ 5 lat.
7. **Powołanie na podstawę prawną** — art. OLiOC + pkt Programu.

## 9. Stan na 2026-05-25 — co śledzić

- **Projekt POLiOC v17** jest w uzgodnieniach (MON + KW Rządu i ST). Wartości mogą się zmienić przed uchwałą RM.
- **Plik źródłowy XLSX** `Propozycja zadań do POLiOC 2027-2031 cz.42.xlsx` używa `§ 4000` (placeholder) — zastąp szczegółowym przed złożeniem.
- **Ścieżka uchwalenia** — uchwała Rady Ministrów (kompetencja z art. 156 OLiOC). Po uchwale: roczne aktualizacje przez MSWiA.
- **Sprawdzaj zmiany w projekcie** — śledź wersje DOCX w `now_skille/materialy_polioc/`.
