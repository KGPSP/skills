# CHANGELOG — audited-feature-workflow (historycznie feature-planner-v3)

> Wersje przed wprowadzeniem semver zrekonstruowane z historii git (backfill).
> Wariant **senior-grade** Claude Code workflow — koegzystuje z `replit-style-workflow` (wygodny, historycznie `feature-planner-v2`) i `feature-spec-planner` (planning-only).
> **Rename 2026-05-25:** `feature-planner-v3` → `audited-feature-workflow` (folder + frontmatter `name:`). Trigger keywords zachowane (`/goal`, `senior-grade feature`, `dodaj feature v3`).

## [v3.7.0] — 2026-05-30 — Domknięcie luk prozowych: 6 nowych bramek (Phase 4/6/7/8)

### Added
- **6 nowych skryptów-bramek** — koniec egzekucji „prozą" dla pozostałych czynności:
  - `check-plan.sh` — Phase 4/5: plan ma 10 wymaganych sekcji (deterministyczny gate zamiast checklisty HITL).
  - `check-tdd-red.sh` — Phase 6: wymaga RED-log (Status FAILED) — dowód failing testu przed implementacją.
  - `check-anti-rat.sh` — Phase 6/8: sekcja „Anti-rationalization decisions" niepusta (jawne przejście tabeli).
  - `check-test-scopes.sh` — Phase 7: wymagane test scope'y pokryte wg S/M/L (unit … perf/security).
  - `check-five-axis.sh` — Phase 8: CR report ma 5 osi + werdykt.
  - `check-chesterton.sh` — Phase 8: usunięcia definicji wymagają sekcji „Why this existed".
- **13 fixtures GOOD/BAD + 12 meta-test case'ów** → runner `32 → 44 passed`.
- Bramki wpięte w SKILL.md (Phase 5/6/7/8) + indeks; skryptów `12 → 18`.

### Why
Audyt + code review wykazały, że TDD-RED, Anti-Rationalization, 5/7 test scopes, Five-Axis, Chesterton i walidacja planu Phase 4 były egzekwowane wyłącznie prozą. Każda ma teraz deterministyczny gate + meta-test (Beyoncé Rule #12).

### Dowód
- `bash tests/run-meta-tests.sh` → `44/44 passed` (18/18 skryptów ma GOOD+BAD).

## [v3.6.1] — 2026-05-29 — Code-review fixes (1 Critical + 3 Major, pryncypia DOC)

### Fixed
- **[C-1] `run-goal-loop.sh`** — walidacja numeryczności state file przed arytmetyką capów (`case … *[!0-9]*`). Skażony `<goal>-goal-iter-state` nie wywala już skryptu `unbound variable` pod `set -u` PRZED bramką iter/time-cap (caps realnie machine-enforced). + regression test (Prove-It #13).
- **[M-1] SKILL.md** — usunięto fałszywą metrykę „31 case'ów" (runner ≠ 31) → `X/X passed`.
- **[M-2] SKILL.md** — Gate Phase 0: „6/6 pól" → „5/5 pól" (po usunięciu pola `ralph` w v3.5.0).
- **[M-3] effort/Dynamic Workflows egzekwowalne** — `check-analysis-report.sh` wymaga zadeklarowanego `effort-level:` w analysis report (Phase 1). Standard v3.6.0 dostał obserwowalny dowód + fixture + meta-test (koniec „czystej prozy").

### Dowód
- `bash tests/run-meta-tests.sh` → `X/X passed` (+2 case'y: regression corrupt-state C-1, analysis-no-effort M-3).
- Code review: Five-Axis + pryncypia DOC (material §3/§4/§5).

## [v3.6.0] — 2026-05-29 — Dynamic Workflows + ultrathink/effort jako standard analizy

### Added
- **`references/dynamic-workflows-standard.md`** — standard Dynamic Workflows (Claude Code v2.1.154+) + mapowanie rozumowania: **kanon `/effort` (low/medium/high/xhigh/max)**; **ultrathink** = keyword CLI (nie API/web) → fallback `/effort max`; **ultracode** = `/effort ultracode` (xhigh + auto-orkiestracja; alias `/effort xhigh|max`, z disclaimerem). Wzorce pipeline/parallel + adwersaryjna weryfikacja, limity 16/1000, integracja faz 0/1/6/8, reguła ładowania.

### Changed
- **Phase 1** domyślnie `/effort max` (+ ultrathink); M/L → orkiestracja analizy przez Dynamic Workflows. Callout w SKILL.md + `analysis-protocol.md`.
- **SKILL.md frontmatter** — `allowed-tools` += `Workflow`; `sources` += `DOC/dynamic_workflows-cc.md`; `version: v3.5.0 → v3.6.0`.
- **`/goal` exclusivity** += Dynamic Workflows / `ultracode` (hard stop — DW nie wspiera mid-run input wymaganego przez Gate #1.5).

### Why
Decyzja właściciela: `DOC/dynamic_workflows-cc.md` jako standard, analiza na maks. effort. Terminy zweryfikowane przez research workflow w docs Claude Code; `ultracode`/`ultrathink` z fallbackiem na `/effort` — bez zmyślonych komend.

### Dowód
- `bash tests/run-meta-tests.sh` → `30/30 passed`.

## [v3.5.0] — 2026-05-29 — Usunięcie ralph-loop ze skilla

### Removed
- Tryb **ralph-loop**: trigger `ralph v3`; **Phase 5.7** (16→15 faz); route **6-Ralph**; detekcja Ralph mode + pole `ralph` w env-detection (6→5 pól); sekcja `## Ralph-iterations` w `adr-template.md`; wzmianki `/ralph` w exclusivity.

### Changed
- Treść autonomicznej pętli (wciąż aktualna dla 6-Goal) przeniesiona ralph-loop → 6-Goal: `anti-rationalization.md` §3, `dod-evidence-protocol.md` §7, `non-negotiables.md` #7. `check-env-detection.sh` 5 pól; fixture + meta-test zaktualizowane. `version: v3.4.0 → v3.5.0`.

### Dowód
- `bash tests/run-meta-tests.sh` → `30/30 passed`; `ralph` poza CHANGELOG = 0.

> Uwaga: wpis backfillowany 2026-05-29 — commit kodu (`09d7a61`) utrwalił się wcześniej; edycja CHANGELOG zginęła przez usterkę narzędzi w sesji.

## [v3.4.0] — 2026-05-29 — „Zawsze dowód": evidence gates + meta-testy 12/12

### Added
- **Runner `tests/run-meta-tests.sh`** (wcześniej nie istniał) — 30 case'ów GOOD/BAD, `30/30 passed`. Zamknięcie luki: dotąd 0/7 skryptów-bramek miało testy.
- **5 nowych bramek**: `check-env-detection` (Phase 0), `check-analysis-report` (Phase 1), `check-hypotheses` (Phase 2+3), `check-screenshots` (Phase 7.8), `check-adr` (Phase 9) + fixtures.

### Changed
- **`run-goal-loop.sh`** — capy `--max-iter`/`--max-time` egzekwowane maszynowo (plik stanu → `iter-cap-hit`/`time-cap-hit`, exit 2). SKILL.md: bullety Gate Phase 0/1/2/3/7.8/9; usunięto „0/7"; `version: v3.3.0 → v3.4.0`. `testing-map.md`: 12/12 ✅.

### Dowód
- `bash tests/run-meta-tests.sh` → `30/30 passed`.

> Uwaga: wpis backfillowany 2026-05-29 — commit kodu (`23b3fb4`) utrwalił się wcześniej; edycja CHANGELOG zginęła przez usterkę narzędzi w sesji.

## [v3.3.0] — 2026-05-25 — Rename: feature-planner-v3 → audited-feature-workflow

### Changed

- **Folder:** `dev/feature-planner-v3/` → `dev/audited-feature-workflow/` (`git mv`, history preserved).
- **Frontmatter SKILL.md:** `name: feature-planner-v3` → `name: audited-feature-workflow`. Heading H1 zaktualizowany z notą historyczną.
- **`parent:` w 13× references/*.md** — wszystkie zsynchronizowane na `audited-feature-workflow`.
- **Komentarze w scripts/** (3 wystąpienia: `check-pr-size.sh`, `derive-goal-from-ac.sh`) — zsynchronizowane.
- **Cross-refs w pozostałych skillach** (replit-style-workflow, feature-spec-planner, agent-teams-builder, swarm-orchestrator) — wszystkie `feature-planner-v3` → `audited-feature-workflow` zsynchronizowane przez globalny sed.

### Why

Po renamie `feature-planner` → `replit-style-workflow` (2026-05-25, v2.3.0) sufix `-v3` stracił semantykę sekwencji (nie ma już „v2" w nazwie poprzednika). „Planner" sugerowało wyłącznie planowanie, podczas gdy skill robi pełen workflow z **unikalnym audit trail**: 6 HITL approval gates + raw evidence per AC + breadcrumbs + Five-Axis Review. Nowa nazwa odzwierciedla unique value proposition vs replit-style-workflow — **audytowalność**, zgodność z compliance/regulated environment KG PSP.

### Co NIE zmienia się

- **Funkcjonalność skilla** — pure rename refactor, zero zmian w SKILL.md content czy references.
- **Trigger keywords** — `/goal`, `senior-grade feature`, `dodaj feature v3`, `ralph v3`, `feature-planner v3`, `implement v3` zachowane bez zmian. Skill aktywuje się tak samo.
- **`extends: replit-style-workflow`** — relacja dziedziczenia zachowana (audited rozszerza replit-style o senior-grade harness).
- **22/22 testów `agent-teams-builder/tests/run-meta-tests.sh`** — regresja sprawdzona.

### Migracja

Wywoływanie przez trigger phrasy → bez zmian. Wywoływanie przez `name:` bezpośrednio → użyj `audited-feature-workflow` (nie `feature-planner-v3`).

### Sources

- DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §4 (nazwa skilla: kebab-case, niemyląca, opisowa względem zawartości).
- DOC/material_skill.md §4 (DoD = dowód — audit trail jest unikalną wartością tego skilla).
- DOC/material_skill.md §6 (Meta-Skill Router — `name:` jednoznacznie wskazuje funkcjonalność).

---

## [v3.2.0] — 2026-05-25 — Test Discipline (mapa unit/integration/regression dla skryptów v3)

### Added

- **`references/testing-map.md`** — mapa meta-testów (**unit / integration / regression**) per skrypt v3 (`scripts/*.sh` × 7). Rozróżnia dwa piętra testowania:
  - **`testing-protocol.md`** (istniejący) → testy aplikacji wytwarzanej przez skill (Phase 7: 7 scopes × S/M/L, AC↔Test, raw log).
  - **`testing-map.md`** (nowy) → meta-testy **samego skilla** (czy `check-pr-size.sh` poprawnie klasyfikuje diff, czy `api-impact-scan.sh` nie myli breaking ↔ additive, etc.).
- **Wykryty rozjazd:** 0 / 7 skryptów v3 ma meta-testy. Fixtures `complete-plan.md` / `incomplete-plan.md` istnieją w `tests/fixtures/` (commit `7947066`) ale są **martwe** — żaden skrypt v3 ich nie wywołuje. Mapa zawiera **TODO retrofitting** z kolejnością priorytetową (1: utworzyć `tests/run-meta-tests.sh` wzorcem a-t-b → 2: `check-pr-size.sh` retrofit → 3: `check-ac-coverage.sh` retrofit → reszta).
- **2 wiersze Anti-Rationalization quick-table** (#12, #13) — wymówki specyficzne dla meta-testów skryptów v3:
  - #12: „Skrypt v3 jest deterministyczny, meta-test zbędny" → Beyoncé Rule dla samego skilla.
  - #13: „Bug w skrypcie v3 — fix, regresji nie dorabiam" → Prove-It Pattern dla skryptu (analog Phase 6.5 ale dla walidatora).
- **1 checkbox w DoD Phase 7** — „Meta-testy skryptów v3 (Beyoncé Rule dla samego skilla)".
- **1 wpis w Indeks referencji** — `testing-map.md` z regułą ładowania.

### Why

User feedback: „jak coś wytwarzasz to tworzysz testy". v3 miał już rygor TDD w Phase 6 (failing test PRZED implementacją) + Phase 6.5 Prove-It dla bugów aplikacji, ALE brakowało analogu dla samego skilla (skryptów-bramek). Bramka Phase 6 (`check-pr-size`) lub Phase 7 (`verify-build-clean`) może milcząco regresować przy refaktorze, jeśli sam skrypt nie ma testu.

### Sources

- DOC/material_skill.md §4 (DoD = dowód), §5 (Beyoncé Rule, DAMP, piramida 80/15/5)
- DOC/since_skill.md §5 (TDD RED-GREEN-REFACTOR + Prove-It Pattern = test regresji)
- DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §9, §10

---

## [v3.1.0] — 2026-05-13 — `/goal` mode

### Added

- **Tryb `/goal`** — autonomiczna pętla weryfikacji AC z mierzalnym stopem:
  - **Phase 5.8** + **Gate #1.5** (Goal Mode decision) + **6-Goal sub-route** w Phase 6.
  - `scripts/derive-goal-from-ac.sh` — parsowanie tabeli AC → goal-statement + goal-prompt.
  - `scripts/run-goal-loop.sh` — driver pętli weryfikacyjnej (dry-run + hand-off).
  - `references/goal-mode-protocol.md` (10 sekcji) + Anti-Rat #11.
  - Fixtures: `complete-plan.md` + `incomplete-plan.md`.
- `/goal` wyłączny z `/ralph` i `/teams`; fragile zone → hard stop.

### Fixed

- Hardening po Five-Axis Review: cytowanie ścieżek w wygenerowanych komendach, dup check tylko dla valid AC-ID, usunięty martwy STRICT, rule 7 / constraints-count / status emitter.

---

## [v3.0.0] — 2026-05-12 — initial release (senior-grade)

### Added

- Senior-grade skill z deterministyczną uprzężą inżynieryjną (18 plików, ~4200 linii): SKILL.md (≤500 hard limit), 12 referencji, 5 skryptów POSIX.
- 15-wpisowa Anti-Rationalization Table, twardy DoD z surowymi artefaktami, PR Sizing (100/300/1000), Hyrum's Law, Chesterton's Fence, Beyoncé Rule 1:1 AC↔Test, DAMP over DRY, Five-Axis Review, Plan-Validate-Execute, Thin Vertical Slices, Prove-It Pattern.
