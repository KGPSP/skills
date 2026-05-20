---
title: System plików jako trwała pamięć agentów (zamiast okna kontekstowego)
load-when: "Faza 0 (bootstrap) LUB istnieje już `state/` z poprzedniej sesji (recovery)"
source:
  - DOC/agent-teams-generator-ewaluator.md §5 (Pamięć: system plików jako trwały stan)
  - DOC/since_skill.md §5 (Token budget, progressive disclosure)
---

# System plików = pamięć agentów

> Okno kontekstowe degraduje się w długich sesjach (*context rot*). Agent Teams **nie polegają na kontekście** — dzielą stan przez pliki. Każdy agent przy starcie iteracji czyta `state/`, na koniec dopisuje breadcrumb.

---

## 1. Struktura katalogu `state/`

```
state/
├── plan.md                          # Markdown — Planner pisze raz na sprint
├── contracts/
│   ├── sprint-1.json                # JSON — Generator + Evaluator (append-only)
│   ├── sprint-2.json
│   └── sprint-N.draft.json          # draft = w trakcie negocjacji
├── feature_list.json                # JSON — status wszystkich funkcji (append-only)
├── breadcrumbs.json                 # JSON — log iteracji (append-only, ts-ordered)
├── rubric/
│   ├── design.md                    # Markdown — rubryka per warstwa
│   ├── functionality.md
│   └── code-quality.md
├── evidence/
│   ├── sprint-1/                    # PNG, log, json — artefakty dowodowe per kryterium
│   │   ├── C-01.png
│   │   ├── C-02.log
│   │   └── C-03.json
│   └── sprint-2/
├── pivot_plan.md                    # Markdown — tylko gdy faza 5 aktywna
├── blockers.md                      # Markdown — eskalacja do human
└── verify-report.md                 # Markdown — output fazy 6
```

---

## 2. JSON vs Markdown — krytyczna decyzja

| Format | Kiedy | Dlaczego |
|---|---|---|
| **JSON** | Status, listy, breadcrumbs, wyniki ewaluatora | Model **dopisuje** klucze do struktury. Łatwo walidować schemą. `jq` filtruje. |
| **Markdown** | Plan, kontrakty (negocjacja), rubryki, raporty | Czytelne dla human. Ale UWAGA: model często **nadpisuje cały plik** zamiast dopisywać → ZAKAZ użycia dla append-only data. |

**Reguła:** jeśli plik ma rosnąć w czasie (status, log, lista) → JSON. Jeśli plik ma być raz napisany i rzadko poprawiany → Markdown.

---

## 3. Schemy JSON (twarde)

### 3.1 `feature_list.json`

```json
{
  "version": 1,
  "features": [
    {
      "id": "F-001",
      "name": "Edytor poziomu",
      "sprint": 2,
      "status": "in_progress",
      "iterations": 3,
      "last_evidence": "state/evidence/sprint-2/C-05.png",
      "history": [
        { "ts": "2026-05-19T16:00:00Z", "status": "planned" },
        { "ts": "2026-05-19T16:45:00Z", "status": "in_progress" },
        { "ts": "2026-05-19T18:00:00Z", "status": "pivoted", "reason": "stagnation" }
      ]
    }
  ]
}
```

**Reguła append-only:** każda zmiana statusu = nowy wpis w `history`, **nie** modyfikacja istniejącego. `scripts/append-breadcrumb.sh` używa `jq` z `--argjson` i dopisuje przez `+=`, nie `=`.

### 3.2 `breadcrumbs.json`

```json
[
  {
    "ts": "2026-05-19T16:00:00Z",
    "actor": "bootstrap",
    "event": "init",
    "details": { "project": "retro-forge", "git_init_hash": "..." }
  },
  {
    "ts": "2026-05-19T16:05:00Z",
    "actor": "planner",
    "event": "plan_created",
    "details": { "plan_path": "state/plan.md", "sprints": 7 }
  },
  {
    "ts": "2026-05-19T17:00:00Z",
    "actor": "generator",
    "event": "iteration_start",
    "details": { "sprint": 2, "iteration": 1 }
  },
  {
    "ts": "2026-05-19T17:30:00Z",
    "actor": "evaluator",
    "event": "iteration_verdict",
    "details": { "sprint": 2, "iteration": 1, "passed": 11, "total": 15, "verdict": "iterate" }
  }
]
```

**Zawsze append.** Brak `git diff` pokazującego usunięte wpisy. Walidacja: `scripts/check-breadcrumbs-append-only.sh`.

---

## 4. Promptowanie pod zachowanie append-only

W system promptach Generatora i Evaluatora:

> "Gdy modyfikujesz `state/breadcrumbs.json` lub `state/feature_list.json`:
> 1. Przeczytaj plik (`cat state/breadcrumbs.json`).
> 2. Dopisz nowy wpis na końcu tablicy (LUB do `history` istniejącego klucza).
> 3. Walidacja: `jq '. | length' state/breadcrumbs.json` po zapisie musi zwrócić wartość **większą** niż przed.
> 4. NIE WOLNO usuwać ani modyfikować istniejących wpisów. Operacje destruktywne na tych plikach = błąd procedury."

---

## 5. Git worktrees dla pracy równoległej

Gdy zespół buduje wiele sprintów jednocześnie (np. Frontend Builder + Backend Builder pracują na różnych funkcjach):

```bash
git worktree add ../project-feature-frontend feature/frontend
git worktree add ../project-feature-backend  feature/backend
```

**Korzyść:** każdy agent ma osobny katalog roboczy, brak kolizji w `state/contracts/`, niezależne commity. Pisanie do `state/` z różnych worktree → konflikty? **NIE — `state/` jest w głównym worktree, dzielony przez symlink lub merge przez agenta-integratora.**

Wariant prosty (zalecany na start): **jeden worktree, jeden aktywny sprint na raz.** Worktrees włącz dopiero przy 5+ równoległych funkcjach.

---

## 6. Git jako część uprzęży

Uprząż automatycznie:

1. **Inicjalizuje repo** w fazie 0: `git init && git commit --allow-empty -m "init agent-teams session"`.
2. **Commit po każdym `passed == total` kontraktu:** `git commit -m "sprint-{n}: {goal} — all {N} criteria passed"`.
3. **Tag po fazie 7:** `git tag -a v{semver}`.
4. **Archiwizuje branch przed pivotem** (patrz `pivot-protocol.md §2 krok 4`).

Brak ręcznych commitów w trakcie sesji — wszystko przez skrypty.

---

## 7. Recovery — wznawianie sesji z istniejącego `state/`

Jeśli faza 0 wykryje istniejący `state/`:

1. **STOP — nie nadpisuj.**
2. Wczytaj `state/breadcrumbs.json` i znajdź ostatni wpis: `last = breadcrumbs[-1]`.
3. Wczytaj `state/feature_list.json` i znajdź pierwszą funkcję ze statusem ≠ `passed`/`shipped`.
4. Wczytaj odpowiedni `state/contracts/sprint-{n}.json`.
5. Wznów od fazy określonej przez `last.event`:
   - `event == "init"` → faza 1 (Planner).
   - `event == "plan_created"` → faza 2 (spawn).
   - `event == "contract_accepted"` → faza 4 (pętla).
   - `event == "pivot_executed"` → faza 3 (renegocjacja).
6. Wpis w breadcrumbs: `event: "session_resumed"`.

**Bez recovery** sesja rzucona w połowie traci całą pracę.

---

## 8. Walidatory plików stanu

| Walidator | Co sprawdza |
|---|---|
| `scripts/check-breadcrumbs-append-only.sh` | `git diff state/breadcrumbs.json` nie pokazuje `-` linii w tablicy |
| `scripts/check-contract-coverage.sh {n}` | Liczba kryteriów ≥15, wszystkie binary, evidence_type określony |
| JSON-schema validation (ręcznie) | `jq -e --slurpfile s assets/breadcrumbs-schema.json '. as $d \| $s[0]' state/breadcrumbs.json` (najprościej: `jq empty state/breadcrumbs.json` dla syntax + `verify-non-negotiables.sh` dla semantyki) |
| `scripts/check-evidence-completeness.sh {n}` | Każde `passed: true` kryterium ma odpowiadający plik w `state/evidence/sprint-{n}/` |
| `scripts/verify-non-negotiables.sh` | 5 zasad nienegocjowalnych (zob. `non-negotiables.md`) |

Uruchamiaj na każdej granicy fazy.

---

## 9. Exit criterion bootstrap (faza 0)

```bash
test -d state/ && \
test -f state/breadcrumbs.json && \
test "$(jq '. | length' state/breadcrumbs.json)" -ge 1 && \
git log --oneline | head -1 | grep -q "init agent-teams session"
```

Wszystkie 4 zielone → faza 0 zamknięta.
