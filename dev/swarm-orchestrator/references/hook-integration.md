---
name: hook-integration
type: reference
parent: swarm-orchestrator
sources:
  - Claude Code hooks documentation (SessionStart, PreToolUse, UserPromptSubmit)
---

# Hook integration (opcjonalna)

**Skill działa bez hooków** — to czysto opt-in convenience. Hooki ułatwiają detekcję prerequisites i ostrzeganie operatora przed typowymi pułapkami.

## Gdzie konfigurować

**Per-project** (recommended): `<workspace>/.claude/settings.json` — widoczne tylko w tym workspace.

**Global:** `~/.claude/settings.json` — wszystkie sesje Claude Code (wpływa na każdy projekt). Używaj tylko dla globalnych ostrzeżeń.

## Snippet 1 — SessionStart: detekcja niedokończonych runów

Cel: gdy operator otwiera Claude Code w katalogu zawierającym `.agents-swarm/runs/{RUN_ID}/`, pokazuje listę i sugeruje attach/stop.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "if [ -d .agents-swarm/runs ]; then unfinished=$(ls -1 .agents-swarm/runs/ 2>/dev/null); if [ -n \"$unfinished\" ]; then echo \"⚠ swarm-orchestrator: unfinished runs detected:\"; echo \"$unfinished\" | sed 's/^/  - /'; echo \"  Resume: scripts/swarm-attach.sh --run <RUN_ID>\"; echo \"  Stop:   scripts/swarm-stop.sh --run <RUN_ID>\"; fi; fi"
          }
        ]
      }
    ]
  }
}
```

## Snippet 2 — PreToolUse Bash: doctor before swarm-start

Cel: zanim agent uruchomi `swarm-start.sh`, automatyczny `swarm-doctor.sh` — blokuje jeśli env niezdatne.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$TOOL_INPUT\" | grep -q swarm-start.sh; then dev/swarm-orchestrator/scripts/swarm-doctor.sh || exit 1; fi"
          }
        ]
      }
    ]
  }
}
```

**Uwaga:** ścieżka `dev/swarm-orchestrator/scripts/swarm-doctor.sh` zakłada że workspace = repo skilla. Dla zewnętrznych workspace'ów dostosuj (np. wskazując `$HOME/.claude/plugins/...`).

## Snippet 3 — UserPromptSubmit: warning przy git dirty

Cel: gdy prompt zawiera `/swarm` lub `/YOLO`, ostrzeż jeśli workspace ma uncommitted changes.

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$USER_PROMPT\" | grep -qE '/swarm|/YOLO'; then dirty=$(git status --short 2>/dev/null); if [ -n \"$dirty\" ]; then echo \"⚠ Workspace has uncommitted changes — swarm-start.sh will reject without --allow-dirty\"; echo \"$dirty\"; fi; fi"
          }
        ]
      }
    ]
  }
}
```

## Lokalizacja hooków w plugin manifest

**Otwarte pytanie:** czy plugin manifest (`dev/.claude-plugin/plugin.json`) może deklarować hooki przez pole `hooks:` — wymaga weryfikacji w Claude Code plugin spec. W v1.0.0 swarm-orchestrator hooki są **opt-in przez user** (kopiowane snippet do `.claude/settings.json`), nie deklarowane przez plugin.

Jeśli przyszła wersja Claude Code wesprze `hooks:` w plugin manifest, możemy podbić wersję skilla i dopisać hooks tam — bez ingerencji w user `.claude/settings.json`.

## Co hooki NIE robią

- **NIE auto-instalują** `.claude/agents/swarm-*.md` — to robi `swarm-start.sh:install_project_agents` (one-shot operacja).
- **NIE zarządzają tmux sessions** — to oddzielny mechanizm.
- **NIE zastępują walidatorów** — hooki są tylko warning/blocker dla operatora; walidatory egzekwują DoD.

## Testowanie hooków

```sh
# Symulacja SessionStart
cd <workspace_z_unfinished_runs>
claude  # zobacz output hook'a w terminalu

# Symulacja PreToolUse Bash
echo '{"tool_input":"scripts/swarm-start.sh ..."}' | bash -c "$(jq -r '.hooks.PreToolUse[0].hooks[0].command' .claude/settings.json)"

# Symulacja UserPromptSubmit
USER_PROMPT="/swarm yolo --prd PRD.md" bash -c "$(jq -r '.hooks.UserPromptSubmit[0].hooks[0].command' .claude/settings.json)"
```
