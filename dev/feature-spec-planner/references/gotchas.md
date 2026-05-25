---
name: gotchas
description: Auto-populating baza wiedzy projektowych anomalii (Grounding in Real Expertise). Phase 1 wykrywa, Phase 5 (ADR) deduplikuje.
type: reference
parent: feature-spec-planner
source: 'since_skill.md §6 (Grounding in Real Expertise)'
auto-populated: true
---

# Project Gotchas

> [!important] Plik samonarastający
> Ten plik **rośnie z czasem**. Każde uruchomienie feature-spec-planner w Phase 1 dokleja anomalia odkryte w analizie kodu. Phase 5 (ADR) dedupuje. Po >100 wpisach — split per moduł (`gotchas-api.md`, `gotchas-ui.md`, `gotchas-db.md`).

---

## 1. Cel pliku

LLM-y mają domyślną wiedzę o typowych wzorcach (REST, JWT, TypeScript). Brakuje im **projektowych anomalii** — rzeczy, które „w tym repo robimy inaczej". Bez tej wiedzy agent halucynuje (np. używa `email` jako klucza, podczas gdy projekt używa `userId` UUID).

**Gotchas to wiedza domenowa specyficzna dla tego repo:**

- Konwencje, których nie znajdzie w README.
- Decyzje historyczne (np. „nie używamy `enum` bo migracja w 2024 była bolesna").
- Pułapki, w które wpadli inżynierowie projektu.
- Reguły kontrintuitywne.

> [!quote] since_skill.md §6 — Grounding in Real Expertise
> Skill ma uzupełniać luki, nie powtarzać generalnej wiedzy modelu. Sekcja `Gotchas` opisuje firmowe anomalie (np. soft-delete, niestandardowe konwencje nazewnictwa).

---

## 2. Template wpisu

> [!example] Każdy wpis MUSI używać tego template'u

```markdown
## <Nazwa anomalii>
**Wykryto:** <data ISO, np. 2026-05-11>
**Lokalizacja:** {baseDir}/<ścieżka/do/pliku/lub/katalogu>
**Co:** <opis anomalii — 1-3 zdania, konkretnie>
**Why this matters:** <konsekwencja zignorowania — co się zepsuje>
**Reguła dla agenta:** <imperatyw — co agent ma robić aby uszanować anomalię>
```

**Wymagania:**

- Wszystkie 5 pól wypełnione (brak `TBD`).
- Data ISO (YYYY-MM-DD) — pozwala na decay detection (>1 rok → review czy nadal aktualne).
- Ścieżka relatywna przez `{baseDir}`, forward slashes.
- „Reguła dla agenta" w trybie rozkazującym (`Używaj X`, `Nie modyfikuj Y`).

---

## 3. Kategorie wpisów

| Kategoria | Co opisuje | Przykład |
|---|---|---|
| **Konwencje nazewnictwa** | snake_case w API vs camelCase w UI, prefixy, suffixy | „API zwraca `user_id`, UI używa `userId` — wymagany mapping w `api-client/transforms.ts`" |
| **Soft-delete patterns** | `deletedAt TIMESTAMP NULL` vs `active BOOLEAN` vs `status ENUM` | „Soft-delete przez `deleted_at`, NIE `is_active=false`. Każdy SELECT MUSI mieć `WHERE deleted_at IS NULL`" |
| **Migration gotchas** | Brakujące indeksy, locki, kolejność migracji, FK constraints | „Migracje w `prisma/migrations/` MUSZĄ dodawać index w osobnej migracji niż kolumnę (lock contention)" |
| **Test fixture quirks** | Seed data, time mocking, shared state | „Test runner używa `--randomize=false` — testy zależą od kolejności w `users.fixture.ts`" |
| **Build/deploy quirks** | Env vars, secrets, build flags, CI quirks | „`NEXT_PUBLIC_*` są inlined w build — sekrety MUSZĄ być serwerowe (`process.env.X` bez prefiksu)" |

---

## 4. Reguły utrzymania

> [!warning] Bez utrzymania ten plik puchnie i staje się bezużyteczny

**Phase 5 (ADR) dedup pass:**

1. Sortuj wpisy alfabetycznie po `## <Nazwa>`.
2. Wykryj duplikaty (taka sama lokalizacja + opis) → merge.
3. Wykryj stale entries (data >12 miesięcy + brak modyfikacji pliku z lokalizacji) → flag `[STALE?]` do review.
4. Jeśli >100 wpisów → split per moduł:
   - `gotchas-api.md` — backend / API conventions.
   - `gotchas-ui.md` — frontend / komponenty.
   - `gotchas-db.md` — schema, migracje, queries.
   - `gotchas-infra.md` — CI/CD, deploy, env vars.

**Phase 1 add pass:**

1. Po analizie projektu — dopisek do `## <Nowa anomalia>`.
2. Wpis zawsze pełen 5 pól (sekcja 2 template).
3. Lokalizacja zweryfikowana (`test -e {baseDir}/<ścieżka>`).

**Maintenance commands:**

```bash
# Liczba wpisów
grep -c '^## ' {baseDir}/dev/feature-spec-planner/references/gotchas.md

# Sortowanie alfabetyczne (manual review przed apply)
awk '/^## /{print NR":"$0}' {baseDir}/dev/feature-spec-planner/references/gotchas.md

# Stale check (wpisy >12 miesięcy)
grep -E '\*\*Wykryto:\*\* 202[0-4]-' {baseDir}/dev/feature-spec-planner/references/gotchas.md
```

---

## 5. Przykładowe wpisy (placeholders)

> [!important] Poniższe 3 wpisy są szablonowe — Phase 1 feature-spec-planner zastępuje je realnymi anomalia z projektu.

## Soft-delete via deleted_at (PLACEHOLDER)
**Wykryto:** 2026-05-11
**Lokalizacja:** {baseDir}/src/db/schema.prisma
**Co:** Wszystkie tabele biznesowe (users, orders, products) używają `deleted_at TIMESTAMP NULL` zamiast hard DELETE. Brak `is_active` boolean.
**Why this matters:** SELECT bez `WHERE deleted_at IS NULL` zwraca tombstones — niezgodność z business logic, potencjalny data leak do audit log.
**Reguła dla agenta:** Każdy nowy SELECT od strony aplikacji MUSI zawierać `WHERE deleted_at IS NULL` lub używać middleware'u `softDeleteFilter` z `{baseDir}/src/db/middleware/`.

## API snake_case vs UI camelCase (PLACEHOLDER)
**Wykryto:** 2026-05-11
**Lokalizacja:** {baseDir}/src/api-client/transforms.ts
**Co:** Backend (REST API) zwraca pola w `snake_case` (`user_id`, `created_at`). Frontend używa `camelCase` (`userId`, `createdAt`). Konwersja przez `transformResponse()` w `api-client`.
**Why this matters:** Nowy endpoint bez przejścia przez `transformResponse` → mismatched fields w UI → null reference errors.
**Reguła dla agenta:** Wszystkie nowe wywołania API MUSZĄ używać `apiClient.get/post()` z `{baseDir}/src/api-client/` — direct `fetch()` zakazany.

## Migracje: kolumna + index w osobnych krokach (PLACEHOLDER)
**Wykryto:** 2026-05-11
**Lokalizacja:** {baseDir}/prisma/migrations/
**Co:** Dodanie kolumny i utworzenie indeksu na niej w jednej migracji powoduje lock contention na dużych tabelach (>1M wierszy). Konwencja projektu: 2 osobne migracje (`add-column`, potem `add-index`).
**Why this matters:** Single-migration deploy na prod tabeli `events` (~50M wierszy) w 2025 spowodował 45-minutowy lock i incydent SEV2.
**Reguła dla agenta:** Każda migracja dodająca indeks na świeżej kolumnie MUSI być w osobnym plikum migration. `CREATE INDEX CONCURRENTLY` (Postgres) jeśli możliwe.

---

## 6. Integracja z fazami

| Faza | Co robi z gotchas.md |
|---|---|
| **Phase 1 (feature-spec-planner)** | **Add pass** — po analizie kodu/struktury projektu wykrywa nowe anomalia i dopisuje wpisy (sekcja 2 template). Lokalizacje weryfikowane (`test -e`). |
| **Phase 4 (feature-spec-planner)** | Plan referencyjnie wskazuje gotchas relewantne dla feature'a (sekcja `Relevant gotchas`, np. „dotyczy soft-delete — patrz gotchas.md#soft-delete-via-deleted_at"). |
| **Phase 5 (feature-spec-planner, ADR)** | **Dedup pass** — sekcja 4 reguły utrzymania. Sortowanie, merge duplikatów, flag stale, ewentualny split per moduł przy >100 wpisach. |
| **Wykonawca** | Anti-rationalization quick-check przed commitem oraz review (oś Architecture) sprawdzają, czy implementacja respektuje gotchas wymienione w planie — poza zakresem feature-spec-planner. |
