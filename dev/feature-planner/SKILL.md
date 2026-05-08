---
name: feature-planner-v2
description: Structured feature implementation workflow (Replit Agent style) with auto Agent Teams routing, /effort max boost, and deep-research probe (context7, Explore, defuddle, WebSearch, codex; ZERO Gemini). Use when the user describes a feature, change, or task in natural language and Claude Code should plan and implement it end-to-end. Triggers: "dodaj feature v2", "zaimplementuj v2", "zrób żeby", "feature planner v2", "implement", "build feature", "add functionality" — or any request mixing planning + parallel/sequential implementation + testing + code review + ADR. Runs: detect env → analysis → hypotheses → plan (docs/plany/) → APPROVAL GATE → worktree decision (M+: propose, L: rekomendowane) → implement (sequential or 6-Teams auto-routing 2–5 teammates) → testing (7 zakresów: unit/integration/system/acceptance/E2E-playwright-chrome/regression/perf+security per S/M/L) → live preview (M+ z UI: dev server + Playwright headed) → code review → ADR (docs/adr/). Never skip approval gate or code review.
---

# Feature Planner v2 — Replit Agent Style + Auto Agent Teams + Deep Research

> **v2 deltas vs v1:**
> - Phase 0.3 — `/effort max` request (boost reasoning przed analizą)
> - Phase 0.4 — auto-detect `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` (env / settings.json)
> - Phase 1.0 — Deep research probe (stock CC + pluginy: context7, Explore, defuddle, WebSearch, codex; ZERO Gemini)
> - Phase 4 — `parallel-group` hint per task
> - Phase 6 — routing: 6-Sequential ↔ 6-Teams (auto, agent dobiera 2–5 teammates sam)

Full workflow: **analyze → hypothesize → plan → save → approve → implement+commit → test → review → ADR**

Reference files (read when you reach each phase):
- Phase 1 — Deep Analysis: `references/analysis-protocol.md`
- Phase 7 — Testing: `references/testing-protocol.md`
- Phase 8.1 — Acceptance Criteria: `references/ac-protocol.md`
- Phase 8 — Code Review: `references/code-review-protocol.md` (format-agnostic: AC schema, CR report, severity)
- Phase 9 — ADR: `references/adr-template.md`

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

### 0.5 Bypass mode hint (długie Phase 6)

Dla planów rozmiaru **L** lub 6-Teams (≥ 3 teammates) Phase 6 będzie wywołać dziesiątki
permission prompts (Bash dla ORM/git, Write dla każdego pliku, TaskCreate). Aby uniknąć
wybijania flow, wypisz do użytkownika **miękką** sugestię:

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

**Decyzja na wejściu (z Phase 0.4 + Phase 4):**

- `TEAMS_ENABLED=1` AND plan ma ≥ 2 zadania w ≥ 2 różnych `parallel-group` → **PHASE 6-Teams**
- W każdym innym przypadku → **PHASE 6-Sequential**

Wypisz do użytkownika która ścieżka:

```
🛣️  Implementacja: <"6-Teams (równolegle, N teammates)" | "6-Sequential">
```

Jeżeli idziemy w **6-Teams** — przejdź od razu do sekcji `## PHASE 6-Teams` (poniżej 6-Sequential).

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
**TaskCreate** raz per zadanie z planu (numeracja jak w Phase 4 „Zadania"):

```
TaskCreate per zadanie z planu:
  - title: "[1] [Task Name]"          status: pending
  - title: "[2] [Task Name]"          status: pending
  ...
```

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

**① Header + TaskUpdate(in_progress)** — `### ⏳ [n/total] [Task Name]` + `TaskUpdate(taskId_n, status=in_progress)`

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

**⑥ Report + TaskUpdate(completed) + checklist update** — `TaskUpdate(taskId_n, status=completed)` po zielonym validate i commicie. Bez completed-update zadanie wisi `in_progress` w harness UI.

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

**Najpierw — TaskCreate per zadanie z planu** (lead rejestruje wszystkie, każdy taskId zostanie
wpisany w spawn prompt teammate'a, który nim zarządza):

```
TaskCreate per zadanie:
  - "[1] [Task Name]"  status: pending  (assignee: backend-dev)
  - "[2] [Task Name]"  status: pending  (assignee: frontend-dev)
  ...
```

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
4. **Update progress board + TaskUpdate** w user-facing chat po każdym ukończonym tasku.
   Lead wywołuje `TaskUpdate(taskId, status=completed)` gdy teammate zaraportuje commit
   (teammate nie ma access do harness task system leada — to zadanie leada):

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

**E2E run-mode (zakres 5):**

1. **Preferowane:** `npx playwright test --project=chromium` (real Chromium → łapie Chrome-specific bugi).
2. **Fallback gdy brak Chromium:** najpierw `npx playwright install chromium --with-deps`,
   gdy install zawodzi (brak praw / sandbox) → użyj Playwright CLI z dostępnym browserem
   (firefox/webkit) i **explicit oznacz w raporcie**, jaki browser realnie odpalił.
   Brak Chromium ≠ skip E2E. Lepiej zielony test na firefox niż pominięty.

Commit: `test(plan-PLAN_NUM): [scope] tests` (np. `test(plan-042): unit + integration shelter validators`).

**Test gate** — wszystkie wymagane zakresy zielone przed Phase 8. Kolejność wykonania:
unit → typecheck/lint/build → integration → system → acceptance → E2E → regression → perf+security.

**Każdy test mapuje się na konkretny AC** — zbieraj `test::name` (z prefiksem zakresu:
`test::unit`, `test::e2e`, `test::security`, `manual::`) teraz, wpisuj do trace matrix w Phase 8.

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

### 9.5 Final TaskUpdate

Po zapisaniu ADR oznacz finalne zadania w harness:
- `TaskUpdate(taskId_review, status=completed)` (jeśli było)
- `TaskUpdate(taskId_adr, status=completed)` (jeśli było)
Lub po prostu sprzątnij listę: `TaskList → TaskUpdate completed` dla wszystkich pozostałych.

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
| **E2E preferuje Chromium** | Phase 7 — `playwright --project=chromium`; fallback: `playwright install` → inny browser; brak Chromium ≠ skip E2E |
| **Worktree dla L, propose dla M** | Phase 5.5 — auth/DB/UI w izolowanym `git worktree add ../<repo>-plan-PLAN_NUM-<slug>` na `plan/PLAN_NUM-<slug>`; S = skip; cleanup po mergu PR, nie wcześniej |
| **Live preview przed code review** | Phase 7.8 — M+ z UI: start dev server (background) → Playwright headed Chromium na FEATURE_URL → screenshot + console check → user wizualnie zatwierdza → cleanup (zabij dev server + browser) |
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
| **TaskCreate per zadanie** | Phase 6.1 — każde zadanie z planu rejestrowane w harness; TaskUpdate(in_progress) na ⏳, TaskUpdate(completed) po commicie |
| **ADR sanity check** | Phase 9.3 — `test -s "$ADR_FILE"` + `grep -c '^## '` ≥ 6 sekcji; brak ADR = brak zamknięcia planu |

---

## Quick Reference Flow

```
[0]  PLAN_NUM (zero-pad) + CR_BACKEND + /effort max prośba + TEAMS_ENABLED probe + bypass-mode hint (jeśli L/6-Teams)
[1]  Analysis: stack → architektura → analog END-TO-END → data model → impact radius → tests → patterns
     → Analysis Report → open questions? → STOP lub OK
[2]  H1/H2/H3 hipotezy (każda z referencją do Analysis Report)
[3]  Rekomendacja Hx
[4]  Plan: Co&Dlaczego | Rozmiar S/M/L | DoD | Założenia | OOS | Rollback | Tasks (+parallel-group) | Files
[5]  test -s $PLAN_FILE → ⛔ HARD STOP (approval)
[5.5] Worktree decision: S=skip | M=propose (default no) | L=propose strongly (default yes)
       → if accepted: `git worktree add ../<repo>-plan-PLAN_NUM-<slug> -b plan/PLAN_NUM-<slug>` → operate w worktree
[6]  Pre-flight: context7 docs probe (OBLIGATORYJNE dla każdej external lib) → TaskCreate per zadanie → Routing:
        ├─ TEAMS_ENABLED=1 + ≥2 parallel-groups → PHASE 6-Teams (auto-size 2–5)
        │     └─ 6T.0 git → 6T.1 sizing → 6T.2 TaskCreate+spawn → 6T.3 lead TaskUpdate → 6T.5 cleanup
        └─ inaczej                              → PHASE 6-Sequential
              └─ gałąź plan/PLAN_NUM-slug → per-task: TaskUpdate(in_progress) → impl → ORM → validate → git add jawnie → commit → TaskUpdate(completed)
[7]  7 zakresów testów: unit | integration | system | acceptance | E2E (playwright chrome / CLI fallback) | regression | perf+security
     → matryca S/M/L → kolejność wykonania → ⛔ GATE
[7.8] Live preview (M+ z UI): detect dev cmd → background server → wait ready → Playwright headed Chromium na FEATURE_URL
       → screenshot + console messages → user wizualnie ✅/🔄 → cleanup (kill dev + browser) — skip dla S i backend-only
[8]  AC (F/T/N, MUST/SHOULD/COULD, Given-When-Then) → FORK wg $CR_BACKEND → CR report z AC verdict → fix 🔴
[9]  mkdir -p docs/adr → Write ADR (≥6 sekcji + Parallelization jeśli 6-Teams) → sanity check → commit → TaskUpdate(completed)
```
