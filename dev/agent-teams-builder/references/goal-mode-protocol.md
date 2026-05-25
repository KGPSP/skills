---
title: Tryb /goal — autonomiczna pętla AC z auto-pivotem
load-when: "User napisał /goal LUB chce pracy 6+h bez nadzoru"
source:
  - DOC/goal_mode.md (przykłady stan końcowy + weryfikacja + ograniczenia)
  - DOC/agent-teams-generator-ewaluator.md §3 + §7 (pętla + pivot)
  - DOC/since_skill.md §6 (Calibration — destruktywne = Plan-Validate-Execute)
---

# Tryb /goal — pętla nadzorowana z bramkami

> `/goal` = delegacja całej pętli Generator-Evaluator do Agent Teams z **mierzalnym stanem końcowym** + **sposobem weryfikacji** + **ograniczeniami**.

> [!important] v1.7.0 — /goal respektuje wszystkie 6 bramek akceptacji
> Decyzja projektowa: domyślnie `/goal` **NIE jest trybem „bez nadzoru przez wielogodziny".** Pętla zatrzymuje się na każdej z 6 bramek (`references/approval-gates-protocol.md`), emituje status `awaiting_gate_{n}`, zapisuje checkpoint i **zwraca kontrolę człowiekowi**. Praca nocna „odpal i zostaw" domyślnie nie zadziała — proces będzie czekał na frazę akceptującą.

> [!tip] `/YOLO /goal` — przywrócenie pełnej autonomii (v1.8.0)
> Dodaj `/YOLO` do promptu, by **wyłączyć bramki** i odzyskać tryb „odpal i zostaw": agent sam stawia hipotezy, wybiera najbardziej prawdopodobną i auto-zatwierdza każdą bramkę. Zabezpieczenia destrukcyjne (§4) i walidatory pozostają aktywne. Pełny protokół: `references/approval-gates-protocol.md §9`.

---

## 1. Format `/goal`

```
/goal <stan końcowy>
Weryfikacja: <komenda lub komendy z exit code 0>
Ograniczenia: <co NIE wolno tknąć>
```

### Dobre przykłady (z goal_mode.md)

```
/goal Wszystkie testy w katalogu tests/auth/ przechodzą.
Weryfikacja: `npm test -- tests/auth` kończy się exit code 0.
Ograniczenia: nie modyfikuj plików testowych, nie commituj,
nie dotykaj plików poza src/auth/.
```

```
/goal Plik src/services/CezolService.ts jest rozbity na moduły,
każdy poniżej 300 linii.
Weryfikacja: `wc -l src/services/cezol/*.ts` pokazuje wszystkie
pliki <300, `npm run typecheck` exit 0, `npm test` exit 0.
Ograniczenia: zachowaj publiczne API (eksporty z index.ts bez zmian),
nie zmieniaj zachowania.
```

### Antywzorce (odrzuć)

| Antywzorzec | Co źle | Riposta |
|---|---|---|
| `/goal popraw kod` | Niemierzalne | "Brak warunku exit. Zdefiniuj `Weryfikacja: <komenda>`." |
| `/goal kod jest ładniejszy` | Subiektywne | "Brak mierzalnej rubryki. Załaduj `evaluator-rubric.md` i wyspecyfikuj progi binarne." |
| `/goal działa szybciej` | Brak progu | "O ile szybciej? Mierzone jak? Domyślnie: `time` < 200ms LUB benchmark suite exit 0." |

---

## 2. Pętla AC (Acceptance Criteria)

Tryb `/goal` używa pętli auto-iterującej:

```
LOOP:
  iteration += 1
  Generator: pisze kod
  scripts/run-goal-loop.sh: uruchamia komendę weryfikacji
  IF exit code == 0:
    BREAK (goal achieved)
  ELSE:
    Evaluator: analizuje output (stderr, failed tests, log)
    Evaluator: dopisuje feedback do state/goal-iterations.json
    IF iteration >= MAX_GOAL_ITERATIONS (domyślnie 10):
      IF auto-pivot enabled (env GOAL_AUTO_PIVOT=1):
        → pivot-protocol.md
      ELSE:
        → eskalacja do human (state/blockers.md)
```

### 2.1 Konfiguracja

| Env | Default | Co robi |
|---|---|---|
| `MAX_GOAL_ITERATIONS` | 10 | Twarda granica iteracji bez pivota |
| `GOAL_AUTO_PIVOT` | 0 | Czy pivot ma odpalić bez human |
| `PIVOT_REQUIRES_HUMAN` | 1 | Czy pivot wymaga akceptacji człowieka (patrz pivot-protocol.md) |
| `GOAL_TIMEOUT_HOURS` | 6 | Twardy limit czasowy całej pętli |

---

## 3. Wymagania przed `/goal`

Przed włączeniem trybu autonomicznego:

1. **Czysty git status** — żaden uncommitted change. `git status --porcelain | wc -l` == 0.
2. **Osobny worktree** (silnie zalecane):
   ```bash
   git worktree add ../project-goal-$(date +%Y%m%d) goal/$(uuidgen | head -c 8)
   ```
3. **State zainicjalizowany** — `scripts/init-team-state.sh` wykonany.
4. **Smoke test działa** — przed `/goal` ręcznie uruchom aplikację, potwierdź że startuje.
5. **Auto mode w Claude Code** — zaakceptuj narzędzia automatycznie (inaczej co iterację user musi klikać "Allow").
6. **Backup branch** — `git branch backup-pre-goal-$(date +%Y%m%d)`.

Brak któregokolwiek = `/goal` zwraca `[GOAL BLOCKED]` i wymaga ręcznej naprawy.

---

## 4. Czego `/goal` NIE robi

| Zakaz | Powód |
|---|---|
| Nie `git push` do remote | Force push na main / origin = nieodwracalna szkoda |
| Nie `npm publish` / `pip publish` | Publikacja jest gestem ludzkim |
| Nie `rm -rf` poza katalogiem feature (oprócz pivota z planem) | Plan-Validate-Execute obowiązkowe |
| Nie `DROP TABLE`, `DELETE FROM` bez WHERE | Operacje destruktywne na bazie wymagają human |
| Nie zmieniaj `.env`, `secrets/`, `~/.ssh/` | Strefa wrażliwa |

Lista enforce'owana w `scripts/run-goal-loop.sh` preflight check.

---

## 5. Workflow `/goal`

### Krok 1 — User wprowadza komendę

```
/goal <SPEC>
```

### Krok 2 — Parser (inline w parent agencie)

Parent agent (ten, który obsługuje komendę `/goal`) ekstraktuje z SPEC:

- `end_state` (zdanie po `/goal`).
- `verification` (komendy z linii `Weryfikacja:` — split po przecinkach i backtick'ach).
- `constraints` (lista z linii `Ograniczenia:`).

Zapisuje do `state/goal-current.json`:

```bash
jq -n --arg es "$END_STATE" --argjson v "$VERIFICATION_JSON" --argjson c "$CONSTRAINTS_JSON" \
  '{end_state: $es, verification: $v, constraints: $c, ts: now | todate}' \
  > state/goal-current.json
```

### Krok 3 — Walidacja (inline)

Parent agent sprawdza:

- `end_state` NIE zawiera fraz `"lepszy"|"ładniejszy"|"szybszy"|"better"|"nicer"|"faster"` bez progu liczbowego.
- `.verification | length >= 1` (musi być choć jedna komenda shell).
- `.constraints | length >= 1` (Scope Discipline jawne).

Failed walidacja → zwróć user'owi błąd z konkretną sugestią poprawki, NIE uruchamiaj pętli.

### Krok 4 — Pętla

```bash
scripts/run-goal-loop.sh state/goal-current.json
```

Skrypt (zatrzymuje się na każdej bramce, `references/approval-gates-protocol.md §5`):
1. Uruchamia Planner (Faza 1 SKILL.md) z prompt'em wygenerowanym z `end_state`. → **🚦 GATE #1** (STOP).
2. Spawn Generator + Evaluator (Faza 2).
3. Negocjacja kontraktu wokół `verification` (Faza 3) — kryteria binarne wynikają z komend weryfikacji. → **🚦 GATE #2** (STOP).
4. Pętla generator-ewaluator (Faza 4) z `MAX_GOAL_ITERATIONS`, per sprint → **🚦 GATE #3** (+ **GATE #4** jeśli QA) (STOP).
5. Verify (Faza 6) z pełnym audytem → **🚦 GATE #5** (STOP).
6. **NIE wchodzi w Fazę 7 (Ship) autonomicznie** — `/goal` zostawia gotową pracę na branchu po **🚦 GATE #6**, user decyduje o `git tag` i merge.

### Krok 5 — Raport końcowy

`state/goal-report.md`:

- Status: `achieved` / `pivoted_to_human` / `timeout` / `aborted_by_constraint_violation`.
- Liczba iteracji.
- Lista commitów.
- Linki do evidence.
- Pivot history (jeśli był).
- Czas wykonania.

User wraca rano, czyta raport, robi code review.

---

## 6. Bezpieczniki dla pracy między bramkami

> [!warning] Praca nocna „odpal i zostaw" — domyślnie OFF, włącz `/YOLO`
> Bez `/YOLO` pętla zatrzyma się na pierwszej bramce (#1 — plan) i będzie czekać na zgodę. `caffeinate` / auto-accept utrzymują sesję między bramkami, ale **nie zastępują człowieka** na bramce. Liczniki `MAX_GOAL_ITERATIONS` / `GOAL_TIMEOUT_HOURS` liczą się tylko między bramkami, nie w czasie oczekiwania. **Z `/YOLO`** bramki są auto-zatwierdzane (`approval-gates-protocol.md §9`) — wtedy `caffeinate` + tipy poniżej mają sens dla pracy nocnej.

Praktyczne tipy dla odcinków pracy między bramkami:

- **Osobny worktree** — Claude pracuje na izolowanym branchu, masz czysty main rano.
- **Auto-accept narzędzi** — bez tego `/goal` zatrzymuje się co 5 minut na permission prompt.
- **Caffeinate (macOS):** `caffeinate -di -t 28800` (8h bez sleep).
- **Power supply podłączony** — laptop na baterii zaśnie.
- **Sieć stabilna** — przewodowy LAN > Wi-Fi dla nocnych runów.

Te punkty NIE są w skillu, są w runbooku ops. Wpis w README skilla z odniesieniem.

---

## 7. Exit criterion trybu `/goal`

Pętla wychodzi w jednym z 4 stanów:

| Stan | Co znaczy | Co dalej |
|---|---|---|
| `achieved` | `verification` exit 0 + wszystkie kontrakty passed | User robi review + merge |
| `pivoted` | Po pivocie pętla kontynuuje od fazy 3 | Auto, dalej w pętli |
| `escalated` | Konflikt wymagań / `MAX_GOAL_ITERATIONS` osiągnięte / constraint violation | Plik `state/blockers.md` + człowiek |
| `timeout` | `GOAL_TIMEOUT_HOURS` osiągnięte | Zapisz checkpoint, zwróć kontrolę |

Wszystkie 4 stany loguje się w `state/breadcrumbs.json` z polami `final_state`, `iterations`, `pivots`, `duration_minutes`.

---

## 8. Integracja z audited-feature-workflow

Jeśli `audited-feature-workflow` jest zainstalowany w tym samym projekcie:

- `/goal` w agent-teams-builder uruchamia **całą pętlę** z generator-ewaluator.
- `/goal` w audited-feature-workflow uruchamia **pojedynczą pętlę AC** dla 1 feature.

Wybierz wg skali:
- Zadanie 1 feature → `audited-feature-workflow`.
- Zadanie 5+ sprintów → `agent-teams-builder` (ten skill).
