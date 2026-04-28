---
name: feature-planner-v2
description: Structured feature implementation workflow (Replit Agent style) with auto Agent Teams routing, /effort max boost, and deep-research probe (context7, Explore, defuddle, WebSearch, codex; ZERO Gemini). Use when the user describes a feature, change, or task in natural language and Claude Code should plan and implement it end-to-end. Triggers: "dodaj feature v2", "zaimplementuj v2", "zrób żeby", "feature planner v2", "implement", "build feature", "add functionality" — or any request mixing planning + parallel/sequential implementation + testing + code review + ADR. Runs: detect env → analysis → hypotheses → plan (docs/plany/) → APPROVAL GATE → implement (sequential or 6-Teams auto-routing 2–5 teammates) → testing (4 layers) → code review → ADR (docs/adr/). Never skip approval gate or code review.
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
case "$CURRENT_BRANCH" in
  main|master|develop)
    git checkout -b "plan/${PLAN_NUM}-${SLUG}" ;;
esac
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

Identyczny jak `6.0` (sequential): repo OK, `user.email` set, brak uncommitted tracked changes,
gałąź `plan/PLAN_NUM-${SLUG}` (jeśli na main/master/develop).

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
4 warstwy i test-gate.

---

## PHASE 7 — TESTING

**Przeczytaj teraz `references/testing-protocol.md`.**

| Rozmiar | Unit | Integration | E2E playwright | E2E chrome-devtools-mcp |
|---------|------|-------------|----------------|--------------------------|
| **S** | ✅ | ✅ | ⏭️ | ⏭️ |
| **M** | ✅ | ✅ | ✅ | ⏭️ |
| **L** | ✅ | ✅ | ✅ | ✅ |

Commit: `test(plan-PLAN_NUM): [layer] tests`.

**Test gate** — wszystkie wymagane warstwy zielone przed Phase 8.

**Każdy test mapuje się na konkretny AC** — zbieraj `test::name` teraz, wpisuj do trace matrix w Phase 8.

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
| **Test gate przed review** | Wymagane warstwy zielone |
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
[6]  Pre-flight: context7 docs probe (OBLIGATORYJNE dla każdej external lib) → TaskCreate per zadanie → Routing:
        ├─ TEAMS_ENABLED=1 + ≥2 parallel-groups → PHASE 6-Teams (auto-size 2–5)
        │     └─ 6T.0 git → 6T.1 sizing → 6T.2 TaskCreate+spawn → 6T.3 lead TaskUpdate → 6T.5 cleanup
        └─ inaczej                              → PHASE 6-Sequential
              └─ gałąź plan/PLAN_NUM-slug → per-task: TaskUpdate(in_progress) → impl → ORM → validate → git add jawnie → commit → TaskUpdate(completed)
[7]  Test matrix S/M/L → ⛔ GATE
[8]  AC (F/T/N, MUST/SHOULD/COULD, Given-When-Then) → FORK wg $CR_BACKEND → CR report z AC verdict → fix 🔴
[9]  mkdir -p docs/adr → Write ADR (≥6 sekcji + Parallelization jeśli 6-Teams) → sanity check → commit → TaskUpdate(completed)
```
