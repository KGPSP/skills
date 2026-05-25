---
name: przeliczenia-walut-vat
type: reference
parent: planowanie-wydatkow-it-psp
sources:
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §III.0
description: Reguły przeliczania kosztów na PLN BRUTTO — kurs NBP, VAT 23%, reverse charge dla usług zagranicznych (import usług), rezerwy. Wzory + przykłady. Ładowany w F3 (Price).
---

# Przeliczenia walut + VAT — PLN BRUTTO bezwzględnie

## Zasada nadrzędna: PLN BRUTTO

**Wszystkie kwoty w PLN brutto (z VAT).** KG PSP jako jednostka budżetowa **co do zasady nie odlicza VAT** od wydatków publicznych (art. 15 ust. 6 ustawy z 11.03.2004 r. o podatku od towarów i usług) — VAT to **realny koszt budżetu**, nie pozycja techniczna.

Wyjątek: dostawca **zwolniony z VAT** (niektóre usługi finansowe, edukacyjne) → wpisz kwotę faktury, oznacz „zw.".

## A. Kurs planistyczny

Dla pozycji walutowych (USD, EUR, GBP, CHF):

| Krok | Działanie |
|---|---|
| 1 | Ustal **kurs planistyczny**. Rekomendowane: **średni kurs NBP z dnia rozpoczęcia opracowania kosztorysu** lub **średni roczny ostatnio dostępny**. Można też przyjąć kurs ustalony przez dysponenta (MSWiA) jeśli jest podany. |
| 2 | Zapisz w raport.md: `Kurs planistyczny: 1 USD = X,XX PLN (NBP, RRRR-MM-DD)`. To **wymóg audytowy** — bez kursu z datą wniosek jest niekompletny. |
| 3 | Przelicz wszystkie kwoty walutowe na PLN przed dodaniem VAT. |
| 4 | Dodaj **rezerwę kursową 10–15%** jako osobną pozycję (sekcja O katalogu) — **nie wliczaj** w cenę bazową, bo to maskuje rzeczywisty koszt. |

> Źródło kursów NBP: tabela A — https://nbp.pl/statystyka-i-sprawozdawczosc/kursy/tabela-a/ (codzienne); tabela średnich rocznych — sprawozdania NBP.

## B. Reverse charge — import usług elektronicznych

**Faktury od dostawców zagranicznych usług elektronicznych** (Google, Mapbox, Cloudflare, GitHub, OpenAI/Anthropic, AWS, Azure, Stripe, Notion itp.) są **bez polskiego VAT**.

KG PSP jako nabywca usług elektronicznych ma obowiązek **samonaliczenia VAT 23%** — to **reverse charge** (mechanizm odwróconego obciążenia) z art. 17 ust. 1 pkt 4 ustawy o VAT.

### Wzór

```
Kwota_PLN_brutto = (Cena_netto_waluta × Kurs_planistyczny) × 1,23
```

**Konsekwencja:** w budżecie wpisujesz kwotę **brutto** uwzględniającą samonaliczony VAT 23%, mimo że faktura nie ma polskiego VAT.

### Wyjątki

Niektóre usługi są zwolnione (np. usługi finansowe — Stripe wąsko, niektóre usługi ubezpieczeniowe). **Weryfikuj księgowo per dostawca**, bo lista jest specyficzna. W razie wątpliwości — domyślnie 23% RC.

## C. Wzór ogólny

```
Kwota_PLN_brutto = (Cena_netto × Kurs) × (1 + Stawka_VAT)
```

| Sytuacja | Stawka VAT | Wzór |
|---|---|---|
| Dostawca PL z VAT 23% | 23% | netto × 1,23 |
| Dostawca PL zwolniony | 0% (oznacz „zw.") | netto × 1,00 |
| Dostawca PL z VAT 8% (niektóre szczególne) | 8% | netto × 1,08 |
| Dostawca PL z VAT 5% (niektóre szczególne) | 5% | netto × 1,05 |
| **Dostawca zagraniczny — usługi elektroniczne (RC)** | **23% RC** | **netto × kurs × 1,23** |
| Dostawca zagraniczny — usługa zwolniona | 0% RC | netto × kurs × 1,00 |

## D. Lista znanych dostawców z reverse charge (kontekst KG PSP)

| Dostawca | Charakter | RC 23%? |
|---|---|---|
| Google Cloud / Google Maps / Google Workspace | usługi chmurowe / mapy | ✅ tak |
| Microsoft Azure / Microsoft 365 | usługi chmurowe | ✅ tak (zwykle Microsoft Ireland) |
| Amazon Web Services (AWS) | usługi chmurowe | ✅ tak |
| Cloudflare | WAF/CDN/DNS/DDoS | ✅ tak |
| Mapbox | mapy | ✅ tak |
| OpenAI | API LLM | ✅ tak |
| Anthropic | API LLM | ✅ tak |
| GitHub (Enterprise) | repo + CI/CD | ✅ tak |
| GitLab.com | repo + CI/CD | ✅ tak |
| Figma | projektowanie | ✅ tak |
| Slack | komunikacja | ✅ tak |
| Notion | wiki/dokumenty | ✅ tak |
| Jira / Atlassian Cloud | tracker zadań | ✅ tak |
| PagerDuty / Opsgenie | incident mgmt | ✅ tak |
| Linear | tracker | ✅ tak |
| Sentry / Datadog / New Relic | monitoring/APM | ✅ tak |
| Stripe | płatności (subskrypcje) | częściowo zw. — weryfikuj |
| Polski operator telekomunikacyjny | telefonia/Internet | ❌ VAT 23% bezpośrednio |
| Polski integrator (firma PL) | usługi konsultingowe | ❌ VAT 23% bezpośrednio |
| NASK | hosting niejawny | ❌ VAT 23% lub zw. — weryfikuj |

## E. Rezerwy — trzy kategorie (Cz. O katalogu)

| Rezerwa | Wysokość | Charakter | § (2027+) |
|---|---|---|---|
| **Utrzymaniowa** | 10–20% OPEX | Pokrycie wzrostu cen, dodatkowych zgłoszeń, awarii | macierzysty (najczęściej **682**) lub **810** |
| **Kursowa** | 10–15% pozycji walutowych | Wahania kursu USD/EUR (różnice kursowe) | macierzysty (najczęściej **682**) |
| **Overage API** | 10–20% bazowych zapytań | Przekroczenia limitów (mapy, LLM, SMS, e-mail transakcyjny) | **682** |
| Rozwojowa | 5–15% CAPEX | Zmiany prawne/funkcjonalne | **720** lub **810** |

> **Rezerwa = osobna pozycja**, nie wliczaj w cenę bazową. Wtedy w sprawozdaniu widać rzeczywiste wykorzystanie.

## F. Przykłady end-to-end

### Przykład 1 — usługa zagraniczna LLM

**Wejście:** API LLM 1 000 USD/miesiąc; kurs planistyczny 4,00 PLN/USD; reverse charge VAT 23%.

| Krok | Obliczenie | Wynik |
|---|---|---|
| Netto miesięcznie PLN | 1 000 × 4,00 | **4 000 PLN netto** |
| Brutto miesięcznie PLN | 4 000 × 1,23 | **4 920 PLN brutto** |
| Brutto rocznie PLN | 4 920 × 12 | **59 040 PLN brutto** |
| + Rezerwa kursowa 15% | 59 040 × 1,15 | **67 896 PLN brutto** (konserwatywne) |

### Przykład 2 — usługa polska z VAT 23%

**Wejście:** Service desk firma polska 5 000 zł netto/miesiąc.

| Krok | Obliczenie | Wynik |
|---|---|---|
| Brutto miesięcznie | 5 000 × 1,23 | **6 150 PLN brutto** |
| Brutto rocznie | 6 150 × 12 | **73 800 PLN brutto** |
| Rezerwa utrzymaniowa 15% | 73 800 × 1,15 | (jako osobna pozycja) **11 070 PLN** |

### Przykład 3 — Google Maps z overage

**Wejście:** Google Maps 1 500 USD/rok bazowo; szacowane przekroczenie 30% (overage).

| Krok | Obliczenie | Wynik |
|---|---|---|
| Bazowe netto PLN | 1 500 × 4,00 | 6 000 PLN |
| Bazowe brutto PLN (RC 23%) | 6 000 × 1,23 | **7 380 PLN brutto** |
| Rezerwa overage 30% (osobna pozycja) | 7 380 × 0,30 | **2 214 PLN brutto** |
| **Suma do wniosku** | | **9 594 PLN brutto** |

### Przykład 4 — stacja robocza ujęta jako ŚT amortyzowany wieloletnio (2027+)

**Wejście:** Stacja robocza 15 000 zł netto / sztuka, polski dostawca, VAT 23%, polityka rachunkowości KG PSP: ujmowana jako ŚT amortyzowany wieloletnio.

| Krok | Obliczenie | Wynik |
|---|---|---|
| Brutto | 15 000 × 1,23 | **18 450 PLN brutto** |
| Klasyfikacja | ŚT amortyzowany wieloletnio | **§ 702 (702002 — Sprzęt informatyczny)** — wydatek majątkowy, grupa BP 4 |

### Przykład 5 — laptop ujęty jako ŚT amortyzowany jednorazowo (2027+)

**Wejście:** Laptop 5 000 zł netto / sztuka, polski dostawca, VAT 23%, polityka rachunkowości KG PSP: ujmowany jako ŚT amortyzowany jednorazowo.

| Krok | Obliczenie | Wynik |
|---|---|---|
| Brutto | 5 000 × 1,23 | **6 150 PLN brutto** |
| Klasyfikacja | ŚT amortyzowany jednorazowo | **§ 701 (Środki trwałe amortyzowane jednorazowo)** — wydatek majątkowy, grupa BP 4 |

### Przykład 6 — laptop ujęty jako wyposażenie nietworzące ŚT (2027+)

**Wejście:** Laptop 5 000 zł netto / sztuka, polski dostawca, VAT 23%, polityka rachunkowości KG PSP: ujmowany jako wyposażenie nietworzące ŚT.

| Krok | Obliczenie | Wynik |
|---|---|---|
| Brutto | 5 000 × 1,23 | **6 150 PLN brutto** |
| Klasyfikacja | Wyposażenie nietworzące ŚT | **§ 778 (778005 lub 778009)** — wydatek bieżący, grupa BP 3 |

> **❗ KLUCZOWA ZMIANA 2027+ (Dz.U. 2026 poz. 582):** Próg 10 000 zł zlikwidowany. Klasyfikacja zależy od **polityki rachunkowości jednostki**, nie kwoty. Patrz `references/klasyfikacja-budzetowa.md` Pułapka 4. Te same 5 000 zł netto → § 701, § 702 albo § 778 zależnie od decyzji rachunkowej.

## G. Checklist przed F4 (Classify)

- [ ] Kurs planistyczny NBP z datą wpisany w raport.md.
- [ ] Każda pozycja walutowa: netto × kurs = netto PLN.
- [ ] Każda pozycja: VAT bezpośrednio (23% / 8% / 5% / zw.) **lub** reverse charge 23% (usługi zagr.).
- [ ] Każda pozycja: brutto PLN obliczony.
- [ ] Rezerwy utrzymaniowa (10–20% OPEX) / kursowa (10–15% walut) / overage (10–20%) jako **osobne pozycje**, nie wliczone w cenę bazową.
- [ ] Tabela III.B kompletna — brak `[do uzupełnienia]`.
