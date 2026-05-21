# CHANGELOG — planner-f

> Skill pochodny od `feature-planner-v3` — zachowuje fazy analizy/planu/ADR, odcina fazy wykonawcze.

## [v1.0.0] — 2026-05-21 — initial release (planning-only)

### Added

- Workflow planowania, analizy i dokumentacji w **7 fazach** z **1 bramką akceptacji** na końcu (Phase 6).
- Zachowane z v3: Deep Analysis, Hyrum's Law Impact, Chesterton's Fence, ≥3 hipotezy (Minimal/Idiomatic/Ambitious), Recommendation, Plan Document (AC matrix + DoD-spec + Thin Vertical Slices + Out-of-scope + Rollback), ADR, auto-narastające gotchas.
- 5 Non-negotiables i 11-wierszowa Anti-Rationalization Table w **wersji planistycznej** (tylko reguły dotyczące analizy/AC/scope/Hyrum/Chesterton/dokumentacji).
- AC ↔ Test (Beyoncé Rule) i DoD evidence jako **specyfikacja** dla wykonawcy — planner-f nie uruchamia testów ani nie zbiera raw artefaktów.
- Skrypty: `api-impact-scan.sh` (Hyrum scan, z v3) + nowy `check-plan-complete.sh` (bramka kompletności pakietu: sekcje planu, niepuste komórki AC, Out-of-scope, fragile→Rollback).
- Fixtures: `complete-plan.md` (gate exit 0) + `incomplete-plan.md` (gate exit 1).
- Handoff summary po akceptacji — wskazuje skill wykonawczy (feature-planner-v3 / agent-teams-builder).

### Removed (vs feature-planner-v3)

- Fazy wykonawcze: Phase 6 implementacja, 6.5 Prove-It, 7 testy (7 scopes), 7.8 live preview, 8 Five-Axis code review.
- Tryby pętli: ralph-loop, Agent Teams, `/goal` (Phase 5.8 + 6-Goal + Gate #1.5).
- Skrypty wykonawcze: `extract-raw-log.sh`, `check-ac-coverage.sh`, `verify-build-clean.sh`, `check-pr-size.sh`, `derive-goal-from-ac.sh`, `run-goal-loop.sh`.
- Referencje wykonawcze: `testing-protocol.md`, `code-review-protocol.md`, `five-axis-review.md`, `fragile-operations-protocol.md`, `goal-mode-protocol.md` (fragile zachowane jako wymóg sekcji Rollback w planie).
- Sekcje ADR `## Parallelization` (6-Teams) i `## Ralph-iterations` (6-Ralph).
