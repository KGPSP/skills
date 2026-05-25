---
name: ac-protocol
type: reference
parent: audited-feature-workflow
sources:
  - dev/feature-planner v2 baseline
  - DOC/material_skill.md §5 (Beyoncé Rule — 1:1 AC↔Test mapping)
description: Acceptance Criteria derivation (F/N/C), AC↔DoD mapping, SMART rules, Trace matrix. v3 dokleja Beyoncé Rule 1:1 enforcement (każdy AC ma test).
---

# references/ac-protocol.md

Protokół dla Phase 8.1 — **Derive Acceptance Criteria** (kryteria satysfakcji / warunki odbioru).
Cel: zamienić „Definition of Done" z planu na **binarnie weryfikowalne** warunki, do których
dążymy i na podstawie których Phase 8 wydaje werdykt.

> **Zasada nadrzędna:** AC nie jest listą życzeń. AC to kontrakt. Każdy punkt ma być taki,
> że po przeczytaniu można jednoznacznie powiedzieć: spełnione albo nie.

---

## Dlaczego AC a nie sama Definition of Done?

**Definition of Done** (w planie) jest user-facing: co się dzieje, co widzi tester.
**AC** jest review-facing: jak technicznie udowodnić, że DoD jest spełnione.

| DoD (Phase 4) | AC (Phase 8.1) |
|---------------|-----------------|
| „Użytkownik widzi listę schronów w swoim powiecie" | `AC-F-1 [MUST]: GET /api/shelters?powiat=mazowieckie zwraca 200 + array z polami {id, name, dostepnosc}, odfiltrowany do powiecie mazowieckim, posortowany po `name` ASC, max 100 pozycji bez paginacji` |
| „Działa szybko" | `AC-N-1 [SHOULD]: p95 latency < 500ms dla zapytania zwracającego 100 schronów (measured: k6 smoke test, 50 rps, 60s)` |

DoD „czuje się dobre", AC „da się sprawdzić checkiem zielonym/czerwonym".

---

## Trzy kategorie AC

### AC-F — Funkcjonalne

**Czym jest:** to co *użytkownik* (lub *consumer API*) może zrobić i co za to dostaje.
**Skąd:** z sekcji *Definition of Done* w planie.
**Format:** Given-When-Then.

### AC-T — Techniczne

**Czym jest:** poprawność na poziomie kodu — zgodność z patterns catalog, poprawna obsługa błędów,
odpowiednie typowanie, brak antywzorców specyficznych dla tego repo.
**Skąd:** z sekcji *Zadania* + z *Patterns catalog* (Analysis Report 1.7).
**Format:** zdanie twierdzące + plik/ścieżka do weryfikacji.

### AC-N — Niefunkcjonalne

**Czym jest:** performance, bezpieczeństwo, accessibility, compliance, observability.
**Skąd:** z kontekstu projektu — dla PSP: RODO, WCAG 2.1 AA (gdziesieukryc.pl, mLegitymacja),
wymagania ABW/KRI (SKR-Z, CEZOL), PZP dla zamówień.
**Format:** mierzalna liczba / konkretny standard / checklist pozycja.

---

## Quality bar — każdy AC musi być (SMART-like)

| Kryterium | Co znaczy | Anti-przykład |
|-----------|-----------|----------------|
| **Testable** | Istnieje binarny check — test lub procedura manualna | ❌ „Powinno być intuicyjne" |
| **Specific** | Konkretne liczby, ścieżki, warunki | ❌ „Szybkie", „łatwe", „dobre UX" |
| **Traceable** | Mapuje się na *DoD #n* / *Zadanie #n* / *Założenie #n* z planu | ❌ „Ogólnie lepsza wydajność" |
| **Independent** | Jedna troska per AC — nie łączymy | ❌ „Zwraca listę ORAZ szybko ORAZ po auth" |

Jeśli AC nie przechodzi któregokolwiek z 4 checków → przepisz albo wyrzuć.

---

## Priorytety (MoSCoW)

| Priorytet | Znaczenie | Konsekwencja |
|-----------|-----------|--------------|
| `[MUST]` | Niespełnienie = **nie można mergować** | Phase 8 wydaje FIX-FIRST |
| `[SHOULD]` | Niespełnienie = można mergować, ale **nie można zamknąć planu ADR-em** | Phase 9 zablokowana |
| `[COULD]` | Nice-to-have, trafia do backlogu jako follow-up | Bez wpływu na workflow |

**Rule of thumb:** happy path + failure paths = MUST. Perf, accessibility, observability = SHOULD
(chyba że feature jest stricte perf-critical — wtedy MUST). Refactor okolicy, dodatkowe typy = COULD.

---

## Minimum coverage per feature

Niezależnie od rozmiaru (S/M/L), minimum:

1. **1× Happy path** `[MUST]` — podstawowe scenario działa
2. **1× Boundary** `[MUST]` lub `[SHOULD]` — puste dane / max rozmiar / znaki specjalne / granica paginacji
3. **1× Failure** `[MUST]` — co ma się wywalić i jak (status, komunikat)
4. **1× Non-regression** `[MUST]` — **jeśli** dotykasz istniejącego kodu; co się NIE ma zepsuć

Dla **M**/**L** dodajesz jeszcze AC-N (min. 1× perf + 1× security/authz jeśli dotyczy).

---

## Szablony

### AC-F — Given-When-Then

```markdown
### AC-F-1 [MUST] — [Tytuł, czasownik + dopełnienie]
**Mapuje na:** DoD #1
**Given:** [precondition — stan systemu, użytkownik, dane]
**When:** [akcja / request / event]
**Then:**
- [obserwowalny outcome 1 — konkretny]
- [obserwowalny outcome 2]
- [negatywny outcome — czego NIE powinno być]
**Verified by:** `tests/integration/shelters-list.spec.ts::"filters by powiat"`
```

### AC-T — twierdzenie + dowód

```markdown
### AC-T-1 [MUST] — Route używa zod do walidacji query params
**Mapuje na:** Zadanie #2, Patterns catalog (Validation = zod)
**Stwierdzenie:** `src/app/api/shelters/route.ts` importuje schema z `src/schemas/shelters.schema.ts`
i wywołuje `.parse()` przed business logic.
**Weryfikacja:** grep + manualny review diff.
```

### AC-N — mierzalny standard

```markdown
### AC-N-1 [SHOULD] — Performance: p95 < 500ms dla listy 100 schronów
**Mapuje na:** Założenie #3 („filtr po powiat będzie szybki bo jest index")
**Target:** p95 < 500ms
**Measurement:** k6 script, 50 rps, 60s ramp-up, prod-like data (10k schronów w Postgres)
**Tool:** `scripts/perf/shelters-list.js`
**Verified by:** manual run + zapis wyniku w `docs/code-reviews/CR-PLAN_NUM-perf.md`
```

---

## Kategorie scenariuszy (pokrycie)

Planując AC-F, przejdź przez cztery kategorie — każda zasługuje na ≥1 AC (jeśli dotyczy):

### Success (happy path)
Podstawowe, oczekiwane scenario. *„User A wykonuje X, widzi Y."*

### Boundary (edge cases)
- Puste dane (0 wyników)
- Maksimum (10 000 pozycji, limit 100)
- Znaki specjalne (polskie ogonki, cudzysłowy, emoji w wyszukiwaniu)
- Granice paginacji (strona pierwsza, ostatnia, poza zakresem)
- Jednoczesne requesty (race condition)

### Failure (negatywne)
- Brak autoryzacji → 401
- Brak uprawnień → 403
- Zasób nie istnieje → 404
- Niepoprawne dane wejściowe → 400 + konkretny komunikat błędu
- Błąd bazy danych → 500 + log w strukturalnym formacie, BEZ wycieku PII

### Non-regression
- „Istniejący endpoint `/api/shelters/:id` dalej zwraca 200 i pełny obiekt"
- „Trigger SOIA-ALERT nie zależy od nowego pola i dalej działa"
- „Frontend admin nie wywali się na nowym polu (dostaje je ale ignoruje)"

---

## NFR checklist dla kontekstu PSP (AC-N)

Dla projektów PSP/civil protection — standardowe wymiary do rozważenia. **Nie każdy dotyczy każdego
featuru** — zaznacz N/A jeśli nie dotyczy, ale jawnie.

### Bezpieczeństwo
- [ ] **Authz** — każdy endpoint ma zdefiniowaną rolę wymaganą (anonimowy / dispatcher / admin KG / admin KP)
- [ ] **Input validation** — wszystkie inputy przez zod/pydantic (nie surowe `req.body`)
- [ ] **SQL injection** — używany ORM / prepared statements (nie string concat)
- [ ] **XSS** — escape w renderingu (React domyślnie OK, ale `dangerouslySetInnerHTML`?)
- [ ] **Rate limiting** — endpointy publiczne (mapa schronów) mają limit per IP
- [ ] **Secrets** — żadne hardcoded API keys, tokeny, hasła w kodzie ani w logach

### RODO / Ochrona danych osobowych
- [ ] **Minimizacja** — endpoint zwraca tylko pola potrzebne do featuru (nie `SELECT *`)
- [ ] **Retencja** — dane z audytu mają politykę usuwania (jeśli dotyczy)
- [ ] **Audyt dostępu** — dostęp do danych osobowych jest logowany (kto, kiedy, co)
- [ ] **Prawo do zapomnienia** — jeśli dotyczy użytkowników, usuwanie kaskadowe / anonimizacja

### WCAG 2.1 AA (dla UI — gdziesieukryc.pl, mLegitymacja, dashboardy)
- [ ] **Kontrast** — min. 4.5:1 dla tekstu normalnego, 3:1 dla dużego
- [ ] **Klawiatura** — wszystkie interakcje dostępne z klawiatury (Tab, Enter, Esc)
- [ ] **Screen reader** — `aria-label` / `alt` / `role` dla interaktywnych elementów
- [ ] **Focus visible** — focus ring widoczny, nie ukryty CSS-em
- [ ] **Color not only** — informacja nie przekazywana tylko kolorem (czerwony = błąd + ikona)

### Performance
- [ ] **API latency** — p95 < [target]ms dla typowego payloadu
- [ ] **DB query** — brak N+1, widoczne `EXPLAIN ANALYZE` dla kwerend nad tabelami >10k wierszy
- [ ] **Bundle size** (FE) — wzrost < [X]kb dla nowego route'u
- [ ] **Memory** — brak leaków (jeśli long-running service: ALARM-PL, matrix.straz.gov.pl)

### Observability
- [ ] **Logi** — strukturalne (JSON), z `request-id` dla trace'owania, bez PII
- [ ] **Metryki** — counter requestów + histogram latency (Prometheus format jeśli stack ma)
- [ ] **Alerty** — zdefiniowany threshold dla critical errorów (if applicable)
- [ ] **Error tracking** — błędy trafiają do Sentry / analogicznego (jeśli podpięte)

### Compliance (jeśli dotyczy)
- [ ] **PZP** — jeśli endpoint udostępnia dane objęte zamówieniem publicznym, ślad w OPZ/SWZ
- [ ] **KRI** — Krajowe Ramy Interoperacyjności — format danych zgodny ze standardami (np. GML dla GIS)
- [ ] **ABW accreditation** — dla systemów klasyfikowanych (SKR-Z, CEOZO) — brak wycieków do warstw jawnych

---

## Kompletny przykład — feature „Lista schronów w powiecie"

```markdown
# AC-042 — Lista schronów w powiecie

## Kontekst
Plan: `docs/plany/042-shelters-powiat-filter.md`
Rozmiar: M
Autor AC: [imię]
Data: 2026-04-23

---

## AC-F (Funkcjonalne)

### AC-F-1 [MUST] — Lista schronów filtrowana po powiecie
**Mapuje na:** DoD #1, Zadanie #3
**Given:** w bazie są 3 schrony w powiecie mazowieckim i 2 w świętokrzyskim
**When:** `GET /api/shelters?powiat=mazowieckie`
**Then:**
- HTTP 200
- Response shape: `{ data: Shelter[], total: number }`
- `data.length === 3`
- Każdy element ma pola: `id`, `name`, `dostepnosc`, `powiatSlug`
- Wszystkie elementy mają `powiatSlug === "mazowieckie"`
- Posortowane po `name` ASC
**Verified by:** `tests/integration/shelters-list.spec.ts::"filters by powiat"`

### AC-F-2 [MUST] — Pusta lista dla nieznanego powiatu
**Mapuje na:** DoD #1 (boundary)
**Given:** brak schronów dla `powiat=nieistniejacy`
**When:** `GET /api/shelters?powiat=nieistniejacy`
**Then:** HTTP 200, `{ data: [], total: 0 }`
**Verified by:** `tests/integration/shelters-list.spec.ts::"returns empty for unknown powiat"`

### AC-F-3 [MUST] — 400 dla brakującego parametru
**Mapuje on:** DoD #2 (failure)
**Given:** request bez query param
**When:** `GET /api/shelters`
**Then:** HTTP 400, body zawiera `{ error: { code: "MISSING_PARAM", param: "powiat" } }`
**Verified by:** `tests/integration/shelters-list.spec.ts::"requires powiat param"`

### AC-F-4 [MUST] — Non-regression: endpoint `/api/shelters/:id` działa
**Mapuje na:** Założenie #2
**Given:** istnieje schron id=123
**When:** `GET /api/shelters/123`
**Then:** HTTP 200, zwraca pełny obiekt (jak przed zmianą)
**Verified by:** `tests/integration/shelters-get.spec.ts` (istniejące testy passują)

---

## AC-T (Techniczne)

### AC-T-1 [MUST] — Walidacja przez zod
**Stwierdzenie:** `src/app/api/shelters/route.ts` importuje `sheltersListQuerySchema` z
`src/schemas/shelters.schema.ts` i wywołuje `.safeParse()` przed logiką.
**Zgodność z patterns catalog:** Validation = zod (pozycja z Analysis Report 1.7)

### AC-T-2 [MUST] — Brak N+1 w query
**Stwierdzenie:** W service `listShelters()` używa jednej kwerendy `prisma.shelter.findMany({where, orderBy})`,
bez pętli z zapytaniami per element. Weryfikacja: Prisma query log w teście integracyjnym.

### AC-T-3 [SHOULD] — Response shape zgodny z konwencją
**Stwierdzenie:** Endpoint zwraca `{ data, total }` zamiast `{ shelters }` — zgodnie z
`src/lib/api-response.ts::listResponse()` (wzorzec z analog /api/users).

---

## AC-N (Niefunkcjonalne)

### AC-N-1 [SHOULD] — Performance p95 < 500ms
**Target:** p95 < 500ms dla request zwracającego 100 schronów
**Measurement:** `scripts/perf/shelters-list.js` (k6, 50 rps, 60s)
**Dataset:** 10k schronów w bazie (seed `scripts/seed/shelters-10k.ts`)
**Verified by:** manual run, wynik w `docs/code-reviews/CR-042-perf.md`

### AC-N-2 [MUST] — Authz: dostęp publiczny BEZ autoryzacji
**Uzasadnienie:** gdziesieukryc.pl jest publiczne — obywatel musi mieć dostęp bez logowania
**Stwierdzenie:** Route NIE ma `auth()` middleware. Test integracyjny wywołuje bez tokenu i dostaje 200.
**Verified by:** `tests/integration/shelters-list.spec.ts::"anonymous access allowed"`

### AC-N-3 [MUST] — Rate limit 60 req/min per IP
**Target:** 60 requests/min per IP, przy przekroczeniu → 429 z `Retry-After`
**Mechanism:** middleware z `src/lib/rate-limit.ts` (istniejący, używany przez /api/map-tiles)
**Verified by:** test manualny + smoke test w staging

### AC-N-4 [MUST] — Minimum danych (RODO)
**Stwierdzenie:** Response nie zawiera: `adresDokladny` (tylko powiatSlug), `osobaKontaktowa`,
`telefonKontaktowy`. Response ma: `name`, `id`, `dostepnosc`, `lokalizacjaPrzyblizona` (lat/lng zaokrąglone).
**Verified by:** snapshot testu + manualny review schematu response.

---

## Trace matrix

| AC | Priorytet | Test / Procedura | Status |
|----|-----------|------------------|--------|
| AC-F-1 | MUST | `shelters-list.spec.ts::"filters by powiat"` | ⏳ |
| AC-F-2 | MUST | `shelters-list.spec.ts::"returns empty..."` | ⏳ |
| AC-F-3 | MUST | `shelters-list.spec.ts::"requires powiat..."` | ⏳ |
| AC-F-4 | MUST | `shelters-get.spec.ts` (istniejące) | ⏳ |
| AC-T-1 | MUST | grep + review | ⏳ |
| AC-T-2 | MUST | query log w test + review | ⏳ |
| AC-T-3 | SHOULD | review | ⏳ |
| AC-N-1 | SHOULD | k6 manual run | ⏳ |
| AC-N-2 | MUST | `shelters-list.spec.ts::"anonymous..."` | ⏳ |
| AC-N-3 | MUST | smoke test manual | ⏳ |
| AC-N-4 | MUST | snapshot test | ⏳ |

Legenda: ⏳ pending · ✅ PASS · ❌ FAIL · ⚠️ PARTIAL
```

---

## Sign-off protocol (Phase 8.4)

Po code review trace matrix dostaje werdykt per AC. Warunki zamknięcia:

| Warunek | Czy spełniony? |
|---------|----------------|
| Wszystkie AC `[MUST]` = ✅ PASS | **wymagane dla merge** |
| Wszystkie AC `[SHOULD]` = ✅ PASS lub jawne PARTIAL z uzasadnieniem | **wymagane dla ADR** |
| Wszystkie AC `[COULD]` | nie blokuje, loguje się do backlogu jako follow-up |

Jeśli `SHOULD` zostaje `PARTIAL` — musi być wpis w ADR (Phase 9) z uzasadnieniem czemu i kiedy zostanie domknięte.

---

## Anti-patterny (nie rób)

- ❌ **AC bez testu** — „sprawdzone ręcznie" to nie weryfikacja. Albo test, albo spisana procedura manualna z krokami.
- ❌ **AC łączone** — „endpoint zwraca listę, szybko, z auth" = 3 AC, nie 1.
- ❌ **AC bez priorytetu** — bez MUST/SHOULD/COULD nie wiadomo co blokuje co.
- ❌ **AC-N jako „powinno być szybkie"** — zawsze liczba + metoda pomiaru.
- ❌ **AC pisane po implementacji** — AC dokumentuje intencję planu, nie fakty po fakcie. Piszesz je na początku Phase 8, nie na końcu.
- ❌ **Brak non-regression** gdy dotykasz istniejącego kodu — to najczęstsze źródło produkcyjnych bugów.
- ❌ **AC dla rzeczy nie w planie** — AC odzwierciedla plan; jeśli dodajesz coś czego nie było w planie, to najpierw zmieniasz plan.

---

## Quick reference

```
AC = kontrakt weryfikowalny, nie lista życzeń
Kategorie:   AC-F (funkcjonalne) | AC-T (techniczne) | AC-N (niefunkcjonalne)
Priorytety:  MUST (blokuje merge) | SHOULD (blokuje ADR) | COULD (backlog)
Quality:     Testable, Specific, Traceable, Independent
Minimum:     1× happy + 1× boundary + 1× failure (+ 1× non-regression jeśli dotykasz)
Format F:    Given-When-Then + Verified by
Format T:    Stwierdzenie + plik/linia + zgodność z patterns catalog
Format N:    Target (liczba/standard) + Measurement (jak) + Tool
Output:      docs/code-reviews/AC-PLAN_NUM-[name].md z sekcjami F/T/N + Trace matrix
Gate:        wszystkie MUST = PASS przed merge, wszystkie SHOULD = PASS/PARTIAL-z-uzasadnieniem przed ADR
```

---

## Beyoncé Rule — 1:1 AC ↔ Test Mapping

> [!quote] Zasada Beyoncé (`material_skill.md` §5)
> „If you liked it, you should have put a test on it." — Zmiana bez testu jest długiem technologicznym. Infrastruktura nie wyłapuje bugów — robią to wyłącznie testy.

Każdy AC z planu (Phase 4) MUSI mieć przypisany konkretny test. Brak testu = brak weryfikacji = AC traktowany jako niezrealizowany.

### Wymóg Phase 4 — tabela mapowania AC → Test

Plan w Phase 4 zawiera obowiązkową sekcję `## AC Coverage Matrix`:

```markdown
## AC Coverage Matrix

| AC ID | Typ | Priorytet | Test ID | Plik testu | Komenda uruchamiająca |
|---|---|---|---|---|---|
| AC-F-01 | Functional | MUST | `health endpoint returns 200` | `{baseDir}/tests/health.test.ts:42` | `pnpm test health` |
| AC-F-02 | Functional | MUST | `returns 503 when DB down` | `{baseDir}/tests/health.test.ts:78` | `pnpm test health` |
| AC-N-01 | Performance | SHOULD | `health p95 < 100ms @ 100rps` | `{baseDir}/perf/health.spec.ts` | `pnpm test:perf` |
| AC-T-01 | Constraint (typecheck) | MUST | `tsc strict` | `{baseDir}/tsconfig.json` | `pnpm tsc --noEmit` |
| AC-T-02 | Constraint (lint) | MUST | `eslint --max-warnings 0` | `{baseDir}/.eslintrc.cjs` | `pnpm lint` |
```

Kolumny obowiązkowe:
- **AC ID** — pełny identyfikator z sekcji AC-F / AC-T / AC-N (np. `AC-F-01`, nie „pierwszy").
- **Typ** — Functional / Performance / Security / Constraint (typecheck/lint/build).
- **Priorytet** — MUST / SHOULD / COULD (przenosi się z AC).
- **Test ID** — nazwa test case'a (jak czyta się w outpucie testera) **lub** nazwa command outputu (`tsc strict`, `eslint --max-warnings 0`).
- **Plik testu** — absolutna ścieżka z `{baseDir}` + linia (gdy test jednostkowy).
- **Komenda** — komenda dokładnie wpisywana w terminalu (kopiowalna).

### Phase 7 — coverage check

Phase 7 weryfikuje matrix przed otwarciem gate:

```bash
bash {baseDir}/dev/audited-feature-workflow/scripts/check-ac-coverage.sh {baseDir}/docs/plany/PLAN_NUM-*.md
```

Output skryptu:
- ✅ `AC-F-01 → tests/health.test.ts:42` — found, executable.
- ❌ `AC-N-02 → BRAK TESTU` — STOP w Phase 7.

**Hard rule**: brak testu na MUST AC → gate **zamknięty**, powrót do Phase 6 (implementacja brakującego testu) lub Phase 4 (przeklasyfikowanie AC na SHOULD/COULD z uzasadnieniem).

### Edge case — AC-N (non-functional) bez testu

Niektóre AC-N są niemożliwe do zautomatyzowania (np. „zgodność wizualna ze stylem PSP", „brak regresji UX dla screen readerów na NVDA"). Dla nich wymagana jest jawna procedura manualnej weryfikacji:

```markdown
| AC-N-03 | Accessibility | SHOULD | `manual: NVDA navigation` | `docs/manual-tests/AC-N-03.md` | (manualna procedura) |
```

A w `docs/manual-tests/AC-N-03.md`:

```markdown
# AC-N-03 — NVDA navigation

## Verification: manual
1. Uruchom Windows 11 + NVDA 2025.x.
2. Otwórz {baseDir}/preview w Firefox 130.
3. Tab → Tab → Tab — czy NVDA czyta etykiety przycisków?
4. Enter na przycisk „Wyślij" — czy NVDA potwierdza akcję?

## Dowód (Phase 7)
- Screenshot terminala NVDA log: `{baseDir}/docs/manual-tests/evidence/AC-N-03.png`
- Nagranie: `{baseDir}/docs/manual-tests/evidence/AC-N-03.mp4`
```

Brak dowodu (screenshot/nagranie/log) → AC-N traktowane jak brak testu = gate **zamknięty**.

### Anti-rationalization

| Wymówka agenta | Riposta |
|---|---|
| „AC-N jest jakościowy, nie da się go zmierzyć" | Każdy AC musi mieć kryterium akceptacji w liczbach lub w procedurze manualnej z artefaktem. „Jakościowy" = niepełny AC. |
| „Test pokrywa wiele AC naraz, jeden wpis wystarczy" | 1:1 mapping — jeden AC, jedna pozycja w matrix. Ten sam test może wystąpić w kolumnie „Test ID" wielokrotnie (różne AC) — to OK, ale każdy AC ma własny wiersz. |
| „Test napiszę w Phase 6, na razie zostawiam pole puste" | Coverage matrix powstaje w Phase 4. Pusty wpis = STOP. Jeśli nie wiesz jakim testem zweryfikujesz AC, AC jest źle zdefiniowany. |
