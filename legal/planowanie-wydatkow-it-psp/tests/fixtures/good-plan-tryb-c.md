# Raport finansowy — Service Desk KG PSP — 2026-05-25

> Tryb C — środki własne KG PSP poza POLiOC (754/75409, klasyfikacja 2027+)
>
> **Walutowość:** PLN BRUTTO (wszystkie pozycje krajowe — brak pozycji walutowych, kurs planistyczny niewymagany).

## 1. Metryczka systemu

| Pole | Wartość |
|---|---|
| Nazwa systemu | Service Desk KG PSP |
| Akronim | SD-KGPSP |
| Walutowość | PLN BRUTTO |
| Źródło finansowania | część 42, dział 754, rozdział 75409 |
| Klasyfikacja UFP | 2027+ wg Dz.U. 2026 poz. 582 |

## 5. Tabela III.B

| Pozycja | § | Koszt roczny brutto | Część | Dział | Rozdział | B/M | Grupa BP |
|---|---|---|---|---|---|---|---|
| Subskrypcja Jira Service Management (PL, VAT 23%) | 682 | 73 800 | 42 | 754 | 75409 | B | 3 |
| Stacja robocza service desk (12 szt × 15 000 zł netto, ujęte jako ŚT) | 702 | 221 400 | 42 | 754 | 75409 | M | 4 |

## 6. Uzasadnienia (schemat 4-punktowy dla trybu C — pkt 2, 5, 7, 8)

## Pozycja: SD-001 – Subskrypcja Jira Service Management

**Klasyfikacja:** część 42 / dział 754 / rozdział 75409 / § 682 / typ B / grupa BP 3
**Kwota brutto PLN:** 73 800 zł
**Alokacja:** KG PSP 73 800, Akademia 0, CS Czstch 0, SA Krk 0, SA Pzn 0, SP Bdg 0
**Charakter:** OPEX bieżący — usługi informatyczne (subskrypcja SaaS, dostęp czasowy — nie WNiP)

### 2. CELOWOŚĆ Z UWZGLĘDNIENIEM POSIADANYCH ZASOBÓW
- Stan aktualny: service desk obsługiwany aktualnie przez arkusze Excel + skrzynka e-mail.
- Luka: brak ticketingu, brak SLA tracking, brak rozliczalności obsługi zgłoszeń.
- Rezultat: wdrożenie standardu ITIL obsługi zgłoszeń, raportowanie SLA, audytowalność.

### 5. KOSZTORYS
- Kwota netto: 60 000 zł (5 000 zł netto × 12 m-c, dostawca PL z VAT 23%).
- VAT: 23% bezpośrednio.
- Kurs planistyczny: nie dotyczy (pozycja PLN).
- Rezerwy: utrzymaniowa 15% = 11 070 zł (osobna pozycja w sekcji 5).
- Kwota brutto razem: 73 800 zł.

### 7. OKRES UŻYWANIA
- Nie dotyczy — pozycja OPEX (§ 682, subskrypcja roczna SaaS bez nabycia WNiP).

### 8. PRÓG OPINIOWANIA MSWiA
- Kwota brutto > 100 000 zł: nie (73 800 zł < 100 000 zł).
- Wniosek o opinię MSWiA: niewymagany. Pkt 166 Programu nie ma zastosowania (poza POLiOC).

---

## Pozycja: SD-002 – Stacje robocze service desk

**Klasyfikacja:** część 42 / dział 754 / rozdział 75409 / § 702 (702002) / typ M / grupa BP 4
**Kwota brutto PLN:** 221 400 zł
**Alokacja:** KG PSP 221 400, Akademia 0, CS Czstch 0, SA Krk 0, SA Pzn 0, SP Bdg 0
**Charakter:** CAPEX majątkowy — 12 szt stacji roboczych ujętych w polityce rachunkowości KG PSP jako środki trwałe amortyzowane wieloletnio. Klasyfikacja § 702 (702002 — zwykły sprzęt informatyczny administracyjny, nie zadania operacyjne PSP).

### 2. CELOWOŚĆ Z UWZGLĘDNIENIEM POSIADANYCH ZASOBÓW
- Stan aktualny: stacje robocze service desku — modele z 2018 r., kończy się wsparcie OS i bezpieczeństwa.
- Luka: brak zgodności z minimum technicznym do obsługi nowoczesnych narzędzi ticketingowych i komunikatorów.
- Rezultat: wymiana parku stacji roboczych na 12 szt. spełniających minimum techniczne na okres 5+ lat.

### 5. KOSZTORYS
- Kwota netto: 180 000 zł (12 × 15 000 zł).
- VAT: 23% bezpośrednio.
- Rezerwy: rozwojowa 5% = 9 000 zł (zaokrąglenia, akcesoria).
- Kwota brutto razem: 221 400 zł.

### 7. OKRES UŻYWANIA
- Planowany okres używania: ≥ 5 lat (zgodnie z polityką wymiany sprzętu KG PSP).
- Plan utrzymania:
  - Gwarancja producenta: 3 lata on-site + 2 lata extended.
  - Wymiana baterii: po 3 latach (rezerwa wpisana w plan utrzymania KG PSP, poza tym wnioskiem).
  - Plan wymiany: po 5+ latach kolejny cykl wymiany sprzętu.

### 8. PRÓG OPINIOWANIA MSWiA
- Kwota brutto > 100 000 zł: tak (221 400 zł).
- Załączony osobny wniosek o opinię MSWiA: `wniosek-opinii-SDKGPSP-stacje-2026-05-25.md`.

## 7. Tabela XLSX

| Pod-obszar | Nazwa zadania | Dział | Rozdział | § | Kwota brutto [zł] | KG PSP | Akademia | CS Czstch | SA Krk | SA Pzn | SP Bdg |
|---|---|---|---|---|---|---|---|---|---|---|---|
| C-OPEX | Subskrypcja Jira Service Management | 754 | 75409 | 682 | 73 800 | 73 800 | 0 | 0 | 0 | 0 | 0 |
| C-CAPEX | Stacje robocze service desk (12 szt) | 754 | 75409 | 702 | 221 400 | 221 400 | 0 | 0 | 0 | 0 | 0 |

**Suma F razem:** 295 200 zł
**Walidacja:** sum(G..L) = F dla każdego wiersza? **TAK**.
