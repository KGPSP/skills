# Session log — {YYYY-MM-DD}

> Auto-generated przez `scripts/append-session-log.sh` na koniec dnia LUB na koniec sesji `/goal`.
> Agreguje breadcrumbs.json + git log + state/feature_list.json w czytelny dzienny raport.
> NIE pisany ręcznie.

---

## Session metadata

- **Date:** {YYYY-MM-DD}
- **Project:** <z state/feature_list.json.project>
- **Duration:** <min> (od pierwszego eventu w breadcrumbs do ostatniego)
- **Active agents:** <lista actor'ów które miały eventy>

---

## Activity summary

### Sprints worked on

| Sprint | Status (start of day) | Status (end of day) | Iterations | Commits |
|---|---|---|---|---|
| 1 | passed | passed | 2 | 3 |
| 2 | in_progress | passed | 4 (iter 3 stagnacja → fix) | 5 |
| 3 | planned | in_progress | 1 (smoke OK, UI tests in progress) | 1 |

### Breadcrumbs distribution

```
bootstrap: 0 (session continued)
planner: 1
generator: 12 events (8 iteration_start, 4 commit)
evaluator: 8 events (6 iteration_verdict, 2 sprint_passed)
playwright-runner: 3 events (3 phase_complete: smoke, ui, perf)
human: 1 (blocker_resolved)
```

### Commits

```
git log --oneline --since=midnight
{auto-populated}
```

---

## Decisions made today

> Agregacja z state/decision-log.md + nowe ADRs.

- **Lekkie decyzje (decision-log):** {count}
- **ADRs powstałe:** {linki}

Przykład:
> - ADR-0003: Wybór `react-dnd` vs `dnd-kit` (Sprint 2)
> - decision-log: 5 wpisów (naming conventions, file structure)

---

## QA reports

| Sprint | Smoke | UI | Perf | A11y | Visual | Overall |
|---|---|---|---|---|---|---|
| 1 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 2 | ✅ | ✅ | ⚠️ LCP=2700ms | ✅ | ✅ | ⚠️ ADR-0004 needed |

---

## Blockers (open)

> Z `state/blockers.md` filtered to "not resolved".

- 🔴 **Q3:** Czy export ma być HTML czy zip? — open since {date} (sprint 6 zablokowany)
- 🟡 **Performance:** LCP 2700ms vs target 2500ms — needs ADR

---

## Open Questions resolved today

- ✅ **Q1:** Mobile support? → Resolved: NO (desktop-only MVP). Decyzja w sprincie 0.

---

## Pivots

> Z eventów `pivot_executed` w breadcrumbs.

| Sprint | Time | Reason | Archive branch |
|---|---|---|---|
| (none) | — | — | — |

---

## Tomorrow's plan

> Z `state/feature_list.json` — wszystkie features ze statusem `planned` i `in_progress`.

- Sprint 3 — Asset palette (continue from current)
- Sprint 4 — Play mode (start)
- Resolve open question Q3 (ship format)

---

## Notes (manual append)

> Sekcja jedyna do której można dopisać ręcznie. Wszystko inne — auto.

- ...

---

## Links

- Plan: `state/plan.md`
- Feature list: `state/feature_list.json`
- Breadcrumbs (filtered today): `jq '[.[] | select(.ts | startswith("{YYYY-MM-DD}"))]' state/breadcrumbs.json`
- Active retrospectives: `state/retrospectives/`
