---
name: non-negotiables
type: reference
parent: audited-feature-workflow
source: DOC/material_skill.md §8
description: Siedem zasad nienegocjowalnych dla agenta v3. Pięć rdzennych z material_skill.md §8 + dwie specyficzne dla v3 (Verification with raw artifacts, Anti-Laziness w bramkach). Każda zasada egzekwowana w konkretnych fazach.
---

# 7 Non-negotiables (master reference)

> [!important] Zasada nadrzędna
> Te 7 punktów to **imperatyw** dla każdego uruchomienia v3. Naruszenie któregokolwiek = STOP, eskalacja do użytkownika, nie continue.

---

## #1 — Uwidaczniaj założenia przed budowaniem

> [!quote] material_skill.md §8
> Każde ciche założenie musi być zgłoszone. Praca przy niejasnych wymaganiach jest zabroniona.

**Jak egzekwowane w v3:**

- Phase 4 (plan): sekcja `Assumptions` obowiązkowa, jawnie wymienia wszystkie założenia.
- Phase 5 (approval gate): brak `Assumptions` w planie = blokada.
- Phase 6 (per slice): nowo wykryte założenia → wstrzymaj, dopisz do planu, eskaluj.

**Anti-pattern:** „Zakładam że <X> bo to standardowe" — żadne założenie nie jest „standardowe" bez explicit deklaracji.

---

## #2 — Zatrzymaj się przy konflikcie wymagań

> [!quote] material_skill.md §8
> Zakaz zgadywania intencji. Konflikt to sygnał do przerwania pracy i eskalacji do człowieka.

**Jak egzekwowane w v3:**

- Phase 1 (analysis): konflikt między PRIMARY TEMPLATE a wymaganiem usera → STOP.
- Phase 2 (hipotezy): jeśli żadna hipoteza nie pokrywa wszystkich AC bez konfliktu → STOP, zapytaj.
- Phase 6 (implementation): konflikt napotkany w runtime (np. test contradiction) → STOP.

**Anti-pattern:** „Wybiorę interpretację najbardziej sensowną" — improwizacja = bug w produkcji.

---

## #3 — Wybieraj rozwiązania nudne i oczywiste

> [!quote] material_skill.md §8 — Cleverness is expensive
> Kod ma być czytelny dla najsłabszego ogniwa w zespole.

**Jak egzekwowane w v3:**

- Phase 2 (hipotezy): hipoteza **Idiomatic** preferowana domyślnie nad **Ambitious**.
- Phase 3 (recommendation): jeśli wybierasz **Ambitious** — wymagane uzasadnienie + Hyrum Risk analiza.
- Phase 8 (Five-Axis Review): oś **Readability & Simplicity** — *„1000 linii vs 100 linii dające ten sam efekt = porażka"*.

**Anti-pattern:** Generic types z 4 parametrami, abstrakcyjne fabryki, „przygotowane na przyszłość" rozwiązania bez konkretnego use case.

---

## #4 — Dostarczaj twardy dowód, nie deklarację

> [!quote] material_skill.md §8 — Verification is non-negotiable
> Każdy status „done" musi być podparty logiem, wynikiem testu lub zrzutem ekranu.

**Jak egzekwowane w v3:**

- Phase 5 (approval gate): DoD per AC w planie wymaga formatu dowodu.
- Phase 7 (test gate): `sh scripts/extract-raw-log.sh` — wklejony **surowy** output, nie parafraza.
- Phase 7.8 (live preview): screenshot per AC-F dla M+ UI.
- Phase 8 (review): raw evidence w PR description.

**Akceptowalne dowody:**

| Typ | Format |
|---|---|
| Build clean | Exit code 0 + grep brak `warning\|warn\|deprecated\|⚠` |
| Test pass | Raw output: `Tests: X passed, 0 failed` |
| Runtime | Trace ścieżki krytycznej (curl + endpoint response) |
| UI | Screenshot per AC-F |
| Security | Scan output (npm audit / cargo audit / safety) |

**Anti-pattern:** „Testy przeszły" (parafraza), „wydaje się że działa" (subiektywna deklaracja), „kod jest poprawny zgodnie z analizą" (LLM judgment).

Pełen protokół: [dod-evidence-protocol.md](dod-evidence-protocol.md).

---

## #5 — Dotykaj tylko tego, o co cię poproszono

> [!quote] material_skill.md §8 — Scope Discipline
> Jedyny gwarant mergowalnych Pull Requestów.

**Jak egzekwowane w v3:**

- Phase 4 (plan): sekcja `Out of scope` obowiązkowa.
- Phase 6 (per commit): `sh scripts/check-pr-size.sh` po każdym commit.
- Phase 8 (review): Chesterton check dla każdej deleted line. Wykryty out-of-scope refactor → cofnij + zgłoś jako osobny task w `out-of-scope.md`.

**Anti-pattern:** „Przy okazji posprzątałem style w sąsiednim pliku" — to nie ten PR.

---

## #6 — Verification with raw artifacts (specyficzne dla v3)

**Powód dodania w v3:** v2 wymagał DoD ale akceptował parafrazy. v3 wymusza **surowe artefakty**.

**Jak egzekwowane:**

- Phase 7: raw log z konsoli (komenda `extract-raw-log.sh`), nie streszczenie.
- Phase 8: Multi-Model Review (opcjonalny) — drugi agent (codex-rescue) waliduje artefakty.
- Phase 9: ADR zawiera linki do raw artefaktów (commitowane wraz z planem).

**Format akceptowalny:**

```log
$ pnpm test src/health.test.ts
PASS src/health.test.ts
  ✓ returns 200 OK (12ms)
  ✓ returns content-type application/json (3ms)
  ✓ returns body { status: "ok" } (4ms)

Tests:       3 passed, 3 total
Suites:      1 passed, 1 total
Time:        0.847 s
```

Wklejony **dosłownie** do PR description, bez modyfikacji.

---

## #7 — Anti-Laziness w bramkach (specyficzne dla v3)

> [!quote] since_skill.md §6
> Najwyższa waga jakości. **Nie optymalizuj pod szybkość implementacji wykonawczej.**

**Powód dodania w v3:** Anthropic guidance zauważył systemową tendencję LLM do *Agent Laziness* — pomijania bramek dla speedu. v3 dodaje twardą deklarację w każdej bramce.

**Jak egzekwowane:**

- Phase 5: approval gate wymaga **explicit** zgody usera, nie auto-proceed.
- Phase 7: brak skrótu „testy szybkie, pomijam build clean".
- Phase 8: Five-Axis Review nie pomijany dla małych PR.
- Każda iteracja ralph-loop: anti-rationalization quick-table przechodzona **explicite**, nie deklaratywnie.

**Anti-pattern:** „Pominę krok X dla efektywności" — krok X istnieje dlatego, że bez niego są incydenty.

---

## Egzekwowanie globalne

| Faza | Non-negotiables aktywne |
|---|---|
| **Phase 0** | #2 (detekcja konfliktu trigger / scope) |
| **Phase 1** | #2 (konflikt PRIMARY TEMPLATE), #5 (scope analysis) |
| **Phase 2-3** | #1 (assumptions), #3 (boring preferred) |
| **Phase 4** | #1, #5 (plan structure), #4 (DoD evidence format) |
| **Phase 5** | #1, #4, #7 (gate enforcement) |
| **Phase 6** | #4, #5, #7 (per commit) |
| **Phase 7** | #4, #6 (raw artifacts), #7 |
| **Phase 8** | wszystkie 7 (final audit) |
| **Phase 9** | #4 (artifacts in ADR), #5 (scope discipline log) |

---

## Wzorzec eskalacji (gdy non-negotiable narusza)

```
1. STOP — nie kontynuuj fazy.
2. Identyfikuj naruszone #X.
3. Cytuj zasadę w PR description / Phase output.
4. Eskaluj do użytkownika z propozycją 2-3 rozwiązań.
5. Czekaj na decyzję — żadna improwizacja.
```

Brak akceptacji → rollback fazy, restart od ostatniego zatwierdzonego checkpointu.
