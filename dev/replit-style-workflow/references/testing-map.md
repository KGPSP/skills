---
name: testing-map
type: reference
parent: replit-style-workflow
sources:
  - DOC/material_skill.md §4 — Definition of Done (dowód zamiast deklaracji)
  - DOC/material_skill.md §5 — Beyoncé Rule, DAMP over DRY, piramida 80/15/5
  - DOC/since_skill.md §5 — TDD RED-GREEN-REFACTOR + Prove-It Pattern (regresja)
  - DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §9 — Checklist gotowości
description: Mapa testów (unit / integration / regression) dla skilla replit-style-workflow (historycznie feature-planner-v2). Skill jest prose-heavy i NIE ma własnych skryptów-bramek — mapa dokumentuje ten stan i wymusza dyscyplinę „każda nowa funkcjonalność = nowy skrypt walidatora + meta-test".
---

# Test Discipline — replit-style-workflow (historycznie feature-planner-v2)

> **Zakres:** meta-testy skryptów-bramek **samego skilla** v2.
> **NIE w zakresie:** testy aplikacji, którą skill buduje (Phase 7 — 7 scopes × S/M/L, patrz [`testing-protocol.md`](testing-protocol.md)).
>
> **Krytyczna informacja:** v2 NIE MA katalogu `scripts/` ani `tests/`. Cały rygor jest zawarty w prozie `SKILL.md` (2229 linii). Ten plik dokumentuje stan i wymusza retrofitting przy każdej nowej funkcjonalności.

## Pryncypium (source: DOC/material_skill.md §5, DOC/since_skill.md §5)

> **Beyoncé Rule** — *„If you liked it, you should have put a test on it"*. **W v2 nie da się jej obecnie egzekwować na poziomie meta-testów** (brak skryptów do testowania), ale OBOWIĄZUJE od momentu dodania pierwszego skryptu walidującego.
> **Piramida 80/15/5** — 80% unit / 15% integration / 5% E2E. Aktualnie v2: 0/0/0.
> **TDD RED-GREEN-REFACTOR** — failing fixture + assert_exit PRZED implementacją (gdy retrofittujesz pierwszy skrypt).
> **Prove-It Pattern (= test regresji)** — każdy bug w prozie SKILL.md, który **da się** wykryć deterministycznie → utwórz skrypt + regression fixture.
> **Konsekwencja stanu obecnego:** każde naruszenie procedury v2 w realnym workflow jest niewykrywalne automatycznie — wykrywa się dopiero w retrospective albo w PR review.

## Definicje (w kontekście v2)

| Typ | Definicja | Stan v2 | Plan retrofittingu |
|---|---|---|---|
| **Unit** | Jeden walidator vs jedna fixture (jak w a-t-b / v3) | ❌ Brak — v2 nie ma `scripts/` ani `tests/` | Przy pierwszym walidatorze: utwórz `tests/run-meta-tests.sh` (wzorzec a-t-b) |
| **Integration** | Chain ≥2 walidatorów / faz | ❌ | Po unitach |
| **Regression** | Fixture odtwarzająca bug walidatora | ❌ | Wymagane od pierwszego buga w retrofitted skrypcie |

## Mapa „funkcjonalność v2 → potencjalny test"

> Pokazuje co BY musiało mieć test, gdyby v2 było retrofitted. **Wszystko Status ❌.**

| Funkcjonalność SKILL.md v2 | Linie | Co dałoby się przetestować deterministycznie | Sugerowany skrypt + fixture |
|---|---|---|---|
| PHASE 0 — Plan Numbering & Env Detection | 31-183 | Numerowanie planu (kolejność `docs/plany/NNN-*.md`), stack detection | `check-plan-numbering.sh` + fixtures z gappy/non-gappy plan series |
| PHASE 1 — Deep Analysis | 184-321 | Czy `state/analysis.md` ma 8 wymaganych sekcji (Stack, Architektura, Analog, Data model, …) | `verify-analysis-complete.sh` (jak `verify-plan-rigor.sh` w a-t-b) + fixtures GOOD/BAD per sekcja |
| PHASE 2 — Hipotezy (≥3 required) | 357-377 | Liczba hipotez ≥3, każda Minimal/Idiomatic/Ambitious | `check-hypotheses-count.sh` + fixtures hypothesis-2 (BAD), hypothesis-3-mixed (GOOD) |
| PHASE 3 — Rekomendacja | 378-388 | Plik `state/recommendation.md` istnieje + wskazuje H<N> z Phase 2 | `verify-recommendation-link.sh` |
| PHASE 4 — Plan Document | 389-432 | 11 sekcji planu (Co/Dlaczego, Szacowany nakład, …) | Reuse `verify-plan-rigor.sh` z a-t-b (lub kopia) |
| PHASE 5 — APPROVAL GATE | 433-470 | Breadcrumb `gate_approved` przed Phase 6 | `verify-approval-gate.sh` (kopia z a-t-b okrojona) |
| PHASE 5.5 — Worktree decision | 471-610 | Decision matrix S/M/L → akcja | `derive-worktree-decision.sh` + fixtures plan-S / plan-M / plan-L |
| PHASE 5.7 — Ralph-loop decision | 611-734 | Warunki opt-in (size L + zielone testy + user explicit `ralph`) | `check-ralph-eligibility.sh` |
| PHASE 6 — Implementation routing | 735-1397 | Wybór 6-Sequential/Teams/Ralph na podstawie planu | `route-implementation.sh` |
| PHASE 7 — Testing (7 scopes) | 1398-… | Każdy scope (unit/integration/system/acceptance/E2E/regression/perf+sec) ma raw log | `extract-raw-log.sh` (kopia z v3) + fixtures success/fail per scope |
| PHASE 7.6 — Ralph test-fix | 1506-… | Failing testy → ralph-loop fix → green | `verify-test-fix-loop.sh` |

**Stan ogółem:** 0/11 phases ma walidatory + testy. **v2 to czysta proza** — dyscyplina opiera się na tym, że agent czyta i postępuje. Brak deterministycznej uprzęży.

## Pryncypium retrofittingu: „każda zmiana w v2 = krok w stronę v3"

> Egzekwowane przez Anti-Rat „v2 zostaje prose-heavy bo działa".

**Reguła:** jeśli dodajesz nową funkcjonalność do v2 (nowa faza, nowy artefakt, nowa bramka) i da się ją wyrazić deterministycznie → **utwórz skrypt + fixture + assert_exit w nowym lub istniejącym runnerze**. W przeciwnym razie wskazania v2 są niewykrywalne automatycznie i v2 dryfuje.

**Antypattern:** dodanie nowej sekcji opisowej do SKILL.md bez skryptu = dług techniczny równy 1× rozmiar sekcji.

## Procedura: dodawanie nowej funkcjonalności do v2 (z retrofittingiem)

> Egzekwowane przez Beyoncé Rule.

1. **Spec** — opisz funkcjonalność w SKILL.md (nowa Phase X / sub-section).
2. **Decyzja: czy da się wyrazić deterministycznie?**
   - **TAK** (np. „każdy plan ma ≥N sekcji", „artefakt X istnieje i jest niepusty") → przejdź do kroku 3.
   - **NIE** (np. „agent przeanalizuje uważnie") → przemyśl ponownie. **Pryncypium Process over Prose**: jeśli nie ma deterministycznego artefaktu, krok jest za miękki.
3. **Utwórz skrypt** `dev/replit-style-workflow/scripts/<nazwa>.sh` (POSIX, `#!/bin/sh`, `set -eu`). Jeśli `scripts/` nie istnieje — utwórz (`mkdir -p`).
4. **RED** — `tests/fixtures/<komponent>-good.<ext>` + `<komponent>-bad-<typ>.<ext>`. Jeśli `tests/` nie istnieje — utwórz `tests/run-meta-tests.sh` (skopiuj wzorzec z `dev/agent-teams-builder/tests/run-meta-tests.sh`).
5. **Implementacja** skryptu → **GREEN** `bash tests/run-meta-tests.sh` → wszystkie cases passed.
6. **Integration** — jeśli skrypt łączy się z innym walidatorem v2: scena z `setup_*`.
7. **Update** `testing-map.md` — wiersz w tabeli, Status ❌ → ✅.
8. **Update** `CHANGELOG.md` v2: `+N test cases, walidator: <nazwa>, +1 step closer to v3 rigor`.

**Exit criterion:** runner output `X/X passed` wklejony do PR description.

## Procedura: fix buga w workflow v2 (Prove-It Pattern, source: DOC/since_skill.md §5)

> Najczęstsze bugi w v2 to **rozjazd prozy z realnym workflow** (np. agent pomija fazę, bo proza jej nie egzekwuje).

1. **Reprodukcja** — opisz buga w `state/blockers.md` lub PR description. Jeśli da się utworzyć fixture (input który v2 obecnie misshandluje) → przejdź do kroku 2. Jeśli nie → bug jest niemierzalny → przepisz fazę w SKILL.md tak, żeby BYŁ mierzalny (krok w stronę v3).
2. **Utwórz skrypt walidatora** dla buga + `tests/fixtures/regression-<short-desc>.<ext>`.
3. **RED** — assert_exit w runnerze. Walidator nie istnieje (lub nieprawidłowo obsługuje fixture) → case failuje.
4. **Fix** — implementacja skryptu walidatora ALBO update SKILL.md jeśli to bug prozy + dodanie walidatora egzekwującego.
5. **GREEN** — runner zielony.
6. **Update** `testing-map.md` + `CHANGELOG.md` v2.

## Anti-Rationalization (testowanie meta-testów v2)

| Wymówka | Riposta (blokada) | Źródło |
|---|---|---|
| „v2 to historyczny prose-heavy skill, testy nie pasują do designu" | Odrzucono częściowo. **Historyczny stan ≠ trwała immunność.** Każda NOWA funkcjonalność w v2 musi mieć test, nawet jeśli stare fazy nie mają. Niech v2 ewoluuje w stronę v3, nie cementuje braku rygoru. | DOC/material_skill.md §5 |
| „SKILL.md v2 ma 2229 linii prozy, mniej linijek na refaktor" | Odrzucono. **Beyoncé Rule** nie patrzy na rozmiar SKILL.md. Patrzy na liczbę funkcjonalności bez testów. Aktualnie w v2 = 11 phases × 0 testów = dług technologiczny. | DOC/material_skill.md §5 |
| „Dodam nową sekcję do v2 bez skryptu — to tylko opis" | Odrzucono. **Process over Prose** (Filar 1). Opis bez exit criterion = krok za miękki. Jeśli krok jest faktycznie nieweryfikowalny, nie ma czego dodawać. | DOC/material_skill.md §2, DOC/since_skill.md §2 (Filar 1) |
| „Bug w workflow v2 — naprawię prozę, regresja w przyszłości się nie zdarzy" | Odrzucono. **Prove-It Pattern.** Bug w prozie = bug niewykrywalny → wróci. Jedyny sposób uchwycenia regresji = walidator + fixture. Bez tego v2 dryfuje. | DOC/since_skill.md §5 |
| „v2 jest stabilne (v2.1.0), nie ruszam testów" | Odrzucono. Stabilność wersji ≠ stabilność workflow. Pierwsza realna zmiana w v2 ma okazję dodać pierwszy test. **Zero ≠ stable.** | DOC/material_skill.md §5 |

## DoD per zmiana (egzekwowane przy każdej nowej funkcjonalności v2)

- [ ] Nowa faza/sekcja/artefakt: ocena „czy deterministycznie weryfikowalne". Tak → kroki 3-8 procedury. Nie → przepisz na deterministyczne lub nie dodawaj.
- [ ] Utworzony walidator w `scripts/` (utwórz katalog jeśli nie istnieje).
- [ ] Utworzona fixture w `tests/fixtures/` + `assert_exit` w `tests/run-meta-tests.sh` (utwórz runner jeśli nie istnieje, wzorzec a-t-b).
- [ ] Fix buga workflow: regression fixture + assert_exit (Prove-It).
- [ ] `bash tests/run-meta-tests.sh` → `X/X passed`.
- [ ] `references/testing-map.md` zaktualizowana — wiersz funkcjonalności + Status ❌→✅.
- [ ] `CHANGELOG.md` v2: `+N test cases` + nota `+1 walidator z 11 phases pokryty`.

## Reguła ładowania (Progressive Disclosure)

> Załaduj `references/testing-map.md` zawsze gdy:
> - dodajesz/modyfikujesz fazę w SKILL.md v2
> - fix buga workflow v2 (Phase 6/7 errors, niewykryte regresje)
> - retrospective po wykonaniu featuru w v2 — które fazy zadrżały? Czy uchwyciłeś je walidatorem?
> - migrujesz fazę z v2 do v3 — testing-map.md v3 ma już strukturę, można skopiować mapę.

## Long-term: czy v2 ma sens utrzymywać?

Jeśli **żadna** nowa funkcjonalność v2 nie wejdzie w najbliższych 6 miesiącach, a v3 + feature-spec-planner pokrywają wszystkie use cases v2 → rozważ deprecation v2 w przyszłej wersji marketplace (analogicznie do usunięcia `feature-planner-codex` w `2026-05-25`). To decyzja produktowa, nie testowa — ale brak testów meta jest sygnałem, że skill stoi w miejscu.
