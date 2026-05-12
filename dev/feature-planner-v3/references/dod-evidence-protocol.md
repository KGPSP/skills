---
name: dod-evidence-protocol
type: reference
parent: feature-planner-v3
source: DOC/material_skill.md §4
description: Formaty akceptowanych dowodów per typ AC (Functional / Non-functional / Constraint). Egzekwowane w Phase 5 (plan musi deklarować format) i Phase 7 (artefakt musi być dostarczony przed approval gate).
---

# Definition of Done — Evidence Protocol

> [!quote] material_skill.md §4
> Status „Gotowe" bez artefaktu jest traktowany jako **błąd systemu**, a nie zakończenie zadania.

## Filozofia

W v3 **deklaracja agenta jest halucynacją** dopóki nie zostanie podparta surowym artefaktem. Ten protokół definiuje:

1. Co jest akceptowalnym dowodem per typ AC.
2. Jakie wzorce surowych outputów są wymagane.
3. Co jest **anty-dowodem** (parafraza, judgment) i automatycznie odrzucane.

---

## Sekcja 1 — AC-F (Functional)

**Co to:** Wymaganie funkcjonalne — endpoint zwraca X, UI pokazuje Y, command wykonuje Z.

**Wymagany dowód:** raw log testu **PLUS** (dla M+ UI) screenshot.

### Wzorce akceptowalne

| Stack | Komenda | Format outputu |
|---|---|---|
| Node + Jest | `pnpm test path/to.test.ts` | `Tests: N passed, 0 failed` |
| Node + Vitest | `pnpm test:vi path/to.test.ts` | `✓ N tests passed` |
| Python + pytest | `pytest -v path/to/test_x.py` | `N passed in X.XXs` |
| Rust + cargo | `cargo test test_name` | `test result: ok. N passed; 0 failed` |
| Go | `go test -v ./pkg/...` | `--- PASS: TestX (0.00s)` per test |

### Pełen wzorzec dowodu (przykład Node)

```log
$ pnpm test src/health.test.ts
PASS src/health.test.ts
  GET /health
    ✓ returns 200 OK (12ms)
    ✓ returns content-type application/json (3ms)
    ✓ returns body { status: "ok" } (4ms)

Tests:       3 passed, 3 total
Suites:      1 passed, 1 total
Time:        0.847 s
```

### Screenshot (M+ UI)

- Format: PNG, viewport 1920×1080 (desktop) + 375×667 (mobile).
- Nazwa: `{plan-id}-AC-F-{NN}-{browser}.png`.
- Lokalizacja: `{baseDir}/plans/screenshots/`.
- Wymóg per AC-F osobny screenshot pokazujący wymagany stan UI.

---

## Sekcja 2 — AC-N (Non-functional)

**Co to:** Wymaganie niefunkcjonalne — performance, reliability, security, accessibility.

### Sub-typ: Performance

**Komenda:** `sh scripts/extract-raw-log.sh --cmd "pnpm test:perf"` lub Lighthouse / k6 / wrk.

**Wzorzec:**

```log
$ k6 run perf/health.js
     execution: local
        scenarios: (100.00%) 1 scenario, 50 max VUs
        duration: 30s

     http_req_duration..............: avg=12.4ms  p(95)=24.1ms  p(99)=38.2ms
     http_req_failed................: 0.00%  ✓ 0  ✗ 50000
     http_reqs......................: 50000  1666.6/s
```

Próg sukcesu definiowany w planie (Phase 4): np. `p(95) < 50ms`.

### Sub-typ: Security

**Komenda:** `npm audit --production` / `cargo audit` / `safety check`.

**Wzorzec sukcesu:**

```log
$ npm audit --production
found 0 vulnerabilities in 234 scanned packages
```

### Sub-typ: Reliability (chaos / fault injection)

**Wzorzec:** trace + recovery log + circuit breaker state.

### Sub-typ: Accessibility

**Komenda:** `npx playwright test --grep @a11y` z `@axe-core/playwright`.

**Wzorzec:** zero violations w axe scan.

### Edge case: AC-N bez automatu

Jeśli AC-N nie ma testu automatycznego (np. „UX feels responsive") → wymagana `Verification: <manual-step>` z dowodem (screenshot + opis kroków manual).

---

## Sekcja 3 — AC-C (Constraint)

**Co to:** Ograniczenie / inwariant — type safety, lint rule, runtime guard, naming convention.

### Wymagany dowód: output linter / type-check / runtime assertion

| Constraint type | Komenda | Format dowodu |
|---|---|---|
| TypeScript strict | `tsc --noEmit` | Exit 0, brak `error TS` |
| ESLint rule | `pnpm lint --max-warnings 0` | Exit 0 |
| Rust borrowck | `cargo check --release` | Exit 0 |
| Python typing | `mypy src/` | `Success: no issues found in N files` |
| Runtime guard | Test z `expect(...).toThrow()` | Test passed |

### Wzorzec

```log
$ tsc --noEmit
$ echo "Exit: $?"
Exit: 0
```

Wraz z linijką pliku/regułą której constraint dotyczy (jeśli applicable):

```typescript
// src/api/users.ts:42
type UserId = string & { readonly __brand: 'UserId' };  // AC-C-01: branded type enforced
```

---

## Sekcja 4 — Komendy referencyjne v3

Skrypt `extract-raw-log.sh` jest gotowym narzędziem do generowania dowodu:

```bash
sh {baseDir}/dev/feature-planner-v3/scripts/extract-raw-log.sh \
   --cmd "pnpm test src/health.test.ts" \
   --lines 30
```

Output: gotowy blok Markdown z sygnaturą `Status: PASSED|FAILED` + komenda + exit code.

Coverage check (Beyoncé Rule 1:1):

```bash
sh {baseDir}/dev/feature-planner-v3/scripts/check-ac-coverage.sh \
   --plan {baseDir}/plans/<N>-<slug>.md
```

Output: JSON `{"total_ac": N, "covered": M, "missing": [...], "status": "ok|missing"}`.

---

## Sekcja 5 — Anty-dowody (automatycznie odrzucane)

Te wzorce **nie są dowodem** i powodują blokadę Phase 7 approval:

| Anty-dowód | Dlaczego nie | Co zrobić zamiast |
|---|---|---|
| „Testy przeszły" | Parafraza, brak komendy, brak exit code | Wklej raw output |
| „Wydaje się działać" | Subiektywna deklaracja | Wklej trace lub log |
| „Build kompiluje się czysto" | Brak komendy + exit | `sh verify-build-clean.sh` raw output |
| „Sprawdziłem manualnie, OK" | Brak artefaktu manual check | Screenshot + opis kroków |
| „Logika jest poprawna semantycznie" | LLM judgment, nie dowód | Wklej runtime trace |
| Streszczenie loga („3 testy passed") | Parafraza | Wklej dosłownie z konsoli |
| Screenshot bez kontekstu | Brak związku z AC | Nazwa pliku `{plan}-AC-F-{NN}` |
| Test output z `--silent` lub `--quiet` | Brak listy testów | Re-run bez flag silencing |

---

## Sekcja 6 — Integracja z fazami

### Phase 4 (plan writing)

DoD section MUSI mieć dla każdego AC:

```markdown
| AC-ID | Komenda dowodu | Próg sukcesu | Lokalizacja artefaktu |
|---|---|---|---|
| AC-F-01 | `pnpm test src/health.test.ts` | `3 passed, 0 failed` | `plans/<N>-evidence/AC-F-01.log` |
| AC-N-01 | `k6 run perf/health.js` | `p(95) < 50ms` | `plans/<N>-evidence/AC-N-01.log` |
| AC-C-01 | `tsc --noEmit` | `Exit 0` | `plans/<N>-evidence/AC-C-01.log` |
```

### Phase 5 (approval gate)

- [ ] Każdy AC w planie ma kolumnę `Komenda dowodu`.
- [ ] Każdy AC ma `Próg sukcesu`.
- [ ] Każdy AC ma deklarowaną lokalizację artefaktu.

Brak → gate blokuje.

### Phase 7 (test gate)

1. Uruchom każdą `Komenda dowodu` z planu.
2. Wklej raw output (przez `extract-raw-log.sh`).
3. Porównaj z `Próg sukcesu` — match required.
4. Zapisz artefakt do deklarowanej lokalizacji.
5. `sh check-ac-coverage.sh` → status `ok`.

### Phase 8 (review)

PR description zawiera sekcję `Evidence` z linkami do artefaktów (lub inline'd raw logs dla małych).

### Phase 9 (ADR)

ADR commitowane wraz z folderem `evidence/` (artefakty z Phase 7).

---

## Sekcja 7 — Edge case: ralph-loop

W autonomous mode każda iteracja generuje własny set artefaktów:

```
plans/<N>-evidence/
├── iter-001/
│   ├── AC-F-01.log
│   ├── AC-F-02.log
│   └── build.log
├── iter-002/
│   └── ...
```

Ralph-loop **NIE może** reużywać artefaktów z poprzedniej iteracji. Każda iteracja = świeży dowód.

---

## Sekcja 8 — Anti-pattern: „evidence-after-the-fact"

Agent czasem chce dokleić dowód PO zakończeniu pracy („zapomniałem zapisać log, ale testy przeszły, wkleję teraz z pamięci"). **Niedopuszczalne.**

Reguła: artefakt **musi być wygenerowany w momencie wykonywania komendy**, nie rekonstruowany. Jeśli zapomniał — re-run komendy, nowy log.

---

## Reguła końcowa

> [!warning] Bez surowego artefaktu zadanie nie istnieje
> Wszystkie inne formy raportowania (deklaracja, parafraza, streszczenie) są traktowane jako halucynacja. Phase 7 nie przepuszcza bez evidence per AC.
