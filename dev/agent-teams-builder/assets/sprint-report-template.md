# Sprint Report — wykonanie sprintu {N}

> Raport o **wykonaniu zadania** prezentowany człowiekowi na **GATE #3** (akceptacja sprintu).
> Pisany przez **Evaluator** po `sprint_passed`, PRZED frazą akceptującą. Cel: człowiek czyta i decyduje
> „zatwierdzam sprint {N}" / „request changes" w 3-5 minut. To NIE retrospektywa (lessons learned) —
> to dowód „co zrobiono i że działa". Retro żyje osobno w `state/retrospectives/sprint-{N}.md`.

---

## 1. Co zrobiono (executive summary)

- **Sprint:** {N} — <slug>
- **Goal (z PRD):** <jednolinijkowy cel biznesowy>
- **Wybrana hipoteza:** <H1/H2/H3 z plan.md> — <nazwa>
- **Status:** ✅ passed (wszystkie kryteria) | ⚠️ passed po pivocie
- **Iterations:** <N> / MAX_ITERATIONS
- **Diff:** <±X linii>, <Y plików> (`git diff --stat <range>`)

2-3 zdania prozą: co użytkownik końcowy może teraz zrobić, czego nie mógł przed sprintem.

---

## 2. Kryteria kontraktu — wynik (binarny)

> Tabela 1:1 z `state/contracts/sprint-{N}.json`. Każde kryterium = pass/fail + link do dowodu.

| Kryterium | Typ | Priorytet | Wynik | Dowód |
|---|---|---|---|---|
| C-01 | AC-F | MUST | ✅ pass | `state/evidence/sprint-{N}/c01-cursor.png` |
| C-02 | AC-T | MUST | ✅ pass | `tests/editor/store.spec.ts::addTile` |
| ... | ... | ... | ... | ... |

**Coverage:** `<passed>/<total>` kryteriów MUST = pass. SHOULD pominięte → link do ADR.

---

## 3. Dowód runtime (evidence)

> Niezależnie wygenerowany przez **Evaluatora** (NIE Generatora). Independent verification.

- **Screenshots:** `state/evidence/sprint-{N}/` (<liczba> plików, screenshot per AC-F).
- **Logi testów (raw, bez parafraz):** `<komenda>` → exit 0, output w evidence.
- **QA report** (jeśli playwright-runner): `state/qa-reports/sprint-{N}.md` → GATE #4.
- **Smoke test:** aplikacja startuje lokalnie — `<komenda>` exit 0.

---

## 4. Decyzje i dług

- **ADR powstałe w sprincie:** <linki do `docs/adr/ADR-NNNN-*.md`> (lub „brak — decyzje lekkie w decision-log.md").
- **Hyrum impact zrealizowany:** <co z publicznym API faktycznie się zmieniło vs plan>.
- **Dług techniczny zaciągnięty:** <lista lub „brak"> + gdzie zapisany (`feature_list.json` COULD / backlog).
- **Scope:** `git diff --name-only <range>` zwraca tylko pliki ze sprintu wg `plan.md`? ✅ / ⚠️.

---

## 5. Rekomendacja Evaluatora dla GATE #3

> ✅ **Approve** — sprint kompletny, dowody na miejscu, gotowy do akceptacji i kolejnego sprintu.
> ⚠️ **Approve z zastrzeżeniem** — działa, ale `<co wymaga uwagi w następnym sprincie>`.
> ❌ **Request changes** — `<co blokuje>` (wtedy NIE prezentuj jako gotowe do zgody).

---

## 6. Pytanie do człowieka (bramka)

> **GATE #3 — Sprint {N}.** Artefakty do przeglądu: sekcje 2-4 powyżej + evidence w `state/evidence/sprint-{N}/`.
> Czy zatwierdzasz sprint {N} i przejście do kolejnego? Odpowiedz „zatwierdzam sprint {N}" / „request changes: <powód>".

---

## Links

- PRD: `state/prd/sprint-{N}.md`
- Plan: `state/plan.md §Sprint {N}`
- Contract: `state/contracts/sprint-{N}.json`
- Retrospective: `state/retrospectives/sprint-{N}.md`
- Breadcrumbs range: <ts_start..ts_end>
