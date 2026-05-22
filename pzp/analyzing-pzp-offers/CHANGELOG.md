# CHANGELOG — analyzing-pzp-offers

> Wersja zrekonstruowana z historii git (backfill).

## [v1.1.0] — 2026-05-21 — zgodność z pryncypiami DOC

### Added

- **Frontmatter kanoniczny:** `trigger:`, `do-not-trigger-for:` (Negative Triggers — §7), `model:`, `allowed-tools:` (`Bash`/`Read`/`Write`/`Glob`/`Grep`/`TodoWrite` — bez `Edit` na kodzie), `sources:` (→ DOC), `size-limit: 500-lines-hard`. Sekcja body „When NOT to Use" zsynchronizowana z `do-not-trigger-for` (3 nowe wykluczenia + odsyłacze do `drafting-pzp-letters`, `weryfikacja-umow-pzp`).
- **Exit criteria** po każdej z faz 0–5 (Filar 1 — mierzalny artefakt per faza) + jawny nakaz `TodoWrite` w Phase 0.
- **Frontmatter referencji** w `references/verification-prompt.md` (`type: reference`, `parent`, `loaded-when`, `sources:` → sekcje DOC z numerem §).

### Changed

- **Filar 2** — „Red Flags — STOP and restart" (lista) → kanoniczna tabela **Anti-Rationalization** (`Wymówka | Riposta`, 9 wymówek domenowych z formatem blokady „Odrzucono.").
- **Filar 4** — heavy reference przeniesiony do podkatalogu **`references/`** (`git mv`, kanon DOC §1/§10): `references/verification-prompt.md` (4 odwołania w SKILL.md + 2 w templatach zaktualizowane). „Supporting Files" → tabela **reguł ładowania L3** („Załaduj gdy" z fazami).
- **Filar 3** — „Deliverables Checklist" oznaczona wprost jako **Definition of Done** (dowodowa).

### Notes

- SKILL.md **499 linii** (limit ≤500 — margines 1 linia). Bez zmian merytorycznych w 18 edge cases, podstawach prawnych ani Iron Law — wyłącznie domknięcie zgodności z `DOC/`. **Rekomendacja na v1.2.0 (priorytet): konsolidacja „Common Mistakes"** (częściowy duplikat z Anti-Rationalization) — odzyska margines linii, który jest obecnie krytyczny.

## [v1.0.0] — 2026-04-28 — initial release

### Added

- Weryfikacja oferty wykonawcy w postępowaniu PZP (oferta vs SWZ/OPZ + pisma/modyfikacje).
- Produkuje raport z cytatami źródeł i indeksem dokumentów; znaleziska F1–F6 + ocena ryzyka.
