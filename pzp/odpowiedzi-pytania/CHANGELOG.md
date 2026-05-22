# CHANGELOG — odpowiedzi-pytania

> Wersja zrekonstruowana z historii git (backfill).

## [v1.1.0] — 2026-05-22 — zgodność z pryncypiami DOC

### Fixed

- **Niepoprawny YAML frontmatter (latent)** — `description` zawierał `… \`odpowiedzi_<RRRR-MM-DD>/\`: indeks…` (dwukropek+spacja → zagnieżdżone mapowanie). Zamienione na `—`. Frontmatter parsuje się czysto (9 pól).
- **Ścieżki absolutne `/Users/sq13pl/…` w referencjach** (`prawo-index.md`, `pzp-articles-map.md`) → sparametryzowane jako `{prawo_dir}` (zakaz ścieżek absolutnych, §4; ten sam typ buga co w `drafting-pzp-letters`).
- **Over-exclusion w `do-not-trigger-for`** — usunięto wpis „istotna zmiana charakteru zamówienia" (warunek wykrywany w trakcie — Phase 4.5 STOP-gate, nie filtr pre-aktywacyjny routera). Body „When NOT to Use" zsynchronizowane z `do-not-trigger-for` (dodane odsyłacze `analyzing-pzp-offers`, `drafting-pzp-letters`).

### Added

- **Frontmatter kanoniczny:** `trigger:`, `do-not-trigger-for:` (Negative Triggers — §7, z „When NOT to Use" + cross-ref do `analyzing-pzp-offers`, `drafting-pzp-letters`), `model:`, `allowed-tools:` (`Bash`/`Read`/`Write`/`Glob`/`Grep`/`TodoWrite` — bez `Edit` na kodzie), `sources:` (→ DOC), `size-limit:`.
- **Exit criteria** — skonsolidowana tabela faza→artefakt (Filar 1) po diagramie Workflow + nakaz `TodoWrite`.
- **Frontmatter referencji** w 4 plikach `references/` (`type: reference`, `parent`, `loaded-when`, `sources:` → §DOC).

### Changed

- **Filar 2** — „Red Flags — STOP and restart" (lista) → kanoniczna tabela **Anti-Rationalization** (`Wymówka | Riposta`, 9 wymówek z formatem „Odrzucono.").
- **Filar 3** — checklista Phase 7 oznaczona wprost jako **Definition of Done**.
- **Filar 4** — „Supporting Files" → tabela **reguł ładowania L3 imperatywnych** (DOC §5).

### Notes

- SKILL.md 483 linie (limit ≤500). By zmieścić frontmatter w skillu blisko limitu (492→), odzyskano miejsce kompresją duplikatów (skrócona tabela artykułów Pzp — pełna w `references/pzp-articles-map.md`; drzewo plików i blok frontmatter — duplikaty „Format wyniku"/templatów). Bez zmian merytorycznych (11 reguł bezwzględnych, Phase 4.5 STOP-gate, reguły terminowe art. 135/137/284/286, Iron Law).

## [v1.0.0] — 2026-04-28 — initial release

### Added

- Odpowiedzi Zamawiającego na pytania wykonawców (wyjaśnienia/modyfikacje SWZ/OPZ/umowy) w reżimie ustawy Pzp (art. 135 / art. 284).
- Produkuje 7 plików roboczych w `odpowiedzi_<RRRR-MM-DD>/`: indeks dokumentów, rejestr pytań, analiza w modelu 3 hipotez, finalne odpowiedzi do publikacji, wykaz zmian dokumentacji, raport ryzyk, wersja do akceptacji kierownika.
