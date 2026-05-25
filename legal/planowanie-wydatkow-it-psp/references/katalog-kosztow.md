---
name: katalog-kosztow
type: reference
parent: planowanie-wydatkow-it-psp
sources:
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §II
  - now_skille/materialy_polioc/FINANSOWANIE/Analiza_klasyfikacji_IT_KG_PSP_2027_BIL.docx
description: Atomowy katalog pozycji kosztowych dla systemu IT KG PSP — 15 sekcji A–O. Każda pozycja występuje raz, z jednostką rozliczeniową, typem CAPEX/OPEX, driverem kosztu i paragrafem 2027+ (Dz.U. 2026 poz. 582). Ładowany w F2 (Catalogize) — zaznaczenie pozycji dotyczących systemu.
---

# Katalog kosztów — 15 sekcji A–O (klasyfikacja 2027+)

> **Zasada:** każda pozycja występuje **raz**. Wybierz tylko te, które realnie występują w danym systemie. Pomijasz pozycje irrelewantne (np. „Relokacja serwerowni" dla systemu w modelu SaaS). Pusta sekcja = świadoma decyzja, opisz dlaczego.
>
> **Paragrafy 2027+ wg Dz.U. 2026 poz. 582.** Klucz przejścia stara → nowa w `references/klasyfikacja-budzetowa.md` §10.

## A. Środowiska systemu

| Pozycja | Typ | Jednostka | § | Driver kosztu | Uwagi |
|---|---|---|---|---|---|
| Środowisko produkcyjne | OPEX/CAPEX | miesiąc | **682** (PaaS) / **720** (budowa od zera) | klasa wydajności, redundancja, HA | warstwa jawna i niejawna oddzielnie |
| Środowisko przedprodukcyjne / staging | OPEX | miesiąc | **682** | skala vs prod | często skalowane w dół |
| Środowisko testowe | OPEX | miesiąc | **682** | liczba równoległych testów | dane testowe wymagają anonimizacji |
| Środowisko deweloperskie | OPEX | miesiąc | **682** | liczba devów | per-user lub współdzielone |
| Środowisko DR (Disaster Recovery) | OPEX/CAPEX | miesiąc | **682** (usługa) / **702** (sprzęt) | RTO/RPO | hot/warm/cold standby |
| Środowisko szkoleniowe | OPEX | miesiąc | **682** | częstotliwość użycia | może być on-demand |

## B. Infrastruktura i hosting

| Pozycja | Typ | Jednostka | § | Driver kosztu | Uwagi |
|---|---|---|---|---|---|
| Hosting aplikacji (PaaS / kontenery / VM) | OPEX | miesiąc | **682** | CPU, RAM, autoskalowanie | warstwa jawna vs niejawna — różne dostawcy |
| Hosting backendu / API | OPEX | miesiąc | **682** | RPS, instancje | często wydzielone od frontu |
| Hosting frontendu | OPEX | miesiąc | **682** | ruch, CDN | może być w cenie CDN |
| Baza danych (PostgreSQL/MSSQL itp.) | OPEX | miesiąc | **682** | rozmiar, IOPS, klasa | managed vs self-hosted |
| Repliki bazy danych (HA / read) | OPEX | miesiąc | **682** | liczba replik, region | wymóg HA dla systemów krytycznych |
| Storage plików (block/file) | OPEX | GB/miesiąc | **682** | wolumen + transakcje | załączniki, dokumenty |
| Object storage | OPEX | GB/miesiąc | **682** | wolumen + zapytania PUT/GET | raporty, eksporty |
| Cache (np. Redis) | OPEX | miesiąc | **682** | rozmiar, throughput | przyspieszenie aplikacji |
| Kolejki zadań (queue) | OPEX | miesiąc | **682** | liczba wiadomości | przetwarzanie asynchroniczne |
| Scheduler | OPEX | miesiąc | **682** | liczba zadań | synchronizacje cykliczne |
| Registry obrazów kontenerowych | OPEX | GB/miesiąc | **682** | liczba i rozmiar obrazów | retencja warstw |
| Backup infrastruktury | OPEX | GB/miesiąc | **682** | retencja, częstotliwość | testy odtworzeniowe — sekcja D |
| Snapshoty środowisk | OPEX | GB/miesiąc | **682** | częstotliwość, retencja | szybkie rollbacki |
| Autoskalowanie — rezerwa wydajnościowa | OPEX | miesiąc | **682** | szczytowe obciążenie | koszt rezerwowy, nawet gdy nieużywany |
| **Transfer danych wychodzących (egress)** | OPEX | GB/miesiąc | **682** | wolumen wychodzący z chmury | **najczęściej pomijany koszt chmury** |
| Serwery rackowe / macierze / UPS jako ŚT | CAPEX | szt. | **702** (702002) / **701** jednorazowo | klasa, redundancja | ujmowane jako ŚT — polityka rachunkowości decyduje |
| Relokacja serwerowni / migracja | CAPEX | pakiet | **720** (gdy część budowy) / **682** (gdy bieżąca) | zakres, testy, dokumentacja | jednorazowo |

## C. Łączność i sieć

| Pozycja | Typ | Jednostka | § | Driver kosztu | Uwagi |
|---|---|---|---|---|---|
| Łącze Internet podstawowe | OPEX | miesiąc | **681** | przepustowość, SLA | usługi telekomunikacyjne |
| Łącze Internet zapasowe | OPEX | miesiąc | **681** | przepustowość, SLA | ciągłość działania |
| Łącze WAN (między lokalizacjami) | OPEX | miesiąc | **681** | przepustowość | jeśli usługa telekom |
| Łącze SKR-Z / GovNet / sieć wydzielona | OPEX | miesiąc | **681** | klasa, lokalizacje | dla części niejawnej |
| **Dzierżawa ciemnego włókna / kanalizacji teletechnicznej** | OPEX | miesiąc | **631003** | długość, lokalizacja | dzierżawa składnika, NIE usługa telekomunikacyjna |
| APN M2M | OPEX | miesiąc | **681** | liczba SIM, transfer | urządzenia terenowe, syreny, telemetryka |
| Karty SIM M2M | OPEX | SIM/miesiąc | **681** | liczba kart | per-karta + opłata aktywacyjna |
| SMS API | OPEX | SMS | **682** (gdy API jako SaaS) / **681** (gdy telekom) | wolumen | alerty, kody, fallback |
| API e-mail transakcyjny | OPEX | e-mail | **682** | wolumen | maile systemowe |
| API push / RCS | OPEX | powiadomienie | **682** | wolumen | aplikacje mobilne |
| VPN (dostęp administracyjny) | OPEX | miesiąc | **682** | liczba użytkowników | zdalna administracja |
| Stałe adresy IP | OPEX | IP/miesiąc | **681** | liczba IP | drobny, ale konieczny |
| DNS | OPEX | strefa/miesiąc | **682** | liczba zapytań | |
| Domeny | OPEX | rok | **682** | liczba domen, TLD | odnowienia roczne |
| Certyfikaty TLS | OPEX | rok | **682** | liczba, klasa (DV/OV/EV/kwalifikowany) | Let's Encrypt zwykle 0 zł |
| Load balancer | OPEX | miesiąc | **682** | przepustowość, reguły | równoważenie ruchu |
| Reverse proxy / WAF brzegowy (usługa) | OPEX | miesiąc | **682** | managed | brzeg aplikacji |
| Firewall sprzętowy jako ŚT | CAPEX | szt. | **702** (702002) lub **704001** (gdy operacyjny) | klasa, port density | **704 wymaga uzasadnienia operacyjnego** |
| Transfer między środowiskami | OPEX | GB/miesiąc | **682** | wolumen | często pomijany |
| Naprawa sprzętu łączności | OPEX | naprawa | **634003** | jednorazowo / SLA | maszty, anteny, radio |

## D. Bezpieczeństwo systemu

| Pozycja | Typ | Jednostka | § | Driver kosztu | Uwagi |
|---|---|---|---|---|---|
| WAF (usługa) | OPEX | miesiąc/rok | **682** | przepustowość, reguły | np. Cloudflare |
| Ochrona DDoS | OPEX | miesiąc/rok | **682** | poziom (L3/L4/L7), SLA | często łącznie z WAF/CDN |
| CDN | OPEX | GB/miesiąc | **682** | transfer cache miss vs hit | |
| IAM | OPEX | user/miesiąc | **682** | liczba kont, integracje | |
| MFA | OPEX | user/miesiąc | **682** | liczba kont | aplikacja TOTP zwykle 0 zł |
| Tokeny sprzętowe (TOTP/U2F) | CAPEX/OPEX | szt. | **778005** (gdy materiał) / **701** (gdy ŚT) | liczba admin. | polityka rachunkowości decyduje |
| PAM (Privileged Access Mgmt) | OPEX | konto/miesiąc | **682** | liczba kont uprzywilejowanych | wymóg dla krytycznych |
| Menedżer sekretów | OPEX | sekret/miesiąc | **682** | liczba sekretów | klucze API, hasła |
| Rotacja sekretów | OPEX | miesiąc | **682** | liczba sekretów | często ręczna |
| Skanowanie podatności | OPEX | miesiąc | **682** | liczba assetów | continuous scanning |
| SAST | OPEX | miesiąc | **682** | liczba repo, devów | |
| DAST | OPEX | miesiąc/test | **682** | liczba środowisk | |
| SCA (zależności OSS) | OPEX | miesiąc | **682** | liczba projektów | |
| SBOM | OPEX | miesiąc | **682** | liczba buildów | |
| **Pentest aplikacji cykliczny** | OPEX | test (rocznie / po dużej zmianie) | **677** | zakres, klasa | ekspertyza/analiza |
| **Pentest przedwdrożeniowy** | CAPEX | test | **720** | część kosztu wytworzenia | wchodzi w wartość aktywa |
| Audyt konfiguracji chmury | OPEX | rok | **677** | liczba środowisk | hardening |
| SIEM (usługa SaaS) | OPEX | GB logów/miesiąc | **682** | wolumen | |
| SIEM/SOC tworzony od zera | CAPEX | pakiet | **720** | jednorazowo | wytworzenie aktywa |
| SOC (24/7 lub godzinowy, usługa) | OPEX | miesiąc | **682** | klasa, SLA | wewn. vs zewn. |
| Retencja logów bezpieczeństwa | OPEX | GB/miesiąc | **682** | okres | wymóg prawny |
| EDR na stacjach admin. (SaaS) | OPEX | stacja/miesiąc | **682** | liczba stacji | |
| Rejestr zdarzeń admin. | OPEX | miesiąc | **682** | wolumen | rozliczalność |
| HSM / KMS (sprzęt) | CAPEX | szt. | **702** (702002) lub **712** (gdy WNiP) | liczba operacji | wymagane dla wysokich klas |
| **Testy odtworzeniowe backupu** | OPEX | test | **682** | częstotliwość | **często pomijany** |
| BCP/DRP — utrzymanie i ćwiczenia | OPEX | rok | **682** | częstotliwość | |
| Akredytacja systemów niejawnych | OPEX/CAPEX | pakiet | **677** (ekspertyza) / **720** (gdy część wytworzenia) | klauzula | jednorazowo + odnowienia |
| **Specjalistyczny sprzęt łączności krytycznej** | CAPEX | szt. | **704001** | klasa operacyjna | **WYMAGA uzasadnienia operacyjnego — zadania PSP** |

## E. Monitoring i obserwowalność

| Pozycja | Typ | Jednostka | § | Uwagi |
|---|---|---|---|---|
| Monitoring dostępności (uptime) | OPEX | miesiąc | **682** | liczba endpointów |
| Monitoring infrastruktury | OPEX | host/miesiąc | **682** | CPU/RAM/dysk/sieć |
| Monitoring aplikacyjny (APM) | OPEX | miesiąc | **682** | liczba transakcji |
| Logi aplikacyjne | OPEX | GB/miesiąc | **682** | wolumen, retencja |
| Logi audytowe | OPEX | GB/miesiąc | **682** | działania user + admin |
| Alerting / on-call | OPEX | miesiąc | **682** | liczba alertów |
| Status page | OPEX | miesiąc | **682** | liczba komponentów |
| Incident mgmt (PagerDuty/Opsgenie) | OPEX | user/miesiąc | **682** | liczba on-call |
| Dashboardy operacyjne | OPEX | user/miesiąc | **682** | Grafana, Kibana |
| Retencja metryk | OPEX | GB/miesiąc | **682** | okres |
| Retencja logów (30/90/180/365 dni) | OPEX | GB/miesiąc | **682** | rośnie wykładniczo |
| Eksport logów do archiwum | OPEX | GB/miesiąc | **682** | cold storage |
| Raporty SLA | OPEX | rok | **682** | manualne vs auto |

## F. Service desk i wsparcie użytkowników

| Pozycja | Typ | Jednostka | § | Uwagi |
|---|---|---|---|---|
| Service desk (firma zewn.) | OPEX | miesiąc | **682** | klasa, SLA |
| Narzędzie ticketingowe | OPEX | user/miesiąc | **682** | Jira, Zendesk |
| Dokumentacja użytkowa | OPEX | rok | **682** | aktualizacje |
| Obsługa zgłoszeń (RPO/RTO odpowiedzi) | OPEX | miesiąc | **682** | godziny dyżurów |
| Konsultanci ad-hoc — osoba fizyczna | OPEX | godzina | **670** (670001) | umowa zlecenia/dzieło |

## G. Dane, mapy, usługi zewnętrzne (API)

| Pozycja | Typ | Jednostka | § | Uwagi |
|---|---|---|---|---|
| Mapy (Google Maps / Mapbox / HERE) | OPEX | rok / zapytanie | **682** | + **overage**, RC 23% |
| Geokodowanie | OPEX | zapytanie | **682** | |
| Dane referencyjne (TERYT, BDOT, EGiB, KRS itp.) | OPEX/CAPEX | rok / pakiet | **682** | dostępy uwierzytelnione |
| API LLM (OpenAI, Anthropic) | OPEX | token | **682** | + **overage**, RC 23% |
| GPU dla inferencji (chmura) | OPEX | godzina / miesiąc | **682** | usługa chmurowa |
| GPU sprzęt jako ŚT | CAPEX | szt. | **702** (702002) | gdy serwer GPU on-premise |
| ePUAP / WęzełKK / Profil Zaufany | OPEX | rok | **682** | integracje publiczne |
| API GUS / REGON | OPEX | rok / zapytanie | **682** | |
| API ePUAP / e-Doręczenia | OPEX | rok | **682** | |

## H. Narzędzia wytwórcze i programistyczne

| Pozycja | Typ | Jednostka | § | Uwagi |
|---|---|---|---|---|
| Repozytorium kodu (GitHub/GitLab) | OPEX | user/miesiąc | **682** | subskrypcja SaaS |
| CI/CD (minuty + runners) | OPEX | minuta/miesiąc | **682** | |
| IDE (Cursor, JetBrains) | OPEX | user/miesiąc | **682** | subskrypcja czasowa |
| LLM dla devów (Copilot, Claude) | OPEX | user/miesiąc | **682** | |
| Narzędzia projektowania (Figma) | OPEX | user/miesiąc | **682** | |
| Tracker zadań (Jira/Linear) | OPEX | user/miesiąc | **682** | |
| Komunikacja zespołu (Slack/Teams) | OPEX | user/miesiąc | **682** | |
| Licencja bezterminowa / WNiP (zakup gotowego) | CAPEX | szt. | **712** (712002 wdrożenia) lub **711** (jednorazowo) | przeniesienie praw majątkowych |

## I. Testy i jakość oprogramowania

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Testy E2E (Playwright/Cypress cloud) | OPEX | miesiąc | **682** |
| Testy wydajnościowe (k6/Locust cloud) | OPEX | miesiąc/test | **682** |
| Testy WCAG / dostępność zewn. | OPEX/CAPEX | rok/test | **677** (zewn. ekspertyza) lub **682** (SaaS) |
| Pentest cykliczny | OPEX | rok | **677** |
| Pentest przedwdrożeniowy | CAPEX | test | **720** (koszt wytworzenia) |
| Audyt zewn. zgodności | OPEX | rok | **677** |

## J. Dokumentacja, zgodność, formalne utrzymanie

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Dokumentacja bieżąca (operacyjna) | OPEX | rok | **682** |
| SZBI — opracowanie zewn. | OPEX | pakiet | **677** |
| DPIA — zewn. ekspertyza | OPEX | pakiet | **677** |
| Rejestry RODO | OPEX | rok | **682** |
| Audyt zgodności (RODO/OIN/KSC) | OPEX | rok | **677** |
| Konsultacje prawne (zewn. firma) | OPEX | godzina | **682** lub **677** |
| Konsultacje prawne — osoba fizyczna | OPEX | godzina | **670** (670001) |

## K. Konta i uprawnienia

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Konta użytkowników (GitHub/GitLab/Jira/Figma) | OPEX | user/miesiąc | **682** |
| Konta service desk | OPEX | user/miesiąc | **682** |
| Konta administracyjne (PAM) | OPEX | user/miesiąc | **682** |
| Konta robocze automatyzacji (CI/CD, integracje) | OPEX | konto/miesiąc | **682** |

## L. Zespół i prace utrzymaniowe

> **Uwaga:** wynagrodzenia funkcjonariuszy/żołnierzy zawodowych (kadra mundurowa KG PSP) → § 239/240/618 (efekt kontroli NIK P/24/011, dawniej § 307/§ 418). **To poza zakresem skilla IT** — zob. uzgodnienie z BF-I.

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Etaty utrzymaniowe — pracownicy cywilni (administracja, dev, security) | OPEX | osoba/miesiąc | uposażenia/wynagrodzenia (poza zakresem skilla IT) |
| Umowy zlecenia / dzieło — osoba fizyczna | OPEX | pakiet | **670** (670001) |
| Firma zewn. utrzymaniowa | OPEX | miesiąc | **682** |
| Konsultanci ad-hoc — firma | OPEX | godzina | **682** |
| Konsultanci ad-hoc — osoba fizyczna | OPEX | godzina | **670** (670001) |
| **Programiści — wytwarzanie nowego modułu (firma)** | CAPEX | pakiet | **720** (koszt wytworzenia WNiP) |

## M. Sprzęt pomocniczy i organizacja

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Stacja robocza — ujęta jako wyposażenie nietworzące ŚT | OPEX | szt. | **778005** lub **778009** (informatyki) |
| Stacja robocza — ujęta jako ŚT amortyzowana jednorazowo | CAPEX | szt. | **701** |
| Stacja robocza — ujęta jako ŚT amortyzowana wieloletnio | CAPEX | szt. | **702** (702002) |
| Laptop pracownika BIŁ — polityka decyduje | OPEX/CAPEX | szt. | **778** lub **701** lub **702** (zgodnie z polityką rachunkowości KG PSP) |
| Telefon służbowy | OPEX | szt./rok | **778005** lub **701** |
| UPS / zasilanie awaryjne — ŚT | CAPEX | szt. | **702** (702002) lub **701** |
| Energia elektryczna (kolokacja, serwerownia) | OPEX | miesiąc | **770** |
| Woda (serwerownia, chłodzenie) | OPEX | miesiąc | **771** |
| Materiały biurowe / akcesoria | OPEX | rok | **778005** |
| Tokeny sprzętowe MFA | OPEX | szt. | **778005** |
| **Kable, patchcordy, drobne elementy sieciowe — materiały informatyki** | OPEX | szt. | **778009** |
| **Drobne elementy łączności — materiały łączności** | OPEX | szt. | **778008** |

## N. Szkolenia i wdrożenie

| Pozycja | Typ | Jednostka | § |
|---|---|---|---|
| Szkolenia administratorów (zewnętrzne) | OPEX | osoba | **638** |
| Szkolenia operatorów / service desk (zewn.) | OPEX | osoba | **638** |
| Pilotaż / wdrożenie przed odbiorem | CAPEX | pakiet | **720** (koszt wytworzenia) |
| Materiały szkoleniowe (wytworzenie) | OPEX/CAPEX | pakiet | **682** lub **720** |

## O. Umowy, dostawcy, rezerwy

> **Te pozycje są często pomijane. Każdy wniosek powinien mieć rezerwy.**

| Pozycja | Typ | Jednostka | § | Wysokość |
|---|---|---|---|---|
| **Rezerwa utrzymaniowa** | OPEX | rok | macierzysty (najczęściej 682) lub **810** | **10–20% OPEX** |
| **Rezerwa kursowa** (USD/EUR) | OPEX | rok | macierzysty (najczęściej 682) | **10–15% pozycji walutowych** |
| **Rezerwa overage API** (mapy, LLM, SMS) | OPEX | rok | **682** | **10–20% bazowych zapytań** |
| Rezerwa rozwojowa | CAPEX | rok | **720** lub **810** | 5–15% CAPEX |
| Koszty wyjścia (exit) — eksport danych, migracja | OPEX | pakiet | **682** | jednorazowo |
| Koszty migracji przy zmianie dostawcy | OPEX/CAPEX | pakiet | **682** (bieżąca) lub **720** (gdy wytworzenie aktywa) | jednorazowo |

> Rezerwy klasyfikuj w macierzystym § (najczęściej **682**) lub w § **810** jeśli planowane jako odrębna pozycja budżetowa.

## Klucz przejścia stara → nowa klasyfikacja

Pełna tabela mapowania w `references/klasyfikacja-budzetowa.md` §10. Najczęstsze:

| Stary § (do 2026) | Nowy § (od 2027) |
|---|---|
| 4300 | 682 (usługi IT) / 687 (pozostałe) / 631 (dzierżawa) / 677 (ekspertyzy) |
| 4350 / 4360 | 681 (lub 631003 dzierżawa łączy) |
| 4390 | 677 |
| 4210 | 778 (materiały) lub 701 (ŚT amort. jednorazowo) — **bez progu 10k** |
| 4260 | 770 (energia) / 771 (woda) |
| 4170 | 670 (670001) |
| 4700 | 638 |
| 6050 | 720 |
| 6060 | 702 (ŚT zwykłe) / 701 (jednorazowo) / 704 (specjalistyczny operacyjny) / 712 (WNiP) / 711 (WNiP jednorazowo) |
