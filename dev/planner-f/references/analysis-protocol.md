---
name: analysis-protocol
type: reference
parent: planner-f
sources:
  - dev/feature-planner v2 baseline
  - DOC/material_skill.md §5 (Hyrum's Law, Chesterton's Fence)
description: Phase 1 deep analysis — stack detection, architecture walk, analog feature, PRIMARY TEMPLATE. planner-f zachowuje Hyrum Impact Analysis i Chesterton's Fence dla deletion (dziedziczone z feature-planner-v3).
---

# references/analysis-protocol.md

Protokół dla Phase 1 — **Deep Analysis**. Cel: przed napisaniem jakiejkolwiek hipotezy wiedzieć,
w jaki codebase wchodzisz, co tam już jest i kto na czym siedzi. Output to **Analysis Report** —
jawny artefakt, który zasila Phase 2 (hipotezy) i Phase 4 (plan).

> **Zasada nadrzędna:** jeśli kończysz Phase 1 i nie umiesz wskazać *analoga* (istniejący feature
> najbliższy temu co budujesz) — masz problem. Albo go znajdź, albo uruchom Blocker Protocol.

---

## Timing (orientacyjny, łącznie ~30 min)

| Krok | Czas | Co produkuje |
|------|------|--------------|
| 1.1 Stack detection | ~1 min | 1-linia klasyfikacji |
| 1.2 Architecture walk | ~5 min | mapa warstw entry→DB |
| 1.3 Find the analog | ~10 min | **PRIMARY TEMPLATE** dla Phase 4 |
| 1.4 Data model snapshot | ~2 min | lista tabel/relacji |
| 1.5 Dependency impact radius | ~5 min | lista plików poza scope |
| 1.6 Tests as spec | ~3 min | konwencje testów |
| 1.7 Patterns catalog | ~2 min | tabelka konwencji |
| 1.8 Analysis Report | ~2 min | scalenie w dokument |

Dla featurów rozmiaru **S** dopuszczalny „express mode" (skip 1.6 + 1.7, skrócone 1.5). Dla **L** — nigdy.

---

## 1.1 Stack & framework detection

Cel: klasyfikacja w jednej linii. Nie potrzebujesz pełnej listy zależności — potrzebujesz wiedzieć,
*w czym to jest napisane*.

### Komendy

```bash
# Node / TS
if [ -f package.json ]; then
  # Primary framework
  jq -r '.dependencies // {} | keys | .[]' package.json 2>/dev/null \
    | grep -E '^(next|react|vue|svelte|express|fastify|nest|hono|remix|astro)' | head -5
  # Test runner
  jq -r '(.devDependencies // {}) + (.dependencies // {}) | keys | .[]' package.json 2>/dev/null \
    | grep -E '^(vitest|jest|playwright|cypress|mocha)' | head -5
  # Scripts
  jq -r '.scripts // {} | to_entries[] | "\(.key): \(.value)"' package.json 2>/dev/null
fi

# Python
[ -f pyproject.toml ] && grep -E '^(name|version|requires-python|dependencies|tool\.)' pyproject.toml | head -20
[ -f requirements.txt ] && head -30 requirements.txt

# Go / Rust / inne
[ -f go.mod ] && head -20 go.mod
[ -f Cargo.toml ] && head -30 Cargo.toml
```

### Heurystyki

- `next` w deps + `app/` w repo → **Next.js App Router**
- `next` bez `app/` → **Next.js Pages Router**
- `@nestjs/*` → **NestJS** (decoratory, modules, providers)
- `fastapi` + `sqlalchemy` → warstwa service/repo prawie zawsze
- `django` → monolityczny MVT, models = schema
- `fastify` często bez service layer (plugin-first)

### Output (1-linia)

```
Stack: Next.js 14 (app router) + Prisma/Postgres + Vitest + Playwright + Tailwind + Zustand
```

---

## 1.2 Architecture walk (entry → DB)

Cel: prześledzić jedną ścieżkę requestu przez warstwy. Nie rysuj UML-a — zrób krótką trasę.

### Entry points

```bash
# Next.js app router — route handlers
find . -type f -path '*/app/**/route.ts' -not -path '*/node_modules/*' | head -10
find . -type f -path '*/app/**/page.tsx' -not -path '*/node_modules/*' | head -5

# Next.js pages router
find . -type f -path '*/pages/api/*' -not -path '*/node_modules/*' | head -10

# Express/Fastify
rg -l 'app\.listen\(|fastify\(\)|createServer\(' --type ts --type js 2>/dev/null | head -5

# NestJS
find . -name 'main.ts' -not -path '*/node_modules/*' | head -3

# FastAPI/Flask
rg -l 'FastAPI\(\)|Flask\(__name__\)' --type py 2>/dev/null | head -3
```

### Routes / controllers

```bash
# Express/Fastify style
rg -n 'app\.(get|post|put|delete|patch)\(' --type ts -g '!node_modules' | head -20
# NestJS decorators
rg -n '@(Get|Post|Put|Delete|Patch)\(|@Controller\(' --type ts -g '!node_modules' | head -20
# FastAPI
rg -n '@(app|router)\.(get|post|put|delete)' --type py | head -20
```

### Service / repo layer

```bash
# Nazwy katalogów
find . -maxdepth 4 -type d \( -name services -o -name repositories -o -name repos \
  -o -name domain -o -name usecases -o -name handlers \) -not -path '*/node_modules/*' | head

# Nazwy plików
rg -l 'class.*Service|class.*Repository|class.*Handler' --type ts -g '!node_modules' | head -10
```

### Output

Jedna linia per warstwa:
```
Entry: src/app/layout.tsx + src/app/api/*/route.ts
Routing: Next.js app router (file-based)
Service: src/services/shelters.service.ts (manual DI)
Repo:   brak — bezpośrednio Prisma client w service
DB:     Prisma + Postgres (prisma/schema.prisma)
```

Jeśli warstwy **nie ma** — zapisz "brak". Brak service layer to informacja, nie luka.

---

## 1.3 Find the analog — READ END TO END

**To jest najważniejszy krok Phase 1.** Jeśli go zrobisz dobrze, Phase 4 napisze się sama.

### Algorytm

1. Z opisu featuru wyłuskaj **2–4 słowa domenowe** (np. dla „powiadomienia push do dyżurnych KG PSP":
   `push`, `notification`, `dispatcher`, `KG`).
2. Reverse-search każdego słowa osobno — szukaj w nazwach plików i w treści.
3. Znajdź najbliższy analog — feature CRUD-owy/API-owy/UI-owy o podobnej strukturze.
4. **Przeczytaj go w całości**: route → validation → service → repo → DB → test.
5. Zanotuj wzorzec jako "primary template" w Analysis Report.

### Komendy

```bash
# Pliki
rg -l "$KEYWORD" --type ts --type tsx -g '!node_modules' -g '!dist'

# Treść + kontekst
rg -n -C 2 "$KEYWORD" --type ts -g '!node_modules' | head -50

# Katalogi featurów
ls -d src/features/*/ src/modules/*/ src/app/*/ 2>/dev/null
```

### Przykład (domena PSP)

Feature do zbudowania: "Lista schronów dostępnych w danym powiecie, filtrowana po `Dostepnosc`".

```bash
rg -l "shelter|schron|Dostepnosc" --type ts -g '!node_modules'
rg -l "powiat|voivodeship|wojewodztwo" --type ts -g '!node_modules'
```

Jeśli znajdziesz `src/features/shelters/` — czytasz go od góry do dołu:
- `routes.ts` / `route.ts` (jak wygląda HTTP handler?)
- `shelters.service.ts` (jest service? jak wywołuje repo?)
- `shelters.schema.ts` (walidacja — zod? manual?)
- `shelters.test.ts` (co już jest pokryte testem?)

Jeśli **nie ma analoga** — Blocker:

> 🛑 Nie znalazłem analoga dla "lista z filtrem po atrybucie domenowym".
> Najbliższe co widzę to `src/app/api/users/route.ts` ale to ma inny wzorzec (paginacja cursor-based
> zamiast powiatowej). Czy: (1) idziemy wzorcem users (2) czy ustalamy nową konwencję?

### Output

```markdown
## Analog featuru (PRIMARY TEMPLATE)
- Feature: `src/features/shelters/` (lista schronów, list endpoint z filtrem)
- Pliki:
  - `src/app/api/shelters/route.ts` — HTTP handler (GET z query params)
  - `src/services/shelters.service.ts` — business logic
  - `src/schemas/shelters.schema.ts` — zod validation
  - `prisma/schema.prisma` (model Shelter)
  - `tests/integration/shelters.spec.ts`
- Wzorzec CRUD: `route → zod.parse(searchParams) → service.list(filter) → prisma.findMany → res.json`
- Convention: service zwraca już zserializowaną formę (no DTO mapping layer)
```

---

## 1.4 Data model snapshot

### Komendy

```bash
# Prisma — pełny schema
[ -f prisma/schema.prisma ] && cat prisma/schema.prisma

# Drizzle
rg -n 'pgTable\(|mysqlTable\(|sqliteTable\(' --type ts -g '!node_modules' | head -20

# SQLAlchemy
rg -l 'class.*\(db\.Model\)|class.*\(Base\)' --type py | head -10

# Django
find . -name models.py -not -path '*/node_modules/*' | head -5

# Ostatnie migracje — co się zmieniało
ls -lt prisma/migrations/ alembic/versions/ migrations/ 2>/dev/null | head -15
```

### Output

```markdown
## Data model — affected
- Tabele: `Shelter`, `Powiat`, `ShelterDostepnosc` (enum)
- Relacje: `Shelter.powiatId` FK → `Powiat.id` (N:1)
- Indeks: `(powiatId, dostepnosc)` — composite (istnieje, więc filtr będzie szybki)
- Ostatnie migracje:
  - 2026-04-10 `add_dostepnosc_enum` — dodał enum
  - 2026-04-02 `add_powiat_index` — index na powiatId
  - 2026-03-18 `create_shelters`
```

---

## 1.5 Dependency impact radius — reverse search

**Cel: znaleźć pliki *poza* planowanym scope, które mogą wymagać zmian.** To jest ten moment,
w którym wyłapujesz, że dodanie pola do `Shelter` wymaga update'u frontendu, typów w API clienta,
testów integracyjnych, mocków, seedów, i być może auth middleware (jeśli pole jest chronione).

### Komendy

```bash
# Kto importuje ten moduł?
TARGET="shelters"
rg -l "from ['\"].*${TARGET}|import.*${TARGET}" --type ts -g '!node_modules'

# Kto używa tego typu/interfejsu?
rg -w -l "ShelterDto|ShelterEntity|Shelter\b" --type ts -g '!node_modules'

# Kto używa konkretnej funkcji?
rg -n "listShelters\(|getShelters\(" --type ts -g '!node_modules'

# Auth / permission checks
rg -l "requireAuth|withAuth|@UseGuards|@login_required|hasPermission" --type ts --type py -g '!node_modules'

# Seedy, fixtures, mocki
find . -path '*/seed*' -o -path '*/fixture*' -o -path '*/mock*' -not -path '*/node_modules/*' | head -10

# API client (jeśli jest osobny)
find . -type d -name 'api-client' -o -name 'sdk' -not -path '*/node_modules/*'
```

### Heurystyki co jeszcze sprawdzić

| Dotykasz | To sprawdź też |
|----------|----------------|
| Pole w modelu DB | seed, fixture, type w API clienta, testy integracyjne, Storybook stories |
| Endpoint API | frontend consumer, API docs (OpenAPI/Swagger), rate limits, auth middleware |
| Schema auth | wszystkie route'y, testy e2e logujące się, refresh token flow |
| Feature flag | dashboard flag, testy z różnymi wartościami, rollback plan |
| i18n key | wszystkie locale files, brakujące tłumaczenia na CI |

### Output

```markdown
## Dependency impact radius
Pliki poza planowanym scope które MOGĄ wymagać zmian:

**Wymagają** (włącz do planu):
- `src/types/api.ts` — `ShelterDto` musi dostać nowe pole
- `prisma/seed.ts` — seed nie ma `dostepnosc`, wywali się
- `tests/integration/shelters.spec.ts` — trzeba dopisać test filtra

**Mogą wymagać** (włącz do Out of scope lub zapytaj):
- `src/app/admin/shelters/page.tsx` — admin UI nie pokazuje `dostepnosc` — nie naprawiamy w tym planie?
- `apps/mobile-shelter-map/*` — mobile consumer — osobny release cycle

**Nie wymagają** (ale świadomie sprawdzone):
- `src/services/alarm.service.ts` — używa `Shelter` ale tylko przez `id`, bez pól
```

---

## 1.6 Tests as spec

Istniejące testy to najbardziej niedoceniane źródło wiedzy o konwencji repo.

### Komendy

```bash
# Testy dla analoga
rg -l "describe\(.*shelter|describe\(.*Schron|test\(.*shelter" --type ts -g '!node_modules'

# Przeczytaj 2–3 najbliższe
rg -l "describe\(.*shelter" --type ts -g '!node_modules' | head -3 | xargs -I{} sh -c 'echo "=== {} ==="; head -50 {}'

# Konwencje — jak są nazywane, jak są strukturyzowane
find . -type f \( -name '*.test.ts' -o -name '*.spec.ts' -o -name 'test_*.py' \) \
  -not -path '*/node_modules/*' | head -5 | xargs head -30
```

### Co wyciągnąć

- **Builder / factory pattern** — czy jest `makeShelter()` / `ShelterFactory.build()` / fixture JSON?
- **Setup / teardown** — per-test DB? transakcja rollback? fresh DB?
- **Mocki** — czy mockowane są zewnętrzne API? auth? zegar (`vi.useFakeTimers`)?
- **Assertion style** — `expect().toEqual()` czy custom matchers (`toMatchShelter`)?
- **Organizacja** — jeden `describe` per feature czy per metoda?

### Output

```markdown
## Test conventions
- Fixture: `tests/fixtures/shelters.ts` eksportuje `buildShelter({ overrides })`
- DB: per-test transakcja + rollback (`tests/helpers/db.ts::withTx`)
- Mock: `vi.mock('@/lib/auth')` dla testów niewymagających prawdziwego JWT
- Struktura: jeden `describe('shelters service')` + nested `describe` per metoda
- Naming: `"should return empty array when powiat has no shelters"` (behavior-focused)
```

---

## 1.7 Patterns catalog

Wypełniasz w formie tabelki. To się przydaje w **każdej** kolejnej fazie (Phase 2 hipotezy muszą
być zgodne z patterns, a wykonawca później odtwarza patterns w implementacji i weryfikuje je przy review AC-T).

```markdown
| Wymiar | Konwencja w tym repo | Dowód |
|--------|----------------------|-------|
| File naming | `kebab-case.ts`, komponenty `PascalCase.tsx` | `src/services/shelters.service.ts` |
| Validation | `zod` — schemy w osobnych plikach `*.schema.ts` | `src/schemas/shelters.schema.ts` |
| Error handling | throw + global error handler w route | `src/lib/error-handler.ts` |
| Response shape | `{ data, error }` dla API, raw dla SSR | `src/lib/api-response.ts` |
| Auth check | NextAuth `auth()` helper w route | `src/app/api/shelters/route.ts:L8` |
| Logging | `pino` structured logger, request-id context | `src/lib/logger.ts` |
| State (FE) | TanStack Query dla server state, Zustand dla UI state | `src/stores/` |
| DB | Prisma, service volet callu'je klient bezpośrednio | (brak repo layer) |
| i18n | `next-intl`, klucze w `messages/pl.json` | `messages/` |
| Env vars | `@t3-oss/env-nextjs` z walidacją | `src/env.mjs` |
```

---

## 1.8 Analysis Report (artefakt)

Scal wszystko z kroków 1.1–1.7 w jeden dokument. Wypisz w chacie; opcjonalnie zapisz do
`docs/plany/_analysis/PLAN_NUM-analysis.md` (użyteczne przy długich sesjach, dla audytu
w projektach PSP — ślad dlaczego wybrano dane podejście).

### Szablon

```markdown
# Analysis Report — plan #PLAN_NUM — [feature name]
Data: YYYY-MM-DD
Autor: [imię/narzędzie]

## Stack
[1-linia z 1.1]

## Architektura
Entry: [plik] → Routing: [plik/dir] → Service: [plik|brak] → Repo: [plik|brak] → DB: [ORM + silnik]

## Analog featuru (PRIMARY TEMPLATE)
[z 1.3 — feature + lista plików + wzorzec CRUD + konwencja]

## Data model — affected
[z 1.4 — tabele + relacje + indeksy + ostatnie migracje]

## Dependency impact radius
**Wymagają zmian:** [...]
**Mogą wymagać (do ustalenia):** [...]
**Sprawdzone, nie wymagają:** [...]

## Test conventions
[z 1.6 — fixture, setup, mock, struktura, naming]

## Patterns catalog
[tabela z 1.7]

## Open questions
- [pytanie] — dlaczego to blokuje Phase 2
```

### Hard rule

**Jeśli sekcja `Open questions` nie jest pusta → STOP, zadaj pytania, poczekaj na odpowiedź.**
Wejście w Phase 2 z nierozwiązanym open question = gwarantowany rework w Phase 6.

---

## Anti-patterny (nie rób)

- ❌ `ls -la && cat package.json` i pisanie hipotez. Za mało.
- ❌ Pominięcie analoga („i tak wiem jak się robi CRUD"). Każde repo ma swoje konwencje.
- ❌ „Patterns catalog" jako lista życzeń zamiast zaobserwowanych faktów (każdy wpis ma mieć *dowód* — ścieżkę do pliku).
- ❌ Pominięcie dependency impact radius dla featurów **M**/**L** — 80% bugów z review pochodzi stąd.
- ❌ Analysis Report tylko „w głowie". Nie ma go na piśmie → nie istnieje → Phase 2 robi się z domysłów.

---

## Express mode (tylko dla **S** — 1 plik, surgical)

Minimum do pominięcia:
- 1.6 (tests as spec) — pod warunkiem, że nie dotykasz żadnego pliku, który ma test
- 1.7 (patterns catalog) — pod warunkiem, że robisz naprawę w stylu już istniejącego sąsiedniego kodu

Nie pomijaj **nigdy**: 1.1, 1.2, 1.3 (analog), 1.4, 1.8 (report — choćby skrócony).

---

## Hyrum's Law Impact Analysis

> [!quote] Prawo Hyruma (`material_skill.md` §5)
> „Przy odpowiedniej liczbie użytkowników API, nie ma znaczenia, co obiecałeś w dokumentacji: wszystkie zauważalne zachowania twojego systemu zostaną przez kogoś wykorzystane."

Każde obserwowalne zachowanie publicznego API ma użytkownika — nawet to nieudokumentowane. Faza 1.5 wymusza analizę wpływu **przed** decyzją o zmianie sygnatury / zachowania.

### Procedura (Phase 1.5)

1. **Wykryj zmiany publicznych eksportów**:
   - TypeScript / JavaScript → `export function`, `export class`, `export const`, public methods klas eksportowanych.
   - Python → `def` w `__init__.py`, klasy bez `_` prefixu, wartości w `__all__`.
   - Rust → `pub fn`, `pub struct`, `pub trait`.
   - Inne → grep po konwencji języka.

2. **Klasyfikuj zmianę** według tabeli:

   | Typ | Definicja | Przykład | Wymagana akcja |
   |---|---|---|---|
   | `breaking` | zmiana sygnatury, zmiana typu zwracanego, usunięcie parametru, zmiana zachowania domyślnego | `getUser(id)` → `getUser(id, options)` z required `options` | lista callerów + plan migracji |
   | `additive` | nowa metoda, nowy opcjonalny parametr z default value, nowy eksport | dodanie `getUserAsync(id)` obok `getUser(id)` | adnotacja w `api-impact.md` |
   | `internal` | zmiana w private/protected, brak zmian publicznej powierzchni | refaktor wewnętrznej funkcji pomocniczej | brak (zwykła analiza) |

3. **Dla `breaking` — uruchom skan callerów**:
   ```bash
   bash {baseDir}/dev/planner-f/scripts/api-impact-scan.sh <symbol> <repo-root>
   ```
   Output musi zawierać: ścieżka:linia każdego wywołania w monorepo + tag czy caller jest w scope tej zmiany.

4. **Wygeneruj artefakt** `analysis/api-impact.md` (commitowany razem z planem):
   ```markdown
   # API Impact — PLAN_NUM

   ## Zmiany breaking
   | Symbol | Stary kontrakt | Nowy kontrakt | Powód |
   |---|---|---|---|
   | `getUser` | `(id: string) => User` | `(id: string, opts: Opts) => User` | wymóg AC-F-03 |

   ## Lista callerów (breaking)
   - {baseDir}/src/auth/middleware.ts:42 — w scope (zmieni się w Phase 6)
   - {baseDir}/src/admin/users.ts:128 — POZA scope (wymaga osobnego PR-a)

   ## Zmiany additive
   - `getUserAsync` — nowy eksport, brak wpływu na istniejących callerów.

   ## Decyzja
   PROCEED z migracją callerów w scope / STOP — eskalacja do team-lead.
   ```

5. **Hard gate**: jeśli sekcja „Lista callerów (breaking)" zawiera pozycje POZA scope → STOP, eskalacja, decyzja o stackingu lub rozszerzeniu planu.

### Anti-rationalization

| Wymówka agenta | Riposta |
|---|---|
| „API jest nowe, nie ma userów" | Każdy publiczny eksport ma minimum jednego callera w bieżącym repo — sprawdź `grep -r`. Brak callerów = niepotrzebny eksport, kandydat do `internal`. |
| „To tylko opcjonalny parametr, niczego nie psuje" | Zmiana default value to breaking. Dodanie required argumentu (nawet z `?`) to breaking dla callerów używających destrukturyzacji. |
| „Zachowanie nieudokumentowane, więc mogę je zmienić" | Hyrum's Law — obserwowalne zachowanie ≠ udokumentowane. Wymagana analiza wpływu. |

---

## Chesterton's Fence dla deletion

> [!quote] Płot Chestertona (`material_skill.md` §5)
> „Nie usuwaj ogrodzenia, dopóki nie zrozumiesz i nie opiszesz dokładnie, dlaczego zostało ono postawione."

Nie usuwaj kodu, którego pierwotnej funkcji nie potrafisz wyjaśnić. Pozornie martwy kod bywa cichym kontraktem, feature flagą lub workaroundem produkcyjnego incydentu.

### Procedura przed `git rm` / usunięciem funkcji / usunięciem klasy

1. **Znajdź wprowadzający commit**:
   ```bash
   git blame <ścieżka>
   git log -L :<symbol>:<ścieżka>
   git log --diff-filter=A -- <ścieżka>   # dla całego pliku
   ```

2. **Czytaj commit message + PR description**:
   - Jeśli commit ma referencję do issue/ticketu → otwórz i przeczytaj kontekst.
   - Jeśli PR description wspomina o incydencie / regresji / kompliance → kod ZOSTAJE bez głębszej analizy.

3. **Sprawdź aktywnych callerów**:
   ```bash
   grep -rn "<nazwa_symbolu>" {baseDir}/src
   grep -rn "<nazwa_symbolu>" {baseDir}/tests
   ```
   - Caller znaleziony → kod ZOSTAJE (lub plan musi obejmować refaktor callerów).
   - Brak callerów + zrozumiała funkcja → kandydat do usunięcia.
   - Brak callerów + niezrozumiała funkcja → STOP.

4. **Wygeneruj sekcję `Why this existed` w PR description**:
   ```markdown
   ## Why this code existed (Chesterton check)

   - **Symbol usuwany**: `legacyAuthFallback` (src/auth/legacy.ts)
   - **Wprowadzony**: commit `abc123` (2024-08-12) — fix dla incydentu INC-451 (OAuth provider outage).
   - **Pierwotny powód**: fallback dla 5xx z providera OAuth — wymuszał lokalną sesję.
   - **Dlaczego można usunąć**: provider OAuth ma teraz SLA 99.99% + retry middleware z Phase 6. Fallback nigdy nie był używany od 2025-01.
   - **Dowód braku użycia**: `grep -rn legacyAuthFallback {baseDir}` → 0 hitów poza testem jednostkowym; logi produkcyjne za 12 miesięcy → 0 wywołań.
   ```

5. **Hard rule**: brak sekcji `Why this existed` w PR description → review **blokuje deletion**.

6. **Eskalacja na out-of-scope**:
   - Jeśli nie potrafisz wyjaśnić → kod **ZOSTAJE**.
   - Dodaj wpis w `analysis/out-of-scope.md`:
     ```markdown
     ## TODO: Chesterton fence — niewyjaśniony kod
     - {baseDir}/src/legacy/foo.ts:120-145 — funkcja `magicNormalizer`, brak callerów, brak kontekstu w git history (squash z 2023). Wymaga rozmowy z autorem lub osobnego spike'a.
     ```

### Anti-rationalization

| Wymówka agenta | Riposta |
|---|---|
| „Nikt tego nie używa, można usunąć" | Brak callerów to konieczny, ale niewystarczający warunek. Wymagane wyjaśnienie pierwotnej funkcji. |
| „Linter mówi że dead code" | Linter widzi statyczny graf wywołań — nie widzi feature flag, dynamic imports, runtime reflection. |
| „Stary kod, na pewno do wyrzucenia" | Wiek kodu ≠ jego zbędność. Stary kod często enkoduje bardzo drogo zdobytą wiedzę o edge case'ach. |
