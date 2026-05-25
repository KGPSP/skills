---
name: klasyfikacja-budzetowa
type: reference
parent: planowanie-wydatkow-it-psp
sources:
  - now_skille/materialy_polioc/FINANSOWANIE/Analiza_klasyfikacji_IT_KG_PSP_2027_BIL.docx
  - now_skille/materialy_polioc/FINANSOWANIE/Material_edukacyjny_Finanse_publiczne_2026_BIL_KG_PSP.docx
  - now_skille/materialy_polioc/FINANSOWANIE/ezd_359297-bf-i-rozporzadzenie-klasyfikacja-budzetowa/2026-05-14-uwagi-bil-klasyfikacja-2027.md
  - now_skille/materialy_polioc/material_przeliczanie_kosztow.md §IV
description: Klasyfikacja UFP (część → dział → rozdział → § → typ B/M) dla wydatków IT KG PSP w okresie planowania budżetu **2027+**. Stosuje rozporządzenie MFiG z 20.04.2026 (Dz.U. 2026 poz. 582) wprowadzające nowe paragrafy 3-cyfrowe + załącznik nr 4 dla bezpieczeństwa wewnętrznego PSP. Trzy warianty: A (POLiOC cz. 42 obronne 752/75282), B (POLiOC podstawowy 754/75414), C (środki własne KG PSP 754/75409). Ładowany w F4 (Classify).
---

# Klasyfikacja budżetowa wg ufp — okres planowania 2027+

> **Pomyłka w klasyfikacji = ryzyko zarzutu naruszenia DFP** (art. 5–18a ustawy z 17.12.2004 r. o odpowiedzialności za naruszenie dyscypliny finansów publicznych).

## 0. Stan prawny — reforma klasyfikacji 2027+

| Akt | Data | Status |
|---|---|---|
| Ustawa z 27.02.2026 o zmianie ufp i niektórych innych ustaw | ogłoszona 30.03.2026, weszła 14.04.2026 | **Dz.U. 2026 poz. 426** |
| Rozporządzenie MFiG z 20.04.2026 w sprawie szczegółowej klasyfikacji dochodów, wydatków, przychodów i rozchodów oraz środków pochodzących ze źródeł zagranicznych | ogłoszone 28.04.2026, weszło 29.04.2026 | **Dz.U. 2026 poz. 582** |
| Ustawa o finansach publicznych — tekst jednolity | aktualizowany | **Dz.U. 2025 poz. 1483** + zmiany |

**Stosowanie:**
- **Planowanie ustawy budżetowej na rok 2027 i lata kolejne** (oraz projekty uchwał JST na 2027+) → **NOWA klasyfikacja** (Dz.U. 2026 poz. 582).
- Sprawozdania z wykonania budżetu 2026 → przepisy dotychczasowe (poza zakresem skilla — skill jest **ex ante**, nie sprawozdawczość).
- POLiOC 2027–2031 → w całości **NOWA klasyfikacja**.

> **Skill obsługuje wyłącznie planowanie 2027+.** Stara klasyfikacja (4xxx/6xxx) usunięta z matrycy — jeśli analizujesz wnioski archiwalne, zob. „Klucz przejścia" w §10.

## 1. Trzy warianty klasyfikacji — wybór w F1

| Tryb | Źródło finansowania | Część | Dział | Rozdział | Podstawa prawna |
|---|---|---|---|---|---|
| **A** | **POLiOC cz. 42 (środki obronne 0,15% PKB)** | **42** MSWiA | **752** Obrona narodowa | **75282** Zadania obronne PSP | art. 155 ust. 2 pkt 3 OLiOC + art. 40 ust. 1 pkt 2 ustawy o Obronie Ojczyzny + pkt 41 Projektu POLiOC 2027–2031 |
| B | POLiOC podstawowy (poza 0,15%) | 42 / 85/XX | 754 | **75414** Obrona cywilna | art. 155 ust. 1 OLiOC |
| C | Środki własne KG PSP poza POLiOC | 42 | 754 | **75409** KG PSP | budżet zwykły MSWiA |
| (D) | Inne podmioty obronne (nie-PSP) | 42 / 85/XX | 752 | 75281 Zadania obronne (ogólne) | jak A, ale dla innych organów |
| (R) | Rezerwa celowa Programu OLiOC | **83** Rezerwy celowe | przepływ do docelowej | — | dystrybucja decyzją RM |

> **WAŻNE:** Rozdziały 75282 / 75414 / 75409 **pozostają bez zmian** w reformie 2027+ (nie wymieniono ich wśród uchylonych/zmienionych w Dz.U. 2026 poz. 582). Reforma dotyczy wyłącznie **paragrafów** (4. poziom klasyfikacji) i nowej logiki 5 grup wydatków BP.

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

## 2. Działy i rozdziały — pozostają bez zmian

### Dział 754 — Bezpieczeństwo publiczne i ochrona przeciwpożarowa (tryb B/C)

| Rozdział | Nazwa | Zastosowanie |
|---|---|---|
| **75409** | Komenda Główna PSP | Wydatki KG PSP — systemy centralne (CEOZO, CEZOL, SOiA), warstwa centralna, BIŁ |
| 75410 | Komendy wojewódzkie PSP | Wydatki KW PSP (z części 85/XX wojewody) |
| 75411 | Komendy powiatowe PSP | Wydatki KP/KM PSP |
| 75412 | Ochotnicze straże pożarne | OSP |
| 75413 | Pozostałe jednostki ochrony ppoż. | inne jednostki |
| **75414** | Obrona cywilna | Zadania OLiOC (środki podstawowe — poza 0,15%) |
| 75415 | Ratownictwo górskie i wodne | GOPR/TOPR/WOPR |
| 75421 | Zarządzanie kryzysowe | |

### Dział 752 — Obrona narodowa (tryb A)

| Rozdział | Nazwa | Zastosowanie |
|---|---|---|
| 75281 | Zadania obronne wynikające z OLiOC (ogólne) | inne podmioty obronne (nie-PSP) |
| **75282** | **Zadania obronne wynikające z OLiOC realizowane przez PSP** | **Cały wniosek PSP do POLiOC cz. 42** |

## 3. Nowa struktura paragrafu (3+1)

```
Paragraf = 3 cyfry przedmiot/charakter + 1 cyfra źródło/przeznaczenie finansowania
np. 682 (Usługi informatyczne) + 0 (środki krajowe) = "6820"
```

**Zmiana względem starej klasyfikacji:** numeracja paragrafów zmieniona z 4xxx/6xxx (np. 4300, 6060) na **3-cyfrowe** (np. 682, 702) z czwartą cyfrą jako źródło. **Struktura 3+1 zachowana**, ale numeracja, treść ekonomiczna i przypisanie do grup wydatków **przebudowane**.

### Pięć grup wydatków budżetu państwa (art. 124 ufp po zmianie)

| Gr. | Nazwa | Sens ekonomiczny | Zakres paragrafów |
|---|---|---|---|
| 1 | Transfery bieżące | Przepływy bieżące do innych podmiotów, dotacje, subwencje, zasoby własne UE | 300–399, 400–498, 850–899 |
| 2 | Świadczenia na rzecz osób fizycznych | Wydatki kierowane bezpośrednio do osób fizycznych (niebędące wynagrodzeniem) | 200–299 |
| **3** | **Wydatki bieżące** | **Daniny, wynagrodzenia, zakupy towarów i usług, koszty funkcjonowania jednostek, obsługa długu SP** | **100–199, 600–699, 770–799, 800–849** |
| **4** | **Wydatki majątkowe** | **Nakłady na niefinansowe aktywa trwałe, akcje, udziały i wkłady do spółek** | **700–769** |
| 5 | Transfery majątkowe | Transfery przeznaczone na finansowanie wydatków majątkowych | 500–599 |

**Dla skilla IT KG PSP istotne są wyłącznie grupy 3 (bieżące) i 4 (majątkowe).**

## 4. Decyzja główna: bieżące czy majątkowe (przed wyborem paragrafu)

Reforma wymusza ustalenie charakteru ekonomicznego **PRZED** wyborem paragrafu. Pytania kontrolne (BIŁ KG PSP):

1. **Czy powstaje lub jest nabywany środek trwały?** → grupa 4 (700–769)
2. **Czy powstaje lub jest nabywana wartość niematerialna i prawna (WNiP)?** → grupa 4 (711/712)
3. **Czy wydatek ulepsza istniejący środek trwały albo system?** → grupa 4
4. **Czy jest to tylko utrzymanie, aktualizacja, wsparcie, abonament, dostęp do usługi?** → grupa 3 (682 najczęściej)
5. **Czy wykonawcą jest przedsiębiorca, czy osoba fizyczna na umowie cywilnoprawnej?** → osoba fizyczna → § 670
6. **Czy usługa jest elementem ceny nabycia/wytworzenia aktywa?** → wchodzi w wartość ŚT/WNiP (np. analiza przedwdrożeniowa za inwestycją)

> **❗ KLUCZOWA ZMIANA 2027+:** **Próg 10 000 zł zlikwidowany.** O kwalifikacji do wydatku majątkowego decyduje **polityka rachunkowości jednostki** (czy zakup ujmowany jako środek trwały, czy materiał), **NIE wartość zakupu**. Patrz §6 Pułapka 4.

## 5. Matryca paragrafów IT — wydatki BIEŻĄCE (grupa BP 3)

| § | Nazwa | Typowe zastosowanie IT | Pozycja zał. nr 4 |
|---|---|---|---|
| **631** | Najem i dzierżawa | **Dzierżawa łączy, ciemnego włókna, kanalizacji teletechnicznej, otworów kanalizacyjnych, traktów** | **631003** — Dzierżawa łączy/traktów (PSP) |
| **634** | Naprawy i konserwacja | **Serwis sprzętu IT i łączności, naprawy, konserwacja** (NIE remont — to § 627) | **634003** Łączność (maszty, anteny, radiotelefony); **634004** Informatyka (serwery, stacje, sieć) |
| **638** | Szkolenia zewnętrzne | Szkolenia administratorów, operatorów (zewnętrzne, nie SC) | — |
| **642** | Dopłaty do przejazdów | (rzadko w IT) | — |
| **662** | Odpady i ścieki | (poza IT) | — |
| **670** | Wynagrodzenia bezosobowe | **Umowy zlecenia / o dzieło z osobą fizyczną** (NIE przedsiębiorcą) — konsultacje IT, audyt, kodowanie ad-hoc | **670001** — typowa pozycja PSP |
| **677** | Ekspertyzy, analizy, opinie | **Pentest cykliczny, audyt bezpieczeństwa, audyt zgodności, ekspertyza techniczna, DPIA zewn., analizy ryzyka, testy WCAG zewn., analiza przedwdrożeniowa** (gdy nie jest kosztem inwestycji) | brak rozwinięcia w zał. nr 4 |
| **678** | Ubezpieczenia osobowe i majątkowe | Ubezpieczenie sprzętu IT | — |
| **681** | Usługi telekomunikacyjne | **Internet, transmisja danych, telefonia, GSM/LTE/5G, APN M2M, SMS API jako usługa, transmisja telekomunikacyjna** | brak rozwinięcia w zał. nr 4 |
| **682** | **Usługi informatyczne** | **DOMYŚLNY § dla większości usług IT 2027+:** hosting, SaaS, PaaS/IaaS, mapy API, LLM API, service desk, integracje, transfer, CDN, WAF (gdy usługa), backup zarządzany, monitoring jako usługa, SOC/SIEM/EDR jako SaaS, CI/CD, repozytoria, utrzymanie i wsparcie systemów, drobne poprawki/aktualizacje (NIE wytworzenie nowego modułu — patrz § 720) | brak rozwinięcia w zał. nr 4 |
| **687** | Usługi pozostałe | **Tylko gdy NIE pasuje § 682/634/681/631/677/670** — np. montaż/instalacja wyposażenia łącznościowego jako samodzielna usługa (gdy nie zwiększa ceny nabycia ŚT) | **687011** Montaż sprzętu łączności; **687020** Usługi pozostałe (ostatnia deska — używaj ostrożnie) |
| **770** | Energia | Prąd, gaz (serwerownia) | — |
| **771** | Woda | Woda (serwerownia) | — |
| **778** | **Materiały i wyposażenie** | **Drobne materiały IT, akcesoria, kable, patchcordy, wyposażenie nietworzące środka trwałego** — **bez progu kwotowego** | **778005** Wyposażenie nieuznawane za ŚT; **778008** Materiały łączności; **778009** Materiały informatyki |
| 810 | Rezerwy | Rezerwy budżetowe (gdy planowane jako odrębna pozycja) | — |

## 6. Matryca paragrafów IT — wydatki MAJĄTKOWE (grupa BP 4)

| § | Nazwa | Typowe zastosowanie IT | Pozycja zał. nr 4 |
|---|---|---|---|
| **701** | **Środki trwałe amortyzowane jednorazowo** | **ŚT zakupione i amortyzowane jednorazowo wg polityki rachunkowości KG PSP** (laptop, stacja robocza, drobny serwer/sprzęt sieciowy ujmowany jako ŚT jednorazowy) | brak ogólnej pozycji IT — uzasadnij w opisie |
| **702** | **Środki trwałe** (zwykłe, amortyzowane wieloletnio) | **DOMYŚLNY § dla sprzętu IT jako ŚT:** serwery rackowe, macierze, biblioteki taśmowe, UPS centrum danych, switche, routery, firewalle (gdy ujmowane jako ŚT amortyzowany wieloletnio) | **702001** Sprzęt łączności i elektroniki (niespecjalistyczny); **702002** Sprzęt informatyczny |
| **703** | Specjalistyczny sprzęt bezpieczeństwa publicznego amortyzowany jednorazowo | **Tylko gdy spełnia definicję specjalistycznego (zadania operacyjne PSP) I amortyzowany jednorazowo** | brak rozwinięcia w zał. nr 4 |
| **704** | **Specjalistyczny sprzęt informatyczny i łączności dla bezpieczeństwa publicznego** | **Sprzęt do zadań OPERACYJNYCH PSP:** system dyspozytorski, łączność krytyczna, sprzęt zintegrowany z systemami ratowniczymi, sprzęt specjalistyczny CEZOL (gdy zadanie operacyjne, nie administracyjne) | **704001** Sprzęt informatyczny i łączności (specjalistyczny — wymaga uzasadnienia operacyjnego w opisie) |
| **711** | **WNiP amortyzowane jednorazowo** | **Licencja bezterminowa / prawo majątkowe ujmowane jako WNiP amortyzowana jednorazowo** | brak ogólnej pozycji IT |
| **712** | **WNiP** (amortyzowane wieloletnio) | **Zakup licencji bezterminowej / praw majątkowych jako WNiP** (np. zakup gotowego systemu z przeniesieniem praw) | **712001** B+R; **712002** Wdrożenia |
| **720** | **Inwestycje** | **Wytworzenie systemu, modułu, funkcjonalności jako aktywa jednostki** — prace developerskie prowadzące do wytworzenia WNiP lub zwiększenia wartości aktywa, infrastruktura tworzona od zera, projekt + analizy + programowanie + testy przedwdrożeniowe + dokumentacja powykonawcza jako koszt wytworzenia | zał. nr 4 dotyczy inwestycji budowlanych |

## 7. Załącznik nr 4 — szczegółowość bezpieczeństwa wewnętrznego (PSP)

> Art. 39 ust. 5 ufp pozwala określić klasyfikację wydatków o **większej szczegółowości** dla zadań bezpieczeństwa wewnętrznego. Załącznik nr 4 do Dz.U. 2026 poz. 582 to **załącznik PSP/Policja/SG/SOP**. W KG PSP **zawsze sprawdzaj szczegółowość** dla pozycji IT i łączności.

| Pozycja | Paragraf | Treść | Zastosowanie KG PSP |
|---|---|---|---|
| **631003** | 631 | Dzierżawa łączy/traktów/obwodów/kanalizacji teletechnicznej | Dzierżawa od OPL, dzierżawa ciemnego włókna |
| **634003** | 634 | Naprawy łączności (radiotelefony, maszty, pola antenowe, urządzenia łączności) | Serwis radia, masztów |
| **634004** | 634 | Naprawy sprzętu informatycznego | Naprawa serwerów, stacji, urządzeń sieciowych |
| **670001** | 670 | Wynagrodzenia bezosobowe — osoba fizyczna | Umowa zlecenia/dzieło z konsultantem IT |
| **687011** | 687 | Montaż/instalacja wyposażenia łącznościowego | Montaż masztów, anten, instalacja sprzętu łącznościowego jako samodzielna usługa |
| **687020** | 687 | Usługi pozostałe | OSTATNIA DESKA — używaj ostrożnie |
| **702001** | 702 | Sprzęt łączności i elektroniki (niespecjalistyczny) | Sprzęt łączności administracyjny |
| **702002** | 702 | Sprzęt informatyczny | Serwery, stacje robocze, sprzęt sieciowy administracyjny |
| **704001** | 704 | Sprzęt informatyczny i łączności specjalistyczny | Sprzęt dyspozytorski, łączność krytyczna, sprzęt zintegrowany z systemami ratowniczymi |
| **712001** | 712 | WNiP — Badania i rozwój | Licencje do prac B+R |
| **712002** | 712 | WNiP — Wdrożenia | Licencje gotowe do wdrożenia |
| **778005** | 778 | Wyposażenie nieuznawane za ŚT | Drobne wyposażenie IT nie ujmowane jako ŚT |
| **778008** | 778 | Materiały łączności | Kable, patchcordy, akcesoria łącznościowe |
| **778009** | 778 | Materiały informatyki | Kable, akcesoria informatyczne, drobne moduły |

## 8. Pułapki klasyfikacyjne 2027+ (NAJCZĘSTSZE BŁĘDY — czytaj uważnie)

### Pułapka 1: Subskrypcja roczna SaaS ≠ WNiP

**Roczna subskrypcja nie daje trwałego prawa** → zawsze **§ 682** (Usługi informatyczne), niezależnie od wartości. Tylko **licencje wieczyste / bezterminowe** z przeniesieniem praw → § 711/712.

Przykład: subskrypcja GitHub Enterprise 30 000 zł/rok → § 682 (NIE § 712).

**Test rozstrzygający:** czy po wygaśnięciu umowy jednostka **zachowuje prawo majątkowe** do oprogramowania? Jeżeli NIE → § 682. Jeżeli TAK → § 711 lub 712.

### Pułapka 2: Licencja czasowa (rok+) ≠ WNiP

Tylko licencje **bezterminowe** lub > 1 roku z opłaceniem z góry i przeniesieniem praw majątkowych → § 711/712. Licencja czasowa (np. 1-3 lata bez przeniesienia praw) → § 682.

### Pułapka 3: Drobna rozbudowa ≠ § 720 (inwestycja)

**§ 720 (Inwestycje) tylko dla:**
- Budowy nowego systemu/modułu jako aktywa jednostki,
- Istotnej modernizacji zwiększającej wartość ŚT/WNiP,
- Wytworzenia nowego modułu funkcjonalnie odrębnego.

**Drobne poprawki / aktualizacje / wsparcie / utrzymanie** → § 682 (Usługi informatyczne).

**Test:** czy efektem prac jest **odrębne aktywo lub ulepszenie istniejącego ŚT/WNiP**? Jeżeli tak → § 720. Jeżeli prace mają charakter utrzymaniowy → § 682.

### Pułapka 4: ❗ LIKWIDACJA PROGU 10 000 zł (Dz.U. 2026 poz. 582)

> **TO JEST ZMIANA RELATYWNIE DO STAREJ KLASYFIKACJI 4xxx/6xxx.** Dawny próg 10 000 zł z art. 16d CIT **NIE OBOWIĄZUJE** dla klasyfikacji budżetowej 2027+.

**Decyzja, czy zakup jest wydatkiem majątkowym czy bieżącym, należy do polityki rachunkowości jednostki**, NIE do progu kwotowego.

| Sytuacja | Klasyfikacja 2027+ |
|---|---|
| Laptop 5 000 zł, **polityka rachunkowości ujmuje jako ŚT amortyzowany jednorazowo** | **§ 701** (ŚT amort. jednorazowo) — wydatek majątkowy |
| Laptop 5 000 zł, **polityka rachunkowości ujmuje jako wyposażenie nietworzące ŚT** | **§ 778005** (Wyposażenie) — wydatek bieżący |
| Stacja robocza 15 000 zł, ujęta jako ŚT amort. wieloletnio | **§ 702** (702002) — wydatek majątkowy |
| Akcesoria, kable, drobne elementy — nie tworzą ŚT | **§ 778009** (materiały informatyki) — wydatek bieżący |

**Konsekwencja:** w planie rzeczowo-finansowym KG PSP udział wydatków majątkowych może wzrosnąć vs poprzednia klasyfikacja (nawet drobny sprzęt może iść jako § 701 jeśli polityka rachunkowości tak stanowi).

**Procedura w KG PSP:** sprawdź politykę rachunkowości KG PSP **przed** klasyfikacją. Jeśli politykę określa BIŁ/BF — uzgodnij z [[Paulina Kośka]] (BF-I).

### Pułapka 5: Hosting + drobna rozbudowa w jednej fakturze

**Rozdziel pozycje:**
- Hosting → § 682 (bieżący),
- Rozbudowa → § 720 (majątkowy) — **jeśli to istotne wytworzenie aktywa**.

Nie kwalifikuj całości jako § 682 ani jako § 720. Mieszanie B i M w jednej pozycji = błąd klasyfikacji.

### Pułapka 6: Pentest przed odbiorem vs cykliczny

| Typ pentestu | § | Charakter |
|---|---|---|
| Przed odbiorem nowego systemu (część kosztu wytworzenia) | **720** | majątkowy (wchodzi w wartość aktywa) |
| Cykliczny (rocznie / po dużej zmianie) | **677** | bieżący (ekspertyza/analiza) |

### Pułapka 7: § 4000 nadal placeholder w plikach XLSX wzorcowych

Plik XLSX wzorcowy `Propozycja zadań do POLiOC 2027-2031 cz.42.xlsx` w kolumnie paragrafu używa `4000` jako **placeholder dla starej klasyfikacji**. Od 2027+ ten placeholder jest **nieaktualny**.

**Zastąp `4000` szczegółowym paragrafem 3-cyfrowym** z matrycy w §5/§6:
- usługi → 682
- materiały → 778
- ekspertyzy → 677
- telekom → 681
- dzierżawa → 631
- ŚT → 701/702/704
- WNiP → 711/712
- wytworzenie → 720

### Pułapka 8: ❗ Sprzęt 704 vs 702 — uzasadnij operacyjność

**§ 704 (Specjalistyczny sprzęt bezpieczeństwa publicznego)** jest zarezerwowany dla sprzętu **do zadań OPERACYJNYCH PSP** (dyspozytorski, łączność krytyczna, sprzęt zintegrowany z systemami ratowniczymi). **NIE używaj § 704 dla sprzętu administracyjnego** (serwery aplikacyjne, stacje robocze biurowe, sprzęt sieciowy) — to § 702.

**Test:** czy sprzęt jest niezbędny do **operacji ratowniczych/bezpieczeństwa publicznego** w czasie zdarzenia? Jeżeli tak → § 704 z **wyraźnym uzasadnieniem operacyjnym** w opisie pozycji.

> **Walidator skilla wymaga: jeśli pozycja ma paragraf 704, sekcja uzasadnienia musi zawierać frazy `"zadanie operacyjne"` / `"sprzęt specjalistyczny"` / `"dyspozytorski"` / `"łączność krytyczna"`.** Brak uzasadnienia → exit 1.

BIŁ KG PSP ostrzega wprost: *„Serwer administracyjny ujęty w 704001 bez uzasadnienia operacyjnego"* — to typowy błąd kontrolny.

### Pułapka 9: Subskrypcje chmurowe (cloud, SaaS, IaaS, PaaS)

**Test rozstrzygający:** czy jednostka kupuje **dostęp do usługi/zasobu** (czas trwania umowy = czas dostępu)? Jeżeli tak → **§ 682** (Usługi informatyczne).

Przykłady kwalifikowane do § 682:
- subskrypcja Microsoft 365, Google Workspace, Jira/Atlassian,
- usługa GitHub/GitLab Enterprise,
- usługa repozytorium kodu i CI/CD,
- usługa backupu chmurowego,
- moc obliczeniowa AWS/Azure/GCP (compute, storage, bazy danych, kontenery, PaaS),
- usługi cyberbezpieczeństwa SaaS/SOC/SIEM/EDR/XDR,
- utrzymanie i wsparcie systemów (drobne poprawki, aktualizacje).

## 9. Matryca skrócona: katalog Cz. II → paragrafy 2027+

> **Uwaga o spójności:** skrócona matryca w `SKILL.md` (faza F4) jest derywatem §5/§6/§7 tego pliku. Przy aktualizacji paragrafów lub progów (np. zmiana art. 16d CIT, nowe rozporządzenie klasyfikacji wydatków) **zaktualizuj oba miejsca jednocześnie**. W razie rozbieżności **ten plik jest źródłem prawdy**.

| Sekcja katalogu (Cz. II) | Dominujący § | Wyjątki |
|---|---|---|
| A. Środowiska systemu | **682** (gdy hosting/PaaS) | 720 gdy budowa środowiska od zera |
| B. Infrastruktura i hosting | **682** | 720 wytworzenie środowiska od zera; 702 serwery jako ŚT; 701 ŚT amort. jednorazowo |
| C. Łączność i sieć | **681** Internet/telekom; **631003** dzierżawa łączy | 682 dla domen/DNS jako usługi; 702/704 sprzęt sieciowy jako ŚT (704 tylko z uzasadnieniem operacyjnym) |
| D. Bezpieczeństwo systemu | **682** (usługi SOC/SIEM/EDR SaaS) | **677** pentest/audyt cykliczny; **712** HSM jako WNiP; **702** EDR sprzęt; 720 SIEM/SOC tworzony od zera |
| E. Monitoring | **682** | 720 wdrożenie własnego monitoringu od zera; 702 sprzęt monitoringu |
| F. Service desk | **682** | **670** konsultanci osoba fizyczna; **638** szkolenia operatorów |
| G. Dane, mapy, API | **682** | wszystkie subskrypcje SaaS |
| H. Narzędzia wytwórcze | **682** | **712** licencje wieczyste (B+R: 712001, wdrożenia: 712002); 711 jeśli amort. jednorazowo |
| I. Testy i jakość | **682** | **677** zewn. testy/audyty; 720 testy przedwdrożeniowe (koszt wytworzenia) |
| J. Dokumentacja, zgodność | **677** ekspertyzy / **682** dokumentacja bieżąca | 670 konsultanci osoby fizyczne |
| K. Konta i uprawnienia | **682** | |
| L. Zespół | uposażenia (kadra mundurowa: 239/240/618 — poza skillem IT) / **670** umowy zlecenia osób fizycznych / **682** firma zewn. utrzymaniowa | **720** programiści wytwarzający nowy system |
| M. Sprzęt pomocniczy | **778** materiały < polityki ŚT / **701** ŚT amort. jednorazowo / **702** ŚT zwykłe / **704** specjalistyczny (z uzasadnieniem operacyjnym) | **770** energia |
| N. Szkolenia | **638** szkolenia zewnętrzne | 720 pilotaż przed odbiorem |
| O. Rezerwy | macierzysty § (najczęściej 682) lub **810** | |

## 10. Klucz przejścia — stara klasyfikacja → nowa (pomocniczo)

> **Tylko jako referencja interpretacyjna dla danych historycznych.** Nowe plany (2027+) używają **wyłącznie nowej klasyfikacji**. Klucz pomaga zrozumieć, w jaki paragraf 2027+ idzie pozycja, która historycznie była w paragrafie 4xxx/6xxx.

| Stary § (do 2026) | Nowy § (od 2027) | Komentarz |
|---|---|---|
| 4170 (wynagrodzenia bezosobowe) | **670** (670001) | Umowy zlecenia/dzieło osób fizycznych |
| 4210 (materiały i wyposażenie) | **778** (778005/008/009) **lub 701** | Próg 10k zlikwidowany — decyduje polityka rachunkowości |
| 4260 (energia) | **770** (energia) lub **771** (woda) | Rozdzielone |
| 4270 (usługi remontowe) | **627** (remonty) lub **634** (naprawy/konserwacja) | |
| 4300 (zakup usług pozostałych) | **682** (usługi IT) / **687** (pozostałe) / **631** (dzierżawa) / **677** (ekspertyzy) | Paragraf resztowy rozbity |
| 4350 (Internet) | **681** | Scalone z telekom |
| 4360 (telekom) | **681** lub **631003** (dzierżawa) | |
| 4390 (ekspertyzy/analizy/opinie) | **677** | Bez zmian merytorycznych |
| 4700 (szkolenia NIE SC) | **638** | |
| 4810 (rezerwy) | **810** | Numeracja zmieniona |
| 6050 (wydatki inwestycyjne JB — wytworzenie) | **720** | Inwestycje |
| 6060 (wydatki na zakupy inwestycyjne JB) | **702** (ŚT zwykłe) / **701** (ŚT amort. jednorazowo) / **712** (WNiP) / **711** (WNiP jednorazowo) / **704** (specjalistyczny — z uzasadnieniem operacyjnym) | Rozbite na 4 paragrafy + bez progu 10k |

**Pełne klucze przejścia MF:** [https://www.gov.pl/web/finanse/klasyfikacja-szczegolowa-od-planowania-na-2027r](https://www.gov.pl/web/finanse/klasyfikacja-szczegolowa-od-planowania-na-2027r) (pliki `Klucze przejścia wydatki.docx` i `Klucze przejścia.xlsx`).

## 11. Pełna ścieżka klasyfikacyjna — przykład end-to-end

> Zakup rocznej subskrypcji Google Maps API (1 500 USD/rok) na potrzeby warstwy jawnej CEOZO „Gdzie się ukryć", finansowany z POLiOC cz. 42.

| Element | Wartość |
|---|---|
| Tryb | **A — POLiOC cz. 42 (środki obronne)** |
| Część | **42 — Sprawy wewnętrzne (MSWiA)** (ewent. uruchomione z 83 → 42) |
| Dział | **752 — Obrona narodowa** |
| Rozdział | **75282 — Zadania obronne PSP** |
| Paragraf 3-cyfrowy | **§ 682 — Usługi informatyczne** (subskrypcja roczna SaaS, NIE WNiP — § 711/712) |
| Czwarta cyfra (źródło) | **0** (środki krajowe POLiOC) → pełny kod `6820` |
| Pozycja zał. nr 4 | brak rozwinięcia dla § 682 |
| Grupa wydatków BP | **3** (wydatki bieżące) |
| Typ wydatku | **bieżący (B)** |
| Kwota netto USD | 1 500 USD |
| Kurs planistyczny | NBP, np. 4,00 PLN/USD z 2026-05-25 |
| Netto PLN | 1 500 × 4,00 = 6 000 PLN |
| VAT (RC, import usług) | 23% (samonaliczenie) |
| **Brutto PLN** | **6 000 × 1,23 = 7 380 PLN brutto/rok** |
| + Rezerwa kursowa 15% | 7 380 × 1,15 ≈ 8 487 PLN (planowanie konserwatywne) |

## 12. Szybkie reguły decyzyjne (cheatsheet BIŁ)

| Jeśli to… | Sprawdź paragraf | Pozycja zał. nr 4 |
|---|---|---|
| utrzymanie / aktualizacja systemu | **682** | — |
| naprawa sprzętu informatycznego | **634004** | 634004 |
| naprawa sprzętu łączności / masztów / anten | **634003** | 634003 |
| dzierżawa łącza lub traktu | **631003** | 631003 |
| usługa telekomunikacyjna (Internet, transmisja, telefonia) | **681** | — |
| serwer lub sprzęt IT jako ŚT | **702002** | 702002 |
| **specjalistyczny sprzęt IT/łączności dla zadań operacyjnych** | **704001** | 704001 — **WYMAGA uzasadnienia operacyjnego** |
| drobne materiały IT / łączności | **778009 / 778008** | 778009 / 778008 |
| licencja / subskrypcja czasowa bez nabycia prawa | **682** | — |
| gotowa WNiP (licencja bezterminowa) | **711** (amort. jednorazowo) lub **712** (wieloletnio) | 712001 B+R, 712002 wdrożenia |
| wytworzenie systemu / modułu jako aktywa | **720** | — |
| ekspertyza / analiza / audyt (gdy nie inwestycja) | **677** | — |
| umowa zlecenia / dzieło osoba fizyczna | **670001** | 670001 |
| szkolenie zewnętrzne | **638** | — |
| montaż / instalacja samodzielna sprzętu łącznościowego | **687011** | 687011 |
