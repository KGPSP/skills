---
name: recovery-protocol
type: reference
parent: swarm-orchestrator
sources:
  - DOC/agents_swarm/scripts/lib/state.sh (write_run_index_file)
---

# Recovery protocol — wznawianie istniejącego runu

## Wykrycie

Faza 0 (Doctor) sprawdza:
```sh
[ -d "$WORKSPACE/.agents-swarm/runs" ] && ls -1 "$WORKSPACE/.agents-swarm/runs"
```

Jeśli istnieją runy bez breadcrumb `gate_approved gate:5` → potencjalny niedokończony run.

## Trzy scenariusze

### A. Tmux session żyje, state istnieje

**Diagnoza:**
```sh
RUN_ID=<found>
. "$WORKSPACE/.agents-swarm/runs/$RUN_ID/run.env"
tmux has-session -t "$SESSION_NAME" 2>/dev/null && echo "alive"
```

**Action:**
```sh
scripts/swarm-attach.sh --run "$RUN_ID"
# operator zobaczy 4 panes z ostatnim stanem (Claude procesy żyją)
```

**Następny krok:** kontynuuj w pane'ach. Jeśli ostatnia faza zakończona — `swarm-phase.sh --phase <next>`. Jeśli pętla YOLO przerwana — `swarm-yolo.sh --run $RUN_ID --mode yolo` (driver odczyta `yolo-status.json` i kontynuuje).

### B. Tmux session zmarł (reboot, kill), state istnieje

**Diagnoza:**
```sh
tmux has-session -t "$SESSION_NAME" 2>/dev/null || echo "dead"
ls "$WORKSPACE/.agents-swarm/runs/$RUN_ID/state/"
```

**Re-spawn:** v1.0.0 NIE wspiera automatic re-spawn (Claude procesy w panes się skończyły, kontekst stracony).

**Manual recovery:**
1. `tmux new-session -d -s "$SESSION_NAME" -n swarm`
2. Manualne split-window + select-layout (zobacz `lib/tmux.sh:tmux_start_swarm`).
3. Per pane: `tmux send-keys -t {pane} "cd $WORKSPACE && claude" Enter`.
4. Per pane: paste boot prompt z `$RUN_DIR/prompts/{role}.md` (loaded via `tmux load-buffer` + `paste-buffer`).
5. Generator/evaluator/planner muszą przeczytać `state/plan.md`, `state/contracts/sprint-N.json`, `state/breadcrumbs.json` żeby zsynchronizować kontekst.

**Lepsza alternatywa:** zarchiwizuj nieudany run i zacznij nowy:
```sh
scripts/archive-run.sh --run "$RUN_ID" --reason "tmux-dead recovery, starting fresh"
scripts/swarm-start.sh --workspace . --prd PRD.md --name <new-slug>
```

### C. Niedokończony run, ale chcesz zrezygnować

```sh
scripts/swarm-stop.sh --run "$RUN_ID"     # zabija tmux session (jeśli żyje)
# State zostaje w .agents-swarm/runs/$RUN_ID/ — do debugu lub manualnego archive
```

Jeśli zdecydujesz że nie potrzebny:
```sh
# Manual archive (nie auto bo nie ma gate:5)
scripts/archive-run.sh --run "$RUN_ID" --reason "abandoned"
```

## Lookup po RUN_ID

`.runs/{RUN_ID}.env` w katalogu skilla (lub `~/.claude/swarm-runs/`) zawiera mapping:
```sh
RUN_ID='20260524T184151Z-9721'
WORKSPACE='/path/to/repo'
RUN_DIR='/path/to/repo/.agents-swarm/runs/...'
SESSION_NAME='swarm-feat-x-...'
```

Dzięki temu `swarm-attach.sh --run {RUN_ID}` działa bez `--workspace`.

## SessionStart hook (opcjonalny)

`references/hook-integration.md` zawiera snippet do `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "*",
      "hooks": [{"type": "command", "command": "ls .agents-swarm/runs/ 2>/dev/null | head -3"}]
    }]
  }
}
```

Pokazuje listę niedokończonych runów przy starcie sesji Claude Code w workspace.

## Limity

- **v1.0.0 nie wspiera auto re-spawn** po crash systemu — kontekst paneli stracony.
- **Brak migracji state** między wersjami skilla — jeśli zmienisz schema `breadcrumbs.json`, stare runy mogą nie parsować się przez nowe walidatory.
- **Recovery wymaga git repo** — jeśli workspace nie jest git repo, `swarm-start.sh` odmówił bootstrapu, więc recovery jest n/a.
