---
title: Accessibility Protocol — axe-core WCAG 2.1 AA
load-when: "Faza 4 SKILL.md — po perf OK"
source:
  - https://github.com/dequelabs/axe-core
  - https://www.w3.org/WAI/WCAG21/quickref/
---

# Accessibility — WCAG 2.1 AA audit

> Cel: zero violations level **critical** i **serious** wg axe-core. Nie zaprzeczamy — accessibility to obowiązek prawny (EU EAA 2025) i etyczny.

## 1. Setup

```bash
npm install -D @axe-core/playwright
```

W teście:

```typescript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('home page has no a11y violations', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'best-practice'])
    .analyze();
  expect(results.violations).toEqual([]);
});
```

Pełen template: `templates/a11y.spec.ts.tmpl`.

## 2. Klasyfikacja violations (axe-core impact)

| Impact | Próg | Werdykt | Przykłady |
|---|---|---|---|
| **critical** | 0 | HARD FAIL | Brak alt text na image, brak `<label>` na input |
| **serious** | 0 | HARD FAIL | Niewystarczający kontrast 4.5:1, brak focus indicator |
| **moderate** | ≤ 3 | WARN | Heading hierarchy issues, niespójny lang |
| **minor** | ≤ 10 | WARN | Brak `lang` na html, deprecated attributes |

## 3. Najczęstsze violations (i fixy)

| Violation | Co znaczy | Fix |
|---|---|---|
| `color-contrast` | Tekst kontrast < 4.5:1 (normalny) lub < 3:1 (duży) | Zmień kolory, sprawdź przez `https://webaim.org/resources/contrastchecker/` |
| `image-alt` | `<img>` bez `alt` | Dodaj `alt=""` (decorative) LUB `alt="Opis"` (informational) |
| `label` | `<input>` bez `<label>` / `aria-label` | Dodaj `<label for="id">` LUB `aria-label="..."` |
| `link-name` | `<a>` bez tekstu (np. tylko ikona) | Dodaj `aria-label` LUB `<span class="sr-only">opis</span>` |
| `landmark-one-main` | Brak `<main>` na stronie | Owin treść w `<main>` |
| `region` | Treść poza landmark (header/nav/main/footer) | Dodaj odpowiednie landmarki |
| `aria-required-attr` | ARIA role bez wymaganych atrybutów | Sprawdź `aria-*` per role w WAI-ARIA spec |

## 4. Reguły specjalne

### Modal/Dialog

Każdy modal MUSI mieć:
- `role="dialog"` lub `<dialog>` element.
- `aria-labelledby="id-tytułu"` LUB `aria-label="Tytuł"`.
- Focus trap (Tab nie ucieka poza modal).
- Esc zamyka (test: `await page.keyboard.press('Escape'); await expect(modal).toBeHidden();`).

### Forms

- Każde pole input ma label LUB aria-label.
- Błędy walidacji: `aria-describedby` wskazuje na `<span class="error">`.
- Submit button NIE jest `<div onclick>` — zawsze `<button type="submit">`.

### Keyboard navigation

Test sprawdza:
```typescript
await page.keyboard.press('Tab');
await expect(page.locator(':focus')).toHaveAttribute('data-testid', 'first-focusable');
// ... iteruj przez wszystkie focusable ...
```

Brak focus visible (`:focus-visible` outline) = serious violation.

## 5. Evidence

```
state/evidence/sprint-{n}/a11y/
├── violations.json         # Pełna struktura axe-core: { violations: [...], passes: [...], incomplete: [...] }
├── violations-grouped.md   # Czytelnie pogrupowane per impact (critical → minor)
├── axe-report.html         # HTML report (open w browser)
└── metadata.json           # { produced_by, phase: "a11y", critical, serious, moderate, minor, passed }
```

`metadata.json` format:

```json
{
  "produced_by": "playwright-runner",
  "phase": "a11y",
  "ts": "2026-05-20T10:30:00Z",
  "violations_by_impact": {
    "critical": 0,
    "serious": 0,
    "moderate": 2,
    "minor": 5
  },
  "passed": true,
  "blocking_failures": []
}
```

## 6. Anti-Rationalization

| Wymówka | Riposta |
|---|---|
| „Mamy lighthouse, nie potrzebujemy axe" | **Odrzucono.** Lighthouse daje agreggated score, axe daje konkretne violations z WCAG ref. Oba potrzebne. |
| „Tylko 2 critical violations" | **Odrzucono.** Critical próg to 0. Każda critical = ślepy user nie skorzysta. |
| „Color contrast 4.4:1 — prawie OK" | **Odrzucono.** 4.5:1 to twardy próg WCAG AA. 4.4 = fail. |
| „Aria-label na całość, nie indywidualnie" | **Odrzucono.** Każdy interaktywny element ma własny accessible name. |
| „Mobile users nie używają screen reader" | **Odrzucono — fałszywa informacja.** VoiceOver/TalkBack są na 100% mobile. Mobile a11y = obowiązek. |
| „Test sprawdzi user manualnie" | **Odrzucono.** Manualne testy nie są reprodukowalne. axe-core jest. Use oba: axe automated + manual screen reader spot check. |

## 7. Exit criterion fazy 4

- `violations.json` istnieje.
- `metadata.json` ma `violations_by_impact.critical == 0 && serious == 0`.
- `axe-report.html` wygenerowany (do code review).
- Jeśli `moderate > 3` LUB `minor > 10` — WARN w qa-summary, ale faza passed.
