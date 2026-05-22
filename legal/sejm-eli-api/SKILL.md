---
name: sejm-eli-api
version: v1.0.0
description: Use when grounding any claim about Polish legal acts in the official Sejm ELI API (api.sejm.gov.pl/eli) — fetch act metadata, status, dates, references, table of contents, or the literal text by Dz.U./M.P. citation, search acts by title/keyword, or import an act into an Obsidian vault. Triggers include "sprawdź akt w ELI", "pobierz metadane Dz.U.", "jaki status ma ustawa", "czy akt obowiązuje", "ELI Sejm API", "api.sejm.gov.pl", "znajdź akt po tytule", "Dz.U. <rok> poz. <nr>", "M.P. <rok> poz. <nr>", "importuj akt do Obsidian", "weryfikacja cytatu przepisu względem źródła", whenever a task needs authoritative, machine-readable metadata about a Polish statute/regulation rather than a full legal opinion.
trigger:
  - "sprawdź akt w ELI / Sejm API"
  - "pobierz metadane Dz.U. / M.P."
  - "jaki status ma ustawa / czy obowiązuje"
  - "Dz.U. <rok> poz. <nr>"
  - "M.P. <rok> poz. <nr>"
  - "znajdź akt prawny po tytule / słowie kluczowym"
  - "pobierz treść / spis treści aktu (text.html / struct)"
  - "zweryfikuj cytat przepisu względem źródła urzędowego"
  - "importuj akt do Obsidian (ELI → notatka)"
do-not-trigger-for:
  - "sporządź pełną opinię prawną / analizę z hipotezami — użyj legal/opinie-prawne"
  - "wytłumacz po ludzku, co mówi przepis (bez sięgania do źródła)"
  - "napisz pismo PZP (wezwanie/odrzucenie) — użyj skilli z pzp/"
  - "interpretacja / wykładnia normy bez potrzeby metadanych źródłowych"
  - "research orzecznictwa SN/NSA/TK (to nie ELI — użyj WebSearch w opinie-prawne)"
  - "tłumaczenie aktu na inny język"
model: claude-opus-4-7
allowed-tools: ['Bash', 'Read', 'Write', 'WebFetch', 'Glob', 'Grep', 'TodoWrite']
sources:
  - DOC/material_skill.md
  - DOC/since_skill.md
  - DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md
size-limit: 500-lines-hard
---

# sejm-eli-api — komunikacja z urzędowym źródłem prawa (Sejm ELI API)

> [!quote] Anti-Laziness (since_skill.md §6)
> Najwyższa waga rzetelności źródła. **Nie zgaduj metadanych ani URL-i.** Każde twierdzenie o akcie (status, daty, brzmienie) musi pochodzić z odpowiedzi API zwróconej **w tej sesji** — nie z wiedzy parametrycznej.

> [!important] 5 Non-negotiables (material_skill.md §8)
> 1. Uwidaczniaj założenia (np. domniemany publikator) przed wywołaniem API.
> 2. Zatrzymaj się, gdy cytowanie jest niejednoznaczne — najpierw `/eli/acts`.
> 3. Wybieraj rozwiązanie nudne: oficjalne endpointy ELI, nie scraping ani zmyślone URL-e.
> 4. Dostarczaj dowód: surowy fragment JSON / kod HTTP, nie parafrazę.
> 5. Dotykaj tylko tego, o co poproszono (metadane vs. pełna opinia → to różne skille).

## Czym jest ten skill (i czym nie jest)

To **warstwa pozyskania i ugruntowania (retrieval/grounding)**: rozmawia z `https://api.sejm.gov.pl/eli`, oficjalnym API Sejmu opartym o standard ELI (European Legislation Identifier), aby dostarczyć **maszynowo czytelne, urzędowe metadane** aktów prawnych RP.

- **Tu:** identyfikacja aktu, status, daty, references, spis treści, treść HTML/PDF, wyszukiwanie, import do Obsidian.
- **Nie tu:** wykładnia, hipotezy interpretacyjne, opinia prawna → **REQUIRED SUB-SKILL:** `legal/opinie-prawne` (ten skill bywa jego fazą deep-research R2 — pozyskanie literalnego brzmienia).

**Strefa kalibracji (INSTRUKCJA §6):** odczyt z API = strefa wolna. **Zapis do vaulta Obsidian** (Faza 6) = operacja generatywna — uruchamiana wyłącznie na jawne żądanie i z `--vault` wskazanym przez użytkownika (nigdy ścieżka domyślna „na ślepo").

## Stałe

```text
BASE = https://api.sejm.gov.pl/eli
Publikatory (z /eli/acts): DU = Dziennik Ustaw (Dz.U.), MP = Monitor Polski (M.P.)
```

> Endpointy poniżej zweryfikowano `curl`-em **2026-05-22**. Pełny katalog z kształtem odpowiedzi: `references/endpoints.md`. Zawsze potwierdzaj kod 200 zanim zacytujesz dane.

## Procedura (Process over Prose)

Utwórz `TodoWrite` z fazami, które realnie wystąpią w zadaniu (proste „mam Dz.U. X poz. Y" → Fazy 0,3,5).

### Faza 0 — Parsowanie cytowania
1. Wyodrębnij `(publisher, year, position)` z tekstu użytkownika.
   - `Dz.U. 2024 poz. 1222` → `DU / 2024 / 1222`; `M.P. 2025 poz. 10` → `MP / 2025 / 10`.
   - Forma skrótowa `DU/2024/1222` lub `DU 2024 1222` też dozwolona.
2. Jeśli brakuje pozycji lub publikator nieoczywisty → **nie zgaduj**, przejdź do Fazy 1/2.

**Exit:** trójka `(publisher, year, pos)` albo jawna decyzja „brak — wymagane wyszukanie".

### Faza 1 — Rozpoznanie publikatora (gdy nie DU/MP oczywiste)
```sh
curl -sS "$BASE/acts" | python3 -m json.tool   # albo: scripts/eli-fetch.sh publishers
```
Z odpowiedzi odczytaj `code` właściwego publikatora. **Nie zakładaj** kodu spoza listy.

**Exit:** potwierdzony `code` publikatora (np. `DU`, `MP`).

### Faza 2 — Wyszukanie aktu (gdy brak pozycji)
```sh
curl -sS "$BASE/acts/search?title=<fraza-url-encoded>&limit=10" | python3 -m json.tool
# scripts/eli-fetch.sh search "Prawo zamówień publicznych"
```
Odpowiedź: `{count, items[], offset, totalCount, searchQuery}`. Wybierz pozycję po `displayAddress`/`title`/`status`. Przy `totalCount > limit` paginuj `offset`.

**Exit:** wskazany `address`/`displayAddress` jednego konkretnego aktu (lub krótka lista kandydatów do potwierdzenia przez użytkownika).

### Faza 3 — Pobranie metadanych (rdzeń)
```sh
curl -sS "$BASE/acts/${PUB}/${YEAR}/${POS}" | python3 -m json.tool
# scripts/eli-fetch.sh meta DU 2024 1222
```
Kluczowe pola: `address`, `displayAddress`, `title`, `type`, `status`, `inForce`, `announcementDate`, `promulgation`, `entryIntoForce`, `changeDate`, `textHTML`, `textPDF`, `keywords`, `references`, `prints`.

**Exit:** zapisany obiekt metadanych z kodem HTTP 200; odnotowane `status` + `changeDate` (świeżość).

### Faza 4 — Treść / struktura / relacje (gdy zadanie tego wymaga)
- Brzmienie literalne: `…/${POS}/text.html` (gdy `textHTML:true`) lub `…/text.pdf` (gdy `textPDF:true`).
- Spis treści (part→chpt→arti→ust/pkt): `…/${POS}/struct`.
- Relacje (uchylające/zmieniające/wykonawcze): `…/${POS}/references`.

**Najpierw sprawdź booleany `textHTML`/`textPDF` w metadanych**, dopiero potem pobieraj. Nie wymyślaj wariantów ścieżki — dozwolone tylko zweryfikowane (`references/endpoints.md`).

**Exit:** pobrany artefakt (HTML/PDF/struct/references) z kodem 200 — albo jawna adnotacja „tekst niedostępny wg metadanych".

### Faza 5 — Grounding twierdzeń
1. Każde twierdzenie o akcie cytuje konkretne pole: `displayAddress`, `title`, `status`, `inForce`, `entryIntoForce`, `changeDate`.
2. Cytat **brzmienia** przepisu = fragment z `text.html`/`text.pdf` (literalnie), nigdy z pamięci.
3. Kontekst legislacyjny → `prints[].linkPrintAPI`, `prints[].linkProcessAPI`.

**Exit:** odpowiedź, w której każde twierdzenie ma przypięte źródłowe pole/fragment + link `source_api`.

### Faza 6 — Import do Obsidian (tylko na żądanie)
```sh
scripts/import-eli-act.py --vault "<ścieżka-vaulta>" DU 2024 1222
scripts/import-eli-act.py --vault "<ścieżka-vaulta>" "Dz.U. 2024 poz. 1222"
scripts/import-eli-act.py --vault "<ścieżka-vaulta>" --force DU 2024 1222
```
Domyślny output: `PRAWO/akty/<pub>/<rok>/<pos>.md` (frontmatter z polami źródłowymi + surowy JSON). Szczegóły formatu i pól: `references/obsidian-import.md`.

**Exit:** plik notatki zapisany; `stdout` skryptu (JSON `{ok, output, displayAddress, status}`) pokazany jako dowód.

## Quick reference — endpointy (skrót)

| Cel | Wzorzec | Kod (2026-05-22) |
|-----|---------|------------------|
| Lista publikatorów | `GET /acts` | 200 (list) |
| Lista aktów w roku | `GET /acts/{pub}/{year}` | 200 |
| **Metadane aktu** | `GET /acts/{pub}/{year}/{pos}` | 200 |
| Treść HTML | `GET /acts/{pub}/{year}/{pos}/text.html` | 200 `text/html` |
| Treść PDF | `GET /acts/{pub}/{year}/{pos}/text.pdf` | 200 `application/pdf` |
| Spis treści | `GET /acts/{pub}/{year}/{pos}/struct` | 200 (list) |
| Relacje | `GET /acts/{pub}/{year}/{pos}/references` | 200 |
| Wyszukiwarka | `GET /acts/search?title=…&limit=N&offset=M` | 200 |

Pełny opis pól i kształtu odpowiedzi → **załaduj `references/endpoints.md`** gdy potrzebujesz parametrów wyszukiwarki, pełnej listy pól metadanych lub struktury `struct`.

## Anti-Rationalization — blokady na drogi-na-skróty

Riposta = **blokada, nie sugestia**.

| Wymówka | Riposta (blokada) |
|---------|-------------------|
| „Znam numer Dz.U. z pamięci, nie sprawdzam" | Odrzucono. Pozycje i statusy bywają mylone, akty uchylane. Wywołaj Fazę 3 albo dane nie istnieją. |
| „Zmyślę URL tekstu, pewnie taki jest" | Odrzucono. Tylko endpointy z `references/endpoints.md`. Najpierw booleany `textHTML/textPDF`, potem 200. |
| „Status się nie zmienił od mojej wiedzy" | Odrzucono. `changeDate` rozstrzyga świeżość. Pobierz metadane teraz — status może być „uchylony". |
| „ISAP/Google wystarczy zamiast ELI" | Odrzucono. To skill o **ELI Sejm API** jako źródle maszynowym. ISAP/web → inny przepływ (opinie-prawne). |
| „Sparafrazuję brzmienie przepisu" | Odrzucono. Parafraza ≠ cytat. Brzmienie wyłącznie z `text.html`/`text.pdf`, literalnie. |
| „Zaimportuję od razu do domyślnego vaulta" | Odrzucono. Zapis tylko na żądanie i z `--vault` wskazanym przez użytkownika (Scope Discipline). |
| „API nie odpowiada, podam z pamięci" | Odrzucono. Błąd HTTP = brak danych. Zgłoś kod błędu, nie halucynuj metadanych. |

## Caveats

- **Brak OpenAPI/Swagger** pod `/docs`, `/swagger-ui`, `/openapi.json`, `/v3/api-docs` (sprawdzone 2026-05-22). Endpointy dokumentuje `references/endpoints.md` — rozszerzaj go tylko o ścieżki zweryfikowane `curl`-em w sesji.
- **Świeżość:** zawsze pobieraj metadane przed odpowiedzią — `status`, `changeDate`, `references` zmieniają się.
- **Źródło vs. interpretacja:** to skill pozyskania metadanych. Ocena prawna, wykładnia, hipotezy → `legal/opinie-prawne`. Nie mieszaj warstw.
- **ELI a publikator:** ELI Sejm API odzwierciedla Dz.U./M.P.; przy sporze o obowiązywanie ostateczny jest publikator urzędowy (art. 88 Konstytucji) — odnotuj, jeśli istotne.

## Definition of Done

- [ ] Cytowanie sparsowane lub akt jednoznacznie wskazany (Faza 0/1/2).
- [ ] Metadane pobrane z kodem **HTTP 200** w tej sesji (Faza 3) — surowy fragment JSON w dowodzie.
- [ ] `status` + `changeDate` odnotowane (świeżość potwierdzona).
- [ ] Brzmienie przepisu (jeśli cytowane) pochodzi z `text.html`/`text.pdf`, nie z pamięci.
- [ ] Każde twierdzenie ma przypięte źródłowe pole + `source_api` URL.
- [ ] Import do Obsidian (jeśli zlecony): plik zapisany + `stdout` skryptu pokazany; `--vault` jawnie podany.
- [ ] Żadnego zmyślonego URL-a/numeru — wszystko zweryfikowane endpointami z `references/endpoints.md`.

## Pliki pomocnicze — reguły ładowania (Progressive Disclosure)

Ładuj referencję **tylko gdy spełniony warunek**.

| Plik | Załaduj gdy |
|------|-------------|
| [references/endpoints.md](references/endpoints.md) | Potrzebujesz parametrów wyszukiwarki, pełnej listy pól metadanych, kształtu `struct`/`references` lub chcesz dodać/zweryfikować endpoint. |
| [references/obsidian-import.md](references/obsidian-import.md) | Faza 6 — import do vaulta: pola frontmatter notatki, układ katalogów, opcje skryptu. |
| [scripts/eli-fetch.sh](scripts/eli-fetch.sh) | Szybkie, ad-hoc wywołania (`publishers`/`search`/`meta`/`text`/`struct`) bez ręcznego sklejania URL. |
| [scripts/import-eli-act.py](scripts/import-eli-act.py) | Materializacja aktu jako notatki Obsidian z frontmatterem źródłowym. |

## Sources

- [DOC/material_skill.md](../../DOC/material_skill.md) — Process over Prose, Anti-Rationalization, DoD (dowód nie deklaracja), Scope Discipline (§8 Non-negotiables).
- [DOC/since_skill.md](../../DOC/since_skill.md) — token budget / Progressive Disclosure, Negative Triggers, Anti-Laziness, scripts/ jako narzędzia deterministyczne, kalibracja stref.
- [DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md](../../DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md) — struktura katalogu, szablon frontmatter, checklista §9.
- Powiązany skill: `legal/opinie-prawne` (warstwa interpretacji; ten skill bywa jej fazą R2).
