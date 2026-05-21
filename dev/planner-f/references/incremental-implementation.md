---
name: incremental-implementation
description: Thin Vertical Slices + 5-step incremental rule. Wymusza budowanie end-to-end odnogami zamiast warstwa-po-warstwie.
type: reference
parent: planner-f
source: 'since_skill.md §5 (Incremental Implementation + TDD)'
---

# Incremental Implementation

> [!important] Cel pliku
> LLM-y domyślnie generują masywne rozwiązania end-to-end albo budują warstwa-po-warstwie. Oba podejścia produkują half-merged state i blokują delivery. Reżim **Thin Vertical Slices** wymusza odwrotne podejście — wąska odnoga przez cały stos, mergowalna niezależnie.

---

## 1. Czym są Thin Vertical Slices

**Definicja:** najmniejsza wartościowa funkcjonalność przechodząca przez wszystkie warstwy systemu — DB → API → UI — w jednym, mergowalnym kawałku.

> [!example] Slice vs Layer
> Feature: „pokazuj liczbę aktywnych userów w panelu admin".
>
> ❌ **Layer-by-layer:** najpierw cała tabela `users` z 12 polami + 5 indeksów (DB), potem 8 endpointów CRUD (API), potem pełen panel admin z 10 widokami (UI). Half-merged przez tygodnie.
>
> ✅ **Vertical slice:** jedna migracja dodająca `last_active_at TIMESTAMP` + jeden endpoint `GET /admin/users/active-count` + jeden widget na dashboardzie. Cała odnoga end-to-end. Merge w jednym PR. Wartość dostarczona w 1 dzień.

**Charakterystyka slice'a:**

- **End-to-end** — od trwałości (DB) do prezentacji (UI/CLI/API response).
- **Atomic** — jeden PR, jeden review cycle, jeden deploy.
- **Reversible** — `git revert` cofa całą odnogę bez sierot w DB/API.
- **Demo-able** — user widzi wartość po merge'u.

---

## 2. Anti-pattern „Layer-by-layer build"

> [!warning] Domyślne zachowanie LLM
> Agent dostaje task „dodaj feature X", planuje:
> 1. Tydzień 1: cała warstwa DB (migracje, ORM models, fixtures).
> 2. Tydzień 2: cała warstwa API (8 endpointów + tests).
> 3. Tydzień 3: cała warstwa UI (komponenty, routing, state).

**Dlaczego to zła droga:**

- **Half-merged state** — warstwa DB w prod, API jeszcze nie ma → mertwe kolumny, niewykorzystane indeksy.
- **Integracja na końcu** — pierwsze E2E dopiero w tygodniu 3; każdy mismatch między warstwami wraca jako refaktor.
- **Brak wartości** — przez 2 tygodnie nikt nic nie widzi. Stakeholder traci zaufanie.
- **Trudny rollback** — `revert` 3 PR-ów (DB → API → UI) bez kolizji jest złożony.
- **Scope creep** — agent buduje „przy okazji" pełen CRUD nawet jeśli AC wymaga 1 odczytu.

---

## 3. 5-step incremental rule

> [!important] Per slice — w tej kolejności, bez skrótów

1. **Najprostsza logika bazowa** — minimalna implementacja realizująca AC slice'a. Bez przedwczesnych abstrakcji, bez „extension points na przyszłość".
2. **Natychmiastowy test (TDD)** — failing test PIERWSZY, potem implementacja. Commit RED → commit GREEN. Bez RED → STOP.
3. **Walidacja procesu budującego** — `pnpm build --strict` / `cargo build --warnings-as-errors` / `mypy --strict` zwraca exit 0 z 0 warnings.
4. **Commit (atomic)** — jeden commit per slice (lub para RED/GREEN). Treść commit message zawiera slice ID + AC reference.
5. **Dopiero teraz przejście do następnej slice** — żadnego „dopisanego scope'u" w bieżącej slice. Następna funkcjonalność = nowa slice = nowy cykl 5-step.

**Reguła operacyjna:** jeśli krok N zawiedzie, agent NIE przeskakuje do N+1. Naprawa kroku N lub abort slice'a.

---

## 4. Safe Defaults via Feature Flags

> [!important] Niedokończone slices za feature flagą
> Slice nie gotowa do prod = ukryta za flagą. Brak half-merged state widocznego dla użytkownika końcowego.

**Wzorzec:**

```typescript
// {baseDir}/src/feature-flags.ts
export const FLAGS = {
  newAdminActiveUsers: process.env.FF_NEW_ADMIN_ACTIVE_USERS === 'true',
} as const;

// {baseDir}/src/admin/dashboard.tsx
import { FLAGS } from '../feature-flags';

export function Dashboard() {
  return (
    <>
      <ExistingWidgets />
      {FLAGS.newAdminActiveUsers && <ActiveUsersWidget />}
    </>
  );
}
```

**Reguły:**

- Każda slice in-progress ma swój flag (default `false`).
- Flag usuwany dopiero gdy slice w 100% gotowa + observability + rollout plan.
- Slice merged behind flag = `git revert`-friendly bez touching prod behavior.
- Flag w nazwie planu i ADR (ADR — Phase 5 — dokumentuje flag lifecycle).

---

## 5. Wzorzec dla nowej funkcjonalności

> [!example] „Dodaj endpoint /users z listą aktywnych userów"

Rozbicie na slices (każda mergowalna niezależnie):

### Slice 1 — minimal DB model + migration + test

- **Co:** migracja dodająca `users.last_active_at TIMESTAMP NULL` + index.
- **Test:** integration test sprawdzający, że kolumna istnieje + index działa (`EXPLAIN` plan).
- **DoD:** `pnpm test {baseDir}/src/db/migrations/__tests__/last-active-at.spec.ts` zielony.
- **PR size target:** ~50 linii.

### Slice 2 — API endpoint (GET) + integration test

- **Co:** `GET {baseDir}/src/api/users/active.ts` zwracający `{ count: number }`.
- **Test:** integration test z seed data (3 active, 2 inactive) → expect `count: 3`.
- **DoD:** endpoint za feature flagą `FF_ACTIVE_USERS_ENDPOINT`.
- **PR size target:** ~80 linii.

### Slice 3 — UI list view + E2E test

- **Co:** widget `<ActiveUsersWidget />` na dashboardzie admin + Playwright E2E.
- **Test:** Playwright klika dashboard, asercja na widoczność liczby.
- **DoD:** widget za feature flagą `FF_ACTIVE_USERS_UI`.
- **PR size target:** ~120 linii.

**Suma:** ~250 linii w 3 mergowalnych PR-ach. Każda slice samodzielnie wnosi wartość (DB ready / API ready / user-facing).

---

## 6. Anti-pattern „extending goals"

> [!danger] Agent dodaje sobie pracy

**Co robi domyślny LLM (na etapie wykonania):**

- Task: „dodaj endpoint zwracający count aktywnych userów".
- Agent podczas wykonania doklada: pagination, filtering, sorting, bulk export, audit log, 3 dodatkowe endpointy „dla spójności".
- Wynik: PR 1500 linii, brak focus, review niemożliwy.

**Reguła:** scope z Phase 4 (plan dokument) jest **twardy**. Każde rozszerzenie wymaga:

1. STOP implementacji bieżącej slice.
2. Zapis w `{baseDir}/docs/plans/<plan-id>/out-of-scope.md` z uzasadnieniem.
3. Nowy plan / nowe uruchomienie planner-f dla rozszerzenia.

**Wykrywanie podczas wykonania (u wykonawcy):**

- Slice diff > target PR size z planu o >50% → flagujemy jako extending goals.
- Pliki dotykane poza listą z planu → flag.
- Nowe zależności (npm install / cargo add) niewspomniane w planie → flag.

---

## 7. Integracja z fazami

> [!important] W planner-f slices to artefakt PLANU, nie wykonania
> planner-f produkuje **listę slices** (rozbicie + kolejność + PR size target). 5-step rule (sekcja 3) i feature-flag code (sekcja 4) opisują, **jak wykonawca** zrealizuje każdą slice — to materiał referencyjny dla downstream, nie czynność planner-f.

| Faza | Co robi z incremental rule |
|---|---|
| **Phase 4 (planner-f)** | Plan rozbija feature na **listę thin vertical slices** (sekcja 5 wzorzec). Każda slice ma: opis, DB/API/UI komponenty, listę planowanych testów, PR size target, ew. nazwę feature flagi. |
| **Phase 6 gate (planner-f)** | `check-plan-complete.sh` odrzuca plan bez ≥1 slice lub ze slice'em >300 linii target bez uzasadnienia. |
| **Wykonawca — egzekucja** | 5-step rule per slice (sekcja 3): logika bazowa → failing test (RED) → build clean → commit atomic. Anti-rationalization przeciw „extending goals" (sekcja 6). |
| **Wykonawca — bugfix** | Prove-It Pattern: RED test reprodukujący buga → GREEN po fixie. |
| **Wykonawca — test gate** | Każda slice ≥1 zielony test w odpowiednim scope. Niedokończona slice za feature flagą (sekcja 4). |
