# CHANGELOG — feature-planner-v3

> Wersje przed wprowadzeniem semver zrekonstruowane z historii git (backfill).
> Major `v3` to generacja wariantu (senior-grade) — koegzystuje z `feature-planner` (v2).

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
