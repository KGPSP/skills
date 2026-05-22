# Changelog — sejm-eli-api

## [2026-05-22] v1.0.0 — pierwsza wersja

### Added

- **SKILL.md** — procedura 6-fazowa (parsowanie cytowania → publikator → wyszukanie → metadane → treść/struktura → grounding → import) z exit criteria, tabelą Anti-Rationalization (7 wymówek), DoD, regułami ładowania L3, frontmatterem kanonicznym (`trigger`, `do-not-trigger-for`, `sources`, `version`, `size-limit`).
- **references/endpoints.md** — katalog endpointów `api.sejm.gov.pl/eli` zweryfikowany `curl`-em 2026-05-22: `/acts`, `/acts/{pub}/{year}`, `/acts/{pub}/{year}/{pos}`, `…/text.html`, `…/text.pdf`, `…/struct`, `…/references`, `/acts/search` (paginacja `count/items/offset/totalCount`).
- **references/obsidian-import.md** — format notatki Obsidian + opcje importera.
- **scripts/eli-fetch.sh** — POSIX wrapper (publishers/search/year/meta/struct/references/text), `set -eu`, url-encode, `--max-time`.
- **scripts/import-eli-act.py** — import metadanych aktu do vaulta Obsidian; vault z `--vault`/`OBSIDIAN_VAULT` (bez zaszytej ścieżki absolutnej); frontmatter źródłowy + surowy JSON.

### Notes

- Pozycjonowanie: warstwa retrieval/grounding; interpretacja → `legal/opinie-prawne`.
- Brak OpenAPI/Swagger po stronie API — `references/endpoints.md` jest dokumentacją zastępczą, rozszerzaną tylko o ścieżki zweryfikowane w sesji.
