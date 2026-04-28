---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa>>"
wykonawca: <<nazwa>>
wykonawca_slug: <<slug-wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
typ_dokumentu: braki-i-niezgodnosci
status: <<draft | final>>
liczba_F1: <<N>>
liczba_F2: <<N>>
liczba_F3: <<N>>
liczba_F4: <<N>>
liczba_F5: <<N>>
liczba_F6: <<N>>
tags:
  - pzp/raport
  - pzp/znaleziska
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
---

# Stwierdzone braki, błędy i niezgodności — Oferta <<wykonawca>>

> [!info] Metryka znalezisk
> - **Liczba znalezisk ogółem:** <<N>>
> - **Kategorie F1–F6:** <<rozkład>>
> - **Data analizy:** <<yyyy-mm-dd>>
> - Każde znalezisko zawiera: wymóg (cytat ze źródła), stan faktyczny w ofercie (cytat), kategorię F, podstawę prawną, sugerowane działanie.

## Struktura znaleziska

Format każdego wpisu:

```markdown
> [!<callout>] #<id> — <krótki tytuł>
> **Kategoria F:** F<1–6> — <nazwa>
> **Podstawa prawna:** art. <N> <ust. N> Pzp / inna
> **Wymóg (źródło):** [DOC: <plik>] [Rozdz. N] [ust. N] [pkt N] [str. N] — „<dosłowny cytat lub parafraza>"
> **Stan oferty (źródło):** [DOC: <plik oferty>] [str. N] — <opis faktyczny + ewentualny cytat>
> **Wpływ:** <wpływ na ocenę oferty>
> **Sugerowane działanie zamawiającego:** <co zrobić, jakie wezwanie, jaki termin>
> **Możliwość uzupełnienia:** <tak / nie — podstawa>
> **Block ID:** ^find-<id>
```

---

## 1. Braki formalne

<<Braki w formularzu, podpisie, pełnomocnictwie, formacie dokumentów. UWAGA: callout i kategoria F zależą od charakteru braku — NIE używaj sztywno `[!warning]`. Stosuj mapę z SKILL.md → Callouts według kategorii F.>>

> [!tip] Mapa callout dla braków formalnych
> - **Brak formularza oferty** → **F5 `[!danger]`** (art. 226 ust. 1 pkt 3 Pzp — niezgodność z ustawą / nieprawidłowo sporządzona oferta; brak formularza = brak ważnego oświadczenia woli). Nieuzupełnialny.
> - **Brak/nieprawidłowy podpis oferty (art. 63 Pzp)** → **F5 `[!danger]`** (art. 226 ust. 1 pkt 4 Pzp — nieważna na podstawie odrębnych przepisów / pkt 6 — niezgodna forma elektroniczna). Nieuzupełnialny.
> - **Brak pełnomocnictwa dla konsorcjum (art. 58 ust. 2 Pzp)** → **F2 `[!warning]`** — uzupełnialny w trybie art. 128 ust. 1 Pzp (pełnomocnictwo jest dokumentem podmiotowym).
> - **Nieprawidłowa forma dokumentów (PDF zamiast DOCX gdy SWZ narzuca)** → **F3 `[!question]`** (art. 223 Pzp — wyjaśnienia) lub **F4 `[!failure]`** jeśli forma rzutuje na treść.
> - **Brak pieczątki / firmowania** → **F1 `[!info]`** — brak nieistotny, nie wpływa na ocenę.
> - **Brak pełnomocnictwa dla osoby podpisującej (jeśli nie wynika z KRS)** → **F2 `[!warning]`** — uzupełnialny, ale UWAGA: pełnomocnictwo musi pochodzić z daty przed upływem terminu składania ofert.

### Przykład wpisu dla braku formularza oferty

> [!danger] #F-001 — Brak formularza oferty (Zał. nr 3 do SWZ)
> **Kategoria F:** F5 — podstawa odrzucenia
> **Podstawa prawna:** art. 226 ust. 1 pkt 3 Pzp
> **Wymóg:** `[DOC: SWZ_z załącznikami.pdf] [Rozdz. XIV] [pkt <<N>>] [str. <<N>>]` — „Oferta składana jest na formularzu stanowiącym Zał. nr 3 do SWZ."
> **Stan oferty:** `[DOC: <<plik oferty>>]` — brak wypełnionego Zał. nr 3; w pakiecie oferty nie ma dokumentu odpowiadającego formularzowi oferty.
> **Wpływ:** Oferta podlega odrzuceniu jako niezgodna z przepisami ustawy (art. 226 ust. 1 pkt 3 Pzp).
> **Sugerowane działanie:** Odrzucić ofertę. Nie jest to brak uzupełnialny (formularz = treść oferty, nie dokument dodatkowy).
> **Możliwość uzupełnienia:** NIE — formularz oferty jest oświadczeniem woli wykonawcy, nie może być uzupełniony po terminie składania ofert.
> ^find-001

### Przykład wpisu dla braku pełnomocnictwa konsorcjum (uzupełnialny)

> [!warning] #F-002 — Brak pełnomocnictwa konsorcjum (art. 58 ust. 2 Pzp)
> **Kategoria F:** F2 — wada uzupełnialna
> **Podstawa prawna:** art. 128 ust. 1 Pzp
> **Wymóg:** `[DOC: SWZ] [Rozdz. <<N>>]` — „W przypadku oferty składanej wspólnie wykonawcy ustanawiają pełnomocnika (…)"
> **Stan oferty:** `[DOC: <<plik>>]` — konsorcjum złożyło ofertę bez pełnomocnictwa wskazującego osobę uprawnioną.
> **Wpływ:** Wada uzupełnialna — wezwanie do uzupełnienia.
> **Sugerowane działanie:** Wezwanie art. 128 ust. 1 Pzp, termin min. 3 dni.
> **Możliwość uzupełnienia:** TAK — dokumenty podmiotowe i pełnomocnictwo uzupełnialne (data pełnomocnictwa musi być jednak przed terminem składania ofert).
> ^find-002

## 2. Braki uzupełnialne (art. 107 ust. 2 / art. 128 ust. 1 Pzp)

<<Przedmiotowe i podmiotowe środki dowodowe, które można uzupełnić na wezwanie>>

> [!warning] #F-0NN — <<Tytuł>>
> **Kategoria F:** F2 — Wada uzupełnialna
> **Podstawa prawna:** <<art. 107 ust. 2 Pzp (przedmiotowe)>> / <<art. 128 ust. 1 Pzp (podmiotowe)>>
> **Wymóg:** <<cytat + źródło>>
> **Stan oferty:** <<...>>
> **Sugerowane działanie:** Wezwanie do uzupełnienia w trybie <<art. X Pzp>>, termin <<N dni>>.
> ^find-0NN

## 3. Braki nieuzupełnialne

> [!failure] #F-0NN — <<Tytuł>>
> **Kategoria F:** F4 lub F5
> **Podstawa prawna:** art. 226 ust. 1 pkt <<N>> Pzp
> **Wymóg:** <<cytat + źródło>>
> **Stan oferty:** <<...>>
> **Wpływ:** Oferta podlega odrzuceniu / brak nie podlega uzupełnieniu (formularz oferty, oświadczenia kryterium oceny).
> ^find-0NN

## 4. Niezgodności techniczne (z OPZ)

<<Parametry techniczne niespełniające minimum OPZ>>

> [!failure] #F-0NN — <<pkt OPZ, krótki opis>>
> **Kategoria F:** F4 — Niezgodność treści (art. 226 ust. 1 pkt 5 Pzp)
> **Wymóg:** `[DOC: Zał nr 1 do SWZ_OPZ.docx] [Część <<A/B/C>>] [pkt <<N>>]` — „<<cytat parametru min.>>"
> **Oferta wykonawcy:** `[DOC: <<plik>>] [str. <<N>>]` — <<oferowana wartość>>
> **Rozbieżność:** <<oferowane X vs. wymagane ≥ Y>>
> **Wpływ:** Oferta niezgodna z warunkami zamówienia — podstawa odrzucenia.
> **Możliwość wyjaśnień (art. 223 Pzp):** <<tak — gdy niejednoznaczność / nie — gdy parametr jest sprzeczny>>
> ^find-0NN

## 5. Niespójności dokumentów oferty

<<Sprzeczności wewnętrzne: formularz vs OPZ vs karty vs załączniki>>

> [!question] #F-0NN — <<Tytuł>>
> **Kategoria F:** F3 — Wymaga wyjaśnienia (art. 223 Pzp)
> **Dokument 1:** `[DOC: <<plik>>] [str. <<N>>]` — „<<cytat>>"
> **Dokument 2:** `[DOC: <<plik>>] [str. <<N>>]` — „<<sprzeczny cytat>>"
> **Sugerowane działanie:** Wezwanie do wyjaśnień w trybie art. 223 ust. 1 Pzp.
> ^find-0NN

## 6. Ryzyka odrzucenia (art. 226 ust. 1 Pzp)

> [!danger] #F-0NN — <<Tytuł>>
> **Kategoria F:** F5 — Podstawa odrzucenia
> **Podstawa:** art. 226 ust. 1 pkt <<N>> Pzp — <<nazwa przesłanki>>
> **Okoliczności:** <<zwięzłe stwierdzenie okoliczności>>
> **Cytaty:** <<źródła potwierdzające>>
> **Wpływ:** Odrzucenie oferty.
> ^find-0NN

## 7. Kwestie wymagające wyjaśnienia (art. 223 Pzp)

> [!question] #F-0NN — <<Tytuł>>
> **Kategoria F:** F3 / F6
> **Pytanie do wykonawcy:** <<precyzyjna treść pytania>>
> **Kontekst:** <<...>>
> **Sugerowany termin wezwania:** <<N dni>>
> ^find-0NN

---

## Zestawienie znalezisk

| ID | Tytuł | Kategoria F | Podstawa prawna | Uzupełnialne | Wpływ |
|----|-------|-------------|------------------|--------------|-------|
| F-001 | <<...>> | F<<N>> | art. <<...>> | <<tak/nie>> | <<...>> |
| F-002 | <<...>> | F<<N>> | art. <<...>> | <<tak/nie>> | <<...>> |
| ... | ... | ... | ... | ... | ... |

## Mapa na sugerowane wezwania

| Wezwanie | Podstawa | Znaleziska objęte | Termin sugerowany |
|----------|----------|-------------------|-------------------|
| Do uzupełnienia przedm. ś.d. | art. 107 ust. 2 Pzp | F-00X, F-00Y | <<N>> dni |
| Do uzupełnienia podmiot. ś.d. | art. 128 ust. 1 Pzp | F-00Z | <<N>> dni |
| Do wyjaśnień treści oferty | art. 223 ust. 1 Pzp | F-00X, F-00Y | <<N>> dni |
| Do wyjaśnień ceny | art. 224 Pzp | F-00Z | <<N>> dni |

## Powiązania

- [[02-tabela-kontrolna-<<slug-wykonawcy>>]] — wiersze odnoszą się do znalezisk `^find-XXX`
- [[05-ocena-ryzyka-<<slug-wykonawcy>>]] — priorytetyzacja znalezisk wg F
- [[06-cytaty-i-zrodla-<<slug-wykonawcy>>]] — lokalizacje wszystkich cytatów
