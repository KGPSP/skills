---
title: Documentation Protocol — pełen audit trail wszystkich dokumentów (PRD, ADR, retrospectives, code reviews, QA reports, decisions, sessions)
load-when: "Faza 1 (Planner) — ZAWSZE. Plus każda faza która produkuje dokument (3-7)."
source:
  - dev/feature-planner-v3/SKILL.md (Phase 4/8/9 — plan/code-review/ADR)
  - dev/feature-planner-v3/references/adr-template.md
  - DOC/material_skill.md §4 (Definition of Done — dowód zamiast deklaracji)
  - DOC/since_skill.md §6 (Grounding in real expertise — runbooki + traces)
---

# Documentation Protocol — pełen audit trail

> **Cel:** każdy artefakt pracy zespołu agentów (plan, decyzja, kod, test, review, retrospekcja) jest **persistowany** jako dokument w spójnym formacie. Po sesji `/goal` możesz prześledzić KAŻDĄ decyzję, jej kontekst, alternatywy i wynik bez czytania surowych breadcrumbs.

---

## 1. Dwie warstwy dokumentacji

| Warstwa | Lokalizacja | Charakter | Co tam siedzi |
|---|---|---|---|
| **State (ephemeral)** | `state/` | Per-sesja, w `.gitignore` repo projektu (lub osobny katalog `.agent-state/`) | Plan, PRD, TODO snapshots, breadcrumbs, retrospectives, sessions, QA reports |
| **Docs (committable)** | `docs/` | Trwała wiedza, commitowana do git repo projektu | ADRs (architektura), Code reviews (Five-Axis), Final reports |

> **Reguła:** state/ to to co agent generuje w trakcie pracy + ślad audytu. docs/ to to co zostaje w repo PO sesji jako sourcery dla przyszłych engineerów (i agentów).

---

## 2. Pełna struktura katalogów (10 typów dokumentów)

```
state/                                          (ephemeral — per-sesja)
├── plan.md                                     (1 — Planner, faza 1)
├── prd/
│   ├── sprint-1.md                             (2 — Planner, per sprint)
│   ├── sprint-2.md
│   └── ...
├── contracts/sprint-{n}.json                   (kontrakt negocjacji — istnieje)
├── feature_list.json                           (status — istnieje)
├── breadcrumbs.json                            (audit log — istnieje)
├── evidence/sprint-{n}/                        (runtime dowody — istnieje)
├── rubric/                                     (few-shot — istnieje)
├── blockers.md                                 (eskalacje — istnieje)
├── todo.md                                     (3 — Generator, snapshot per sprint)
├── retrospectives/
│   ├── sprint-1.md                             (4 — Evaluator/Generator, po sprincie)
│   └── ...
├── sessions/
│   ├── 2026-05-20.md                           (5 — auto, per dzień pracy)
│   └── ...
├── decision-log.md                             (6 — lekka chronologia decyzji)
├── qa-reports/
│   ├── sprint-1.md                             (7 — playwright-runner agregacja)
│   └── ...
└── final-report.md                             (8 — po wszystkich sprintach)

docs/                                           (committable do repo projektu)
├── adr/
│   ├── ADR-0001-react-vs-vue.md                (9 — Generator, per decyzja architektoniczna)
│   ├── ADR-0002-state-management-context.md
│   └── ...
├── code-reviews/
│   ├── CR-sprint-1-bootstrap.md                (10 — Evaluator, Five-Axis per sprint)
│   └── ...
└── reports/
    └── final-{project-slug}.md                 (copy of state/final-report.md)
```

---

## 3. Per dokument — kto / kiedy / format

### Dokument 1: `state/plan.md`

- **Kto:** Planner (faza 1)
- **Kiedy:** raz na sesję, na start.
- **Format:** 11 sekcji wg `references/planning-rigor.md` + `assets/plan-template.md`.
- **Status w v1.5:** ✅ Istnieje, walidator `verify-plan-rigor.sh`.

### Dokument 2: `state/prd/sprint-{n}.md` — Product Requirements Document

- **Kto:** Planner (faza 1, **po** napisaniu plan.md)
- **Kiedy:** per sprint, PRZED fazą 3 (negocjacja kontraktu) — PRD jest bazą dla kontraktu.
- **Format:** `assets/prd-template.md`. Sekcje:
  - User story (jako/chcę/aby)
  - Problem statement
  - Personas (kogo dotyczy)
  - Functional requirements (lista)
  - Non-functional requirements (perf, a11y, security)
  - Out of scope per sprint
  - Success metrics (mierzalne)
  - Open questions (eskalacja)
- **Walidator:** sprawdza obecność wszystkich 8 sekcji.

### Dokument 3: `state/todo.md` — TODO snapshot

- **Kto:** Generator (po każdej iteracji)
- **Kiedy:** w trakcie pracy nad sprintem, snapshot raz na koniec iteracji (NIE per minuta).
- **Format:** GitHub-flavored markdown z `- [ ]` / `- [x]`. Sekcje per sprint.
- **Reguła:** **persistowany snapshot z TodoWrite tool** — agent używa TodoWrite w pamięci, ale co iteracja zrzuca stan do tego pliku.

### Dokument 4: `state/retrospectives/sprint-{n}.md` — Sprint Retrospective

- **Kto:** Evaluator (po `sprint_passed` LUB po pivocie)
- **Kiedy:** po zamknięciu każdego sprintu.
- **Format:** `assets/retrospective-template.md`. Sekcje:
  - Sprint summary (cel + wynik)
  - What went well (3+ punkty)
  - What didn't (3+ punkty)
  - Lessons learned (per agent: Generator/Evaluator)
  - Pivot history (jeśli był)
  - Iterations needed (vs target)
  - Cost (czas + tokeny)
  - Action items dla następnych sprintów
- **Walidator:** sprawdza obecność po `sprint_passed` event.

### Dokument 5: `state/sessions/{YYYY-MM-DD}.md` — Daily session log

- **Kto:** auto-generated (skrypt `scripts/append-session-log.sh` wywoływany na końcu dnia LUB na końcu sesji)
- **Kiedy:** raz na dzień (cron) lub na zakończenie sesji `/goal`.
- **Format:** auto-extracted z breadcrumbs.json + git log + state/feature_list.json.
- **Reguła:** NIE pisany ręcznie. Skrypt agreguje.

### Dokument 6: `state/decision-log.md` — Decision Log

- **Kto:** dowolny agent który podejmuje **lekką** decyzję (nie wymaga ADR — np. "wybrałem nazwę funkcji `parseTilemap` zamiast `tilemapParser`")
- **Kiedy:** każda decyzja warta wzmiankowania ale za drobna na ADR.
- **Format:** append-only, GitHub-flavored:
  ```markdown
  ## 2026-05-20T16:00 — Generator: nazwa funkcji `parseTilemap`
  **Decyzja:** prefer verb-first (parseTilemap) over noun-first (tilemapParser).
  **Powód:** repo convention (sprawdzone w `grep -rE 'function parse'` zwraca 12 hits).
  **Hyrum:** brak (nowy moduł).
  ```
- **Reguła:** lekkie. ADR dla architektonicznych, decision-log dla mikro.

### Dokument 7: `state/qa-reports/sprint-{n}.md` — QA Report

- **Kto:** playwright-runner (po fazie 5 — visual regression)
- **Kiedy:** po zakończeniu wszystkich 5 faz QA dla sprintu.
- **Format:** czytelna agregacja `state/evidence/sprint-{n}/qa-summary.json` w markdown z linkami do evidence.
- **Sekcje:** Summary table (5 faz × pass/fail), Detailed findings per faza, Blocking failures, Evidence links.

### Dokument 8: `state/final-report.md` — Final Project Report

- **Kto:** Planner (lub dedykowany rola "documentarian" jeśli skonfigurowany)
- **Kiedy:** po fazie 7 (ship) — koniec projektu.
- **Format:** executive summary:
  - Project goal (z plan.md §1)
  - Sprints completed / pivoted
  - Final metrics vs Success metric
  - Architecture summary
  - Key decisions (linki do ADRów)
  - Lessons learned (agregacja z retrospectives)
  - Cost (czas + tokeny + USD jeśli mierzone)
  - Recommendations dla follow-ups
- **Output:** kopia → `docs/reports/final-{project-slug}.md` (committable).

### Dokument 9: `docs/adr/ADR-NNNN-{slug}.md` — Architecture Decision Record

- **Kto:** Generator (po każdej decyzji architektonicznej)
- **Kiedy:** wybór biblioteki, design pattern, schema DB, format protokołu, breaking change.
- **Format:** `assets/adr-template.md` (przejęty z feature-planner-v3). Sekcje:
  - Status (Accepted | Proposed | Superseded by ADR-XXXX)
  - Context
  - Decision
  - Consequences (pozytywne / negatywne / operacyjne)
  - Alternatives considered (min. 2)
  - Verification (jak sprawdzimy że decyzja działa)
  - Follow-ups (opcjonalne)
- **Numbering:** sekwencyjne (ADR-0001, ADR-0002, ...). Walidator `scripts/check-adr-numbering.sh` (opcjonalny).
- **Reguła:** Hyrum-affecting decisions = OBOWIĄZKOWO ADR.

### Dokument 10: `docs/code-reviews/CR-sprint-{n}-{slug}.md` — Five-Axis Code Review

- **Kto:** Evaluator (po `sprint_passed` LUB delegacja do feature-planner-v3 reviewer)
- **Kiedy:** po zakończeniu sprintu, **przed** fazą 7 (ship).
- **Format:** `assets/code-review-template.md` (Five-Axis Review style):
  - Change sizing (diff lines, files touched)
  - Findings per oś (Correctness, Readability, Architecture, Security, Performance)
  - Severity per finding (Critical / Optional / Nit / FYI)
  - Summary (N critical / N optional / N nit)
  - Verdict (Approve / Request changes / Block)
- **Walidator:** sprawdza obecność per sprint passed + brak Critical findings.

---

## 4. Workflow — kto pisze co i kiedy

```
Faza 1 — Planner ───────────────► state/plan.md
                            └──► state/prd/sprint-N.md (per sprint)

Faza 3 — Generator + Evaluator ── state/contracts/sprint-N.json
                                  state/decision-log.md (lekkie decyzje)

Faza 4 — Generator ─────────────► state/todo.md (snapshot per iteracja)
                            └──► docs/adr/ADR-NNNN-*.md (per decyzja arch.)

Faza 4 — playwright-runner ─────► state/qa-reports/sprint-N.md

Faza 4-end — Evaluator ─────────► state/retrospectives/sprint-N.md
                            └──► docs/code-reviews/CR-sprint-N-*.md (Five-Axis)

Faza 7 — Planner ───────────────► state/final-report.md
                            └──► docs/reports/final-*.md (kopia, committable)

Auto/cron — skrypt ────────────► state/sessions/{YYYY-MM-DD}.md
```

---

## 5. Anti-Rationalization (documentation)

| Wymówka | Riposta |
|---|---|
| „PRD to overhead dla małego sprintu" | **Odrzucono.** PRD to 8 krótkich sekcji (5-10 min pisania). Bez PRD generator implementuje wg swojej interpretacji = pętla bez progresu. |
| „ADR zapiszę później jak będzie czas" | **Odrzucono. Płot Chestertona.** ADR PISZESZ w momencie decyzji — wtedy znasz kontekst i alternatywy. Później = halucynacja własnej motywacji. |
| „TODO jest w mojej głowie, persistencja niepotrzebna" | **Odrzucono.** Pivot LUB recovery sesji = TODO z głowy jest stracone. Snapshot raz na iterację (NIE per krok). |
| „Retrospective to ceremoniał" | **Odrzucono. Calibration loop.** Bez retrospective uprząż dryfuje. To 5 punktów lessons learned, nie 30 stron. |
| „Code review już zrobił Evaluator w werdykcie" | **Odrzucono.** Werdykt = pass/fail per kryterium. Code review = analiza JAK kod jest napisany (Five-Axis). Dwie różne rzeczy. |
| „Final report nikt nie przeczyta" | **Odrzucono.** Przeczyta: następny engineer onboardujący, audyt compliance, Ty za 6 miesięcy, agent w kolejnej sesji `/goal` na tym samym projekcie. |

---

## 6. Walidator

```bash
bash scripts/verify-documentation.sh
```

Sprawdza:

- Per zakończony sprint (status: passed lub shipped w feature_list.json):
  - `state/prd/sprint-N.md` istnieje + ma 8 wymaganych sekcji.
  - `state/retrospectives/sprint-N.md` istnieje.
  - `state/qa-reports/sprint-N.md` istnieje **jeśli** playwright-runner uruchamiał.
  - `docs/code-reviews/CR-sprint-N-*.md` istnieje.
- Jeśli sprint dotknął architektury (heurystyka: zmiana publicznych API LUB nowa lib w deps):
  - Min. 1 ADR w `docs/adr/` z timestamp w zakresie sprintu.
- `state/todo.md` istnieje + jq sprawdza że jest aktualizowany (mtime po ostatnim commicie).

Exit 0 = wszystkie dokumenty obecne. Exit ≠0 = brak dokumentu → blokada fazy 6 verify.

---

## 7. Reguła: dokumentowanie NIE może być pomijane

DoD agent-teams-builder (dodane w v1.6) zawiera item:

```
- [ ] **Documentation** — scripts/verify-documentation.sh exit 0.
      Każdy passed sprint ma PRD + retrospective + code review.
      Architektoniczne decyzje mają ADR. TODO snapshot aktualny.
```

Brak dokumentu = blokada merge sprintu.

---

## 8. Mapowanie na fazy SKILL.md

| Faza | Co produkuje dokumentację |
|---|---|
| 0 bootstrap | `scripts/init-docs-structure.sh` tworzy katalogi |
| 1 Planner | `state/plan.md` + `state/prd/sprint-*.md` |
| 2 spawn | breadcrumb `role_spawned` (już istnieje) |
| 3 kontrakt | `state/decision-log.md` przy negocjacji + Generator może pisać draft ADR |
| 4 pętla | TODO snapshot per iteracja + ADR per decyzja + QA report od playwright-runner |
| 5 pivot | retrospective extra "pivot section" + ADR opisujący POWÓD pivota |
| 6 verify | `verify-documentation.sh` + code review (Five-Axis) per sprint |
| 7 ship | final-report.md + kopia do docs/reports/ |

---

## 9. Setup w projekcie

```bash
# Init struktury katalogów (idempotent)
bash scripts/init-docs-structure.sh

# Sprawdzenie
ls state/{prd,retrospectives,sessions,qa-reports}
ls docs/{adr,code-reviews,reports}
```

Skrypt `init-docs-structure.sh` tworzy katalogi + dopisuje sensible `.gitignore` (state/* w gitignore, docs/* committable).

---

## 10. Exit criterion

Faza 6 (verify) przechodzi tylko gdy:

```bash
scripts/verify-documentation.sh && \
scripts/verify-plan-rigor.sh && \
scripts/verify-non-negotiables.sh && \
scripts/verify-library-currency.sh --all-sprints
# All exit 0
```

Wszystkie 4 zielone → faza 7 (ship) odblokowana.
