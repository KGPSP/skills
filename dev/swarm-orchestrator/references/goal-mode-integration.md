---
name: goal-mode-integration
type: reference
parent: swarm-orchestrator
sources:
  - DOC/goal_mode.md §1,§3 (anatomia /goal)
  - dev/audited-feature-workflow/references/goal-mode-protocol.md (10 reguł, 7 STOP)
  - dev/audited-feature-workflow/scripts/derive-goal-from-ac.sh (logika inline)
---

# Integracja /goal mode

YOLO tryb wykorzystuje protokół `/goal` z `audited-feature-workflow` — autonomiczna pętla weryfikacji AC z mierzalnym STOP.

## Anatomia `goal-statement.md`

Format produkowany przez `swarm-derive-goal.sh`:

```markdown
# Goal — <slug>

## Stan końcowy
<co znaczy "done" — 1-2 zdania, mierzalne>

## Weryfikacja
### AC-1 — T-1: <nazwa testu>
- **Komenda**: `<single non-interactive command>`
- **Expected**: exit 0

### AC-2 — T-2: <nazwa testu>
- **Komenda**: `<single non-interactive command>`
- **Expected**: exit 0

(... per AC z plan.md)

## Ograniczenia
- paths_in_scope: <lista>
- out_of_scope: <lista>
- fragile_zones_detected: false
- max_iter: 20
- max_time: 480
```

## Derive (Faza 4)

`scripts/swarm-derive-goal.sh --plan state/plan.md --output state/goal-statement.md`:

1. Parsuje frontmatter `plan.md`: `paths-in-scope`, `out-of-scope`, `sprint-count`.
2. Parsuje sekcję `# Acceptance Criteria` (tabela 6 kolumn).
3. Per AC: wyciąga `Komenda`, waliduje (no chaining), generuje `### AC-X — T-Y` blok.
4. Wykrywa Fragile paths w `paths-in-scope` — exit 5 jeśli wykryto bez `--force-fragile`.
5. Pisze `goal-statement.md` + `goal-prompt.txt` (jednoblokowy do paste w generator pane).
6. Liczy SHA256(`goal-statement.md`) → `goal-statement.md.sha256` (TOCTOU protection — `swarm-yolo.sh` weryfikuje że plik nie zmienił się po Gate #1.5).

## 10 reguł walidacji (z goal-mode-protocol.md §3)

`swarm-derive-goal.sh` egzekwuje:
1. PRD/plan ma frontmatter `paths-in-scope:` (lista YAML, niepusta).
2. PRD/plan ma sekcję `# Acceptance Criteria`.
3. Tabela AC ma dokładnie 6 kolumn: AC-ID / Typ / Opis / Test ID / Plik testu / Komenda.
4. Każda AC ma niepustą `Komenda`.
5. `Komenda` nie zawiera command chaining: `&&`, `||`, `;`, `|`, `$()`, backticks.
6. `Komenda` jest non-interactive (nie czeka na stdin).
7. Każdy `Plik testu` istnieje w `paths-in-scope` (relatywna ścieżka).
8. Sekcja `# Out of scope` ma ≥1 bullet.
9. AC nie jest subiektywne — opis zawiera mierzalny stan końcowy (nie "ładniej", "szybciej" bez progu).
10. `paths-in-scope` nie zawiera Fragile zone (chyba że `--force-fragile`).

Złamanie którejkolwiek → exit 1 + lista braków + sugestia poprawki.

## Gate #1.5 (goal acceptance)

Po `swarm-derive-goal.sh` exit 0:

- **Hybrid:** operator czyta `goal-statement.md` w pane parent, akceptuje (`gate_approved gate:1.5 actor:human`).
- **YOLO:** Driver auto-approve (`gate_approved gate:1.5 actor:yolo auto_approved:true`).

Driver `swarm-yolo.sh` weryfikuje przed pierwszą iteracją:
```sh
sha256sum -c "$RUN_DIR/state/goal-statement.md.sha256"
# Jeśli mismatch → exit 2 (goal-statement.md zmieniony po Gate #1.5)
```

To chroni przed: user/agent edytuje `goal-statement.md` po akceptacji, żeby ominąć trudne AC.

## Pętla `/goal` w generator pane

W YOLO, generator pane otrzymuje `goal-prompt.txt` (jednoblokowy) jako kontekst, plus per iter `phase-yolo-iterate.md` z `{{FOCUS_AC}}`, `{{FAIL_CMD}}`, `{{FAIL_LOG}}` z `swarm-yolo.sh`.

Po każdej iteracji generator commituje atomic. Driver re-invokuje (lub bash wrapper). Re-invoke aż:
- Wszystkie verification cmds exit 0 → GREEN → archive.
- iter-cap / time-cap / no-progress / scope-violation → STOP z odpowiednim status.

## Współistnienie z innymi skillami

`/goal` w `swarm-orchestrator` **nie wyklucza** `/goal` w `audited-feature-workflow` — to dwa różne entry-pointy do tego samego protokołu:
- `audited-feature-workflow` — single-agent autonomous loop (jeden proces claude).
- `swarm-orchestrator` — 4-agent w tmux, gdzie generator pane jest "main agent" loop'a.

W praktyce: jeśli user pisze `/goal` z PRD i wybiera `--mode yolo`, swarm-orchestrator daje **bardziej widoczną i auditable** pętlę dzięki tmux panes + evaluator pane jako niezależny sędzia (presja rywalizacyjna z DOC/agent-teams-generator-ewaluator.md §4).
