# agent-teams-builder

> Skill orkiestrujący zespół sub-agentów (Planner + Generator + Evaluator + opcjonalni specjaliści) wg wzorca **Generator-Ewaluator** do realizacji złożonych zadań programistycznych z presją rywalizacyjną, twardymi rubrykami i mechanizmem pivota.

---

## Kiedy używać

Użyj, gdy:

- Zadanie wymaga **>2h pracy** i pojedynczy agent w pętli wpadłby w pułapkę łatania zepsutego fundamentu.
- Budujesz **aplikację od zera** lub refaktoryzujesz moduł end-to-end.
- Chcesz pracy z **bramkami akceptacji** (domyślnie) lub w pełni autonomicznej pętli (`/YOLO /goal`).
- Potrzebujesz **niezależnej krytyki** kodu (Evaluator) — nie samooceny Generatora.

**NIE używaj dla:**

- Jednoplikowych zmian / one-linerów (użyj `feature-planner-v3`).
- Eksploracji kodu bez intencji budowania (zwykły chat).
- Code review pojedynczego PR (użyj dedykowanego skilla).

---

## Tryby autonomii

Trzy poziomy nadzoru, wybierane flagą w prompcie:

| Tryb | Flaga | Bramki human-in-the-loop | Kiedy |
|---|---|---|---|
| **Domyślny** | (brak) | **6 bramek** — STOP + zgoda człowieka na plan / kontrakty / sprint / QA / review / ship | Praca dzienna pod nadzorem |
| **Goal** | `/goal <spec>` | Nadzorowana pętla — zatrzymuje się na każdej bramce, emituje `awaiting_gate_{n}` | Mierzalny cel z checkpointami |
| **YOLO** | `/YOLO /goal <spec>` | **OFF** — agent sam stawia hipotezy, wybiera najbardziej prawdopodobną, auto-zatwierdza | Praca nocna „odpal i zostaw" |

**Planowanie (Faza 1) zawsze na `effort max` (ultrathink)** — błąd planu kaskaduje przez godziny pracy N agentów.

`/YOLO` znosi bramki **przeglądu**, NIE zabezpieczenia destrukcyjne: walidatory `verify-*.sh` dalej muszą przechodzić, brak `git push`/`publish`/`DROP`/`rm` poza katalogiem feature, Plan-Validate-Execute dla pivota. Pełny protokół: `references/approval-gates-protocol.md`.

---

## Struktura katalogu

```
agent-teams-builder/
├── SKILL.md                          ← <500 linii, frontmatter pełny
├── README.md                         ← ten plik
├── CHANGELOG.md                      ← semver + historia zmian
├── agents/                           ← gotowe sub-agenty Claude Code (kopiuj do .claude/agents/)
│   ├── planner.md                    ← effort max (ultrathink); 11-sekcyjny plan + PRD
│   ├── generator.md
│   └── evaluator.md
├── references/                       ← progresywnie ładowane protokoły (14)
│   ├── approval-gates-protocol.md    ← 6 bramek human-in-the-loop + tryb /YOLO (§9)
│   ├── goal-mode-protocol.md         ← Tryb /goal (nadzorowany; /YOLO znosi bramki)
│   ├── planning-rigor.md             ← Faza 1 (3 hipotezy/sprint + Hyrum + rollback)
│   ├── documentation-protocol.md     ← 10 typów dokumentów (PRD/ADR/retro/CR/QA)
│   ├── contract-negotiation.md       ← Faza 3
│   ├── evaluator-rubric.md           ← Faza 4 (twarde progi binarne)
│   ├── pivot-protocol.md             ← Faza 5 (Plan-Validate-Execute)
│   ├── memory-filesystem.md          ← Faza 0 + recovery
│   ├── role-mapping.md               ← Faza 2 + skalowanie do 7+ agentów
│   ├── library-currency-protocol.md  ← context7 + fallback chain
│   ├── anti-rationalization.md       ← Pełna tabela wymówek
│   ├── non-negotiables.md            ← 5 zasad nienegocjowalnych
│   ├── dod-evidence-protocol.md      ← Faza 6 (DoD audit)
│   └── traces-reading.md             ← Kalibracja po realnych przebiegach
├── scripts/                          ← deterministyczne narzędzia bash (19)
│   ├── init-team-state.sh
│   ├── init-docs-structure.sh        ← tworzy state/{prd,...} + docs/{adr,...}
│   ├── append-breadcrumb.sh
│   ├── append-session-log.sh
│   ├── setup-context7.sh
│   ├── smoke-test-runner.sh
│   ├── pivot-trigger.sh
│   ├── run-goal-loop.sh
│   ├── check-contract-coverage.sh
│   ├── check-evidence-completeness.sh
│   ├── check-scope-discipline.sh
│   ├── check-breadcrumbs-append-only.sh
│   ├── verify-role-isolation.sh
│   ├── verify-evaluator-rubric.sh
│   ├── verify-plan-rigor.sh
│   ├── verify-documentation.sh
│   ├── verify-library-currency.sh
│   ├── verify-approval-gates.sh      ← egzekwuje 6 bramek (gate_approved w breadcrumbs)
│   └── verify-non-negotiables.sh
└── assets/                           ← szablony + few-shot examples (14)
    ├── plan-template.md              ← 11 sekcji planu
    ├── prd-template.md               ← PRD per sprint (8 sekcji)
    ├── sprint-report-template.md     ← raport wykonania sprintu (GATE #3)
    ├── retrospective-template.md     ← retro po sprincie
    ├── code-review-template.md       ← Five-Axis review (GATE #5)
    ├── adr-template.md               ← Architecture Decision Record
    ├── session-log-template.md
    ├── claude-md-template.md
    ├── mcp-config-template.json
    ├── contract-template.json
    ├── feature-list-schema.json
    ├── breadcrumbs-schema.json
    ├── rubric-example.md             ← good design vs AI slop
    └── prompt-templates.md           ← prompty systemowe dla 3 ról
```

---

## Quick start

### 1. Lokalizacja skilla

Skill mieszka w repo: `dev/agent-teams-builder/`. W sesji Claude Code wywołasz go triggerem (`/team`, `/goal`, `/YOLO`, „zbuduj zespół agentów do…") — `SKILL.md` ładuje się automatycznie.

### 2. Aktualny zakres (v1.8.0)

- 7-fazowa procedura (bootstrap → ship) z exit criteria + **6 bramek akceptacji**.
- **14 protokołów** referencyjnych z progresywnym ładowaniem.
- **19 skryptów** deterministycznych (init, smoke, pivot, 7 walidatorów `verify-*` + 4 `check-*`).
- Tryby autonomii: domyślny (bramki) / `/goal` (nadzorowany) / `/YOLO /goal` (pełna autonomia).
- Pełny audit trail dokumentów (PRD/ADR/retro/code-review/QA/sprint-report).

Pełna historia zmian: [CHANGELOG.md](CHANGELOG.md). Źródła: `DOC/agent-teams-generator-ewaluator.md`, `DOC/material_skill.md §8`, `DOC/since_skill.md`, `DOC/goal_mode.md`.

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

Dwie warstwy ochrony, niezależne od trybu autonomii:

**1. Bramki przeglądu (6, human-in-the-loop)** — domyślnie STOP na plan/kontrakty/sprint/QA/review/ship. `/YOLO` je auto-zatwierdza (audit: `actor: yolo` w breadcrumbs). Walidator: `verify-approval-gates.sh`.

**2. Zabezpieczenia destrukcyjne (zawsze aktywne, także w `/YOLO`):**
- Operacje destruktywne (pivot, `rm -rf`) używają **Plan-Validate-Execute**: plan Evaluatora → pisemna walidacja Generatora w breadcrumbs → execute z archiwizacją branchu. Opcjonalny human hook `PIVOT_REQUIRES_HUMAN=1`.
- **Nigdy** automatycznie: `git push`, `npm publish`, `DROP TABLE`/`DELETE` bez WHERE, `rm` poza katalogiem feature, dotykanie `.env`/`secrets/`/`~/.ssh/`.
- Walidatory `verify-*.sh` muszą przechodzić nawet w `/YOLO` — fail = STOP + `state/blockers.md`.

---

## Tipy do długich sesji (`/YOLO /goal`)

> Bez `/YOLO` proces zatrzyma się na **pierwszej bramce** i będzie czekał na zgodę — praca nocna „odpal i zostaw" wymaga `/YOLO`.

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
