---
title: Setup Protocol — bootstrap środowiska testowego
load-when: "Faza 0 SKILL.md — pierwszy run w projekcie LUB CI"
source:
  - https://playwright.dev/docs/intro
  - DOC/since_skill.md §6 (Fragile Operations)
---

# Setup — bootstrap Playwright + axe-core + pixelmatch

> Cel: idempotentny setup zależności i konfiguracji. Po pierwszym uruchomieniu `init-playwright.sh` projekt ma kompletny zestaw narzędzi QA.

## 1. Dependencies (instalowane przez init-playwright.sh)

```json
{
  "devDependencies": {
    "@playwright/test": "^1.42.0",
    "@axe-core/playwright": "^4.8.5",
    "pixelmatch": "^5.3.0",
    "pngjs": "^7.0.0"
  }
}
```

Plus binarki przeglądarek: `npx playwright install --with-deps chromium firefox webkit`.

**Dla CI:** `--with-deps` instaluje też system libraries (libnss3, libgbm, itd.) — wymagane na Ubuntu CI.

## 2. playwright.config.ts (z templates/)

Kluczowe ustawienia:

- `testDir: './tests'`
- `fullyParallel: true` (testy niezależne)
- `forbidOnly: !!process.env.CI` (zakaz `.only` w CI)
- `retries: process.env.CI ? 2 : 0`
- `reporter: [['html'], ['json', { outputFile: 'tests-results.json' }]]`
- `use: { trace: 'on-first-retry', screenshot: 'only-on-failure', video: 'retain-on-failure' }`
- `projects: [chromium, firefox, webkit]` — cross-browser
- `webServer: { command: 'npm run dev', url: APP_URL, reuseExistingServer: !process.env.CI }`

Pełny template: `templates/playwright.config.ts.tmpl`.

## 3. Detection projektu (smoke-test-runner też tego używa)

| Plik wskazujący stos | Build command | App start |
|---|---|---|
| `package.json` (node/npm) | `npm run build` | `npm run dev` lub `npm start` |
| `pnpm-lock.yaml` | `pnpm build` | `pnpm dev` |
| `Cargo.toml` (rust) | `cargo build --release` | `cargo run` |
| `go.mod` | `go build ./...` | `go run main.go` |
| `pyproject.toml` | `pip install -e .` | `python -m {module}` |

Jeśli niejednoznaczny → STOP, eskaluj.

## 4. Stop-gates fazy 0

- Node.js < 18 → eskalacja (Playwright 1.42+ wymaga 18+).
- `playwright.config.ts` istnieje + różni się od template → **NIE nadpisuj**, wczytaj i dopisz brakujące sekcje (a11y reporter, etc.).
- Browser binaries nie zainstalowane → `npx playwright install` LUB instrukcja dla user'a.

## 5. Exit criterion

```bash
npx playwright --version  # exit 0
npx playwright test --list  # exit 0 (nawet 0 testów to OK — config parsuje się)
test -f playwright.config.ts  # exists
```

Wszystkie 3 zielone → faza 0 zamknięta.
