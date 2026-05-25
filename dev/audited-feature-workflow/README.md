# audited-feature-workflow

> Senior-grade feature workflow z deterministyczną uprzężą inżynieryjną dla agentów AI. **16 faz, 6 bramek approval, 11 wierszy Anti-Rationalization, 5-osiowy code review, plus tryb `/goal`** — autonomiczna pętla weryfikacji AC z mierzalnym stopem.

[![version](https://img.shields.io/badge/version-v3.1.1-blue)]() [![size](https://img.shields.io/badge/SKILL.md-413%2F500_lines-green)]() [![tests](https://img.shields.io/badge/spec_AC-8%2F8_passing-brightgreen)]()

---

## Co to jest

`audited-feature-workflow` to skill dla Claude Code, który prowadzi agenta AI przez **audytowalny proces wdrażania feature-ów** — od deep analysis przez plan, implementation, testing, review aż po ADR. Każda faza ma mierzalne exit criteria. Każda bramka wymaga jawnej zgody lub twardego dowodu.

Skill nie jest „helper-em do refaktoringów". To **rygorystyczna uprząż** dla nietrywialnych zmian: nowe feature, migracje API, zmiany w infrastrukturze, refactoring z impactem architektonicznym.

## Kiedy używać

✅ **TAK** — gdy:
- Zadanie wymaga ≥3 plików zmian i ma jakikolwiek impact architektoniczny.
- Chcesz delegować na agenta AI z minimalnym nadzorem, ale z twardymi gwarancjami jakości.
- Implementacja jest mergowalna jako PR (nie ad-hoc fix).
- Masz mierzalne kryteria akceptacji (testy, exit codes, grep-able artefakty).

❌ **NIE** — gdy:
- Jednoliniowa poprawka, literówka, rename zmiennej.
- Eksploracja repozytorium bez intencji implementacji.
- Czysto deklaratywne pytanie („wytłumacz co robi ten kod").

Pełna lista negatywnych triggerów w [SKILL.md `do-not-trigger-for`](SKILL.md).

## Jak uruchomić

W prompcie do Claude Code napisz:

```
feature-planner v3, dodaj <nazwa feature>
```

lub jeden z innych triggerów:
- `dodaj feature v3`
- `senior-grade feature`
- `implement v3`
- `zaimplementuj v3`
- `ralph v3` — wariant z autonomous ralph-loop
- `/goal` — wariant z autonomous goal-driven loop (patrz [Tryb /goal](#tryb-goal))
- `goal mode`

Claude rozpozna trigger, wykona Phase 0 (env detection) i poprowadzi cię przez 16 faz z 6 bramkami approval.

## Architektura — 16 faz, 6 bramek

| Faza | Cel | Bramka |
|------|-----|--------|
| 0 | Env detection + Negative Triggers + Fragile zone | — |
| 1 | Deep analysis + Hyrum + Chesterton | — |
| 1.5 | Dependency Impact Radius + API klasyfikacja | — |
| 2 | ≥3 hipotezy (Minimal / Idiomatic / Ambitious) | — |
| 3 | Recommendation + Hyrum Risk | — |
| 4 | Plan document + DoD + Thin Slices + AC↔Test mapping | — |
| **5** | **Save plan** | **APPROVAL #1** |
| 5.5 | Worktree decision (S/M/L) | — |
| 5.7 | Ralph-loop decision (opt-in L) | — |
| 5.8 | **Goal Mode decision + auto-derive (tylko /goal)** | **APPROVAL #1.5** |
| **6** | **Implementation (Sequential / Teams / Ralph / Goal)** | **APPROVAL #2** |
| 6.5 | Prove-It Pattern (bugfix only) | — |
| **7** | **Testing 7 scopes + raw logs + build clean** | **APPROVAL #3** |
| **7.8** | **Live preview UI (M+)** | **APPROVAL #4** |
| **8** | **Five-Axis Code Review + PR Sizing** | **APPROVAL #5** |
| 9 | ADR + Anti-rationalization decisions | — |

## Kluczowe pryncypia

### Twarde bramki — nie da się ich obejść

5 nienegocjowalnych zasad ([non-negotiables.md](references/non-negotiables.md)):
1. **Uwidaczniaj założenia przed budowaniem** — każde ciche założenie zgłoś, nie zgaduj.
2. **Zatrzymaj się przy konflikcie wymagań** — eskaluj, nie improwizuj.
3. **Wybieraj rozwiązania nudne i oczywiste** — cleverness jest kosztem.
4. **Dostarczaj twardy dowód, nie deklarację** — log, test, screenshot.
5. **Dotykaj tylko tego, o co cię poproszono** — Scope Discipline.

### Anti-Rationalization quick-table (11 wierszy)

Tabela wymówek agentów AI z ripostami. Przykład:

| # | Wymówka | Riposta |
|---|---------|---------|
| 1 | „Zmiana mała, pomijam Phase 1" | Phase 1 nienegocjowalna. 5 linii kontekstu = minimum. |
| 2 | „Testy dopiszę w Phase 7" | TDD: failing test PRZED implementacją. Bez RED → brak GREEN. |
| 4 | „Kod się buduje, można mergować" | Build clean ≠ DoD. Wymagane: log testu + runtime trace + screenshot. |
| 6 | „PR 800 linii ale spójny" | >300 wymaga uzasadnienia, >1000 = automatyczny split. |
| 11 | „Goal-statement deryw kompletny, można pominąć Gate #1.5" | Gate #1.5 jest nienegocjowalny w /goal. |

Pełna tabela: [anti-rationalization.md](references/anti-rationalization.md).

### Five-Axis Code Review (Phase 8)

Każdy PR przechodzi audyt na 5 osiach: **Correctness, Readability, Architecture, Security, Performance**. Severity labels: Critical (blokada), Optional, Nit, FYI. Plus PR Sizing gate (>1000 linii = hard stop) i Chesterton check (każde `git rm` wymaga uzasadnienia). [five-axis-review.md](references/five-axis-review.md).

### Hub-and-spoke

`SKILL.md` jest **zwięzły** (413/500 linii hard limit). Szczegóły protokołów lazy-load z [references/](references/). Skrypty (deterministyczne narzędzia) z [scripts/](scripts/). Nigdy nie duplikujemy treści między hub a spoke.

---

## Tryb `/goal`

> **Nowość w v3.1.1** — autonomiczna pętla weryfikacji AC.

`/goal` to czwarta ścieżka implementacji (obok Sequential, Teams, Ralph). Aktywuje się **tylko** gdy w prompcie pojawi się `/goal` lub `goal mode`.

### Cel

Pozwolić agentowi AI iterować **całą noc** w izolowanym worktree (overnight runs) bez utraty bramek v3. Skrypt deterministycznie derywuje *goal-statement* z tabeli AC w Phase 4 i wykonuje verification commands, dopóki wszystkie nie zwrócą exit 0.

### Wzorzec

> **Stan końcowy + Sposób weryfikacji + Ograniczenia**

Przykład auto-generowany z tabeli AC w planie:

```
/goal Funkcja add(a,b) zwraca sumę. Funkcja sub(a,b) zwraca różnicę. Suma 10000 wywołań <100ms. Brak zewnętrznych deps. Weryfikacja: npm test -- tests/add.test.js; npm test -- tests/sub.test.js; npm test -- tests/perf.test.js; npm run check-deps; wszystkie exit 0. Ograniczenia: nie ruszaj UI, max 20 iter, max 480 min.
```

### Flow

```
Phase 4 (plan z tabelą AC)
      ↓
Phase 5 — APPROVAL #1 (plan)
      ↓
Phase 5.8 — auto-derive goal-statement.md + goal-prompt.txt
      ↓
Gate #1.5 — Goal Approval (user akceptuje wygenerowany goal)
      ↓
Phase 6 / 6-Goal route — run-goal-loop.sh iteruje
   ├─ Wszystkie cmd exit 0 → GREEN, przejdź do Phase 7
   ├─ Któryś fail → hand-off do calling Claude session
   │     ↓ agent commituje minimal fix
   │     ↓ re-invoke run-goal-loop.sh
   ├─ iter > max-iter → STOP, eskalacja
   ├─ elapsed > max-time → STOP, eskalacja
   ├─ Komenda chain detected → STOP scope-violation
   ├─ SHA256 mismatch → STOP (TOCTOU detection)
   ├─ Fragile zone touched → STOP scope-violation
   └─ 3 iter bez progresu → STOP no-progress
      ↓
Phase 7 / 8 / 9 (ręczne, niezmienione)
```

### Co `/goal` egzekwuje

| Mechanizm | Cel |
|-----------|-----|
| **AC walidacja (10 reguł)** | Bez kompletnej tabeli AC → exit 1 z listą braków |
| **SHA256 sidecar** | Wykrywa modyfikacje `goal-statement.md` po Gate #1.5 (TOCTOU) |
| **Komenda allowlist** | Tylko `npm/pnpm/yarn/pytest/cargo/go/make/sh/bash/node` jako prefix |
| **Chain rejection** | Odrzuca Komendy zawierające `&&`, `\|\|`, `;`, `\|`, `$(...)`, backticks |
| **`--max-iter ≥ 1`** | Nieskończona pętla zabroniona (`--max-iter 0` → exit 2) |
| **Path traversal guard** | `--out-dir` musi być pod `$REPO_ROOT` lub `/tmp` |
| **Secret detection** | Plany z pattern `API_KEY=`, `sk-*`, `ghp_*` itp. odrzucane |
| **Fragile-zone enforcement** | `git diff` przeciw `migrations/`, `terraform/`, `k8s/`, `auth/`, `.github/workflows/`, `Dockerfile` |
| **Exclusivity** | `/goal` ⊕ `/ralph` ⊕ `/teams` (jedna strategia na raz) |

### Co `/goal` NIE robi

- Nie omija żadnej bramki #2/#3/#4/#5 — autonomia tylko między #1.5 a #2.
- Nie modyfikuje planu ani goal-statement w trakcie pętli (TOCTOU protection).
- Nie commituje samodzielnie — agent commituje, skrypt waliduje.
- Nie woła sieciowych API (overnight runs muszą być deterministyczne local-only).
- Nie pomija Phase 7 (testing scopes), Phase 8 (Five-Axis Review), Phase 9 (ADR).
- W fragile zone — hard stop, brak autonomii (eskalacja do operatora).

Pełen protokół: [references/goal-mode-protocol.md](references/goal-mode-protocol.md) (10 sekcji).

---

## Struktura plików

```
dev/audited-feature-workflow/
├── README.md                          ← ten plik
├── SKILL.md                           ← główny prompt skilla (413 linii)
├── references/                        ← protokoły hub-and-spoke
│   ├── non-negotiables.md             ← 5 zasad master
│   ├── anti-rationalization.md        ← pełna tabela 11 wymówek
│   ├── analysis-protocol.md           ← Phase 1 (+ Hyrum + Chesterton)
│   ├── ac-protocol.md                 ← AC + Beyoncé 1:1 mapping
│   ├── dod-evidence-protocol.md       ← formaty dowodów per AC
│   ├── incremental-implementation.md  ← Thin Vertical Slices
│   ├── testing-protocol.md            ← 7 test scopes + DAMP + Prove-It
│   ├── code-review-protocol.md        ← code review + PR Sizing
│   ├── five-axis-review.md            ← 5 osi + severity + Multi-Model
│   ├── fragile-operations-protocol.md ← Plan-Validate-Execute
│   ├── goal-mode-protocol.md          ← Phase 5.8 + 6-Goal + Gate #1.5
│   ├── adr-template.md                ← Architecture Decision Record
│   └── gotchas.md                     ← auto-populating anomalie
├── scripts/                           ← deterministyczne narzędzia
│   ├── verify-build-clean.sh          ← build clean enforcement
│   ├── check-pr-size.sh               ← PR sizing gate
│   ├── check-ac-coverage.sh           ← 1:1 AC ↔ test
│   ├── api-impact-scan.sh             ← Hyrum risk scan
│   ├── extract-raw-log.sh             ← DoD evidence helper
│   ├── derive-goal-from-ac.sh         ← AC → goal-statement.md (Phase 5.8)
│   └── run-goal-loop.sh               ← autonomous goal-driven loop driver
└── tests/fixtures/                    ← test plans dla /goal scripts
    ├── complete-plan.md               ← happy-path fixture
    └── incomplete-plan.md             ← fail-path fixture (brakuje Komendy)
```

## Quick start — przykładowy workflow

### Klasyczny feature (Sequential)

1. **Prompt:** `dodaj feature v3: integracja z X API`
2. Claude wykonuje Phase 0–4, prezentuje plan.
3. **Ty:** „proceed" / „zatwierdzam" → APPROVAL #1.
4. Claude implementuje (Phase 6 Sequential, slice-by-slice, TDD).
5. **Ty:** „proceed" → APPROVAL #2 po każdej slice.
6. Phase 7: testy, raw logs, build clean → APPROVAL #3.
7. Phase 8: Five-Axis Review → APPROVAL #5.
8. Phase 9: ADR z anti-rationalization decisions.
9. Merge.

### Overnight goal-driven run

1. **Prompt:** `feature-planner v3, dodaj X /goal`
2. Phase 0–4 jak wyżej, ale Phase 4 MUSI mieć tabelę AC z `Komenda` per wiersz.
3. APPROVAL #1 (plan).
4. Phase 5.5 → worktree (M/L obligatoryjnie).
5. Phase 5.8 → skrypt deryw goal-statement.md.
6. **Ty:** „zatwierdzam goal" → APPROVAL #1.5.
7. Włącz auto-mode w Claude Code (akceptacja tools bez monitów).
8. 6-Goal pętla iteruje (`run-goal-loop.sh` + agent re-invocation).
9. Rano: status `GREEN` lub raport (iter-cap/time-cap/scope-violation/no-progress).
10. Ręczna Phase 7 → 8 → 9 → merge.

## Wymagania

- **Claude Code** (CLI lub IDE plugin).
- **Bash 3.2+** (macOS BSD coreutils + Linux GNU OK).
- **Git 2.5+** (worktree support).
- **gh CLI** opcjonalnie (jeśli używasz Phase 5.7 ralph z PR queue).
- **shasum/sha256sum** — dla /goal TOCTOU protection.

## Limitacje znane

- `/goal` jest **single-shot per invocation** — calling Claude session zarządza pętlą. Statusy `iter-cap-hit`, `time-cap-hit`, `no-progress`, `pr-too-big` są emitted przez caller, nie skrypt.
- Komenda allowlist (`npm/pnpm/yarn/pytest/cargo/go/make/sh/bash/node`) — projekty z `deno`, `vitest`, `bun` wymagają custom patch.
- DOC/ folder w tym repo jest `.gitignore`d (local-only); link z SKILL.md jest oznaczony `(local-only, gitignored)`.
- Fragile zone hard-coded: `migrations/`, `terraform/`, `k8s/`, `auth/`, `.github/workflows/`, `Dockerfile`. Custom paths przez `--fragile-paths CSV`.

## Wersjonowanie

- **v3.0** — pierwsza wersja senior-grade (Anti-Rat, Hyrum, Chesterton, Beyoncé, DAMP, PR Sizing, Five-Axis, Plan-Validate-Execute, Thin Slices, Prove-It).
- **v3.1** — dodanie `/goal` mode (Phase 5.8 + 6-Goal route + Gate #1.5).
- **v3.1.1** — hardening Five-Axis Review fixes (18 fixów w jednym commicie: RC capture, strict cell guard, Komenda chaining rejection, SHA256 TOCTOU protection, max-iter guard, path traversal guard, secret detection, fragile-zone enforcement, dokumentacja consistency).

Pełna historia: `git log dev/audited-feature-workflow/`.

## Linki

- [Spec designu /goal mode](../../docs/superpowers/specs/2026-05-13-audited-feature-workflow-goal-mode-design.md)
- [Plan implementacji /goal mode](../../docs/superpowers/plans/2026-05-13-audited-feature-workflow-goal-mode.md)
- [SKILL.md](SKILL.md) — główny prompt skilla
- [goal-mode-protocol.md](references/goal-mode-protocol.md) — pełny protokół /goal
- [replit-style-workflow (wygodny wariant)](../replit-style-workflow/) — historycznie feature-planner-v2; bez Anti-Rat #11, bez /goal, bez Five-Axis hardening

## Filozofia

> „Najwyższa waga jakości. Nie optymalizuj pod szybkość implementacji wykonawczej. Każda bramka i każdy artefakt dowodowy jest nienegocjowalny. Brak skrótów, nawet jeśli wymówka brzmi inżynieryjnie."

— Anti-Laziness preamble, SKILL.md.

`audited-feature-workflow` jest dla zespołów, które wolą **godzinę więcej pracy z agentem AI w zamian za audytowalność, bezpieczeństwo i deterministyczne exit criteria** niż szybki diff bez gwarancji. Skill nie jest pluginem do generowania kodu — jest **uprzężą inżynieryjną**, która sprawia, że agent AI pracuje jak senior engineer w 1:1 review.
