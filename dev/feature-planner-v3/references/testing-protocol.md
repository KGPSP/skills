---
name: testing-protocol
type: reference
parent: feature-planner-v3
sources:
  - dev/feature-planner v2 baseline
  - DOC/material_skill.md §5 (DAMP over DRY, Beyoncé Rule)
  - DOC/since_skill.md §5 (Prove-It Pattern, raw log requirement)
description: Phase 7 testing — 7 scopes × S/M/L matryca, E2E Playwright tiers 1-4, test gate sequencing. v3 dokleja DAMP checklist, raw log requirement i Prove-It Pattern dla bugfix.
---

# references/testing-protocol.md

Protokół dla Phase 7 — **Testing**. Cel: udowodnić, że implementacja spełnia *Definition of Done*
z planu, **zanim** wejdziemy w Phase 8 (Code Review). Test gate to twardy checkpoint:
nie idziemy w review z czerwonymi testami zakresu wymaganego dla danego rozmiaru featuru.

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

> **Akceptacyjne to *etykieta zakresu*, nie osobny suite.** Ten sam plik testowy może wystąpić
> w trace matrix dwa razy — raz pod `test::acceptance` (gdy waliduje konkretny AC-F), raz pod
> `test::e2e` (gdy testuje boundary/failure niepowiązany 1:1 z żadnym AC-F). Przykład: jeden
> `shelter-list.spec.ts` zawiera 4 testy `@acceptance` (AC-F-1..4) i 2 testy edge case'ów
> bez tagu — w raporcie liczone osobno, w trace matrix mapowane różnymi prefiksami.

---

### 5. E2E (Playwright Chrome)

**Co testujemy:** pełną ścieżkę użytkownika w przeglądarce — od kliknięcia do efektu w UI,
łącznie z assets, network, hydratacją SSR, auth flow.
**Wymagane dla M+:** dla featurów z UI.
**Tooling:** `@playwright/test`, projekt `chromium` (stabilny CI), fixture: zalogowany
user PSP. **Cel: realny Chromium, nie webkit/firefox**, bo prod userzy używają Chromium-based
przeglądarek (Edge, Chrome).

**Hierarchia run-mode (z SKILL.md Phase 7):**

| Tier | Mechanizm | Trigger eskalacji |
|------|-----------|-------------------|
| **1** | `playwright test --project=chromium` (test runner) | Domyślny dla M+ z UI |
| **2** | `playwright install chromium --with-deps` + retry Tier 1 | Tier 1 fail z "Executable doesn't exist" |
| **3** | `chrome-devtools-mcp` MCP plugin (real Chrome via DevTools Protocol) | Tier 1+2 fail / brak `@playwright/test` w deps |
| **4** | `playwright test --project=firefox` (lub webkit) | Wszystkie wyższe tiery fail; jawnie raportuj który browser w Phase 7 / Phase 8 CR |

#### 5.1 Tier 1: Playwright Chromium (preferowane)

```bash
# Zakładamy że @playwright/test + chromium są zainstalowane
npx playwright test --project=chromium tests/e2e/shelter-list.spec.ts
```

#### 5.2 Tier 2: Playwright CLI fallback (gdy brak Chromium)

Gdy `npx playwright test --project=chromium` zawodzi z `Executable doesn't exist`
(częste w piaskownicach CI / kontenerach bez headful supportu), użyj fallbacku:

```bash
# Krok 1: spróbuj zainstalować chromium przez Playwright CLI
#   UWAGA: nie pipuj przez `tee` jeśli chcesz odczytać exit code — pipe maskuje $?.
#   Albo użyj `${PIPESTATUS[0]}`, albo zapisz log bez pipe (jak niżej).
npx playwright install chromium --with-deps > /tmp/pw-install.log 2>&1
PW_INSTALL_STATUS=$?

# Krok 2a: jeśli install OK → re-run normalnie
if [ "$PW_INSTALL_STATUS" -eq 0 ]; then
  npx playwright test --project=chromium
else
  # Krok 2b: brak praw / brak APT → fallback na browser który JUŻ jest w cache.
  #   Playwright cache'uje binaria w ~/.cache/ms-playwright (Linux) lub
  #   ~/Library/Caches/ms-playwright (macOS). Sprawdzamy co realnie jest dostępne;
  #   firefox/webkit są zwykle preinstallowane w oficjalnych obrazach Playwright.
  PW_CACHE="${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}"
  [ -d "$HOME/Library/Caches/ms-playwright" ] && PW_CACHE="$HOME/Library/Caches/ms-playwright"

  AVAILABLE_BROWSER=""
  for b in firefox webkit chromium; do
    if ls -d "$PW_CACHE"/${b}-* >/dev/null 2>&1; then
      AVAILABLE_BROWSER="$b"; break
    fi
  done

  echo "FALLBACK: brak Chromium, używam ${AVAILABLE_BROWSER:-firefox}"
  npx playwright test --project="${AVAILABLE_BROWSER:-firefox}" \
    --trace=retain-on-failure --screenshot=only-on-failure
fi
```

> **Uwaga o `$?` po pipe** — w domyślnym bashu (bez `set -o pipefail`) `$?` zwraca exit code
> *ostatniego* polecenia w pipe (zwykle `tee`), nie pierwszego. Dlatego powyżej zapisujemy
> log przez redirect `> file 2>&1` zamiast `| tee`. Alternatywa: `${PIPESTATUS[0]}`.

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

#### 5.3 Tier 3: chrome-devtools-mcp (real Chrome przez MCP plugin)

Gdy brak `@playwright/test` w deps lub Tier 2 install zawodzi (np. korporacyjny proxy bez
dostępu do `playwright.azureedge.net`), użyj pluginu `chrome-devtools-mcp` —
**real Chrome** sterowany przez Chrome DevTools Protocol z agenta.

**Preflight:**

```bash
CDM_ENABLED="false"
if [ -f ~/.claude/settings.json ]; then
  CDM_ENABLED=$(jq -r '.enabledPlugins["chrome-devtools-mcp@claude-plugins-official"] // false' \
    ~/.claude/settings.json 2>/dev/null || echo "false")
fi
if [ "$CDM_ENABLED" != "true" ]; then
  echo "SKIP Tier 3 — plugin chrome-devtools-mcp niedostępny, eskalacja do Tier 4"
  # NIE używamy `exit` w skillu (sekcja referencyjna, nie samodzielny skrypt).
  # Agent powinien rozpoznać `SKIP Tier 3` i przejść do Tier 4 zamiast wykonywać
  # bloki MCP poniżej. W praktyce: ten blok kończy testing-protocol.md zakres
  # Tier 3 — kolejny blok kodu rozpoczyna Tier 4.
fi
```

**Realizacja AC-F z Tier 3 (per AC z DoD):**

```
mcp__plugin_chrome-devtools-mcp_chrome-devtools__new_page(url)        ← otwiera Chrome page
  ↓
mcp__plugin_chrome-devtools-mcp_chrome-devtools__navigate_page         ← navigate
mcp__plugin_chrome-devtools-mcp_chrome-devtools__fill_form / __click   ← interakcja
mcp__plugin_chrome-devtools-mcp_chrome-devtools__wait_for              ← poczekaj na element
  ↓
mcp__plugin_chrome-devtools-mcp_chrome-devtools__list_console_messages ← console errors = fail
mcp__plugin_chrome-devtools-mcp_chrome-devtools__list_network_requests ← 4xx/5xx = fail
mcp__plugin_chrome-devtools-mcp_chrome-devtools__take_screenshot       ← evidence dla CR/AC
mcp__plugin_chrome-devtools-mcp_chrome-devtools__take_snapshot         ← DOM snapshot (a11y tree)
```

**Reguły Tier 3:**

1. **Wynik = `manual::e2e` w trace matrix** — to nie automated regression suite, ale realne
   browser flow z dowodem (screenshot + console + network).
2. **Każdy AC-F z DoD = jeden flow + 1 screenshot** — bez screenshotu AC nie ma PASS verdict.
3. **Console errors = fail** — `list_console_messages` musi być pusta lub zawierać tylko
   znane warnings (zaloguj wyjątki w raporcie Phase 7).
4. **Network 4xx/5xx = fail** — `list_network_requests` filtruj po `status >= 400`; każdy
   nieoczekiwany blokuje gate (oczekiwane np. 401 dla testu błędnej auth = OK z notą).
5. **Headless OK** — plugin używa real Chrome, ale możesz sterować bez UI (operator widzi
   screenshoty zamiast headed window).
6. **Brak kompatybilności z `@playwright/test` spec files** — jeśli masz istniejące spec'i,
   Tier 3 ich NIE odpali; flowy musisz wywołać manualnie per AC.

**Anti-pattern:** Tier 3 jako primary E2E gdy `@playwright/test` jest w deps i działa.
Tier 1 zawsze szybszy (parallel, fixtures, retry, sharding) — Tier 3 to lifeboat dla
środowisk gdzie Playwright nie startuje, nie default.

#### 5.4 Tier 4: Playwright CLI z innym browser'em (firefox/webkit)

Ostatnia ścieżka — gdy Tier 1-3 fail (brak Chromium binary, brak install permissions,
brak `chrome-devtools-mcp` pluginu). Realizacja jest opisana w sekcji 5.2 (CLI fallback)
— ten sam mechanizm `playwright install` + automatyczna detekcja dostępnego browser'a
w cache i odpalenie testów na firefox/webkit.

**Reguły Tier 4:**

1. **Jawnie raportuj który browser** odpalił testy w Phase 7 i Phase 8 CR
   (`E2E: 5 passed via firefox — chromium niedostępny`).
2. **Trace + screenshot przy failure** (`--trace=retain-on-failure --screenshot=only-on-failure`)
   — bez headed Chromium dowód jest jedynym śladem do triagu.
3. **Dla L raportuj fallback explicit do usera** (jak w 5.2 reguła 5) — Chromium-specific
   bugi nie zostaną złapane.

> Tier 4 to ten sam runtime co Tier 1/2 (Playwright), różni się tylko `--project=firefox`
> zamiast `chromium`. Spec'i z Tier 1 nie wymagają zmian — Playwright projects są multi-browser.

#### 5.5 Co MUSI pokrywać E2E

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

---

## DAMP over DRY

> [!quote] DAMP w testach (`material_skill.md` §5, `since_skill.md` §5)
> „DAMP = Descriptive And Meaningful Phrases. W testach przedkładamy czytelność nad unikanie powtórzeń. Nadmiernie abstrakcyjne, »sprytne« testy generowane przez AI są niemożliwe do zdiagnozowania w przypadku awarii. Test musi czytać się jak specyfikacja."

Reguła nadrzędna nad DRY: jeśli test failnie, czytelnik powinien zrekonstruować scenariusz **z samego ciała testu**, bez skakania do helperów, fixture'ów i `beforeEach`.

### Checklist DAMP per test file

- [ ] **Test name czyta się jak zdanie**. `it('returns 404 when user is not authorized')` ✅, `it('test1')` ❌, `it('handles error')` ❌ (które error? co znaczy „handles"?).
- [ ] **Setup widoczny w teście** — żadnych `beforeEach` ukrywających kluczowy stan. Wyjątek: czyszczenie globalnych zasobów (DB, file handles) jest OK.
- [ ] **Brak helperów typu `createValidUser()` ukrywających pola** — pola wpływające na assertion muszą być widoczne w teście:
  ```ts
  // ❌ DRY ale nieczytelne
  const user = createValidUser();
  expect(canDelete(user)).toBe(false);  // dlaczego false?

  // ✅ DAMP
  const user = { id: 1, role: 'guest', isActive: true };
  expect(canDelete(user)).toBe(false);  // bo role=guest
  ```
- [ ] **Powtórzenia są OK, jeśli zwiększają diagnostykę**. 3 podobne testy z drobną różnicą bardziej czytelne niż jeden parametryzowany z `cases.map`.
- [ ] **Assertions wyrażają intencję, nie tylko fakt**: `expect(response.status).toBe(404)` + komentarz przy nietrywialnych assertach (`// 404 not 401 — user authenticated ale brak permission`).
- [ ] **Reguła końcowa**: jeśli test failnie, czy z samego output (test name + assertion + stack trace) można odtworzyć scenariusz **bez czytania reszty pliku**?

### Anti-patterny

| Anty-wzorzec | Dlaczego ❌ | Co zamiast |
|---|---|---|
| `setupTestEnvironment()` — magiczny helper budujący 5 obiektów | Ukrywa fixture data; failing test mówi „assertion failed" bez kontekstu którego pola brakuje | Inline setup, nawet kosztem 3× powtórzenia |
| `it('test case #1234')` | Numer ticketu w nazwie testu = test bez sensu po zamknięciu ticketu | Pełne zdanie opisujące zachowanie |
| Parametryzacja na 30 cases z subtelnymi różnicami | Failing case w środku — trudne do izolacji, halucynacje w debugowaniu | Rozbicie na grupy po 3-5 cases per `describe` |
| `beforeEach` budujący stub z 10 metod, z których test używa 2 | Test wygląda na zależny od 10 rzeczy, w rzeczywistości od 2 | Stub tylko tego, czego test używa, in-line |

### Granica DAMP — kiedy DRY wygrywa

DAMP nie znaczy „kopiuj wszystko zawsze". DRY wygrywa gdy:
- pomocnik jest **deterministyczny i niezawodny** (np. `await server.start()` w `beforeAll`);
- nie ukrywa danych assertion-relevant;
- powtórzenia byłyby >10× w jednym pliku (wtedy lepiej parametryzacja niż 10 kopii).

Reguła decyzyjna: „czy czytelnik failing testu zrozumie scenariusz?" Tak → OK. Nie → zwiększ inline-ness.

---

## Raw Log Requirement w DoD

> [!quote] Verification is non-negotiable (`material_skill.md` §4)
> „Status »Gotowe« bez artefaktu jest traktowany jako błąd systemu, a nie zakończenie zadania. (...) Subiektywne »wydaje się działać« jest definicyjnie odrzucane."

Phase 7 NIE akceptuje parafrazy modelu („testy przeszły", „wszystko zielone", „nie ma błędów"). Wymagany **surowy output** narzędzia testowego, kopiowany dosłownie z terminala.

### Wzorce akceptowalne

Każdy framework ma własny wzorzec output'u. Akceptowalne tylko surowy tekst z terminala:

| Framework | Wzorzec surowego logu | Kluczowe linie do wklejenia |
|---|---|---|
| Jest / Vitest | `Tests: X passed, 0 failed, Y total` | ostatnie 5 linii summary + lista failed (jeśli są) |
| pnpm test | tak samo jak runner pod spodem | runner output + exit code |
| Cargo (Rust) | `test result: ok. X passed; 0 failed; Z ignored` | linia summary + bloki `test path::name ... ok` |
| pytest | `=== X passed in Ys ===` + per-test `PASSED` | finałowe summary + lista PASSED/FAILED |
| go test | `ok package time` per package | wszystkie linie `ok` + `FAIL` (jeśli są) |
| Playwright | `X passed (Ys)` + per-test status | summary + reporter output |
| ESLint | `✖ 0 problems (0 errors, 0 warnings)` lub pusty exit 0 | finałowa linia z liczbą problemów |
| tsc --noEmit | brak output przy sukcesie, exit code 0 | wklej `echo $?` lub `tsc --noEmit && echo TYPECHECK_OK` |

### Komenda ekstrakcji

```bash
bash {baseDir}/dev/feature-planner-v3/scripts/extract-raw-log.sh "<test-command>"
# np.: bash .../extract-raw-log.sh "pnpm test --run"
```

Skrypt:
1. Uruchamia komendę.
2. Zapisuje pełny stdout+stderr do `docs/test-evidence/PLAN_NUM-<test>-<timestamp>.log`.
3. Wycina kluczowe linie (summary + last N failing) do `docs/test-evidence/PLAN_NUM-<test>-summary.md`.
4. Zwraca exit code komendy testowej.

### Co NIE jest akceptowalne

❌ „Testy przeszły, 42/42 passed."
❌ „Wszystkie testy zielone."
❌ Streszczenie: „Build OK, type-check OK, lint OK, unit OK."
❌ Status emoji bez logu: „✅ done".

✅ Pełny blok terminala z prefiksem komendy:

```
$ pnpm test --run
 RUN  v1.6.0 /repo

 ✓ tests/health.test.ts (3)
   ✓ returns 200 when DB is reachable
   ✓ returns 503 when DB is down
   ✓ includes timestamp in response

 Test Files  1 passed (1)
      Tests  3 passed (3)
   Start at  14:23:12
   Duration  823ms
```

### Hard rule

Phase 7 zamykasz **tylko** wklejając wymagane surowe logi w `docs/test-evidence/PLAN_NUM-summary.md`. Brak logu = brak DoD = brak Phase 8.

---

## Prove-It Pattern dla bugfix

> [!quote] Prove-It (`since_skill.md` §5)
> „Procedura blokująca natychmiastowe przepisywanie kodu po zobaczeniu loga błędu: 1. Stop — nie dotykaj kodu produkcyjnego. 2. Napisz test, który odtwarza buga i zawodzi. 3. Dowód RED → dopiero teraz pisz fix. 4. Test wraca do GREEN → fix zatwierdzony."

Wprowadza **NOWĄ Phase 6.5** w workflow dla wszystkich planów typu „bugfix" (gdy plan adresuje istniejącego buga, nie buduje nowego feature'a).

### Procedura Phase 6.5 (bugfix only)

1. **STOP — nie dotykaj kodu produkcyjnego.**
   - Brak edycji w `src/`, `app/`, `lib/` zanim test RED nie powstanie.
   - Jedyne dozwolone edycje: `tests/` (nowy plik testu) i `docs/` (notatki).

2. **Napisz test odtwarzający buga**:
   - Test celuje w ścieżkę kodu, w której bug się manifestuje.
   - Test używa danych z bug reportu / issue / log produkcyjnego.
   - Test **musi failować** z assertion error (nie z `TypeError` ani z błędu setup'u — to nie liczy się jako reproduce).

3. **Uruchom test → dowód RED**:
   ```bash
   bash {baseDir}/dev/feature-planner-v3/scripts/extract-raw-log.sh "pnpm test bugfix-PLAN_NUM"
   ```
   - Output musi pokazać `1 failed` z konkretnym assertion message.
   - Wklej dowód do `docs/test-evidence/PLAN_NUM-RED.log`.
   - Brak RED dowodu → STOP, test nie reprodukuje buga, popraw test.

4. **Dopiero teraz pisz fix**:
   - Edytuj kod produkcyjny.
   - Minimalna zmiana, która zielonkawi test.
   - Zakaz refactoringu „przy okazji" — to osobny plan.

5. **Test wraca do GREEN → fix zatwierdzony**:
   ```bash
   bash {baseDir}/dev/feature-planner-v3/scripts/extract-raw-log.sh "pnpm test bugfix-PLAN_NUM"
   ```
   - Output musi pokazać `1 passed` dla tego konkretnego testu.
   - Wklej dowód do `docs/test-evidence/PLAN_NUM-GREEN.log`.
   - Cała sweet (`pnpm test`) musi też pozostać GREEN — regresja w innych testach blokuje fix.

6. **Commit z dwoma artefaktami**:
   - `docs/test-evidence/PLAN_NUM-RED.log` (dowód reproducer'a)
   - `docs/test-evidence/PLAN_NUM-GREEN.log` (dowód fixa)

### Anti-pattern: „przepisuję od razu"

❌ **Najczęstsza patologia**: agent widzi log błędu → otwiera `src/foo.ts` → poprawia 3 linie → uruchamia `pnpm test` → testy zielone → ogłasza fix.

Problem:
- Nie wiemy, czy test, który pokazywał buga, naprawdę pokazywał buga (mógł nie istnieć).
- Nie wiemy, czy fix adresuje root cause czy symptom.
- Nie ma testu regresyjnego chroniącego przed powrotem buga.

✅ **Prove-It zmusza do dyscypliny**: napisz test reprodukujący → RED → fix → GREEN. Test pozostaje w sweet jako regression guard.

### Edge case — bug nie reprodukuje się w testach jednostkowych

Niektóre bugi (race conditions, network flakiness, kompliance z prawdziwym API) wymagają test integracyjnego lub E2E:

- **Integration** → test używa prawdziwego DB (testcontainer) / prawdziwego serwera HTTP (`supertest`).
- **E2E** → Playwright reproducer z konkretnym user flow.
- **Race condition** → test z `Promise.all` + intentional sleeps + assertion na sekwencję events.

Procedura Phase 6.5 pozostaje ta sama — RED → fix → GREEN — ale test trafia do `tests/integration/` lub `tests/e2e/` zamiast `tests/unit/`.

### Hard rule

Plan typu „bugfix" bez sekcji `## Prove-It evidence` w PR description (z dwoma blokami logów RED + GREEN) → Phase 8 review **blokuje merge** jako naruszenie protokołu testowego.
