# swarm-orchestrator

Orkiestracja 4 agentów Claude Code w tmux -CC panes (parent / planner / generator / evaluator) z trzema trybami: **manual**, **hybrid** (default), **yolo**. Komponuje:
- widzialność tmux z [`DOC/agents_swarm/`](../../DOC/agents_swarm/) (prototyp local-only),
- rygor 5 bramek + kontrakty + breadcrumbs z [`dev/agent-teams-builder/`](../agent-teams-builder/),
- autonomię `/goal` z [`dev/audited-feature-workflow/`](../audited-feature-workflow/) (Phase 6-Goal route).

## Quickstart

```sh
# 1. Pre-flight: czy env zdatne (tmux, claude, git, jq, awk, bash)
scripts/swarm-doctor.sh

# 2. Bootstrap (hybrid mode — default)
scripts/swarm-start.sh --workspace . --prd PRD.md --name feat-x

# Output:
#   RUN_ID=20260524T184151Z-9721
#   SESSION_NAME=swarm-feat-x-20260524T184151Z-9721
#   RUN_DIR=/workspace/.agents-swarm/runs/...
#   ATTACH=tmux -CC attach -t swarm-feat-x-...

# 3. Attach w iTerm2 (4 natywne okna)
scripts/swarm-attach.sh --run "$RUN_ID"

# 4a. Manual: ręcznie odpalaj fazy
scripts/swarm-phase.sh --run "$RUN_ID" --phase plan
scripts/swarm-phase.sh --run "$RUN_ID" --phase contract
# ...

# 4b. YOLO: autonomiczna pętla
scripts/swarm-derive-goal.sh --plan state/plan.md
scripts/swarm-yolo.sh --run "$RUN_ID" --mode yolo \
  --max-iter 20 --max-time 480 --sprint 1
# Re-invoke po każdym commit aż GREEN lub STOP.

# 5. Audit
scripts/verify-approval-gates.sh
scripts/check-evidence-completeness.sh --all-sprints

# 6. Stop / archive
scripts/swarm-stop.sh --run "$RUN_ID"   # graceful
scripts/archive-run.sh --run "$RUN_ID"  # tar.gz + delete
```

## Tryby — quick decision

| Tryb | Kiedy | Bramki | STOP |
|---|---|---|---|
| **manual** | maksimum kontroli, każda faza ręcznie | wszystkie human | `swarm-stop.sh` |
| **hybrid** (default) | auto wewnątrz sprintu, STOP per gate | 5× human | bramki + standardowe |
| **yolo** | overnight run z PRD; single-sprint autonomy | auto (yolo) | iter-cap/time-cap/no-progress/scope/pr-size/abort |

Pełen protokół: [`references/modes-protocol.md`](references/modes-protocol.md).

## Co reużywa

| Komponent | Źródło |
|---|---|
| `scripts/lib/{paths,state,prompt,tmux}.sh` | `DOC/agents_swarm/scripts/lib/` (1:1) |
| `scripts/swarm-{start,phase,attach,send,status,stop,doctor}.sh` | `DOC/agents_swarm/scripts/` (1:1) |
| `scripts/append-breadcrumb.sh` | `dev/agent-teams-builder/scripts/` (1:1) |
| `scripts/verify-*.sh`, `check-*.sh`, `smoke-test-runner.sh`, `pivot-trigger.sh` | `dev/agent-teams-builder/scripts/` (adaptacja: prefix swarm-* w role files, SCRIPTS_DIR env) |
| `scripts/extract-raw-log.sh`, `check-pr-size.sh` | `dev/audited-feature-workflow/scripts/` (1:1) |
| `scripts/swarm-derive-goal.sh` | `dev/audited-feature-workflow/scripts/derive-goal-from-ac.sh` (inline copy) |

## Co dodaje nowego

- `scripts/swarm-yolo.sh` — driver YOLO/hybrid (single-iteration, jak v3 run-goal-loop), z 7 STOP conditions + atomic commit guard + auto-pivot.
- `scripts/error-hash.sh` — md5 sygnatury błędu (no-progress detection).
- `scripts/archive-run.sh` — tar.gz + delete po gate:5 (auto-cleanup po sukcesie).
- `prompts/phase-yolo-iterate.md` — generator iteracja w YOLO (focus pierwszej fail AC).
- `SKILL.md` + 10× `references/` zgodne z DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md.

## Instalacja jako plugin

Dodane do `dev/.claude-plugin/plugin.json` w wersji 1.1.0:
```sh
/plugin marketplace add KGPSP/skills
/plugin install dev-tools@kgpsp-skills
```

Po instalacji skill jest dostępny przez triggery: `/swarm`, `/YOLO`, `swarm orchestrator`, `uruchom swarm`, `tmux agent swarm`.

## Hooki (opcjonalne)

`references/hook-integration.md` — snippety do `.claude/settings.json` per-project:
- SessionStart: detekcja niedokończonych runów
- PreToolUse Bash: pre-flight doctor przed swarm-start.sh
- UserPromptSubmit: warning gdy git dirty

Skill działa **bez** hooków.

## Definition of Done

12 binarnych checków — patrz [`SKILL.md` § DoD](SKILL.md#definition-of-done-binarna-checklista). Każdy zwraca exit 0 z raw outputem (DoD = dowód, nie deklaracja — `DOC/material_skill.md §4`).

## FAQ

**Q: Czy działa bez tmux?**  
A: Nie domyślnie. `swarm-doctor.sh` zgłosi brak tmux → użyj `dev/agent-teams-builder` (Task tool fallback) lub `dev/audited-feature-workflow` (single-agent).

**Q: Czy YOLO może `git push`?**  
A: Nie. Twarde zakazy egzekwowane w `swarm-yolo.sh`. YOLO commituje atomic per slice, push zawsze wymaga human gate.

**Q: Co się dzieje gdy tmux session umrze (reboot)?**  
A: State w `.agents-swarm/runs/{RUN_ID}/` zostaje. Re-spawn nie jest wspierany w v1.0.0 — zarchiwizuj i zacznij nowy run, albo manualny tmux setup ([`references/recovery-protocol.md`](references/recovery-protocol.md)).

**Q: Multi-sprint w YOLO?**  
A: V1.0.0: single sprint per invokacja. Następny sprint = nowa invokacja `--sprint N`. To celowe — błąd we wczesnym sprincie nie kaskaduje.

**Q: Czemu kopia skryptów z innych skilli, nie symlink?**  
A: Po `/plugin install` ścieżki `../` poza katalog skilla nie działają. Każdy skill musi być samowystarczalny.
