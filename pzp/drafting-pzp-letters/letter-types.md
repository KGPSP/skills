# Letter Types — katalog typów pism i tabela decyzyjna

Tabela decyzyjna „mam znalezisko z kategorią Fx + kontekst → użyj template Wyy/Zyy/Oyy". Używana w Phase 2 skilla.

## Index

- **W01–W11** — Wezwania (art. 107 / 128 / 223 / 224 / 126 / 220 / 98 / 122 / 128a Pzp)
- **Z01–Z05** — Zawiadomienia (art. 223 ust. 2 / 253 / 255 Pzp)
- **O01–O02** — Odrzucenia / Wykluczenia (art. 226 / 108 / 109 Pzp)

---

## Tabela główna — wybór pisma

| Kod | Nazwa | Podstawa prawna | Termin | Template MD | Priorytet |
|-----|-------|-----------------|--------|-------------|-----------|
| W01 | Wezwanie do uzupełnienia JEDZ / podmiotowych ś.d. | art. 128 ust. 1 Pzp (z uwzględnieniem ograniczeń art. 128 ust. 3) | min. 5 dni | `W01-wezwanie-uzupelnienie-podmiotowe.md` | A |
| W02 | Wezwanie do uzupełnienia przedmiotowych ś.d. | art. 107 ust. 2 Pzp (z uwzględnieniem wyłączeń art. 107 ust. 3) | min. 5 dni | `W02-wezwanie-uzupelnienie-przedmiotowe.md` | A |
| W03 | Wezwanie do wyjaśnień treści oferty | art. 223 ust. 1 Pzp | wyznaczony (rek. 5 dni) | `W03-wezwanie-wyjasnienia-tresci-oferty.md` | A |
| W04 | Wezwanie do wyjaśnień podmiotowych ś.d. | art. 128 ust. 4 Pzp | min. 5 dni | `W04-wezwanie-wyjasnienia-podmiotowe.md` | B |
| W05 | Wezwanie — rażąco niska cena | art. 224 Pzp | min. 5 dni | `W05-wezwanie-wyjasnienia-razaco-niska-cena.md` | A |
| W06 | Wezwanie — skuteczność zastrzeżenia TP | art. 18 ust. 3 Pzp + art. 11 ust. 2 uznk | min. 5 dni | `W06-wezwanie-wyjasnienia-tajemnica.md` | B |
| W07 | Wezwanie do złożenia podmiotowych ś.d. (najwyżej ocenioną) | art. 126 ust. 1 Pzp | min. 10 dni | `W07-wezwanie-zlozenie-sd-najwyzej-oceniona.md` | B |
| W08 | Wezwanie do przedłużenia TZO | art. 220 ust. 3 / 307 ust. 2 Pzp | przed upływem TZO | `W08-wezwanie-przedluzenie-tzo.md` | B |
| W09 | Wezwanie do przedłużenia / wniesienia wadium | art. 220 ust. 4 + 98 Pzp | termin przedłużenia TZO | `W09-wezwanie-przedluzenie-wadium.md` | B |
| W10 | Wezwanie do wymiany podmiotu trzeciego | art. 122 Pzp | wyznaczony (typ. 5-10 dni) | `W10-wezwanie-wymiana-podmiotu-trzeciego.md` | B |
| W11 | Wezwanie — wyjaśnienia certyfikacji (od 12.07.2026) | art. 128a Pzp | min. 5 dni | `W11-wezwanie-wyjasnienia-certyfikat.md` | B |
| Z01 | Zawiadomienie o poprawie omyłki pisarskiej | art. 223 ust. 2 pkt 1 Pzp | Informacyjne | `Z01-zawiadomienie-poprawa-omylki-pisarskiej.md` | A |
| Z02 | Zawiadomienie o poprawie omyłki rachunkowej | art. 223 ust. 2 pkt 2 Pzp | Informacyjne | `Z02-zawiadomienie-poprawa-omylki-rachunkowej.md` | A |
| Z03 | Zawiadomienie o poprawie innej omyłki | art. 223 ust. 2 pkt 3 + ust. 3 Pzp | 3 dni na sprzeciw | `Z03-zawiadomienie-poprawa-omylki-innej.md` | A |
| Z04 | Zawiadomienie o wyborze najkorzystniejszej oferty | art. 253 Pzp | niezwłocznie | `Z04-zawiadomienie-wybor-oferty.md` | B |
| Z05 | Zawiadomienie o unieważnieniu postępowania | art. 255, 260 Pzp | niezwłocznie | `Z05-zawiadomienie-uniewaznienie.md` | B |
| O01 | Informacja o odrzuceniu oferty | art. 226 ust. 1 Pzp (pkt 1-19) | niezwłocznie po decyzji | `O01-informacja-odrzucenie.md` | A |
| O02 | Informacja o wykluczeniu wykonawcy | art. 108 / 109 Pzp + sankcje | niezwłocznie po decyzji | `O02-informacja-wykluczenie.md` | A |

**Priorytet A** = pełny template, gotowy do użycia.
**Priorytet B** = szkielet z nagłówkiem, podstawą prawną, typowym układem i komentarzami `<!-- TODO -->` do rozwinięcia treści merytorycznej dla konkretnego przypadku.

---

## Tabela mapowania: Kategoria F → pismo

| Kategoria F | Typ pisma | Dodatkowe warunki |
|-------------|-----------|-------------------|
| F1 (omyłka pisarska — literówki) | Z01 | Gdy omyłka jest w samej ofercie wykonawcy. Gdy w wzorze SWZ — adnotacja w protokole, pismo fakultatywne. |
| F2 (uzupełnienie JEDZ / podmiotowych ś.d.) | W01 | PRZED W01 sprawdź art. 128 ust. 3 — ograniczenie, że uzupełnienie nie może służyć potwierdzeniu kryteriów selekcji. |
| F2p (uzupełnienie przedmiotowych ś.d.) | W02 | PRZED W02 sprawdź SWZ — czy zamawiający przewidział uzupełnianie (art. 107 ust. 2). Sprawdź wyłączenia art. 107 ust. 3 (kryteria oceny ofert, oferta i tak podlega odrzuceniu, przesłanki unieważnienia). |
| F3 — wyjaśnienie treści oferty | W03 | Niedopuszczalne negocjacje ani zmiana treści. |
| F3 — wyjaśnienie podmiotowych ś.d. | W04 | Tylko gdy dokumenty są złożone, ale niejasne. Brak dokumentu = W01, nie W04. |
| F3 — rażąco niska cena | W05 | Próg 30% od wartości zam. + VAT lub średniej ofert niepodlegających odrzuceniu. |
| F3 — tajemnica przedsiębiorstwa | W06 | Wezwanie do wykazania 3 przesłanek z art. 11 ust. 2 uznk. |
| F3a — omyłka rachunkowa | Z02 | Zamawiający poprawia + zawiadamia; brak terminu sprzeciwu. |
| F3a — omyłka inna (niepowodująca istotnych zmian) | Z03 | Termin sprzeciwu 3 dni; sprzeciw = O01 art. 226 ust. 1 pkt 11. |
| F4 (niezgodność z warunkami zamówienia) | W03 najpierw, O01 potem | **Nigdy od razu O01.** Zawsze daj wykonawcy szansę wyjaśnień. |
| F5 (inne podstawy odrzucenia art. 226) | O01 | Zweryfikuj przesłankę literalnie. Dodaj pouczenie o środkach ochrony prawnej. |
| F5w (wykluczenie) | O02 **po weryfikacji self-cleaning** | Art. 110 Pzp — sprawdź JEDZ / oświadczenia. Jeśli self-cleaning jest — eskalacja do F6, nie generuj O02. |
| F6 (wymaga analizy prawnej) | — | Eskalacja do prawnika. Skill nie generuje pisma. |

---

## Reguły grupowania znalezisk (MANDATORY)

**Zasada naczelna:** jedno pismo = jedna podstawa prawna. Nigdy nie łącz:
- art. 223 ust. 1 z art. 128 ust. 1 (różne instytucje: wyjaśnienia ≠ uzupełnienie)
- art. 223 ust. 1 z art. 107 ust. 2 (treść oferty ≠ przedmiotowe ś.d.)
- art. 128 ust. 1 z art. 107 ust. 2 (podmiotowe ≠ przedmiotowe)
- art. 224 (RNC) z art. 223 ust. 1 (RNC zawsze samodzielnie)
- art. 18 ust. 3 (tajemnica) z cokolwiek innym

**Dopuszczalne agregacje (w jednym piśmie):**
- Wszystkie F3 z art. 223 ust. 1 — jedno W03 z wypunktowanymi żądaniami.
- Wszystkie F2 z art. 128 ust. 1 — jedno W01.
- Wszystkie F2p z art. 107 ust. 2 (dla tego samego wykonawcy) — jedno W02.
- Wszystkie F1 dotyczące omyłek w samej ofercie wykonawcy — jedno Z01.
- Wszystkie F4 (niezgodności z WZ) rozpatrywane na etapie wyjaśnień — dołączone do W03 z art. 223 ust. 1 jako punkty do wyjaśnienia.

**Niedopuszczalne agregacje:**
- F3a (omyłka) w tym samym piśmie co F1 (omyłka pisarska) — różne tryby (Z02/Z03 vs Z01), różne terminy sprzeciwu.
- F5w (wykluczenie) z F5 (inne odrzucenie) — O01 ≠ O02.
- Wezwanie do wyjaśnień łącznie z informacją o odrzuceniu — logicznie wykluczające się.

---

## Typowa struktura pisma (każdego typu)

Skill wypełnia sekcje w następującej kolejności:

```
1. [Nagłówek — z szablonu DOCX, statyczny: "Biuro Informatyki i Łączności"]
2. Sygnatura pisma (podstawia się w zakładce ezdSprawaZnak)
3. Miejscowość, data (ezdDataPodpisu)
4. Adresat (nazwa wykonawcy + adres z oferty)
5. Sygnatura postępowania (dosłowna; np. "BL-V.2371.3.2026")
6. Tytuł pisma (np. "Wezwanie do wyjaśnień treści oferty")
7. Wstęp normatywny (powołanie podstawy prawnej)
8. Stan faktyczny (cytaty wymogu + cytaty oferty + ocena — per znalezisko)
9. Żądanie (wypunktowane, w imperatywie normatywnym)
10. Termin odpowiedzi (konkretny, z odwołaniem do platformy)
11. Pouczenie o skutkach (literalny opis skutku prawnego)
12. Środki ochrony prawnej (tylko O01, O02, Z04, Z05)
13. Podpis (ezdPracownikNazwa, ezdPracownikAtrybut1-3)
14. Załączniki (lista lub "nie dotyczy")
15. Otrzymują (wykonawca + a/a)
```

---

## Przykłady — kazus WASKO (BL-V.2371.3.2026)

Dane wejściowe: `03-braki-i-niezgodnosci-wasko.md` (7 kategorii znalezisk K1–K7).

### Znaleziska WASKO → pisma

**Z01 (omyłki pisarskie, F1):**
- K1.F1.1 — Znak sprawy "BF-IV" w Zał. 3, 9, 10 (wzór SWZ — w tym zakresie adnotacja protokolarna, nie pismo do wykonawcy)
- K1.F1.2 — Literówka "www.wsko.pl" w JEDZ → Z01 (pismo fakultatywne; ale poprawka wymagana art. 223 ust. 2 pkt 1)

**W01 (uzupełnienie JEDZ, F2):**
- K2.1 — Podwykonawstwo "Nie" w JEDZ WASKO (sprzeczne z Zał. 6 Cloudware) → W01 z żądaniem zmiany na "Tak" + wskazanie Cloudware

**W03 (wyjaśnienia treści oferty, F3 + F4):**
- K4.1 — ASHRAE A2 zamiast A1 (F4 → W03 najpierw, potem ewentualnie O01)
- K4.2 — PDU 1-faz niezgodne z B.1 2N (F4 → W03 najpierw)
- K4.3 — Niekompletny plan testów A.10 (F4 → W03 lub W02 w zależności od weryfikacji SWZ)
- K5.1 — Status MŚP: formularz vs JEDZ (F3 → W03, następnie Z01 gdy WASKO wyjaśni)
- K5.2 — LiteLLM vs Envoy Gateway (F3 → W03)
- K5.3 — NVMe U.2 vs E1.S (F3 → W03, wyjaśnienie + ew. oświadczenie o równoważności art. 99 ust. 5)
- K6.1 — Art. 118 ust. 2 Pzp — zakres Cloudware (F3/F4 → W03, priorytet najwyższy)
- K7.1 — Pełnomocnictwo Cloudware "wobec WASKO" (F3 → W03, wykładnia celowościowa)
- K7.2 — A.6: liczba serwerów + RAID1 NVMe (F3 → W03)
- K7.3 — C.1 UPS: konfiguracja + autonomia (F3 → W03)
- K7.4 — C.2 agregat: interpretacja "mocy ciągłej" (F3 → W03)
- K7.5 — C.1 ATS: konkretny frame ATyS p (F3 → W03)
- K7.6 — B.3 szafy 600×1200 (F3 → W03)

**F6 (analiza prawna, bez pisma):**
- K7.7 — UBO dostawców CLICO, ASBIS (F6 — obowiązek Zamawiającego, nie wada oferty)
- K7.8 — "Signature Not Verified" (F6 — analiza techniczna podpisów eIDAS)

**Rezultat dla WASKO (pisma):**
1. **W03** — wezwanie do wyjaśnień treści oferty (13 punktów — K4.1, K4.2, K4.3*, K5.1, K5.2, K5.3, K6.1, K7.1, K7.2, K7.3, K7.4, K7.5, K7.6)
   *(K4.3 — jeśli SWZ przewiduje uzupełnianie przedmiotowych ś.d. → W02 zamiast W03; jeśli nie — wyjaśnienie jako element W03)*
2. **W01** — wezwanie do uzupełnienia JEDZ (1 punkt — K2.1, podwykonawstwo)
3. **Z01** — zawiadomienie o poprawie omyłki pisarskiej w JEDZ (1 punkt — K1.F1.2)

**NIE generujemy dla WASKO:**
- O01 (brak podstaw bezwarunkowego odrzucenia; F4 idą najpierw przez W03)
- O02 (brak przesłanek wykluczenia)
- W02 (oddzielne, zależne od weryfikacji SWZ dla K4.3)
- W05 (cena 21,2 mln brutto nie odstaje, ocena dopiero po otwarciu wszystkich ofert)
- W07 (dopiero gdy WASKO = najwyżej oceniona)

**Kolejność wysyłki:**
1. Krok 1 (równolegle): Z01 + W01 + W03.
2. Krok 2 (po odpowiedzi WASKO): ocena wyjaśnień F4 → decyzja O01 art. 226 ust. 1 pkt 5 (jeśli niewystarczające).
3. Krok 3 (jeśli WASKO = najwyżej oceniony): W07 art. 126 ust. 1 (min. 10 dni).

---

## Matryca konfliktowa — co z czym się wyklucza w ramach jednego pisma

|     | W01 | W02 | W03 | W04 | W05 | W06 | Z01 | Z02 | Z03 | O01 | O02 |
|-----|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **W01** | OK  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  |
| **W02** |     | OK  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  |
| **W03** |     |     | OK  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  |
| **W04** |     |     |     | OK  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  |
| **W05** |     |     |     |     | OK  | ❌  | ❌  | ❌  | ❌  | ❌  | ❌  |
| **W06** |     |     |     |     |     | OK  | ❌  | ❌  | ❌  | ❌  | ❌  |
| **Z01** |     |     |     |     |     |     | OK  | ❌  | ❌  | ❌  | ❌  |
| **Z02** |     |     |     |     |     |     |     | OK  | ❌  | ❌  | ❌  |
| **Z03** |     |     |     |     |     |     |     |     | OK  | ❌  | ❌  |
| **O01** |     |     |     |     |     |     |     |     |     | OK  | ❌  |
| **O02** |     |     |     |     |     |     |     |     |     |     | OK  |

**Wszystkie pola poza diagonalą = ❌.** Każdy typ pisma pisze się osobno. Nie ma „pism zintegrowanych".

---

## Checklist Phase 2 (kwalifikacja prawna)

Dla KAŻDEGO znaleziska z `03-braki-i-niezgodnosci-<slug>.md`:

- [ ] Odczytano kategorię F (F1/F2/F2p/F3/F3a/F4/F5/F5w/F6) z callouta.
- [ ] Sprawdzono podstawę prawną z callouta (zacytowaną w analizie).
- [ ] Zweryfikowano warunki eskalacji:
  - F2 → art. 128 ust. 3 (kryteria selekcji)?
  - F2p → art. 107 ust. 2 przewidziany w SWZ? + art. 107 ust. 3 (kryteria oceny)?
  - F4 → najpierw W03, potem ewentualnie O01?
  - F5w → sprawdzono self-cleaning (art. 110)?
- [ ] Zdecydowano o docelowym typie pisma (kod W/Z/O).
- [ ] Zgrupowano z innymi znaleziskami tego samego typu (wspólna podstawa prawna).
- [ ] Oznaczono F6 jako eskalację (brak pisma).

Po przejściu checklisty — grupy znalezisk są gotowe do Phase 3 (projekt treści `.md`).
