---
name: qa-architect
description: Multi-stack setup-time generator strategii QA i konfiguracji testów dla aplikacji webowych (Node/TypeScript + Next.js/React, Python, Go) z bazą PostgreSQL. Orkiestruje Managera + 5 sub-agentów (tooling-decisor, config-builder, test-author, ci-author, reviewer) wg paradygmatu QA-swarm. Produkuje audytowalny blueprint w `qa-blueprint/`: qa-strategy.md (decyzje + uzasadnienie), konfiguracje runnerów per stack (vitest/jest/pytest/go test + Playwright + Testcontainers), workflowy GitHub Actions (PR/nightly/release), kontrakt CLAUDE.md+AGENTS.md, skill pomocniczy verify-tests, docker-compose.test.yml, checklisty PR+testów oraz harmonogram pilotażu 4-tygodniowego. Aktywuj na trigger `/qa-architect`, `zaprojektuj strategię testów`, `qa blueprint`, `setup QA dla projektu`. Nie wykonuje testów (od tego jest playwright-test-suite) ani nie pisze feature'a (audited-feature-workflow).
trigger:
  - "/qa-architect"
  - "qa architect"
  - "zaprojektuj strategię testów"
  - "qa blueprint"
  - "setup qa"
  - "setup testów"
  - "dobierz narzędzia testowe"
  - "skonfiguruj zestaw testów"
  - "QA swarm setup"
do-not-trigger-for:
  - "uruchom testy"                       # → playwright-test-suite
  - "napisz test jednostkowy"             # → audited-feature-workflow Phase 6/7
  - "popraw failing test"                 # 1-liniowa zmiana
  - "wytłumacz co robi vitest"            # tylko dokumentacja
  - "review jednego PR"                   # → code-review
  - "feature implementation"              # → audited-feature-workflow / replit-style-workflow
  - "swarm orchestrator setup"            # → swarm-orchestrator
  - eksploracja repozytorium bez intencji setup QA
  - jednoliniowe zmiany w istniejącym test config
model: claude-opus-4-7
allowed-tools: ['Bash', 'Read', 'Write', 'Edit', 'Glob', 'Grep', 'TodoWrite', 'Agent']
sources:
  - DOC/material_skill.md §3 (Anti-Rationalization), §5 (Beyoncé+DAMP), §8 (5 Non-negotiables)
  - DOC/since_skill.md §1 (Token budget), §4 (Negative Triggers), §5 (Prove-It), §6 (Anti-Laziness), §7 (Plan-Validate-Execute)
  - DOC/QA-swarm.md §2 (paradygmat swarm), §3-4 (krytyczna rewizja, piramida), §6.3 (kontrakt projektowy), §7 (dobór narzędzi), §8 (wzorce), §10-11 (struktura+CI), §12.3 (pilotaż 4-tyg), §12.5 (checklisty)
  - DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §3 (pięć filarów), §9 (checklista), §10 (`source:` traceability)
  - DOC/agent-teams-generator-ewaluator.md §2 (Manager + workers), §4 (rubryka)
version: v1.0.1
size-limit: 500-lines-hard
---

# qa-architect — multi-stack QA blueprint orchestrator

> [!quote] Anti-Laziness preamble (since_skill.md §6)
> Najwyższa waga jakości. **Nie optymalizuj pod szybkość blueprintu.** Brak shortcut'u dla „aplikacja jest mała, wystarczy unit + smoke e2e". Piramida z 2 modyfikacjami (komponentowa + Postgres) jest nienegocjowalna dla każdej aplikacji webowej z bazą SQL.

> [!important] 5 Non-negotiables (pełna treść: [non-negotiables.md](references/non-negotiables.md))
> 1. **Uwidaczniaj założenia przed projektowaniem.** Każde ciche założenie o stacku (ORM, hosting, package manager) — eskaluj, nie zgaduj.
> 2. **Zatrzymaj się przy konflikcie wymagań.** Stack mówi Next.js App Router + user prosi o Cypress jako default e2e → STOP, eskaluj (paper §7.2 rekomenduje Playwright).
> 3. **Wybieraj nudne, oczywiste.** Vitest+RTL nad „własny harness", `pg` nad ekstrawagancki ORM bez powodu.
> 4. **Dostarczaj twardy dowód, nie deklarację.** Output `check-blueprint-complete.sh` wklejony do raportu, nie „blueprint jest kompletny".
> 5. **Dotykaj tylko tego, o co cię poproszono.** Skill **nie modyfikuje** kodu aplikacyjnego — tworzy wyłącznie `qa-blueprint/` + opcjonalny patch `CLAUDE.md`. Refactor istniejącego kodu = osobny task.

---

## Anti-Rationalization quick-table (pełna: [anti-rationalization.md](references/anti-rationalization.md))

Przed każdym artefaktem blueprintu i przed deklaracją „blueprint complete" — przejdź przez tę tabelę.

| # | Wymówka agenta | Riposta (blokada) |
|---|---|---|
| 1 | „Mockujemy Postgres in-memory dla szybkości testów" | Odrzucono (paper §4.2, §8.5). Transakcje + izolacja + parameterized queries `pg` ≠ mock. **Testcontainers obowiązkowy** dla warstwy SQL. |
| 2 | „Wystarczy `getByTestId`, semantyczne query to overkill" | Odrzucono (paper §10.2, Testing Library Guiding Principles). `getByRole` → `getByLabelText` → `data-testid` (escape hatch). |
| 3 | „Async Server Components testujemy w Jest, jest community plugin" | Odrzucono (paper §4.2, Next.js Testing Guide). Async RSC **nie wspierane** w Jest/Vitest — przesuń do Playwright e2e. |
| 4 | „Jeden runner dla wszystkiego — Jest dla unit i e2e" | Odrzucono. Jest/Vitest = unit/component/integration. **Playwright = e2e** (paper §7.2). |
| 5 | „GitHub Actions doda team później, na razie tylko lokalny test" | Odrzucono (paper §11). Bez CI gate = brak DoD bramki dla PR. Workflow PR obowiązkowy w blueprintzie. |
| 6 | „MSW dla wszystkiego — łatwiej utrzymać jedną warstwę mocków" | Odrzucono (paper §8.4). MSW = granice sieciowe. `vi.fn()/spyOn()` = lokalne moduły. **Testcontainers = baza SQL.** Hierarchia mockowania nienegocjowalna. |
| 7 | „Stack Python — pomijamy sekcję Server Components" | Akceptowalne (skip nie dotyczy). Każdy stack ma własny profile — załaduj `references/stack-profiles/<stack>.md`. |
| 8 | „Blueprint kompletny, sprawdziłem ręcznie pliki" | Odrzucono. `sh scripts/check-blueprint-complete.sh` musi zwrócić exit 0 + wklej raw output. Bez tego DoD #4 niespełnione. |
| 9 | „PR sizing dla blueprintu — wygenerowałem 1500 linii configów, ale to spójne" | Odrzucono (paper §6.2; material §5). Blueprint też podlega PR Sizing. >300 linii diff = uzasadnienie, >1000 = split (np. config + CI + skille — 3 PRy). |
| 10 | „Pominę reviewer agenta, ja już zweryfikowałem" | Odrzucono. Five-Axis Review obowiązkowy w Phase 7 (paper §11 — multi-model review). Manager **nie review'uje swojej pracy.** |

---

## Pozycjonowanie (czego skill NIE robi)

| Tryb | Kto | Co robi |
|---|---|---|
| **qa-architect (ten skill)** | User w głównym oknie | **Setup-time:** generuje qa-blueprint/ z configami, CI, kontraktem CLAUDE.md |
| `playwright-test-suite` | User lub Evaluator | **Runtime:** wykonuje testy E2E + axe + Chrome DevTools MCP, generuje evidence |
| `audited-feature-workflow` Phase 7 | Wewnątrz feature workflow | **Per-feature:** 7 zakresów × matryca S/M/L dla pojedynczej zmiany |
| `swarm-orchestrator` | User | **Long-running:** tmux orkiestracja 4 agentów Claude w panes (>2h zadania) |

Granica: qa-architect **kończy się** na wygenerowaniu blueprintu + opcjonalnym patchu `CLAUDE.md`. Wdrożenie konfiguracji do produkcji = osobny PR (handoff do `audited-feature-workflow`).

---

## Architektura: 8 faz + 2 bramki approval

| Faza | Cel | Bramka | Sub-agent |
|---|---|---|---|
| 0 | Detect stack + Negative Triggers + Fragile zone | — | — |
| 1 | Discovery: czytaj istniejące testy/configi/CI | — | — |
| 2 | Tooling decisions per stack | — | tooling-decisor |
| 3 | Layer strategy (piramida 80/15/5 + 2 mod.) | — | — |
| 4 | Swarm decomposition (Manager) | **APPROVAL #1** | qa-manager |
| 5 | Parallel execution (configs + CI + sample tests) | — | config-builder, test-author, ci-author |
| 6 | Consolidation: `qa-blueprint/` + CLAUDE.md patch | — | — |
| 7 | Verification: scripts + Five-Axis Review | — | reviewer |
| 8 | Handoff: pilotaż 4-tyg + raport | **APPROVAL #2** | — |

---

## Phase 0 — Detect environment

1. Sprawdź **Negative Triggers** (frontmatter `do-not-trigger-for`). Jeśli match → exit, sugeruj właściwy skill.
2. Uruchom `sh scripts/detect-stack.sh {projectDir}` — output JSON z polami: `stack` (nextjs|node-generic|python|go|unknown), `package_manager`, `db_driver`, `has_existing_tests` (bool), `has_existing_ci` (bool).
3. Wykrywaj **Fragile Zone**: jeśli skill ma patchować `CLAUDE.md` lub `.github/workflows/` w głównym repo (nie w `qa-blueprint/`) → flag `--fragile` → aktywuj Plan-Validate-Execute z [fragile-operations](references/non-negotiables.md#fragile-operations).
4. Wykrywaj **rozmiar projektu** (S/M/L): `find {projectDir} -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" \) | wc -l`. <50 = S, 50–500 = M, >500 = L.

> [!warning] Output Phase 0
> `qa-blueprint/00-environment.md` z polami: stack, size, fragile, package_manager, db_driver, existing_tests, existing_ci.

> [!danger] Hard stop
> - `stack == unknown` (exit 2) → **STOP**. Eskaluj: pokaż output `detect-stack.sh`, zapytaj który stack/profile wybrać.
> - `stack == monorepo` (exit 3) → **STOP**. Eskaluj: pokaż listę `components`, zapytaj który komponent przeprocesować (qa-architect domyślnie jeden komponent per invokacja; multi-component = osobne uruchomienia z `--projectDir <komponent>`).
> - **Nie zgaduj** (#2 non-negotiable).

---

## Phase 1 — Discovery

1. Glob: `**/{vitest,jest,playwright,cypress,pytest,jest.config,vitest.config}*` — istniejące configi.
2. Glob: `**/__tests__/**`, `**/*.{test,spec}.{ts,tsx,js,py,go}` — istniejące testy + ich liczność per warstwa.
3. Read: `.github/workflows/*.{yml,yaml}` — istniejące CI gates.
4. Read: `CLAUDE.md`, `AGENTS.md` (jeśli istnieją) — istniejący kontrakt.
5. Read: `docker-compose*.yml` — istniejące services.
6. Klasyfikuj per warstwa (unit / integration-http / integration-db / e2e / perf / security): jakie warstwy są pokryte, jakie nieobecne, jakie używają wzorców anty (np. mock dla `pg`).

> [!warning] Output Phase 1
> `qa-blueprint/01-discovery.md` z tabelą **Gap matrix**: kolumny = warstwy, wiersze = stack-required vs existing vs brakujące.

---

## Phase 2 — Tooling decisions

Wywołaj sub-agent `tooling-decisor` przez `Agent` tool z promptem `prompts/tooling-decisor.md`. Input: output Phase 0 + 1. Output: `qa-blueprint/02-tooling.md` z decyzjami:

- runner unit/component (Vitest vs Jest dla TS; pytest dla Python; standard testing dla Go)
- runner e2e (Playwright > Cypress dla greenfield)
- mockowanie HTTP (MSW dla TS; respx dla Python; httptest dla Go)
- baza SQL (Testcontainers <stack>; docker-compose fallback)
- perf (k6) i security (npm audit + ZAP baseline + dependency review)

Każda decyzja MUSI mieć: **Wybór | Uzasadnienie (cytat z paper'a §X.Y) | Alternatywa odrzucona | Powód odrzucenia**.

> [!warning] Output Phase 2
> `qa-blueprint/02-tooling.md` z tabelą `tool | profile | rationale | source-section`.

---

## Phase 3 — Layer strategy

Załaduj [layer-strategy.md](references/layer-strategy.md). Wymagane outputy:

1. **Piramida 80/15/5** dostosowana do rozmiaru (S/M/L per detect-stack).
2. **Modyfikacja 1:** komponentowa warstwa (Testing Library — semantyczne query, `getByRole` first).
3. **Modyfikacja 2:** integracyjna bazodanowa z realnym PostgreSQL (Testcontainers obowiązkowy).
4. **Macierz odpowiedzialności warstw** (paper §4.2) per stack.
5. **Per-stack exclusions** (paper §4.2): np. dla Next.js — async Server Components → e2e, nie unit.

> [!warning] Output Phase 3
> `qa-blueprint/03-layer-strategy.md` z piramidą + macierzą warstw + exclusions.

---

## Phase 4 — Swarm decomposition (Manager)

Wywołaj sub-agent `qa-manager` przez `Agent` tool z promptem `prompts/qa-manager.md`. Manager:

1. Dekomponuje pracę na **5–6 mikro-zadań** (paper §13.2 — optymalny rozmiar).
2. Przydziela własność plików per sub-agent (zapobiega konfliktom):
   - `config-builder` → `qa-blueprint/configs/`
   - `test-author` → `qa-blueprint/samples/`
   - `ci-author` → `qa-blueprint/ci/`
   - `reviewer` → `qa-blueprint/review/`
3. Wypisuje zależności (np. ci-author musi czekać na config-builder).

> [!warning] Output Phase 4
> `qa-blueprint/04-swarm-plan.md` z tabelą zadań: `agent | input | output | dependencies | exit_criterion`.

> [!important] APPROVAL #1
> Pokaż user'owi `04-swarm-plan.md` i zapytaj wprost: **„Czy ten podział pracy i własności plików jest OK? Czy mam dodać/usunąć/zmienić sub-agenta?"** Bez explicite zgody — brak Phase 5. Logika: orkiestracja 5+ sub-agentów to koszt tokenów ×5–15 (paper §2.1, §12.1), user musi zaakceptować budżet.

---

## Phase 5 — Parallel execution

Po akceptacji #1 — uruchom **w jednej wiadomości równolegle** 3 sub-agenty (config-builder, test-author, ci-author). Po ich zakończeniu — uruchom reviewer w Phase 7 (nie tutaj — najpierw consolidation).

| Sub-agent | Prompt | Templates | Output |
|---|---|---|---|
| `config-builder` | [prompts/config-builder.md](prompts/config-builder.md) | `templates/configs/<stack>/*` | `qa-blueprint/configs/{vitest,jest,playwright,pytest,go-test,docker-compose.test}.{ext}` |
| `test-author` | [prompts/test-author.md](prompts/test-author.md) | `templates/configs/<stack>/samples/*` (jeśli są) | `qa-blueprint/samples/{unit,integration-http,integration-db,e2e}.{ext}` — po **1 przykładzie per warstwa** (Beyoncé) |
| `ci-author` | [prompts/ci-author.md](prompts/ci-author.md) | `templates/ci/*` | `qa-blueprint/ci/{pr,nightly,prerelease}.yml` |

Każdy sub-agent dostaje w prompcie: output Phase 0–3 + ścieżkę do swojego template + **constraint scope discipline** (nie modyfikuje plików spoza przypisanej własności).

> [!warning] Output Phase 5
> Pliki w `qa-blueprint/configs/`, `qa-blueprint/samples/`, `qa-blueprint/ci/`. Raporty z każdego sub-agenta agregowane przez Managera w Phase 6 do `qa-strategy.md` (sekcja Execution log — nie osobny plik).

---

## Phase 6 — Consolidation

1. Wygeneruj **`qa-blueprint/qa-strategy.md`** — master document scalający 00–05 + linki do wszystkich artefaktów (template: `templates/qa-strategy.md`).
2. Wygeneruj **`qa-blueprint/CLAUDE.md.patch`** (template: `templates/claude-md-patch.md`) — fragment do dopisania do istniejącego `CLAUDE.md` projektu. Nie patchuj automatycznie — user musi review'ować i mergować ręcznie.
3. Wygeneruj **`qa-blueprint/AGENTS.md`** (template: `templates/agents-md.md`) — wersjonowane reguły dla agentów AI (importowalne przez `@AGENTS.md` w CLAUDE.md, paper §3.2).
4. Wygeneruj **`qa-blueprint/.claude/skills/verify-tests/SKILL.md`** (template: `templates/verify-tests-skill.md`) — skill pomocniczy dla agentów uruchamiających testy, paper §6.3.
5. Wygeneruj **`qa-blueprint/checklists.md`** (paper §12.5) — PR + testy.
6. Wygeneruj **`qa-blueprint/pilot-4-weeks.md`** (paper §12.3) — harmonogram pilotażu.

> [!warning] Output Phase 6
> Pełny `qa-blueprint/` w gotowości do Phase 7 verification.

---

## Phase 7 — Verification (DoD + Five-Axis Review)

1. `sh scripts/check-blueprint-complete.sh {projectDir}/qa-blueprint` — sprawdza obecność wszystkich wymaganych plików. **Exit 0 wymagany**, raw output wklejony do `qa-blueprint/07-verification.md`.
2. `sh scripts/verify-postgres-strategy.sh {projectDir}/qa-blueprint` — grep dla wzorców anty: `jest.mock\(.*pg`, `vi.mock\(.*postgres`, `mock-db`, `in-memory-pg`. **Exit 0 wymagany**.
3. Wywołaj sub-agent `reviewer` przez `Agent` tool z promptem `prompts/reviewer.md`. Input: cały `qa-blueprint/`. Output: `qa-blueprint/07-review.md` z Five-Axis Review (Correctness / Readability / Architecture / Security / Performance) — severity Critical|Optional|Nit|FYI.
4. Jeśli reviewer raportuje Critical → STOP, eskaluj do usera, **nie maskuj retry**.

> [!warning] Output Phase 7
> `qa-blueprint/07-verification.md` (raw outputs skryptów) + `qa-blueprint/07-review.md` (5-axis). Brak Critical findings = przejście do Phase 8.

---

## Phase 8 — Handoff

1. Wypełnij `qa-blueprint/pilot-4-weeks.md` konkretnymi datami (Tydzień 1–4, paper §12.3).
2. Wygeneruj `qa-blueprint/HANDOFF.md` zawierające:
   - **Co user musi zrobić ręcznie:** mergeować CLAUDE.md.patch, wybrać commit strategy (single PR vs split per paper §6.2), uruchomić `npm ci`/`pip install`/`go mod tidy` z nowymi deps.
   - **Linki do następnych skilli:** `audited-feature-workflow` (gdy będzie wdrażać pierwszą funkcjonalność z TDD), `playwright-test-suite` (gdy uruchomi e2e).
   - **Metryki sukcesu pilotażu** (paper §12.2): pokrycie / stabilność / czas — z konkretnymi progami.
3. Wklej do `HANDOFF.md` checklisty z `qa-blueprint/checklists.md` jako reference.

> [!important] APPROVAL #2
> Pokaż userowi: `qa-blueprint/qa-strategy.md` + `HANDOFF.md`. Zapytaj wprost: **„Akceptujesz blueprint i harmonogram pilotażu? Mam patchować CLAUDE.md teraz czy zostawić jako patch do ręcznego mergu?"** Bez explicite zgody — koniec sesji bez modyfikacji głównego `CLAUDE.md` (Scope Discipline #5).

---

## Definition of Done (per blueprint)

- [ ] `00-environment.md` — stack wykryty + output `detect-stack.sh` wklejony
- [ ] `01-discovery.md` — Gap matrix istniejących testów/CI
- [ ] `02-tooling.md` — decyzje narzędziowe z cytatami z paper'a
- [ ] `03-layer-strategy.md` — piramida + macierz + exclusions per stack
- [ ] `04-swarm-plan.md` — APPROVAL #1 zalogowany
- [ ] `configs/` — kompletne konfiguracje runnerów + docker-compose.test.yml
- [ ] `samples/` — po 1 przykład per wymagana warstwa (Beyoncé Rule)
- [ ] `ci/` — workflow PR + nightly + prerelease
- [ ] `qa-strategy.md` — master document
- [ ] `CLAUDE.md.patch` + `AGENTS.md` + `verify-tests/SKILL.md`
- [ ] `checklists.md` + `pilot-4-weeks.md`
- [ ] `07-verification.md` — raw output `check-blueprint-complete.sh` (exit 0) + `verify-postgres-strategy.sh` (exit 0)
- [ ] `07-review.md` — Five-Axis Review, 0 Critical findings
- [ ] `HANDOFF.md` — APPROVAL #2 zalogowany

Pełny protokół DoD: [dod-evidence-protocol.md](references/dod-evidence-protocol.md).

---

## Calibration: strefa pracy (since_skill.md §6)

| Faza | Strefa | Reżim |
|---|---|---|
| 0–3 | Wolna | Manager analizuje, sub-agenty nie uruchomione |
| 4 | Wolna | Manager dekomponuje, APPROVAL gate |
| 5 | Wolna | Sub-agenty piszą do `qa-blueprint/` (osobny katalog, brak ryzyka) |
| 6 | Wolna | Consolidation w `qa-blueprint/` |
| 7 | **Audit** | Skrypty + reviewer — read-only |
| 8 (auto-patch CLAUDE.md) | **Fragile** | Plan-Validate-Execute — APPROVAL #2 obowiązkowy, dry-run pokazany |

---

## Sources & references

- [non-negotiables.md](references/non-negotiables.md) — pełna treść 5 nienegocjowalnych + Fragile Ops
- [anti-rationalization.md](references/anti-rationalization.md) — rozszerzona tabela wymówek QA
- [stack-detection.md](references/stack-detection.md) — protokół Phase 0
- [tooling-decision-matrix.md](references/tooling-decision-matrix.md) — pełna macierz narzędzi
- [layer-strategy.md](references/layer-strategy.md) — piramida + 2 modyfikacje + per-stack mapping
- [swarm-protocol.md](references/swarm-protocol.md) — protokół Manager + workers (paper §2.2, §13.2)
- [dod-evidence-protocol.md](references/dod-evidence-protocol.md) — twarde dowody dla blueprintu
- [ci-cd-protocol.md](references/ci-cd-protocol.md) — GitHub Actions PR/nightly/release (paper §11)
- [checklists.md](references/checklists.md) — PR + testy (paper §12.5)
- [stack-profiles/nextjs-react.md](references/stack-profiles/nextjs-react.md)
- [stack-profiles/node-generic.md](references/stack-profiles/node-generic.md)
- [stack-profiles/python.md](references/stack-profiles/python.md)
- [stack-profiles/go.md](references/stack-profiles/go.md)

**Templates** w `templates/`: `qa-strategy.md`, `claude-md-patch.md`, `agents-md.md`, `verify-tests-skill.md`, `configs/<stack>/*`, `ci/*.yml`, `docker-compose.test.yml`.

**Scripts** w `scripts/`: `detect-stack.sh`, `check-blueprint-complete.sh`, `verify-postgres-strategy.sh`, `extract-raw-log.sh`.

**Prompts** sub-agentów w `prompts/`: `qa-manager.md`, `tooling-decisor.md`, `config-builder.md`, `test-author.md`, `ci-author.md`, `reviewer.md`.
