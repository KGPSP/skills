# Changelog

Historia zmian na poziomie repozytorium. Per-skill detale → commit history poszczególnych folderów.

## [2026-05-25] dev/feature-planner-codex — usunięcie skilla

### Removed

- **`dev/feature-planner-codex/`** — cały skill (8 plików: SKILL.md, CHANGELOG.md, agents/openai.yaml, references/{ac-protocol,adr-template,analysis-protocol,code-review-protocol,testing-protocol}.md). Wariant codex-native (OpenAI Codex CLI) wycofany — repo koncentruje się wyłącznie na Claude Code (3 warianty plannerów: feature-planner v2 · feature-planner-v3 · planner-f).

### Changed

- **`dev-tools`** (plugin) → `v1.2.0`: usunięto `feature-planner-codex` z `skills:` (6 skilli). `description` i `keywords` zaktualizowane (`codex` usunięte z keywords). [`dev/.claude-plugin/plugin.json`](dev/.claude-plugin/plugin.json).
- **`marketplace.json`** (root) → `v1.2.0`: opis `dev-tools` zsynchronizowany z nową listą skilli.
- **`README.md`** (root) — usunięty wiersz tabeli i bullet „Praca w Codex CLI"; tabela „Instalacja" zaktualizowana (`dev-tools` 6 skilli, z swarm-orchestrator zamiast feature-planner-codex); „cztery warianty" → „trzy warianty".
- **`dev/README.md`** — usunięty wiersz tabeli planerów, gałąź decision tree „Środowisko = Codex CLI", sekcja trigger keywords „### feature-planner-codex"; „Cztery warianty" → „Trzy warianty".
- **`AGENTS.md`** — usunięty wpis pozycjonowania `feature-planner-codex (Codex CLI)`.

## [2026-05-24] dev/swarm-orchestrator v1.0.0 — multi-agent tmux orchestration z YOLO/goal

### Added

- **`dev/swarm-orchestrator/`** — nowy skill: orkiestracja 4 agentów Claude Code w tmux -CC panes (parent / planner / generator / evaluator) z 3 trybami (manual / hybrid default / yolo). Komponuje widzialność tmux z [`DOC/agents_swarm/`](DOC/agents_swarm/) (prototyp local-only), rygor 5 bramek + kontrakty + breadcrumbs z [`dev/agent-teams-builder/`](dev/agent-teams-builder/) i autonomię `/goal` z [`dev/feature-planner-v3/`](dev/feature-planner-v3/) (Phase 6-Goal route).
- SKILL.md (268 linii, limit 500) z 8 fazami + 5 bramkami + Anti-Rat 8 wierszy + DoD 12 punktów + frontmatter kanoniczny (`trigger`, `do-not-trigger-for`, `model`, `allowed-tools`, `sources`, `version`, `size-limit`).
- 10× `references/*.md`: modes-protocol, tmux-orchestration, goal-mode-integration, stop-conditions, approval-gates-protocol, pivot-protocol, recovery-protocol, anti-rationalization (pełna tabela 18 wymówek), hook-integration, prd-input-schema.
- 26 skryptów `scripts/`: lib/ (paths/state/prompt/tmux) + swarm-* entry-points + walidatory/checki + **NOWE** `swarm-yolo.sh` (single-iteration driver z 7 STOP conditions + atomic commit guard + auto-pivot), `error-hash.sh` (md5 sygnatury błędu dla no-progress detection), `archive-run.sh` (tar.gz + delete po gate:5).
- 4 agenty `agents/swarm-{parent,planner,generator,evaluator}.md` (1:1 z prototypu DOC/agents_swarm).
- 10 promptów `prompts/`: 4 boot + 5 phase + **NOWY** phase-yolo-iterate.md (generator iteracja w YOLO).
- Assets: plan-template.md, contract-template.json, breadcrumbs-schema.json.
- Tests: 5 fixtures (good/bad PRD) + `run-meta-tests.sh` (47 checków: syntax/fixtures/structure/scripts-exec/error-hash). **47/47 passed.**

### Decyzje produktowe (potwierdzone z user)

- Backend domyślny: **tmux panes** (4 procesy `claude`); Task tool fallback gdy brak tmux.
- Tryb domyślny: **hybrid** (5 bramek HITL + auto między).
- YOLO: **single sprint** per invokacja, **atomic commits** bez `git push`, **auto-pivot** po 3× no-progress.
- State retention: **auto-archive po sukcesie** (gate:5) → `.agents-swarm/archives/{RUN_ID}.tar.gz`; failed runs zostają do debugu.

### Twarde zakazy YOLO (egzekwowane przez `swarm-yolo.sh`)

- `git push`, `npm publish`, `gh pr create`, `gh release`, `DROP`, `rm` poza `paths_in_scope` — zawsze human gate.
- Fragile zones (`migrations/`, `terraform/`, `k8s/`, `auth/`, `.github/workflows/`, `Dockerfile`, `prod*`) — exit 5 chyba że `--force-fragile` (logowane w breadcrumb `fragile_override`).

### Changed

- **`dev-tools`** (plugin) → `v1.1.0`: dodano `swarm-orchestrator` (7 skilli). Zaktualizowano `dev/.claude-plugin/plugin.json` (skills array, version, +4 keywords: tmux/swarm/yolo/goal-mode), `marketplace.json` description (root version 1.0.0 → 1.1.0).

## [2026-05-22] legal/sejm-eli-api v1.0.0 — komunikacja z Sejm ELI API

### Added

- **`legal/sejm-eli-api/`** — nowy skill: warstwa retrieval/grounding dla urzędowego źródła prawa RP przez `api.sejm.gov.pl/eli`. SKILL.md (187 linii) z procedurą 6-fazową + exit criteria, Anti-Rationalization (7 wymówek), DoD, frontmatterem kanonicznym (`trigger`, `do-not-trigger-for`, `sources`, `version`, `size-limit`).
- `references/endpoints.md` — katalog endpointów zweryfikowany `curl`-em 2026-05-22 (`/acts`, `/acts/{pub}/{year}[/{pos}]`, `…/text.html|text.pdf|struct|references`, `/acts/search` z paginacją).
- `references/obsidian-import.md` — format notatki + opcje importera.
- `scripts/eli-fetch.sh` (POSIX, `set -eu`) + `scripts/import-eli-act.py` (vault z `--vault`/`OBSIDIAN_VAULT`, bez ścieżek absolutnych). Oba przetestowane na żywym API (meta/search/import + guardy).
- Pozycjonowanie: warstwa pozyskania metadanych; interpretacja → `legal/opinie-prawne`.

### Changed

- **`legal-tools`** (plugin) → `v1.1.0`: dodano `sejm-eli-api` (2 skille). Zaktualizowano `marketplace.json`, `legal/.claude-plugin/plugin.json`, README (tabela legal + tabela marketplace).

## [2026-05-22] Plugin marketplace — repo jako źródło instalowalne w Claude Code

### Added

- **`.claude-plugin/marketplace.json`** (root) — manifest marketplace `kgpsp-skills` z 3 pluginami wg domen: `pzp-tools`, `legal-tools`, `dev-tools`.
- **`pzp/.claude-plugin/plugin.json`** — plugin `pzp-tools` (4 skille: analyzing-pzp-offers, drafting-pzp-letters, odpowiedzi-pytania, weryfikacja-umow-pzp).
- **`legal/.claude-plugin/plugin.json`** — plugin `legal-tools` (1 skill: opinie-prawne).
- **`dev/.claude-plugin/plugin.json`** — plugin `dev-tools` (6 skilli: agent-teams-builder, feature-planner-v2, feature-planner-v3, feature-planner-v2-codex, planner-f, playwright-test-suite).
- Pole `skills:` w każdym `plugin.json` wskazuje istniejące katalogi skilli wprost (bez przenoszenia plików) — `skills` jest additywne do domyślnego `skills/`. Instalacja: `/plugin marketplace add KGPSP/skills` → `/plugin install <plugin>@kgpsp-skills`. Zwalidowane `claude plugin validate .` (passed).

## [2026-05-22] weryfikacja-umow-pzp v1.1.0 — domknięcie zgodności z DOC

### Fixed

- **`pzp/weryfikacja-umow-pzp/`** — najpoważniejsze naruszenie z całej domeny PZP: **SKILL.md 703 → 480 linii** (twardy limit ≤500). Ciężkie bloki wyniesione do `references/` (`sed`, bajt-w-bajt): `legal-basis-catalog.md` (art. 431–465 + k.c./RODO/KSC/pr.aut.), `edge-cases.md` (18 + Common Mistakes), `format-obsidian.md`, `kg-psp-integration.md`.
- **Ścieżka absolutna `/Users/mklosinski/…`** → `{prawo_dir}`.

### Changed

- **Frontmatter kanoniczny:** `trigger:`, `do-not-trigger-for:` (§7), `model:`, `allowed-tools:` (bez `Edit`), `sources:` (→ DOC), `size-limit:`.
- **Filar 1** — skonsolidowana tabela **exit criteria** faza→artefakt + `TodoWrite`.
- **Filar 2** — Red Flags → tabela **Anti-Rationalization** (9 wymówek).
- **Filar 3** — Deliverables Checklist oznaczona jako **Definition of Done**.
- **Filar 4** — `verification-prompt.md` → `references/` (`git mv`, §1/§10); Supporting Files → tabela **reguł ładowania L3 imperatywnych** (§5); **frontmatter referencji** w 5 plikach `references/` (§10).
- Bez zmian merytorycznych (katalog art. 431–465, 18 edge cases, P1–P7/R1–R4, Iron Law — przeniesione 1:1 do `references/`). SKILL.md 480 linii (≤500).

## [2026-05-22] odpowiedzi-pytania v1.1.0 — domknięcie zgodności z DOC

### Fixed

- **`pzp/odpowiedzi-pytania/`** — trzy bugi przy okazji audytu DOC:
  - latent bug YAML: `description` miał `… \`odpowiedzi_<RRRR-MM-DD>/\`: indeks…` (dwukropek+spacja → rozsypywał frontmatter po dodaniu pól). Zamienione na `—`.
  - ścieżki absolutne `/Users/sq13pl/…` w referencjach (`prawo-index.md`, `pzp-articles-map.md`) → `{prawo_dir}` (§4).
  - over-exclusion w `do-not-trigger-for` („istotna zmiana charakteru" — wykrywane w Phase 4.5, nie pre-aktywacyjnie) usunięte; body „When NOT to Use" zsynchronizowane.

### Changed

- **Frontmatter kanoniczny:** `trigger:`, `do-not-trigger-for:` (§7), `model:`, `allowed-tools:` (`Bash`/`Read`/`Write`/`Glob`/`Grep`/`TodoWrite`, bez `Edit`), `sources:` (→ DOC), `size-limit:`.
- **Filar 1** — skonsolidowana tabela **exit criteria** faza→artefakt + nakaz `TodoWrite`.
- **Filar 2** — Red Flags → kanoniczna tabela **Anti-Rationalization** (9 wymówek).
- **Filar 3** — Phase 7 oznaczona jako **Definition of Done**.
- **Filar 4** — Supporting Files → tabela **reguł ładowania L3 imperatywnych** (§5); **frontmatter referencji** w 4 plikach `references/` (§10) — struktura `references/` była poprawna od początku.
- SKILL.md 483 linie (≤500; miejsce na frontmatter odzyskane kompresją duplikatów — pełna mapa artykułów w `references/pzp-articles-map.md`). Bez zmian merytorycznych (Phase 4.5 STOP-gate, reguły terminowe art. 135/137/284/286, 11 reguł bezwzględnych, Iron Law).

## [2026-05-21] drafting-pzp-letters v1.1.0 — domknięcie zgodności z DOC

### Fixed

- **`pzp/drafting-pzp-letters/`** — dwa bugi przy okazji audytu DOC:
  - **Ścieżka absolutna** w Phase 4 (`/Users/mklosinski/…/wzor_pismo_przewodnie.docx`, cudze konto) → parametr `<template_docx>` w Required Inputs.
  - **Niepoprawny YAML** `description` (`Triggers include:` → `Triggers include —`); frontmatter teraz parsuje się czysto.
  - Exec-bit `scripts/render_docx.py` `100644` → `100755`.

### Changed

- **Frontmatter kanoniczny:** `trigger:`, `do-not-trigger-for:` (§7), `model:`, `allowed-tools:` (`Bash`/`Read`/`Write`/`Glob`/`Grep`/`TodoWrite`, bez `Edit` na kodzie), `sources:` (→ DOC), `size-limit:`.
- **Filar 1** — exit criteria po fazach 0–5 + nakaz `TodoWrite`.
- **Filar 2** — Red Flags → kanoniczna tabela **Anti-Rationalization** (`Wymówka | Riposta`, 10 wymówek).
- **Filar 3** — dodana **Definition of Done** (checklista pakietu pism).
- **Filar 4** — heavy references przeniesione do **`references/`** (`git mv`, §1/§10); Supporting Files → tabela **reguł ładowania L3 imperatywnych** (§5) + jawne ładowanie w Phase 2; **frontmatter referencji** w obu plikach (§10).
- Bez zmian merytorycznych (tabela decyzyjna F→pismo, reguły grupowania/eskalacji, self-cleaning, Iron Law). SKILL.md 398 linii (≤500).

## [2026-05-21] analyzing-pzp-offers v1.1.0 — domknięcie zgodności z DOC

### Changed

- **`pzp/analyzing-pzp-offers/`** — audyt względem `DOC/` i naprawa formalnych niezgodności (bez zmian merytorycznych: 18 edge cases, podstawy prawne Pzp/KSC, Iron Law nietknięte).
  - **Frontmatter kanoniczny:** dodane `trigger:`, **`do-not-trigger-for:`** (§7, z „When NOT to Use"), `model:`, `allowed-tools:` (`Bash`/`Read`/`Write`/`Glob`/`Grep`/`TodoWrite`, bez `Edit` na kodzie), `sources:` (→ DOC), `size-limit:`.
  - **Filar 1** — **exit criteria** po fazach 0–5 + nakaz `TodoWrite`.
  - **Filar 2** — Red Flags → kanoniczna tabela **Anti-Rationalization** (`Wymówka | Riposta`, 9 wymówek domenowych).
  - **Filar 3** — „Deliverables Checklist" oznaczona jako **Definition of Done**.
  - **Filar 4** — Supporting Files → tabela **reguł ładowania L3**; heavy reference przeniesiony do **`references/`** (`git mv`, §1/§10): `references/verification-prompt.md` (odwołania w SKILL.md + templatach zaktualizowane); **frontmatter referencji** (`type: reference`, `parent`, `sources:` → §DOC).
  - Body „When NOT to Use" zsynchronizowane z `do-not-trigger-for`. SKILL.md 499 linii (limit ≤500, margines 1 linia → konsolidacja „Common Mistakes" zaplanowana na v1.2.0).

## [2026-05-21] opinie-prawne v1.1.0 — domknięcie zgodności z DOC

### Changed

- **`legal/opinie-prawne/`** — audyt względem `DOC/` i naprawa formalnych niezgodności (bez zmian merytorycznych w metodzie prawnej).
  - **Frontmatter kanoniczny:** dodane `trigger:`, **`do-not-trigger-for:`** (brakujące Negative Triggers — §7), `model:`, `allowed-tools:` (research+analiza, bez `Edit`/`Bash` na kodzie), `sources:` (→ DOC), `size-limit: 500-lines-hard`.
  - **Filar 2** — kanoniczna tabela **Anti-Rationalization** (`Wymówka | Riposta`, 8 wymówek domenowych) obok istniejących Red flags i Zakazów.
  - **Filar 1** — **exit criteria** po każdym z 9 kroków metody + checklista **Definition of Done** (8 pozycji).
  - **Filar 4** — jawne **reguły ładowania L3** (tabela „załaduj gdy") + **frontmatter referencji** (`type: reference`, `parent`, `sources:` → sekcje DOC z numerem §) w obu plikach `references/` (§10).
  - SKILL.md 464 linie (limit ≤500).

## [2026-05-21] planner-f v1.0.0 — planning-only wariant feature-planner-v3

### Added

- **`dev/planner-f/`** — skill planowania, analizy i dokumentacji feature'a **bez fazy implementacji**. Pochodny od `feature-planner-v3` (fazy 0–5 + ADR), odcina fazy wykonawcze.
  - **SKILL.md** (256 linii, limit ≤500) — **7 faz + 1 bramka akceptacji** (Phase 6): env-detection → deep analysis (Hyrum+Chesterton) → impact radius → ≥3 hipotezy → recommendation → plan (AC matrix + DoD-spec + Thin Slices + Out-of-scope + Rollback) → ADR → handoff.
  - **8 referencji** — `non-negotiables` i `anti-rationalization` przepisane w wersji planistycznej; `analysis-protocol`, `ac-protocol` (+ DAMP + piramida 80/15/5), `dod-evidence-protocol`, `incremental-implementation`, `adr-template`, `gotchas` zaadaptowane (numery faz przemapowane na model planner-f).
  - **2 skrypty** — `api-impact-scan.sh` (Hyrum, z v3) + nowy `check-plan-complete.sh` (bramka kompletności pakietu) + 2 fixtures (gate exit 0 / exit 1).

### Pryncypia (audit DOC)

- **material_skill.md + since_skill.md**: 21/21 pryncypiów obecnych. AC↔Test (Beyoncé), DoD i raw-evidence egzekwowane jako **specyfikacja** (planner-f nie wykonuje); reguły czysto wykonawcze (TDD RED, build clean, Five-Axis, Prove-It) jawnie przekazane wykonawcy.

### Pozycjonowanie

- **planner-f** — wytwarza audytowalny pakiet planistyczny (analiza + plan + ADR), kończy na zatwierdzonym planie.
- **feature-planner-v3** — od Phase 6 realizuje plan (implementacja + testy + review). Komplementarne: planner-f planuje, v3 buduje.

---

## [2026-05-20] Documentation Protocol — agent-teams-builder v1.6.0 + playwright-test-suite v1.2.0

### Added

Pełen audit trail wszystkich dokumentów pracy zespołu agentów. **10 typów dokumentów** w dwóch warstwach:

**Ephemeral (state/):**
- PRD per sprint, TODO snapshot, retrospectives, sessions log, decision log, QA reports, final report

**Committable (docs/):**
- ADRs sekwencyjne (`ADR-{NNNN}-{slug}.md`)
- Five-Axis Code Reviews per sprint passed
- Final reports (kopia z state/)

### Nowe komponenty

- `references/documentation-protocol.md` — pełen protokół (10 typów × kto/kiedy/format)
- 5 templates: PRD, ADR, retrospective, code review (Five-Axis), session log
- 3 skrypty: `init-docs-structure.sh`, `verify-documentation.sh`, `append-session-log.sh`
- Group 8 meta-tests (19/19 passed)

### Why

User chce **wiedzieć co dzieje**. Po v1.6: każda decyzja udokumentowana (ADR), każdy sprint ma retrospektywę + code review, ślad audytu kompletny. Po sesji `/goal` można prześledzić KAŻDĄ decyzję bez surowych breadcrumbs.

---

## [2026-05-20] Planning Rigor (transfer z feature-planner-v3) — agent-teams-builder v1.5.0

### Added

- **Planning Rigor protocol** — `agent-teams-builder` dziedziczy dyscyplinę planistyczną z `feature-planner-v3`:
  - **3 hipotezy per sprint** (Minimal/Idiomatic/Ambitious) z trade-offs, Hyrum risk, kosztem.
  - **11 obowiązkowych sekcji planu** (z 6 do 11): Goal, Sprints (z hipotezami), Dependencies, Open Questions, Out of scope, Success metric, Risks (skalowane H/M/L), **Recommendation summary** (nowa), **Hyrum Impact** (nowa), **Rollback plan** (nowa), **Alternatives considered** (nowa).
  - **AC priorities** MUST/SHOULD/COULD (przejęte z `ac-protocol.md`).
  - **Walidator** `verify-plan-rigor.sh` egzekwujący strukturę.

### Why

Planner v1.4 produkował płaską listę sprintów bez audytu wyborów architektonicznych. Po transferze rygoru z feature-planner-v3 — każda decyzja jest udokumentowana, alternatywy odrzucone explicite, Hyrum Impact wykrywany PRZED implementacją (nie po regresji).

### Test results

- `bash dev/agent-teams-builder/tests/run-meta-tests.sh` → **16/16 passed** (z 14 → 16).

---

## [2026-05-20] context7 MCP integration — agent-teams-builder v1.4.0 + playwright-test-suite v1.1.0

### Added

- **Library Currency Protocol** — wszystkie 4 sub-agenty (planner/generator/evaluator/playwright-runner) OBOWIĄZKOWO wywołują **context7 MCP** przed każdym nowym importem lub setupie biblioteki. Eliminuje halucynacje API (pierwsza przyczyna zerwanej pętli generator-ewaluator).
- **4-poziomowy fallback chain**: context7 → DeepWiki MCP → WebFetch → `npm view` + JSDoc (offline).
- **`scripts/setup-context7.sh`** — idempotentny instalator MCP (per-user `claude mcp add` LUB per-project `.mcp.json`).
- **`scripts/verify-library-currency.sh`** — walidator: każdy sprint dotykający `package.json`/`Cargo.toml`/`requirements.txt`/`go.mod` MUSI mieć breadcrumb `library_currency_checked` z prawidłowym `source`.
- **`references/library-currency-protocol.md`** + **`assets/mcp-config-template.json`** + **`assets/claude-md-template.md`** (auto-invoke regułą).
- **3 nowe meta-testy** w `run-meta-tests.sh` (14/14 passed).

### Why

Halucynacja API (LLM cutoff date) była pierwszą przyczyną patologicznej pętli: Generator pisze przeterminowany kod → Evaluator widzi runtime error → kolejne iteracje z kolejnymi halucynacjami → pivot. Context7 dostarcza aktualną, version-specific dokumentację bibliotek bezpośrednio do kontekstu agenta.

---

## [2026-05-20] audit(dev): Google DNA compliance — agent-teams-builder v1.3.0 + playwright-test-suite v1.0.1

Audit pryncypiów wg `material_skill.md` §5 (Google DNA) + §8 (5 Non-negotiables) + `since_skill.md` §2 (5 filarów) wykrył luki w pokryciu 4 zasad inżynieryjnych Google. Naprawione w obu skillach.

### Changed

- **`dev/agent-teams-builder/`** → **v1.3.0**
  - `SKILL.md` — 4 nowe wymówki anty-racjonalizacyjne (Chesterton's Fence / Hyrum's Law / Beyoncé Rule / DAMP > DRY).
  - `references/anti-rationalization.md §5` — nowa sekcja "Google DNA" z 6 wymówkami i ripostami (przed: **brak Chesterton's Fence**).
- **`dev/playwright-test-suite/`** → **v1.0.1**
  - `SKILL.md` — nowa sekcja "Google DNA" + 4 nowe wymówki + DoD rozszerzony o Beyoncé/DAMP/Chesterton checks + explicit `(Non-negotiable #N)` labels + token budget L2 ≤5000.
  - `references/playwright-ui-protocol.md §5` — nowa sekcja "Google DNA w testach" z przykładami ✅/❌.

### Audit summary (po fixach)

| Zasada | agent-teams-builder | playwright-test-suite |
|---|---|---|
| Hyrum's Law | 8+ wzmianek ✅ | (w obu) ✅ |
| Chesterton's Fence | 5+ (było **0**) ✅ | ✅ |
| Beyoncé Rule | 15+ ✅ | 6+ ✅ |
| DAMP > DRY | 5+ ✅ | 7+ ✅ |

### Sanity tests

- `agent-teams-builder/tests/run-meta-tests.sh` → **11/11 passed** ✅
- `verify-role-isolation.sh` z 4 sub-agentami → ✅

---

## [2026-05-20] playwright-test-suite v1.0.0 + agent-teams-builder integration

### Added

- **`dev/playwright-test-suite/`** — dedykowany skill QA dla aplikacji webowych. 5-fazowa procedura (smoke → UI → DevTools → a11y → visual) przez Playwright CLI + `@axe-core/playwright` + pixelmatch. Pełna struktura:
  - SKILL.md (~250 linii)
  - **agents/playwright-runner.md** — dedykowany sub-agent Claude Code
  - references/ (7 protokołów)
  - scripts/ (7 orchestratorów)
  - templates/ (7 Playwright .ts.tmpl)

### Changed

- **`dev/agent-teams-builder/agents/evaluator.md`** — sekcja "Delegacja do playwright-runner" z gotowym wzorcem `Task(subagent_type: "playwright-runner")`. Evaluator deleguje pełne QA do dedykowanego sub-agenta zamiast wywoływać Playwright/Chrome inline.
- **`dev/agent-teams-builder/scripts/verify-role-isolation.sh`** — uznaje `playwright-runner` jako allowed producer evidence files + dodaje walidację jego izolacji (read-only na kodzie).

### Architecture (po tym sprincie)

```
parent agent (główne okno)
   ├── Task(planner)    → state/plan.md
   ├── Task(generator)  → kod w src/
   └── Task(evaluator)  → werdykt
              └── Task(playwright-runner)  ← NOWY skill
                     ├── 5 faz QA
                     └── state/evidence/sprint-{n}/qa-summary.json
```

---

## [2026-05-20] agent-teams-builder v1.2.0 — meta-tests

### Added

- **`dev/agent-teams-builder/tests/`** — 7 fixtures testowych (GOOD/BAD przykłady dla każdego walidatora) + `run-meta-tests.sh` (11 testów w 5 grupach, sprawdza że walidatory zachowują się zgodnie z oczekiwaniem).

### Fixed

- `scripts/check-breadcrumbs-append-only.sh` — bug `set -e -o pipefail` aborts skrypt gdy `grep` nie znajduje matchu w pipe. Naprawione przez lokalne `set +o pipefail`.

### Test results

- `bash tests/run-meta-tests.sh` → **11/11 passed**.

---

## [2026-05-20] agent-teams-builder v1.1.0

### Added

- **`dev/agent-teams-builder/`** — orkiestracja zespołu sub-agentów (Planner + Generator + Evaluator + opcjonalni specjaliści) wg wzorca Generator-Ewaluator do realizacji złożonych zadań programistycznych.
  - **SKILL.md** (~270 linii, limit ≤500) — 7-fazowa procedura (bootstrap → ship) z exit criteria per faza.
  - **`agents/`** (3 pliki) — gotowe definicje sub-agentów Claude Code (`planner.md`, `generator.md`, `evaluator.md`) z izolowanymi tools (Generator BEZ Playwright, Evaluator BEZ Edit).
  - **`references/`** (10 protokołów, ~2200 linii) — progresywne ładowanie: `contract-negotiation`, `evaluator-rubric`, `pivot-protocol`, `memory-filesystem`, `role-mapping`, `goal-mode-protocol`, `anti-rationalization`, `non-negotiables`, `dod-evidence-protocol`, `traces-reading`.
  - **`scripts/`** (12 skryptów bash, ~1000 linii) — `init-team-state`, `append-breadcrumb`, `check-contract-coverage`, `verify-evaluator-rubric`, `pivot-trigger`, `smoke-test-runner`, `check-breadcrumbs-append-only`, `verify-role-isolation`, `check-evidence-completeness`, `run-goal-loop`, `check-scope-discipline`, `verify-non-negotiables`.
  - **`assets/`** (6 plików) — szablon kontraktu z 15 binarnymi kryteriami, few-shot rubryki "good design vs AI slop", JSON schemy dla feature_list i breadcrumbs, plan template, prompt-templates.
  - **Tryb `/goal`** — autonomiczna pętla AC z auto-pivotem po MAX_ITERATIONS.
  - **Mechanizm pivota** — Plan-Validate-Execute dla operacji destruktywnych, archiwizacja branchu przed `rm -rf`, opcjonalny human hook (`PIVOT_REQUIRES_HUMAN=1`).

### Source

- `DOC/agent-teams-generator-ewaluator.md` (wzorzec Generator-Ewaluator, sekcje 1-10)
- `DOC/material_skill.md` §8 (5 Non-negotiables)
- `DOC/since_skill.md` §2 (5 filarów: Process / Anti-Rat / Verification / Progressive / Scope)
- `DOC/goal_mode.md` (przykłady `/goal` z mierzalną weryfikacją)

### Pozycjonowanie vs feature-planner-v3

- **feature-planner-v3** — pojedynczy feature, 1 sesja, 1 agent. Optymalny dla 100-300 linii diff.
- **agent-teams-builder** (ten skill) — projekty wielosprintowe, zespół sub-agentów z presją rywalizacyjną, dla pracy >2h. Optymalny dla "zbuduj aplikację od zera".

---

## [2026-05-12] feature-planner-v3 + dokumentacja repo

### Added

- **`dev/feature-planner-v3/`** — nowy senior-grade skill (18 plików, 4200 linii):
  - SKILL.md (344 linii, hard limit ≤500)
  - 12 referencji (`anti-rationalization`, `non-negotiables`, `dod-evidence-protocol`, `fragile-operations-protocol`, `incremental-implementation`, `five-axis-review`, `gotchas` + 4 rozszerzone z v2 + `adr-template`)
  - 5 deterministycznych skryptów POSIX (`check-pr-size`, `verify-build-clean`, `check-ac-coverage`, `extract-raw-log`, `api-impact-scan`)
- **`dev/README.md`** — decision tree + porównanie v2 vs v3 + struktura plików v3
- **`pzp/README.md`** — indeks 4 skilli PZP z mapowaniem na fazy postępowania
- **`CHANGELOG.md`** — niniejszy plik
- **`.gitignore`** — wyłączenia (`DOC/`, macOS artefakty, IDE, `node_modules`, Python cache, secrets, tmp logs)

### Changed

- **`README.md`** (top-level) — dodano `feature-planner-v3` do tabeli `dev/`, sekcja "Wybór dev/feature-planner (skrót)", sekcja "Pryncypia projektowania skilli (od v3)"

### Reżim koegzystencji

`feature-planner` (v2) i `feature-planner-v3` koegzystują — żadnych zmian w plikach v2. Wybór świadomy przez trigger (`v3` w prompcie → v3, inaczej → v2).

---

## [Wcześniej]

Pojedyncze commity feature-by-feature na branchu `main`. Główne kamienie milowe (z git history):

- `0fd51c0` — feature-planner: TodoWrite usage + harden Ralph-loop
- `3efab06` — Add Ralph-loop autonomous workflow
- `7dcf821` — Add worktree decision (Phase 5.5) and live preview (Phase 7.8)
- `0bb6456` — Add 7-scope testing matrix and Playwright fallback
- `0ba33ae` — init: KGPSP skills catalog (pzp, legal, dev)

Pełna historia: `git log --oneline`.
