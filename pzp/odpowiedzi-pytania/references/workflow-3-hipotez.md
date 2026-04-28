# Metodyka analizy 3 hipotez per obszar pytania

Szczegółowa metodyka analizy w modelu trzech hipotez, używana w Phase 3 skilla `odpowiedzi-pytania`. Dokument referencyjny — czytaj przy pytaniach niestandardowych.

## Schemat ogólny

Dla każdego pytania:

```
H1 — odpowiedź NEGATYWNA, bez zmiany dokumentacji
   → "Zamawiający nie dopuszcza" / "Zamawiający podtrzymuje zapisy"

H2 — odpowiedź POZYTYWNA, ze zmianą dokumentacji
   → "Zamawiający dopuszcza X" / "Zamawiający dokonuje zmiany"

H3 — odpowiedź KOMPROMISOWA, dopuszczająca warunkowo lub przez doprecyzowanie
   → "Zamawiający dopuszcza X pod warunkiem Y" / "Zamawiający doprecyzowuje OPZ"
```

Dla każdej hipotezy oceń:

1. **Skutki prawne** — zgodność z ustawą Pzp, regulaminem KG PSP, wcześniejszymi odpowiedziami.
2. **Skutki dla konkurencyjności** — czy zawęża / rozszerza krąg wykonawców.
3. **Skutki dla spójności dokumentacji** — czy wymaga zmian w SWZ/OPZ/umowie/ogłoszeniu.
4. **Ryzyko odwoławcze** — prawdopodobieństwo skutecznego odwołania do KIO (niskie / średnie / wysokie).
5. **Wpływ na termin składania ofert** — czy wymusza przedłużenie.
6. **Wymóg zmiany dokumentacji** — TAK/NIE + co.

## Reguła wyboru rekomendacji

```
Preferuj kolejno (malejąco):
1. zabezpiecza interes Zamawiającego
2. zwiększa lub utrzymuje konkurencyjność
3. nie obniża istotnych wymagań jakościowych / bezpieczeństwa / funkcjonalnych
4. spójność z dotychczasową dokumentacją
5. minimalizacja ryzyka odwoławczego
6. brak niekontrolowanej zmiany charakteru zamówienia

Konflikt (1) ↔ (2): preferuj (1).
Konflikt (1) ↔ (3): preferuj (3) — bezpieczeństwo / jakość / funkcjonalność > krótkoterminowy interes.
Konflikt (4) ↔ (5): preferuj (5) — spójność można naprawić, ryzyka odwoławczego nie.
```

---

## Per obszar pytania

### Obszar: `OPZ-parametr` (parametr techniczny)

**Pytanie typowe:** „Czy Zamawiający dopuszcza zaoferowanie procesora Intel Xeon Gold 6442Y zamiast AMD EPYC 9554?"

#### H1 — Nie dopuszcza, OPZ bez zmian

- **Skutki prawne:** zgodne z ustawą Pzp, jeśli parametr jest minimalnym wymaganiem uzasadnionym przedmiotem zamówienia.
- **Skutki dla konkurencyjności:** wąskie. Może zawęzić krąg wykonawców do jednego producenta.
- **Spójność dokumentacji:** bez zmian.
- **Ryzyko odwoławcze:** **wysokie**, jeśli parametr odpowiada wyłącznie konkretnemu producentowi (art. 99 ust. 4 Pzp — niedopuszczalność ograniczeń konkurencji bez uzasadnienia).
- **Termin:** bez zmian.
- **Zmiana dokumentacji:** brak.

#### H2 — Dopuszcza, OPZ ze zmianą

- **Skutki prawne:** dopuszczalne, jeśli zachowane parametry minimalne i nie obniża to celu zamówienia.
- **Skutki dla konkurencyjności:** rozszerza krąg wykonawców.
- **Spójność dokumentacji:** zmiana OPZ (wymagane parametry → kryteria równoważności).
- **Ryzyko odwoławcze:** średnie — odwołanie może wnieść inny wykonawca, jeśli alternatywa nie jest faktycznie równoważna.
- **Termin:** **prawdopodobnie wymaga przedłużenia** (art. 137 ust. 6 / art. 286 ust. 3).
- **Zmiana dokumentacji:** OPZ pkt […] — wprowadzenie kryteriów równoważności.

#### H3 — Dopuszcza warunkowo, doprecyzowanie OPZ

- **Skutki prawne:** najbezpieczniejsze. Dopuszczenie z konkretnymi kryteriami minimalnymi.
- **Skutki dla konkurencyjności:** rozszerza krąg, ale w granicach kontrolowanych.
- **Spójność dokumentacji:** zmiana OPZ z katalogiem kryteriów równoważności.
- **Ryzyko odwoławcze:** niskie.
- **Termin:** może wymagać przedłużenia, jeśli zmiana istotna.
- **Zmiana dokumentacji:** OPZ — wyodrębniony pkt z kryteriami.

**Default rekomendacja:** **H3** (jeśli alternatywa rzeczywiście może być równoważna) lub **H1** (jeśli parametr jest niezbędny ze względu na bezpieczeństwo/integralność/SLA).

---

### Obszar: `OPZ-rownowaznosc` (równoważność)

**Pytanie typowe:** „Czy Zamawiający dopuszcza rozwiązanie równoważne dla oprogramowania Microsoft SQL Server wskazanego w pkt B.3 OPZ?"

#### H1 — Nie dopuszcza

- **Skutki prawne:** **wysokie ryzyko niezgodności z art. 99 ust. 5–6 Pzp.** Jeśli OPZ powołuje znak towarowy bez uzasadnienia → wadliwe SWZ.
- **Skutki dla konkurencyjności:** zawęża drastycznie.
- **Ryzyko odwoławcze:** **bardzo wysokie**.

#### H2 — Dopuszcza ogólnie

- **Skutki prawne:** zgodne z art. 99 ust. 6 Pzp.
- **Spójność dokumentacji:** OPZ wymaga doprecyzowania kryteriów równoważności.
- **Ryzyko odwoławcze:** średnie — brak kryteriów = ryzyko niejednoznaczności.

#### H3 — Dopuszcza z katalogiem kryteriów równoważności

- **Skutki prawne:** **najwłaściwsze.** Art. 99 ust. 6 wymaga opisu kryteriów.
- **Spójność dokumentacji:** zmiana OPZ — dodanie katalogu kryteriów (np. funkcjonalność, kompatybilność z istniejącymi systemami, wsparcie producenta, certyfikacja, parametry wydajnościowe).
- **Ryzyko odwoławcze:** niskie.

**Default rekomendacja:** **H3 (zawsze).** Brak dopuszczenia równoważności = ryzyko unieważnienia postępowania przez KIO.

> [!important] Reguła Iron Law dla równoważności:
> Skill nie ma prawa wytworzyć odpowiedzi „Zamawiający nie dopuszcza rozwiązań równoważnych", chyba że jest to obiektywnie uzasadnione charakterem zamówienia i prawidłowo opisane (np. interoperacyjność z konkretnym systemem certyfikowanym). W razie wątpliwości — eskalacja do `wymaga konsultacji prawnej`.

---

### Obszar: `umowa-PPU` (projektowane postanowienia umowy)

**Pytanie typowe:** „Wnoszę o zmniejszenie kary umownej z 1% do 0,1% wartości netto za każdy dzień zwłoki."

#### H1 — Nie dopuszcza, umowa bez zmian

- **Skutki prawne:** sprawdź art. 433 pkt 2 Pzp — zakaz nieproporcjonalnych kar. Jeśli kara jest proporcjonalna do wartości i ryzyka — H1 OK.
- **Spójność dokumentacji:** bez zmian.
- **Ryzyko odwoławcze:** zależne od proporcjonalności. 1% za dzień przy zamówieniu wieloletnim może być oceniane jako nieproporcjonalne.

#### H2 — Dopuszcza zmianę

- **Skutki prawne:** OK, jeśli nowa wysokość zachowuje funkcję zabezpieczającą.
- **Spójność dokumentacji:** zmiana § projektu umowy.
- **Ryzyko odwoławcze:** niskie, jeśli zmiana jest racjonalna.

#### H3 — Kompromis (np. zróżnicowane stawki za różne typy zwłoki)

- **Skutki prawne:** OK.
- **Spójność dokumentacji:** doprecyzowanie § umowy z rozdzieleniem stawek (np. zwłoka w dostawie 0,5%, zwłoka w odbiorze 0,2%, niezgodność jakościowa 0,1%).

**Default rekomendacja:** **H2 lub H3**, jeśli kara jest faktycznie nieproporcjonalna. **H1**, jeśli wykonawca po prostu próbuje obniżyć ryzyko.

**Klauzule krytyczne (sprawdź zawsze):**
- art. 433 pkt 1 — termin zapłaty max 30 dni
- art. 433 pkt 2 — proporcjonalność kar
- art. 436 — obligatoryjne elementy umowy
- art. 439 — waloryzacja (umowy > 6 m-cy)
- art. 454–455 — możliwość zmiany umowy

---

### Obszar: `kryteria-oceny` (kryteria oceny ofert)

**Pytanie typowe:** „Czy kryterium 'doświadczenie kierownika projektu' można zmienić na 'liczba realizacji projektów IT z 3 ostatnich lat'?"

#### H1 — Nie dopuszcza

- **Skutki prawne:** OK po wszczęciu postępowania.
- **Spójność dokumentacji:** bez zmian.
- **Ryzyko odwoławcze:** średnie — wykonawca może odwołać się od kryterium, jeśli jest nieproporcjonalne lub nieobiektywne (art. 241 Pzp).

#### H2 — Dopuszcza

- **Skutki prawne:** zmiana SWZ z wpływem na kryteria oceny → zmiana ogłoszenia (art. 137 ust. 6).
- **Spójność dokumentacji:** SWZ + ogłoszenie + przedłużenie terminu.
- **Ryzyko odwoławcze:** zależne od stopnia zmiany.

#### H3 — Doprecyzowanie kryterium

- **Skutki prawne:** możliwe bez pełnej zmiany.
- **Spójność dokumentacji:** drobna zmiana SWZ.

**Default rekomendacja:** **H1**. Kryteria oceny zmienia się **wyjątkowo i bardzo ostrożnie**. Każda zmiana = zmiana ogłoszenia + przedłużenie terminu. Eskalacja do `wymaga decyzji Zamawiającego`.

---

### Obszar: `warunki-udzialu` (warunki udziału w postępowaniu)

**Pytanie typowe:** „Czy Zamawiający dopuszcza wykazanie się jednym wdrożeniem zamiast dwoma?"

#### H1 — Nie dopuszcza

- **Skutki prawne:** OK, jeśli warunek jest proporcjonalny (art. 112 ust. 1 Pzp).
- **Ryzyko odwoławcze:** zależne od proporcjonalności. Wymóg „co najmniej 5 wdrożeń o wartości 50 mln" przy zamówieniu 1 mln = nieproporcjonalny.

#### H2 — Dopuszcza złagodzenie

- **Skutki prawne:** zmiana SWZ.
- **Spójność dokumentacji:** SWZ + ogłoszenie + przedłużenie terminu.

#### H3 — Doprecyzowanie warunku (np. dopuszczenie zsumowania doświadczenia konsorcjantów)

- **Skutki prawne:** OK.
- **Spójność dokumentacji:** drobna zmiana SWZ.

**Default rekomendacja:** **H1**, jeśli warunek jest proporcjonalny. **H2/H3**, jeśli wykonawca uzasadnia nieproporcjonalność.

---

### Obszar: `przedmiotowe-sd` (przedmiotowe środki dowodowe)

**Pytanie typowe:** „Czy Zamawiający dopuszcza złożenie próbki w terminie późniejszym niż termin składania ofert?"

#### H1 — Nie dopuszcza (próbka z ofertą)

- **Skutki prawne:** OK, jeśli SWZ tak stanowi i ś.d. dotyczy kryteriów oceny ofert (art. 107 ust. 3 Pzp — wykluczenie uzupełniania).
- **Ryzyko odwoławcze:** niskie.

#### H2 — Dopuszcza uzupełnienie

- **Skutki prawne:** TYLKO jeśli SWZ przewiduje uzupełnianie (art. 107 ust. 2 Pzp) i ś.d. NIE służy kryteriom oceny.
- **Spójność dokumentacji:** zmiana SWZ.

#### H3 — Doprecyzowanie (różne ś.d., różne terminy)

- **Skutki prawne:** OK.

**Default rekomendacja:** **H1**, jeśli ś.d. dotyczy kryteriów oceny. **H2**, jeśli SWZ przewiduje uzupełnianie w art. 107 ust. 2 i ś.d. NIE służy kryterium.

---

### Obszar: `podmiotowe-sd` (podmiotowe środki dowodowe)

**Pytanie typowe:** „Czy oświadczenie podpisane podpisem zaufanym jest równoważne podpisowi elektronicznemu kwalifikowanemu?"

#### H1 — Nie dopuszcza

- **Skutki prawne:** sprawdź wymogi SWZ + art. 63 Pzp.
- **Ryzyko odwoławcze:** zależne.

#### H2 — Dopuszcza

- **Skutki prawne:** dla postępowań ≥ progi unijne — wymagany kwalifikowany podpis elektroniczny (art. 63 ust. 1 Pzp). Podpis zaufany niedopuszczalny dla ofert.
- **Skutki:** dla < progi unijne — można dopuścić podpis zaufany lub osobisty (art. 63 ust. 2).

#### H3 — Doprecyzowanie

- **Skutki prawne:** OK po sprawdzeniu progu.

**Default rekomendacja:** zależnie od progu. Powyżej progów unijnych — H1 (kwalifikowany podpis elektroniczny obligatoryjny).

---

### Obszar: `wykluczenie` (podstawy wykluczenia)

**Pytanie typowe:** „Czy spółka, której wspólnik jest objęty sankcjami, podlega wykluczeniu?"

#### H1, H2, H3 — analiza identyczna

- **Skutki prawne:** sprawdź art. 5k rozporządzenia 833/2014, art. 7 ust. 1 ustawy z dnia 13 kwietnia 2022 r. o szczególnych rozwiązaniach w zakresie przeciwdziałania wspieraniu agresji na Ukrainę.
- **Ryzyko odwoławcze:** wysokie, jeśli niewłaściwa interpretacja.

**Default rekomendacja:** **eskalacja** do `wymaga konsultacji prawnej`. Sankcje międzynarodowe wymagają indywidualnej oceny.

---

### Obszar: `termin-skladania` (termin składania ofert)

**Pytanie typowe:** „Wnoszę o przedłużenie terminu składania ofert o 14 dni."

#### H1 — Nie przedłuża

- **Skutki prawne:** OK, jeśli aktualny termin spełnia minimum ustawowe (art. 132 / art. 283).
- **Skutki dla konkurencyjności:** może zawęzić (krótki termin = mniej wykonawców).
- **Ryzyko odwoławcze:** średnie, jeśli zmiany SWZ uzasadniają przedłużenie.

#### H2 — Przedłuża zgodnie z wnioskiem

- **Skutki prawne:** OK.
- **Spójność dokumentacji:** SWZ + ogłoszenie.

#### H3 — Częściowe przedłużenie (np. 7 dni zamiast 14)

- **Skutki prawne:** OK.

**Default rekomendacja:** zależnie od:
- Czy są pytania w obecnej turze, które wymagają zmiany SWZ → **H2 lub H3**.
- Czy zmiany istotnie modyfikują warunki → **H2** (obligatoryjne przedłużenie o czas niezbędny — art. 137 ust. 6 / art. 286 ust. 3; ustawa nie określa minimum dni, w praktyce KIO 6–14 dni dla zmian istotnych).
- Czy nie ma istotnych zmian → **H1** lub **H3** krótszy.

---

### Obszar: `termin-realizacji` (termin wykonania zamówienia)

**Pytanie typowe:** „Wnoszę o przedłużenie terminu realizacji z 90 do 120 dni."

#### H1 — Nie przedłuża

- **Skutki prawne:** OK, jeśli termin jest wykonalny.
- **Skutki:** może zawęzić krąg wykonawców.

#### H2 — Przedłuża

- **Skutki prawne:** OK.
- **Spójność dokumentacji:** § umowy + SWZ.
- **Skutki finansowania:** sprawdź czy zmiana mieści się w zaangażowaniu budżetowym.

#### H3 — Etapowanie (terminy częściowe)

- **Skutki prawne:** OK.
- **Spójność dokumentacji:** umowa + harmonogram.

**Default rekomendacja:** **H2 lub H3**, jeśli wykonawcy uzasadniają nierealność terminu (np. czas dostawy komponentów). **H1**, jeśli termin jest wynikiem przepisów (np. dofinansowanie z UE z konkretną datą).

---

### Obszar: `odbiory-SLA` (odbiory, SLA, gwarancje)

**Pytanie typowe:** „Czy Zamawiający dopuszcza odbiór etapowy zamiast jednego końcowego?"

#### H1, H2, H3 — analiza zależna od projektu umowy

- **Skutki prawne:** OK po sprawdzeniu spójności z projektem umowy.
- **Ryzyko odwoławcze:** zależne od wpływu na cenę / harmonogram.

**Default rekomendacja:** **eskalacja** do `wymaga konsultacji technicznej` (technicznie kompetentna osoba musi ocenić wpływ na realizację).

---

### Obszar: `licencje` (licencje, prawa autorskie)

**Pytanie typowe:** „Czy Zamawiający dopuszcza licencję 'per server' zamiast wymaganej 'per core'?"

#### H1, H2, H3

- **Skutki prawne:** OK po sprawdzeniu modelu licencyjnego producenta.
- **Skutki:** wpływa na wartość zamówienia + koszt utrzymania.

**Default rekomendacja:** **eskalacja** do `wymaga konsultacji technicznej`.

---

### Obszar: `integracja` (integracja z istniejącymi systemami)

**Pytanie typowe:** „Czy Zamawiający dopuszcza brak integracji z systemem EZD?"

**Default rekomendacja:** **eskalacja** do `wymaga konsultacji technicznej`. Integracja zwykle jest wymaganiem niezbędnym (art. 99 ust. 1 — zrozumiały sposób; opisany cel).

---

### Obszar: `cyber-KSC` (cyberbezpieczeństwo, KSC)

**Pytanie typowe:** „Czy Zamawiający wymaga zgodności z NIS2 / KSC?"

**Default rekomendacja:** **eskalacja** do `wymaga konsultacji prawnej + technicznej`. Cyberbezpieczeństwo to obszar regulowany (ustawa o krajowym systemie cyberbezpieczeństwa, Dz.U. 2026 poz. 20). Każda odpowiedź musi być spójna z wymaganiami SWZ + przepisami branżowymi.

---

## Macierz decyzyjna „pozytywna / kompromisowa / negatywna"

| Sytuacja | Domyślnie |
| --- | --- |
| Pytanie o równoważność rozwiązania (znak towarowy w OPZ) | **H3 (kompromis z kryteriami)** |
| Pytanie o normę z dopuszczeniem „lub równoważnej" | **H2 (dopuszczenie)** |
| Pytanie o termin realizacji (uzasadnienie nierealności) | **H2 lub H3 (przedłużenie)** |
| Pytanie o termin składania ofert (bez zmiany SWZ) | **H1 (bez przedłużenia)** lub **H3** |
| Pytanie o termin składania ofert (przy zmianach SWZ) | **H2 (przedłużenie)** |
| Pytanie o złagodzenie warunku udziału (proporcjonalny) | **H1 (podtrzymanie)** |
| Pytanie o złagodzenie warunku udziału (nieproporcjonalny) | **H2 lub H3** |
| Pytanie o zmniejszenie kary umownej (proporcjonalna) | **H1 (podtrzymanie)** |
| Pytanie o zmniejszenie kary umownej (nieproporcjonalna) | **H2 (zmiana)** |
| Pytanie o uzupełnianie ś.d. przedmiotowych | **art. 107 ust. 2/3 — zależnie od kryteriów oceny** |
| Pytanie o uzupełnianie ś.d. podmiotowych | **art. 128 ust. 1/3 — zależnie od selekcji** |
| Pytanie o sankcje międzynarodowe | **eskalacja: konsultacja prawna** |
| Pytanie o cyberbezpieczeństwo / KSC | **eskalacja: konsultacja prawna + techniczna** |
| Pytanie o integrację | **eskalacja: konsultacja techniczna** |
| Pytanie o licencjonowanie | **eskalacja: konsultacja techniczna** |
| Pytanie sprzeczne z wcześniejszą odpowiedzią | **sprostowanie + ujednolicenie** |
| Pytanie nieproceduralne (poza art. 135 / 284) | **eskalacja: nie odpowiadać w trybie wyjaśnień** |

## Powtarzalne pułapki

1. **H2 bez wskazania kryteriów równoważności** — bardzo częsty błąd. Rozwiązanie: zawsze dodaj kryteria do OPZ.
2. **H3 z warunkami niemierzalnymi** — „pod warunkiem zachowania jakości". Rozwiązanie: konkrety mierzalne (parametr ≥ X, IOPS ≥ Y).
3. **H1 z uzasadnieniem „bo tak"** — odpowiedź odmowna bez uzasadnienia normatywnego = ryzyko odwoławcze. Rozwiązanie: zawsze odesłanie do art. Pzp + uzasadnienie z proporcjonalności / przejrzystości.
4. **Ignorowanie skutku dla terminu składania ofert** — zmiana SWZ często wymaga przedłużenia. Rozwiązanie: w `04_zmiany_dokumentacji.md` zawsze pole „Wpływ na termin".
5. **Brak sprawdzenia wcześniejszych odpowiedzi** — sprzeczność = błąd proceduralny. Rozwiązanie: w Phase 0 obowiązkowe `ls <folder_pzp>` + wczytanie poprzednich tur Q&A.
6. **Eskalacja do `wymaga decyzji Zamawiającego` bez wskazania konkretnej decyzji** — w `06_wersja_do_akceptacji.md` opis decyzji musi być konkretny: „Czy Zamawiający dopuszcza skrócenie terminu realizacji do 75 dni? Skutek: zmiana § 2 umowy + termin składania ofert bez zmian (zmiana nie wpływa na krąg wykonawców)."
