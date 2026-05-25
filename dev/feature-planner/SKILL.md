---
name: feature-planner-v2
version: v2.2.0
description: Structured feature workflow (Replit Agent style) with Agent Teams auto-routing, ralph-loop autonomous mode, /effort max, deep research (context7/Explore/defuddle/WebSearch/codex; ZERO Gemini). Use when user describes a feature/change/task and Claude Code should plan + implement end-to-end. Triggers "dodaj feature v2", "zaimplementuj", "zrób żeby", "implement", "build feature", "ralph", "ralph-loop", "iteruj aż zielono". Runs detect env → analysis → hypotheses → plan → APPROVAL → worktree (M+) → ralph decision → implement (6-Sequential / 6-Teams 2–5 / 6-Ralph autonomous) → 7 test scopes (unit/integration/system/acceptance/E2E-playwright-chromium-tier1234/regression/perf+security per S/M/L; opt 7.6 ralph test-fix) → live preview (M+ UI) → code review → ADR. Never skip approval gate or code review.
---

# Feature Planner v2 — Replit Agent Style + Auto Agent Teams + Ralph Loop + Deep Research

> **v2 deltas vs v1:**
> - Phase 0.3 — `/effort max` request (boost reasoning przed analizą)
> - Phase 0.4 — auto-detect `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` (env / settings.json)
> - Phase 0.5 — auto-detect `ralph-loop` plugin (cache + plugins.json + enabledPlugins)
> - Phase 1.0 — Deep research probe (stock CC + pluginy: context7, Explore, defuddle, WebSearch, codex; ZERO Gemini)
> - Phase 4 — `parallel-group` hint per task
> - Phase 5.7 — Ralph-loop decision (opt-in dla L-size lub backend-only z silnym test gate)
> - Phase 6 — routing: 6-Sequential ↔ 6-Teams (auto 2–5 teammates) ↔ **6-Ralph (autonomous self-correcting loop)**
> - Phase 7 — E2E zakres 5 wzmocniony: Playwright Chromium first → `chrome-devtools-mcp` fallback → CLI screenshot
> - Phase 7.6 — opcjonalny ralph-loop test-fix dla E2E flakiness / czerwonych zakresów

Full workflow: **analyze → hypothesize → plan → save → approve → implement+commit → test → review → ADR**

Reference files (read when you reach each phase):
- Phase 1 — Deep Analysis: `references/analysis-protocol.md`
- Phase 7 — Testing (aplikacji wytwarzanej przez skill): `references/testing-protocol.md`
- Phase 8.1 — Acceptance Criteria: `references/ac-protocol.md`
- Phase 8 — Code Review: `references/code-review-protocol.md` (format-agnostic: AC schema, CR report, severity)
- Phase 9 — ADR: `references/adr-template.md`
- Test Discipline (meta-testy samego skilla, Beyoncé Rule + Prove-It dla regresji): `references/testing-map.md` — **v2 NIE ma `scripts/` ani `tests/`**, plik dokumentuje stan i wymusza retrofitting przy każdej nowej funkcjonalności (każda nowa faza/bramka = nowy skrypt walidatora + fixture + assert_exit w runnerze, wzorzec: `dev/agent-teams-builder/tests/`).

---

## PHASE 0 — PLAN NUMBERING & ENVIRONMENT DETECTION

### 0.1 PLAN_NUM

```bash
mkdir -p docs/plany

PLAN_NUM_RAW=$(
  find docs/plany -maxdepth 1 -type f -name '[0-9]*-*.md' -printf '%f\n' 2>/dev/null \
    | sed -E 's/^0*([0-9]+)-.*/\1/' \
    | sort -n | tail -1
)
PLAN_NUM_RAW=$(( ${PLAN_NUM_RAW:-0} + 1 ))
printf -v PLAN_NUM "%03d" "$PLAN_NUM_RAW"   # 001, 002, ... — stabilne sortowanie
echo "PLAN_NUM=$PLAN_NUM"
```

> **Substitution rule:** Replace every occurrence of `PLAN_NUM` in commands, file paths,
> and commit messages with the actual number (e.g. `042`). Never output the literal string `PLAN_NUM`.

### 0.2 Code review backend detection

Order of preference: `superpowers` → `codex` → `inline`.

```bash
if ls ~/.claude/plugins/ 2>/dev/null | grep -qi superpowers \
   || grep -qi '"superpowers"' ~/.claude/plugins.json 2>/dev/null; then
  CR_BACKEND="superpowers"
elif command -v codex >/dev/null 2>&1; then
  CR_BACKEND="codex"
else
  CR_BACKEND="inline"
fi
echo "CR_BACKEND=$CR_BACKEND"
```

Print to user: `🔎 Code review backend: ${CR_BACKEND} (plan #${PLAN_NUM})`

### 0.3 Effort boost — `/effort max`

Bezpośrednio po wykryciu `PLAN_NUM` i `CR_BACKEND` wypisz do użytkownika:

```
🧠 Wchodzę w tryb głębokiej analizy. Włącz proszę `/effort max`
   (lub potwierdź, że już jest aktywne) — Phase 1 i Phase 4 wymagają
   pełnej mocy reasoningu.
```

To jest miękka prośba — nie blokuje workflow. Jeśli user nie odpowie, kontynuuj
na obecnym ustawieniu, ale zaloguj `EFFORT_REQUESTED=max`.

### 0.4 Agent Teams probe

Wykryj czy `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` jest aktywne. Sprawdzaj
w kolejności: env var → `.claude/settings.json` (projekt) → `~/.claude/settings.json` (user).

```bash
# Env var (najwyższy priorytet — działa w bieżącej sesji)
TEAMS_ENV="${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-0}"

# Settings.json — projekt → user
TEAMS_PROJ=$(jq -r '.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS // "0"' .claude/settings.json 2>/dev/null || echo 0)
TEAMS_USER=$(jq -r '.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS // "0"' ~/.claude/settings.json 2>/dev/null || echo 0)

if [ "$TEAMS_ENV" = "1" ] || [ "$TEAMS_PROJ" = "1" ] || [ "$TEAMS_USER" = "1" ]; then
  TEAMS_ENABLED=1
else
  TEAMS_ENABLED=0
fi
echo "TEAMS_ENABLED=$TEAMS_ENABLED  (env=$TEAMS_ENV proj=$TEAMS_PROJ user=$TEAMS_USER)"
```

Wypisz do użytkownika jedną z dwóch linii:

- `TEAMS_ENABLED=1` → `🤖 Agent Teams: WŁĄCZONE — Phase 6 pójdzie równolegle`
- `TEAMS_ENABLED=0` → `🤖 Agent Teams: WYŁĄCZONE — Phase 6 sekwencyjnie`

**Jeśli `TEAMS_ENABLED=0`**, pokaż jak włączyć (dopisać do `~/.claude/settings.json`):

```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

…ale nie blokuj workflow. Kontynuuj sekwencyjnie. Zmiana w `settings.json`
zacznie działać dopiero w **następnej** sesji Claude Code.

> **Canonical reference:** `CLAUDE-CC/Konfiguracja/Ustawienia.md` — pełna lista env vars
> harness'a (Agent Teams, bypass mode, /effort, kompaktowanie) z aktualnymi wartościami
> per-vault.

### 0.5 Ralph-loop plugin probe

Wykryj czy plugin `ralph-loop@claude-plugins-official` jest zainstalowany i aktywny.
Phase 5.7 użyje wyniku do propozycji autonomicznego trybu (Phase 6-Ralph).

```bash
# (1) Cache obecny — fizyczne pliki
RALPH_CACHED=0
ls ~/.claude/plugins/cache/claude-plugins-official/ralph-loop/ >/dev/null 2>&1 && RALPH_CACHED=1

# (2) Aktywny w settings.json (enabledPlugins) — guard gdy plik nie istnieje
RALPH_ENABLED="false"
if [ -f ~/.claude/settings.json ]; then
  RALPH_ENABLED=$(jq -r '.enabledPlugins["ralph-loop@claude-plugins-official"] // false' \
    ~/.claude/settings.json 2>/dev/null || echo "false")
fi

# (3) Setup script dostępny (executable test)
RALPH_SCRIPT=$(find ~/.claude/plugins/cache/claude-plugins-official/ralph-loop \
  -name "setup-ralph-loop.sh" -type f 2>/dev/null | head -1)

if [ "$RALPH_CACHED" = "1" ] && [ "$RALPH_ENABLED" = "true" ] && [ -n "$RALPH_SCRIPT" ]; then
  RALPH_AVAILABLE=1
else
  RALPH_AVAILABLE=0
fi
echo "RALPH_AVAILABLE=$RALPH_AVAILABLE  (cached=$RALPH_CACHED enabled=$RALPH_ENABLED)"
```

Wypisz do użytkownika **tylko gdy `RALPH_AVAILABLE=1`** (cisza gdy 0 — by nie zaśmiecać UX):

```
🔁 Ralph-loop: dostępny — Phase 5.7 zaproponuje autonomiczny tryb iteracyjny dla L-size
```

> **Co to daje:** Phase 6-Ralph (opt-in po approval) wpina implementację w pętlę
> `while ! green: implement → typecheck → lint → test → fix → repeat`. Plugin używa
> Stop-hooka, więc Claude Code **sam** podaje sobie ten sam prompt aż do `<promise>FEATURE_DONE</promise>`.
> Przydatne dla L-size z silnym test gate (TDD-style), nieprzydatne dla S/M gdzie human-in-the-loop wystarczy.

### 0.6 Bypass mode hint (długie Phase 6)

Dla planów rozmiaru **L** lub 6-Teams (≥ 3 teammates) Phase 6 będzie wywołać dziesiątki
permission prompts (Bash dla ORM/git, Write dla każdego pliku, TodoWrite na każdą zmianę
statusu). Aby uniknąć wybijania flow, wypisz do użytkownika **miękką** sugestię:

```
🔓 Phase 6 dla planu rozmiaru L wykona ~30+ tool calls. Rozważ uruchomienie
   sesji z `claude --dangerously-skip-permissions` (jednorazowo) lub stałe
   ustawienie `"defaultMode": "bypassPermissions"` w `~/.claude/settings.json`.

   To nie blokuje approval gate (Phase 5) — to chat-level pytanie, nie permission prompt.
```

**Reguły:**

- Sugestia **opcjonalna** — nie blokuj, nie pytaj o potwierdzenie. User decyduje.
- Pomiń sugestię dla **S** (≤ 5 tool calls — overhead nie warty).
- W bypass mode approval gate Phase 5 **DALEJ obowiązuje** (chat message, nie permission prompt).
- Bypass nie omija sanity checks (`test -s`) ani test gate'u.

---

## PHASE 1 — DEEP ANALYSIS

**Przeczytaj teraz `references/analysis-protocol.md`** — pełne komendy, wzorce detekcji stacku,
szablony reverse-search, format Analysis Report.

Nigdy nie proponuj rozwiązania przed analizą. Phase 1 produkuje **Analysis Report** — jawny artefakt,
który zasila Phase 2 (hipotezy) i Phase 4 (plan). To nie jest „posiedź nad kodem 2 minuty" —
to strukturalne skanowanie w 8 krokach.

### 1.0 Deep research probe — kiedy i czym (stock CC + pluginy)

Przed wejściem w 1.1 zdecyduj, czy ten feature wymaga deep research. **Skip całkowicie**, jeśli:
rozmiar = **S** AND analog feature znajdziesz w 1.3 AND zero nowych zależności / regulacji / API zewn.

Jeśli NIE skip → użyj **wyłącznie stock Claude Code + pluginów** (zero zewnętrznych LLM-ów):

| Sygnał w requeście | Mechanizm | Trigger |
|--------------------|-----------|---------|
| **JAKAKOLWIEK** zewnętrzna biblioteka / API biblioteki / migracja wersji (React, Next, Prisma, Tailwind, Drizzle, itd.) | **`context7` skill** (resolve-library-id → query-docs) — **OBLIGATORYJNE przed implementacją** | Zawsze przed napisaniem kodu używającego biblioteki — nie polegaj na pamięci / training data |
| „Jak my to robimy" — nieznany obszar repo / wiele kandydatów na analog | **`Agent` z `subagent_type=Explore`** (1–3 równolegle) | Gdy `rg`/`grep` w 1.3 daje > 20 hitów lub 0 |
| Konkretny URL ze specyfikacją / PRD / dokumentem urzędowym | **`defuddle` skill** | Czysty markdown z URL (zamiast WebFetch z noise'em) |
| Ogólny research bez znanego URL (regulacja, standard, RFC) | **`WebSearch`** → potem `defuddle`/`WebFetch` na top-3 | Gdy domena prawna/proceduralna (PSP, RODO, WCAG) i brak materiału lokalnie |
| Głęboka analiza istniejącego kodu (security, dependency graph, „co to robi") | **`codex:rescue`** / `delegate-codex` | Kod legacy > 500 linii bez testów, lub feature dotykający auth/permissions |

**Reguły:**

1. **Maks 2 mechanizmy w jednym Phase 1** — research nie jest celem, tylko paliwem dla planu.
2. **Każde użycie zaloguj** w Analysis Report 1.8 (nowa linia: `## Research used` z listą: `context7: react@19 server-actions`, `Explore: shelters/ patterns`).
3. **Equipment lock** — nie używamy `delegate-gemini` ani innych zewnętrznych LLM. Stock CC + pluginy only.
4. **Cache wyników** — jeśli ten sam plan robisz drugi raz tego samego dnia, wyniki context7/Explore reuse z chatu, nie wywołuj ponownie.

Output 1.0 → wpisz w Analysis Report sekcję `## Research used` (nawet pusta: `none — feature S, analog znany`).

### 1.1 Stack & framework detection (~1 min)

Jednoliniowa klasyfikacja: język, framework web, ORM/DB, test runner, bundler.
Output: `Next.js 14 (app router) + Prisma/Postgres + Vitest + Playwright + Tailwind`.

```bash
# Node
[ -f package.json ] && jq -r '.dependencies + .devDependencies | keys[]' package.json 2>/dev/null | head -40
# Python
[ -f pyproject.toml ] && grep -E '^(name|version|dependencies|tool\.)' pyproject.toml
[ -f requirements.txt ] && head -30 requirements.txt
```

### 1.2 Architecture walk (entry → DB) (~5 min)

Prześledź drogę requestu od wejścia do danych. Zanotuj warstwy które realnie istnieją
(niektóre codebases nie mają service layer — domain anemiczny; niektóre mają CQRS; niektóre mają tRPC).

**Entry points:**
```bash
# Next.js app router / pages
find . -type d \( -name app -o -name pages \) -not -path '*/node_modules/*' | head -5
# Express/Fastify/NestJS
rg -l 'app\.(get|post|put|delete|patch)\(|@(Get|Post|Controller)\(|router\.(get|post)' \
   --type ts --type js 2>/dev/null | head -10
# FastAPI/Flask/Django
rg -l '@(app|router)\.(get|post|put|delete)|@api_view|urlpatterns' --type py 2>/dev/null | head -10
```

### 1.3 Find the analog — READ END TO END (~10 min, NAJWAŻNIEJSZY KROK)

Dla featuru do zbudowania znajdź **najbliższy istniejący feature** i przeczytaj go w całości —
od route przez service/repo do schematu DB i testów. To jest **PRIMARY TEMPLATE** dla Phase 4.

```bash
# Reverse-search po słowach kluczowych domeny (przykłady PSP)
rg -l "shelter|schron|Dostepnosc" --type ts --type tsx    # gdziesieukryc.pl
rg -l "CEZOL|civil.?protection" --type ts
rg -l "mLegitymacja|digital.?id" --type ts
rg -l "SOIA|ALARM.?PL|siren" --type ts
```

Jeśli nie znajdujesz analoga → **Blocker Protocol** (feature nowatorski dla codebase, trzeba
ustalić konwencje z użytkownikiem PRZED Phase 2).

### 1.4 Data model snapshot (~2 min)

```bash
# Prisma
[ -f prisma/schema.prisma ] && grep -E '^(model|enum) ' prisma/schema.prisma
# Drizzle
rg -l 'pgTable|mysqlTable|sqliteTable' --type ts | head -5
# SQLAlchemy/Django
rg -l 'class.*\(db\.Model\)|class.*\(models\.Model\)' --type py | head -5
# Recent migrations
ls -lt prisma/migrations/ alembic/versions/ migrations/ 2>/dev/null | head -10
```

### 1.5 Dependency impact radius — reverse search (~5 min)

Dla każdego pliku / typu / funkcji, który planujesz dotknąć → kto go używa?

```bash
# Kto importuje ten moduł?
rg -l "from.*['\"].*shelters['\"]|import.*shelters" --type ts
# Kto używa tego typu/interfejsu?
rg -w "ShelterDto|ShelterEntity|ShelterService"
# Auth middleware dotykające tej ścieżki
rg -l "requireAuth|withAuth|@UseGuards|@login_required" --type ts --type py
```

Output: lista plików **poza „Relevant files"**, które mogą wymagać dotknięcia → albo włączasz
do planu, albo jawnie wpisujesz do „Out of scope" z uzasadnieniem.

### 1.6 Tests as spec (~3 min)

```bash
rg -l "describe\\(.*shelter|test\\(.*shelter" --type ts
find . -type f \( -name '*.test.ts' -o -name '*.spec.ts' -o -name 'test_*.py' \) \
  -not -path '*/node_modules/*' | head -5 | xargs head -30
```

Wyciągnij: jakie fixtures, builder patterny, mocki, helper-y per domena.

### 1.7 Patterns catalog (output table)

| Wymiar | Konwencja w tym repo |
|--------|-----------------------|
| Naming | `camelCase` / `snake_case` / `kebab-case` files |
| Validation | `zod` / `yup` / `class-validator` / manual |
| Error handling | `throw` / `Result<T,E>` / try-catch na granicy |
| Response shape | `{ data, error }` / raw / RFC 7807 `{ type, title, detail }` |
| Auth check | middleware global / per-route / decorator / RBAC table |
| Logging | `console` / `pino` / `winston` / `structlog` |
| State (FE) | Zustand / Redux / Context / TanStack Query |
| DB access | raw SQL / Prisma / Drizzle / SQLAlchemy ORM |
| i18n | `next-intl` / `i18next` / brak |

### 1.8 Analysis Report (artefakt produkowany)

Na końcu Phase 1 wyprodukuj w chacie (i opcjonalnie zapisz do `docs/plany/_analysis/PLAN_NUM-analysis.md`):

```markdown
# Analysis Report — plan #PLAN_NUM

## Stack
[1-linia klasyfikacji]

## Architektura (zaobserwowane warstwy)
Entry: [file] → Routing: [file/dir] → Service: [file|brak] → Repo: [file|brak] → DB: [ORM]

## Analog featuru (PRIMARY TEMPLATE)
- Feature: [name]
- Pliki: [3–5 kluczowych ścieżek]
- Wzorzec CRUD: [skrót — np. "route → zod parse → service → prisma → response"]

## Data model — affected
- Tabele: [lista]
- Relacje: [N:M via X, FK na Y]
- Ostatnie migracje: [3 daty + co zmieniały]

## Dependency impact radius
Pliki poza planowanym scope które MOGĄ wymagać zmian:
- [path] — dlaczego
- [path] — dlaczego

## Patterns catalog
[tabelka z 1.7]

## Research used
[lista z Phase 1.0 — np. "context7: prisma@5 migrations", "Explore: app/(auth)/ patterns" — lub "none"]

## Open questions
- [pytanie do użytkownika]
```

**Jeśli są Open questions → STOP i zapytaj.** Nie lecisz w Phase 2 z domysłami.

---

## PHASE 2 — HIPOTEZY (≥ 3 required)

Use labels `[H1]`, `[H2]`, `[H3]` — NOT `[N]`.

```
### Hipoteza [H1]: [Nazwa]
**Opis:** ...
**Zalety:** ...
**Wady / Ryzyka:** ...
**Złożoność:** Niska / Średnia / Wysoka
**Czas realizacji:** ~X godzin
**Wpływ na istniejący kod:** Minimalny / Średni / Duży
**Referencja do Analysis Report:** [np. "Analog CRUD z 1.3", "nowy wzorzec poza patterns catalog"]
```

Always explore: **Minimalne** · **Idiomatyczne** · **Ambitne**.

Jeśli WSZYSTKIE hipotezy mają krytyczne wady → **[H4] hybrid best-of** z pełnym szablonem, STOP.

---

## PHASE 3 — REKOMENDACJA

```
## ✅ Rekomendacja: Hipoteza [Hx] — [Nazwa]
**Uzasadnienie:** [...]
**Kluczowe decyzje techniczne:**
- [Decision + reason]
```

---

## PHASE 4 — PLAN DOCUMENT

Zapisz verbatim do `docs/plany/PLAN_NUM-[kebab-name].md`.

```markdown
# PLAN_NUM - [Feature Name]

## Co & Dlaczego
[2–4 zdania: co, po co, kontekst systemowy]

## Szacowany nakład
~[X]h implementacja + ~[Y]h testy + ~[Z]h review

## Rozmiar featuru
**S** (1 plik, surgical) | **M** (typowy feature) | **L** (auth/DB/UI, krytyczny)
→ decyduje o zakresie testów (Phase 7) i głębokości review (Phase 8)

## Definition of Done
[Obserwowalne outcome'y — co tester klika/widzi]
- [outcome]

## Założenia
[Co zakładam — jeśli fałszywe, plan się wywala]
- [assumption]

## Out of scope
[Obowiązkowe. Każdy punkt + powód.]
- [item] — [powód]

## Plan awaryjny (rollback)
- Commity: `git revert <commit-range>`
- Migracje DB: `<komenda rollback>`
- Feature flag: `<nazwa> = false`

## Zadania
1. **[Task Name]** — [Detal + referencja do wzorca z Analysis Report] *(parallel-group: <nazwa>)*
2. **[Task Name]** — ... *(parallel-group: <nazwa>, depends-on: 1)*

> **Konwencja `parallel-group`:** mapuj po granicach plików (np. `backend`, `frontend`,
> `db-migrations`, `tests-scaffolding`). Dwa zadania w tej samej grupie nigdy nie dotykają
> tego samego pliku jednocześnie. Brak `parallel-group` = sekwencyjnie (np. migracje DB,
> które łamią schema). Hint zostanie wykorzystany w Phase 6 do auto-podziału między teammates.

## Relevant files
[Ścieżki do utworzenia/modyfikacji — jedna linia, bez opisu]
```

---

## PHASE 5 — SAVE PLAN & APPROVAL GATE

```bash
mkdir -p docs/plany
PLAN_FILE="docs/plany/${PLAN_NUM}-${SLUG}.md"
```

Zapisz plan (Write tool) verbatim z Phase 4.

**Sanity check:**
```bash
test -s "$PLAN_FILE" || { echo "ERROR: plan pusty"; exit 1; }
wc -l "$PLAN_FILE"
grep -c '^## ' "$PLAN_FILE"     # ≥ 8 sekcji
```

```
---
📋 Plan #PLAN_NUM gotowy i zapisany.
🔎 Code review backend: ${CR_BACKEND}

✅  Zaakceptować — zaczynam implementację
🔄  Modyfikacja — napisz co zmienić
❌  Inne podejście — podaj numer hipotezy (H1/H2/H3)
➕  Dodaj lub usuń zadania
🔧  Zmień CR backend — napisz: codex / superpowers / inline
---
```

**Zero kodu przed explicit approval.**

---

## PHASE 5.5 — WORKTREE DECISION (M+)

Po approval z Phase 5, **przed** Phase 6.−1 (pre-flight) i Phase 6.0 (routing). Decyduje
czy implementacja idzie w bieżącym katalogu, czy w izolowanym `git worktree`.

### 5.5.1 Decision matrix

| Rozmiar | Worktree | Reason |
|---------|----------|--------|
| **S** | ❌ skip (default) | Mała surgical zmiana — overhead worktree > benefit |
| **M** | 💬 propose (default no) | Średnia zmiana — worktree opcjonalnie pomocny |
| **L** | ✅ propose strongly (default yes) | Auth/DB/UI krytyczne — izolacja chroni `main` przed long-running zmianami |

**Override matrycy → propose worktree** (tylko **dla M+**, S zostaje S=skip nawet w tych
przypadkach) gdy:

- Plan dotyka **migracji DB schema** → DB w worktree można testcontainerem postawić niezależnie.
- Plan ma `parallel-group: db-migrations` + ≥ 1 inną grupę → 6-Teams łatwiej koordynować
  ze stabilnym worktree leada.
- Branch/main jest aktywnie deployowany (CI/CD na każdym pushu) → izolacja zmniejsza
  ryzyko przypadkowego deploy'u half-implemented featuru.

> **Reguła twarda:** S = skip jest niezależne od override'ów. Mała surgical zmiana
> (1 plik, < 50 linii) nie usprawiedliwia overhead worktree, nawet przy migracji indexu DB.
> Override'y eskalują **M → propose strongly** lub **L → must use**, nigdy **S → propose**.

### 5.5.2 Worktree naming

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
WORKTREE_PATH="${REPO_ROOT}/../${REPO_NAME}-plan-${PLAN_NUM}-${SLUG}"
WORKTREE_BRANCH="plan/${PLAN_NUM}-${SLUG}"
echo "Worktree path:   $WORKTREE_PATH"
echo "Worktree branch: $WORKTREE_BRANCH"
```

Konwencja:
- **Path:** sibling katalogu repo, sufiks `-plan-${PLAN_NUM}-${SLUG}` → łatwo znaleźć i posprzątać.
- **Branch:** `plan/${PLAN_NUM}-${SLUG}` (ten sam co w Phase 6.0 sequential checkout).
- **Slug:** kebab-case, krótki (≤ 30 znaków). Wyciągnięty z planu (Phase 4 nazwa featuru).

### 5.5.3 Propose to user

**Dla rozmiaru M:**

```
🌳 Worktree (opcjonalny, rozmiar M):
   Mogę wykonać implementację w izolowanym worktree:
     📁 path:   ../<repo-name>-plan-PLAN_NUM-<slug>/
     🌿 branch: plan/PLAN_NUM-<slug>
   Wtedy `main` zostaje czysty — dobry wybór gdy CI deployuje na każdym pushu
   lub gdy chcesz mieć paralelnie dostępną wersję pre-zmiana.

   ✅  Tak, zrób worktree
   ❌  Nie, zostań w bieżącym katalogu (default — szybciej, mniej kontekstu)
```

**Dla rozmiaru L:**

```
🌳 Worktree (REKOMENDOWANY, rozmiar L):
   Plan dotyka auth/DB/UI — silnie zalecam pracę w izolowanym worktree:
     📁 path:   ../<repo-name>-plan-PLAN_NUM-<slug>/
     🌿 branch: plan/PLAN_NUM-<slug>
   Korzyści:
     - main pozostaje stabilny i deployowalny przez całą implementację
     - możesz porównać side-by-side stan przed/po (preview obu URLi)
     - rollback to po prostu `git worktree remove` — bez `git reset`

   ✅  Tak, zrób worktree (default)
   ❌  Nie, zostań w bieżącym katalogu (świadomy wybór)
```

### 5.5.4 Create worktree

Jeśli accepted:

```bash
# Pre-flight: walidacja
git rev-parse --git-dir >/dev/null 2>&1 || { echo "ERROR: not a git repo"; exit 1; }
git fetch origin >/dev/null 2>&1 || true   # best-effort (offline OK)

# Branch nie może już istnieć (worktree -b tworzy nowy)
if git show-ref --verify --quiet "refs/heads/$WORKTREE_BRANCH"; then
  echo "ERROR: branch $WORKTREE_BRANCH already exists"; exit 1
fi

# Path nie może już istnieć
[ -e "$WORKTREE_PATH" ] && { echo "ERROR: path $WORKTREE_PATH exists"; exit 1; }

# Create
git worktree add "$WORKTREE_PATH" -b "$WORKTREE_BRANCH"

# Sanity
git worktree list

# OBOWIĄZKOWE: przełącz cwd do worktree. Bash tool w Claude Code persystuje cwd między
# wywołaniami, ale tylko jeśli explicit `cd` zostało wywołane. Bez tego Phase 6+ poleci
# w starym repo i `git checkout -b plan/...` faila z "branch already exists" (bo Phase 5.5
# już go utworzyła w worktree).
cd "$WORKTREE_PATH" || { echo "ERROR: nie mogę cd do $WORKTREE_PATH"; exit 1; }
pwd   # sanity — powinno wypisać $WORKTREE_PATH
echo "✅ Worktree created + cwd switched: $WORKTREE_PATH"
```

**Po utworzeniu — wszystkie Phase 6 / 7 / 8 / 9 commands wykonują się w `$WORKTREE_PATH`.**
Plan file (`docs/plany/PLAN_NUM-${SLUG}.md`) jest dziedziczony z commit'u, z którego worktree
powstał — wciąż go widzisz w worktree. ADR i CR artifacts zapiszesz w worktree, scommitujesz
na `$WORKTREE_BRANCH`, push'niesz osobno.

> **Reminder dla agenta:** na początku każdego bloku bash w Phase 6+, jeśli planujesz
> commands operujące na repo (git, npm, file edits), zacznij od `pwd` — jeśli to nie
> `$WORKTREE_PATH`, to znaczy że cwd zostało zresetowane (np. przez błąd shella) i
> musisz `cd "$WORKTREE_PATH"` ponownie przed dalszymi operacjami.

### 5.5.5 Skip path (no worktree)

Jeśli user wybrał "zostań w bieżącym katalogu":

```
📁 Pracuję w bieżącym katalogu. Phase 6 utworzy gałąź plan/PLAN_NUM-<slug>
   z `git checkout -b` (jak w 6.0 sequential).
```

Pomiń resztę Phase 5.5 — idź do Phase 6.−1.

### 5.5.6 Worktree cleanup (po Phase 9 / merge)

```bash
# Po mergu PR (lub gdy plan jest porzucony)
git worktree remove "$WORKTREE_PATH"
git branch -d "$WORKTREE_BRANCH"   # jeśli zmergowane (--delete safe)
```

**Nie usuwaj worktree przed mergem** — chyba że user explicit prosi (plan abandoned).
Worktree pozostaje dostępny dla post-merge fixes / hotpatchy.

---

## PHASE 5.7 — RALPH-LOOP DECISION (opt-in, po worktree)

Po Phase 5.5 (worktree), **przed** Phase 6.−1 (pre-flight) i Phase 6.0 (routing).
Decyduje czy Phase 6 idzie w trybie **autonomicznym** (6-Ralph: Stop-hook pętla
self-correcting) czy **interaktywnym** (6-Sequential / 6-Teams jak dotąd).

### 5.7.1 Skip rules (cisza, idziemy dalej)

Pomiń Phase 5.7 całkowicie (idź do Phase 6.−1) gdy:

- `RALPH_AVAILABLE=0` (Phase 0.5) — plugin niezainstalowany / wyłączony.
- Plan **rozmiar S** — pętla self-correct dla 1 surgical zmiany = overhead > zysk.
- Plan ma **`Open questions`** w Analysis Report (Phase 1.8) — autonomiczny loop nie
  potrafi pytać usera, zablokuje się.
- Plan dotyka **migracji DB schema** + **brak rollback skryptu** — autonomiczny commit
  złych migracji jest trudny do cofnięcia.

### 5.7.2 Decision matrix (gdy RALPH_AVAILABLE=1)

| Sygnał | Default | Powód |
|--------|---------|-------|
| **L-size + silny test gate** (≥ 5 zakresów testów wg matrycy 7) | 💬 propose (default no) | Loop self-correct na zielony test gate — TDD-friendly |
| **Backend-only L-size** (no UI, server logic) | 💬 propose (default no) | Bez UI = brak Phase 7.8 preview gate, łatwiej autonomicznie |
| **Greenfield feature** (zero analoga w 1.3, czysty zielony kod) | 💬 propose (default no) | Iteracja = paliwo, brak legacy do regresji |
| **M-size standard** | ⏭️ skip | Sequential / Teams szybsze niż loop |
| **L-size z UI + auth + DB** | ⏭️ skip (preferuj 6-Teams) | Cross-cutting = lead-driven decyzje, loop traci kontekst |
| **User explicit "ralph"/"loop" w request** | ✅ propose strongly (default yes) | User wie czego chce — respect |

### 5.7.3 Propose to user

**Dla scenariusza propose (default no):**

```
🔁 Ralph-loop (autonomiczny, opcjonalny):
   Plan #PLAN_NUM jest L-size z silnym test gate. Mogę uruchomić Phase 6 w trybie
   autonomicznym — pętla `implement → typecheck → lint → test → fix` aż do
   `<promise>FEATURE_DONE</promise>` lub --max-iterations.

   Korzyści:
     - self-correcting: gdy lint/test fail, agent sam wraca i poprawia
     - persistence: nie pyta o pozwolenie na każdy fix (bypass mode safe)
     - safety net: --max-iterations limit + całe state w git (rollback łatwy)
   Ryzyka:
     - autonomiczny = brak human-in-the-loop podczas loop (zatrzymasz przez /cancel-ralph)
     - może iterować długo (drogi compute, ale tani vs human time)
     - Phase 7.8 live preview wciąż wymaga interakcji — loop kończy się PRZED 7.8

   ✅  Tak, uruchom 6-Ralph (max-iterations: <auto-policzone>)
   ❌  Nie, idź klasycznie (default — 6-Sequential / 6-Teams wg routingu)
```

**Dla scenariusza propose strongly (user explicit):**

```
🔁 Ralph-loop (REKOMENDOWANY, user explicit):
   User explicit poprosił o ralph/loop. Uruchamiam Phase 6-Ralph z:
     - prompt:           wbudowany z plan + DoD + AC
     - completion-promise: "FEATURE_DONE"
     - max-iterations:    <auto-policzone wg rozmiaru>

   ✅  Tak, start (default)
   ❌  Nie, klasyczny routing
```

### 5.7.4 Auto-compute max-iterations

**Najpierw wyciągnij z planu zmienne** (używane w 5.7.4 + Phase 6R.2 prompt). Robisz to **raz**
po Phase 5 approval — wszystkie kolejne fazy je dziedziczą:

```bash
# PLAN_FILE — z Phase 5 (np. docs/plany/042-shelter-list.md)
PLAN_SIZE=$(awk '/^## Rozmiar featuru/{getline; print; exit}' "$PLAN_FILE" | grep -oE '\b[SML]\b' | head -1)
SLUG=$(basename "$PLAN_FILE" .md | sed -E 's/^[0-9]+-//')
FEATURE_NAME=$(head -1 "$PLAN_FILE" | sed -E 's/^# *[0-9]+ *- *//')
echo "PLAN_SIZE=$PLAN_SIZE  SLUG=$SLUG  FEATURE_NAME=$FEATURE_NAME"

# Sanity — wszystkie trzy zmienne MUSZĄ być ustawione
[ -z "$PLAN_SIZE" ] && { echo "⚠️  PLAN_SIZE niewykryty — uzupełnij w planie sekcję 'Rozmiar featuru'"; PLAN_SIZE="M"; }
[ -z "$SLUG" ]      && { echo "❌ SLUG pusty — niemożliwy do wyciągnięcia z $PLAN_FILE"; exit 1; }
[ -z "$FEATURE_NAME" ] && FEATURE_NAME="(unnamed)"

# Heurystyka: liczba zadań × 2 (każde może wymagać fix loop) + buffer per zakres testu.
# `awk` z exclusive boundaries (p flag) — drukuje TYLKO linie *między* "## Zadania" a kolejnym
# "## ", bez nagłówków. Bez tego inclusive range łapał header'y i zawyżał TASK_COUNT.
TASK_COUNT=$(awk '/^## Zadania/{p=1; next} /^## /{p=0} p' "$PLAN_FILE" | grep -cE '^[0-9]+\.')
TEST_SCOPES=$(case "$PLAN_SIZE" in S) echo 4;; M) echo 5;; L) echo 7;; *) echo 5;; esac)
RALPH_MAX_ITER=$(( TASK_COUNT * 2 + TEST_SCOPES * 3 ))
# Twardy clamp [10, 60] — < 10 nie złapie iteracji, > 60 to pewnie zły plan
[ "$RALPH_MAX_ITER" -lt 10 ] && RALPH_MAX_ITER=10
[ "$RALPH_MAX_ITER" -gt 60 ] && RALPH_MAX_ITER=60
echo "RALPH_MAX_ITER=$RALPH_MAX_ITER (tasks=$TASK_COUNT, scopes=$TEST_SCOPES)"
```

Pokaż użytkownikowi w propose (5.7.3) jako konkretną liczbę. User może override
naturalnym językiem („zmień na 30").

### 5.7.5 Set state for Phase 6 routing

**Najpierw zmapuj odpowiedź użytkownika z 5.7.3** na zmienną `RALPH_DECISION`:

```bash
# Mapowanie odpowiedzi z propose (5.7.3) — agent musi to ustawić explicit:
#   user kliknął "✅ Tak" / "Tak" / "yes" / "ok" / akceptacja            → RALPH_DECISION="yes"
#   user kliknął "❌ Nie" / "Nie" / "no" / brak odpowiedzi w 60s         → RALPH_DECISION="no"
# Bez explicit przypisania ten blok cicho ustawi RALPH_MODE=0 (default no).
RALPH_DECISION="${RALPH_DECISION:-no}"   # safe default jeśli zmienna pusta
echo "RALPH_DECISION=$RALPH_DECISION"

if [ "$RALPH_DECISION" = "yes" ]; then
  RALPH_MODE=1
  echo "✅ 6-Ralph mode aktywne — Phase 6.0 routing pominie 6-Sequential / 6-Teams"
else
  RALPH_MODE=0
  echo "📁 6-Ralph mode wyłączone — klasyczny routing 6-Sequential / 6-Teams"
fi
```

> **Reguła twarda:** RALPH_MODE=1 nadpisuje TEAMS_ENABLED. Nie ma sensu spawn'ować
> teammates w autonomicznym loopie — to lead-driven coordination, ralph-loop = solo agent
> z self-feedback. Jeśli user chce paralelizmu, niech wybierze 6-Teams (sequential decision —
> ralph LUB teams, nigdy oba).

---

## PHASE 6 — IMPLEMENTATION (routing)

### 6.−1 Pre-flight: context7 docs probe (OBLIGATORYJNE)

**Przed routingiem (sequential ↔ teams), zanim napiszesz JAKIKOLWIEK kod:**

Z planu (sekcje *Relevant files* + *Zadania*) wyciągnij listę zewnętrznych bibliotek,
których będziesz używać. Dla **każdej** biblioteki wywołaj **context7**:

```
context7 / resolve-library-id  → ID biblioteki
context7 / query-docs           → docs dla konkretnego API/wzorca z zadania
```

**Przykład (plan dotyka Prisma + Next.js app router + Tailwind v4):**
```
context7: prisma@5 — relations + transaction API (zadanie 3, 5)
context7: next@14 — server actions + revalidatePath (zadanie 2)
context7: tailwindcss@4 — @theme directive (zadanie 4)
```

**Output do chatu** (przed routingiem):
```
📚 Pre-flight context7 — biblioteki w planie #PLAN_NUM:
  ✓ prisma@5 — relations API
  ✓ next@14 — server actions
  ✓ tailwindcss@4 — @theme

→ Implementacja na świeżych docach, nie na pamięci.
```

**Kiedy SKIP:**
- Wszystkie zadania używają **wyłącznie** stdlib języka (bez npm/pip imports).
- Wszystkie biblioteki były już probowane w Phase 1.0 i wynik jest świeży (< 24h).
- Plan to czysty refaktor wewnętrzny (rename, extract function — zero zmian API biblioteki).

**NIGDY nie skip:**
- Gdy plan dotyka biblioteki, której wersja w `package.json` / `pyproject.toml` jest > 6 miesięcy nowsza od training data.
- Gdy zadanie używa API, którego nie widziałeś w analogu (Phase 1.3).
- Gdy biblioteka znana jest z breaking changes między wersjami (React, Next, Prisma, Drizzle, Tailwind).

**Reguła decyzyjna:**

> Jeśli pomyślisz „przecież wiem jak to działa" — to znak, że MUSISZ uruchomić context7.
> Pamięć modelu nie zna API zaktualizowanych po cutoff'cie. Nie zgaduj.

### 6.0 Routing decision

**Decyzja na wejściu (z Phase 0.4 + Phase 4 + Phase 5.7):**

```bash
# Hard assert — zmienne MUSZĄ być ustawione przed routingiem (defaulty defensywne).
RALPH_MODE="${RALPH_MODE:-0}"
TEAMS_ENABLED="${TEAMS_ENABLED:-0}"

# Mutual exclusion — RALPH_MODE wygrywa z TEAMS_ENABLED (5.7.5 reguła twarda).
# Jeśli oba ustawione na 1 (np. agent zapomniał wyzerować TEAMS po Phase 5.7), to bug
# w workflow — wymuś ralph i zaloguj ostrzeżenie.
if [ "$RALPH_MODE" = "1" ] && [ "$TEAMS_ENABLED" = "1" ]; then
  echo "⚠️  RALPH_MODE=1 AND TEAMS_ENABLED=1 — egzekwuję mutual exclusion (ralph wygrywa)"
  TEAMS_ENABLED=0
fi

# Sprawdź czy plan ma ≥ 2 parallel-groups (warunek Teams)
PARALLEL_GROUPS_COUNT=$(awk '/^## Zadania/{p=1; next} /^## /{p=0} p' "$PLAN_FILE" \
  | grep -oE 'parallel-group: [a-z-]+' | sort -u | wc -l)

if [ "$RALPH_MODE" = "1" ]; then
  ROUTE="6-Ralph"
elif [ "$TEAMS_ENABLED" = "1" ] && [ "$PARALLEL_GROUPS_COUNT" -ge 2 ]; then
  ROUTE="6-Teams"
else
  ROUTE="6-Sequential"
fi
echo "🛣️  Routing decision: $ROUTE  (RALPH_MODE=$RALPH_MODE, TEAMS_ENABLED=$TEAMS_ENABLED, parallel_groups=$PARALLEL_GROUPS_COUNT)"
```

Trzy ścieżki, w kolejności priorytetu:

1. `RALPH_MODE=1` (Phase 5.7 user accepted) → **PHASE 6-Ralph** (autonomous loop)
2. `TEAMS_ENABLED=1` AND plan ma ≥ 2 zadania w ≥ 2 różnych `parallel-group` → **PHASE 6-Teams**
3. W każdym innym przypadku → **PHASE 6-Sequential**

> **Mutual exclusion:** 6-Ralph wyklucza 6-Teams (Phase 5.7.5 reguła twarda). User wybiera
> jedno z dwóch dla L-size: paralelizm leadem (Teams) **lub** autonomiczny loop (Ralph).
> Hard assert powyżej egzekwuje to nawet gdy obie zmienne wpadną w stan `=1`.

Wypisz do użytkownika która ścieżka:

```
🛣️  Implementacja: <"6-Ralph (autonomous loop, max N iter)" | "6-Teams (równolegle, N teammates)" | "6-Sequential">
```

- **6-Ralph** → przejdź do sekcji `## PHASE 6-Ralph` (po 6-Sequential i 6-Teams).
- **6-Teams** → przejdź do sekcji `## PHASE 6-Teams`.
- **6-Sequential** → kontynuuj poniżej (6.0 git env → 6.1 task registration → 6.2 per-task loop).

---

## PHASE 6-Sequential — IMPLEMENTATION (jednowątkowo)

### 6.0 Git environment & branch strategy

```bash
git rev-parse --git-dir >/dev/null 2>&1 || { echo "ERROR: Not a git repo"; exit 1; }
git config user.email >/dev/null 2>&1 || { echo "ERROR: user.email not set"; exit 1; }
if git status --porcelain | grep -vq '^??'; then
  echo "ERROR: Uncommitted tracked changes"; exit 1;
fi

CURRENT_BRANCH=$(git branch --show-current)
EXPECTED_BRANCH="plan/${PLAN_NUM}-${SLUG}"

# Phase 5.5 mogła już utworzyć worktree na expected branch.
# Trzy stany: (a) jesteśmy w worktree na expected, (b) jesteśmy na main, (c) coś innego.
if [ "$CURRENT_BRANCH" = "$EXPECTED_BRANCH" ]; then
  echo "✅ Już na $EXPECTED_BRANCH (prawdopodobnie z worktree Phase 5.5)"
else
  case "$CURRENT_BRANCH" in
    main|master|develop)
      git checkout -b "$EXPECTED_BRANCH" ;;
    *)
      echo "⚠️  Aktualna gałąź: $CURRENT_BRANCH (nie main/expected) — kontynuuję na niej, ale potwierdź"
      ;;
  esac
fi
```

### 6.1 Task registration & Progress Board

**① Zarejestruj zadania w harness task system** — przed pierwszą implementacją wywołaj
**TodoWrite** **raz** z całą listą zadań planu (numeracja jak w Phase 4 „Zadania"):

```
TodoWrite({
  todos: [
    { content: "[1] <Task Name>", activeForm: "Wykonuję [1] <Task Name>", status: "pending" },
    { content: "[2] <Task Name>", activeForm: "Wykonuję [2] <Task Name>", status: "pending" },
    ...
  ]
})
```

> **Architektura tooli:** harness Claude Code ma **jeden** tool — `TodoWrite` — który
> nadpisuje całą listę todo. Nie ma `TaskCreate` per zadanie ani `TaskUpdate(taskId, ...)`.
> Każda zmiana statusu = **kolejne wywołanie TodoWrite z całą listą**, w której zmieniony
> jest status pojedynczego zadania. Trzymaj cache listy w pamięci między wywołaniami.

To daje harness'owi widoczność progresu (UI checklisty + protection przed compaction
długiej sesji). Inline chat-checkbox to **uzupełnienie**, nie zamiennik.

**② Pokaż Progress Board w chacie:**

```
## 🚀 Implementacja — Plan #PLAN_NUM: [Feature Name]
Gałąź: `plan/PLAN_NUM-[slug]`  |  CR backend: `${CR_BACKEND}`

- [ ] 1. [Task Name]
- [ ] 2. [Task Name]
```

### 6.2 Per-Task Loop

**① Header + TodoWrite(task n → in_progress)** — `### ⏳ [n/total] [Task Name]` + wywołanie
`TodoWrite` z całą listą gdzie task `n` ma `status: "in_progress"`, reszta zachowuje swój
poprzedni status (`pending` lub `completed`).

**② Implement** — tylko pliki z „Relevant files". Mirror wzorców z Analysis Report. Zero TODO/stubów/debug logów.

> **Library API check:** jeśli to zadanie używa external library, której **nie probowałeś** w Phase 6.−1
> (lub wynik > 24h temu), wywołaj **context7** **TERAZ** — przed napisaniem pierwszej linii kodu.
> „Wydaje mi się że wiem" = czerwona flaga.

**③ Migracje DB (detekcja ORM):**
```bash
if [ -f drizzle.config.ts ] || [ -f drizzle.config.js ] || [ -f drizzle.config.mjs ]; then
  npx drizzle-kit generate
elif [ -f prisma/schema.prisma ]; then
  npx prisma migrate dev --name "plan-${PLAN_NUM}-${SLUG}"
elif [ -f alembic.ini ]; then
  alembic revision --autogenerate -m "plan-${PLAN_NUM}-${SLUG}"
else
  echo "INFO: brak ORM"
fi
```

**④ Validate:**
```bash
if npm run --silent typecheck >/dev/null 2>&1; then
  npm run typecheck && npm run lint
else
  npx tsc --noEmit && npm run lint
fi
# Python: ruff check . && mypy .
```

**⑤ Commit (NIGDY `git add -A`):**
```bash
git add $RELEVANT_FILES migrations/ prisma/migrations/ alembic/versions/ 2>/dev/null
git status --short
git diff --cached --stat
git commit -m "[type](plan-PLAN_NUM): [imperative description]"
```

Typy: `feat` (+ migracje) · `fix` · `refactor` · `build` · `chore` (tylko nieprodukcyjne).

**⑥ Report + TodoWrite(task n → completed) + checklist update** — wywołaj `TodoWrite`
z całą listą gdzie task `n` ma `status: "completed"` (po zielonym validate i commicie).
Bez completed-update zadanie wisi `in_progress` w harness UI.

### 6.3 Blocker Protocol

```
## 🛑 Bloker — Zadanie [N]
**Problem:** [...]
**Opcje:** 1. [A]  2. [B]
Jak chcesz postąpić?
```

Modyfikacja pliku spoza „Relevant files" = bloker.

---

## PHASE 6-Teams — PARALLEL IMPLEMENTATION (auto)

### 6T.0 Git environment check

Wykonaj **identyczne kontrole co Phase 6.0** (sequential), z tą samą logiką detekcji
worktree:

```bash
git rev-parse --git-dir >/dev/null 2>&1 || { echo "ERROR: Not a git repo"; exit 1; }
git config user.email >/dev/null 2>&1 || { echo "ERROR: user.email not set"; exit 1; }
if git status --porcelain | grep -vq '^??'; then
  echo "ERROR: Uncommitted tracked changes"; exit 1;
fi

CURRENT_BRANCH=$(git branch --show-current)
EXPECTED_BRANCH="plan/${PLAN_NUM}-${SLUG}"

# Trzy stany (jak w 6.0): worktree z Phase 5.5 / fresh main / inny.
if [ "$CURRENT_BRANCH" = "$EXPECTED_BRANCH" ]; then
  echo "✅ Już na $EXPECTED_BRANCH — kontynuuję (Teams w worktree z Phase 5.5 jest OK)"
else
  case "$CURRENT_BRANCH" in
    main|master|develop) git checkout -b "$EXPECTED_BRANCH" ;;
    *)
      echo "⚠️  Aktualna gałąź: $CURRENT_BRANCH (nie main/expected) — kontynuuję, ale potwierdź"
      ;;
  esac
fi

# Reminder: jeśli Phase 5.5 utworzyła worktree, lead operuje w $WORKTREE_PATH.
# Teammates spawnowani z lead session dziedziczą cwd lead'a, więc też pracują w worktree.
pwd
```

### 6T.1 Auto-sizing teamu

**Agent dobiera liczbę teammates sam — nie pyta użytkownika.** Heurystyka:

| Sygnał | Liczba teammates |
|--------|------------------|
| 2 parallel-groups, ≤ 3 zadania | **2** (lead-worker + 1) |
| 3 parallel-groups, 4–6 zadań | **3** |
| 4 parallel-groups, 7–10 zadań | **4** |
| ≥ 5 parallel-groups lub > 10 zadań | **5** (twardy max) |

**Reguły twarde:**

- Nigdy więcej niż **5 teammates** (powyżej koordynacja > zysk).
- Każdy teammate musi mieć **≥ 1 wyłączny katalog/glob plików** — zero overlapów.
- **Migracje DB / schema → zawsze 1 dedykowany teammate** (nie równolegle z innymi piszącymi do DB).
- Zadania z `depends-on: X` muszą być w tym samym teammate **lub** realizowane sekwencyjnie z barierą.

**Wypisz do użytkownika tabelę przed spawnowaniem (przykład):**

```
👥 Team #PLAN_NUM — auto-sizing: 3 teammates

| Teammate       | Parallel-groups        | Owned files              | Tasks    |
|----------------|------------------------|--------------------------|----------|
| backend-dev    | backend, db-migrations | server/**, prisma/**     | 1, 3, 5  |
| frontend-dev   | frontend, ui           | app/**, components/**    | 2, 4     |
| tester-prep    | tests-scaffolding      | tests/**                 | 6        |
```

### 6T.2 Spawn the team

**Najpierw — TodoWrite z całą listą zadań planu** (lead rejestruje wszystkie raz; teammate
jest opisany w `content` jako tag `(assignee: <name>)`, bo TodoWrite nie ma pola assignee):

```
TodoWrite({
  todos: [
    { content: "[1] <Task Name> (assignee: backend-dev)",  activeForm: "...", status: "pending" },
    { content: "[2] <Task Name> (assignee: frontend-dev)", activeForm: "...", status: "pending" },
    ...
  ]
})
```

> **Uwaga lead:** TodoWrite jest globalny dla sesji lead'a. Teammates nie mają dostępu do
> tej listy (są w osobnych kontekstach). Lead aktualizuje listę gdy teammate raportuje
> commit — i robi to przez **kolejny TodoWrite z całą listą**, w której task `n` zmienia
> status na `completed`.

Następnie wywołaj **jedną wiadomością** spawn-prompt (lead = bieżąca sesja):

```
Create an agent team for Plan #PLAN_NUM.

Shared context every teammate must read first:
  • docs/plany/PLAN_NUM-<slug>.md          (the plan)
  • docs/plany/_analysis/PLAN_NUM-...md    (Analysis Report, if exists)

Common rules for every teammate:
  • Touch ONLY files in your owned-files list. Anything outside = blocker → message lead.
  • Mirror existing patterns from Analysis Report (Patterns catalog 1.7).
  • Validate (typecheck + lint) before EACH commit.
  • One commit per task: `[type](plan-PLAN_NUM): <imperative>`.
  • NIGDY `git add -A` — tylko własne pliki + migracje (jeśli właściciel migracji).
  • Report each task completion to lead in chat.

Teammate 1: <name>
  Owned files: <globs>
  Tasks (numbers from plan): <list>
  Spawn prompt: "<task-specific spawn prompt>"

Teammate 2: <name>
  ...

Coordination:
  • If you need data from another teammate's output → message them directly first;
    escalate to lead only if blocked > 1 round-trip.
  • Cross-cutting decisions (API shape, DTO names) → lead decides, broadcasts.
```

### 6T.3 Lead's role during parallel work

W trakcie pracy teammates lead (Ty) **MUSI**:

1. **Stay available — NIE implementuj.** Jeśli złapiesz się na kodowaniu, zatrzymaj
   i re-deleguj. Lead-job: synthesize, decide, broadcast.
2. **Cross-team decisions** — gdy teammate A pyta „jaki ma być response shape", a B będzie
   to konsumował, lead decyduje i mówi obu.
3. **Approve plan-mode entries** — jeśli teammate wchodzi w plan-mode (np. nietrywialna
   migracja), zrewiduj względem feature-planu, approve/reject explicitly.
4. **Update progress board + TodoWrite** w user-facing chat po każdym ukończonym tasku.
   Lead wywołuje `TodoWrite` z całą listą (gdzie task `n` zmienia status na `completed`)
   gdy teammate zaraportuje commit (teammate nie ma access do TodoWrite leada — to zadanie leada):

   ```
   ## 🚀 Implementacja — Plan #PLAN_NUM (Teams)
   ✅ backend-dev: zadanie 1 ukończone (commit abc123)
   ⏳ frontend-dev: zadanie 2 w toku
   ⏸  tester-prep: czeka na zadanie 1 (depends-on)
   ```

### 6T.4 Blocker / file-conflict protocol

Gdy dwóch teammates potrzebuje tego samego pliku (przeoczenie w 6T.1):

```
## 🛑 Konflikt plików — Plan #PLAN_NUM
Plik: <path>
Teammates: <a>, <b>
Opcje:
  1. Sekwencyjnie: <a> kończy → <b> startuje (bezpieczne)
  2. Refactor: rozdziel plik na dwa moduły, każdy do innego teammate
  3. Re-assign: przenieś jedno zadanie do drugiego teammate
Jak postąpić?
```

Hard stop — pytaj użytkownika.

### 6T.5 Team cleanup

Po `Wait for all teammates to confirm completion.` → **lead (i tylko lead)** uruchamia:

```
Clean up the team.
```

Dalej → Phase 7 (testing). Testy lecą w sesji lead, nie w teammates — łatwiej skoordynować
7 zakresów i test-gate.

---

## PHASE 6-Ralph — AUTONOMOUS SELF-CORRECTING LOOP

Aktywne **tylko gdy `RALPH_MODE=1`** (decyzja z Phase 5.7). Wykonuje implementację planu
w pętli `implement → typecheck → lint → test → fix` aż do `<promise>FEATURE_DONE</promise>`
lub osiągnięcia `--max-iterations`.

> **Why ralph-loop tutaj:** plugin `ralph-loop@claude-plugins-official` używa Stop-hooka,
> który blokuje exit z sesji i podaje sobie ten sam prompt ponownie. To daje **persistent
> iteration** bez zewnętrznego `while true` w bashu — Claude Code sam siebie loop'uje.
> Zachowuje plan w plikach + git history → każda iteracja widzi co już zrobione i co jeszcze
> wymaga fix.

### 6R.0 Git environment check (identyczne z 6.0)

```bash
git rev-parse --git-dir >/dev/null 2>&1 || { echo "ERROR: Not a git repo"; exit 1; }
git config user.email >/dev/null 2>&1 || { echo "ERROR: user.email not set"; exit 1; }
if git status --porcelain | grep -vq '^??'; then
  echo "ERROR: Uncommitted tracked changes"; exit 1;
fi

CURRENT_BRANCH=$(git branch --show-current)
EXPECTED_BRANCH="plan/${PLAN_NUM}-${SLUG}"

if [ "$CURRENT_BRANCH" = "$EXPECTED_BRANCH" ]; then
  echo "✅ Już na $EXPECTED_BRANCH (worktree z Phase 5.5 lub poprzedni branch)"
else
  case "$CURRENT_BRANCH" in
    main|master|develop) git checkout -b "$EXPECTED_BRANCH" ;;
    *)
      echo "⚠️  Aktualna gałąź: $CURRENT_BRANCH — kontynuuję, potwierdź czy OK"
      ;;
  esac
fi
pwd  # sanity (worktree-aware)
```

### 6R.1 Pre-flight invariants (TWARDE — bez tego loop kończy się źle)

**Wszystkie poniższe MUSZĄ być spełnione przed `/ralph-loop`. Jeśli któryś fail → STOP
i powiedz userowi co naprawić.**

```bash
# (1) Bypass mode aktywny (settings.json defaultMode lub --dangerously-skip-permissions)
# Guard: gdy ~/.claude/settings.json nie istnieje, jq zwróci "" zamiast "default" (// działa
# tylko na null, nie na brak inputu). Domyślny tryb potraktuj jak "default" (= NIE bypass).
DEFAULT_MODE="default"
if [ -f ~/.claude/settings.json ]; then
  DEFAULT_MODE=$(jq -r '.permissions.defaultMode // "default"' ~/.claude/settings.json 2>/dev/null || echo "default")
  [ -z "$DEFAULT_MODE" ] && DEFAULT_MODE="default"
fi
if [ "$DEFAULT_MODE" != "bypassPermissions" ] && [ -z "${CLAUDE_DANGEROUSLY_SKIP_PERMISSIONS:-}" ]; then
  echo "❌ Ralph-loop wymaga bypass mode. Ustaw:"
  echo '   ~/.claude/settings.json: {"permissions": {"defaultMode": "bypassPermissions"}}'
  echo "   lub uruchom Claude Code z --dangerously-skip-permissions"
  exit 1
fi

# (2) Plan + AC dostępne (loop bez specyfikacji = chaos)
[ -s "docs/plany/${PLAN_NUM}-${SLUG}.md" ] || { echo "❌ Brak planu"; exit 1; }

# (3) Git clean (ralph commits w pętli — dirty state psuje attribution)
git status --porcelain | grep -vq '^??' && { echo "❌ Uncommitted changes"; exit 1; }

# (4) Test runner istnieje (loop NEEDS automated verification)
HAS_TESTS=0
[ -f package.json ] && jq -e '.scripts.test' package.json >/dev/null 2>&1 && HAS_TESTS=1
[ -f pyproject.toml ] && grep -qE 'pytest|nose2|unittest' pyproject.toml && HAS_TESTS=1
if [ "$HAS_TESTS" = "0" ]; then
  echo "❌ Brak `npm test` / `pytest` — ralph-loop bez testów = nie wie kiedy stop"
  echo "   Dodaj test runner do planu lub przełącz na 6-Sequential"
  exit 1
fi

# (5) TodoWrite registry (jak w 6.1) — przed launch'em loop'a wywołaj TodoWrite raz
#     z całą listą zadań planu. Loop nie potrafi tego zrobić sam (brak chat memory między
#     iteracjami) — lead operator musi to zrobić TUTAJ, przed `/ralph-loop`.
echo "✅ Pre-flight invariants OK — ready dla /ralph-loop"
echo "   → wywołaj teraz TodoWrite z listą zadań planu (jak w Phase 6.1 ①)"
```

### 6R.2 Build the ralph prompt

Prompt jest **single-shot** — zostanie podany ponownie w każdej iteracji. MUSI zawierać
wszystko, co Claude potrzebuje, by kontynuować od stanu git/plików (bez chat memory).

```bash
RALPH_PROMPT_FILE="/tmp/ralph-prompt-${PLAN_NUM}.txt"
# Ścieżki absolutne — loop wywoływany z różnych cwd (worktree, /tmp). Bez absolute path
# `references/testing-protocol.md` szukany byłby względem cwd loop'a, nie repo.
REPO_ROOT=$(git rev-parse --show-toplevel)
TESTING_PROTOCOL="${REPO_ROOT}/references/testing-protocol.md"
# Fallback: skill może być w innym repo niż feature; szukamy testing-protocol.md w cache:
[ -f "$TESTING_PROTOCOL" ] || TESTING_PROTOCOL=$(find ~/.claude/plugins -name testing-protocol.md -path "*feature-planner*" 2>/dev/null | head -1)
[ -f "$TESTING_PROTOCOL" ] || TESTING_PROTOCOL="<podaj absolutną ścieżkę do testing-protocol.md>"

cat > "$RALPH_PROMPT_FILE" <<EOF
# Ralph-loop iteration — Plan #${PLAN_NUM}: ${FEATURE_NAME}

## State recovery (read FIRST every iteration)
1. Read \`${REPO_ROOT}/docs/plany/${PLAN_NUM}-${SLUG}.md\` — plan + DoD + Założenia + OOS + Tasks
2. Read \`${REPO_ROOT}/docs/code-reviews/AC-${PLAN_NUM}-${SLUG}.md\` **if exists** — AC priorytety (powstaje w Phase 8.1, w Phase 6 zwykle brak — wtedy pomiń)
3. Run \`git log --grep="plan-${PLAN_NUM}" --oneline\` — co już zaimplementowane
4. Wywołaj \`TodoWrite\` ze stanem listy z poprzedniej iteracji **tylko jeśli musisz coś zmienić**
   (lista jest persystentna w harness UI między iteracjami; możesz ją zobaczyć w UI)
5. Run \`git status\` + \`git diff\` — co w toku, co dirty

## Loop body (per iteration)

### Step 1 — Pick next task
Z planu sekcja "Zadania" + git history wyciągnij **pierwszy** task ze statusem != completed.
Jeśli wszystkie completed → przejdź do Step 4 (test gate).

### Step 2 — Implement
- Tylko pliki z "Relevant files" planu
- Mirror wzorców z Analysis Report (Patterns catalog 1.7)
- Zero TODO/stubów/debug logów
- Library API check: jeśli używasz external lib której nie ma w git history tej sesji →
  wywołaj \`context7\` przed kodowaniem

### Step 3 — Validate + commit
\`\`\`bash
# Validate
npm run typecheck && npm run lint   # albo: npx tsc --noEmit && npm run lint
# Python: ruff check . && mypy .

# Commit (NIGDY git add -A)
git add <relevant-files-only>
git commit -m "[type](plan-${PLAN_NUM}): <imperative description>"
\`\`\`

Po commicie wywołaj **TodoWrite** z całą listą zadań — task aktualny zmień na
\`status: "completed"\`, reszta zachowuje swój status. (Listę widziałeś w state recovery 4
albo w pierwszej iteracji w Phase 6R.1 ⑤ pre-flight registry.)

Jeśli typecheck/lint fail → **NIE commituj** i **NIE zmieniaj TodoWrite** (task zostaje
\`in_progress\`), fix w next iteration.

### Step 4 — Test gate (gdy wszystkie zadania committed)
Uruchom 7 zakresów wg matrycy S/M/L (zob. \`${TESTING_PROTOCOL}\`):
- unit + integration + acceptance + regression (zawsze)
- system + E2E (M+) — E2E hierarchia Tier 1-4 (Playwright Chromium → install → chrome-devtools-mcp → CLI fallback)
- perf + security (L zawsze, M jeśli AC-N)

Jeśli któryś zakres czerwony → **NIE wystawiaj promise**, fix w next iteration.

### Step 5 — Promise
Tylko gdy:
✅ Wszystkie taski z planu completed (git log + TodoWrite list status)
✅ typecheck + lint zielone
✅ Wszystkie wymagane zakresy testów zielone
✅ Każdy DoD bullet z \`docs/plany/${PLAN_NUM}-${SLUG}.md\` (sekcja "Definition of Done") ma test/dowód
   pokrywający go w git history (test::name w komicie testowym)

> **Uwaga o AC:** plik \`docs/code-reviews/AC-${PLAN_NUM}-${SLUG}.md\` powstaje **w Phase 8.1**,
> nie w Phase 6. W Phase 6-Ralph zwykle go nie ma — **pomijamy jego sprawdzenie** w Step 5
> (zamiast tego polegamy na DoD z planu, który istnieje od Phase 4). Sprawdzaj AC tylko
> jeśli plik faktycznie istnieje (rerun Phase 6 po Phase 8 fix loop).

Wtedy wystaw EXACTLY:
<promise>FEATURE_DONE</promise>

## Anti-patterns (loop-specific — DO NOT)

- ❌ Wystaw promise wcześniej "bo i tak działa" — promise kłamie = sabotaż loop
- ❌ Skip test bo "trywialnie wiadomo że pass" — loop ufa testom, nie tobie
- ❌ \`git add -A\` — może wciągnąć /tmp artifacts ralph-loop'a
- ❌ Modify pliki spoza "Relevant files" — to bloker, output bloker message i wystaw <promise>BLOCKED</promise> (ale wtedy nie zadziała completion-promise = loop poleci dalej; lepiej: zatrzymaj kodowanie, output blocker w chacie, czekaj na user via /cancel-ralph)
- ❌ Phase 7.8 live preview — Phase 6-Ralph kończy się PRZED 7.8. Live preview = lead-driven, post-loop.

## Plan reference (verbatim Co & Dlaczego)
$(awk '/^## Co & Dlaczego/,/^## /' "docs/plany/${PLAN_NUM}-${SLUG}.md" | head -20)

## Definition of Done (verbatim)
$(awk '/^## Definition of Done/,/^## /' "docs/plany/${PLAN_NUM}-${SLUG}.md" | head -30)
EOF

wc -l "$RALPH_PROMPT_FILE"
echo "Prompt: $RALPH_PROMPT_FILE"
```

### 6R.3 Launch /ralph-loop

```bash
# RALPH_MAX_ITER ustawione w Phase 5.7.4
echo "🔁 Uruchamiam /ralph-loop dla Plan #${PLAN_NUM}"
echo "   max-iterations:    $RALPH_MAX_ITER"
echo "   completion-promise: FEATURE_DONE"
echo "   prompt-file:       $RALPH_PROMPT_FILE"
echo ""
echo "   /cancel-ralph  → manualny stop (przerwie loop, ale nie cofnie commitów)"
echo "   monitor:       head -10 .claude/ralph-loop.local.md"
```

Następnie **wywołaj slash command** `/ralph-loop` z prompt'em z pliku + flagami:

```
/ralph-loop "$(cat /tmp/ralph-prompt-PLAN_NUM.txt)" --max-iterations $RALPH_MAX_ITER --completion-promise "FEATURE_DONE"
```

> **Praktyka:** prompt jest długi (zwykle 100–200 linii) — Claude Code akceptuje to, ale
> w UI widać tylko header. To OK — pełna treść jest w `.claude/ralph-loop.local.md`
> (state file pluginu).

### 6R.4 Lead's role during loop

W Phase 6-Ralph **NIE MA** osobnego leada — Claude Code sam jest agentem loop'a. Twoje
zadania jako "operator" loop'a to:

1. **Monitor postępu** — co kilka iteracji `head -20 .claude/ralph-loop.local.md`,
   aby widzieć current iteration i czy zbliża się do completion-promise.
2. **Reagowanie na blockers** — jeśli loop iteruje > 5x na tym samym tasku bez progresu
   (sprawdź `git log --grep "plan-PLAN_NUM" | wc -l`), to znak że loop się zaplótł.
   Wykonaj `/cancel-ralph` i przejdź na 6-Sequential ręcznie.
3. **Zero implementacji w trakcie** — nie modifikuj plików gdy loop pracuje, dirty state
   wybije agentowi state recovery (Step 1 prompt).

### 6R.5 Completion / cancellation

**Completion (loop wystawił FEATURE_DONE):**

```bash
# State file pluginu zawiera "completed_at" i finalną iterację
grep -E '^iteration:|^completed_at:' .claude/ralph-loop.local.md

# Verify ostatni commit
git log --oneline -5

# Sprawdź TodoWrite list w harness UI — wszystkie zadania powinny być completed.
# (Lista jest persystentna w sesji; sprawdź wizualnie w checklist UI lub wywołaj
#  TodoWrite z bieżącym stanem żeby zobaczyć jak wygląda zarejestrowana lista.)

# State persistence — zapisz że Phase 6 było 6-Ralph (czytane przez Phase 7.6 skip rule)
mkdir -p .claude
RALPH_STATE_FILE=".claude/plan-${PLAN_NUM}.state"
echo "RALPH_USED=1" > "$RALPH_STATE_FILE"
echo "RALPH_COMPLETED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$RALPH_STATE_FILE"
echo "✅ Zapisano $RALPH_STATE_FILE — Phase 7.6 skip rule będzie aktywna"
```

Po completion idź do **Phase 7.8** (live preview, jeśli plan ma UI) → **Phase 8** (code review).
Phase 7 (testy) Ralph już przebiegł w Step 4 — ale **lead re-runuje test gate** w Phase 7
żeby potwierdzić determinizm (czy testy są zielone w czystej sesji bez self-feedback).

**Cancellation (user `/cancel-ralph` lub max-iterations hit):**

```bash
# /cancel-ralph już zadziałał (usunął state file) lub max iterations exhausted

# Sprawdź ostatnią iteracji i co zostało zrobione
git log --grep="plan-${PLAN_NUM}" --oneline | head

# Decyzja:
# (a) Loop dotarł blisko końca (> 80% tasków done) → przełącz na 6-Sequential
#     i dokończ ręcznie ostatnie zadania
# (b) Loop daleko od końca → rollback (git reset) + restart przez 6-Sequential lub
#     6-Teams z innym planem
```

### 6R.6 Anti-patterns (operator-specific)

- ❌ Uruchamianie 6-Ralph dla S-size — Phase 5.7.1 skip rule, ale jeśli ominięto:
  overhead loop > zysk, jedna implementacja + manualne validate jest szybsza.
- ❌ Mieszanie Phase 6-Ralph z Phase 6-Teams ("ralph spawn 3 teammates") — Phase 5.7.5
  reguła twarda. Ralph = solo agent z self-feedback. Teams = lead-driven coordination.
- ❌ Pomijanie pre-flight invariants 6R.1 — bez bypass mode loop wybije się przy każdym
  permission prompt (Bash, Write); bez test runnera loop nie ma jak wystawić promise.
- ❌ Manualne `git commit` w trakcie loop'a — agent w next iteration zobaczy dirty/extra
  commity i będzie próbował je "poprawić" (git mess).
- ❌ Liczenie że loop zrobi Phase 7.8 live preview — to interaktywna faza, loop kończy
  się PRZED nią. Loop = code-only completion, preview = post-loop human gate.

---

## PHASE 7 — TESTING

**Przeczytaj teraz `references/testing-protocol.md`** — pełna definicja 7 zakresów testów,
matryca S/M/L, kolejność wykonania, fallback Playwright CLI gdy brak Chromium.

**7 zakresów testów (scope-driven):**

| # | Zakres | **S** | **M** | **L** |
|---|--------|:---:|:---:|:---:|
| 1 | Jednostkowe (czy działa kawałek kodu) | ✅ | ✅ | ✅ |
| 2 | Integracyjne (czy elementy działają razem) | ✅ | ✅ | ✅ |
| 3 | Systemowe (czy działa cały system) | ⏭️ | ✅ | ✅ |
| 4 | Akceptacyjne (czy spełnia wymagania / DoD) | ✅¹ | ✅ | ✅ |
| 5 | E2E Playwright Chrome (pełna ścieżka usera) | ⏭️ | ✅ | ✅ |
| 6 | Regresyjne (czy nie zepsuło starego) | ✅ | ✅ | ✅ |
| 7 | Wydajność + Bezpieczeństwo | ⏭️ | ✅² | ✅ |

¹ Dla **S** akceptacyjne mogą być manualne (procedura z checklistą + adnotacja `manual::` w trace matrix).
² Dla **M** wymagane jeśli plan ma jakikolwiek AC-N.

**E2E run-mode (zakres 5) — Playwright Chrome hierarchia:**

| Tier | Mechanizm | Kiedy użyć | Komenda / tool |
|------|-----------|------------|----------------|
| **1 — preferowane** | Playwright Chromium (test runner) | Domyślne dla M+ z UI; spec files w `tests/e2e/` lub `e2e/` | `npx playwright test --project=chromium` |
| **2 — install fallback** | Playwright Chromium po install | Tier 1 fail z "browser not installed" | `npx playwright install chromium --with-deps && npx playwright test --project=chromium` |
| **3 — chrome-devtools-mcp** | MCP plugin (real Chrome) | Brak Playwright deps / sandbox restriction; chcemy traffic + console + DOM inspect | `mcp__plugin_chrome-devtools-mcp_chrome-devtools__*` (new_page, navigate_page, take_screenshot, list_console_messages, list_network_requests) |
| **4 — CLI fallback (inny browser)** | Playwright firefox/webkit | Tier 1–3 fail, Chromium niedostępne | `npx playwright test --project=firefox` (ZAWSZE oznacz w raporcie który browser realnie odpalił) |

> **Reguła twarda:** brak Chromium **NIE oznacza** skip E2E. Eskalujemy w dół tabeli aż coś
> zadziała. Lepiej zielony test na firefox + jawna nota w raporcie niż pominięta walidacja.

**Plugin status check (preflight zakresu 5):**

```bash
# Czy Playwright zainstalowany w projekcie?
PW_INSTALLED=0
[ -f package.json ] && jq -e '.devDependencies["@playwright/test"] // .dependencies["@playwright/test"]' package.json >/dev/null 2>&1 && PW_INSTALLED=1

# Czy Chromium binary jest w cache? Playwright cache'uje binaria w deterministycznych ścieżkach:
#   - Linux:   ~/.cache/ms-playwright/chromium-*
#   - macOS:   ~/Library/Caches/ms-playwright/chromium-*
#   - override: $PLAYWRIGHT_BROWSERS_PATH (jeśli ustawione)
# Sprawdzamy fizyczną obecność katalogu zamiast nieistniejącego `playwright install --dry-run`.
PW_CHROMIUM_OK=0
PW_CACHE="${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}"
[ -d "$HOME/Library/Caches/ms-playwright" ] && PW_CACHE="$HOME/Library/Caches/ms-playwright"
ls -d "$PW_CACHE"/chromium-* >/dev/null 2>&1 && PW_CHROMIUM_OK=1

# Czy chrome-devtools-mcp plugin aktywny? (settings.json może nie istnieć — fallback "false")
CDM_ENABLED="false"
if [ -f ~/.claude/settings.json ]; then
  CDM_ENABLED=$(jq -r '.enabledPlugins["chrome-devtools-mcp@claude-plugins-official"] // false' \
    ~/.claude/settings.json 2>/dev/null || echo "false")
fi

echo "PW_INSTALLED=$PW_INSTALLED  PW_CHROMIUM_OK=$PW_CHROMIUM_OK  CDM_ENABLED=$CDM_ENABLED"
```

**Decyzja na podstawie probe:**

- `PW_INSTALLED=1` + `PW_CHROMIUM_OK=1` → **Tier 1** (najczęstszy path)
- `PW_INSTALLED=1` + `PW_CHROMIUM_OK=0` → spróbuj **Tier 2** (`playwright install chromium`)
- `PW_INSTALLED=0` + `CDM_ENABLED=true` → **Tier 3** (chrome-devtools-mcp; spec'i w spec files NIE działają, ale pełny browser-driven flow OK)
- Cokolwiek innego → **Tier 4** (CLI z innym browser'em + jawny raport)

**Tier 3 — chrome-devtools-mcp jako primary E2E (gdy brak Playwright):**

```
mcp__plugin_chrome-devtools-mcp_chrome-devtools__new_page(url)
  ↓
mcp__plugin_chrome-devtools-mcp_chrome-devtools__fill_form / __click / __navigate_page
  ↓
mcp__plugin_chrome-devtools-mcp_chrome-devtools__list_console_messages   ← console errors = fail
mcp__plugin_chrome-devtools-mcp_chrome-devtools__list_network_requests   ← 4xx/5xx = fail
mcp__plugin_chrome-devtools-mcp_chrome-devtools__take_screenshot         ← evidence dla CR/AC
```

Wynik **wpisz jako manual::e2e** w trace matrix Phase 8 (nie automated test, ale realne
browser flow). Każdy AC-F z DoD musi mieć **screenshot** dowodzący PASS.

Commit: `test(plan-PLAN_NUM): [scope] tests` (np. `test(plan-042): unit + integration shelter validators`).

**Test gate** — wszystkie wymagane zakresy zielone przed Phase 8. Kolejność wykonania:
unit → typecheck/lint/build → integration → system → acceptance → E2E → regression → perf+security.

**Każdy test mapuje się na konkretny AC** — zbieraj `test::name` (z prefiksem zakresu:
`test::unit`, `test::e2e`, `test::security`, `manual::e2e`, `manual::`) teraz, wpisuj do
trace matrix w Phase 8.

**Loguj wyjścia testów do plików** — Phase 7.6 (opcjonalny ralph-loop test-fix) potrzebuje
listy czerwonych testów **bez ponownego uruchomienia** (re-run kosztuje czas + ma efekty
uboczne na DB/auth state). Standardowe ścieżki:

```bash
# Unit + integration (Vitest/Jest)
npm test 2>&1 | tee /tmp/test-unit-${PLAN_NUM}.log
# E2E (Playwright)
npx playwright test --project=chromium --reporter=line 2>&1 | tee /tmp/test-e2e-${PLAN_NUM}.log
# Pythonowy odpowiednik
pytest 2>&1 | tee /tmp/test-pytest-${PLAN_NUM}.log
```

> **Reguła twarda:** logi `/tmp/test-*-${PLAN_NUM}.log` muszą istnieć przed wejściem w Phase 7.6.
> Jeśli ich nie ma, Phase 7.6 nie ma czego parsować — wraca do manualnego fix loop'a.

---

## PHASE 7.6 — RALPH-LOOP TEST-FIX (opcjonalny)

Po Phase 7 test gate, **przed** Phase 7.8. Aktywuje się **tylko gdy oba spełnione:**

1. `RALPH_AVAILABLE=1` (Phase 0.5 probe)
2. Phase 7 zostawiło ≥ 1 czerwony zakres (typecheck/lint/unit/integration/system/acceptance/E2E/regression/perf+security)
   ALE feature wygląda "blisko" — większość testów green, czerwone wyglądają na fixable
   (typo, race condition, brakujący await, missing assertion).

**Skip rules (cisza, idź do 7.8 lub fix-loop ręcznie):**

```bash
# Sprawdź state file z Phase 6R.5 — czy Phase 6 było 6-Ralph?
RALPH_STATE_FILE=".claude/plan-${PLAN_NUM}.state"
RALPH_USED_PHASE6=0
[ -f "$RALPH_STATE_FILE" ] && grep -q "RALPH_USED=1" "$RALPH_STATE_FILE" && RALPH_USED_PHASE6=1

# Skip Phase 7.6 jeśli któreś:
[ "$RALPH_AVAILABLE" = "0" ]   && { echo "SKIP 7.6 — RALPH_AVAILABLE=0, manualny fix"; SKIP_76=1; }
[ "$PLAN_SIZE" = "S" ]         && { echo "SKIP 7.6 — S-size, manualny fix prostszy"; SKIP_76=1; }
[ "$RALPH_USED_PHASE6" = "1" ] && { echo "SKIP 7.6 — Phase 6 było 6-Ralph (loop już iterował na test gate); fix manualnie"; SKIP_76=1; }
```

- `RALPH_AVAILABLE=0` → klasyczny fix loop (manualnie ty / 6-Sequential).
- Czerwone testy = **systemowy bug** (architektura, źle dobrana hipoteza) → ralph-loop nie
  uratuje, **wracaj do Phase 6** lub Phase 2 (re-hypothesize).
- Plan rozmiar **S** → manualny fix prostszy.
- Phase 6 było **6-Ralph** (sprawdzane przez `.claude/plan-${PLAN_NUM}.state`) → Step 4
  prompt'a już iterował na test gate; jeśli i tak czerwone, znaczy że loop wystawił
  `<promise>FEATURE_DONE</promise>` przedwcześnie (bug w prompt'cie), **NIE re-uruchamiaj
  loop'a na test-fix**, fix manualnie.

**Build the test-fix prompt** (gdy `SKIP_76` nie ustawione):

```bash
[ "${SKIP_76:-0}" = "1" ] && { echo "Phase 7.6 pominięta — przejdź do 7.8 lub manualnie fix"; exit 0; }

RALPH_TESTFIX_PROMPT="/tmp/ralph-testfix-${PLAN_NUM}.txt"

# Czytaj logi testów z Phase 7 (NIE re-run — efekty uboczne na DB/auth/rate limiting).
# Phase 7 obowiązkowo loguje wyniki do /tmp/test-*-${PLAN_NUM}.log.
TEST_E2E_LOG="/tmp/test-e2e-${PLAN_NUM}.log"
TEST_UNIT_LOG="/tmp/test-unit-${PLAN_NUM}.log"

if [ ! -f "$TEST_E2E_LOG" ] && [ ! -f "$TEST_UNIT_LOG" ]; then
  echo "❌ Brak logów Phase 7 — nie mogę zbudować promptu test-fix bez listy failures"
  echo "   Wróć do Phase 7 i odpal testy z 'tee /tmp/test-*-${PLAN_NUM}.log'"
  exit 1
fi

FAILING_TESTS=""
[ -f "$TEST_E2E_LOG" ]  && FAILING_TESTS+=$(grep -E '✗|FAIL' "$TEST_E2E_LOG"  | head -20)
FAILING_UNIT=""
[ -f "$TEST_UNIT_LOG" ] && FAILING_UNIT+=$(grep -E 'FAIL|✗' "$TEST_UNIT_LOG" | head -10)

# Sanity — jeśli logi istnieją ale puste, znaczy testy zielone — Phase 7.6 nie ma sensu
if [ -z "$FAILING_TESTS$FAILING_UNIT" ]; then
  echo "✅ Logi Phase 7 nie pokazują czerwonych — Phase 7.6 niepotrzebne, idź do 7.8"
  exit 0
fi

REPO_ROOT=$(git rev-parse --show-toplevel)

cat > "$RALPH_TESTFIX_PROMPT" <<EOF
# Ralph-loop test-fix — Plan #${PLAN_NUM}

Feature jest zaimplementowany ale test gate ma czerwone zakresy. Iteruj fix → re-run aż green.

## State recovery (per iteration)
1. \`${REPO_ROOT}/docs/plany/${PLAN_NUM}-${SLUG}.md\` — plan + DoD
2. \`${REPO_ROOT}/docs/code-reviews/AC-${PLAN_NUM}-${SLUG}.md\` — AC priorytety (jeśli jest; powstaje w Phase 8.1)
3. \`git log --grep="plan-${PLAN_NUM}" --oneline\` — co już commitowane
4. Run \`npm test\` + \`npx playwright test --project=chromium\` — current red/green (re-run dopiero po fix'ie, nie w state recovery)

## Failing tests (snapshot at start — z logów Phase 7)
\`\`\`
$FAILING_TESTS
$FAILING_UNIT
\`\`\`

## Loop body

### Step 1 — Pick first red test
Wybierz **pierwszy** czerwony test (priorytet: unit > integration > E2E — bo unit szybciej iterują).

### Step 2 — Diagnose
- Read test file (assertion + setup)
- Read SUT (system under test) — kod który test sprawdza
- Run **tylko ten jeden test** w izolacji: \`npm test -- <test-name>\` lub
  \`npx playwright test -g "<test-title>"\`

### Step 3 — Fix (kod produkcyjny lub test)
**Reguła:** fix testu OK gdy assertion był wadliwy (literówka w expected value, race condition w setup).
Fix kodu produkcyjnego gdy SUT robi nie to co plan/DoD wymaga.

NIGDY nie fix przez:
- ❌ \`test.skip\` / \`xit\` / \`@pytest.mark.skip\` (= ukrycie problemu)
- ❌ Modifikacja DoD/AC żeby pasowały do bugu (= sabotaż gate'u)
- ❌ Rozluźnienie assertion (\`toBe\` → \`toBeDefined\`) bez uzasadnienia

### Step 4 — Validate
\`\`\`bash
# Re-run zakres który był czerwony
npm test                                       # unit + integration
npx playwright test --project=chromium         # E2E
\`\`\`

Jeśli ten sam test wciąż czerwony po 3 iteracjach na nim → **bloker**, output blocker w chacie
(loop wystawi \`<promise>BLOCKED</promise>\` ale to nie jest completion-promise → loop poleci dalej; lepiej:
zatrzymaj iterowanie tego testu, przejdź do następnego).

### Step 5 — Commit
\`\`\`bash
git add <fixed-files>
git commit -m "fix(plan-${PLAN_NUM}): <test-name or red-zone> — <why>"
\`\`\`

### Step 6 — Promise
Tylko gdy:
✅ \`npm test\` zielone
✅ \`npx playwright test --project=chromium\` zielone (lub fallback tier zielone, jawnie oznaczone)
✅ Wszystkie zakresy z matrycy 7 wymagane dla rozmiaru green

Wystaw EXACTLY:
<promise>TESTS_GREEN</promise>
EOF

# Max iterations: zwykle dużo mniej niż implementation loop
RALPH_TESTFIX_MAX=$(( $(echo "$FAILING_TESTS$FAILING_UNIT" | wc -l) * 3 + 10 ))
[ "$RALPH_TESTFIX_MAX" -gt 30 ] && RALPH_TESTFIX_MAX=30
echo "RALPH_TESTFIX_MAX=$RALPH_TESTFIX_MAX"
```

**Launch:**

```
/ralph-loop "$(cat /tmp/ralph-testfix-PLAN_NUM.txt)" --max-iterations $RALPH_TESTFIX_MAX --completion-promise "TESTS_GREEN"
```

**Po completion / cancellation:**

- `<promise>TESTS_GREEN</promise>` → idź do Phase 7.8 (live preview).
- `--max-iterations` exhausted → wracaj do Phase 6 (jeśli systemowy bug) lub fix manualnie ostatnie czerwone.

> **Anti-pattern:** uruchamianie 7.6 dla tej samej grupy testów więcej niż raz. Jeśli pierwszy
> 7.6 zostawił czerwone, drugi nic nie naprawi (te same prompt + state). Wskaźnik systemowego problemu —
> wracaj do Phase 6 lub Phase 2.

---

## PHASE 7.8 — LIVE PREVIEW (M+, gdy feature ma UI)

Po test gate green (Phase 7), **przed** Phase 8 code review. Cel: user widzi feature na żywo
w przeglądarce, zanim zatwierdzi merge. Preview = wizualna acceptance, niezastępowalna
przez zielone testy automatyczne.

### 7.8.1 Skip rules

- **S** → skip (mała surgical zmiana, review bazuje na diff'ie).
- **Backend-only** (no UI) → skip — oznacz w raporcie `7.8: n/a — backend-only`.
- **Pure refactor** (zero zmiany behavior) → skip — preview nic nie pokaże.
- **M/L z UI** → wymagane.

### 7.8.2 Detect dev server command + port

```bash
# Node — package.json scripts.dev (Next.js, Vite, Remix, Astro, etc.)
DEV_CMD=$(jq -r '.scripts.dev // .scripts.start // empty' package.json 2>/dev/null)

# Python fallbacki — UWAGA: entry point bywa różny per projekt.
# Komendy poniżej to HEURYSTYKI — sprawdź konwencje repo i nadpisz $DEV_CMD ręcznie jeśli różne.
if [ -z "$DEV_CMD" ]; then
  if   [ -f "manage.py" ]; then DEV_CMD="python manage.py runserver"
  elif grep -q "fastapi\|uvicorn" pyproject.toml requirements.txt 2>/dev/null; then
    # Probuj wykryć entry: szukaj `<var> = FastAPI(` lub `<var>: FastAPI = FastAPI(`
    # w typowych lokalizacjach. Łapie: app, application, api, server, etc.
    FASTAPI_FILE=$(grep -lE '^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*([[:space:]]*:[[:space:]]*FastAPI)?[[:space:]]*=[[:space:]]*FastAPI\(' \
      app/main.py main.py src/main.py api/main.py server/main.py 2>/dev/null | head -1)

    # Wyciągnij nazwę zmiennej (app/application/api/...) z linii `<var> [: FastAPI] = FastAPI(`
    if [ -n "$FASTAPI_FILE" ]; then
      FASTAPI_VAR=$(grep -E '^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*([[:space:]]*:[[:space:]]*FastAPI)?[[:space:]]*=[[:space:]]*FastAPI\(' "$FASTAPI_FILE" \
        | head -1 \
        | sed -E 's/^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*).*/\1/')
      FASTAPI_VAR="${FASTAPI_VAR:-app}"   # bezpieczny default

      # Mapuj path → moduł (kropki zamiast slashes, bez .py)
      FASTAPI_MODULE="${FASTAPI_FILE%.py}"
      FASTAPI_MODULE="${FASTAPI_MODULE//\//.}"
      DEV_CMD="uvicorn ${FASTAPI_MODULE}:${FASTAPI_VAR} --reload --port 8000"
    else
      echo "⚠️  Wykryto FastAPI w deps, ale nie znaleziono entry pointu w typowych lokalizacjach."
      echo "   Podaj DEV_CMD ręcznie (przykład: uvicorn myapp.main:app --reload --port 8000)"
      DEV_CMD=""
    fi
  elif grep -q "flask" pyproject.toml requirements.txt 2>/dev/null; then
    DEV_CMD="flask run --debug"
  fi
fi

# Port detection — z .env, package.json, lub framework default
DEV_PORT=$(grep -E '^PORT=' .env .env.local 2>/dev/null | head -1 | cut -d= -f2)
DEV_PORT="${DEV_PORT:-3000}"   # Next.js/Vite default

[ -z "$DEV_CMD" ] && { echo "⚠️  Brak dev command — podaj jak uruchomić serwer (zapytaj user)"; exit 1; }
echo "Dev cmd:  $DEV_CMD"
echo "Dev port: $DEV_PORT"
```

> **Uwaga o heurystykach:** dla nietypowych setupów (custom entry, monorepo, env-loader przez
> `cross-env` / `dotenv-cli` / Next.js 15+ `--env-file`) najpierw spytaj usera o właściwy
> `DEV_CMD` zamiast zgadywać.

### 7.8.3 Start dev server (background)

```bash
# Log do pliku, kill safety. Używamy `setsid` aby utworzyć nową grupę procesów —
# pozwoli to zabić cały drzewo (npm → next dev → turbopack workers) w 7.8.8.
DEV_LOG="/tmp/dev-${PLAN_NUM}.log"

# `sh -c "$DEV_CMD"` — interpretuje $DEV_CMD jak shell (obsługuje quoting, env-loader,
# wieloargumentowe komendy z package.json). NIE używać `nohup $DEV_CMD` bezpośrednio —
# word-splitting niszczy wieloargumentowe komendy.
if command -v setsid >/dev/null 2>&1; then
  setsid sh -c "$DEV_CMD" > "$DEV_LOG" 2>&1 < /dev/null &
else
  # macOS bez setsid → fallback na nohup + sh -c
  nohup sh -c "$DEV_CMD" > "$DEV_LOG" 2>&1 < /dev/null &
fi
DEV_PID=$!
echo "Dev server PID: $DEV_PID (port $DEV_PORT), log: $DEV_LOG"

# Wait for ready (poll do 60s)
READY=0
for i in $(seq 1 30); do
  if curl -fsS "http://localhost:${DEV_PORT}" >/dev/null 2>&1 \
     || curl -fsS "http://localhost:${DEV_PORT}/api/health" >/dev/null 2>&1; then
    echo "✅ Dev server ready na :${DEV_PORT}"
    READY=1
    break
  fi
  sleep 2
done

if [ "$READY" -ne 1 ]; then
  echo "❌ Dev server nie wystartował w 60s — sprawdź $DEV_LOG"
  tail -30 "$DEV_LOG"
  # Pełny cleanup process tree (nie tylko parent) — identyczny jak w 7.8.8.
  [ -n "${DEV_PID:-}" ] && kill -TERM -"$DEV_PID" 2>/dev/null
  sleep 1
  [ -n "${DEV_PID:-}" ] && kill -9 -"$DEV_PID" 2>/dev/null
  if command -v lsof >/dev/null 2>&1; then
    lsof -ti:"${DEV_PORT}" 2>/dev/null | xargs -r kill -9 2>/dev/null
  elif command -v fuser >/dev/null 2>&1; then
    fuser -k "${DEV_PORT}/tcp" 2>/dev/null
  fi
  exit 1
fi
```

### 7.8.4 Wyciągnij FEATURE_URL — twardy gate

Z planu (Definition of Done lub Relevant files) wywnioskuj URL feature. **Bez konkretnego URL
preview pokazuje przypadkowy ekran (np. login redirect z `/`) — to marnuje pełen cykl preview**
(60s server start + browser launch + cleanup). Lepiej zapytać niż zgadnąć.

```bash
# Probuj wykryć z diff'u (Phase 6 commits)
FIRST_COMMIT=$(git log --grep="plan-${PLAN_NUM}" --format=%H --reverse | head -1)
DETECTED_PATHS=""
if [ -n "$FIRST_COMMIT" ]; then
  DETECTED_PATHS=$(git diff --name-only "${FIRST_COMMIT}^..HEAD" \
    | grep -E '(app|pages|routes)/.*(page|index)\.(tsx|jsx|vue|svelte)$' \
    | head -3)
fi

# Trzy stany — każdy wymaga innej akcji od agenta po wyjściu z bash bloku.
if [ -n "$FEATURE_PATH" ]; then
  echo "FEATURE_URL_STATE=set"
  FEATURE_URL="http://localhost:${DEV_PORT}${FEATURE_PATH}"
  echo "Feature URL: $FEATURE_URL"
elif [ -n "$DETECTED_PATHS" ]; then
  echo "FEATURE_URL_STATE=needs-user-pick"
  echo "Wykryto kandydatów na FEATURE_PATH (z diff'u Phase 6):"
  echo "$DETECTED_PATHS"
else
  echo "FEATURE_URL_STATE=needs-user-input"
  echo "Brak FEATURE_PATH i brak kandydatów w diff'ie."
fi
```

> **⛔ STOP-GATE dla agenta** (czytaj wynik bash bloku powyżej):
>
> - **`FEATURE_URL_STATE=set`** → kontynuuj do 7.8.5.
> - **`FEATURE_URL_STATE=needs-user-pick`** → **NIE kontynuuj do 7.8.5**. Wypisz w chacie
>   listę kandydatów i zapytaj usera który ekran chce zobaczyć. Po odpowiedzi zsetuj
>   `FEATURE_PATH=<wybrana ścieżka>` i re-run blok 7.8.4.
> - **`FEATURE_URL_STATE=needs-user-input`** → **NIE kontynuuj do 7.8.5**. Wypisz w chacie
>   pytanie: „Pod jakim URL feature jest dostępny? (np. /schrony/lista)". Po odpowiedzi
>   zsetuj `FEATURE_PATH` i re-run blok 7.8.4.
>
> **Powód twardego gate'u:** default na `/` produkuje preview homepage/login redirect —
> bezużyteczny dla M+ feature review, a koszt jest pełen cykl (60s server start, browser
> launch, screenshot, cleanup). Tańszy jest 1 chat-question niż 1 zmarnowany preview cycle.
> Gate jest invariantem workflow — bypass mode go NIE omija (to nie permission prompt,
> tylko logiczna decyzja agenta).

### 7.8.5 Open in Playwright Chrome (preferowane)

```bash
# Preferowane: Playwright headed Chromium z screenshot + browser zostaje otwarty.
# Heredoc 'EOF' (single-quoted) → shell NIE interpoluje, JS template-literals działają.
cat > "/tmp/preview-${PLAN_NUM}.mjs" <<'EOF'
import { chromium } from 'playwright';
import { writeFileSync } from 'node:fs';

const url = process.env.FEATURE_URL;
const out = process.env.SCREENSHOT_PATH;
const ready = process.env.READY_MARKER;

const browser = await chromium.launch({ headless: false });

// SIGTERM/SIGINT handler — zapewnia że Chromium zostanie zamknięty po `kill $PW_PID`,
// a nie osierocony jako zombie.
// UWAGA: SIGKILL (`kill -9`) bypassuje ten handler — wtedy browser może zostać sierotą
// i 7.8.8 polega na port-level kill (lsof/fuser) jako safety net dla node, ale dla
// orphan Chromium na macOS może wymagać manual `pkill -f "Google Chrome for Testing"`.
const cleanup = async () => {
  try { await browser.close(); } catch {}
  process.exit(0);
};
process.on('SIGTERM', cleanup);
process.on('SIGINT', cleanup);

const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
const page = await ctx.newPage();
await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
await page.screenshot({ path: out, fullPage: true });

// Marker file → shell może deterministycznie czekać aż screenshot jest na dysku
// (zamiast `sleep 5` race condition). writeFileSync z 2-byte payload jest atomowy
// na ext4/tmpfs/APFS dla single-block writes.
writeFileSync(ready, 'ok');

console.log(`Screenshot: ${out}`);
console.log('Browser pozostaje otwarty — zamknij ręcznie lub kill PID po przeglądzie.');
// Trzymaj browser przy życiu — exit przez SIGTERM/SIGINT z cleanup() powyżej.
await new Promise(() => {});
EOF

SCREENSHOT_PATH="/tmp/preview-${PLAN_NUM}.png"
READY_MARKER="/tmp/preview-${PLAN_NUM}.ready"
rm -f "$READY_MARKER"   # ensure clean slate

FEATURE_URL="$FEATURE_URL" SCREENSHOT_PATH="$SCREENSHOT_PATH" READY_MARKER="$READY_MARKER" \
  node "/tmp/preview-${PLAN_NUM}.mjs" &
PW_PID=$!

# Czekaj aż screenshot zapisany (zamiast `sleep 5` race) — max 35s
# (page.goto timeout = 30s, +5s na screenshot + write)
for i in $(seq 1 35); do
  [ -f "$READY_MARKER" ] && break
  # Sprawdź czy node nie umarł
  kill -0 "$PW_PID" 2>/dev/null || {
    echo "❌ Playwright proces umarł — sprawdź czy $FEATURE_URL jest osiągalny"
    break
  }
  sleep 1
done

if [ -f "$READY_MARKER" ]; then
  echo "✅ Preview screenshot gotowy: $SCREENSHOT_PATH"
else
  echo "⚠️  Screenshot nie powstał w 35s — przejdź do fallback (7.8.6)"
fi
```

### 7.8.6 Fallback: brak Chromium / brak Playwright

Jeśli `chromium.launch()` zawodzi (sandbox / brak deps), wykorzystaj `chrome-devtools-mcp`:

```
mcp__plugin_chrome-devtools-mcp_chrome-devtools__new_page  → URL = $FEATURE_URL
mcp__plugin_chrome-devtools-mcp_chrome-devtools__take_screenshot
mcp__plugin_chrome-devtools-mcp_chrome-devtools__list_console_messages
```

Screenshot wpisz w raport, console messages zwracaj user'owi (errors w konsoli = blocker preview).

**Fallback-fallback** (cowork bez display, headless): screenshot przez Playwright headless +
Lighthouse audit:

```bash
npx playwright screenshot --full-page \
  --browser=chromium --device='Desktop Chrome' \
  "$FEATURE_URL" "/tmp/preview-${PLAN_NUM}.png" \
  || npx playwright screenshot --browser=firefox "$FEATURE_URL" "/tmp/preview-${PLAN_NUM}.png"
```

### 7.8.7 Show user the preview

```
🎬 Live preview — Plan #PLAN_NUM
   Feature URL:  http://localhost:${DEV_PORT}${FEATURE_PATH}
   Screenshot:   /tmp/preview-${PLAN_NUM}.png
   Dev server:   PID ${DEV_PID} (log: /tmp/dev-${PLAN_NUM}.log)
   Browser:      Playwright headed Chromium (lub fallback — patrz raport)

   Sprawdź feature wizualnie. Sprawdź:
     □ Layout zgodny z mockup'em / DoD
     □ Brak console errors (F12)
     □ Mobile viewport OK (resize do 375px)
     □ Dark mode (jeśli plan dotyka theme)
     □ Real data, nie placeholdery

   ✅  Wygląda dobrze → Phase 8 code review
   🔄  Coś nie tak → opisz problem, wracamy do Phase 6 (fix loop)
```

### 7.8.8 Cleanup po preview

Po decision z user. **Trzy warstwy kill** — bo Next.js / Vite / uvicorn często spawn'ują
proces tree (parent shell → node → turbopack workers / vite optimizer / uvicorn workers).
Sam `kill $DEV_PID` zabija tylko parent → dzieci osierocone, port wciąż zajęty.

```bash
# (1) Graceful — SIGTERM do Playwright (cleanup handler zamyka Chromium) i całej
#     grupy procesów dev servera (negative PID = process group).
[ -n "${PW_PID:-}" ] && kill -TERM "$PW_PID" 2>/dev/null
[ -n "${DEV_PID:-}" ] && kill -TERM -"$DEV_PID" 2>/dev/null   # negative = grupa
sleep 2

# (2) Force — jeśli SIGTERM nie zadziałał na grupie.
# UWAGA: SIGKILL na Playwright bypassuje SIGTERM handler w ESM script — Chromium może
# zostać orphan'em. Jeśli kolejne preview cykle zaczynają wolno startować lub widzisz
# zombies w `ps aux | grep "Chrome for Testing"`, użyj manual: `pkill -f "Chrome for Testing"`
# (macOS) lub `pkill -f chromium` (Linux).
[ -n "${PW_PID:-}" ] && kill -9 "$PW_PID" 2>/dev/null
[ -n "${DEV_PID:-}" ] && kill -9 -"$DEV_PID" 2>/dev/null

# (3) Port-level safety net — gwarantuje że port jest wolny dla następnej iteracji.
#     Łapie sieroty których nie znaleźliśmy przez PID/grupę (np. gdy `setsid` nie był
#     dostępny i parent się odlinkował).
if command -v lsof >/dev/null 2>&1; then
  lsof -ti:"${DEV_PORT}" 2>/dev/null | xargs -r kill -9 2>/dev/null
elif command -v fuser >/dev/null 2>&1; then
  fuser -k "${DEV_PORT}/tcp" 2>/dev/null
fi

# Verify port is free
if curl -fsS "http://localhost:${DEV_PORT}" >/dev/null 2>&1; then
  echo "⚠️  Port $DEV_PORT WCIĄŻ ZAJĘTY po cleanup — manual intervention needed"
  command -v lsof >/dev/null && lsof -i:"${DEV_PORT}"
else
  echo "✅ Port $DEV_PORT zwolniony"
fi

# Zachowaj screenshot do PR review (nie commitujemy do repo — to /tmp artifact)
[ -f "/tmp/preview-${PLAN_NUM}.png" ] && \
  echo "📸 Screenshot: /tmp/preview-${PLAN_NUM}.png — załącz w PR opisie (Phase 8.4)"
rm -f "/tmp/preview-${PLAN_NUM}.ready"   # marker, już niepotrzebny
```

**Anti-pattern:** dev server zostawiony w tle po Phase 7.8. Każda iteracja zostawia
proces na port'cie → następny `npm run dev` faila z `EADDRINUSE`. Zawsze cleanup,
zawsze weryfikuj że port jest wolny.

---

## PHASE 8 — CODE REVIEW

### 8.1 Derive Acceptance Criteria

**Przeczytaj teraz `references/ac-protocol.md`** — pełne szablony, quality checklist, Given-When-Then,
kategorie (Success/Boundary/Failure/Non-regression), NFR checklist dla PSP (RODO/WCAG/Perf/Security/Observability).

**Trzy kategorie AC:**
- **AC-F** (Funkcjonalne) — user-observable, z *Definition of Done*, format Given-When-Then
- **AC-T** (Techniczne) — code-level correctness, z *Zadania* + *Patterns catalog* (Analysis Report 1.7)
- **AC-N** (Niefunkcjonalne) — perf, security, accessibility, compliance

**Quality bar — każdy AC:**
1. **Testable** — binarny check (test lub procedura manualna); nie „szybko", nie „łatwo"
2. **Specific** — konkretne liczby/warunki (p95 < 500ms, NIE „fast")
3. **Traceable** — mapuje się na *Definition of Done #n* / *Zadanie #n* / *Założenie #n*
4. **Independent** — jedna troska per AC

**Priorytety (MoSCoW):** `[MUST]` blokuje merge · `[SHOULD]` blokuje ADR · `[COULD]` backlog.

**Minimum per feature:** 1 happy + 1 boundary + 1 failure (+ 1 non-regression jeśli dotyka istniejącego kodu).

Zapisz do `docs/code-reviews/AC-PLAN_NUM-[name].md`:
- `## AC-F (Funkcjonalne)` — Given-When-Then
- `## AC-T (Techniczne)`
- `## AC-N (Niefunkcjonalne)` — RODO/WCAG/Perf/Security
- `## Trace matrix` — tabela AC ↔ test/procedura

### 8.2 Prepare review bundle

```bash
FIRST_COMMIT=$(git log --grep="plan-${PLAN_NUM}" --format=%H --reverse | head -1)
LAST_COMMIT=$(git log --grep="plan-${PLAN_NUM}" --format=%H | head -1)
[ -z "$FIRST_COMMIT" ] && { echo "ERROR: brak commitów"; exit 1; }

git log --oneline ${FIRST_COMMIT}^..${LAST_COMMIT}
DIFF_SIZE=$(git diff --shortstat ${FIRST_COMMIT}^..${LAST_COMMIT} | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
echo "Diff size: ${DIFF_SIZE} linii"
[ "${DIFF_SIZE:-0}" -gt 2000 ] && echo "⚠️  >2000 linii — rozważ split"
```

### 8.3 Invoke code review — **fork wg `$CR_BACKEND`**

#### 🅰️ Wariant A: `CR_BACKEND=superpowers`

> Use the **code-reviewer** agent to review commits `${FIRST_COMMIT}^..${LAST_COMMIT}` for plan #PLAN_NUM.
>
> **AC:** `docs/code-reviews/AC-PLAN_NUM-[name].md` (z priorytetami MUST/SHOULD/COULD)
> **Plan:** `docs/plany/PLAN_NUM-[name].md`
>
> Dla każdego AC oceń: **PASS / FAIL / PARTIAL**, z dowodem (file:line lub nazwa testu).
> Dodatkowe findings poza AC grupuj wg severity: 🔴 Critical / 🟡 Major / 🟢 Minor.

#### 🅱️ Wariant B: `CR_BACKEND=codex`

```bash
codex exec \
  --context "docs/plany/${PLAN_NUM}-${SLUG}.md" \
  --context "docs/code-reviews/AC-${PLAN_NUM}-${SLUG}.md" \
  --diff "${FIRST_COMMIT}^..${LAST_COMMIT}" \
  --format "severity-grouped-with-ac-mapping" \
  > docs/code-reviews/_raw-CR-${PLAN_NUM}.txt
```

#### 🅲 Wariant C: `CR_BACKEND=inline`

> Review commits przeciw plan + AC. Dla każdego AC: PASS/FAIL/PARTIAL + dowód.
> Findings wg severity. **Bądź krytyczny** — bugi, edge cases, naruszenia AC.

### 8.4 Structure findings → CR report

```markdown
# CR-PLAN_NUM — [feature name]
Backend: `${CR_BACKEND}` | Commits: `${FIRST_COMMIT}..${LAST_COMMIT}` | Diff: ${DIFF_SIZE} linii

## AC verdict
| AC | Priorytet | Verdict | Dowód |
|----|-----------|---------|-------|
| AC-F-1 | MUST | ✅ PASS | `tests/integration/shelters-list.spec.ts::"filters by powiat"` |
| AC-F-2 | MUST | ❌ FAIL | brak obsługi pustej listy |
| AC-N-1 | SHOULD | ⚠️ PARTIAL | p95=620ms (target <500ms) |

## 🔴 Critical (blokuje merge)
### [1] file.ts:42 — [tytuł]
**AC:** AC-F-2
**Problem:** ... **Dlaczego:** ... **Fix:** ...

## 🟡 Major (blokuje ADR)
## 🟢 Minor (backlog)

## Podsumowanie
- AC MUST spełnione: [X/Y]
- AC SHOULD spełnione: [X/Y]
- Blokery merge: [lista 🔴]
- Decyzja: PROCEED / FIX-FIRST / RESTART-PHASE-6

## Live preview artifact (z Phase 7.8, jeśli był)
- Screenshot: `/tmp/preview-PLAN_NUM.png` → załącz w opisie PR (drag-drop w GitHub UI)
- Feature URL podczas review: `http://localhost:DEV_PORT/FEATURE_PATH`
- Console errors: [none / lista — z list_console_messages]
```

### 8.5 Fix criticals

Każdy 🔴 → `fix(plan-PLAN_NUM): [desc]`. Po fixach **re-run 8.3**.

### 8.6 Commit review artifacts

```bash
git add docs/code-reviews/AC-${PLAN_NUM}-*.md docs/code-reviews/CR-${PLAN_NUM}-*.md
git commit -m "docs(plan-${PLAN_NUM}): code review (backend: ${CR_BACKEND})"
```

**Brak ADR dopóki są otwarte 🔴 lub niespełnione AC MUST.**

---

## PHASE 9 — ADR

**Przeczytaj teraz `references/adr-template.md`** — pełny template z opcjonalną sekcją
`## Parallelization` (gdy plan wykonywany w 6-Teams).

### 9.1 Setup

```bash
mkdir -p docs/adr
ADR_FILE="docs/adr/ADR-${PLAN_NUM}-${SLUG}.md"
echo "ADR_FILE=$ADR_FILE"
```

### 9.2 Write ADR

Wywołaj **Write tool** z treścią wg template z `references/adr-template.md`. Sekcje obowiązkowe:
`Status`, `Kontekst`, `Decyzja`, `Konsekwencje`, `Alternatywy rozważane`, `Weryfikacja`.
Sekcja `Follow-ups` opcjonalna. Sekcja `Parallelization` **obowiązkowa gdy 6-Teams**, inaczej pomiń.

### 9.3 Sanity check

```bash
test -s "$ADR_FILE" || { echo "ERROR: ADR pusty"; exit 1; }
SECTIONS=$(grep -c '^## ' "$ADR_FILE")
[ "$SECTIONS" -ge 6 ] || { echo "ERROR: ADR ma $SECTIONS sekcji, wymagane ≥6"; exit 1; }
wc -l "$ADR_FILE"
```

### 9.4 Commit

```bash
git add "$ADR_FILE"
git commit -m "docs(plan-${PLAN_NUM}): ADR — [kebab-name decision]"
```

### 9.5 Final TodoWrite

Po zapisaniu ADR wywołaj **TodoWrite** raz z całą listą gdzie **wszystkie** zadania mają
`status: "completed"` (włączając ewentualne dodatkowe entry "Code review" / "ADR" jeśli były
dodawane do listy w Phase 8 / 9). To zamyka harness checklist UI dla planu.

Jeśli z jakiegoś powodu lista jest nieaktualna (np. compaction), wywołaj TodoWrite z pustą
listą `{ todos: [] }` — to czyści tracking dla bieżącej sesji.

### 9.6 Worktree cleanup reminder (jeśli Phase 5.5 utworzyła worktree)

**Nie usuwaj worktree od razu po ADR.** Worktree zostaje **do czasu mergu PR** —
post-merge fixy / hotpatchy łatwiej zrobić z istniejącego worktree niż go odtwarzać.

Po mergu PR (lub gdy plan abandoned) pokaż userowi:

```
🧹 Worktree cleanup (po mergu PR):
   git worktree remove "$WORKTREE_PATH"
   git branch -d "$WORKTREE_BRANCH"   # --delete safe (sprawdza merge)

   Jeśli zostawiasz worktree (np. dla follow-up planu) — pamiętaj że gałąź
   $WORKTREE_BRANCH wciąż istnieje i `git worktree list` ją pokaże.
```

Pomiń tę sekcję jeśli Phase 5.5 nie utworzyła worktree (S-size lub user wybrał skip).

---

## CRITICAL RULES

| Reguła | Detail |
|--------|--------|
| **Analysis Report obowiązkowy** | Phase 1.8 — bez niego nie startujemy Phase 2 |
| **Open questions blokują Phase 2** | Jeśli są w Analysis Report → STOP i zapytaj |
| **Analog featuru = primary template** | Brak analoga → Blocker |
| **H1/H2/H3 dla hipotez** | Nigdy `[N]` |
| **Zero kodu przed approval** | Phase 5 hard stop |
| **Zawsze zapisuj plan** | `test -s $PLAN_FILE` |
| **Taski ≠ testy** | Testy = Phase 7 |
| **Out of scope + Założenia + Rollback** | Wszystkie trzy w planie |
| **feat dla migracji** | Migracje = kod produkcyjny |
| **Nigdy `git add -A`** | Tylko „Relevant files" + migracje |
| **Nigdy commit na main/master** | Gałąź `plan/PLAN_NUM-slug` |
| **Commit per task** | Jedno zadanie = jeden commit |
| **AC SMART-owe** | Testable, Specific, Traceable, Independent |
| **AC-F = Given-When-Then** | MUST/SHOULD/COULD |
| **Trace matrix AC ↔ test** | Każdy MUST ma test lub procedurę manualną |
| **Test gate przed review** | 7 zakresów per S/M/L matryca; unit+integration+acceptance+regression zawsze; system+E2E od M; perf+security: L zawsze, M jeśli AC-N istnieje |
| **E2E hierarchia Chromium** | Phase 7 — Tier 1: `playwright test --project=chromium` → Tier 2: `playwright install chromium` → Tier 3: `chrome-devtools-mcp` (real Chrome przez MCP) → Tier 4: CLI z innym browser'em (jawny raport). Brak Chromium ≠ skip E2E |
| **Worktree dla L, propose dla M** | Phase 5.5 — auth/DB/UI w izolowanym `git worktree add ../<repo>-plan-PLAN_NUM-<slug>` na `plan/PLAN_NUM-<slug>`; S = skip; cleanup po mergu PR, nie wcześniej |
| **Ralph-loop jako opt-in** | Phase 5.7 — propose dla L-size z silnym test gate / backend-only / greenfield / user explicit. RALPH_MODE=1 wyklucza TEAMS_ENABLED (mutual exclusion). S = skip zawsze |
| **Ralph pre-flight invariants** | Phase 6R.1 — bypass mode + plan + clean git + test runner. Bez tego loop wybije się na permission prompts lub nie wie kiedy stop |
| **Ralph kończy PRZED 7.8** | Phase 6-Ralph = code-only completion. Live preview = post-loop human gate (interaktywna, loop nie potrafi) |
| **Live preview przed code review** | Phase 7.8 — M+ z UI: start dev server (background) → Playwright headed Chromium na FEATURE_URL → screenshot + console check → user wizualnie zatwierdza → cleanup (zabij dev server + browser) |
| **Test-fix loop opcjonalny** | Phase 7.6 — gdy `RALPH_AVAILABLE=1` + większość testów green + czerwone wyglądają na fixable; SKIP gdy systemowy bug (wracaj do Phase 6/2) lub Phase 6 było 6-Ralph (loop już iterował na test gate) |
| **Fix 🔴 + AC MUST przed ADR** | Phase 9 dopiero przy zero krytycznych i wszystkich MUST |
| **PLAN_NUM wszędzie** | Spójny w plikach, commitach, review |
| **`/effort max` request** | Phase 0.3 — miękka prośba o boost reasoningu, nie blokuje |
| **TEAMS auto-detect** | Phase 0.4 — env var OR settings.json (project/user) |
| **TEAMS auto-sizing** | Phase 6T.1 — agent dobiera 2–5 teammates sam, nie pyta |
| **TEAMS = 1 file = 1 teammate** | Phase 6T.1 — zero overlapów ownership |
| **Lead nie koduje** | Phase 6T.3 — lead synchronizuje, nie implementuje |
| **Lead-only cleanup** | Phase 6T.5 — tylko lead `Clean up the team` |
| **Migracje DB → 1 teammate** | Phase 6T.1 — schema changes nigdy równolegle |
| **Deep research = stock CC + pluginy** | Phase 1.0 — context7 / Explore / defuddle / WebSearch / codex; ZERO Gemini i innych zewnętrznych LLM |
| **Research lock: max 2 mechanizmy** | Phase 1.0 — research to paliwo, nie cel; loguj w „Research used" |
| **context7 OBLIGATORYJNIE przed kodem** | Phase 6.−1 — dla każdej external library w planie wywołaj `resolve-library-id` + `query-docs` przed implementacją. Wyniki w chacie. „Pamiętam jak to działa" = czerwona flaga, nie znasz post-cutoff API |
| **TodoWrite z całą listą** | Phase 6.1 — harness Claude Code ma **jeden** tool `TodoWrite` (nie ma TaskCreate/TaskUpdate per task). Każda zmiana statusu = kolejne wywołanie TodoWrite z całą listą; pojedynczy task `n` zmienia status, reszta zachowuje swój. Schema: `{ todos: [{ content, activeForm, status }] }` |
| **ADR sanity check** | Phase 9.3 — `test -s "$ADR_FILE"` + `grep -c '^## '` ≥ 6 sekcji; brak ADR = brak zamknięcia planu |

---

## Quick Reference Flow

```
[0]   PLAN_NUM (zero-pad) + CR_BACKEND + /effort max prośba + TEAMS_ENABLED probe + RALPH_AVAILABLE probe + bypass-mode hint (jeśli L/6-Teams/6-Ralph)
[1]   Analysis: stack → architektura → analog END-TO-END → data model → impact radius → tests → patterns
      → Analysis Report → open questions? → STOP lub OK
[2]   H1/H2/H3 hipotezy (każda z referencją do Analysis Report)
[3]   Rekomendacja Hx
[4]   Plan: Co&Dlaczego | Rozmiar S/M/L | DoD | Założenia | OOS | Rollback | Tasks (+parallel-group) | Files
[5]   test -s $PLAN_FILE → ⛔ HARD STOP (approval)
[5.5] Worktree decision: S=skip | M=propose (default no) | L=propose strongly (default yes)
       → if accepted: `git worktree add ../<repo>-plan-PLAN_NUM-<slug> -b plan/PLAN_NUM-<slug>` → operate w worktree
[5.7] Ralph-loop decision: S=skip | M=skip | L+test-gate/backend/greenfield=propose (default no) | user explicit "ralph"=propose strongly (default yes)
       → RALPH_MODE=1 wyklucza TEAMS_ENABLED (sequential decision)
[6]   Pre-flight: context7 docs probe (OBLIGATORYJNE dla każdej external lib) → TodoWrite z listą zadań → Routing (hard-assert mutual exclusion: RALPH_MODE wygrywa z TEAMS):
        ├─ RALPH_MODE=1                              → PHASE 6-Ralph (autonomous loop)
        │     └─ 6R.0 git → 6R.1 invariants (bypass+plan+clean+tests+TodoWrite) → 6R.2 build prompt (absolute paths) → 6R.3 /ralph-loop → 6R.4 operator role (monitor+blockers, NO impl) → 6R.5 promise/cancel + .claude/plan-N.state file → 6R.6 anti-patterns (no S-size, no mix with Teams, no manual commits during loop)
        ├─ TEAMS_ENABLED=1 + ≥2 parallel-groups → PHASE 6-Teams (auto-size 2–5)
        │     └─ 6T.0 git → 6T.1 sizing → 6T.2 TodoWrite+spawn → 6T.3 lead TodoWrite (per-task completed) → 6T.5 cleanup
        └─ inaczej                              → PHASE 6-Sequential
              └─ gałąź plan/PLAN_NUM-slug → per-task: TodoWrite(task n→in_progress) → impl → ORM → validate → git add jawnie → commit → TodoWrite(task n→completed)
[7]   7 zakresów testów: unit | integration | system | acceptance | E2E (Playwright Chromium → install → chrome-devtools-mcp → CLI fallback) | regression | perf+security
      → matryca S/M/L → kolejność wykonania → ⛔ GATE
[7.6] Ralph-loop test-fix (opcjonalny): RALPH_AVAILABLE=1 + ≥1 czerwony zakres + fixable (nie systemowy bug)
       → /ralph-loop "fix → re-run → green" --completion-promise "TESTS_GREEN" — skip gdy Phase 6 było 6-Ralph
[7.8] Live preview (M+ z UI): detect dev cmd → background server → wait ready → Playwright headed Chromium na FEATURE_URL
       → screenshot + console messages → user wizualnie ✅/🔄 → cleanup (kill dev + browser) — skip dla S i backend-only
[8]   AC (F/T/N, MUST/SHOULD/COULD, Given-When-Then) → FORK wg $CR_BACKEND → CR report z AC verdict → fix 🔴
[9]   mkdir -p docs/adr → Write ADR (≥6 sekcji + Parallelization jeśli 6-Teams + Ralph-iterations jeśli 6-Ralph) → sanity check → commit → finalne TodoWrite(wszystkie completed)
```
