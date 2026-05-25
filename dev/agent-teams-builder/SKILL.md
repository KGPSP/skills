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
  - "/YOLO" # autonomia bez bramek — patrz references/approval-gates-protocol.md §9
do-not-trigger-for:
  - "przeczytaj plik X"
  - "wytłumacz co robi ta funkcja"
  - "popraw literówkę w komentarzu"
  - "1-liniowa zmiana w istniejącym module"
  - "review jednego PR" # użyj audited-feature-workflow
  - eksploracja repozytorium bez intencji budowania
  - zadania mieszczące się w jednej sesji jednego agenta (<2h pracy)
model: claude-opus-4-7
allowed-tools: ['Bash', 'Read', 'Edit', 'Write', 'Grep', 'Glob', 'TodoWrite', 'Task']
sources:
  - DOC/material_skill.md
  - DOC/since_skill.md
  - DOC/agent-teams-generator-ewaluator.md
  - DOC/goal_mode.md
version: v1.9.0
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
> Ten skill operuje w **trybie nadzorowanym z 6 bramkami akceptacji człowieka** (human-in-the-loop). Pętla **zatrzymuje się** na każdej bramce i czeka na jawną zgodę — także w trybie `/goal`. Przy operacjach destruktywnych (pivot = `rm` katalogu, force push, drop bazy) dodatkowo wchodzi w **Plan-Validate-Execute** — patrz `references/pivot-protocol.md`. Bez wyjątków.

> [!important] 6 APPROVAL GATES (pełny protokół: `references/approval-gates-protocol.md`)
> Proces ZATRZYMUJE się i czeka na jawną frazę akceptującą człowieka:
> 1. **GATE #1 — Plan** (po Fazie 1) — `state/plan.md` + PRD.
> 2. **GATE #2 — Kontrakty** (po Fazie 3) — `state/contracts/sprint-{n}.json`.
> 3. **GATE #3 — Sprint** (po każdym sprincie w Fazie 4) — `state/sprint-reports/sprint-{n}.md`.
> 4. **GATE #4 — QA/Runtime** (po QA) — `state/qa-reports/sprint-{n}.md` + screenshoty.
> 5. **GATE #5 — Code Review** (Faza 6) — `docs/code-reviews/CR-sprint-{n}-*.md`.
> 6. **GATE #6 — Ship** (Faza 7) — `state/final-report.md`.
>
> **Naruszenie litery bramki = naruszenie ducha bramki.** Cisza ≠ zgoda. `/goal` respektuje wszystkie bramki.

> [!caution] Tryb `/YOLO` — pełna autonomia (bramki OFF)
> `/YOLO` **wyłącza human-in-the-loop**: na każdej bramce agent sam podejmuje decyzję (Planner stawia 3 hipotezy i wybiera najbardziej prawdopodobną), auto-zatwierdza artefakt (breadcrumb `gate_approved` z `actor: "yolo"`, `auto_approved: true`) i kontynuuje **bez czekania na człowieka**. Najmocniejszy w parze z `/goal`: `/YOLO /goal <spec>` = w pełni autonomiczna pętla do celu (przywraca tryb „odpal i zostaw" sprzed v1.7.0, teraz jako jawny opt-in).
>
> **Czego `/YOLO` NIE znosi:** (1) walidatory `verify-*.sh` dalej muszą przechodzić — autonomia ≠ udawanie że kod działa; fail walidatora → STOP + `state/blockers.md`; (2) twarde zabezpieczenia destrukcyjne — brak `git push`, `npm publish`, `DROP TABLE`/`DELETE` bez WHERE, `rm` poza katalogiem feature; (3) Plan-Validate-Execute dla pivota. Pełny protokół: `references/approval-gates-protocol.md §9`.

---

## Konwencja zapisu stanu (filesystem persistence)

Agent Teams **nie polegają na oknie kontekstowym** (context rot). Stan dzielony przez pliki w **dwóch warstwach** (`state/` ephemeral + `docs/` committable — patrz `references/documentation-protocol.md`):

### Warstwa ephemeral (state/, gitignored)

| Plik | Format | Kto pisze | Kto czyta | Zasada |
|---|---|---|---|---|
| `state/plan.md` | Markdown | Planner | Wszyscy | 11 sekcji (planning-rigor) |
| `state/prd/sprint-{n}.md` | Markdown | Planner | Wszyscy | 8 sekcji PRD, baza dla kontraktu |
| `state/contracts/sprint-{n}.json` | **JSON** | Generator + Evaluator (negocjacja) | Wszyscy | **Dopisuj, nie nadpisuj** |
| `state/feature_list.json` | **JSON** | Generator (status) | Wszyscy | **Dopisuj, nie nadpisuj** |
| `state/breadcrumbs.json` | **JSON** | Każdy agent (log iteracji) | Wszyscy + human | Append-only, znacznik czasu |
| `state/rubric/{phase}.md` | Markdown | Planner / Evaluator | Evaluator | Few-shot examples obowiązkowe |
| `state/todo.md` | Markdown | Generator (snapshot per iteracja) | Wszyscy | Persistowany TodoWrite |
| `state/retrospectives/sprint-{n}.md` | Markdown | Evaluator (po passed) | Wszyscy + human | 8 sekcji retro |
| `state/sprint-reports/sprint-{n}.md` | Markdown | Evaluator (przed GATE #3) | Human | Raport wykonania do akceptacji |
| `state/qa-reports/sprint-{n}.md` | Markdown | playwright-runner (po fazie 5 QA) | Evaluator, human | Agregacja qa-summary.json |
| `state/decision-log.md` | Markdown | Każdy agent (lekkie decyzje) | Wszyscy | Append-only |
| `state/sessions/{YYYY-MM-DD}.md` | Markdown | Auto (skrypt) | Human | Auto-generated |
| `state/final-report.md` | Markdown | Planner (po fazie 7) | Human | Executive summary |
| `state/blockers.md` | Markdown | Każdy agent | Human | Eskalacje |

### Warstwa committable (docs/, w gicie projektu)

| Plik | Format | Kto pisze | Kiedy |
|---|---|---|---|
| `docs/adr/ADR-{NNNN}-{slug}.md` | Markdown | Generator (lub inny agent) | Per decyzja architektoniczna |
| `docs/code-reviews/CR-sprint-{n}-{slug}.md` | Markdown | Evaluator (Five-Axis Review) | Per sprint passed |
| `docs/reports/final-{slug}.md` | Markdown | Planner | Po fazie 7 (kopia z state/) |

**Zasady:**
- Markdown niszczy historię (model nadpisuje cały plik). JSON wymusza dopisywanie. Patrz `references/memory-filesystem.md`.
- `state/` to ephemeral per-sesja, w `.gitignore`. `docs/` to trwała wiedza projektu, commitowana.
- Pełen audit trail dokumentów: `references/documentation-protocol.md`. Walidator: `scripts/verify-documentation.sh`.

---

## Procedura (Process over Prose)

### Faza 0 — Bootstrap (Plan-Validate-Execute)

1. Uruchom `scripts/init-team-state.sh {project-name}` — tworzy `state/` z pustymi plikami, inicjalizuje `git init`, opcjonalnie `git worktree` dla pracy równoległej.
2. **Walidacja:** wklej output `ls -la state/` oraz `git status` (artefakt dowodowy).
3. **Stop-gate:** Jeśli istnieje już `state/` z poprzedniej sesji — załaduj `references/memory-filesystem.md §recovery` zanim cokolwiek nadpiszesz.

**Exit criterion:** `state/breadcrumbs.json` zawiera wpis `{"ts": "...", "actor": "bootstrap", "event": "init"}` + repo git ma initial commit.

### Faza 1 — Planner (specyfikacja sprintów)

> [!important] Planning = effort max (ultrathink)
> Planowanie to faza o najwyższej dźwigni — błąd planu kaskaduje przez godziny pracy N agentów. **Spawnuj Plannera z maksymalnym budżetem rozumowania**: w prompcie Task dla Plannera dodaj słowo **`ultrathink`** (najwyższy próg extended thinking). Nie optymalizuj tej fazy pod szybkość. To nienegocjowalne — szybki płytki plan kosztuje więcej niż wolny głęboki.

1. Uruchom sub-agenta **Planner** (osobne okno kontekstowe) z promptem rozpoczętym od **`ultrathink`**: "ultrathink. Zamień prompt użytkownika na specyfikację wysokopoziomową podzieloną na sprinty/user stories. **Bez szczegółów technicznych.** Output: `state/plan.md`."
2. Planner **nie pisze kodu**. Nie projektuje API. Nie wybiera bibliotek. Błąd na tym etapie kaskaduje przez godziny pracy.
3. Output Plannera musi zawierać:
   - Listę 3-15 sprintów z mierzalnymi celami biznesowymi.
   - Listę zewnętrznych zależności (API, biblioteki, dane).
   - Listę **niewiadomych do eskalacji** (Non-negotiable #1: uwidaczniaj założenia).

**Exit criterion:** `state/plan.md` istnieje, zawiera sekcję "Sprints", "Dependencies", "Open Questions". Hash gita w breadcrumbs.

> [!important] 🚦 GATE #1 — Plan (STOP przed Fazą 2)
> Walidacja: `scripts/verify-plan-rigor.sh` exit 0 + `state/prd/sprint-*.md` istnieje per sprint. Przedstaw `state/plan.md` + PRD człowiekowi z checklistą (`references/approval-gates-protocol.md §3`). Breadcrumb `gate_pending` (gate:1). **STOP — czekaj na „zatwierdzam plan" / „proceed".** Bez frazy akceptującej NIE spawnuj zespołu. Po zgodzie → breadcrumb `gate_approved` (gate:1).

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
     prompt: "ultrathink. <oryginalny prompt użytkownika + ścieżka do assets/plan-template.md>"
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

> [!important] 🚦 GATE #2 — Kontrakty (STOP przed Fazą 4)
> Walidacja: `check-contract-coverage.sh {n}` exit 0 dla każdego sprintu + zero skal 1-10. Przedstaw `state/contracts/sprint-*.json` człowiekowi. Breadcrumb `gate_pending` (gate:2). **STOP — czekaj na „zatwierdzam kontrakty".** Po zgodzie → `gate_approved` (gate:2).

### Faza 4 — Pętla generator-ewaluator (hill climbing)

Powtarzaj **dla każdego sprintu** osobno:

1. **Generator** pisze kod zgodnie z kontraktem. Commit po każdej działającej zmianie.
2. **Smoke test** — `scripts/smoke-test-runner.sh` uruchamia aplikację lokalnie (npm start / docker-compose / cokolwiek). **Bez tego ewaluator nie wchodzi.** Brak smoke testu = generator pisze do śmietnika.
3. **Evaluator** uruchamia aplikację (Playwright/Chrome/Computer Use), wykonuje scenariusze z kontraktu, robi screenshots, weryfikuje wg rubryki. Patrz `references/evaluator-rubric.md`.
4. **Feedback do Generatora** — **wyłącznie sucha krytyka** (`"przycisk Save nie reaguje na klik"`), **bez** podpowiedzi rozwiązania (`"dodaj onClick handler"`). Generator sam szuka.
5. **Audyt:** każda iteracja → wpis w `state/breadcrumbs.json` z polami: `iteration`, `generator_action`, `evaluator_verdict`, `passed_criteria`, `failed_criteria`, `runtime_evidence_path`.
6. **Loop until** `passed_criteria == total_criteria` LUB `iteration >= MAX_ITERATIONS` (domyślnie 5).

**Exit criterion:** wszystkie kryteria z kontraktu = passed + screenshot/log w `state/evidence/sprint-{n}/` + `git commit` z hash w breadcrumbs.

> [!important] 🚦 GATE #3 — Sprint + 🚦 GATE #4 — QA (STOP po każdym sprincie)
> Evaluator pisze `state/sprint-reports/sprint-{n}.md` (`assets/sprint-report-template.md`). Walidacja: `check-evidence-completeness.sh {n}` exit 0. **STOP — czekaj na „zatwierdzam sprint {n}"** przed kolejnym sprintem. Jeśli playwright-runner robił QA → dodatkowo **GATE #4**: przedstaw `state/qa-reports/sprint-{n}.md` + screenshoty per AC-F, **STOP — „zatwierdzam QA"**. Breadcrumby `gate_approved` (gate:3, sprint:n) i (gate:4, sprint:n).

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
5. Five-Axis Review (opcjonalnie, jeśli `dev/audited-feature-workflow` jest zainstalowany): Correctness, Readability, Architecture, Security, Performance — wywołaj przez Task tool z `subagent_type: "reviewer"` z audited-feature-workflow.
6. **Beyoncé Rule:** każda funkcja w diffie ma test. Brak testu = blokada (heurystyka: `git diff --name-only HEAD~N | grep -E "src/.*\\.(ts|js|py)$" | xargs -I {} sh -c 'test -f "tests/$(basename {} | sed s/src//).spec.{ts,js,py}"'`).
7. Uruchom `scripts/verify-approval-gates.sh` — wszystkie bramki (#1-#5) domknięte zgodą człowieka w breadcrumbs.

> [!important] 🚦 GATE #5 — Code Review (STOP przed Fazą 7)
> Five-Axis Review → `docs/code-reviews/CR-sprint-{n}-*.md` per sprint. Zero findings `Critical`. Przedstaw człowiekowi. Breadcrumb `gate_pending` (gate:5). **STOP — czekaj na „zatwierdzam review".** Po zgodzie → `gate_approved` (gate:5).

**Exit criterion:** wszystkie checki zielone + raport `state/verify-report.md` zawiera linki do evidence per sprint + `git log --oneline` pokazuje atomowe commity ≤300 linii.

### Faza 7 — Ship

1. Planner pisze `state/final-report.md` (executive summary — `references/documentation-protocol.md §3 Dokument 8`).
2. **🚦 GATE #6 — Ship:** walidacja `verify-approval-gates.sh` exit 0 (bramki #1-#5 domknięte) + wszystkie `verify-*.sh` exit 0. Przedstaw `state/final-report.md` człowiekowi. Breadcrumb `gate_pending` (gate:6). **STOP — czekaj na „zatwierdzam ship"** przed `git tag`. Po zgodzie → `gate_approved` (gate:6).
3. PR Sizing check: każdy commit ≤100 linii (≤300 z uzasadnieniem, >1000 = blokada). Sprawdź: `git log --stat HEAD~N..HEAD`.
4. CHANGELOG entry: ręcznie dopisz wersję + zmiany do `CHANGELOG.md` (lub przez `keepachangelog` jeśli zainstalowany).
5. Tag: `git tag -a v{x.y.z} -m "{description}"`.
6. **Osobny human gate dla push** — przed `git push` do remote zatrzymaj proces. Trzymaj się zasady: `/goal` NIE robi `git push` (patrz `references/goal-mode-protocol.md §4`).

**Exit criterion:** `gate_approved` (gate:6) w breadcrumbs + `git tag` istnieje + `git log` clean + CHANGELOG zaktualizowany.

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
| „Pamiętam jak działa useEffect, znam React od lat" | Odrzucono. **Halucynacja API.** Twoja wiedza ma cutoff date. Wywołaj `mcp__context7__get-library-docs` przed każdym importem. Patrz `references/library-currency-protocol.md`. |
| „Lib jest stabilna, na pewno nie ma breaking changes" | Odrzucono. Stabilność ≠ brak deprecations. context7 → `topic: "breaking changes"`. Bez breadcrumb `library_currency_checked` → walidator odrzuca sprint. |
| „Context7 zajmuje czas, pominę dla małych libów" | Odrzucono. Mała lib może mieć duże breaking changes (np. `chalk 5.x` przeszedł na ESM-only). Każdy nowy `import` → minimum `npm view {lib} version` + breadcrumb (source: npm-jsdoc). |
| „Wystarczy jedna hipoteza per sprint, ta jest oczywista" | Odrzucono. **Planning rigor.** Bez 3 alternatyw (Minimal/Idiomatic/Ambitious) brak rzeczywistego wyboru architektonicznego. Patrz `references/planning-rigor.md §1`. |
| „Hyrum Impact zaktualizuję jak będzie potrzebne" | Odrzucono. **Hyrum wykrywa się PRZED implementacją**, nie po regresji. Sekcja wymagana w `state/plan.md` (lub jawne "no public API changes in tej sesji"). |
| „Rollback plan to zmartwienie później" | Odrzucono. Sprint bez rollback strategy = sprint który nie może być cofnięty bez data loss. Każdy sprint ma 1-linijkową strategię. |
| „PRD per sprint to overhead, kontrakt wystarczy" | Odrzucono. PRD to 8 krótkich sekcji (User story → FR → NFR → metrics). Kontrakt generuje się Z PRD. Bez PRD generator implementuje wg swojej interpretacji = pętla bez progresu. Patrz `references/documentation-protocol.md §3 Dokument 2`. |
| „ADR napiszę później jak będzie czas" | Odrzucono. **Płot Chestertona.** ADR PISZESZ w momencie decyzji — wtedy znasz kontekst i alternatywy. Później = halucynacja własnej motywacji. Sekwencyjne ADR-NNNN w `docs/adr/`. |
| „TODO jest w mojej głowie, persistencja niepotrzebna" | Odrzucono. Pivot LUB recovery sesji = TODO z głowy stracone. `state/todo.md` snapshot z TodoWrite raz na iterację. |
| „Retrospective to ceremoniał, sprint przeszedł = done" | Odrzucono. **Calibration loop.** Bez retrospective uprząż dryfuje. To 5 punktów lessons learned, NIE 30 stron analizy. Patrz `assets/retrospective-template.md`. |
| „Code review już zrobił Evaluator w werdykcie" | Odrzucono. Werdykt = pass/fail per kryterium. Code review = analiza JAK kod jest napisany (Five-Axis: Correctness/Readability/Architecture/Security/Performance). Dwie różne rzeczy. |
| „Plan oczywisty, spawnuję zespół bez GATE #1" | Odrzucono. **GATE #1 nienegocjowalny.** Błędny plan kaskaduje przez godziny pracy N agentów. Bez `gate_approved` (gate:1) → blokada spawnu. Patrz `references/approval-gates-protocol.md`. |
| „Sprint przeszedł, lecę dalej bez akceptacji" | Odrzucono. **GATE #3 per sprint.** Człowiek widzi raport wykonania ZANIM kolejny sprint buduje na potencjalnie złej decyzji. Cisza ≠ zgoda. |
| „/goal jest autonomiczny, bramki psują ideę" | Odrzucono. Decyzja projektowa v1.7.0: **`/goal` respektuje wszystkie 6 bramek.** Chcesz pełną autonomię bez bramek = zmiana wymagań do eskalacji (Non-negotiable #2), nie cichy skrót. |
| „Człowiek napisał 'spoko', traktuję jako zgodę" | Odrzucono. Tylko frazy z whitelisty (`approval-gates-protocol.md §4`). Niejednoznaczność = dopytaj. |
| „Jestem w `/YOLO`, więc mogę zrobić `git push` / `DROP TABLE`" | Odrzucono. **`/YOLO` znosi bramki PRZEGLĄDU, nie zabezpieczenia destrukcyjne.** Brak push/publish/drop/rm-poza-feature także w YOLO. Operacje nieodwracalne zawsze wymagają człowieka. |
| „W `/YOLO` pominę walidator, leci autonomicznie" | Odrzucono. YOLO auto-zatwierdza artefakt **po** przejściu `verify-*.sh`. Fail walidatora w YOLO = STOP + `blockers.md`, nie auto-pass. Autonomia ≠ udawanie zielonego. |
| „Dodaję nowy walidator do `scripts/`, test runnerowy później" | Odrzucono. **Beyoncé Rule dla samego skilla.** Każdy `verify-*.sh` / `check-*.sh` musi mieć fixture GOOD + BAD + `assert_exit` w `tests/run-meta-tests.sh`. Bez tego walidator milcząco regresuje. Patrz `references/testing-map.md §Procedura`. |
| „Bug walidatora — naprawiam, regresji nie dorabiam" | Odrzucono. **Prove-It Pattern (test regresji).** Każdy bug walidatora → `tests/fixtures/regression-<short-desc>.<ext>` + failing `assert_exit` PRZED fixem. Bez tego ten sam bug wróci. Patrz `references/testing-map.md §Procedura fix buga`. |
| „Walidator nie czyta state/ ani breadcrumbs, integration test zbędny" | Sprawdź ponownie. Reaguje na gate? Pisze evidence? Wtedy ma cross-validator dependency → 15% piramidy 80/15/5 = integration scena w runnerze. Patrz `references/testing-map.md §Mapa`. |

Pełna tabela z Google DNA (Hyrum/Chesterton/Beyoncé/DAMP) + library currency + domenowymi wariantami: `references/anti-rationalization.md §5` + `references/library-currency-protocol.md §7`. Mapa meta-testów (unit/integration/regression) per walidator + procedura dodawania: `references/testing-map.md`.

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
- [ ] **Library currency** — `scripts/verify-library-currency.sh {sprint-n}` exit 0. Każda nowa paczka w `package.json` ma breadcrumb `library_currency_checked` z `source ∈ {context7, deepwiki, webfetch, npm-jsdoc}`.
- [ ] **Plan rigor (faza 1)** — `scripts/verify-plan-rigor.sh` exit 0. `state/plan.md` ma wszystkie 11 sekcji + 3 hipotezy per sprint (Minimal/Idiomatic/Ambitious) + Hyrum Impact + Rollback plan + Alternatives considered (min. 2).
- [ ] **Documentation** — `scripts/verify-documentation.sh` exit 0. Każdy passed sprint ma PRD (8 sekcji) + retrospective + code review (Five-Axis). Architektoniczne decyzje mają ADR w `docs/adr/`. TODO snapshot aktualny. QA report jeśli playwright-runner uruchamiał.
- [ ] **Approval gates** — `scripts/verify-approval-gates.sh` exit 0. Każda z 6 bramek (#1-#6) ma `gate_approved` w breadcrumbs z jawną zgodą człowieka, w prawidłowej kolejności (plan przed spawnem, sprint przed kolejnym). Brak wiszących `gate_pending`.
- [ ] **Meta-testy walidatorów (Beyoncé Rule dla samego skilla)** — każda zmiana w `scripts/` ma odpowiadające `assert_exit` w `tests/run-meta-tests.sh` (unit). Walidator z cross-validator dependency: integration scena z `setup_*`. Bug walidatora: regression fixture `tests/fixtures/regression-*.<ext>`. Surowy output `bash tests/run-meta-tests.sh | tail -3` → `X/X passed` wklejony do PR description. Mapa: `references/testing-map.md`.

Pełna procedura zbierania dowodów: `references/dod-evidence-protocol.md`. Pełen protokół currency: `references/library-currency-protocol.md`. Pełen rygor planistyczny: `references/planning-rigor.md`. Pełen audit trail dokumentów: `references/documentation-protocol.md`. Pełen protokół bramek akceptacji: `references/approval-gates-protocol.md`. Mapa meta-testów walidatorów (unit/integration/regression): `references/testing-map.md`.

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
| Faza 6 (verify) | `dod-evidence-protocol.md` (Five-Axis Review przez audited-feature-workflow jeśli zainstalowany) |
| Kalibracja skilla po 3+ realnych przebiegach | `traces-reading.md` |
| Planner/Generator/Evaluator dodaje bibliotekę LUB nowy import | `library-currency-protocol.md` (context7 + fallback chain) |
| Faza 1 (Planner pisze state/plan.md) — ZAWSZE | `planning-rigor.md` (3 hipotezy/sprint + Hyrum Impact + Rollback + Alternatives) |
| Faza 1 (Planner) + Faza 4-end (Evaluator po sprincie) — ZAWSZE | `documentation-protocol.md` (PRD/ADR/retro/code-review/QA report) |
| Start sesji (każdy tryb, włącznie z /goal) — ZAWSZE | `approval-gates-protocol.md` (6 bramek human-in-the-loop) |
| Dodajesz/modyfikujesz walidator w `scripts/` LUB fix buga walidatora LUB Faza 6 (verify) audit DoD | `testing-map.md` (mapa unit/integration/regression per walidator + procedura RED-GREEN-REFACTOR + Prove-It dla regresji) |

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
| Każda bramka #1-#6 (przejścia faz) | **Human-in-the-loop** | STOP, przedstaw artefakt, czekaj na frazę akceptującą. Cisza ≠ zgoda. Także w /goal. |

---

## Sources

- [DOC/material_skill.md](../../DOC/material_skill.md) — pryncypia procesowe: Process over Prose, Anti-Rationalization, DoD, 5 Non-negotiables.
- [DOC/since_skill.md](../../DOC/since_skill.md) — pryncypia projektowe skilla: token budget, kebab-case, Negative Triggers, Plan-Validate-Execute, Beyoncé Rule.
- [DOC/agent-teams-generator-ewaluator.md](../../DOC/agent-teams-generator-ewaluator.md) — wzorzec Generator-Ewaluator (§1-10).
- [DOC/goal_mode.md](../../DOC/goal_mode.md) — przykłady `/goal` z mierzalną weryfikacją.
- Reference implementation: `dev/audited-feature-workflow/` (struktura references/ + scripts/).
