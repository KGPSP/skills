# CHANGELOG — feature-spec-planner (historycznie planner-f)

> Skill pochodny od `audited-feature-workflow` — zachowuje fazy analizy/planu/ADR, odcina fazy wykonawcze.
> **Rename 2026-05-25:** `planner-f` → `feature-spec-planner` (folder + frontmatter `name:`). Trigger keywords zachowane (włącznie z `/plan-f` + legacy alias `"planner-f"`).

## [v1.1.0] — 2026-05-25 — Rename: planner-f → feature-spec-planner

### Changed

- **Folder:** `dev/planner-f/` → `dev/feature-spec-planner/` (`git mv`, history preserved).
- **Frontmatter SKILL.md:** `name: planner-f` → `name: feature-spec-planner`. H1 z notą historyczną.
- **`parent:` w 8× `references/*.md`** — wszystkie zsynchronizowane na `feature-spec-planner`.
- **Trigger keywords:** główny trigger zaktualizowany z `"planner-f"` na `"feature-spec-planner"`; **`"planner-f"` zachowany jako legacy alias** (backward-compat dla user'ów którzy nadal wpisują starą nazwę).
- **`/plan-f` slash command** — zachowany bez zmian (różny pattern, sed go nie zamienił).
- **Komentarze w `scripts/check-plan-complete.sh`** — zsynchronizowane.
- **Cross-refs w pozostałych skillach** (`audited-feature-workflow`, `replit-style-workflow`, root README/CHANGELOG, AGENTS.md) — wszystkie `planner-f` → `feature-spec-planner` zsynchronizowane przez globalny sed.

### Why

Po renamach `feature-planner` → `replit-style-workflow` (v2.3.0) i `feature-planner-v3` → `audited-feature-workflow` (v3.3.0), `planner-f` był jedynym skillem w `dev-tools` plugin ze skrótowym, niejasnym sufixem `-f` (gdzie `f` = `final`/`finalize`?). Nazwa nie wskazywała na unikalną wartość: **planning-only workflow** produkujący spec (Analysis Report + Plan + ADR) bez wykonania. `feature-spec-planner` jasno wskazuje:
- **`feature`** — zakres (feature lifecycle)
- **`spec`** — kluczowy output (AC ↔ Test specification, DoD-spec, Thin Vertical Slices spec)
- **`planner`** — zachowane powiązanie z planowaniem

Plus konsystencja: wszystkie 3 renamed dev workflow skille mają teraz opisowe nazwy (replit-style-workflow / audited-feature-workflow / feature-spec-planner) — naming convention w plugin spójna.

### Co NIE zmienia się

- **Funkcjonalność skilla** — pure rename refactor, zero zmian w SKILL.md content czy references.
- **Trigger keywords** — wszystkie zachowane (włącznie z `/plan-f` slash + nowy legacy alias `"planner-f"` dla backward-compat).
- **Relacja `derives-from: audited-feature-workflow`** — zachowana (skill dziedziczy z senior-grade workflow, ale odcina fazy wykonawcze).
- **22/22 testów `agent-teams-builder/tests/run-meta-tests.sh`** — regresja sprawdzona.

### Migracja

Wywoływanie przez trigger phrasy → bez zmian. Wywoływanie przez nazwę `name:`:
- Stara: `planner-f` — nadal działa (legacy trigger).
- Nowa: `feature-spec-planner` — preferowana.

### Sources

- DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §4 (nazwa skilla: kebab-case, opisowa względem zawartości — `-f` był niejednoznaczny).
- DOC/material_skill.md §6 (Meta-Skill Router — `name:` powinien jednoznacznie wskazywać funkcjonalność).

---

## [v1.0.0] — 2026-05-21 — initial release (planning-only)

### Added

- Workflow planowania, analizy i dokumentacji w **7 fazach** z **1 bramką akceptacji** na końcu (Phase 6).
- Zachowane z v3: Deep Analysis, Hyrum's Law Impact, Chesterton's Fence, ≥3 hipotezy (Minimal/Idiomatic/Ambitious), Recommendation, Plan Document (AC matrix + DoD-spec + Thin Vertical Slices + Out-of-scope + Rollback), ADR, auto-narastające gotchas.
- 5 Non-negotiables i 11-wierszowa Anti-Rationalization Table w **wersji planistycznej** (tylko reguły dotyczące analizy/AC/scope/Hyrum/Chesterton/dokumentacji).
- AC ↔ Test (Beyoncé Rule) i DoD evidence jako **specyfikacja** dla wykonawcy — feature-spec-planner nie uruchamia testów ani nie zbiera raw artefaktów.
- Skrypty: `api-impact-scan.sh` (Hyrum scan, z v3) + nowy `check-plan-complete.sh` (bramka kompletności pakietu: sekcje planu, niepuste komórki AC, Out-of-scope, fragile→Rollback).
- Fixtures: `complete-plan.md` (gate exit 0) + `incomplete-plan.md` (gate exit 1).
- Handoff summary po akceptacji — wskazuje skill wykonawczy (audited-feature-workflow / agent-teams-builder).

### Removed (vs audited-feature-workflow)

- Fazy wykonawcze: Phase 6 implementacja, 6.5 Prove-It, 7 testy (7 scopes), 7.8 live preview, 8 Five-Axis code review.
- Tryby pętli: ralph-loop, Agent Teams, `/goal` (Phase 5.8 + 6-Goal + Gate #1.5).
- Skrypty wykonawcze: `extract-raw-log.sh`, `check-ac-coverage.sh`, `verify-build-clean.sh`, `check-pr-size.sh`, `derive-goal-from-ac.sh`, `run-goal-loop.sh`.
- Referencje wykonawcze: `testing-protocol.md`, `code-review-protocol.md`, `five-axis-review.md`, `fragile-operations-protocol.md`, `goal-mode-protocol.md` (fragile zachowane jako wymóg sekcji Rollback w planie).
- Sekcje ADR `## Parallelization` (6-Teams) i `## Ralph-iterations` (6-Ralph).
