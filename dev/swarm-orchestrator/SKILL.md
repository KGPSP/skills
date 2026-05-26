---
name: swarm-orchestrator
description: |
  Orkiestracja 4 agentów Claude Code w tmux -CC panes (parent / planner / generator / evaluator)
  na bazie PRD lub planu, w trzech trybach: manual / hybrid (default) / yolo.
  Łączy widzialność tmux-CC z rygorem agent-teams-builder (kontrakty, breadcrumbs, walidatory)
  i autonomią /goal z audited-feature-workflow. Single-sprint per invokacja YOLO, atomic commits per
  slice bez `git push`, auto-pivot po 3× no-progress, auto-archive po sukcesie (gate:5).
trigger:
  - "swarm orchestrator"
  - "uruchom swarm"
  - "/swarm"
  - "swarm yolo"
  - "tmux agent swarm"
  - "/YOLO"
  - "/goal"
do-not-trigger-for:
  - "przeczytaj plik"
  - "wytłumacz funkcję"
  - "popraw literówkę"
  - "1-liniowa zmiana"
  - "review jednego PR"
  - "zadanie <2h pracy jednego agenta"
  - "brak tmux LUB brak iTerm2"
  - "eksploracja repozytorium bez intencji budowania"
model: claude-opus-4-7
allowed-tools: ['Bash', 'Read', 'Edit', 'Write', 'Grep', 'Glob', 'TodoWrite', 'Task']
sources:
  - DOC/material_skill.md §2,§3,§4,§5,§8
  - DOC/since_skill.md §1,§4,§5,§7
  - DOC/agents_swarm.md §1,§3.2
  - DOC/goal_mode.md §1,§3
  - DOC/agent-teams-generator-ewaluator.md §2,§4,§7
  - dev/agent-teams-builder/SKILL.md (Anti-Rationalization, YOLO)
  - dev/audited-feature-workflow/references/goal-mode-protocol.md
version: v1.0.0
size-limit: 500-lines-hard
---

# swarm-orchestrator

Orkiestracja 4 agentów Claude Code w tmux panes (parent / planner / generator / evaluator) z trybem manual, hybrid (default) lub yolo. Uruchom **wyłącznie** dla zadań >2h pracy z PRD lub planem — single agent w długim runie cierpi na context rot, 4 osobne procesy w 4 panes dają widzialność iteracji i izolację kontekstu (DOC/agents_swarm.md §3.2).

**Nie ładuj się dla** prostych zadań: przeczytaj plik, wytłumacz funkcję, popraw literówkę, jednoliniowa zmiana, review pojedynczego PR, eksploracja repo bez intencji budowania. Te zadania wykonaj bezpośrednio bez skilla.

## Procedura (8 faz + 5 bramek)

### Faza 0 — Doctor + Mode Detection

1. Wykonaj `scripts/swarm-doctor.sh` — sprawdza tmux, claude, git, jq, awk, bash.
2. Wykryj iTerm2 (`$TERM_PROGRAM == "iTerm.app"`) — warning gdy inny terminal, nie blocker.
3. Wykryj tryb z user input:
   - `/swarm manual ...` lub fraza "manual" → manual
   - `/swarm yolo ...` lub `/YOLO /goal ...` lub fraza "yolo" → yolo
   - W przeciwnym razie → **hybrid (default)**.
4. Sprawdź czy istnieje `.agents-swarm/runs/{RUN_ID}/` w `cwd` — jeśli tak, załaduj `references/recovery-protocol.md`.

**Exit criterion:** `swarm-doctor.sh` exit 0 + tryb ustalony + brak kolizji albo recovery confirmed.

### Faza 1 — Bootstrap Run

1. Wykonaj `scripts/swarm-start.sh --workspace <repo> --prd <PRD.md>` (lub `--goal <inline>`).
2. Skrypt: waliduje git repo + clean (chyba że `--allow-dirty`), tworzy `RUN_ID`, `SESSION_NAME`, `.agents-swarm/runs/{RUN_ID}/` z poddrzewem `state/`, `prompts/`, `logs/`, zapisuje `run.env` + index w `.runs/{RUN_ID}.env`.
3. Skrypt: `ensure_git_excludes` dopisuje `.agents-swarm/` i `.claude/agents/swarm-*.md` do `.git/info/exclude`.
4. Skrypt: `install_project_agents` kopiuje 4 definicje agentów z `agents/` do `<workspace>/.claude/agents/`.
5. Init breadcrumbs.json: `printf '[]' > state/breadcrumbs.json` (jeśli skrypt nie zrobił).
6. Dopisz breadcrumb `init` z `BASE_DIR=$RUN_DIR scripts/append-breadcrumb.sh yolo init '{"mode":"<mode>"}'`.

**Exit criterion:** breadcrumb `init` w `state/breadcrumbs.json` + `run.env` + `.runs/{RUN_ID}.env` istnieją + initial `git rev-parse HEAD` zapisany w `state/initial-hash.txt`.

### Faza 2 — Tmux Spawn + Boot

1. `swarm-start.sh` wewnętrznie wywołuje `tmux_start_swarm` (4 panes, layout `tiled`, sesja `swarm-{slug}-{RUN_ID}`).
2. `render_boot_prompts` renderuje 4 boot prompty z `prompts/boot-*.md` przez awk substitution.
3. `tmux_send_boot_prompts` wysyła każdy prompt do swojej pane przez `tmux load-buffer` + `paste-buffer -d` + `send-keys Enter`.
4. Wypisz `ATTACH=tmux -CC attach -t {SESSION_NAME}` — operator otwiera w iTerm2.

**Exit criterion:** `tmux list-panes -t {SESSION_NAME} | wc -l` == 4 + 4 procesy `claude` w panes + 4 boot prompts paste-buffered (widoczne w panes).

### Faza 3 — Plan (Planner)

1. **Manual:** operator wywołuje `scripts/swarm-phase.sh --run {RUN_ID} --phase plan`.
2. **Hybrid/YOLO:** Driver dispatch'uje automatycznie via `swarm-phase.sh --phase plan`.
3. Planner pane otrzymuje `prompts/phase-plan.md` → pisze `state/plan.md` (11 sekcji zgodnie z `assets/plan-template.md`).
4. Po zapisie: dopisz breadcrumb `plan_completed`.
5. Walidator: `scripts/verify-plan-rigor.sh` — sprawdza 11 sekcji + AC table + DoD per AC.

**Exit criterion:** `state/plan.md` niepusty + `verify-plan-rigor.sh` exit 0 + breadcrumb `plan_completed`.

### Faza 3.5 — GATE #1 (plan acceptance)

- **Manual / Hybrid:** operator akceptuje plan w pane parent → dopisuje breadcrumb `gate_approved {"gate":1,"actor":"human"}`.
- **YOLO:** Driver auto-approve → breadcrumb `gate_approved {"gate":1,"actor":"yolo","auto_approved":true}`.

**Exit criterion:** breadcrumb `gate_approved` (gate:1).

### Faza 4 — Goal Derivation (tylko YOLO)

1. Wykonaj `scripts/swarm-derive-goal.sh --plan state/plan.md --output state/goal-statement.md`.
2. Skrypt: parsuje tabelę AC z `plan.md`, generuje `state/goal-statement.md` (sekcje: Stan końcowy / Weryfikacja / Ograniczenia) + `state/goal-prompt.txt`.
3. 10 reguł walidacji (z `dev/audited-feature-workflow/references/goal-mode-protocol.md §3`): kolumna `Komenda` non-interactive, AC mierzalne, frontmatter `paths-in-scope` obecny, brak `fragile-paths` chyba że `--force-fragile`.

**Exit criterion:** `swarm-derive-goal.sh` exit 0 + `goal-statement.md` ma 3 sekcje (Stan końcowy / Weryfikacja / Ograniczenia).

### Faza 4.5 — GATE #1.5 (goal acceptance, tylko YOLO)

- **YOLO:** Driver auto-approve goal-statement → breadcrumb `gate_approved {"gate":1.5,"actor":"yolo"}`.
- **Hybrid:** operator akceptuje goal-statement w pane parent.

**Exit criterion:** breadcrumb `gate_approved` (gate:1.5).

### Faza 5 — Contract Negotiation (Generator ↔ Evaluator)

1. **Manual/Hybrid/YOLO:** dispatch `scripts/swarm-phase.sh --phase contract` — wysyła do **generator** i **evaluator** panes równocześnie (`prompts/phase-contract.md`).
2. Generator proponuje kryteria; Evaluator zaostrza do obserwowalnych pass/fail; iteracja w pane'ach, oboje edytują wspólnie `state/contracts/sprint-1.json`.
3. Po `status: "accepted"` w JSON → walidator `scripts/check-contract-coverage.sh` (≥15 binarnych kryteriów, zero skal 1–10, paths_in_scope niepusty, out_of_scope niepusty).
4. Dopisz breadcrumb `contract_accepted {"sprint":1}`.

**Exit criterion:** `state/contracts/sprint-1.json:status == "accepted"` + `check-contract-coverage.sh` exit 0.

### Faza 5.5 — GATE #2 (contract acceptance)

- Akceptacja kontraktu (human / yolo auto).
- Breadcrumb `gate_approved {"gate":2}`.

### Faza 6 — Implementation Loop

#### Manual

Operator dispatch'uje `swarm-phase.sh --phase generate` → generator pisze kod → `--phase evaluate` → evaluator runuje verification cmds + zapisuje evidence + ledger. Powtórz aż `passed_criteria == total_criteria`.

#### Hybrid

`swarm-yolo.sh --run {RUN_ID} --mode hybrid --sprint 1` — auto-loop wewnątrz sprintu, STOP na GATE #3.

#### YOLO (autonomiczny)

`swarm-yolo.sh --run {RUN_ID} --mode yolo --max-iter 20 --max-time 480 --sprint 1` — pełna autonomia z 7 STOP conditions (patrz `references/stop-conditions.md`). **Twarde zakazy**: `git push`, `npm publish`, `gh pr create`, `gh release`, `DROP`, `rm` poza `paths_in_scope` egzekwowane w `swarm-yolo.sh`.

Walidator pre-commit: `scripts/check-scope-discipline.sh` + `scripts/check-pr-size.sh`.

**Exit criterion:** smoke test exit 0 + `passed_criteria == total_criteria` w `state/contracts/sprint-N.json:ledger` LUB `iter >= MAX_ITER` (→ pivot, patrz `references/pivot-protocol.md`).

### Faza 6.5 — GATE #3 (sprint review, per sprint)

- Sprint report w `state/sprint-reports/sprint-N.md`.
- Breadcrumb `gate_approved {"gate":3,"sprint":N}`.

### Faza 7 — Verify (audit całości)

1. `scripts/verify-approval-gates.sh` — wszystkie 5 bramek zaakceptowane (manual/yolo).
2. `scripts/check-evidence-completeness.sh --all-sprints` — każde `passed:true` ma plik evidence.
3. `scripts/check-scope-discipline.sh` — `git diff --name-only` ⊂ `paths_in_scope`.
4. `scripts/check-pr-size.sh` — każdy commit ≤300 lub `--justified`.

**Exit criterion:** wszystkie 4 walidatory exit 0.

### Faza 7.5 — GATE #4 (code review)

- `docs/code-reviews/CR-sprint-N-*.md` per sprint.
- Zero Critical findings.
- Breadcrumb `gate_approved {"gate":4}`.

### Faza 8 — Ship + Archive

1. `state/final-report.md` (executive summary).
2. Breadcrumb `gate_approved {"gate":5,"actor":"human|yolo"}`.
3. Git tag (opcjonalnie).
4. `scripts/archive-run.sh --run {RUN_ID} --workspace {WORKSPACE}` — tar.gz do `.agents-swarm/archives/{RUN_ID}.tar.gz` + delete `.agents-swarm/runs/{RUN_ID}/`.

**Exit criterion:** `gate_approved` (gate:5) + archiwum istnieje + manifest.txt obok.

## Tryby uruchomienia

| Tryb | Wywołanie | Driver | STOP |
|---|---|---|---|
| `manual` | `/swarm manual --workspace . --goal "..."` | operator `swarm-phase.sh --phase X` | `swarm-stop.sh` |
| **`hybrid` (default)** | `/swarm --prd PRD.md` | `swarm-yolo.sh --mode hybrid` | bramki + standardowe |
| `yolo` | `/swarm yolo --prd PRD.md` lub `/YOLO /goal` | `swarm-yolo.sh --mode yolo` | tylko mierzalne (single sprint) |

Pełen protokół: `references/modes-protocol.md`.

## Anti-Rationalization

| # | Wymówka | Riposta |
|---|---|---|
| 1 | „Wystarczy 1 agent, szybciej i mniej koordynacji" | Odrzucono. Context rot w runie >2h gwarantowany (DOC/agents_swarm.md §3.2). Spawnuj 4 panes nawet dla pozornie prostego zadania. |
| 2 | „Pomijam contract phase bo wiem co robić" | Odrzucono. Rozmyta krytyka = patologiczna pętla. **≥15 binarnych kryteriów nawet dla 5-liniowej funkcji.** |
| 3 | „Generator może sam ocenić swój kod, ma evidence z testów" | Odrzucono. Sędzia we własnej sprawie. Werdykt + screenshot generuje **inny agent niż autor** (DOC/agent-teams-generator-ewaluator.md §4). |
| 4 | „Tmux to overhead, użyję Task tool zawsze" | Odrzucono dla zadań >2h. Task tool zwraca jeden message — tracisz widzialność iteracji. Tmux pane = persistent proces. Task tool jest fallback gdy `swarm-doctor` zgłasza brak tmux. |
| 5 | „STOP po 3× ten sam error_hash to za wcześnie, jestem blisko" | Odrzucono. Powtórzony hash = pętla. „Jestem blisko" to halucynacja postępu. Eskalacja lub pivot, nie „jeszcze chwilę" (DOC/material_skill.md §3). |
| 6 | „Pomijam evidence, będzie w git history" | Odrzucono. Git diff ≠ runtime trace. **DoD wymaga artefaktu w `state/evidence/sprint-N/`** (DOC/material_skill.md §4). |
| 7 | (YOLO) „Pomijam smoke test, leci autonomicznie" | Odrzucono. YOLO znosi **bramki przeglądu**, NIE walidatory. Smoke fail = STOP + `state/blockers.md`. |
| 8 | (YOLO) „Mogę `git push` w YOLO, walidatory zielone" | Odrzucono. YOLO znosi human-in-the-loop, **nie** twarde zabezpieczenia destrukcyjne. Pełna lista zakazów: `references/anti-rationalization.md`. |

Pełna tabela 12+ wymówek z konsekwencjami: `references/anti-rationalization.md`.

## Definition of Done (binarna checklista)

- [ ] `swarm-doctor.sh` exit 0 (tmux/claude/git/jq/awk/bash present)
- [ ] `verify-role-isolation.sh` exit 0 (4 agenty `swarm-*.md`, każdy z prawidłowymi tools)
- [ ] `verify-plan-rigor.sh` exit 0 (plan ma 11 sekcji + AC table + DoD per AC)
- [ ] `check-contract-coverage.sh` exit 0 per sprint (≥15 binarnych, zero skal 1–10)
- [ ] `verify-approval-gates.sh` exit 0 (wszystkie 5 gates zaakceptowane / auto_approved)
- [ ] `check-evidence-completeness.sh --all-sprints` exit 0 (każde `passed:true` ma evidence)
- [ ] `check-scope-discipline.sh` exit 0 (`git diff --name-only` ⊂ `paths_in_scope`)
- [ ] `check-pr-size.sh` exit 0 (każdy commit ≤300 lub `--justified`)
- [ ] **Append-only audit:** `jq 'length' state/breadcrumbs.json` monotonicznie rośnie (sanity check w `append-breadcrumb.sh`)
- [ ] **Independent verification:** generator NIE pisał evidence (`actor` w breadcrumbs `iteration_verdict` == `evaluator`)
- [ ] **Archive po sukcesie:** `.agents-swarm/archives/{RUN_ID}.tar.gz` istnieje + manifest.txt obok
- [ ] **Brak zombie tmux session:** `tmux has-session -t {SESSION_NAME}` zwraca 1 (sesja zamknięta) po archive

## Reguły ładowania references/

| Warunek | Plik do załadowania |
|---|---|
| Faza 0 detekcja trybu | `references/modes-protocol.md` |
| Trigger `/YOLO` lub `swarm yolo` | `references/modes-protocol.md` (sekcja YOLO) |
| Faza 2 spawn tmux | `references/tmux-orchestration.md` |
| Wykryto istniejący `.agents-swarm/runs/` | `references/recovery-protocol.md` |
| Każda bramka (3.5 / 5.5 / 6.5 / 7.5 / 8) | `references/approval-gates-protocol.md` |
| Faza 4 (YOLO goal derivation) | `references/goal-mode-integration.md` |
| Faza 6 sprint zacina się ≥3 iteracje | `references/pivot-protocol.md` |
| Faza 6 YOLO osiąga STOP condition | `references/stop-conditions.md` |
| Agent wpada w wymówkę spoza tabeli powyżej | `references/anti-rationalization.md` |
| User pyta o hooki / `swarm-doctor` sugeruje hook | `references/hook-integration.md` |
| User wskazuje PRD/plan jako input | `references/prd-input-schema.md` |

## Quick commands

```sh
# Bootstrap (hybrid default)
scripts/swarm-doctor.sh
scripts/swarm-start.sh --workspace . --prd PRD.md --name feat-x

# Attach w iTerm2
scripts/swarm-attach.sh --run {RUN_ID}

# Manual phase advance
scripts/swarm-phase.sh --run {RUN_ID} --phase plan
scripts/swarm-phase.sh --run {RUN_ID} --phase contract
# ...

# YOLO single sprint
scripts/swarm-derive-goal.sh --plan state/plan.md
scripts/swarm-yolo.sh --run {RUN_ID} --mode yolo --max-iter 20 --max-time 480 --sprint 1

# Audit
scripts/verify-approval-gates.sh
scripts/check-evidence-completeness.sh --all-sprints

# Stop / archive
scripts/swarm-stop.sh --run {RUN_ID}      # graceful (zachowuje state)
scripts/archive-run.sh --run {RUN_ID}     # tar.gz + delete (po gate:5)
```

## Kluczowe pliki state (lokacja: `<workspace>/.agents-swarm/runs/{RUN_ID}/`)

- `goal.md` — user-provided goal
- `goal-statement.md` + `goal-prompt.txt` — derive output (YOLO)
- `state/plan.md` — Planner output
- `state/contracts/sprint-N.json` — kontrakt sprintu
- `state/breadcrumbs.json` — append-only audit (jq length monotonicznie)
- `state/evidence/sprint-N/` — screenshoty, raw logi, runtime traces
- `state/final-report.md` — executive summary (gate:5)
- `state/blockers.md` — eskalacje
- `state/yolo-status.json` — driver state (iter, start_ts, recent_hashes)
- `logs/goal-run-log.md` — append-only raw output verification cmd
