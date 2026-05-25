# KGPSP Skills

Zbiór wyspecjalizowanych **Claude Code Skills** używanych w Komendzie Głównej Państwowej Straży Pożarnej. Skille są zorganizowane w kategorie tematyczne; każdy skill to samodzielny folder z plikiem `SKILL.md` (frontmatter + instrukcje) oraz katalogami pomocniczymi (`templates/`, `references/`, `scripts/`, `agents/`).

## Struktura

```
skills/
├── pzp/      # Prawo Zamówień Publicznych
├── legal/    # Opinie prawne, retrieval ELI, planowanie wydatków IT
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

### `legal/` — Opinie prawne, retrieval ELI, planowanie wydatków IT

| Skill | Wersja | Zastosowanie |
|-------|--------|--------------|
| [`opinie-prawne`](legal/opinie-prawne/) | `v1.0.0` | Sporządzanie opinii prawnych w polskim porządku prawnym (effort max, deep research po isap.sejm.gov.pl, eli.gov.pl, orzecznictwo SN/NSA/TK). |
| [`sejm-eli-api`](legal/sejm-eli-api/) | `v1.0.0` | Komunikacja z urzędowym źródłem prawa RP przez Sejm ELI API (`api.sejm.gov.pl/eli`): metadane, status, daty, relacje, spis treści i treść HTML/PDF aktów Dz.U./M.P., wyszukiwanie po tytule, import do Obsidian. Warstwa retrieval/grounding dla `opinie-prawne`. |
| [`planowanie-wydatkow-it-psp`](legal/planowanie-wydatkow-it-psp/) | **`v1.1.0`** | Wniosek finansowy / uzasadnienie wydatku / kosztorys TCO dla systemu IT KG PSP (CEOZO, CEZOL, SOiA, inne) z **klasyfikacją UFP 2027+** (Dz.U. 2026 poz. 582 — paragrafy 3-cyfrowe, bez progu 10 000 zł, załącznik nr 4 PSP) w 3 trybach: A POLiOC cz. 42 obronne `752/75282` (domyślny), B POLiOC podstawowy `754/75414`, C środki własne KG PSP `754/75409`. Procedura 6 faz (F1 Define → F2 Catalogize → F3 Price → F4 Classify → F5 Justify → F6 Verify+Ship), 7 plików `references/` (katalog kosztów A–O, klasyfikacja UFP 2027+, przeliczenia walut + VAT + reverse charge, 8-punktowy schemat uzasadnienia, ramy POLiOC, lista 19 małych kosztów, 21 wymówek anti-rationalization). Walidator POSIX `check-cost-plan.sh` — 9 sprawdzeń (brak paragrafów 4-cyfrowych legacy, kurs NBP, kompletność uzasadnienia, opinia MSWiA > 100k, plan utrzymania ≥ 5 lat dla pozycji majątkowych § 700–729, reverse charge dla walut, klasyfikacja 752/75282, suma alokacji `G..L = F`, **uzasadnienie operacyjne dla § 704 — specjalistyczny sprzęt bezpieczeństwa PSP**). |

### `dev/` — Narzędzia developerskie

Workflowy planowania/implementacji feature'a + orkiestracja zespołów agentów + QA end-to-end. Pełne porównanie i decyzja "który użyć kiedy" → [`dev/README.md`](dev/README.md).

**Planowanie feature'a** — trzy warianty (wybór zależy od rygoru i tego, czy skill ma też implementować):

| Skill | Wariant | Zastosowanie |
|-------|---------|--------------|
| [`replit-style-workflow`](dev/replit-style-workflow/) | **wygodny** (Claude Code) · `v2.3.0` | Replit Agent style z auto Agent Teams routing, ralph-loop autonomous, `/effort max`, 7 test scopes (unit/integration/system/acceptance/E2E/regression/perf+sec), worktree decision matrix. Domyślny wybór dla **typowych** zadań feature'owych. (Historycznie: `feature-planner-v2`.) |
| [`audited-feature-workflow`](dev/audited-feature-workflow/) | **senior-grade** (Claude Code) · `v3.3.0` | `replit-style-workflow` + deterministyczna uprząż inżynieryjna: 15-wpisowa Anti-Rationalization Table, twardy DoD z surowymi artefaktami, PR Sizing 100/300/1000, Hyrum's Law, Chesterton's Fence, Beyoncé Rule 1:1 AC↔Test, DAMP over DRY, Five-Axis Review, Plan-Validate-Execute, Thin Vertical Slices, Prove-It Pattern. **/goal mode** — autonomiczna pętla weryfikacji AC. Dla zadań **wysokiego rygoru** — fragile ops, audytowalna delegacja, compliance. (Historycznie: `feature-planner-v3`.) |
| [`feature-spec-planner`](dev/feature-spec-planner/) | **planning-only** · `v1.1.0` | Pochodny od `audited-feature-workflow`, **odcięty od implementacji**: 7 faz + 1 bramka akceptacji. Produkuje audytowalny pakiet planistyczny (Analysis Report + Plan z AC/DoD-spec/Thin Slices + ADR) gotowy do **handoffu** skillowi wykonawczemu. Zachowuje Hyrum/Chesterton/Beyoncé/DAMP jako **specyfikację** (nie pisze ani nie uruchamia kodu). Gdy chcesz analizę i decyzje **przed** kodowaniem, albo wykonanie deleguje ktoś inny. (Historycznie: `planner-f`.) |

**Orkiestracja i QA** — dla projektów wielosprintowych i testów aplikacji:

| Skill | Wersja | Zastosowanie |
|-------|--------|--------------|
| [`agent-teams-builder`](dev/agent-teams-builder/) | **v1.9.0** | Orkiestracja zespołu sub-agentów (Planner + Generator + Evaluator + specjaliści) wg wzorca Generator-Ewaluator. 7-fazowa procedura, twarde rubryki, mechanizm pivota (Plan-Validate-Execute), tryb `/goal` + **`/YOLO`** (autonomia bez bramek). **6 HITL approval gates** (v1.7.0), **Planning Rigor** (3 hipotezy/sprint, 11 sekcji planu, Hyrum Impact), **context7 MCP** (library currency), **Documentation Protocol** (10 typów dokumentów), **Test Discipline** (mapa unit/integration/regression dla 19 walidatorów, 22/22 cases passed — v1.9.0). Dla zadań „zbuduj aplikację od zera", projektów >2h. |
| [`playwright-test-suite`](dev/playwright-test-suite/) | **v1.2.0** | QA end-to-end aplikacji webowej: 5-fazowa procedura (smoke → UI → DevTools → a11y → visual) przez Playwright CLI + `@axe-core/playwright` + pixel-diff. Dedykowany sub-agent `playwright-runner`, **context7 MCP** (currency check przed nowym importem), QA Report (`state/qa-reports/`) zgodny z Documentation Protocol agent-teams-builder. Standalone QA lub Evaluator-Runtime w pętli Generator-Ewaluator. |
| [`swarm-orchestrator`](dev/swarm-orchestrator/) | **v1.0.0** | Orkiestracja 4 agentów Claude Code w **tmux -CC panes** (parent / planner / generator / evaluator) w 3 trybach: manual / hybrid (default) / yolo. Komponuje widzialność tmux z rygorem 5 bramek + kontrakty + breadcrumbs z `agent-teams-builder` i autonomią `/goal` z `audited-feature-workflow`. Single-sprint per invokacja YOLO, atomic commits per slice bez `git push`, auto-pivot po 3× no-progress. |

## Instalacja (Claude Code plugin marketplace)

Repo jest **marketplace pluginów Claude Code** (`kgpsp-skills`). Skille są pogrupowane w 3 pluginy wg domen — instalujesz tylko to, czego potrzebujesz.

| Plugin | Skille | Co zawiera |
|--------|--------|------------|
| `pzp-tools` | 4 | analyzing-pzp-offers, drafting-pzp-letters, odpowiedzi-pytania, weryfikacja-umow-pzp |
| `legal-tools` | 3 | opinie-prawne, sejm-eli-api, planowanie-wydatkow-it-psp |
| `dev-tools` | 6 | agent-teams-builder, replit-style-workflow, audited-feature-workflow, feature-spec-planner, playwright-test-suite, swarm-orchestrator |

**1. Dodaj marketplace** (jednorazowo):

```
/plugin marketplace add KGPSP/skills
```

**2. Zainstaluj wybrany plugin:**

```
/plugin install pzp-tools@kgpsp-skills
/plugin install legal-tools@kgpsp-skills
/plugin install dev-tools@kgpsp-skills
```

Po instalacji skille są dostępne z prefiksem pluginu, np. `pzp-tools:analyzing-pzp-offers`, `dev-tools:audited-feature-workflow`.

**Aktualizacja / usunięcie:**

```
/plugin marketplace update kgpsp-skills      # pobierz najnowszą wersję manifestu
/plugin marketplace remove kgpsp-skills       # usuń marketplace
```

> **Test lokalny** (bez GitHub, np. praca na sklonowanym repo): zamiast `KGPSP/skills` podaj ścieżkę do katalogu — `/plugin marketplace add /ścieżka/do/skills`. Walidacja manifestu przed publikacją: `claude plugin validate .`.

## Użycie

Skille są przeznaczone do pracy w **Claude Code** (CLI / IDE). Najwygodniej zainstalować je przez marketplace (sekcja **Instalacja** powyżej). Alternatywnie po sklonowaniu repo możesz wskazać katalog jako lokalne źródło skilli — Claude Code automatycznie odczyta frontmatter `name` / `description` z każdego `SKILL.md`.

Trigger skilla z poziomu czatu:

```
/<nazwa-skilla>
```

lub naturalnym językiem zgodnym z `description` w SKILL.md.

### Wybór skilla workflow w `dev/` (skrót)

- **„Dodaj endpoint", „zrób X", „zaimplementuj Y"** → `replit-style-workflow` (historycznie feature-planner-v2, wygodny rygor).
- **„senior-grade feature", „audytowalnie", „fragile op", „migration DB", „auth refactor"** → `audited-feature-workflow`.
- **„zaplanuj", „przeanalizuj i zaprojektuj", „przygotuj plan/ADR bez implementacji"** → `feature-spec-planner` (kończy na zatwierdzonym planie, handoff do wykonawcy).

Pełna decyzja w [`dev/README.md`](dev/README.md).

## Konwencje

- Każdy skill jest **samodzielny** — wszystkie wymagane templates/references/scripts znajdują się w jego folderze.
- **Wersjonowanie** — każdy skill ma w SKILL.md pole `version:` (semver `vX.Y.Z`) oraz własny `CHANGELOG.md`. Majory `v2`/`v3` w plannerach kodują generację wariantu. Wersje historyczne `pzp/`, `legal/`, `feature-planner*` zostały zrekonstruowane z historii git (backfill — oznaczone w CHANGELOG-ach). Stan startowy: `pzp/*` + `legal/opinie-prawne` = `v1.0.0`.
- Skille operacyjne (`pzp/`, `legal/`) generują artefakty w **Obsidian Flavored Markdown** z frontmatterem YAML, gotowe do zapisu w vaulcie KG PSP.
- Skille developerskie (`dev/`) zakładają pracę w repozytorium git z konwencjami `docs/plany/`, `docs/adr/`.
- Pliki referencyjne (`references/X.md`) mają frontmatter z polami `name`, `type: reference`, `parent`, `sources`, `description`.
- Skrypty (`scripts/X.sh`) — **POSIX shell** (`#!/bin/sh`), `set -eu`, bez bash-isms, exec bit zapisany w git.

## Pryncypia projektowania skilli (od `audited-feature-workflow`)

Skille z najwyższym rygorem (`audited-feature-workflow`, `agent-teams-builder`) respektują pryncypia zaczerpnięte z [Addy Osmani — Agent Skills](https://addyosmani.com/blog/agent-skills/) i *Software Engineering at Google*:

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
