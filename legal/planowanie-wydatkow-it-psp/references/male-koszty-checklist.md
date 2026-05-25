---
name: male-koszty-checklist
type: reference
parent: planowanie-wydatkow-it-psp
sources:
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §VII.1
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §VII.2
description: Lista 19 „małych kosztów" najczęściej pomijanych przy planowaniu TCO systemu IT + alokacja A/B/C (bezpośrednie / wytwórcze / wspólne). Ładowany w F2 (Catalogize) jako kontrolna lista kompletności.
---

# Małe koszty — checklist + alokacja A/B/C

> **Najgorzej pomijane są pozycje pozornie drobne**, które w skali roku tworzą znaczące pozycje budżetu. Przejdź przez tę listę po wypełnieniu drzewa kosztów (F2) — sprawdź, czy nic nie zostało pominięte.

## 1. Lista 19 pozycji najczęściej pomijanych

Status: dla każdej pozycji oznacz [TAK / NIE / N/D] w raport.md.

| # | Pozycja | § (typowy) | Status | Uwagi |
|---|---|---|---|---|
| 1 | Konta użytkowników (GitHub/GitLab/Jira/Figma/service desk) | 4300 | [ ] | per-user × miesiąc; rosną z zespołem |
| 2 | Minuty CI/CD + płatne runners | 4300 | [ ] | przekroczenia bezpłatnego limitu |
| 3 | Skanowanie sekretów i podatności w repo | 4300 | [ ] | GitHub Advanced Security, Snyk, Trivy |
| 4 | **Transfer danych wychodzących z chmury (egress)** | 4300 | [ ] | **najczęściej pomijany koszt chmury** |
| 5 | Retencja logów (30/90/180/365 dni) | 4300 | [ ] | rośnie wykładniczo z wolumenem |
| 6 | Storage backupów + **testy odtworzeniowe** | 4300 | [ ] | testy często pomijane, ale wymóg BCP |
| 7 | Środowiska testowe i staging | 4300 | [ ] | część SKU dostawcy chmury |
| 8 | Domeny, DNS, certyfikaty, stałe IP | 4300 / 4350 | [ ] | drobne, ale roczne odnowienia |
| 9 | SMS-y, e-maile transakcyjne, geokodowanie | 4300 / 4360 (SMS) | [ ] | per-zdarzenie |
| 10 | **Limity API map i LLM (overage)** | 4300 | [ ] | rezerwa 10–20% bazowego |
| 11 | Subskrypcje LLM dla devów / analityków / adminów | 4300 | [ ] | per-user × miesiąc; rosną z zespołem |
| 12 | **Testy WCAG** dla usług publicznych | 4390 | [ ] | wymóg dostępności cyfrowej |
| 13 | Pentesty po większych zmianach | 4390 / 6050 | [ ] | cykliczne 4390, przedwdrożeniowe 6050 |
| 14 | Dokumentacja bezpieczeństwa (SZBI, DPIA zewn.) | 4390 | [ ] | ekspertyzy |
| 15 | Obsługa incydentów i dyżury | 4300 / uposażenia 4xxx | [ ] | on-call, RPO/RTO |
| 16 | Różnice kursowe (USD/EUR) — rezerwa kursowa | macierzysty § | [ ] | **10–15%** pozycji walutowych |
| 17 | VAT i przewalutowania | brutto | [ ] | uwzględnij w brutto (Cz. III.0) |
| 18 | Rezerwa na przekroczenia limitów (overage) | 4300 | [ ] | **10–20%** API |
| 19 | Migracja danych przy zmianie dostawcy + **koszty wyjścia (exit)** | 4300 (bież.) lub 6050 (wytw.) | [ ] | export, backup, przeniesienie |

> Po wypełnieniu listy: ile pozycji „NIE"? Każda = ryzyko niedoszacowania budżetu. Wpisz w raport.md uzasadnienie (czy świadomie pomijasz, czy dorzucasz).

## 2. Alokacja A/B/C — do rozliczeń wewnętrznych

Dla przejrzystości rozdziel wydatki na trzy grupy. Pozwala wskazać, że część kosztów jest **wspólna dla portfela** systemów centralnych PSP i alokowana proporcjonalnie (klucz alokacji do uzgodnienia z dysponentem — np. liczba użytkowników, wolumen, udział w OPEX).

### A. Koszty bezpośrednie systemu

> Bez nich dany system **nie działa**.

| Pozycja | § |
|---|---|
| Hosting, baza danych, storage | 4300 |
| Mapy, API, dane referencyjne | 4300 |
| Backup (per system) | 4300 |
| Monitoring (per system) | 4300 |
| Bezpieczeństwo per system | 4300 / 4390 |
| Service desk per system | 4300 |
| Łączność (per system) | 4350 / 4360 |
| Utrzymanie aplikacji | 4300 |

### B. Koszty wytwórcze i rozwojowe

> Potrzebne do **rozwijania** systemu.

| Pozycja | § |
|---|---|
| Repozytoria kodu | 4300 |
| CI/CD, narzędzia | 4300 |
| LLM dla zespołu (devów) | 4300 |
| Testy (cykliczne) | 4300 / 4390 |
| Dokumentacja | 4300 / 4390 |
| **Budowa nowych modułów** | **6050** |

### C. Koszty wspólne / platformowe

> Obsługują **kilka systemów** naraz; alokowane proporcjonalnie.

| Pozycja | § | Klucz alokacji (przykład) |
|---|---|---|
| Cloudflare / WAF / DDoS | 4300 | liczba domen / ruch |
| SIEM / SOC | 4300 | wolumen logów / liczba systemów |
| Service desk centralny | 4300 | liczba zgłoszeń |
| Monitoring centralny | 4300 | liczba endpointów |
| Repozytoria kodu (organizacja) | 4300 | liczba użytkowników |
| Narzędzia LLM (subskrypcje org.) | 4300 | liczba użytkowników |
| Zarządzanie tożsamością (IAM/SSO) | 4300 | liczba użytkowników |
| Backup centralny | 4300 | wolumen TB |
| Audyty bezpieczeństwa portfela | 4390 | liczba systemów objętych |

## 3. Reguła zapisu w raport.md

W sekcji 4 raport.md dla każdej pozycji wpisz:

```
| Pozycja | Sekcja katalogu | A/B/C | Typ (CAPEX/OPEX) | § | Kwota brutto/rok |
|---|---|---|---|---|---|
| Hosting NASK CEOZO niejawna | B | **A** | OPEX | 4300 | … |
| Cloudflare WAF/CDN/DNS | D | **C** | OPEX | 4300 | … (klucz alokacji: ruch — CEOZO 40%, CEZOL 30%, inne 30%) |
| Repo GitHub Enterprise (organizacja) | H | **C** | OPEX | 4300 | … (klucz: liczba developerów; CEOZO 20%, CEZOL 25%, ...) |
| Budowa modułu IAM CEOZO | D | **B** | CAPEX | 6050 | … |
```

## 4. Wartość alokacji A/B/C dla MSWiA

Alokacja A/B/C **pomaga uzasadnić, dlaczego pozycje wyglądające na drobne sumują się do dużej kwoty**. Bez alokacji łatwo zostać zapytanym „dlaczego potrzebujecie 1,9 mln zł na SIEM dla CEOZO, skoro CEOZO ma tylko 200 000 zł utrzymania?" — odpowiedź: SIEM to **alokacja C** (1,9 mln) na portfel 5+ systemów, z czego CEOZO odpowiada ~20%.

Wpisz to wprost w raport.md sekcja 4 + przywołaj w uzasadnieniu 8-punktowym (pkt 5 — kosztorys).
