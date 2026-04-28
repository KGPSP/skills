---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa postępowania>>"
zamawiajacy: <<nazwa zamawiającego>>
wykonawca: <<nazwa wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
autor_analizy: <<email autora>>
typ_dokumentu: cytaty-i-zrodla
status: <<draft | final>>
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/cytaty-i-zrodla
---

# Register cytatów i źródeł — <<sygnatura>>

> [!info] Cel dokumentu
> Spis wszystkich cytatów użytych w raporcie, wraz z lokalizacją w dokumentach źródłowych. Pełni funkcję audit trail — umożliwia weryfikację każdej konkluzji raportu przez osobę kontrolującą (np. Biuro Prawne, radcę prawnego, NIK).

## 1. Cytaty z projektu umowy

| ID cytatu | Jednostka redakcyjna | Cytat literalny | Wykorzystany w (nr poprawki / analizy) |
|-----------|----------------------|------------------|-----------------------------------------|
| U-001 | § 1 ust. 1 | „<<cytat>>" | [[05-proponowane-poprawki-<<slug>>#P-001]], [[03-analiza-szczegolowa-<<slug>>#3 Przedmiot umowy]] |
| U-002 | § 2 ust. 3 | „<<cytat>>" | <<...>> |
| … | … | … | … |

## 2. Cytaty z SWZ

| ID cytatu | Lokalizacja | Cytat literalny | Wykorzystany w |
|-----------|-------------|------------------|-----------------|
| SWZ-001 | `[DOC: SWZ.pdf] [Rozdz. III] [str. 12]` | „<<cytat>>" | <<...>> |
| SWZ-002 | `[DOC: SWZ.pdf] [Rozdz. XII] [str. 45]` | „<<cytat>>" | <<...>> |
| … | … | … | … |

## 3. Cytaty z OPZ

| ID cytatu | Lokalizacja | Cytat literalny | Wykorzystany w |
|-----------|-------------|------------------|-----------------|
| OPZ-001 | `[DOC: OPZ.pdf] [Część A] [pkt A.3] [str. 8]` | „<<cytat>>" | <<...>> |
| OPZ-002 | `[DOC: OPZ.pdf] [Część B] [str. 15]` | „<<cytat>>" | <<...>> |
| … | … | … | … |

## 4. Cytaty z oferty wykonawcy

| ID cytatu | Lokalizacja | Cytat literalny | Wykorzystany w |
|-----------|-------------|------------------|-----------------|
| OF-001 | `[DOC: Formularz-ofertowy.pdf] [pkt 4] [str. 2]` | „<<cytat o cenie>>" | <<...>> |
| OF-002 | `[DOC: Formularz-ofertowy.pdf] [pkt 5] [str. 2]` | „<<cytat o terminie>>" | <<...>> |
| OF-003 | `[DOC: Formularz-ofertowy.pdf] [pkt 6]` | „<<cytat o gwarancji>>" | <<...>> |
| … | … | … | … |

## 5. Cytaty z PPU (Załącznik „Wzór umowy" do SWZ)

| ID cytatu | Lokalizacja | Cytat literalny | Wykorzystany w |
|-----------|-------------|------------------|-----------------|
| PPU-001 | `[DOC: Zał-5-Wzór-umowy.pdf] [§ 4 ust. 1]` | „<<cytat>>" | <<...>> |
| … | … | … | … |

## 6. Cytaty z odpowiedzi na pytania i modyfikacji SWZ

| ID cytatu | Lokalizacja | Data pisma | Cytat literalny | Wykorzystany w |
|-----------|-------------|------------|------------------|-----------------|
| PIS-001 | `[DOC: Pismo-01-wyjasnienia.pdf] [odp. na pyt. 3]` | <<yyyy-mm-dd>> | „<<cytat modyfikacji>>" | <<...>> |
| … | … | … | … | … |

## 7. Cytaty z harmonogramu

| ID cytatu | Lokalizacja | Cytat literalny | Wykorzystany w |
|-----------|-------------|------------------|-----------------|
| HRM-001 | `[DOC: Harmonogram.xlsx] [wiersz X]` | „<<cytat>>" | <<...>> |
| … | … | … | … |

## 8. Cytaty z aktów prawnych

### 8.1. Ustawa Pzp (tekst jednolity Dz.U. 2024 poz. 1320 ze zm.)

> [!important] Literalność i lokalizacja
> Cytaty poniższe są dokładne — weryfikowane 1:1 przeciwko autorytatywnemu tekstowi ustawy w [[D20192019Lj]]. Ze względu na to że plik D20192019Lj.md może być reformatowany (co zmienia numery linii), kolumna „Źródło" wskazuje **nagłówek Obsidian** (`### Art. N`) zamiast statycznego numeru linii. Do odnalezienia: `grep -n "^### Art. N" D20192019Lj.md` lub w Obsidian — Outline → Art. N.
> **Przy dodawaniu nowych cytatów** — zweryfikuj treść 1:1 w D20192019Lj.md przed wpisaniem do raportu.

| ID | Artykuł | Cytat literalny | Źródło (nagłówek w D20192019Lj.md) | Wykorzystany w |
|----|---------|-----------------|------------------------------------|-----------------|
| PZP-433-1 | art. 433 pkt 1 | „Projektowane postanowienia umowy nie mogą przewidywać: 1) odpowiedzialności wykonawcy za opóźnienie, chyba że jest to uzasadnione okolicznościami lub zakresem zamówienia" | `### Art. 433` → pkt 1 | [[05-proponowane-poprawki-<<slug-sygnatury>>#P-XXX]] |
| PZP-433-2 | art. 433 pkt 2 | „2) naliczania kar umownych za zachowanie wykonawcy niezwiązane bezpośrednio lub pośrednio z przedmiotem umowy lub jej prawidłowym wykonaniem" | `### Art. 433` → pkt 2 | <<...>> |
| PZP-433-3 | art. 433 pkt 3 | „3) odpowiedzialności wykonawcy za okoliczności, za które wyłączną odpowiedzialność ponosi zamawiający" | `### Art. 433` → pkt 3 | <<...>> |
| PZP-433-4 | art. 433 pkt 4 | „4) możliwości ograniczenia zakresu zamówienia przez zamawiającego bez wskazania minimalnej wartości lub wielkości świadczenia stron" | `### Art. 433` → pkt 4 | <<...>> |
| PZP-434-1 | art. 434 ust. 1 | „Umowę zawiera się na czas oznaczony." | `### Art. 434` → ust. 1 | <<...>> |
| PZP-434-2 | art. 434 ust. 2 | „Zamawiający może zawrzeć umowę, której przedmiotem są świadczenia powtarzające się lub ciągłe, na okres dłuższy niż 4 lata, jeżeli wykonanie zamówienia w dłuższym okresie spowoduje oszczędności kosztów realizacji zamówienia w stosunku do okresu czteroletniego lub jest to uzasadnione zdolnościami płatniczymi zamawiającego lub zakresem planowanych nakładów oraz okresem niezbędnym do ich spłaty." | `### Art. 434` → ust. 2 | <<...>> |
| PZP-436-1 | art. 436 pkt 1 | „Umowa zawiera postanowienia określające w szczególności: 1) planowany termin zakończenia usługi, dostawy lub robót budowlanych, oraz, w razie potrzeby, planowane terminy wykonania poszczególnych części usługi, dostawy lub roboty budowlanej, określone w dniach, tygodniach, miesiącach lub latach, chyba że wskazanie daty wykonania umowy jest uzasadnione obiektywną przyczyną" | `### Art. 436` → pkt 1 | <<...>> |
| PZP-436-2 | art. 436 pkt 2 | „2) warunki zapłaty wynagrodzenia" | `### Art. 436` → pkt 2 | <<...>> |
| PZP-436-3 | art. 436 pkt 3 | „3) łączną maksymalną wysokość kar umownych, których mogą dochodzić strony" | `### Art. 436` → pkt 3 | <<...>> |
| PZP-436-4 | art. 436 pkt 4 | „4) w przypadku umów zawieranych na okres dłuższy niż 12 miesięcy: a) wysokości kar umownych naliczanych wykonawcy z tytułu braku zapłaty lub nieterminowej zapłaty wynagrodzenia należnego podwykonawcom z tytułu zmiany wysokości wynagrodzenia, o której mowa w art. 439 ust. 5, b) zasady wprowadzania zmian wysokości wynagrodzenia w przypadku zmiany: [stawki VAT/akcyzy; minimalnego wynagrodzenia; zasad ubezpieczeń społecznych/zdrowotnych; zasad PPK] — jeżeli zmiany te będą miały wpływ na koszty wykonania zamówienia przez wykonawcę" | `### Art. 436` → pkt 4 | <<...>> |
| PZP-439-1 | art. 439 ust. 1 | „Umowa, której przedmiotem są roboty budowlane, dostawy lub usługi, zawarta na okres dłuższy niż 6 miesięcy, zawiera postanowienia dotyczące zasad wprowadzania zmian wysokości wynagrodzenia należnego wykonawcy w przypadku zmiany ceny materiałów lub kosztów związanych z realizacją zamówienia." | `### Art. 439` → ust. 1 | <<...>> |
| PZP-439-2 | art. 439 ust. 2 | „W umowie określa się: 1) poziom zmiany ceny materiałów lub kosztów [...] uprawniający strony umowy do żądania zmiany wynagrodzenia oraz początkowy termin ustalenia zmiany wynagrodzenia; 2) sposób ustalania zmiany wynagrodzenia: a) z użyciem odesłania do wskaźnika [...] Prezesa GUS lub b) przez wskazanie innej podstawy [...]; 3) sposób określenia wpływu zmiany [...] oraz określenie okresów, w których może następować zmiana wynagrodzenia; 4) maksymalną wartość zmiany wynagrodzenia, jaką dopuszcza zamawiający." | `### Art. 439` → ust. 2 | <<...>> |
| PZP-443 | art. 443 ust. 1 | „Zamawiający płaci wynagrodzenie w częściach, po wykonaniu części umowy, lub udziela zaliczki na poczet wykonania zamówienia, w przypadku umów zawieranych na okres dłuższy niż 12 miesięcy." | `### Art. 443` → ust. 1 | <<...>> |
| PZP-447 | art. 447 ust. 1 | „W przypadku zamówień na roboty budowlane, których termin wykonywania jest dłuższy niż 12 miesięcy, jeżeli umowa przewiduje zapłatę: 1) wynagrodzenia należnego wykonawcy w częściach, warunkiem zapłaty, przez zamawiającego, drugiej i następnych części należnego wynagrodzenia za odebrane roboty budowlane jest przedstawienie dowodów zapłaty wymagalnego wynagrodzenia podwykonawcom i dalszym podwykonawcom [...]" | `### Art. 447` → ust. 1 | <<...>> |
| PZP-450-1 | art. 450 ust. 1 | „Zabezpieczenie może być wnoszone, według wyboru wykonawcy, w jednej lub w kilku następujących formach: 1) pieniądzu; 2) poręczeniach bankowych lub poręczeniach spółdzielczej kasy oszczędnościowo-kredytowej [...]; 3) gwarancjach bankowych; 4) gwarancjach ubezpieczeniowych; 5) poręczeniach udzielanych przez podmioty, o których mowa w art. 6b ust. 5 pkt 2 ustawy [...] o utworzeniu Polskiej Agencji Rozwoju Przedsiębiorczości." | `### Art. 450` → ust. 1 | <<...>> |
| PZP-452-2 | art. 452 ust. 2 | „Zabezpieczenie ustala się w wysokości nieprzekraczającej 5 % ceny całkowitej podanej w ofercie albo maksymalnej wartości nominalnej zobowiązania zamawiającego wynikającego z umowy." | `### Art. 452` → ust. 2 | <<...>> |
| PZP-452-3 | art. 452 ust. 3 | „Zabezpieczenie można ustalić w wysokości większej niż określona w ust. 2, nie większej jednak niż 10 % ceny całkowitej podanej w ofercie [...], jeżeli jest to uzasadnione przedmiotem zamówienia lub wystąpieniem ryzyka związanego z realizacją zamówienia, co zamawiający opisał w SWZ lub innych dokumentach zamówienia." | `### Art. 452` → ust. 3 | <<...>> |
| PZP-453-1 | art. 453 ust. 1 | „Zamawiający zwraca zabezpieczenie w terminie 30 dni od dnia wykonania zamówienia i uznania przez zamawiającego za należycie wykonane." | `### Art. 453` → ust. 1 | <<...>> |
| PZP-453-2 | art. 453 ust. 2 | „Zamawiający może pozostawić na zabezpieczenie roszczeń z tytułu rękojmi za wady lub gwarancji kwotę nieprzekraczającą 30 % zabezpieczenia." | `### Art. 453` → ust. 2 | <<...>> |
| PZP-453-3 | art. 453 ust. 3 | „Kwota, o której mowa w ust. 2, jest zwracana nie później niż w 15. dniu po upływie okresu rękojmi za wady lub gwarancji." | `### Art. 453` → ust. 3 | <<...>> |
| PZP-454-1 | art. 454 ust. 1 | „Istotna zmiana zawartej umowy wymaga przeprowadzenia nowego postępowania o udzielenie zamówienia." | `### Art. 454` → ust. 1 | <<...>> |
| PZP-454-2 | art. 454 ust. 2 | „Zmiana umowy jest istotna, jeżeli powoduje, że charakter umowy zmienia się w sposób istotny w stosunku do pierwotnej umowy, w szczególności jeżeli zmiana: 1) wprowadza warunki, które gdyby zostały zastosowane w postępowaniu [...] to wzięliby w nim udział lub mogliby wziąć udział inni wykonawcy lub przyjęte zostałyby oferty innej treści; 2) narusza równowagę ekonomiczną stron umowy na korzyść wykonawcy, w sposób nieprzewidziany w pierwotnej umowie; 3) w sposób znaczny rozszerza albo zmniejsza zakres świadczeń i zobowiązań wynikający z umowy; 4) polega na zastąpieniu wykonawcy [...] w przypadkach innych, niż wskazane w art. 455 ust. 1 pkt 2." | `### Art. 454` → ust. 2 | <<...>> |
| PZP-455-2 | art. 455 ust. 2 | „Dopuszczalne są również zmiany umowy bez przeprowadzenia nowego postępowania o udzielenie zamówienia, których łączna wartość jest mniejsza niż progi unijne oraz jest niższa niż 10 % wartości pierwotnej umowy, w przypadku zamówień na usługi lub dostawy, albo 15 %, w przypadku zamówień na roboty budowlane, a zmiany te nie powodują zmiany ogólnego charakteru umowy." | `### Art. 455` → ust. 2 | <<...>> |
| PZP-456-1-1 | art. 456 ust. 1 pkt 1 | „Zamawiający może odstąpić od umowy: 1) w terminie 30 dni od dnia powzięcia wiadomości o zaistnieniu istotnej zmiany okoliczności powodującej, że wykonanie umowy nie leży w interesie publicznym, czego nie można było przewidzieć w chwili zawarcia umowy, lub dalsze wykonywanie umowy może zagrozić podstawowemu interesowi bezpieczeństwa państwa lub bezpieczeństwu publicznemu" | `### Art. 456` → ust. 1 pkt 1 | <<...>> |
| PZP-456-1-2 | art. 456 ust. 1 pkt 2 | „2) jeżeli zachodzi co najmniej jedna z następujących okoliczności: a) dokonano zmiany umowy z naruszeniem art. 454 i art. 455, b) wykonawca w chwili zawarcia umowy podlegał wykluczeniu na podstawie art. 108, c) Trybunał Sprawiedliwości Unii Europejskiej stwierdził, w ramach procedury przewidzianej w art. 258 Traktatu o funkcjonowaniu Unii Europejskiej, że Rzeczpospolita Polska uchybiła zobowiązaniom, które ciążą na niej na mocy Traktatów, dyrektywy 2014/24/UE, dyrektywy 2014/25/UE i dyrektywy 2009/81/WE, z uwagi na to, że zamawiający udzielił zamówienia z naruszeniem prawa Unii Europejskiej." | `### Art. 456` → ust. 1 pkt 2 | <<...>> |
| PZP-456-3 | art. 456 ust. 3 | „W przypadkach, o których mowa w ust. 1, wykonawca może żądać wyłącznie wynagrodzenia należnego z tytułu wykonania części umowy." | `### Art. 456` → ust. 3 | <<...>> |

### 8.2. Kodeks cywilny

| ID | Artykuł | Cytat | Wykorzystany w |
|----|---------|-------|-----------------|
| KC-001 | art. 353¹ | „Strony zawierające umowę mogą ułożyć stosunek prawny według swego uznania, byleby jego treść lub cel nie sprzeciwiały się właściwości (naturze) stosunku, ustawie ani zasadom współżycia społecznego." | <<...>> |
| KC-002 | art. 483 § 1 | „Można zastrzec w umowie, że naprawienie szkody wynikłej z niewykonania lub nienależytego wykonania zobowiązania niepieniężnego nastąpi przez zapłatę określonej sumy (kara umowna)." | <<...>> |
| KC-003 | art. 484 § 2 | „Jeżeli zobowiązanie zostało w znacznej części wykonane, dłużnik może żądać zmniejszenia kary umownej; to samo dotyczy wypadku, gdy kara umowna jest rażąco wygórowana." | <<...>> |
| … | … | … | … |

### 8.3. RODO (rozp. 2016/679)

| ID | Artykuł | Cytat | Wykorzystany w |
|----|---------|-------|-----------------|
| RODO-001 | art. 28 ust. 3 | „Przetwarzanie przez podmiot przetwarzający odbywa się na podstawie umowy lub innego instrumentu prawnego…" | <<...>> |
| RODO-002 | art. 32 | „Uwzględniając stan wiedzy technicznej, koszt wdrażania, charakter, zakres, kontekst i cele przetwarzania oraz ryzyko…" | <<...>> |

### 8.4. Ustawa o krajowym systemie cyberbezpieczeństwa (Dz.U. 2026 poz. 20 i 252)

| ID | Artykuł | Cytat | Wykorzystany w |
|----|---------|-------|-----------------|
| KSC-001 | art. 33 ust. 4 | <<cytat o rekomendacjach>> | <<...>> |
| KSC-002 | art. 67b ust. 15 | <<cytat o dostawcach wysokiego ryzyka>> | <<...>> |

### 8.5. Ustawa o prawie autorskim (Dz.U. 2022 poz. 2509 ze zm.)

| ID | Artykuł | Cytat | Wykorzystany w |
|----|---------|-------|-----------------|
| PA-001 | art. 41 ust. 2 | „Umowa o przeniesienie autorskich praw majątkowych lub umowa o korzystanie z utworu, zwana dalej «licencją», obejmuje pola eksploatacji wyraźnie w niej wymienione." | <<...>> |
| PA-002 | art. 74 ust. 4 | <<cytat dot. programów komputerowych>> | <<...>> |

## 9. Orzecznictwo — cytaty uzupełniające (opcjonalne)

| ID | Sygnatura | Organ / data | Teza | Wykorzystany w |
|----|-----------|--------------|------|-----------------|
| ORZ-001 | <<np. KIO 1234/2025>> | KIO 2025-XX-XX | „<<teza orzeczenia>>" | <<...>> |
| ORZ-002 | <<...>> | <<...>> | <<...>> | <<...>> |

## 10. Literatura (opcjonalne)

| ID | Źródło | Wykorzystany w |
|----|--------|-----------------|
| LIT-001 | <<np. J. Pieróg, Prawo zamówień publicznych. Komentarz, wyd. X, s. 478>> | <<...>> |
| … | … | … |

## Sprawdzenie audit trail

- [ ] Każda konkluzja w [[01-raport-glowny-<<slug>>]] ma cytat z tego registru
- [ ] Każda poprawka w [[05-proponowane-poprawki-<<slug>>]] ma przypisany ID cytatu z umowy (U-XXX) i ID uzasadnienia prawnego (PZP-XXX / KC-XXX / …)
- [ ] Każdy wiersz w [[04-macierz-korelacji-<<slug>>]] ma ID cytatu źródłowego
- [ ] Brak odwołań do cytatów, które nie są w tym registru
- [ ] Wszystkie cytaty są literalne (bez parafrazy), z dokładną lokalizacją

## Powiązania

- [[01-raport-glowny-<<slug-sygnatury>>]]
- [[03-analiza-szczegolowa-<<slug-sygnatury>>]]
- [[04-macierz-korelacji-<<slug-sygnatury>>]]
- [[05-proponowane-poprawki-<<slug-sygnatury>>]]
- [[06-ocena-ryzyk-<<slug-sygnatury>>]]
- [[07-wnioski-koncowe-<<slug-sygnatury>>]]
