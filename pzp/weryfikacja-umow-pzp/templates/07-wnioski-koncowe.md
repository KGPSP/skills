---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa postępowania>>"
zamawiajacy: <<nazwa zamawiającego>>
wykonawca: <<nazwa wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email autora>>
typ_dokumentu: wnioski-koncowe
status: <<draft | final>>
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wnioski-koncowe
---

# Wnioski końcowe — weryfikacja projektu umowy <<sygnatura>>

> [!important] Format
> **Pięć pytań — jednoznaczne odpowiedzi.** Brak „być może", „warto rozważyć", „można by". Odpowiedź zamawiającego musi być przygotowana do bezpośredniego przeniesienia do protokołu / notatki decyzyjnej.

---

## Pytanie 1 — Czy projekt umowy może zostać podpisany w obecnym brzmieniu?

<!-- Agent wybiera: [!success]=TAK, [!warning]=WARUNKOWO, [!danger]=NIE -->
> [!warning] Odpowiedź
> **<<TAK / NIE / WARUNKOWO>>**

### Uzasadnienie

<<1-3 akapity — dlaczego. Odniesienie do wykrytych R1 (jeśli są — odpowiedź NIE / WARUNKOWO) lub ich braku (odpowiedź TAK).>>

### Dane liczbowe wspierające

- Liczba znalezisk R1 (krytyczne, blokujące podpis): <<N>>
- Liczba znalezisk R2 (istotne, silnie rekomendowane): <<N>>
- Kluczowe obszary problemowe: <<lista top 3-5>>

---

## Pytanie 2 — Jakie poprawki są bezwzględnie konieczne przed podpisaniem?

> [!danger] Bezwzględne minimum

| # | P-XXX | Nazwa poprawki | Jednostka | Podstawa obligatoryjności |
|---|-------|-----------------|-----------|----------------------------|
| 1 | [[05-proponowane-poprawki-<<slug>>#P-001]] | <<nazwa>> | <<§>> | <<np. art. 439 Pzp — obligatoryjna waloryzacja>> |
| 2 | [[05-proponowane-poprawki-<<slug>>#P-002]] | <<...>> | <<§>> | <<...>> |
| 3 | … | … | … | … |

### Konsekwencja niewdrożenia

<<Co grozi zamawiającemu, jeśli podpisze umowę bez tych poprawek: nieważność z mocy prawa, ryzyko unieważnienia (art. 457 Pzp), wzrost ryzyka sporu sądowego, zarzuty kontroli NIK/UZP, potencjalna kara administracyjna.>>

### Status wdrożenia

- [ ] Wszystkie R1 (<<N>>) wdrożone w projekcie umowy
- [ ] Zweryfikowane przez radcę prawnego / Biuro Prawne KG PSP
- [ ] Zaakceptowane przez wykonawcę (jeśli wymaga uzgodnienia)

---

## Pytanie 3 — Jakie poprawki są rekomendowane dla zwiększenia bezpieczeństwa zamawiającego?

> [!warning] Silnie rekomendowane (R2)

| # | P-XXX | Nazwa | Jednostka | Korzyść dla zamawiającego |
|---|-------|-------|-----------|----------------------------|
| 1 | [[05-proponowane-poprawki-<<slug>>#P-XXX]] | <<...>> | <<§>> | <<np. „eliminuje ryzyko nieskutecznej egzekucji kary przy odmowie zapłaty przez wykonawcę">> |
| … | … | … | … | … |

### Zalecane (R3)

| # | P-XXX | Nazwa | Jednostka |
|---|-------|-------|-----------|
| 1 | [[05-proponowane-poprawki-<<slug>>#P-XXX]] | <<...>> | <<§>> |
| … | … | … | … |

### Do rozważenia (R4)

| # | P-XXX | Nazwa | Jednostka |
|---|-------|-------|-----------|
| 1 | [[05-proponowane-poprawki-<<slug>>#P-XXX]] | <<literówka w nazwie / redakcja>> | <<§>> |
| … | … | … | … |

---

## Pytanie 4 — Jakie ryzyka pozostaną nawet po korekcie?

> [!info] Ryzyka rezydualne

Pełna analiza: [[06-ocena-ryzyk-<<slug>>#Ryzyka pozostałe po wdrożeniu wszystkich rekomendowanych poprawek]].

### 4.1. Ryzyka rynkowe / ekonomiczne

- <<np. „Ryzyko wzrostu wskaźnika GUS powyżej założonego cap-u waloryzacji (5%) — przy wysokiej inflacji zamawiający może być zmuszony do dodatkowej zmiany umowy w trybie art. 455 ust. 1 pkt 3">>
- <<...>>

### 4.2. Ryzyka realizacyjne

- <<np. „Ryzyko niedostępności komponentów po stronie wykonawcy — umowa nie może tego całkowicie wyeliminować, może jedynie zabezpieczyć mechanizmem kar i odstąpienia">>
- <<...>>

### 4.3. Ryzyka prawne (interpretacyjne)

- <<np. „Ryzyko odmiennej interpretacji klauzuli waloryzacyjnej przez KIO — praktyka orzecznicza w zakresie art. 439 wciąż się kształtuje">>
- <<...>>

### 4.4. Ryzyka organizacyjne zamawiającego

- <<np. „Ryzyko, że zamawiający nie dochowa własnego terminu akceptacji harmonogramu, co usprawiedliwi opóźnienie wykonawcy">>
- <<...>>

### Mitygacja ryzyk rezydualnych

<<Zalecenia operacyjne (poza redakcyjnymi) — np. „przygotować zespół wdrożeniowy", „zaplanować rezerwę budżetową na waloryzację", „ustalić pisemne procedury komunikacji z wykonawcą".>>

---

## Pytanie 5 — Czy istnieją elementy wymagające pilnego ujednolicenia z dokumentacją postępowania?

> [!warning] Rozbieżności umowa ↔ dokumentacja postępowania

Pełna macierz: [[04-macierz-korelacji-<<slug>>]].

### 5.1. Rozbieżności z PPU (Wzór umowy)

| # | Umowa § | PPU | Rodzaj rozbieżności | Priorytet korekty |
|---|---------|------|----------------------|-------------------|
| 1 | <<§>> | <<§ PPU>> | <<...>> | <<R1/R2>> |
| … | … | … | … | … |

### 5.2. Rozbieżności z SWZ

| # | Umowa § | SWZ rozdz. | Rozbieżność | Priorytet |
|---|---------|------------|-------------|-----------|
| 1 | <<§>> | <<Rozdz.>> | <<...>> | <<...>> |

### 5.3. Rozbieżności z OPZ

| # | Umowa § | OPZ | Rozbieżność | Priorytet |
|---|---------|------|-------------|-----------|
| 1 | <<§>> | <<pkt OPZ>> | <<...>> | <<...>> |

### 5.4. Rozbieżności z ofertą wykonawcy

> [!danger] Kluczowe
> Rozbieżność umowa ↔ oferta wybranego wykonawcy to najbardziej wrażliwy obszar. Każda taka niezgodność = P7 + R1/R2 + ryzyko art. 454 (nielegalna zmiana umowy).

| # | Umowa § | Oferta | Rozbieżność | Priorytet |
|---|---------|---------|-------------|-----------|
| 1 | <<§ (cena)>> | <<formularz>> | <<...>> | <<...>> |
| 2 | <<§ (termin)>> | <<formularz>> | <<...>> | <<...>> |
| 3 | <<§ (gwarancja)>> | <<formularz>> | <<...>> | <<...>> |

### 5.5. Rozbieżności z odpowiedziami na pytania i modyfikacjami SWZ

| # | Pismo | Zakres modyfikacji | Status uwzględnienia | Priorytet |
|---|-------|---------------------|-----------------------|-----------|
| 1 | <<Pismo z dn.>> | <<...>> | <<nieuwzględniony / uwzględniony częściowo>> | <<...>> |

### Rekomendowane działania pilne

- [ ] <<Korekta P-XXX — termin do <<data>>>>
- [ ] <<Korekta P-XXX — termin do <<data>>>>
- [ ] Uzgodnienie z wykonawcą (jeżeli wymaga) — pismo: [[drafting-pzp-letters]]

---

## Rekomendacja końcowa — podpis dokumentu

**Opracowanie:** <<imię i nazwisko / email autora analizy>>
**Data:** <<yyyy-mm-dd>>

<!-- Agent wybiera callout wg konkluzji: [!success]/[!warning]/[!danger] -->
> [!warning] Decyzja rekomendowana
> <<Zwięzłe streszczenie rekomendacji: „Projekt umowy może zostać podpisany po wdrożeniu poprawek R1 (lista P-XXX, P-XXX, …). Poprawki R2 silnie rekomendowane. Po ich wdrożeniu umowa zapewni wystarczające bezpieczeństwo dla Zamawiającego." LUB „Projekt umowy nie powinien zostać podpisany w obecnym brzmieniu ze względu na naruszenia art. 439 Pzp i art. 433 pkt 1 Pzp. Wymaga gruntownej przebudowy." — konkretnie i jednoznacznie.>>

## Nazwa poszczególnych poprawek do wdrożenia (lista sumaryczna)

Dla łatwego kopiowania do korespondencji:

**R1 (obligatoryjne przed podpisem):**
- P-001 — <<nazwa>>
- P-002 — <<nazwa>>
- …

**R2 (silnie rekomendowane):**
- P-XXX — <<nazwa>>
- …

**R3 (zalecane):**
- P-XXX — <<nazwa>>
- …

## Powiązania

- [[00-podsumowanie-wykonawcze-<<slug-sygnatury>>]]
- [[01-raport-glowny-<<slug-sygnatury>>]]
- [[02-tabela-ustalen-krytycznych-<<slug-sygnatury>>]]
- [[03-analiza-szczegolowa-<<slug-sygnatury>>]]
- [[04-macierz-korelacji-<<slug-sygnatury>>]]
- [[05-proponowane-poprawki-<<slug-sygnatury>>]]
- [[06-ocena-ryzyk-<<slug-sygnatury>>]]
