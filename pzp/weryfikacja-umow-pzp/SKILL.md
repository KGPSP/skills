---
name: weryfikacja-umow-pzp
version: v1.0.0
description: Use when verifying draft contracts (projekt umowy / wzór umowy / PPU — projektowane postanowienia umowy) in Polish public procurement (PZP) before signing. Triggers include weryfikacja projektu umowy PZP, analiza wzoru umowy, audyt umowy przed podpisaniem, sprawdzenie PPU, korelacja umowy z SWZ/OPZ/ofertą, ocena postanowień umownych w reżimie zamówień publicznych, and whenever the user supplies a projekt umowy + folder z dokumentacją postępowania (SWZ, OPZ, oferta, pisma z odpowiedziami, harmonogram, załączniki). Produces a detailed report with explicit original-quote + proposed-new-wording pairs for each recommended correction.
---

# Weryfikacja projektu umowy w reżimie PZP (kontrola przed podpisaniem)

## Overview

Systematyczny workflow pogłębionej analizy projektu umowy (lub projektowanych postanowień umowy — PPU) w postępowaniu PZP z perspektywy zamawiającego publicznego. Skill wytwarza **serię dokumentów analitycznych w Obsidian Flavored Markdown**, których centralnym produktem jest `05-proponowane-poprawki-<slug-sprawy>.md` — **dla każdej wykrytej wady: cytat obecnego brzmienia + cytat proponowanego brzmienia + uzasadnienie prawne/operacyjne**.

**Core principle:** Każde ustalenie ma podstawę w konkretnej jednostce redakcyjnej projektu umowy (§ / ust. / pkt / lit. / załącznik) i konkretnym dokumencie postępowania. Nie „wydaje się", nie „prawdopodobnie". Albo cytat + wniosek, albo „nie można potwierdzić na podstawie przekazanych dokumentów". Wszystkie modyfikacje SWZ / odpowiedzi na pytania są **nadrzędne** wobec pierwotnego brzmienia SWZ i OPZ w zakresie objętym zmianą; to samo dotyczy projektu umowy — wersja po modyfikacjach jest wiążąca.

**This is a technique skill.** Stosuj fazy kolejno — nie wolno pominąć Phase 1 (indeksacja). Bez audit trail analiza nie ma wartości przy kontroli / sporze / odwołaniu do KIO.

> [!important] Aktualna podstawa prawna (stan na 2026-04-22)
> - **Ustawa Pzp:** ustawa z dnia 11 września 2019 r. — Prawo zamówień publicznych; **tekst jednolity: Dz.U. 2024 poz. 1320** z nowelizacjami: 2025 r. poz. 620, 769, 794, 1165, 1173, **1235**; 2026 r. poz. 252.
> - **Autorytatywny tekst ustawy w repo KG PSP:** [[D20192019Lj]] (11 516 linii, 632 artykuły) — wszystkie cytaty art. Pzp w raportach MUSZĄ być weryfikowane literalnie przeciwko temu plikowi.
> - **Nowelizacja 12.07.2026 r.** (Dz.U. 2025 poz. 1235) — certyfikacja wykonawców (art. 128a, 124 ust. 2-4, 273 ust. 2). Dla postępowań wszczętych przed 12.07.2026 — przepisy dotychczasowe.
> - **Postanowienia umowne — kluczowe artykuły Pzp:** art. 431–465 Pzp (dział VII — umowa w sprawie zamówienia publicznego). **Poniżej opisy skrótowe — zawsze przed cytowaniem w raporcie zweryfikuj literalnie w [[D20192019Lj]]**:
>   - **art. 432** — forma umowy (pisemna pod rygorem nieważności, chyba że odrębne przepisy stanowią inaczej),
>   - **art. 433** — katalog klauzul niedopuszczalnych w „Projektowanych postanowieniach umowy" — **pkt 1** odpowiedzialność wykonawcy za opóźnienie „chyba że jest to uzasadnione okolicznościami lub zakresem zamówienia"; **pkt 2** naliczanie kar umownych za zachowanie wykonawcy niezwiązane bezpośrednio lub pośrednio z przedmiotem umowy / jej prawidłowym wykonaniem; **pkt 3** odpowiedzialność wykonawcy za okoliczności, za które wyłączną odpowiedzialność ponosi zamawiający; **pkt 4** możliwość ograniczenia zakresu zamówienia przez zamawiającego bez wskazania minimalnej wartości/wielkości świadczenia stron,
>   - **art. 434** — umowę zawiera się na czas oznaczony; dłuższy niż 4 lata tylko dla świadczeń powtarzających się / ciągłych przy uzasadnieniu (oszczędności / zdolności płatnicze / nakłady i okres spłaty),
>   - **art. 435** — wyjątki dopuszczające czas nieoznaczony: dostawy wody, gazu, ciepła z sieci, licencji na oprogramowanie, usługi przesyłowe/dystrybucyjne energii/gazu,
>   - **art. 436** — **obligatoryjne postanowienia umowy (4 pkt, nie 7)**: pkt 1 planowany termin zakończenia usługi/dostawy/RB; pkt 2 warunki zapłaty wynagrodzenia; pkt 3 **łączna maksymalna wysokość kar umownych, których mogą dochodzić strony**; pkt 4 dla umów > 12 m-cy: a) kary umowne wykonawcy z tytułu braku / nieterminowej zapłaty wynagrodzenia podwykonawcom z art. 439 ust. 5, b) tzw. „mała klauzula waloryzacyjna" dla zmiany VAT / płacy minimalnej / ZUS / PPK,
>   - **art. 437** — **obligatoryjne postanowienia umowy O ROBOTY BUDOWLANE dotyczące podwykonawstwa** (7 pkt: obowiązek przedkładania projektu umowy o podwykonawstwo, termin zgłaszania zastrzeżeń/sprzeciwu, zasady zapłaty wynagrodzenia, terminy zapłaty podwykonawcom, kary umowne — weryfikacja: `grep "### Art. 437" D20192019Lj.md`),
>   - **art. 438** — **obowiązki związane z zatrudnieniem na umowę o pracę** (dla RB/usług z art. 95 ust. 1) — sposób dokumentowania zatrudnienia + sankcje,
>   - **art. 439** — **obligatoryjna waloryzacja wynagrodzenia** w umowach > 6 miesięcy (roboty budowlane / dostawy / usługi): klauzula musi określać poziom zmiany uprawniający do waloryzacji, sposób ustalania (wskaźnik GUS lub inny), sposób określenia wpływu, okresy i **maksymalną wartość zmiany wynagrodzenia**,
>   - **art. 442** — zaliczki na poczet wykonania zamówienia (fakultatywne; jeżeli > 20% wynagrodzenia — obowiązek żądania zabezpieczenia zaliczki),
>   - **art. 443** — **dla umów > 12 m-cy: obowiązkowa wypłata wynagrodzenia w częściach lub zaliczki**; ostatnia część ≤ 50% wynagrodzenia; zaliczka ≥ 5% wynagrodzenia,
>   - **art. 447** — dla zamówień na **roboty budowlane o terminie > 12 m-cy** dodatkowe zasady: warunkiem zapłaty kolejnych części / zaliczek jest przedstawienie dowodów zapłaty podwykonawcom,
>   - **art. 448** — ogłoszenie w BZP o wykonaniu umowy w terminie 30 dni,
>   - **art. 449** — definicja zabezpieczenia NWU, moment wnoszenia (przed zawarciem umowy, chyba że ustawa / SWZ stanowi inaczej),
>   - **art. 450** — **formy zabezpieczenia NWU**: pieniądz / poręczenia bankowe lub SKOK / gwarancje bankowe / gwarancje ubezpieczeniowe / poręczenia PARP (ust. 1); za zgodą zamawiającego także weksle z poręczeniem wekslowym, zastaw na papierach wartościowych SP/JST, zastaw rejestrowy (ust. 2),
>   - **art. 452 ust. 2** — **cap wysokości zabezpieczenia: ≤ 5%** ceny całkowitej z oferty (wyjątkowo ≤ 10% z uzasadnieniem w SWZ — ust. 3); dla umów > 1 rok możliwość potrąceń z należności (ust. 4-7),
>   - **art. 453** — **zasady zwrotu zabezpieczenia**: 70% w terminie 30 dni od wykonania zamówienia i uznania za należycie wykonane (ust. 1); ≤ 30% pozostawione na rękojmię/gwarancję (ust. 2); zwrot kwoty z ust. 2 nie później niż w 15. dniu po upływie rękojmi/gwarancji (ust. 3),
>   - **art. 454** — **definicja zmiany istotnej** (4 przesłanki: zmiana warunków wpływająca na wynik postępowania, naruszenie równowagi ekonomicznej, znaczne rozszerzenie/zmniejszenie zakresu, zastąpienie wykonawcy poza art. 455 ust. 1 pkt 2),
>   - **art. 455** — **katalog dopuszczalnych zmian umowy** bez nowego postępowania: ust. 1 pkt 1 (przewidziane w SWZ jasne klauzule), pkt 2 (zastąpienie wykonawcy — sukcesja / przejęcie zobowiązań), pkt 3 (dodatkowe dostawy/usługi/roboty, wzrost ceny ≤ 50%), pkt 4 (okoliczności nieprzewidzialne, wzrost ≤ 50%); ust. 2 (zmiany łącznej wartości < progów UE oraz < 10% dostawy/usługi lub < 15% RB),
>   - **art. 456** — **odstąpienie przez zamawiającego**: ust. 1 pkt 1 istotna zmiana okoliczności powodująca, że wykonanie umowy nie leży w interesie publicznym (termin 30 dni); ust. 1 pkt 2 lit. a-c — (a) zmiana umowy z naruszeniem art. 454/455, (b) wykonawca w chwili zawarcia podlegał wykluczeniu z art. 108, (c) TSUE stwierdził naruszenie prawa UE przez RP. **UWAGA:** „upadłość/likwidacja wykonawcy" NIE jest ustawową przesłanką odstąpienia z art. 456 — może być tylko przesłanką odstąpienia umownego,
>   - **art. 457** — **nieważność umowy** (naruszenia przy udzieleniu zamówienia: brak ogłoszenia, naruszenie art. 264/308/421/577, zawarcie przed terminem z art. 216 ust. 2, itp.),
>   - **art. 462** — ogólne zasady podwykonawstwa (wykonawca może powierzyć część; zamawiający może żądać wskazania części i nazw),
>   - **art. 463** — zakaz kształtowania umów o podwykonawstwo mniej korzystnie dla podwykonawcy niż umowa z wykonawcą (kary umowne, wypłata wynagrodzenia),
>   - **art. 464** — **tryb przedkładania projektów umów o podwykonawstwo** (dla RB); termin zapłaty ≤ 30 dni; sprzeciwy zamawiającego,
>   - **art. 465** — **bezpośrednia zapłata wynagrodzenia podwykonawcy** przez zamawiającego (w przypadku uchylenia się wykonawcy od zapłaty, dla umów na RB). Solidarna odpowiedzialność inwestora/generalnego wykonawcy wynika z art. 647¹ § 5 k.c. (nie z art. 465 Pzp).
> - **K.c. w zakresie nieuregulowanym Pzp** (art. 8 ust. 1 Pzp): art. 353¹ (swoboda umów), art. 58 (nieważność czynności), art. 471 i n. (odpowiedzialność kontraktowa), art. 483–485 (kary umowne — w tym art. 484 § 1: kara umowna wyłącza żądanie odszkodowania ponad karę, chyba że strony inaczej postanowiły; § 2: miarkowanie), art. 498–499 (potrącenie), art. 556–576 (rękojmia za wady przy sprzedaży), art. 577–582 (gwarancja jakości), art. 647–658 (umowa o roboty budowlane — w tym art. 647¹ § 5: solidarna odpowiedzialność), art. 734–751 (zlecenie i umowy podobne).
> - **RODO:** rozp. 2016/679 + ustawa z 10.05.2018 r. o ochronie danych osobowych (tekst jednolity: Dz.U. 2019 poz. 1781) — dla każdej umowy z przetwarzaniem danych osobowych wymagana jest umowa powierzenia art. 28 RODO.
> - **KSC:** ustawa o krajowym systemie cyberbezpieczeństwa (Dz.U. 2026 poz. 20 i 252) — dla zamówień ICT / infrastruktury — wymogi cyberbezpieczeństwa, dostawcy wysokiego ryzyka (art. 67b ustawy KSC).
> - **Prawo autorskie:** ustawa z 04.02.1994 r. o prawie autorskim i prawach pokrewnych (tekst jednolity: Dz.U. 2025 poz. 24) — dla umów IT / projektowych: art. 41 (przeniesienie / licencja), art. 50 (pola eksploatacji), art. 64–65, art. 74 (programy komputerowe).
> - **Ustawa z 08.03.2013 r. o przeciwdziałaniu nadmiernym opóźnieniom w transakcjach handlowych** (tekst jednolity: Dz.U. 2023 poz. 711) — art. 8 ust. 2 (termin 30+30 dni dla transakcji asymetrycznych).
> - **Zasady redakcji cytatów:** [[zasady_redakcji]] — § 54-63 Zasad techniki prawodawczej (oznaczanie art. / ust. / pkt / lit. / tiret).
> - Nie używać przedawnionych sygnatur (np. Dz.U. 2023 poz. 1605 dla Pzp; Dz.U. 2023 poz. 1790 dla ustawy o terminach zapłaty).

## When to Use

- User przekazuje projekt umowy (`.docx` / `.pdf` / `.md`) + folder z dokumentacją postępowania (SWZ, OPZ, oferta, pisma z odpowiedziami) i prosi o weryfikację przed podpisaniem.
- User pisze: „sprawdź projekt umowy", „zweryfikuj wzór umowy", „przeanalizuj PPU", „czy umowa jest zgodna z SWZ", „czy można podpisać w tej wersji", „audyt umowy przed zawarciem", „kontrola umowy w reżimie PZP".
- User wskazuje, że trwa etap **po wyborze oferty, przed podpisaniem umowy** — klasyczny moment do kontroli kontraktowej.
- User wskazuje sygnaturę postępowania i prosi o ocenę gotowości do podpisania umowy.
- User chce listę konkretnych poprawek z cytatami oryginału i proponowanym brzmieniem — **to kluczowa funkcja skilla**.

## When NOT to Use

- Umowy poza reżimem PZP (np. umowy cywilnoprawne nieobjęte PZP, umowy wewnętrzne jednostki, darowizny, porozumienia międzygminne) — użyj ogólnej analizy kontraktowej.
- Umowy już zawarte — tu wchodzi w grę analiza aneksu, zmiany umowy (art. 454–455 Pzp) albo odstąpienia (art. 456 Pzp), co wymaga odrębnego podejścia.
- Analiza samego SWZ / OPZ bez projektu umowy — tu użyj `analyzing-pzp-offers` jeśli chodzi o ofertę, albo wykonaj samodzielny audyt SWZ (inna metodyka).
- Generowanie pism do wykonawcy (informacja o wyborze, wezwania) — to robi `drafting-pzp-letters`.
- Wstępny szkic umowy przed publikacją SWZ (tu robimy redakcję konstrukcyjną, a nie weryfikację formalną).

## Required Inputs — ZAWSZE dopytaj, jeśli brakuje

Zanim rozpoczniesz cokolwiek innego, potwierdź z userem:

1. **`<contract_path>`** — absolute path do pliku projektu umowy (`.docx` / `.pdf` / `.md`) **albo** folderu zawierającego wyłącznie projekt umowy wraz z załącznikami do umowy.
2. **`<procurement_dir>`** — absolute path do folderu z dokumentacją postępowania: SWZ, OPZ, ogłoszenie, pisma z wyjaśnieniami i zmianami SWZ, oferta wybranego wykonawcy (formularz ofertowy + załączniki), harmonogram, załączniki techniczne/proceduralne/odbiorowe.
3. **`<output_dir>`** — (opcjonalne, default: `<procurement_dir>/weryfikacja-umowy-<slug-sygnatury>-<yyyy-mm-dd>/`) — folder docelowy dla raportów.
4. **`<autor_analizy>`** — (opcjonalne, default z kontekstu `userEmail` w CLAUDE.md / auto-memory; dla KG PSP: `claude@kg.straz.gov.pl` lub `mklosinski@kg.straz.gov.pl`).
5. **`<analysis_dir>`** — (opcjonalne) — folder z uprzednią analizą oferty (raport z `analyzing-pzp-offers`). Jeśli dostępny — wykorzystaj `03-braki-i-niezgodnosci-*.md` i `06-cytaty-i-zrodla-*.md` jako materiał referencyjny i spójnościowy.
6. **`<zadania_md>`** — (opcjonalne) — plik `.md` z indywidualnymi uwagami usera (np. „zwróć uwagę na klauzulę gwarancji", „sprawdź, czy waloryzacja jest zgodna z ofertą"). Traktować jako pomocniczy prompt, nie jako dokument postępowania.

Jeżeli user nie podał ścieżek: wypisz aktualny drzewostan katalogów nadrzędnych i zapytaj o konkretne foldery. **NIE zgaduj.**

Jeżeli brak wyraźnego wskazania pliku umowy — **zapytaj usera o konkretny plik**. Przykład: folder `PROJEKTY/PZP/xxx/` może zawierać wiele wersji umowy; zawsze potwierdź, którą analizujesz.

## Workflow

```mermaid
flowchart TD
    Start(["User podaje contract + procurement"]) --> P0["Phase 0: Walidacja wejścia"]
    P0 --> P1["Phase 1: Indeksacja plików (umowa + dokumentacja)"]
    P1 --> P2["Phase 2: Ekstrakcja wymagań kontraktowych"]
    P2 --> P3["Phase 3: Analiza umowy (I–V)"]
    P3 --> P4["Phase 4: Budowa macierzy korelacji"]
    P4 --> P5["Phase 5: Lista proponowanych poprawek (cytat → cytat)"]
    P5 --> P6["Phase 6: Generowanie raportu A–F + addendów"]
    P6 --> Done(["Seria 11 dokumentów + rekomendacja"])
```

### Phase 0 — Walidacja wejścia

1. `ls -la` na obu ścieżkach; wypisz strukturę (włącznie z załącznikami ZIP, XAdES, podpisami zewnętrznymi).
2. Potwierdź, że `<contract_path>` wskazuje konkretny plik lub folder z projektem umowy — jeżeli znalazłeś kilka plików z wyglądu kandydujących (np. „Umowa wersja 3.docx", „Umowa_po_uwagach_radcy.docx"), **STOP. Zapytaj usera**, który jest wersją wiążącą do analizy.
3. Zidentyfikuj obecność dokumentów kluczowych w `<procurement_dir>`:
   - **Obligatoryjnie:** ogłoszenie, SWZ, OPZ, projektowane postanowienia umowy (PPU) w pierwotnym brzmieniu — jeśli istnieje odrębnie od projektu umowy — często oznaczane jako „Załącznik nr X do SWZ — wzór umowy" / „Załącznik — PPU".
   - **Jeżeli dotyczy:** oferta (formularz ofertowy + karta oceny oferowanych parametrów), pisma z wyjaśnieniami i modyfikacjami SWZ (chronologicznie), harmonogram, załączniki techniczne, protokoły negocjacji (dla trybów negocjacyjnych), informacja o wyborze oferty.
4. Jeżeli `<contract_path>` wskazuje `.docx` / `.pdf` — konwertuj przez skill `convert` do `.md` (patrz Phase 1) **zanim** rozpoczniesz Phase 2.
5. Sprawdź czy `<procurement_dir>` zawiera pliki z notatkami usera (`ZADANIE.md`, `notatki.md`, `uwagi.md`, `oczekiwania.md`) — jeśli tak, **przeczytaj je PRZED Phase 2**. Te pliki NIE są dokumentami postępowania (nie cytujesz ich jako źródło prawne), ale wskazują na czym user chce się skupić.
6. Jeżeli wykryjesz **archiwum ZIP** (np. z załącznikami): zapytaj usera o rozpakowanie albo czy zawartość jest już w podfolderze.
7. Jeżeli wykryjesz **plik podpisu zewnętrznego** (`.XAdES`, `.sig`, `.p7s`) bez pliku źródłowego — **STOP. Zapytaj usera**, czy to błąd kompletacji materiału, czy faktyczny brak podpisywanego dokumentu.
8. Utwórz `<output_dir>` jeśli nie istnieje (`mkdir -p`).

### Phase 1 — Indeksacja plików (ZAWSZE pierwsza — nigdy nie pomijać)

**Cel:** dla każdego pliku tworzysz rekord: nazwa + typ + rola w postępowaniu + kluczowe parametry (strony, daty, kwoty, podmioty).

**Wykonanie:**

- **Index A — `<output_dir>/index-umowa.md`** — szczegółowy rozkład projektu umowy z listą paragrafów/ustępów/punktów i załączników. Dla każdego paragrafu: tytuł i jednozdaniowe streszczenie. Dla każdego załącznika: czy faktycznie fizycznie istnieje w przekazanym materiale, czy tylko zawołany w treści umowy.
- **Index B — `<output_dir>/index-dokumentacja-postepowania.md`** — spis całej dokumentacji postępowania (ogłoszenie, SWZ, OPZ, pisma, oferta, harmonogram). Dla każdego pliku co najmniej 2–3 zdania opisu: tytuł właściwy, data, wersja, strony, kluczowe parametry.

Format indexów — patrz `templates/index-umowa.md` i `templates/index-dokumentacja-postepowania.md`.

**Red flag — STOP:** jeżeli chcesz pominąć indeksację bo „umowa jest krótka" — to sygnał, że zaczynasz domniemywać. Wróć i odczytaj pliki.

### Phase 2 — Ekstrakcja wymagań kontraktowych z dokumentacji postępowania

> [!danger] PRECONDITION CHECK — STOP, jeśli nie zachodzi
> Zanim zaczniesz Phase 2, **bezwzględnie sprawdź**:
> 1. Czy `<output_dir>/index-umowa.md` istnieje i ma opis KAŻDEGO paragrafu projektu umowy oraz KAŻDEGO załącznika?
> 2. Czy `<output_dir>/index-dokumentacja-postepowania.md` istnieje i ma opis KAŻDEGO pliku w `<procurement_dir>`?
>
> **Jeśli NIE — wróć do Phase 1.** Pod żadnym pozorem nie rozpoczynaj Phase 2 bez ukończonych indeksów. Brak indeksów = **nieważna analiza** (brak audit trail).

Zbuduj **katalog wymagań kontraktowych** wynikających z dokumentacji postępowania. Dla każdej kategorii poniżej odszukaj w SWZ/OPZ/PPU/ofercie źródło wymogu i zapisz w `<output_dir>/wymagania-kontraktowe.md` (plik roboczy, niekoniecznie produkcyjny):

| Obszar kontraktowy | Typowe źródło | Co sprawdzić |
|--------------------|---------------|--------------|
| Strony umowy + reprezentacja | Ogłoszenie, SWZ, oferta (formularz) | Zgodność nazw, NIP, REGON, KRS, umocowania |
| Przedmiot umowy | SWZ Rozdz. „Opis przedmiotu zamówienia", OPZ | Zakres rzeczowy, zakres usług, ilość, części |
| Termin realizacji | SWZ Rozdz. „Termin wykonania", harmonogram, oferta | Daty graniczne, etapy, kamienie milowe |
| Wynagrodzenie i płatności | SWZ Rozdz. „Wynagrodzenie / płatności", oferta (cena) | Model rozliczeń (ryczałt / obmiar / jednostkowe), terminy płatności, przedpłaty |
| Kary umowne | SWZ Rozdz. „Kary umowne" / PPU | Wysokość, zdarzenia, cap, zasady naliczania |
| Odbiory | SWZ + OPZ „Warunki odbioru", harmonogram | Procedury, terminy, dokumenty odbiorowe, kryteria akceptacji |
| Gwarancja / rękojmia / SLA | SWZ, OPZ, oferta (okres gwarancji) | Okres, zakres, czas reakcji, czas naprawy |
| Zabezpieczenie NWU (art. 449–453 Pzp — rozdz. 2) | SWZ „Zabezpieczenie" | Wysokość (art. 452 ust. 2: ≤ 5% ceny brutto; ust. 3: ≤ 10% z uzasadnieniem), formy (art. 450), zwrot (art. 453) |
| Waloryzacja (art. 439 Pzp) | SWZ, PPU — dla umów > 6 miesięcy | Klauzula wskaźnika, częstotliwość, cap (maksymalna wartość zmiany) |
| Zmiany umowy (art. 454–455 Pzp) | PPU „Zmiany umowy" | Katalog dopuszczalnych zmian — **obligatoryjny** |
| Odstąpienie / wypowiedzenie | PPU „Odstąpienie" | Zgodność z art. 456 Pzp (4 przesłanki — NIE obejmują upadłości) + k.c. |
| Podwykonawstwo (art. 462–465 Pzp + art. 437 dla RB) | SWZ, PPU, oferta („Wykaz podwykonawców") | Zgoda zamawiającego; bezpośrednia zapłata (art. 465); solidarność z art. 647¹ § 5 k.c. |
| Zaliczki i płatności częściowe (art. 442, 443, 447 Pzp) | PPU | art. 442 zaliczki; art. 443 dla umów > 12 m-cy (dostawy/usługi); art. 447 dla RB > 12 m-cy |
| RODO / bezpieczeństwo | SWZ, OPZ, wymogi KSC (jeśli ICT) | Umowa powierzenia art. 28 RODO, klauzule TOM |
| Prawa autorskie / licencje | SWZ, OPZ, oferta (jeśli IT/projekt) | Pola eksploatacji, przeniesienie/licencja |
| Tajemnica przedsiębiorstwa + poufność | SWZ, oferta | Zakres zobowiązań, okres |
| Załączniki do umowy | SWZ lista, PPU | Czy wszystkie wymienione + czy fizycznie istnieją |

Każde wymaganie opisz: `{obszar, źródło (dokument + rozdział/punkt + strona), treść wymogu, wersja aktualna po modyfikacjach}`.

**Kluczowe:** wszystkie modyfikacje SWZ / odpowiedzi na pytania wykonawców są **nadrzędne** wobec pierwotnej wersji SWZ/OPZ w zakresie objętym zmianą. Pracuj wyłącznie na aktualnym brzmieniu. Wersja PPU z załącznika do SWZ po modyfikacjach wiąże wersję projektu umowy przedkładaną do podpisu.

### Phase 3 — Analiza umowy (sekcje I–V z verification-prompt.md)

Zastosuj pełny prompt analityczny z `verification-prompt.md`. Analiza przebiega w 5 sekcjach:

- **I. Analiza formalna dokumentu** — tytuł, strony, reprezentacja, NIP/REGON, struktura (§/ust./pkt/lit.), numeracja, odesłania, definicje, terminologia, nazwy dokumentów powiązanych, nazwy załączników, kwoty, daty, jednostki.
- **II. Analiza pod kątem Pzp** — zgodność z art. 431–465 Pzp, **klauzule niedopuszczalne w PPU (art. 433)**, czas trwania (art. 434 — co do zasady oznaczony; > 4 lat wymaga uzasadnienia świadczeniami ciągłymi/powtarzającymi się i konkretnymi warunkami), obligatoryjne postanowienia (art. 436 — 4 pkt), podwykonawstwo w RB (art. 437 — 7 pkt), zatrudnienie na umowę o pracę (art. 438 — dla art. 95 ust. 1), waloryzacja (art. 439), płatności częściowe dla umów > 12 m-cy (art. 443) i RB > 12 m-cy (art. 447), zabezpieczenie NWU (art. 449–453), **katalog zmian umowy (art. 454–455)**, odstąpienie (art. 456 — wyłącznie 4 przesłanki ustawowe), niepodleganie obejściu zasad konkurencyjności / przejrzystości / równego traktowania (art. 16 Pzp), proporcjonalność kar umownych (art. 484 § 2 k.c.), spójność z dokumentacją postępowania i ofertą.
- **III. Analiza spójności wewnętrznej** — czy definicje są konsekwentnie używane, czy obowiązki stron wzajemnie pokryte, czy etapy odbiorowe skorelowane z kamieniami milowymi płatności, czy kary umowne powiązane ze zdarzeniami z harmonogramu i obowiązkami, czy postanowienia końcowe nie osłabiają wcześniejszych obowiązków.
- **IV. Analiza korelacji z dokumentacją postępowania** — macierz: zapis umowy ↔ odpowiadający zapis w SWZ/OPZ/ofercie/harmonogramie/załącznikach ↔ status (zgodne / częściowo zgodne / niezgodne / brak regulacji).
- **V. Ocena ryzyk kontraktowych** — per ryzyko: źródło, dotknięty zapis, możliwy skutek, poziom istotności (krytyczne/istotne/umiarkowane/drobne), rekomendacja ograniczenia.

**Każde znalezisko klasyfikujesz wg:**

| Kod | Kategoria problemu | Przykład |
|-----|-------------------|----------|
| **P1** | Formalny | Błąd w nazwie strony, zła numeracja, brak daty |
| **P2** | Prawny (k.c., inne ustawy) | Klauzula sprzeczna z k.c., z RODO, z ustawą o prawie autorskim |
| **P3** | Pzp | Klauzula abuzywna (art. 433), sprzeczna z katalogiem zmian (art. 455), brak waloryzacji (art. 439) |
| **P4** | Redakcyjny | Błędne odesłanie wewnętrzne, literówka wpływająca na interpretację, błędna nazwa załącznika |
| **P5** | Logiczny (spójność wewnętrzna) | Sprzeczność dwóch paragrafów, definicja niezgodna z użyciem |
| **P6** | Operacyjny | Procedura niewykonalna w praktyce, brak mechanizmu egzekwowania |
| **P7** | Brak korelacji z dokumentacją | Termin z umowy ≠ termin z oferty, parametr z umowy ≠ parametr z OPZ |

**Poziomy ryzyka:**

| Kod | Poziom | Konsekwencja |
|-----|--------|--------------|
| **R1** | Krytyczne | Uniemożliwia podpisanie lub nieważność z mocy prawa; obligatoryjna korekta przed podpisem |
| **R2** | Istotne | Znaczące ryzyko sporu / nieskutecznej egzekucji; korekta przed podpisem rekomendowana silnie |
| **R3** | Umiarkowane | Ryzyko interpretacyjne lub operacyjne; korekta zalecana |
| **R4** | Drobne | Wady redakcyjne / czytelnościowe bez wpływu na wykonalność; do rozważenia |

### Phase 4 — Macierz korelacji dokumentów

Utwórz `<output_dir>/04-macierz-korelacji-<slug-sygnatury>.md` (format: `templates/04-macierz-korelacji.md`).

Dla KAŻDEJ jednostki redakcyjnej projektu umowy, która odwołuje się do dokumentu postępowania (SWZ, OPZ, oferta, pisma), wpisz wiersz:

| Zapis umowy | Dokument powiązany | Odpowiadający zapis | Status | Opis rozbieżności | Rekomendacja |
|-------------|---------------------|---------------------|--------|-------------------|--------------|

Statusy: `zgodne` / `częściowo zgodne` / `niezgodne` / `brak regulacji`.

**Pokryj co najmniej:**

1. Przedmiot umowy ↔ OPZ
2. Termin wykonania ↔ SWZ „Termin wykonania" + oferta + harmonogram
3. Wynagrodzenie ↔ oferta (formularz ofertowy) + SWZ „Wynagrodzenie"
4. Kary umowne ↔ PPU (Załącznik do SWZ) + odpowiedzi na pytania
5. Gwarancja / SLA ↔ OPZ + oferta (deklarowany okres)
6. Odbiory ↔ OPZ + załączniki odbiorowe
7. Waloryzacja ↔ PPU + SWZ
8. Zabezpieczenie ↔ SWZ
9. Podwykonawcy ↔ oferta („Wykaz podwykonawców") + SWZ
10. Załączniki do umowy ↔ SWZ „Załączniki do umowy"

### Phase 5 — Proponowane poprawki (cytat oryginału → cytat proponowanego brzmienia)

**To jest kluczowy produkt tego skilla.** Utwórz `<output_dir>/05-proponowane-poprawki-<slug-sygnatury>.md` (format: `templates/05-proponowane-poprawki.md`).

Dla KAŻDEJ wady wykrytej w Phase 3 (kategorie P1–P7) utwórz osobny blok:

```markdown
### P-XXX [Krótka nazwa poprawki]

**Kategoria:** P[1–7] | **Poziom ryzyka:** R[1–4]

**Jednostka redakcyjna:** § N ust. M pkt K lit. L umowy / „Załącznik nr Y do umowy"

**Obecne brzmienie:**
> [!quote] Cytat z projektu umowy (§ N ust. M)
> „[...DOKŁADNY cytat obecnego brzmienia — kopiuj literalnie...]"

**Problem:**
[Opis: co konkretnie jest niewłaściwe. Odróżnij: sprzeczność z ustawą / sprzeczność z SWZ / sprzeczność wewnętrzną / ryzyko interpretacyjne / błąd redakcyjny.]

**Proponowane brzmienie:**
> [!success] Propozycja nowego brzmienia (§ N ust. M)
> „[...pełny tekst proponowany do wstawienia w miejsce obecnego...]"

**Uzasadnienie:**
- **Prawne:** [konkretna podstawa: art. 433 ust. 1 Pzp / art. 353¹ k.c. / orzecznictwo KIO (ze wskazaniem sygnatury)]
- **Dokumentacja postępowania:** [odwołanie do cytatu z SWZ/OPZ/oferty w formacie `[DOC: plik] [Rozdz. N] [str. N]` z literalnym cytatem]
- **Operacyjne:** [wpływ na wykonalność, odbiór, rozliczenie, kontrolę; co zagraża, jeśli nie wprowadzimy poprawki]
- **Alternatywa (jeśli dotyczy):** [druga możliwa redakcja, jeżeli istnieje kilka interpretacji równolegle bezpiecznych]
```

**Reguły:**

1. **Zawsze cytat literalny obecnego brzmienia** — nie parafrazuj. Kopiuj dokładnie, z zachowaniem interpunkcji i ewentualnych błędów. Cytuj całe zdanie / ustęp, z kontekstem (nie wyrywaj z kontekstu).
2. **Proponowane brzmienie musi być pełne i wstawialne** — tak, żeby można było skopiować do projektu umowy bez dalszej pracy redakcyjnej. Nie pisz „dodać klauzulę o waloryzacji" — pisz całą klauzulę.
3. **Zachowuj styl redakcyjny** projektu umowy (polski urzędowy, terminologia z ustawy Pzp + OPZ). Nie wprowadzaj anglicyzmów.
4. **Uzasadnienie prawne MUSI wskazywać konkretny artykuł Pzp / k.c. / innej ustawy**, z datą publikacji aktualnego tekstu jednolitego (zob. blok „Aktualna podstawa prawna" na początku tego SKILL.md).
5. **Jeżeli poprawka wynika z niespójności z SWZ/OPZ/ofertą** — cytuj dokument źródłowy z lokalizacją (plik + Rozdz. + str.).
6. **Jeżeli wariantowe** — przedstaw opcję A i opcję B z wyjaśnieniem, którą user jako zamawiający powinien preferować.
7. **Sortowanie + numeracja** (dwa kroki):
   - Plik `05-proponowane-poprawki` jest **grupowany sekcjami wg poziomu ryzyka** (R1 → R2 → R3 → R4) — tak strukturyzowany jest template.
   - Wewnątrz każdej grupy R-* poprawki są uszeregowane **wg kolejności paragrafów umowy** (rosnąco: § 1 → § 2 → § 15 → załączniki).
   - Numeracja P-001, P-002, … jest **ciągła przez cały plik** (nie restartowana w każdej sekcji R) — tak, by wikilinki `[[05-proponowane-poprawki#P-042]]` były unikalne.
   - Przykład kolejności: P-001 (R1 w § 2) → P-002 (R1 w § 7) → P-003 (R2 w § 3) → P-004 (R2 w § 5) → P-005 (R3 w § 1) → P-006 (R3 w § 9) → P-007 (R4 w § 4).
8. **Grupuj** poprawki dotyczące tego samego paragrafu razem w obrębie tej samej sekcji R (np. jeśli § 7 ma 3 problemy R2, to P-0XX, P-0XX+1, P-0XX+2 w sekcji R2).

### Phase 6 — Generowanie raportu A–F + addendów

**KAŻDA analiza MUSI kończyć się serią dokumentów**, nie pojedynczym plikiem. Minimalny zestaw:

| # | Plik | Zawartość | Mapowanie na format A–F z promptu |
|---|------|-----------|----------------------------------|
| 0a | `index-umowa.md` | Struktura projektu umowy | — |
| 0b | `index-dokumentacja-postepowania.md` | Indeks dokumentacji | — |
| 1 | `00-podsumowanie-wykonawcze-<slug-sygnatury>.md` | 1–2 strony executive summary z ogólną oceną + rekomendacją | **A. Ocena ogólna + F. Wnioski końcowe (skrót)** |
| 2 | `01-raport-glowny-<slug-sygnatury>.md` | Pełny raport — wprowadzenie + sekcje I–V z analizy | **A + F (pełne)** |
| 3 | `02-tabela-ustalen-krytycznych-<slug-sygnatury>.md` | Tabela ustaleń (nr / jedn. / opis / rodzaj / ryzyko / korekta) | **B** |
| 4 | `03-analiza-szczegolowa-<slug-sygnatury>.md` | 15 obszarów: strony, definicje, przedmiot, obowiązki, terminy, odbiory, wynagrodzenie, kary, gwarancja, RODO, prawa autorskie, zmiany, odstąpienie, załączniki, zgodność z dok. post. | **C** |
| 5 | `04-macierz-korelacji-<slug-sygnatury>.md` | Zapis umowy ↔ dokument powiązany ↔ odpowiadający zapis ↔ status | **D** |
| 6 | `05-proponowane-poprawki-<slug-sygnatury>.md` | Per P-XXX: cytat oryginału + cytat propozycji + uzasadnienie | **E** (kluczowy produkt) |
| 7 | `06-ocena-ryzyk-<slug-sygnatury>.md` | Ryzyka: źródło / zapis / skutek / istotność / rekomendacja | **V → osobne rozbudowanie** |
| 8 | `07-wnioski-koncowe-<slug-sygnatury>.md` | 5 pytań z promptu z jednoznacznymi odpowiedziami | **F** (pełne) |
| 9 | `08-cytaty-i-zrodla-<slug-sygnatury>.md` | Register wszystkich cytatów (plik + str. + treść) | — |

Wszystkie pliki w **Obsidian Flavored Markdown**:

- Frontmatter z properties (`sygnatura`, `postepowanie`, `zamawiajacy`, `wykonawca`, `data_analizy`, `autor_analizy`, `typ_dokumentu`, `status`, `tags`).
- Wikilinks między dokumentami (np. `[[05-proponowane-poprawki-<slug>#P-015]]`, `[[04-macierz-korelacji-<slug>]]`).
- Callouts dla znalezisk: `> [!danger]` R1 krytyczne, `> [!warning]` R2 istotne, `> [!info]` R3 umiarkowane, `> [!note]` R4 drobne, `> [!success]` zgodność potwierdzona, `> [!quote]` literalne cytaty, `> [!abstract]` wymagana dalsza analiza prawna.
- Tagi: `#pzp/weryfikacja-umowy`, `#pzp/sygnatura/<slug>`, `#pzp/poziom-ryzyka/<R1-R4>`, `#pzp/kategoria-problemu/<P1-P7>`.
- Highlights dla parametrów krytycznych: `==termin realizacji: 2026-12-31==`, `==wynagrodzenie 2 450 000,00 zł brutto==`.
- Block IDs `^P-XXX` przy każdej poprawce do cross-referencji.
- Footnotes przy długich odnośnikach do dokumentów źródłowych.

Szczegółowe templaty — katalog `templates/`.

## Citation Format (OBLIGATORYJNY)

### Cytowanie umowy

```
§ <N> ust. <M> pkt <K> lit. <L> umowy
```

Przykład: `§ 7 ust. 3 pkt 2 lit. a umowy` — wskazuje jednoznacznie położenie.

Dla załączników do umowy: `Załącznik nr <N> do umowy — <nazwa> — pkt <M> / str. <K>`.

### Cytowanie dokumentów postępowania

```
[DOC: <plik>] [Rozdz. <N>] [ust. <N>] [pkt <N>] [lit. <l>] [str. <N>]
```

Przykład:

```markdown
> [!warning] P-012 — Niezgodność terminu realizacji z ofertą

**Obecne brzmienie:** § 4 ust. 1 umowy
> „Wykonawca zobowiązany jest wykonać przedmiot umowy w terminie do dnia 31 grudnia 2026 r."

**Stan wymagany:** `[DOC: Oferta-WASKO.pdf] [str. 2]` — „Wykonawca deklaruje realizację zamówienia w terminie 10 miesięcy od daty zawarcia umowy"
oraz `[DOC: SWZ.pdf] [Rozdz. IV] [pkt 3] [str. 14]` — „Termin realizacji: 10 miesięcy od daty zawarcia umowy"

**Kategoria:** P7 (brak korelacji) + P5 (spójność wewnętrzna — umowa z 22.04.2026 r. + 10 miesięcy ≠ 31.12.2026 r.) | **Ryzyko:** R2

**Proponowane brzmienie:**
> „Wykonawca zobowiązany jest wykonać przedmiot umowy w terminie 10 (dziesięciu) miesięcy, liczonych od dnia zawarcia niniejszej umowy."

**Uzasadnienie:**
- **Prawne:** art. 436 pkt 2 Pzp — termin wykonania zamówienia jest obligatoryjnym elementem umowy; termin musi być zgodny z ofertą (art. 454 ust. 1 Pzp — zmiana terminu niezgodnie z katalogiem = istotna zmiana umowy).
- **Dokumentacja postępowania:** oferta wykonawcy deklaruje 10 miesięcy; SWZ określa 10 miesięcy od daty zawarcia — przy dacie 22.04.2026 + 10 miesięcy = 22.02.2027, a nie 31.12.2026.
- **Operacyjne:** sztywna data 31.12.2026 tworzy ryzyko roszczenia wykonawcy o skrócenie terminu; niezgodność naraża zamawiającego na zarzut istotnej zmiany umowy na etapie ewentualnej kontroli.
```

## Obsidian MD — wymagane formaty per dokument

### Konwencja placeholder-ów w templatach

| Składnia | Znaczenie |
|----------|-----------|
| `<<nazwa_pola>>` | Placeholder do wypełnienia — wartość z dokumentów / kontekstu / usera |
| `<<opcja1 \| opcja2 \| opcja3>>` | Lista wyborów — agent wybiera jedną opcję (pipe `\|` = OR) |
| `<<...>>` | Dłuższy tekst do uzupełnienia |

**Zasada:** W gotowych dokumentach nie powinno pozostać ŻADNEGO placeholder-a `<<...>>`. Jeśli sekcja nie dotyczy przypadku — usuń ją całkowicie lub oznacz „nie dotyczy" z uzasadnieniem.

### Frontmatter (każdy dokument)

```yaml
---
sygnatura: BL-V.2371.3.2026
postepowanie: "System X dla KG PSP"
zamawiajacy: Komenda Główna Państwowej Straży Pożarnej
wykonawca: WASKO S.A.
data_analizy: 2026-04-22
autor_analizy: claude@kg.straz.gov.pl
typ_dokumentu: raport-glowny
status: draft
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/BL-V-2371-3-2026
  - pzp/wykonawca/wasko
  - pzp/poziom-ryzyka/R2
---
```

### Callouts według kategorii ryzyka

| Poziom | Callout | Zastosowanie |
|--------|---------|--------------|
| R1 Krytyczne | `> [!danger]` | Uniemożliwia podpisanie, nieważność, sprzeczność z ustawą |
| R2 Istotne | `> [!warning]` | Silne ryzyko sporu / egzekucji, korekta wymagana |
| R3 Umiarkowane | `> [!info]` | Ryzyko interpretacyjne, korekta zalecana |
| R4 Drobne | `> [!note]` | Redakcyjne, do rozważenia |
| Zgodność potwierdzona | `> [!success]` | OK |
| Wymagana analiza prawna | `> [!abstract]` | Do pogłębionej oceny |
| Cytat dosłowny | `> [!quote]` | Zawsze dla cytatów z projektu umowy i dokumentów postępowania |
| Propozycja nowego brzmienia | `> [!success]` | Proponowane brzmienie poprawki |

## Edge Cases — ZAWSZE przestrzegać

1. **Klauzule niedopuszczalne (art. 433 Pzp — 4 pkt)** — jeden z najczęstszych problemów projektów umów w PZP. Literalny tekst ustawy: „Projektowane postanowienia umowy nie mogą przewidywać". Sprawdź wprost czy nie ma:
   - **pkt 1:** odpowiedzialności wykonawcy za opóźnienie — chyba że jest to uzasadnione okolicznościami lub zakresem zamówienia (uwaga: pkt 1 nie jest kategorycznym zakazem kar za opóźnienie — klauzula „chyba że uzasadnione" dopuszcza kary przy obiektywnym uzasadnieniu, np. roboty budowlane na czas),
   - **pkt 2:** naliczania kar umownych za zachowanie wykonawcy niezwiązane bezpośrednio lub pośrednio z przedmiotem umowy lub jej prawidłowym wykonaniem,
   - **pkt 3:** odpowiedzialności wykonawcy za okoliczności, za które wyłączną odpowiedzialność ponosi zamawiający,
   - **pkt 4:** możliwości ograniczenia zakresu zamówienia przez zamawiającego bez wskazania minimalnej wartości lub wielkości świadczenia stron.
   **Klauzula sprzeczna z art. 433 = wadliwość postanowienia (art. 58 § 1 k.c. w zw. z art. 8 ust. 1 Pzp).** To zwykle ryzyko R1 / R2 w zależności od rodzaju naruszenia.

2. **Katalog zmian umowy (art. 455 Pzp)** — w każdym paragrafie o „zmianach umowy" projekt umowy musi odzwierciedlać katalog z art. 455. Niedopuszczalne jest:
   - zapis typu „zmiany wymagają aneksu" bez wskazania podstaw (za mało),
   - zapis rozszerzający katalog zmian poza art. 455 (sprzeczny z ustawą),
   - zapis, który pozwala zmienić umowę sposób obchodzenia zasad konkurencyjności (art. 16 Pzp).
   **Postanowienia mają wskazywać konkretne przesłanki** (art. 455 ust. 1 pkt 1–4 + ust. 2) i ograniczenia.

3. **Waloryzacja (art. 439 Pzp)** — **obligatoryjna dla umów > 6 miesięcy** (usługi / roboty budowlane). Sprawdź:
   - czy klauzula jest w umowie,
   - czy wskazuje wskaźnik (np. GUS — wskaźnik cen i usług konsumpcyjnych / wskaźnik cen produkcji budowlano-montażowej),
   - czy określa częstotliwość (minimum raz na 12 miesięcy),
   - czy ma maksymalną wartość zmiany (cap),
   - czy jest symetryczna (waloryzacja w górę i w dół).
   **Brak waloryzacji w umowie > 6 miesięcy = wada formalna (art. 439 Pzp), ryzyko R1/R2.**

4. **Zabezpieczenie NWU (art. 449–453 Pzp — rozdział 2)** — sprawdź:
   - **wysokość — art. 452 ust. 2:** ≤ 5% ceny całkowitej podanej w ofercie (wyjątkowo ≤ 10% przy uzasadnieniu przedmiotem/ryzykiem w SWZ — ust. 3),
   - **forma — art. 450 ust. 1:** pieniądz / poręczenia bankowe lub SKOK / gwarancje bankowe / gwarancje ubezpieczeniowe / poręczenia PARP; za zgodą zamawiającego (ust. 2): weksle z poręczeniem wekslowym, zastaw na papierach wartościowych SP/JST, zastaw rejestrowy,
   - **moment wniesienia — art. 449 ust. 3:** przed zawarciem umowy (chyba że ustawa / SWZ stanowi inaczej),
   - **zmiana formy — art. 451:** możliwa w trakcie realizacji z zachowaniem ciągłości i wysokości,
   - **potrącenia z należności — art. 452 ust. 4-7:** dla umów > 1 rok możliwość tworzenia przez potrącenia; min. 30% w dniu zawarcia,
   - **zasady zwrotu — art. 453:** 70% w terminie 30 dni od wykonania zamówienia i uznania za należycie wykonane (ust. 1); ≤ 30% pozostawione na rękojmię/gwarancję (ust. 2); zwrot tej kwoty nie później niż w 15. dniu po upływie okresu rękojmi/gwarancji (ust. 3).

5. **Kary umowne (art. 483 k.c. + art. 433 Pzp)** — typowe błędy:
   - kara naliczana za każdy dzień BEZ capu (= możliwa dysproporcja),
   - kara za okoliczności niezawinione (np. siła wyższa, zmiana przepisów) = abuzywna,
   - brak zasady odliczania kar od wynagrodzenia (operacyjne komplikacje),
   - kumulacja kar bez górnego limitu zbiorczego (najczęstsza rekomendacja: cap 20-30% wynagrodzenia brutto),
   - jednostronność (tylko wykonawca płaci kary, zamawiający nie — zwykle akceptowalne, ale warto mieć klauzulę o odsetkach za zwłokę w płatności art. 4 ustawy 8.03.2013 r. o przeciwdziałaniu nadmiernym opóźnieniom w transakcjach handlowych).

6. **Podwykonawstwo (art. 462–465 Pzp — rozdział 5; obligatoryjne postanowienia umowy o roboty budowlane — art. 437)** — dla zamówień na roboty budowlane umowa musi zawierać (art. 437 ust. 1, 7 pkt):
   - pkt 1: obowiązek przedkładania projektu umowy o podwykonawstwo (i jej zmian) oraz poświadczonej kopii zawartej umowy (dla RB),
   - pkt 2: terminy zgłoszenia zastrzeżeń / sprzeciwu zamawiającego,
   - pkt 3: obowiązek przedkładania kopii umów o podwykonawstwo dostaw/usług oraz ich zmian,
   - pkt 4: zasady zapłaty wynagrodzenia uwarunkowane dowodami zapłaty podwykonawcom,
   - pkt 5: terminy zapłaty podwykonawcom (maks. 30 dni — art. 464 ust. 2),
   - pkt 6: zasady zawierania umów z dalszymi podwykonawcami,
   - pkt 7: kary umowne (brak/nieterminowa zapłata, nieprzedłożenie projektu umowy, zmiany).
   Bezpośrednia zapłata podwykonawcy przez zamawiającego — **art. 465 Pzp** (w razie uchylenia się wykonawcy od zapłaty). Solidarna odpowiedzialność inwestora/wykonawcy — **art. 647¹ § 5 k.c.** (nie wynika z art. 465 Pzp). Dla zamówień innych niż roboty budowlane — ogólne zasady z art. 462 Pzp (wskazanie części, wymiana podwykonawcy — ust. 6, skutki dla warunków udziału — ust. 7). **Brak obligatoryjnych elementów art. 437 w umowie na RB = wadliwość (R1).**

7. **Powierzenie przetwarzania danych osobowych (art. 28 RODO)** — jeżeli przedmiot umowy wiąże się z przetwarzaniem danych osobowych (np. systemy IT, oprogramowanie, usługi analityczne, chmura):
   - umowa powierzenia ma być **odrębnym załącznikiem do umowy** (albo pełną sekcją w umowie),
   - musi zawierać wszystkie elementy z art. 28 ust. 3 RODO: przedmiot, czas, charakter i cel, rodzaj danych, kategorie osób, prawa i obowiązki administratora, subpowierzenie za zgodą, TOM (art. 32 RODO), wsparcie przy wnioskach osób, zwrot / usunięcie danych, audyty.
   **Brak umowy powierzenia dla przetwarzania danych = naruszenie art. 28 RODO, ryzyko R1.**

8. **Prawa autorskie (dla umów IT / projektowych / badawczych)** — sprawdź:
   - czy jest przeniesienie / licencja (art. 41 pr.aut.),
   - czy wskazano pola eksploatacji (art. 50 pr.aut.) — konkretnie, nie „wszystkie możliwe",
   - dla oprogramowania: art. 74 pr.aut. (specjalne zasady dla programów komputerowych),
   - moment przejścia praw (zwykle: odbiór + zapłata),
   - prawo do wykonywania praw zależnych (utwory pochodne) i prawo zezwalania na wykonywanie praw zależnych,
   - sublicensing — czy zamawiający może udzielać sublicencji jednostkom PSP / innym organom administracji.
   **Jeśli umowa jest IT / projektowa, a prawa autorskie nieuregulowane = ryzyko R1.**

9. **Cyberbezpieczeństwo (KSC)** — dla zamówień ICT (systemy, oprogramowanie, chmura, sieć):
   - art. 33 ust. 4 ustawy KSC — rekomendacje CSIRT MON / NASK / Rządowy Zespół Reagowania,
   - art. 67b ustawy KSC — **dostawcy wysokiego ryzyka** (w tym z państw trzecich bez umów z UE),
   - wymogi TOM (techniczne i organizacyjne środki bezpieczeństwa),
   - obowiązek zgłaszania incydentów,
   - prawo do audytu zamawiającego (nie może być wyłączone w umowie).

10. **Termin umowy (art. 434–435 Pzp)** — zasadniczo **maksymalnie 4 lata**. Wyjątki: umowy koncesyjne, umowy o roboty budowlane z obiektywnym uzasadnieniem dłuższego terminu, umowy na finansowanie. **Umowa > 4 lata bez uzasadnienia = R1**.

11. **Częstotliwość płatności w umowach > 12 miesięcy** (art. 437 Pzp, dla robót budowlanych) — obligatoryjnie płatności częściowe (min. ≥ 2) albo zaliczki. **Brak płatności częściowych w umowie > 12 m-cy = wada formalna**.

12. **Rozbieżność w nazwach własnych** — typowe: nazwa postępowania w umowie ≠ nazwa w ogłoszeniu, sygnatura w tytule umowy ≠ sygnatura faktyczna, NIP/REGON wykonawcy w umowie ≠ w ofercie. Redakcyjne, ale wpływa na tożsamość stron → R2/R3.

13. **Dosłowny cytat vs streszczenie w macierzy korelacji** — w macierzy cytujesz zawsze literalnie obie strony (zapis umowy ↔ zapis dokumentu). Nie parafrazujesz. Jeśli cytat jest długi — skracaj, ale zaznacz skrócenie przez `[…]`.

14. **Załączniki do umowy wymienione, ale nie dołączone** — jeżeli umowa wskazuje np. „Załącznik nr 5 — Harmonogram", ale w przekazanym materiale załącznika brak, zapytaj usera: czy user to pominął, czy w umowie jest błąd odesłania. **NIE zakładaj, że „pewnie są u zamawiającego"**. To ryzyko R1/R2 (w zależności od roli załącznika).

15. **Odpowiedzi na pytania wykonawców zmieniające sens PPU** — częsta sytuacja, że po pytaniach wykonawców zmodyfikowano PPU (wzór umowy). Projekt umowy do podpisu musi odzwierciedlać wersję **po modyfikacjach**, a nie pierwotną. Sprawdź chronologicznie wszystkie pisma.

16. **Wybór między formą pisemną a elektroniczną** (art. 432 Pzp) — dla postępowań elektronicznych umowa musi być w formie elektronicznej z kwalifikowanym podpisem. Forma pisemna obok elektronicznej — redundancja; wyłącznie pisemna w postępowaniu elektronicznym = wada formalna.

17. **Klauzule dotyczące podpisu wykonawcy** — jeżeli umowa przewiduje wyłącznie formę pisemną, a wykonawcą jest podmiot zagraniczny — dodatkowe ryzyko operacyjne (nawet jeśli zgodne z ustawą). Rekomenduj elektroniczną.

18. **Sankcje międzynarodowe (art. 5k rozp. 833/2014 + art. 7 ust. 1 ustawy antyrosyjskiej)** — umowa powinna zawierać klauzulę o:
    - prawie odstąpienia w razie objęcia wykonawcy sankcjami,
    - obowiązku wykonawcy powiadomienia zamawiającego o zmianie statusu sankcyjnego,
    - zakazie powierzania sprawy podmiotom objętym sankcjami.

## Common Mistakes

| Błąd | Poprawka |
|------|----------|
| „Umowa jest zgodna z SWZ" bez cytatu | Dodaj `[DOC: SWZ.pdf] [Rozdz. X] [str. Y]` + literalny cytat |
| Proponowane brzmienie w formie opisowej („należy dodać waloryzację") | Zawsze pełny tekst klauzuli gotowy do wklejenia |
| Pomijanie modyfikacji SWZ / odpowiedzi na pytania | Zawsze chronologicznie przeanalizuj wszystkie pisma PRZED Phase 3 |
| Analiza jako jeden plik | Seria 9+ plików obligatoryjna |
| Brak kategoryzacji P1–P7 | Każde znalezisko ma kategorię + poziom ryzyka |
| Ignorowanie art. 433 Pzp (klauzule abuzywne) | Osobna sekcja w analizie szczegółowej punkt „Kary umowne i odpowiedzialność" |
| Pominięcie waloryzacji dla umów > 6 m-cy | Zawsze sprawdź art. 439 Pzp |
| Plain MD bez callouts | Zawsze frontmatter + callouts + wikilinks |
| Cytat parafrazowany zamiast literalnego | Kopiuj dosłownie, z interpunkcją |
| Pominięcie załącznika z umowy „bo pewnie istnieje" | Zapytaj usera o fizyczną obecność |
| Pominięcie RODO dla umów z przetwarzaniem danych | Zawsze art. 28 RODO — osobna weryfikacja |
| „Trzeba poprawić X" bez propozycji konkretnej klauzuli | Każda poprawka ma pełny tekst nowego brzmienia |
| Rekomendacja „do rozważenia" bez jednoznacznego wniosku | W F-sekcji odpowiedzi muszą być jednoznaczne (tak/nie + które poprawki bezwzględnie przed podpisem) |

## Red Flags — STOP and restart

- „Umowa krótka, pominę indeksowanie" — NIE. Zawsze indeks.
- „Znam strukturę umów PZP, nie muszę czytać projektu" — NIE. Czytaj.
- „Pewnie zgodne z SWZ" — NIE. Cytuj i porównuj.
- „Modyfikacje SWZ pominę — pewnie nie mają wpływu" — NIE. Chronologicznie wszystkie.
- „Wystarczy lista poprawek ogólnie" — NIE. Seria dokumentów obligatoryjna.
- „Napiszę 'dodać klauzulę waloryzacji' — user sobie to napisze" — NIE. Cały tekst klauzuli.
- „Brak załącznika pewnie błąd techniczny" — NIE. Zapytaj usera.
- „Rekomendacja: warto rozważyć" — NIE. Jednoznacznie: konieczne/rekomendowane/do rozważenia (z uzasadnieniem).

## Deliverables Checklist — przed zakończeniem

### Dokumenty obligatoryjne (seria 11 plików)

- [ ] `index-umowa.md` — rozkład projektu umowy (każdy § + każdy załącznik)
- [ ] `index-dokumentacja-postepowania.md` — spis całości dokumentacji z opisami (każdy plik co najmniej 2–3 zdania)
- [ ] `00-podsumowanie-wykonawcze-<slug>.md` — 1–2 strony executive summary
- [ ] `01-raport-glowny-<slug>.md` — pełny raport (sekcje I–V)
- [ ] `02-tabela-ustalen-krytycznych-<slug>.md` — tabela B
- [ ] `03-analiza-szczegolowa-<slug>.md` — 15 obszarów (C)
- [ ] `04-macierz-korelacji-<slug>.md` — macierz D
- [ ] `05-proponowane-poprawki-<slug>.md` — **kluczowy** produkt, per P-XXX: cytat oryg. + cytat propozycji + uzasadnienie
- [ ] `06-ocena-ryzyk-<slug>.md` — ryzyka kontraktowe (sekcja V)
- [ ] `07-wnioski-koncowe-<slug>.md` — odpowiedzi na 5 pytań z promptu
- [ ] `08-cytaty-i-zrodla-<slug>.md` — register cytatów (weryfikowany przeciwko [[D20192019Lj]])

### Quality gates (dla KAŻDEGO dokumentu)

- [ ] Frontmatter YAML kompletny (sygnatura, postepowanie, zamawiajacy, wykonawca, data_analizy, autor_analizy, typ_dokumentu, status, tags)
- [ ] Wszystkie znaleziska mają: callout + cytat obecnego brzmienia + kategoria P1-P7 + poziom R1-R4 + podstawa prawna + [jeżeli w pliku `05-*`] propozycja nowego brzmienia + uzasadnienie
- [ ] Wikilinks między dokumentami spójne; wszystkie cele istnieją
- [ ] Brak placeholderów `<<...>>` w gotowych dokumentach
- [ ] Każdy cytat z projektu umowy ma jednostkę redakcyjną (§ N ust. M pkt K lit. L)
- [ ] Każdy cytat z dokumentacji postępowania ma format `[DOC: plik] [Rozdz. N] [str. M]`
- [ ] Rekomendacja końcowa w `07-wnioski-koncowe` jednoznaczna (tak/nie w 5 pytaniach)
- [ ] Wszystkie proponowane brzmienia w `05-proponowane-poprawki` są gotowe do wklejenia (pełny tekst, nie „należy dodać")

### Quality gates — specyficzne dla umowy

- [ ] Sprawdzono art. 433 Pzp (4 pkt — klauzule niedopuszczalne w PPU) — każda kara umowna, każda klauzula odpowiedzialności
- [ ] Sprawdzono art. 436 Pzp (4 obligatoryjne postanowienia: termin, warunki zapłaty, łączny cap kar, dla > 12 m-cy — kary podwykonawcze + mała klauzula waloryzacyjna)
- [ ] Sprawdzono art. 439 Pzp (pełna waloryzacja dla umów > 6 m-cy na roboty/dostawy/usługi)
- [ ] Sprawdzono art. 437 Pzp (dla roboty budowlane — 7 pkt obligatoryjnych dot. podwykonawstwa)
- [ ] Sprawdzono art. 449–453 Pzp (zabezpieczenie NWU: formy art. 450, cap 5% art. 452 ust. 2, zwrot art. 453)
- [ ] Sprawdzono art. 454–455 Pzp (katalog dopuszczalnych zmian umowy)
- [ ] Sprawdzono art. 456 Pzp (odstąpienie — wyłącznie 4 ustawowe przesłanki z ust. 1 pkt 1 + pkt 2 lit. a-c)
- [ ] Sprawdzono art. 442 Pzp (zaliczki) i art. 443 Pzp (płatności częściowe dla umów > 12 m-cy)
- [ ] Sprawdzono art. 462–465 Pzp (podwykonawstwo) + art. 647¹ § 5 k.c. (solidarna odpowiedzialność) — jeśli dotyczy
- [ ] Sprawdzono art. 28 RODO (jeśli dotyczy — przetwarzanie danych)
- [ ] Sprawdzono pr.aut. art. 41, 50, 74 (jeśli dotyczy — IT / projekty)
- [ ] Sprawdzono KSC art. 33, 67b (jeśli dotyczy — ICT)
- [ ] Sprawdzono spójność terminów w umowie ↔ harmonogramie ↔ ofercie
- [ ] Sprawdzono spójność wynagrodzenia w umowie ↔ ofercie (formularz ofertowy)
- [ ] Sprawdzono wszystkie odesłania wewnętrzne („zgodnie z § N", „w myśl ust. M") — brak błędnych odesłań
- [ ] Sprawdzono spis załączników ↔ faktyczne istnienie załączników w materiale
- [ ] Sprawdzono zgodność nazw, dat, NIP, REGON, kwot we wszystkich miejscach

## Naming Conventions — ZAWSZE przestrzegać

### Zasada ogólna separatorów

**Wszędzie myślnik (`-`) jako separator.** Podkreślnika NIE używamy w nowo tworzonych plikach.

### Slug sygnatury postępowania

Taki sam jak w `analyzing-pzp-offers`:

1. Zamień kropki `.` i ukośniki `/ \` na myślnik.
2. Zamień spacje na myślnik.
3. Pozostaw cyfry, litery i myślniki.

**Przykłady:**

- `BL-V.2371.3.2026` → `BL-V-2371-3-2026`
- `BZP/II/78/2026` → `BZP-II-78-2026`

### Slug wykonawcy (dla raportów per wykonawca)

Identyczny jak w `analyzing-pzp-offers`:

- transliteracja polskich znaków → ascii,
- do małych liter,
- usunąć formy prawne (`Sp. z o.o.`, `S.A.`, `GmbH`, …),
- zamienić separatory na `-`,
- zostaw 1–2 pierwsze znaczące słowa.

**Przykłady:**

- `WASKO S.A.` → `wasko`
- `GALAXY SYSTEMY INFORMATYCZNE Sp. z o.o.` → `galaxy`

### Nazwy plików wyjściowych

```
<output_dir>/
├── index-umowa.md
├── index-dokumentacja-postepowania.md
├── 00-podsumowanie-wykonawcze-<slug-sygnatury>.md
├── 01-raport-glowny-<slug-sygnatury>.md
├── 02-tabela-ustalen-krytycznych-<slug-sygnatury>.md
├── 03-analiza-szczegolowa-<slug-sygnatury>.md
├── 04-macierz-korelacji-<slug-sygnatury>.md
├── 05-proponowane-poprawki-<slug-sygnatury>.md
├── 06-ocena-ryzyk-<slug-sygnatury>.md
├── 07-wnioski-koncowe-<slug-sygnatury>.md
└── 08-cytaty-i-zrodla-<slug-sygnatury>.md
```

**Uwaga:** raporty nie mają slug-a wykonawcy — weryfikujemy projekt umowy dla konkretnej sygnatury, niezależnie od tego czy mamy oferty wielu wykonawców. Wykonawca wchodzi jako metadana w frontmatter i w treści, gdy porównujemy z ofertą.

### Wikilinks

- `[[index-umowa]]`, `[[05-proponowane-poprawki-<slug-sygnatury>#P-012]]`
- Nagłówki sekcji w pełnym brzmieniu, bez anchor do komórek tabel
- Block IDs `^P-XXX` przy każdej proponowanej poprawce do cross-referencji z macierzy i tabeli ustaleń

## Integracja z kontekstem KG PSP (`PROJEKTY/PZP/PRAWO/`)

Jeżeli skill jest uruchamiany na maszynie użytkownika z vault KG PSP (katalog `/Users/mklosinski/Documents/GitHub/Legitymacje_OSP/OBSIDIAN/PROJEKTY/PZP/PRAWO/`), wykorzystaj następujące zasoby:

### Weryfikacja cytatów Pzp

- **Plik:** [[D20192019Lj]] (`PROJEKTY/PZP/PRAWO/D20192019Lj.md`) — tekst jednolity ustawy Pzp, Dz.U. 2024 poz. 1320, 11 516 linii, 632 art.
- **Zasada:** każdy cytat art. Pzp w raporcie musi być **literalny** — zweryfikuj przez `Grep` / `Read` w tym pliku przed umieszczeniem w raporcie.

### Porównanie z wewnętrznymi szablonami KG PSP

Standardowe projekty umów w KG PSP bazują na dwóch szablonach (zgodnie z [[index_pzp]]):

- **[[szablon-1-umowa_dostawa]]** (`PROJEKTY/PZP/PRAWO/szablon-1-umowa_dostawa.md`) — wzór umowy dostawy,
- **[[szablon-1-umowa_usluga]]** (`PROJEKTY/PZP/PRAWO/szablon-1-umowa_usluga.md`) — wzór umowy usługi.

W Phase 2 (ekstrakcja wymagań) dodaj do `<output_dir>/wymagania-kontraktowe.md` osobną sekcję „Odstępstwa od szablonu KG PSP":

1. Zidentyfikuj typ umowy (dostawa / usługa) wg przedmiotu zamówienia.
2. Porównaj strukturę projektu umowy (wykaz §) z odpowiednim szablonem.
3. Zanotuj: (a) paragrafy obecne w szablonie, brak w projekcie, (b) paragrafy w projekcie poza szablonem, (c) odstępstwa w treści kluczowych paragrafów.
4. Odstępstwa wymagają uzasadnienia i oznacz je w `05-proponowane-poprawki` jako `P3` / `R2-R3` zależnie od istotności.

**Uwaga:** same szablony KG PSP mogą zawierać pola z publikatorem Pzp do aktualizacji — jeśli szablon cytuje przedawniony publikator (np. `Dz.U. 2019 poz. 2019` bez wskazania tekstu jednolitego), **nie powielaj tego błędu w raporcie** — użyj aktualnego `Dz.U. 2024 poz. 1320 ze zm.`.

### Wewnętrzny obieg parafowania (Regulamin KG PSP § 18)

Zgodnie z § 18 [[regulamin_kg_psp]] projekt umowy **przed podpisaniem** musi zostać zaparafowany przez:

1. **Kierownika komórki organizacyjnej właściwej dla przedmiotu zamówienia** (merytorycznie odpowiedzialnego za treść),
2. **Biuro Prawne KG PSP** (zgodność z Pzp i k.c., ocena ryzyk prawnych),
3. **Biuro Finansów KG PSP** (zgodność finansowa, sprawdzenie wynagrodzenia i płatności).

W `07-wnioski-koncowe` (Pytanie 2 — Status wdrożenia) uwzględnij ten obieg jako 3-stopniową checklistę:

```markdown
### Status wdrożenia (obieg § 18 [[regulamin_kg_psp]])

- [ ] Wszystkie R1 (N) wdrożone w projekcie umowy
- [ ] Parafowanie: kierownik komórki organizacyjnej (<<imię nazwisko>>) — <<data>>
- [ ] Parafowanie: Biuro Prawne KG PSP — <<data>>
- [ ] Parafowanie: Biuro Finansów KG PSP — <<data>>
- [ ] Zaakceptowane przez wykonawcę (jeśli wymaga uzgodnienia)
```

### Zasady redakcji — ZTP

Cytowanie jednostek redakcyjnych zgodnie z [[zasady_redakcji]] (§ 54-63 Zasad techniki prawodawczej):

- **Ustawy / rozporządzenia:** `art. N ust. M pkt K lit. L tiret M`
- **Umowy i akty wewnętrzne:** `§ N ust. M pkt K lit. L` (paragraf zamiast artykułu — konwencja kodeksowa)

## Integracja z istniejącymi skillami

### Powiązanie z `analyzing-pzp-offers`

- **Jeśli** user dostarczył `<analysis_dir>` z raportem wygenerowanym przez `analyzing-pzp-offers`:
  - przeczytaj `03-braki-i-niezgodnosci-<slug>.md` — sprawdź czy są F3a/F3 znaleziska w ofercie, które mogą wpłynąć na treść umowy (poprawa omyłki rachunkowej w ofercie = zmiana ceny w umowie),
  - przeczytaj `06-cytaty-i-zrodla-<slug>.md` — używaj skatalogowanych cytatów dla spójności cytowania,
  - porównaj wnioski z analizy oferty z obecnym stanem projektu umowy — zapis w `04-macierz-korelacji` powinien pokrywać te same punkty, co analiza oferty.
- **Jeśli** `<analysis_dir>` nie istnieje — skill działa samodzielnie, ale w `00-podsumowanie-wykonawcze` odnotuj „brak poprzedniej analizy oferty".

### Powiązanie z `drafting-pzp-letters`

- Po zakończeniu weryfikacji umowy, jeśli wykryto konieczność korekty po stronie wykonawcy (np. dostarczenie uzupełnionych załączników, zgoda na modyfikację klauzuli), **rekomenduj** uruchomienie `drafting-pzp-letters` z odpowiednim typem pisma.
- Typowe sytuacje: wezwanie do zgody na waloryzację, wezwanie do uzgodnienia harmonogramu szczegółowego, zawiadomienie o poprawie omyłki pisarskiej w samej umowie.

## Konwersja plików źródłowych

- **DOCX** (najczęstsze dla projektów umów): użyj skill `convert` lub Read tool (Read tool obsługuje DOCX).
- **PDF tekstowy:** Read tool z `pages:` lub `pdftotext`.
- **PDF obraz / skan:** zapytaj usera o OCR; oznacz w indeksie „PDF obraz — treść niedostępna tekstowo, analiza ograniczona do metadanych".
- **MD:** Read tool bezpośrednio.
- **ZIP:** zapytaj usera o rozpakowanie; nie próbuj automatycznie.
- **XAdES / .sig / .p7s:** oznacz w indeksie jako „podpis zewnętrzny do `<plik>`".

## Supporting Files

- `verification-prompt.md` — **heavy reference** — pełny prompt analityczny (sekcje I–V, zasady pracy, szczegółowy zakres, format odpowiedzi, zasady cytowania, podstawy prawne). Używaj PODCZAS Phase 3–6.
- `templates/index-umowa.md` — rozkład projektu umowy
- `templates/index-dokumentacja-postepowania.md` — indeks dokumentacji
- `templates/00-podsumowanie-wykonawcze.md` — executive summary (A + F skrót)
- `templates/01-raport-glowny.md` — pełny raport I–V
- `templates/02-tabela-ustalen-krytycznych.md` — tabela B
- `templates/03-analiza-szczegolowa.md` — 15 obszarów (C)
- `templates/04-macierz-korelacji.md` — macierz D
- `templates/05-proponowane-poprawki.md` — **kluczowy** template (E)
- `templates/06-ocena-ryzyk.md` — ryzyka V
- `templates/07-wnioski-koncowe.md` — odpowiedzi na 5 pytań (F)
- `templates/08-cytaty-i-zrodla.md` — register

## The Iron Law

**Każda rekomendacja poprawki MUSI zawierać:**

1. **Dokładną lokalizację** w projekcie umowy (§ N ust. M pkt K lit. L).
2. **Literalny cytat obecnego brzmienia** (nie parafraza).
3. **Propozycję pełnego nowego brzmienia** (gotową do wklejenia, nie „należy dodać").
4. **Uzasadnienie prawne** (konkretny artykuł Pzp / k.c. / RODO / KSC / pr.aut.) z aktualnym publikatorem.
5. **Odniesienie do dokumentacji postępowania** (cytat z SWZ/OPZ/oferty/pism) — jeśli poprawka wynika z korelacji.

Naruszenie tej zasady = analiza bez wartości. Zamawiający musi móc przenieść rekomendację 1:1 do projektu umowy.
