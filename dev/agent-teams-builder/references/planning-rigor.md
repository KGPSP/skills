---
title: Planning Rigor — hipotezy, rekomendacje, Hyrum impact, rollback (dziedziczone z feature-planner-v3)
load-when: "Faza 1 SKILL.md (Planner) — ZAWSZE. Plus odświeżenie przy każdej amendment do state/plan.md."
source:
  - dev/feature-planner-v3/SKILL.md §Phase 2-4 (hipotezy + rekomendacje + plan output)
  - dev/feature-planner-v3/references/ac-protocol.md (AC structure)
  - dev/feature-planner-v3/references/five-axis-review.md
  - DOC/material_skill.md §5 (Prawo Hyruma, Płot Chestertona)
  - DOC/since_skill.md §6 (Grounding in real expertise)
---

# Planning Rigor — dziedziczone z feature-planner-v3

> **Cel:** transferować dyscyplinę planistyczną Senior Engineera z `feature-planner-v3` (1 feature, 1 sesja) do `agent-teams-builder` (zespół, N sprintów). Planner przestaje być "generatorem listy sprintów" — staje się architektem **uzasadnionych** wyborów z wyraźnym audit trail.

---

## 1. Trzy hipotezy per sprint (Minimal / Idiomatic / Ambitious)

Planner **dla każdego sprintu** generuje **minimum 3 hipotezy** podejścia. Bez tego — wybór architektury jest niejawny, rozmyty, niemożliwy do audytu.

### Format

```markdown
### Sprint 2 — Editor canvas

**Goal (business):** User rysuje poziom przez drag-drop kafelków na siatce 32x18.

**Hipotezy podejścia (3 wymagane):**

| # | Nazwa | Opis | Trade-offs | Hyrum risk | Koszt (h) |
|---|---|---|---|---|---|
| H1 | **Minimal** | Canvas 2D z manualnym `mousedown`/`mousemove`/`mouseup` | Pełna kontrola, brak deps. **Con:** ręczna obsługa touch, brak undo. | brak (nowy moduł) | 6h |
| H2 | **Idiomatic** | `react-dnd` + custom backend HTML5 | Konwencja, accessibility OK, undo darmowy. **Con:** +50KB bundle, learning curve. | brak | 10h |
| H3 | **Ambitious** | Phaser 3 Scene + InputPlugin | Native game engine, future-proof dla physics. **Con:** ciężki Phaser (300KB), nadmiarowy na MVP. | **średni** — jeśli wybierzemy później, refactor 4 sprintów | 16h |

**Wybór:** H2 (Idiomatic).

**Uzasadnienie wg 5 Non-negotiables:**
- **#1 Założenia:** zakładam że accessibility jest wymagane (potwierdzone w Open Questions Q3).
- **#3 Nudne rozwiązania:** react-dnd jest standardem branżowym (3M downloads/week na npm).
- Hyrum: nowa funkcja, brak istniejących consumerów.

**Odrzucone:** H1 (brak undo to dług), H3 (overkill dla MVP). H3 zachowane jako "Future consideration" w `state/plan.md → Ryzyka`.
```

### Reguły

- **Minimum 3 hipotezy.** 2 = brak rzeczywistego wyboru, model nie był wymuszony do myślenia.
- **Wybór JEDNEJ** + jawne uzasadnienie + lista odrzuconych.
- **Hyrum risk per hipoteza:** czy zmiana wpłynie na publiczne API / consumers?
- Hipotezy w `state/plan.md` per sprint (NIE w kontrakcie sprintu — to robota Generatora w fazie 3 negocjacji).

---

## 2. Plan output — 10 sekcji (rozszerzenie z 6 obecnych)

Plan `state/plan.md` musi mieć (zaktualizowany szablon w `assets/plan-template.md`):

| # | Sekcja | Co zawiera | Status v1.4 → v1.5 |
|---|---|---|---|
| 1 | **Goal (business)** | Jednolinijkowy cel | ✅ było |
| 2 | **Sprints** | 3-15 sprintów + per sprint 3 hipotezy + wybór | ⚠️ ROZSZERZONE — dodać hipotezy |
| 3 | **Dependencies** | Biblioteki + wersje weryfikowane przez context7 | ✅ było |
| 4 | **Open Questions** | Niewiadome do eskalacji | ✅ było |
| 5 | **Out of scope** | Cała sesja | ✅ było |
| 6 | **Success metric** | Definicja zakończenia | ✅ było |
| 7 | **Ryzyka** | Klasyfikacja H/M/L + mitigation | ⚠️ ROZSZERZONE — skalowanie i mitigation |
| 8 | **Recommendation summary** | Top-level rekomendacja arch. + dlaczego | 🆕 NOWA |
| 9 | **Hyrum Impact** | Lista publicznych API sprawdzanych w sprintach | 🆕 NOWA |
| 10 | **Rollback plan** | Per sprint: jak cofnąć jeśli pivot lub regresja | 🆕 NOWA |
| 11 | **Alternatives considered** | Top-level odrzucone podejścia (architecture, biblioteki) | 🆕 NOWA |

---

## 3. Acceptance Criteria z priorytetami (przejęte z ac-protocol.md)

**Każde** kryterium w kontrakcie sprintu (`state/contracts/sprint-{n}.json`) dostaje pole `priority`:

| Priorytet | Co znaczy | Co blokuje |
|---|---|---|
| **MUST** | Krytyczne — bez tego sprint = fail | Merge sprintu |
| **SHOULD** | Ważne — pominięcie wymaga ADR | Bez ADR — merge zablokowany |
| **COULD** | Nice-to-have — może iść do backlog | Nic, ale ślad w `state/feature_list.json` |

### Format AC (3 typy z ac-protocol.md)

```json
{
  "id": "C-01",
  "type": "AC-F",
  "priority": "MUST",
  "binary": true,
  "given": "User na stronie /editor z pustym canvas",
  "when": "User wciska strzałkę w prawo",
  "then": "Kursor przesuwa się o 1 kafel (32px)",
  "evidence_type": "playwright_screenshot",
  "verified_by": "tests/editor/keyboard.spec.ts::cursor moves right"
}
```

3 typy:
- **AC-F (Functional)** — Given/When/Then + verified_by.
- **AC-T (Technical)** — stwierdzenie + plik:linia (np. "Module `EditorStore` ma metody `addTile`/`removeTile`/`undo` w `src/editor/store.ts`").
- **AC-N (Non-functional)** — target liczbowy + measurement (np. "TTI < 1500ms, mierzony przez Performance API w faza 3").

---

## 4. Hyrum Impact — kiedy obowiązkowy

Sekcja `Hyrum Impact` w `state/plan.md` **wymagana** gdy którykolwiek sprint:

- Modyfikuje publiczne API (eksportowane funkcje, klasy, endpointy REST/GraphQL).
- Zmienia sygnaturę istniejącego helpera używanego w >1 miejscu (`grep -rn 'fnName('` zwraca >1).
- Modyfikuje schema DB / migrację.
- Aktualizuje wersję krytycznej dep (`react 18 → 19`).

### Format

```markdown
## Hyrum Impact (sprawdzone PRZED akceptacją planu)

| Sprint | Co zmienia | Consumers | Klasyfikacja | Mitigation |
|---|---|---|---|---|
| 2 | API `/api/v1/levels` → `/api/v2/levels` (zmiana schema) | 1 (frontend editor) | **Breaking** | Migracja frontend w tym samym sprincie; backward-compat alias przez 1 release |
| 4 | Sygnatura `parseTilemap()` zyskuje opcjonalny argument | 3 testy + Play scene | **Additive** | Domyślna wartość = obecne zachowanie; testy regresyjne |
| 5 | Nowy moduł `EditorStore`, brak istniejących użyć | 0 | **Internal** | n/a |

**Klasyfikacja:**
- **Breaking** — wymaga migracji consumerów w tym samym sprincie LUB osobny sprint migracji
- **Additive** — domyślne wartości / nakładki kompatybilne
- **Internal** — nowy kod, brak zewnętrznych użyć
```

---

## 5. Rollback plan — per sprint

Każdy sprint w `state/plan.md` ma 1-linijkową strategię rollback:

```markdown
### Sprint 2 — Editor canvas

**Goal:** ...

**Rollback:** Jeśli sprint pivot LUB regresja: `git revert {sprint-hash}` — komponent `EditorCanvas`
jest izolowany (feature flag `ENABLE_EDITOR_V2`), wyłączenie flagi przywraca poprzednią
wersję bez utraty danych użytkownika. Branch archiwizacyjny: `archive/sprint-2-pivot-{ts}`.
```

Dla destruktywnych (DB migrations, breaking API):

```markdown
**Rollback:** Migracja DB ma odpowiadającą `down()` w `migrations/0042.ts`. Schema-compat
window: 1 release (rollback możliwy do release v0.5.x). Po v0.6.0 — rollback wymaga
restore z snapshot.
```

---

## 6. Alternatives considered — top-level

Po wszystkich sprintach planu Planner zapisuje **odrzucone podejścia architektoniczne**:

```markdown
## Alternatives considered (top-level)

| Alternatywa | Dlaczego odrzucona | Triggered re-consideration? |
|---|---|---|
| **Monolit React + WebGL przez Three.js** | Wymaga 3D, projekt jest 2D. Bundle +800KB. | NIE |
| **PWA z offline storage przez IndexedDB** | Out of scope (Sprint 0: desktop-only). | TAK — po MVP, sprint future "PWA mode" |
| **Server-side rendering (Next.js)** | Editor wymaga ciężkiego runtime JS, SSR nie pomaga. | NIE |

**Reguła:** minimum 2 odrzucone alternatywy top-level. Brak = Planner nie pomyślał o szerszej przestrzeni rozwiązań.
```

---

## 7. Walidator — verify-plan-rigor.sh

```bash
bash scripts/verify-plan-rigor.sh
# Sprawdza state/plan.md:
#   - Sekcja "Sprints" zawiera 3+ hipotez per sprint (heurystyka: 3+ wierszy w tabeli Hipotezy)
#   - Sekcja "Recommendation summary" istnieje + niepusta
#   - Sekcja "Hyrum Impact" istnieje (warning jeśli pusta, error jeśli brak)
#   - Sekcja "Rollback plan" per sprint
#   - Sekcja "Alternatives considered" z min. 2 wpisami
#   - "Open Questions" niepuste LUB świadoma deklaracja "no open questions"
```

Exit 0 → plan akceptowalny. Exit ≠0 → Planner musi uzupełnić.

---

## 8. Anti-Rationalization (planning)

| Wymówka | Riposta |
|---|---|
| „Wystarczy jedna hipoteza, ta jest oczywista" | **Odrzucono.** Bez 3 alternatyw nie ma rzeczywistego wyboru. Brak udokumentowanych alternatyw = niemożliwy audit decyzji. |
| „Rollback to zmartwienie później, na razie buduję" | **Odrzucono.** Sprint bez rollback strategy = sprint który nie może być cofnięty bez data loss. To dług operacyjny. |
| „Hyrum Impact zaktualizuję jak będzie potrzebne" | **Odrzucono.** Hyrum wykrywa się PRZED implementacją, nie po regresji. Wymóg sekcji w planie. |
| „Alternatives considered to academic exercise" | **Odrzucono.** Brak alternatyw = halucynacja że wybór był jedyny. Minimum 2 odrzucone na top-level. |

---

## 9. Exit criterion fazy 1

Planner zamyka fazę 1 tylko gdy:

```bash
bash scripts/verify-plan-rigor.sh   # exit 0
bash scripts/verify-non-negotiables.sh   # exit 0
```

Dopiero wtedy parent agent może wejść w fazę 2 (spawn ról).

---

## 10. Mapowanie do plan-template.md

`assets/plan-template.md` zaktualizowane — zawiera szkielet wszystkich 11 sekcji + komentarze HTML wskazujące Plannerowi co wpisać. Patrz `assets/plan-template.md`.
