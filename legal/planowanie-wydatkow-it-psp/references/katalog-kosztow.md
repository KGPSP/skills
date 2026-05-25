---
name: katalog-kosztow
type: reference
parent: planowanie-wydatkow-it-psp
sources:
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §II
description: Atomowy katalog pozycji kosztowych dla systemu IT KG PSP — 15 sekcji A–O. Każda pozycja występuje raz, z jednostką rozliczeniową, typem CAPEX/OPEX i driverem kosztu. Ładowany w F2 (Catalogize) — zaznaczenie pozycji dotyczących systemu.
---

# Katalog kosztów — 15 sekcji A–O

> **Zasada:** każda pozycja występuje **raz**. Wybierz tylko te, które realnie występują w danym systemie. Pomijasz pozycje irrelewantne (np. „Relokacja serwerowni" dla systemu w modelu SaaS). Pusta sekcja = świadoma decyzja, opisz dlaczego.

## A. Środowiska systemu

| Pozycja | Typ | Jednostka | Driver kosztu | Uwagi |
|---|---|---|---|---|
| Środowisko produkcyjne | OPEX/CAPEX | miesiąc | klasa wydajności, redundancja, HA | warstwa jawna i niejawna oddzielnie |
| Środowisko przedprodukcyjne / staging | OPEX | miesiąc | skala vs prod | często skalowane w dół |
| Środowisko testowe | OPEX | miesiąc | liczba równoległych testów | dane testowe wymagają anonimizacji |
| Środowisko deweloperskie | OPEX | miesiąc | liczba devów | per-user lub współdzielone |
| Środowisko DR (Disaster Recovery) | OPEX/CAPEX | miesiąc | RTO/RPO | hot/warm/cold standby |
| Środowisko szkoleniowe | OPEX | miesiąc | częstotliwość użycia | może być on-demand |

## B. Infrastruktura i hosting

| Pozycja | Typ | Jednostka | Driver kosztu | Uwagi |
|---|---|---|---|---|
| Hosting aplikacji (PaaS / kontenery / VM) | OPEX | miesiąc | CPU, RAM, autoskalowanie | warstwa jawna vs niejawna — różne dostawcy |
| Hosting backendu / API | OPEX | miesiąc | RPS, instancje | często wydzielone od frontu |
| Hosting frontendu | OPEX | miesiąc | ruch, CDN | może być w cenie CDN |
| Baza danych (PostgreSQL/MSSQL itp.) | OPEX | miesiąc | rozmiar, IOPS, klasa | managed vs self-hosted |
| Repliki bazy danych (HA / read) | OPEX | miesiąc | liczba replik, region | wymóg HA dla systemów krytycznych |
| Storage plików (block/file) | OPEX | GB/miesiąc | wolumen + transakcje | załączniki, dokumenty |
| Object storage | OPEX | GB/miesiąc | wolumen + zapytania PUT/GET | raporty, eksporty |
| Cache (np. Redis) | OPEX | miesiąc | rozmiar, throughput | przyspieszenie aplikacji |
| Kolejki zadań (queue) | OPEX | miesiąc | liczba wiadomości | przetwarzanie asynchroniczne |
| Scheduler | OPEX | miesiąc | liczba zadań | synchronizacje cykliczne |
| Registry obrazów kontenerowych | OPEX | GB/miesiąc | liczba i rozmiar obrazów | retencja warstw |
| Backup infrastruktury | OPEX | GB/miesiąc | retencja, częstotliwość | testy odtworzeniowe — sekcja D |
| Snapshoty środowisk | OPEX | GB/miesiąc | częstotliwość, retencja | szybkie rollbacki |
| Autoskalowanie — rezerwa wydajnościowa | OPEX | miesiąc | szczytowe obciążenie | koszt rezerwowy, nawet gdy nieużywany |
| **Transfer danych wychodzących (egress)** | OPEX | GB/miesiąc | wolumen wychodzący z chmury | **najczęściej pomijany koszt chmury** |
| Relokacja serwerowni / migracja | CAPEX | pakiet | zakres, testy, dokumentacja | jednorazowo |

## C. Łączność i sieć

| Pozycja | Typ | Jednostka | Driver kosztu | Uwagi |
|---|---|---|---|---|
| Łącze Internet podstawowe | OPEX | miesiąc | przepustowość, SLA | usługi jawne |
| Łącze Internet zapasowe | OPEX | miesiąc | przepustowość, SLA | ciągłość działania |
| Łącze WAN (między lokalizacjami) | OPEX | miesiąc | przepustowość | jeśli dotyczy |
| Łącze SKR-Z / GovNet / sieć wydzielona | OPEX | miesiąc | klasa, lokalizacje | dla części niejawnej |
| APN M2M | OPEX | miesiąc | liczba SIM, transfer | urządzenia terenowe, syreny, telemetryka |
| Karty SIM M2M | OPEX | SIM/miesiąc | liczba kart | per-karta + opłata aktywacyjna |
| SMS API | OPEX | SMS | wolumen | alerty, kody, fallback |
| API e-mail transakcyjny | OPEX | e-mail | wolumen | maile systemowe |
| API push / RCS | OPEX | powiadomienie | wolumen | aplikacje mobilne |
| VPN (dostęp administracyjny) | OPEX | miesiąc | liczba użytkowników | zdalna administracja |
| Stałe adresy IP | OPEX | IP/miesiąc | liczba IP | drobny, ale konieczny |
| DNS | OPEX | strefa/miesiąc | liczba zapytań | |
| Domeny | OPEX | rok | liczba domen, TLD | odnowienia roczne |
| Certyfikaty TLS | OPEX | rok | liczba, klasa (DV/OV/EV/kwalifikowany) | Let's Encrypt zwykle 0 zł |
| Load balancer | OPEX | miesiąc | przepustowość, reguły | równoważenie ruchu |
| Reverse proxy / WAF brzegowy | OPEX/CAPEX | miesiąc | managed vs własny | brzeg aplikacji |
| Firewall brzegowy / NAT | OPEX/CAPEX | miesiąc/pakiet | usługowy vs sprzętowy | |
| Transfer między środowiskami | OPEX | GB/miesiąc | wolumen | często pomijany |

## D. Bezpieczeństwo systemu

| Pozycja | Typ | Jednostka | Driver kosztu | Uwagi |
|---|---|---|---|---|
| WAF | OPEX | miesiąc/rok | przepustowość, reguły | np. Cloudflare |
| Ochrona DDoS | OPEX | miesiąc/rok | poziom (L3/L4/L7), SLA | często łącznie z WAF/CDN |
| CDN | OPEX | GB/miesiąc | transfer cache miss vs hit | |
| IAM | OPEX | user/miesiąc | liczba kont, integracje | |
| MFA | OPEX | user/miesiąc | liczba kont | aplikacja TOTP zwykle 0 zł |
| Tokeny sprzętowe (TOTP/U2F) | CAPEX/OPEX | szt. | liczba admin. | jednorazowo + zapasy |
| PAM (Privileged Access Mgmt) | OPEX | konto/miesiąc | liczba kont uprzywilejowanych | wymóg dla krytycznych |
| Menedżer sekretów | OPEX | sekret/miesiąc | liczba sekretów | klucze API, hasła |
| Rotacja sekretów | OPEX | miesiąc | liczba sekretów | często ręczna |
| Skanowanie podatności | OPEX | miesiąc | liczba assetów | continuous scanning |
| SAST | OPEX | miesiąc | liczba repo, devów | |
| DAST | OPEX | miesiąc/test | liczba środowisk | |
| SCA (zależności OSS) | OPEX | miesiąc | liczba projektów | |
| SBOM | OPEX | miesiąc | liczba buildów | |
| **Pentest aplikacji** | OPEX/CAPEX | test (rocznie / po dużej zmianie) | zakres, klasa | OPEX cykliczny, CAPEX przedwdrożeniowy |
| Audyt konfiguracji chmury | OPEX | rok | liczba środowisk | hardening |
| SIEM | OPEX | GB logów/miesiąc | wolumen | |
| SOC (24/7 lub godzinowy) | OPEX | miesiąc | klasa, SLA | wewn. vs zewn. |
| Retencja logów bezpieczeństwa | OPEX | GB/miesiąc | okres | wymóg prawny |
| EDR na stacjach admin. | OPEX | stacja/miesiąc | liczba stacji | |
| Rejestr zdarzeń admin. | OPEX | miesiąc | wolumen | rozliczalność |
| HSM / KMS | OPEX/CAPEX | klucz/miesiąc | liczba operacji | wymagane dla wysokich klas |
| **Testy odtworzeniowe backupu** | OPEX | test | częstotliwość | **często pomijany** |
| BCP/DRP — utrzymanie i ćwiczenia | OPEX | rok | częstotliwość | |
| Akredytacja systemów niejawnych | OPEX/CAPEX | pakiet | klauzula | jednorazowo + odnowienia |

## E. Monitoring i obserwowalność

| Pozycja | Typ | Jednostka | Uwagi |
|---|---|---|---|
| Monitoring dostępności (uptime) | OPEX | miesiąc | liczba endpointów |
| Monitoring infrastruktury | OPEX | host/miesiąc | CPU/RAM/dysk/sieć |
| Monitoring aplikacyjny (APM) | OPEX | miesiąc | liczba transakcji |
| Logi aplikacyjne | OPEX | GB/miesiąc | wolumen, retencja |
| Logi audytowe | OPEX | GB/miesiąc | działania user + admin |
| Alerting / on-call | OPEX | miesiąc | liczba alertów |
| Status page | OPEX | miesiąc | liczba komponentów |
| Incident mgmt (PagerDuty/Opsgenie) | OPEX | user/miesiąc | liczba on-call |
| Dashboardy operacyjne | OPEX | user/miesiąc | Grafana, Kibana |
| Retencja metryk | OPEX | GB/miesiąc | okres |
| Retencja logów (30/90/180/365 dni) | OPEX | GB/miesiąc | rośnie wykładniczo |
| Eksport logów do archiwum | OPEX | GB/miesiąc | cold storage |
| Raporty SLA | OPEX | rok | manualne vs auto |

## F. Service desk i wsparcie użytkowników

| Pozycja | Typ | Jednostka | Uwagi |
|---|---|---|---|
| Service desk (wewn. / firma zewn.) | OPEX | miesiąc | klasa, SLA |
| Narzędzie ticketingowe | OPEX | user/miesiąc | Jira, Zendesk |
| Dokumentacja użytkowa | OPEX | rok | aktualizacje |
| Obsługa zgłoszeń (RPO/RTO odpowiedzi) | OPEX | miesiąc | godziny dyżurów |

## G. Dane, mapy, usługi zewnętrzne (API)

| Pozycja | Typ | Jednostka | Uwagi |
|---|---|---|---|
| Mapy (Google Maps / Mapbox / HERE) | OPEX | rok / zapytanie | + **overage** |
| Geokodowanie | OPEX | zapytanie | |
| Dane referencyjne (TERYT, BDOT, EGiB, KRS itp.) | OPEX/CAPEX | rok / pakiet | dostępy uwierzytelnione |
| API LLM (OpenAI, Anthropic) | OPEX | token | + **overage**, RC 23% |
| GPU dla inferencji | OPEX/CAPEX | godzina / miesiąc | |
| ePUAP / WęzełKK / Profil Zaufany | OPEX | rok | integracje publiczne |
| API GUS / REGON | OPEX | rok / zapytanie | |
| API ePUAP / e-Doręczenia | OPEX | rok | |

## H. Narzędzia wytwórcze i programistyczne

| Pozycja | Typ | Jednostka | § (typowy) |
|---|---|---|---|
| Repozytorium kodu (GitHub/GitLab) | OPEX | user/miesiąc | 4300 |
| CI/CD (minuty + runners) | OPEX | minuta/miesiąc | 4300 |
| IDE (Cursor, JetBrains) | OPEX | user/miesiąc | 4300 |
| LLM dla devów (Copilot, Claude) | OPEX | user/miesiąc | 4300 |
| Narzędzia projektowania (Figma) | OPEX | user/miesiąc | 4300 |
| Tracker zadań (Jira/Linear) | OPEX | user/miesiąc | 4300 |
| Komunikacja zespołu (Slack/Teams) | OPEX | user/miesiąc | 4300 |
| Licencja wieczysta ≥ 10k netto > 1r | CAPEX | szt. | **6060** |

## I. Testy i jakość oprogramowania

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Testy E2E (Playwright/Cypress cloud) | OPEX | miesiąc | 4300 |
| Testy wydajnościowe (k6/Locust cloud) | OPEX | miesiąc/test | 4300 |
| Testy WCAG / dostępność | OPEX/CAPEX | rok/test | **4390** (zewn.) lub 4300 |
| Pentest cykliczny | OPEX | rok | **4390** |
| Pentest przedwdrożeniowy | CAPEX | test | **6050** (koszt wytworzenia) |
| Audyt zewn. zgodności | OPEX | rok | **4390** |

## J. Dokumentacja, zgodność, formalne utrzymanie

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Dokumentacja bieżąca (operacyjna) | OPEX | rok | 4300 |
| SZBI — opracowanie zewn. | OPEX | pakiet | **4390** |
| DPIA — zewn. ekspertyza | OPEX | pakiet | **4390** |
| Rejestry RODO | OPEX | rok | 4300 |
| Audyt zgodności (RODO/OIN/KSC) | OPEX | rok | **4390** |
| Konsultacje prawne (zewn.) | OPEX | godzina | 4300 lub 4390 |

## K. Konta i uprawnienia

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Konta użytkowników (GitHub/GitLab/Jira/Figma) | OPEX | user/miesiąc | 4300 |
| Konta service desk | OPEX | user/miesiąc | 4300 |
| Konta administracyjne (PAM) | OPEX | user/miesiąc | 4300 |
| Konta robocze automatyzacji (CI/CD, integracje) | OPEX | konto/miesiąc | 4300 |

## L. Zespół i prace utrzymaniowe

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Etaty utrzymaniowe (administracja, dev, security) | OPEX | osoba/miesiąc | 4010/4020/4040/4110/4120 (uposażenia/wynagr.) |
| Umowy zlecenia / dzieło | OPEX | pakiet | **4170** |
| Firma zewn. utrzymaniowa | OPEX | miesiąc | 4300 |
| Konsultanci ad-hoc | OPEX | godzina | 4170 lub 4300 |
| **Programiści — wytwarzanie nowego modułu** | CAPEX | pakiet | **6050** (koszt wytworzenia) |

## M. Sprzęt pomocniczy i organizacja

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Stacja robocza < 10k netto | OPEX | szt. | **4210** |
| Stacja robocza ≥ 10k netto, > 1r | CAPEX | szt. | **6060** |
| Telefon służbowy | OPEX | szt./rok | 4210 |
| UPS / zasilanie awaryjne | CAPEX | szt. | 6060 (≥ 10k) lub 4210 |
| Energia elektryczna (kolokacja) | OPEX | miesiąc | **4260** |
| Materiały biurowe / akcesoria | OPEX | rok | 4210 |
| Tokeny sprzętowe MFA | CAPEX | szt. | 4210 (< 10k) |

## N. Szkolenia i wdrożenie

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Szkolenia administratorów (NIE SC) | OPEX | osoba | **4700** |
| Szkolenia operatorów / service desk | OPEX | osoba | **4700** (lub 4550/4710 dla SC) |
| Pilotaż / wdrożenie przed odbiorem | CAPEX | pakiet | **6050** |
| Materiały szkoleniowe (wytworzenie) | OPEX/CAPEX | pakiet | 4300 lub 6050 |

## O. Umowy, dostawcy, rezerwy

> **Te pozycje są często pomijane. Każdy wniosek powinien mieć rezerwy.**

| Pozycja | Typ | Jednostka | Wysokość |
|---|---|---|---|
| **Rezerwa utrzymaniowa** | OPEX | rok | **10–20% OPEX** |
| **Rezerwa kursowa** (USD/EUR) | OPEX | rok | **10–15% pozycji walutowych** |
| **Rezerwa overage API** (mapy, LLM, SMS) | OPEX | rok | **10–20% bazowych zapytań** |
| Rezerwa rozwojowa | CAPEX | rok | 5–15% CAPEX |
| Koszty wyjścia (exit) — eksport danych, migracja | OPEX | pakiet | jednorazowo |
| Koszty migracji przy zmianie dostawcy | OPEX/CAPEX | pakiet | jednorazowo |

> Rezerwy klasyfikuj w macierzystym § (najczęściej 4300) lub w § 4810 jeśli planowane jako odrębna pozycja budżetowa.
