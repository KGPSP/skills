# feature-planner-v3 — `/goal` Mode (Phase 5.8 + 6-Goal route)

- **Status**: Design — accepted (2026-05-13)
- **Source skill**: `dev/feature-planner-v3/`
- **Source doc**: `DOC/goal_mode.md`
- **Owner**: Michal Klosinski
- **Spec author**: Claude (Opus 4.7 1M)

---

## 1. Cel

Dodać do skilla `feature-planner-v3` nowy przełącznik `/goal`, który po zatwierdzeniu planu z Phase 4 **deterministycznie wyprowadza** zwięzły *goal-statement* z tabeli Acceptance Criteria, sekcji `## Out of scope` i `## Definition of Done`, a następnie uruchamia autonomiczną pętlę 6-Goal driveowaną komendami weryfikacyjnymi. Wzorzec wyjściowy:

> **Stan końcowy + Sposób weryfikacji + Ograniczenia** — zgodnie z `DOC/goal_mode.md`.

Celem jest umożliwienie nadzorowanych (Gate #1.5) overnight runs bez utraty żadnej z twardych bramek v3 (Anti-Rationalization, Hyrum, Chesterton, Beyoncé, DAMP, PR Sizing, Five-Axis Review, ADR).

---

## 2. Decyzje brainstormingowe (z `/plan` mode)

| # | Pytanie | Decyzja |
|---|---|---|
| Q1 | Umiejscowienie w 14-fazowym flow | **Nowa Phase 5.8 + 6-Goal route** (czwarta gałąź obok 6-Sequential / 6-Teams / 6-Ralph). |
| Q2 | Niekompletne AC w Phase 4 | **Hard stop + lista braków** — skrypt waliduje 10 reguł, exit 1 z lokalizacją błędu. |
| Q3 | Approval auto-derived goal | **Nowy Gate #1.5 „Goal Approval"** — jawna zgoda użytkownika przed 6-Goal. |
| Q4 | Composability z istniejącymi flagami | **Exclusive z `/ralph` i `/teams`**, dziedziczy worktree z Phase 5.5, **hard stop w Fragile zone**, dziedziczy Phase 6.5/7/8/9 bez modyfikacji. |

Approach realizacyjny: **Hub-and-spoke (B)** — zwięzłe sekcje w `SKILL.md`, pełny protokół w nowym `references/goal-mode-protocol.md`, dwa nowe skrypty w `scripts/`.

---

## 3. Architektura — co się zmienia w SKILL.md

### 3.1 Frontmatter

```yaml
trigger:
  - "feature-planner v3"
  - "dodaj feature v3"
  - "senior-grade feature"
  - "implement v3"
  - "zaimplementuj v3"
  - "ralph v3"
  - "/goal"          # NEW
  - "goal mode"      # NEW
sources:
  - DOC/material_skill.md
  - DOC/since_skill.md
  - DOC/goal_mode.md  # NEW
```

`description:` dopisek: `… plus /goal mode auto-derived from AC (Phase 5.8 + 6-Goal route)`.

`allowed-tools`, `size-limit`, `extends`, `version` — bez zmian.

### 3.2 Tabela architektury

Tytuł sekcji: **„15 faz + 6 bramek approval"** (było: 14 faz + 5 bramek).

Nowy wiersz wstawiony po Phase 5.7:

| Faza | Cel | Bramka |
|---|---|---|
| 5.8 | Goal Mode decision + auto-derive goal-statement (tylko gdy `/goal`) | **APPROVAL #1.5** |

Numeracja istniejących bramek #1–#5 **nie zmienia się** — Gate #1.5 wsuwa się logicznie między #1 (Plan) i #2 (Implementation start), bez przenumerowania pozostałych.

### 3.3 Anti-Rationalization quick-table — nowy wiersz

| # | Wymówka | Riposta |
|---|---|---|
| 11 | „Goal-statement deryw kompletny, można pominąć Gate #1.5" | Gate #1.5 jest nienegocjowalny w `/goal`. Bez jawnej zgody → brak startu pętli. |

### 3.4 Phase 5.7 — krótki noklik

Dopisek 2 linii: `/goal jest exclusive z /ralph i /teams. Jeśli wykryto kombinację → Phase 5.8 hard-stopuje, eskalacja.`

### 3.5 Nowa sekcja Phase 5.8 (~35 linii w SKILL.md)

```markdown
## Phase 5.8 — Goal Mode decision + auto-derive

Aktywuje się **tylko** gdy prompt zawiera `/goal` lub `goal mode`.

**Exclusivity:**
- `/goal` + `/ralph` → hard stop. „Wybierz jedną strategię pętli."
- `/goal` + `/teams` → hard stop. Konflikt modeli wykonawczych.
- `/goal` + `--fragile` (z Phase 0) → hard stop. Fragile zone wymusza
  Plan-Validate-Execute; autonomia niedozwolona, eskalacja do operatora.

**Goal derivation (deterministyczna):**
1. `sh {baseDir}/dev/feature-planner-v3/scripts/derive-goal-from-ac.sh \
       --plan "$PLAN_FILE"`.
2. Skrypt waliduje 10 reguł (patrz [goal-mode-protocol.md](references/goal-mode-protocol.md)).
3. Brak któregokolwiek pola → exit 1 + lista braków + lokalizacje. Faza stop.
4. Generuje:
   - `plans/<N>-<slug>-goal-statement.md` (markdown, strukturalny).
   - `plans/<N>-<slug>-goal-prompt.txt` (plain text, single block).

**Output Phase 5.8:**
- `goal-statement.md` + `goal-prompt.txt`.
- Komunikat: „Goal-statement wygenerowany. Czekam na APPROVAL #1.5."

## Gate #1.5 — Goal Approval

> [!important] Approval checklist
> - [ ] `goal-statement.md` niepusty (`test -s`).
> - [ ] Trzy sekcje: `## Stan końcowy`, `## Weryfikacja`, `## Ograniczenia`.
> - [ ] Każde AC z planu → bullet w `## Stan końcowy` (1:1, skrypt waliduje).
> - [ ] Każda `Komenda` z AC → blok w `## Weryfikacja`.
> - [ ] `## Out of scope` z planu obecne w `## Ograniczenia`.
>
> **STOP — czekaj na jawną zgodę użytkownika.** Bez „zatwierdzam goal" /
> „proceed goal" / ręcznej edycji + „ok" → brak startu 6-Goal.
```

### 3.6 Phase 6 — routing (+1 wiersz) i 6-Goal sub-route (~20 linii)

Routing:
```
- 6-Sequential — domyślnie dla S/M.
- 6-Teams (2-5 agentów) — dla L gdy parallel safe.
- 6-Ralph — autonomous L z zielonym test gate.
- 6-Goal — autonomous goal-driven loop (tylko gdy /goal, exclusive z Ralph/Teams).
```

6-Goal sub-route (skrótowo w SKILL.md, pełny algorytm w `references/goal-mode-protocol.md`):

```markdown
### 6-Goal — autonomous goal-driven loop

Pre-flight: APPROVAL #1.5 ✅, git status clean, build baseline.

Driver: `sh scripts/run-goal-loop.sh --goal "$GOAL_FILE" --plan "$PLAN_FILE" \
                                    --max-iter 20 --max-time 480`.

Per iteracja:
1. Uruchom wszystkie `## Weryfikacja` cmds → raw log do goal-run-log.md.
2. Wszystkie exit 0 → GREEN, exit pętli, Phase 6.5/7.
3. Pierwsze fail (lex po AC-ID) → kontekst do next iter.
4. Anti-Rationalization quick-check (11 wierszy) przed każdym commitem.
5. PR Sizing + Fragile guard + Out-of-scope guard → STOP przy violation.

Stop warunki (poza GREEN):
- iter > max-iter         → status iter-cap-hit
- elapsed > max-time      → status time-cap-hit
- Fragile/scope violation → status scope-violation
- 3 iter bez progresu     → status no-progress

Każdy stop ≠ GREEN: raport do użytkownika, brak Phase 7, brak merge.
```

### 3.7 Indeks referencji + Sources

W „Protokoły projektowe (warstwa B)":
- `goal-mode-protocol.md` — Phase 5.8 + 6-Goal + Gate #1.5.

W „Skrypty (warstwa B)":
- `scripts/derive-goal-from-ac.sh` — AC → goal-statement.md generator.
- `scripts/run-goal-loop.sh` — autonomous goal-driven loop driver.

W „Sources":
- `DOC/goal_mode.md` — pattern „stan końcowy + weryfikacja + ograniczenia".

---

## 4. Kontrakt `goal-statement.md`

```markdown
---
plan-id: <N>-<slug>
plan-file: plans/<N>-<slug>.md
generated-at: <ISO-8601>
generated-by: scripts/derive-goal-from-ac.sh v<X>
ac-count: <int>
verification-commands: <int>
constraints-count: <int>
---

# Goal Statement — <N>-<slug>

> [!info] Źródło
> Auto-derived z `plans/<N>-<slug>.md` (sekcje `## Acceptance Criteria`,
> `## Out of scope`, `## Definition of Done`). Edytuj ręcznie przed
> APPROVAL #1.5 jeśli trzeba — zmiany pójdą do 6-Goal as-is.

## Stan końcowy

- **<AC-ID>** (<F/N/C>): <Opis AC z planu, 1:1 kopia>
- …

## Weryfikacja

### <AC-ID> — <Test ID>
- **Plik testu**: `<plik testu>`
- **Komenda**: `<Komenda z planu>`
- **Próg sukcesu**: `<format dowodu z DoD>`

### BUILD — clean
- **Komenda**: `sh {baseDir}/dev/feature-planner-v3/scripts/verify-build-clean.sh`
- **Próg**: exit 0, zero warnings.

### AC-COVERAGE — 1:1
- **Komenda**: `sh {baseDir}/dev/feature-planner-v3/scripts/check-ac-coverage.sh \
                  --plan "$PLAN_FILE"`
- **Próg**: 100%.

## Ograniczenia

- **Out of scope** (z planu):
  - <bullet 1>
  - <bullet 2>
- **Scope Discipline (Non-negotiable #5)**: nie modyfikuj plików spoza
  `files-touched` z Phase 4.
- **PR Sizing**: >1000 linii diff = hard stop, split.
- **Anti-Rationalization quick-table**: przechodzona przed każdym commitem.
- **Worktree boundary** (jeśli aktywne): nie wychodź poza `<worktree-path>`.
- **Fragile zone**: dotknięcie `migrations/`, `terraform/`, `k8s/`, `auth/`,
  `.github/workflows/`, `Dockerfile` → STOP scope-violation.
- **Iteration cap**: max 20 (config: `--max-iter`).
- **Time cap**: max 480 min = 8h (config: `--max-time`).

## Definition of Done (agregat)

6-Goal kończy się GREEN tylko gdy:
- [ ] Wszystkie cmd z `## Weryfikacja` exit 0 w jednym przebiegu.
- [ ] Build clean.
- [ ] AC coverage 100%.
- [ ] PR size ≤ target (lub `--justified`).
- [ ] Brak zmian w Fragile zone.
- [ ] `goal-run-log.md` zawiera raw output ostatniej zielonej iter.

## Goal-prompt (plain text)

> Patrz `plans/<N>-<slug>-goal-prompt.txt`.
```

Format `goal-prompt.txt` (single block, max 800 znaków, brak markdown):

```
/goal <Stan końcowy — agregat AC-Opis>. Weryfikacja: <komendy oddzielone
średnikiem, exit 0 wymagany>. Ograniczenia: <Out of scope + scope discipline
+ caps>.
```

Wzorzec wprost z `DOC/goal_mode.md` przykład #1 (test repair).

---

## 5. Kontrakt skryptów

### 5.1 `scripts/derive-goal-from-ac.sh` (~150 linii bash)

```
Usage: derive-goal-from-ac.sh --plan <path> [--out-dir <dir>] [--strict]

Walidacja (kolejność, każdy fail → exit 1 + komunikat z lokalizacją):
  1. Plik istnieje i niepusty.
  2. Sekcja `## Acceptance Criteria` istnieje.
  3. Tabela AC ma nagłówek: AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda.
  4. Każdy wiersz ma wypełnione 6 kolumn (brak `-`, `TBD`, `TODO`, pusty).
  5. AC-ID unikalne, format `AC-\d+`.
  6. Typ ∈ {F, N, C}.
  7. Plik testu — ścieżka istnieje LUB sufiks .test/.spec (akceptuj
     TDD RED jeśli plik nie istnieje).
  8. Komenda — prefiks ∈ {npm, pnpm, yarn, pytest, cargo, go, make, sh,
     bash, node}. Inne → exit 1 (wymaga justified flag).
  9. Sekcja `## Out of scope` istnieje, ≥1 bullet.
  10. Sekcja `## Definition of Done` istnieje z formatem dowodu per AC.

Output (sukces):
  <out-dir>/<basename>-goal-statement.md  # kontrakt z §4
  <out-dir>/<basename>-goal-prompt.txt    # plain text
  stdout: „OK: AC=<N>, Verification=<M>, Constraints=<K>"
  exit 0

Output (fail):
  stderr: lista brakujących pól z lokalizacją (linia X w planie)
  exit 1
```

Skrypt jest **read-only** wobec planu. Nie modyfikuje, nie commituje.

### 5.2 `scripts/run-goal-loop.sh` (~250 linii bash)

```
Usage: run-goal-loop.sh --goal <path> --plan <path>
                       [--max-iter <int>] [--max-time <minutes>]
                       [--worktree <path>] [--files-touched <comma-sep>]
                       [--fragile-paths <comma-sep>] [--dry-run]

Algorytm:
  1. Sparsuj `## Weryfikacja` → lista (AC-ID, cmd, próg).
  2. Sparsuj `## Ograniczenia` → caps + fragile + scope.
  3. Loop:
     a. Iter N: timestamp START → append do goal-run-log.md.
     b. Każde cmd: capture stdout+stderr+exit → append do logu.
     c. Wszystkie exit 0 → GREEN, break.
     d. Pierwsze fail (lex po AC-ID) → focus.
     e. No-progress check: error_hash(stdout+stderr) identyczny jak iter
        N-1 i N-2 → STOP no-progress.
     f. **Hand-off do calling agenta** (Claude session): skrypt drukuje
        do stdout ustrukturyzowany kontekst (goal-prompt + focus cmd + raw
        output + diff od baseline) i czeka na agent commit. Skrypt sam
        NIE woła LLM — jest walidatorem/driverem, nie orchestrator-em
        modelu. Wzorzec: same jak Ralph-loop w v3.
     g. Agent commituje atomic. Pre-commit walidacja (skrypt re-uruchamia):
        - anti-rationalization quick-check (11 wierszy).
        - `git diff --name-only HEAD^` → filter:
          - przecięcie z fragile-paths ≠ ∅ → STOP scope-violation.
          - plik ∉ files-touched → STOP scope-violation.
        - `check-pr-size.sh` → >1000 → STOP pr-too-big.
     h. Inkrementuj iter, sprawdź caps.

Output (zawsze):
  goal-run-log.md  # append-only, raw logs all iter, exit codes, diffy
  goal-result.md   # status (GREEN/iter-cap/time-cap/scope-violation/
                   # no-progress/pr-too-big), iter count, czas, telemetria
  exit 0 jeśli GREEN, exit 1 w pozostałych
```

Skrypt **nie commituje samodzielnie** — orkiestruje agenta, waliduje przed/po. Pure local, brak network deps.

---

## 6. `references/goal-mode-protocol.md` (~180 linii) — outline

1. **Cel i zakres** — kiedy `/goal`, kiedy NIE (lustrzane do Negative Triggers).
2. **Pełna sekwencja Phase 5.8** — krok po kroku z error/recovery.
3. **Format goal-statement.md** — pełny szablon (przekopiowany z §4).
4. **Format goal-prompt.txt** — przykład 1:1 z `DOC/goal_mode.md` (test repair).
5. **Gate #1.5 protokół approval** — checklist + przykłady ręcznej edycji.
6. **6-Goal kontrakt pętli** — pseudo-kod + scenariusze (GREEN, iter-cap, time-cap, scope-violation, no-progress, pr-too-big).
7. **Anti-Rationalization variant dla goal-mode** — wiersz #11 + 3 dodatkowe:
   - „Verification cmd jest flaky, zmień próg" → NIE, fix flakiness albo stop.
   - „Iter cap blisko, skróć test" → NIE, eskalacja.
   - „Cap czasu minął, 1 cmd od zielonego" → NIE, raport + decyzja user.
8. **Telemetry kontrakt** — co MUSI być w `goal-run-log.md` i `goal-result.md`. Format sekcji `Goal-loop telemetry` w ADR Phase 9.
9. **Bezpieczeństwo overnight runs** — checklist (worktree, auto-mode, brak sekretów w cmd, brak destruktywnych komend w `## Weryfikacja`).
10. **Antywzorce** — z `DOC/goal_mode.md` + 3 dodatkowe v3:
    - Goal-statement bez Out of scope → blokada.
    - 1 cmd dla wszystkich AC (np. tylko `npm test`) → loss of 1:1 mapping.
    - `--max-iter 0` bez justified → ban.

---

## 7. Composability matrix

| Combo | Wynik | Powód |
|---|---|---|
| `/goal` sam | OK | Default single autonomous run. |
| `/goal` + `/ralph` | **Hard stop** | Dwie strategie pętli. |
| `/goal` + `/teams` | **Hard stop** | Konflikt modeli wykonawczych. |
| `/goal` + worktree S | Opt-in (`--worktree`) | Dziedziczone z Phase 5.5. |
| `/goal` + worktree M | Default ON | Dziedziczone. |
| `/goal` + worktree L | Obligatoryjny | Dziedziczone. |
| `/goal` + `--fragile` | **Hard stop** | Plan-Validate-Execute, brak autonomii. |
| `/goal` + bugfix (`fix:`) | OK, Phase 6.5 dziedziczone | Prove-It Pattern egzekwowany. |
| `/goal` + UI (M+) | OK, Gate #4 dziedziczone | Live preview ręczny po GREEN. |

---

## 8. Niezmiennice (co `/goal` NIE robi)

- Nie omija **żadnej** bramki #2/#3/#4/#5 — autonomia jest tylko między #1.5 a #2 (driver pętli).
- Nie modyfikuje planu ani goal-statement.md w trakcie pętli. Zmiana AC → STOP + regeneracja + ponowne Gate #1.5.
- Nie woła sieciowych API. Wszystko local.
- Nie commituje samodzielnie — agent commituje, skrypt waliduje.
- Nie omija Phase 7 (testing scopes), Phase 8 (Five-Axis Review) ani Phase 9 (ADR + goal-loop telemetry).
- Nie ingeruje w v2 (`dev/feature-planner/`).

---

## 9. Token budget

| Plik | Stan | Po designie | Δ |
|---|---:|---:|---:|
| `dev/feature-planner-v3/SKILL.md` | 345 / 500 | ~414 / 500 | +69 |
| `dev/feature-planner-v3/references/goal-mode-protocol.md` | — | ~180 | +180 |
| `dev/feature-planner-v3/scripts/derive-goal-from-ac.sh` | — | ~150 | +150 |
| `dev/feature-planner-v3/scripts/run-goal-loop.sh` | — | ~250 | +250 |
| `dev/feature-planner-v3/tests/fixtures/complete-plan.md` | — | ~80 | +80 |
| `dev/feature-planner-v3/tests/fixtures/incomplete-plan.md` | — | ~70 | +70 |
| `DOC/goal_mode.md` | 48 | 49 | +1 |

Bufor w SKILL.md: 86 linii (zostaje na drobne korekty po self-review).

---

## 10. Pliki — bilans końcowy

**Nowe (5):**
1. `dev/feature-planner-v3/references/goal-mode-protocol.md`
2. `dev/feature-planner-v3/scripts/derive-goal-from-ac.sh`
3. `dev/feature-planner-v3/scripts/run-goal-loop.sh`
4. `dev/feature-planner-v3/tests/fixtures/complete-plan.md` — fixture do AC-4/5 (kompletny plan Phase 4 z poprawną tabelą AC).
5. `dev/feature-planner-v3/tests/fixtures/incomplete-plan.md` — fixture do AC-3 (plan z brakującym `Komenda` w wierszu AC).

**Zmodyfikowane (2):**
1. `dev/feature-planner-v3/SKILL.md` (patch ~69 linii, kontrakty z §3).
2. `DOC/goal_mode.md` (+1 linia, link do reference protocol).

**Niezmienione:**
- Wszystkie pozostałe references (`anti-rationalization.md`, `fragile-operations-protocol.md`, etc.).
- Pozostałe scripts (`check-pr-size.sh`, `check-ac-coverage.sh`, etc.).
- `dev/feature-planner/` (v2) — nieruszany.
- `DOC/material_skill.md`, `DOC/since_skill.md` — nieruszane.

---

## 11. Acceptance Criteria dla samego designu (dogfooding)

| AC-ID | Typ | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | `SKILL.md` zawiera nową Phase 5.8 i Gate #1.5 | T-1 | manual review | `grep -c "Phase 5.8\|Gate #1.5" dev/feature-planner-v3/SKILL.md` (≥2) |
| AC-2 | F | `SKILL.md` mieści się w 500-line hard limit | T-2 | manual review | `wc -l dev/feature-planner-v3/SKILL.md` (≤500) |
| AC-3 | F | `derive-goal-from-ac.sh` waliduje 10 reguł i exituje na braku | T-3 | scripts/tests | `bash scripts/derive-goal-from-ac.sh --plan tests/fixtures/incomplete-plan.md; [ $? -eq 1 ]` |
| AC-4 | F | `derive-goal-from-ac.sh` generuje goal-statement.md zgodny z §4 | T-4 | scripts/tests | `bash scripts/derive-goal-from-ac.sh --plan tests/fixtures/complete-plan.md && test -s plans/*-goal-statement.md` |
| AC-5 | F | `run-goal-loop.sh --dry-run` parsuje goal i wypisuje plan iteracji | T-5 | scripts/tests | `bash scripts/run-goal-loop.sh --goal tests/fixtures/goal.md --plan tests/fixtures/complete-plan.md --dry-run` |
| AC-6 | C | `/goal` + `/ralph` daje hard stop (reguła w SKILL.md) | T-6 | manual review | `grep -qE "exclusive z /ralph i /teams\|/goal.*ralph.*hard stop" dev/feature-planner-v3/SKILL.md` |
| AC-7 | C | `/goal` + `--fragile` daje hard stop (reguła w SKILL.md) | T-7 | manual review | `grep -qE "fragile.*hard stop\|--fragile.*niedozwolony" dev/feature-planner-v3/SKILL.md` |
| AC-8 | N | `references/goal-mode-protocol.md` istnieje i ma 10 sekcji wg §6 | T-8 | manual review | `grep -c "^## " dev/feature-planner-v3/references/goal-mode-protocol.md` (≥10) |

## Out of scope

- Implementacja samego `/goal` jako CLI — to jest skill prompt, nie binarka.
- Integracja z zewnętrznymi orkiestratorami (ralph-tui, codex itp.) — osobne skille.
- Telemetria do zewnętrznych systemów (Grafana, Sentry). `goal-run-log.md` jest lokalny.
- Modyfikacja v2 (`dev/feature-planner/`).
- UI/screenshots dla goal-statement — pozostaje plain markdown.

## Definition of Done dla designu

- [ ] Spec zapisany w `docs/superpowers/specs/2026-05-13-feature-planner-v3-goal-mode-design.md`.
- [ ] Self-review przeszedł (placeholder scan, internal consistency, scope, ambiguity).
- [ ] User zaakceptował spec.
- [ ] Następny krok: invoke `superpowers:writing-plans` z tym spec-em jako wejściem.

---

## 12. Następne kroki

1. **Self-review** spec-u (inline fixes).
2. **User review** — user czyta plik, akceptuje / żąda zmian.
3. **`superpowers:writing-plans`** — z tym spec-em jako requirements, planowanie sekwencji implementacyjnej (3 nowe pliki + 2 patche).
