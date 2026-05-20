# `dev/` — Narzędzia developerskie

Workflowy planowania/implementacji feature'a, orkiestracja zespołów sub-agentów oraz QA end-to-end dla agentów AI.

## Planowanie feature'a

Trzy warianty pokrywają różne kombinacje **środowiska** (Claude Code vs Codex CLI) i **rygoru** (wygodny vs senior-grade).

| Skill | Wariant | Środowisko | Rygor | Wielkość |
|---|---|---|---|---|
| [`feature-planner`](feature-planner/) | **v2** | Claude Code | wygodny | ~2200 linii SKILL.md |
| [`feature-planner-v3`](feature-planner-v3/) | **v3** | Claude Code | senior-grade | 344 linii SKILL.md + 12 refs + 5 scripts |
| [`feature-planner-codex`](feature-planner-codex/) | **codex** | OpenAI Codex CLI | wygodny | krótszy, codex-native |

## Orkiestracja i QA

Dla projektów wielosprintowych (zespół agentów) i testów aplikacji webowych.

| Skill | Wersja | Rola | Zastosowanie |
|---|---|---|---|
| [`agent-teams-builder`](agent-teams-builder/) | **v1.3.0** | orkiestrator | Zespół sub-agentów Generator-Ewaluator (Planner + Generator + Evaluator + specjaliści). 7-fazowa procedura, twarde rubryki, pivot (Plan-Validate-Execute), tryb `/goal`, meta-testy walidatorów (11/11). Dla „zbuduj aplikację od zera", projektów >2h. |
| [`playwright-test-suite`](playwright-test-suite/) | **v1.0.1** | QA / Evaluator-Runtime | 5-fazowa procedura (smoke → UI → DevTools → a11y → visual) przez Playwright CLI + `@axe-core/playwright` + pixel-diff. Sub-agent `playwright-runner`, evidence zgodne z DoD agent-teams-builder. Standalone QA lub deleguje z evaluatora. |

> **Relacja:** `agent-teams-builder` Evaluator deleguje pełne QA do sub-agenta `playwright-runner` z `playwright-test-suite` (`Task(subagent_type: "playwright-runner")`), zamiast wywoływać Playwright inline. Oba respektują Google DNA (Hyrum / Chesterton / Beyoncé / DAMP) — patrz audit w głównym [`CHANGELOG.md`](../CHANGELOG.md).

---

## Decision tree: który feature-planner użyć?

```
START
  │
  ├── Środowisko = Codex CLI (nie Claude Code)?
  │     └── YES → feature-planner-codex
  │
  ├── Zadanie dotyka fragile zone (DB migration, auth core, infra, secrets)?
  │     └── YES → feature-planner-v3 (Plan-Validate-Execute reżim)
  │
  ├── Wymagana audytowalność (compliance, regulatory, post-mortem-ready)?
  │     └── YES → feature-planner-v3 (raw artifacts, evidence per AC)
  │
  ├── Zmiana > 300 linii lub publiczne API?
  │     └── YES → feature-planner-v3 (PR Sizing gate, Hyrum impact)
  │
  ├── Bugfix?
  │     └── YES → feature-planner-v3 (Prove-It Pattern w Phase 6.5)
  │
  └── Typowy feature, mid-size, niska wrażliwość?
        └── feature-planner (v2)
```

---

## Porównanie szczegółowe v2 vs v3

### Co wspólne (v3 dziedziczy z v2)

- 11 baz faz (Phase 0–9 + 5.5 worktree + 5.7 ralph decision)
- Agent Teams routing (6-Sequential / 6-Teams 2–5 / 6-Ralph autonomous)
- Worktree decision matrix (S/M/L + overrides)
- 7 test scopes (unit / integration / system / acceptance / E2E Playwright tier 1–4 / regression / perf+security)
- Ralph-loop autonomous mode
- ADR generation (Phase 9)
- ZERO Gemini (deep-research przez context7 / Explore / WebSearch / codex)

### Co dokleja v3

| Obszar | Wzmocnienie v3 |
|---|---|
| **Wymówki agenta** | 15-wpisowa Anti-Rationalization Table + per-faza redirects + osobne wpisy dla ralph-loop |
| **Definition of Done** | Surowe artefakty (raw log, screenshot, trace) — bez parafraz modelu |
| **PR Sizing** | Twardy gate: ≤100 optymalne, ≤300 z uzasadnieniem, >1000 hard stop split |
| **API changes** | Hyrum's Law impact analysis — `breaking`/`additive`/`internal` klasyfikacja |
| **Deletion** | Chesterton's Fence — `Why this existed:` w PR description przed `git rm` |
| **Testy** | Beyoncé Rule 1:1 AC↔Test mapping + DAMP over DRY checklist |
| **Bugfix** | Prove-It Pattern (Phase 6.5 NOWA) — failing test reproducer PRZED fixem |
| **Implementacja** | Thin Vertical Slices (end-to-end odnogi, nie warstwa-po-warstwie) |
| **Fragile ops** | Plan-Validate-Execute reżim dla DB/infra/auth |
| **Code Review** | Five-Axis Review (Correctness/Readability/Architecture/Security/Performance) z severity Critical/Optional/Nit/FYI |
| **Konstrukcja skilla** | HARD limit SKILL.md ≤500 linii, imperatywny tryb, kebab-case, `{baseDir}`, scripts/ deterministyczne |

### Struktura plików v3

```
feature-planner-v3/
├── SKILL.md (344 linii, ≤500 hard limit)
├── references/
│   ├── analysis-protocol.md          # + Hyrum + Chesterton
│   ├── ac-protocol.md                # + Beyoncé 1:1
│   ├── code-review-protocol.md       # + PR Sizing + Five-Axis redirect
│   ├── testing-protocol.md           # + DAMP + raw logs + Prove-It
│   ├── adr-template.md               # kopia z v2 (bez zmian)
│   ├── anti-rationalization.md       # NOWY — 15 wpisów + ralph-loop variant
│   ├── non-negotiables.md            # NOWY — 7 zasad master
│   ├── dod-evidence-protocol.md      # NOWY — formaty dowodów per AC type
│   ├── fragile-operations-protocol.md # NOWY — Plan-Validate-Execute
│   ├── incremental-implementation.md # NOWY — Thin Vertical Slices
│   ├── five-axis-review.md           # NOWY — 5 osi + severity + Multi-Model
│   └── gotchas.md                    # NOWY — auto-populating projektowych anomalii
└── scripts/                          # NOWE — 5 deterministycznych skryptów POSIX
    ├── check-pr-size.sh              # PR sizing gate (Phase 6, Phase 8)
    ├── verify-build-clean.sh         # Build clean enforcement (Phase 7)
    ├── check-ac-coverage.sh          # 1:1 AC ↔ test mapping (Phase 7)
    ├── extract-raw-log.sh            # DoD evidence helper (Phase 7)
    └── api-impact-scan.sh            # Hyrum risk scan (Phase 1.5)
```

---

## Trigger keywords

### feature-planner (v2)

```
"dodaj feature v2", "zaimplementuj", "zrób żeby", "implement",
"build feature", "ralph", "ralph-loop", "iteruj aż zielono"
```

### feature-planner-v3

```
"feature-planner v3", "dodaj feature v3", "senior-grade feature",
"implement v3", "zaimplementuj v3", "ralph v3"
```

### feature-planner-codex

Aktywowany w środowisku Codex CLI — patrz `feature-planner-codex/SKILL.md`.

---

## Negative triggers (v3)

v3 jest *targeted skill* — nie aktywuje się dla:

- „przeczytaj plik X"
- „wytłumacz co robi ten kod"
- „popraw literówkę"
- „rename variable"
- jednoliniowych poprawek bez impactu architektonicznego
- eksploracji repozytorium bez zamiaru implementacji

Dla tych zadań — bez skilla lub bezpośrednie wywołanie narzędzi.

---

## Koegzystencja

v2 i v3 koegzystują — żadnych zmian w plikach v2 podczas wdrożenia v3. Wybór świadomy przez trigger lub manualnie. Brak automatycznego routera v2/v3 (intentional — user decyduje na podstawie kontekstu zadania).

## Anty-pattern: nie używaj v3 dla wszystkiego

v3 ma wysoki overhead (15 wpisów anti-rationalization, raw artifacts, PR sizing gate, Hyrum scan). Dla zadań typu *„dodaj prosty getter do klasy"* to przesada — użyj v2 lub bez skilla. v3 zwraca się przy zadaniach o realnym ryzyku (compliance, fragile ops, publiczne API, duże diffy).

## Źródła pryncypiów v3

- [Addy Osmani — Agent Skills](https://addyosmani.com/blog/agent-skills/) (Engineering Director, Google Chrome)
- [addyosmani/agent-skills — GitHub](https://github.com/addyosmani/agent-skills) (MIT, 39K+ ⭐)
- *Software Engineering at Google* (O'Reilly, 2020) — Beyoncé Rule, DAMP over DRY, Hyrum's Law, Chesterton's Fence
- [Anthropic — The Complete Guide to Building Skills for Claude](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) — best practices dla skill creators
