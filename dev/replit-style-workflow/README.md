# replit-style-workflow

> Strukturalny workflow feature'a w stylu Replit Agent dla Claude Code — od **analizy przez plan, approval gate, implementację (Sequential / Teams / Ralph), 7 zakresów testów, live preview, code review aż po ADR**. Wygodny rygor: tyle uprzęży, ile naprawdę potrzebne, bez biurokracji `audited-feature-workflow`.

[![version](https://img.shields.io/badge/version-v2.3.0-blue)]() [![SKILL.md](https://img.shields.io/badge/SKILL.md-2230_lines-orange)]() [![references](https://img.shields.io/badge/references-6_files-blue)]() [![scope](https://img.shields.io/badge/scope-full_SDLC-green)]()

---

## Co to jest

`replit-style-workflow` to skill Claude Code, który prowadzi agenta przez **kompletny lifecycle feature'a** — od deep analysis przez plan, hard approval gate, implementację z auto-routingiem (sequential / Agent Teams / ralph-loop), pełną matrycę testową aż po code review i ADR.

Skill jest **wariantem wygodnym** w decision-tree planerów `dev/`:

| Skill | Pozycja | Kiedy używać |
|-------|---------|--------------|
| **replit-style-workflow** | wygodny rygor (lighter) | typowe zadania — feature, refaktor, integracja, większość daily work |
| [`audited-feature-workflow`](../audited-feature-workflow/) | senior-grade (heavier) | wymagana audytowalność, 5-osiowy review, /goal overnight runs |
| [`feature-spec-planner`](../feature-spec-planner/) | planning-only | przerywasz po planie i ADR — handoff do innego wykonawcy |

Skill **nie generuje kodu „od ręki"**. Najpierw analiza, hipotezy, plan, approval — dopiero potem implementacja. Approval gate (Phase 5) jest **hard stop** — bez explicit „zatwierdzam" agent nie pisze kodu.

> **Historia nazwy:** skill nazywał się `feature-planner-v2`. Rename na `replit-style-workflow` w v2.3.0 (2026-05-25) — patrz [CHANGELOG.md](CHANGELOG.md). Trigger keywords nie zmienione.

## Kiedy używać

✅ **TAK** — gdy:
- Zadanie wymaga deep analysis kodu i ≥3 plików zmian.
- Chcesz approval gate przed implementacją (zero kodu bez „proceed").
- Plan kwalifikuje się do automatycznego dzielenia między teammates (Agent Teams) lub autonomicznej pętli `ralph-loop`.
- Wynik ma być mergowalny jako PR z ADR i artefaktami review.

❌ **NIE** — gdy:
- Jednoliniowa poprawka, literówka, rename zmiennej (overhead workflow > benefit).
- Eksploracja repozytorium bez intencji implementacji.
- Wymagasz **pełnej audytowalności** (Anti-Rationalization #11, Five-Axis Review, PR Sizing, /goal) — wtedy → [`audited-feature-workflow`](../audited-feature-workflow/).
- Chcesz **tylko plan + ADR** bez implementacji → [`feature-spec-planner`](../feature-spec-planner/).

## Jak uruchomić

W prompcie do Claude Code napisz dowolny z triggerów:

```
dodaj feature v2: <opis>
zaimplementuj <opis>
zrób żeby <oczekiwany efekt>
implement <opis>
build feature <opis>
ralph: <opis>            # opt-in autonomous loop dla L-size
ralph-loop <opis>
iteruj aż zielono <opis>  # alias dla ralph
```

Claude rozpozna trigger, wykona Phase 0 (env detection) i poprowadzi cię przez fazy.

## Architektura — fazy i bramki

```
Phase 0   ENV: PLAN_NUM + CR backend + /effort max + Agent Teams probe + ralph-loop probe + bypass hint
Phase 1   DEEP ANALYSIS: stack → architektura → analog END-TO-END → data model → impact radius
          → tests as spec → patterns catalog → Analysis Report
Phase 2   HIPOTEZY: ≥3 (H1 Minimalna / H2 Idiomatyczna / H3 Ambitna), opcjonalnie H4 hybrid
Phase 3   REKOMENDACJA: Hx + uzasadnienie + kluczowe decyzje techniczne
Phase 4   PLAN DOCUMENT: Co&Dlaczego | Rozmiar S/M/L | DoD | Założenia | Out of scope
          | Rollback | Zadania (+parallel-group) | Relevant files
Phase 5   SAVE & APPROVAL GATE                                        ⛔ HARD STOP #1
Phase 5.5 WORKTREE DECISION (M+): S=skip | M=propose | L=propose strongly
Phase 5.7 RALPH-LOOP DECISION (opt-in dla L): mutual-exclusive z Teams
Phase 6   IMPLEMENTATION — routing:
            ├─ 6-Ralph     (autonomous self-correcting loop, Stop-hook + completion-promise)
            ├─ 6-Teams     (parallel, auto 2–5 teammates wg parallel-groups)
            └─ 6-Sequential (default, jednowątkowo per task)
Phase 7   TESTING: 7 zakresów × matryca S/M/L (unit / integration / system / acceptance /
          E2E Playwright Chromium tier 1-4 / regression / perf+security)              ⛔ GATE
Phase 7.6 RALPH-LOOP TEST-FIX (opcjonalny, gdy testy ⩓zielone i fixable)
Phase 7.8 LIVE PREVIEW (M+ z UI): dev server background → Playwright headed Chromium
          → screenshot + console → user wizualnie zatwierdza                          ⛔ GATE
Phase 8   CODE REVIEW: AC derivation → bundle → fork wg CR_BACKEND (superpowers/codex/inline)
          → CR report → fix 🔴 + AC MUST                                              ⛔ GATE
Phase 9   ADR: ≥6 sekcji + Parallelization (jeśli 6-Teams) + Ralph-iterations (jeśli 6-Ralph)
```

## Trzy ścieżki implementacji (Phase 6 auto-routing)

Routing decyzyjny w `Phase 6.0` (z hard-assert mutual exclusion):

| Ścieżka | Wybór | Typowy use case |
|---------|-------|------------------|
| **6-Sequential** | default — gdy Teams off lub plan < 2 parallel-groups | typowy feature S/M, brak silnego paralelizmu |
| **6-Teams** | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` AND plan ma ≥ 2 `parallel-group:` | L-size cross-cutting z naturalnym podziałem (backend / frontend / db-migrations) |
| **6-Ralph** | user opt-in w Phase 5.7 (plugin `ralph-loop` zainstalowany + L-size + silny test gate) | autonomiczna pętla TDD-style — `implement → typecheck → lint → test → fix` aż do `<promise>FEATURE_DONE</promise>` |

> **Reguła twarda:** `RALPH_MODE=1` wyklucza `TEAMS_ENABLED=1`. User wybiera **jedno** dla L-size: paralelizm leadem (Teams) lub autonomiczny loop (Ralph). Hard-assert w Phase 6.0 egzekwuje to.

## Kluczowe pryncypia

### Approval Gate (Phase 5) — nienegocjowalny

```
📋 Plan #PLAN_NUM gotowy i zapisany.
🔎 Code review backend: ${CR_BACKEND}

✅  Zaakceptować — zaczynam implementację
🔄  Modyfikacja — napisz co zmienić
❌  Inne podejście — podaj numer hipotezy (H1/H2/H3)
➕  Dodaj lub usuń zadania
🔧  Zmień CR backend — napisz: codex / superpowers / inline
```

**Zero kodu przed explicit approval.** To jedyna twarda bramka w całym workflow (`audited-feature-workflow` ma ich 6) — wystarcza, bo plan przeszedł deep analysis i hipotezy. Dla typowego feature'a jedna bramka = wygodny rygor.

### Deep Research bez Gemini (Phase 1.0)

Skill używa **wyłącznie stock Claude Code + pluginów** — zero zewnętrznych LLM-ów:

| Sygnał | Mechanizm | Trigger |
|--------|-----------|---------|
| Zewnętrzna biblioteka / API / migracja wersji | **`context7`** (resolve-library-id → query-docs) | OBLIGATORYJNE przed implementacją |
| „Jak my to robimy" — nieznany obszar repo | **`Agent` z `subagent_type=Explore`** | gdy `rg`/`grep` > 20 hitów lub 0 |
| Konkretny URL ze specem | **`defuddle`** | czysty markdown z URL |
| Ogólny research (regulacja, RFC) | **`WebSearch`** → `defuddle`/`WebFetch` | brak materiału lokalnie |
| Głęboka analiza istniejącego kodu | **`codex:rescue`** / `delegate-codex` | legacy > 500 linii bez testów, auth/permissions |

Limit: **max 2 mechanizmy w jednym Phase 1**. Equipment lock: zero `delegate-gemini`. Każde użycie zalogowane w sekcji `## Research used` Analysis Report.

### Pre-flight `context7` przed kodem (Phase 6.−1)

> Jeśli pomyślisz „przecież wiem jak to działa" — to znak, że MUSISZ uruchomić context7.
> Pamięć modelu nie zna API zaktualizowanych po cutoff'cie. Nie zgaduj.

Dla **każdej** external library w planie: `resolve-library-id` + `query-docs` PRZED napisaniem kodu używającego biblioteki.

### 7-scope testing matrix (Phase 7)

| Zakres | S (surgical) | M (typowy) | L (auth/DB/UI) |
|--------|:---:|:---:|:---:|
| Unit | ✅ | ✅ | ✅ |
| Integration | ✅ | ✅ | ✅ |
| System | ⏭️ | ✅ | ✅ |
| Acceptance | ✅ (≥1 AC-F) | ✅ | ✅ |
| E2E (Playwright Chromium) | ⏭️ | ✅ golden + 1 edge | ✅ golden + 2-3 edge + failure |
| Regression | ✅ smoke | ✅ suite | ✅ pełen + dotknięte moduły |
| Perf + Security | ⏭️ | ✅ jeśli AC-N | ✅ |

**E2E hierarchia Chromium (4 tiery):**
1. `playwright test --project=chromium`
2. `playwright install chromium` (jeśli brak binarki)
3. `chrome-devtools-mcp` (real Chrome przez MCP)
4. CLI z innym browserem (jawny raport)

Brak Chromium ≠ skip E2E.

### Live preview (Phase 7.8) — M+ z UI

Dla feature'ów z UI rozmiaru M+:

```
detect dev server cmd → start background → wait ready → wyciągnij FEATURE_URL
→ Playwright headed Chromium → screenshot + console messages
→ user wizualnie zatwierdza → cleanup (kill dev + browser)
```

Skip dla S i backend-only.

### Code review fork (Phase 8) — `$CR_BACKEND`

Auto-detect w Phase 0.2, preference: `superpowers` → `codex` → `inline`.

| Backend | Mechanizm |
|---------|-----------|
| `superpowers` | plugin Superpowers — full multi-agent code review |
| `codex` | OpenAI Codex CLI (`codex exec`) — wysokiej jakości review z drugiego LLM |
| `inline` | Claude robi review sam w jednym przebiegu — fallback gdy nic innego nie ma |

User może override w Phase 5 approval: „zmień CR backend → codex/superpowers/inline".

## Struktura plików

```
dev/replit-style-workflow/
├── README.md                          ← ten plik
├── CHANGELOG.md                       ← historia wersji (v2.0.0 → v2.3.0)
├── SKILL.md                           ← główny prompt (2230 linii — historycznie prose-heavy)
└── references/
    ├── analysis-protocol.md           ← Phase 1: deep analysis (8 kroków, Analysis Report)
    ├── testing-protocol.md            ← Phase 7: 7 zakresów × matryca S/M/L
    ├── testing-map.md                 ← meta-test discipline (stan obecny: 0 walidatorów, retrofitting principle)
    ├── ac-protocol.md                 ← Phase 8.1: AC derivation (F/T/N, MUST/SHOULD/COULD, Given-When-Then)
    ├── code-review-protocol.md        ← Phase 8: AC schema, CR report, severity (format-agnostic)
    └── adr-template.md                ← Phase 9: ADR template (≥6 sekcji)
```

> **Uwaga:** v2 jest historycznie prose-heavy — **NIE MA katalogu `scripts/` ani `tests/`**. Cały rygor zawarty w prozie `SKILL.md`. Pryncypium retrofittingu (testing-map.md): **każda nowa funkcjonalność** = nowy skrypt walidatora + fixture + assert_exit w runnerze (wzorzec: `dev/agent-teams-builder/tests/`).

## Quick start — przykładowe scenariusze

### Typowy feature (M-size, Sequential)

1. **Prompt:** `dodaj feature: lista schronień z filtrowaniem po wojewodztwie`
2. Claude wykonuje Phase 0–4, prezentuje plan.
3. **Ty:** „zatwierdzam" → APPROVAL.
4. Phase 5.5: worktree? → wybierasz „nie" (default dla M).
5. Phase 5.7: ralph-loop? → skip (M-size).
6. Phase 6-Sequential: TodoWrite + per-task loop (impl → ORM → validate → commit).
7. Phase 7: 5 zakresów (unit / integration / system / acceptance / E2E + regression).
8. Phase 7.8: live preview headed Chromium na `localhost:3000/shelters`.
9. Phase 8: AC → bundle → review wg `$CR_BACKEND` → fix 🔴 + AC MUST.
10. Phase 9: ADR + final TodoWrite.

### L-size z autonomous ralph-loop

1. **Prompt:** `ralph: dodaj OAuth2 z Microsoft Entra ID, dla wszystkich endpointów /api/*`
2. Phase 0.5 wykrywa `RALPH_AVAILABLE=1`.
3. Phase 0–4 jak wyżej, plan rozmiar **L** z silnym test gate.
4. **Approval.**
5. Phase 5.5: worktree → tak (default dla L).
6. Phase 5.7: ralph-loop → tak (user explicit).
7. Phase 6-Ralph: build prompt → `/ralph-loop` z `--completion-promise FEATURE_DONE` + `--max-iterations 30` (auto-policzone).
8. Loop iteruje aż `<promise>FEATURE_DONE</promise>` lub iter-cap. Operator monitoruje (NO impl).
9. Phase 7.8 (live preview) **PO** loopie — interaktywna, loop nie potrafi.
10. Phase 8 → 9 → merge.

### L-size cross-cutting z Agent Teams

1. **Prerequisite:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` w `~/.claude/settings.json`.
2. **Prompt:** `dodaj feature v2: panel admin z CRUD-em schronień + audit log`
3. Phase 0.4 wykrywa `TEAMS_ENABLED=1`.
4. Plan rozmiar L z ≥ 2 `parallel-group:` (`backend`, `frontend`, `db-migrations`).
5. **Approval.**
6. Phase 5.5: worktree → tak.
7. Phase 5.7: ralph-loop → skip (cross-cutting = lead-driven).
8. Phase 6-Teams: auto-sizing → 3-4 teammates. Lead nie koduje — synchronizuje, blokery, cleanup.
9. Phase 7 → 7.8 → 8 → 9.

## Wymagania

- **Claude Code** (CLI lub IDE plugin).
- **Bash 3.2+** (POSIX shell w blokach SKILL.md).
- **Git 2.5+** (worktree support dla Phase 5.5).
- **Node + jq** — do parsowania `package.json` i `~/.claude/settings.json` w Phase 0.
- **Plugin `ralph-loop@claude-plugins-official`** (opcjonalnie) — dla Phase 6-Ralph i 7.6.
- **Plugin Superpowers** lub **Codex CLI** (opcjonalnie) — dla wysokiej jakości code review w Phase 8.
- **Playwright + Chromium** — dla Phase 7 E2E tier 1 i Phase 7.8 live preview.

## Konfiguracja środowiska (Phase 0 detection)

Skill automatycznie wykrywa stan środowiska w Phase 0 i adaptuje workflow:

```bash
# Włącz Agent Teams (Phase 0.4) — dopisz do ~/.claude/settings.json:
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }

# Włącz ralph-loop (Phase 0.5)
/plugin marketplace add claude-plugins-official
/plugin install ralph-loop@claude-plugins-official

# Bypass mode dla długich Phase 6 (opcjonalne — sugerowane dla L-size / 6-Teams)
claude --dangerously-skip-permissions
# lub stałe w ~/.claude/settings.json:
{ "defaultMode": "bypassPermissions" }
```

Phase 5 approval gate **DALEJ obowiązuje** w bypass mode (chat message, nie permission prompt).

## Critical rules (z SKILL.md)

| Reguła | Detail |
|--------|--------|
| **Analysis Report obowiązkowy** | Phase 1.8 — bez niego nie startujemy Phase 2 |
| **Open questions blokują Phase 2** | Jeśli są w Analysis Report → STOP i zapytaj |
| **Analog featuru = primary template** | Brak analoga → Blocker Protocol |
| **H1/H2/H3 dla hipotez** | Nigdy `[N]` |
| **Zero kodu przed approval** | Phase 5 hard stop |
| **`context7` OBLIGATORYJNE przed kodem** | Phase 6.−1 dla każdej external library |
| **Deep research = stock CC + pluginy** | Zero `delegate-gemini` / zewnętrznych LLM |
| **TodoWrite z całą listą** | Harness CC ma jeden tool — nadpisuje całą listę |
| **Test gate przed review** | 7 zakresów per matryca S/M/L |
| **E2E hierarchia Chromium 4-tier** | Brak Chromium ≠ skip E2E |
| **Worktree dla L** | Auth/DB/UI w izolowanym `git worktree`; cleanup po mergu PR |
| **Ralph-loop opt-in** | Phase 5.7; mutual-exclusive z Teams; S = skip zawsze |
| **Live preview przed code review** | Phase 7.8 M+ z UI; headed Chromium |
| **Fix 🔴 + AC MUST przed ADR** | Phase 9 dopiero przy zero krytycznych i wszystkich MUST |
| **PLAN_NUM wszędzie** | Spójny w plikach, commitach, review, ADR |

Pełna tabela (40+ wierszy): [SKILL.md → Critical Rules](SKILL.md).

## Limitacje znane

- **Prose-heavy:** SKILL.md ma 2230 linii (znacznie powyżej 500-line soft-limit zalecanego w `DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md`). Refaktor na hub-and-spoke planowany długoterminowo — patrz [`references/testing-map.md`](references/testing-map.md).
- **Brak `scripts/` i `tests/`:** wszystkie bramki są w prozie, nie są egzekwowalne deterministycznie. Pryncypium retrofittingu zostało wprowadzone w v2.2.0 — każda nowa funkcjonalność dodaje skrypt + fixture + meta-test (wzorzec: `dev/agent-teams-builder/tests/`).
- **Single approval gate:** dla użytkowników wymagających większego rygoru (5 bramek, Anti-Rat #11, Five-Axis Review, /goal overnight) → użyj [`audited-feature-workflow`](../audited-feature-workflow/).
- **Phase 7.8 wymaga UI:** dla czystego backendu live preview = N/A (oznacz `n/a — backend-only`). Phase 7 zakres 3 (systemowe) z prawdziwym HTTP zastępuje E2E.

## Wersjonowanie

- **v2.0.0** (2026-04-28) — initial release: workflow Replit Agent style, Agent Teams routing (Sequential / Teams 2-5), deep research bez Gemini.
- **v2.1.0** (2026-05-08) — 7-scope testing matrix, Phase 5.5 (worktree), Phase 7.8 (live preview), ralph-loop (6-Ralph).
- **v2.2.0** (2026-05-25) — Test Discipline: `references/testing-map.md` + pryncypium retrofittingu.
- **v2.3.0** (2026-05-25) — **Rename:** `feature-planner` → `replit-style-workflow` (folder + frontmatter). Trigger keywords zachowane.

Pełna historia: [CHANGELOG.md](CHANGELOG.md).

## Linki

- [SKILL.md](SKILL.md) — główny prompt skilla
- [CHANGELOG.md](CHANGELOG.md) — historia wersji
- [references/](references/) — protokoły lazy-load (analysis / testing / AC / CR / ADR / testing-map)
- [audited-feature-workflow](../audited-feature-workflow/) — senior-grade wariant z 6 bramkami + `/goal`
- [feature-spec-planner](../feature-spec-planner/) — wariant planning-only (przerywa po planie + ADR)
- [agent-teams-builder](../agent-teams-builder/) — orkiestrator wykorzystywany w Phase 6-Teams

## Filozofia

> „Replit Agent style: szybko z analizą, szybko z planem, hard stop na approval, dalej tyle uprzęży, ile naprawdę potrzebne. Nie biurokracja — wygodny rygor."

`replit-style-workflow` jest dla zespołów, które chcą **strukturalny lifecycle feature'a** (analiza → plan → approval → implementacja → testy → live preview → review → ADR), ale **nie potrzebują 6 bramek i 11-wierszowej Anti-Rationalization** z `audited-feature-workflow`. Domyślny wybór dla typowych zadań — gdy zaczynasz mieć wątpliwości („czy to nie powinno być w pełni audytowalne?"), to znak, że trzeba przeskoczyć do `audited-feature-workflow`.
