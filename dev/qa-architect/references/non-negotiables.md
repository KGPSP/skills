---
name: non-negotiables
type: reference
parent: qa-architect
sources:
  - DOC/material_skill.md §8 (5 Non-negotiables)
  - DOC/since_skill.md §6 (Anti-Laziness), §7 (Plan-Validate-Execute)
  - DOC/QA-swarm.md §6.3 (kontrakt), §12.5 (checklisty)
description: Pięć zasad nienegocjowalnych dla qa-architect + protokół Fragile Operations dla auto-patchu CLAUDE.md/.github/workflows/. Każda zasada zmapowana na konkretną fazę z exit criterion.
---

# Non-negotiables qa-architect

> [!important] Zasada nadrzędna
> Naruszenie któregokolwiek z tych 5 punktów = **STOP**, eskalacja do usera, nie continue. Skill `qa-architect` z definicji dotyka kontraktu repozytorium (`CLAUDE.md`, `AGENTS.md`, `.github/workflows/`) — błąd tu kosztuje cały zespół.

---

## #1 — Uwidaczniaj założenia przed projektowaniem

**Egzekwowane w:**
- Phase 0 — output `detect-stack.sh` może mieć `stack: unknown` → STOP, eskaluj. Nie zgaduj.
- Phase 2 — każda decyzja narzędziowa w `02-tooling.md` ma sekcję `Assumptions:` (np. „zakładam npm jako PM, bo `package-lock.json` istnieje").
- Phase 6 — `CLAUDE.md.patch` zawiera komentarz `# Assumes existing CLAUDE.md uses Markdown frontmatter convention.`

**Anti-pattern:** „Zakładam że team używa Vitest bo to popularne" — bez evidence w `package.json` to zgadywanie.

---

## #2 — Zatrzymaj się przy konflikcie wymagań

**Egzekwowane w:**
- Phase 2 — jeśli user wprost prosi o Cypress jako default e2e dla greenfield, a paper §7.2 rekomenduje Playwright → **eskaluj**, pokaż obie ścieżki + uzasadnienie obu, czekaj na decyzję.
- Phase 4 — jeśli `04-swarm-plan.md` ma zadania konfliktujące o własność plików → STOP, Manager musi przebudować plan.
- Phase 7 — jeśli reviewer wykryje Critical (np. config-builder wyprodukował `jest.config` ale stack to Python) → STOP, nie próbuj naprawić w pętli.

**Anti-pattern:** „Wybieram interpretację najbardziej sensowną" — improwizacja = niespójny blueprint.

---

## #3 — Wybieraj rozwiązania nudne i oczywiste

**Egzekwowane w:**
- Phase 2 — `tooling-decisor` preferuje stack-default (next/jest dla Next.js, pytest dla Python) nad „custom harness".
- Phase 5 — `config-builder` używa **templates** z `templates/configs/<stack>/`, nie pisze od zera.
- Phase 7 — Five-Axis Review oś **Readability**: jeśli config ma >150 linii dla małego stacku = porażka.

**Anti-pattern:** Custom plugin Jest, „własny runner z perf hookami", abstrakcyjna fabryka config-buildera „na przyszłość".

---

## #4 — Dostarczaj twardy dowód, nie deklarację

**Egzekwowane w:**
- Phase 7 — `check-blueprint-complete.sh` MUSI być uruchomiony, raw output wklejony do `07-verification.md`. Bez tego DoD niespełnione.
- Phase 7 — `verify-postgres-strategy.sh` MUSI być uruchomiony — exit 0 znaczy brak mocków `pg`.
- Phase 8 — `HANDOFF.md` zawiera linki do raw artefaktów (nie parafrazy).

**Format akceptowalny:**

| Typ | Format |
|---|---|
| Stack detection | Raw JSON z `detect-stack.sh` (exit 0) |
| Blueprint completeness | Raw output `check-blueprint-complete.sh` (exit 0, pełna lista plików) |
| Anti-mock check | Raw output `verify-postgres-strategy.sh` (exit 0, lista skanu) |
| Review verdict | `07-review.md` z `## Verdict: PASS\| FAIL` |

**Anti-pattern:** „Blueprint kompletny" (parafraza), „configi wyglądają OK" (subiektywne).

---

## #5 — Dotykaj tylko tego, o co cię poproszono

**Egzekwowane w:**
- **Cały skill domyślnie nie modyfikuje istniejącego repo.** Output trafia do `qa-blueprint/` (osobny katalog).
- Patch `CLAUDE.md` = osobny plik `qa-blueprint/CLAUDE.md.patch`, **nie** auto-mergowany.
- Patch `.github/workflows/` = pliki w `qa-blueprint/ci/`, **nie** kopiowane do `.github/workflows/` bez explicite zgody (APPROVAL #2).
- Phase 5 — każdy sub-agent ma w prompcie constraint własności plików. `config-builder` modyfikuje TYLKO `qa-blueprint/configs/`.

**Anti-pattern:** „Skoro już generuję configi, przy okazji posprzątam istniejący jest.config" — to nie ten skill, to nie ten task.

---

## Fragile Operations Protocol (Plan-Validate-Execute)

> [!warning] Kiedy aktywuje się PVE
> Tylko w Phase 8 — gdy user **explicite zaakceptuje** auto-patch `CLAUDE.md` (APPROVAL #2 z opcją „patch teraz"). Wszystkie inne operacje są w strefie wolnej (`qa-blueprint/` to katalog osobny).

**Plan:**
1. Wygeneruj **diff** istniejącego `CLAUDE.md` vs `CLAUDE.md + qa-blueprint/CLAUDE.md.patch`.
2. Wklej diff do raportu Phase 8.

**Validate:**
3. Sprawdź czy istniejący `CLAUDE.md` ma już sekcję QA (grep `## QA\|## Test` w istniejącym pliku) — jeśli tak, eskaluj („sekcja QA już istnieje, mam **zastąpić** czy **uzupełnić**?").
4. Sprawdź czy patch nie zawiera ścieżek absolutnych `/Users/` (Scope Discipline #5 wzmocnione przez `since_skill.md §6`).

**Execute:**
5. Tylko po explicite „tak" — append/replace zgodnie z decyzją usera.
6. Commit zostaje **nie zrobiony automatycznie** — wymaga osobnego `git commit` od usera (CLAUDE.md repo-rule: „Commit/push tylko na wyraźne żądanie").

**Hard rollback:** jeśli cokolwiek pójdzie nie tak — `git checkout HEAD -- CLAUDE.md` i raport błędu.

---

## Egzekwowanie globalne

| Faza | Non-negotiables aktywne |
|---|---|
| Phase 0 | #1 (assumptions Phase 0), #2 (stack unknown) |
| Phase 1 | #1 (gap matrix bez halucynacji) |
| Phase 2 | #1, #2 (konflikty Vitest/Jest/Playwright/Cypress), #3 (boring preferred) |
| Phase 3 | #3 (piramida boring) |
| Phase 4 | #1, #2 (konflikty plików), #5 (scope per sub-agent) |
| Phase 5 | #5 (sub-agenty trzymają się własności plików) |
| Phase 6 | #5 (CLAUDE.md.patch jako patch, nie auto-merge) |
| Phase 7 | #4 (raw artefakty), #2 (Critical → STOP) |
| Phase 8 | wszystkie 5, Fragile Ops dla auto-patchu |

---

## Wzorzec eskalacji (gdy naruszenie)

```
1. STOP — nie kontynuuj fazy.
2. Identyfikuj naruszone #X.
3. Cytuj zasadę w raporcie fazy.
4. Eskaluj do usera z 2-3 propozycjami rozwiązań.
5. Czekaj na decyzję — brak improwizacji.
```

Brak akceptacji → rollback fazy, restart od Phase 0 lub od ostatniego zatwierdzonego checkpointu.
