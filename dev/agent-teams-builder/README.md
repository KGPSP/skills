# agent-teams-builder

> Skill orkiestrujący zespół sub-agentów (Planner + Generator + Evaluator + opcjonalni specjaliści) wg wzorca **Generator-Ewaluator** do realizacji złożonych zadań programistycznych z presją rywalizacyjną, twardymi rubrykami i mechanizmem pivota.

---

## Kiedy używać

Użyj, gdy:

- Zadanie wymaga **>2h pracy** i pojedynczy agent w pętli wpadłby w pułapkę łatania zepsutego fundamentu.
- Budujesz **aplikację od zera** lub refaktoryzujesz moduł end-to-end.
- Chcesz uruchomić tryb `/goal` z autonomiczną pracą wielogodzinną.
- Potrzebujesz **niezależnej krytyki** kodu (Evaluator) — nie samooceny Generatora.

**NIE używaj dla:**

- Jednoplikowych zmian / one-linerów (użyj `feature-planner-v3`).
- Eksploracji kodu bez intencji budowania (zwykły chat).
- Code review pojedynczego PR (użyj dedykowanego skilla).

---

## Struktura katalogu

```
agent-teams-builder/
├── SKILL.md                          ← <500 linii, frontmatter pełny
├── README.md                         ← ten plik
├── agents/                           ← gotowe sub-agenty Claude Code (kopiuj do .claude/agents/)
│   ├── planner.md
│   ├── generator.md
│   └── evaluator.md
├── references/                       ← progresywnie ładowane protokoły
│   ├── contract-negotiation.md       ← Faza 3
│   ├── evaluator-rubric.md           ← Faza 4 (4 filary, twarde progi)
│   ├── pivot-protocol.md             ← Faza 5 (Plan-Validate-Execute)
│   ├── memory-filesystem.md          ← Faza 0 + recovery
│   ├── role-mapping.md               ← Faza 2 + skalowanie do 7+ agentów
│   ├── goal-mode-protocol.md         ← Tryb /goal (respektuje bramki)
│   ├── approval-gates-protocol.md    ← 6 bramek akceptacji człowieka (human-in-the-loop)
│   ├── anti-rationalization.md       ← Pełna tabela wymówek
│   ├── non-negotiables.md            ← 5 zasad nienegocjowalnych
│   ├── dod-evidence-protocol.md      ← Faza 6 (DoD audit)
│   └── traces-reading.md             ← Kalibracja po realnych przebiegach
├── scripts/                          ← deterministyczne narzędzia bash
│   ├── init-team-state.sh
│   ├── append-breadcrumb.sh
│   ├── check-contract-coverage.sh
│   ├── verify-evaluator-rubric.sh
│   ├── pivot-trigger.sh
│   ├── smoke-test-runner.sh
│   ├── check-breadcrumbs-append-only.sh
│   ├── verify-role-isolation.sh
│   ├── check-evidence-completeness.sh
│   ├── run-goal-loop.sh
│   ├── check-scope-discipline.sh
│   ├── verify-approval-gates.sh      ← egzekwuje 6 bramek (gate_approved w breadcrumbs)
│   └── verify-non-negotiables.sh
└── assets/                           ← szablony + few-shot examples
    ├── contract-template.json
    ├── rubric-example.md             ← good design vs AI slop
    ├── feature-list-schema.json
    ├── breadcrumbs-schema.json
    ├── plan-template.md
    ├── sprint-report-template.md     ← raport wykonania sprintu (GATE #3)
    └── prompt-templates.md           ← prompty systemowe dla 3 ról
```

---

## Quick start

### 1. Skopiuj skill do repo

```bash
# Cel: /Users/sq13pl/Documents/GitHub/skills/dev/agent-teams-builder/
cp -r /Users/sq13pl/Documents/Claude/Projects/SKILLS/agent-teams-builder \
      /Users/sq13pl/Documents/GitHub/skills/dev/
```

### 2. Wpis do CHANGELOG repo

```markdown
## [v1.0.0] — 2026-05-19

### Added
- dev/agent-teams-builder/ — orkiestracja Generator-Ewaluator dla zadań programistycznych.
  - 7-fazowa procedura (bootstrap → ship) z exit criteria.
  - 10 protokołów referencyjnych z progresywnym ładowaniem.
  - 12 skryptów deterministycznych (init, smoke, pivot, walidatory).
  - Tryb /goal z auto-pivotem.
  - Source: DOC/agent-teams-generator-ewaluator.md, DOC/material_skill.md §8, DOC/since_skill.md.
```

### 3. Bootstrap pierwszej sesji

```bash
cd <your-project>
bash {skill-path}/scripts/init-team-state.sh "my-project-name"
# → tworzy state/ z plan.md, breadcrumbs.json, feature_list.json
# → git init + initial commit
```

### 4. Spawn ról (faza 2) — Claude Code Agent Teams

Skopiuj **gotowe definicje sub-agentów** do `.claude/agents/` w katalogu projektu:

```bash
mkdir -p .claude/agents
cp {skill-dir}/agents/planner.md   .claude/agents/
cp {skill-dir}/agents/generator.md .claude/agents/
cp {skill-dir}/agents/evaluator.md .claude/agents/

bash scripts/verify-role-isolation.sh   # exit 0 = OK
```

Po skopiowaniu Claude Code automatycznie wykrywa sub-agenty. Parent agent wywołuje je przez `Task` tool z `subagent_type: "planner"|"generator"|"evaluator"`.

### 5. Pętla generator-ewaluator

Procedura w `SKILL.md` (fazy 3-6). Skrypty walidują każdy etap.

---

## Wymagania uruchomieniowe

| Komponent | Zastosowanie |
|---|---|
| **Claude Code Agent Teams** | Spawn sub-agentów z osobnymi kontekstami |
| **Playwright MCP** | Evaluator — testy web apps |
| **Chrome DevTools MCP** | Evaluator — perf + network traces |
| **Computer Use** | Evaluator — natywne aplikacje desktop |
| **playwright CLI** | Reprodukowalne smoke testy |
| **Bash + jq + git** | Skrypty + state management |

---

## Kalibracja

Pierwsze 10 sesji = full audit traces (60 min każda). Patrz `references/traces-reading.md §7`.

Po każdej sesji wpisz do `state/metrics.json`:
- `sprints_completed`, `sprints_pivoted`, `total_iterations`
- `false_successes_found_in_review`
- `cost_estimate_usd`

Trend rosnący w `false_successes` → uprząż dryfuje → poprawki w `references/evaluator-rubric.md` i `references/anti-rationalization.md`.

---

## Bezpieczeństwo

Operacje destruktywne (pivot, `rm -rf`) używają **Plan-Validate-Execute**:

1. Plan napisany przez Evaluatora w `state/pivot_plan.md`.
2. Walidacja: Generator akceptuje pisemnie w breadcrumbs.
3. Execute: skrypt z archiwizacją branchu + commit.

Opcjonalny human hook: `PIVOT_REQUIRES_HUMAN=1` zatrzymuje pivot do czasu klawisza.

---

## Tipy do długich sesji (`/goal`)

- Osobny `git worktree` — czysty main rano.
- Auto mode w Claude Code — bez tego pauza co iterację.
- `caffeinate -di` (macOS) — przeciw uśpieniu.
- Power supply + stabilna sieć.
- Backup branch `git branch backup-pre-goal-$(date +%Y%m%d)`.

---

## Source

- [DOC/material_skill.md](../../DOC/material_skill.md)
- [DOC/since_skill.md](../../DOC/since_skill.md)
- [DOC/agent-teams-generator-ewaluator.md](../../DOC/agent-teams-generator-ewaluator.md)
- [DOC/goal_mode.md](../../DOC/goal_mode.md)
- Reference implementation: `dev/feature-planner-v3/`

---

## Licencja

Skill wewnętrzny KG PSP. Inspirowany frameworkiem Agent Skills (addyosmani/agent-skills, MIT) + prelekcją Anthropic o Agent Teams (cytowaną w `DOC/agent-teams-generator-ewaluator.md`).
