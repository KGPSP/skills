---
title: Chrome DevTools Protocol — perf, network, console
load-when: "Faza 3 SKILL.md — po UI tests OK"
source:
  - https://playwright.dev/docs/api/class-tracing
  - Core Web Vitals: https://web.dev/vitals/
---

# Chrome DevTools — perf + network + console

> Cel: zmierzyć **runtime** zachowanie aplikacji — czy szybko ładuje, czy console nie krzyczy, czy network nie ma niespodzianek. Wszystkie progi **binarne**.

## 1. HAR (HTTP Archive) — kolejność requestów

Playwright zapisuje HAR przez:

```typescript
test('captures HAR', async ({ context }) => {
  await context.tracing.start({ name: 'sprint-2', screenshots: true, snapshots: true });
  // ... interakcje ...
  await context.tracing.stop({ path: 'state/evidence/sprint-2/perf/trace.zip' });
});
```

Alternatywa: `--video=on --trace=on` w `playwright.config.ts`.

### Co sprawdzać w HAR

| Kryterium | Sprawdź |
|---|---|
| **Kolejność API (Hyrum)** | POST /save → 201 → GET /verify → 200. Nie odwrotnie. |
| **Brak 4xx/5xx niespodziewanych** | Każdy 4xx/5xx ma odpowiadające kryterium kontraktu które tego oczekuje (np. C-02: pusty body → 400). |
| **Brak blocked requests** | `status: "blocked"` w HAR = problem CORS/CSP/AdBlock. |
| **Brak duplicate requests** | Ten sam URL z tym samym body wywołany 2× w 100ms = N+1 lub bug. |

## 2. Console messages

```typescript
test('zero console errors', async ({ page }) => {
  const errors: string[] = [];
  page.on('console', msg => {
    if (msg.type() === 'error') errors.push(msg.text());
  });
  // ... interakcje ...
  expect(errors).toEqual([]);
});
```

### Progi

| Poziom | Próg | Werdykt |
|---|---|---|
| `error` | == 0 | HARD FAIL |
| `warning` | == 0 (default) lub ≤ N z kontraktu | WARN lub FAIL |
| `info`/`log`/`debug` | bez limitu | informacyjne |

**Wyjątki dla `warning`:** muszą być jawnie wymienione w kontrakcie (`"acceptable_warnings": ["DevTools failed to parse SourceMap"]`).

## 3. Core Web Vitals

Mierzenie przez `web-vitals` library injected do strony LUB Playwright `performance.timing`.

### Progi Google (twarde)

| Metryka | Próg "Good" | Co to mierzy |
|---|---|---|
| **LCP** (Largest Contentful Paint) | < 2500ms | Główny element widoczny |
| **FCP** (First Contentful Paint) | < 1800ms | Pierwszy pixel narysowany |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Skoki layoutu (bad UX) |
| **INP** (Interaction to Next Paint) | < 200ms | Responsywność na interakcję |
| **TTFB** (Time to First Byte) | < 800ms | Server response |

### Override per kontrakt

Kontrakt może podnieść próg (np. dla aplikacji z heavy bundle):

```json
{
  "performance_thresholds": {
    "LCP_ms": 3000,
    "ADR_ref": "docs/adr/0042-relaxed-lcp.md"
  }
}
```

Brak ADR przy override → walidator odrzuca.

## 4. Memory profiling (opcjonalne)

```typescript
const session = await page.context().newCDPSession(page);
await session.send('HeapProfiler.enable');
const beforeSnapshot = await session.send('HeapProfiler.takeHeapSnapshot');
// ... 30s interakcji ...
const afterSnapshot = await session.send('HeapProfiler.takeHeapSnapshot');
```

Sprawdza memory leaks — wzrost heap > 50MB po 30s symulowanego użycia.

## 5. Evidence struktury

```
state/evidence/sprint-{n}/perf/
├── network.har         # JSON, wszystkie requesty
├── console.log         # tekst, każda linia: {ts} [{level}] {message}
├── vitals.json         # { LCP, FCP, CLS, INP, TTFB } + thresholds + passed per metric
├── heap-diff.txt       # różnica memory snapshots (opcjonalne)
├── trace.zip           # Playwright trace (browser perf, screenshots, snapshots)
└── metadata.json       # { produced_by, phase: "devtools", passed, blocking_failures }
```

## 6. Anti-Rationalization

| Wymówka | Riposta |
|---|---|
| „Console warnings są normalne w dev mode" | **Odrzucono.** Testuj BUILD output, nie dev. `npm run build && npm run preview`. |
| „LCP 3.2s — to tylko trochę nad progiem" | **Odrzucono bez ADR.** 2500ms to twardy próg Google. Każde przekroczenie wymaga uzasadnienia. |
| „N+1 queries naprawimy w sprincie X+1" | **Odrzucono.** HAR pokazuje N+1 → blokuj merge. Naprawa w tym sprincie LUB feature flag wyłączający feature. |
| „Memory leak — to library issue" | **Odrzucono.** Library issue lub nie — i tak musisz workaroundować. ADR + workaround LUB pivot. |

## 7. Exit criterion fazy 3

- `vitals.json` zawiera wszystkie 5 metryk + flag `passed` per metryka.
- `console.log` filtrowany przez `level=error` ma 0 wpisów.
- `network.har` walidowany pod kątem kontraktu (kolejność, brak niespodziewanych statusów).
- `metadata.json` ma `passed: true|false` + ewentualne `blocking_failures: ["LCP_above_threshold", ...]`.
