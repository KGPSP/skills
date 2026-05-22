# CHANGELOG — drafting-pzp-letters

> Wersja zrekonstruowana z historii git (backfill).

## [v1.1.0] — 2026-05-21 — zgodność z pryncypiami DOC

### Fixed

- **Ścieżka absolutna w treści skilla (Phase 4)** — `--template /Users/mklosinski/…/wzor_pismo_przewodnie.docx` (wskazywała cudze konto, bug przenośności) → sparametryzowana jako `<template_docx>` (Required Inputs pkt 6).
- **Niepoprawny YAML frontmatter** — `description` zawierał `Triggers include:` (dwukropek+spacja → zagnieżdżone mapowanie). Zamienione na `Triggers include —`. Frontmatter parsuje się czysto (9 pól).
- **Exec-bit skryptu** `scripts/render_docx.py` `100644` → `100755`.

### Added

- **Frontmatter kanoniczny:** `trigger:`, `do-not-trigger-for:` (Negative Triggers — §7, z „When NOT to Use"), `model:`, `allowed-tools:` (`Bash`/`Read`/`Write`/`Glob`/`Grep`/`TodoWrite` — bez `Edit` na kodzie), `sources:` (→ DOC), `size-limit:`.
- **Exit criteria** po fazach 0–5 (Filar 1) + nakaz `TodoWrite` w Phase 0.
- **Definition of Done** — checklista pakietu pism (Filar 3; skill jej nie miał).
- **Frontmatter referencji** w `legal-basis-catalog.md` i `letter-types.md` (`type: reference`, `parent`, `loaded-when`, `sources:` → §DOC).

### Changed

- **Filar 2** — „Red Flags — STOP and restart" (lista) → kanoniczna tabela **Anti-Rationalization** (`Wymówka | Riposta`, 10 wymówek z formatem blokady „Odrzucono."; pełna riposta „ekonomika procesowa" zachowana).
- **Filar 4** — heavy references przeniesione do podkatalogu **`references/`** (`git mv`, kanon DOC §1/§10): `references/legal-basis-catalog.md`, `references/letter-types.md`. „Supporting Files" → tabela **reguł ładowania L3 w formacie imperatywnym** („Jeśli `<warunek>` → załaduj `references/<plik>`", DOC §5) + jawna instrukcja ładowania na początku Phase 2 (co-location).

### Notes

- SKILL.md 398 linii (limit ≤500 — duży margines). Bez zmian merytorycznych w tabeli decyzyjnej F→pismo, regułach grupowania/eskalacji, self-cleaning per przesłankę ani Iron Law — wyłącznie domknięcie zgodności z `DOC/` + dwie naprawy bugów (ścieżka, YAML).

## [v1.0.0] — 2026-04-28 — initial release

### Added

- Projekty pism proceduralnych (wezwania do uzupełnienia/wyjaśnień, informacje o odrzuceniu/wykluczeniu, zawiadomienia o poprawie omyłki, wybór/unieważnienie) na podstawie analizy oferty.
- Generuje `.md` (do review) + `.docx` w szablonie EZD KG PSP, z podstawą prawną i cytatami źródeł.
