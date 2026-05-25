# ADR-{NNNN} — {slug}

> Architecture Decision Record. Pisany przez **Generator** w momencie podjęcia decyzji architektonicznej.
> Numbering sekwencyjne (ADR-0001, ADR-0002, ...). Filename: `docs/adr/ADR-{NNNN}-{kebab-slug}.md`.
> Format inspirowany Michael Nygard's ADR + przejęty z `dev/audited-feature-workflow/references/adr-template.md`.

---

## Status

<jeden z: Proposed | Accepted | Deprecated | Superseded by ADR-XXXX>

Date: <YYYY-MM-DD>
Sprint: <N>
Author: generator (lub: planner/evaluator/playwright-runner — jeśli decyzja powstała w ich obszarze)

---

## Context

<2-4 zdania: jaka sytuacja wymaga decyzji, jakie ograniczenia/siły, dlaczego decydujemy teraz>

Przykład:
> Sprint 2 buduje editor canvas z obsługą drag-drop kafelków. Mamy 3 opcje rendering: Canvas 2D API (manual mouse events), react-dnd (HTML5 backend), Phaser 3 Scene (game engine).
> Ograniczenia: bundle size <200KB, accessibility WCAG AA, target browsers Chrome/Firefox/Safari ≥110.

---

## Decision

<wybrane podejście w trybie oznajmującym (1-3 zdania)>

Przykład:
> Wybieramy **react-dnd** z HTML5 backend dla drag-drop logiki + custom canvas dla renderowania.

---

## Consequences

### Positive

- <konsekwencja pozytywna 1>
- <konsekwencja pozytywna 2>

Przykład:
- react-dnd ma builtin keyboard support → spełnia NFR-03 (WCAG AA).
- Undo stack darmowy z react-dnd state.
- 3M downloads/week na npm = community support.

### Negative / Costs

- <konsekwencja negatywna 1 — co tracimy>
- <konsekwencja negatywna 2>

Przykład:
- +50KB do bundle (vs 0 dla Canvas 2D manual). NFR-05 nadal OK (300KB / 200KB threshold breached → ADR-0003 osobno).
- Learning curve dla zespołu (react-dnd ma swoje conventions).

### Operational

- <co operacyjnie wymaga uwagi: monitoring, alerts, runbooks>

Przykład:
- Brak — biblioteka client-side, brak runtime infrastructure impact.

---

## Alternatives considered

Minimum **2** alternatywy odrzucone. Format: nazwa + dlaczego NIE.

| Alternatywa | Dlaczego NIE |
|---|---|
| **Canvas 2D + manual events** | Pełna kontrola, ale brak undo + brak keyboard a11y. NFR-03 (WCAG AA) niemożliwy do spełnienia bez 200+ linii custom kodu. |
| **Phaser 3 Scene** | Future-proof dla physics, ale 300KB bundle (NFR-05 breach) + overkill dla 2D static tiles. Zachowane jako future consideration jeśli dodamy physics w v0.2.0. |

---

## Verification

Jak sprawdzimy że decyzja **działa** zgodnie z założeniami:

- **Test ref:** `tests/editor/drag-drop.spec.ts::user drags tile from palette to canvas`
- **AC verified:** C-04 (drag-drop functional), C-12 (keyboard navigation a11y) z `state/contracts/sprint-2.json`
- **Plan link:** `state/plan.md §Sprint 2 hipoteza H2 (Idiomatic)`
- **Evidence:** `state/evidence/sprint-2/ui/C-04/after.png` + `state/evidence/sprint-2/a11y/violations.json`

---

## Follow-ups

Opcjonalne — co dalej:

- [ ] Sprint 3: rozważyć dodanie `react-dnd-touch-backend` dla mobile (jeśli scope się rozszerzy).
- [ ] Performance regression test po dodaniu react-dnd (porównanie bundle przed/po).

---

## Hyrum Impact

> Wypełniaj **tylko** gdy decyzja dotyka publicznych API / schema DB / wersji critical dep.

- **Klasyfikacja:** Internal (nowy moduł, brak istniejących consumerów).
- **Migration path:** n/a (greenfield).

---

## References

- [react-dnd docs (context7-verified version 16.0.1)](https://react-dnd.github.io/react-dnd/about)
- ADR-0001 (poprzednia decyzja: framework React vs Vue)
- `state/plan.md §Sprint 2`
- `state/prd/sprint-2.md §4 Functional requirements`
