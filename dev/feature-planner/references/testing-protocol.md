# references/testing-protocol.md

Protokół dla Phase 7 — **Testing**. Cel: udowodnić, że implementacja spełnia *Definition of Done*
z planu, **zanim** wejdziemy w Phase 8 (Code Review). Test gate to twardy checkpoint:
nie idziemy w review z czerwonymi testami warstwy wymaganej dla danego rozmiaru featuru.

> **Zasada nadrzędna:** każdy test mapuje się na konkretny AC z Phase 8.1. Jeśli piszesz test,
> który nie mapuje się na żaden AC — masz albo brakujący AC, albo niepotrzebny test. Decyduj.

---

## Matryca S/M/L × 4 warstwy

| Rozmiar | Unit | Integration | E2E playwright | E2E chrome-devtools-mcp | Komentarz |
|---------|------|-------------|----------------|--------------------------|-----------|
| **S** | ✅ wymagany | ✅ wymagany | ⏭️ skip | ⏭️ skip | 1 plik / surgical change |
| **M** | ✅ wymagany | ✅ wymagany | ✅ wymagany | ⏭️ skip | typowy feature |
| **L** | ✅ wymagany | ✅ wymagany | ✅ wymagany | ✅ wymagany | auth/DB/UI krytyczny |

**Skip rules:**

- Pure refactor (zero zmiany behavior) → tylko warstwy istniejące w analogu, nie dodawaj nowych typów.
- Migracja bez logiki (rename kolumny) → integration z round-trip read/write zamiast unit.
- Czysty backend bez UI → E2E playwright/chrome-devtools-mcp = N/A (oznacz `n/a — backend-only`).

---

## Definicje warstw (w kontekście stack'u PSP)

### Unit
**Co testujemy:** czystą logikę, helpery, transformacje, walidacje (zod/yup), reducery, business rules.
**Czego NIE testujemy:** integracji z DB, HTTP, frameworkiem.
**Tooling:** vitest / jest / pytest.
**Speed:** < 1s na plik.

```bash
# Node
npm test -- src/lib/validators/shelter.test.ts
# Python
pytest tests/unit/test_shelter_validator.py -v
```

### Integration
**Co testujemy:** boundary między warstwami — route handler ↔ service ↔ repo ↔ DB,
auth middleware na konkretnym endpoincie, migracje (round-trip read/write po migracji),
CRS/topology na warstwie GIS.
**Tooling:** vitest + supertest / pytest + httpx / Prisma test client.
**DB:** prawdziwa baza testowa (nie mock — patrz CLAUDE.md feedback memory).

```bash
# Next.js API route
npm test -- tests/integration/api/shelters.test.ts
# Migration round-trip
npm run db:test-migration
```

### E2E playwright
**Co testujemy:** user-facing flow w przeglądarce — golden path + 1–2 edge cases.
**Wymagane dla M+:** dla featurów z UI.
**Tooling:** `@playwright/test`, fixture: zalogowany user PSP.

```bash
npx playwright test --project=chromium tests/e2e/shelter-list.spec.ts
```

### E2E chrome-devtools-mcp
**Co testujemy:** rzeczy, których playwright nie złapie — performance (LCP, CLS, INP),
memory leaks, network waterfall, a11y audit (web.dev), responsive na mobile/tablet.
**Wymagane dla L:** features auth/DB/UI krytyczne, panele kierownictwa, mobile-first widoki.
**Tooling:** chrome-devtools-mcp skille — `lighthouse_audit`, `performance_start_trace`,
`take_snapshot`, `list_console_messages`.

---

## Kolejność wykonania (test gate)

1. **Unit** — najszybsze, wyłapują regresje pure logic. Jeśli czerwone → fix przed dalej.
2. **Typecheck + build** — `npm run typecheck && npm run build` (lub `tsc --noEmit`, `mypy .`).
3. **Integration** — sprawdzają boundaries. DB musi być postawiona.
4. **E2E playwright** (M+) — golden path + 1 boundary + 1 failure.
5. **E2E chrome-devtools-mcp** (L) — perf/a11y/responsive jako finalna walidacja UX.

**Pełna suite (`npm test` bez filtra)** — uruchom dopiero gdy:
- Phase 6 dotknął kod współdzielony (utils/, types/, schema globalny), LUB
- konwencje repo wymagają (np. CI gate na PR), LUB
- ≥ 3 warstwy zielone i chcesz finalny smoke.

---

## Mapowanie testów na AC

W Phase 7 zbieraj nazwy testów per zadanie:

```
Zadanie 3: Filter shelters by powiat
  test::unit  — `validators/shelter-filter.test.ts::"rejects invalid powiat code"`
  test::int   — `api/shelters.test.ts::"GET ?powiat=mazowieckie returns filtered list"`
  test::e2e   — `e2e/shelter-list.spec.ts::"selects powiat in dropdown"`
```

W Phase 8.1 te `test::name` wpisujesz do **Trace matrix** (AC ↔ test). Każdy `[MUST]` musi
mieć minimum 1 mapowanie albo udokumentowaną procedurę manualną.

**Anti-pattern:** test bez nazwy zgodnej z AC (np. `it('works')`). Nazwa testu = subject AC.

---

## Reporting (format)

Po każdej warstwie raportuj zwięźle:

```text
Verification — Phase 7 (rozmiar M):
- `npm test -- src/lib/shelter`: 12 passed
- `npm run typecheck`: passed
- `npm test -- tests/integration/shelters`: 8 passed
- `npx playwright test shelter-list.spec.ts`: 3 passed (golden + 2 edge)
- `npm run build`: passed (Vite bundle warning: ekran wojewódzki 312kB — pre-existing)
Test gate: ✅ wszystkie wymagane warstwy zielone → Phase 8
```

**Co MUSI być w raporcie:** komenda, wynik, istotne ostrzeżenia, oznaczenie `pre-existing` jeśli
warning był przed zmianą.

---

## Failure handling

Gdy test zawiedzie:

1. **Przeczytaj failure** — full stacktrace, nie tylko ostatnia linia.
2. **Zidentyfikuj przyczynę** — czy wynika z Twojej zmiany, czy z istniejącego stanu.
3. **Fix wąski test** → rerun (`vitest run --filter`, `pytest -k`) → zielone.
4. **Re-run całej warstwy** żeby sprawdzić, czy fix nie złamał innego testu.
5. **Pre-existing failures** — oznacz tylko z dowodem (commit hash, gdzie weszło): np.
   `tests/legacy/old.test.ts: failed (pre-existing od d4a82f1, niezwiązane z planem #PLAN_NUM)`.

**Anti-pattern:** ukrywanie pre-existing failures bez dowodu. Code review wyłapie i odrzuci.

---

## Test gate — twardy checkpoint przed Phase 8

```bash
# Phase 7 closing check
echo "Test gate dla planu #${PLAN_NUM}:"
echo "  - Unit:           ${UNIT_RESULT}"
echo "  - Integration:    ${INT_RESULT}"
echo "  - E2E playwright: ${PW_RESULT:-n/a}"
echo "  - E2E chrome-mcp: ${CMC_RESULT:-n/a}"
[ "$UNIT_RESULT" = "PASS" ] && [ "$INT_RESULT" = "PASS" ] || { echo "❌ GATE BLOCKED"; exit 1; }
echo "✅ GATE OPEN — przejście do Phase 8 (Code Review)"
```

**Brak Phase 8 dopóki gate nie otwarty.** To nie jest zalecenie — to invariant workflow.
