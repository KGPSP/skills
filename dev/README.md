# `dev/` — Narzędzia developerskie

Workflowy planowania/implementacji feature'a, orkiestracja zespołów sub-agentów oraz QA end-to-end dla agentów AI.

## Planowanie feature'a

Trzy warianty pokrywają różne kombinacje **rygoru** (wygodny vs senior-grade) oraz **zakresu** (planowanie+implementacja vs samo planowanie). Wszystkie pracują w Claude Code.

| Skill | Wariant | Wersja | Rygor | Zakres | Wielkość |
|---|---|---|---|---|---|
| [`replit-style-workflow`](replit-style-workflow/) | **wygodny** (historycznie v2) | `v2.3.0` | wygodny | plan + implementacja | ~2200 linii SKILL.md |
| [`audited-feature-workflow`](audited-feature-workflow/) | **senior-grade** (historycznie v3, Opus 4.8) | `v3.10.0` | senior-grade | plan + implementacja | 480 linii SKILL.md + 17 refs + 21 scripts + 2 workflows |
| [`feature-spec-planner`](feature-spec-planner/) | **planning-only** (historycznie planner-f) | `v1.1.0` | senior-grade | **tylko plan + analiza + ADR** | 256 linii SKILL.md + 8 refs + 2 scripts |

> **`feature-spec-planner` vs `audited-feature-workflow`:** ten sam rygor analityczno-planistyczny (fazy 0–5 + ADR), ale feature-spec-planner **kończy na zatwierdzonym planie** — nie pisze kodu, nie pisze/uruchamia testów, nie commituje. Reguły wykonawcze (TDD RED, build clean, Five-Axis, Prove-It, PR sizing przy commitach) są **specyfikowane** w planie i przekazywane wykonawcy (handoff do v3 Phase 6+ lub `agent-teams-builder`). Używaj, gdy chcesz oddzielić „co/dlaczego budujemy" od „budujemy".

## Orkiestracja i QA

Dla projektów wielosprintowych (zespół agentów) i testów aplikacji webowych.

| Skill | Wersja | Rola | Zastosowanie |
|---|---|---|---|
| [`agent-teams-builder`](agent-teams-builder/) | **v1.9.0** | orkiestrator | Zespół sub-agentów Generator-Ewaluator (Planner + Generator + Evaluator + specjaliści). 7-fazowa procedura + **6 HITL approval gates** + tryby `/goal` i `/YOLO`. Twarde rubryki, pivot (Plan-Validate-Execute), Planning Rigor, context7 MCP, Documentation Protocol (10 typów dokumentów), Test Discipline (mapa meta-testów walidatorów). **22/22 cases passed** w runnerze. Dla „zbuduj aplikację od zera", projektów >2h. |
| [`playwright-test-suite`](playwright-test-suite/) | **v1.2.0** | QA / Evaluator-Runtime | 5-fazowa procedura (smoke → UI → DevTools → a11y → visual) przez Playwright CLI + `@axe-core/playwright` + pixel-diff. Sub-agent `playwright-runner`, QA Report (`state/qa-reports/`), evidence zgodne z DoD agent-teams-builder. Standalone QA lub deleguje z evaluatora. |
| [`qa-architect`](qa-architect/) | **v1.0.1** | QA blueprint orchestrator (setup-time) | Multi-stack (Next.js/React, Node generic, Python, Go + PostgreSQL) generator strategii i konfiguracji testów. Orkiestruje Managera + 5 sub-agentów (tooling-decisor, config-builder, test-author, ci-author, reviewer) zgodnie z paradygmatem QA-swarm (DOC/QA-swarm.md §2.2). 8 faz + 2 bramki approval. Produkuje `qa-blueprint/` z 24 plikami (qa-strategy + configs + samples + ci + CLAUDE.md.patch + AGENTS.md + verify-tests skill + checklists + pilot 4-tyg). Wymusza realny Postgres via Testcontainers + semantic queries + Playwright nad Cypress greenfield. **18/18 meta-tests passed** (16 oryginalne + 2 monorepo exit 3). |
| [`swarm-orchestrator`](swarm-orchestrator/) | **v1.0.0** | multi-agent tmux | Orkiestracja 4 agentów Claude Code w tmux -CC panes (parent / planner / generator / evaluator) w 3 trybach (manual / hybrid / yolo). Komponuje widzialność tmux z rygorem 5 bramek + kontrakty + breadcrumbs (`agent-teams-builder`) i autonomią `/goal` (`audited-feature-workflow` 6-Goal route). Single-sprint per invokacja YOLO, atomic commits, auto-pivot po 3× no-progress. |

### Ewolucja agent-teams-builder (v1.1 → v1.9)

| Wersja | Kamień milowy |
|---|---|
| v1.1.0 | Bazowa orkiestracja (Planner/Generator/Evaluator + pivot + `/goal`) |
| v1.2.0 | Meta-testy walidatorów + 7 fixtures |
| v1.3.0 | Google DNA compliance (Chesterton / Hyrum / Beyoncé / DAMP) |
| v1.4.0 | **context7 MCP** — Library Currency Protocol (eliminacja halucynacji API), 4-poziomowy fallback chain |
| v1.5.0 | **Planning Rigor** (transfer z `audited-feature-workflow`) — 3 hipotezy/sprint, 11 sekcji planu, Hyrum Impact, `verify-plan-rigor.sh` |
| v1.6.0 | **Documentation Protocol** — pełen audit trail (10 typów dokumentów: PRD/ADR/retro/Five-Axis CR/QA/sessions), `verify-documentation.sh` |
| v1.7.0 | **6 HITL Approval Gates** (transfer z `audited-feature-workflow`) — `verify-approval-gates.sh` + `references/approval-gates-protocol.md`. `/goal` respektuje wszystkie bramki. |
| v1.7.1 | Planning = effort max (ultrathink) — Planner spawn z najwyższym budżetem rozumowania |
| v1.8.0 | **Tryb `/YOLO`** — jawny opt-in autonomii bez bramek (przywraca pętlę „odpal i zostaw" sprzed v1.7); twarde rails destruktywne zachowane |
| v1.9.0 | **Test Discipline** — `references/testing-map.md` mapuje unit/integration/regression dla każdego walidatora (10/19 unit ✅, 3/19 integration ✅, 22/22 cases passed) |

> **Relacja:** `agent-teams-builder` Evaluator deleguje pełne QA do sub-agenta `playwright-runner` z `playwright-test-suite` (`Task(subagent_type: "playwright-runner")`), zamiast wywoływać Playwright inline. Runner produkuje `state/qa-reports/sprint-N.md` zgodny z Documentation Protocol. Oba respektują Google DNA (Hyrum / Chesterton / Beyoncé / DAMP) i context7 MCP (currency check) — patrz audit w głównym [`CHANGELOG.md`](../CHANGELOG.md).

---

## Decision tree: który feature-planner użyć?

```
START
  │
  ├── Chcesz TYLKO plan/analizę/ADR (kod napisze ktoś inny / później)?
  │     └── YES → feature-spec-planner  (kończy na zatwierdzonym planie, handoff)
  │
  ├── Zadanie dotyka fragile zone (DB migration, auth core, infra, secrets)?
  │     └── YES → audited-feature-workflow (Plan-Validate-Execute reżim)
  │
  ├── Wymagana audytowalność (compliance, regulatory, post-mortem-ready)?
  │     └── YES → audited-feature-workflow (raw artifacts, evidence per AC)
  │
  ├── Zmiana > 300 linii lub publiczne API?
  │     └── YES → audited-feature-workflow (PR Sizing gate, Hyrum impact)
  │
  ├── Bugfix?
  │     └── YES → audited-feature-workflow (Prove-It Pattern w Phase 6.5)
  │
  └── Typowy feature, mid-size, niska wrażliwość?
        └── replit-style-workflow (historycznie feature-planner-v2)
```

---

## Porównanie szczegółowe replit-style-workflow vs audited-feature-workflow

### Co wspólne (audited dziedziczy z replit-style)

- 11 baz faz (Phase 0–9 + 5.5 worktree + 5.7 ralph decision)
- Agent Teams routing (6-Sequential / 6-Teams 2–5 / 6-Ralph autonomous)
- Worktree decision matrix (S/M/L + overrides)
- 7 test scopes (unit / integration / system / acceptance / E2E Playwright tier 1–4 / regression / perf+security)
- Ralph-loop autonomous mode
- ADR generation (Phase 9)
- ZERO Gemini (deep-research przez context7 / Explore / WebSearch / codex)

### Co dokleja audited-feature-workflow

| Obszar | Wzmocnienie audited |
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

### Struktura plików audited-feature-workflow

```
audited-feature-workflow/                  # v3.10.0, Opus 4.8
├── SKILL.md (480 linii, ≤500 hard limit)  # 17 faz + 6 bramek HITL
├── references/                            # 17 protokołów (L3 progressive disclosure)
│   ├── analysis-protocol.md · ac-protocol.md · code-review-protocol.md
│   ├── testing-protocol.md · dod-evidence-protocol.md · five-axis-review.md
│   ├── anti-rationalization.md (15 wpisów) · non-negotiables.md · adr-template.md
│   ├── fragile-operations-protocol.md · incremental-implementation.md · gotchas.md
│   ├── goal-mode-protocol.md · hypothesis-eval-protocol.md · testing-map.md
│   ├── deep-research-protocol.md          # Phase 1.0 (context7 obligatoryjny)
│   └── dynamic-workflows-standard.md      # Phase 1/6/8 orchestration + macierz wykluczeń
├── scripts/                               # 21 deterministycznych bramek POSIX (pełny indeks: SKILL.md „Skrypty")
│   ├── check-pr-size · verify-build-clean · check-ac-coverage · extract-raw-log · api-impact-scan
│   ├── check-{env-detection,analysis-report,research-log,hypotheses,plan,tdd-red,anti-rat,test-scopes}
│   ├── check-{screenshots,adr,five-axis,chesterton} · derive-goal-from-ac · run-goal-loop
│   └── check-orchestration-decl · check-workflow-scripts          # v3.10.0
├── workflows/                             # v3.10.0 — szablony Dynamic Workflow (.js, exemplar)
│   ├── phase1-fanout-analysis.js          # fan-out analizy per podsystem
│   └── phase8-five-axis-review.js         # agent per oś + adwersaryjna weryfikacja
└── tests/                                 # run-meta-tests.sh (66/66) + run-e2e.sh (22/22 + 7/7) + fixtures/
```

---

## Trigger keywords

### replit-style-workflow (historycznie feature-planner-v2)

```
"dodaj feature v2", "zaimplementuj", "zrób żeby", "implement",
"build feature", "ralph", "ralph-loop", "iteruj aż zielono"
```

### audited-feature-workflow (historycznie feature-planner-v3)

```
"feature-planner v3", "dodaj feature v3", "senior-grade feature",
"implement v3", "zaimplementuj v3", "ralph v3", "/goal", "goal mode"
```

### feature-spec-planner (historycznie planner-f)

```
"feature-spec-planner", "planner-f" (legacy alias), "zaplanuj feature",
"przeanalizuj i zaplanuj", "przygotuj plan", "przygotuj specyfikację",
"zaprojektuj rozwiązanie", "plan bez implementacji", "napisz ADR", "/plan-f"
```

---

## Negative triggers (audited-feature-workflow)

`audited-feature-workflow` jest *targeted skill* — nie aktywuje się dla:

- „przeczytaj plik X"
- „wytłumacz co robi ten kod"
- „popraw literówkę"
- „rename variable"
- jednoliniowych poprawek bez impactu architektonicznego
- eksploracji repozytorium bez zamiaru implementacji

Dla tych zadań — bez skilla lub bezpośrednie wywołanie narzędzi.

---

## Koegzystencja

`replit-style-workflow`, `audited-feature-workflow` i `feature-spec-planner` koegzystują — żadnych zmian w `replit-style-workflow` podczas pracy w `audited-feature-workflow`. Wybór świadomy przez trigger lub manualnie. Brak automatycznego routera (intentional — user decyduje na podstawie kontekstu zadania).

## Anty-pattern: nie używaj `audited-feature-workflow` dla wszystkiego

`audited-feature-workflow` ma wysoki overhead (15 wpisów anti-rationalization, raw artifacts, PR sizing gate, Hyrum scan, 6 HITL gates). Dla zadań typu *„dodaj prosty getter do klasy"* to przesada — użyj `replit-style-workflow` lub bez skilla. `audited-feature-workflow` zwraca się przy zadaniach o realnym ryzyku (compliance, fragile ops, publiczne API, duże diffy).

## Źródła pryncypiów audited-feature-workflow

- [Addy Osmani — Agent Skills](https://addyosmani.com/blog/agent-skills/) (Engineering Director, Google Chrome)
- [addyosmani/agent-skills — GitHub](https://github.com/addyosmani/agent-skills) (MIT, 39K+ ⭐)
- *Software Engineering at Google* (O'Reilly, 2020) — Beyoncé Rule, DAMP over DRY, Hyrum's Law, Chesterton's Fence
- [Anthropic — The Complete Guide to Building Skills for Claude](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) — best practices dla skill creators
