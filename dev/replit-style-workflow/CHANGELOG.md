# CHANGELOG — replit-style-workflow (historycznie feature-planner-v2)

> Wersje przed wprowadzeniem semver zrekonstruowane z historii git (backfill).
> Wariant **wygodny** Claude Code workflow — koegzystuje z `feature-planner-v3` (senior-grade) i `planner-f` (planning-only).
> **Rename 2026-05-25:** `feature-planner` → `replit-style-workflow` (folder + frontmatter `name:`). Trigger keywords zachowane.

## [v2.3.0] — 2026-05-25 — Rename: feature-planner → replit-style-workflow

### Changed

- **Folder:** `dev/feature-planner/` → `dev/replit-style-workflow/` (`git mv`, rename detected przez gita — historia plików zachowana).
- **Frontmatter SKILL.md:** `name: feature-planner-v2` → `name: replit-style-workflow`. Description rozszerzona o pozycjonowanie ("wygodny rygor, lighter niż feature-planner-v3, domyślny dla typowych zadań").
- **`parent:`** w `references/testing-map.md` zsynchronizowane: `feature-planner-v2` → `replit-style-workflow`.

### Why

Nazwa `feature-planner` sugerowała wyłącznie planowanie, ale skill robi pełny workflow (plan → implementacja → 7 test scopes → live preview → code review → ADR). Myliło się też z [`planner-f`](../planner-f/) (który JEST planning-only). Dodatkowo `feature-planner-v2` w frontmatterze vs `feature-planner` jako folder = niezgrabna inkonsystencja. Nowa nazwa odzwierciedla unikalną wartość — **Replit Agent style** workflow z auto-routingiem (Sequential/Teams/Ralph) i deep research.

### Co NIE zmienia się

- **Trigger keywords** — `"dodaj feature v2"`, `"zaimplementuj"`, `"zrób żeby"`, `"implement"`, `"build feature"`, `"ralph"`, `"ralph-loop"`, `"iteruj aż zielono"` zachowane bez zmian. Skill aktywuje się tak samo.
- **Zawartość SKILL.md + references/** — bez zmian funkcjonalnych. Pure rename refactor.
- **Cross-references** w `feature-planner-v3` (`extends:`), `agent-teams-builder`, `planner-f`, README — zsynchronizowane (5 plików).

### Migracja dla użytkownika

Jeśli wywoływałeś po nazwie skilla bezpośrednio (`/replit-style-workflow` lub przez router → `name:`), aktualizuj. Wywoływanie przez trigger phrasy (`"dodaj feature"`, `"ralph"`, etc.) działa nadal.

### Sources

- DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §4 (nazwa skilla: kebab-case, opisowa, niemyląca) — `feature-planner` myli się z `planner-f`.
- DOC/material_skill.md §6 (Architektura operacyjna — Meta-Skill Router) — `name:` jest identyfikatorem aktywacji, powinien jednoznacznie wskazywać funkcjonalność.

---

## [v2.2.0] — 2026-05-25 — Test Discipline (dokumentacja stanu + pryncypium retrofittingu)

### Added

- **`references/testing-map.md`** — mapa Test Discipline dla v2. Dokumentuje stan: **v2 NIE ma `scripts/` ani `tests/`**, cały rygor jest w prozie SKILL.md (2229 linii). Plik:
  - Mapuje 11 faz/sub-sekcji v2 (PHASE 0 → PHASE 7.6) → potencjalny walidator + fixtures (wszystkie Status ❌).
  - Wymusza **pryncypium retrofittingu**: każda NOWA funkcjonalność v2 = nowy skrypt walidatora + fixture + assert_exit w runnerze (wzorzec: `dev/agent-teams-builder/tests/`).
  - Zawiera Anti-Rationalization (5 wymówek dla v2: „v2 to historyczny prose-heavy", „SKILL.md 2229 linii — mniej refaktoru", „opis bez skryptu wystarczy", „bug w prozie bez regresji", „v2 stabilne, nie ruszam").
  - Wskazuje long-term: jeśli żadna nowa funkcjonalność v2 nie wejdzie w 6 miesięcy → rozważ deprecation (analog do `feature-planner-codex` 2026-05-25).
- **1 wpis w „Reference files"** w SKILL.md — link do `testing-map.md` z notą o stanie 0 walidatorów.

### Why

User feedback: „jak coś wytwarzasz to tworzysz testy". v2 jest historycznie prose-heavy i NIE ma żadnych meta-testów. Dodanie wymówki retoryki testowej do prozy 2229-liniowej nic nie zmieni — potrzebny jest **deterministyczny pryncypium**: każda przyszła zmiana w v2 zaczyna od skryptu walidatora + meta-testu. Bez tego v2 dryfuje w stronę stałej technicznej drabiny.

### Sources

- DOC/material_skill.md §2 (Process over Prose — opis bez exit criterion = krok za miękki), §5 (Beyoncé Rule)
- DOC/since_skill.md §5 (Prove-It Pattern dla regresji)
- DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §9, §11 (anty-wzorzec „esej zamiast procedury")

---

## [v2.1.0] — 2026-05-08 — testing matrix + worktree + ralph-loop

### Added

- **7-scope testing matrix** (unit / integration / system / acceptance / E2E Playwright tier 1–4 / regression / perf+security) per S/M/L + Playwright fallback.
- **Phase 5.5** — worktree decision matrix; **Phase 7.8** — live preview (M+ UI).
- **Ralph-loop** — tryb autonomiczny (6-Ralph) + użycie `TodoWrite`.

### Fixed

- Poprawki z code review Phase 5.5 / 7.8 (B1, S1–S4, 2nd-pass review).

---

## [v2.0.0] — 2026-04-28 — initial release

### Added

- Bazowy workflow planowania feature'a (Replit Agent style): detect env → analysis → hypotheses → plan → APPROVAL → implement → code review → ADR.
- Agent Teams routing (6-Sequential / 6-Teams 2–5).
- Deep research bez Gemini (context7 / Explore / WebSearch / codex).
