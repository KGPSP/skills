---
name: swarm-protocol
type: reference
parent: qa-architect
sources:
  - DOC/QA-swarm.md §2.2 (architektura roju, podział ról), §13.2 (pozycjonowanie Claude Code)
  - DOC/agent-teams-generator-ewaluator.md §2 (Manager + workers), §4 (rubryka), §7 (anty-pivot)
  - DOC/material_skill.md §3 (anti-rationalization S-series)
description: Protokół orkiestracji Manager + 5 sub-agentów dla Phase 4-5. Definiuje role, dekompozycję 5-6 mikro-zadań, przypisanie własności plików, kontrakty input/output per agent, anti-rationalization specyficzne dla swarm.
---

# Swarm protocol — Manager + 5 workers

> [!quote] QA-swarm.md §13.2
> Optymalny podział zakłada przypisanie od pięciu do sześciu odizolowanych mikro-zadań na jednego agenta QA. Manager przypisuje **własność plików** do konkretnych agentów (np. `config-builder` → `qa-blueprint/configs/`), co zapobiega powstawaniu konfliktów.

## 1. Role agentów

| Agent | Pozycja | Modyfikuje pliki | Czyta pliki | Zakaz |
|---|---|---|---|---|
| **qa-manager** | Phase 4 (jedyne wywołanie) | `qa-blueprint/04-swarm-plan.md` | wszystko z Phase 0–3 | nie pisze configów, nie review'uje |
| **tooling-decisor** | Phase 2 | `qa-blueprint/02-tooling.md` | `00-environment.md`, `01-discovery.md`, `references/tooling-decision-matrix.md` | nie generuje configów (tylko decyzje) |
| **config-builder** | Phase 5 (parallel) | `qa-blueprint/configs/**` | `02-tooling.md`, `03-layer-strategy.md`, `templates/configs/<stack>/**` | nie modyfikuje `samples/`, `ci/`, `04-swarm-plan.md` |
| **test-author** | Phase 5 (parallel) | `qa-blueprint/samples/**` | `02-tooling.md`, `03-layer-strategy.md`, `templates/configs/<stack>/samples/**` (jeśli są) | nie modyfikuje `configs/`, nie pisze do prod-code |
| **ci-author** | Phase 5 (parallel) | `qa-blueprint/ci/**` | `02-tooling.md`, `03-layer-strategy.md`, `templates/ci/**` | nie modyfikuje `configs/`, `samples/` |
| **reviewer** | Phase 7 (po consolidation) | `qa-blueprint/07-review.md` | cały `qa-blueprint/**` | nie modyfikuje żadnego innego pliku, nie poprawia znalezisk |

## 2. Dekompozycja 5–6 mikro-zadań (Manager Phase 4)

Manager produkuje `04-swarm-plan.md` z **listą zadań** w tym formacie:

| # | Sub-agent | Input (pliki) | Output (pliki) | Depends-on | Exit criterion | Estimated tokens |
|---|---|---|---|---|---|---|
| 1 | config-builder | 02, 03, templates/configs/nextjs/* | configs/vitest.config.ts, configs/playwright.config.ts, configs/docker-compose.test.yml | — | wszystkie pliki istnieją + składnia OK | ~3-5k |
| 2 | test-author | 02, 03, templates/configs/nextjs/samples/* (opt) | samples/unit.test.tsx, samples/integration-http.test.ts, samples/integration-db.int.test.ts, samples/e2e.spec.ts | — | po 1 sample per wymagana warstwa | ~5-8k |
| 3 | ci-author | 02, 03, templates/ci/* | ci/pr.yml, ci/nightly.yml, ci/prerelease.yml | — | YAML poprawny + matrix node version + steps zgodne z layer strategy | ~3-5k |
| 4 | (consolidation, Phase 6) | wszystko z Phase 5 | qa-strategy.md, CLAUDE.md.patch, AGENTS.md, verify-tests/SKILL.md, checklists.md, pilot-4-weeks.md | 1, 2, 3 | wszystkie linki działają, qa-strategy.md scala 00-05 | — |
| 5 | reviewer | qa-blueprint/** | 07-review.md | 4 | Five-Axis Review wykonany, severity per finding, 0 Critical | ~5-10k |

Reguły dekompozycji:
- Zadania 1, 2, 3 są **niezależne** → uruchom Phase 5 równolegle (jedna wiadomość, 3 wywołania Agent tool).
- Zadanie 4 (consolidation) **nie jest sub-agentem** — wykonuje go Manager (sam skill) w Phase 6 po zebraniu outputów.
- Zadanie 5 (reviewer) **nie może być equal Managera ani któregokolwiek workera** — to inny agent (paper §11 multi-model review).

## 3. Kontrakt promptu sub-agenta

Każdy prompt w `prompts/<agent>.md` MUSI mieć tę strukturę:

```markdown
# Role: <agent name>

## Mission
<1-2 zdania co robi>

## Scope (file ownership)
- Modyfikujesz wyłącznie: <konkretne globs>
- Czytasz: <konkretne ścieżki>
- ZAKAZ: <co nie wolno>

## Inputs
- `<path>`: <opis co tam jest>
- `<path>`: <opis>

## Procedure
1. <krok>
2. <krok>

## Exit criterion
- <mierzalny output>

## Anti-rationalization
| Wymówka | Riposta |
|---|---|
| <typowa wymówka tego agenta> | <riposta blokująca> |
```

## 4. Wywołanie sub-agenta przez Agent tool

Manager / skill wywołuje sub-agent'a tak:

```
Agent(
  description: "<3-5 word task>",
  subagent_type: "general-purpose",
  prompt: <pełen prompt z `prompts/<agent>.md` + dodatkowe inputy (ścieżki + wartości z poprzednich faz)>
)
```

**Reguły:**

- `subagent_type: general-purpose` — używamy domyślnego agenta z dostępem do tools. Custom subagent_type wymagałby rejestracji w `~/.claude/agents/` — overhead bez korzyści dla single-skill setupu.
- Każdy prompt zawiera **cały kontekst sub-agenta** — agent NIE widzi konwersacji rodzica.
- Manager NIE czeka aktywnie — Agent tool zwraca tool result po zakończeniu.
- Manager **agreguje** outputy, nie przekazuje je dalej między sub-agentami (no peer-to-peer w tej architekturze — to celowe uproszczenie vs paper §2.2).

## 5. Parallel execution Phase 5

Po APPROVAL #1 — wywołaj **w jednej wiadomości** trzy Agent tool calls (config-builder, test-author, ci-author). Anti-pattern S5: sekwencyjne wywoływanie zwiększa czas ×3 i traci atomowość Phase 5.

Jeśli zadanie 2 (test-author) faktycznie zależy od zadania 1 (np. config-builder definiuje `setupFiles` które test-author musi referencować) — Manager w Phase 4 oznacza zależność i robi 2 batches:
- Batch 1: config-builder (sam).
- Batch 2: test-author + ci-author (równolegle, po zakończeniu config-builder).

To wyjątek — domyślnie wszystkie 3 są niezależne (każdy używa templates per stack).

## 6. Anti-rationalization sub-agent specific (S-series)

| # | Wymówka swarm | Riposta |
|---|---|---|
| S1 | „Sub-agent nie ma dostępu do Phase X, podsumuję mu" | Sub-agent dostaje **pełen output Phase X** w prompcie. Podsumowanie = halucynacja źródła. |
| S2 | „Sub-agent zwrócił coś dziwnego, spróbuję jeszcze raz z innym promptem" | Stop. Popraw `prompts/<agent>.md`, nie iteruj losowo. |
| S3 | „Reviewer FYI severity, mogę zignorować" | FYI nie blokuje merge, ale loguj w `07-review.md`. Ignorowanie = traci audit trail. |
| S4 | „Pomijam ci-author, user ma już swój GH Actions" | Discovery Phase 1 zweryfikowało gap. ci-author **uzupełnia brakujące jobs**, nie nadpisuje. |
| S5 | „config-builder i ci-author zależne — wywołam sekwencyjnie" | Phase 5 explicite: **równolegle w jednej wiadomości** (chyba że Phase 4 oznaczyło zależność). |
| S6 | „Wywołam reviewer równolegle z config-builder — szybciej" | Reviewer Phase 7, **po consolidation**. Review niekompletnego blueprintu = bezwartościowe finding. |

## 7. Cost-effectiveness check

Paper §12.1 — wskaźnik E:

```
E = (T_single · C_token) / (T_swarm · C_token · α_swarm)
```

gdzie `α_swarm ∈ [4, 15]`. Dla qa-architect typowo `α_swarm ≈ 4–6` (mała liczba workers, prosty kontrakt).

**Heurystyka:** jeśli detect-stack wskazuje **S** (mała aplikacja, <50 plików) i `db_driver == none` — Manager Phase 4 MOŻE zaproponować skipping `test-author` (templates wystarczają, brak testowania SQL). Decyzja **w APPROVAL #1**, nie automatyczna.

## 8. Hard rules

1. **Nigdy nie spawn'uj sub-agenta przed APPROVAL #1** — koszt tokenów × wymówek.
2. **Manager nie modyfikuje plików workers** — narusza file ownership.
3. **Reviewer nie modyfikuje znalezisk** — tylko raportuje. Naprawy = osobna iteracja (po APPROVAL #2).
4. **Brak peer-to-peer** — sub-agenty nie komunikują się ze sobą, tylko via Manager (uproszczenie vs paper §2.2 — mniej ruchomych części).
