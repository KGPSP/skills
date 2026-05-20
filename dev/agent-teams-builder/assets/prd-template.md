# PRD — Sprint {N}: <slug>

> Product Requirements Document. Pisany przez **Planner** w fazie 1 SKILL.md, **po** napisaniu `state/plan.md`, **przed** fazą 3 (negocjacja kontraktu).
> PRD jest bazą dla kontraktu sprintu — Generator i Evaluator w fazie 3 negocjują kryteria realizujące te requirements.

---

## 1. User story

Jako **<persona>**
Chcę **<funkcjonalność>**
Aby **<wartość biznesowa>**.

Przykład:
> Jako **twórca gier amator**
> Chcę **rysować poziomy 2D przez drag-drop kafelków na siatce**
> Aby **w 5 minut zbudować pierwszy poziom bez kodu**.

---

## 2. Problem statement

<2-4 zdania: jaki problem rozwiązujemy, dla kogo, dlaczego teraz>

Przykład:
> Obecnie tworzenie gier 2D wymaga albo silnika (Phaser/Godot — krzywa uczenia) albo umiejętności kodowania (Canvas API). Adresujemy lukę między "no-code" (drag-drop UI builders) a "low-code" (templates) dla domeny gier retro 2D.

---

## 3. Personas (kogo dotyczy)

- **Primary:** <opis 1-2 zdania>
- **Secondary:** <opis>
- **NOT for:** <kogo wykluczamy świadomie>

---

## 4. Functional requirements

Lista **co system robi**. Każdy requirement = 1 linia.

- FR-01: Użytkownik widzi siatkę 32×18 kafelków na canvas 1024×576px.
- FR-02: Klik LPM na pusty kafel kładzie wybrany sprite z palette.
- FR-03: Klik PPM na zajęty kafel usuwa sprite.
- FR-04: Drag z palette na canvas malarza ciągłą linię (jak Paint).
- FR-05: Ctrl+Z cofa ostatnią operację (undo stack ≥10).
- FR-06: F5 odtwarza stan canvas z localStorage.

> **Reguła:** FR muszą być **observable** (user widzi/słyszy/dotyka). Brak FR typu "system używa state managera X".

---

## 5. Non-functional requirements

Mierzalne progi (z metodą pomiaru).

| NFR | Target | Measurement | Tool |
|---|---|---|---|
| NFR-01 (perf) | TTI < 1500ms na home | `performance.timing.domInteractive` | Playwright/Chrome DevTools |
| NFR-02 (perf) | Render 32×18 siatki < 100ms | `performance.now()` mark/measure | Playwright |
| NFR-03 (a11y) | WCAG 2.1 AA, 0 critical violations | `@axe-core/playwright` | playwright-runner faza 4 |
| NFR-04 (security) | CSP `default-src 'self'`, brak `unsafe-inline` | HTTP header check | curl + `script-src` audit |
| NFR-05 (compat) | Chrome ≥110, Firefox ≥110, Safari ≥16 | Playwright matrix | `playwright.config.ts.projects` |

---

## 6. Out of scope (per sprint)

- <co jawnie pomijamy w tym sprincie>
- <co przesuwamy na następny sprint LUB do backlog>

> **Reguła:** brak — sprint próbuje zrobić wszystko, kontrakt będzie rozmyty.

---

## 7. Success metrics (mierzalne)

- [ ] <metric 1> — np. "100% FR realizowane przez Playwright tests"
- [ ] <metric 2> — np. "axe-core 0 critical/serious violations"
- [ ] <metric 3> — np. "Bundle size < 200KB gzipped"

---

## 8. Open questions (eskalacja)

- [ ] Q1: <pytanie wymagające decyzji human przed implementacją>
- [ ] Q2: ...

> **Reguła Non-negotiable #1:** każda niewiadoma jawnie zgłoszona. Lista pusta = Planner założył coś bez świadomości.

---

## Notes

- **Kontrakt sprintu** (`state/contracts/sprint-{N}.json`) — generowany w fazie 3 na podstawie FR + NFR z tego PRD. Każde FR → kryterium binarne. Każde NFR → kryterium z metryką.
- **Hipotezy** w `state/plan.md §Sprints` mówią JAK realizujemy te requirements (Minimal/Idiomatic/Ambitious).
- **ADR** w `docs/adr/` powstaje gdy realizacja wymaga decyzji architektonicznej (lib, pattern, schema).
