# weryfikacja-umow-pzp

> Audyt projektu umowy / PPU w reżimie PZP przed podpisaniem. **Dla każdej wykrytej wady: cytat obecnego brzmienia + pełne proponowane brzmienie + uzasadnienie prawne.** Output: seria 11 dokumentów analitycznych.

[![version](https://img.shields.io/badge/version-v1.1.0-blue)]() [![size](https://img.shields.io/badge/SKILL.md-480%2F500_lines-green)]() [![domena](https://img.shields.io/badge/domena-PZP-orange)]()

---

## Co to jest

Skill dla Claude Code prowadzący **pogłębioną kontrolę kontraktową** projektu umowy (lub projektowanych postanowień umowy — PPU) z perspektywy zamawiającego publicznego, na etapie po wyborze oferty a przed podpisaniem. Centralny produkt to `05-proponowane-poprawki-<slug>.md` — **dla każdej wady para: literalny cytat obecnego brzmienia → pełne brzmienie proponowane (gotowe do wklejenia) → uzasadnienie**.

Centralna zasada (**Iron Law**): *każda rekomendacja poprawki zawiera dokładną lokalizację (§ N ust. M), literalny cytat oryginału, pełne nowe brzmienie, uzasadnienie prawne (art. Pzp/k.c./RODO/KSC/pr.aut.) i odniesienie do dokumentacji postępowania.* Zamawiający musi móc przenieść rekomendację 1:1 do umowy.

## Kiedy używać

✅ **TAK** — gdy:
- Masz projekt umowy + folder z dokumentacją postępowania (SWZ, OPZ, oferta, pisma) i chcesz weryfikacji przed podpisaniem.
- Trwa etap **po wyborze oferty, przed podpisaniem** — klasyczny moment kontroli.
- Potrzebujesz listy konkretnych poprawek z cytatami oryginału i proponowanym brzmieniem.

❌ **NIE** — gdy:
- Umowy poza reżimem PZP (cywilnoprawne, wewnętrzne, darowizny).
- Umowy już zawarte → analiza aneksu/zmiany (art. 454–455) lub odstąpienia (art. 456) ma odrębne podejście.
- Analiza samego SWZ/OPZ bez projektu umowy; wstępny szkic przed publikacją SWZ.
- Weryfikacja oferty → `analyzing-pzp-offers`. Pisma do wykonawcy → `drafting-pzp-letters`.

Pełna lista w [SKILL.md `do-not-trigger-for`](SKILL.md).

## Jak uruchomić

```
sprawdź projekt umowy — umowa <ścieżka>, postępowanie <ścieżka>
```

Triggery: `sprawdź projekt umowy`, `zweryfikuj wzór umowy`, `przeanalizuj PPU`, `czy umowa zgodna z SWZ`, `audyt umowy przed podpisaniem`, `kontrola umowy w reżimie PZP`.

## Workflow — 7 faz

| Faza | Cel | Exit |
|------|-----|------|
| 0 | Walidacja wejścia | `<contract_path>` potwierdzony, dokumenty rozpoznane, `TodoWrite` |
| 1 | **Indeksacja** (umowa + dokumentacja) | `index-umowa.md` + `index-dokumentacja-postepowania.md` |
| 2 | Ekstrakcja wymagań kontraktowych | katalog wymagań z źródłem i brzmieniem po modyfikacjach |
| 3 | Analiza umowy (sekcje I–V) | znaleziska sklasyfikowane (P1–P7 + R1–R4) z cytatami |
| 4 | Macierz korelacji | `04-macierz-korelacji` — zapis umowy ↔ dokument ↔ status |
| 5 | **Proponowane poprawki** (cytat → cytat) | `05-proponowane-poprawki` — kluczowy produkt |
| 6 | Generowanie raportu A–F + addendów | komplet 11 dokumentów + rekomendacja |

Phase 2 ma **precondition check** — bez indeksów analiza nieważna.

## Output — seria 11 dokumentów

`index-umowa`, `index-dokumentacja-postepowania`, `00-podsumowanie-wykonawcze`, `01-raport-glowny`, `02-tabela-ustalen-krytycznych`, `03-analiza-szczegolowa`, `04-macierz-korelacji`, `05-proponowane-poprawki`, `06-ocena-ryzyk`, `07-wnioski-koncowe`, `08-cytaty-i-zrodla`.

**Klasyfikacja**: kategorie problemu **P1–P7** (formalny / prawny / Pzp / redakcyjny / logiczny / operacyjny / brak korelacji), poziomy ryzyka **R1–R4** (krytyczne → drobne).

## Kluczowe pryncypia

- **Iron Law** — każda poprawka: lokalizacja + cytat oryginału + pełne nowe brzmienie + uzasadnienie + korelacja z dokumentacją.
- **Proponowane brzmienie wstawialne** — pełny tekst klauzuli, nie „należy dodać waloryzację".
- **Modyfikacje SWZ nadrzędne** — wersja PPU po modyfikacjach wiąże projekt do podpisu.
- **Kontrola obligatoryjnych klauzul** — art. 433 (abuzywne), 436/437 (obligatoryjne), 439 (waloryzacja >6 m-cy), 449–453 (zabezpieczenie), 454–456 (zmiany/odstąpienie), 28 RODO, pr.aut., KSC.
- **Anti-Rationalization** — 9 wymówek z blokadami.

## Struktura plików

```
weryfikacja-umow-pzp/
├── README.md                          ← ten plik
├── SKILL.md                           ← główny prompt (480/500 linii)
├── CHANGELOG.md
├── references/
│   ├── verification-prompt.md         ← heavy ref: sekcje I–V, format (Phase 3–6)
│   ├── legal-basis-catalog.md         ← art. 431–465 Pzp + k.c./RODO/KSC/pr.aut. (przed Phase 2)
│   ├── edge-cases.md                  ← 18 przypadków + Common Mistakes (Phase 3)
│   ├── format-obsidian.md             ← frontmatter, callouts (Phase 6)
│   └── kg-psp-integration.md          ← weryfikacja [[D20192019Lj]], parafowanie §18, ZTP
└── templates/                         ← index-umowa, index-dokumentacja + 00–08
```

## Wymagania

- **Claude Code** (CLI lub IDE plugin).
- Projekt umowy + folder dokumentacji postępowania (lokalnie).
- Opcjonalnie: tekst jednolity ustawy Pzp w `{prawo_dir}` ([[D20192019Lj]]) do literalnej weryfikacji cytatów.

## Wersjonowanie

- **v1.0.0** — pierwsze wydanie (audyt umowy, pary cytat→propozycja, P1–P7/R1–R4, art. 431–465).
- **v1.1.0** — domknięcie zgodności z `DOC/`: **SKILL.md 703 → 480 linii** (4 ciężkie bloki wyniesione do `references/`), frontmatter kanoniczny, exit criteria, tabela Anti-Rationalization, Definition of Done, reguły ładowania L3; **fixy**: sparametryzowana ścieżka (`{prawo_dir}`), `verification-prompt.md` → `references/`, korekta podstawy prawnej (art. 437 → art. 443/447 dla płatności częściowych).

Pełna historia: `git log pzp/weryfikacja-umow-pzp/` oraz [CHANGELOG.md](CHANGELOG.md).

## Filozofia

> „Analiza umowy ma wartość tylko wtedy, gdy zamawiający może przenieść każdą rekomendację 1:1 do projektu — z gotowym brzmieniem klauzuli i podstawą prawną. Mieszanie podstaw, propozycje opisowe i pominięcia załączników to ryzyko sporu i kontroli."

Skill jest uprzężą kontroli kontraktowej przed podpisaniem — zamienia mglistą ocenę „umowa wygląda OK" w audytowalną listę poprawek z cytatami i podstawą prawną.
