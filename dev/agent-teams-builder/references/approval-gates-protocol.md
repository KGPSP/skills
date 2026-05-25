---
title: Approval Gates Protocol — 6 bramek akceptacji człowieka (human-in-the-loop) dla całego flow zespołu agentów
load-when: "ZAWSZE — pierwsza bramka domyka Fazę 1. Załaduj na start sesji (każdy tryb, włącznie z /goal)."
source:
  - dev/audited-feature-workflow/SKILL.md §Phase 5/5.8/6/7/7.8/8 (6 APPROVAL GATES)
  - references/documentation-protocol.md (artefakty zatwierdzane na bramkach)
  - references/planning-rigor.md (plan zatwierdzany na GATE #1)
  - DOC/material_skill.md §8 (Non-negotiable #1 — uwidaczniaj założenia; #2 — stop przy konflikcie)
---

# Approval Gates Protocol — human-in-the-loop

> **Cel:** agent-teams-builder przestaje być "odpal i zostaw". Każdy artefakt o wysokim koszcie błędu (plan, kontrakt, kod sprintu, QA, review, ship) **zatrzymuje proces** i czeka na **jawną zgodę człowieka** zanim pętla ruszy dalej. To wzorzec **6 APPROVAL GATES** przeniesiony z `audited-feature-workflow` na flow zespołu N-sprintowego.

> [!important] Zasada nadrzędna
> **Naruszenie litery bramki = naruszenie ducha bramki.** Bramka nie jest "sugestią do rozważenia" — to twardy STOP. Bez frazy akceptującej od człowieka proces NIE przechodzi do następnej fazy. Dotyczy to **także trybu `/goal`** (decyzja projektowa: wszystkie bramki aktywne, `/goal` je respektuje).

---

## 1. Mapa 6 bramek na fazy SKILL.md

| Gate | Pozycja w flow | Co zatwierdzasz | Artefakt do przeglądu | Walidator pre-gate |
|---|---|---|---|---|
| **#1 — Plan** | Po Fazie 1 (Planner), PRZED Fazą 2 (spawn) | Specyfikacja sprintów + PRD | `state/plan.md` (11 sekcji) + `state/prd/sprint-*.md` | `verify-plan-rigor.sh` exit 0 |
| **#2 — Kontrakty** | Po Fazie 3 (negocjacja), PRZED Fazą 4 (pętla) | Kryteria binarne per sprint | `state/contracts/sprint-{n}.json` | `check-contract-coverage.sh {n}` exit 0 |
| **#3 — Sprint** | Po każdym sprincie w Fazie 4, PRZED kolejnym sprintem | Wykonanie pojedynczego sprintu | `state/sprint-reports/sprint-{n}.md` + evidence | `check-evidence-completeness.sh {n}` exit 0 |
| **#4 — QA / Runtime** | Po QA (playwright-runner), PRZED Fazą 6 | Dowód działania w runtime | `state/qa-reports/sprint-{n}.md` + screenshoty per AC-F | (qa-summary.json bez blocking) |
| **#5 — Code Review** | Faza 6 (verify) — Five-Axis | Jakość kodu (jak napisany) | `docs/code-reviews/CR-sprint-{n}-*.md` | zero findings `Critical` |
| **#6 — Ship** | Faza 7, PRZED `git tag` / `git push` | Raport końcowy + decyzja o release | `state/final-report.md` | wszystkie `verify-*.sh` exit 0 |

> Bramki #3 i #4 są **per sprint** (powtarzają się). Bramki #1, #2, #5, #6 są raz na ich fazę (choć #2/#5 obejmują wszystkie sprinty łącznie).

---

## 2. Co znaczy "STOP" — protokół zatrzymania

Gdy proces dochodzi do bramki, parent agent (główne okno) wykonuje **dokładnie** tę sekwencję:

1. **Zamroź pętlę.** Żadnego spawnu, edycji, commita, `rm` po wejściu w bramkę.
2. **Zapisz checkpoint** — breadcrumb `gate_pending`:
   ```bash
   bash scripts/append-breadcrumb.sh "parent" "gate_pending" \
     "$(jq -nc --argjson g 1 --arg a "state/plan.md" '{gate: $g, artifact: $a}')"
   ```
3. **Przedstaw artefakt** człowiekowi: ścieżka pliku + checklist bramki (z §3) + jednoznaczne pytanie.
4. **Czekaj na jawną frazę akceptującą** (patrz §4). Cisza ≠ zgoda. Komentarz typu "wygląda ok" bez frazy ≠ zgoda — dopytaj.
5. Po akceptacji — breadcrumb `gate_approved`:
   ```bash
   bash scripts/append-breadcrumb.sh "human" "gate_approved" \
     "$(jq -nc --argjson g 1 --arg a "state/plan.md" --arg by "operator" '{gate: $g, artifact: $a, approved_by: $by}')"
   ```
6. **Dopiero teraz** przejdź do następnej fazy.

> [!warning] Odrzucenie na bramce
> Jeśli człowiek odrzuca / żąda zmian → breadcrumb `gate_rejected` z polem `reason`, wróć do fazy która produkowała artefakt (np. odrzucony plan → Planner poprawia → ponowne GATE #1). NIE obchodź bramki "bo poprawka jest drobna".

---

## 3. Checklisty per bramka

### GATE #1 — Plan
- [ ] `state/plan.md` niepusty (`test -s`).
- [ ] `scripts/verify-plan-rigor.sh` → exit 0 (11 sekcji + 3 hipotezy/sprint + Hyrum + Rollback + Alternatives ≥2).
- [ ] Każdy sprint ma wybraną JEDNĄ hipotezę + uzasadnienie wg 5 Non-negotiables.
- [ ] `state/prd/sprint-{n}.md` istnieje dla każdego sprintu (8 sekcji).
- [ ] Open Questions: rozwiązane LUB świadomie odroczone (jawna decyzja człowieka).
- [ ] **STOP** → fraza akceptująca przed Fazą 2 (spawn ról).

### GATE #2 — Kontrakty
- [ ] `scripts/check-contract-coverage.sh {n}` → exit 0 dla każdego sprintu.
- [ ] Każdy kontrakt ma ≥15 kryteriów **binarnych** (zero skal 1-10).
- [ ] Evaluator dopisał `accepted: true` w breadcrumbs dla każdego kontraktu.
- [ ] **STOP** → fraza akceptująca przed Fazą 4 (pętla gen-eval).

### GATE #3 — Sprint (per sprint)
- [ ] Wszystkie kryteria kontraktu = `passed` (`passed_criteria == total_criteria`).
- [ ] `state/evidence/sprint-{n}/` zawiera dowód runtime (screenshot/log/output).
- [ ] `state/retrospectives/sprint-{n}.md` istnieje.
- [ ] `state/sprint-reports/sprint-{n}.md` wygenerowany (raport o wykonaniu — `assets/sprint-report-template.md`).
- [ ] Independent verification: kod pisał Generator, evidence robił Evaluator (verified w breadcrumbs).
- [ ] **STOP** → fraza akceptująca przed kolejnym sprintem.

### GATE #4 — QA / Runtime (per sprint, jeśli playwright-runner uruchamiał)
- [ ] `state/qa-reports/sprint-{n}.md` istnieje.
- [ ] Zero blocking failures w `qa-summary.json`.
- [ ] Screenshot per AC-F (walidacja wizualna UI).
- [ ] **STOP** → fraza akceptująca przed Fazą 6 (verify).

### GATE #5 — Code Review (Five-Axis)
- [ ] `docs/code-reviews/CR-sprint-{n}-*.md` istnieje dla każdego sprintu.
- [ ] Zero findings o severity `Critical` (Optional/Nit/FYI dozwolone z notatką).
- [ ] PR Sizing: każdy commit ≤100 linii (≤300 z uzasadnieniem).
- [ ] Chesterton: każda `git rm` / usunięta funkcja ma sekcję `Why this existed:`.
- [ ] **STOP** → fraza akceptująca przed Fazą 7 (ship).

### GATE #6 — Ship
- [ ] `state/final-report.md` niepusty.
- [ ] `verify-documentation.sh` + `verify-plan-rigor.sh` + `verify-non-negotiables.sh` + `verify-library-currency.sh --all-sprints` + `verify-approval-gates.sh` → wszystkie exit 0.
- [ ] CHANGELOG zaktualizowany + wersja zdecydowana.
- [ ] **STOP** → fraza akceptująca przed `git tag`. Osobny human gate przed `git push` (już istniejący — patrz `goal-mode-protocol.md §4`).

---

## 4. Frazy akceptujące (whitelist)

Proces przechodzi bramkę **tylko** po jednej z fraz (case-insensitive, dopasowanie do bramki):

| Bramka | Akceptowane frazy |
|---|---|
| #1 | „zatwierdzam plan", „proceed", „ok plan", ręczna edycja `plan.md` + „ok" |
| #2 | „zatwierdzam kontrakty", „proceed kontrakty" |
| #3 | „zatwierdzam sprint {n}", „proceed sprint", „następny sprint" |
| #4 | „zatwierdzam QA", „proceed QA", „QA ok" |
| #5 | „zatwierdzam review", „proceed review", „review ok" |
| #6 | „zatwierdzam ship", „proceed ship", „release ok" |

**Nie liczą się jako zgoda:** „spoko", „dzięki", „👍" bez kontekstu bramki, milczenie, „chyba ok". Przy niejednoznaczności — dopytaj, NIE zakładaj.

---

## 5. Interakcja z trybem `/goal`

> Decyzja projektowa (v1.7.0): **wszystkie 6 bramek aktywne także w `/goal`.** `/goal` przestaje być pracą nocną "bez nadzoru" — staje się **pętlą nadzorowaną z checkpointami**.

W `/goal` pętla na każdej bramce:

1. Emituje status `awaiting_gate_{n}` (zamiast kontynuować autonomicznie).
2. Zapisuje pełny checkpoint stanu (`state/goal-checkpoint.json`) + breadcrumb `gate_pending`.
3. **Zwraca kontrolę człowiekowi** z artefaktem + checklistą bramki.
4. Po `gate_approved` — wznawia pętlę od następnej fazy.

Konsekwencje, które MUSISZ zakomunikować użytkownikowi przy starcie `/goal`:
- `caffeinate` / praca nocna **nie działa** — proces zatrzyma się na pierwszej bramce i będzie czekał.
- `MAX_GOAL_ITERATIONS` / `GOAL_TIMEOUT_HOURS` liczą się **tylko między bramkami**, nie w trakcie oczekiwania na zgodę.
- Jeśli operator chce klasyczny tryb autonomiczny bez bramek → to świadoma zmiana wymagań, eskaluj (Non-negotiable #2), NIE pomijaj bramek po cichu.

---

## 6. Anti-Rationalization (gates)

| Wymówka | Riposta (blokada) |
|---|---|
| „Plan oczywisty, spawnuję zespół od razu" | **Odrzucono.** GATE #1 nienegocjowalny. Błędny plan kaskaduje przez godziny pracy N agentów. Koszt złego planu rośnie liniowo z liczbą sprintów. |
| „Sprint przeszedł, lecę do następnego bez pytania" | **Odrzucono.** GATE #3 per sprint. Człowiek widzi raport wykonania ZANIM kolejny sprint zbuduje na potencjalnie złej decyzji. |
| „/goal jest autonomiczny, bramki psują ideę" | **Odrzucono.** Decyzja projektowa v1.7.0: `/goal` respektuje bramki. Jeśli chcesz pełną autonomię — to zmiana wymagań do eskalacji, nie cichy skrót. |
| „Człowiek powiedział 'spoko', to zgoda" | **Odrzucono.** Tylko frazy z whitelisty (§4). Niejednoznaczność = dopytaj. Cisza ≠ zgoda. |
| „Poprawka po odrzuceniu jest drobna, pominę re-gate" | **Odrzucono.** Każda poprawka artefaktu = ponowne przejście bramki. Brak `gate_approved` po `gate_rejected` = blokada. |
| „Zarejestruję wszystkie zgody na końcu hurtem" | **Odrzucono.** Breadcrumb `gate_approved` PRZED przejściem fazy, nie po fakcie. Audit trail musi odzwierciedlać realną kolejność. |

---

## 7. Walidator — verify-approval-gates.sh

```bash
bash scripts/verify-approval-gates.sh
```

Sprawdza w `state/breadcrumbs.json`:
- Dla każdego sprintu `passed`/`shipped` w `feature_list.json` → istnieje `gate_approved` z `gate: 3` dla tego sprintu.
- Istnieje `gate_approved` z `gate: 1` (plan) PRZED pierwszym `role_spawned` (chronologia: plan zatwierdzony przed spawnem).
- Każdy `gate_pending` ma odpowiadający `gate_approved` LUB `gate_rejected` (brak wiszących bramek).
- Jeśli `final-report.md` istnieje → `gate_approved` z `gate: 6`.

Exit 0 = wszystkie bramki domknięte zgodą. Exit ≠0 = brakująca/wisząca zgoda → blokada Fazy 7 (ship).

---

## 8. Red Flags — STOP i zatrzymaj się na bramce

- Spawn ról bez `gate_approved` gate:1 w breadcrumbs.
- Commit kolejnego sprintu bez `gate_approved` gate:3 poprzedniego.
- `git tag` bez `gate_approved` gate:6.
- „W /goal pomijam bramki dla szybkości".
- `gate_pending` bez następującego `gate_approved`/`gate_rejected`.

**Każdy z tych sygnałów oznacza: wróć, przedstaw artefakt, poczekaj na frazę akceptującą.**

---

## 9. Tryb `/YOLO` — autonomia bez bramek (human-in-the-loop OFF)

> `/YOLO` to **jawny opt-in** w prompcie użytkownika. Wyłącza wszystkie 6 bramek przeglądu: zamiast STOP+czekanie, agent sam podejmuje decyzję i kontynuuje. Najmocniejszy w parze z `/goal` (`/YOLO /goal <spec>`) — przywraca w pełni autonomiczną pętlę „odpal i zostaw" sprzed v1.7.0.

### 9.1 Co się zmienia na każdej bramce

Zamiast protokołu STOP (§2 kroki 3-4), parent agent wykonuje **YOLO-resolve**:

1. **Uruchom walidator bramki** (`verify-plan-rigor.sh` / `check-contract-coverage.sh` / `check-evidence-completeness.sh` / ...). **Musi przejść.** Fail → STOP + `state/blockers.md` + eskalacja (autonomia NIE znosi weryfikacji).
2. **Auto-decyzja:** wybierz najbardziej prawdopodobną opcję. Dla GATE #1 — Planner wybrał już JEDNĄ hipotezę (Idiomatic domyślnie, chyba że dowody faworyzują inną); YOLO akceptuje ten wybór bez pytania człowieka.
3. **Auto-zatwierdź** — breadcrumb z jawnym znacznikiem autonomii:
   ```bash
   bash scripts/append-breadcrumb.sh "yolo" "gate_approved" \
     "$(jq -nc --argjson g 1 --arg a "state/plan.md" '{gate: $g, artifact: $a, auto_approved: true}')"
   ```
4. **Kontynuuj** do następnej fazy bez czekania.

### 9.2 Czego `/YOLO` NIE znosi (twarde rails)

| Zachowane mimo YOLO | Powód |
|---|---|
| `verify-*.sh` muszą przechodzić | Autonomia ≠ udawanie zielonego. Fail = STOP + blockers. |
| Brak `git push` / `npm publish` | Publikacja = nieodwracalny gest zewnętrzny, zawsze człowiek. |
| Brak `DROP TABLE` / `DELETE` bez WHERE | Utrata danych nieodwracalna. |
| Brak `rm -rf` poza katalogiem feature | Patrz `goal-mode-protocol.md §4`. |
| Plan-Validate-Execute dla pivota | `references/pivot-protocol.md` — destruktywny reset wymaga planu + walidacji. |
| Strefa wrażliwa (`.env`, `secrets/`, `~/.ssh/`) nietykalna | — |

> **Mentalny model:** `/YOLO` przyspiesza **przegląd** (zgoda człowieka → auto-decyzja), nie autoryzuje **szkody**. Bramka recenzji ≠ zabezpieczenie destrukcyjne.

### 9.3 Audit trail

YOLO jest w pełni audytowalny: każda auto-decyzja to breadcrumb `gate_approved` z `actor: "yolo"` + `auto_approved: true`. `verify-approval-gates.sh` przechodzi (sprawdza obecność `gate_approved`, nie aktora), a `[WARN]` sygnalizuje że bramki zostały zatwierdzone autonomicznie. Po sesji człowiek widzi w breadcrumbs **dokładnie** które decyzje podjął agent zamiast niego.

### 9.4 Komunikat startowy (obowiązkowy)

Przed uruchomieniem `/YOLO` parent agent komunikuje użytkownikowi:
> „Tryb /YOLO: wyłączam 6 bramek akceptacji. Sam wybieram hipotezy (najbardziej prawdopodobne), auto-zatwierdzam plan/kontrakty/sprinty/QA/review. Zabezpieczenia destrukcyjne (push/publish/drop/rm) i walidatory pozostają aktywne. Wracam do Ciebie przy fail walidatora, eskalacji lub operacji nieodwracalnej. Potwierdź start."
