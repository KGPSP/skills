---
name: anti-rationalization
type: reference
parent: planowanie-wydatkow-it-psp
sources:
  - DOC/material_skill.md §3
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §XI (audit log)
description: Pełna tabela 20 wymówek agenta przy przygotowywaniu wniosku finansowego (5 wycena / 7 klasyfikacja UFP / 4 uzasadnienie / 4 walidacja) — z ripostami i wskazaniem fazy, do której wrócić. Egzekwowana przed F6 (Verify) i przed deklaracją „done". Source: DOC §3 (Process over Prose) + audit log Cz. XI materiału.
---

# Anti-Rationalization — pełna tabela wymówek

> Przejdź przez tabelę przed F6 (Verify+Ship) i przed deklaracją „done". Każda wymówka = **stop** + powrót do właściwej fazy. Nie ma „wyjątku dla tej sytuacji".

## 1. Wymówki dotyczące wyceny (faza F3)

| # | Wymówka agenta | Riposta (blokada) | Powrót do |
|---|---|---|---|
| 1 | „Kwota netto wystarczy, budżetówka nie odlicza VAT" | **Wszystkie kwoty w PLN BRUTTO.** Art. 15 ust. 6 ustawy o VAT — KG PSP jako JB nie odlicza, VAT = realny koszt budżetu. Cz. III.0.A. Cofnij, przelicz każdą pozycję × (1 + stawka VAT). | F3 |
| 2 | „Cloudflare/Google/AWS bez VAT na fakturze → wpiszę netto + 0 VAT" | **Reverse charge / import usług.** Art. 17 ust. 1 pkt 4 ustawy o VAT — KG PSP **samonalicza VAT 23%**. Brutto = (cena netto × kurs) × 1,23. Cz. III.0.C. Lista znanych dostawców RC: `references/przeliczenia-walut-vat.md` §D. | F3 |
| 3 | „USD zostawię, dział księgowości przeliczy" | **Wszystkie kwoty w PLN.** Wpisz kurs planistyczny NBP z datą + rezerwę kursową 10–15% (Cz. III.0.B). Bez kursu z datą pozycja nie wejdzie do XLSX (kontrola formalna). Format: `Kurs planistyczny: 1 USD = X,XX PLN (NBP, RRRR-MM-DD)`. | F3 |
| 4 | „Rezerwa kursowa jest opcjonalna — kurs się ustabilizuje" | **Obowiązkowa rezerwa 10–15% pozycji walutowych** (Cz. O katalogu). USD/EUR wahają się historycznie ±20% w cyklu 5-letnim. Bez rezerwy = ryzyko niedofinansowania = wstrzymanie usługi w trakcie roku budżetowego. | F3 |
| 5 | „Pomyłka skali ×1000 — chyba miało być więcej, dorzucę zero" | **Stop. Eskaluj.** Cz. XI.5: „pomyłka skali ×1000 to najczęstsza przyczyna odrzucenia wniosku". Najpierw weryfikacja u autora danych (czy 90 zł/m-c, czy 90 000 zł/m-c?), dopiero potem wpis do wniosku. Nigdy „chyba". | F3 |

## 2. Wymówki dotyczące klasyfikacji UFP (faza F4)

| # | Wymówka agenta | Riposta (blokada) | Powrót do |
|---|---|---|---|
| 6 | „754/75409 jak normalnie KG PSP" | Dla **POLiOC cz. 42 obronnych (tryb A) → 752/75282**. Art. 155 ust. 2 pkt 3 OLiOC + art. 40 ust. 1 pkt 2 ustawy o Obronie Ojczyzny + pkt 41 Projektu Programu. 754 tylko dla trybu B (środki podstawowe OLiOC poza 0,15%) lub C (środki własne KG PSP poza POLiOC). Cz. IX.2, XI.1. | F1 → F4 |
| 7 | „§ 4000 jak w pliku wzorcowym XLSX" | **§ 4000 to placeholder/zbiór 4xxx, NIE pozycja klasyfikacji.** W rozporządzeniu Dz.U. 2026 poz. 582 nie ma takiego paragrafu szczegółowego. Cz. X.4, XI.4 #1. Zastąp szczegółowym wg matrycy: 4210 (sprzęt < 10k), 4260 (energia), 4300 (usługi), 4350 (Internet), 4360 (telekom), 4390 (ekspertyzy), 4700 (szkolenia NIE SC). | F4 |
| 8 | „Brutto > 10 000 zł → § 6060 (środek trwały)" | **Próg 10 000 zł dotyczy WARTOŚCI NETTO** (art. 16d CIT). Cz. IV.3.c #4. Komputer brutto 12 054 zł / netto 9 800 zł → **§ 4210** (materiał). Sprawdź netto każdego ŚT, nie brutto. | F4 |
| 9 | „Subskrypcja roczna 30k zł → § 6060 (WNiP, bo licencja)" | **Subskrypcja roczna ≠ WNiP.** Nie daje trwałego prawa majątkowego. Zawsze **§ 4300**, niezależnie od wartości. Tylko **licencje wieczyste** (lub > 1 r. z opłaceniem z góry) i ≥ 10k netto → § 6060. Cz. IV.3.c #1–2. | F4 |
| 10 | „Drobna rozbudowa → § 6050 (inwestycja)" | **§ 6050 tylko dla:** budowy nowego modułu, istotnej modernizacji, rozbudowy funkcjonalnej o znaczącej wartości, wytworzenia nowego systemu. **Drobne poprawki / usuwanie błędów → OPEX § 4300.** Cz. IV.3.c #3. Sprawdź: czy to nowy moduł, czy poprawka? | F4 |
| 11 | „Hosting + drobna rozbudowa wpiszę w jednej pozycji" | **Rozdziel pozycje.** Hosting → § 4300 (bieżący). Rozbudowa → § 6050 (majątkowy) — jeśli to istotne wytworzenie. Cz. IV.3.c #5. Mieszanie B i M w jednym wierszu = błąd klasyfikacji = ryzyko zarzutu DFP. | F4 |
| 12 | „Klasyfikacja: tylko paragraf wystarczy" | **Pełna ścieżka część → dział → rozdział → § → typ B/M** jest WYMAGANA. Niepełna klasyfikacja = ryzyko zarzutu naruszenia DFP (art. 5–18a ustawy z 17.12.2004 r.). Cz. IV.1–4. | F4 |

## 3. Wymówki dotyczące uzasadnienia (faza F5)

| # | Wymówka agenta | Riposta (blokada) | Powrót do |
|---|---|---|---|
| 13 | „Uzasadnienie 1 akapit, MSWiA zrozumie kontekst" | **8-PUNKTOWY schemat OBOWIĄZKOWY per pozycja** (Cz. X.2): (1) kwalifikowalność / (2) celowość / (3) zgodność obronna / (4) lokalizacja / (5) kosztorys / (6) wskaźnik / (7) okres używania / (8) próg MSWiA. Brak choćby jednego punktu = pozycja niekompletna, walidator zwraca exit 1. | F5 |
| 14 | „Wskaźnik realizacji → 'zwiększy zdolność' / 'poprawi efektywność'" | **WYMAGANA konkretna delta numeryczna.** Format: Aktualny [0/1/2/3/4/4+] → Docelowy [0/1/2/3/4/4+], wzrost +N punktów. Cz. IX.5, X.2 pkt 6. Proza zamiast liczby = wniosek wraca do uzupełnienia. | F5 |
| 15 | „Obszar/podobszar POLiOC sam zdecyduję, jest oczywiste" | **Matryca decyzyjna w `references/polioc-ramy.md` §2.** CEOZO → 5E (decyzja MSWiA — ewidencja nie jest sama w sobie budowlą). CEZOL → 4E (bezp. teleinf.). Platformowe SIEM/SOC/EDR/PKI → 4E. W razie wątpliwości — konsultuj Załącznik 2 Programu (lista zadań) i Załącznik 3 (asortyment), nie zgaduj. | F5 |
| 16 | „Plan utrzymania ŚT pominę, to formalność" | **Wymóg ≥ 5 lat dla ŚT z OLiOC** (pkt 184 Projektu Programu, art. 156 OLiOC). Bez planu utrzymania w pkt 7 schematu — pozycja w § 6050/6060 nie może wejść do wniosku. Cz. IX.1. Zbycie przed 5 latami = zgoda wojewody/MSWiA. Zakaz najmu/zbycia komercyjnego. | F5 |

## 4. Wymówki dotyczące walidacji (faza F6)

| # | Wymówka agenta | Riposta (blokada) | Powrót do |
|---|---|---|---|
| 17 | „Suma alokacji G..L (jednostki PSP) jakoś się zaokrągli do F (kwota)" | **TWARDY wymóg: suma kol. G..L = kol. F dla każdego wiersza XLSX.** Cz. X.6. Rozbieżność = błąd, do skorygowania przed złożeniem. Walidator sprawdza per wiersz. | F6 |
| 18 | „100k brutto to drobny zakup, wniosek o opinię MSWiA pominę" | **Próg 100 000 zł brutto na 1 rodzaj zakupu = OBOWIĄZKOWA opinia MSWiA** (pkt 166 Programu). Cz. IX.1, X.7 #6, XI.4 #5. Praktycznie wszystkie pozycje IT POLiOC są > 100k. Brak załączonego wniosku o opinię = wstrzymanie wydatkowania. | F6 |
| 19 | „Inwestycje wieloletnie — wpiszę razem, podziału na lata nie potrzeba" | **Art. 156a OLiOC** — inwestycje wieloletnie wymagają wykazu z **podziałem na lata 2027–2031** z limitem na każdy rok. Cz. IX.7, XI.4 #6. Dotyczy: CEOZO budowa, CEZOL rozbudowa wieloletnia, infrastruktura backupu, etc. Brak podziału = pozycja nie wejdzie do uchwały RM. | F6 |
| 20 | „Walidator zwrócił exit 1, ale pozycje wyglądają OK — pomijam" | **Walidator = źródło prawdy.** Exit 1 = realny błąd. Przeczytaj komunikat, znajdź wadliwą pozycję, popraw, uruchom ponownie. Nie pomijaj. DOC §3: „Riposta = blokada, nie sugestia". | F6 |

## 5. Zasada nadrzędna — Beyoncé Rule dla wniosków finansowych

> *„If you liked it, you should have put a test on it"* — adaptacja dla planowania wydatków:
>
> **Każda kwota w raport.md musi mieć dowód** (netto, kurs, VAT/RC, podstawę klasyfikacji, podstawę prawną). Bez dowodu = pozycja nie istnieje. Cz. III.0 + Cz. IV.3.c + Cz. X.2.

## 6. Wzorcowe sytuacje „spirit vs letter"

| Sytuacja | „Spirit" (intencja) | „Letter" (forma) | Decyzja |
|---|---|---|---|
| Pozycja 99 999 zł brutto | Próg 100k nie przekroczony | Praktycznie 100k | **Załącz opinię MSWiA proaktywnie** (bezpieczna interpretacja). |
| Subskrypcja 3-letnia 50k zł netto/rok | Wieloletnia → przypomina WNiP | Każdy rok osobno fakturowany | **§ 4300 dla każdego roku.** Nie § 6060. |
| Pentest po dużym update + cykl roczny | Dwa pentesty w roku | Charakter ten sam (cykliczny) | **Obie pozycje § 4390** (cykliczne). § 6050 tylko dla pentestu PRZED odbiorem nowego systemu. |
| Stacja robocza 9 990 zł netto | Bardzo blisko progu 10k | Netto < 10k | **§ 4210** (materiał). Nie § 6060. Trzymaj się litery progu. |
| LLM API 100 zł/m-c bazowo + szacowane 500 zł/m-c overage | Bazowe drobne | Rzeczywiste znaczne | **Wpisz obie pozycje:** bazową (4300, 1 200 zł/rok) + rezerwa overage (4300, 6 000 zł/rok). |

## 7. Stop-list — co zatrzymuje cały proces

Następujące sygnały **wstrzymują** wszystko do wyjaśnienia z autorem danych / dysponentem:

- Rozbieżność danych wejściowych (np. „90 zł/m-c" vs „1 mln/rok").
- Niejasność czy zadanie idzie w tryb A czy B (gdzie klasyfikacja).
- Brak danych o aktualnym poziomie wskaźnika (pkt 6 schematu) — niemożliwa konkretna delta.
- Brak planu utrzymania ŚT na ≥ 5 lat dla pozycji § 6050/6060.
- Suma alokacji G..L ≠ F po próbach korekt.

**Nie zgaduj. Eskaluj.** Cz. XI.5 zawiera 5 punktów wymagających weryfikacji u źródła — model 1:1.
