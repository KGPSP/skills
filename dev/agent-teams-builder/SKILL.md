---
name: agent-teams-builder
description: Orkiestracja zespołu sub-agentów (Planner + Generator + Evaluator + opcjonalni specjaliści) wg wzorca Generator-Ewaluator do realizacji złożonych zadań programistycznych z presją rywalizacyjną, twardymi rubrykami i mechanizmem pivota. Użyj dla zadań typu "zbuduj aplikację X od zera", "zrefaktoryzuj moduł Y end-to-end", "zrealizuj feature pod /goal", gdzie pojedynczy agent w pętli wpada w pułapkę łatania zepsutego fundamentu.
trigger:
  - "zbuduj zespół agentów do"
  - "uruchom agent teams"
  - "generator-ewaluator"
  - "zbuduj aplikację od zera"
  - "/team"
  - "/goal" # delegacja do goal-mode-protocol.md
do-not-trigger-for:
  - "przeczytaj plik X"
  - "wytłumacz co robi ta funkcja"
  - "popraw literówkę w komentarzu"
  - "1-liniowa zmiana w istniejącym module"
  - "review jednego PR" # użyj feature-planner-v3
  - eksploracja repozytorium bez intencji budowania
  - zadania mieszczące się w jednej sesji jednego agenta (<2h pracy)
model: claude-opus-4-7
allowed-tools: ['Bash', 'Read', 'Edit', 'Write', 'Grep', 'Glob', 'TodoWrite', 'Task']
sources:
  - DOC/material_skill.md
  - DOC/since_skill.md
  - DOC/agent-teams-generator-ewaluator.md
  - DOC/goal_mode.md
version: v1
size-limit: 500-lines-hard
---

# agent-teams-builder — uprząż Generator-Ewaluator dla zadań programistycznych

> [!quote] Anti-Laziness preamble (since_skill.md §6)
> Najwyższa waga jakości. **Nie optymalizuj pod szybkość implementacji.** Każda bramka, każdy artefakt dowodowy i każda iteracja rubryki jest nienegocjowalna. Generator nie jest sędzią we własnej sprawie — Ewaluator ma prawo do resetu pracy.

> [!important] 5 Non-negotiables (material_skill.md §8)
> 1. Uwidaczniaj założenia przed budowaniem.
> 2. Zatrzymaj się przy konflikcie wymagań.
> 3. Wybieraj rozwiązania nudne i oczywiste.
> 4. Dostarczaj twardy dowód, nie deklarację.
> 5. Dotykaj tylko tego, o co cię poproszono.

> [!warning] Strefa pracy
> Ten skill operuje w **trybie autonomicznym wielogodzinnym**. Przy operacjach destruktywnych (pivot = `rm` katalogu, force push, drop bazy) wchodzi w **Plan-Validate-Execute** — patrz `references/pivot-protocol.md`. Bez wyjątków.

---

## Konwencja zapisu stanu (filesystem persistence)

Agent Teams **nie polegają na oknie kontekstowym** (context rot). Stan dzielony przez pliki:

| Plik | Format | Kto pisze | Kto czyta | Zasada |
|---|---|---|---|---|
| `state/plan.md` | Markdown | Planner | Wszyscy | Wstrzykiwany co N iteracji |
| `state/contracts/sprint-{n}.json` | **JSON** | Generator + Evaluator (negocjacja) | Wszyscy | **Dopisuj, nie nadpisuj** |
| `state/feature_list.json` | **JSON** | Generator (status) | Wszyscy | **Dopisuj, nie nadpisuj** |
| `state/breadcrumbs.json` | **JSON** | Każdy agent (log iteracji) | Wszyscy + human | Append-only, znacznik czasu |
| `state/rubric/{phase}.md` | Markdown | Planner / Evaluator | Evaluator | Few-shot examples obowiązkowe |

**Zasada:** Markdown niszczy historię (model nadpisuje cały plik). JSON wymusza dopisywanie. Patrz `references/memory-filesystem.md`.

---

## Procedura (Process over Prose)

### Faza 0 — Bootstrap (Plan-Validate-Execute)

1. Uruchom `scripts/init-team-state.sh {project-name}` — tworzy `state/` z pustymi plikami, inicjalizuje `git init`, opcjonalnie `git worktree` dla pracy równoległej.
2. **Walidacja:** wklej output `ls -la state/` oraz `git status` (artefakt dowodowy).
3. **Stop-gate:** Jeśli istnieje już `state/` z poprzedniej sesji — załaduj `references/memory-filesystem.md §recovery` zanim cokolwiek nadpiszesz.

**Exit criterion:** `state/breadcrumbs.json` zawiera wpis `{"ts": "...", "actor": "bootstrap", "event": "init"}` + repo git ma initial commit.

### Faza 1 — Planner (specyfikacja sprintów)

1. Uruchom sub-agenta **Planner** (osobne okno kontekstowe) z promptem: "Zamień prompt użytkownika na specyfikację wysokopoziomową podzieloną na sprinty/user stories. **Bez szczegółów technicznych.** Output: `state/plan.md`."
2. Planner **nie pisze kodu**. Nie projektuje API. Nie wybiera bibliotek. Błąd na tym etapie kaskaduje przez godziny pracy.
3. Output Plannera musi zawierać:
   - Listę 3-15 sprintów z mierzalnymi celami biznesowymi.
   - Listę zewnętrznych zależności (API, biblioteki, dane).
   - Listę **niewiadomych do eskalacji** (Non-negotiable #1: uwidaczniaj założenia).

**Exit criterion:** `state/plan.md` istnieje, zawiera sekcję "Sprints", "Dependencies", "Open Questions". Hash gita w breadcrumbs.

### Faza 2 — Spawn ról (Claude Code Agent Teams)

1. **Skopiuj definicje sub-agentów** do `.claude/agents/` w katalogu repo projektu:
   ```bash
   mkdir -p .claude/agents
   cp {skill-dir}/agents/planner.md   .claude/agents/
   cp {skill-dir}/agents/generator.md .claude/agents/
   cp {skill-dir}/agents/evaluator.md .claude/agents/
   ```
   Każdy plik ma frontmatter `name`, `description`, `tools` (allowed-tools per rola), `model`.
2. **Weryfikacja izolacji** narzędzi PRZED pierwszym wywołaniem:
   - Generator: `tools` zawiera `Read, Write, Edit, Bash, Grep, Glob`. **NIE zawiera** `mcp__playwright__*`, `mcp__chrome-devtools__*`, `mcp__computer-use__*`.
   - Evaluator: `tools` zawiera `Read, Bash, Grep, Glob, Write` (Write tylko do `state/evidence/` i `state/contracts/` przez `Bash`). **NIE zawiera** `Edit`.
   - Planner: `tools` zawiera `Read, Write, Grep, Glob, Bash`. **NIE zawiera** `Edit` (Planner pisze tylko `state/plan.md` raz).
   Uruchom: `bash scripts/verify-role-isolation.sh`.
3. **Wywołanie sub-agenta** przez Task tool (parent agent w głównym oknie):
   ```
   Task(
     description: "Spawn Planner — wypełnij state/plan.md",
     subagent_type: "planner",
     prompt: "<oryginalny prompt użytkownika + ścieżka do assets/plan-template.md>"
   )
   ```
   Analogicznie dla Generatora i Evaluatora w fazach 3-4.
4. **Każdy spawn** — wpis w `state/breadcrumbs.json`:
   ```bash
   bash scripts/append-breadcrumb.sh "<parent>" "role_spawned" \
     "$(jq -nc --arg n planner --arg t "Read,Write,Bash,Grep,Glob" '{name: $n, tools: $t}')"
   ```
5. **Skalowanie do 7+ agentów** (projekty >5 sprintów): dodaj `frontend-builder`, `backend-builder`, `integrator` + ich Evaluatory do `.claude/agents/`. Patrz `references/role-mapping.md §3`.

**Żelazna reguła:** każdy agent generujący cokolwiek dostaje dedykowanego ewaluatora. Brak ewaluatora = brak presji rywalizacyjnej = halucynacje.

**Exit criterion:** pliki `.claude/agents/{planner,generator,evaluator}.md` istnieją + `scripts/verify-role-isolation.sh` exit 0 + 3 breadcrumby `role_spawned`.

### Faza 3 — Negocjacja kontraktu (Generator ↔ Evaluator)

Faza najważniejsza. Bez sztywnego kontraktu — rozmyta krytyka → generator ignoruje → patologiczna pętla.

1. Generator proponuje: "Zbuduję funkcję X. Zweryfikuj testując Y, Z." → zapisuje w `state/contracts/sprint-{n}.draft.json`.
2. Evaluator odrzuca/modyfikuje: zakres zbyt szeroki, testy zbyt słabe, brak edge case'ów → dopisuje notatki.
3. **Iteruj przez wymianę plików** aż obaj agenci dojdą do porozumienia. Wstrzykuj `state/plan.md` co 3-4 wymiany żeby agenci nie zgubili celu.
4. **Granularność:** kontrakt MUSI zawierać ≥15 konkretnych kryteriów dla pojedynczej funkcji (w cytowanym projekcie Anthropic — 27). **Twarde progi binarne, nie skale 1-10.** Patrz `references/contract-negotiation.md`.
5. Zatwierdzony kontrakt: `state/contracts/sprint-{n}.json` (rename z .draft.json) + `scripts/check-contract-coverage.sh {n}` zwraca exit 0.

**Exit criterion:** `scripts/check-contract-coverage.sh {n}` → exit 0 + plik ma ≥15 kryteriów binarnych + Evaluator dopisał "accepted: true" w breadcrumbs.

### Faza 4 — Pętla generator-ewaluator (hill climbing)

Powtarzaj **dla każdego sprintu** osobno:

1. **Generator** pisze kod zgodnie z kontraktem. Commit po każdej działającej zmianie.
2. **Smoke test** — `scripts/smoke-test-runner.sh` uruchamia aplikację lokalnie (npm start / docker-compose / cokolwiek). **Bez tego ewaluator nie wchodzi.** Brak smoke testu = generator pisze do śmietnika.
3. **Evaluator** uruchamia aplikację (Playwright/Chrome/Computer Use), wykonuje scenariusze z kontraktu, robi screenshots, weryfikuje wg rubryki. Patrz `references/evaluator-rubric.md`.
4. **Feedback do Generatora** — **wyłącznie sucha krytyka** (`"przycisk Save nie reaguje na klik"`), **bez** podpowiedzi rozwiązania (`"dodaj onClick handler"`). Generator sam szuka.
5. **Audyt:** każda iteracja → wpis w `state/breadcrumbs.json` z polami: `iteration`, `generator_action`, `evaluator_verdict`, `passed_criteria`, `failed_criteria`, `runtime_evidence_path`.
6. **Loop until** `passed_criteria == total_criteria` LUB `iteration >= MAX_ITERATIONS` (domyślnie 5).

**Exit criterion:** wszystkie kryteria z kontraktu = passed + screenshot/log w `state/evidence/sprint-{n}/` + `git commit` z hash w breadcrumbs.

### Faza 5 — Pivot (jeśli zacięcie)

Jeśli po `MAX_ITERATIONS` (domyślnie 5) generator nie wspina się na rubryce:

1. Evaluator wysyła do Generatora komunikat: `"podejście nie działa, usuń wszystko, zacznijmy od nowa"`.
2. **Plan-Validate-Execute** dla operacji destruktywnej:
   - **Plan:** Evaluator wypisuje co konkretnie usunąć (lista plików), dlaczego (które kryteria zawiodły), z czego startować (nowy szkielet).
   - **Validate:** Generator weryfikuje plan z bazą prawdy (kontrakt + plan Plannera) i akceptuje **pisemnie** w breadcrumbs.
   - **Execute:** `scripts/pivot-trigger.sh {sprint-n}` — zapisuje branch `archive/sprint-{n}-pivot-{timestamp}`, czyści katalog feature, zostawia szkielet.
3. **Opcjonalny human hook:** jeśli `PIVOT_REQUIRES_HUMAN=1` w env, skrypt zatrzymuje proces i prosi człowieka o klawisz.

Patrz `references/pivot-protocol.md`.

**Exit criterion:** branch `archive/...` istnieje + breadcrumbs ma `event: "pivot_executed"` z hashami przed/po + faza 3 startuje od nowa z czystą kartą.

### Faza 6 — Verify (audyt dowodowy)

Po zakończeniu wszystkich sprintów:

1. Uruchom `scripts/verify-evaluator-rubric.sh` — sprawdza czy wszystkie kontrakty mają `status: "passed"` + każdy ma evidence + brak skali 1-10 (tylko binarne).
2. Uruchom `scripts/verify-non-negotiables.sh` — wymusza 5 zasad nienegocjowalnych (assumptions, brak blockerów open, evidence per passed, scope discipline).
3. Uruchom `scripts/check-evidence-completeness.sh --all-sprints` — każde `passed: true` ma plik dowodowy.
4. Uruchom `scripts/check-breadcrumbs-append-only.sh` — brak usuniętych wpisów (audit trail).
5. Five-Axis Review (opcjonalnie, jeśli `dev/feature-planner-v3` jest zainstalowany): Correctness, Readability, Architecture, Security, Performance — wywołaj przez Task tool z `subagent_type: "reviewer"` z feature-planner-v3.
6. **Beyoncé Rule:** każda funkcja w diffie ma test. Brak testu = blokada (heurystyka: `git diff --name-only HEAD~N | grep -E "src/.*\\.(ts|js|py)$" | xargs -I {} sh -c 'test -f "tests/$(basename {} | sed s/src//).spec.{ts,js,py}"'`).

**Exit criterion:** wszystkie checki zielone + raport `state/verify-report.md` zawiera linki do evidence per sprint + `git log --oneline` pokazuje atomowe commity ≤300 linii.

### Faza 7 — Ship

1. PR Sizing check: każdy commit ≤100 linii (≤300 z uzasadnieniem, >1000 = blokada). Sprawdź: `git log --stat HEAD~N..HEAD`.
2. CHANGELOG entry: ręcznie dopisz wersję + zmiany do `CHANGELOG.md` (lub przez `keepachangelog` jeśli zainstalowany).
3. Tag: `git tag -a v{x.y.z} -m "{description}"`.
4. **Human approval gate** — przed `git push` do remote zatrzymaj proces. Trzymaj się zasady: `/goal` NIE robi `git push` (patrz `references/goal-mode-protocol.md §4`).

**Exit criterion:** `git tag` istnieje + `git log` clean + CHANGELOG zaktualizowany.

---

## Anti-Rationalization

Tabela ripost. **Każda riposta = blokada, nie sugestia.** Format: "Odrzucono. {konsekwencja}. {co zamiast}."

| Wymówka | Riposta (blokada) |
|---|---|
| „Pominę negocjację kontraktu, ten sprint jest prosty" | Odrzucono. Rozmyte kryteria → rozmyta krytyka → generator ignoruje → patologiczna pętla. **Minimum 15 kryteriów binarnych nawet dla 5-liniowej funkcji.** |
| „Evaluator może mieć dostęp do edytora, szybciej naprawi" | Odrzucono. Łamie regułę presji rywalizacyjnej. Evaluator zostaje krytykiem, nie współautorem. Wycofaj uprawnienie + wpis w breadcrumbs. |
| „Generator zrobi screenshot zamiast Evaluatora" | Odrzucono. Sędzia we własnej sprawie. Każdy artefakt dowodowy generuje **inny** agent niż autor. |
| „Pominę smoke test, kod się skompilował" | Odrzucono. Build clean ≠ runtime ok. **Smoke test przed wejściem Evaluatora jest nienegocjowalny.** |
| „Po 5 iteracjach zrobię jeszcze 10, blisko jestem" | Odrzucono. `MAX_ITERATIONS` to twardy próg. Brak progresji na rubryce = pivot. Łatanie zepsutego fundamentu kosztuje więcej niż reset. |
| „Wpiszę feedback w Markdown, łatwiej czytać" | Odrzucono. Markdown jest nadpisywany. **Breadcrumbs i status idą do JSON.** Markdown tylko dla negocjacji kontraktów i rubryk. |
| „Refaktoryzowałem przy okazji moduł obok" | Odrzucono. Scope Discipline (Non-negotiable #5). Cofnij, zgłoś osobny sprint, zaktualizuj plan. |
| „Skala 7/10 wystarczy dla tego kryterium" | Odrzucono. Modele osiadają na 7/10 i przepuszczają niestabilny kod. **Tylko progi binarne** (`tests pass: yes/no`, `0 TypeScript errors`, `0 console.error w Playwright`). |
| „Ewaluator może użyć Markdown do `feature_list`" | Odrzucono. JSON dla statusu i list. Markdown nadpisuje całe pliki, JSON wymusza dopisywanie kluczy. |
| „Pivot bez archiwizacji branchu, kasujemy" | Odrzucono. Plan-Validate-Execute dla operacji destruktywnych. Archiwizacja branchu = obowiązek, nie opcja. |
| „Wyrzucam ten test/walidator — wygląda na martwy" | Odrzucono. **Płot Chestertona.** Zanim usuniesz cokolwiek pozornie zbędnego, sprawdź `git log -p` + breadcrumbs + ADR. Brak wyjaśnienia = obowiązek pozostawienia. |
| „Zmieniam sygnaturę funkcji helpera — nikt nie korzysta" | Odrzucono. **Prawo Hyruma.** `grep -rn 'fnName('` zwraca >0 = ktoś korzysta. Każda zmiana interfejsu wymaga analizy wpływu. |
| „Pominę test, fix to 5 linii" | Odrzucono. **Zasada Beyoncé.** Każda zmiana w kodzie zasługuje na test. Heurystyka: `git diff --name-only` z `src/` → odpowiadające testy w `tests/`. |
| „Wyodrębniłem helper z 3 testów — DRY" | Odrzucono. **DAMP > DRY w testach.** Test musi czytać się jak specyfikacja. Cofnij abstrakcję. |

Pełna tabela z Google DNA (Hyrum/Chesterton/Beyoncé/DAMP) + domenowymi wariantami: `references/anti-rationalization.md §5`.

---

## Definition of Done

- [ ] **Clean build** każdego sprintu — warnings as errors, 0 błędów lintera.
- [ ] **Beyoncé Rule** — każda funkcja w diffie ma test (unit/integration/E2E zgodnie z piramidą 80/15/5).
- [ ] **Runtime evidence** — screenshot z Playwright LUB log z Computer Use LUB output endpointu w `state/evidence/sprint-{n}/`.
- [ ] **PR Sizing** — każdy commit ≤100 linii (≤300 z uzasadnieniem). >1000 = blokada i podział.
- [ ] **Scope Discipline** — `git diff --name-only` zwraca tylko pliki ze sprintu z `state/plan.md`.
- [ ] **Contract coverage** — `scripts/check-contract-coverage.sh` zielony dla każdego sprintu.
- [ ] **Rubric — twarde progi** — `scripts/verify-evaluator-rubric.sh` potwierdza zero skal 1-10.
- [ ] **Breadcrumbs append-only** — `jq '. | length' state/breadcrumbs.json` rośnie monotonicznie; brak `git diff` pokazującego usunięte wpisy.
- [ ] **Independent verification** — kto pisał kod (Generator) NIE pisał ewidencji (Evaluator). Verified w breadcrumbs.
- [ ] **Pivot audit (jeśli dotyczy)** — branch `archive/...` istnieje, pisemna akceptacja Generatora w breadcrumbs.
- [ ] **CHANGELOG + tag** — wersja zaktualizowana, tag wystawiony.

Pełna procedura zbierania dowodów: `references/dod-evidence-protocol.md`.

---

## Progresywne ładowanie referencji

Załaduj `references/{plik}.md` **tylko** gdy spełniony warunek:

| Warunek | Plik do załadowania |
|---|---|
| Faza 3 (negocjacja kontraktu) | `contract-negotiation.md` |
| Faza 4 (ewaluator zaczyna ocenę) | `evaluator-rubric.md` |
| Pętla zacina się ≥3 iteracji | `pivot-protocol.md` |
| Bootstrap LUB recovery z istniejącego `state/` | `memory-filesystem.md` |
| Spawn ról LUB skalowanie do 5+ sprintów | `role-mapping.md` |
| User napisał `/goal` | `goal-mode-protocol.md` |
| Generator wpadł w wymówkę nieujętą w tabeli | `anti-rationalization.md` |
| Konflikt wymagań LUB eskalacja | `non-negotiables.md` |
| Faza 6 (verify) | `dod-evidence-protocol.md` (Five-Axis Review przez feature-planner-v3 jeśli zainstalowany) |
| Kalibracja skilla po 3+ realnych przebiegach | `traces-reading.md` |

**Reguła:** nie ładuj wszystkiego na raz. Token budget L2 ≤5000. Reszta progresywnie.

---

## Calibration — strefa pracy

| Faza | Strefa | Rygor |
|---|---|---|
| 0 (bootstrap), 7 (ship) | Fragile Operations | Powtarzaj komendy z runbooka krok-po-kroku. Plan-Validate-Execute. |
| 1 (Planner), 2 (spawn), 3 (negocjacja) | Strefa wolna | Agent uzasadnia wybory, szeroki dialog. |
| 4 (pętla gen-eval) | Strefa wolna dla Generatora, **Fragile** dla Evaluatora | Evaluator nie improwizuje rubryki — czyta z pliku. |
| 5 (pivot) | **Destruktywne** | Plan-Validate-Execute obowiązkowe. Opcjonalny human hook. |
| 6 (verify) | Fragile | Wszystkie skrypty exit 0 zanim faza zamknięta. |

---

## Sources

- [DOC/material_skill.md](../../DOC/material_skill.md) — pryncypia procesowe: Process over Prose, Anti-Rationalization, DoD, 5 Non-negotiables.
- [DOC/since_skill.md](../../DOC/since_skill.md) — pryncypia projektowe skilla: token budget, kebab-case, Negative Triggers, Plan-Validate-Execute, Beyoncé Rule.
- [DOC/agent-teams-generator-ewaluator.md](../../DOC/agent-teams-generator-ewaluator.md) — wzorzec Generator-Ewaluator (§1-10).
- [DOC/goal_mode.md](../../DOC/goal_mode.md) — przykłady `/goal` z mierzalną weryfikacją.
- Reference implementation: `dev/feature-planner-v3/` (struktura references/ + scripts/).
