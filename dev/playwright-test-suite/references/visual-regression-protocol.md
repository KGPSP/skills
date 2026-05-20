---
title: Visual Regression Protocol — pixel-diff vs baseline
load-when: "Faza 5 SKILL.md — po a11y OK"
source:
  - https://playwright.dev/docs/test-snapshots
  - https://github.com/mapbox/pixelmatch
---

# Visual Regression — pixel-perfect porównanie

> Cel: wykryć **niezamierzone** zmiany wizualne (nakładanie się tekstu, przesunięte elementy, zmiany koloru po zmianie nie-CSS pliku). Każdy diff > threshold = blokada lub świadoma decyzja o nowym baseline.

## 1. Dwa podejścia

### Podejście A — Playwright built-in (`toHaveScreenshot()`)

```typescript
test('home page matches baseline', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('home.png', { maxDiffPixels: 100 });
});
```

Pierwsze uruchomienie tworzy baseline w `tests/snapshots/`. Kolejne porównują.

**Pro:** zero dependencies, działa od razu.
**Con:** mniej kontroli nad threshold per region.

### Podejście B — Pixelmatch (custom script)

```bash
node scripts/visual-diff.js baseline.png current.png diff.png
```

Pixelmatch zwraca liczbę różnych pixeli. Można customizować:
- Threshold per pixel (0-1, default 0.1).
- Regiony ignorowane (np. timestamps w UI).
- Antialiasing handling.

**Pro:** pełna kontrola.
**Con:** więcej kodu glue.

Skill używa **A jako default**, **B jako opcja** dla skomplikowanych przypadków.

## 2. Workflow

### Pierwsze uruchomienie (init baseline)

```bash
npx playwright test --update-snapshots
```

Tworzy `tests/snapshots/{view}-{platform}.png`. **Te pliki idą do git** (są częścią specyfikacji).

### Kolejne uruchomienia (verify)

```bash
npx playwright test
```

Porównuje current vs baseline. Diff > threshold = test fail.

### Świadoma regeneracja baseline

**TYLKO** przez Plan-Validate-Execute:

1. **Plan:** wypisz co konkretnie się zmieniło wizualnie i dlaczego (commit message powinien wyjaśnić).
2. **Validate:** code review widzi nowy baseline w PR diff.
3. **Execute:** `npx playwright test --update-snapshots {view}` (per view, nie globalnie).

**Antywzorzec:** `--update-snapshots` w CI automatycznie. Wtedy regression nigdy nie zostanie wykryta.

## 3. Threshold tuning

| Próg | Kiedy używać |
|---|---|
| `maxDiffPixels: 0` | Pixel-perfect (rzadko realne — antialiasing nie pozwala) |
| `maxDiffPixels: 100` | **Default** — tolerancja na sub-pixel rendering |
| `maxDiffPixels: 500` | Aplikacje z dynamicznym contentem (charts, gradients) |
| `maxDiffPixelRatio: 0.01` | 1% pikseli różne — dla full-page screenshots |

**Mask dynamic content:**

```typescript
await expect(page).toHaveScreenshot('dashboard.png', {
  mask: [page.locator('.timestamp'), page.locator('.live-counter')]
});
```

## 4. Co testować visually

| Element | Czy testować |
|---|---|
| **Full page screenshots** | TAK (per route) |
| **Komponenty UI** (button, modal, card) | TAK (per state: default/hover/disabled) |
| **Layouts responsywne** | TAK (per viewport: mobile, tablet, desktop) |
| **Charts / data visualizations** | Z maskowaniem osi dat |
| **Animacje** | Wyłącz animacje w teście: `page.addStyleTag({ content: '*{transition:none!important;animation:none!important}' })` |
| **Loading states** | Tylko jeśli stable (nie podczas async fetch) |

## 5. Evidence

```
state/evidence/sprint-{n}/visual/
├── {view-name}/
│   ├── current.png        # screenshot z bieżącego run
│   ├── baseline.png       # kopia tests/snapshots/{view}.png
│   ├── diff.png           # diff highlightowany (czerwone pixele)
│   └── diff-stats.json    # { pixels_different, threshold, ratio, passed }
└── metadata.json          # { produced_by, phase: "visual", views_tested, views_passed, views_failed }
```

`diff-stats.json` per view:

```json
{
  "view": "home-desktop",
  "pixels_different": 47,
  "total_pixels": 2073600,
  "ratio": 0.0000227,
  "threshold_pixels": 100,
  "threshold_ratio": 0.001,
  "passed": true
}
```

## 6. Anti-Rationalization

| Wymówka | Riposta |
|---|---|
| „Po prostu uaktualnij baseline, kod się zmienił" | **Odrzucono.** Update baseline = świadoma decyzja w PR. Code reviewer MUSI zobaczyć nowy screenshot i potwierdzić. |
| „Visual diff jest flaky" | **Często TAK** — sub-pixel rendering, font hinting, GPU. Fix: użyj **stałego viewport** + **disable animations** + **mask timestamps**. Jeśli nadal flaky, zwiększ `maxDiffPixels` po 5 runach kalibracji. |
| „Mamy 50 widoków, visual tests trwają wieczność" | **Tylko widoki krytyczne** dla UX. Lista w kontrakcie. Nie testuj wszystkiego. |
| „Diff to tylko 200 pixeli, akceptowalne" | **Tylko jeśli kontrakt na to pozwala** (`maxDiffPixels: 200`). Inaczej fail. |
| „Tylko desktop, mobile nie testuję" | **Odrzucono.** Per-viewport snapshots: mobile (375x667), tablet (768x1024), desktop (1920x1080). |
| „Update snapshots po każdym refactorze automatycznie" | **Odrzucono.** Refactor który zmienia visual = nie refactor, to feature change. Decyzja w PR review. |

## 7. Exit criterion fazy 5

- Każdy view z listy w kontrakcie ma 3 pliki w `state/evidence/sprint-{n}/visual/{view}/`.
- Każdy view ma `diff-stats.json` z `passed: true|false`.
- `metadata.json` agreguje views_passed / views_failed.
- Jeśli jakikolwiek view ma `passed: false` → faza fail, ale evidence wystarcza Evaluatorowi do decyzji o pivot/fix/baseline-update.

## 8. Strefa pracy

Visual regression jest **destruktywna dla baseline** (`--update-snapshots` nadpisuje pliki w `tests/snapshots/`).

**Reguła:** `playwright-runner` **NIE robi** `--update-snapshots` automatycznie. Zawsze zwraca diff jako evidence i pozostawia decyzję parent agentowi/userowi.
