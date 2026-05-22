# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ Zasada nr 1 — przed pracą nad JAKIMKOLWIEK skillem przeczytaj `DOC/`

**Przed tworzeniem, modyfikacją lub aktualizacją skilla NAJPIERW zapoznaj się z katalogiem [`/Users/sq13pl/Documents/GitHub/skills/DOC`](DOC/), a dopiero potem przygotowuj/edytuj skill.**

To nie jest opcjonalne. `DOC/` zawiera kanoniczne pryncypia, na których stoją wszystkie skille tego repo. Praca nad skillem bez ich znajomości produkuje niespójność z resztą katalogu.

Kolejność czytania:
1. [`DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md`](DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md) — krok-po-kroku jak budować skill w tym repo: struktura katalogu, szablon `SKILL.md`, 5 filarów, checklista gotowości (§9), reguła `source:` w referencjach (§10).
2. [`DOC/material_skill.md`](DOC/material_skill.md) — pryncypia procesowe: Process over Prose, Anti-Rationalization, DoD (dowód nie deklaracja), Hyrum, Chesterton, Beyoncé, DAMP, 5 Non-negotiables.
3. [`DOC/since_skill.md`](DOC/since_skill.md) — pryncypia projektowe: token budget, kebab-case, imperatyw, scripts/, Negative Triggers, Anti-Laziness, Plan-Validate-Execute, Thin Vertical Slices, Prove-It.
4. Warunkowo: [`DOC/goal_mode.md`](DOC/goal_mode.md) (gdy skill ma tryb `/goal`), [`DOC/agent-teams-generator-ewaluator.md`](DOC/agent-teams-generator-ewaluator.md) (gdy skill orkiestruje sub-agentów).

> **Uwaga:** `DOC/` jest **gitignored** (local-only — patrz `.gitignore`), więc nie pojawia się w `git ls-files` ani na zdalnym repo. Istnieje wyłącznie lokalnie pod ścieżką bezwzględną powyżej. Pola `sources:` w `SKILL.md`/referencjach wskazują na `DOC/...` mimo że pliki nie są commitowane — to celowe (kanoniczne źródło prawdy, nie publiczny artefakt).

**Reference implementation:** kopiuj `dev/feature-planner-v3/` jako wzorzec dojrzałego skilla (frontmatter, fazy z exit criteria, `references/` z `source:` per sekcja DOC, `scripts/` POSIX). `dev/planner-f/` to przykład skilla pochodnego (odcięcie faz wykonawczych od v3).

## Czym jest to repo

Katalog **Claude Code Skills** dla Komendy Głównej PSP. Repo **nie zawiera aplikacji** — każdy skill to samodzielny pakiet dokumentacji proceduralnej (Markdown + skrypty POSIX), który Claude Code ładuje na podstawie frontmatter `name`/`description`. „Build" tutaj = napisanie/edycja skilla zgodnego z pryncypiami DOC, nie kompilacja kodu.

Trzy domeny (każdy skill = jeden samodzielny folder):
- `pzp/` — Prawo Zamówień Publicznych (4 skille operacyjne, generują `.md`/`.docx` w Obsidian Flavored Markdown)
- `legal/` — opinie prawne + komunikacja z Sejm ELI API (2 skille)
- `dev/` — narzędzia developerskie dla agentów AI (planowanie feature'a, orkiestracja zespołów sub-agentów, QA) — to tu jest najwięcej rygoru inżynieryjnego

## Marketplace pluginów (Claude Code)

Repo jest **instalowalnym marketplace** — `.claude-plugin/marketplace.json` (nazwa `kgpsp-skills`) grupuje skille w 3 pluginy wg domen:

- `pzp-tools` → `pzp/.claude-plugin/plugin.json`
- `legal-tools` → `legal/.claude-plugin/plugin.json`
- `dev-tools` → `dev/.claude-plugin/plugin.json`

Każdy `plugin.json` ma pole **`skills:`** wskazujące katalogi skilli **wprost** (np. `"./sejm-eli-api"`) — bez przenoszenia do `skills/`. Pole jest additywne do domyślnego `skills/`; nazwa wywołania pochodzi z `name:` we frontmatterze SKILL.md (wygrywa z nazwą katalogu — np. `dev/feature-planner/` → `feature-planner-v2`). Cały drzewostan domeny kopiowany jest do cache, więc `references/`/`scripts/`/`templates/` działają; **ścieżki `../` poza katalog pluginu nie działają** po instalacji (dlatego skille nie mogą zależeć od `DOC/` w runtime — `DOC/` to źródło autorskie, nie runtime).

Instalacja: `/plugin marketplace add KGPSP/skills` → `/plugin install <plugin>@kgpsp-skills`.

> **Reguła przy dodawaniu/zmianie skilla:** dopisz katalog do `skills:` w `plugin.json` właściwej domeny, podbij `version` pluginu, zaktualizuj opis w `marketplace.json` i tabelę „Instalacja" w `README.md`. Skill bez wpisu w `plugin.json` **nie jest instalowalny**.

## Architektura skilla (Progressive Disclosure — 4 poziomy)

Zrozumienie wymaga przeczytania wielu plików; oto „big picture":

```
<skill-name>/
├── SKILL.md          # L2: procedura. HARD limit ≤500 linii. Ładowany gdy router wybierze skill.
├── references/*.md   # L3: rozbudowane protokoły. Ładowane gdy SKILL.md JAWNIE wskaże + warunek.
├── scripts/*.sh      # L4: deterministyczne narzędzia (POSIX). Wywoływane, nie ładowane do kontekstu.
├── assets/ | templates/  # rubryki, szablony few-shot, .docx
├── tests/fixtures/   # GOOD/BAD przykłady dla walidatorów (skille dev/)
├── README.md + CHANGELOG.md
```

- **L1 frontmatter** (`name`, `description`, `trigger`, `do-not-trigger-for`) — zawsze w kontekście; to on decyduje o aktywacji. `description` mówi CO robi i KIEDY użyć.
- **Reguła ładowania L3:** w SKILL.md pisz wprost *„Jeśli `<warunek>`, załaduj `references/<plik>.md`"* — nie zostawiaj decyzji modelowi.
- **Pliki `references/`** mają własny frontmatter: `name`, `type: reference`, `parent: <skill>`, `source:`/`sources:` (wskazujący sekcję `DOC/material_skill.md`/`since_skill.md` z numerem §) — pozwala audytować pochodzenie każdej zasady.
- **Skrypty** istnieją bo LLM jest słaby w rutynowych/deterministycznych operacjach (liczenie, walidacja struktury). Tam gdzie regułę da się wyegzekwować skryptem — rób skrypt, nie prozę.

## Konwencje (egzekwowane w całym repo)

- **Frontmatter SKILL.md:** `name` (kebab-case), `description`, `trigger:`, `do-not-trigger-for:` (Negative Triggers — obowiązkowe), `model`, `allowed-tools`, `sources:` (→ DOC), `version:` (semver `vX.Y.Z`), `size-limit: 500-lines-hard`.
- **`allowed-tools`:** wymień tylko narzędzia naprawdę potrzebne. Skill wyłącznie analizujący/planujący NIE dostaje `Edit`/`Write` na kodzie (przykład: `planner-f` ma `Write` tylko do artefaktów planistycznych).
- **Styl:** tryb rozkazujący („Weryfikuj X", nie „Powinieneś sprawdzić X"); ścieżki przez `{baseDir}` lub względne (nigdy absolutne `/Users/...` w treści skilla); kebab-case nazw; tabele/listy/numerowane kroki zamiast prozy; twarde progi binarne („0 błędów"), nie skale 1–10.
- **Skrypty:** POSIX shell. Wzorzec referencyjny `#!/bin/sh` + `set -eu`, bez bash-isms; exec bit (`100755`) zapisany w gicie. (Część starszych skryptów w `agent-teams-builder` używa `#!/usr/bin/env bash` + `set -o pipefail` — przy nowych trzymaj się POSIX.)
- **Wersjonowanie:** każdy skill ma `version:` w SKILL.md **oraz** własny `CHANGELOG.md`. Nowy skill / nowa wersja → wpis także w **repo-root [`CHANGELOG.md`](CHANGELOG.md)** (format datowany `## [RRRR-MM-DD] ...`).
- **Daty względne** zamieniaj na bezwzględne (dziś orientacyjnie patrz na ostatnie wpisy CHANGELOG).

## Walidacja / testy

Repo nie ma globalnego test runnera. Testy to **meta-testy walidatorów** i **bramki skryptowe** per skill, uruchamiane bezpośrednio:

```bash
# Meta-testy walidatorów (najpełniejszy zestaw — agent-teams-builder)
bash dev/agent-teams-builder/tests/run-meta-tests.sh        # uruchamia wszystkie grupy
# pojedyncza grupa/fixture: czytaj run-meta-tests.sh — woła walidatory na tests/fixtures/{GOOD,BAD}

# Bramka kompletności planu (planner-f) — sprawdź na fixtures
sh dev/planner-f/scripts/check-plan-complete.sh --plan dev/planner-f/tests/fixtures/complete-plan.md    # exit 0
sh dev/planner-f/scripts/check-plan-complete.sh --plan dev/planner-f/tests/fixtures/incomplete-plan.md  # exit 1

# Składnia każdego skryptu przed commitem
sh -n <ścieżka>/scripts/*.sh
# Skrypty Pythona (np. legal/sejm-eli-api): kompilacja przed commitem
python3 -m py_compile <ścieżka>/scripts/*.py

# Marketplace: walidacja manifestu + test instalacji (CLI, nie interaktywny /plugin)
claude plugin validate .                                  # bramka manifestu — musi: ✔ Validation passed
claude plugin marketplace add /Users/sq13pl/Documents/GitHub/skills   # test lokalny ze ścieżki
claude plugin install <plugin>@kgpsp-skills && claude plugin details <plugin>   # potwierdza Skills (N)
claude plugin uninstall <plugin> && claude plugin marketplace remove kgpsp-skills   # SPRZĄTAJ po teście
```

Po edycji skilla z `tests/` — uruchom jego runner i potwierdź, że przechodzi (np. `19/19 passed`), zanim uznasz pracę za skończoną (DoD = dowód, nie deklaracja).

## Jak pracujemy (workflow)

- **Commit/push tylko na wyraźne żądanie.** Domyślnie kończ na zwalidowanych zmianach lokalnych + krótkim podsumowaniu; pytaj, czy commitować.
- **DoD = dowód, nie deklaracja.** Przed „gotowe": uruchom skrypt/walidator i wklej surowy output (kod HTTP, `✔ passed`, `stdout`). Nie pisz „powinno działać".
- **Weryfikuj zewnętrzne źródła na żywo** zanim je udokumentujesz w skillu (np. endpointy API `curl`-em z datą) — zakaz „mock zamiast realnego źródła" (DOC anty-wzorzec).
- **Po teście instalacji marketplace SPRZĄTAJ** (`uninstall` + `marketplace remove`) i potwierdź czysty stan — nie zostawiaj artefaktów na maszynie użytkownika bez zgody.
- **Wklejony kod bywa uszkodzony** (znaki ucięte przy paście) — przepisz na działającą wersję i potwierdź `py_compile`/`sh -n`, nie kopiuj 1:1.
- **Ścieżki absolutne do prywatnych vaultów** (`/Users/<ktoś>/...`) zastępuj parametrem (`--vault`) lub zmienną env — nigdy nie zaszywaj w skillu.

## Git

- Branch domyślny: `main`. Skrypty trzymaj wykonywalne (`git ls-files -s` powinien pokazywać `100755`).
- Commit messages kończ stopką `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`.
- `DOC/` i `.claude/*.state`/`*.local.*` są w `.gitignore` — nie próbuj ich commitować.

## Pełniejszy kontekst

- Indeks i porównanie skilli: [`README.md`](README.md), decision tree planerów: [`dev/README.md`](dev/README.md).
- Pozycjonowanie wariantów planowania: `feature-planner` (v2, wygodny) · `feature-planner-v3` (senior-grade, pełny SDLC) · `planner-f` (planning-only, kończy na planie+ADR, handoff do wykonawcy) · `feature-planner-codex` (Codex CLI).
