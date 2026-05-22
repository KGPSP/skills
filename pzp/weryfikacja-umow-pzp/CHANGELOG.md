# CHANGELOG — weryfikacja-umow-pzp

> Wersja zrekonstruowana z historii git (backfill).

## [v1.1.0] — 2026-05-22 — zgodność z pryncypiami DOC

### Fixed

- **Przekroczenie twardego limitu — SKILL.md 703 → 480 linii (≤500).** Ciężkie bloki wyniesione do `references/` (zachowane bajt-w-bajt przez `sed`): katalog podstaw prawnych (art. 431–465 Pzp + k.c./RODO/KSC/pr.aut.) → `legal-basis-catalog.md`; 18 edge cases + Common Mistakes → `edge-cases.md`; formaty Obsidian → `format-obsidian.md`; integracja KG PSP + powiązania skilli → `kg-psp-integration.md`.
- **Ścieżka absolutna `/Users/mklosinski/…`** (blok integracji KG PSP) → sparametryzowana `{prawo_dir}`.
- **Błąd prawny (pre-existing, wykryty w code review)** — edge case 11 wskazywał `art. 437 Pzp` (podwykonawstwo w RB) jako podstawę płatności częściowych w umowach > 12 m-cy; poprawione na **art. 443 Pzp** (dostawy/usługi) + **art. 447 Pzp** (roboty budowlane).

### Added

- **Frontmatter kanoniczny:** `trigger:`, `do-not-trigger-for:` (Negative Triggers — §7, z „When NOT to Use" + cross-ref do `analyzing-pzp-offers`, `drafting-pzp-letters`), `model:`, `allowed-tools:` (`Bash`/`Read`/`Write`/`Glob`/`Grep`/`TodoWrite` — bez `Edit`), `sources:` (→ DOC), `size-limit:`.
- **Exit criteria** — skonsolidowana tabela faza→artefakt (Filar 1) + nakaz `TodoWrite`.
- **Frontmatter referencji** w 5 plikach `references/` (`type: reference`, `parent`, `loaded-when`, `sources:` → §DOC).

### Changed

- **Filar 4** — `verification-prompt.md` przeniesiony do **`references/`** (`git mv`, §1/§10; odwołania w SKILL.md zaktualizowane). „Supporting Files" → tabela **reguł ładowania L3 imperatywnych** (§5) wskazująca 5 referencji per faza.
- **Filar 2** — „Red Flags" (lista) → kanoniczna tabela **Anti-Rationalization** (`Wymówka | Riposta`, 9 wymówek „Odrzucono.").
- **Filar 3** — „Deliverables Checklist" oznaczona wprost jako **Definition of Done**.
- Citation Format — rozwlekły przykład P-012 skrócony (pełna struktura w Phase 5 + `templates/05`).

### Notes

- Bez zmian merytorycznych: katalog art. 431–465, 18 edge cases, klasyfikacje P1–P7/R1–R4, macierz korelacji, Iron Law — wszystko zachowane, przeniesione do `references/` 1:1.

## [v1.0.0] — 2026-04-28 — initial release

### Added

- Audyt projektu umowy / wzoru umowy / PPU przed podpisaniem, z korelacją do SWZ/OPZ/oferty/pism.
- Raport z parą **cytat obecnego brzmienia + proponowane brzmienie** dla każdej wykrytej wady.
