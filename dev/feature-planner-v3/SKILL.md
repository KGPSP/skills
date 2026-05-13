---
name: feature-planner-v3
description: Senior-grade feature workflow z deterministyczną uprzężą inżynieryjną. Rozszerza v2 (Replit Agent style, Agent Teams, ralph-loop, worktree, 7 test scopes) o twarde bramki z material_skill.md + since_skill.md — Anti-Rationalization, Hyrum's Law, Chesterton's Fence, Beyoncé Rule, DAMP over DRY, PR Sizing, Five-Axis Review, Plan-Validate-Execute dla fragile ops, Thin Vertical Slices, Prove-It Pattern. Używaj gdy zadanie wymaga audytowalnej delegacji na agenta AI z mierzalnymi exit criteria w każdej fazie. Plus /goal mode auto-derived z AC (Phase 5.8 + 6-Goal route).
trigger:
  - "feature-planner v3"
  - "dodaj feature v3"
  - "senior-grade feature"
  - "implement v3"
  - "zaimplementuj v3"
  - "ralph v3"
  - "/goal"
  - "goal mode"
do-not-trigger-for:
  - "przeczytaj plik X"
  - "wytłumacz co robi ten kod"
  - "popraw literówkę"
  - "rename variable"
  - jednoliniowe poprawki bez impactu architektonicznego
  - eksploracja repozytorium bez zamiaru implementacji
model: claude-opus-4-7
allowed-tools: ['Bash', 'Read', 'Edit', 'Write', 'Grep', 'Glob', 'TodoWrite', 'Agent', 'SendMessage', 'TaskOutput']
sources:
  - DOC/material_skill.md
  - DOC/since_skill.md
  - DOC/goal_mode.md
version: v3
extends: feature-planner-v2
size-limit: 500-lines-hard
---

# feature-planner v3 — senior-grade enforcement

> [!quote] Anti-Laziness preamble (since_skill.md §6)
> Najwyższa waga jakości. **Nie optymalizuj pod szybkość implementacji wykonawczej.** Każda bramka i każdy artefakt dowodowy jest nienegocjowalny. Brak skrótów, nawet jeśli wymówka brzmi inżynieryjnie.

> [!important] 5 Non-negotiables (pełna treść: [non-negotiables.md](references/non-negotiables.md))
> 1. **Uwidaczniaj założenia przed budowaniem** — każde ciche założenie zgłoś, nie zgaduj.
> 2. **Zatrzymaj się przy konflikcie wymagań** — eskaluj, nie improwizuj.
> 3. **Wybieraj rozwiązania nudne i oczywiste** — cleverness jest kosztem.
> 4. **Dostarczaj twardy dowód, nie deklarację** — log, test, screenshot.
> 5. **Dotykaj tylko tego, o co cię poproszono** — Scope Discipline.

---

## Anti-Rationalization quick-table (pełna: [anti-rationalization.md](references/anti-rationalization.md))

Przed każdym `git commit` w Phase 6 i przed każdą deklaracją „done" w Phase 7 — przejdź przez tę tabelę.

| # | Wymówka agenta | Riposta (blokada) |
|---|---|---|
| 1 | „Zmiana mała, pomijam Phase 1" | Phase 1 nienegocjowalna. 5 linii kontekstu = minimum. |
| 2 | „Testy dopiszę w Phase 7" | TDD: failing test PRZED implementacją. Bez RED → brak GREEN. |
| 3 | „AC jest oczywiste" | Każdy AC-F/N/C zapisany w planie. Brak AC = blokada Phase 5. |
| 4 | „Kod się buduje, można mergować" | Build clean ≠ DoD. Wymagane: log testu + runtime trace + screenshot. |
| 5 | „Refaktoryzowałem sąsiedni plik" | Scope Discipline. Cofnij, zgłoś w `out-of-scope.md`. |
| 6 | „PR 800 linii ale spójny" | >300 wymaga uzasadnienia, >1000 = automatyczny split. |
| 7 | „API zmiana bezpieczna, nie ma userów" | Hyrum's Law. Każda sygnatura wymaga `api-impact.md`. |
| 8 | „Usunąłem martwy kod" | Chesterton's Fence. Bez `why-this-existed:` — przywróć. |
| 9 | „Test pokrywa happy path" | Beyoncé Rule. Każdy edge case z AC-N → osobny test. |
| 10 | „DRY-uję testy w helper" | DAMP over DRY. Test czytelny jak spec, bez magicznych helperów. |

---

## Architektura: 14 faz + 5 bramek approval

| Faza | Cel | Bramka |
|---|---|---|
| 0 | Detekcja środowiska + Negative Triggers + Fragile zone | — |
| 1 | Deep analysis + Hyrum + Chesterton | — |
| 1.5 | Dependency Impact Radius + API klasyfikacja | — |
| 2 | ≥3 hipotezy (Minimal / Idiomatic / Ambitious) | — |
| 3 | Recommendation + Hyrum Risk | — |
| 4 | Plan document + DoD + Thin Slices + AC↔Test mapping | — |
| 5 | Save plan | **APPROVAL #1** |
| 5.5 | Worktree decision (S/M/L) | — |
| 5.7 | Ralph-loop decision (opt-in L) | — |
| 6 | Implementation (Sequential / Teams / Ralph) | **APPROVAL #2** |
| 6.5 | Prove-It Pattern (bugfix only) | — |
| 7 | Testing 7 scopes + raw logs + build clean | **APPROVAL #3** |
| 7.8 | Live preview UI (M+) | **APPROVAL #4** |
| 8 | Five-Axis Code Review + PR Sizing | **APPROVAL #5** |
| 9 | ADR + Anti-rationalization decisions | — |

---

## Phase 0 — Detekcja środowiska

1. Wykrywaj trigger v3 (lista w frontmatter). Jeśli brak `v3` w prompcie → **route do v2**.
2. Sprawdzaj **Negative Triggers** (frontmatter `do-not-trigger-for`). Jeśli match → exit, sugeruj brak skilla.
3. Wykrywaj **stack**: `package.json` (Node), `pyproject.toml` (Python), `Cargo.toml` (Rust), `go.mod` (Go), `pom.xml` / `build.gradle` (JVM).
4. Wykrywaj **rozmiar projektu** (S/M/L) — `find . -type f -name "*.{ts,py,rs,go}" | wc -l` + linie zmian planowanych.
5. Wykrywaj **Fragile Zone** — ścieżki `migrations/`, `terraform/`, `k8s/`, `auth/`, `Dockerfile`, `.github/workflows/`. Jeśli match → flag `--fragile` → aktywuj [fragile-operations-protocol.md](references/fragile-operations-protocol.md).
6. Wykrywaj **Ralph mode** (trigger `ralph` lub `iteruj aż zielono`) i **Agent Teams** (trigger `parallel`, `teams`).
7. Numeruj plan: `find {baseDir}/plans -name "*.md" | wc -l` + 1.

> [!warning] Output Phase 0
> `env-detection.md` z polami: stack, size, fragile, ralph, teams, plan-number.

---

## Phase 1 — Deep Analysis

Wywołaj [analysis-protocol.md](references/analysis-protocol.md). Wymagane outputy:

1. **PRIMARY TEMPLATE** — najbardziej zbliżona istniejąca feature w repo.
2. **Architecture walk** — stack + warstwa + framework + konwencje.
3. **Analog feature** — porównywalny pattern do naśladowania.
4. **Hyrum Impact Analysis** — lista publicznych eksportów dotkniętych zmianą. Klasyfikacja: `breaking` / `additive` / `internal`.
5. **Chesterton scan** — dla każdej kandydatury do deletion: `git blame` + `git log -L` → sekcja `Why this existed:`. Bez wyjaśnienia kod zostaje.
6. **Gotchas update** — dopisz odkryte anomalie do [gotchas.md](references/gotchas.md).

> [!warning] Output Phase 1
> `analysis/<plan-id>.md` + `analysis/<plan-id>-api-impact.md` (jeśli zmiana publiczna).

---

## Phase 1.5 — Dependency Impact Radius

1. Uruchom `sh {baseDir}/dev/feature-planner-v3/scripts/api-impact-scan.sh --base main`.
2. Sklasyfikuj każdy eksport: `breaking` / `additive` / `internal`.
3. Dla `breaking`: deprecation plan lub uzasadnienie braku w ADR.
4. Reverse search callerów: `git grep <symbol> -- ':!*test*'`.

---

## Phase 2 — ≥3 Hipotezy

Generuj minimum 3 alternatywy: **Minimal** (najmniejszy ruch), **Idiomatic** (zgodne z konwencją repo), **Ambitious** (przyszłościowe). Dla każdej: trade-offs, ryzyko, koszt, Hyrum risk.

---

## Phase 3 — Recommendation

1. Wybierz **jedną** hipotezę.
2. Uzasadnij wybór względem 5 Non-negotiables.
3. **Hyrum Risk section** (jeśli zmiana publiczna) — co się stanie z istniejącymi callerami.
4. Kluczowe decyzje techniczne (formaty, biblioteki, schematy).

---

## Phase 4 — Plan Document

Wymagane sekcje planu w `{baseDir}/plans/<N>-<slug>.md`:

1. **Co i dlaczego** — 2-3 zdania, biznesowy cel.
2. **Acceptance Criteria** — tabela AC w formacie:
   ```
   | AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda |
   ```
   Każdy AC ma test (Beyoncé Rule 1:1). Pełen protokół: [ac-protocol.md](references/ac-protocol.md).
3. **Definition of Done** — per AC: komenda + format dowodu + próg sukcesu. Pełen protokół: [dod-evidence-protocol.md](references/dod-evidence-protocol.md).
4. **Assumptions** — wszystkie założenia jawnie.
5. **Out of scope** — co jawnie pomijamy + uzasadnienie.
6. **Thin Vertical Slices** — rozbicie na end-to-end odnogi (DB→API→UI), nie warstwa-po-warstwie. Każda slice mergowalna niezależnie. Pełen protokół: [incremental-implementation.md](references/incremental-implementation.md).
7. **Rollback plan** — szczególnie dla `--fragile` zone.
8. **Target diff size** — szacunek (≤300 linii preferowane).
9. **Hyrum Risk** — jeśli zmiana publicznego API.
10. **Anti-rationalization quick-table** — link do [anti-rationalization.md](references/anti-rationalization.md).

---

## Phase 5 — APPROVAL GATE #1

> [!important] Approval checklist
> Zapisz plan do `{baseDir}/plans/<N>-<slug>.md`. Zanim ruszysz dalej, sprawdź:
> - [ ] Plik nie jest pusty (`test -s "$PLAN_FILE"`).
> - [ ] Wszystkie 10 sekcji obecne (`grep -c '^## ' "$PLAN_FILE" >= 10`).
> - [ ] Każdy AC ma `Test ID` + `Komenda` (1:1 mapping).
> - [ ] DoD ma format dowodu dla każdego AC.
> - [ ] Jeśli `--fragile`: dosłowna procedura Plan-Validate-Execute załączona.
> - [ ] Target diff size deklarowany.
>
> **STOP — czekaj na jawną zgodę użytkownika.** Bez „proceed" / „zatwierdzam" / „ok" → nie pisz kodu.

---

## Phase 5.5 — Worktree decision

| Size | Worktree | Override |
|---|---|---|
| S (<100 linii) | NIE | `--worktree` wymusza TAK |
| M (100-500 linii) | TAK domyślnie | `--no-worktree` wymusza NIE |
| L (>500 linii) | TAK obligatoryjnie | brak overrides |

Komenda: `git worktree add ../<slug>-wt -b feat/<slug>`.

---

## Phase 5.7 — Ralph-loop decision

Aktywuj **tylko** gdy: (a) size L, (b) testy zielone w v2 dla podobnej fazy, (c) user explicite napisał `ralph`.

Reguła v3: każda iteracja ralph-loop **MUSI** przejść przez Anti-Rationalization quick-table. Brak skrótu na „już to widziałem w poprzedniej iteracji".

---

## Phase 6 — Implementation + APPROVAL GATE #2

Routing implementacji:
- **6-Sequential** — domyślnie dla S/M.
- **6-Teams** (2-5 agentów) — dla L gdy parallel safe.
- **6-Ralph** — autonomous L z zielonym test gate.

Pre-flight: `git status` clean. Build baseline check.

Dla każdej slice (Thin Vertical Slices — [incremental-implementation.md](references/incremental-implementation.md)):

1. **Najprostsza logika bazowa** dla slice.
2. **Failing test** (RED) — TDD. Commit failing test PRZED implementacją.
3. **Implementacja minimalna** → test GREEN.
4. **Build validation**: `sh {baseDir}/dev/feature-planner-v3/scripts/verify-build-clean.sh` — exit 0.
5. **Commit atomic** — slice = jeden commit lub mała seria.
6. **PR Sizing check**: `sh {baseDir}/dev/feature-planner-v3/scripts/check-pr-size.sh` po każdym commit.
   - ≤300 linii: ✅ proceed
   - 301-1000: ⚠️ wymaga `--justified` + wpis w PR description
   - \>1000: ⛔ hard stop, split (stacking lub vertical slicing)
7. **Anti-rationalization quick-check** przed `git commit` (przejdź tabelę).
8. **Safe Defaults** — niedokończone slices za feature flagą.
9. Przejdź do następnej slice.

> [!danger] Jeśli `--fragile`
> Reżim **Plan-Validate-Execute** — patrz [fragile-operations-protocol.md](references/fragile-operations-protocol.md). Bez kreatywności. Dosłowne wykonanie zatwierdzonych komend.

---

## Phase 6.5 — Prove-It Pattern (bugfix only)

Aktywuj gdy trigger zawiera `fix:` / `bug:` / `regression:`.

1. **STOP** — nie dotykaj kodu produkcyjnego.
2. Napisz test, który **odtwarza buga** i zawodzi (RED). Commit failing test.
3. Wklej output RED jako dowód (`sh extract-raw-log.sh`).
4. Dopiero teraz pisz fix.
5. Test wraca do GREEN → fix zatwierdzony. Wklej output GREEN.

Anti-pattern: natychmiastowe przepisanie kodu po zobaczeniu loga błędu, bez RED dowodu.

---

## Phase 7 — Testing + APPROVAL GATE #3

Test scopes (matryca S/M/L w [testing-protocol.md](references/testing-protocol.md)):

1. **Unit** (wszystkie size).
2. **Integration** (M, L).
3. **System** (L).
4. **Acceptance** (M, L) — 1:1 AC mapping.
5. **E2E Playwright tiers 1-4** (M, L).
6. **Regression** (L).
7. **Perf + Security** (L).

Bramki Phase 7:

- [ ] **Build clean**: `sh {baseDir}/dev/feature-planner-v3/scripts/verify-build-clean.sh` → exit 0, zero warnings.
- [ ] **Raw log requirement** — `sh {baseDir}/dev/feature-planner-v3/scripts/extract-raw-log.sh --cmd "<TEST_CMD>"` wklejony do PR description. **Bez parafraz modelu.**
- [ ] **AC coverage 1:1**: `sh {baseDir}/dev/feature-planner-v3/scripts/check-ac-coverage.sh --plan "$PLAN_FILE"` → 100%.
- [ ] **DAMP checklist** per test file (patrz [testing-protocol.md](references/testing-protocol.md) sekcja DAMP).
- [ ] **Trace runtime** dla ścieżki krytycznej.

> [!important] Brak któregokolwiek artefaktu = STOP. **„Wydaje się działać" to halucynacja**, nie status.

---

## Phase 7.8 — Live preview UI + APPROVAL GATE #4 (M+ z UI)

Uruchom dev server. Otwórz w przeglądarce. **Screenshot per AC-F** z UI. Walidacja wizualna przed Phase 8.

> [!important] Gate #4 — preview approval
> Bez screenshotów per AC-F i wizualnej walidacji UI nie przechodź do Phase 8.

---

## Phase 8 — Five-Axis Code Review + APPROVAL GATE #5

Wywołaj [five-axis-review.md](references/five-axis-review.md). Pięć osi audytu:

1. **Correctness** — off-by-one, null safety, race conditions.
2. **Readability & Simplicity** — 1000 linii vs 100 linii = porażka.
3. **Architecture** — duplikacje, cykliczne zależności, naruszenia granic.
4. **Security** — SQL injection, secrets scan, OWASP Top 10.
5. **Performance** — N+1, niekontrolowane pętle, brak async I/O.

Severity labels: **Critical** (blokada), **Optional**, **Nit**, **FYI**.

Dodatkowe bramki Phase 8:

- [ ] **PR Sizing gate**: `sh check-pr-size.sh --base main` → ≤300 linii lub `--justified`.
- [ ] **Chesterton check** — dla każdej `git rm` / deleted function: sekcja `Why this existed:` w PR description.
- [ ] **Anti-rationalization final pass** — przejdź tabelę całą.
- [ ] (Opcjonalnie L-size) **Multi-Model Review** — drugi agent (codex-rescue) review na osiach ryzyka. **ZAKAZ Gemini** (dziedziczone z v2).

---

## Phase 9 — ADR (Architecture Decision Record)

Wywołaj [adr-template.md](references/adr-template.md). ADR MUSI zawierać:

1. **Context** — co i dlaczego.
2. **Decision** — wybrana hipoteza + alternatywy.
3. **Anti-rationalization decisions** — wymówki, które agent odrzucił po drodze (z tabeli).
4. **Hyrum/Chesterton decisions** — zachowania API zachowane, kod nieusuany mimo pokusy.
5. **Consequences** — co się zmienia, co zostaje.
6. **Gotchas dopisek** — anomalie odkryte w Phase 1 dodane do [gotchas.md](references/gotchas.md).

> [!warning] Dedup pass
> Phase 9 wymusza dedup [gotchas.md](references/gotchas.md). Jeśli >100 wpisów → split per moduł.

---

## Indeks referencji

### Protokoły procesowe (warstwa A — material_skill.md)

- [non-negotiables.md](references/non-negotiables.md) — 5 zasad master.
- [anti-rationalization.md](references/anti-rationalization.md) — pełna tabela wymówek + ralph-loop variant.
- [dod-evidence-protocol.md](references/dod-evidence-protocol.md) — formaty dowodów per typ AC.
- [analysis-protocol.md](references/analysis-protocol.md) — Phase 1 (+ Hyrum + Chesterton).
- [ac-protocol.md](references/ac-protocol.md) — AC + Beyoncé 1:1 mapping.
- [code-review-protocol.md](references/code-review-protocol.md) — review (+ PR Sizing + Five-Axis redirect).
- [testing-protocol.md](references/testing-protocol.md) — 7 scopes + DAMP + Prove-It + raw logs.

### Protokoły projektowe (warstwa B — since_skill.md)

- [fragile-operations-protocol.md](references/fragile-operations-protocol.md) — Plan-Validate-Execute.
- [incremental-implementation.md](references/incremental-implementation.md) — Thin Vertical Slices.
- [five-axis-review.md](references/five-axis-review.md) — 5 osi + severity + Multi-Model.
- [gotchas.md](references/gotchas.md) — auto-populating projektowych anomalii.

### Skrypty (warstwa B — deterministyczne narzędzia)

- `scripts/check-pr-size.sh` — PR sizing gate.
- `scripts/verify-build-clean.sh` — build clean enforcement.
- `scripts/check-ac-coverage.sh` — 1:1 AC ↔ test.
- `scripts/extract-raw-log.sh` — DoD evidence helper.
- `scripts/api-impact-scan.sh` — Hyrum risk scan.

### Szablon

- [adr-template.md](references/adr-template.md) — ADR (bez zmian z v2).

---

## Sources

- [DOC/material_skill.md](../../DOC/material_skill.md) — pryncypia procesowe (Process over Prose, Anti-rationalization, DoD, Scope Discipline, Hyrum, Chesterton, Beyoncé, DAMP, 5 Non-negotiables).
- [DOC/since_skill.md](../../DOC/since_skill.md) — pryncypia projektowe skilla (token budget, kebab-case, imperatyw, scripts/, Negative Triggers, Anti-Laziness, Plan-Validate-Execute, Five-Axis Review, Thin Vertical Slices, Prove-It).
- [dev/feature-planner/SKILL.md](../feature-planner/SKILL.md) — v2 baseline (Agent Teams, ralph-loop, worktree decision, 7 test scopes).
