---
name: hypothesis-eval-protocol
description: Niezależna read-only ocena ≥3 hipotez z Phase 2 przez odrębny subagent. Rubryka binarna (passed:true/false, ZAKAZ skal 1-10), framing adwersarialny, blind input. Wywoływany w Phase 2.5 (M/L); zasila Phase 3 notą Reconciliation przy rozbieżności.
type: reference
parent: audited-feature-workflow
source: 'Generator-Evaluator pattern (agent-teams-builder, swarm-orchestrator); v3.5 dodatek'
---

# Hypothesis Evaluation Protocol — independent read-only judge

> [!important] Cel pliku
> Phase 2 generuje 3 hipotezy, Phase 3 wybiera jedną — ale gdy robi to **ten sam agent**, wybór jest *self-justification*: generator nieświadomie ustawia hipotezy tak, by „wygrała" ta, którą i tak wolał, a potem sam siebie uzasadnia. Ten protokół wstawia **niezależnego read-only sędziego** między generację a wybór. To Generator-Evaluator na poziomie *projektowania* — analog Multi-Model Review dla kodu w Phase 8.

## Kiedy

- **Size M/L** — aktywne. **Size S** — pomiń (trywialna zmiana nie potrzebuje sędziego; overkill).
- Po Phase 2 (3 hipotezy gotowe), **przed** Phase 3 (recommendation).

## Jak odpalić

Jeden **read-only subagent** przez tool `Agent`:

- **Typ:** `evaluator` (binary criteria + read-only z definicji — pierwszy wybór) lub `Explore` (fallback gdy evaluator niedostępny; gwarantuje brak Edit/Write).
- **Read-only twardo:** subagent NIE ma `Edit`/`Write`, nie dotyka repo, nie implementuje. Tylko czyta i sądzi. To cała siła pomysłu — sędzia, który nie może „naprawić", musi *ocenić*.

## Blind input (krytyczne dla niezależności)

Przekaż subagentowi:

- 3 hipotezy z Phase 2 (Minimal / Idiomatic / Ambitious) z trade-offami, ryzykiem, kosztem, Hyrum risk.
- `analysis/<plan-id>.md` (PRIMARY TEMPLATE, konwencje, Hyrum impact, Chesterton candidates).
- Read-only dostęp do repo (weryfikacja claimów repo-fit / blast radius).

> [!danger] NIE przekazuj preferencji generatora
> Jeśli subagent dowie się, którą hipotezę generator woli, zakotwiczy się na cudzym wyborze i ocena przestaje być niezależna. Wejście jest **blind** — same hipotezy, bez wskazówki kto faworyt.

## Rubryka — binarna (ZAKAZ skal 1-10)

Per hipoteza, każde kryterium `passed: true/false` + jednozdaniowe uzasadnienie:

| Kryterium | Pytanie kontrolne |
|---|---|
| **5 Non-negotiables** | Czy hipoteza nie łamie żadnej z 5 zasad master? |
| **Hyrum / Chesterton** | Blast radius na publiczne API? Usuwa kod bez „why-this-existed"? |
| **Repo-fit** | Zgodna z PRIMARY TEMPLATE i konwencjami z Phase 1? |
| **Odwracalność** | Koszt rollbacku akceptowalny (szczególnie fragile zone)? |
| **Beyoncé 1:1** | Każde przyszłe AC da się pokryć testem? |

Binarność wymusza twardą decyzję zamiast rozmytego „ujdzie, 7/10". Hipoteza z choć jednym `false` na krytycznym kryterium → oznaczona jako ryzykowna w rankingu (z podaniem którego).

## Framing adwersarialny

Dla **każdej** hipotezy subagent znajduje jej **najsłabszy punkt** (refute-by-default) — nie chwali. Pytanie sterujące: *„gdyby ta hipoteza miała zawieść w produkcji, to przez co?"*. To samo nastawienie co adwersarialna weryfikacja findingów w Phase 8 — sędzia szuka dziury, nie aprobaty.

## Output (dowód)

`analysis/<plan-id>-hypotheses-eval.md`:

1. **Ranking** 3 hipotez z uzasadnieniem kolejności.
2. **Rubryka binarna** per hipoteza (tabela passed/false + jednozdaniowe uzasadnienia).
3. **Najsłabszy punkt** każdej hipotezy.

To **surowy output subagenta** — Phase 3 go cytuje/wkleja, **nie parafrazuje** (Anti-Rat #4: deklaracja = halucynacja dopóki niepodparta artefaktem). Niezależny artefakt jest twardszym dowodem dla APPROVAL #1 niż self-justification generatora.

## Zasilanie Phase 3 — doradcze + Reconciliation

Ocena jest **doradcza**, nie twarda bramka — **human ma ostatnie słowo** (APPROVAL #1):

- Wybór generatora **= top ranking** evaluatora → potwierdź, kontynuuj Phase 3.
- Wybór generatora **≠ top ranking** → **obowiązkowa nota „Reconciliation"** w Phase 3: dlaczego mimo niższej oceny evaluatora wybierasz tę hipotezę. Rozbieżność eskaluje do human przy APPROVAL #1 — on rozstrzyga.

> [!note] Rozbieżność to sygnał, nie błąd
> Gdy generator i evaluator się różnią, to najcenniejszy moment całej fazy — ujawnia ukryte założenie po jednej ze stron. **Nigdy nie ukrywaj rozbieżności** cichym dopasowaniem wyboru do rankingu (to byłby teatr). Ujawnij ją i pozwól człowiekowi rozstrzygnąć.

## Anty-wzorzec — „ewaluacja-teatr"

Krok, który *czuje się* rygorystyczny, ale produkuje potakujący output, jest **gorszy** niż jego brak — daje fałszywą pewność. Cztery zabezpieczenia przed teatrem (wszystkie obowiązkowe): rubryka binarna · framing adwersarialny · blind input · jawna nota rozbieżności. Bez któregokolwiek — Phase 2.5 nie spełnia celu.

## Sources

- Generator-Evaluator: `dev/agent-teams-builder/`, `dev/swarm-orchestrator/` (Planner+Generator+Evaluator, kontrakty, binary verdict).
- [analysis-protocol.md](analysis-protocol.md) — Phase 1 outputy będące wejściem oceny (PRIMARY TEMPLATE, Hyrum, Chesterton).
- [five-axis-review.md](five-axis-review.md) — adwersarialna weryfikacja na poziomie kodu (Phase 8); Phase 2.5 to jej odpowiednik na poziomie projektu.
- [dynamic-workflows-standard.md](dynamic-workflows-standard.md) — wariant L/ultracode mógłby użyć Workflow judge-panel (3 soczewki) zamiast 1 evaluatora; wybrano prostszy wariant single-evaluator.
