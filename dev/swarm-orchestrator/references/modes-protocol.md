---
name: modes-protocol
type: reference
parent: swarm-orchestrator
sources:
  - DOC/goal_mode.md §1,§3 (YOLO autonomy)
  - DOC/agent-teams-generator-ewaluator.md §7 (pivot mechanism)
  - dev/agent-teams-builder/SKILL.md (5 approval gates)
---

# Tryby uruchomienia swarm-orchestrator

3 tryby z różnym poziomem autonomii i widzialności bramek.

## Manual

**Kiedy:** operator chce pełną kontrolę; każda faza wymaga ręcznej decyzji.

**Wywołanie:** `/swarm manual --workspace . --goal "..."` lub explicite `scripts/swarm-start.sh --workspace . --goal "..." --name <slug>`.

**Flow:**
1. `swarm-start.sh` → bootstrap + tmux spawn + boot prompts.
2. Operator wywołuje `swarm-phase.sh --run {RUN_ID} --phase plan`.
3. Czeka na pane planner, czyta `state/plan.md`.
4. Operator akceptuje plan, wywołuje `--phase contract`.
5. Czeka na pane generator + evaluator, czyta `state/contracts/sprint-1.json`.
6. `--phase generate` → `--phase evaluate` → powtórz aż passed_criteria == total_criteria.
7. `--phase report` → operator akceptuje `state/final-report.md`.
8. Opcjonalnie: `archive-run.sh` (manual archive, nie auto).

**STOP:** wyłącznie ręczny przez `swarm-stop.sh --run {RUN_ID}`. Brak iter-cap, time-cap.

**Bramki:** wszystkie ręczne — operator dopisuje `gate_approved {"actor":"human"}` w breadcrumbs.

## Hybrid (default)

**Kiedy:** operator chce auto-progress wewnątrz sprintu, ale STOP na każdej z 5 bramek (plan, contract, sprint, code-review, ship).

**Wywołanie:** `/swarm --prd PRD.md` lub `/swarm hybrid --prd PRD.md --name <slug>`.

**Flow:**
1. `swarm-start.sh --mode hybrid --prd PRD.md` — bootstrap.
2. Driver `swarm-yolo.sh --mode hybrid --run {RUN_ID} --sprint 1`:
   - Auto-dispatch `phase-plan` do planner pane.
   - **STOP na GATE #1** — czeka aż operator zaakceptuje (breadcrumb `gate_approved` gate:1, actor:human).
   - Auto-dispatch `phase-contract`.
   - **STOP na GATE #2** — operator akceptuje kontrakt.
   - Auto-loop generate↔evaluate wewnątrz sprintu (re-invoke per iter).
   - **STOP na GATE #3** — operator akceptuje sprint-report.
   - Auto-verify (Faza 7).
   - **STOP na GATE #4** — code-review zaakceptowane.
   - **STOP na GATE #5** — ship + archive.

**STOP conditions:** 5 bramek + standardowe (iter-cap=20, time-cap=480 min, no-progress, scope-violation, pr-too-big, human-abort).

**Default Bo:** bezpieczny kompromis — operator widzi i akceptuje każdą fazę, ale nie musi ręcznie odpalać phase script'ów.

## YOLO (autonomiczny)

**Kiedy:** krótki, dobrze zdefiniowany sprint z wymiernymi AC + komendą weryfikacyjną; chcesz overnight run lub szybką iterację.

**Wywołanie:** `/swarm yolo --prd PRD.md --max-iter 20 --max-time 480` lub `/YOLO /goal <inline goal>`.

**Pre-flight wymóg (twardy):**
- PRD ma frontmatter `paths-in-scope:` (lista YAML, niepusta)
- PRD ma sekcję `# Acceptance Criteria` z tabelą 6 kolumn (AC-ID/Typ/Opis/Test ID/Plik testu/Komenda)
- Kolumna `Komenda` zawiera single command (bez `&&`, `||`, `;`, `$()`, backticks, `|`)
- Sekcja `# Out of scope` ma ≥1 bullet
- `paths-in-scope` nie zawiera Fragile zone (chyba że `--force-fragile`)

Brak któregokolwiek → `swarm-derive-goal.sh` exit 1 + lista braków.

**Flow:**
1. `swarm-start.sh --mode yolo --prd PRD.md` — bootstrap z auto-approve gate:1.
2. `swarm-derive-goal.sh --plan state/plan.md` — produkuje `goal-statement.md` + `goal-prompt.txt`.
3. Auto-approve gate:1.5 (yolo, auto_approved:true).
4. Driver `swarm-yolo.sh --mode yolo --run {RUN_ID} --sprint 1 --max-iter 20 --max-time 480`:
   - Per call: run verification cmds, write `state/goal-run-log.md`.
   - Jeśli ALL GREEN → auto-approve gate:5 → `archive-run.sh` → exit 0.
   - Jeśli fail → wysyła `phase-yolo-iterate.md` do generator pane → exit 1 (re-invoke required).
   - Po każdej iter: dopisuje `error-hash`. 3× ten sam = `pivot-trigger.sh` z `PIVOT_REQUIRES_HUMAN=0`.

**STOP conditions (tylko mierzalne):**
- iter-cap (>20 default)
- time-cap (>480 min)
- no-progress (3× ten sam error_hash)
- scope-violation (modyfikacja poza paths_in_scope lub w Fragile zone)
- pr-too-big (>1000 linii bez --justified)
- human-abort (`swarm-stop.sh`)
- GREEN (all passed → archive)

**Twarde zakazy (egzekwowane w `swarm-yolo.sh`):**
- `git push` — zawsze human gate
- `npm publish`, `gh release`, `pip publish`, `cargo publish` — zawsze human gate
- `gh pr create`, `gh pr merge` — zawsze human gate
- `DROP TABLE`, `DROP DATABASE` — zawsze human gate
- `rm` poza paths_in_scope — scope violation
- Edycja Fragile zones (`migrations/`, `terraform/`, `k8s/`, `auth/`, `.github/workflows/`, `Dockerfile`, `prod*`) — exit 5 chyba że `--force-fragile`

**Single sprint per invokacja:** YOLO przerabia **jeden** sprint z `contracts/sprint-N.json`. Po success → archive + exit. Następny sprint = nowa invokacja `--sprint 2`.

## Decision tree

```
Wybór trybu:
├── Operator chce klikać każdą fazę?            → manual
├── PRD ma AC table z Komenda + paths_in_scope? → yolo (jeśli zadanie short)
│                                                  hybrid (jeśli zadanie wymaga review per gate)
└── Inaczej (brak AC, eksperymentalne)          → manual
```
