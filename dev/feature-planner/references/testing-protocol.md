# references/testing-protocol.md

Protokół dla Phase 7 — **Testing**. Cel: udowodnić, że implementacja spełnia *Definition of Done*
z planu, **zanim** wejdziemy w Phase 8 (Code Review). Test gate to twardy checkpoint:
nie idziemy w review z czerwonymi testami warstwy wymaganej dla danego rozmiaru featuru.

> **Zasada nadrzędna:** każdy test mapuje się na konkretny AC z Phase 8.1. Jeśli piszesz test,
> który nie mapuje się na żaden AC — masz albo brakujący AC, albo niepotrzebny test. Decyduj.

---

## 7 zakresów testów (scope-driven)

Zamiast jednej listy „warstw" pracujemy z 7 zakresami testów, które odpowiadają na różne
pytania o jakość. Dobierasz je per rozmiar featuru (S/M/L) — nie wszystkie zakresy są
sensowne dla każdej zmiany.

| # | Zakres | Pytanie na które odpowiada |
|---|--------|----------------------------|
| 1 | **Jednostkowe** (unit) | Czy działa mały kawałek kodu (funkcja, klasa, helper)? |
| 2 | **Integracyjne** | Czy elementy działają razem (route ↔ service ↔ DB, moduł ↔ moduł)? |
| 3 | **Systemowe** | Czy działa cały system end-to-end po stronie serwerowej (API contract, workflow biznesowy)? |
| 4 | **Akceptacyjne** | Czy system spełnia wymagania użytkownika / Definition of Done? |
| 5 | **E2E** | Czy działa pełna ścieżka użytkownika w przeglądarce / kliencie? |
| 6 | **Regresyjne** | Czy nowa zmiana nie zepsuła starej funkcji? |
| 7 | **Wydajnościowe + Bezpieczeństwa** | Czy system jest szybki, stabilny i odporny? |

---

## Matryca S/M/L × 7 zakresów

| Zakres | **S** (surgical) | **M** (typowy feature) | **L** (auth/DB/UI krytyczny) |
|--------|:---:|:---:|:---:|
| 1. Jednostkowe | ✅ wymagane | ✅ wymagane | ✅ wymagane |
| 2. Integracyjne | ✅ wymagane | ✅ wymagane | ✅ wymagane |
| 3. Systemowe | ⏭️ skip | ✅ wymagane | ✅ wymagane |
| 4. Akceptacyjne | ✅ (≥1 AC-F manual lub automated) | ✅ wymagane | ✅ wymagane |
| 5. E2E (Playwright Chrome) | ⏭️ skip | ✅ wymagane (golden + 1 edge) | ✅ wymagane (golden + 2–3 edge + failure) |
| 6. Regresyjne | ✅ wymagane (smoke analoga) | ✅ wymagane (suite analoga) | ✅ wymagane (pełen suite + dotknięte moduły) |
| 7. Wydajność + bezpieczeństwo | ⏭️ skip | ✅ jeśli AC-N istnieje | ✅ wymagane |

**Skip rules:**

- **Pure refactor** (zero zmiany behavior) → tylko zakresy istniejące w analogu + regresyjne.
  Nie dodawaj nowych zakresów (system, perf) jeśli baseline ich nie miał.
- **Migracja bez logiki** (rename kolumny, dodanie indexu) → integracyjne z round-trip read/write
  + regresyjne. Skip unit (brak logiki do izolowania).
- **Czysty backend bez UI** → E2E (zakres 5) = N/A (oznacz `n/a — backend-only`).
  Zamiast tego **systemowe** z prawdziwym HTTP (curl / supertest na boot serwerze) pokrywa
  całą ścieżkę.
- **Czysty frontend bez nowego API** → integracyjne ograniczone do FE composition (component
  + hook + store). Systemowe = N/A. E2E robi heavy-lifting.

---

## Definicje zakresów (w kontekście stack'u PSP)

### 1. Jednostkowe (unit)

**Co testujemy:** czystą logikę, helpery, transformacje, walidacje (zod/yup), reducery,
business rules, utility functions.
**Czego NIE testujemy:** integracji z DB, HTTP, frameworkiem, side-effectów.
**Tooling:** vitest / jest / pytest.
**Speed:** < 1s na plik. Cała suite < 30s.

```bash
# Node
npm test -- src/lib/validators/shelter.test.ts
# Python
pytest tests/unit/test_shelter_validator.py -v
```

**Wskaźnik dobrej jakości:** test izoluje SUT przez dependency injection / mock,
nie przez `vi.mock('@/db')` całych modułów.

---

### 2. Integracyjne

**Co testujemy:** boundary między warstwami w obrębie jednego serwisu — route handler
↔ service ↔ repo ↔ DB; auth middleware na konkretnym endpoincie; migracje
(round-trip read/write po migracji); CRS/topology na warstwie GIS; składanie hooków
+ store + komponentu we frontendzie.
**Tooling:** vitest + supertest / pytest + httpx / Prisma test client / @testing-library/react.
**DB:** prawdziwa baza testowa (nie mock — patrz CLAUDE.md feedback memory: integration
tests must hit a real database).

```bash
# Next.js API route + DB
npm test -- tests/integration/api/shelters.test.ts
# Migration round-trip
npm run db:test-migration
# FE composition
npm test -- tests/integration/components/shelter-form.test.tsx
```

**Wskaźnik dobrej jakości:** test pokazuje, że dwa realne moduły mówią do siebie tym samym
„językiem" (kontrakt typów + zachowanie boundary).

---

### 3. Systemowe

**Co testujemy:** cały system po stronie serwerowej jako black-box — API contract,
workflow biznesowy przechodzący przez wiele endpointów, side-effecty (queue, email, audit log),
zachowanie po restarcie. Symulujesz „prawdziwego klienta", nie testujesz wewnętrznej struktury.
**Czym różni się od integracyjnych:** integracyjne testują składowe boundaries; systemowe
testują **system jako całość zewnętrznie**, najczęściej przez HTTP API uruchomione na
realnym serwerze (lub kontenerze).
**Tooling:** supertest na bootowanym serwerze / pytest + httpx z `app.startup` /
testcontainers / docker-compose.test.yml.

```bash
# Bootowany Next.js + prawdziwa DB w testcontainers
npm run test:system
# Workflow: create shelter → publish → audit log → query history
npm test -- tests/system/shelter-lifecycle.spec.ts
```

**Wskaźnik dobrej jakości:** scenariusz przechodzi przez **≥ 2 endpointy** lub **≥ 1 side-effect**
(audit, email, queue). Single-endpoint = wciąż integracyjny.

---

### 4. Akceptacyjne

**Co testujemy:** czy system spełnia wymagania zapisane w *Definition of Done* (Phase 4)
i w **AC-F** (Phase 8.1). To są testy „od strony użytkownika biznesowego" — nie sprawdzają
wewnętrznej struktury, tylko obserwowalne zachowanie.
**Format:** Given-When-Then (mapowanie 1:1 z AC-F).
**Realizacja:** zwykle są to E2E (zakres 5) **lub** systemowe (zakres 3) **z dodatkową
adnotacją `@acceptance` i nazwą AC w opisie**. Nie potrzebujesz osobnego frameworka
(typu Cucumber) — wystarczy konwencja nazewnicza.
**Może być manualny:** dla `[MUST]` AC, których nie da się rozsądnie zautomatyzować
(np. wizualna kontrola PDF, akustyka alarmu), dopuszczalna jest **udokumentowana procedura
manualna** z checklistą, podpisana w trace matrix Phase 8.1.

```bash
# Automated acceptance (E2E z tagiem)
npx playwright test --grep "@acceptance" tests/acceptance/
# Manualna checklista
cat docs/code-reviews/manual-procedures-PLAN_NUM.md
```

**Wskaźnik dobrej jakości:** nazwa testu = subject AC-F. `it("AC-F-1: kierownik widzi listę
schronów po zalogowaniu")`, NIE `it("login works")`.

---

### 5. E2E (Playwright Chrome)

**Co testujemy:** pełną ścieżkę użytkownika w przeglądarce — od kliknięcia do efektu w UI,
łącznie z assets, network, hydratacją SSR, auth flow.
**Wymagane dla M+:** dla featurów z UI.
**Tooling:** `@playwright/test`, projekt `chromium` (stabilny CI), fixture: zalogowany
user PSP. **Cel: realny Chromium, nie webkit/firefox**, bo prod userzy używają Chromium-based
przeglądarek (Edge, Chrome).

#### 5.1 Run-mode: Playwright Chromium (preferowane)

```bash
# Zakładamy że @playwright/test + chromium są zainstalowane
npx playwright test --project=chromium tests/e2e/shelter-list.spec.ts
```

#### 5.2 Run-mode: Playwright CLI fallback (gdy brak Chromium)

Gdy `npx playwright test --project=chromium` zawodzi z `Executable doesn't exist`
(częste w piaskownicach CI / kontenerach bez headful supportu), użyj fallbacku:

```bash
# Krok 1: spróbuj zainstalować chromium przez Playwright CLI
npx playwright install chromium --with-deps 2>&1 | tee /tmp/pw-install.log

# Krok 2a: jeśli install OK → re-run normalnie
if [ $? -eq 0 ]; then
  npx playwright test --project=chromium
else
  # Krok 2b: brak praw / brak APT → użyj playwright CLI w trybie codegen/headless
  # z dowolnym dostępnym browserem (firefox / webkit zwykle dostępne w obrazach Playwright)
  AVAILABLE_BROWSER=$(npx playwright install --dry-run 2>&1 | grep -oE 'chromium|firefox|webkit' | head -1)
  echo "FALLBACK: brak Chromium, używam ${AVAILABLE_BROWSER:-firefox}"
  npx playwright test --project="${AVAILABLE_BROWSER:-firefox}"
fi
```

**Reguły fallbacku:**

1. **Test gate akceptuje fallback** — pod warunkiem że w raporcie Phase 7 wpisujesz
   *jaki* browser realnie odpalił testy (`E2E: 5 passed via firefox — chromium niedostępny`).
2. **Fallback nie zwalnia z odpalenia E2E** — brak Chromium != skip E2E.
   Lepiej zielony test na Firefox niż pominięty.
3. **Headless OK** — Playwright CLI domyślnie headless, nie potrzebujesz X server.
4. **Trace + screenshot przy failure** — `--trace=retain-on-failure --screenshot=only-on-failure`
   dają dowód do triagu nawet bez headful.
5. **Dla L (auth/DB/UI) raportuj fallback explicit do usera** — jeśli plan jest L i odpalasz
   na Firefox bo Chromium niedostępny, dodaj do raportu Phase 7 linijkę „⚠️ E2E na firefox
   (chromium niedostępny w środowisku) — Chromium-specific bugi nie zostaną złapane".

#### 5.3 Co MUSI pokrywać E2E

- **Golden path** — najważniejsza ścieżka happy z DoD.
- **1 boundary** (M) lub **2–3 boundaries** (L) — pusta lista, max length, granice paginacji.
- **1 failure** (M) lub **failure + 401/403** (L) — błędna walidacja, brak uprawnień.

```ts
// tests/e2e/shelter-list.spec.ts
test('AC-F-1 @acceptance: kierownik widzi listę schronów po zalogowaniu', async ({ page }) => {
  await loginAs(page, 'kierownik-mazowieckie');
  await page.goto('/schrony');
  await expect(page.getByRole('heading', { name: /schrony/i })).toBeVisible();
  await expect(page.getByTestId('shelter-list-item')).toHaveCount(/* > 0 */);
});
```

---

### 6. Regresyjne

**Co testujemy:** czy nowa zmiana **nie zepsuła** istniejących funkcji. To nie jest osobny
suite — to **dyscyplina uruchamiania**.
**Realizacja:** odpal wszystkie istniejące testy w modułach **dotkniętych** przez dependency
impact radius z Phase 1.5. Dla L → pełen suite repo.
**Tooling:** ten sam co inne zakresy — różnica jest w *zakresie filtrów*.

```bash
# Identify dotknięte moduły (z Analysis Report 1.5)
TOUCHED="src/lib/shelters src/app/(panel)/schrony tests/integration/shelters"

# Smoke (S): tylko wąski filtr na bezpośrednio dotkniętych plikach
npm test -- $(echo "$TOUCHED" | tr ' ' '\n' | head -1)

# Suite analoga (M): cały dotknięty moduł + jego konsumenci
npm test -- $TOUCHED

# Full repo (L): pełny suite + lint + typecheck + build
npm test && npm run typecheck && npm run lint && npm run build
```

**Wskaźnik dobrej jakości:** raport Phase 7 wymienia dokładnie *które* preexisting testy
przeszły **w obrębie dotkniętych modułów**, nie tylko „all green" bez kontekstu.

**Failed regressions handling:** jeśli regresyjny test pęka po Twojej zmianie, **to nie jest
pre-existing failure** (pre-existing wymaga commit hash dowodu sprzed zmiany). Default:
Twoja zmiana zepsuła. Fix → re-run.

---

### 7. Wydajnościowe + bezpieczeństwa

Łączne, bo dla featurów PSP zwykle zazębiają się (np. timing-based auth attack to i perf,
i security). Wymagane dla **L**, opcjonalne dla M (jeśli AC-N istnieje).

#### 7.A Wydajność

**Co testujemy:** Core Web Vitals (LCP, CLS, INP), TTFB endpointów krytycznych,
N+1 queries, bundle size, memory leaks na długich sesjach.
**Tooling:**
- **Lighthouse CI** lub `chrome-devtools-mcp:lighthouse_audit` dla LCP/CLS/INP.
- **k6 / artillery / autocannon** dla load testów backend.
- **`chrome-devtools-mcp:performance_start_trace`** dla deep tracing pojedynczego scenariusza.

```bash
# Lighthouse single-page audit
npx lighthouse https://localhost:3000/schrony --only-categories=performance --output=json

# Backend load (api shelters list)
npx autocannon -c 10 -d 30 -m GET http://localhost:3000/api/shelters

# Bundle size delta vs main
npm run build && du -sh .next/static/chunks/*.js | sort -h | tail -5
```

**AC-N targety (default dla PSP):**
- API p95 < 500ms (lokalnie), p95 < 1500ms (prod via WAN).
- LCP < 2.5s (mobile 4G).
- CLS < 0.1.
- Bundle delta < +50kB gzipped, chyba że feature L explicit dopuszcza.

#### 7.B Bezpieczeństwo

**Co testujemy:**
- **Auth & RBAC** — czy endpoint odrzuca anonimowego, czy odrzuca usera z innym powiatem,
  czy honoruje role (kierownik / oficer / podgląd).
- **Input validation** — XSS, SQLi, path traversal, prototype pollution, mass assignment.
- **Sekrety** — `git diff` nie zawiera tokenów, `.env` nie commitujemy.
- **Headers** — CSP, HSTS, X-Frame-Options dla nowych endpointów.
- **Dependency CVEs** — `npm audit --audit-level=high` / `pip-audit`.

**Tooling:**
- **`delegate-codex` (codex:rescue)** dla głębokiego security audit zmienionych plików
  — szczególnie auth middleware, query buildery, input handlery.
- **`npm audit --audit-level=high`** / **`pip-audit`** dla CVE dependencji (bramka).
- **Custom auth-matrix tests** — tabela `(user_role, endpoint, method) → expected_status`.
- **OWASP ZAP baseline** (opcjonalne dla L) — automated scan endpointów.

```bash
# Dependency CVE bramka
npm audit --audit-level=high
# Python
pip-audit --strict

# Auth matrix (przykład)
npm test -- tests/security/auth-matrix.spec.ts

# Codex security audit zmienionych plików
codex exec --context "git diff main...HEAD --name-only" \
  --task "OWASP top 10 audit zmienionych plików — szczególnie auth, queries, input handlers"
```

**AC-N targety security (PSP):**
- Zero `npm audit` high/critical (bramka twarda).
- Każdy nowy endpoint ma test 401 (anon) i 403 (cross-tenant / wrong role).
- Zero hardcoded secrets w diff (bramka twarda — `git secrets` lub `gitleaks` w CI).
- RODO: nowe pola PII oznaczone w schemacie i pokryte w `data-retention-policy.md`.

---

## Kolejność wykonania (test gate)

Lecimy w kolejności od najszybszych i najwęższych do najwolniejszych i najszerszych.
Czerwony zakres niżej w kolejności blokuje fix przed przejściem dalej.

1. **Jednostkowe (1)** — najszybsze, łapią regresje pure logic. Czerwone → fix, nie idziemy dalej.
2. **Typecheck + lint + build** — `npm run typecheck && npm run lint && npm run build`
   (lub `tsc --noEmit`, `mypy .`, `ruff check .`).
3. **Integracyjne (2)** — DB postawiona, prawdziwe boundaries.
4. **Systemowe (3)** (M+) — bootowany serwer + workflow E2E po stronie serwerowej.
5. **Akceptacyjne (4)** — sprawdź AC-F z Phase 8.1, wykonaj manualne procedury jeśli były.
6. **E2E Playwright Chrome (5)** (M+) — golden + boundaries + failure. Fallback na CLI jeśli brak Chromium.
7. **Regresyjne (6)** — suite na dotkniętych modułach (S/M) lub pełny repo (L).
8. **Perf + Security (7)** (L; M warunkowo) — Lighthouse + auth matrix + npm audit + codex security pass.

**Pełna suite (`npm test` bez filtra)** — uruchom dopiero gdy:
- Phase 6 dotknął kod współdzielony (utils/, types/, schema globalny), LUB
- konwencje repo wymagają (np. CI gate na PR), LUB
- ≥ 4 zakresy zielone i chcesz finalny smoke.

---

## Mapowanie testów na AC

W Phase 7 zbieraj nazwy testów per zadanie i per AC:

```
Zadanie 3: Filter shelters by powiat
  test::unit         — `validators/shelter-filter.test.ts::"rejects invalid powiat code"`
  test::integration  — `api/shelters.test.ts::"GET ?powiat=mazowieckie returns filtered list"`
  test::system       — `system/shelter-lifecycle.spec.ts::"create → filter → publish"`
  test::acceptance   — `e2e/shelter-list.spec.ts::"AC-F-3 @acceptance: filtruje po powiecie"`
  test::e2e          — `e2e/shelter-list.spec.ts::"selects powiat in dropdown"`
  test::regression   — `npm test -- src/lib/shelters` (12 passed)
  test::perf         — `lighthouse: LCP=1.8s (target <2.5s)`
  test::security     — `auth-matrix.spec.ts::"oficer-mazowieckie cannot read pomorskie shelters"`
```

W Phase 8.1 te `test::name` wpisujesz do **Trace matrix** (AC ↔ test). Każdy `[MUST]` musi
mieć minimum 1 mapowanie albo udokumentowaną procedurę manualną (oznaczoną `manual::`).

**Anti-pattern:** test bez nazwy zgodnej z AC (np. `it('works')`). Nazwa testu = subject AC.

---

## Reporting (format)

Po każdym zakresie raportuj zwięźle. Przykład raportu dla featuru **M**:

```text
Verification — Phase 7 (rozmiar M, plan #042):
- [1] Jednostkowe:    `npm test -- src/lib/shelter`             → 12 passed
- typecheck + lint + build:                                       → passed
- [2] Integracyjne:   `npm test -- tests/integration/shelters`  → 8 passed
- [3] Systemowe:      `npm run test:system -- shelter-lifecycle`→ 3 passed (create→publish→audit)
- [4] Akceptacyjne:   E2E grep @acceptance                       → 4 passed (AC-F-1..4)
- [5] E2E:            `npx playwright test --project=chromium`  → 6 passed (1 golden + 2 boundary + 1 failure + 2 acceptance overlap)
- [6] Regresyjne:     `npm test -- src/lib/shelters src/app/(panel)/schrony` → 27 passed (none preexisting)
- [7] Perf+Security:  AC-N istnieje → odpalono:
                       · `npm audit --audit-level=high`           → 0 high/critical
                       · Lighthouse /schrony                       → LCP 1.9s, CLS 0.04 ✅
                       · Auth matrix                               → 8 passed (401/403 wszystkie)
Test gate: ✅ wszystkie wymagane zakresy zielone → Phase 8
```

**Co MUSI być w raporcie:** komenda, wynik, istotne ostrzeżenia, oznaczenie `pre-existing`
jeśli warning był przed zmianą, **plus jaki browser** dla E2E (Chromium / fallback).

Przykład dla **S** (mniej zakresów):

```text
Verification — Phase 7 (rozmiar S, plan #043):
- [1] Jednostkowe:    `npm test -- src/lib/utils/format-date`   → 4 passed
- typecheck + lint:                                               → passed
- [2] Integracyjne:   `npm test -- tests/integration/utils`     → 2 passed
- [4] Akceptacyjne:   manual:: zweryfikowano DoD#1 — data wyświetla się w PL → ✅
- [6] Regresyjne:     `npm test -- src/lib/utils`               → 11 passed
Test gate: ✅ S-scope zielony (system/E2E/perf skipped per matrix) → Phase 8
```

---

## Failure handling

Gdy test zawiedzie:

1. **Przeczytaj failure** — full stacktrace, nie tylko ostatnia linia.
2. **Zidentyfikuj przyczynę** — czy wynika z Twojej zmiany, czy z istniejącego stanu.
3. **Fix wąski test** → rerun (`vitest run --filter`, `pytest -k`, `playwright test --grep`)
   → zielone.
4. **Re-run całego zakresu** żeby sprawdzić, czy fix nie złamał innego testu.
5. **Re-run zakresu *poprzedniego*** — jeśli fix dotknął kodu produkcyjnego, regresyjne
   poprzedniego zakresu mogły się przesunąć.
6. **Pre-existing failures** — oznacz tylko z dowodem (commit hash, gdzie weszło):
   `tests/legacy/old.test.ts: failed (pre-existing od d4a82f1, niezwiązane z planem #PLAN_NUM)`.

**Anti-pattern:** ukrywanie pre-existing failures bez dowodu. Code review wyłapie i odrzuci.

**E2E flakiness** — jeśli test E2E pęka raz na 3 runy, to flaky. Default: traktuj jako
**fail** dopóki nie zidentyfikujesz race condition (auto-wait, network mock, fixture order).
Nie zmieniaj `retries` żeby ukryć — to zostanie wyłapane w code review.

---

## Test gate — twardy checkpoint przed Phase 8

```bash
# Phase 7 closing check (przykład bash sketch — dostosuj do CI)
echo "Test gate dla planu #${PLAN_NUM} (rozmiar ${SIZE}):"
echo "  - [1] Jednostkowe:      ${UNIT_RESULT}"
echo "  - [2] Integracyjne:     ${INT_RESULT}"
echo "  - [3] Systemowe:        ${SYS_RESULT:-n/a}"
echo "  - [4] Akceptacyjne:     ${ACC_RESULT}"
echo "  - [5] E2E (${PW_BROWSER:-n/a}): ${E2E_RESULT:-n/a}"
echo "  - [6] Regresyjne:       ${REG_RESULT}"
echo "  - [7] Perf+Security:    ${PERF_RESULT:-n/a} / ${SEC_RESULT:-n/a}"

# Wymagane zawsze (dla każdego rozmiaru):
[ "$UNIT_RESULT" = "PASS" ] && [ "$INT_RESULT" = "PASS" ] \
  && [ "$ACC_RESULT" = "PASS" ] && [ "$REG_RESULT" = "PASS" ] \
  || { echo "❌ GATE BLOCKED — base scopes failing"; exit 1; }

# Wymagane dla M+:
if [ "$SIZE" != "S" ]; then
  [ "$SYS_RESULT" = "PASS" ] && [ "$E2E_RESULT" = "PASS" ] \
    || { echo "❌ GATE BLOCKED — M/L scopes failing"; exit 1; }
fi

# Wymagane dla L:
if [ "$SIZE" = "L" ]; then
  [ "$PERF_RESULT" = "PASS" ] && [ "$SEC_RESULT" = "PASS" ] \
    || { echo "❌ GATE BLOCKED — L perf/security failing"; exit 1; }
fi

echo "✅ GATE OPEN — przejście do Phase 8 (Code Review)"
```

**Brak Phase 8 dopóki gate nie otwarty.** To nie jest zalecenie — to invariant workflow.
