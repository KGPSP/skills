---
title: Playwright UI Protocol — fizyczne testy interakcji
load-when: "Faza 2 SKILL.md — po smoke OK"
source:
  - https://playwright.dev/docs/best-practices
  - DOC/agent-teams-generator-ewaluator.md §4.2 (testy klawiatury, layout)
---

# Playwright UI — fizyczne testy zachowania

> Cel: zweryfikować że aplikacja **reaguje na akcje użytkownika** zgodnie z kontraktem. Black-box. Testy sprawdzają co user widzi/słyszy, NIE wewnętrzny state.

## 1. Zakres pokrycia

| Kategoria | Co testować | Tool |
|---|---|---|
| **Klawiatura** | Enter, Esc, Tab, Arrow keys, Space, Backspace, modifier combos (Ctrl+S) | `page.keyboard.press()` |
| **Mysz** | Click, dblclick, right-click, hover, drag-drop, scroll | `page.click()`, `page.dragAndDrop()` |
| **Forms** | Input typing, select dropdown, file upload, checkbox, radio | `page.fill()`, `page.selectOption()`, `setInputFiles()` |
| **Persistencja** | F5 → state z localStorage / sessionStorage | `page.reload()` + `page.evaluate(() => localStorage)` |
| **Layout** | BoundingBox per element, brak nakładania, responsywność | `page.locator().boundingBox()` na viewports |

## 2. Mapowanie kryterium kontraktu → test

| Kryterium kontraktu (przykład) | Test scenario |
|---|---|
| `C-03: Wciśnięcie Enter w polu name wywołuje submit` | `await page.locator('input[name=name]').press('Enter'); await expect(page).toHaveURL(/.*\/success/)` |
| `C-04: Form bounding box nie przecina header (1920x1080)` | `const a = await form.boundingBox(); const b = await header.boundingBox(); expect(a.y).toBeGreaterThan(b.y + b.height)` |
| `C-12: F5 → stan formularza odtworzony z localStorage` | `await page.fill('input', 'foo'); await page.reload(); await expect(page.locator('input')).toHaveValue('foo')` |
| `C-14: Pusty input → EmptyState component` | `await expect(page.locator('[data-testid=empty-state]')).toBeVisible()` |

## 3. Best practices (z playwright.dev)

✅ **Tak:**
- `getByRole('button', { name: 'Save' })` — semantic locators
- `await expect(locator).toBeVisible()` — auto-waiting
- `page.screenshot({ path: 'state/evidence/.../C-XX-after.png' })` po każdej akcji
- `await page.context().tracing.start({ screenshots: true, snapshots: true })`

❌ **Nie:**
- `page.locator('div:nth-child(3) > .btn-primary')` — fragile CSS selectors
- `await page.waitForTimeout(2000)` — magic waits, używaj `waitForSelector` / `waitForLoadState`
- `if (await element.isVisible()) { ... }` — używaj `expect(...).toBeVisible()`
- Mock'owanie API (chyba że kontrakt wprost na to pozwala)

## 4. Anti-Rationalization (UI tests)

| Wymówka | Riposta |
|---|---|
| „Test sprawdza implementację" | **Black-box.** Test wciska klawisz, sprawdza co user widzi. Nie testuj wewnętrznych Redux/Vuex state. |
| „Mockuję wszystkie API żeby test był szybki" | **Odrzucono.** Test integracyjny musi hit'ować real API. Jeśli to nieuniknione → użyj `MSW` + warning. |
| „`waitForTimeout(5000)` bo flaky" | **Odrzucono.** Flaky = brak auto-wait. Użyj `await expect(locator).toBeVisible({ timeout: 5000 })`. |
| „Selector za pomocą XPath bo dynamic class" | **Odrzucono.** Dodaj `data-testid` do produkcji + użyj semantic locators (`getByRole`). |
| „Test pominę bo działa lokalnie" | **Odrzucono.** "Działa lokalnie" ≠ działa. Wklej `npx playwright show-report` URL. |
| „Generator może modyfikować test żeby przeszedł" | **Odrzucono.** Test jest specyfikacją kontraktu. Modyfikacja testu = renegocjacja kontraktu. |

## 5. Debug guide

Gdy test fail:

1. **Otwórz trace.zip:** `npx playwright show-trace state/evidence/sprint-{n}/ui/{C-XX}/trace.zip`.
2. Trace pokaże każdy krok + screenshot + DOM snapshot + network.
3. Najczęstsze przyczyny:
   - **Race condition** — element pojawia się po asynchronicznym fetch. Fix: `await expect(...).toBeVisible({ timeout: 10000 })`.
   - **Selector nie pasuje** — DOM się zmienił. Otwórz trace, sprawdź jak DOM wygląda w momencie kroku.
   - **Modal/overlay blokuje click** — `await page.locator('.modal').waitFor({ state: 'hidden' })` przed kliknięciem.
   - **Animacja** — Playwright klika podczas animacji. Wyłącz animacje w teście: `page.addStyleTag({ content: '* { transition: none !important; }' })`.

## 6. Evidence per kryterium

Dla każdego `C-XX` z kontraktu:

```
state/evidence/sprint-{n}/ui/{C-XX}/
├── before.png          # screenshot przed akcją
├── after.png           # screenshot po akcji
├── trace.zip           # full Playwright trace
├── dom-snapshot.html   # DOM po akcji
└── metadata.json       # { produced_by, criterion_id, passed, observation, tool: "playwright" }
```

Brak któregokolwiek = artefakt niekompletny.

## 7. Exit criterion fazy 2

- Każde `type: "functional"|"layout"` kryterium z kontraktu ma katalog `ui/{C-XX}/` z 5 plikami.
- `metadata.json` każdego kryterium ma `passed: true|false` + `observation`.
- `tests-results.json` z Playwright reporter jest spójny z metadata.
