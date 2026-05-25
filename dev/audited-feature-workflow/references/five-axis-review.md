---
name: five-axis-review
description: Pięcioosiowy audyt kodu (Correctness, Readability, Architecture, Security, Performance) z severity labels i Change Sizing. Wywoływany w Phase 8.
type: reference
parent: audited-feature-workflow
source: 'since_skill.md §4 (Code Review & Quality)'
---

# Five-Axis Code Review

> [!important] Cel pliku
> Code review w v3 ma **strukturalne osie** — nie wolny przegląd „co mi się rzuca w oczy". Każdy finding ma oś, severity i lokalizację. Tylko Critical blokuje merge.

---

## 1. Pięć osi

Każdy PR przechodzi audyt na pięciu osiach — w kolejności poniżej. Brak skipu którejkolwiek.

### 1.1 Correctness

**Co sprawdza:**

- **Off-by-one** — pętle, range queries, slicing (`arr[0..n]` vs `arr[0..n-1]`).
- **Null safety** — opcjonale pola, `?.`, `Optional<T>`, `Maybe`, return `null` vs throw.
- **Race conditions** — współbieżny dostęp do stanu, brak locków, async w hot path.
- **Boundary conditions** — pusta lista, max int, unicode edge cases, timezone DST.
- **Zgodność ze specyfikacją AC** — 1:1 mapping plan AC → implementacja.
- **Error paths** — co się dzieje gdy fetch zawiedzie, gdy DB lock'uje, gdy user anuluje.

**Wzorzec finding:**

```text
[Correctness / Critical] {baseDir}/src/api/users.ts:42
Pętla `for (let i = 0; i <= users.length; i++)` ma off-by-one
(`<=` zamiast `<`) — produkuje `undefined` access na ostatniej iteracji.
AC-F-3 mówi: zwracaj listę o długości N, nie N+1.
```

### 1.2 Readability & Simplicity

**Co sprawdza:**

- **Kod czytany 10× częściej niż pisany** — czy nowy junior zrozumie w 30s?
- **Przedwczesne abstrakcje** — interface dla 1 implementacji, dependency injection bez 2-go consumer'a.
- **„Sprytne" optymalizacje** — bitshifty, regex 200 znaków, jednolinijki łączące 5 operacji.
- **Naming** — `data`, `info`, `process` = zła nazwa. `activeUsersCount`, `parseIsoDate` = dobra.
- **Function length** — funkcja >50 linii bez wewnętrznej struktury → split.

> [!quote] since_skill.md §4
> *Jeśli 1000 linii daje ten sam efekt co 100 — praca jest odrzucana.*

**Wzorzec finding:**

```text
[Readability / Optional] {baseDir}/src/utils/parse.ts:15-87
Funkcja `processData` ma 72 linie z 4 zagnieżdżonymi `if` i 3 anonimowymi callbackami.
Rozważ split na `validateInput` + `transformShape` + `serializeOutput` — każda 15-20 linii.
```

### 1.3 Architecture

**Co sprawdza:**

- **Duplikacje** — identyczna logika w 3 miejscach → DRY (z poszanowaniem DAMP w testach).
- **Cykliczne zależności** — moduł A importuje B, B importuje A. Tool: `madge`, `dep-cruiser`.
- **Naruszenia granic modułów** — `{baseDir}/src/api/` importuje z `{baseDir}/src/ui/`.
- **Layer leak** — komponent React wykonuje `psql` directly.
- **Shared state w nieoczekiwanym miejscu** — singleton w `utils/`, globalny mutable map.
- **Wzorce pasujące do projektu** — projekt jest event-sourcing? Nowy kod używa sync mutation? Mismatch.

**Wzorzec finding:**

```text
[Architecture / Critical] {baseDir}/src/ui/Dashboard.tsx:23
Import `from '../db/prisma'` — komponent UI sięga bezpośrednio do warstwy DB.
Łamie warstwowość: UI → API → service → DB. Wprowadź `useActiveUsers()` hook
wołający endpoint z slice 2.
```

### 1.4 Security

**Co sprawdza:**

- **Input validation** — granica zaufania. Każdy input z zewnątrz (HTTP, file, env, IPC) walidowany schemą (Zod, Pydantic, JSON Schema).
- **SQL injection** — query building przez parametry, NIGDY przez concat'y.
- **XSS** — output encoding, raw-HTML injection w React/Vue/Angular zakazany bez sanitizera (DOMPurify).
- **CSRF** — tokens na mutating endpoints.
- **Secrets scanning** — `gitleaks`, `truffleHog` na diffie. Brak `API_KEY=` w kodzie.
- **AuthZ checks** — każdy endpoint mutujący sprawdza `req.user.can(action)`.
- **OWASP Top 10** — pełny redirect do [owasp.org/Top10](https://owasp.org/Top10/). Findings mapowane na A01-A10.
- **Dependency CVE** — `npm audit --production`, `pip-audit`, `cargo audit` — exit ≠ 0 = finding.

**Wzorzec finding:**

```text
[Security / Critical] {baseDir}/src/api/users/search.ts:18 — OWASP A03 (Injection)
Query: `db.query(\`SELECT * FROM users WHERE name = '${input}'\`)` — string interpolation
w SQL. Wymagane: prepared statement z parametrami (`db.query('SELECT ... WHERE name = $1', [input])`).
```

### 1.5 Performance

**Co sprawdza:**

- **N+1 queries** — pętla po liście robi N osobnych SELECT'ów. Tool: query log inspection.
- **Niekontrolowane pętle** — `while (true)`, rekurencja bez base case na user input.
- **Brak async I/O** — `fs.readFileSync` w handlerze HTTP, sync DB call w `async` route.
- **Cache-busting** — brak memoization na drogim compute, repeated fetch tego samego URL.
- **Memory leaks** — listenery bez `removeEventListener`, globalne mapy bez TTL.
- **Bundle size (frontend)** — nowy import z `lodash` (cała biblioteka) zamiast `lodash/debounce`.

**Wzorzec finding:**

```text
[Performance / Optional] {baseDir}/src/api/users/list.ts:34
`for (const user of users) { user.profile = await db.profile.findUnique(...) }`
to klasyczne N+1 — N osobnych queries. Rozważ `db.profile.findMany({ where: { userId: { in: userIds } } })`
lub `include: { profile: true }` na top-level query.
```

---

## 2. Severity labels

| Severity | Kiedy | Akcja |
|---|---|---|
| **Critical** | Bug widoczny w prod, security hole, AC mismatch, architecture leak | **Blokuje merge.** Hard stop. |
| **Optional** | Sugestia ulepszenia, niewymagane | Niesblokujące. Możliwe do odroczenia do follow-up. |
| **Nit** | Kosmetyka (whitespace, naming preference) | Niesblokujące. Zwykle reviewer-flavor. |
| **FYI** | Kontekst dla autora (np. „w innym PR robisz X — tutaj jest podobny pattern") | Niesblokujące. Informacyjne. |

> [!warning] Tylko Critical blokuje
> Optional / Nit / FYI nie blokują merge — można je merge'ować z TODO comment lub follow-up task.

---

## 3. Change Sizing

> [!important] Twarde progi PR Sizing (since_skill.md §4)

| Diff size | Status | Wymóg |
|---|---|---|
| **~100 linii** | Optymalne | Standard review |
| **≤300 linii** | Tolerowane | Wymagane uzasadnienie w PR description (sekcja `## Why this PR is >100 lines`) |
| **>1000 linii** | **Automatyczny split** | Hard stop — agent MUSI rozbić PR na vertical slices (`references/incremental-implementation.md`) |

**Mierzenie:**

- Komenda: `git diff --stat origin/main...HEAD | tail -1` — bierzemy „N insertions(+), M deletions(-)" → `N + M`.
- Wykluczenia: generated files (lockfiles, snapshots) — odjąć od totalu.
- Skrypt: `{baseDir}/dev/audited-feature-workflow/scripts/check-pr-size.sh` (Phase 8 gate).

**Override:** w wyjątkowych przypadkach (np. mass rename via tooling, generated migration) wymagany flag `--justified` + sekcja `## Size justification` w PR.

---

## 4. Multi-Model Review Pattern

> [!important] Opcjonalny dla L-size features

**Wzorzec (since_skill.md §4):**

- **Model A** — agent budujący (główny w sesji). Optymalizowany pod implementację.
- **Model B** — niezależny review pass. Bez kontekstu sesji A.
- **Wynik** — uwagi klasyfikowane przez severity, finalna bramka u człowieka.

**Decyzja v3:** Model B = **Codex** via agent `codex-rescue` lub skill `delegate-codex`.

> [!danger] ZAKAZ Gemini
> v2 ma `ZERO Gemini` w description. v3 to dziedziczy. Multi-Model Review NIE używa `delegate-gemini` ani `mcp__claude_ai_*` opartych o Gemini. Tylko Codex.

**Trigger:**

- Feature L-size (zgodnie z matrix S/M/L w SKILL.md Phase 0.3).
- `--multi-model-review` flag eksplicytny.
- Sensytywna domena (auth, payments, crypto).

**Output Model B:** Markdown w `{baseDir}/docs/code-reviews/CR-<plan-id>-codex.md` z findings per oś + severity.

---

## 5. Wzorzec output review

> [!example] Template Markdown per oś — wypełniany w Phase 8

```markdown
# Code Review — Plan #<plan-id> — <slug>

**Reviewer:** <agent / human>
**Diff:** `git diff <FIRST_COMMIT>^..<LAST_COMMIT>` (<N> linii)
**Multi-model:** [ ] Codex pass dołączony

## Change Sizing
- Diff: <N> linii (<status: optymalne/tolerowane/auto-split>)
- Justification (jeśli >100): <treść lub „brak — w budżecie">

## Findings

### Correctness
- [Critical] {baseDir}/<plik>:<linia> — <opis> — AC ref: <AC-F-N>
- [Optional] <...>

### Readability & Simplicity
- [Optional] <...>
- [Nit] <...>

### Architecture
- [Critical] <...>
- [FYI] <...>

### Security
- [Critical] <...> — OWASP <A0X>
- [Optional] <...>

### Performance
- [Optional] <...>

## Summary
- Critical: <N>  ← merge blocked dopóki >0
- Optional: <N>
- Nit: <N>
- FYI: <N>

## Verdict
[ ] Approve (Critical = 0)
[ ] Request changes (Critical ≥ 1) — patrz findings powyżej
```

---

## 6. Integracja z fazami

| Faza | Co robi z five-axis review |
|---|---|
| **Phase 6** | Implementacja per slice — anti-rationalization check przed commit'em uwzględnia 5 osi (np. „czy dodałem input validation?" = Security pre-check). |
| **Phase 7** | Test gate dostarcza dowody dla osi Correctness (AC mapping) i Performance (load test logs jeśli L-size). |
| **Phase 8** | **Główne wywołanie** — pełen audyt 5 osi per AC. Output w `{baseDir}/docs/code-reviews/CR-<plan-id>-<slug>.md`. Severity labels stosowane konsekwentnie. Critical = hard stop. |
| **Phase 8 (L-size)** | Optional Multi-Model Review przez Codex (sekcja 4). |
| **Phase 9** | ADR dokumentuje decyzje review (jakie Critical findings naprawiono, jakie Optional odroczono do follow-up). |
