# KGPSP Skills

Zbiór wyspecjalizowanych **Claude Code Skills** używanych w Komendzie Głównej Państwowej Straży Pożarnej. Skille są zorganizowane w kategorie tematyczne; każdy skill to samodzielny folder z plikiem `SKILL.md` (frontmatter + instrukcje) oraz katalogami pomocniczymi (`templates/`, `references/`, `scripts/`, `agents/`).

## Struktura

```
skills/
├── pzp/      # Prawo Zamówień Publicznych
├── legal/    # Opinie prawne i analizy normatywne
└── dev/      # Narzędzia developerskie (planowanie, orkiestracja agentów, QA)
```

## Katalog skilli

### `pzp/` — Prawo Zamówień Publicznych

| Skill | Zastosowanie |
|-------|--------------|
| [`analyzing-pzp-offers`](pzp/analyzing-pzp-offers/) | Weryfikacja oferty wykonawcy w postępowaniu PZP (oferta vs SWZ/OPZ + pisma/modyfikacje). Produkuje raport z cytatami źródeł i indeksem dokumentów. |
| [`drafting-pzp-letters`](pzp/drafting-pzp-letters/) | Projekty pism proceduralnych (wezwania do uzupełnienia/wyjaśnień, informacje o odrzuceniu/wykluczeniu, zawiadomienia o poprawie omyłki, wybór/unieważnienie) na podstawie analizy oferty. Generuje `.md` + `.docx` w szablonie EZD. |
| [`weryfikacja-umow-pzp`](pzp/weryfikacja-umow-pzp/) | Audyt projektu umowy / PPU przed podpisaniem — z parą **cytat obecnego brzmienia + proponowane brzmienie** dla każdej wykrytej wady. |
| [`odpowiedzi-pytania`](pzp/odpowiedzi-pytania/) | Odpowiedzi Zamawiającego na pytania wykonawców (wyjaśnienia/modyfikacje SWZ) — model 3 hipotez, finalne odpowiedzi do publikacji, raport ryzyk. |

### `legal/` — Opinie prawne

| Skill | Zastosowanie |
|-------|--------------|
| [`opinie-prawne`](legal/opinie-prawne/) | Sporządzanie opinii prawnych w polskim porządku prawnym (effort max, deep research po isap.sejm.gov.pl, eli.gov.pl, orzecznictwo SN/NSA/TK). |

### `dev/` — Narzędzia developerskie

Workflowy planowania/implementacji feature'a + orkiestracja zespołów agentów + QA end-to-end. Pełne porównanie i decyzja "który użyć kiedy" → [`dev/README.md`](dev/README.md).

**Planowanie feature'a** — trzy warianty (wybór zależy od środowiska i wymaganego rygoru):

| Skill | Wariant | Zastosowanie |
|-------|---------|--------------|
| [`feature-planner`](dev/feature-planner/) | **v2** (Claude Code) | Replit Agent style z auto Agent Teams routing, ralph-loop autonomous, `/effort max`, 7 test scopes (unit/integration/system/acceptance/E2E/regression/perf+sec), worktree decision matrix. Domyślny wybór dla **typowych** zadań feature'owych. |
| [`feature-planner-v3`](dev/feature-planner-v3/) | **v3** (senior-grade) | v2 + deterministyczna uprząż inżynieryjna: 15-wpisowa Anti-Rationalization Table, twardy DoD z surowymi artefaktami, PR Sizing 100/300/1000, Hyrum's Law, Chesterton's Fence, Beyoncé Rule 1:1 AC↔Test, DAMP over DRY, Five-Axis Review, Plan-Validate-Execute, Thin Vertical Slices, Prove-It Pattern. Dla zadań **wysokiego rygoru** — fragile ops, audytowalna delegacja, compliance. |
| [`feature-planner-codex`](dev/feature-planner-codex/) | **codex-native** | Wariant bez Claude-Code-specific koncepcji (Agent Teams, slash commands). Do pracy w **OpenAI Codex CLI**. |

**Orkiestracja i QA** — dla projektów wielosprintowych i testów aplikacji:

| Skill | Wersja | Zastosowanie |
|-------|--------|--------------|
| [`agent-teams-builder`](dev/agent-teams-builder/) | **v1.6.0** | Orkiestracja zespołu sub-agentów (Planner + Generator + Evaluator + specjaliści) wg wzorca Generator-Ewaluator. 7-fazowa procedura, twarde rubryki, mechanizm pivota (Plan-Validate-Execute), tryb `/goal`. **Planning Rigor** (3 hipotezy/sprint, 11 sekcji planu, Hyrum Impact), **context7 MCP** (library currency — eliminacja halucynacji API), **Documentation Protocol** (pełen audit trail: PRD/ADR/retro/Five-Axis CR/QA — 10 typów dokumentów). Meta-testy walidatorów **19/19**. Dla zadań „zbuduj aplikację od zera", projektów >2h. |
| [`playwright-test-suite`](dev/playwright-test-suite/) | **v1.2.0** | QA end-to-end aplikacji webowej: 5-fazowa procedura (smoke → UI → DevTools → a11y → visual) przez Playwright CLI + `@axe-core/playwright` + pixel-diff. Dedykowany sub-agent `playwright-runner`, **context7 MCP** (currency check przed nowym importem), QA Report (`state/qa-reports/`) zgodny z Documentation Protocol agent-teams-builder. Standalone QA lub Evaluator-Runtime w pętli Generator-Ewaluator. |

## Użycie

Skille są przeznaczone do pracy w **Claude Code** (CLI / IDE). Po sklonowaniu repo wskaż katalog jako źródło skilli — Claude Code automatycznie odczyta frontmatter `name` / `description` z każdego `SKILL.md`.

Trigger skilla z poziomu czatu:

```
/<nazwa-skilla>
```

lub naturalnym językiem zgodnym z `description` w SKILL.md.

### Wybór dev/feature-planner (skrót)

- **„Dodaj endpoint", „zrób X", „zaimplementuj Y"** → `feature-planner` (v2).
- **„senior-grade feature", „audytowalnie", „fragile op", „migration DB", „auth refactor"** → `feature-planner-v3`.
- **Praca w Codex CLI** (nie Claude Code) → `feature-planner-codex`.

Pełna decyzja w [`dev/README.md`](dev/README.md).

## Konwencje

- Każdy skill jest **samodzielny** — wszystkie wymagane templates/references/scripts znajdują się w jego folderze.
- Skille operacyjne (`pzp/`, `legal/`) generują artefakty w **Obsidian Flavored Markdown** z frontmatterem YAML, gotowe do zapisu w vaulcie KG PSP.
- Skille developerskie (`dev/`) zakładają pracę w repozytorium git z konwencjami `docs/plany/`, `docs/adr/`.
- Pliki referencyjne (`references/X.md`) mają frontmatter z polami `name`, `type: reference`, `parent`, `sources`, `description`.
- Skrypty (`scripts/X.sh`) — **POSIX shell** (`#!/bin/sh`), `set -eu`, bez bash-isms, exec bit zapisany w git.

## Pryncypia projektowania skilli (od v3)

Skille z najwyższym rygorem (`feature-planner-v3`) respektują pryncypia zaczerpnięte z [Addy Osmani — Agent Skills](https://addyosmani.com/blog/agent-skills/) i *Software Engineering at Google*:

- **Process over Prose** — workflow z punktami kontrolnymi, nie esej o jakości.
- **Anti-Rationalization Tables** — predefiniowane riposty na wymówki LLM.
- **Verification with raw artifacts** — surowy log/screenshot/trace, nie parafraza.
- **Scope Discipline** — *Touch only what you are asked to touch*.
- **Progressive Disclosure** — meta-skill router, brak ładowania wszystkiego naraz.
- **Hyrum's Law + Chesterton's Fence** — szanuj obserwowalne zachowania i historyczne decyzje.
- **Beyoncé Rule** — *If you liked it, you should have put a test on it* (1:1 AC↔Test).
- **DAMP over DRY w testach** — czytelność diagnostyki > unikanie powtórzeń.
- **PR Sizing** — ~100 optymalne, >300 wymaga uzasadnienia, >1000 hard stop.
- **5 Non-negotiables** — uwidaczniaj założenia, zatrzymuj się przy konflikcie, wybieraj nudne rozwiązania, dostarczaj dowód nie deklarację, dotykaj tylko zakresu.

## Licencja

Wewnętrzny użytek KG PSP. Treść skilli odzwierciedla praktykę i metodykę pracy KG PSP — wykorzystanie poza organizacją wymaga uzgodnienia.
