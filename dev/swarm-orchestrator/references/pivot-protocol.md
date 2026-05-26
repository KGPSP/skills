---
name: pivot-protocol
type: reference
parent: swarm-orchestrator
sources:
  - DOC/agent-teams-generator-ewaluator.md §7 (pivot trigger)
  - DOC/since_skill.md §7 (Plan-Validate-Execute)
  - dev/agent-teams-builder/scripts/pivot-trigger.sh (1:1 reuse z patch SCRIPTS_DIR)
---

# Pivot protocol — Plan-Validate-Execute

Pivot to **reset sprintu** wywołany gdy generator zacina się w pętli (no-progress 3× ten sam error_hash). Reset = archiwizacja branchu + usunięcie pracy + restart od Fazy 5 (contract renegotiation).

## Trigger

**Automatyczny (YOLO):** `swarm-yolo.sh` po 3× ten sam `error_hash` z `error-hash.sh` → wywołuje `pivot-trigger.sh` z `PIVOT_REQUIRES_HUMAN=0`.

**Ręczny (hybrid/manual):** evaluator (lub operator) pisze `state/pivot_plan.md` z sekcjami:
1. `## Dlaczego pivot` — które AC zawiodły, dlaczego obecne podejście nie działa.
2. `## Co usuwamy` — lista paths/files do `rm -rf`.
3. `## Nowy approach` — opis innego podejścia (≤200 słów).
4. `## Co zachowujemy` — pliki/decyzje które przeżywają (zwykle contract, plan).

Generator akceptuje pivot dopisując breadcrumb `pivot_accepted {"sprint":"sprint-N"}`.

## Egzekucja (pivot-trigger.sh)

Skrypt egzekwuje **Plan-Validate-Execute**:

### Plan

- Sprawdza obecność `state/pivot_plan.md` (od evaluatora).
- Sprawdza breadcrumb `pivot_accepted` dla danego sprintu (od generatora) — bez akceptacji ABORT.
- Parsuje sekcję `## Co usuwamy` → lista paths.

### Validate

- **Bezpieczeństwo:** discard paths NIE mogą zawierać:
  - `state/contracts/` (kontrakt = niezmiennik sprintu)
  - `state/plan.md` (plan = niezmiennik sprintu)
  - `state/breadcrumbs.json` (audit = nieusuwalny)
  - `state/evidence/` (evidence = audit)
- Hook człowieka (`PIVOT_REQUIRES_HUMAN=1` default w hybrid/manual) — printuje pivot_plan.md, czeka na `y` z stdin.

### Execute

1. Archive branch: `git checkout -b archive/sprint-N-pivot-{TIMESTAMP}` + powrót do main.
2. `rm -rf` paths z `## Co usuwamy`.
3. `git add -A && git commit -m "pivot(sprint-N): discard implementation, restart from contract"`.
4. Breadcrumb `pivot_executed {"sprint":"sprint-N","hash_before":X,"hash_after":Y,"archived_branch":B}`.
5. Move `state/pivot_plan.md` → `state/evidence/pivots/sprint-N-pivot-{TS}/pivot_plan.md` (audit).
6. Save `before-hash.txt`, `archive-branch.txt` w evidence.

## Po pivocie

1. Wróć do Fazy 5 (Contract Negotiation) — generator i evaluator negocjują NOWY contract `sprint-N+1.json` lub renegocjują istniejący sprint.
2. Reset `state/yolo-status.json` (iter=0, start_ts=now).
3. Generator implementuje od zera w pane generator (czysty kod, ale plan i contract pamięta).

## Limity pivotów

**Default: max 2 pivoty per sprint.** Walidator `check-pivot-budget.sh` (TODO — nie zaimplementowany w v1.0.0) miał by sprawdzać liczność `pivot_executed` per sprint w breadcrumbs. Trzeci pivot → STOP + eskalacja do human (`status: pivot-budget-exhausted`).

**W v1.0.0:** brak walidatora; operator musi pilnować budgetu czytając breadcrumbs.

## Anti-Rationalization (specyficzne dla pivota)

| Wymówka | Riposta |
|---|---|
| „Pivot to przyznanie się do porażki" | Nie. Pivot to świadoma decyzja że obecne podejście jest droższe niż restart. Zachowujesz wiedzę (plan + contract), tracisz tylko zły kod. |
| „Jeszcze jedna iteracja może załatwi" | Error_hash powtarza się 3×. Z definicji pętla. Pivot wcześniej = mniej spalonych iteracji = niżej time-cap. |
| „Pivot zaorze evidence" | Nie. `pivot-trigger.sh` przenosi pivot_plan.md do `state/evidence/pivots/` — pełen audit trail zachowany. Discarded code idzie do archive branch. |
| „Mogę po prostu zmienić kontrakt zamiast pivotować" | Można, ale to wymaga renegotiation contract phase + akceptacji gate:2 ponownie. Jeśli implementation jest zła a contract OK → pivot jest właściwą drogą. |
