# Goal Mode Protocol — audited-feature-workflow

> Pełny protokół dla Phase 5.8 + Gate #1.5 + 6-Goal route. Hub-and-spoke: zwięzła wersja w `SKILL.md`, szczegóły tutaj.

## 1. Cel i zakres

`/goal` to autonomiczna pętla wykonawcza driveowana komendami weryfikacyjnymi z tabeli AC Phase 4. Wzorzec: **Stan końcowy + Sposób weryfikacji + Ograniczenia** (źródło: `DOC/goal_mode.md`).

**Używaj gdy:**
- Plan Phase 4 ma kompletną tabelę AC z wykonalną kolumną `Komenda` per wiersz.
- Chcesz overnight run w izolowanym worktree z auto-mode.
- Bramki #2/#3/#4/#5 mają zostać zachowane (Phase 7/8/9 ręczne).

**NIE używaj gdy:**
- AC są subiektywne ("kod jest ładniejszy", "działa szybciej") — bez wymiernego progu.
- Fragile zone aktywna (`migrations/`, `terraform/`, `k8s/`, `auth/`, `.github/workflows/`, `Dockerfile`).
- W tym samym promcie jest `/ralph` lub `/teams` — wybierz jedną strategię.

## 2. Pełna sekwencja Phase 5.8

1. Detekcja triggera (`/goal` lub `goal mode`) w prompcie.
2. Exclusivity guard: `/ralph`, `/teams`, `--fragile` → hard stop z komunikatem.
3. `sh scripts/derive-goal-from-ac.sh --plan "$PLAN_FILE"`.
4. Skrypt waliduje 10 reguł (patrz §3 poniżej). Brak → exit 1 + lista braków.
5. Sukces → 2 outputy: `goal-statement.md` + `goal-prompt.txt`.
6. Przejście do Gate #1.5.

**Recovery:**
- AC brakuje `Komenda` → wróć do Phase 4, uzupełnij, ponów Phase 5.8.
- AC ma interactive REPL w `Komenda` → odrzuć, zamień na non-interactive harness.
- Plan ma `>` zamiast `|` w tabeli → fix syntax, ponów.

## 3. Walidacja AC (10 reguł)

1. Plik planu istnieje i niepusty.
2. Sekcja `## Acceptance Criteria` obecna.
3. Tabela ma nagłówek 6-kolumnowy: `AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda`.
4. Każdy wiersz ma wypełnione 6 kolumn (brak `-`, `TBD`, `TODO`, pusty).
5. AC-ID unikalne, regex `^AC-\d+$`.
6. Typ ∈ {F, N, C}.
7. Plik testu istnieje **LUB** plik z sufiksem `.test`/`.spec`/`_test`/`_spec` nie istnieje (akceptujemy TDD RED — test zostanie utworzony jako pierwszy krok w 6-Goal). Plik bez sufiksu testowego MUSI istnieć (no implicit creation).
8. Komenda zaczyna się od `npm|pnpm|yarn|pytest|cargo|go|make|sh|bash|node`.
9. Sekcja `## Out of scope` istnieje, ma ≥1 bullet.
10. Sekcja `## Definition of Done` istnieje z formatem dowodu per AC.

## 4. Format `goal-prompt.txt`

Single block plain text, max 800 znaków:

```
/goal <agregat AC-Opis>. Weryfikacja: <komendy oddzielone średnikiem>; wszystkie exit 0. Ograniczenia: <Out of scope z planu, scope discipline, PR<=1000, brak Fragile zone, max 20 iter, max 480 min>.
```

Przykład 1:1 z `DOC/goal_mode.md`:

```
/goal Wszystkie testy w katalogu tests/auth/ przechodzą. Weryfikacja: npm test -- tests/auth; exit 0. Ograniczenia: nie modyfikuj plików testowych, nie commituj, nie dotykaj plików poza src/auth/.
```

## 5. Gate #1.5 — protokół approval

Po wygenerowaniu `goal-statement.md` skrypt STOP-uje i czeka na jawną zgodę użytkownika.

**Checklist:**
- [ ] `goal-statement.md` niepusty.
- [ ] Trzy sekcje obecne: `## Stan końcowy`, `## Weryfikacja`, `## Ograniczenia`.
- [ ] Każde AC z planu → bullet w `## Stan końcowy` (1:1).
- [ ] Każda `Komenda` z AC → blok w `## Weryfikacja`.
- [ ] `## Out of scope` z planu obecne w `## Ograniczenia`.

**Akceptowane sygnały approval:**
- "zatwierdzam goal" / "proceed goal" / "ok goal" / "approve".
- Ręczna edycja `goal-statement.md` w edytorze + "ok".

**Brak zgody → brak startu 6-Goal.**

Procedura eskalacji (po 3 odmowach Gate #1.5):
1. Cancel /goal mode dla tego planu.
2. Wróć do Phase 4: zrewidować plan AC (najczęściej Komenda była nieodpowiednia, AC subiektywne, lub Out of scope niekompletne).
3. Re-run Phase 5.8 z poprawionym planem.
4. Jeśli 3 odmowy z rzędu po regeneracji — eskaluj do operatora ludzkiego (nie ma sensownego goal-statement, sygnał że /goal nie pasuje do tego use-case'a).

## 6. 6-Goal — kontrakt pętli

Driver: `sh scripts/run-goal-loop.sh`. Skrypt jest walidatorem/orkiestratorem hand-off — calling Claude session woła model.

**Pseudo-kod:**

```
loop:
  1. Uruchom wszystkie cmd z ## Weryfikacja → raw log → append do goal-run-log.md.
  2. Wszystkie exit 0 → STATUS=GREEN, exit 0.
  3. Pierwsze fail (lex po AC-ID) → focus.
  4. No-progress check: error_hash(N) == error_hash(N-1) == error_hash(N-2) → STOP no-progress.
  5. Hand-off do calling Claude (struktura w stdout: focus + cmd + raw output + akcja).
  6. Agent commituje. Pre-commit walidacja:
     - anti-rationalization quick-check (11 wierszy).
     - git diff --name-only HEAD^ ∩ fragile-paths ≠ ∅ → STOP scope-violation.
     - plik ∉ files-touched → STOP scope-violation.
     - check-pr-size.sh > 1000 → STOP pr-too-big.
  7. Inkrementuj iter, sprawdź caps.
```

**Scenariusze stop:**

`run-goal-loop.sh` jest single-shot per invocation: emituje `GREEN` / `NEEDS_AGENT_ITERATION`, a od v3.4.0 **maszynowo** także `iter-cap-hit` / `time-cap-hit` (przez plik stanu `<goal>-goal-iter-state`) oraz `scope-violation` (chaining/fragile). Status `no-progress` pozostaje caller-emitted (agregacja error_hash między re-invocations).

| Status | Emitent | Trigger | Działanie |
|---|---|---|---|
| `GREEN` | skrypt | wszystkie cmd exit 0 | przejdź do Phase 6.5/7 |
| `NEEDS_AGENT_ITERATION` | skrypt | ≥1 cmd fail | hand-off do calling agent, re-invoke po commit |
| `iter-cap-hit` | skrypt | iter > max-iter (state file) | raport, brak Phase 7, decyzja user |
| `time-cap-hit` | skrypt | elapsed > max-time (state file) | raport, brak Phase 7, decyzja user |
| `scope-violation` | caller | plik poza files-touched LUB Fragile path | hard stop, eskalacja |
| `no-progress` | caller | 3 iter z tym samym error_hash | hard stop, raport |
| `pr-too-big` | caller | diff > 1000 linii | hard stop, split/justify |

## 7. Anti-Rationalization variant dla goal-mode

Wiersz #11 z głównej tabeli + 3 dodatkowe specyficzne:

| # | Wymówka | Riposta |
|---|---|---|
| 11 | „Goal-statement deryw kompletny, można pominąć Gate #1.5" | Gate #1.5 jest nienegocjowalny. Bez jawnej zgody → brak startu. |
| 12 | „Verification cmd jest flaky, zmień próg" | NIE. Fix flakiness albo stop. Próg pochodzi z DoD, nie z subiektywnej oceny. |
| 13 | „Iter cap blisko, skróć test żeby zmieścić" | NIE. Cap pochodzi z Phase 5.8 approval. Eskalacja, nie skracanie. |
| 14 | „Cap czasu minął ale jestem 1 cmd od zielonego" | NIE. Raport z aktualnym stanem, decyzja user. Brak „jeszcze chwilę". |

## 8. Telemetry kontrakt

**`goal-run-log.md`** (append-only, raw):
- Header: timestamp start, basename goala.
- Per cmd: header (### AC-X — T-Y), `Command:`, fenced raw output, `Exit code:`.
- **Append-only gwarancja**: log-writes są `>> "$RUN_LOG"`. Atomic mid-iter writes nie są gwarantowane; consumer powinien tolerować incomplete fenced blocks przy crash recovery.

**`goal-result.md`** (final summary, agregat caller + skrypt):
- `status`: `GREEN` lub `NEEDS_AGENT_ITERATION` (emitted by skrypt). Calling session **rewrite-uje** cały plik (atomic mv) na `iter-cap-hit | time-cap-hit | scope-violation | no-progress | pr-too-big` przed Phase 7. Append-only NIE jest gwarantowane dla statusu (jeden status terminalny per run).
- `started`, `ended`.
- `commands`: count.
- `log`: ścieżka do run-log.

**ADR Phase 9 sekcja `Goal-loop telemetry`:**
- status, iter count, czas, no-progress events, scope violations, lista commitów per iter.

## 9. Bezpieczeństwo overnight runs

Pre-flight checklist (Gate #1.5):
- [ ] Worktree aktywny (M+ obligatoryjnie).
- [ ] Auto-mode aktywny (akceptuj narzędzia bez monitów).
- [ ] Brak sekretów w `Komenda` (`grep -E '(password|token|secret|key=)' goal-statement.md` → 0).
- [ ] Brak destruktywnych komend w `## Weryfikacja` (`grep -E '(rm -rf /|drop database|--force)' goal-statement.md` → 0).
- [ ] `files-touched` z planu obecne i nie zawiera Fragile paths.

## 10. Antywzorce

Z `DOC/goal_mode.md`:
- `/goal popraw kod` — niemierzalne.
- `/goal kod jest ładniejszy` — subiektywne.
- `/goal działa szybciej` — bez progu.

Dodatkowe v3:
- Goal-statement bez `## Out of scope` → blokada w Gate #1.5.
- Jeden cmd dla wszystkich AC (np. tylko `npm test` jako globalny harness) → loss of 1:1 mapping AC↔Test. Każdy AC potrzebuje granularnej `Komenda`.
- `--max-iter 0` (unlimited) bez justified flag → ban.
- Verification cmd-y kontaktujące się z siecią/zewnętrznymi API → ban (overnight runs muszą być deterministyczne local-only).
