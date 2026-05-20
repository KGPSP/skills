# CHANGELOG — feature-planner (v2)

> Wersje przed wprowadzeniem semver zrekonstruowane z historii git (backfill).
> `v2` to generacja wariantu (Claude Code, wygodny rygor) — koegzystuje z `feature-planner-v3`.

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
