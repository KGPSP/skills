# Changelog

## [v1.0.0] — 2026-05-24

### Added
- Skill `swarm-orchestrator` (kebab-case, frontmatter zgodny z `DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §2`).
- SKILL.md — 8 faz + 5 bramek + Anti-Rat 8 wierszy + DoD 12 punktów + reguły ładowania references (268 linii, limit 500).
- 10× `references/*.md`:
  - `modes-protocol.md` — manual / hybrid / yolo
  - `tmux-orchestration.md` — layout, attach, send, recovery
  - `goal-mode-integration.md` — derive-goal-from-ac + Gate #1.5
  - `stop-conditions.md` — 7 mierzalnych STOP
  - `approval-gates-protocol.md` — 5 bramek + format breadcrumb
  - `pivot-protocol.md` — Plan-Validate-Execute reset
  - `recovery-protocol.md` — wznawianie istniejącego runu
  - `anti-rationalization.md` — pełna tabela 18 wymówek
  - `hook-integration.md` — opcjonalne hooki
  - `prd-input-schema.md` — format PRD + 10 reguł walidacji
- `scripts/lib/{paths,state,prompt,tmux}.sh` (1:1 z `DOC/agents_swarm/scripts/lib/`).
- `scripts/swarm-{start,phase,attach,send,status,stop,doctor}.sh` (1:1 z `DOC/agents_swarm/`).
- `scripts/append-breadcrumb.sh` (1:1 z `dev/agent-teams-builder/`).
- `scripts/verify-{role-isolation,plan-rigor,approval-gates}.sh` — adaptacja: prefix `swarm-*`, 5 gates zamiast 6.
- `scripts/check-{contract-coverage,evidence-completeness,scope-discipline,pr-size}.sh`.
- `scripts/{smoke-test-runner,pivot-trigger,extract-raw-log}.sh` — adaptacja `SCRIPTS_DIR` env w pivot-trigger.
- **NOWE:** `scripts/swarm-yolo.sh` — single-iteration YOLO/hybrid driver z 7 STOP conditions, atomic commit guard, auto-pivot po 3× no-progress, archive trigger po GREEN.
- **NOWE:** `scripts/error-hash.sh` — md5 sygnatury błędu (no-progress detection).
- **NOWE:** `scripts/archive-run.sh` — tar.gz + delete + manifest po gate:5.
- `agents/swarm-{parent,planner,generator,evaluator}.md` (1:1 z `DOC/agents_swarm/agents/`).
- `prompts/boot-*.md` + `prompts/phase-*.md` (1:1 z `DOC/agents_swarm/prompts/`).
- **NOWE:** `prompts/phase-yolo-iterate.md` — generator iteracja w YOLO z `{{FOCUS_AC}}`, `{{FAIL_CMD}}`, `{{FAIL_LOG}}`.
- `assets/{plan,contract,prd}-template.{md,json}`, `breadcrumbs-schema.json`.
- `tests/fixtures/{good,bad}-prd-*.md` (5 fixtures).
- `tests/test-*.sh` (8 meta-testów).

### Configured
- Wpis w `dev/.claude-plugin/plugin.json` (`skills:` array + version bump 1.0.0 → 1.1.0 + keywords +4: `tmux`, `swarm`, `yolo`, `goal-mode`).
- Wpis w `.claude-plugin/marketplace.json` (description rozszerzony o "swarm tmux orchestration").
- Wpis w root `CHANGELOG.md` (release v1.1.0 z datą 2026-05-24).

### Decyzje produktowe (potwierdzone z user)
- Backend domyślny: **tmux panes** (4 procesy `claude`); Task tool fallback gdy brak tmux.
- Tryb domyślny: **hybrid** (5 bramek HITL + auto między).
- YOLO: **single sprint** per invokacja, **atomic commits** bez `git push`, **auto-pivot** po 3× no-progress.
- State retention: **auto-archive po sukcesie** (gate:5) → `.agents-swarm/archives/{RUN_ID}.tar.gz`; failed runs zostają nietknięte do debugu.

### Twarde zakazy YOLO
- `git push`, `npm publish`, `gh pr create`, `gh release`, `DROP`, `rm` poza `paths_in_scope` — zawsze human gate.
- Fragile zones (`migrations/`, `terraform/`, `k8s/`, `auth/`, `.github/workflows/`, `Dockerfile`, `prod*`) — exit 5 chyba że `--force-fragile` (logowane w breadcrumb `fragile_override`).

### POSIX compliance
- Nowe skrypty: `#!/bin/sh + set -eu` (zgodnie z `DOC/since_skill.md §4`).
- Dziedziczone z `agent-teams-builder`: zachowany shebang `#!/usr/bin/env bash` (CLAUDE.md akceptuje wyjątek dla starszych skryptów).
- Wszystkie 23 skrypty pass'ują `sh -n` (POSIX) lub `bash -n` (bash) per shebang.
