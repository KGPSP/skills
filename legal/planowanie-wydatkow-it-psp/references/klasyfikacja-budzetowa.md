---
name: klasyfikacja-budzetowa
type: reference
parent: planowanie-wydatkow-it-psp
sources:
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §IV
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §IX.2
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §XI.1
description: Pełna klasyfikacja UFP (część → dział → rozdział → § → typ B/M) dla wydatków IT KG PSP. Trzy warianty: A (POLiOC cz. 42 obronne 752/75282), B (POLiOC podstawowy 754/75414), C (środki własne KG PSP 754/75409). Matryca paragrafów + pułapki klasyfikacyjne. Ładowany w F4 (Classify).
---

# Klasyfikacja budżetowa wg ustawy o finansach publicznych

> **Pomyłka w klasyfikacji = ryzyko zarzutu naruszenia DFP** (art. 5–18a ustawy z 17.12.2004 r. o odpowiedzialności za naruszenie dyscypliny finansów publicznych).

## 1. Trzy warianty klasyfikacji — wybór w F1

| Tryb | Źródło finansowania | Część | Dział | Rozdział | Podstawa prawna |
|---|---|---|---|---|---|
| **A** | **POLiOC cz. 42 (środki obronne 0,15% PKB)** | **42** MSWiA | **752** Obrona narodowa | **75282** Zadania obronne PSP | art. 155 ust. 2 pkt 3 OLiOC + art. 40 ust. 1 pkt 2 ustawy o Obronie Ojczyzny + pkt 41 Projektu POLiOC 2027–2031 |
| B | POLiOC podstawowy (poza 0,15%) | 42 / 85/XX | 754 | **75414** Obrona cywilna | art. 155 ust. 1 OLiOC |
| C | Środki własne KG PSP poza POLiOC | 42 | 754 | **75409** KG PSP | budżet zwykły MSWiA |
| (D) | Inne podmioty obronne (nie-PSP) | 42 / 85/XX | 752 | 75281 Zadania obronne (ogólne) | jak A, ale dla innych organów |
| (R) | Rezerwa celowa Programu OLiOC | **83** Rezerwy celowe | przepływ do docelowej | — | dystrybucja decyzją RM |

> **WAŻNE (Cz. XI.1):** Dla wniosków do POLiOC cz. 42 (środki obronne) klasyfikacja idzie w **752/75282, NIE w 754**. Wcześniejsze założenie domyślne 754/75414 jest słuszne tylko dla trybu B/C.

### Pełna lista części 85/XX (województwa, gdy wniosek terenowy)

| Część | Województwo | Część | Województwo |
|---|---|---|---|
| 85/02 | dolnośląskie | 85/20 | podlaskie |
| 85/04 | kujawsko-pomorskie | 85/22 | pomorskie |
| 85/06 | lubelskie | 85/24 | śląskie |
| 85/08 | lubuskie | 85/26 | świętokrzyskie |
| 85/10 | łódzkie | 85/28 | warmińsko-mazurskie |
| 85/12 | małopolskie | 85/30 | wielkopolskie |
| 85/14 | mazowieckie | 85/32 | zachodniopomorskie |
| 85/16 | opolskie | | |
| 85/18 | podkarpackie | | |

## 2. Dział 754 — Bezpieczeństwo publiczne i ochrona przeciwpożarowa (tryb B/C)

| Rozdział | Nazwa | Zastosowanie |
|---|---|---|
| **75409** | Komenda Główna PSP | Wydatki KG PSP — systemy centralne (CEOZO, CEZOL, SOiA), warstwa centralna, BIiŁ |
| 75410 | Komendy wojewódzkie PSP | Wydatki KW PSP (z części 85/XX wojewody) |
| 75411 | Komendy powiatowe PSP | Wydatki KP/KM PSP |
| 75412 | Ochotnicze straże pożarne | OSP |
| 75413 | Pozostałe jednostki ochrony ppoż. | inne jednostki |
| **75414** | Obrona cywilna | Zadania OLiOC (środki podstawowe — poza 0,15%) |
| 75415 | Ratownictwo górskie i wodne | GOPR/TOPR/WOPR |
| 75421 | Zarządzanie kryzysowe | |

## 3. Dział 752 — Obrona narodowa (tryb A)

| Rozdział | Nazwa | Zastosowanie |
|---|---|---|
| 75281 | Zadania obronne wynikające z OLiOC (ogólne) | inne podmioty obronne (nie-PSP) |
| **75282** | **Zadania obronne wynikające z OLiOC realizowane przez PSP** | **Cały wniosek PSP do POLiOC cz. 42** |

## 4. Wydatki bieżące vs majątkowe — kategorie

### Próg środka trwałego (art. 16d CIT)

| Wartość początkowa | Okres używania | Klasyfikacja | § | Typ |
|---|---|---|---|---|
| **< 10 000 zł NETTO** | dowolny | materiał / wyposażenie | **4210** | bieżący |
| **≥ 10 000 zł NETTO** | **> 1 rok** | środek trwały lub WNiP | **6060** | **majątkowy** |
| ≥ 10 000 zł netto | ≤ 1 rok | materiał | 4210 | bieżący |

> Próg dotyczy WARTOŚCI NETTO, nie brutto. Komputer brutto 12 054 zł / netto 9 800 zł → **§ 4210** (materiał), nie § 6060.

### 4 kategorie wydatków IT

| Kategoria | Definicja | Przykład | § |
|---|---|---|---|
| **Środek trwały rzeczowy** | Składnik materialny ≥ 10k netto, > 1r | Serwer, stacja robocza, sprzęt sieciowy, UPS | **6060** |
| **WNiP** | Prawo majątkowe (licencja, oprogramowanie, autorskie prawa) ≥ 10k netto, > 1r | Licencja **wieczysta**, autorskie prawa do kodu | **6060** |
| **Usługa** | Świadczenie ciągłe/jednorazowe bez trwałego prawa | PaaS, SaaS, hosting, mapy API, LLM API, pentest, service desk | **4300** (lub 4350/4360/4390/4700) |
| **Materiał** | Składnik < 10k netto lub ≤ 1r | Akcesoria, kable, drobny sprzęt | **4210** |

## 5. Pułapki klasyfikacyjne (NAJCZĘSTSZE BŁĘDY — czytaj uważnie)

### Pułapka 1: Subskrypcja roczna SaaS ≠ WNiP

**Roczna subskrypcja nie daje trwałego prawa** → zawsze **§ 4300**, niezależnie od wartości. Tylko **licencje wieczyste** lub > 1 rok z opłaceniem z góry i ≥ 10 000 zł → § 6060.

Przykład: subskrypcja GitHub Enterprise 30 000 zł/rok → § 4300 (NIE § 6060).

### Pułapka 2: Licencja czasowa (1 rok) ≠ WNiP

Tylko licencje wieczyste lub > 1 roku z opłaceniem z góry → § 6060. Roczna licencja na rok → § 4300.

### Pułapka 3: Drobna rozbudowa ≠ § 6050

**§ 6050 tylko dla:**
- Budowy nowego systemu,
- Istotnej modernizacji,
- Rozbudowy funkcjonalnej o znaczącej wartości,
- Wytworzenia nowego modułu.

**Drobne poprawki / usuwanie błędów / niewielkie zmiany** → OPEX § 4300.

### Pułapka 4: Brutto vs netto przy progu 10 000 zł

Próg 10 000 zł z art. 16d CIT dotyczy **wartości początkowej NETTO**. W sprawozdaniu budżetowym kwoty są **brutto**.

Konsekwencja: komputer brutto 12 054 zł / netto 9 800 zł → **§ 4210** (NIE § 6060), bo netto < 10k.

### Pułapka 5: Hosting + drobna rozbudowa w jednej fakturze

**Rozdziel pozycje:**
- Hosting → § 4300 (bieżący),
- Rozbudowa → § 6050 (majątkowy) — jeśli to istotne wytworzenie.

Nie kwalifikuj całości jako § 4300 ani jako § 6050.

### Pułapka 6: Pentest przed odbiorem vs cykliczny

| Typ pentestu | § | Charakter |
|---|---|---|
| Przed odbiorem nowego systemu (część kosztu wytworzenia) | **6050** | majątkowy |
| Cykliczny (rocznie / po dużej zmianie) | **4390** lub 4300 | bieżący |

### Pułapka 7: § 4000 nie istnieje jako pozycja klasyfikacji

W rozporządzeniu Dz.U. 2026 poz. 582 **nie ma czterocyfrowego paragrafu „4000"** jako pozycji wydatkowej. To **placeholder/zbiór paragrafów 4xxx**.

**Zastąp § 4000 szczegółowym** (4210/4260/4300/4350/4360/4390/4700) wg matrycy poniżej.

> **Uwaga o spójności:** skrócona matryca paragrafów w `SKILL.md` (faza F4, sekcja „Skrócona matryca paragrafów") jest **derywatem §6–8 tego pliku** i służy nawigacji w głównej procedurze. Przy aktualizacji paragrafów lub progów (np. zmiana art. 16d CIT, nowe rozporządzenie klasyfikacji wydatków) **zaktualizuj oba miejsca jednocześnie** — pełną matrycę tutaj i wyciąg w SKILL.md F4. W razie rozbieżności **ten plik jest źródłem prawdy** (`source: now_skille/materialy_polioc/material_przeliczanie_kosztow.md §IV`).

## 6. Matryca paragrafów — wydatki BIEŻĄCE (typ B)

| § | Nazwa | Typowe zastosowanie IT |
|---|---|---|
| **4170** | Wynagrodzenia bezosobowe | Umowy zlecenia/dzieło z osobami fizycznymi (konsultacje, kodowanie ad-hoc, audyt) |
| **4210** | Zakup materiałów i wyposażenia | Sprzęt < 10 000 zł netto, akcesoria, kable, materiały eksploatacyjne |
| **4260** | Zakup energii | Prąd, woda, gaz (np. serwerownia) |
| **4270** | Zakup usług remontowych | Remonty pomieszczeń serwerowni |
| **4300** | **Zakup usług pozostałych** | **DOMYŚLNY § dla większości usług IT:** hosting, SaaS, PaaS, mapy API, LLM API, service desk, integracje, transfer, CDN, WAF (gdy usługa), backup zarządzany |
| **4350** | Zakup usług dostępu do sieci Internet | Łącza internetowe (podstawowe, zapasowe) |
| **4360** | Opłaty z tytułu zakupu usług telekomunikacyjnych | Telefonia, GSM/LTE/5G, APN M2M, SMS API, łącza WAN telekomunikacyjne |
| **4390** | Zakup usług obejmujących wykonanie ekspertyz, analiz i opinii | **Pentest cykliczny, audyt bezpieczeństwa, audyt zgodności, ekspertyza techniczna, DPIA zewn., analizy ryzyka, testy WCAG zewn.** |
| **4700** | Szkolenia pracowników NIE SC | Szkolenia administratorów, operatorów, service desk (dla SC są 4550/4710) |
| 4810 | Rezerwy | Rezerwy budżetowe (gdy planowane jako odrębna pozycja) |

## 7. Matryca paragrafów — wydatki MAJĄTKOWE (typ M)

| § | Nazwa | Typowe zastosowanie IT |
|---|---|---|
| **6050** | **Wydatki inwestycyjne jednostek budżetowych** | **Budowa nowego systemu, istotna modernizacja, rozbudowa funkcjonalna o znaczącej wartości, wytworzenie nowego modułu**, infrastruktura tworzona od zera. Praktycznie: ponoszone na **wytworzenie** ŚT/WNiP (nie na **zakup gotowego**); obejmuje projekt, analizy, programowanie, testy przedwdrożeniowe, dokumentację powykonawczą. |
| **6060** | **Wydatki na zakupy inwestycyjne JB** | **Zakup gotowych** ŚT (serwery, stacje robocze ≥ 10k, sprzęt sieciowy ≥ 10k) **i WNiP** (licencje wieczyste ≥ 10k z okresem > 1 r.). |

## 8. Matryca skrócona: katalog Cz. II → paragrafy

| Sekcja katalogu | Dominujący § | Wyjątki |
|---|---|---|
| A. Środowiska | 4300 | 6050 gdy budowa od zera |
| B. Infrastruktura i hosting | 4300 | 6050 wytworzenie środowiska; 6060 serwery ≥ 10k |
| C. Łączność i sieć | **4350** Internet / **4360** telekom | 4300 dla domen/DNS; 6060 sprzęt sieciowy ≥ 10k |
| D. Bezpieczeństwo | 4300 (usługi) | **4390** pentest/audyt; 6060 HSM/EDR ≥ 10k; 6050 SIEM/SOC od zera |
| E. Monitoring | 4300 | 6050 wdrożenie własnego monitoringu od zera |
| F. Service desk | 4300 | 4170 konsultanci |
| G. Dane, mapy, API | 4300 | wszystkie subskrypcje |
| H. Narzędzia wytwórcze | 4300 | **6060** licencje wieczyste ≥ 10k > 1r |
| I. Testy i jakość | 4300 | **4390** zewn. testy; 6050 testy przed odbiorem |
| J. Dokumentacja, zgodność | **4390** ekspertyzy / 4300 bieżąca | |
| K. Konta i uprawnienia | 4300 | |
| L. Zespół | uposażenia 4010/4020/4040/4110/4120 / **4170** zlec. / 4300 firma zewn. | **6050** programiści wytwarzający nowy system |
| M. Sprzęt pomocniczy | **4210** < 10k / **6060** ≥ 10k > 1r | **4260** energia |
| N. Szkolenia | **4700** NIE SC / 4550/4710 SC | 6050 pilotaż przed odbiorem |
| O. Rezerwy | 4300 lub 4810 | |

## 9. Pełna ścieżka klasyfikacyjna — przykład end-to-end

> Zakup rocznej subskrypcji Google Maps API (1 500 USD/rok) na potrzeby warstwy jawnej CEOZO „Gdzie się ukryć", finansowany z POLiOC cz. 42.

| Element | Wartość |
|---|---|
| Tryb | **A — POLiOC cz. 42 (środki obronne)** |
| Część | **42 — Sprawy wewnętrzne (MSWiA)** (ewent. uruchomione z 83 → 42) |
| Dział | **752 — Obrona narodowa** |
| Rozdział | **75282 — Zadania obronne PSP** |
| Paragraf | **§ 4300 — Zakup usług pozostałych** (subskrypcja roczna, NIE WNiP) |
| Typ wydatku | **bieżący (B)** |
| Kwota netto USD | 1 500 USD |
| Kurs planistyczny | NBP, np. 4,00 PLN/USD z 2026-05-25 |
| Netto PLN | 1 500 × 4,00 = 6 000 PLN |
| VAT (RC, import usług) | 23% (samonaliczenie) |
| **Brutto PLN** | **6 000 × 1,23 = 7 380 PLN brutto/rok** |
| + Rezerwa kursowa 15% | 7 380 × 1,15 ≈ 8 487 PLN (planowanie konserwatywne) |
