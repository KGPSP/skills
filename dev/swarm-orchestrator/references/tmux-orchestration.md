---
name: tmux-orchestration
type: reference
parent: swarm-orchestrator
sources:
  - DOC/agents_swarm/scripts/lib/tmux.sh (1:1 reuse)
  - DOC/agents_swarm.md §3.1 (visibility argument)
---

# Tmux orchestration layer

## Topologia panes

Sesja `swarm-{slug}-{RUN_ID}` zawiera **4 panes** w layoucie `tiled`:

```
┌────────────────────┬────────────────────┐
│   parent (%0)      │   planner (%1)     │
│   koordynator      │   pisze plan.md    │
├────────────────────┼────────────────────┤
│   generator (%2)   │   evaluator (%3)   │
│   pisze kod        │   ocenia + evidence│
└────────────────────┴────────────────────┘
```

Każda pane uruchamia **osobny proces `claude`** — niezależne okno kontekstowe, izolacja od pozostałych ról.

## Spawn (lib/tmux.sh)

`tmux_start_swarm()` wywoływane przez `swarm-start.sh`:

```
1. tmux new-session -d -s swarm-{slug}-{RUN_ID} -n swarm
2. tmux split-window -h -t {SESSION}:0
3. tmux split-window -v -t {SESSION}:0.0
4. tmux split-window -v -t {SESSION}:0.1
5. tmux select-layout -t {SESSION}:0 tiled
6. tmux select-pane -t {SESSION}:0.0 -T parent
7. tmux select-pane -t {SESSION}:0.1 -T planner
8. tmux select-pane -t {SESSION}:0.2 -T generator
9. tmux select-pane -t {SESSION}:0.3 -T evaluator
10. Per pane: tmux send-keys -t {pane} "cd {WORKSPACE} && claude" Enter
```

Pane IDs (`%0`-`%3` lub podobne) zapisywane do `run.env` jako `PARENT_PANE`, `PLANNER_PANE`, `GENERATOR_PANE`, `EVALUATOR_PANE`.

## Attach z iTerm2 (control mode)

```sh
scripts/swarm-attach.sh --run {RUN_ID}
# → tmux -CC attach -t swarm-{slug}-{RUN_ID}
```

iTerm2 wykrywa `-CC` flag i otwiera **4 natywne okna iTerm2** (jedno per pane). Operator widzi 4 niezależne sesje Claude równolegle. Detach: Cmd+D w iTerm2 lub `tmux detach` w pane.

W innym terminalu (Alacritty, kitty, WezTerm) `-CC` daje fallback do standardowego tmux UI w jednym oknie.

## Routing promptów (lib/tmux.sh:tmux_send_file)

```
tmux_send_file <pane_id> <prompt_file>
  1. BUFFER=$(date +%s)-$$
  2. tmux load-buffer -b "$BUFFER" "$prompt_file"
  3. tmux paste-buffer -d -b "$BUFFER" -t "$pane_id"
  4. tmux send-keys -t "$pane_id" Enter
```

`load-buffer` + `paste-buffer -d` (delete after) jest bezpieczne dla wielolinijkowych promptów z cudzysłowami, backslashami, znakami specjalnymi. Nigdy nie używaj `send-keys "text"` bezpośrednio — powłoka interpretuje znaki.

## Recovery sesji

Tmux session **żyje aż**:
- `swarm-stop.sh` (graceful kill)
- crash systemu (po reboot — session zniknie)
- `archive-run.sh` (kill + tar.gz + delete state)

Sprawdzenie czy żyje:
```sh
tmux has-session -t swarm-{slug}-{RUN_ID} 2>/dev/null && echo "alive" || echo "dead"
```

Recovery niedokończonego runu:
1. `swarm-status.sh --run {RUN_ID}` — pokazuje tmux session + breadcrumbs length + last phase.
2. Jeśli sesja żyje: `swarm-attach.sh --run {RUN_ID}` → kontynuuj w pane'ach.
3. Jeśli sesja zniknęła ale state istnieje: re-spawn nie jest wspierany w MVP. Manualny restart z nowym RUN_ID albo `tmux new-session` + ręczne paste-buffer z `prompts/`.

## Doctor (swarm-doctor.sh)

Sprawdza:
- `command -v tmux` — exit 2 jeśli brak
- `command -v claude` — exit 2 jeśli brak  
- `command -v git`, `command -v jq`, `command -v awk` — exit 2 jeśli brak
- `$TERM_PROGRAM == "iTerm.app"` — warning jeśli inny terminal
- `tmux -V | awk '{print $2}'` — warning jeśli wersja <3.0

Wywołanie automatyczne w `swarm-start.sh` (gdy hook `PreToolUse` skonfigurowany) lub ręczne.
