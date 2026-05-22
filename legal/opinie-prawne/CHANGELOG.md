# CHANGELOG — opinie-prawne

> Wersja zrekonstruowana z historii git (backfill).

## [v1.1.0] — 2026-05-21 — zgodność z pryncypiami DOC

### Added

- **Frontmatter kanoniczny:** `trigger:`, `do-not-trigger-for:` (Negative Triggers — §7), `model:`, `allowed-tools:` (analiza+research, bez `Edit` na kodzie), `sources:` (→ DOC), `size-limit: 500-lines-hard`.
- **Tabela Anti-Rationalization** (`Wymówka | Riposta`) — 8 wymówek domenowych z twardymi blokadami (Filar 2).
- **Definition of Done** — checklista 8 pozycji (deep research, weryfikacja cytatów/sygnatur, ≥3 hipotezy, poziom pewności, przepisy przejściowe, struktura, zastrzeżenia).
- **Exit criteria** po każdym z 9 kroków metody analizy (Filar 1 — mierzalny artefakt per faza).
- **Reguły ładowania L3** (Progressive Disclosure §5) — tabela „załaduj gdy" dla `references/` i `templates/`.
- **Frontmatter referencji** (`name`/`type: reference`/`parent`/`loaded-when`/`sources:` (lista → sekcje DOC z numerem §)) w `metodyka-wykladni.md` i `zrodla-urzedowe.md` (§10).

### Notes

- SKILL.md 464 linie (limit ≤500). Bez zmian merytorycznych w metodzie analizy, hierarchii źródeł i protokole deep research — wyłącznie domknięcie zgodności z `DOC/`.

## [v1.0.0] — 2026-04-28 — initial release

### Added

- Sporządzanie opinii prawnych w polskim porządku prawnym (effort max, ultrathink, deep research po isap.sejm.gov.pl, eli.gov.pl, dziennikustaw.gov.pl, orzecznictwo SN/NSA/TK).
- Obejmuje prawo konstytucyjne, administracyjne, cywilne, karne, pracy, finansów publicznych, zamówień publicznych, IT/cyber, RODO i pozostałe gałęzie prawa polskiego.
