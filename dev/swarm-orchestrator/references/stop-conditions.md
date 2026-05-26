---
name: stop-conditions
type: reference
parent: swarm-orchestrator
sources:
  - dev/audited-feature-workflow/references/goal-mode-protocol.md §10 (7 STOP types)
  - DOC/material_skill.md §3 (Anti-Rationalization)
---

# STOP conditions — twarde i mierzalne

Wszystkie STOP są **mierzalne** (binarny pass/fail, nie skala 1–10). YOLO honoruje wszystkie 7; hybrid honoruje 5 bramek + standardowe.

## 1. iter-cap

**Detekcja:** `swarm-yolo.sh` zwiększa `ITER` per call; gdy `ITER > MAX_ITER` (default 20) → STOP.

**Output:**
```json
{"status":"iter-cap-hit","iter":21,"max_iter":20,"elapsed_sec":1247}
```
+ breadcrumb `yolo_stopped {"reason":"iter-cap-hit",...}` + exit 3.

**Co robić:** czytaj `state/yolo-status.json` + ostatnie 3 iteracje w `logs/yolo-iter-*.log`. Albo zwiększ `--max-iter` (jeśli zadanie naprawdę szersze) albo zwężaj scope (split sprint).

## 2. time-cap

**Detekcja:** `swarm-yolo.sh` zapisuje `START_TS` w `yolo-status.json` per pierwszy call; gdy `(NOW - START_TS) > MAX_TIME * 60` → STOP.

**Output:** `{"status":"time-cap-hit","elapsed_sec":N,"max_time_sec":M}` + exit 3.

**Co robić:** sprint za duży lub agent zacięty. Sprawdź ostatnie iteracje — czy progress jest. Jeśli tak — zwiększ `--max-time`. Jeśli nie — pivot lub abort.

## 3. no-progress

**Detekcja:** `error-hash.sh` liczy md5 (pierwsze 8 znaków) z linii błędu w `logs/yolo-iter-N-acM.log`. Driver trzyma ostatnie 3 hashe. Gdy 3 z 3 są równe i hash ≠ "no-errors" → STOP.

**Output:** `{"status":"no-progress","hash":"a3f7b2c8","recent_hashes":["a3f7b2c8","a3f7b2c8","a3f7b2c8"]}` + exit 4.

**Co robić w YOLO:** auto-pivot triggered (PIVOT_REQUIRES_HUMAN=0). Driver wywołuje `pivot-trigger.sh` — archive branch, reset sprint, restart Faza 5. Patrz `pivot-protocol.md`.

**Co robić w hybrid:** STOP + eskalacja do human. Operator decyduje: pivot ręcznie, zmień approach, abort.

## 4. scope-violation

**Detekcja:** dwa źródła:
- **Pre-flight:** `paths_in_scope` w `contract.json` zawiera Fragile zone path (`migrations/`, `terraform/`, `k8s/`, `auth/`, `.github/workflows/`, `Dockerfile`, `prod*`) — exit 5 chyba że `--force-fragile`.
- **Per iter:** `check-scope-discipline.sh` — `git diff --name-only` zawiera plik spoza `paths_in_scope` lub w Fragile zone.

**Output:** `{"status":"scope-violation","reason":"<...>","violations":["<file1>","<file2>"]}` + exit 5.

**Co robić:** generator przekroczył scope. Rollback przez `git reset --hard` (operator). Zaktualizuj `paths_in_scope` w contract jeśli rozszerzenie zamierzone, albo wycofaj zmiany.

## 5. pr-too-big

**Detekcja:** `check-pr-size.sh` — per commit liczy `git show --stat`. Limit: 300 linii (warning) / 1000 linii (hard fail, chyba że `--justified`).

**Output:** exit 6 z listą plików i liczbą zmienionych linii.

**Co robić:** generator zrobił non-atomic commit. Rollback, split na atomiki. Maksimum 1 AC per commit.

## 6. human-abort

**Detekcja:** operator wywołał `swarm-stop.sh --run {RUN_ID}`.

**Output:** breadcrumb `yolo_stopped {"reason":"human-abort"}` + tmux session zostaje (zachowanie state do debugu) + exit 0.

**Co robić:** state nietknięty. `swarm-status.sh --run {RUN_ID}` pokaże gdzie zatrzymał się run. Operator decyduje czy resume (re-spawn) czy zostawić.

## 7. GREEN (success, NIE jest błędem)

**Detekcja:** wszystkie verification cmds z `goal-statement.md` exit 0 w jednej iteracji.

**Output:** breadcrumb `gate_approved {"gate":5,"actor":"yolo","auto_approved":true}` + `archive-run.sh` wywołany → tar.gz + delete + exit 0.

**Co robić:** nic. Sprint zakończony, archiwum w `.agents-swarm/archives/{RUN_ID}.tar.gz`, manifest obok. Sprawdź też `git log --oneline` żeby zobaczyć atomic commits.

## Priorytety STOP (kolejność oceny w swarm-yolo.sh)

1. Pre-flight: walidacja args, ścieżki, contract presence → exit 2.
2. iter-cap → exit 3.
3. time-cap → exit 3.
4. Fragile path check (jeśli nie `--force-fragile`) → exit 5.
5. Run verification cmds.
6. Per cmd: command-chaining check → exit 5.
7. ALL GREEN? → archive + exit 0.
8. FAIL? → error-hash + no-progress check → exit 4 z pivot (yolo) lub STOP (hybrid).
9. FAIL? + progress (różny hash) → wyślij phase-yolo-iterate do generator + exit 1 (re-invoke required).

## Twarde zakazy (egzekwowane niezależnie od trybu)

YOLO znosi human-in-the-loop ALE **nie** te zabezpieczenia:
- `git push`, `git push --force` — zawsze human gate
- `npm publish`, `cargo publish`, `pip publish`, `gh release create` — zawsze human gate
- `gh pr create`, `gh pr merge`, `gh pr review --approve` — zawsze human gate
- `DROP TABLE`, `DROP DATABASE`, `TRUNCATE` — zawsze human gate
- `rm -rf` poza `paths_in_scope` — scope violation
- Edycja Fragile zones — exit 5 chyba że `--force-fragile`

Próba uruchomienia przez generator → driver blokuje (whitelist commands), dopisuje breadcrumb `destructive_blocked`, exit 7.
