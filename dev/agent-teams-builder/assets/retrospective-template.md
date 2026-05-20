# Retrospective — Sprint {N}

> Pisany przez **Evaluator** (lub Generator jako secondary) po `sprint_passed` LUB po pivocie.
> 5-10 minut na wypełnienie. Format krótki — lessons learned, NIE 30 stron analizy.

---

## Sprint summary

- **Sprint:** {N} — <slug>
- **Goal (z PRD):** <jednolinijkowy cel biznesowy>
- **Result:** ✅ passed | ⚠️ pivoted | ❌ escalated
- **Iterations:** <N> / MAX_ITERATIONS=5
- **Duration:** <min>
- **Pivots:** <0|1|2+>

---

## What went well

> Minimum 3 punkty. Bez tego retrospective jest jednostronny.

- ✅ <co działało>
- ✅ <co działało>
- ✅ <co działało>

Przykład:
> ✅ Context7 dla react-dnd dał aktualną składnię — Generator napisał poprawny kod od pierwszej iteracji.
> ✅ Smoke test złapał breaking change w react 19 (StrictMode podwójne render) zanim Evaluator wszedł.
> ✅ Pivot plan przygotowany w fazie 1 — wiedzieliśmy że H1 (manual canvas) jest fallback.

---

## What didn't

> Minimum 3 punkty (jeśli sprint pivoted — 5+).

- ❌ <co nie działało>
- ❌ <co nie działało>
- ❌ <co nie działało>

Przykład:
> ❌ Generator w iteracji 2 dodał `useState<any>` zamiast typed state — Evaluator złapał w C-09 (craft filar). +1 iteracja.
> ❌ Visual regression flaky na firefox — antialiasing różnice. Dodaliśmy `maxDiffPixels: 200` w fazie 5.
> ❌ axe-core wykrył 2 moderate violations (color-contrast w hover state) — nie był FR ale wymaga fix przed ship.

---

## Lessons learned

### Per Generator

- <co Generator powinien robić inaczej w następnym sprincie>

Przykład:
> - Failing test pisać PRZED implementacją (TDD) — w iter 1 ominęliśmy, ale w iter 2 musieliśmy cofnąć i napisać.
> - Każdy `useState` ma explicit type (`useState<User | null>(null)` — NIE `useState(null)`).

### Per Evaluator

- <co Evaluator powinien robić inaczej>

Przykład:
> - Feedback dla generatora MUSI być specific. "Drag-drop nie działa" było zbyt ogólne — Generator próbował 3 różnych implementacji zanim trafił. Lepiej: "Drag-drop: keyboard event Enter nie wywołuje submit (test C-04 fail)."

### Per playwright-runner (jeśli zaangażowany)

- <co playwright-runner powinien robić inaczej>

---

## Pivot history (jeśli był pivot)

> Wypełniaj **tylko** jeśli sprint przeszedł przez fazę 5 (pivot).

- **Iteration when pivot triggered:** <N>
- **Stagnation pattern:** `passed[3]=11, passed[4]=11, passed[5]=11` (przykład)
- **Failed criteria (last 3 iters):** C-08, C-09, C-15
- **Pivot plan:** linki do `state/evidence/pivots/sprint-{N}-pivot-{ts}/pivot_plan.md`
- **Archive branch:** `archive/sprint-{N}-pivot-{ts}`
- **Recovery time:** <min> (od pivot_executed do passed)
- **Was pivot necessary?** ✅ TAK / ❌ NIE (retro analysis)

---

## Cost

- **Time:** ~<min> w sumie
- **Tokens:** ~<liczba> (jeśli mierzone)
- **USD estimate:** ~$<wartość> (jeśli measured w API mode)
- **Human escalations:** <N>

---

## Action items dla następnych sprintów

> Konkretne zmiany w workflow. NIE generyczne ("być bardziej staranny"). Konkretne ("dodać check X w smoke test").

- [ ] **Action 1:** <konkretna zmiana>
- [ ] **Action 2:** ...

Przykład:
> - [ ] Dodać do smoke test check: `console.warn` w trybie StrictMode (React 19) — żeby złapać podwójne render side effects wcześniej.
> - [ ] Wymóg w PRD: każde FR z keyboard interaction MA test z `page.keyboard.press()` — nie tylko `click()`.

---

## Update to anti-rationalization (jeśli wymówka się powtórzyła)

Jeśli ten sprint ujawnił nową kategorię wymówek agentów — dopisz wiersz do `references/anti-rationalization.md`:

```markdown
| <wymówka cytat z trace> | <riposta deterministyczna> |
```

---

## Links

- PRD: `state/prd/sprint-{N}.md`
- Plan section: `state/plan.md §Sprint {N}`
- Contract: `state/contracts/sprint-{N}.json`
- QA Report: `state/qa-reports/sprint-{N}.md`
- Code Review: `docs/code-reviews/CR-sprint-{N}-*.md`
- ADRs in sprint: <links do ADRów które powstały>
- Breadcrumbs range: <ts_start..ts_end>
