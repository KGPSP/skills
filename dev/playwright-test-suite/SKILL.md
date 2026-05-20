---
name: playwright-test-suite
description: Wykonuje pełen zestaw testów end-to-end aplikacji webowej przez Playwright CLI + Chrome DevTools MCP + axe-core (a11y) + pixel-diff (visual). Generuje strukturę evidence (screenshots, HAR, traces, raporty) zgodną z DoD agent-teams-builder. Użyj jako Evaluator-Runtime w pętli Generator-Ewaluator LUB jako standalone QA dla pojedynczego projektu.
trigger:
  - "uruchom testy playwright"
  - "test aplikacji"
  - "smoke test"
  - "accessibility audit"
  - "performance regression"
  - "/test"
  - "/playwright"
do-not-trigger-for:
  - "napisz test jednostkowy" # to robi Generator wewnątrz swojego workflow
  - "wytłumacz co robi playwright" # tylko dokumentacja
  - "popraw selector w istniejącym teście" # 1-liniowa zmiana
  - eksploracja kodu testów
  - "test API bez UI" # użyj curl/httpie bezpośrednio
model: claude-opus-4-7
allowed-tools: ['Bash', 'Read', 'Write', 'Glob', 'Grep', 'Task']
sources:
  - DOC/material_skill.md
  - DOC/since_skill.md
  - DOC/agent-teams-generator-ewaluator.md (§4 Rubryka, §6 Tooling QA)
version: v1.0.0
size-limit: 500-lines-hard
---

# playwright-test-suite — full-stack E2E QA harness

> [!quote] Anti-Laziness preamble
> **Nie optymalizuj pod szybkość.** Test który "przeszedł lokalnie" bez evidence nie istnieje. Bez screenshot/HAR/trace w `state/evidence/` — werdykt jest deklaracją, nie dowodem.

> [!important] 5 Non-negotiables (material_skill.md §8)
> 1. Uwidaczniaj założenia przed budowaniem (test który mockuje API == nie testuje produkcji).
> 2. Zatrzymaj się przy konflikcie wymagań (test specyfikuje X, kontrakt mówi Y → STOP).
> 3. Wybieraj nudne rozwiązania (`page.click('button[type=submit]')` > custom XPath).
> 4. Dostarczaj twardy dowód, nie deklarację (screenshot zamiast "wygląda OK").
> 5. Dotykaj tylko tego, o co cię poproszono (test nie modyfikuje kodu produkcyjnego).

> [!warning] Strefa pracy
> Ten skill **NIE modyfikuje** kodu aplikacji. Jeśli test wykryje błąd → zapisuje evidence + zwraca werdykt. Naprawa = robota Generatora (np. w pętli agent-teams-builder).

---

## Pozycjonowanie

| Tryb użycia | Kto wywołuje | Co produkuje |
|---|---|---|
| **Standalone QA** | User w głównym oknie (`/test`) | Raport w `qa-report/` + werdykt pass/fail |
| **Dependency Evaluatora** | sub-agent `evaluator` z agent-teams-builder przez Task tool | Evidence w `state/evidence/sprint-{n}/` zgodnie z kontraktem sprintu |
| **CI/CD** | GitHub Actions / pre-merge hook | JUnit XML + JSON reports |

---

## Procedura (5 faz)

### Faza 0 — Bootstrap środowiska testowego

1. Uruchom `scripts/init-playwright.sh {project-dir}` — sprawdza Node.js ≥18, instaluje `@playwright/test`, `@axe-core/playwright`, `pixelmatch`, `pngjs`. Tworzy `playwright.config.ts` z `templates/playwright.config.ts.tmpl`.
2. **Walidacja:** `npx playwright --version` exit 0 + browsers installed (`npx playwright install --with-deps`).
3. **Stop-gate:** jeśli `playwright.config.ts` istnieje — **nie nadpisuj**, wczytaj i sprawdź spójność z `templates/`.

**Exit criterion:** `npx playwright test --list` zwraca exit 0 (nawet jeśli 0 testów — config się parsuje).

### Faza 1 — Smoke testy

1. Uruchom `scripts/run-smoke.sh` — sekwencja:
   - Build clean (`npm run build` || `cargo build` || `go build` || `pip install -e .`).
   - App start na `APP_URL` (default: `http://localhost:3000`).
   - `curl -fsS $APP_URL` → HTTP 2xx/3xx.
   - `npx playwright test smoke.spec.ts` (z `templates/smoke.spec.ts.tmpl`).
2. **Evidence:** `state/evidence/sprint-{n}/smoke.log` + `smoke.metadata.json`.

**Exit criterion:** wszystkie 4 kroki exit 0. Brak smoke = brak prawa wchodzenia w kolejne fazy.

### Faza 2 — UI Interactions (Playwright CLI)

1. Uruchom `scripts/run-ui-tests.sh {sprint-n}` — czyta `state/contracts/sprint-{n}.json` (jeśli istnieje), generuje `tests/ui-*.spec.ts` z szablonu, uruchamia.
2. **Pokrycie:** klawiatura (Enter/Esc/Arrow/Tab), mysz (click/dblclick/dragAndDrop), forms (input/select/file upload), persistencja (F5 → localStorage).
3. **Evidence:** PNG screenshots pre/post każdej interakcji + DOM snapshots + trace.zip.

**Exit criterion:** `npx playwright test --reporter=json` zwraca exit 0 LUB raport `tests-results.json` ma jasno wymienione fail (z metadata).

### Faza 3 — Chrome DevTools (perf, network, console)

1. Uruchom `scripts/run-devtools-trace.sh` — używa Chrome DevTools MCP (lub Playwright `trace`).
2. **Co mierzy:**
   - **Network HAR** — wszystkie żądania + kolejność (Hyrum check).
   - **Console errors** — `page.on('console', msg => ...)` → zero `error`/`warning`.
   - **Performance metrics** — TTI, LCP, FCP, CLS, INP (Core Web Vitals).
   - **Memory** — heap snapshot przed/po.
3. **Evidence:** `state/evidence/sprint-{n}/network.har`, `console.log`, `perf-metrics.json`.

**Exit criterion:** `console errors == 0` + `LCP < 2500ms` + brak request blocked/4xx/5xx.

### Faza 4 — Accessibility audit (axe-core)

1. Uruchom `scripts/run-a11y.sh` — `npx playwright test a11y.spec.ts` z `@axe-core/playwright`.
2. **Standard:** WCAG 2.1 Level AA. Reguły: `wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`, `best-practice`.
3. **Evidence:** `state/evidence/sprint-{n}/a11y-violations.json` (struktura axe-core) + zrzut violations w czytelnym formacie.

**Exit criterion:** `violations.length == 0` dla `impact: critical|serious`. `moderate` i `minor` → WARN, nie FAIL.

### Faza 5 — Visual regression (pixel-diff)

1. Uruchom `scripts/run-visual-diff.sh {baseline-branch}` — porównuje screenshoty current vs baseline (z `git show {branch}:assets/baseline/*.png` LUB lokalny `assets/baseline/`).
2. **Tool:** Playwright `toHaveScreenshot()` ALBO `pixelmatch` przez Node script.
3. **Threshold:** maxDiffPixels: 100 (domyślne); konfigurowane per kontrakt.
4. **Evidence:** `state/evidence/sprint-{n}/visual-diff/{view}.png` (current vs baseline vs diff).

**Exit criterion:** każdy widok pre/post ma diff ≤ threshold. Większy diff → screenshot + manual review LUB regeneracja baseline (świadoma decyzja).

---

## Anti-Rationalization

| Wymówka | Riposta (blokada) |
|---|---|
| „Smoke wystarczy, UI tests są ciężkie" | **Odrzucono.** Smoke = aplikacja startuje. UI tests = aplikacja DZIAŁA. To 2 osobne weryfikacje. |
| „Testuję headless, bez screenshots — szybciej" | **Odrzucono. Non-negotiable #4 (twardy dowód).** Bez screenshot/HAR/trace w `state/evidence/` werdykt jest deklaracją, nie dowodem. |
| „Mock'uję API w teście" | **Odrzucono. Non-negotiable #1 (założenia).** Test integracyjny mockuje API = nie testuje produkcji. Jawnie zgłoś założenie LUB użyj real API. |
| „Pominę axe-core, mamy lighthouse" | **Odrzucono.** Lighthouse mierzy ogólnie, axe-core daje konkretne violations z WCAG ref. Oba potrzebne. |
| „Visual regression jest flaky" | **Odrzucono w tej formie.** Flaky = zła konfiguracja `maxDiffPixels`/`threshold`. Skalibruj na 5 runach. |
| „Test failed → przepisuję selektor" | **Odrzucono.** Najpierw zrozum DLACZEGO selektor nie matchuje (DOM się zmienił? Async?). Patrz `references/playwright-ui-protocol.md §debug`. |
| „Test specyfikuje X, kontrakt mówi Y — wybiorę bardziej elastyczne" | **Odrzucono. Non-negotiable #2 (konflikt → STOP).** Konflikt między testem a kontraktem = eskalacja do parent agenta (zwykle Evaluator z agent-teams-builder), NIE samodzielna interpretacja. Dopisz do `state/blockers.md`. |
| „LCP 3.5s → akceptowalne dla naszej domeny" | **Odrzucono bez ADR.** Core Web Vitals to twardy próg Google. Wyjątek wymaga `docs/adr/` z uzasadnieniem biznesowym. |
| „Test sprawdza implementację, nie zachowanie" | **Odrzucono. Non-negotiable #3 (nudne rozwiązania).** Black-box. Test wciska klawisz i sprawdza co user widzi, nie wewnętrzne Redux/Vuex state. |
| „Modyfikuję test żeby przeszedł zamiast naprawiać kod" | **Odrzucono. Non-negotiable #5 (Scope Discipline).** Test jest specyfikacją kontraktu. Modyfikacja testu = renegocjacja kontraktu. Bug w kodzie? Naprawia Generator. |
| „Wyłączam ten test, jest dziwny" | **Odrzucono (Chesterton's Fence).** Sprawdź `git log -p {test-file}` zanim wyłączysz. Dziwny test często = ślad realnego buga. Wymagany ADR dla `.skip`. |
| „Test bez assertion, sprawdza tylko że nie crashuje" | **Odrzucono (Beyoncé Rule).** Test bez `expect(...)` to no-op. Każda zmiana w kodzie zasługuje na test z assertion. |
| „Wyekstrahowałem helper z 5 testów (DRY)" | **Odrzucono w testach (DAMP > DRY).** Test musi czytać się jak specyfikacja. Abstrakcja = nieczytelność przy awarii. Cofnij. |
| „Używam `page.locator('.btn')` bo pamiętam że tak było w Playwright 1.30" | **Odrzucono.** Halucynacja API. Wywołaj `mcp__context7__get-library-docs` z `libraryID: "/microsoft/playwright"` przed setup'em. Patrz `dev/agent-teams-builder/references/library-currency-protocol.md`. |
| „axe-core ma stabilny API od lat" | **Odrzucono.** axe-core 4.8+ wprowadziło WCAG 2.2 rules. Sprawdź context7 dla aktualnych reguł i ich `impact` levels. |

Pełna tabela + Google DNA wymówki (Hyrum/Chesterton/Beyoncé/DAMP): `references/playwright-ui-protocol.md §5`.

---

## Google DNA (material_skill.md §5)

| Zasada | Operacyjnie w skillu |
|---|---|
| **Hyrum's Law** | HAR check kolejności requestów (§3 chrome-devtools-protocol). Test sprawdza nie tylko status code, ale i sekwencję wywołań. |
| **Chesterton's Fence** | Zakaz wyłączania testów (`.skip`, `test.fixme`) bez `git log` + ADR. Dziwny test często = ślad realnego buga. |
| **Beyoncé Rule** | Każdy publiczny export aplikacji ma odpowiadający test Playwright. Heurystyka walidacji w playwright-runner. |
| **DAMP over DRY** | Test musi czytać się jak specyfikacja. Zakaz `testHelper(page, A, B, C)` — preferuj jawne kroki nawet z duplikacją. |

Szczegóły: `references/playwright-ui-protocol.md §5 (Google DNA w testach)`.

---

## Definition of Done

- [ ] `npx playwright --version` exit 0 + browsers installed.
- [ ] Smoke: build clean + app responds + smoke.spec.ts passed.
- [ ] UI interactions: każde kryterium kontraktu typu `functional`/`layout` ma odpowiadający test z evidence.
- [ ] Chrome DevTools: `console errors == 0`, Core Web Vitals w progu.
- [ ] Accessibility: `violations[impact in critical|serious] == 0`.
- [ ] Visual regression: pixel-diff ≤ threshold per view.
- [ ] **Beyoncé Rule:** każdy publiczny export aplikacji w `src/` ma odpowiadający test w `tests/`.
- [ ] **DAMP w testach:** test czyta się jak specyfikacja (brak nadmiernych helperów ukrywających kroki).
- [ ] **Chesterton check:** żaden test nie ma `.skip`/`.fixme` bez ADR w `docs/adr/`.
- [ ] **Library currency:** breadcrumb `library_currency_checked` dla `@playwright/test` i `@axe-core/playwright` (faza 0) — `source` przez context7 lub fallback chain.
- [ ] Evidence w `state/evidence/sprint-{n}/` z metadata.json per plik.
- [ ] `state/evidence/sprint-{n}/qa-summary.json` zagregowany — pass/fail per faza.
- [ ] Werdykt JSON w kontrakcie sprintu (jeśli wywoływany z agent-teams-builder).

---

## Progresywne ładowanie

> **Reguła:** nie ładuj wszystkiego na raz. Token budget L2 (SKILL.md) ≤ 5000 znaków. Każdy plik z `references/` ładowany **tylko** gdy spełniony warunek poniżej.

| Warunek | Plik do załadowania |
|---|---|
| Faza 0 (bootstrap) | `references/setup-protocol.md` |
| Faza 1 (smoke) | `references/smoke-protocol.md` |
| Faza 2 (UI interactions) — Google DNA, debug guide | `references/playwright-ui-protocol.md` |
| Faza 3 (perf/network) | `references/chrome-devtools-protocol.md` |
| Faza 4 (a11y) | `references/accessibility-protocol.md` |
| Faza 5 (visual) | `references/visual-regression-protocol.md` |
| Wywoływany z agent-teams-builder | `references/agent-teams-integration.md` |

---

## Integracja z agent-teams-builder

Gdy wywoływany przez sub-agenta `evaluator` z agent-teams-builder:

1. Evaluator wywołuje przez Task tool:
   ```
   Task(
     description: "Run playwright suite for sprint 2",
     subagent_type: "playwright-runner",
     prompt: "Uruchom 5 faz testowych dla sprintu 2 wg kontraktu state/contracts/sprint-2.json. Evidence do state/evidence/sprint-2/."
   )
   ```
2. `playwright-runner` (sub-agent z `agents/playwright-runner.md`) czyta kontrakt, mapuje kryteria na fazy, uruchamia testy.
3. Generuje `state/evidence/sprint-{n}/qa-summary.json` zgodny ze schematem oczekiwanym przez Evaluatora.
4. Wraca z werdyktem do Evaluatora — Evaluator dopisuje do kontraktu sprintu.

Patrz `references/agent-teams-integration.md`.

---

## Calibration

| Faza | Strefa | Rygor |
|---|---|---|
| 0 (bootstrap) | Fragile | Komendy z runbooka, exit 0 wymagany po każdej |
| 1-2 (smoke + UI) | Strefa wolna | Tests autorskie wg kontraktu, kreatywność w scenariuszach |
| 3-4 (perf + a11y) | Fragile | Twarde progi (LCP, WCAG), brak interpretacji |
| 5 (visual diff) | **Destruktywne dla baseline** | Plan-Validate-Execute przed `--update-snapshots` |

---

## Sources

- [DOC/material_skill.md](../../DOC/material_skill.md) — Process over Prose, DoD, 5 Non-negotiables.
- [DOC/since_skill.md](../../DOC/since_skill.md) — token budget, kebab-case, Plan-Validate-Execute.
- [DOC/agent-teams-generator-ewaluator.md](../../DOC/agent-teams-generator-ewaluator.md) §4 (rubryka 4-filarowa), §6 (tooling QA).
- [Playwright docs](https://playwright.dev/) — best practices CLI.
- [axe-core](https://github.com/dequelabs/axe-core) — WCAG rules engine.
- Sibling skill: `dev/agent-teams-builder/` — orkiestrator który wywołuje ten skill.
